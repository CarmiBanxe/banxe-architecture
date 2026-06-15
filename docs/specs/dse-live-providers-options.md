# DSE Live-Providers — ODR Options Package (T8.4)

**Status:** INTERNAL design / options doc — **DECISION PENDING (ODR)**.
**Scope:** banxe-architecture (this doc) + DSE BaaS provider-layer (T8.3).
**Refs:** ADR-084 (DSE advisory foundation), ADR-085 (Risk & Earn advisory scope),
ADR-086 (Risk/Earn read-only sandbox); IL-217 (T8.3 provider-layer wiring).

> **No code is changed by this sprint to enable live providers.** All environments
> remain **mock-only**; the `assert_mock_only()` safety-rail (T8.3) refuses any
> non-mock provider/mode at startup. This document only *evaluates options* and
> defines the env / `ProviderMode` matrix an operator would use **after** a formal
> ODR + compliance sign-off. Selecting, configuring, or enabling any candidate
> below is an **OPERATOR DECISION (ODR)** — not taken here.

## 0. How to read this doc

Per domain (Market/Risk, Sentiment, Stress, Earn) we evaluate 2 realistic
candidates against: **latency**, **coverage**, **API model**, **licensing**,
**MiCA risk** (CASP boundary / data-protection), **cost**, **integration
complexity**, plus **monitoring/SLA** needs and **DSE BaaS impact**. The advisory,
self-custodial, no-execution boundary (ADR-084/085/086) is **invariant** for every
option — a live data source feeds *analytics inputs only*; it never adds execution,
custody, or order routing.

The DSE consumes each domain through an existing Protocol seam, so a future live
adapter slots in **without changing the public contract**:

| Domain | Protocol seam (today, mock) | Provider env (T8.3) |
|---|---|---|
| Market / risk | `RiskMetricsProvider` (+ market data) | `BANXE_DSE_MARKET_PROVIDER`, `BANXE_DSE_RISK_PROVIDER` |
| Sentiment | `SentimentProvider` | `BANXE_DSE_SENTIMENT_PROVIDER` |
| Stress | `StressProvider` | `BANXE_DSE_STRESS_PROVIDER` |
| Earn / yield | `EarnRatesProvider`, `EarnRatesCatalog` | `BANXE_DSE_EARN_PROVIDER`, `BANXE_EARN_RATES_PROVIDER` |

---

## 1. Market / Risk metrics (volatility, VaR, drawdown, liquidity)

### Candidate A — Kaiko (centralized institutional market-data vendor)
- **Pros:** broad CEX+DEX coverage, normalized OHLCV/orderbook/derivatives, strong
  data-quality SLAs, EU entity (MiCA-aligned data vendor), historical depth for
  VaR/volatility calibration.
- **Cons:** commercial license + per-seat/volume cost; REST+WS but rate-limited by
  tier; vendor lock-in on schema.
- **Latency:** low (hosted REST/WS, ~tens of ms); needs local caching for the DSE
  sub-100ms target.
- **Licensing/MiCA:** licensed market data; **data vendor, not a CASP** → we remain
  advisory. Redistribution terms must be checked before surfacing raw figures to
  partners (derive metrics, don't re-serve raw feed).
- **Cost/complexity:** medium-high cost, medium integration (one REST client +
  schema map behind `RiskMetricsProvider`).

### Candidate B — dYdX v4 Indexer (exchange-native / on-chain, public API)
- **Pros:** already partially integrated (ADR-083 S6.2, public Indexer, no key);
  perps-native (funding, oracle prices, orderbook) directly relevant to the DSE's
  perp candidates; **free, public, no API key**.
- **Cons:** single-venue (dYdX) coverage; not a full cross-market vol/VaR source;
  on-chain semantics differ per market; uptime tied to the Indexer.
- **Latency:** low for public Indexer; WS available.
- **Licensing/MiCA:** public market data; **API-only, no AGPL vendoring** (per
  ADR-083); lowest data-licensing risk.
- **Cost/complexity:** low cost, low-medium integration (adapter already scaffolded
  as a port).

**Recommendation (for ODR):** start **sandbox-live with B (dYdX Indexer)** for
perp-centric coverage at zero key/cost risk, and evaluate **A (Kaiko)** for
prod-live cross-market breadth once budget + redistribution terms are signed.

---

## 2. Sentiment (news / on-chain / social)

### Candidate A — Santiment (on-chain + social metrics API)
- **Pros:** combined on-chain + social + dev-activity signals; documented REST/
  GraphQL; sentiment + social-volume series usable as the DSE sentiment overlay.
- **Cons:** commercial tiers; social data provenance and model opacity; signal
  quality varies by asset.
- **Latency:** medium (hosted API; sentiment is not sub-second critical → cache).
- **Licensing/MiCA:** third-party data; **social/news data may carry
  data-protection considerations** (no personal data should enter the DSE — ingest
  aggregate scores only, never raw posts/PII).
- **Cost/complexity:** medium cost, low-medium integration.

### Candidate B — LunarCrush (social-first sentiment)
- **Pros:** strong social coverage, simple REST, fast onboarding; asset-level
  social score.
- **Cons:** social-only (no on-chain depth); rate-limited; model is a black box.
- **Latency:** medium.
- **Licensing/MiCA:** same PII caveat — aggregate scores only; verify redistribution.
- **Cost/complexity:** low cost, low integration.

**Recommendation (for ODR):** **A (Santiment)** for the richer on-chain+social blend
that matches the DSE sentiment sub-scores (news, on-chain, social); B as a cheaper
fallback. **Hard rule:** ingest only aggregate scores — **no raw social content /
PII** ever reaches the DSE or its logs.

---

## 3. Stress-test data (scenario / implied-vol inputs)

### Candidate A — Deribit market data (implied-vol surface, public API)
- **Pros:** the reference crypto options venue → IV surface / term structure for
  realistic shock scenarios and Greeks calibration; public market-data API.
- **Cons:** BTC/ETH-centric (thin coverage for long-tail assets); options semantics
  add modelling work.
- **Latency:** low (public REST/WS).
- **Licensing/MiCA:** public market data; data vendor, not a CASP.
- **Cost/complexity:** low cost, medium integration (IV-surface → stress scenarios).

### Candidate B — DeFi risk-analytics vendor (Gauntlet / Chaos Labs)
- **Pros:** purpose-built protocol stress/scenario simulations and risk parameters;
  aligns with the Composable DeFi Stack (ADR-083); narrative-grade scenarios.
- **Cons:** commercial engagement; coverage scoped to supported protocols; outputs
  are model-derived (need provenance/versioning in `modelVersions`).
- **Latency:** scenarios are slow-moving → batch/cache, not request-path.
- **Licensing/MiCA:** contractual; model outputs are advisory — keep the
  estimates/simulations disclaimer.
- **Cost/complexity:** higher cost, medium-high integration.

**Recommendation (for ODR):** **A (Deribit IV)** first for cheap, public,
high-signal volatility-shock inputs; **B** later for protocol-specific DeFi stress
where Earn exposure grows.

---

## 4. Earn / Yield (rates, alternatives)

### Candidate A — StakeKit / yield.xyz (managed staking & yield API)
- **Pros:** broad staking/yield coverage with normalized APY, lockup, protocol
  metadata — matches the existing `earnMetrics` shape (mock named `mock-stakekit`);
  sandbox env available.
- **Cons:** commercial; the vendor also offers *transactional* staking — **we use
  the READ-ONLY rates surface only**; must fence off any execution/staking path
  (out of scope, ODR).
- **Latency:** medium (hosted REST; rates cache well).
- **Licensing/MiCA:** **read-only rate data only**; **no staking/execution** →
  stays advisory and self-custodial. Yields are estimates, disclaimer retained.
- **Cost/complexity:** medium cost, low integration (maps onto `EarnRatesCatalog`).

### Candidate B — DefiLlama Yields API (open data)
- **Pros:** free, open, very broad pool/protocol coverage; simple REST; great for a
  comparison panel.
- **Cons:** community data quality varies; no SLA; needs sanity filters and risk-band
  derivation on our side.
- **Latency:** medium (cache; not request-critical).
- **Licensing/MiCA:** open data (check attribution); read-only; advisory.
- **Cost/complexity:** zero cost, low integration.

**Recommendation (for ODR):** **B (DefiLlama)** for a zero-cost, broad **sandbox-live**
comparison surface; **A (StakeKit/yield.xyz)** for prod-live normalized quality —
**strictly the read-only rates surface, never staking/execution**.

---

## 5. Env / ProviderMode configuration matrix

All variables below are **defined seams** (T8.3); **none are set this sprint**.
`BANXE_` is the settings prefix. Values shown are *illustrative names* an operator
would choose **post-ODR** — they are **not** committed to code or config.

| Domain | `*_PROVIDER` (example) | `*_API_KEY` | `*_BASE_URL` | sandbox-live | prod-live |
|---|---|---|---|---|---|
| Market/Risk | `BANXE_DSE_MARKET_PROVIDER=dydx` \| `kaiko` | `BANXE_DSE_MARKET_API_KEY` (kaiko only) | `BANXE_DSE_MARKET_BASE_URL` | dYdX public Indexer / Kaiko sandbox | Kaiko prod (keyed) |
| Sentiment | `BANXE_DSE_SENTIMENT_PROVIDER=santiment` \| `lunarcrush` | `BANXE_DSE_SENTIMENT_API_KEY` | `BANXE_DSE_SENTIMENT_BASE_URL` | vendor sandbox key | vendor prod key |
| Stress | `BANXE_DSE_STRESS_PROVIDER=deribit` \| `gauntlet` | `BANXE_DSE_STRESS_API_KEY` (vendor only) | `BANXE_DSE_STRESS_BASE_URL` | Deribit public / vendor sandbox | vendor prod |
| Earn | `BANXE_DSE_EARN_PROVIDER=defillama` \| `stakekit` | `BANXE_DSE_EARN_API_KEY` (stakekit only) | `BANXE_DSE_EARN_BASE_URL` | DefiLlama / StakeKit sandbox | StakeKit prod (keyed) |

**Overall mode:** `BANXE_DSE_PROVIDER_MODE = mock | sandbox-live | prod-live`
(today: **mock**, enforced). Public-facing risk-greeks and earn-rates seams
(`BANXE_RISK_GREEKS_PROVIDER`, `BANXE_EARN_RATES_PROVIDER`) follow the same matrix.

### Recommended additional flags for safe mock / sandbox-live / prod-live separation
(future-spec — **not implemented**, listed for the ODR + a later sprint):

- `BANXE_DSE_LIVE_ALLOWED` (master kill-switch; must be true *and* mode != mock).
- Per-domain mode override (e.g. `BANXE_DSE_<DOMAIN>_MODE`) so one domain can go
  sandbox-live while others stay mock (staged rollout).
- **Secrets indirection:** keys provided via the deployment secret store / vault
  reference, never a literal in env files or code.
- Egress allow-list of provider hostnames; per-provider `*_TIMEOUT_S`,
  `*_RATE_LIMIT`, and circuit-breaker thresholds (config-as-data).
- Data-retention + PII-scrub flags for MiCA/GDPR (sentiment): ingest aggregate
  scores only; never persist raw social/news content.
- `providerMode` is already surfaced in observability (T8.3) so dashboards can
  distinguish mock vs sandbox-live vs prod-live once enabled.

---

## 6. Monitoring / SLA requirements (per live rollout)

- **Latency budget:** mock is sub-ms; any live source adds network latency. Live
  adapters must be async + cached + timeout-bounded so the facade keeps its target;
  expose `dse_baas_request_latency_*` (T8.2) per provider.
- **Availability:** circuit-breaker + graceful fallback to mock on provider error
  (the DSE already degrades gracefully when a provider is absent).
- **Data freshness/quality:** staleness alerts; `modelVersions`/provider version in
  the response metadata for provenance.
- **Error budget:** track `dse_baas_requests_total{status}` and a new per-provider
  error metric; page on sustained provider failure.
- **Compliance logging:** sentiment ingestion must log only aggregate scores
  (no PII); retain per MiCA/GDPR policy.

## 7. DSE BaaS impact

- **Contract:** unchanged — live mode adds **no** request/response fields; the same
  advisory payload (recommendations + utility + enrichment + explainability) is
  returned. Only `providerMode` (observability) flips.
- **Behaviour:** utility/ranking math is unchanged; live data changes *inputs*, not
  the model — outputs will differ numerically but the framework and disclaimers
  hold.
- **Partner-facing:** still advisory, self-custodial, no execution; SLA/billing/
  tiering remain separate future ODRs (not introduced here).

---

## 8. ODR decision points (operator + compliance sign-off required)

1. **Per-domain candidate selection** (A vs B) and contracts/licenses.
2. **Enabling any non-mock `ProviderMode`** (sandbox-live first, then prod-live).
3. **Setting any `*_API_KEY` / `*_BASE_URL`** (via vault, never in code).
4. **MiCA/CASP review:** confirm each source is a *data vendor* (advisory inputs),
   not an execution/custody dependency; sentiment PII handling sign-off.
5. **Redistribution terms** for any raw figures surfaced to partners.

## 9. Future code / infra steps (NOT done this sprint)

- Implement live adapters behind the existing Protocols
  (`RiskMetricsProvider` / `SentimentProvider` / `StressProvider` /
  `EarnRatesProvider` / `EarnRatesCatalog`); wire `build_*_provider` to return them
  for the approved provider name.
- Add a bounded HTTP client (httpx is already a dep, lazily imported) with timeout/
  retry/circuit-breaker; **no live client is wired today**.
- Under ODR, relax `assert_mock_only()` to permit the approved mode/provider set
  (guarded by `BANXE_DSE_LIVE_ALLOWED` + secrets present), keeping mock the default.
- Secrets management, egress allow-list, monitoring/alerts, data-retention.
- Per-provider conformance tests + a sandbox-live smoke (non-prod key) in a
  dedicated future sprint.

**Until all of the above are signed off (ODR) and implemented, every environment
stays mock-only and the safety-rail blocks any live configuration.**
