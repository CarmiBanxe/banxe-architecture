# RISK REGISTER — EMI BANXE AI BANK

## Status
Initial draft 2026-05-22. Reference for ROADMAP_8Q gating. Subject to MLRO and Internal Audit review before EMI go-live.

## Scope
All risks tied to (a) migration from legacy banxe.rar to NEW Hexagonal stack, (b) EMI license obligations under FCA (UK reference) and ACPR (FR primary), (c) GDPR/CNIL data protection, (d) FCA CASS 15 client-money safeguarding.

## Risk format
RID — Category — Description — Likelihood (L/M/H) — Impact (L/M/H) — Owner — Mitigation — Status

---

## R-REG-01 — FCA CASS 15 reconciliation failure
- Category: Regulatory (CASS 15 client money safeguarding)
- Description: banxe-recon service in failed state (AUDIT_COMPLIANCE 2026-05-20); without daily 5y-retention reconciliation, the firm is in breach of CASS 15.3.
- Likelihood: H · Impact: H · Owner: MLRO + Treasury
- Mitigation: Reconnect banxe-recon to midaz-ledger (UP per PR #303); enable ruflo_checkpoints (ADR-027) TTL 5y; daily Verify Drill.
- Status: OPEN. Blocked on banxe-recon revival and ledger queues.

## R-REG-02 — KYC/AML gap during legacy-to-new switchover
- Category: Regulatory (4AMLD/5AMLD + Travel Rule)
- Description: SumSub runs against legacy KYC store; NEW user store not wired; risk of KYC bypass during switchover.
- Likelihood: M · Impact: H · Owner: Compliance Officer
- Mitigation: Strangler Fig dual-write to legacy + NEW user store; freeze new account creation during cut-over window.
- Status: OPEN. Gated on user-store migration plan.

## R-REG-03 — Travel Rule v2 non-compliance on crypto outflows
- Category: Regulatory (FATF Travel Rule, EU TFR)
- Description: NEW crypto-ops-monitor not yet emitting IVMS101; outflows over EUR 1k require originator/beneficiary data exchange.
- Likelihood: M · Impact: H · Owner: Compliance + Crypto-ops
- Mitigation: Wire Sumsub Travel Rule v2 into crypto-ops-monitor; quarantine outflows over EUR 1k pending implementation.
- Status: OPEN.

## R-REG-04 — ACPR EMI license capital adequacy reporting
- Category: Regulatory (ACPR FR, primary EMI authority)
- Description: ACPR monthly reporting requires single source of truth for client-money totals; split between legacy Temenos and NEW midaz-ledger.
- Likelihood: M · Impact: H · Owner: CFO
- Mitigation: Dual-source recon until midaz-ledger has 100 percent coverage; flag discrepancies in MIGRATION_DASHBOARD.
- Status: OPEN.

---

## R-PRIV-01 — CNIL GDPR data localisation
- Category: Privacy (GDPR Art. 28, CNIL cross-border transfer guidance)
- Description: Legacy stack hosts EU user PII on undocumented infrastructure; Article 28 sub-processor list incomplete.
- Likelihood: H · Impact: M · Owner: DPO
- Mitigation: PII routing per ADR-021 (PII routing canon); confine EU PII to EU storage; publish Art. 28 register.
- Status: OPEN. ADR-021 in place; implementation pending.

## R-PRIV-02 — Subject Access Requests across legacy + new
- Category: Privacy (GDPR Art. 15-17)
- Description: A SAR requires manual cross-stack data assembly; 30-day statutory deadline at risk.
- Likelihood: M · Impact: M · Owner: DPO
- Mitigation: Unified user-data export endpoint behind Hexagonal port; automated SAR workflow in R7 GUIYON backlog.
- Status: OPEN.

## R-PRIV-03 — Historical-leak remediation incomplete
- Category: Security/Privacy (S15.5 historical-leak runbook)
- Description: 12 secrets identified in legacy git history (first-session audit); S17 90-day rotation not applied to all credentials.
- Likelihood: M · Impact: H · Owner: SecOps
- Mitigation: git-filter-repo rewrite of legacy repos before any push to factory-*; rotate 12 identified credentials; record each rotation in IL.
- Status: PARTIAL. S17 defined; 12-secret rotation outstanding.

---

## R-OPS-01 — bus factor = 1
- Category: Operational
- Description: Single operator holds full system context; loss of access blocks all operations.
- Likelihood: L · Impact: H · Owner: Operator
- Mitigation: Universal Canon + IL + ADR trail (docs/canon/UNIVERSAL-CANON-2026-05-22.md in main); next-session seed via CANON-TRANSFER-PACKAGE.
- Status: PARTIAL. Documentation trail durable; staffing not addressed.

## R-OPS-02 — Prometheus dead 2+ weeks
- Category: Observability (R3 track)
- Description: Production metrics blind since early May; no alerting on midaz-ledger or banxe-recon failures.
- Likelihood: H · Impact: M · Owner: SRE
- Mitigation: R3 Observability foundation; Prometheus exporter for guardian_github_post_events post webhook live (R3 runbook Section 4).
- Status: OPEN.

## R-OPS-03 — No backup strategy
- Category: Operational continuity
- Description: midaz-postgres, midaz-mongodb, ClickHouse have no documented backup cadence or restore drill.
- Likelihood: M · Impact: H · Owner: SRE
- Mitigation: Per-DB backup spec; weekly restore drill; retention aligned with CASS 15 (5y) and GDPR (purge after legitimate retention).
- Status: OPEN.

## R-OPS-04 — midaz-ledger queues not declared
- Category: Operational (consumer 404 NOT_FOUND backoff)
- Description: midaz-ledger consumer retries on missing queues (BALANCE_CREATE_QUEUE, TRANSACTION_BALANCE_OPERATION_QUEUEE, AUDIT_EXCHANGE).
- Likelihood: H · Impact: L · Owner: Central
- Mitigation: Declare queues in midaz-rabbitmq; R1 next-tracked.
- Status: OPEN (non-blocking).

---

## R-MIG-01 — Vendor-to-OpenSource cut-over risk
- Category: Migration (ADR-017)
- Description: Tribe to Hyperswitch, Temenos to Midaz, WordPress to Strapi, Apollo to Hasura cut-overs each carry hidden coupling risk.
- Likelihood: M · Impact: H · Owner: Migration lead
- Mitigation: Strangler Fig + Shadow Mode + Canary Rollout per TRADING_REFACTOR_TASKS phases D/E; quarantine list for evaluate.sh under R5.
- Status: OPEN. Per-vendor sub-tracks to be detailed.

## R-MIG-02 — Legacy source unavailable on current infra
- Category: Migration (factual gap discovered 2026-05-22)
- Description: 270 banxe.rar legacy projects are NOT on Legion, evo1, or evo2 in usable form; only audit artefacts present.
- Likelihood: H · Impact: H · Owner: Operator
- Mitigation: Locate or restore banxe.rar source archive before Phase B extraction (TRADING_REFACTOR_TASKS) can begin.
- Status: OPEN. Critical blocker for right-track refactor work.

---

## R-SEC-01 — Guardian webhook unauthenticated to GitHub
- Category: Security (CI/CD)
- Description: Guardian factory + project have no path to post to GitHub Checks/Statuses; every PR rides admin-bypass (chain extended to nine times in 2026-05-22 session).
- Likelihood: H · Impact: M · Owner: Central + Operator
- Mitigation: ADR-077 GitHub App auth (in main as c10ee84); operator runbook ~/banxe-operator-runbooks/R3-GITHUB-APP-SETUP-2026-05-22.md pending action; webhook implementation queued post-creds.
- Status: OPEN. Blocking R3/S14.3 deployment.

## R-SEC-02 — Claude Code bypass-permissions on Legion
- Category: Security (UNIVERSAL-CANON section 15)
- Description: Bypass-permissions mode forbidden on Legion and production; accidental enable would let Claude Code execute unaudited shell commands.
- Likelihood: L · Impact: H · Owner: Operator
- Mitigation: ~/.claude/settings.json mode 600; explicit canon prohibition in UNIVERSAL-CANON section 15; review on every Claude Code restart.
- Status: CONTROLLED. Policy in place; mechanical check pending under R5 repo governance.

---

## Next steps
- MLRO review of R-REG-01 through R-REG-04 before EMI go-live.
- DPO review of R-PRIV-01 through R-PRIV-03; Art. 28 register publication target Q3.
- SRE prioritises R-OPS-02 (Prometheus revival) and R-OPS-03 (backup spec) within next sprint.
- Operator action on R-SEC-01 (GitHub App creation per runbook) unblocks R3/S14.3 chain.
- R-MIG-02 (legacy source absence) escalated as critical right-track blocker.

## Refs
- UNIVERSAL-CANON-2026-05-22.md sections 7, 12, 13, 15
- REFACTOR_MASTER_PLAN.md (270-project classification)
- TRADING_PHASE_A_INVENTORY.md, TRADING_REFACTOR_TASKS.md
- ADR-016 through ADR-021, ADR-027 (CASS 15 retention), ADR-077 (Guardian App auth)
- IL anchors: R1-MIDAZ-LEDGER-BLOCKER-RESOLVED, CANON-BYPASS-EXCEPTION-EXTEND-TO-NINE (2026-05-22)
- AUDIT_COMPLIANCE, AUDIT_BACKUP, AUDIT_OBSERVABILITY, AUDIT_SECURITY (2026-05-20/21)

=== END OF RISK_REGISTER (draft 2026-05-22) ===
