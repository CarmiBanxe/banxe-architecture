---
id: ADR-084
title: Decision Support Engine (DSE) + BaaS advisory scope — advisory-only, no auto-execution
status: ACCEPTED
date: 2026-06-14
accepted: 2026-06-14
supersedes: []
related:
  - "ADR-083-composable-defi-stack.md (QuotePort/MarketDataPort/ExchangePort the DSE reads)"
  - "ADR-021-exchangeport-network-transport.md (self-custodial ports)"
il_anchor: IL-206
scope: BANXE-only
concept_only: false
---

# ADR-084: Decision Support Engine (DSE) + BaaS advisory scope

**Status:** ACCEPTED — 2026-06-14
**IL:** IL-206 (T7.1 — DSE foundation + BaaS contract)

## Context

A new parallel track (T7.x Decision & Risk / BaaS) sits on top of the existing
terminal stack (MarketDataPort → dYdX, ExchangePort unsigned-intent, QuotePort →
LI.FI, WalletAuthPort → SIWE). The Decision Support Engine (DSE) computes and
**explains** recommended actions (spot, perp, earn, risk, meta) with a utility score,
Kelly/Half-Kelly sizing, and sentiment + stress overlays; BaaS/TaaS partners may
call a pure advisory endpoint. This ADR fixes the **scope and the hard boundaries**
of that track (Sprint T7.1 spec + skeleton).

## Decision

### D1 — DSE is an ADVISORY-ONLY, explainable layer

The DSE produces ranked, explainable recommendations (utility `U_a`, Kelly/
Half-Kelly sizing, reasons). It **never executes, signs, or holds keys**
(self-custodial — consistent with WalletAuthPort/ExchangePort). All sizing is
informational; the user (or partner's user) signs any resulting transaction in
their own wallet.

- Utility: `U_a = w1·ER_a − w2·σ_a − w3·VaR99_a − w4·DD_a + w5·Liq_a`, with three
  presets (Conservative/Balanced/Aggressive) + custom weights.
- Sizing: Kelly `f* = (p·(b+1) − 1)/b` clamped to `[0,1]`; **Half-Kelly (f*/2) is
  the hard-limit default** surfaced to users.
- All monetary/metric fields are **decimal strings (I-01 — never float)**.

### D2 — Terminal ↔ BaaS boundary

- **Terminal (internal):** `POST /api/v1/dss/recommend` in `banxe-trading-backend`
  serves the terminal UI.
- **BaaS (external, Tier-2):** `POST /v1/dss/recommend` (OpenAPI in
  `banxe-trading-backend/docs/specs/dse-baas-api.yaml`) is a **pure advisory**
  partner endpoint. Kong gateway, partner API keys, billing, and rate limits are
  **out of scope** for T7.1 (spec/skeleton only). Both surfaces share one engine.

### D3 — NO casino-effect / gamification / auto-execution in this track

Casino-effect, engagement loops, real-money gamification, AgentFi auto-trading,
and "quant-frontier" models are **explicitly excluded** from this track. The
Feature-Map / math documents are used **only** for informational models and
fee-logic shapes, never for real-money gamification. Any future paper/demo or
gamified surface requires a **separate ODR/ADR** and a compliance review.

### D4 — Mock/fixture by default; real providers are env-gated future sprints

Sentiment (MiroFish) and stress (MicroFish CMS-VAE), and quote-driven expected
return (QuotePort), are **mock/fixture** in T7.1. Real integrations are separate,
**env-gated** sprints (`BANXE_DSE_*` provider seams default `mock`). No external
network call, endpoint, or key is introduced in T7.1.

### D5 — Compliance-first (MiCA / MiFID II)

The DSE is **decision-support / advisory**, kept distinct from execution. Every
response carries an advisory **disclaimer** (not investment advice; not an
execution or portfolio-management service; user retains custody). The
advisory-vs-execution separation and disclosure satisfy the MiCA/CASP and
MiFID II posture; nothing here performs portfolio management or discretionary
execution on behalf of the user.

## Consequences

- **Positive:** terminal + partners get explainable, risk-adjusted guidance with a
  single engine; clean self-custodial boundary; no new network/keys; spec-first
  contracts (OpenAPI) with model↔spec conformance tests.
- **Negative / cost:** mock metrics are illustrative until real sentiment/stress/
  pricing land; BaaS productization (Kong, keys, and billing) is deferred.
- **Risk:** scope creep toward gamification/auto-execution — fenced by D3 (separate
  ODR/ADR required).

## OPERATOR DECISION REQUIRED (gated — NOT in T7.1)

- Real provider keys/endpoints: MiroFish (sentiment), MicroFish (stress),
  StakeKit/LI.FI/dYdX/WalletConnect — env-only, never in code.
- Real fee, integrator, and white-label (BaaS) terms; Kong gateway + partner API keys.
- Any real-money gamification / casino-effect or AgentFi auto-execution — requires
  a separate ODR/ADR + compliance sign-off.

## References

- `banxe-trading-backend/docs/specs/dse-utility-api.yaml`, `dse-baas-api.yaml`
- `banxe-trading-backend/src/banxe_trading_backend/dse/*` (engine, models, kelly, utility, profiles)
- ADR-083 (Composable DeFi Stack: QuotePort/MarketDataPort/ExchangePort), ADR-021
- Master plan + DSE + BaaS + Feature-Map + math SSOT docs (informational only)
- IL-205 (LI.FI QuotePort), IL-204 (dYdX submission), IL-201 (SIWE)
