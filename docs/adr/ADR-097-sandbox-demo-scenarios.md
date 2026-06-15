---
id: ADR-097
title: Sandbox demo scenarios (SBOX-2) — deterministic, mock-only demo journeys
status: ACCEPTED
date: 2026-06-15
accepted: 2026-06-15
supersedes: []
related:
  - "ADR-096-unified-sandbox-mode-surface.md (the sandbox surface these scenarios sit on)"
  - "ADR-083-composable-defi-stack.md (the advisory seams the journeys compose)"
  - "ADR-093-multi-venue-execution-preview-hardening.md (the unsigned execution preview used)"
  - "ADR-095-g1-g4-go-live-decision-support.md (the go-live gates these demos sit below)"
il_anchor: IL-242
scope: BANXE-only
concept_only: false
---

# ADR-097: Sandbox demo scenarios (SBOX-2)

**Status:** ACCEPTED — 2026-06-15
**IL:** IL-242 (Sprint SBOX-2 — sandbox demo scenarios)
**Extends:** ADR-096 (unified sandbox surface) over the delivered advisory seams. No
live activation.

## Context

SBOX-1 (ADR-096) made the sandbox an explicit internal surface. To demonstrate the
advisory product — to an investor, a partner, or compliance — there was no canonical,
repeatable walkthrough showing how a recommendation flows through the previews and
the marketplace. SBOX-2 adds that: a small set of **deterministic demo journeys** the
sandbox can replay, built entirely from the already-delivered mock/advisory seams.

## Decision

### D1 — A registry of deterministic demo scenarios

Add a static registry of `SandboxScenario`s, each a list of `SandboxStep`s
(`dse-recommendation`, `mm-preview`, `fee-preview`, `quant-preview`,
`execution-preview`, `marketplace-card`, `explanation`). At least three ship:
`spot-swap-demo`, `perp-hedge-demo`, `yield-rebalance-demo`. Each step carries a mock
request/response snippet; the same scenario id always yields the same walkthrough.

### D2 — Two internal read-only endpoints

`GET /api/v1/sandbox/scenarios` (summaries) and
`GET /api/v1/sandbox/scenarios/{id}` (full walkthrough; unknown id → 404). Internal
terminal endpoints, mounted under the `/api/v1` prefix.

### D3 — Mock-only, unsigned, no live capability

Every payload is **mock data** — no real quotes/prices, no network, no keys. The
scenarios only illustrate the existing mock/advisory endpoints; every
`execution-preview` step is `signed: false` / `submitted: false`. They are
demonstrations of the DSE / preview / marketplace surface, **not live trading**, and
add no execution capability.

### D4 — Internal only; no external surface, no contract change

Not added to the external `/v1` BaaS facade (404 there); no existing contract changes.

## Consequences

- **Positive:** a demonstrable sandbox loop — a repeatable, safe walkthrough to show
  the advisory product without live risk.
- **Neutral:** purely descriptive demo data composed from existing seams; no new
  capability, provider, or network dependency.
- **No change** to code behaviour elsewhere, to any `/v1` facade, or to any contract.

## OPERATOR DECISION REQUIRED (unchanged)

Nothing here activates live providers, execution, billing, or KYB. Live go-live
remains an ADR-095 ratification cell + a dedicated ACCEPTED ADR.

## References

- banxe-trading-backend: `services/sandbox_scenarios.py`, `api/sandbox_scenarios.py`
- ADR-096 (sandbox surface); ADR-083, ADR-089…093 (composed seams); ADR-095 (gates)
- `docs/runbooks/g1-g4-mica-aml-runbook.md` (sandbox as the safe training environment)
