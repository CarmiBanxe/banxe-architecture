---
il_ts: 2026-06-28T15:00:00Z
session_id: agent-factory-legacy-otp-reclassification
source: CEO
status: DONE
---
### Docs reclassification — legacy_otp = LIVE_KEEP base class; Twilio/SendGrid PARKED scaffold (docs-plane)

- **Objective:** Reclassify legacy_otp across ARCH dossiers to match verified EMI code (mirrors recon PR #840/IL-630, fin060 PR #841/IL-636). Additive (originals struck/superseded). NO code; no consolidation.
- **Evidence (ADR-102 audit, EMI origin/main 4f93870):** LegacyOtpAdapter (services/auth/legacy/legacy_otp_adapter.py) is a SHARED BASE CLASS (in-memory generate/send/verify/can_resend, implements OtpDeliveryPort), inherited by TwilioOtpAdapter/SendGridOtpAdapter/TwilioOtpStub/SendGridOtpStub (class X(LegacyOtpAdapter)). Deleting it breaks all production adapters + stubs → NOT a migrate/retire target; the "4 consumers" are its subclasses. Twilio/SendGrid production adapters = PARKED scaffold, NOT wired (0 DI/route), gated on provider creds (BT-*) + OTP-delivery route + live delivery (out of sandbox). OtpDeliveryPort (SMS/email) is a SEPARATE 2FA channel from the wired TOTPService/TwoFactorPort runtime SCA path (two_factor.py → sca_service → auth-router). Handoff/dossier "legacy_otp → production (LIVE_MIGRATE_NEXT/repoint/provider parity)" is a MISCLASSIFICATION → corrected: legacy_otp_adapter = LIVE_KEEP base class; Twilio/SendGrid = PARKED.
- **Edits:** correction note + 4 supersede marks (rows :80/:110/:115/:133) in docs/refactor-legacy/EMI-LEGACY-RATIONALIZATION-PASS-1-2026-06-27.md; one-line pointer in docs/sessions/SESSION-HANDOFF-STATE-AND-TASKS-2026-06-27.md. Cross-ref PLAN-ROADMAP-SPRINTS:98 + EMI-IMPL-STATE-REFRESH:43,174 (already correct), not duplicated.
- **Provenance:** banxe-architecture origin/main @ ad99f63 IL max=650; provisional IL = max+1 frozen-at-merge (Rule 8; MAIN regenerates).
- **Perimeter / canon:** docs+ledger only; NO EMI/runtime/.semgrep code; no adapter aliased/retired/wired; bitrix/neuronext guards untouched; append-only build_ledger; sub-B/factory → MAIN per §71/§74 (NO merge — operator decides). RAR/secrets untouched.
- **Refs:** EMI 4f93870; ADR-102; ADR-119/I-28; recon PR #840/IL-630; fin060 PR #841/IL-636; PLAN-ROADMAP-SPRINTS:98; EMI-IMPL-STATE-REFRESH:43,174.
