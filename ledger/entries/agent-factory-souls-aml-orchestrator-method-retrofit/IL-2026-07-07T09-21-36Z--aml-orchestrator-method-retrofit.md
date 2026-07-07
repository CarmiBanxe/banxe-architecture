---
il_ts: 2026-07-07T09:21:36Z
session_id: agent-factory-souls-aml-orchestrator-method-retrofit
source: CEO
status: PROPOSED
---
### Teachers-retrofit (final) — add ## Decision Method to banxe-aml-orchestrator.md, grounded on resolved identity

- **Objective:** Retrofit the mandatory `## Decision Method` into `agents/souls/banxe-aml-orchestrator.md` (the
  `banxe_aml_orchestrator` L1-top AML orchestrator), grounded on the NOW-RESOLVED canonical identity from #1092
  (RED · L1-top · autonomy L3; SMF17; human doubles Head of Financial Crime + MLRO). **Additive section ONLY**; no
  authority/status change (stays PROPOSED); no passport/_TEMPLATE/ADR-131/config/schema.
- **Grounding (from canonical passport, not restated):** L1-top orchestrator that dispatches to L2 sub-agents
  (aml_orchestrator/sanctions_check/tx_monitor/crypto_aml), aggregates scores, builds ExplanationBundle, initiates TM/
  case/sanctions workflows; HITL gates SAR/threshold/sanctions; forbidden submit_SAR/PEP; MLRO SMF17 non-delegable.
- **Decision Method (per this agent):** enumerate L1-orchestration actions (initiate-only) → score by aggregate AML
  risk / evidence sufficiency / regulatory deadline (MAUT) → satisfice within its HITL gate → escalate to Head of
  FinCrime + MLRO. **AML fail-closed (RED, absolute):** final SAR/PEP/sanctions-reversal/SUBMIT is NEVER the agent's
  (human-gated I-27, SMF17, BUG-007); never auto-clears a hit, never self-escalates a level, fail-closed on ambiguity.
  Pointer-first to concept / consultant-escalation-protocol / BEST-DECISION-BOUNDARY / ADR-162 — not restated.
- **Placement:** inserted immediately after `## HITL Gate` (the SOUL's last section). Additions-only, 0 deletions.
- **Milestone:** closes the teacher program — every teacher/decision agent method-equipped
  (internal_audit, spec_first_auditor, gap_tracker, cfo/coo/ceo orchestration, case_management, banxe_aml_orchestrator).
  `aml_orchestrator` (L2 sub) has no SOUL — optional separate authoring, not required for the teacher set.
- **Perimeter:** banxe-architecture; worktree off origin/main (ADR-120); no TRADING-001 / agent/specproj/* (Rule 6);
  signed; --force-with-lease. NOT activated (RED/L1/L3 activation = I-27 operator+MLRO, never factory). IL frozen-at-merge (Rule 8).
- **Refs:** ADR-131 (+#1077); FACTORY-CANON §1.11; I-27; SMF17; BUG-007; ADR-102; #1092 (identity dedup);
  agents/passports/aml/banxe_aml_orchestrator.yaml; docs/sources/best-decision-concept-2026-07-06-v2.md;
  docs/sources/consultant-escalation-protocol-2026-07-07.md; docs/canon/BEST-DECISION-BOUNDARY.md; docs/adr/ADR-162-best-decision-principle.md; [[aml-orchestrator-3passport-identity-conflict]].
