---
id: ADR-086
title: Risk & Earn BaaS read-only sandbox endpoints — analytics-only, no execution
status: ACCEPTED
date: 2026-06-14
accepted: 2026-06-14
supersedes: []
related:
  - "ADR-085-dse-risk-earn-scope.md (extends — Risk/Earn advisory content)"
  - "ADR-084-dse-baas-foundation.md (DSE advisory-only foundation + boundaries)"
  - "ADR-083-composable-defi-stack.md (QuotePort/MarketDataPort/ExchangePort seams)"
il_anchor: IL-211
scope: BANXE-only
concept_only: false
---

# ADR-086: Risk & Earn BaaS read-only sandbox endpoints

**Status:** ACCEPTED — 2026-06-14
**IL:** IL-211 (T7.5 — first read-only Risk/Earn BaaS endpoints, sandbox)
**Extends:** ADR-084 (DSE advisory-only foundation) and ADR-085 (Risk/Earn
advisory content). The advisory, self-custodial, no-execution boundary is
**unchanged**; this ADR records the first *dedicated* Risk/Earn data endpoints.

## Context

Through T7.1–T7.4 the only externally surfaced BaaS endpoint was the advisory
`POST /v1/dss/recommend` (with a partner sandbox DX layer, IL-210). ADR-085 D2
explicitly deferred dedicated Risk/Earn endpoints to a future ADR. The roadmap
(TaaS API Suite Phase 2) describes `GET /v1/risk/greeks` (portfolio Greeks) and
`GET /v1/earn/rates` (yield comparison) as low-level data services partners may
consume on their own or alongside the DSE.

T7.5 introduces the **first two** of these — strictly read-only, sandbox, mock
data — so partners get composable Risk/Earn analytics without any execution
capability. This is a surface expansion beyond the single advisory endpoint, so
it warrants its own ADR to fix the boundary precedent that the future Risk
(`var`/`stress`/`pnl`) and Earn execution endpoints will inherit.

## Decision

### D1 — Two read-only analytics endpoints (sandbox)

Add `GET /v1/risk/greeks` (portfolio-level Delta/Gamma/Vega/Theta/Rho for a
target asset / net notional) and `GET /v1/earn/rates` (current-yield comparison
"rate cards": asset, protocol, apy, lockup, variable flag, qualitative risk
band). Internal paths `GET /api/v1/risk/greeks` and `GET /api/v1/earn/rates`.
Both are **GET / read-only** — they return data and estimates only.

### D2 — Analytics, NOT execution (MiCA / MiFID II)

These are advisory analytics, kept **separate from execution**. There is **no**
`POST /v1/risk/stress`, no `POST /v1/orders/earn/*`, no stake/unstake, no order
placement. Self-custodial: the backend signs nothing and holds no keys. Per
MiCA CASP / MiFID II, analytics and execution stay separated, with prominent
disclaimers (estimates / simulations, not a promise of return, not advice).

### D3 — Sandbox / mock-data default, env-gated providers

Values are produced by `RiskGreeksProvider` and `EarnRatesCatalog` Protocol
seams with **deterministic mock implementations by default** (light math, no
heavy calibration). Every response is flagged `source: "sandbox-mock"`. No
network, no keys, no production endpoints in code or config. Real providers
register behind the same Protocols, env-gated (`BANXE_RISK_GREEKS_PROVIDER` /
`BANXE_EARN_RATES_PROVIDER`, default `mock`); any non-mock value raises an
operator-gated error this sprint.

### D4 — No gamification, no agentic features

No streaks, no Variable Ratio Reinforcement, no leaderboards, no tournaments,
no copy-trading, no AgentFi / autotrading — not even in examples. The endpoints
surface facts (Greeks, risk bands, rates) only. Any engagement or auto-execution
surface requires a separate ODR/ADR + compliance sign-off.

### D5 — Future Risk/Earn endpoints remain deferred

`GET /v1/risk/var`, `POST /v1/risk/stress`, `GET /v1/risk/pnl`, live rate feeds,
and any earn execution are **future Phase 2+**, each under its own ADR + legal
review. This ADR covers only the two read-only sandbox endpoints above.

## Consequences

- **Positive:** partners gain composable, read-only Risk/Earn analytics they can
  use standalone or with the DSE; clean analytics-vs-execution boundary set for
  the whole Risk/Earn surface; deterministic mocks keep CI network-free.
- **Negative / cost:** mock values are illustrative until real risk/earn data and
  calibration land; the remaining Risk/Earn endpoints + productization deferred.
- **Risk:** scope creep toward execution/gamification — fenced by D2/D4/D5
  (separate ODR/ADR required).

## OPERATOR DECISION REQUIRED (gated — NOT in T7.5)

- Real risk-model and earn (StakeKit / Aave / risk-data) provider keys/endpoints
  behind the Protocol seams — env-only, never in code.
- Enabling production Risk/Earn endpoints, live rate feeds, Kong gateway, partner
  keys, billing or rate limits.
- Any further Risk endpoint (var / stress / pnl) or earn execution (stake /
  unstake / orders) — separate ADR + legal review.
- Any gamification / VRRS / leaderboards / AgentFi / autotrading — separate ODR/ADR.

## References

- `banxe-trading-backend/docs/specs/risk-api.yaml` (GET /v1/risk/greeks)
- `banxe-trading-backend/docs/specs/earn-api.yaml` (GET /v1/earn/rates)
- `banxe-trading-backend/src/banxe_trading_backend/risk/greeks.py`, `api/risk.py`
- `banxe-trading-backend/src/banxe_trading_backend/earn/rates.py`, `api/earn.py`
- `banxe-trading-backend/docs/specs/dse-baas-sandbox-guide.md` (Risk/Earn sections)
- ADR-085 (Risk/Earn advisory content), ADR-084 (DSE foundation); IL-209/210 (T7.3/T7.4)
