# M-GATEWAY — Developer Platform Build-Spec (public API product, OpenAPI publication, SDKs, versioning)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-25 · **Block:** M-gateway · **Priority:** P2 · **Sprint:** 12 · **Promotes:** the 0% (new developer-platform definition).
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). This doc **specifies/defines the developer-platform contract**; ships **no** runtime code and makes **no** cross-repo write.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103 (server-only refactor / promotion gate), ADR-059-A/ADR-119 (append-only frozen ledger). Additive; mutates no prior artifact.

> M-gateway is the **developer-platform productisation layer** — the **public API product**: OpenAPI/Swagger
> published spec, generated SDKs, developer portal/docs, API-key **self-service** onboarding, versioning/deprecation
> governance, partner DX, usage analytics + plan/tier hooks. It **publishes through I-api** (IL-508, the internal
> gateway) — it **does NOT** reimplement routing, authN/authZ, or rate-limiting (those are I-api), nor IAM/key
> infrastructure (I-security). **M-gateway = the product/DX wrapper on top of I-api.**

---

## 0. Duplication Audit (ADR-102) — explicit I-api disambiguation

| Artifact | Role | Decision |
|---|---|---|
| `docs/architecture/I-API-BUILD-SPEC.md` (IL-508) | **Internal API gateway** — routing, authN/authZ (Keycloak), rate limiting, PII Proxy on egress, the runtime ingress | **keep / REUSE — DISAMBIGUATE** — **I-api = infrastructure gateway** (routing/auth/rate-limit) in Block I; **M-gateway = developer-platform productisation** (public OpenAPI, SDKs, portal, self-service keys, versioning policy) in Block M. M-gateway **publishes through** I-api; it **does NOT** reimplement routing/auth/rate-limiting (ADR-102). I-api §0/§4 already cross-defines this boundary ("Feeds M-gateway … M-gateway productises/publishes through I-api") |
| `docs/architecture/B-PRICING-BUILD-SPEC.md` (IL-512) | commercial pricing catalogue (tiers, published fee schedules) | **keep / REUSE** — M-gateway plan/tier hooks **reference** B-pricing tiers; pricing **not** duplicated |
| `ROADMAP-MATRIX.md` I-security | Keycloak IAM + API-key infra + PII Proxy | **keep / REUSE** — self-service key issuance is **fulfilled by I-security IAM**; M-gateway provides the **DX/UX**, not the IAM. Key infra **not** reimplemented |
| LiteLLM AI-routing gateway (`decision-litellm-dual-gateway`) | internal AI/model routing | **keep / reference + DISAMBIGUATE** — different plane (AI inference); not this product |

No existing `M-GATEWAY-BUILD-SPEC` / developer-platform artifact on main (live audit: `find docs -iname '*m-gateway*'`/`*gateway*BUILD*` ⇒ empty; `ls docs/architecture` has I-API but no M-GATEWAY). New file is **non-duplicative**; it is the **productisation wrapper** on top of I-api, not a second gateway.

## 1. Scope — public API product (developer platform)

M-gateway defines the **product/DX** layer; all policy is **config-as-data** (CLAUDE.md §10):

1. **OpenAPI/Swagger publication** — curate + publish the **public** OpenAPI 3.x spec (subset of I-api's surface deemed public), with examples, changelogs, and a rendered Swagger/Redoc portal.
2. **SDK generation** — generate + publish language client SDKs (e.g. Python, JS/TS) from the published OpenAPI; versioned, semver-tagged.
3. **Developer portal + docs** — guides, references, quickstarts, status, changelog; the public face of the API product.
4. **API-key self-service** — developer **app registration**, self-service **key issuance/rotation/revocation** UX (fulfilled by I-security IAM), scopes/plan selection, sandbox vs production keys.
5. **Versioning + deprecation policy** — public API version lifecycle (`/v1`→`/v2`), deprecation notices, sunset timelines, backward-compat governance.
6. **Usage analytics + plan/tier hooks** — per-app/per-key usage metering surfaced to developers; plan/tier hooks reference **B-pricing** tiers (and downstream **D-fee** billing); rate-tier selection maps to I-api's enforced limits.

**Out** of M-gateway: request routing / authN-authZ enforcement / rate-limit enforcement (I-api), IAM + key-store + PII Proxy infrastructure (I-security), pricing computation/billing (B-pricing/D-fee), AI/model routing (LiteLLM gateway).

## 2. Data model (PublishedAPI / SDKArtifact / DeveloperApp / APIKeyGrant)

Declarative, config-as-data; versioned, immutable-per-version.

### 2.1 `PublishedAPI`
- `api_id`, `version` (semver), `openapi_ref` (published spec doc), `visibility` (`public | partner | sandbox`), `status` (`active | deprecated | sunset`), `changelog`, `deprecation` `{ since, sunset_at }`.

### 2.2 `SDKArtifact`
- `sdk_id`, `api_id`, `language`, `version`, `package_ref` (registry coordinate), `generated_from_openapi_version`.

### 2.3 `DeveloperApp`
- `app_id`, `developer_id`, `name`, `redirect_uris?`, `selected_plan` (B-pricing tier ref), `environment` (`sandbox | production`), `created_at`.

### 2.4 `APIKeyGrant`
- `grant_id`, `app_id`, `key_ref` (**issued by I-security IAM** — M-gateway holds a reference, not the secret), `scopes[]`, `rate_tier` (→ I-api enforcement), `state` (`active | rotated | revoked`), `issued_at`.
- **No secret stored** in M-gateway — keys live in I-security/IAM; M-gateway orchestrates the DX (request/rotate/revoke) and holds references only.

## 3. Publication flow (M-gateway defines product → I-api enforces runtime)

```
internal API surface (I-api routes) → M-gateway productisation
  1. curate public subset → PublishedAPI (OpenAPI 3.x, visibility, version)
  2. generate SDKs from OpenAPI → SDKArtifact[] (semver, publish to registry)
  3. render developer portal/docs from PublishedAPI + changelog
  4. developer self-service: register DeveloperApp → select plan (B-pricing tier)
       → request APIKeyGrant (issued by I-security IAM; scopes + rate_tier)
  5. runtime: developer calls the API → I-api enforces auth/routing/rate-limit (M-gateway does NOT)
  6. usage analytics metered per app/key; plan/tier hooks → B-pricing/D-fee; deprecation notices on version sunset
```

- M-gateway **defines + publishes the product**; **I-api enforces at runtime** (auth, routing, rate-limit). Clean separation: product/DX vs infrastructure gateway.
- Key issuance is **fulfilled by I-security IAM**; M-gateway provides the self-service UX + holds references.

## 4. Versioning + deprecation governance

- Public API versions are **semver**; breaking change ⇒ new major (`/v2`); additive ⇒ minor.
- **Deprecation policy** (config-as-data): deprecation notice → sunset timeline → removal; developers notified via portal + changelog; no silent breaking change.
- SDKs regenerated per published version; old SDK majors supported per policy window.

## 5. Producer/consumer contracts (referenced, not duplicated)

- **Publishes through I-api** (`I-API-BUILD-SPEC` IL-508): the public OpenAPI is a curated view of I-api's surface; **I-api enforces** routing/auth/rate-limit at runtime. M-gateway does **not** reimplement gateway runtime.
- **Self-service keys via I-security IAM**: app registration → key issuance/rotation/revocation fulfilled by IAM; M-gateway provides DX + references. IAM/key infra **not** reimplemented.
- **Plan/tier hooks → B-pricing** (IL-512): developer plan selection references B-pricing tiers; usage/tier feeds D-fee billing. Pricing **not** duplicated.
- **Sibling M-sandbox** (P2): the sandbox environment is a separate block; M-gateway issues sandbox keys/visibility but does not implement the mock-rails sandbox.

## 6. DoD / acceptance criteria (for the banxe-emi-stack PR)

- [ ] `test_published_openapi_is_curated_public_subset` (public spec published; not the raw internal surface).
- [ ] `test_sdk_generated_from_openapi_semver` (SDKs generated + semver-tagged from published OpenAPI).
- [ ] `test_developer_app_self_service_registration` (app register → plan select → environment).
- [ ] `test_api_key_issued_by_i_security_not_stored` (key issuance fulfilled by IAM; **M-gateway holds reference, no secret**; boundary test).
- [ ] `test_rate_tier_maps_to_i_api_enforcement` (tier selection → I-api enforced limit; M-gateway does **not** enforce; boundary test).
- [ ] `test_plan_tier_references_b_pricing` (plan hooks reference B-pricing tiers; no pricing computation here).
- [ ] `test_versioning_deprecation_policy` (semver; deprecation notice + sunset; no silent breaking change).
- [ ] `test_usage_analytics_per_app_key` (metering surfaced; feeds billing hooks).
- [ ] `test_no_routing_auth_ratelimit_reimplementation` (M-gateway contains no gateway runtime — I-api owns it; boundary test).
- [ ] Coverage ≥ 90%, Ruff + semgrep clean; I-api/I-security/B-pricing boundaries respected.

## 7. Perimeter

- **In:** developer-platform productisation — public OpenAPI publication, SDK generation, developer portal/docs, API-key self-service DX, versioning/deprecation governance, usage analytics + plan/tier hooks.
- **Out (fail-closed, §8):** routing / authN-authZ / rate-limit enforcement (I-api), IAM + key-store + PII Proxy (I-security), pricing/billing computation (B-pricing/D-fee), AI/model routing (LiteLLM), the sandbox environment (M-sandbox).
- **Plane:** spec only here; runtime in `banxe-emi-stack` is a separate operator-authorized action (§9).

## 8. Out of scope (fail-closed)

No runtime code here; no cross-repo write into banxe-emi-stack; **no routing / authN-authZ / rate-limit enforcement reimplementation** (I-api owns the internal gateway runtime; M-gateway publishes through it); **no second gateway** (ADR-102 — M-gateway is the productisation wrapper, not a gateway); **no IAM / API-key-store / PII Proxy reimplementation** (I-security owns key issuance + infra; M-gateway holds references, no secrets); **no pricing computation / billing** (B-pricing defines tiers, D-fee computes); **no AI/model routing** (LiteLLM gateway); **no sandbox mock-rails** (M-sandbox sibling); no silent breaking API change (deprecation policy mandatory).

## 9. Operator gates NOT crossed

- **Cross-repo runtime** — implementing M-gateway in `banxe-emi-stack` is a **separate operator-authorized action** (cross-repo write; NO write made here).
- **Public API launch / partner onboarding / production key issuance** = operator-authorized action — not done here.
- No passport activation; no DRAFT promotion; no operator-gated PR touched; Arch-WG DRAFTs untouched.
- If any gate is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 10. References

`docs/architecture/I-API-BUILD-SPEC.md` (IL-508 — internal gateway M-gateway publishes through; routing/auth/rate-limit owner);
`docs/architecture/B-PRICING-BUILD-SPEC.md` (IL-512 — plan/tier source);
`ROADMAP-MATRIX.md` (I-security IAM, M-sandbox sibling rows);
`docs/canon/decision-litellm-dual-gateway-2026-05-13.md` (AI-routing gateway — disambiguated);
OpenAPI 3.x / Swagger / Redoc; semver; ADR-027 (audit), ADR-102/103/115/116/117/119; CLAUDE.md §9/§10/§11; I-security (Keycloak IAM, PII Proxy).
