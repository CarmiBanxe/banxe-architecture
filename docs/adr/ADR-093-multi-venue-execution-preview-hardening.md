---
id: ADR-093
title: Multi-venue execution-preview hardening — unsigned, mock-only, additive
status: ACCEPTED
date: 2026-06-15
accepted: 2026-06-15
supersedes: []
related:
  - "ADR-083-composable-defi-stack.md (self-custodial unsigned intents; the venues)"
  - "ADR-089-market-making-advisory-seam.md (sibling moat seam)"
il_anchor: IL-236
scope: BANXE-only
concept_only: false
---

# ADR-093: Multi-venue execution-preview hardening

**Status:** ACCEPTED — 2026-06-15
**IL:** IL-236 (Sprint S16 — multi-venue unsigned execution-preview hardening, mock-safe)
**Extends:** ADR-083 (Composable DeFi Stack; self-custodial unsigned intents). The
unsigned / not-submitted, self-custodial boundary is **unchanged**.

## Context

The internal `POST /api/v1/execution/intent-preview` already exists (T9.1 / IL-219)
as an unsigned "advice → intent" seam over the `ExchangePort`. Phase-A now broadens
its coverage across multiple venues / products (spot / perp / earn) so a terminal
can compare candidate executions — **without** crossing into live execution. Real
signing, submission and multi-venue *routing* remain on the operator-gated go-live
track (G3).

## Decision

### D1 — Additive multi-venue / multi-product preview

Extend `/api/v1/execution/intent-preview` **additively**: when the request carries
`venues` / `productType` / `intentType` it returns a normalized `candidates` set
(per venue/product) with a deterministic `bestCandidate`. The legacy single-venue
(T9.1) request and response shape are **unchanged** (backward compatible).

### D2 — Unsigned, not submitted, always

`signed: false` and `submitted: false` at the top level **and per candidate**.
Candidate fields are descriptive/advisory only (`expectedPrice`, `estimatedFeeUsd`,
`estimatedSlippageBps`, `etaSeconds`, `confidence`, optional `notes`). Nothing is
signed, submitted, or executed; the backend holds no keys.

### D3 — Mock-only candidate ranking

Candidates and ranking are **deterministic mock heuristics** (per-venue fee /
slippage / ETA fixtures, default venues per product, a weighted score with a small
`riskProfile` adjustment). NO network, NO real quotes / orderbooks / gas estimators
/ chain reads.

### D4 — Fail-closed; no public /v1 exposure

The provider seam `BANXE_EXECUTION_PREVIEW_PROVIDER` defaults to `mock`; any other
value **fails closed at startup** (a live execution / submission / signing provider
is ODR). The request model is `extra="forbid"`, so `submit` / `sign` / `live` flags
and any non-`preview-only` `executionMode` **fail closed (`422`)**. The endpoint
stays **internal** (`/api/v1/...`); it is **not** added to the external `/v1` BaaS
facade and changes no partner contract.

## Consequences

- **Positive:** broader advisory execution breadth (multi-venue comparison) on main,
  reversible behind one endpoint; backward compatible.
- **Negative / cost:** real signing, submission, live routing and venue keys remain
  future operator-gated work (G3).
- **Risk:** scope creep toward live execution — fenced by D2/D4 (unsigned,
  fail-closed, ODR).

## OPERATOR DECISION REQUIRED (gated — NOT in S16)

- Client-side signing, submission / execution to a live chain, real multi-venue
  routing, real venue keys / endpoints (the go-live track, G3).
- Any external `/v1` exposure of the execution preview or partner-contract change.

## References

- `banxe-trading-backend/src/banxe_trading_backend/services/intent_preview.py`,
  `api/execution.py`, `config.py`
- `banxe-trading-backend/docs/specs/execution-intent-sandbox.md`
- ADR-083 (Composable DeFi Stack); IL-219 (T9.1 execution-intent bridge)
