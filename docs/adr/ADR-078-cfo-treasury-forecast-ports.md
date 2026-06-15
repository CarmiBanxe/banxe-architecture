---
id: ADR-078
title: CFO Treasury & Forecast Ports — FXExposurePort, NOSTROReconPort, LiquidityForecastPort (read-only) for EMI BANXE AI BANK
status: ACCEPTED
date: 2026-06-09
accepted: 2026-06-09
supersedes: []
related:
  - "ADR-049-intent-layer-client-facing-agent-masks.md (the §D2 gate-chain the consuming agents enforce)"
  - "ADR-046-decision-lineage-schema.md (one AgentDecisionRecord per masked action)"
  - "ADR-047-ai-cost-governance-policy.md (cost_cap + AUTO/REVIEW/BLOCK bands)"
  - "ADR-056-ledger-coupling-gate.md (this ADR ships with an IL block)"
binding_artifact: null
il_anchor: IL-172-CFO-TREASURY-FORECAST-PORTS-2026-06-09
scope: BANXE-only
concept_only: false
---

# ADR-078: CFO Treasury & Forecast Ports (read-only) for EMI BANXE AI BANK

**Status:** ACCEPTED — 2026-06-09
**Sprint:** 46 / IL-172 (companion: instruction-ledger/sprint-46/IL-TREAS-01-treasury-forecast.md)

## Context

Sprint-45 (IL-FPA-01) shipped two CFO-office L2 agents — FPAAgent and BIAgent — because each
bound cleanly to an existing port CONTRACT (LedgerPort, AnalyticsPort). The two remaining
ORG-STRUCTURE §2.5 agents were **deferred**: TreasuryAgent (§2.5.3 — NOSTRO reconciliation +
FX exposure) and ForecastAgent (§2.5.2 — liquidity forecasting) had **no injectable port
CONTRACT**. `services/recon/recon_port.py` is safeguarding-specific (client-funds vs
safeguarding bank), not NOSTRO/correspondent recon; there is no FX-exposure port; there is no
liquidity/forecast port. The agent pattern (ADR-049 §D2) governs a *call to an injected port*,
so the agents could not be built without first defining their ports. Fabricating live
integrations would violate I-10 (no fake integrations).

## Decision

Introduce three **read-only** hexagonal port CONTRACTs (injectable Protocol/ABC, with InMemory
implementations for tests), mirroring the existing LedgerPort/AnalyticsPort/recon-port shape.
Each carries its own `<Name>Error` for defense-in-depth and emits no lineage itself (the
consuming agent owns ADR-046 lineage). All monetary values are `Decimal` (I-01).

### D1 — FXExposurePort
- **DOES:** read FX positions and aggregate exposure (`get_exposure(currency_pair)`,
  `get_total_exposure()`), returning Decimal GBP magnitudes for a read-only exposure view.
- **DOES NOT:** execute FX trades, place or settle hedges, or mutate any position (soul
  `fx-exposure-agent`: "NEVER execute hedge trades"). Hedge *execution* stays in the existing
  `services/fx_engine` / `services/fx_exchange` services, out of this port's surface.

### D2 — NOSTROReconPort
- **DOES:** read internal vs external NOSTRO/correspondent balances and **compare**
  (`get_nostro_balances(account_id, as_of)`, `reconcile(account_id, as_of)` → difference +
  matched flag at £0.01 tolerance).
- **DOES NOT:** initiate transfers, post journal entries, or mutate balances (soul
  `cash-position-agent`: "NEVER initiate any bank transfers"). Distinct from the
  safeguarding `recon_port` (client-funds vs safeguarding bank) — this is NOSTRO/correspondent.

### D3 — LiquidityForecastPort
- **DOES:** supply read-only **inputs** for a rolling liquidity forecast
  (`get_forecast_inputs(horizon_days)` → opening balance + projected in/outflows;
  `get_current_position(as_of)`).
- **DOES NOT:** run statistical/ML forecast models (H2O/dbt per soul are upstream/out of
  scope), nor mutate any source. The ForecastAgent surfaces the rolling forecast over these
  inputs; modelling-tool integration is a later, separately-gated decision.

### D4 — Consumers (built in banxe-emi-stack this sprint)
- **TreasuryAgent** (§2.5.3, L2 Review) consumes FXExposurePort + NOSTROReconPort. The §D2
  "step-up" position is realised as the **>£100k CFO sign-off**: a material amount ≥ £100k
  forces the action to REVIEW and requires `human_reviewed_by` (escalate → CFO), regardless of
  confidence band.
- **ForecastAgent** (§2.5.2, L2 Review) consumes LiquidityForecastPort; below-AUTO holds for
  Head-of-FP&A review (HITL hold).

## Boundaries (explicit)

These ports are **read + compare only**. No port here moves money, executes a trade, posts a
ledger entry, or mutates state. They are governed surfaces for *reading* treasury/liquidity
data so a masked L2 agent can report/recommend under HITL — never act. Live adapters
(Frankfurter, QuantLib, Blnk, CAMT.053, Midaz) are out of scope; only InMemory test impls ship
here.

## Consequences

**Positive:** unblocks the two deferred CFO agents on a governed, no-fake-integration surface;
keeps execution (fx_engine/fx_exchange) cleanly separated from read-only treasury views; each
port is independently swappable behind a real adapter later.

**Negative / costs:** three new contracts to maintain; the forecast computation and live
adapters remain unbuilt (read-only inputs only); the £100k threshold + roles are config-as-data
on the mask and must be kept aligned with ORG-STRUCTURE §2.5.3.

## Alternatives considered

- **Reuse `services/recon/recon_port.py` for NOSTRO** — rejected: it is safeguarding-specific
  (client-funds vs safeguarding bank), a different reconciliation domain.
- **Bind TreasuryAgent to the existing fx_engine services** — rejected: those are
  execution-oriented (quoting, hedging, executing), not a read-only exposure CONTRACT; coupling
  a read mask to an execution service blurs the no-execute boundary.
- **Defer again until live adapters exist** — rejected: the port-first split lets the governed
  agent + contract land now (I-10-safe), with live adapters as a later swap.
