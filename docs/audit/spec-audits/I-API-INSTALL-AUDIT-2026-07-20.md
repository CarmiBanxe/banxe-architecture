# Context & scope

Install-audit for **I-api**, the item S-A8's own OPEN POINT 4 flagged as unaudited and
routed to "a candidate future install-audit sprint (a natural 'S-A9' or equivalent)" —
this is that sprint. Scope: locate the actual runtime code implementing
`I-API-BUILD-SPEC.md`'s ingress/edge-gateway contract (REST surface + OpenAPI, authN/authZ,
rate limiting/quotas, routing, versioning/idempotency/error model, security integration),
record paths + SHA, check each DoD item against real code, and report duplication/wiring
gaps. Evidence-only; no code fixed, no spec rewritten, no cross-repo write.

# What exists (code / config / docs — paths + SHA)

Repo: `banxe-emi-stack`, branch `agent/factory/ledgerenv/sandbox-fix`, HEAD
`26365b4500a10e33eb30fe6afb3129a8ff9f8d7a`.

**Two independent, non-communicating "gateway" implementations exist**, four days apart,
neither aware of the other (no cross-import in either direction, confirmed via `rg`):

1. `src/api/gateway.py` — self-labeled in its own docstring **"GAP-023 I-api"**. Framework-
   agnostic `APIGateway` class: `GatewayRequest`/`GatewayResponse` dataclasses,
   `APIKeyAuthPort`/`RateLimiterPort`/`IdempotencyStorePort`/`AuditTrailPort` Protocols,
   in-memory adapters, a `handle()` pipeline covering version extraction → route match →
   API-key auth → sliding-window rate limit → idempotency lookup/store → audit log. Last
   commit `f44251b6250300e897858fee2eaf18a341e0524e` (2026-04-13). Covered by
   `tests/test_src_api.py` (43 tests). **Zero consumers found anywhere outside its own test
   file** (`rg "src.api.gateway|APIGateway\("` across `api/` and `services/`: no matches) —
   never wired into `api/main.py` or any router.
2. `services/api_gateway/` — `api_key_manager.py`, `rate_limiter.py`, `ip_filter.py`,
   `quota_manager.py`, `request_logger.py`, `models.py`, `gateway_agent.py`
   (`GatewayAgent`, orchestrates the five above; docstring: "Trust Zone AMBER | Autonomy L2
   (L4 HITL for revocation per I-27)"). Last commit
   `4133fbcd6137bb1327ed87935704317235af0987` (2026-04-17, four days after #1). Covered by
   125 tests across `tests/test_api_gateway/*` (`api_key_manager`:21, `models`:20,
   `rate_limiter`:17, `ip_filter`:17, `request_logger`:17, `quota_manager`:17,
   `gateway_agent`:16).
   - **This one is wired into the live app**: `api/routers/api_gateway.py` (last commit
     same as above) registers `router` at `app.include_router(api_gateway.router)`
     (`api/main.py` line 227, confirmed present). It exposes a **self-service management
     API** — `POST /v1/gateway/keys`, `GET /v1/gateway/keys/{id}`, `POST
     /v1/gateway/keys/{id}/revoke`, `POST /v1/gateway/check` (manually authenticate +
     rate-limit a caller-supplied request), `GET /v1/gateway/rate-limits`, `POST
     /v1/gateway/ip-filter` — i.e. callers can *ask* the gateway to check a request, but
     nothing in `api/main.py` *automatically* routes other routers' traffic through it
     first.

**AuthN actually enforced on live routes** is a **third, separate** mechanism, unrelated to
either "gateway": `api/deps.py` (last commit `2d367204698a781e382bd81aa566a3086cb7f507`,
2026-06-27) defines `require_auth` (Bearer-token extraction → `IAMPort.validate_token`) and
`require_permission(perm)` (adds `IAMPort.authorize`). Backing adapter:
`services/iam/mock_iam_adapter.py` (last commit `d4725943d98411db599fc3bcc87145ebdc20c010`,
2026-04-13) — `MockIAMAdapter` (default) and a **real** `KeycloakAdapter` class (JWKS-based
offline JWT validation; own docstring: *"STATUS: ACTIVE — Keycloak 26.2.5 running on GMKtec
:8180... Realm: banxe"*), selected via `IAM_ADAPTER` env var. `require_auth` is imported
into ~20+ of 84 `api/routers/*.py` files (confirmed via `rg`, e.g. `sanctions_rescreen.py`,
`mlro_notifications.py`, `treasury.py`, `fx_exchange.py`, `card_issuing.py`, `hitl.py`,
`fraud.py`, `regulatory.py`, `audit_dashboard.py`, `lending.py`, `merchant_acquiring.py`,
`document_management.py`, `compliance_automation.py`) — **per-router opt-in, not a
centralized gateway layer**. `api/routers/payments.py` and `api/routers/ledger.py` —
arguably the two most sensitive routers in the stack — import neither `require_auth` nor
any API-key check (confirmed via `grep` on their import blocks): no auth dependency of any
kind is visible on those endpoints in this codebase.

**Rate limiting actually wired for auth** is a **fourth** mechanism, also unrelated to
either "gateway": `services/auth/rate_limiter_factory.py` (last commit
`1a53a16e91220059481e67a07dfbd8c4ded709a4`, 2026-05-11, "ADR-030, G-API-01/02") returns a
`RedisRateLimiterAdapter` gated by `RATE_LIMIT_ENABLED`, consumed by `api/routers/auth.py`
— this is **login/brute-force rate limiting**, not the per-client/per-endpoint API gateway
rate limiting the spec describes.

**`api/main.py`** (last commit `2ab5a4261f913298399c8e717eb1731817eb0b4f`, 2026-06-25)
registers 84 routers under `/v1` prefix; its only `add_middleware`/`@app.middleware` calls
are CORS and a request-ID middleware (`request_id_middleware`, FCA audit I-24) — **no
auth, rate-limit, or PII-redaction middleware runs globally** for all routes.

**OpenAPI**: `tests/test_api_health.py::test_openapi_schema_reachable` asserts
`GET /openapi.json` returns successfully — confirms FastAPI's auto-generated schema is
reachable, but this is not the spec's "OpenAPI 3.x as source-of-truth contract; request/
response schema validation at the edge" (no schema-validation-at-edge code found).

**Not found anywhere in the repo** (each confirmed via repo-wide `rg`, zero matches):
`application/problem` / RFC-9457 problem+json error model; a PII Proxy / Presidio
integration on the API-egress path (`presidio`/`pii_proxy`/`PIIProxy` matches only
`services/voice_support/*`, an unrelated domain); any of the DoD's nine literal test names
(`test_openapi_contract_is_source_of_truth`, `test_authn_via_keycloak_oidc`,
`test_authz_scope_enforced_per_route`, `test_api_key_auth_for_partners`,
`test_rate_limit_and_quota`, `test_routing_to_upstream_services_only`,
`test_pii_proxy_on_egress`, `test_versioning_idempotency_error_model`,
`test_no_secrets_in_gateway`).

# Ledger/gateway topology & I-api-conformance notes

- **The spec describes one gateway; the codebase has four uncoordinated mechanisms**
  covering different, overlapping slices of it: (1) `src/api/gateway.py` — the closest
  conceptual match to the spec's full pipeline (version+route+auth+rate-limit+idempotency+
  audit in one place) but entirely disconnected from the live HTTP app; (2)
  `services/api_gateway/` — API-key lifecycle + rate/quota/IP-filter management, wired but
  only as an opt-in self-service check, not automatic enforcement; (3) `api/deps.py`
  `require_auth`/`require_permission` + Keycloak `IAMPort` — real, active, Bearer-JWT auth,
  wired per-router by hand into a minority of routers; (4)
  `services/auth/rate_limiter_factory.py` — Redis-backed rate limiting scoped to
  login/auth endpoints specifically. None of the four is "the single ingress" the spec's
  own framing (§1.4: *"the gateway is the only public ingress; services are not directly
  exposed"*) requires — every router in `api/main.py` is directly reachable under `/v1`
  with whatever auth (or none) it individually chose to import.
- **This is a materially different finding from D-GL/B-EMI's "0%/partial" pattern**: those
  audits found either a clean single implementation (D-GL) or an unwired-but-coherent one
  (B-EMI). I-api instead shows **duplicated, non-communicating partial implementations**,
  which is itself the ADR-102 concern the Duplication Audit process exists to catch — and
  which none of the four components' own history flagged against each other (each was
  built independently, four different sprints/dates, with no cross-reference).
- **The most consequential gap is not "unimplemented" but "unenforced on the routes that
  matter most"**: `payments.router` and `ledger.router` — the two routers whose spec
  documents (D-GL, and by extension B-EMI's producer contracts) this same audit series has
  already examined — carry no visible authentication dependency in this codebase. This
  does not necessarily mean they are unprotected in a deployed environment (an external
  reverse proxy or infra-level gate could exist outside this repo), but nothing in
  `banxe-emi-stack` itself confirms one.
- **Keycloak is real, not a stub** — worth stating plainly since several other audits in
  this series (B-EMI, M-gateway) found spec claims that didn't hold in code. Here the
  opposite: the spec under-claims relative to what exists (`KeycloakAdapter`'s own
  docstring asserts it is live and active on GMKtec, JWKS-validated), even though it is
  wired into only a minority of routes.

# Gaps & risks (OPEN POINTS)

1. **Four uncoordinated auth/gateway mechanisms, no single ingress.** `src/api/gateway.py`,
   `services/api_gateway/`, `api/deps.py` (IAM), and `services/auth/rate_limiter_factory.py`
   each implement a slice of I-api's scope independently, with no cross-references. This is
   the concrete duplication the ADR-102 process is meant to surface before merge —
   surfaced here after the fact, since each was built in isolation across separate sprints.
2. **`src/api/gateway.py` (the implementation closest to the full spec pipeline) is
   completely orphaned** — 43 tests pass against a class nothing in the running
   application calls.
3. **`payments.router` and `ledger.router` have no visible auth dependency in this repo.**
   Highest-severity finding in this audit: if no external gate exists either, the two most
   sensitive financial endpoints are reachable without authentication.
4. **AuthN coverage is per-router opt-in, not gateway-enforced.** `require_auth` appears in
   roughly 20-25 of 84 routers; there is no mechanism that would catch a new router being
   added without it, short of manual review.
5. **No API-key-based partner/server-to-server authN path is unified with the Keycloak
   Bearer-token path.** The spec (§1.2) wants both; the codebase has both but as two
   unrelated systems (`services/api_gateway/api_key_manager.py` vs `IAMPort`), with no
   shared authorization/scope model between them.
6. **No RFC-9457 (problem+json) error model anywhere** — confirmed zero matches
   repo-wide. Error responses across routers are ad-hoc dicts (`{"error": "..."}"` style,
   per `src/api/gateway.py` and typical FastAPI `HTTPException(detail=...)` usage
   elsewhere), not a uniform structured error contract.
7. **No PII Proxy / Presidio egress integration for the API layer.** The only Presidio-
   adjacent code in the repo is domain-specific to `services/voice_support/`, unconnected
   to the general API-response egress path the spec requires.
8. **No per-client/per-endpoint gateway-wide rate limiting is actually enforced on live
   traffic.** The only in-memory `RateLimiter`/`InMemoryRateLimiter` implementations
   (`services/api_gateway/rate_limiter.py`, `src/api/gateway.py`) are either opt-in-only or
   unwired; the one rate limiter that is live and enforced
   (`services/auth/rate_limiter_factory.py`) is scoped to login/auth, not general API
   traffic.
9. **None of the DoD's nine named tests exist**, though partial functional equivalents
   exist scattered across the four mechanisms' own test suites (168 tests total: 43 +
   125) — no single test suite validates the spec's actual acceptance criteria end-to-end.

# Next steps / hooks into Floor-2 rooms

- **OPEN POINT 1 (four uncoordinated mechanisms):** route to the governance/ledger-tech
  room for a consolidation decision — which of the four becomes the canonical I-api
  surface, and whether the other three are retired, merged, or explicitly scoped as
  sibling concerns (per the same pattern S-A8 used to disambiguate M-gateway/I-api at the
  spec level, now needed at the code level).
- **OPEN POINT 2 (orphaned `src/api/gateway.py`):** route to the payments/tech room — a
  reuse-or-retire decision; its pipeline is the closest match to the spec and could become
  the consolidation target, or it is confirmed dead code and archived.
- **OPEN POINT 3 (payments/ledger routers unauthenticated):** highest priority — route to
  the security/compliance-reviewer room immediately for confirmation of whether an
  external gate exists; if not, this is a live exposure, not a documentation gap, and
  should be escalated above the pace of this audit series.
- **OPEN POINTs 4-5 (per-router opt-in authN, split API-key/JWT models):** route to the
  security/IAM room for a decision on centralizing enforcement (e.g. FastAPI dependency
  applied at router-inclusion time, or true middleware) and unifying the two identity
  models.
- **OPEN POINTs 6-9 (error model, PII egress, live rate limiting, DoD test gap):** route to
  the ledger/tech room as a scoped follow-up implementation sprint against the existing
  I-API-BUILD-SPEC.md — each is a well-defined, independently implementable gap.
