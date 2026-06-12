# HANDOFF — Trading Frontend ↔ Backend Integration (ExchangePort live data + orders)

Date: 2026-06-12
Status: DRAFT (Sprint 5 §1; discovery + integration spec; **no code**; ADR-057, I-28 append-only)
IL: IL-188
Branch: specs/handoff-trading-fe-backend-integration
Parent: HANDOFF-target-frontend-repo-bootstrap.md (IL-156); dependency-map-trading-frontend.md (IL-154); exchangeport-CONTRACT-SPEC-2026-06-06.md
Related ADRs/contracts: ADR-016 (PII/AML routing), ADR-017 (Keycloak cutover / auth), ADR-019 (GraphQL→REST per FE-canon convention), ADR-021 (ExchangePort — see §9 Canon citation note), ADR-027 (audit/CASS retention), ADR-050 (crypto-ops delivery), ADR-082 (charting)

> **Scope note (immutable).** This is a **read-only discovery + integration spec**. It creates **no** repository, changes **no** branch protection or visibility, and writes **no** integration code. All such actions are **OPERATOR-GATED** and listed in §7/§8. The goal is to define *how* `banxe-trading-frontend` moves from its deterministic mock feed (IL-185) to live market data + orders through the ExchangePort contract.

---

## 1. Executive summary

`banxe-trading-frontend` today renders entirely from a **deterministic in-memory mock feed** (`createMockSocketFactory`, IL-185) — no live backend is contacted. To go live it needs two backend surfaces:

1. **Market data** — order-book snapshot + diff over WebSocket (what the FE's `OrderBookWsClient` / `order-book-feed` controller consumes), plus REST for symbols/instruments.
2. **Orders** — REST place/cancel/status, mapping to the **ExchangePort** contract.

**The decisive finding:** the ExchangePort *contract* and a *Python in-process implementation* exist (in `banxe-payment-core`), but **no network-facing service (REST/WS BFF) exposes them to a browser**, and **no order-book market-data feed exists anywhere**. The FE's own `trade-proxy.ts` already names a backend ("TradeProxy" at `:8080`) that **does not exist as a repository**. Bridging FE↔ExchangePort therefore requires a new **trading backend / BFF** service — **repo creation is OPERATOR-GATED (do not create here)**.

---

## 2. Discovery — EXISTS vs MISSING (proof: paths/repos, verified via gh/git 2026-06-12)

### EXISTS

| Artifact | Location (verified) | Notes |
|---|---|---|
| ExchangePort **contract spec** | `banxe-architecture` `docs/refactor/legacy/exchangeport-CONTRACT-SPEC-2026-06-06.md` | Frozen contract: types, 4 ops, idempotency, 7-class error model, 11 conformance tests. Status: CONTRACT SPEC. |
| ExchangePort **implementation (Python port)** | `banxe-payment-core` `src/exchangeport/exchange_port.py`, `src/exchangeport/__init__.py` | Abstract `abc` interface: `get_rate / place_order / cancel_order / get_order_status`. `Amount = str` (Decimal string, never float). In-process port — **not network-exposed**. |
| ExchangePort **consumer (agent)** | `banxe-payment-core` `src/agents/fx_exchange_agent.py` (+ `tests/agents/test_fx_exchange_agent.py`) | Internal agent uses the port; confirms it is wired in-process only. |
| Rate provider | `crypto-ops-monitor` `api/main.py`; arch `crypto-ops-monitor-CONTRACT-SPEC-DRAFT-2026-06-08.md` (Status: **DRAFT, not buildable**) | Multi-chain RPC gateway; provides `getRate` for ExchangePort. **OUT of scope (its own words): order execution, order-book depth.** |
| FE REST/WS expectation | `banxe-trading-frontend` `src/shared/api/trade-proxy.ts` | Names backend `VITE_TRADE_PROXY_URL` (`:8080`), `VITE_TRADE_PROXY_WS` (`:8080/ws`); REST paths `/api/v1/orderbook/{symbol}`, `/api/v1/orders` (POST), `/api/v1/orders/{orderId}` (DELETE), `/api/v1/positions`, `/api/v1/balances`. |
| FE market-data types/client | `banxe-trading-frontend` `src/entities/order-book/types.ts`, `src/shared/api/ws-client.ts`, `src/features/order-book-feed/*` | `WsMessage`, `RawOrderBookSnapshot/Diff`, `OrderBookWsClient`, feed controller (IL-185). |
| FE env WS (feed) | `banxe-trading-frontend` `VITE_ORDERBOOK_WS_URL` (IL-185) | Order-book feed WS URL; defaults to mock factory when unset. |

### MISSING / GAPS

| Gap | Evidence | Consequence |
|---|---|---|
| **`banxe-trading-backend` repo** | `gh repo list CarmiBanxe` → only `banxe-trading-frontend`, `banxe-payment-core`, `crypto-ops-monitor` (no trading-backend / exchange-gateway / BFF). | No service to host the FE's `/api/v1/*` REST + order-book WS. **OPERATOR-GATED repo creation.** |
| **Network transport for ExchangePort** | `banxe-payment-core` has only `src/paymentology/webhook_server.py`; no FastAPI/uvicorn app exposing ExchangePort (`gh search code` FastAPI/uvicorn/websocket → none for exchangeport). | ExchangePort is reachable only in-process (Python). A browser cannot call it. A BFF must adapt REST/WS → ExchangePort. |
| **Order-book (L2 depth) market-data feed** | No `orderbook/snapshot/diff/depth/websocket` hits in `crypto-ops-monitor` or `banxe-payment-core` code search; ExchangePort contract has **no** depth/stream op; crypto-ops-monitor explicitly excludes order-book. | The FE's core feed (snapshot+diff) has **no backend source today**. Needs a market-data provider decision (exchange WS via adapter, or a new aggregator). |
| **ADR-021 ratified file** | `docs/adr/INDEX.md`: "ADR-021 UNASSIGNED — no file in either catalogue." Number is referenced widely but never written; `banxe-emi-stack` ADR-021 is a *mirror of ADR-016* (AI-plane PII/AML), not ExchangePort. | "ExchangePort = ADR-021" is informal. The **CONTRACT SPEC is the authority**; a real ADR-021 (or renumber) is an open governance item. See §9. |
| **Symbols / instruments REST source** | No instruments/symbols catalogue endpoint found in any backend; FE expects `/api/v1/orderbook/{symbol}` but nothing enumerates valid symbols. | Symbol list source is an open decision (§8). |

---

## 3. Target — which backend/port provides market data + orders

- **Orders →** the **ExchangePort** contract, implemented today in `banxe-payment-core/src/exchangeport/`. The FE must **not** call ExchangePort directly (it is a Python in-process port). A network-facing **trading backend / BFF** adapts the FE's REST surface (`/api/v1/orders*`) onto ExchangePort ops.
- **Rate quotes →** `crypto-ops-monitor` RPC (rate source consumed by ExchangePort adapters), already the contracted provider.
- **Market data (order-book snapshot/diff) →** **UNRESOLVED — no current provider.** Recommended target: the BFF owns a market-data module that subscribes upstream (exchange WS via a `PrimaryExchangeAdapter`, or an aggregator) and re-emits the FE's `{type:"snapshot"|"diff"}` envelope. This is the largest build item and a §8 open decision.

### Does `banxe-trading-backend` exist?

**No.** It must be created to host the FE's REST + order-book WS and bridge to ExchangePort.

> ⛔ **OPERATOR DECISION REQUIRED — repo creation.** Creating `banxe-trading-backend` (or designating `banxe-payment-core` to grow a network API module instead) is operator-gated. This HANDOFF does **not** create it. Two candidate shapes for the operator to choose (§8 D1):
> - **(A) New repo `banxe-trading-backend`** — a dedicated BFF/gateway (recommended; clean bounded context, own guardian gates, seeded from `banxe-repo-template`).
> - **(B) Extend `banxe-payment-core`** — add a network API surface (`src/exchangeport_api/`) exposing the existing port. Avoids a new repo but couples a browser-facing transport into the payment core.

---

## 4. ExchangePort contract mapping — FE ↔ backend

### 4.1 Market data (WS + REST) — *no ExchangePort op today; new BFF surface*

| FE construct (verified) | Shape | Backend WS channel / REST endpoint (proposed for BFF) |
|---|---|---|
| `OrderBookWsClient(url, cb, factory)` | connects `VITE_ORDERBOOK_WS_URL`; reconnect/backoff (1s→30s) | `GET (ws) {WS_BASE}/orderbook/{symbol}` — server pushes envelopes below |
| `WsMessage` snapshot | `{ type:"snapshot", data: RawOrderBookSnapshot }` | first frame on subscribe; full book |
| `WsMessage` diff | `{ type:"diff", data: RawOrderBookDiff }` | subsequent frames; incremental |
| `RawOrderBookSnapshot` / `RawOrderBookDiff` | `{ bids:RawPriceLevel[], asks:RawPriceLevel[], sequence:number }` | server emits identical JSON; `sequence` strictly increasing (store drops `diff.sequence ≤ snapshot.sequence`) |
| `RawPriceLevel` | `{ price:string, quantity:string }` | **decimal strings, never float** (I-01); `quantity:"0"` = delete level |
| `trade-proxy.ts` `orderBook(symbol)` | `GET /api/v1/orderbook/{symbol}` | REST snapshot fallback (same `RawOrderBookSnapshot` body) |

**Sequence/gap rule (must hold server-side):** snapshot carries a `sequence`; each diff increments it. On gap or reconnect the server re-sends a fresh snapshot (the FE store already ignores stale/older sequences).

### 4.2 Symbols / instruments — *new BFF REST*

| Need | Proposed endpoint | Body (proposed) |
|---|---|---|
| Tradable symbol list | `GET /api/v1/symbols` | `[{ symbol, baseAsset, quoteAsset, pricePrecision, qtyPrecision, status }]` |
| Instrument detail | `GET /api/v1/instruments/{symbol}` | tick size, min/max qty, fee schedule ref |

*(Not present in any backend today — see §8 D2 for the symbol source decision.)*

### 4.3 Orders — FE REST ↔ ExchangePort ops

| FE REST (`trade-proxy.ts`, verified) | ExchangePort op (`exchange_port.py`, verified) | Mapping notes |
|---|---|---|
| `POST /api/v1/orders` body `{symbol, side, type, amount, limitPrice?, clientOrderId, correlationId}` | `place_order(OrderRequest)` → `OrderResult` | BFF splits `symbol`→`base/quoteAsset`; **`clientOrderId` = UUIDv4 idempotency key (caller-generated)**; re-submit returns original result (never double-executes). |
| `DELETE /api/v1/orders/{orderId}` | `cancel_order(orderId)` → `bool` | idempotent; cancelling a final order returns `false`, not an error. |
| `GET /api/v1/orders/{orderId}` (status) | `get_order_status(orderId)` → `OrderResult` | read-only; safe to poll. |
| *(pre-trade rate)* | `get_rate(base, quote)` → `RateQuote` | honour `ttlSeconds`; **StaleRate** must refuse stale quotes. |
| `GET /api/v1/positions`, `/api/v1/balances` | *(no ExchangePort op)* | **GAP** — not in ExchangePort; needs account/portfolio source (§8 D3). |

**Error model passthrough (contract §Error model):** BFF maps the 7 ExchangePort error classes to HTTP + a typed JSON error carrying `correlationId` + `clientOrderId`:

| ExchangePort error | HTTP | FE action |
|---|---|---|
| ValidationError | 400 | fix + resubmit |
| IdempotencyConflict | 409 | reject (caller bug) |
| StaleRate | 409/425 | re-fetch rate, retry |
| ExchangeUnavailable | 503 | backoff retry (circuit-breaker) |
| InsufficientBalance | 402 | surface to user |
| ComplianceBlock | 451 | escalate MLRO; **never auto-retry** |
| PartialFillTimeout | 200+state | reconcile partial |

Every order op must emit exactly one audit event (`correlationId` + `clientOrderId`) per contract test 11 / ADR-027.

---

## 5. Migration plan — FE mock feed → live

Strictly additive to the FE; the mock stays the test/CI default (no test ever opens a live socket).

1. **Real WS adapter.** Add a `realSocketFactory` (thin wrapper over `new WebSocket(url)` — already the `DEFAULT_FACTORY` in `ws-client.ts`). The feed controller already accepts an injectable `socketFactory`.
2. **Env-gated default swap.** In `pages/order-book`, select factory by env (pattern already shipped in IL-185):
   - `VITE_ORDERBOOK_WS_URL` set → real WS factory (live).
   - unset (tests/CI/dev) → `createMockSocketFactory()` (deterministic).
3. **REST base.** Use `trade-proxy.ts` `getTradeProxyConfig()` (`VITE_TRADE_PROXY_URL` / `VITE_TRADE_PROXY_WS`). **Reconcile env names** (§8 D4): today `VITE_ORDERBOOK_WS_URL` (feed) and `VITE_TRADE_PROXY_WS` (proxy) coexist — pick one WS var or document both roles.
4. **Symbols.** Replace any hard-coded symbol with `GET /api/v1/symbols` (once D2 resolved).
5. **Snapshot/diff contract conformance.** Server must honour the §4.1 sequence rule; add a small FE integration test against a recorded fixture (still no live socket in CI).
6. **Order surface.** Wire `place/cancel/status` REST to the order-entry feature behind the same env gate; keep mock responses for CI.

**Invariant:** CI/tests remain fully deterministic — the mock factory is the default whenever env WS/REST vars are absent.

---

## 6. Auth/session + secrets (per canon)

- **No Keycloak (ADR-017).** Do not introduce a Keycloak/OIDC client in the FE for this slice. Session approach: the BFF terminates auth server-side; the FE sends an opaque bearer/session token over HTTPS/WSS supplied at runtime (never embedded). For the first live slice, **read-only market data may be unauthenticated**; **order endpoints require the session token** issued by the BFF's chosen mechanism (operator decision §8 D5 — must remain Keycloak-free).
- **Secrets via env only.** No secrets in code or repo. FE consumes only `VITE_*` **non-secret** base URLs at build time (`trade-proxy.ts` already enforces this — URLs, not credentials). Tokens are runtime-injected, never built in. WSS/HTTPS in all non-local environments.
- **Compliance routing (ADR-016).** Order flows that move client money must pass the ExchangePort `ComplianceBlock` gate (KYC tier / sanctions / Travel Rule) — escalate to MLRO, never auto-retry. The FE surfaces `451` as a compliance hold; it never bypasses it. AML/KYC validation is mandatory on any payment/order flow.

---

## 7. Step plan (operator-gated items flagged ⛔)

| # | Step | Owner | Gate |
|---|---|---|---|
| 1 | Approve target shape: new `banxe-trading-backend` **(A)** vs extend `banxe-payment-core` **(B)** | Operator | ⛔ **OPERATOR DECISION** |
| 2 | ⛔ **Create repo** `banxe-trading-backend` (if A) seeded from `banxe-repo-template`; or designate payment-core module (if B) | Operator | ⛔ **repo creation — gated** |
| 3 | Ratify **ADR-021 ExchangePort** (or renumber to a free ADR) so the contract has a governed home | Arch WG | governance |
| 4 | Decide market-data provider (exchange WS adapter vs aggregator) + symbol source | Arch WG / Operator | decision (§8 D1–D2) |
| 5 | BFF: implement `/api/v1/orderbook/{symbol}` WS (snapshot+diff, sequence rule) + `/api/v1/symbols` | Factory (backend) | code (separate SPEC) |
| 6 | BFF: implement order REST ↔ ExchangePort (`place/cancel/status/rate`) + 7-class error map + audit | Factory (backend) | code (separate SPEC) |
| 7 | FE: real WS factory + env-gated default swap + order REST wiring (mock stays CI default) | Factory (frontend) | code (separate SPEC) |
| 8 | Conformance: ExchangePort 11-test suite green for the chosen adapter; FE fixture integration test | Factory | tests |
| 9 | ⛔ Any branch-protection / visibility change on new repo | Operator | ⛔ **gated** |

Steps 5–8 are normal factory build tasks (each its own SPEC/PR). Steps 1, 2, 9 are operator-gated. Step 3 is governance.

---

## 8. Open decisions / blockers

- **D1 — Backend home (BLOCKER).** New `banxe-trading-backend` (recommended) vs extend `banxe-payment-core`. Blocks all build steps. ⛔ operator.
- **D2 — Order-book market-data provider (BLOCKER).** No L2 depth feed exists. Which upstream (exchange WS via `PrimaryExchangeAdapter`, CCXT Pro, or aggregator)? Drives §4.1.
- **D3 — Symbols/instruments source.** No catalogue endpoint today; needs a source of tradable pairs + precision/tick metadata.
- **D4 — Positions/balances source.** Not in ExchangePort; needs an account/portfolio backend (or explicit deferral of those FE panels).
- **D5 — Env var reconciliation.** `VITE_ORDERBOOK_WS_URL` (feed, IL-185) vs `VITE_TRADE_PROXY_WS` / `VITE_TRADE_PROXY_URL` (trade-proxy): converge on one WS convention.
- **D6 — Auth mechanism (Keycloak-free).** Token issuance/validation approach for order endpoints, per ADR-017.
- **D7 — ADR-021 governance.** Ratify a real ExchangePort ADR or renumber; the number is currently UNASSIGNED in the INDEX. ⛔ Arch WG.
- **D8 — Charting data feed.** DepthChart (ADR-082, IL-186) renders from the order-book store, so it is fed by D2; candlestick/OHLCV history (if added later) needs its own feed — out of scope here.

---

## 9. Canon citation note (accuracy)

The "ExchangePort = **ADR-021**" label is used per the **established FE-canon convention** (as in IL-154/IL-156 and the CONTRACT SPEC), but verification shows **ADR-021 has no ratified file** in `banxe-architecture` (`docs/adr/INDEX.md` → "UNASSIGNED"); `banxe-emi-stack`'s ADR-021 is a *mirror of ADR-016* (AI-plane PII/AML), unrelated to exchanges. **Authority for the ExchangePort contract is `exchangeport-CONTRACT-SPEC-2026-06-06.md`, not an ADR.** Likewise "ADR-019 (GraphQL→REST)" and "ADR-017 (Keycloak)" follow the FE-canon convention used by prior trading HANDOFFs; their numeric mapping in the arch ADR catalogue differs and is tracked as governance hygiene (D7). This note exists so downstream builders do not assume a governed ADR-021 exists.

---

## 10. References (verified 2026-06-12)

- `exchangeport-CONTRACT-SPEC-2026-06-06.md` (contract authority: types, ops, idempotency, 7 errors, 11 conformance tests)
- `banxe-payment-core` `src/exchangeport/exchange_port.py`, `src/agents/fx_exchange_agent.py` (Python port + consumer)
- `crypto-ops-monitor` `api/main.py`; `crypto-ops-monitor-CONTRACT-SPEC-DRAFT-2026-06-08.md` (rate provider; DRAFT)
- `banxe-trading-frontend` `src/shared/api/trade-proxy.ts`, `src/shared/api/ws-client.ts`, `src/entities/order-book/types.ts`, `src/features/order-book-feed/*` (FE surface)
- `HANDOFF-target-frontend-repo-bootstrap.md` (IL-156), `dependency-map-trading-frontend.md` (IL-154)
- ADR-016 (PII/AML routing), ADR-017 (Keycloak cutover), ADR-027 (audit/CASS), ADR-050 (crypto-ops delivery), ADR-082 (charting); `docs/adr/INDEX.md` (ADR-021 UNASSIGNED)
- IL-185 (live feed controller + mock factory), IL-186 (DepthChart)

=== END OF HANDOFF — Trading Frontend ↔ Backend Integration (Sprint 5 §1; discovery + spec; no code) ===
