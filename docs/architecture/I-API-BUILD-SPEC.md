# I-API — API Gateway Build-Spec (developer-facing REST surface, authN/authZ, rate limiting, routing)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-24 · **Block:** I-api · **Priority:** P1 · **Sprint:** 10 · **Promotes:** the 0% (new API-gateway definition).
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). This doc **specifies/defines the gateway contract**; ships **no** runtime code and makes **no** cross-repo write.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103 (server-only refactor / promotion gate), ADR-059-A/ADR-119 (append-only frozen ledger). Additive; mutates no prior artifact.

> I-api is the **developer/partner-facing API Gateway** — the single ingress that **routes and secures**
> external REST traffic to the banking services. It **fronts** D-gl, payment rails, onboarding, and other
> services; it **does not** implement their business logic. It **integrates** I-security (PII Proxy, auth/IAM)
> rather than reimplementing it. Distinct from the **LiteLLM AI-routing gateway** (internal model routing) —
> see §0.

---

## 0. Duplication Audit (ADR-102)

| Artifact | Role | Decision |
|---|---|---|
| `docs/canon/decision-litellm-dual-gateway-2026-05-13.md` | **LiteLLM dual-gateway** — internal **AI/model** routing (factory vs project planes) | **keep / reference + DISAMBIGUATE** — that is the **AI-inference** gateway; I-api is the **banking REST API** gateway for external developers/partners. **Different planes; not duplicated** (ADR-102) |
| `ROADMAP-MATRIX.md` I-security (`PII Proxy/Presidio, Semgrep+CodeQL`) | security plane — PII redaction, auth hardening, SAST | **keep / REUSE** — I-api **integrates** PII Proxy on egress + IAM auth; **does NOT reimplement** I-security |
| `ROADMAP-MATRIX.md` I-infra (`GMKtec compute, n8n, ClickHouse`) | compute/orchestration/observability sink | **keep / REUSE** — I-api emits logs/metrics to ClickHouse (I-infra); does not reimplement it |
| `ROADMAP-MATRIX.md` M-gateway (`public REST API, OpenAPI, versioning`) | Developer-Platform public API surface (P2, Sprint 12) | **keep / note overlap** — I-api = **infrastructure gateway** (routing/auth/rate-limit) in Block I; **M-gateway** = developer-platform productisation (SDKs, public docs) in Block M. I-api is the gateway M-gateway later publishes through; **not duplicated** |
| `decisions/ADR-015-auth-ports.md` (banxe-emi-stack) / ADR-016 (PII/AML routing) | Keycloak auth ports + PII routing | **keep / REUSE** — I-api authN/authZ uses the existing Keycloak IAM (`banxe-emi` realm); auth ports **not** reimplemented |
| D-gl / C-fps / C-sepa / A-kyc / A-idv / A-kyb / B-emi build-specs | the banking services I-api fronts | **keep / reference** — I-api **routes to** them; their logic **not** duplicated |

No existing `I-API-BUILD-SPEC` / banking-API-gateway artifact on main (live audit: `find docs -iname '*i-api*'`/`*api-gateway*` ⇒ empty; `ls docs/architecture` ⇒ A-IDV/A-KYC/A-KYB/B-EMI/D-FEE/D-FIN/D-GL only). New file is **non-duplicative**; it **defines the gateway layer** around existing services + security, it does not re-implement them.

## 1. Scope — API Gateway (developer/partner-facing)

I-api defines the **ingress/edge** layer; all policy is **config-as-data** (CLAUDE.md §10):

1. **REST API surface + OpenAPI contract** — versioned, developer-facing REST endpoints; OpenAPI 3.x as the source-of-truth contract; request/response schema validation at the edge.
2. **AuthN / AuthZ** — OAuth2/OIDC via the existing **Keycloak IAM** (`banxe-emi` realm, ADR-015) for interactive/service clients; **API keys** for partner/server-to-server access; scope/role-based authorization mapped to endpoints.
3. **Rate limiting + quotas** — per-client / per-API-key / per-endpoint limits and burst control; quota tiers **config-as-data** (CLAUDE.md §10), governance-tunable; `429` with `Retry-After`.
4. **Request routing** — route external requests to internal banking services (D-gl, payment rails, onboarding, B-emi, …); the gateway is the **only** public ingress; services are not directly exposed.
5. **API versioning + idempotency + error model** — explicit version namespace (`/v1`); `Idempotency-Key` support for unsafe methods; a uniform RFC-9457 (problem+json) error model; correlation-id propagation.

**Out** of I-api: any service business logic (D-gl posting, rail send/receive, KYC/KYB, account creation), PII-redaction/auth implementation (I-security owns it), compute/observability backends (I-infra), the LiteLLM AI-routing gateway.

## 2. Gateway model (config-as-data)

- **Route table** — declarative `{ path, method, version, upstream_service, auth_scope, rate_tier, pii_egress_policy }` records (config, not code).
- **Auth policy** — per-route required scopes/roles; token validation against Keycloak JWKS; API-key → client/quota mapping.
- **Rate policy** — per-tier `{ rpm, burst, daily_quota }` (config-as-data).
- **No secrets in the gateway** — signing keys / client secrets live in the server vault / IAM (ADR-103); the gateway holds references, not secrets.

## 3. Security integration (I-security — referenced, not reimplemented)

- **AuthN/AuthZ via IAM** — token validation + introspection against Keycloak (`banxe-emi` realm, ADR-015). I-api enforces; IAM owns identity.
- **PII Proxy (Presidio) on egress** — responses crossing the external boundary route through the PII Proxy per **I-security** / ADR-016, so no un-redacted PII leaves the perimeter beyond lawful need. I-api **invokes** the proxy; it does **not** implement redaction.
- **Edge hardening** — TLS termination, input validation, request-size limits, WAF-style guards; SAST/CodeQL (I-security) applied to gateway code in CI. No secrets logged.
- **Observability** — structured access/audit logs + metrics emitted to ClickHouse (I-infra); correlation-id on every request (ADR-027 audit discipline for security-relevant events).

## 4. Producer/consumer contracts (referenced, not duplicated)

- **Fronts the banking services** (D-gl, C-fps/C-sepa rails, A-kyc/A-idv/A-kyb onboarding, B-emi, …): I-api routes authenticated/rate-limited requests to them. Each service **owns** its logic + invariants (LedgerPort/PaymentRailPort/KYCProviderPort); I-api **does not** reimplement any of it.
- **Consumes I-security**: IAM auth + PII Proxy egress + SAST. I-api integrates; I-security owns.
- **Consumes I-infra**: emits logs/metrics to ClickHouse; runs on GMKtec/evo compute. I-api integrates; I-infra owns.
- **Feeds M-gateway** (later, P2): M-gateway productises/publishes the public API (SDKs, docs) **through** I-api; I-api is the underlying gateway, not the developer-platform packaging.

## 5. DoD / acceptance criteria (for the banxe-emi-stack PR)

- [ ] `test_openapi_contract_is_source_of_truth` (routes validated against OpenAPI 3.x; schema validation at edge).
- [ ] `test_authn_via_keycloak_oidc` (valid token required; invalid/expired → 401; Keycloak `banxe-emi` realm).
- [ ] `test_authz_scope_enforced_per_route` (insufficient scope → 403; role/scope from config).
- [ ] `test_api_key_auth_for_partners` (server-to-server key path; key → client/quota mapping).
- [ ] `test_rate_limit_and_quota` (per-client/endpoint limits from config; 429 + Retry-After; burst control).
- [ ] `test_routing_to_upstream_services_only` (gateway is the only public ingress; **no service business logic in gateway**; boundary test).
- [ ] `test_pii_proxy_on_egress` (external responses routed through PII Proxy; gateway does not implement redaction; I-security owns it).
- [ ] `test_versioning_idempotency_error_model` (/v1 namespace; Idempotency-Key on unsafe methods; RFC-9457 problem+json; correlation-id propagated).
- [ ] `test_no_secrets_in_gateway` (secrets via vault/IAM ref only; none logged; ADR-103).
- [ ] Coverage ≥ 90%, Ruff + semgrep + CodeQL clean; auth/PII boundaries respected.

## 6. Perimeter

- **In:** the edge/gateway layer — REST surface + OpenAPI, authN/authZ (IAM + API keys), rate limiting/quotas, routing, versioning/idempotency/error model, security integration hooks.
- **Out (fail-closed, §7):** service business logic (D-gl/rails/onboarding/B-emi), PII-redaction + auth implementation (I-security), compute/observability backends (I-infra), AI-model routing (LiteLLM gateway).
- **Plane:** spec only here; runtime in `banxe-emi-stack` is a separate operator-authorized action (§8).

## 7. Out of scope (fail-closed)

No runtime code here; no cross-repo write into banxe-emi-stack; **no service business-logic reimplementation** (D-gl posting, rail send/receive, KYC/KYB/IDV, account/IBAN creation — the fronted services own these); **no I-security reimplementation** (PII Proxy/Presidio redaction + IAM identity owned by I-security; gateway integrates only); **no I-infra reimplementation** (compute/ClickHouse owned by I-infra); **no AI/model routing** (LiteLLM dual-gateway, separate plane); **no secrets in the gateway** (vault/IAM only); no direct public exposure of upstream services (gateway is the sole ingress).

## 8. Operator gates NOT crossed

- **Cross-repo runtime** — implementing I-api in `banxe-emi-stack` is a **separate operator-authorized action** (cross-repo write; NO write made here).
- **IAM realm / API-key issuance / production rollout** = config + operator-authorized action — not done here.
- No passport activation; **no operator-gated PR touched (PR #744 long since merged); Arch-WG DRAFTs untouched**.
- If any gate is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 9. References

`docs/canon/decision-litellm-dual-gateway-2026-05-13.md` (AI-routing gateway — disambiguated, not duplicated);
`ROADMAP-MATRIX.md` (I-security, I-infra, M-gateway rows);
banxe-emi-stack `docs/adr/ADR-015-auth-ports.md` (Keycloak auth ports), `decisions/ADR-016-ai-plane-pii-aml-routing.md` (PII routing);
`docs/architecture/D-GL-BUILD-SPEC.md`, `C-FPS`/`C-SEPA`, `A-KYC`/`A-IDV`/`A-KYB`, `B-EMI` build-specs (fronted services, referenced);
ADR-027 (audit trail), ADR-102/103/115/116/117/119; I-01/I-28; CLAUDE.md §9/§10/§11; I-security (PII Proxy / Presidio, Semgrep/CodeQL); I-infra (ClickHouse observability).
