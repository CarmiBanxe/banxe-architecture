# BANXE EMI Bank — Project Documentation Backlog (S12 → S25)

<!-- STATUS-TOTALS -->
Last updated: 2026-05-12 (Sprint D3.1, OI-1 reconciliation)
DONE      13
PARTIAL   48
MISSING   24
BLOCKED   8
DEFERRED  8
TOTAL     101
<!-- /STATUS-TOTALS -->


**Status:** Sprint D1 baseline (initial publication)
**Owner:** CEO + CTIO (project documentation)
**Created:** 2026-05-12
**Parent index:** [`PROJECT-DOCUMENTATION-MASTER-INDEX.md`](./PROJECT-DOCUMENTATION-MASTER-INDEX.md)

---

## 0. How to read this backlog

- One section per sprint (S12 → S25).
- Each sprint lists deliverables grouped by domain.
- Every deliverable carries one status tag from the legend below.
- Every deliverable names a target path (existing or proposed) so reviewers can find it.
- Cross-cutting anchors (ADRs, IL entries, FCA references) are cited inline so the
  documentation programme stays auditable end-to-end.

### 0.1 Status legend

| Tag       | Meaning                                                                              |
|-----------|--------------------------------------------------------------------------------------|
| DONE      | Authored, owned, current, reachable from master index.                                |
| PARTIAL   | Authored but incomplete (named gaps below).                                           |
| MISSING   | Required but not yet authored.                                                        |
| BLOCKED   | Authoring blocked on operator / vendor / regulator decision (named blocker).          |
| DEFERRED  | Postponed past go-live with explicit IL anchor (cited).                               |

### 0.2 Domains

`architecture` · `infrastructure` · `IAM/security` · `compliance/regulatory` ·
`operations/runbooks` · `testing/QA` · `data governance` · `go-live readiness`

### 0.3 Canon provenance reminder

The factory ROADMAP.md defines Sprints S1–S12 (Phases F0–F7). S13–S25 are introduced
in this backlog as **project-documentation execution sprints under Phase F7 production
transition**. They are not amendments to factory canon. See master-index §6.

---

## Sprint S12 — Production-transition baseline (canonical Phase F7 entry)

**Objective:** Freeze the architectural baseline going into production transition. Publish
the project-documentation master index + this backlog so all later sprints have a single
authoritative target list. Confirm domain owners.

| Domain                | Deliverable                                                       | Target path                                                              | Status   |
|-----------------------|-------------------------------------------------------------------|--------------------------------------------------------------------------|----------|
| go-live readiness     | Project documentation master index                                | `docs/project/PROJECT-DOCUMENTATION-MASTER-INDEX.md`                     | DONE     |
| go-live readiness     | Sprint backlog S12–S25                                            | `docs/project/PROJECT-DOCUMENTATION-BACKLOG-S12-S25.md`                  | DONE     |
| architecture          | Architecture freeze note (production candidate scope)             | `docs/project/architecture/architecture-freeze-S12.md`                   | PARTIAL  | (D3.1 reconciled @ docs/project/architecture/)
| architecture          | Master architecture (existing)                                    | `docs/master-document/01-master-full.md`                                 | PARTIAL  |
| architecture          | ADR coverage map (which ADRs cover which subsystems)              | `docs/project/architecture/adr-coverage-map.md`                          | PARTIAL  | (D3.1 reconciled @ docs/project/architecture/)
| infrastructure        | Hardware inventory (existing)                                     | `docs/canon/HW-MODEL-UPGRADE-matrix.md`                                  | PARTIAL  |
| infrastructure        | Production network topology + VPN/Tailscale diagram                | `docs/project/infrastructure/production-topology.md`                     | MISSING  |
| IAM/security          | Privilege model (existing)                                        | `PRIVILEGE-MODEL.md`                                                     | DONE     |

---

## Sprint S13 — Compliance / regulatory pack v1

**Objective:** Consolidate AML / KYC / sanctions / FCA SYSC SOPs into a single audit-ready
pack. Cross-reference accepted ADRs.

| Domain                  | Deliverable                                                       | Target path                                                              | Status   |
|-------------------------|-------------------------------------------------------------------|--------------------------------------------------------------------------|----------|
| compliance/regulatory   | AML programme SOP                                                 | `docs/project/compliance/aml-programme-sop.md`                           | PARTIAL  | (D3.1 reconciled @ docs/project/compliance/)
| compliance/regulatory   | KYC / KYB onboarding SOP                                          | `docs/project/compliance/kyc-kyb-onboarding-sop.md`                      | PARTIAL  |
| compliance/regulatory   | Sanctions screening policy (existing root)                        | `SANCTIONS-POLICY.md`                                                    | PARTIAL  |
| compliance/regulatory   | FCA SYSC 15A operational resilience plan                          | `docs/project/compliance/sysc-15a-operational-resilience.md`             | PARTIAL  | (D3.1 reconciled @ docs/project/compliance/)
| compliance/regulatory   | MLR 2017 Reg 27/28 evidence map                                   | `docs/project/compliance/mlr-2017-evidence-map.md`                       | PARTIAL  | (D3.1 reconciled @ docs/project/compliance/)
| compliance/regulatory   | HITL gates registry (existing partial)                            | `docs/policies/hitl-l3-agent-gate-2026-05-11.md`                         | PARTIAL  |
| go-live readiness       | Compliance pack v1 review checklist                               | `docs/project/compliance/compliance-pack-v1-review-checklist.md`         | PARTIAL  | (D3.1 reconciled @ docs/project/compliance/)

---

## Sprint S14 — Audit-trail durability dossier (ADR-027 / CASS 15 §15.10)

**Objective:** Document BufferedAuditPort behaviour, drain runbook, RPO targets, regulator
testimony pack.

| Domain                  | Deliverable                                                       | Target path                                                              | Status   |
|-------------------------|-------------------------------------------------------------------|--------------------------------------------------------------------------|----------|
| architecture            | ADR-027 reference (existing)                                      | `docs/adr/ADR-027-audit-trail-durability.md`                             | DONE     |
| operations/runbooks     | Audit-buffer drain runbook                                        | `docs/project/operations/audit-buffer-drain-runbook.md`                  | PARTIAL  | (D3.1 reconciled @ docs/project/operations/)
| operations/runbooks     | ClickHouse outage response runbook                                | `docs/project/operations/clickhouse-outage-response.md`                  | PARTIAL  | (D3.1 reconciled @ docs/project/operations/)
| compliance/regulatory   | CASS 15 §15.10 evidence dossier                                   | `docs/project/compliance/cass-15-15-10-evidence.md`                      | PARTIAL  | (D3.1 reconciled @ docs/project/compliance/)
| testing/QA              | E2E audit-trail coverage report (links to G-CASS-02 tests)         | `docs/project/testing/audit-trail-coverage-report.md`                    | MISSING  |
| data governance         | Audit-trail retention + erasure policy                            | `docs/project/data/audit-trail-retention.md`                  | PARTIAL  | (D3.1 reconciled @ docs/project/data/)

---

## Sprint S15 — Webhook reliability + KYC integration (ADR-034)

**Objective:** Document SumSub inbound + outbound webhook flow, idempotency policy, DLQ ops.

| Domain                  | Deliverable                                                       | Target path                                                              | Status   |
|-------------------------|-------------------------------------------------------------------|--------------------------------------------------------------------------|----------|
| architecture            | ADR-034 reference (existing)                                      | `docs/adr/ADR-034-webhook-reliability-kyc.md`                            | DONE     |
| operations/runbooks     | SumSub webhook ops runbook (HMAC, replay, DLQ drain)              | `docs/project/operations/sumsub-webhook-runbook.md`                      | PARTIAL  | (D3.1 reconciled @ docs/project/operations/)
| IAM/security            | SumSub credential rotation procedure                              | `docs/project/security/sumsub-credential-rotation.md`                | PARTIAL  | (D3.1 reconciled @ docs/project/security/)
| testing/QA              | Webhook signature + idempotency test catalogue (G-KYC-04 link)    | `docs/project/testing/webhook-signature-idempotency-tests.md`            | MISSING  |
| compliance/regulatory   | KYC FSM transitions evidence map                                  | `docs/project/compliance/kyc-fsm-transitions-evidence.md`                | PARTIAL  | (D3.1 reconciled @ docs/project/compliance/)

---

## Sprint S16 — Alert routing + observability (ADR-033)

**Objective:** Document n8n + Telegram alert routing, on-call playbook, severity matrix.

| Domain                  | Deliverable                                                       | Target path                                                              | Status   |
|-------------------------|-------------------------------------------------------------------|--------------------------------------------------------------------------|----------|
| architecture            | ADR-033 reference (existing)                                      | `docs/adr/ADR-033-alert-routing-strategy.md`                             | DONE     |
| operations/runbooks     | Alert on-call playbook (KC auth + safeguarding + admin events)    | `docs/project/operations/alert-on-call-playbook.md`                      | PARTIAL  | (D3.1 reconciled @ docs/project/operations/)
| operations/runbooks     | n8n + Telegram pipeline ops runbook                               | `docs/project/operations/n8n-telegram-pipeline.md`                       | PARTIAL  | (D3.1 reconciled @ docs/project/operations/)
| operations/runbooks     | Alert severity + ownership matrix                                 | `docs/project/operations/alert-severity-ownership-matrix.md`             | PARTIAL  | (D3.1 reconciled @ docs/project/operations/)
| testing/QA              | Alert coverage smoke test catalogue (G-OBS-02 link)               | `docs/project/testing/alert-coverage-smoke-tests.md`                     | MISSING  |

---

## Sprint S17 — Secrets rotation + IAM hardening (ADR-032)

**Objective:** Document secret-rotation cadence, KC realm/client model, BYOK policy.

| Domain                  | Deliverable                                                       | Target path                                                              | Status   |
|-------------------------|-------------------------------------------------------------------|--------------------------------------------------------------------------|----------|
| architecture            | ADR-032 reference (existing)                                      | `docs/adr/ADR-032-secret-rotation-policy.md`                             | DONE     |
| IAM/security            | Secret rotation runbook + cadence                                 | `docs/project/security/secret-rotation-runbook.md`                   | PARTIAL  | (D3.1 reconciled @ docs/project/security/)
| IAM/security            | Keycloak realm + client documentation                             | `docs/project/security/keycloak-realm-client-doc.md`                 | PARTIAL  | (D3.1 reconciled @ docs/project/security/)
| IAM/security            | BYOK / KMS policy                                                 | `docs/project/security/byok-kms-policy.md`                           | PARTIAL  | (D3.1 reconciled @ docs/project/security/)
| IAM/security            | Privilege model (existing)                                        | `PRIVILEGE-MODEL.md`                                                     | DONE     |
| compliance/regulatory   | Secrets-in-CI scan policy (gitleaks coverage doc)                 | `docs/project/compliance/secrets-in-ci-scan-policy.md`                   | PARTIAL  | (D3.1 reconciled @ docs/project/compliance/)
| IAM/security            | Long-term Vault / Infisical adoption (G-SEC-02)                   | `docs/project/security/vault-adoption-plan.md`                       | DEFERRED |

> DEFERRED anchor: G-SEC-02 stays OPEN per `INSTRUCTION-LEDGER.md`
> `IL-OPS-TRACKS-EF-PARTIAL-CLOSURE-2026-05-11`. Vault adoption is production-scope.

---

## Sprint S18 — Postgres backup + restore drill (ADR-029)

**Objective:** Document backup chain, restore drill cadence, offsite verification, RPO/RTO.

| Domain                  | Deliverable                                                       | Target path                                                              | Status   |
|-------------------------|-------------------------------------------------------------------|--------------------------------------------------------------------------|----------|
| architecture            | ADR-029 reference (existing)                                      | `docs/adr/ADR-029-postgres-backup-strategy.md`                           | DONE     |
| operations/runbooks     | Backup chain runbook (pgbackrest / WAL-G / cron)                  | `docs/project/operations/postgres-backup-runbook.md`                     | PARTIAL  | (D3.1 reconciled @ docs/project/operations/)
| operations/runbooks     | Restore drill runbook + cadence                                   | `docs/project/operations/postgres-restore-drill-runbook.md`              | PARTIAL  | (D3.1 reconciled @ docs/project/operations/)
| operations/runbooks     | Offsite upload verification procedure                             | `docs/project/operations/postgres-offsite-verification.md`               | PARTIAL  | (D3.1 reconciled @ docs/project/operations/)
| go-live readiness       | RPO / RTO targets + measured baseline                             | `docs/project/go-live/postgres-rpo-rto-baseline.md`                      | MISSING  |
| testing/QA              | Backup chain smoke test catalogue                                 | `docs/project/testing/backup-chain-smoke-tests.md`                       | MISSING  |

---

## Sprint S19 — Auth rate-limit + abuse policies (ADR-030)

**Objective:** Document rate-limit configuration, escalation paths, audit-emitter contract.

| Domain                  | Deliverable                                                       | Target path                                                              | Status   |
|-------------------------|-------------------------------------------------------------------|--------------------------------------------------------------------------|----------|
| architecture            | ADR-030 reference (existing)                                      | `docs/adr/ADR-030-auth-rate-limit-policy.md`                             | DONE     |
| IAM/security            | Rate-limit configuration matrix (per route, per identity tier)    | `docs/project/security/rate-limit-configuration-matrix.md`           | PARTIAL  | (D3.1 reconciled @ docs/project/security/)
| operations/runbooks     | 429 incident response runbook                                     | `docs/project/operations/429-incident-response.md`                       | PARTIAL  | (D3.1 reconciled @ docs/project/operations/)
| compliance/regulatory   | Brute-force / abuse escalation policy                             | `docs/project/compliance/abuse-escalation-policy.md`                     | PARTIAL  | (D3.1 reconciled @ docs/project/compliance/)
| testing/QA              | Rate-limit smoke test catalogue                                   | `docs/project/testing/rate-limit-smoke-tests.md`                         | MISSING  |

---

## Sprint S20 — CI smoke-gate + change management (ADR-035)

**Objective:** Document branch-protection contracts, smoke-gate workflow, release checklist.

| Domain                  | Deliverable                                                       | Target path                                                              | Status   |
|-------------------------|-------------------------------------------------------------------|--------------------------------------------------------------------------|----------|
| architecture            | ADR-035 reference (existing)                                      | `docs/adr/ADR-035-ci-smoke-gate-policy.md`                               | DONE     |
| operations/runbooks     | Branch-protection + required-checks contract                      | `docs/project/operations/branch-protection-contract.md`                  | PARTIAL  | (D3.1 reconciled @ docs/project/operations/)
| operations/runbooks     | Release checklist (sandbox → production candidate)                | `docs/project/operations/release-checklist.md`                           | PARTIAL  | (D3.1 reconciled @ docs/project/operations/)
| testing/QA              | Smoke-gate full-tier promotion plan (G-CI-02 full-tier)           | `docs/project/testing/smoke-gate-full-tier-promotion.md`                 | DEFERRED |

> DEFERRED anchor: G-CI-02 full-tier enforcement deferred to Phase 9 per
> `IL-OPS-TRACK-G-FINAL-CLOSURE-2026-05-11`. Documentation kept for forward continuity.

---

## Sprint S21 — Data governance, GDPR ROPA, retention

**Objective:** Publish ROPA, data-flow diagrams, retention / erasure procedures.

| Domain                  | Deliverable                                                       | Target path                                                              | Status   |
|-------------------------|-------------------------------------------------------------------|--------------------------------------------------------------------------|----------|
| data governance         | GDPR Art. 30 Record of Processing Activities (ROPA)               | `docs/project/data/gdpr-ropa.md`                              | PARTIAL  | (D3.1 reconciled @ docs/project/data/)
| data governance         | Data-flow diagrams (per business process)                         | `docs/project/data/data-flow-diagrams.md`                     | PARTIAL  | (D3.1 reconciled @ docs/project/data/)
| data governance         | Retention schedule (per data class)                               | `docs/project/data/retention-schedule.md`                     | PARTIAL  | (D3.1 reconciled @ docs/project/data/)
| data governance         | Right-to-erasure (Art. 17) procedure                              | `docs/project/data/erasure-procedure.md`                      | PARTIAL  | (D3.1 reconciled @ docs/project/data/)
| data governance         | Cross-border transfer assessment                                  | `docs/project/data/cross-border-transfer-assessment.md`       | BLOCKED  |
| data governance         | AI data flow (existing)                                           | `docs/compliance/ai-data-flow.md`                                        | PARTIAL  |

> BLOCKED anchor: cross-border transfer assessment depends on Legal-confirmed list of
> third-country processors (vendor contracts pending). Track I dependency.

---

## Sprint S22 — Testing / QA programme + traceability matrix

**Objective:** Publish test strategy, coverage targets, gating policy, regulator-evidence
traceability matrix.

| Domain                  | Deliverable                                                       | Target path                                                              | Status   |
|-------------------------|-------------------------------------------------------------------|--------------------------------------------------------------------------|----------|
| testing/QA              | Test strategy document                                            | `docs/project/testing/test-strategy.md`                                  | MISSING  |
| testing/QA              | Coverage targets per service                                      | `docs/project/testing/coverage-targets.md`                               | MISSING  |
| testing/QA              | Gating policy (which tests block which environments)              | `docs/project/testing/gating-policy.md`                                  | MISSING  |
| testing/QA              | Requirement → test → evidence traceability matrix                 | `docs/project/testing/traceability-matrix.md`                            | MISSING  |
| testing/QA              | Smoke test inventory (consolidated index)                         | `docs/project/testing/smoke-test-inventory.md`                           | MISSING  |

---

## Sprint S23 — Operations / runbooks consolidation

**Objective:** Consolidate scattered runbooks into a single library; publish on-call
playbook and incident-response procedure.

| Domain                  | Deliverable                                                       | Target path                                                              | Status   |
|-------------------------|-------------------------------------------------------------------|--------------------------------------------------------------------------|----------|
| operations/runbooks     | Runbook library index (consolidates `docs/runbooks/`)             | `docs/project/operations/runbook-library-index.md`                       | PARTIAL  | (D3.1 reconciled @ docs/project/operations/)
| operations/runbooks     | On-call playbook (rotations, escalation, comms)                   | `docs/project/operations/on-call-playbook.md`                            | PARTIAL  | (D3.1 reconciled @ docs/project/operations/)
| operations/runbooks     | Incident response procedure                                       | `docs/project/operations/incident-response-procedure.md`                 | PARTIAL  | (D3.1 reconciled @ docs/project/operations/)
| operations/runbooks     | HITL decision recording (existing)                                | `docs/runbooks/hitl-decision-recording.md`                               | PARTIAL  |
| go-live readiness       | Runbook completeness checklist (per service)                      | `docs/project/go-live/runbook-completeness-checklist.md`                 | MISSING  |

---

## Sprint S24 — Pre-go-live audit pack

**Objective:** Assemble the dossier MLRO / DPO / Legal / CCO will sign off before go-live.

| Domain                  | Deliverable                                                       | Target path                                                              | Status   |
|-------------------------|-------------------------------------------------------------------|--------------------------------------------------------------------------|----------|
| go-live readiness       | Pre-go-live audit pack (assurance dossier)                        | `docs/project/go-live/pre-go-live-audit-pack.md`                         | MISSING  |
| go-live readiness       | MLRO sign-off checklist                                           | `docs/project/go-live/mlro-signoff-checklist.md`                         | MISSING  |
| go-live readiness       | DPO sign-off checklist                                            | `docs/project/go-live/dpo-signoff-checklist.md`                          | MISSING  |
| go-live readiness       | Legal sign-off checklist                                          | `docs/project/go-live/legal-signoff-checklist.md`                        | MISSING  |
| go-live readiness       | CCO sign-off checklist                                            | `docs/project/go-live/cco-signoff-checklist.md`                          | MISSING  |
| compliance/regulatory   | Open-items register (everything still PARTIAL/BLOCKED at S24)     | `docs/project/compliance/open-items-register.md`                         | PARTIAL  | (D3.1 reconciled @ docs/project/compliance/)

---

## Sprint S25 — Go-live + post-go-live handover

**Objective:** Publish BCP / DR plan, regulator-notification SOP, ops handover dossier.

| Domain                  | Deliverable                                                       | Target path                                                              | Status   |
|-------------------------|-------------------------------------------------------------------|--------------------------------------------------------------------------|----------|
| go-live readiness       | Business Continuity Plan (BCP)                                    | `docs/project/go-live/business-continuity-plan.md`                       | MISSING  |
| go-live readiness       | Disaster Recovery (DR) plan                                       | `docs/project/go-live/disaster-recovery-plan.md`                         | MISSING  |
| compliance/regulatory   | Regulator-notification SOP (FCA, ICO, ECB-relevant)               | `docs/project/compliance/regulator-notification-sop.md`                  | PARTIAL  | (D3.1 reconciled @ docs/project/compliance/)
| operations/runbooks     | Post-go-live operations handover dossier                          | `docs/project/operations/post-go-live-handover.md`                       | PARTIAL  | (D3.1 reconciled @ docs/project/operations/)
| go-live readiness       | Day-1 / Day-7 / Day-30 review playbooks                           | `docs/project/go-live/post-go-live-review-playbooks.md`                  | MISSING  |
| go-live readiness       | Sign-off ledger (final)                                           | `docs/project/go-live/sign-off-ledger.md`                                | MISSING  |

---

## Cross-cutting open items (programme-level dependencies)

| Item                                                            | Sprint impact          | Tag      | Owner / blocker                                                      |
|-----------------------------------------------------------------|------------------------|----------|-----------------------------------------------------------------------|
| Vault / Infisical long-term adoption (G-SEC-02)                 | S17                    | DEFERRED | Production-scope per Track F partial-closure IL                       |
| Smoke-gate full-tier required-check enforcement (G-CI-02)       | S20                    | DEFERRED | Phase 9 per Track G final-closure IL                                  |
| Cross-border transfer assessment (vendor contract list)         | S21                    | BLOCKED  | Legal — third-country processor contracts pending                     |
| 7 sandbox-mocked external API keys (Track I)                    | S13, S15, S16, S25     | BLOCKED  | Operator — production credentials pending vendor onboarding           |
| MLRO / DPO / SMF holders sign-off                               | S13, S24, S25          | BLOCKED  | Operator — appointment + engagement letters pending (Track I)         |
| KC Phase F/G operator-led IAM live-ops (Track B)                | S17                    | BLOCKED  | Operator — pending KC live-ops sprint                                 |

## Definition of Done (per sprint)

A sprint S-N is considered done when **all** of the following hold:

1. Every MISSING deliverable in S-N is moved to DONE or PARTIAL (with named gap), OR
   has been re-tagged to BLOCKED / DEFERRED with cited justification.
2. The status column in this backlog has been updated for every row in S-N.
3. The master index (`PROJECT-DOCUMENTATION-MASTER-INDEX.md`) §5 domain table is
   re-asserted (status may stay PARTIAL across sprints; the assertion is what matters).
4. A sprint-close note is appended to the change log of this backlog and the index.

## Change log

| Date       | Change                                                          | Sprint |
|------------|-----------------------------------------------------------------|--------|
| 2026-05-12 | Sprint D1 — initial publication of S12-S25 backlog              | D1     |
