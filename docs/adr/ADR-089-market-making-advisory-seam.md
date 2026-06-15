---
id: ADR-089
title: Market-making advisory seam — strategy port over QuotePort/ExchangePort, mock-only, unsigned
status: ACCEPTED
date: 2026-06-14
accepted: 2026-06-14
supersedes: []
related:
  - "ADR-083-composable-defi-stack.md (Hummingbot as a future strategy sidecar, not a port)"
  - "ADR-087-dse-provider-foundation.md (mock-default / fail-closed provider pattern)"
il_anchor: IL-223
scope: BANXE-only
concept_only: false
---

# ADR-089: Market-making advisory seam

**Status:** ACCEPTED — 2026-06-14
**IL:** IL-223 (Sprint S12 / X9.1 — market-making advisory seam, mock-safe)
**Extends:** ADR-083 (Composable DeFi Stack). Advisory-only, self-custodial,
mock-first boundaries are **unchanged**.

## Context

ADR-083 lists Hummingbot as a **future strategy sidecar, "not a port"**. The CORE
advisory/sandbox concept (DSE + BaaS + execution-intent preview + provider
foundation + product surface) is complete on main. Sprint S12 opens the first
**moat** seam: a market-making *strategy* abstraction the platform can grow into,
delivered **mock-safe and advisory** with no live venue and no execution.

## Decision

### D1 — A strategy port over the existing self-custodial ports

Introduce `MarketMakingPort` — a strategy abstraction that produces an **advisory
quote ladder** around a mid price. It **composes over** the existing `QuotePort`
(LI.FI) and `ExchangePort` (dYdX unsigned) **without changing their semantics**.
Only a deterministic `MockMarketMakingStrategy` ships (symmetric ladder); a live
strategy host (e.g. a Hummingbot sidecar) is **operator-gated (ODR)**.

### D2 — Advisory + unsigned only

The ladder rungs are **unsigned suggestions** — `signed: false`, `submitted:
false`. Nothing is signed, submitted, or executed; the backend holds **no keys**
and contacts **no live venue** (self-custodial, ADR-083). It is decision-support
for market-making, not order placement.

### D3 — Internal terminal endpoint, not the partner BaaS surface

The seam is exposed only on the **internal** `POST /api/v1/mm/preview` (terminal
endpoint). It is **not** added to `dse-baas-api.yaml` and **not** served on the
external `/v1/...` BaaS facade (returns `404` there). It adds **no** new public
endpoint and **no** change to `POST /v1/dss/recommend` or the execution-intent
preview.

### D4 — Mock-default, fail-closed

`BANXE_MM_PROVIDER` defaults to `mock`; any other value **fails closed at startup**
(operator-gated). No network in the path, no credentials. Invalid inputs (spread,
levels, size, mid) return `422`.

### D5 — CORE contracts unchanged

`POST /v1/dss/recommend` ranking/utility and the execution-intent preview
semantics are unchanged (asserted by tests). The seam is purely additive and
reversible.

## Consequences

- **Positive:** a reversible, testable market-making strategy seam with zero CORE
  contract break; ready for a future live strategy host behind the same port.
- **Negative / cost:** a live strategy host, real venue keys, inventory/risk-aware
  live quoting, and per-rung execution composition remain future operator-gated
  work.
- **Risk:** scope creep toward live quoting/execution — fenced by D2/D4 (advisory,
  unsigned, fail-closed, ODR).

## OPERATOR DECISION REQUIRED (gated — NOT in S12)

- A live strategy host (Hummingbot sidecar) and real venue keys/endpoints.
- Client-side signing, submission/execution, multi-venue routing, live quoting.
- Any SLA, billing, or partner-tiering for a market-making product.

## References

- `banxe-trading-backend/src/banxe_trading_backend/ports/market_making_port.py`,
  `api/market_making.py`, `config.py`
- `banxe-trading-backend/docs/specs/market-making-sandbox.md`
- ADR-083 (Composable DeFi Stack); ADR-087 (mock-default / fail-closed pattern)
