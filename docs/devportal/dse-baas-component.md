# DSE Advisory API — Developer Portal component (BaaS Tier 2)

Backstage / Developer-Portal descriptor for the **DSE Advisory API**: the
advisory-only Decision Support BaaS that partners consume in a sandbox. This page
documents the catalog component and its getting-started links. It describes a
**sandbox-only, advisory** product — there is **no production tier, no Kong
gateway, and no k8s deployment** described here (those are operator-gated).

> **Advisory-only / self-custodial.** The DSE returns explainable recommendations
> with Risk and Earn metrics over `POST /v1/dss/recommend`. It never executes
> orders, signs transactions, or holds keys. Sandbox data is mock or simulated —
> not for a real-money production path. See ADR-084 and ADR-085.

## Catalog entry

| Field | Value |
|---|---|
| Component | `dse-advisory-api` |
| Display name | DSE Advisory API |
| Type | `service` (advisory; non-executing) |
| Tier | BaaS Tier 2 — advisory |
| Lifecycle | `experimental` (alpha or beta, sandbox-only) |
| Owner | `team-dse` |
| System | `decision-support` |
| Domain | `banxe-baas` |

```yaml
# catalog-info.yaml (Developer Portal registration — sandbox/advisory only)
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: dse-advisory-api
  title: DSE Advisory API
  description: >-
    Advisory-only Decision Support BaaS (Tier 2). POST /v1/dss/recommend returns
    explainable recommendations with Risk and Earn metrics. No execution, no
    keys, sandbox returns mock data.
  tags: [dse, advisory, baas-tier-2, sandbox, mica, mifid]
  annotations:
    banxe.example/lifecycle: sandbox-alpha
  links:
    - title: Sandbox & developer guide
      url: https://github.com/CarmiBanxe/banxe-trading-backend/blob/main/docs/specs/dse-baas-sandbox-guide.md
    - title: OpenAPI — dse-baas-api.yaml
      url: https://github.com/CarmiBanxe/banxe-trading-backend/blob/main/docs/specs/dse-baas-api.yaml
    - title: OpenAPI — dse-utility-api.yaml
      url: https://github.com/CarmiBanxe/banxe-trading-backend/blob/main/docs/specs/dse-utility-api.yaml
    - title: Postman / Hoppscotch collection
      url: https://github.com/CarmiBanxe/banxe-trading-backend/blob/main/docs/specs/dse-baas-sandbox.postman_collection.json
spec:
  type: service
  lifecycle: experimental
  owner: team-dse
  system: decision-support
```

## Getting started

1. Self-serve a **Free Sandbox** key (placeholder `YOUR_KEY_HERE` works against
   the mock).
2. Base URL: `https://sandbox.api.banxe.example`. Call
   `POST /v1/dss/recommend` — see the sandbox guide for curl, the Postman or
   Hoppscotch collection, and the Python and TypeScript SDK skeletons.
3. Render the recommendations plus Risk and Earn metrics; **let the user confirm
   each order manually** in their own self-custodial flow.

## Sandbox surface (read-only)

The component currently exposes, all **sandbox read-only, mock data** (T7.5):

| Capability | Endpoint | Status |
|---|---|---|
| Decision support (advisory) | `POST /v1/dss/recommend` | sandbox, mock |
| Risk Analytics — portfolio Greeks | `GET /v1/risk/greeks` | sandbox read-only, mock |
| Earn Rates — yield comparison | `GET /v1/earn/rates` | sandbox read-only, mock |

Production Risk and Earn APIs and any execution (the remaining Risk
`var` / `stress` / `pnl` endpoints and earn stake / unstake) remain **future
Phase 2 / 3**, each under a separate ADR and legal review (see ADR-086).

**Internal enrichment (T7.6, no surface change):** `POST /v1/dss/recommend` now
**internally** consumes the sandbox Risk Greeks and Earn rates analytics to make
its advisory reasoning richer. This adds **no new endpoint** — the response gains
only **optional, additive, sandbox-mock-derived** fields (`analyticsContext`,
`recommendations[].riskNotes`, `recommendations[].alternatives`). Partners treat
these as **informational only** (no auto-execution). See ADR-086 follow-up
(IL-212) and the sandbox guide "Analytics enrichment" section.

**Explainability & traceability (T7.7, no surface change):** the same endpoint now
also exposes **why** each recommendation got its score and a deterministic id —
additive fields `recommendations[].utilityBreakdown` (signed terms that sum to
`utilityScore`), `recommendations[].topDriver`, `traceId`, and
`explanationVersion`. **utility and ranking are unchanged** (the breakdown
decomposes the existing math). Informational/advisory only. See IL-213 and the
sandbox guide "Explainability & traceability" section.

**Decision trace (T7.8, DEV-ONLY, no surface change):** for sandbox debugging the
endpoint can attach an optional `decisionTrace` that reconstructs the whole mock
decision path (inputs → normalized features → `utilityBreakdown` → enrichment) by
`traceId`. **Double-gated and OFF by default** — operator env flag
`BANXE_DSE_DEBUG_ENABLED` **and** per-request header `X-Banxe-Dse-Debug: true`;
**production partners never receive it** (null/absent). Carries **no secrets**
(only request-derived data, mock metadata, provider class names); utility and
ranking unchanged. See IL-214 and the sandbox guide "Decision trace" section.

## DSE BaaS Sandbox (T8.1)

`POST /v1/dss/recommend` is now served externally as a **thin, advisory-only,
mock-only** BaaS facade over the same internal DSE engine. It is **flag-gated and
OFF by default** — production environments serve **no external DSE BaaS**.

- **Sandbox gate:** `BANXE_DSE_BAAS_SANDBOX_ENABLED` (default `false`). When off,
  every request returns **`503` "DSE BaaS sandbox is disabled"**. Deployments
  additionally fence the route to sandbox/dev at the **ingress/host** layer.
- **No keys needed:** sandbox uses **mock data / fixtures** only — no partner API
  keys, no live market data, no DeFi provider calls.
- **Advisory-only:** ranks and explains; **no execution, signing, staking** or
  wallet action (self-custodial). **No SLA, no billing, no partner tiering, no
  rate limits** — those are future ODR, not implemented here.

Example (sandbox enabled):

```bash
curl -sS -X POST "https://sandbox.api.banxe.example/v1/dss/recommend" \
  -H "content-type: application/json" \
  -d '{"asset":"BTCUSDT","portfolioValueUsd":"10000","riskProfile":"balanced"}'
# -> 200: { "recommendations": [...], "traceId": "dss-...", "disclaimer": "Advisory only ...", ... }
# (flag off -> 503 {"detail":"DSE BaaS sandbox is disabled"})
```

The response is the standard DSE advisory payload (recommendations + utility +
`analyticsContext` enrichment + `utilityBreakdown`/`traceId`; `decisionTrace` only
when the separate debug gate is also on). **Usage limits / rate-limits are future
ODR** — not enforced in this sandbox. See IL-215 and the backend sandbox guide
"Enabling the DSE BaaS sandbox facade".

## Boundaries (compliance)

- Advisory product, separate from any execution API. Recommendations are
  decision-support, not investment advice and not execution (MiCA CASP, MiFID II).
- Partners run their own suitability and jurisdiction checks before surfacing or
  acting on a recommendation; disclaimers from the response are shown verbatim.
- No gamification, no copy-trading, no leaderboards, no AgentFi or autotrading.

## Operator-gated (NOT in this component)

Production tier, Kong gateway, k8s deployment, real partner keys, production rate
limits, live execution, and real Risk or Earn data providers are **OPERATOR
DECISION REQUIRED** — env-only, out of scope for this sandbox component.

**Refs:** ADR-084 (DSE BaaS foundation), ADR-085 (DSE Risk and Earn scope),
ADR-086 (Risk and Earn read-only sandbox); backend
`docs/specs/dse-baas-sandbox-guide.md`, `risk-api.yaml`, `earn-api.yaml`;
IL-210 (T7.4), IL-211 (T7.5), IL-215 (T8.1 — DSE BaaS sandbox facade).
