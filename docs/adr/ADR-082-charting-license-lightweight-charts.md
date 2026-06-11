---
id: ADR-082
title: Charting Library — adopt lightweight-charts (Apache-2.0) for banxe-trading-frontend
status: ACCEPTED
date: 2026-06-11
accepted: 2026-06-11
supersedes: []
related:
  - "ADR-056-ledger-coupling-gate.md (this ADR ships with an IL block)"
binding_artifact: null
il_anchor: IL-181-CHARTING-LICENSE-2026-06-11
scope: BANXE-only
concept_only: false
---

# ADR-082: Charting Library — adopt lightweight-charts (Apache-2.0)

**Status:** ACCEPTED — 2026-06-11
**IL:** IL-181 (closes IL-154 OPEN item: charting license decision)

## Context

banxe-trading-frontend needs a charting library for the DepthChart and
candlestick widgets. IL-154 flagged the legacy `charting_library`
(TradingView Advanced Charts) as OUT — it is proprietary, requires a
per-seat commercial license, and its redistribution terms conflict with
our open-source scaffold (the repo is PUBLIC).

The HANDOFF (IL-157 §5) left the charting-license decision as an OPEN
item requiring an ADR before any charting code is introduced.

## Options Considered

### 1. TradingView `charting_library` (proprietary)
- Full-featured professional charting (candlestick, indicators, drawing tools).
- **Rejected:** proprietary license; per-seat cost; cannot be committed
  to a public repo; redistribution restrictions; vendor lock-in on
  data-feed adapter API.

### 2. `lightweight-charts` by TradingView (Apache-2.0)
- Open-source, Apache-2.0 license — freely redistributable.
- Candlestick, line, area, histogram, baseline chart types.
- Small bundle (~45 kB gzipped); zero dependencies; WebGL-accelerated.
- TypeScript-first; active maintenance; large community.
- Limitation: no built-in drawing tools or technical indicators — must
  be implemented as overlays or via a companion library.

### 3. Custom D3-based charting
- Maximum flexibility; no licensing concerns.
- **Rejected (for now):** high implementation cost for trading-grade
  performance (real-time tick updates, crosshair sync, responsive
  resize); would delay delivery of core trading features.

## Decision

**Adopt `lightweight-charts` (Apache-2.0) as the charting library for
banxe-trading-frontend.**

Rationale:
1. License-compatible with a public repo and BANXE's open-scaffold approach.
2. Purpose-built for financial data — candlestick, OHLCV, time-series.
3. Minimal bundle impact; performant for real-time order-book visualization.
4. If advanced features (drawing tools, indicator overlays) are needed
   later, they can be layered on top without replacing the core renderer.

Legacy `charting_library` remains permanently OUT — do NOT vendor or
import it anywhere in banxe-trading-frontend.

## Consequences

- `widgets/depth-chart/` and future candlestick widgets will import
  `lightweight-charts` from npm (`lightweight-charts` package).
- Depth-chart rendering will use the histogram/area series API.
- No drawing-tool or indicator-overlay library is adopted yet; defer to
  a future ADR if product requirements demand them.
- Integration tests should mock the chart container (canvas/WebGL) via
  `vitest` + `jsdom`; visual regression tests are out of scope for MVP.
