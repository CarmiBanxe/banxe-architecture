---
il_ts: 2026-06-28T11:00:00Z
session_id: agent-factory-recon-mergepair-direction-correction
source: CEO
status: DONE
---
### Docs correction — recon merge-pair direction v1→v2 (PARKED) + ADR-102 collisions (docs-plane)

- **Objective:** Correct the recon merge-pair direction across ARCH dossiers to match verified EMI code. Additive (originals struck/superseded, not deleted). NO code; no engine consolidation.
- **Evidence (ADR-102 audit, EMI origin/main 4f93870):** services/recon has THREE distinct engines — (1) reconciliation_engine.py CASS 7.15 IL-007 = LEGACY-cron (midaz_reconciliation.py/daily-recon.sh + 2 tests); (2) reconciliation_engine_v2.py CASS 7.15 IL-REC-01/Phase 51B = CANONICAL live REST (recon_agent → api/routers/safeguarding_recon.py /v1/safeguarding-recon/*, camt053_parser CAMT.053, matrix_scanner) carrying ReconStorePort/HITLProposal/StatementEntry/ReconciliationReport; (3) recon_engine.py CASS 7 safeguarding IL-SAF-01 = SEPARATE domain (api/deps.py DI). Handoff/dossier "v2→v1 (delete v2)" is BACKWARDS → corrected to v1→v2 (non-trivial; PARKED). ADR-102 collisions recorded: class ReconciliationEngine ×2 (reconciliation_engine.py vs recon_engine.py) and @dataclass ReconResult ×2.
- **Edits:** correction note + 3 in-table supersede marks in docs/refactor-legacy/EMI-LEGACY-RATIONALIZATION-PASS-1-2026-06-27.md; one-line pointer in docs/sessions/SESSION-HANDOFF-STATE-AND-TASKS-2026-06-27.md. Cross-references PLAN-ROADMAP-SPRINTS (already PARKED) — not duplicated.
- **Provenance:** banxe-architecture origin/main @ 267172e (drifted from 5ad2fe8; targets intact) IL max=627; provisional IL = max+1 frozen-at-merge (Rule 8; MAIN regenerates).
- **Perimeter / canon:** docs+ledger only; NO EMI/runtime/.semgrep code; no recon engine aliased/retired/consolidated; bitrix/neuronext guards untouched; append-only build_ledger; sub-B/factory → MAIN per §71/§74 (NO merge — operator decides). RAR/secrets untouched.
- **Refs:** EMI 4f93870; ADR-102; ADR-119/I-28; PLAN-ROADMAP-SPRINTS-NEURONEXT-TO-PAYBIS.md:76; pass-1 dossier §1/§3/§7.
