---
il_ts: 2026-06-28T13:00:00Z
session_id: agent-factory-fin060-mergepair-direction-correction
source: CEO
status: DONE
---
### Docs correction — fin060 merge-pair direction (3 contours, PARKED) + ADR-102 collisions (docs-plane)

- **Objective:** Correct fin060 merge-pair direction across ARCH dossiers to match verified EMI code (mirrors recon PR #840/IL-630). Additive (originals struck/superseded). NO code; no consolidation.
- **Evidence (ADR-102 audit, EMI origin/main 4f93870):** FIN060 = THREE complementary contours, not a v2→v1 pair — (1) fin060_generator.py = SUBMISSION engine (PDF WeasyPrint + RegData, generate_fin060→Path, FIN060Data) wrapped by regdata_return.py::RealFIN060Generator → api/deps → /v1/reporting/fin060/* + regdata_gabriel; REQUIRED. (2) fin060_generator_v2.py = GOVERNANCE-API canonical (HITL/CFO, I-27/BT-006 never auto-submit, HITLProposal) → reporting_agent → api/routers/fin060_reporting.py /v1/fin060/* + matrix_scanner. (3) src/safeguarding/fin060_generator.py = SEPARATE safeguarding return-data (FIN060Return, build, CASS 15.12.4R) → api/routers/safeguarding.py /v1/safeguarding. Handoff/dossier "v2→v1 delete/unify" is BACKWARDS → PARKED; deleting v2 regresses I-27/BT-006. ADR-102 collisions: class FIN060Generator ×3 (V2 concrete + regdata_return Protocol port + src-safeguarding concrete); generate_fin060 ×2 (function→Path vs method→HITLProposal).
- **Edits:** correction note + 2 supersede marks + step-106 fix in docs/refactor-legacy/EMI-LEGACY-RATIONALIZATION-PASS-1-2026-06-27.md; one-line pointer in docs/sessions/SESSION-HANDOFF-STATE-AND-TASKS-2026-06-27.md. Cross-ref PLAN-ROADMAP-SPRINTS:78 (already PARKED), not duplicated.
- **Provenance:** banxe-architecture origin/main @ 5fd5cee IL max=630; provisional IL = max+1 frozen-at-merge (Rule 8; MAIN regenerates).
- **Perimeter / canon:** docs+ledger only; NO EMI/runtime/.semgrep code; no fin060 contour aliased/retired/consolidated; bitrix/neuronext guards untouched; append-only build_ledger; sub-B/factory → MAIN per §71/§74 (NO merge — operator decides). RAR/secrets untouched.
- **Refs:** EMI 4f93870; ADR-102; ADR-119/I-28; recon correction PR #840/IL-630; PLAN-ROADMAP-SPRINTS-NEURONEXT-TO-PAYBIS.md:78; pass-1 dossier §1/§3/§7.
