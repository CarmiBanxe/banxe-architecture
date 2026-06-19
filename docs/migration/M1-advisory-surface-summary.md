# M1 advisory-surface summary — BANXE.RAR → EMI checkpoint (docs-only)

<!-- Source: docs/migration/M1-advisory-surface-summary.md | Date: 2026-06-18 | Lane: BANXE.RAR → EMI | Server-only (ADR-103) | Read-only consolidation -->

## Purpose

Factual consolidation of the M1 **advisory, mock-safe** migration lane (M1.1–M1.24) as actually
**merged into code** (`banxe-trading-backend` main) and recorded in the **sharded ledger**
(`banxe-architecture`). This is a read-only checkpoint: an anchor for the next planning step and a
guard against a second source-of-truth. **No code, no ADR, no ledger shard.** Verified against
`banxe-trading-backend` main `3ba510c` and `banxe-architecture` main (IL-333 frontier).

## 1. Substep map (M1.1–M1.24)

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
| M1.18 | instruments **breakdown** (fee-schedule/tick) | `InstrumentsBreakdown`/`instruments_breakdown` | `GET /catalogue/instruments-breakdown` | IL-306 |
| M1.19 | symbols **breakdown** (status/precision) | `SymbolsBreakdown`/`symbols_breakdown` | `GET /catalogue/symbols-breakdown` | IL-307 |
| M1.20 | accounts **breakdown** (type/ledger-nature/status) | `AccountsBreakdown`/`accounts_breakdown` | `GET /catalogue/accounts-breakdown` | IL-311 |
| M1.21 | network **breakdown** (flatten, dedup-per-entity) | `NetworkBreakdown`/`network_breakdown` ← `asset_catalog().assets[*].networks` | `GET /catalogue/network-breakdown` | IL-317 |
| M1.22 | capability **breakdown** (flatten, dedup-per-entity) | `CapabilityBreakdown`/`capability_breakdown` ← `account_metadata().accounts[*].capabilities` | `GET /catalogue/capability-breakdown` | IL-321 |
| M1.23 | supported-asset **breakdown** (flatten, dedup-per-entity) | `SupportedAssetBreakdown`/`supported_asset_breakdown` ← `account_metadata().accounts[*].supported_assets` | `GET /catalogue/supported-asset-breakdown` | IL-325 |
| (norm) | breakdown **dedup-per-entity consistency** (M1.21/M1.22 aligned to M1.23 contract) | `network_breakdown`/`capability_breakdown` → `set(...)` | (no new endpoint) | IL-327 |
| M1.24 | advisory-surface **manifest** (meta/inventory, config-as-data) | `AdvisorySurfaceManifest`/`advisory_surface_manifest` (reuse `__version__`) | `GET /catalogue/advisory-surface` | IL-332 |

> **List-flatten dedup-per-entity contract (M1.21–M1.23, normalised M1.21/M1.22 in the norm row):**
> each list-flatten breakdown counts an entity **once per element** (`set(entity.list)`), so
> `count` = **number of entities that contain the element** and `total_memberships` (= sum of
> counts) need NOT equal `total_<entities>`. Behaviourally neutral on the current mock; robust to
> duplicate config entries.

> The per-substep **plan** docs (`M1.4`…`M1.14`, plus the M1.1–M1.6/M1.7 plan #514) remain as
> **open, unmerged docs-only PRs** (operator-gated); only the **code + IL** pairs were merged. On
> `banxe-architecture` main, merged migration docs are the deep-read specs
> (`m1-risk-dse-analytics-spec.md`, `m1.1-crypto-earn-deepread-spec.md`) + `banxe_to_emi_mapping.md`.

### Endpoint inventory (verified on code main)
**earn (3):** `GET /earn/rates` · `GET /earn/statement` · `GET /earn/taxonomy`.
**accounts (1):** `GET /accounts/metadata`.
**assets (2):** `GET /assets/metadata` · `GET /assets/{asset}/markets`.
**symbols/instruments/markets (6):** `GET /symbols` · `GET /instruments` · `GET /instruments/{symbol}` ·
`GET /instruments/{symbol}/assets` · `GET /markets` · `GET /markets/breakdown`.
**catalogue (9):** `GET /catalogue/meta` · `GET /catalogue/breakdown` · `GET /catalogue/instruments-breakdown` ·
`GET /catalogue/symbols-breakdown` · `GET /catalogue/accounts-breakdown` · `GET /catalogue/network-breakdown` ·
`GET /catalogue/capability-breakdown` · `GET /catalogue/supported-asset-breakdown` · `GET /catalogue/advisory-surface`.
All read-only, advisory, sandbox-mock, fail-closed. (**21 advisory endpoints** verified on code main
`3ba510c`.) NB: the M1.24 manifest's own config-as-data count lists the 8 pre-existing catalogue
endpoints (total_endpoints=20), not counting `/catalogue/advisory-surface` itself; the full published
advisory surface is 21.

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
| Instruments breakdown | `meta/breakdown.py` (`InstrumentsBreakdown`, `instruments_breakdown`) | **derived** per-`fee_schedule_ref`/`tick_size` counts from `list_instruments`; not a 2nd registry |
| Symbols breakdown | `meta/breakdown.py` (`SymbolsBreakdown`, `symbols_breakdown`) | **derived** per-status/precision counts from `MarketDataPort.list_symbols`; base/quote owned by M1.17 |
| Accounts breakdown | `meta/breakdown.py` (`AccountsBreakdown`, `accounts_breakdown`) | **derived** per-type/ledger-nature/status counts from `account_metadata`; **Midaz LedgerPort NOT called**; no balances |
| Network breakdown (flatten) | `meta/breakdown.py` (`NetworkBreakdown`, `network_breakdown`) | **derived flatten** (dedup-per-asset) of `asset_catalog().assets[*].networks`; count = #assets-on-network; not a 2nd registry |
| Capability breakdown (flatten) | `meta/breakdown.py` (`CapabilityBreakdown`, `capability_breakdown`) | **derived flatten** (dedup-per-account) of `account_metadata().accounts[*].capabilities`; **Midaz LedgerPort NOT called** |
| Supported-asset breakdown (flatten) | `meta/breakdown.py` (`SupportedAssetBreakdown`, `supported_asset_breakdown`) | **derived flatten** (dedup-per-account) of `account_metadata().accounts[*].supported_assets`; **accounts-per-asset, NOT a 2nd asset catalogue** |
| Advisory-surface manifest (meta/inventory) | `meta/manifest.py` (`AdvisorySurfaceManifest`, `advisory_surface_manifest`, `_ADVISORY_FAMILIES`) | **config-as-data** inventory of advisory families; **NOT a programmatic `app.routes` scan**; fences out `/internal/*`/`/healthz`/live/regulated/sandbox; **reuses `__version__`** (no 2nd version source); distinct from `catalogue_meta` (= data counts) |
| Fees | `ports/fee_engine_port.py` (`FeeEnginePort`) + `/fees/preview` | fee computation SoT — advisory surfaces carry only `fee_schedule_ref` string, never duplicate |

### Frozen contracts (must not break in future M-track work)
`EarnMetrics` (6 fields), `AnalyticsContext` (4), `EarnRatesResponse` (4), `EarnStatementResponse`
(4), `AccountMetadataResponse` (3), `AccountAdvisoryMetadata`, `CryptoAssetMetadata` (6),
`AssetCatalogResponse` (3), `SymbolInfo` (6), `InstrumentInfo` (5), `InstrumentAssetXref` (4),
`CatalogueMeta` (6), `EarnAdvisoryStatus`, `MarketDataPort`, `FeeEnginePort`, `__version__`,
`EarnTaxonomy` (4 — risk_bands/advisory_statuses/lockup_tenors/source), `CatalogueBreakdown` (3),
`MarketsBreakdown` (4), `AssetClassCount` (2), `MarketAssetCount` (2),
`InstrumentsBreakdown` (4), `SymbolsBreakdown` (5), `AccountsBreakdown` (5), `InstrumentDimensionCount` (2), `SymbolDimensionCount` (2), `AccountDimensionCount` (2),
`NetworkBreakdown` (4), `NetworkCount` (2), `CapabilityBreakdown` (4), `CapabilityCount` (2),
`SupportedAssetBreakdown` (4), `SupportedAssetCount` (2), `AdvisorySurfaceManifest` (5 — families/total_families/total_endpoints/version/source), `AdvisorySurfaceFamily` (2).

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

> **Delivered since the last refresh** (were candidates, now DONE): catalogue breakdown (M1.16,
> IL-299), markets breakdown (M1.17, IL-301), instruments breakdown (M1.18, IL-306), symbols
> breakdown (M1.19, IL-307), accounts breakdown (M1.20, IL-311), **network breakdown (M1.21,
> IL-317)**, **capability breakdown (M1.22, IL-321)**, **supported-asset breakdown (M1.23,
> IL-325)**, **breakdown dedup-per-entity normalisation (IL-327)**, **advisory-surface manifest
> (M1.24, IL-332 — first meta/inventory)**.

> **Both grids are now CLOSED:** (a) single-value categorical breakdowns — asset-class (M1.16),
> markets/base-quote (M1.17), instruments fee-schedule/tick (M1.18), symbols status/precision
> (M1.19), accounts type/ledger-nature/status (M1.20); (b) list-flatten breakdowns (dedup-per-entity)
> — network (M1.21), capability (M1.22), supported-asset (M1.23). The **meta/inventory class** opened
> with the advisory-surface manifest (M1.24). No obvious remaining categorical/flatten breakdown over
> the existing DTOs.

1. **Next domain requires an honest-scope deep-read** — both breakdown grids and the first
   meta/inventory surface are delivered; the next read-only advisory step must be confirmed against
   actual DTO fields before scoping (lessons M1.18–M1.20/M1.23: never fabricate a dimension; narrow
   to real fields; fence infra/live per M1.24). Candidate directions to deep-read: a **DTO-family /
   schema inventory** (config-as-data, like the manifest), an **error-model / problem-detail
   catalogue** (reference-only), or a versioned **advisory-surface changelog** — each pending field
   confirmation and the same `/internal`/live fence.
2. **earn taxonomy↔rates xref** — band→rate-card reference mapping. **Yield-adjacent** (re-surfaces
   `RateCard` APY) — **DEFERRED until explicit operator risk acceptance.**
3. **Fee-schedule descriptor (reference-only)** — descriptive metadata for `fee_schedule_ref`,
   **strictly as reference**, no fee computation. **DEFERRED** (fee-adjacent).
4. **KYC/AML** — compliance gate. **DEFERRED** (never bypassed).

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
`instruments/params.py`, `instruments/xref.py`, `meta/catalogue.py`, `meta/breakdown.py`,
`meta/manifest.py`, `api/*`, `__init__.py`);
ledger shards IL-253/254/269/270/271/272/273/274/275/277/278/279/280/297/299/301/306/307/311/317/321/325/327/332;
ADR-013, ADR-021, ADR-056, ADR-060, ADR-102, ADR-103, ADR-059-A; I-01, I-28.
