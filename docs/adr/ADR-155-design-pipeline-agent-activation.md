---
id: ADR-155
title: Activation of design_pipeline_agent (I-27 gate, full agent go-live)
status: ACCEPTED
date: 2026-07-01
concept_only: false
relates:
  - "ADR-135 (held-out adoption / HITL gate — governs future material change)"
  - "ADR-117 (factory↔project perimeter); the runtime lives in banxe-emi-stack"
  - "design_pipeline_agent passport; UI-UX-DESIGN-SYSTEM-CANON §5A/§7.2/§8 OI-5 (taste advisory, owner, θ)"
  - "ADR-153 (terminal topology); ADR-154 (shared-space arbitration); docs/governance/TERMINAL-OWNERSHIP.md"
il_anchor: IL-759
il_anchor_note: "Provisional per ADR-119 Rule 8 — minted by the central allocator (ADR-143/143-A) over current origin/main; frozen at rebase-before-merge."
scope: BANXE-factory-governance
---

# ADR-155 — Activation of `design_pipeline_agent` (I-27 gate, full agent go-live)

## Status
ACCEPTED — 2026-07-01. Operator scope decision: **full activation**. Prepare-only Draft; the activation merges
only via operator HITL. Line 7 of 7 (final) of the governance sequence.

## Context
`design_pipeline_agent` is the governance passport for the EXISTING `banxe-emi-stack` runtime service
`services/design_pipeline/` (created by SP-PASSPORT-COV to close the orphan-service gap). It has stood at
`status: PROPOSED` / `version: 0.1.0`, not activated, gated by **I-27** on explicit operator approval. The two
preconditions for activation are now on `main`: design-system **ownership** is recorded as interim CTO
(UI-UX-DESIGN-SYSTEM-CANON §7.2) and **θ** is set to `on-canon` (§8 OI-5). The operator has taken the **full
activation** scope decision (full agent go-live, not taste-only), which is the I-27 gate this ADR records.

## Decision
**Activate `design_pipeline_agent` — lift I-27 and bring all five capabilities operational.** The passport moves
to `status: ACTIVE`, `version: 1.0.0`. All five capabilities — `design_to_code`, `component_catalog`,
`design_token_management`, `visual_regression_config`, and `aesthetic_taste_review` — become operational,
**including `design_to_code` / `CodeGeneratorPort` against the existing `services/design_pipeline/` runtime in
`banxe-emi-stack`**. This is a **CLASS_B** go-live; **approvers: CTO + CEO**.

### Explicitly preserved (unchanged by activation)
- **Capability set unchanged** — no capability added or removed; activation flips state, not scope.
- **Taste stays advisory** — `aesthetic_taste_review` is never a promotion / merge / governance gate (canon
  §5A); **θ = on-canon** feeds only the impeccable-loop stop-condition; owner = interim CTO (§7.2).
- **WCAG 2.1 AA (canon §5) remains the hard gate** — taste cannot waive it.
- **I-27 HITL is retained at decision-time** — the agent runs at `autonomy: L2_REVIEW`, so every L2 decision
  carries the BUG-007 confidence thresholds (AUTO >90 / REVIEW 70–90 / BLOCK <70). Activation lifts the
  *passport-activation* gate, not the *runtime* HITL.
- **Future material change is ADR-135-gated** — any change to capabilities, θ, or taste-semantics requires a
  fresh operator HITL via the held-out adoption gate.

## Consequences
- **(+)** The orphan-service governance gap is closed by an *active* owning passport, not a proposed stub.
- **(+)** Completes the taste-skills activation set: ownership (interim CTO) + θ (on-canon) + **activation**.
- **(−/risk)** **Code-generation go-live.** Activation makes `design_to_code` / `CodeGeneratorPort` operational
  against the existing runtime — the material CLASS_B exposure (not the advisory taste capability). Mitigated by:
  L2_REVIEW autonomy with I-27 runtime HITL (BUG-007), AMBER trust zone, CLASS_B change-class, and ADR-135 for
  future material change. The runtime code itself is unchanged and lives in `banxe-emi-stack` (ADR-117 perimeter).
- **(note)** The **impeccable polish-loop runtime is NOT built** (project-side `banxe-ui`, future) — activation
  makes the *agent* operational, not the taste-*scoring loop*; no "taste loop is live" should be inferred.

## Acceptance criteria
Passport: `status: ACTIVE` · `version: 1.0.0` · no "NOT activated" / "Do NOT auto-activate" language · `I-27`
retained in `invariants` · `autonomy: L2_REVIEW` unchanged · `change_class: CLASS_B` · `approvers: [CTO, CEO]` ·
`last_reviewed: 2026-07-01` · capabilities set unchanged (5) · θ=on-canon intact · `yaml.safe_load` valid +
`guardian-schemas` green. `uiux-pipeline.sh` 🟢 (taste advisory unaffected; WCAG §5 still hard gate).

## Anchors
ADR-135 (HITL) · ADR-117 (perimeter) · UI-UX-DESIGN-SYSTEM-CANON §5A/§7.2/§8 OI-5 · ADR-153/154 ·
`TERMINAL-OWNERSHIP.md` · `agents/passports/design_pipeline_agent.yaml` · BUG-007 (HITL thresholds). Operator
directive 2026-07-01 (line 7 of 7 — full activation).
