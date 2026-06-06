# Refactor SPEC — Trading UI group consolidation

Date: 2026-05-23
Status: SPEC (design baseline; impl owned by Terminal B per House rule 10)
Scope: neuron-bitshares-ui + fast-exchange + banxe-trade-view + banxe-trade-view-new -> banxe-trading-ui + banxe-trading-backend + ExchangePort
Source: BANXE.RAR /home/banxe/banxe-rar-extracted/ on evo1
Related: ADR-016 trading-ui migration; ADR-021 five-new-ports (ExchangePort); TRADING_PHASE_A_INVENTORY.md; TRADING_REFACTOR_TASKS.md; CLASS_KEEP.tsv
Owner: Central authors SPEC; Terminal B owns impl

## Purpose

Specify the smart refactor of four legacy trading services into two NEW components (banxe-trading-ui frontend + banxe-trading-backend service) bound by ExchangePort (one of the five Hexagonal Ports per ADR-021). This SPEC concretises ADR-016 trading-ui migration and TRADING_PHASE_A inventory under House rule 10 (Central authors SPEC, Terminal B implements). It is the largest single-SPEC scope in this session (58 MB of legacy code across four projects).

## Legacy inventory (read-only audit 2026-05-23)

### 1. neuron/neuron-bitshares-ui (BitShares fork — legacy DEX UI)

- Path: neuron/neuron-bitshares-ui
- Lang: JavaScript + JSX + React (legacy class components era)
- Size: 22 MB (largest of the group)
- Base: BitShares2-light v2.0.181010, fork of bitshares/bitshares-ui
- Node engine: >=9 (EOL)
- Structure: app/ (components, lib, workers, locales), bloom_filter/, charting_library/, build.sh, appveyor.yml
- Git history: NER->NRON rebrand (neuronchain); blocks API alternatives; input checks
- Role: legacy DEX trading UI; BitShares wallet integration; Electron desktop wrapper
- Reuse target (per CLASS_KEEP): Exchange + Forms + Wallet components -> banxe-trading-ui

### 2. neuron/fast-exchange (NestJS exchange backend)

- Path: neuron/fast-exchange
- Lang: TypeScript (NestJS)
- Size: 2.7 MB
- Pkg: banxe-fast-exchange v0.0.1, author ILINK
- Tooling: nest-cli, eslint, prettier, commitlint, gitlab-ci, ecosystem.config.js (PM2)
- GraphQL coupling: graphql.md present (ADR-019 implication)
- Has .env.example (production-like config)
- Git history active: rate ttl 120s; asset ticker rate fetch; feature 59 old-rates rework
- Role: fast-exchange microservice (rate fetch + exchange ops)
- Reuse target: ExchangePort backend implementation (PrimaryExchangeAdapter)

### 3. banxe/banxe-trade-view (React skeleton, abandoned)

- Path: banxe/banxe-trade-view
- Lang: React + react-scripts (CRA), TypeScript hybrid
- Size: 3.1 MB
- Pkg: cex_front_admin v1.0.0, author ILINK
- Has graphql.schema.json (478 KB) — GraphQL coupling
- Has hygen templates for code generation
- Git history: 2 commits only (Initial commit + add base) — SKELETON, abandoned
- Role: superseded by banxe-trade-view-new
- Reuse target: DROP (no production code)

### 4. banxe/banxe-trade-view-new (React + webpack — current production frontend)

- Path: banxe/banxe-trade-view-new
- Lang: React + webpack 5
- Size: 30 MB (largest by size)
- Pkg: web-boilerplate-ilink v1.0.0, author Soroko Nikita / ILINK
- Tooling: gitlab-ci, babel, eslint, prettier
- Git history active: React Router 6 upgrade (refactor/#53555); modern dev
- Role: current production trade-view frontend
- Reuse target: base for NEW banxe-trading-ui (TRANSFORM)

## Decision per service

### neuron-bitshares-ui: EXTRACT-AND-DROP
- Extract only: Exchange components, Forms, Wallet, Notifier, Modal, Settings (per TRADING_PHASE_A).
- Drop everything BitShares-blockchain-specific (RuDex, neuronjs-js, AesWorker, AddressIndexWorker, GenesisFilterWorker, charting_library coupling).
- Drop Electron desktop wrapper (replaced by Tauri 2 per ADR-016).
- Replace bloom-filter (BitShares) with npm bloom-filter-js.
- Drop neuronjs SDK and Graphene blockchain coupling; replace exchange backend calls with ExchangePort.
- Archive remainder as legacy reference (no live import).

### fast-exchange: TRANSFORM-INTO-PRIMARY-ADAPTER
- Keep as core of banxe-trading-backend.
- Implement PrimaryExchangeAdapter (under ExchangePort).
- Drop GraphQL coupling per ADR-019 (Apollo to Hasura migration).
- Modernise to Node 18+; review ecosystem.config.js for systemd-equivalent service definition.

### banxe-trade-view: DROP
- Skeleton (2 commits); no production code.
- Tag ARCHIVE-RESEARCH; no code migration.

### banxe-trade-view-new: TRANSFORM-INTO-banxe-trading-ui
- Use as base for NEW banxe-trading-ui.
- Modernise: React Router already 6 (good); ensure React 18+; verify webpack 5 config or migrate to vite if cleaner.
- Replace direct exchange backend calls with NEW ExchangePort client.
- Wire i18n locales from neuron-bitshares-ui (en, ru, pl, fr) into NEW.
- Add charts via TradingView lightweight-charts or similar OSS (replace BitShares charting_library coupling).

## Legacy to NEW mapping

| Legacy | NEW location | Verdict |
|---|---|---|
| neuron-bitshares-ui (app/components/Exchange/*) | banxe-trading-ui/src/features/exchange/ | EXTRACT |
| neuron-bitshares-ui (app/components/Wallet/*) | banxe-trading-ui/src/features/wallet/ | EXTRACT |
| neuron-bitshares-ui (app/components/Forms/*) | banxe-trading-ui/src/shared/forms/ | EXTRACT |
| neuron-bitshares-ui (app/lib/neuronjs-*) | (none) | DROP |
| neuron-bitshares-ui (charting_library) | banxe-trading-ui/src/features/charts/ (lightweight-charts) | REPLACE |
| neuron-bitshares-ui (locales) | banxe-trading-ui/messages/ | KEEP |
| fast-exchange (NestJS src/) | banxe-trading-backend/src/ | TRANSFORM |
| fast-exchange (GraphQL) | banxe-trading-backend/src/http/ (REST + Hasura where applicable) | TRANSFORM (drop GraphQL coupling) |
| banxe-trade-view (entire repo) | (none) | DROP |
| banxe-trade-view-new (entire repo) | banxe-trading-ui base | TRANSFORM |

## ExchangePort contract (per ADR-021)

```typescript
export type AssetSymbol = string;
export type OrderSide = "buy" | "sell";
export type OrderType = "market" | "limit";

export interface OrderRequest {
  baseAsset: AssetSymbol;
  quoteAsset: AssetSymbol;
  side: OrderSide;
  type: OrderType;
  amount: string;
  limitPrice?: string;
  clientOrderId: string;
}

export interface OrderResult {
  orderId: string;
  status: "accepted" | "filled" | "partial" | "rejected" | "expired";
  filledAmount: string;
  averagePrice?: string;
  fee?: string;
}

export interface RateQuote {
  baseAsset: AssetSymbol;
  quoteAsset: AssetSymbol;
  bid: string;
  ask: string;
  ttlSeconds: number;
}

export interface ExchangePort {
  getRate(baseAsset: AssetSymbol, quoteAsset: AssetSymbol): Promise<RateQuote>;
  placeOrder(order: OrderRequest): Promise<OrderResult>;
  cancelOrder(orderId: string): Promise<boolean>;
  getOrderStatus(orderId: string): Promise<OrderResult>;
}
```

## Refactor strategy (Phases A-F per TRADING_REFACTOR_TASKS pattern)

- Phase A (done): inventory + decisions per service (this SPEC).
- Phase B (Terminal B): scaffold banxe-trading-ui from banxe-trade-view-new; scaffold banxe-trading-backend from fast-exchange.
- Phase C (Terminal B): extract neuron-bitshares-ui components (Exchange/Wallet/Forms) into banxe-trading-ui; implement ExchangePort + 1 primary adapter + 1 fallback adapter (e.g. CCXT-based) + 1 Hyperswitch-compatible adapter.
- Phase D (Terminal B): shadow-mode rate quotes and order placement vs legacy fast-exchange for 14 days; zero-mismatch on getRate.
- Phase E (Terminal B): cut legacy neuron-bitshares-ui and trade-view-old callers over to banxe-trading-ui + ExchangePort; remove old endpoints.
- Phase F (Terminal B): tag legacy 4 services ARCHIVE; record decommission in IL.

## Risk register tie-in

- R-MIG-02 (legacy on evo1 only): mirror four legacy dirs to off-evo1 backup per R4 PREP.
- R-MIG-LICENSE-01 (BitShares fork divergence): audit neuron-bitshares-ui git diff vs upstream BitShares-UI tag; document divergence; review BitShares MIT compliance.
- R-SEC-NEW-03 (order placement regression): zero-mismatch threshold on Phase D for getRate; partial mismatch acceptable on placeOrder only with explicit MLRO sign-off.
- R-COMP-FCA-02 (audit trail for orders): every ExchangePort placeOrder/cancelOrder must persist to guardian_audit_events with correlationId for MLRO + FCA Section 4 evidence.
- R-OPS-AUTHOR-02 (ILINK author bus factor): NEW banxe-trading-* enforces 2-reviewer rule per R5 governance.

## Acceptance criteria

- banxe-trading-ui repo scaffolded with React 18+ + webpack 5 (or vite), i18n migrated from neuron-bitshares-ui, charts via OSS lightweight-charts.
- banxe-trading-backend repo scaffolded from fast-exchange with GraphQL coupling removed.
- ExchangePort interface defined; primary adapter + fallback adapter + Hyperswitch adapter implemented; contract tests green.
- Phase D shadow-mode complete: 0 mismatches on getRate over 14 days.
- All non-test callers of legacy 4 services switched to NEW; no legacy import in NEW dependency tree.
- 4 legacy services tagged ARCHIVE; decommission in IL.

## Open questions

- Should banxe-trading-ui ship as web-only initially, or include Tauri 2 desktop wrapper from Phase B? Owner: Product + Architecture WG.
- Which is the primary ExchangePort adapter at go-live: Hyperswitch, HollaEx, or CCXT-Binance? Owner: Treasury + Compliance.
- Should banxe-trading-ui share a charts component with future banxe-portfolio or stay isolated? Owner: Frontend WG.
- Does the i18n migration require legal review for FR locale strings (EMI French market)? Owner: Legal.
- Should the BitShares fork audit (R-MIG-LICENSE-01) precede or follow Phase C extraction? Owner: SecOps + Legal.

## References

- ADR-016 trading-ui migration
- ADR-021 five-new-ports (ExchangePort)
- ADR-019 GraphQL migration (Apollo to Hasura)
- ADR-017 vendor-to-OpenSource policy
- TRADING_PHASE_A_INVENTORY.md (component catalog, 13 React components, 3 Web Workers, 8 Binance attach-points)
- TRADING_REFACTOR_TASKS.md (Phase A-F naming convention reused here)
- REFACTOR_MASTER_PLAN.md (270-project Transform-first plan)
- CLASS_KEEP.tsv (4 trading-related rows for this SPEC)
- RISK_REGISTER-2026-05-22.md (R-MIG-02 + adjacent risks)
- crypto-api-keys-lib-SPEC-2026-05-22.md (WalletPort dependency for wallet UI components)
- UNIVERSAL-CANON-TOPOLOGY-CLARIFICATION-2026-05-22.md (House rule 10)
- UNIVERSAL-CANON-BEST-SOLUTION-AND-SEQUENTIAL-2026-05-23.md (House rules 11 + 12)

=== END OF Trading UI group SPEC (snapshot 4ca0eef) ===
