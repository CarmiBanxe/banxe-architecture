---
id: ADR-085
title: DSE Risk & Earn advisory surfaces — advisory-only, no execution, no gamification
status: ACCEPTED
date: 2026-06-14
accepted: 2026-06-14
supersedes: []
related:
  - "ADR-084-dse-baas-foundation.md (extends — DSE advisory scope + boundaries)"
  - "ADR-083-composable-defi-stack.md (QuotePort/MarketDataPort/ExchangePort the DSE reads)"
il_anchor: IL-209
scope: BANXE-only
concept_only: false
---

# ADR-085: DSE Risk & Earn advisory surfaces

**Status:** ACCEPTED — 2026-06-14
**IL:** IL-209 (T7.3 — Risk & Earn advisory surfacing)
**Extends:** ADR-084 (DSE advisory-only foundation). Advisory boundaries are
**unchanged**; this ADR records the formal *content* extension of the engine.

## Context

ADR-084 set the DSE as an advisory-only, self-custodial, explainable layer
(POST /v1/dss/recommend), banning casino, gamification, or auto-execution. T7.3 extends
the *information surfaced* by each recommendation to **Risk** (Greeks, VaR, PnL,
drawdown, liquidity) and **Earn** (yields) metrics — used as utility inputs and
shown in the terminal + BaaS — **without adding any execution capability**.

## Decision

### D1 — Risk & Earn metrics are part of the ADVISORY engine

Each recommendation MAY carry `riskMetrics` (aggregated Greeks, parametric VaR99,
drawdown, unrealized PnL, liquidity) and, for earn-category actions, `earnMetrics`
(current yield, protocol, chain, lockup, variable flag, risk summary). These are
**estimates / simulations, NOT a promise of return or P&L**, and feed the utility
`U_a` (risk VaR term, earn yield in expected return). They grant **no right to
auto-execution** — the boundary set by ADR-084 is unchanged.

### D2 — No new execution endpoints; reuse Risk/Earn API *shapes* only

T7.3 adds **no** Risk API (`GET /v1/risk/*`) or Earn execution
(`POST /v1/orders/earn/*`) endpoints. The master-plan Risk/Earn field shapes are
reused **only** for format/mapping inside the existing advisory
`POST /v1/dss/recommend` (terminal: `POST /api/v1/dss/recommend`). Those dedicated
endpoints remain **future, separate ADRs/sprints**.

### D3 — Mock/default, env-gated providers

Risk (Greeks/VaR/PnL) and Earn (yields) are produced by `RiskMetricsProvider` /
`EarnRatesProvider` Protocol seams with **deterministic mock implementations by
default** (simple, stable models: Delta/Gamma/Theta stub Greeks, parametric VaR99,
position-based PnL; StakeKit/Aave-style fixed yield scenarios). No network, no keys
in tests/CI. Real providers register behind the same Protocols, env-gated
(`BANXE_DSE_RISK_PROVIDER` / `BANXE_DSE_EARN_PROVIDER`, default `mock`).

### D4 — Compliance-first (MiCA / MiFID II); NO gamification in this scope

Risk/Earn advisory surfaces are kept **separate from execution** with prominent
UI/spec disclaimers (estimates, not guarantees). **No gamification** — no streaks,
no Variable Ratio Reinforcement (VRRS), no leaderboards, no AgentFi auto-agents in
this scope. Any gamified/engagement surface or auto-execution requires a **separate
ODR/ADR** + compliance sign-off.

### D5 — Self-custodial pre-fill only

The terminal "Use this" / "Apply manually" affordance **only pre-fills** the
existing order/earn form for the user to review and submit themselves. It never
signs, executes, or holds keys.

## Consequences

- **Positive:** richer, explainable risk-adjusted guidance (Greeks/VaR/PnL + yields)
  for the terminal and BaaS partners (risk card / yield comparison) with a single
  advisory endpoint; clean self-custodial boundary; deterministic mocks for CI.
- **Negative / cost:** mock metrics are illustrative until real risk/earn data lands;
  dedicated Risk/Earn endpoints + productization deferred.
- **Risk:** scope creep toward execution/gamification — fenced by D2/D4 (separate
  ODR/ADR required).

## OPERATOR DECISION REQUIRED (gated — NOT in T7.3)

- Real risk-data and earn (StakeKit/Aave/risk-API) provider keys/endpoints behind
  the Protocol seams — env-only, never in code.
- Enabling a live Risk API in BaaS Tier 2/3; any execution of earn/orders.
- Any gamification / VRRS / leaderboards / AgentFi / autotrading — separate ODR/ADR.

## References

- `banxe-trading-backend/docs/specs/dse-utility-api.yaml` (Greeks, RiskMetrics, EarnMetrics)
- `banxe-trading-backend/docs/specs/dse-baas-api.yaml` (Recommendation.riskMetrics/earnMetrics)
- `banxe-trading-backend/docs/specs/dse-baas-risk-earn.md` (partner developer guide)
- `banxe-trading-backend/src/banxe_trading_backend/{risk,earn}/*`, `dse/engine.py`
- ADR-084 (DSE foundation), ADR-083 (Composable DeFi Stack); IL-206/207 (DSE T7.1/T7.2)
