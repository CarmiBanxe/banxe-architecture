# Legacy Trading Frontend — Dependency Map & Migration Inventory

Date: 2026-06-08
Status: DRAFT (Sprint 2 read-only audit; ADR-057, I-28 append-only)
Source: BANXE.RAR listing (/tmp/banxe-listing.txt, encrypted archive at /mnt/c/Users/mmber/Мой диск/banxe.rar)
Parent SPEC: trading-ui-group-SPEC-2026-05-23.md (SPEC #4)
Related: ADR-016 (trading-ui migration); ADR-021 (ExchangePort); exchangeport-CONTRACT-SPEC-2026-06-06.md

## Scope

Two legacy frontend projects in BANXE.RAR:
- **banxe-trade-view** — React CRA skeleton, 2 commits, ABANDONED
- **banxe-trade-view-new** — Active trading frontend, React + MobX + TradingView charting, ~316 TS/TSX source files

neuron-bitshares-ui (22 MB BitShares fork) is NOT in the BANXE.RAR listing — it resides in a separate `neuron/` archive or repo. This inventory covers only the two `banxe/` projects.

---

## Axis 1: Routes & Navigation

### banxe-trade-view (skeleton)
- `src/routes/endpoints.tsx` — route constants
- `src/routes/router.tsx` — React Router setup
- Minimal: likely only a landing route

### banxe-trade-view-new (active)
- `src/routes/endpoints.ts` — route path constants
- `src/routes/index.ts` — route registry
- `src/routes/router.tsx` — React Router with lazy loading
- Pages: `components/pages/SpotPage/`, `components/pages/ChartFutures/`

**Classification:** REWRITE. Route structure is trivial (2 pages); rebuild from scratch in banxe-trading-ui with Next.js or Vite router. No reuse value.

---

## Axis 2: Screens / Pages

| Screen | Path | Complexity | Classification |
|---|---|---|---|
| SpotPage | `components/pages/SpotPage/` | HIGH (chart + orderbook + place-order + balances + trade history) | REFACTOR — layout composition reusable |
| ChartFutures | `components/pages/ChartFutures/` | HIGH (futures chart + leverage + margin mode + calculator) | REFACTOR — layout composition reusable |
| MobileTradeTabs | `components/organisms/MobileTradeTabs/` | MEDIUM (responsive tab switching) | REWRITE — mobile-first rebuild |
| MobileChartSpotPairs | `components/organisms/MobileChartSpotPairs/` | MEDIUM | REWRITE |

**Classification:** REFACTOR page composition patterns (widget grid layout); REWRITE the pages themselves in modern React.

---

## Axis 3: Order Flow

### Place Order (Spot)
- `components/organisms/SpotPlaceOrder/` — order form (market/limit)
- `components/molecules/SpotCalculatorMarket/` — market order calculator
- `controllers/SpotControllers/PlaceOrdersController/` — order submission logic
- `controllers/SpotControllers/query.ts` — GraphQL mutations

### Place Order (Futures)
- `components/organisms/FuturesPlaceOrder/` — futures order form
- `components/molecules/FuturesCalculatorMarket/` — market calculator with cost/max
- `components/molecules/FuturesCalculatorStopMarket/` — stop-market calculator
- `controllers/Futures/PlaceOrderController/` + `query.ts` — submission + GraphQL
- `components/modals/AdjustLeverage/` — leverage adjustment modal
- `components/modals/MarginEdit/` — margin edit modal
- `components/modals/MarginMode/` — cross/isolated margin toggle
- `components/modals/FuturesCalculator/` — PNL/target/averaging calculators

### Order Status & History
- `components/molecules/FuturesTabOpenOrders/` — open orders list
- `components/molecules/FuturesTabOrdersHistory/` — order history
- `components/molecules/FuturesTabTradesHistory/` — trade fills
- `components/molecules/ChartPanelActiveOrders/` — chart overlay for active orders
- `components/molecules/ChartPanelAllOrders/` — all orders panel
- `components/molecules/ChartPanelHistory/` — history panel
- `stores/SpotPageStores/InformationOnOrdersStore/` — order info state
- `stores/SpotPageStores/OrderFilterStore/` — order filtering
- `utils/serializeOrders.ts` — order data serialization
- `utils/iterateOrders.ts` — order iteration helpers
- `utils/typeOfOrdersCalculators/` — calculator logic per order type

**Classification:** REFACTOR. Order flow logic in controllers/ and utils/typeOfOrdersCalculators/ contains business rules (margin calculation, PNL, averaging) worth extracting. UI components REWRITE. GraphQL queries DROP (ADR-019 → REST).

---

## Axis 4: Balances

- `components/atoms/BalanceChange/` — balance change display
- `components/molecules/TradingBalance/` — trading account balance widget
- `components/molecules/ChartPanelBalances/` — balances panel in chart area
- `components/molecules/DashboardWalletMain/` — main wallet display (trade-view only)
- `components/molecules/DashboardWalletSec/` — secondary wallet display (trade-view only)
- `components/molecules/DashboardStat/` — dashboard statistics (trade-view only)

**Classification:** REWRITE. Balance display is purely presentational. Data source moves from GraphQL to ExchangePort + WalletPort REST APIs. No reuse value in UI components; Decimal-only invariant (I-01) requires fresh implementation.

---

## Axis 5: Market Data

### Pairs & Tickers
- `stores/SpotPageStores/PairsGroupStore/` — spot trading pairs
- `stores/SpotPageStores/CurrentPairStore/` — selected pair state
- `stores/SpotPageStores/MarketFavoritesStore/` — user favorites
- `stores/FuturesStores/PairsFuturesPageStore/` — futures pairs
- `stores/FuturesStores/PairDataStore/` — pair-specific data
- `stores/FuturesStores/MarketFavoritesFuturesStore/` — futures favorites
- `stores/FuturesStores/TickerAndMarkGroupStore/` — ticker + mark price
- `stores/FuturesStores/ExchangeInfoStore/` — exchange info (symbol rules, limits)
- `components/molecules/ChartItemTicker/` — ticker display
- `components/molecules/ChartPairMenu/` — pair selector

### Order Book
- `stores/NewOrderBookStore/` — order book state (MobX)
- `controllers/OrderBook/OrderBookController.ts` — order book data controller
- `controllers/OrderBook/OrderBookStream.ts` — WebSocket order book stream
- `controllers/OrderBook/types.ts` — order book types
- `controllers/SpotControllers/OrderBookController/` — spot order book
- `controllers/Futures/OrderBookController/` — futures order book
- `controllers/FuturesOrderBook/` — alternative futures order book controller
- `components/organisms/SpotOrderBook/` — spot order book UI
- `components/organisms/FuturesOrderBook/` — futures order book UI
- `components/molecules/OrderBookList/` — generic order book list
- `components/molecules/ScrollableTableOrderBook/` — scrollable order book
- `components/atoms/OrderBookBlock/` — order book row
- `utils/orderBook.ts` — order book utilities

### Last Trades
- `stores/LastTradesStore/` — last trades state
- `components/organisms/SpotLastTrades/` — spot last trades
- `components/organisms/FuturesLastTrades/` — futures last trades
- `components/organisms/SpotLastTradesHeader/` — header
- `components/organisms/FuturesLastTradesHeader/` — header
- `components/atoms/LastTradesHeader/` — generic header

**Classification:** REFACTOR stores (MobX state management patterns extractable → Zustand/Jotai). Order book stream controller (OrderBookStream.ts) is REUSE — WebSocket logic for order book diffs is non-trivial and tested. UI components REWRITE.

---

## Axis 6: Auth

### banxe-trade-view (skeleton)
- `components/molecules/AuthorisationMenu/` — login/register menu
- `components/molecules/AuthPopUp/` — auth popup modal
- `components/atoms/ButtonLogin/` — login button

### banxe-trade-view-new
- No dedicated auth components found in src/. Auth likely handled by parent app (banxe-frontend-monorep) or external SSO (Keycloak per ADR-017).

**Classification:** DROP. Auth is handled by Keycloak (ADR-017, S12 IAM hardening). No trading-specific auth components needed. Skeleton auth components are abandoned.

---

## Axis 7: WebSocket / API Calls

### TradingView Charting Data Feed (WebSocket)
- `public/js_api/datafeed.js` — spot data feed adapter for TradingView
- `public/js_api/wss_streaming.js` — spot WebSocket streaming
- `public/js_api/helpers.js` — feed helpers
- `public/js_apiFutures/js_api/datafeed.js` — futures data feed
- `public/js_apiFutures/js_api/wss_streaming.js` — futures WebSocket streaming
- `public/js_apiFutures/js_api/helpers.js` — futures feed helpers
- Duplicated in `src/utils/core/js_api/` and `src/utils/core/js_apiFutures/`

### Trade Proxy (REST/WS Gateway)
- `src/utils/TradeProxy/index.ts` — main proxy class
- `src/utils/TradeProxy/urls.ts` — API endpoint URLs
- `src/utils/TradeProxy/dataPrepare.ts` — request/response transformation
- `src/utils/TradeProxy/types.ts` — proxy type definitions

### GraphQL Controllers
- `src/controllers/ChartController/query.ts` — chart data queries
- `src/controllers/SpotControllers/query.ts` — spot trading queries/mutations
- `src/controllers/Futures/PlaceOrderController/query.ts` — futures order mutations
- `src/controllers/Futures/InfoController/query.ts` — futures info queries
- `src/controllers/Futures/PanelsController/query.ts` — panel data queries
- `src/controllers/Futures/query.ts` — general futures queries

**Classification:**
- TradeProxy: REFACTOR — extract URL map and data transformation logic; rebuild as typed fetch client against ExchangePort REST API.
- WebSocket streaming (wss_streaming.js): REUSE — non-trivial real-time data plumbing; adapt to new WS endpoint.
- GraphQL queries: DROP — ADR-019 mandates GraphQL → REST migration. Query shapes document required API surface.

---

## Axis 8: Widget Composition

### Atomic Design Pattern
The codebase follows Atomic Design (atoms → molecules → organisms → pages):

| Level | Count (approx) | Examples |
|---|---|---|
| Atoms | ~30 | Button, Input, Tabs, Typography, Tooltip, Checkbox, Spiner, TradingTab |
| Molecules | ~25 | OrderBookList, TradingBalance, ChartPairMenu, Calculator variants |
| Organisms | ~15 | SpotChart, SpotOrderBook, SpotPlaceOrder, FuturesChart, DepthChart |
| Modals | ~5 | AdjustLeverage, MarginEdit, MarginMode, FuturesCalculator |
| Pages | 2 | SpotPage, ChartFutures |

### Layout Composition
- SpotPage: chart (left) + orderbook (center) + place-order (right) + history (bottom)
- ChartFutures: chart (left) + orderbook (center) + futures-place-order (right) + leverage/margin panels

### State Management
- MobX stores (17 stores across Spot and Futures domains)
- Controller layer mediates between stores and API/WebSocket

**Classification:** REWRITE UI components (styled-components → design-system tokens). REFACTOR composition patterns (grid layout, responsive breakpoints). MobX stores REFACTOR → modern state management (Zustand recommended).

---

## Charting Replacement (dedicated block)

### Legacy: TradingView Charting Library
- `src/charting_library/` — vendored TradingView library (~hundreds of bundled JS/CSS files)
- `public/datafeeds/udf/` — UDF data feed adapter
- Integration: `components/organisms/SpotChart/`, `components/organisms/FuturesChart/`, `components/organisms/DepthChart/`
- Data feeds: `js_api/datafeed.js` + `wss_streaming.js` (spot), `js_apiFutures/` (futures)

### Assessment
- TradingView Charting Library is proprietary (requires license).
- The vendored copy is from an older version (pre-2024 based on bundle hashes).
- DepthChart (`components/organisms/DepthChart/config.ts`) is a custom implementation.

### Replacement options

| Option | Pros | Cons | Recommendation |
|---|---|---|---|
| TradingView (new license) | Feature parity; proven | License cost; vendor lock-in | RECOMMENDED if budget allows |
| Lightweight Charts (TradingView OSS) | Free; MIT; good for basic charts | No advanced features (drawings, indicators) | FALLBACK — sufficient for MVP |
| Custom D3/Canvas | Full control; no vendor | High dev cost; maintenance burden | NOT RECOMMENDED |

### Decision needed
- **License check:** Does BANXE hold a current TradingView license? If yes, upgrade to latest version. If no, start with Lightweight Charts for MVP and evaluate license later.
- **DepthChart:** Custom implementation — REUSE config.ts depth chart logic; reimplement rendering in Canvas/SVG.

---

## Summary Classification Matrix

| Axis | Component Group | Files | Verdict | Rationale |
|---|---|---|---|---|
| Routes | router, endpoints | 3 | REWRITE | Trivial; 2 pages |
| Screens | SpotPage, ChartFutures | 4 | REFACTOR layout | Composition pattern reusable |
| Order Flow | PlaceOrder, Calculators, Controllers | ~30 | REFACTOR logic | Margin/PNL/averaging math worth extracting |
| Balances | Balance widgets | 6 | REWRITE | Presentational only; Decimal-only fresh |
| Market Data | Stores, OrderBook, LastTrades | ~25 | REFACTOR stores + REUSE OrderBookStream | WS stream logic non-trivial |
| Auth | AuthPopUp, ButtonLogin | 3 | DROP | Keycloak handles auth (ADR-017) |
| WebSocket/API | TradeProxy, wss_streaming, GraphQL | ~20 | REFACTOR proxy + REUSE WS + DROP GQL | GQL → REST (ADR-019) |
| Widgets | Atoms/Molecules/Organisms | ~70 | REWRITE | New design system |
| Charting | TradingView + DepthChart | vendored | REPLACE (license TBD) | Vendored copy outdated |

### banxe-trade-view (skeleton): DROP entirely
2 commits, abandoned. No unique code. Superseded by banxe-trade-view-new.

### Key reuse candidates (extract before rewrite)
1. `utils/typeOfOrdersCalculators/` — order type calculation logic (margin, PNL, cost/max)
2. `controllers/OrderBook/OrderBookStream.ts` — WebSocket order book diff stream
3. `utils/TradeProxy/urls.ts` + `dataPrepare.ts` — API surface map (documents required endpoints)
4. `utils/orderBook.ts` + `utils/serializeOrders.ts` — order book data utilities
5. `components/organisms/DepthChart/config.ts` — depth chart configuration
6. MobX store interfaces (17 stores) — document state shape for Zustand migration
7. GraphQL query files (6 controllers) — document required API surface for REST rebuild

---

## Next steps (awaiting operator confirmation)

- [ ] Step 2: Extract and read key files (OrderBookStream, TradeProxy, calculators) from encrypted archive for detailed logic audit
- [ ] Step 3: Map GraphQL queries → ExchangePort REST endpoints
- [ ] Step 4: Charting license decision (TradingView vs Lightweight Charts)
- [ ] Step 5: Produce migration SPEC for banxe-trading-ui (build-fresh with extracted logic)
