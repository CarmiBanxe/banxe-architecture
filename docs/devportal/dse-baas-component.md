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

**Refs:** ADR-084 (DSE BaaS foundation), ADR-085 (DSE Risk and Earn scope);
backend `docs/specs/dse-baas-sandbox-guide.md`; IL-210 (T7.4).
