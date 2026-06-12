---
id: ADR-083
title: Composable DeFi Stack replaces the Binance-dealer model (self-custodial)
status: ACCEPTED
date: 2026-06-12
accepted: 2026-06-12
supersedes: []
related:
  - "ADR-021-exchangeport-network-transport.md (KEPT — ExchangePort + MarketDataPort + §D2/§D3 unchanged)"
  - "ADR-017 (no Keycloak — AuthPort TODO now resolved to wallet auth)"
  - "ADR-016 (AML/PII routing — DeFi/MiCA surface, governance-gated)"
  - "ADR-019 (GraphQL→REST per FE-canon)"
il_anchor: IL-197
scope: BANXE-only
concept_only: false
---

# ADR-083: Composable DeFi Stack replaces the Binance-dealer model (self-custodial)

**Status:** ACCEPTED — 2026-06-12
**IL:** IL-197 (Sprint 6.1 — discovery + decision; no integration code)

## Context

ADR-021 framed `banxe-trading-backend` as the network transport for an
**ExchangePort** (orders/rate) + **MarketDataPort** (L2 depth), with the live
provider left governance-gated. Operator direction (Sprint 6) **rejects a single
centralized-exchange (Binance/CEX) dealer model** in favour of a **self-custodial
Composable DeFi Stack** — no CEX counterparty, no custody of user keys; the user's
wallet signs every transaction. This ADR records the discovery of the MVP subset
and decides the port architecture, **keeping ADR-021 intact** and adding the
pieces DeFi needs (aggregator/RFQ quotes, wallet auth).

> CEX market-data libraries (CCXT / Cryptofeed / Tardis) are **explicitly out** —
> they are the Binance-style path being replaced.

## Discovery — MVP subset (read-only, verified via gh + registries 2026-06-12)

| Candidate | Repo / SDK (verified) | Version | License | Shape | Order-book vs quote | Decimal / units |
|---|---|---|---|---|---|---|
| **dYdX v4** | `dydxprotocol/v4-chain` (appchain + Indexer); `dydxprotocol/v4-clients` (py `dydx-v4-client` 1.1.6, js `@dydxprotocol/v4-client-js` 3.6.0) | chain @ 2026-06 | **AGPL-3.0** (dYdX custom AGPL; `LICENSE` covers chain, v4-web, v4-abacus) | self-hosted node optional; **public Indexer REST + WS**; on-chain CLOB | **L2 order-book snapshot+diff** — `v4_orderbook` WS channel, `batched` mode = initial snapshot then batched `channel_data` updates (verified across py/js/rs/cpp clients + indexer `socks`). Also trades, markets/instruments, order placement (on-chain, self-custodial signing) | atomic units (quantums / subticks as integer strings) — **no float, I-01 friendly** |
| **LI.FI** | `lifinance/sdk` (`@lifi/sdk` 4.0.0); hosted API `li.quest/v1` | 4.0.0 | **Apache-2.0** | hosted **REST** aggregation API (+ TS SDK) | **quote / route / RFQ** (spot + cross-chain) — **NOT** an order book | amounts in smallest unit (wei) as strings — I-01 compatible |
| **StakeKit / Yield.xyz** | `stakekit/sdk`, `stakekit/js-sdk` (`@stakekit/api-hooks` MIT); hosted Yield.xyz API | SDK 0.0.x | **MIT** (SDK) over a **hosted** API | hosted **REST**; non-custodial txn construction (sign client-side) | **yield / staking** (70+ networks) — not spot order-book/quote | decimal strings |
| **Hummingbot** | `hummingbot/hummingbot` | v2.14.0 (2026-04) | **Apache-2.0** | **self-hosted** Python algo/market-making framework (18.8k★, very active) | strategies + connectors — not a market-data port | Python `Decimal` |
| **OpenDAX** | `openware/opendax` (Apache-2.0, **last push 2023-12 — stale**); `openware/peatio` (MIT) | community v4 | **Apache-2.0 / MIT (community)** vs **commercial cloud** | full exchange UI/engine; community editions stale, current product is commercial (Yellow/OpenDAX cloud) | exchange frontend/engine — not our market-data source (our FE already exists) | — |

## Decision

### D1 — Keep ADR-021 ports; the DeFi stack binds *into* them

ADR-021's **ExchangePort**, **MarketDataPort**, and the §D2 WS / §D3 REST
contracts are **unchanged**. DeFi venues become *adapters* behind these ports —
no rewrite of the frontend or the transport contracts.

### D2 — dYdX v4 reuses §D2 unchanged (MVP layer 1)

dYdX v4's Indexer `v4_orderbook` channel emits an initial **snapshot** then
**batched diffs** — structurally identical to our §D2 envelope
(`{type:"snapshot"|"diff", data:{bids, asks, sequence}}`, decimal/atomic strings).
So the **MarketDataPort adapter for dYdX maps directly onto §D2 with no contract
change**. The **ExchangePort adapter** binds order place / cancel / status to dYdX
on-chain order placement (the user's wallet signs; the backend never holds keys).

### D3 — NEW **QuotePort** for aggregator / RFQ flows

Aggregators (LI.FI, and alternatives 0x / Rubic) are **not** order books — they
return **quotes / routes / RFQ**, a different shape than §D2/§D3. Add a new
read-mostly **QuotePort** (owned by `banxe-trading-backend`), provider-parameterized
like the ExchangePort adapter families:

```
QuotePort (NEW)
  get_quote(sell_token, buy_token, amount, from_chain, to_chain?) -> Quote
  get_routes(...) -> list[Route]              # ranked options
  build_transaction(route) -> UnsignedTx      # user signs client-side (self-custodial)
# Quote/amounts are atomic-unit decimal strings (I-01); never float.
```

REST surface (proposed): `GET /api/v1/quote`, `GET /api/v1/routes`,
`POST /api/v1/quote/build` (returns an unsigned tx). Provider selection
(LI.FI vs 0x vs Rubic) is governance-gated.

### D4 — Self-custodial wallet auth replaces the Keycloak-free AuthPort TODO

ADR-021 left auth as a "Keycloak-free `AuthPort` TODO". This ADR resolves it:
**wallet auth via MetaMask SDK / WalletConnect + Sign-In-with-Ethereum (SIWE,
EIP-4361)**. The frontend connects a wallet; the user signs a SIWE challenge; the
backend **verifies the signature** (no Keycloak, no password, no key custody) and
issues an opaque session token. The `AuthPort` becomes a **`WalletAuthPort`**:

```
WalletAuthPort
  challenge(address) -> SiweMessage
  verify(address, signature, siwe) -> Session   # opaque token; no custody
```

All three execution layers (dYdX, LI.FI, StakeKit) construct **unsigned**
transactions that the user's wallet signs — consistent with self-custody.

### D5 — Stack layer → protocol → port map

| Stack layer | Protocol / provider (MVP) | Port | Contract |
|---|---|---|---|
| On-chain order book (perps/spot CLOB) | **dYdX v4** Indexer | **MarketDataPort** (depth) + **ExchangePort** (orders) | **§D2 WS reused unchanged**; §D3 REST → dYdX order placement |
| Spot / cross-chain swap aggregation | **LI.FI** (alt: 0x / Rubic) | **QuotePort (NEW)** | new `quote`/`routes`/`build` REST |
| Yield / staking | **StakeKit / Yield.xyz** | **YieldPort (future, post-MVP)** | hosted REST; non-custodial txn build |
| Strategy / market-making | **Hummingbot** | strategy host (sidecar, future) | self-hosted; not a port |
| Frontend / UX | **OpenDAX** (optional ref) / our FE | n/a | our FE already exists (IL-156+) |
| Wallet auth | **MetaMask SDK / WalletConnect + SIWE** | **WalletAuthPort** (replaces AuthPort TODO) | verify signature → session |

### D6 — Recommended MVP order

1. **dYdX v4 first** — on-chain order book → **reuses §D2 unchanged** (lowest contract risk; proves the self-custodial path end-to-end).
2. **LI.FI** — implement **QuotePort** for spot/cross-chain swaps.
3. **StakeKit** — yield (introduces YieldPort) after the spot+perps path is proven.

Hummingbot and OpenDAX are **post-MVP / optional** (strategy host; reference UI).

## Canon constraints (binding)

- **REST/WS only (ADR-019):** dYdX Indexer REST + WS; LI.FI/StakeKit hosted REST. No GraphQL.
- **Decimal / I-01:** all amounts are **atomic-unit integer/decimal strings** (wei, quantums, subticks) end-to-end — **never float**. This is *stronger* than the CEX path (native atomic units).
- **No Keycloak (ADR-017):** resolved to **wallet auth (SIWE)**; backend holds **no private keys** (self-custodial — the user signs).
- **Env-only secrets:** integrator/API keys (LI.FI integrator string, StakeKit API key) via env; **no user private keys ever** in the backend. WSS/HTTPS everywhere.
- **AML / MiCA (ADR-016):** a self-custodial / non-custodial DeFi model **changes the regulatory surface** (CASP classification, Travel Rule applicability, MiCA). This is **governance/legal-gated** — see below.

## License governance (flags)

- ⚠️ **dYdX v4 is AGPL-3.0** (custom dYdX AGPL). **Consuming the public Indexer REST/WS API over the network does NOT trigger AGPL §13** — we do not vendor or link the AGPL code. **Vendoring** the AGPL client SDK or **self-hosting** the AGPL indexer/chain code *would* bring network-copyleft obligations. **Recommendation: consume dYdX via the Indexer API only; do not vendor AGPL code.** (Governance-gated.)
- **LI.FI** Apache-2.0, **StakeKit SDK** MIT, **Hummingbot** Apache-2.0 — all OSS-compatible.
- ⚠️ **OpenDAX**: community editions Apache-2.0/MIT but **stale (2023)**; the maintained path is **commercial cloud**. Community-vs-commercial choice is governance-gated.

## Consequences

- **Positive:** self-custodial (no key custody, no CEX counterparty risk); dYdX reuses §D2 with zero contract change; ADR-021 ports preserved; atomic-unit math is inherently I-01-clean; auth TODO resolved without Keycloak.
- **Negative / cost:** a new QuotePort + WalletAuthPort to build; AGPL handling discipline for dYdX; DeFi/MiCA legal surface; aggregator integrator economics; on-chain UX (gas, signing) differs from CEX.
- **Risk:** regulatory classification (MiCA/CASP) and Travel Rule on non-custodial flows; provider/aggregator outages; AGPL contamination if code is vendored carelessly.

## OPERATOR DECISION REQUIRED (gated — NOT decided here)

1. **Integrator keys / addresses** — LI.FI integrator string + fee-collection address; StakeKit/Yield.xyz API key; dYdX subaccount/wallet addresses. (Secrets via env; none committed.)
2. **Per-layer provider selection** — QuotePort: LI.FI vs 0x vs Rubic; dYdX market set; yield provider scope.
3. **Legal / MiCA stance** — CASP classification, Travel Rule applicability, non-custodial regulatory position (ADR-016).
4. **OpenDAX licensing** — community (stale) vs commercial cloud, or drop in favour of our existing FE.
5. **dYdX AGPL consumption mode** — API-only (recommended) vs vendoring (AGPL obligations).

## References (verified 2026-06-12)

- `dydxprotocol/v4-chain` (`LICENSE` = dYdX AGPL), `dydxprotocol/v4-clients` (py `dydx-v4-client` 1.1.6, js `@dydxprotocol/v4-client-js` 3.6.0 AGPL-3.0); Indexer `v4_orderbook` channel (snapshot + batched diffs)
- `lifinance/sdk` `@lifi/sdk` 4.0.0 Apache-2.0; LI.FI API `li.quest/v1`
- `stakekit/sdk` / `@stakekit/api-hooks` MIT; Yield.xyz hosted API
- `hummingbot/hummingbot` Apache-2.0 v2.14.0
- `openware/opendax` Apache-2.0 (community, 2023) / `openware/peatio` MIT
- ADR-021 (ExchangePort/MarketDataPort, §D2/§D3), ADR-016/017/019; HANDOFF IL-188; `HANDOFF-composable-defi-stack-integration.md` (S6.2–S6.7 plan, this PR)
