# HANDOFF — Composable DeFi Stack Integration (Sprint 6 plan)

Date: 2026-06-12
Status: DRAFT (Sprint 6.1; discovery + plan; **no integration code**; ADR-057, I-28 append-only)
IL: IL-197
Branch: adr/083-composable-defi-stack
Parent: ADR-083 (Composable DeFi Stack); ADR-021 (ExchangePort/MarketDataPort, §D2/§D3); HANDOFF IL-188
Related ADRs: ADR-083, ADR-021, ADR-016 (AML/MiCA), ADR-017 (no Keycloak → wallet auth), ADR-019 (REST/WS)

> **Scope note (immutable).** Discovery + sequencing plan only. **No integration
> code, no new dependencies, no secrets, no repo, protection, or visibility changes.**
> Every operator-gated item (keys, provider selection, MiCA stance, OpenDAX
> licensing, dYdX AGPL mode) is surfaced in ADR-083 §"OPERATOR DECISION REQUIRED"
> and below — none are decided or actioned here.

## 1. What ADR-083 fixed vs left open

- **Fixed:** self-custodial Composable DeFi Stack replaces the CEX/Binance dealer model; ADR-021 ExchangePort/MarketDataPort + §D2/§D3 **kept unchanged**; new **QuotePort** (aggregator/RFQ); **WalletAuthPort** (SIWE) replaces the Keycloak-free AuthPort TODO; MVP order dYdX v4 → LI.FI → StakeKit.
- **Open (gated):** integrator keys/addresses; per-layer provider; legal/MiCA stance; OpenDAX licensing; dYdX AGPL consumption mode.

## 2. Sprint 6.2–6.7 plan (each its own SPEC/PR; all behind mocks until keys land)

| Sprint | Deliverable | Port(s) | Notes / gates |
|---|---|---|---|
| **S6.2** | **dYdX MarketDataPort adapter** — bind the Indexer `v4_orderbook` (batched snapshot+diff) onto the existing §D2 envelope; keep the in-memory mock as the CI/default. | MarketDataPort | **§D2 reused unchanged.** API-only (no AGPL vendoring). No keys needed for public market data. |
| **S6.3** | **WalletAuthPort (SIWE)** — challenge/verify endpoints; backend verifies signature, issues opaque session; FE adds MetaMask SDK / WalletConnect connect. | WalletAuthPort | No Keycloak; **no key custody**. ⛔ session/token policy = operator. |
| **S6.4** | **dYdX ExchangePort adapter** — place / cancel / status as **unsigned** orders the wallet signs; §D3 REST maps to dYdX order placement; idempotency on `clientOrderId`. | ExchangePort | ⛔ dYdX subaccount/wallet addresses (env). Self-custodial signing on FE. |
| **S6.5** | **QuotePort + LI.FI adapter** — `GET /api/v1/quote`, `/routes`, `POST /quote/build` (unsigned tx); atomic-unit strings (I-01). | QuotePort (NEW) | ⛔ LI.FI integrator string + fee address; ⛔ provider choice (LI.FI vs 0x vs Rubic). Hosted REST. |
| **S6.6** | **YieldPort + StakeKit/Yield.xyz adapter** — list yields, build non-custodial staking txns. | YieldPort (NEW) | ⛔ StakeKit API key; ⛔ yield scope. Hosted REST. |
| **S6.7** | **Hardening** — conformance suites per port (sequence/snapshot-on-gap for MarketDataPort; idempotency/error-map for ExchangePort; quote-fidelity for QuotePort), MiCA/AML review hooks (ADR-016), observability. | all | ⛔ legal/MiCA stance; audit/Travel-Rule wiring. Optional: Hummingbot strategy sidecar; OpenDAX UI decision. |

**Invariant across all sprints:** mocks remain the CI/test default (no live network in CI); real providers activate only when their env keys/URLs are present — mirroring the IL-185/IL-194 pattern.

## 3. Contract reuse summary

- **§D2 (order-book WS):** dYdX Indexer `v4_orderbook` (snapshot + batched diffs) → maps onto the existing `{type, data:{bids,asks,sequence}}` envelope **with no change** (validated shape per IL-195). Decimal/atomic strings.
- **§D3 (REST orders / rate / symbols):** ExchangePort adapter binds to dYdX order placement; rate / markets / instruments from the Indexer.
- **NEW QuotePort:** aggregator quotes / routes / RFQ — separate from §D2/§D3 (different shape).
- **WalletAuthPort:** SIWE verify → opaque session (replaces AuthPort TODO).

## 4. Canon

REST/WS only (no GraphQL) · Decimal/I-01 via native atomic units (wei/quantums as strings, never float) · no Keycloak (wallet/SIWE) · env-only secrets, **no user private keys in backend** (self-custodial) · ADR-016 AML + MiCA surface is governance-gated.

## 5. Open decisions / blockers (mirror ADR-083; ⛔ = operator/governance)

- ⛔ **Integrator keys/addresses** — LI.FI integrator + fee address; StakeKit API key; dYdX subaccount/wallet (env only).
- ⛔ **Per-layer provider selection** — QuotePort (LI.FI / 0x / Rubic); dYdX markets; yield scope.
- ⛔ **Legal / MiCA stance** — CASP, Travel Rule, non-custodial classification (ADR-016).
- ⛔ **OpenDAX licensing** — community (stale) vs commercial vs drop.
- ⛔ **dYdX AGPL consumption mode** — API-only (recommended) vs vendoring.

## 6. References

- ADR-083 (`docs/adr/ADR-083-composable-defi-stack.md`), ADR-021, ADR-016/017/019
- HANDOFF IL-188 (FE↔backend integration), IL-185 (FE feed + mock), IL-194 (backend skeleton), IL-195 (§D2 validated)
- dYdX `dydxprotocol/v4-chain` + `v4-clients`; `lifinance/sdk`; `stakekit/sdk`; `hummingbot/hummingbot`; `openware/opendax`

=== END OF HANDOFF — Composable DeFi Stack Integration (Sprint 6.1; discovery + plan; no code) ===
