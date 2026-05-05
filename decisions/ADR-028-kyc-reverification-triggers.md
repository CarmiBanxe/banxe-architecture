# ADR-028 — KYC Re-verification Triggers

**Status:** Proposed (2026-05-05)
**Author:** Architecture WG / Compliance lead
**Closes:** G-KYC-01 + G-KYC-02 (canonical), V-03 (HANDOFF-2026-05-04)
**Linked:** ADR-LCY-01 (canonical lifecycle FSM), ADR-016 (AI-plane PII/AML routing),
ADR-027 (audit-trail durability), INVARIANTS I-32/I-33, MASTER-PLAN Track A2,
FCA MLR 2017 Reg.27/28, FCA SS21/3

---

## Context

Banxe's customer lifecycle FSM (ADR-LCY-01) manages the `prospect → onboarding →
kyc_pending → active → dormant → suspended → closed → offboarded` flow. Initial KYC
is enforced as a guard on the `ACTIVATE` transition in `lifecycle_engine.py`. However,
there is currently no mechanism to trigger KYC re-verification after a customer reaches
`ACTIVE` state — even when material risk factors change post-onboarding.

FCA MLR 2017 Reg.27 requires ongoing monitoring of business relationships; Reg.28
requires re-application of CDD measures when "the customer's circumstances change."
Five categories of post-onboarding change mandate re-verification: (1) high-risk role
grant (e.g., AML officer, signatory authority), (2) beneficial owner mutation, (3)
sanctions match on an active customer, (4) jurisdiction change (country of residence),
and (5) expiry of the 24-month periodic review window. SS21/3 §3.2 further requires
that trigger events be logged in an immutable audit trail.

Today, none of these five trigger types is wired in code. `services/hitl/org_roles.py`
is a gate-checker (no role-mutation emitter); `services/kyc/kyc_port.py` has no
`trigger_reverification()` method; `services/events/event_bus.py` has `BanxeEventType`
with KYC/payment events but no `ROLE_CHANGED` or `BENEFICIAL_OWNER_CHANGED` type;
and `lifecycle_observer.py` observes FSM transitions but not role mutations. The result
is a silent compliance gap: a customer granted signatory authority post-onboarding
receives no KYC re-check.

---

## Decision Drivers

1. **Regulatory — MLR 2017 Reg.27/28 + FCA SS21/3**: Re-application of CDD is mandatory
   on material change; each trigger event must produce an immutable audit record.
2. **FSM consistency (ADR-LCY-01)**: The canonical lifecycle FSM cannot be broken; any
   new `KYC_RE_VERIFICATION_REQUIRED` state must be inserted as a valid transition
   respecting the existing edge table.
3. **Auditability (ADR-027, I-24, I-32)**: Every trigger must emit an audit event to
   ClickHouse via the durable audit trail; silent failure (fail-open) is unacceptable.
4. **Latency / blast radius**: KYC re-verification must not block the role-grant
   call-path synchronously; the pipeline must be async with respect to the triggering
   operation.
5. **Test coverage (G-KYC-02)**: Each trigger type must be covered by a CI fixture
   using `InMemory` stubs; no external dependencies in unit tests.

---

## Considered Options

### Option (a) — Extend existing Domain Event Bus (wire existing infrastructure)

`services/events/event_bus.py` already provides `BanxeEventType`, `DomainEvent`,
`InMemoryEventBus`, and `RabbitMQEventBus` with `publish/subscribe`. This option
adds the missing event types (`ROLE_CHANGED`, `BENEFICIAL_OWNER_CHANGED`,
`JURISDICTION_CHANGED`) to `BanxeEventType`, wires emitters into the service layer
that performs role-mutations (a new `OrgRoleService`), and adds a subscriber in
`lifecycle_observer.py` that calls `kyc_port.trigger_reverification(customer_id, reason)`
upon receipt.

| Dimension | Assessment |
|-----------|-----------|
| Regulatory | Full — each event logged via existing bus; ClickHouse consumer adds I-24 |
| Complexity | Low — infrastructure already exists; gap is event types + emitters |
| FSM consistency | Safe — observer calls engine transition `KYC_RE_VERIFICATION_REQUIRED` |
| ClickHouse coupling | Via ADR-027 audit trail; decoupled from trigger path |
| Test coverage | High — `InMemoryEventBus` already usable as test stub |

**Risk:** `InMemoryEventBus` is synchronous (in-process); a slow KYC subscriber can
block the publish call in tests. RabbitMQEventBus swallows handler errors in a daemon
thread — subscriber failures are silent without instrumentation (add to G-OBS-01).

---

### Option (b) — Direct method calls at role-mutation site

Each function that mutates a role (future `OrgRoleService.assign()`) directly calls
`kyc_port.trigger_reverification(customer_id, reason)` before returning. No event
bus required.

| Dimension | Assessment |
|-----------|-----------|
| Regulatory | Full — synchronous call guarantees trigger fires or caller fails |
| Complexity | Minimal — no new infrastructure |
| FSM consistency | Safe — caller controls trigger directly |
| ClickHouse coupling | Via KYC port (must log) |
| Test coverage | High — mock `kyc_port` in role-mutation tests |

**Risk:** Role-mutation and KYC are tightly coupled; adding a new subscriber requires
modifying the mutation site. Synchronous KYC call blocks the role-grant request path.

---

### Option (c) — Outbox pattern (transactional event durability)

Role-mutation writes both the DB state-change and an outbox record in the same
PostgreSQL transaction. A background worker polls the outbox, publishes `ROLE_CHANGED`
events to the bus, and marks records consumed. Combines with option (a) on the
subscribe/dispatch side.

| Dimension | Assessment |
|-----------|-----------|
| Regulatory | Very high — event cannot be lost even if bus is down at mutation time |
| Complexity | High — outbox table, migration, drain worker, deduplication |
| FSM consistency | Safe — event consumed asynchronously by observer |
| ClickHouse coupling | Minimal — event bus is intermediary |
| Test coverage | Moderate — drain worker needs separate test harness |

**Risk:** Outbox drain worker is a new background process; duplicate delivery requires
idempotent subscribers. Adds a new PostgreSQL migration.

---

### Option (d) — CDC / PostgreSQL trigger (database-level change capture)

A PostgreSQL trigger on `role_assignments` fires an event via `pg_notify`; a LISTEN
worker picks it up and dispatches to KYC. No application-layer changes needed.

| Dimension | Assessment |
|-----------|-----------|
| Regulatory | Moderate — relies on DB trigger reliability; hard to unit-test |
| Complexity | Moderate — trigger SQL, LISTEN worker |
| FSM consistency | Safe — downstream subscriber manages FSM transition |
| ClickHouse coupling | Via subscriber |
| Test coverage | Low — DB triggers not exercised by InMemory stubs |

**Risk:** Domain logic in DB triggers violates Protocol DI. Trigger SQL is not
type-checked, not covered by Ruff/mypy, and requires live PostgreSQL in CI.
Rejected per `10-backend-python.md` "no hidden global state" rule.

---

### Option (e) — Scheduled poll (periodic re-verification scan)

A cron job periodically scans `active` customers for role changes since last scan
and queues re-verification. No real-time trigger.

| Dimension | Assessment |
|-----------|-----------|
| Regulatory | Low for high-risk triggers — latency unacceptable |
| Complexity | Low — single cron script |
| FSM consistency | Safe — bulk FSM transitions in batch |
| Test coverage | Easy — deterministic time injection |

**Risk:** FCA SS21/3 §3.2 requires "prompt" re-verification on material change;
a periodic poll is non-compliant for CRITICAL triggers (sanctions hit, MLRO grant).
Acceptable only for the 24-month review (LOW severity).

---

## Trade-off Summary

| Option | Regulatory | Complexity | Decoupling | Testability |
|--------|-----------|-----------|------------|------------|
| (a) Extend event bus | High | Low | High | High |
| (b) Direct call | High | Min | Low | High |
| (c) Outbox | Very High | High | High | Moderate |
| (d) CDC/pg_notify | Moderate | Moderate | High | Low |
| (e) Periodic poll | Low* | Min | High | High |

*Option (e) fails regulatory threshold for CRITICAL/HIGH triggers.

---

## Recommendation

**Option (a) — Extend existing Domain Event Bus**, with **option (c) Outbox** applied
selectively to CRITICAL-severity triggers only.

Rationale:
- Option (a) leverages existing `services/events/` infrastructure with minimum
  complexity; the gap is limited to event types + emitters + subscriber wiring.
- Option (b) creates tight coupling that blocks future subscriber addition; rejected
  in an architecture that already has a working event bus.
- Option (c) outbox complexity is justified for CRITICAL triggers (sanctions hit,
  MLRO/AML_OFFICER grant) where regulatory cost of event loss is maximal; overkill
  for MEDIUM/LOW severity.
- Option (d) violates Protocol DI and is untestable with InMemory stubs.
- Option (e) valid only for LOW-severity 24-month review; all other triggers require
  near-real-time dispatch.

**Combined phased approach (a + selective c):**
- **CRITICAL** (sanctions_hit_active, role_grant_high_risk): outbox write in same
  DB transaction → drain worker → event bus → subscriber.
- **HIGH** (beneficial_owner_change, jurisdiction_change): event bus only
  (InMemoryEventBus in tests, RabbitMQ in prod).
- **LOW** (24_month_review): scheduled cron (option e is acceptable).

---

## Trigger Taxonomy

| Trigger ID | Source | Severity | FSM transition | KYC tier |
|-----------|--------|----------|---------------|----------|
| `role_grant_high_risk` | `OrgRoleService.assign()` where role ∈ {MLRO, AML_OFFICER, SIGNATORY} | CRITICAL | `ACTIVE → KYC_RE_VERIFICATION_REQUIRED` | Full re-KYC |
| `beneficial_owner_change` | UBO mutation on corporate account | HIGH | `ACTIVE → KYC_RE_VERIFICATION_REQUIRED` | Full re-KYC (KYB) |
| `sanctions_hit_active` | OpenSanctions/Yente match on active customer | CRITICAL | `ACTIVE → SUSPENDED` then re-entry | Full re-KYC + freeze |
| `jurisdiction_change` | `country_of_residence` field update | MEDIUM | `ACTIVE → KYC_RE_VERIFICATION_REQUIRED` | Risk re-score |
| `24_month_review` | Scheduled timer (cron) | LOW | `ACTIVE → KYC_RE_VERIFICATION_REQUIRED` | Sample re-KYC |

---

## Consequences

### Positive

- FCA MLR 2017 Reg.27/28 ongoing-monitoring obligation met for all 5 trigger categories.
- `BanxeEventType` enum is extended (additive — no breaking effect on existing subscribers).
- `KYCWorkflowPort.trigger_reverification()` added as new Protocol method; existing
  adapters implement as stub until wired.
- `lifecycle_observer.py` gains `on_role_changed()` handler — no changes to existing
  observer methods.
- New FSM state `KYC_RE_VERIFICATION_REQUIRED` added to ADR-LCY-01 as an addendum;
  existing tests unaffected (no edges removed).

### Negative / Risks

- Outbox pattern for CRITICAL triggers adds a PostgreSQL migration and drain worker;
  failure of drain worker is silent unless instrumented (add to G-OBS-01 scope).
- `KYC_RE_VERIFICATION_REQUIRED` adds edges to the FSM transition test matrix;
  each new edge requires a guard test (ADR-LCY-01 consequence §3).
- `OrgRoleService` is a new service layer; `org_roles.py` is gate-checker only and
  must not be conflated with a role-mutation service.

---

## Implementation Plan

1. **Add event types** — extend `BanxeEventType` in `services/events/event_bus.py`
   with `ROLE_CHANGED`, `BENEFICIAL_OWNER_CHANGED`, `JURISDICTION_CHANGED`,
   `KYC_REVERIFICATION_TRIGGERED`.

2. **Create `OrgRoleService`** — new `services/hitl/org_role_service.py`:
   `assign_role(customer_id, role, granted_by)` writes to `role_assignments` table
   + writes outbox record (CRITICAL) or publishes event (HIGH) via `EventBusPort`.

3. **Add `trigger_reverification()` to `KYCWorkflowPort`** — new method in Protocol;
   implement `NotImplementedError` stub in `MockKYCWorkflow`; future `BallerineAdapter`.

4. **Wire subscriber in `lifecycle_observer.py`** — add `on_role_changed()` to
   `LifecycleObserverPort` Protocol and `InMemoryLifecycleObserver`; register as
   subscriber for `BanxeEventType.ROLE_CHANGED` on event bus startup.

5. **Add FSM state** — add `KYC_RE_VERIFICATION_REQUIRED` to `CustomerState` enum
   and `_FSM` edge table; add `REQUIRE_REVERIFICATION` to `LifecycleEvent`;
   update ADR-LCY-01 as addendum.

6. **Add CI fixtures (G-KYC-02)** —
   `tests/test_customer_lifecycle/test_kyc_reverification_triggers.py`:
   one test per trigger using `InMemoryEventBus` + `InMemoryKYCPort`; assert
   `kyc_port.trigger_reverification()` called with correct `customer_id` + `reason`.

7. **Outbox migration** — `alembic/versions/XXXX_add_role_event_outbox.py`:
   `role_event_outbox(id, customer_id, event_type, payload JSONB, created_at,
   processed_at nullable)`; migration spec per `60-migrations.md` template.

---

## Decision

**Pending** — operator acceptance required after review of the Recommendation.
Implementation begins only after operator confirms chosen option and phasing.
ADR-LCY-01 must be updated as an addendum when new FSM state is accepted.
