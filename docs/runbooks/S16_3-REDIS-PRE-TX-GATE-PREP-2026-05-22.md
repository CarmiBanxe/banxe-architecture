# S16.3 — Redis Pre-Transaction Gate (PREP)

Date: 2026-05-22
Status: PREP (design + acceptance criteria; implementation in follow-up sprint)
Source: IL-OPS-ROADMAP-SPRINTS-S12-S25-APPROVED-2026-05-11 (line 7728, S16 item 3 "Redis gate")
Unblocked by: IL-OPS-R1-MIDAZ-LEDGER-BLOCKER-RESOLVED-2026-05-22 (PR #303)
Related ADRs: ADR-030 (auth rate-limit), ADR-034 (webhook idempotency), ADR-027 (audit-trail)

## Purpose

S16.3 introduces a Redis-backed pre-transaction gate layered between the FastAPI compliance API and the midaz transaction service (http://127.0.0.1:8095). The gate evaluates every outbound transaction request and returns ALLOW / DENY / REQUIRE_REVIEW before the call reaches midaz. This closes the gap left by ADR-030 (which protects only /auth/* and /sca/* surfaces) and ADR-034 (which protects only inbound KYC webhooks): neither covers transaction creation endpoints.

R1 (midaz-ledger crash-loop on RABBITMQ_HEALTH_CHECK_URL) is now closed (PR #303), so midaz transaction endpoints are reachable again — making the gate work meaningful.

## Scope

The gate sits between any caller (FastAPI compliance-api, Hyperswitch, manual operator) and midaz transaction endpoints:

- POST /v1/organizations/{org_id}/ledgers/{ledger_id}/transactions/json
- POST /v1/organizations/{org_id}/ledgers/{ledger_id}/transactions/inflow
- POST /v1/organizations/{org_id}/ledgers/{ledger_id}/transactions/outflow
- POST /v1/organizations/{org_id}/ledgers/{ledger_id}/transactions/annotation

Out of scope for S16.3:

- midaz internal rate-limits (documented in midaz-transaction-api-research.md §6).
- auth-surface rate-limits (covered by ADR-030).
- inbound webhook idempotency (covered by ADR-034).

## Five gate checks

1. Idempotency check.
   - Key: pretx:idem:{idempotency_key} (where idempotency_key is HTTP Idempotency-Key header, else hash of {account_id}|{amount}|{currency}|{timestamp_minute}|{operation}).
   - TTL: 24h.
   - Behaviour: if key exists → return cached (http_status, body) from Redis, do NOT call midaz. If not → proceed and write result on success.

2. Per-account rate-limit.
   - Key: pretx:rate:account:{account_id}:{minute_bucket}.
   - TTL: 120s.
   - Limit: configurable per account tier (default tier = 10 tx/minute, premium = 60 tx/minute).
   - Behaviour: increment counter; if > limit → DENY 429.

3. Sanction / fraud cache hit.
   - Key: pretx:sanction:{account_id} and pretx:fraud:{user_id}.
   - TTL: 1h (refreshed by background sanction/Sardine sync).
   - Behaviour: if either key has value "denied" → DENY 403 without calling midaz. If "review" → REQUIRE_REVIEW (route to manual queue).

4. Circuit breaker on midaz health.
   - Key: pretx:cb:midaz with state ∈ {closed, open, half_open}.
   - State machine: closed → if 5xx ratio > 50% over last 60s → open (60s cool-down) → half_open (1 test request) → closed or open.
   - Behaviour: if state=open → DENY 503 without calling midaz.

5. Amount sanity check (defence-in-depth).
   - No Redis key needed; in-process check.
   - Rejects: amount ≤ 0, amount > tier_max (default £100k per tier), currency not in allowlist.

## Fail-mode

- Production: fail-closed. If Redis is unreachable for > 2s → DENY all transactions with HTTP 503 "gate unavailable". This is the safer default for an EMI bank.
- UAT / dev: fail-open. If Redis unreachable → log warning and proceed to midaz. Configured via env PRETX_GATE_FAIL_MODE=open|closed.

## Connection pool / retry

- Redis client: shared redis>=5.0.0 already present (per ADR-030 dependencies).
- Connection pool: max 20 connections per worker, 200ms timeout per command.
- Retry: 1 retry on connection error, no retry on logical errors.

## Audit trail (ADR-027 linkage)

Every gate decision is appended to ClickHouse table pretx_gate_events with TTL 5y:

- event_time_utc, request_id, idempotency_key, account_id, user_id, amount, currency, operation, verdict (ALLOW / DENY / REQUIRE_REVIEW), verdict_reason, redis_latency_ms, total_latency_ms.
- Persisted before midaz is called (so that even ALLOW decisions are auditable).

## Acceptance criteria (DONE definition)

- All 4 midaz transaction POST endpoints are guarded — direct calls bypassing the gate return 403 at the network layer.
- 5 gate checks above are implemented as a pipeline; each can be independently disabled via env flag for emergency.
- Fail-mode is configurable and tested both ways (prod=closed, uat=open).
- Audit-trail pretx_gate_events is written for every decision, no decision goes unlogged.
- Smoke test passes on dev: idempotency dedup, rate-limit kicks in at N+1, circuit breaker trips and recovers.
- Integration test with R1 midaz instance: ALLOW path → midaz receives request, gate logs total_latency_ms.

## Open questions (route to operator / Sub-B during implementation sprint)

- Account tiering source: do tier definitions live in compliance-api config, in Keycloak attributes, or in a separate Redis hash refreshed nightly?
- Sanction list refresh cadence: 1h was assumed; needs MLRO confirmation against FCA SS21/3 requirements.
- tier_max default £100k: needs Architecture WG approval; current value is a placeholder.

=== END OF S16.3 PREP (snapshot 0ae543a) ===
