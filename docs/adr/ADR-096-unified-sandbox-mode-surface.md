---
id: ADR-096
title: Unified sandbox-mode surface (SBOX-1) — explicit internal sandbox state, mock-safe
status: ACCEPTED
date: 2026-06-15
accepted: 2026-06-15
supersedes: []
related:
  - "ADR-083-composable-defi-stack.md (the advisory seams the sandbox composes)"
  - "ADR-089-market-making-advisory-seam.md (S12 seam surfaced)"
  - "ADR-090-dynamic-fee-engine-advisory-seam.md (S13 seam surfaced)"
  - "ADR-091-quant-moat-advisory-seam.md (S14 seam surfaced)"
  - "ADR-092-ecosystem-marketplace-advisory-seam.md (S15 seam surfaced)"
  - "ADR-093-multi-venue-execution-preview-hardening.md (S16 seam surfaced)"
  - "ADR-095-g1-g4-go-live-decision-support.md (the go-live gates this sandbox sits below)"
il_anchor: IL-241
scope: BANXE-only
concept_only: false
---

# ADR-096: Unified sandbox-mode surface (SBOX-1)

**Status:** ACCEPTED — 2026-06-15
**IL:** IL-241 (Sprint SBOX-1 — unified sandbox-mode status surface)
**Extends:** the delivered advisory seams (ADR-083, ADR-089…093) + the G1L
decision-lineage scaffold (IL-239). No live activation.

## Context

The estate already exposes a set of internal advisory seams — DSE recommend,
market-making / fee / quant / execution-intent previews, the marketplace registry —
plus the G1L decision-lineage logger. They are individually mock-safe, advisory,
unsigned, and fail-closed, but there was no single internal point to confirm "this is
the sandbox, and nothing here is live." A demo shell, a partner, or compliance had to
infer the posture from each endpoint. SBOX-1 makes the sandbox an **explicit internal
product surface**: one descriptive status snapshot over the already-built seams.

## Decision

### D1 — One internal sandbox-status endpoint

Add `GET /api/v1/sandbox/status` (internal terminal endpoint) returning a descriptive
`SandboxProfile`: `mode` (`sandbox-demo`), `advisoryModules` (the composed seams),
`executionMode` (`unsigned-preview-only`), `liveProvidersEnabled`, `billingEnabled`,
`kybEnabled`, `lineageEnabled`, and a `disclaimer`. It is read-only and describes
state only — it changes no behaviour.

### D2 — Flags derived from configuration; cannot report "live" in sandbox

`liveProvidersEnabled` is `true` only if a provider seam is set to a non-mock
provider; since the app fails closed at startup on any non-mock config, it is `false`
in sandbox / CI. `lineageEnabled` follows the G1L flag. `billingEnabled` and
`kybEnabled` are constants `false` — no such capability exists in the estate and none
is activated here (those remain ADR-095 ratify cells).

### D3 — Internal only; no external surface, no contract change

The endpoint is mounted under the `/api/v1` internal prefix and is **not** added to
the external `/v1` BaaS facade (it returns 404 there). No existing request/response
contract changes. The optional per-endpoint `sandboxMode` response marker is
**deliberately not added** — injecting a field into legacy responses risks breaking
existing contracts (and the execution model is `extra="forbid"`); the single status
endpoint already provides the sandbox-state check.

### D4 — Sandbox is the default safe environment below the go-live gates

This surface sits below the ADR-095 G1–G4 gates and the G1R runbook: it is the
default, safe, advisory environment. Moving any provider / billing / KYB / execution
to live remains an operator-ratified ADR-095 cell + a dedicated ACCEPTED ADR — this
ADR adds none of that.

## Consequences

- **Positive:** a single internal handle on the sandbox posture — usable by a demo
  shell, a partner sandbox, or compliance to confirm "no live execution" at a glance.
- **Neutral:** purely descriptive; it composes existing seams and adds no capability.
- **No change** to code behaviour elsewhere, to any `/v1` facade, or to any contract.

## OPERATOR DECISION REQUIRED (unchanged)

Nothing here activates live providers, execution, billing, or KYB. Those stay
operator- and compliance-gated via the ADR-095 ratification cells.

## References

- banxe-trading-backend: `services/sandbox_profile.py`, `api/sandbox.py`
- ADR-083; ADR-089…093 (composed seams); ADR-095 (G1–G4 gates); IL-239 (G1L lineage)
- `docs/runbooks/g1-g4-mica-aml-runbook.md` (the sandbox as default safe environment)
