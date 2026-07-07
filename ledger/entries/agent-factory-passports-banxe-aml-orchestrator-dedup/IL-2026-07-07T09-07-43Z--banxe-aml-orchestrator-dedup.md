---
il_ts: 2026-07-07T09:07:43Z
session_id: agent-factory-passports-banxe-aml-orchestrator-dedup
source: CEO
status: PROPOSED
---
### ADR-102 passport dedup — banxe_aml_orchestrator (corrected operator ruling: TWO agents; dedupe only its 2 passports)

- **Corrected ruling:** initial "one agent RED·L2" was contradicted by full grounding — there are **TWO agents**
  (`aml_orchestrator` L2 sub-orchestrator, called by `banxe_aml_orchestrator` L1 top). Operator re-ruled: TWO agents
  confirmed; dedupe **only** `banxe_aml_orchestrator`'s two passports.
- **Canonical:** `agents/passports/aml/banxe_aml_orchestrator.yaml` set to **RED · L1-top · autonomy L3**; merged in the
  operational layer (ports/skills/callees/capabilities/invariants/fca_references/aigf_risks) from the root passport; kept
  the governance layer (SMF17, HEAD_OF_FINCRIME+MLRO, HITL gates, forbidden SAR/PEP, audit). Conflicts safer-wins
  (RED>AMBER, MAJOR>CLASS_B, level 1). No capability lost.
- **Superseded (NOT hard-deleted):** root `agents/passports/banxe_aml_orchestrator.yaml` → `status: SUPERSEDED` +
  `superseded_by` header, append-only (I-24). Hard-removal = separate operator decision.
- **Untouched:** `agents/passports/aml_orchestrator.yaml` (the separate L2 sub-agent). Pipeline edge (top→sub) preserved.
- **Prepare-only:** identity resolved; NOT activated (I-27 operator+MLRO). No SOUL edit; no config/schema; no hard-delete.
- **Deliverable:** canonical passport (merged) + root superseded-header + ADR-102 note + this shard. ONE Draft PR.
- **Follow-up (separate):** retrofit `agents/souls/banxe-aml-orchestrator.md`'s `## Decision Method` now that the
  banxe_aml_orchestrator identity is fixed (RED/L1/L3). `aml_orchestrator` L2-sub has no SOUL (separate authoring if wanted).
- **Refs:** ADR-102; operator ruling 2026-07-07; I-24; I-27; SMF17; COMPLIANCE-ARCH/MATRIX; [[aml-orchestrator-3passport-identity-conflict]].
