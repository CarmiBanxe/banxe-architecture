# ADR-021: ExchangePort Network Transport — `banxe-trading-backend` + MarketDataPort

**Status:** ACCEPTED
**Date:** 2026-06-12
**Deciders:** Architecture WG (Banxe), Trading stack
**Scope:** banxe-trading-frontend, banxe-trading-backend (to be created — operator-gated), banxe-payment-core, crypto-ops-monitor
**Supersedes:** — (first ratified file for the long-referenced "ADR-021 ExchangePort" number; INDEX previously listed ADR-021 as UNASSIGNED)
**Source-of-determination:** top-level `**Status:** ACCEPTED` line (INDEX generator regex `^\*\*Status:\*\*`)
**IL:** IL-190 (Sprint 5 §2) — ratifies this ADR; builds on HANDOFF IL-188
**Related:**
- `exchangeport-CONTRACT-SPEC-2026-06-06.md` (the frozen ExchangePort contract — authority for ops/types/idempotency/errors)
- `docs/specs/HANDOFF-trading-frontend-backend-integration.md` (IL-188 — discovery; FE↔backend shapes)
- `decisions/ADR-016` (AI plane & PII/AML routing — ComplianceBlock), `decisions/ADR-017` (Keycloak cutover — no Keycloak in FE), ADR-019 (GraphQL→REST per FE-canon), ADR-027 (audit/CASS retention), ADR-050 (crypto-ops delivery), ADR-082 (charting)

> **Numbering note.** "ExchangePort = ADR-021" has been referenced across the trading SPECs/HANDOFFs for months while `docs/adr/INDEX.md` carried ADR-021 as *UNASSIGNED — no file in either catalogue*. Verified 2026-06-12: no `ADR-021-*.md` existed in `decisions/` or `docs/adr/`; the `banxe-emi-stack` ADR-021 is an unrelated *mirror of ADR-016*. This file **ratifies ADR-021 as that long-referenced ExchangePort ADR** (no collision — the number was genuinely free), and extends it with the network-transport + MarketDataPort decisions. The `exchangeport-CONTRACT-SPEC` remains the authority for the order/rate contract itself; this ADR governs *how it is exposed over the network*.

---

## Context

`banxe-trading-frontend` renders entirely from a deterministic in-memory mock feed (`createMockSocketFactory`, IL-185); no live backend is contacted. The HANDOFF (IL-188) verified the integration reality:

- **ExchangePort exists** as a Python **in-process `abc`** in `banxe-payment-core/src/exchangeport/exchange_port.py` (`get_rate / place_order / cancel_order / get_order_status`; `Amount = str` Decimal, never float). It is **not exposed over any network transport** — payment-core ships only a Paymentology webhook server. A browser cannot reach it.
- **No order-book (L2 depth) market-data feed exists** anywhere. ExchangePort is orders + rate only; `crypto-ops-monitor` is the rate source and explicitly excludes order execution and depth.
- The FE already names a backend it cannot find: `trade-proxy.ts` points at `VITE_TRADE_PROXY_URL`/`VITE_TRADE_PROXY_WS` (`:8080`) with REST `/api/v1/{orderbook,orders,positions,balances}`; the order-book feed uses `VITE_ORDERBOOK_WS_URL`.

Something must (a) expose ExchangePort over the network for a browser and (b) provide an order-book snapshot/diff feed. This ADR decides the boundary and the contracts.

## Decision

### D1 — Network boundary: a NEW repo `banxe-trading-backend` (Best-Answer, ratified)

A dedicated **`banxe-trading-backend`** service is the network boundary for the trading stack. It is the **only** browser-facing surface; it adapts REST/WS onto the existing ExchangePort and a new MarketDataPort.

- **`banxe-payment-core` stays the in-process port OWNER.** ExchangePort's contract, idempotency store, and adapters (Primary/CCXT/Hyperswitch) remain in payment-core. The trading-backend **reuses** ExchangePort as the source of truth for orders/rate — it **does not duplicate or re-implement** that logic. Integration is via the published port (in-process call if co-deployed, or a thin internal RPC), never by copying order logic.
- **Why a separate repo, not inside payment-core:** keep the EMI payment core isolated from a public browser-facing transport (blast-radius, deploy cadence, dependency surface, and guardian gates differ). The trading-backend seeds from `banxe-repo-template` (full guardian baseline) — see §Operator-gated.
- payment-core remains free of any FE/transport concerns; the trading-backend depends on payment-core, never the reverse.

> ⛔ **Creation of `banxe-trading-backend` is OPERATOR-GATED** (repo creation). This ADR ratifies the *decision*; it does not create the repo. See §Operator-gated steps.

### D2 — WS contract: order-book snapshot + diff (maps to FE shapes, IL-188 §4.1)

The trading-backend exposes a WebSocket channel the FE's `OrderBookWsClient` consumes (`VITE_ORDERBOOK_WS_URL`):

- **Channel:** `ws {WS_BASE}/orderbook/{symbol}`.
- **Envelope (verbatim FE `WsMessage`):**
  - `{ "type": "snapshot", "data": RawOrderBookSnapshot }` — first frame on subscribe (full book).
  - `{ "type": "diff", "data": RawOrderBookDiff }` — subsequent incremental frames.
- **Payload (verbatim FE types):** `RawOrderBookSnapshot`/`RawOrderBookDiff` = `{ bids: RawPriceLevel[], asks: RawPriceLevel[], sequence: number }`; `RawPriceLevel = { price: string, quantity: string }` — **decimal strings, never float (I-01)**; `quantity:"0"` deletes a level.
- **Sequencing (server invariant):** `sequence` strictly increases; each diff increments it. On gap or reconnect the server re-sends a fresh snapshot. (The FE store already drops `diff.sequence ≤ snapshot.sequence`.)
- **REST fallback:** `GET /api/v1/orderbook/{symbol}` returns a `RawOrderBookSnapshot` body.

### D3 — REST contract: orders / rate / symbols / instruments (maps to ExchangePort, IL-188 §4.2–4.3)

| REST (FE `trade-proxy.ts`) | ExchangePort op (payment-core) | Notes |
|---|---|---|
| `POST /api/v1/orders` `{symbol, side, type, amount, limitPrice?, clientOrderId, correlationId}` | `place_order(OrderRequest)` → `OrderResult` | backend splits `symbol`→`base/quoteAsset`; **`clientOrderId` = caller UUIDv4 idempotency key**; replay returns the original result (never double-executes). |
| `DELETE /api/v1/orders/{orderId}` | `cancel_order(orderId)` → bool | idempotent; cancelling a final order → `false`, not an error. |
| `GET /api/v1/orders/{orderId}` | `get_order_status(orderId)` → `OrderResult` | read-only; safe to poll. |
| `GET /api/v1/rate?base=&quote=` | `get_rate(base, quote)` → `RateQuote` | honour `ttlSeconds`; **StaleRate** refuses stale quotes. |
| `GET /api/v1/symbols` | *(new; backend catalogue)* | `[{symbol, baseAsset, quoteAsset, pricePrecision, qtyPrecision, status}]`. |
| `GET /api/v1/instruments/{symbol}` | *(new; backend catalogue)* | tick size, min/max qty, fee schedule ref. |
| `GET /api/v1/positions`, `/api/v1/balances` | *(no ExchangePort op — GAP)* | needs an account/portfolio source; out of scope here (tracked as open item). |

**Error model (contract §Error model passthrough):** the backend maps ExchangePort's 7 error classes to HTTP + a typed JSON error carrying `correlationId` + `clientOrderId`: ValidationError→400, IdempotencyConflict→409, StaleRate→409/425, ExchangeUnavailable→503, InsufficientBalance→402, ComplianceBlock→451, PartialFillTimeout→200+state. Every order op emits exactly one audit event (`correlationId`+`clientOrderId`) per ExchangePort conformance test 11 / ADR-027.

### D4 — New `MarketDataPort` (read-only L2 depth) with provider-adapter pattern

Because no order-book/depth feed exists, the trading-backend introduces a **`MarketDataPort`** — a read-only port for L2 order-book depth, owned by the trading-backend (it is a transport/market-data concern, not a payment-core concern):

```
MarketDataPort (read-only)
  subscribeOrderBook(symbol, onSnapshot, onDiff): Subscription   # drives the D2 WS channel
  getOrderBookSnapshot(symbol): RawOrderBookSnapshot             # REST fallback
  listSymbols(): SymbolInfo[]                                    # backs GET /api/v1/symbols
```

- **Provider-adapter pattern (mirrors ExchangePort's adapter families).** Concrete providers implement `MarketDataPort` behind a **provider-parameterized** selection (config flag, e.g. `MARKET_DATA_PROVIDER`), exactly as ExchangePort selects Primary/CCXT/Hyperswitch. No vendor is hardcoded in this ADR.
- **Emits the FE envelope directly** (D2 shapes), so the FE swaps `createMockSocketFactory` for a real WS factory with zero type changes (IL-185 already makes the socket factory injectable).
- **Decimal end-to-end (I-01):** prices/quantities are decimal strings across the port and the wire; conversion to number happens only at the FE chart boundary (already true per IL-186).
- **Conformance:** a `MarketDataPort` contract-test suite (sequence monotonicity, snapshot-on-gap, decimal-string fidelity, delete-on-zero) is a follow-up contract-tests task, analogous to ExchangePort's 11-test suite.

> **Provider selection is an OPERATOR/GOVERNANCE decision — not made here.** Candidates to evaluate (listed, not chosen): upstream exchange WS via a `PrimaryExchangeAdapter` (reuse the legacy fast-exchange connection), CCXT Pro watch-order-book, or a dedicated aggregator. Selection criteria: licensing, rate limits, symbol coverage, latency, and CASS/audit fit. Tracked as an open governance item.

## Canon constraints (binding)

- **ADR-019 — GraphQL→REST:** the trading-backend exposes **REST + WS only**. No GraphQL.
- **ADR-017 — no Keycloak:** the FE introduces no Keycloak/OIDC client. The backend terminates auth server-side; the FE sends an opaque bearer/session token over HTTPS/WSS, runtime-injected. First live slice: read-only market data MAY be unauthenticated; **order endpoints require the backend-issued session token** (mechanism is an open item, must remain Keycloak-free).
- **I-01 — Decimal:** `Amount`/price/quantity are decimal strings end-to-end (port, WS, REST); float is forbidden for money.
- **Env-only secrets:** no secrets in code or repo. The FE consumes only **non-secret** `VITE_*` base URLs at build time (`trade-proxy.ts` already enforces URLs-not-credentials); tokens are runtime-injected; WSS/HTTPS in all non-local environments.
- **ADR-016 — AML/PII routing:** money-moving orders pass the ExchangePort `ComplianceBlock` gate (KYC tier / sanctions / Travel Rule) → escalate to MLRO, **never auto-retry**; the FE surfaces `451` as a compliance hold and never bypasses it.

## Consequences

- **Positive:** clean network boundary; payment-core stays isolated; FE goes live by swapping one injectable factory (mock stays the CI/test default — no live socket in CI); ExchangePort reused, not duplicated; the long-dangling ADR-021 number is finally ratified and consistent with the contract.
- **Negative / cost:** a new service + repo to operate; a `MarketDataPort` provider must be selected and built (the largest remaining unknown); positions/balances still lack a backend source.
- **Risk:** order regression (R-SEC-NEW-03) and order audit (R-COMP-FCA-02) are mitigated by reusing ExchangePort's idempotency + audit guarantees rather than re-implementing them in the transport.

## Operator-gated steps (NOT performed by this ADR)

1. ⛔ **Create `banxe-trading-backend`** seeded from `banxe-repo-template` (repo creation — operator-gated).
2. ⛔ Any **branch-protection / visibility** change on the new repo (operator-gated).
3. **Governance:** select the `MarketDataPort` provider; decide the Keycloak-free auth mechanism; decide the data source for symbols, positions and balances.

Build steps (WS/REST surface, ExchangePort wiring, MarketDataPort adapter, conformance tests, FE factory swap) are normal factory tasks under their own SPECs/PRs once the repo exists.

## References

- `exchangeport-CONTRACT-SPEC-2026-06-06.md`; `banxe-payment-core` `src/exchangeport/exchange_port.py`, `src/agents/fx_exchange_agent.py`
- `crypto-ops-monitor` `api/main.py`; `crypto-ops-monitor-CONTRACT-SPEC-DRAFT-2026-06-08.md`
- `banxe-trading-frontend` `src/shared/api/{trade-proxy,ws-client}.ts`, `src/entities/order-book/types.ts`, `src/features/order-book-feed/*`
- `docs/specs/HANDOFF-trading-frontend-backend-integration.md` (IL-188), `HANDOFF-target-frontend-repo-bootstrap.md` (IL-156)
- ADR-016, ADR-017, ADR-019, ADR-027, ADR-050, ADR-082; `docs/adr/INDEX.md` (ADR-021 previously UNASSIGNED)
- IL-185 (mock feed + injectable factory), IL-186 (DepthChart), IL-188 (integration HANDOFF)
