# CHECKPOINT — EMI BANXE AI BANK — 2026-05-06 09:00 CEST

> Tag: `checkpoint-2026-05-06-adr027-accepted`
> Previous checkpoint: `checkpoint-2026-05-05-emi-canon`

## Session summary (2026-05-05 16:00 → 2026-05-06 09:00, ~17h)

### Completed
- V-01..V-13 canon formalisation (13/13 → G-* gaps in GAP-REGISTER)
- Track A first stage: 8 ADRs Proposed (ADR-027..030, 032..035, 038)
- Track A second stage: **ADR-027 Accepted** (BufferedAuditPort + AUDIT_FAIL_CLOSED + drain cron, 15 tests, G-CASS-01 DONE)
- Track B Phase F: KC dev-file → Postgres backend LIVE (downtime 2m44s)
- Track B Phase G: KC session-timeout hardening LIVE (PSD2-grade)
- Track I: G-INFRA-01 evo2 stub, ROADMAP refresh Phase 4.5/4.6/4.7, MASTER-PLAN, realm JSON export
- Guardian-shim: V-01 enforce, ADR-024/026, CB1..CB4, G-GUARD-01/02
- Canon expansion: §3/§4/§15 CCF, IL-CANON-04/05, 4-layer canon, IL-CANON-04 best-decision
- Settings.json zero-popup permissions (PR #63)
- KC_BOOT_ADMIN_PASSWORD rotated (compromised in paste.txt, rotated via kcadm set-password)
- IL-052 phase4 recovery post-mortem

### Next session: Track A second stage ADR-028..034 implementation

| ADR | Тема | Gap | Implementation status |
|-----|------|-----|-----------------------|
| ADR-027 | Audit-trail durability | G-CASS-01 | ✅ Accepted (15 tests) |
| **ADR-028** | **KYC re-verification triggers** | **G-KYC-01/02** | **⏳ next** |
| ADR-029 | Postgres backup strategy | G-OPS-01/02 | ⏳ |
| ADR-030 | Auth rate-limit policy | G-API-01/02 | ⏳ |
| ADR-032 | Secret rotation policy | G-SEC-01 | ⏳ |
| ADR-033 | Alert routing strategy | G-OBS-01/02 | ⏳ |
| ADR-034 | Webhook reliability KYC | G-KYC-03/04 | ⏳ |
| ADR-035 | CI smoke-gate policy | G-CI-01/02 | ⏳ |

### Implementation pattern (proven on ADR-027)
- Step 1: create Port/component + unit tests (PR)
- Step 2: wire into production DI + integration tests (PR)
- Step 3: operational script (cron/CI) + smoke tests (PR)
- Step 4: flip ADR Proposed→Accepted + close gap in GAP-REGISTER (PR in banxe-architecture)

### Production state
- KC realm `banxe-emi`: Legion 100.101.218.26:8180 via Tailscale, Postgres backend, Phase G hardened
- Guardian: evo1 :8195/:8196, ENFORCE mode, cron pull-deploy
- BufferedAuditPort: deployed in main, drain cron `*/5 * * * *` ready

### Open PRs (not merged)
- banxe-emi-stack #36 — factory P1 onboarding (NEEDS_REVISION)
- banxe-architecture #21 — factory P1 onboarding (NEEDS_REVISION)

### Canon rules for next session
1. One step = one artifact. §15 Claude-Code-First. §4 Best-Decision.
2. settings.json zero-popup active (skipDangerousModePermissionPrompt=true).
3. Guardian-shim enforce. Secrets masked. No deadlines.
4. PRs merge via --admin.
