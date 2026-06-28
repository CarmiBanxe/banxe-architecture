---
il_ts: 2026-06-28T17:00:00Z
session_id: agent-factory-legacy-sepa-reclassification
source: CEO
status: DONE
---
### Docs correction — legacy_sepa: SEPA family unwired, live rail = ModulrPaymentAdapter; PARKED (docs-plane)

- **Objective:** Reclassify legacy_sepa across ARCH dossiers to match verified EMI code (4th/final stream; mirrors recon #840/IL-630, fin060 #841/IL-636, legacy_otp #853/IL-662). Additive (originals struck/superseded). NO code; no consolidation.
- **Evidence (ADR-102 audit, EMI origin/main 4f93870):** The live SEPA rail is ModulrPaymentAdapter (services/payment/modulr_client.py) — PaymentRailPort FPS/Bacs/SEPA_CT/SEPA_INSTANT (IL-014), selected via PAYMENT_ADAPTER env (mock default / modulr gated MODULR_API_KEY), wired api/routers/payments.py /v1/payments → PaymentService.send_sepa_ct/send_sepa_instant. None of the three *_sepa_*-named adapters is runtime-wired (0 instantiations): LegacySepaAdapter (legacy_sepa_adapter.py, REWRITE-3, transport-dropped ADR-025) = PARKED reference; ModulrSepaAdapter (modulr_sepa_adapter.py, Modulr REST, sandbox-default) = PARKED scaffold + ADR-102 OVERLAP with the wired ModulrPaymentAdapter SEPA capability; ModulrSepaStub (modulr_sepa_stub.py, NotImplementedError) = PARKED Wave-C seam. Handoff/dossier "legacy_sepa → modulr_sepa_stub (LIVE_MIGRATE_NEXT/repoint/Modulr live-wiring)" is a MISCLASSIFICATION → corrected: legacy_sepa_adapter = PARKED reference; future SEPA-specific path = ModulrSepaAdapter gated (Wave C + MODULR_API_KEY + overlap reconcile).
- **Edits:** correction note + 4 supersede marks (rows 118/133/137/155) in docs/refactor-legacy/EMI-LEGACY-RATIONALIZATION-PASS-1-2026-06-27.md; one-line pointer in docs/sessions/SESSION-HANDOFF-STATE-AND-TASKS-2026-06-27.md. Cross-ref PLAN-ROADMAP-SPRINTS:98 + EMI-IMPL-STATE-REFRESH:45,174 (already correct), not duplicated. Closes all 4 pass-1 LIVE_MIGRATE_NEXT streams → all PARKED.
- **Provenance:** banxe-architecture origin/main @ 6549092 IL max=662; provisional IL = max+1 frozen-at-merge (Rule 8; MAIN regenerates).
- **Perimeter / canon:** docs+ledger only; NO EMI/runtime/.semgrep code; no adapter aliased/retired/wired/deduped; bitrix/neuronext guards untouched; append-only build_ledger; sub-B/factory → MAIN per §71/§74 (NO merge — operator decides). RAR/secrets untouched.
- **Refs:** EMI 4f93870; ADR-102; ADR-119/I-28; recon #840/IL-630; fin060 #841/IL-636; legacy_otp #853/IL-662; PLAN-ROADMAP-SPRINTS:98; EMI-IMPL-STATE-REFRESH:45,174.
