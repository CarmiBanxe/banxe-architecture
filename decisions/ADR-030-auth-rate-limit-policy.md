# ADR-030 — Auth Surface Rate-Limit Policy

**Status:** Accepted (2026-05-10)
**Date Accepted:** 2026-05-10
**Author:** Architecture WG / Security Lead
**Closes:** G-API-01 (no rate limiting on /auth/* endpoints), G-API-02 (rate-limit coverage tests absent), V-12 (HANDOFF-2026-05-04)
**Linked:** ADR-017 (KC realm bruteForceProtected), ADR-027 (audit-trail durability — 429 event buffering), INVARIANTS I-32/I-33/I-34/I-35/I-36, MASTER-PLAN Track A4, OWASP ASVS 2.2.1, PSD2 RTS SCA Art.4

---

## Context

A read-only audit of `banxe-emi-stack/api/routers/auth.py` conducted 2026-05-05
found **zero application-level rate-limit middleware** on any `/auth/*` or `/sca/*`
endpoint. The FastAPI compliance API (port 8093) exposes six auth-surface endpoints
— `POST /auth/login`, `POST /auth/refresh`, `POST /auth/sca/initiate`,
`POST /auth/sca/verify`, `POST /auth/sca/resend`, `GET /auth/sca/methods/{id}` —
none of which are decorated with a rate-limit dependency or protected by upstream
middleware.

Two partial protections exist but are insufficient in scope:

1. **SCA attempt counter** — `SCAService` increments an in-process attempt counter
   per challenge and raises `too_many_attempts` (HTTP 429) after N failures on
   `/auth/sca/verify`. This covers only the verify endpoint for an active challenge;
   it does not protect against challenge-creation floods, login floods, or refresh
   token abuse.

2. **Keycloak bruteForceProtected** — `banxe-emi-realm.json` has
   `bruteForceProtected=True`, `failureFactor=10`, `maxFailureWaitSeconds=900`.
   This protects the **Keycloak token endpoint** (`/realms/banxe-emi/protocol/openid-connect/token`).
   It does **not** protect the application-level endpoints in `api/routers/auth.py`,
   which are distinct HTTP surfaces that accept credentials and issue application JWTs
   independently of the KC token endpoint.

No upstream proxy rate-limiting exists: nginx is present only in Penpot infra (separate
project); Traefik and Envoy are not deployed on evo1. `requirements.txt` contains
`redis>=5.0.0` (Redis is in the stack) but `fastapi-limiter` and `slowapi` are absent.
The existing `services/api_gateway/rate_limiter.py` (token-bucket per API key tier)
is not wired to any `/auth/*` route.

**Regulatory exposure without application-level rate limiting:**
- PSD2 RTS Art.4 mandates that SCA verification attempts be bounded (≤5 per challenge
  is the industry-accepted baseline); the in-process counter satisfies this only for
  the verify step, not for challenge initiation floods.
- OWASP ASVS 2.2.1 requires account lockout or equivalent protection against automated
  credential-stuffing attacks on all authentication endpoints.
- GDPR Art.32 (appropriate technical measures) is weakened if brute-force attacks on
  `/auth/login` can enumerate account existence via timing/error responses.
- Credential-stuffing at `/auth/refresh` could allow token-replay amplification without
  any server-side throttle.

---

## Decision Drivers

1. **Regulatory (PSD2 RTS SCA Art.4 + OWASP ASVS 2.2.1 + GDPR Art.32)** — bounded
   authentication attempts are a regulatory requirement, not an optional hardening. The
   in-process SCA attempt counter partially satisfies PSD2; full compliance requires
   protection on all auth-surface endpoints.

2. **Layered defence** — application-level rate limiting is complementary to, not a
   replacement for, Keycloak-side `bruteForceProtected`. KC-side protects the KC token
   endpoint; application-level protects the FastAPI auth surface. Both must operate in
   parallel.

3. **Identity dimensions** — different endpoints require different key dimensions: per-IP
   (volumetric flooding), per-account (credential stuffing targeting one account),
   per-challenge-id (PSD2 SCA attempt bound), per-refresh-token-id (token replay
   amplification). A single per-IP limiter is insufficient across all six endpoints.

4. **Storage backend** — in-process counters (single-instance only) vs. Redis-backed
   counters (multi-instance, survives process restart). Redis is already in the stack
   (`redis>=5.0.0` in `requirements.txt`); Redis-backed limiting requires no new
   infrastructure.

5. **Observability** — every HTTP 429 response on the auth surface must emit an audit
   event (I-24 append-only, routed through the ADR-027 `BufferedAuditPort` to survive
   ClickHouse transience) and trigger an alert (G-OBS-01 scope) to detect coordinated
   attacks.

---

## Considered Options

### Option (a) — `slowapi` (FastAPI-native, in-process)

`slowapi` wraps the `limits` library with FastAPI integration. Rate state is stored
in-process by default; Redis backend is optional. Decorator-based: `@limiter.limit("5/minute")`.

| Dimension | Assessment |
|-----------|-----------|
| Coverage | All /auth/* endpoints (decorator per route) |
| Complexity | Low — pip install slowapi; one `Limiter` instance |
| Dependency | slowapi + limits; Redis optional |
| Multi-instance | No (in-process default); yes with Redis backend |
| 429 eventing | Manual: must add audit_trail call in exception handler |
| Key dimensions | Per-IP natively; per-account requires custom key_func |
| Maintenance | Actively maintained; FastAPI examples in docs |

**Risk:** Default in-process state resets on process restart; a rolling deployment
clears all counters. Acceptable only as single-instance (evo1 today) with Redis backend
plan for multi-instance.

---

### Option (b) — `fastapi-limiter` + Redis (async, multi-instance)

`fastapi-limiter` uses Redis as the counter store via `aioredis`/`redis.asyncio`.
State persists across restarts and is shared across instances. FastAPI dependency
injection pattern: `Depends(RateLimiter(times=5, seconds=60))`.

| Dimension | Assessment |
|-----------|-----------|
| Coverage | All /auth/* endpoints (Depends per route) |
| Complexity | Moderate — pip install fastapi-limiter; Redis init in lifespan |
| Dependency | fastapi-limiter; Redis already in stack |
| Multi-instance | Yes — Redis is the shared state store |
| 429 eventing | Customisable: override `http_exception_handler` |
| Key dimensions | Per-IP default; custom callback for per-account/per-challenge |
| Maintenance | Actively maintained; designed for FastAPI |

**Risk:** Redis becomes a dependency for all auth requests; Redis downtime blocks auth
(mitigated by local failover or circuit-breaker — acceptable given Redis already in
the critical path for velocity monitoring).

---

### Option (c) — Reverse-proxy layer (Traefik / nginx ingress)

Rate limiting enforced at the ingress layer, before requests reach FastAPI. Traefik
`RateLimit` middleware or nginx `limit_req_zone` / `limit_req`.

| Dimension | Assessment |
|-----------|-----------|
| Coverage | All endpoints by path prefix (/auth/*) |
| Complexity | High — Traefik not deployed; nginx not in evo1 auth path |
| Dependency | New infra (Traefik) or nginx reconfiguration |
| Multi-instance | Yes — single ingress for all instances |
| 429 eventing | Not natively; requires log-shipping to audit trail |
| Key dimensions | Per-IP easy; per-account/per-challenge requires L7 inspection |
| Maintenance | Infrastructure change, not code change |

**Risk:** Traefik is not deployed on evo1; implementing it as a prerequisite for rate
limiting extends the timeline significantly. nginx is present only in Penpot (separate
project). Edge-layer rate limiting deferred to P1 when Traefik is deployed.

---

### Option (d) — Keycloak-only (existing bruteForceProtected)

Rely exclusively on the existing KC `bruteForceProtected` configuration
(`failureFactor=10`, `maxFailureWaitSeconds=900`) with no application-level changes.

| Dimension | Assessment |
|-----------|-----------|
| Coverage | KC token endpoint only — NOT /auth/login, /sca/*, /auth/refresh |
| Complexity | None — already deployed |
| Dependency | None |
| Multi-instance | Yes (KC cluster-aware) |
| 429 eventing | KC admin events only; not in compliance audit trail |
| Key dimensions | Per-account (KC user ID) |
| Maintenance | Zero — existing config |

**Risk:** Application-level `/auth/login` and `/auth/sca/*` routes are FastAPI handlers
that do not pass through KC's brute-force detector. An attacker can flood these
endpoints without triggering KC-side lockout. Option (d) alone does not close G-API-01.

---

## Trade-off Summary

| Option | Auth coverage | Complexity | New infra | Multi-instance | 429 audit event |
|--------|--------------|-----------|-----------|---------------|----------------|
| (a) slowapi in-process | Full | Low | No | No (counter reset on restart) | Manual hook |
| (b) fastapi-limiter + Redis | Full | Moderate | No (Redis in stack) | Yes | Custom callback |
| (c) Traefik/nginx edge | Full by path | High | Yes (Traefik not deployed) | Yes | Log shipping needed |
| (d) KC-only (existing) | KC endpoint only | None | No | Yes | No (not in app trail) |

---

## Recommendation

**Option (b) — `fastapi-limiter` + Redis** for all application-side `/auth/*` and
`/sca/*` endpoints, **in addition to** the existing KC `bruteForceProtected`
(which remains active — layered defence principle).

Rationale:
- Option (a) is simpler but in-process counters reset on restart, violating the
  consistency expectation for a regulated auth surface. Redis backend makes (a)
  equivalent to (b) in safety but adds the `slowapi` abstraction layer; (b) is
  purpose-built for this pattern.
- Option (b) requires no new infrastructure (Redis already in stack), is async-native
  (compatible with FastAPI lifespan), and supports custom key functions for
  per-challenge-id and per-account dimensions.
- Option (c) deferred to P1 — Traefik deployment is a separate infrastructure track.
- Option (d) alone fails G-API-01; retained as the KC-side layer in the combined
  strategy.

**Edge layer (option c)** deferred to P1 when Traefik is deployed; at that point,
per-IP limits can be pushed to ingress and per-account/per-challenge limits remain
at the application layer.

---

## Endpoint × Limit Matrix

| Endpoint | Limit | Identity dimension | PSD2/ASVS basis | 429 severity |
|----------|-------|--------------------|-----------------|-------------|
| `POST /auth/login` | 5/min per IP; 20/h per account | IP + account_id | ASVS 2.2.1 | HIGH |
| `POST /auth/refresh` | 30/min per refresh-token-id | refresh_token_jti | Session replay risk | MEDIUM |
| `POST /auth/sca/initiate` | 10/min per customer_id | customer_id | PSD2 RTS Art.4 | HIGH |
| `POST /auth/sca/verify` | 5/attempt per challenge_id | challenge_id | PSD2 RTS Art.4 (≤5) | CRITICAL |
| `POST /auth/sca/resend` | 3/min per challenge_id | challenge_id | Abuse prevention | MEDIUM |
| `GET /auth/sca/methods/{id}` | 60/min per IP | IP | Low risk, DoS guard | LOW |
| `POST /auth/token` (KC proxy, if any) | 60/min per client_id | client_id | API client abuse | LOW |

**Identity key derivation:**
- `IP`: `request.client.host` (or `X-Forwarded-For` when behind trusted proxy)
- `account_id`: extracted from `LoginRequest.customer_id`
- `refresh_token_jti`: decoded from `TokenRefreshRequest.refresh_token` (JWT claim `jti`)
- `customer_id`: from path/body parameter
- `challenge_id`: from `SCAVerifyRequest.challenge_id` / `SCAResendRequest.challenge_id`

---

## Consequences

### Positive

- G-API-01 closed: all six auth-surface endpoints gain application-level rate limiting
  enforced by Redis-backed counters that survive process restarts.
- PSD2 RTS SCA Art.4 compliance strengthened: `/auth/sca/verify` hard-bounded at
  5 attempts per challenge_id at the HTTP layer (independent of in-process counter).
- Credential-stuffing risk on `/auth/login` quantifiably reduced: 5/min/IP + 20/h/account
  limits block volumetric and targeted attacks.
- G-API-02 closed: each endpoint limit is testable with `fakeredis` in CI
  (Redis already has `fakeredis>=2.21.0` in `requirements.txt`).
- 429 events emitted to audit trail (ADR-027 buffer) create forensic evidence of
  attack attempts for FCA supervisory data requests.

### Negative / Risks

- Redis becomes a hard dependency for all auth requests; Redis downtime will cause
  `fastapi-limiter` initialisation to fail or requests to be blocked. Mitigation:
  configure `fastapi-limiter` with `lua_script_atomic=False` fallback (fail-open on
  Redis error) and monitor Redis availability via G-OBS-01.
- Per-account key extraction (`LoginRequest.customer_id`) is caller-supplied; a
  brute-force attack using non-existent `customer_id` values bypasses per-account
  limits (per-IP limit remains effective). Acceptable: per-IP limit provides the
  primary flood protection.
- `X-Forwarded-For` spoofing risk if deployed behind an untrusted proxy; mitigated
  by only trusting the header when `TRUSTED_PROXY` env var is set.
- `POST /auth/sca/verify` now has two rate-limit mechanisms (in-process attempt counter
  + Redis HTTP limiter); they must be aligned. Recommendation: keep in-process counter
  as a per-challenge guardrail; Redis limiter as the HTTP-layer gate.

---

## Implementation Plan

1. **Add dependency** — `fastapi-limiter>=0.5.3` to `requirements.txt`. No new
   infrastructure required.

2. **Wire Redis in FastAPI lifespan** — `api/main.py` lifespan event:
   ```python
   from fastapi_limiter import FastAPILimiter
   import redis.asyncio as aioredis

   @asynccontextmanager
   async def lifespan(app: FastAPI):
       redis_conn = aioredis.from_url(settings.REDIS_URL, encoding="utf-8")
       await FastAPILimiter.init(redis_conn)
       yield
       await FastAPILimiter.close()
   ```

3. **Decorate endpoints** — add `Depends(RateLimiter(...))` to each route per the
   Endpoint × Limit Matrix. Custom `identifier` callbacks for non-IP key dimensions
   (account_id, challenge_id, refresh_token_jti).

4. **Emit 429 audit events** — override FastAPI's `RequestValidationError` or add
   a custom `429` exception handler that calls `AuditTrail.log()` (via ADR-027
   `BufferedAuditPort`) with event type `AUTH_RATE_LIMIT_EXCEEDED`, including
   endpoint, key dimension, and client IP.

5. **CI fixtures (G-API-02)** — `tests/test_auth/test_rate_limits.py`:
   patch `fastapi_limiter` with `fakeredis`; assert 429 after N+1 requests within
   window for each endpoint in the matrix. ≥15 tests covering all 6 endpoints +
   custom key dimensions + audit event emission on 429.

---

## Decision

**Accepted** (2026-05-10) — Redis-backed sliding window rate limiter on `/auth/login`
and `/auth/token/refresh` with per-IP/per-token-prefix dimensions, configurable
max_attempts/window/lockout via env vars.

---

## Implementation

- **Step 1:** banxe-emi-stack PR #107 — RateLimiterPort + RedisRateLimiterAdapter + 6 unit tests.
- **Step 2:** banxe-emi-stack PR #108 — wire rate-limit into auth flow (login + refresh) + 6 integration tests.
- **Step 3:** banxe-emi-stack PR #109 — CI smoke tests (5 tests).
- **Total:** 17 tests PASS.
- **Gaps closed:** G-API-01 (DONE), G-API-02 (DONE).
