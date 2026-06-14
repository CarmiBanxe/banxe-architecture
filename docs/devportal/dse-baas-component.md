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

## DSE BaaS Observability & Readiness (T8.2) — INTERNAL / OPS

> **Internal-only.** The endpoints and signals below are **not** part of the
> partner BaaS surface, are **excluded from the public OpenAPI**
> (`include_in_schema=false`), and MUST be fenced to ops/cluster networks at the
> ingress layer. They add **no public-contract change** and carry **no
> secrets/PII**. This is readiness tooling for a future prod rollout.

### Metrics — `GET /internal/metrics/dse-baas` (Prometheus text)

| Metric | Type | Labels | Meaning |
|---|---|---|---|
| `dse_baas_requests_total` | counter | `asset`, `risk_profile`, `status` | facade requests; `status` includes **422** (engine validation) and **503** (sandbox disabled) |
| `dse_baas_request_latency_ms_sum` | counter | `asset`, `risk_profile` | summed latency (ms); divide by the count for an average |
| `dse_baas_request_latency_count` | counter | `asset`, `risk_profile` | request count per label |
| `dse_baas_top_action_total` | counter | `action_type` | top-recommendation actionType mix (e.g. HOLD/WAIT vs BUY/OPEN_LONG) |
| `dse_baas_debug_requests_total` | counter | — | requests that opted into the debug/decisionTrace gate |

Interpretation: watch the **error ratio** (`status="4xx"/"5xx"` over total — a spike
in 503 means the sandbox flag is off where it shouldn't be; 422 means malformed
advisory requests), **latency** (sum/count per asset/profile), and the
**actionType distribution** (a sanity signal on advisory behaviour). Labels are
intentionally low-cardinality; in prod, bound the `asset` label set (allow-list)
to control series cardinality. The text format ships as-is to Prometheus; it can
equally be relayed to StatsD or a log stream. **No external system is configured
here** — only the format/labels are defined.

### Health / readiness — `GET /internal/health/dse-baas`

Returns an aggregated `status` + short `summary` + `checks`:

- `OK` (200) — sandbox flag on **and** a no-network mock dry-run of the DSE
  returned recommendations (`"DSE sandbox enabled, mock providers healthy"`).
- `DEGRADED` (200) — internal engine healthy but the BaaS facade is gated off
  (flag false). The component is alive; the partner facade simply returns 503.
- `ERROR` (503) — the internal engine dry-run failed.

Use in **alerts / pre-prod & prod checklists**: gate readiness on `OK` (or
`OK|DEGRADED` if you only need the component alive), page on `ERROR`. The dry-run
is mock and makes **no network call**.

### Structured logs (incident investigation)

Each facade call emits one sanitized JSON line on logger `banxe.dse.baas`:
`traceId`, `asset`, `riskProfile`, `status`, `latencyMs`, the
`includeSentiment`/`includeStressTests` flags, and the response **summary**
(`topActionType`, `topDriver`, `topUtilityScore`, `enrichmentApplied`,
`decisionTraceEmitted`). It contains **no amounts, no positions, no secrets/PII**.
Investigate by joining the log's `traceId` to the response `traceId`; when the
debug gate was on, pull the full `decisionTrace` from the captured response for a
step-by-step reconstruction. See IL-216 and `observability/baas.py`.

## Data providers & modes (T8.3)

The DSE reads through a **provider-layer** over four data-source domains, with an
env-selectable seam per domain plus an overall mode. **Today only `mock` is
implemented and is the default everywhere** — T8.3 adds the configuration and
architectural seams + safety-rails, but activates **no** live provider and changes
**no** behaviour or contract.

| Domain | Provider env | Today | Future (ODR) |
|---|---|---|---|
| Market / risk (vol, VaR, drawdown, liquidity) | `BANXE_DSE_MARKET_PROVIDER` | `mock` | live market data |
| Sentiment (news / on-chain / social) | `BANXE_DSE_SENTIMENT_PROVIDER` | `mock` | live sentiment |
| Stress-test data | `BANXE_DSE_STRESS_PROVIDER` | `mock` | live stress |
| Earn / yield | `BANXE_DSE_EARN_PROVIDER` | `mock` | live yields |
| **Overall mode** | `BANXE_DSE_PROVIDER_MODE` | `mock` | `sandbox-live` / `prod-live` |

Empty placeholder seams exist for future live credentials/endpoints
(`BANXE_DSE_<DOMAIN>_API_KEY`, `BANXE_DSE_<DOMAIN>_BASE_URL`) — **empty by default,
never set in code**.

**Modes:** `mock` (today — deterministic fixtures, no network/keys),
`sandbox-live` and `prod-live` (future). The app **refuses to start** with any
non-mock provider or mode (a fast `LiveProviderNotWiredError`), so live cannot be
switched on accidentally.

**ODR boundary.** Any value other than `mock` — for any domain provider, the
overall mode, or any API key / endpoint — is an **OPERATOR DECISION (ODR)**
requiring formal operator sign-off **and** compliance review (MiCA / BaaS). None
are set this sprint. The request/response **contract is identical across modes**
(no provider-specific fields). Observability carries a safe `providerMode`
(currently `mock`) so a future mock-vs-live switch is visible in logs/metrics
without exposing secrets. See IL-217 and `dse/provider_layer.py`.

**Choosing the first live providers (T8.4, DECISION PENDING):** the per-domain
candidate evaluation, env / `ProviderMode` matrix, and MiCA/compliance risks for a
future live rollout are written up in
[`docs/specs/dse-live-providers-options.md`](../specs/dse-live-providers-options.md).
That is an **ODR options package only** — until an operator + compliance decision
is signed, **all environments stay `mock`** and `assert_mock_only()` refuses any
live provider, mode, or key at startup. No live source is selected, configured, or
enabled here. See IL-218.

**Provider foundation (S10, ADR-087):** each market, sentiment, and stress domain
now resolves through an explicit provider abstraction with a per-domain **tier**
`BANXE_DSE_<DOMAIN>_TIER` ∈ `mock` (default) · `stub` · `live-ready`. `live-ready`
is a **CI-safe inert scaffold** (no network, no credentials, mock-equivalent
output); real activation needs `BANXE_DSE_LIVE_ALLOWED` + credentials + a wired
adapter (none exist — **OPERATOR DECISION REQUIRED**) and otherwise **fails closed**
at startup. Runtime stays mock-first; `POST /v1/dss/recommend` is **unchanged**
(utility/ranking identical), and per-domain provenance (tier + source, no secrets)
is exposed **internally only** (BaaS log + `/internal/health/dse-baas`). See IL-221.

**Partner/product surface (S11, ADR-088):** `POST /v1/dss/recommend` can return an
**opt-in, non-breaking** `product` metadata block for partner/terminal UIs —
populated only when the request supplies `partnerContext` (`null` otherwise; ranking
and utility unchanged). It surfaces safe provenance (`mock` · `stub` ·
`inert-live-ready`), normalized model/versions, the explainability model, advisory /
self-custodial flags, and a `requestId` (= `traceId`, correlation only). The
`partnerContext` seam (`partnerId` / `clientRef` / `mode`) is **advisory,
metering-READY only** — opaque, bounded, **no auth, no billing, no entitlement**;
only `mode: "sandbox"` is supported and any other value **fails closed** (`422`,
OPERATOR DECISION REQUIRED). See IL-222.

## Execution intent preview (T9.1) — INTERNAL, sandbox/mock-only

The end-to-end trajectory is **advice → unsigned intent → execution**. T9.1 adds the
middle link: an **internal** terminal endpoint
`POST /api/v1/execution/intent-preview` that maps a DSE advisory action onto an
**UNSIGNED** execution intent via the existing self-custodial `ExchangePort`
(mock by default). It is **not** part of this partner BaaS surface and is **not**
exposed on the external `/v1/...` facade.

- **Nothing is signed, submitted, or executed** — preview only; the backend holds
  no keys and the client wallet signs client-side (out of scope). Response always
  `mode: sandbox-mock`, `signed: false`, `submitted: false`.
- Tradable actions (BUY / SELL / OPEN_LONG / OPEN_SHORT / CLOSE) map to an
  unsigned order; advisory-only actions (STAKE / HEDGE / HOLD / WAIT / REBALANCE /
  ADJUST_SL / SWAP) return `tradable: false` with no intent.
- **Mock/sandbox default, no live chain, no keys**; DSE live-providers remain
  PENDING/ODR and are untouched; **no SLA, no billing, no rate-limits**;
  client-side signing, submission/execution and multi-venue routing are **future,
  ODR-gated**. See IL-219 and backend `docs/specs/execution-intent-sandbox.md`.

## Execution Intent Preview UI (T9.2) — INTERNAL TERMINAL ONLY

The terminal (`banxe-trading-frontend`) surfaces the T9.1 bridge as a read-only
**Execution Intent Preview** widget — the visual link between a DSE decision and a
*potential* order. It is **internal terminal only** (not a partner BaaS surface)
and stays **sandbox/mock-only**; it adds no new endpoint and no contract change.

**Flow (from recommendation to preview):**

```
DSE recommendation (or manual: asset + actionType + notionalUsd)
   → [Preview unsigned intent]  (POST /api/v1/execution/intent-preview)
   → Execution Preview panel:
        ⚠ PREVIEW ONLY — NOT EXECUTED  (unsigned · not submitted · mock/sandbox)
        venue · side · size · order type · reduce-only
        unsigned intent · signed:false · submitted:false
        self-custodial disclaimer
```

- The user sees the mapped order (venue, side, size, order type, reduce-only) and
  the unsigned-intent summary; advisory-only actions show "not directly tradable".
- **No auto-execution:** there is **no Execute/Submit button** and no call to any
  execution endpoint — nothing is signed or sent (the backend holds no keys; the
  client wallet would sign client-side, which is out of scope). The UI client is
  **mock by default** (`VITE_EXECUTION_PROVIDER=mock`, no network in CI).
- DSE `providerMode` stays `mock`; DSE live-providers remain PENDING/ODR (IL-218);
  no billing, tiering, or rate-limits. See IL-220 and backend
  `docs/specs/execution-intent-sandbox.md` (FE use-cases).

## Market-making advisory seam (S12 / X9.1, ADR-089) — INTERNAL, mock-only

The first **moat** seam: a market-making *strategy* abstraction (`MarketMakingPort`)
over the existing self-custodial `QuotePort` / `ExchangePort`, anchored by ADR-083
(Hummingbot as a *future strategy sidecar, not a port*). Exposed only on the
**internal** `POST /api/v1/mm/preview` (terminal; **404** on the external `/v1`
facade). It returns an **advisory unsigned quote ladder** around a mid
(`signed:false`, `submitted:false`) — nothing is signed, submitted, or executed,
no keys, no live venue. **Mock by default; a non-mock `BANXE_MM_PROVIDER` fails
closed at startup** (a live strategy host is **OPERATOR DECISION REQUIRED**). No
new public BaaS endpoint; `POST /v1/dss/recommend` and the execution-intent preview
are unchanged. See IL-223 and backend `docs/specs/market-making-sandbox.md`.

## Dynamic fee engine seam (S13 / X9.2, ADR-090) — INTERNAL, analytics-only

The next **moat** seam: a `FeeEnginePort` that returns a fee **attribution
decomposition** (metadata) for a candidate action — separating pricing/analytics
from **billing**. Exposed only on the **internal** `POST /api/v1/fees/preview`
(terminal; **404** on the external `/v1` facade). It is **analytics-only** —
**no real charges, invoices, payments, or billing**, no Lago/Orb/Stripe, no
on-chain hooks; `mode:sandbox-mock`, `signed:false`, `submitted:false`. Components:
`integrator_fee` (LI.FI), `builder_code_fee` (dYdX), `referral_fee` (GMX),
`performance_fee` (StakeKit), `maker_rebate` (negative), `bid_ask_spread_capture`,
with a partner-tier **discount** on platform-take fees. **Mock by default; a
non-mock `BANXE_FEE_PROVIDER` fails closed at startup** (a live fee/billing source
is **OPERATOR DECISION REQUIRED**). No new public BaaS endpoint; the `/v1` facade
and CORE contracts are unchanged. See IL-225 and backend
`docs/specs/fee-engine-sandbox.md`.

## Quant-moat seam (S14 / X9.3, ADR-091) — INTERNAL, advisory analytics

An **optional** moat seam: a `QuantEnginePort` emitting **advisory quant signals**
(fair-value gap, stress scenario, volatility regime, flash-crash / inventory flags)
to enrich the DSE / preview / fees / mm flows. Exposed only on the **internal**
`POST /api/v1/quant/preview` (terminal; **404** on the external `/v1` facade).
**Strictly mock-safe** — **no live quant models** (no Heston / rough-Heston /
Remizov / FNO / deep hedging), no live price feeds, no keys, no network, no trading
decisions; `mode:sandbox-mock`, deterministic. The signals are **additive metadata,
never a critical input** — every CORE endpoint works unchanged if no quant provider
is present. **Mock by default; a non-mock `BANXE_QUANT_PROVIDER` fails closed at
startup** (a live quant stack is **OPERATOR DECISION REQUIRED**). No new public
BaaS endpoint; the `/v1` facade and CORE contracts are unchanged. See IL-226 and
backend `docs/specs/quant-engine-sandbox.md`.

## Ecosystem / marketplace seam (S15 / X9.4, ADR-092) — INTERNAL, read-only

A separate **read-only registry** ("vitrine") of ecosystem providers / strategies
/ agents over the existing providers (LI.FI, dYdX, GMX, StakeKit, Hummingbot-MM,
quant). Exposed only on the **internal** read-only endpoints
`GET /api/v1/marketplace/providers` and `/strategies` (+ `/strategies/{id}`;
**404** on the external `/v1` facade). **Strictly read-only and mock-safe** — **no
purchases / subscriptions / activations, no tokens / revenue-share / payouts, no
entitlement, billing, partner-tiers, keys, or limits**; static fixtures, no
network; **"click → trade" is NOT wired**. Cards carry descriptive fields only and
at most link to the already-existing advisory endpoints. No new public BaaS
endpoint; the `/v1` facade and CORE contracts are unchanged. A live / public
marketplace, revenue-share, subscriptions or entitlement is **OPERATOR DECISION
REQUIRED**. See IL-227 and backend `docs/specs/marketplace-sandbox.md`.

## Multi-venue execution-preview hardening (S16, ADR-093) — INTERNAL, unsigned

An **additive** broadening of the T9.1 execution-intent bridge: the same internal
`POST /api/v1/execution/intent-preview` now also returns a **multi-venue /
multi-product** preview. When the request carries `venues` / `productType` /
`intentType`, it answers with a normalized ranked `candidates` set and a
deterministic `bestCandidate` (spot, perp, earn) over the existing self-custodial
unsigned-intent seam; the **legacy single-venue shape and behaviour are unchanged**.
**Strictly advisory and mock-safe** — `signed:false` and `submitted:false` at the
top level **and per candidate**, descriptive fields only (expected price, fee,
slippage, ETA, confidence), deterministic mock heuristics, **no network, no real
quotes / orderbooks / gas, no signing, no submission, no live chain, no keys**. The
request model is `extra="forbid"`, so any `submit` / `sign` / `live` flag and any
non-`preview-only` `executionMode` **fail closed (422)**; the provider seam
`BANXE_EXECUTION_PREVIEW_PROVIDER` defaults to `mock` and **fails closed at startup**
on any other value. **404** on the external `/v1` facade; no new public BaaS endpoint
and no `/v1` partner-contract change. Real signing, submission, live routing and
venue keys remain the **OPERATOR DECISION REQUIRED** go-live track. This composes
with the fee, quant, market-making and marketplace seams (all advisory, mock-safe,
internal). See IL-236 and backend `docs/specs/execution-intent-sandbox.md`.

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
