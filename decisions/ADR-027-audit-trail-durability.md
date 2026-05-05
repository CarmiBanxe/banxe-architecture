# ADR-027 — Audit-Trail Durability Strategy

**Status:** Proposed (2026-05-05)
**Author:** Architecture WG
**Closes:** G-CASS-01 (canonical), V-06 (HANDOFF-2026-05-04)
**Linked:** ADR-016 (AI-plane PII/AML routing), INVARIANTS I-32/I-33, IL-CANON-05, MASTER-PLAN Track A1

---

## Context

Banxe's primary FCA CASS 15 evidence chain runs through ClickHouse: every
reconciliation result, shortfall alert, and FIN060 submission event is written to
`banxe.safeguarding_audit` via `src/safeguarding/audit_trail.py`. The current
implementation calls ClickHouse synchronously via `httpx.post()` with a 5-second
timeout (line 173). On any exception — network timeout, ClickHouse restart, OOM
eviction — `AuditTrail.log()` swallows the error, logs to stderr, and returns
`False` (fail-open). The calling reconciliation engine receives no error signal and
completes successfully, unaware the audit event was silently lost.

ClickHouse on evo1 (192.168.0.72) is a single-instance container with no replica
and no write-ahead buffer above the OS filesystem layer. A brief ClickHouse outage
(rolling update, OOM, disk pressure) creates a window where compliance events are
missing from the audit log — violating FCA CASS 15 §15.10 (evidence of daily
reconciliation) and DORA Art.14(2) (integrity of operational records). The
`services/safeguarding-engine/app/services/audit_logger.py` implementation is a
stub (`raise NotImplementedError("Implement in Phase 3.6")`), so the
safeguarding-engine microservice currently has no production audit path at all.

---

## Decision Drivers

1. **Regulatory evidence chain (FCA CASS 15 §15.10 + MLR 2017 Reg.28)** — every
   reconciliation and shortfall must be durably recorded; a gap in the audit log
   is a reportable compliance failure.
2. **DORA Art.14(2)** — ICT operational records must be complete and tamper-proof;
   silent event loss during an infrastructure incident violates this requirement.
3. **RTO/RPO** — ClickHouse maintenance windows are expected; audit durability must
   survive a 30-minute ClickHouse outage without data loss.
4. **Operational complexity** — any buffer or queue mechanism must be operable by a
   single-engineer team; no exotic infra dependencies.
5. **Existing test coverage gap** — no test exists for the scenario
   "ClickHouse unavailable → recon audit event not lost"; the chosen option must be
   testable with InMemory stubs.

---

## Considered Options

### Option (a) — Blocking append (fail-closed)

Recon raises an exception (returns 5xx via API) if ClickHouse is unavailable.
`AuditTrail.log()` no longer swallows errors.

| Dimension | Assessment |
|-----------|-----------|
| Safety | Maximum — no silent loss; recon fails loudly |
| Complexity | Minimal — remove try/except in log() |
| ClickHouse coupling | Maximum — any ClickHouse hiccup blocks recon |
| Test coverage | Easy — mock httpx.post to raise, assert 5xx |

**Risk:** A ClickHouse restart or brief OOM kills the daily recon job, producing a
FCA-reportable operational failure. Trading one compliance risk for another.

---

### Option (b) — Async queue with disk-backed ring-buffer

Audit events are written first to a local SQLite file (append-only, PRAGMA
journal_mode=WAL) and asynchronously drained to ClickHouse by a background worker.
`AuditTrail.log()` returns True once the SQLite write succeeds.

| Dimension | Assessment |
|-----------|-----------|
| Safety | High — events survive ClickHouse outage up to disk capacity |
| Complexity | Moderate — SQLite writer + drain worker + replay logic |
| ClickHouse coupling | Low — ClickHouse outage is invisible to recon caller |
| Test coverage | Moderate — mock SQLite path; drain worker testable separately |

**Risk:** Ring-buffer overflow if ClickHouse is down for >N hours and recon
volume is high. Drain worker adds a background thread/task dependency.

---

### Option (c) — Dual-write: ClickHouse primary + local SQLite ring-buffer (fail-safe)

Every event is written to ClickHouse (primary) and SQLite (secondary) atomically.
If ClickHouse write fails, SQLite copy ensures event is not lost; a reconciliation
cron replays SQLite-only events when ClickHouse recovers.

| Dimension | Assessment |
|-----------|-----------|
| Safety | Very high — belt-and-braces, no single point of loss |
| Complexity | High — two writes per event; reconcile-on-recovery logic |
| ClickHouse coupling | Low — primary path preferred, secondary always present |
| Test coverage | High — both paths independently testable |

**Risk:** SQLite introduces a second storage dependency; dual-write adds latency
per audit event (two synchronous writes unless SQLite is async).

---

### Option (d) — WAL-based pattern (event-sourcing, closest to G-17)

Events are written to a local append-only log (WAL) first; ClickHouse is a
consumer/reader of the WAL, not the primary store. `AuditTrail.log()` returns True
once the WAL write succeeds. ClickHouse ingests from WAL asynchronously.

| Dimension | Assessment |
|-----------|-----------|
| Safety | High — events committed to durable log before ClickHouse sees them |
| Complexity | High — WAL format, consumer registration, offset tracking |
| ClickHouse coupling | Minimal — ClickHouse is a downstream consumer |
| Test coverage | High — WAL writer testable independently of ClickHouse |

**Risk:** WAL consumer for ClickHouse requires either a custom poller or an
integration with Kafka/Redpanda (P1 scope), adding infra complexity outside
current P0 sprint boundaries.

---

## Trade-off Summary

| Option | Safety | Complexity | ClickHouse coupling | Testability |
|--------|--------|-----------|-------------------|-------------|
| (a) fail-closed | Max | Min | Maximum (blocks recon) | Max |
| (b) async ring-buffer | High | Moderate | Low | Moderate |
| (c) dual-write | Max | High | Low | High |
| (d) WAL-based | High | High | Minimal | High |

---

## Recommendation

**Option (b) — async queue with disk-backed SQLite ring-buffer**, with option (a)
as a hardening step for the interim period before option (b) is fully implemented.

Rationale:
- Option (a) alone trades one compliance risk for another (audit gap vs recon
  outage); acceptable only as a short-term hardening step.
- Option (b) decouples recon availability from ClickHouse uptime while keeping
  events durable on local disk, which is the minimum acceptable durability target.
- Option (c) adds complexity without materially improving on (b) for a single-node
  stack; better suited for a multi-node deployment (Phase 5+).
- Option (d) depends on Kafka/Redpanda (P1 scope); premature for current P0 sprint.

**Phased implementation:**
1. (Immediate) Add fail-closed mode as a flag to `AuditTrail` — raise on CH failure
   when `AUDIT_FAIL_CLOSED=true` in env. Default stays fail-open to avoid breaking
   existing behaviour until buffer is in place.
2. (Sprint 4+) Implement SQLite ring-buffer as `BufferedAuditPort` conforming to
   `ReconAuditPort` Protocol DI pattern. Drain worker as FastAPI lifespan background
   task.
3. (Sprint 4+) Add CI smoke test: ClickHouse stubbed as unreachable → recon
   completes, event present in SQLite buffer, buffer replays to CH on reconnect.

---

## Consequences

### Positive

- FCA CASS 15 §15.10 evidence chain is durable across ClickHouse maintenance windows.
- `AuditTrail.log()` caller (ReconciliationEngine) gets a reliable signal:
  True = event committed, False = lost (only in fail-open mode during interim).
- `BufferedAuditPort` fits existing Protocol DI pattern in `recon_engine.py` — no
  interface changes required at the engine level.

### Negative / Risks

- SQLite ring-buffer introduces a local file dependency; disk failure = buffer loss
  (mitigated by evo1 SSD reliability and ClickHouse WAL backup per G-OPS-01/02).
- Interim fail-open behaviour persists until option (b) is fully deployed; tracked in IL.
- Drain worker adds a background coroutine that must be monitored; failure of the
  drain worker is silent unless instrumented (add to G-OBS-01 scope).

---

## Implementation Plan

1. **Introduce buffer abstraction** — add `BufferedAuditPort` class in
   `src/safeguarding/buffered_audit_port.py`: writes to SQLite WAL
   (`safeguarding_audit.db`, append-only), exposes `drain_to_clickhouse()` method.
   Add `AUDIT_FAIL_CLOSED` env var flag to existing `AuditTrail` — controlled by
   `.env.example`.

2. **Migrate audit_trail.py** — wire `BufferedAuditPort` as the default
   `ReconAuditPort` in `ReconciliationEngine` constructor when `AUDIT_FAIL_CLOSED`
   is not set; keep `AuditTrail` (direct CH write) as the drain target. Update
   `services/safeguarding-engine/app/services/audit_logger.py` stub to delegate to
   `BufferedAuditPort`.

3. **Add CI smoke covering ClickHouse-down** —
   `tests/test_safeguarding/test_audit_durability.py`:
   (a) mock `httpx.post` to raise `ConnectError`; assert recon completes and event
   appears in SQLite buffer; (b) call `drain_to_clickhouse()` with working CH mock;
   assert event transferred and SQLite buffer cleared. Run in quality-gate.yml.

---

## Decision

**Pending** — operator acceptance required after review of the Recommendation.
Implementation begins only after operator confirms chosen option and phasing.
