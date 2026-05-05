# ADR-034 — Webhook Reliability Strategy (KYC / SumSub Inbound)

**Status:** Proposed (2026-05-06)
**Author:** Architecture WG / Compliance lead
**Closes:** G-KYC-03 (canonical), G-KYC-04 (canonical), V-11 (HANDOFF-2026-05-04)
**Linked:** ADR-LCY-01, ADR-027 (audit-trail buffer — ALERT_DELIVERED / KYC_WEBHOOK_RECEIVED),
ADR-028 (KYC re-verification triggers), IL-CANON-04, MASTER-PLAN Track A8,
MLR 2017 Reg.28, FCA SS21/3 (KYC evidence chain), FCA SYSC 15A

---

## Context

SumSub is the production KYC provider for Banxe. SumSub pushes applicant lifecycle
events — `applicantReviewed`, `applicantPending`, `applicantWorkflowCompleted`,
`applicantActionPending` (EDD) — via HTTPS POST to a Banxe-registered webhook URL.
Each event carries an `x-payload-digest` HMAC-SHA1 signature (key = `SUMSUB_WEBHOOK_SECRET`).

**Current state (audit-confirmed, G-KYC-03 findings):**

1. `services/webhooks/webhook_router.py` contains a `WebhookProcessor` class with
   SumSub HMAC-SHA1 verification (`_verify_sumsub`) and `WebhookProvider.SUMSUB` enum,
   but this processor is **not wired to any FastAPI route** in `api/main.py`.
   No `POST /webhooks/sumsub` endpoint is registered — SumSub has no delivery target.

2. `services/webhook_orchestrator/dead_letter_queue.py` provides a DLQ backed by
   `DeliveryAttempt` / `DeliveryStorePort`, but it is wired to **outgoing** delivery only
   (Banxe emitting webhooks to subscribers). No inbound SumSub DLQ path exists.

3. `WebhookProcessor.process()` is synchronous; exceptions from registered handlers are
   caught and swallowed (`event.status = FAILED`). A route returning 200 unconditionally
   after a handler failure would cause SumSub to stop retrying, producing **silent KYC
   FSM state drift** — a missed applicant decision is invisible to any audit trail.

4. No idempotency guard: each call generates a fresh UUID. SumSub retry of the same event
   (identical `applicantId + type + createDate`) would produce a duplicate KYC FSM transition.

5. `SUMSUB_WEBHOOK_SECRET` is absent from `.env.example`. An unconfigured secret falls back
   to empty string, causing every incoming SumSub event to fail signature verification.

**Regulatory exposure:** MLR 2017 Reg.28 requires complete and auditable CDD records.
A missed or duplicated KYC decision event breaks the evidence chain. FCA SS21/3 requires
KYC systems to be resilient and produce auditable outcomes. Silent FSM drift under webhook
delivery failure is a measurable compliance gap.

---

## Decision Drivers

1. **Reliability** — incoming SumSub webhooks must not be lost under transient 5xx errors
   on our side. SumSub retries on its own schedule (vendor-side); we must be idempotent.
2. **Security** — `x-payload-digest` HMAC-SHA1 signature verification is mandatory before
   any payload is processed; invalid signature events must be rejected (401) and audit-logged.
3. **Idempotency** — SumSub may redeliver the same event (retry or resend). The handler
   must deduplicate on `applicantId + type + createDate` to prevent duplicate FSM transitions.
4. **Audit completeness (I-24 + ADR-027)** — every inbound SumSub webhook, including
   SIGNATURE_FAILED events, must produce a `KYC_WEBHOOK_RECEIVED` record in ClickHouse.
5. **CI coverage (G-KYC-04)** — test fixtures must cover: replay attack (duplicate delivery),
   out-of-order delivery, invalid/missing signature, and 5xx-response-then-retry scenarios.

---

## Considered Options

### Option (a) — Inline retry via tenacity

Handler catches exceptions and retries inline via `@retry(stop=stop_after_attempt(3),
wait=wait_exponential(multiplier=1, max=10))` on downstream calls (KYC FSM transition).
Add idempotency check at entry using in-process dict keyed on `applicantId+type+createDate`.

| Dimension | Assessment |
|-----------|-----------|
| Reliability | Medium — retries survive transient downstream errors; does NOT survive restart |
| Idempotency | In-process dict; lost on restart → duplicates possible after crash |
| New infra | None |
| Operability | Simple; handler blocks HTTP thread up to ~30s during retry storm |
| Audit trail | Via existing `WebhookProcessor` audit path |

**Risk:** In-process idempotency state is lost on restart. Under high SumSub retry volume,
blocking request threads creates backpressure. Not suitable for MLR-critical KYC events
where delivery guarantee must survive process restart.

---

### Option (b) — Route failed SumSub events to existing webhook_orchestrator DLQ

Wire `WebhookProcessor` to a new FastAPI route. On handler exception, push the `WebhookEvent`
into `webhook_orchestrator.dead_letter_queue.DeadLetterQueue`. A background worker polls
`DLQ.list_dlq()` and reprocesses via `DLQ.retry_from_dlq()`. Reuse existing `delivery_engine.py`
exponential backoff schedule.

| Dimension | Assessment |
|-----------|-----------|
| Reliability | High — DLQ persists across restarts (ClickHouse-backed in prod) |
| Idempotency | Partial — DLQ prevents duplicate DLQ entries but does not deduplicate at entry |
| New infra | Minimal — new FastAPI route + background worker (asyncio or n8n cron) |
| Operability | Medium — DLQ model mismatch (`DeliveryAttempt` is outbound-shaped; requires mapping) |
| Audit trail | DLQ entries append-only (I-24); separate KYC_WEBHOOK_RECEIVED needed |

**Risk:** `DeadLetterQueue` model is shaped for outbound (`event_id`, `subscription_id`);
mapping inbound SumSub events requires adapter layer. Idempotency at entry (before DLQ enqueue)
is still absent — duplicate delivery creates duplicate DLQ entries, each reprocessed separately.

---

### Option (c) — Idempotency-key + 200 OK immediately + background processing (RECOMMENDED)

Add a `POST /webhooks/sumsub` FastAPI route. The route:
1. Verifies `x-payload-digest` HMAC-SHA1 → returns 401 on failure (no further processing).
2. Computes idempotency key: `SHA256(applicantId + ":" + type + ":" + createDate)`.
3. Checks Redis `SETNX idempotency:{key} 1 EX 86400` — if key exists, returns `200 DUPLICATE`.
4. Logs `KYC_WEBHOOK_RECEIVED` to ClickHouse (via ADR-027 `BufferedAuditPort`).
5. Returns `202 Accepted` immediately.
6. Enqueues payload to Redis list `kc:webhooks:sumsub:queue` (background processing).

A separate `asyncio.create_task` (or n8n cron / FastAPI background task) consumes the queue
and triggers the KYC FSM transition via `services/kyc/`. On FSM failure, exponential retry
with max 3 attempts; on exhaustion → `KYC_WEBHOOK_FAILED` audit event + CTIO Telegram alert.

| Dimension | Assessment |
|-----------|-----------|
| Reliability | Highest — 202 always returned; SumSub never retries a 202 delivery |
| Idempotency | Full — Redis SETNX at entry prevents duplicate FSM transitions |
| New infra | Redis queue key (already in stack, :6379); background worker (~40 lines) |
| Operability | High — decoupled; queue inspectable via Redis CLI; no blocking request threads |
| Audit trail | `KYC_WEBHOOK_RECEIVED` + `KYC_FSM_TRIGGERED` + `KYC_WEBHOOK_FAILED` via ADR-027 |

**Risk:** Redis restart clears the idempotency TTL cache (24h window, acceptable for SumSub
retry window of ~72h with backoff). Queue items are lost on Redis crash without persistence —
mitigate with `appendonly yes` in Redis config or use PostgreSQL-backed queue as fallback.

---

### Option (d) — External queue: RabbitMQ / SumSub Workflow Builder

Configure SumSub Workflow Builder to publish events to a RabbitMQ exchange. Banxe deploys
a RabbitMQ consumer service that processes events with full AMQP reliability guarantees.

| Dimension | Assessment |
|-----------|-----------|
| Reliability | Highest — AMQP delivery guarantees, no HTTP failure modes |
| Idempotency | Via AMQP deduplication (requires message-id setup in SumSub) |
| New infra | RabbitMQ + SumSub Workflow Builder configuration; significant new service |
| Operability | Low — new broker, consumer service, exchange/queue topology to maintain |
| Audit trail | Via consumer logging; ADR-027 integration required separately |

**Risk:** RabbitMQ adds a critical-path dependency not in the current stack. SumSub Workflow
Builder requires SumSub Enterprise tier (licencing cost). Exceeds operability constraint for
single-engineer team.

---

## Trade-off Summary

| Option | Reliability | Idempotency | New infra | Operability |
|--------|------------|-------------|-----------|-------------|
| (a) tenacity inline | Medium | In-process only | None | Simple, thread-blocking |
| (b) DLQ reuse | High | Partial | Minimal | Medium (model mismatch) |
| (c) 202 + Redis queue | Highest | Full (Redis SETNX) | Redis key + worker | High |
| (d) RabbitMQ AMQP | Highest | Full | New broker + Enterprise | Low |

---

## Recommendation

**Option (c) — idempotency-key + 202 OK immediately + background processing.**

Rationale:
- Redis is already in the stack (:6379). No new services required.
- Full idempotency at entry (Redis SETNX) prevents duplicate FSM transitions regardless of
  SumSub retry behaviour.
- 202 Accepted returned immediately decouples SumSub delivery from our processing latency —
  eliminates the 5xx-retry-then-silent-drop failure mode.
- Existing `WebhookProcessor._verify_sumsub()` is reused verbatim; no new HMAC implementation.
- Existing DLQ infrastructure (`dead_letter_queue.py`) can be reused as the exhaustion sink
  for events that fail all 3 background retry attempts.

**Webhook reliability matrix:**

| SumSub event | Idempotency key | Background processing | Audit event | Retry policy |
|-------------|-----------------|----------------------|-------------|-------------|
| `applicantReviewed` | `SHA256(applicantId:type:createDate)` | Re-trigger KYC FSM transition | `KYC_WEBHOOK_RECEIVED` + `KYC_FSM_TRIGGERED` | Exponential ×3 (1s, 10s, 60s) |
| `applicantPending` | `SHA256(applicantId:type:createDate)` | Update lifecycle state | `KYC_WEBHOOK_RECEIVED` | None (terminal) |
| `applicantWorkflowCompleted` | `SHA256(applicantId:workflow_id:createDate)` | Trigger lifecycle transition | `KYC_WEBHOOK_RECEIVED` + `KYC_FSM_TRIGGERED` | Exponential ×3 |
| `applicantActionPending` (EDD) | `SHA256(applicantId:action_id:createDate)` | Open EDD case in Marble | `KYC_WEBHOOK_RECEIVED` + `EDD_CASE_OPENED` | Exponential ×5 (EDD critical) |

**Signature verification behaviour:**

| Condition | HTTP response | Audit | Processing |
|-----------|--------------|-------|-----------|
| Valid signature | 202 Accepted | `KYC_WEBHOOK_RECEIVED status=VERIFIED` | Enqueued |
| Invalid / missing signature | 401 Unauthorized | `KYC_WEBHOOK_RECEIVED status=SIGNATURE_FAILED` | Rejected |
| Duplicate (idempotency hit) | 200 OK `{"status":"DUPLICATE"}` | No new record | Ignored |
| Background FSM failure (all retries exhausted) | — | `KYC_WEBHOOK_FAILED` | DLQ + Telegram alert |

---

## Consequences

### Positive

- SumSub webhook delivery is idempotent, reliable, and auditable end-to-end.
- Every incoming event (including SIGNATURE_FAILED) produces a ClickHouse audit record.
- 202 response eliminates the silent-drop failure mode: SumSub considers delivery complete
  once it receives 202; our processing failures are internally retried.
- Reuses existing `_verify_sumsub()`, `WebhookProcessor`, Redis, and DLQ infrastructure.

### Negative / Risks

- Redis is now a dependency for inbound KYC idempotency. Redis restart clears 24h cache window.
  Mitigate: `appendonly yes` in Redis config; 24h window exceeds SumSub retry window.
- Background worker must be resilient: if the FastAPI process crashes after 202 but before
  the Redis queue item is consumed, the event is lost. Mitigate: Redis queue persistence
  (AOF) or use a PostgreSQL-backed queue as the background store.
- Queue depth monitoring is not in place; an FSM failure storm could exhaust the queue.
  Mitigate: ADR-027 `KYC_WEBHOOK_FAILED` alert → CTIO Telegram on exhaustion.

---

## Implementation Plan

1. **Signature verification middleware** — create `api/dependencies/sumsub_signature.py`:
   FastAPI `Depends` that reads `x-payload-digest`, runs `_verify_sumsub()`, raises `HTTP 401`
   on failure. Log `KYC_WEBHOOK_RECEIVED status=SIGNATURE_FAILED` via ADR-027 BufferedAuditPort.

2. **Idempotency-key cache** — Redis `SETNX` at route entry: key = `sumsub:idempotent:{sha256}`,
   TTL = 86400s (24h). Return `200 {"status":"DUPLICATE"}` if key already exists.

3. **ACK-202-then-enqueue handler** — create `api/routers/sumsub_webhook.py`:
   `POST /webhooks/sumsub` → verify signature (dep) → idempotency check → audit-log → 
   `RPUSH kc:webhooks:sumsub:queue` → return `202`. Register in `api/main.py`.

4. **Background worker → KYC FSM trigger** — create `services/webhooks/sumsub_worker.py`:
   `asyncio.create_task` consuming `BLPOP kc:webhooks:sumsub:queue`, calling KYC FSM via
   `services/kyc/`. Exponential retry ×3; on exhaustion, `DLQ.enqueue()` + Telegram alert.
   Add `SUMSUB_WEBHOOK_SECRET` to `.env.example`.

5. **CI fixtures G-KYC-04** — `tests/test_webhooks/test_sumsub_webhook.py`:
   - `test_valid_signature_returns_202_and_enqueues`
   - `test_invalid_signature_returns_401_and_audit_logs`
   - `test_duplicate_delivery_returns_200_duplicate_no_fsm_transition`
   - `test_out_of_order_rejected_after_completed_no_regression`
   - `test_background_worker_retry_on_fsm_failure`
   All marked `@pytest.mark.webhook`.

---

## Decision

**Pending** — operator acceptance required.
Implementation begins only after operator confirms Option (c) and phasing.
