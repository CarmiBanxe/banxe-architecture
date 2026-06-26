---
il_ts: 2026-06-27T01:00:00Z
session_id: agent-factory-sub-b-paybis-i27-kyc-park
source: CEO
status: DONE
---
### E10 Wave-2 — I-27 KYC legacy PARKED-by-canon (operator decision); deletion scope narrowed (docs-plane)

- **Objective:** Apply operator decision — legacy_bkyc_adapter + legacy_binancekyc_adapter stay PARKED (NOT deleted) because they sit in the I-27 KYC/KYB/AML licensed perimeter; add a CANON RULE that I-27 legacy is never consolidation-deletable; narrow deletion scope to auth-orphans. Docs-plane; NO deletion.
- **Operator decision (this turn, explicit):** legacy_bkyc PARKED despite 0 production refs — implements KYCWorkflowPort (KYB onboarding) in I-27 perimeter; deletion destructive + licensed-compliance; value of removing one file < barrier. legacy_binancekyc reclassified PARKED by same rule (cohesive KYC layer; do not partially delete one of three KYC adapters).
- **Verification (grounding, read-only shell, emi origin/main):** tests/test_legacy_bkyc_adapter.py + tests/test_legacy_binancekyc_adapter.py BOTH exist (verified); both implement KYCWorkflowPort/KYB; kyb_onboarding service exists (application_manager, companies_house_adapter) → "future KYB activation" grounded. NB: this also CORRECTS sub-B's prior IL-558 "legacy_bkyc = confirmed clean orphan" — it has a dedicated test, so never a clean orphan (verify-before-delete validated again).
- **CANON RULE recorded (§1A, referenced §5A):** "KYC/KYB/AML legacy modules (I-27 perimeter) are NEVER candidates for consolidation-deletion — only PARKED. Removal of any I-27 component requires explicit operator + MLRO/HITL-L4 authorization, never best-decision auto."
- **Net effect on deletion scope:** both compliance/legacy KYC adapters REMOVED from deletion scope (PARKED-by-canon). Remaining deletion-eligible (non-I-27, auth perimeter): role_guard (DELETE-WITH-TEST, 0 prod refs) + sca/totp pair (DELETE-AS-PAIR after DI-trace). These are the ONLY remaining real deletion candidates; everything else PARKED. Destructive step still requires operator go.
- **§5A point 4:** I-27 KYC legacy = permanently PARKED-by-canon (not "pending"); deletion scope = auth orphans only.
- **Perimeter / canon:** docs-plane only; NO deletion; FROZEN ports untouched; traceable to operator decision + prior shell-evidence (IL-558) + this verification; isolated worktree off arch origin/main; signed; sub-B hands to MAIN per §71/§74.
- **Deliverable:** PLAN §1A E10 Wave-2 table (2 KYC rows → PARKED) + CANON RULE + итог + Deletion-execution rule + §5A point 4 update, this IL shard.
- **Refs:** IL-558 (Wave-2 audit, corrected re bkyc test); operator decision this turn; I-27 (KYC/KYB/AML HITL); tests/test_legacy_bkyc_adapter.py, tests/test_legacy_binancekyc_adapter.py, services/kyb_onboarding/; ADR-102; ADR-119/I-28.
