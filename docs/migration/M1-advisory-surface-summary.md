# M1 advisory-surface summary — BANXE.RAR → EMI checkpoint (docs-only)

<!-- Source: docs/migration/M1-advisory-surface-summary.md | Date: 2026-06-18 | Lane: BANXE.RAR → EMI | Server-only (ADR-103) | Read-only consolidation -->

## Purpose

Factual consolidation of the M1 **advisory, mock-safe** migration lane (M1.1–M1.17) as actually
**merged into code** (`banxe-trading-backend` main) and recorded in the **sharded ledger**
(`banxe-architecture`). This is a read-only checkpoint: an anchor for the next planning step and a
guard against a second source-of-truth. **No code, no ADR, no ledger shard.** Verified against
`banxe-trading-backend` main `9a0c6eb` and `banxe-architecture` main (IL-280).

## 1. Substep map (M1.1–M1.17)

| Substep | Advisory domain | Key DTO(s) / SoT | Endpoint(s) (prefix `/api/v1`) | IL shard |
|---|---|---|---|---|
| M1.0 | risk/DSE/analytics extraction spec (deep-read) | — (spec) | — | IL-253 |
| M1.1 | crypto-earn deep-read spec | `EarnMetrics` | — | IL-254 |
| M1.2–M1.3 | earn rates groundwork | `EarnRatesResponse`, `RateCard`/`EarnRatesCatalog` | `GET /earn/rates` | (earn vertical) |
| M1.4 | earn advisory **status taxonomy** | `EarnAdvisoryStatus` (str-Enum) | (wired into DSE analytics) | IL-269 |
| M1.5 | earn **analytics/summary** enrichment | `AnalyticsContext` (+`advisory_status` on `EarnAlternative`) | (DSE recommend enrichment) | IL-270 |
| M1.6 | earn advisory **statement** | `EarnStatement`, `EarnStatementResponse` | `GET /earn/statement` | IL-271 |
| M1.7 | accounts advisory **metadata** | `AccountAdvisoryMetadata`, `AccountMetadataResponse` | `GET /accounts/metadata` | IL-272 |
| M1.8 | crypto **asset catalogue** | `CryptoAssetMetadata`, `AssetCatalogResponse` | `GET /assets/metadata` | IL-273 |
| M1.9 | **instrument params** (config-as-data) | `InstrumentInfo` ← `_INSTRUMENT_PARAMS`/`instrument_info` | `GET /instruments/{symbol}` | IL-274 |
| M1.10 | instruments **list** | `list_instruments()` → `list[InstrumentInfo]` | `GET /instruments` | IL-275 |
| M1.11 | instrument↔asset **xref** (single) | `InstrumentAssetXref`/`instrument_asset_xref` | `GET /instruments/{symbol}/assets` | IL-277 |
| M1.12 | markets **bundle** (xref list) | `list_instrument_asset_xref()` | `GET /markets` | IL-278 |
| M1.13 | asset→markets **reverse-xref** | `markets_for_asset()` | `GET /assets/{asset}/markets` | IL-279 |
| M1.14 | catalogue **meta** (counts+version) | `CatalogueMeta`/`catalogue_meta` | `GET /catalogue/meta` | IL-280 |
| M1.15 | earn **taxonomy reference** | `EarnTaxonomy`/`earn_taxonomy` (over `RiskBand`/`EarnAdvisoryStatus`) | `GET /earn/taxonomy` | IL-297 |
| M1.16 | catalogue **breakdown** (asset-class) | `CatalogueBreakdown`/`catalogue_breakdown` | `GET /catalogue/breakdown` | IL-299 |
| M1.17 | markets **breakdown** (per-base/quote) | `MarketsBreakdown`/`markets_breakdown` | `GET /markets/breakdown` | IL-301 |

> The per-substep **plan** docs (`M1.4`…`M1.14`, plus the M1.1–M1.6/M1.7 plan #514) remain as
> **open, unmerged docs-only PRs** (operator-gated); only the **code + IL** pairs were merged. On
> `banxe-architecture` main, merged migration docs are the deep-read specs
> (`m1-risk-dse-analytics-spec.md`, `m1.1-crypto-earn-deepread-spec.md`) + `banxe_to_emi_mapping.md`.

### Endpoint inventory (verified on code main)
`GET /earn/rates` · `GET /earn/statement` · `GET /accounts/metadata` · `GET /assets/metadata` ·
`GET /assets/{asset}/markets` · `GET /symbols` · `GET /instruments` · `GET /instruments/{symbol}` ·
`GET /instruments/{symbol}/assets` · `GET /markets` · `GET /markets/breakdown` ·
`GET /catalogue/meta` · `GET /catalogue/breakdown` · `GET /earn/taxonomy`. All read-only,
advisory, sandbox-mock, fail-closed. (14 advisory endpoints verified on code main.)

## 2. Canonical source-of-truth (one per domain — do NOT duplicate)

| Domain | Canonical SoT | Notes |
|---|---|---|
| Earn rates | `earn/rates.py` (`RateCard`/`EarnRatesCatalog`/`earn_rates`) | `/earn/rates`; advisory yields (DecimalStr) |
| Earn status | `earn/status.py` (`EarnAdvisoryStatus`) | lifecycle taxonomy; wired into analytics |
| Earn analytics | `dse/models.py` `AnalyticsContext` + `services/dss_analytics_enrichment.py` | DSE recommend enrichment |
| Earn statement | `earn/statement.py` (`earn_statement`) | composes rates+metrics+status |
| Accounts metadata | `accounts/metadata.py` (`account_metadata`) | config-as-data; **Midaz LedgerPort (ADR-013) = live account SoT, not duplicated/called** |
| Asset catalogue | `assets/catalog.py` (`_ASSET_META`, `asset_catalog`, `asset_metadata`) | descriptive asset metadata |
| Instrument params | `instruments/params.py` (`_INSTRUMENT_PARAMS`, `instrument_info`, `list_instruments`) | trading params (DecimalStr) |
| Symbol universe | `models.py` `SymbolInfo` + `ports/market_data_port.py` `MarketDataPort` + `split_symbol` | symbol/pair source |
| Instrument↔asset xref / markets | `instruments/xref.py` (`InstrumentAssetXref`, `instrument_asset_xref`, `list_instrument_asset_xref`, `markets_for_asset`) | composition views over the above |
| Catalogue meta | `meta/catalogue.py` (`CatalogueMeta`, `catalogue_meta`) | **derived** counts; version = `__version__` (single source) |
| Earn taxonomy (reference) | `earn/taxonomy.py` (`EarnTaxonomy`, `earn_taxonomy`) | **derive/describe** over `RiskBand`/`EarnAdvisoryStatus`; NOT a 2nd rates/status/analytics source |
| Catalogue breakdown | `meta/breakdown.py` (`CatalogueBreakdown`, `catalogue_breakdown`) | **derived** per-`asset_class` counts from `asset_catalog`; `CatalogueMeta` untouched |
| Markets breakdown | `meta/breakdown.py` (`MarketsBreakdown`, `markets_breakdown`) | **derived** per-base/quote counts from `list_instrument_asset_xref`; not a 2nd registry/counter |
| Fees | `ports/fee_engine_port.py` (`FeeEnginePort`) + `/fees/preview` | fee computation SoT — advisory surfaces carry only `fee_schedule_ref` string, never duplicate |

### Frozen contracts (must not break in future M-track work)
`EarnMetrics` (6 fields), `AnalyticsContext` (4), `EarnRatesResponse` (4), `EarnStatementResponse`
(4), `AccountMetadataResponse` (3), `AccountAdvisoryMetadata`, `CryptoAssetMetadata` (6),
`AssetCatalogResponse` (3), `SymbolInfo` (6), `InstrumentInfo` (5), `InstrumentAssetXref` (4),
`CatalogueMeta` (6), `EarnAdvisoryStatus`, `MarketDataPort`, `FeeEnginePort`, `__version__`,
`EarnTaxonomy` (4 — risk_bands/advisory_statuses/lockup_tenors/source), `CatalogueBreakdown` (3),
`MarketsBreakdown` (4), `AssetClassCount` (2), `MarketAssetCount` (2).

## 3. Operator-gated / out-of-scope (deliberately NOT migrated in M1 advisory lane)

- **Live execution** — orders, fills, matching, live state machines.
- **Balances / positions / ledger postings** — Midaz `LedgerPort` (ADR-013) live ops; never called by advisory surfaces.
- **Wallet ops / custody** — deposits, withdrawals, transfers; `WalletAuthPort` is SIWE auth only.
- **Payments / fund movement.**
- **Fee computation / billing / preview** — owned by `FeeEnginePort` / `/fees/preview`; advisory surfaces carry only `fee_schedule_ref`.
- **KYC / AML** — compliance gate (deferred; never bypassed).
- **Internal/ops/infra metrics** — `/internal/health/dse-baas`, `/internal/metrics/dse-baas`, `BaasMetrics`, `dse_baas_health` stay `include_in_schema=False`, infra-fenced, not part of the public advisory surface.
- **User migrations, DB migrations, schema changes, real-money/live amounts, secrets.**

All numeric advisory fields are `DecimalString` config / descriptive values or integer meta counts
(I-01) — **no balances, live amounts, or computed fees** leak through the advisory surface.

## 4. Candidate next read-only advisory domains (no code selection here)

> **Delivered since the last refresh** (were candidates, now DONE): earn taxonomy reference (M1.15,
> IL-297), catalogue breakdown (M1.16, IL-299), markets breakdown (M1.17, IL-301).

1. **Instruments breakdown** *(next, lowest-blast-radius)* — per-status / per-precision counts from
   `list_instruments`, integer meta, a direct analogue of M1.16/M1.17. Spec enumerables MUST be
   **non-exhaustive strings** (see §spec-fidelity).
2. **earn taxonomy↔rates xref** — band→rate-card reference mapping composing `earn_taxonomy` +
   `earn_rates`. **Yield-adjacent** (re-surfaces `RateCard` APY) — **DEFERRED until explicit
   operator risk acceptance.**
3. **Fee-schedule descriptor (reference-only)** — descriptive metadata for `fee_schedule_ref` values
   **strictly as reference**, no fee computation (FeeEnginePort stays the fee SoT). **DEFERRED**
   (fee-adjacent).

### Spec-fidelity (M1.16 lesson)
Any enumerable field in an OpenAPI spec MUST be a **non-exhaustive `type: string`** (canonical
values in the description), **never a hard `enum`**, when the runtime set can grow — spec must match
runtime. (Per the M1.16 CodeRabbit finding where a hard `enum` on `assetClass` diverged from
runtime; applied again in M1.17 `MarketAssetCount.asset`.)

### Explicitly deferred (P0 / regulated)
Live execution/order management, balances/ledger postings (Midaz), wallet/custody, payments,
fee-computation/billing, KYC/AML, real-money flows. These require operator/governance gating
(ADR-103 PART 2 + compliance) and are out of the advisory lane.

## References
`docs/migration/banxe_to_emi_mapping.md`, `m1-risk-dse-analytics-spec.md`,
`m1.1-crypto-earn-deepread-spec.md`; `banxe-trading-backend` (`earn/*`, `dse/models.py`,
`services/dss_analytics_enrichment.py`, `accounts/metadata.py`, `assets/catalog.py`,
`instruments/params.py`, `instruments/xref.py`, `meta/catalogue.py`, `api/*`, `__init__.py`);
ledger shards IL-253/254/269/270/271/272/273/274/275/277/278/279/280; ADR-013, ADR-021, ADR-102,
ADR-103, ADR-059-A; I-01, I-28.
