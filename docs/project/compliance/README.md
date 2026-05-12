# Compliance & Regulatory — Project Documentation (Layer 2)

Status: CONTENT (D3.2b — full sub-domain content landed)
Sprint: D3.2b (2026-05-12)
Layer: 2 (Product Docs per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
Anchors: IL-PROJECT-DOCS-SPRINT-D1-BASELINE-2026-05-12,
IL-OPS-G-CASS-02-CLOSED-TRACK-D-FULLY-CLOSED-2026-05-11,
IL-OPS-S12-1-DONE-EVIDENCE-AND-NEW-GAPS-2026-05-12,
FCA SUP 15 / CASS 15 / SYSC 4.1, GDPR Art. 30 RoPA / Art. 32 / Art. 33 / Art. 15-22,
AMLR / AMLD6 / MLR 2017, JMLSG, FATF Travel Rule, OFSI / EU / UN sanctions,
Safeguarding (Sprint S20), MLRO (Sprint S20.8),
G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION, G-CASS-01, G-CASS-02,
ADR-027 (audit-trail durability), ADR-028 (KYC re-verification), ADR-032
(secret rotation), ADR-038 (Vault placeholder),
Sprint S13–S25

---

## Scope

In-scope topics for this domain (regulatory sub-anchors):

- **FCA SUP 15** — supervisory notifications, periodic returns, reportable events.
- **FCA CASS 15** (Client Asset Sourcebook) — safeguarding evidence dossier, with
  particular focus on **CASS 15 §15.10** audit-trail durability (ADR-027 anchor).
- **FCA SYSC 4.1** — operational resilience plan, important business services,
  impact-tolerance statements.
- **GDPR Art. 30 Record of Processing Activities (RoPA)** — bank-side processors,
  data classes, lawful basis, retention. Detailed authoring lives under `../data/`;
  RoPA compliance attestations and cross-references land here.
- **AMLR / AMLD6 / AML CTF / MLR 2017** — AML Programme SOP, MLR 2017 Reg 27/28
  evidence map, sanctions screening policy, SAR submission, customer-risk model.
- **Safeguarding** (Sprint S20) — client funds vs operational funds segregation,
  daily reconciliation, FIN-060 reporting.
- **MLRO accountability** (Sprint S20.8) — MLRO sign-off ledger and audit trail.
- **G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION** — incident notification SOP.

## Out of scope

- Implementation source code (lives in `banxe-emi-stack/`).
- Operational runbooks executing compliance procedures (lives under `../operations/`).
- Architectural ADRs themselves (lives under `../architecture/` / `decisions/`).
- Internal HITL workflow mechanics (lives under `../operations/` / `../governance/`).
- GDPR Art. 30 authoring detail (lives under `../data/`).

## Definition of Done

Verbatim from [`../PROJECT-DOCUMENTATION-MASTER-INDEX.md`](../PROJECT-DOCUMENTATION-MASTER-INDEX.md)
§3:

A deliverable is DONE when **all four** of the following are true:

1. Document exists at a stable canonical path under `docs/project/` or a domain folder.
2. Document has named owner, version, and last-reviewed date in its header.
3. Document has been reviewed by the relevant track-lead and reflects current
   production reality (no stale architectural references, no removed services, no
   unmerged ADRs).
4. Document is reachable from this index in two hops or fewer
   (index → backlog → doc, or index → domain table → doc).

## Current artifacts

Real files (enumerated via `git ls-files` / `find docs/`):

- `COMPLIANCE-ARCH.md` (repo root) — top-level compliance architecture.
- `SANCTIONS-POLICY.md` (repo root) — sanctions screening policy.
- `docs/COMPLIANCE-MATRIX.md` — regulatory ↔ control matrix.
- `docs/ARCHITECTURE-18-COMPLIANCE-KB.md` — compliance KB architecture.
- `docs/compliance/ai-data-flow.md` — AI data flow (PARTIAL).
- `docs/policies/ACCESS-AND-SECRETS.md` — access + secrets policy.
- `docs/policies/hitl-l3-agent-gate-2026-05-11.md` — HITL L3 agent gate (PARTIAL).
- `INVARIANTS.md` (repo root) — bank invariants (compliance gates anchored).
- `GAP-REGISTER.md` (repo root) — open compliance gaps
  (G-CASS-01/02, G-KYC-*, G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION).

---

## A. FCA EMI obligations

### A.1 Authorization regime

- BANXE operates as an Electronic Money Institution (EMI) under the **Payment
  Services Regulations 2017 (PSR 2017)** transposing PSD2, and the
  **Electronic Money Regulations 2011 (EMR 2011)** transposing EMD2.
- FCA EMI authorization process: full authorization (not small EMI exemption)
  per current scope — covers e-money issuance, payment services A1–A8, and
  safeguarding obligations under EMR 2011 reg. 20–24.
- TODO: verify current FCA application reference number and stage — owner Sprint
  S13 (Compliance pack v1) or D3.x discovery.

### A.2 SUP 15.3.11R notification

- **SUP 15.3.11R** requires notification to the FCA of significant operational
  incidents without undue delay.
- Open gap: `G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION` — incident
  notification SOP not yet authored; current OPEN status.
- Incident 2026-05-08 retroactive decision: MLRO / DPO / Legal sign-off
  required to determine whether incident crossed the SUP 15.3.11R threshold.
  TODO: discover sign-off decision artifact path in D3.2c gap list; reference
  incident dossiers under `docs/incidents/`.
- Owner sprint: **S25** for the SOP (`docs/project/compliance/regulator-notification-sop.md`,
  MISSING per backlog).

### A.3 CASS 15 — audit-trail durability

- **CASS 15 §15.10** mandates auditable records of all reconciliation events
  with a 5-year retention horizon.
- Evidence: **IL-OPS-G-CASS-02-CLOSED-TRACK-D-FULLY-CLOSED-2026-05-11** closes
  Track D (Audit-Trail Durability) — 5 E2E tests merged demonstrating buffered
  audit-trail behaviour under backend failure / recovery / no silent loss.
- Authoritative ADR: **ADR-027 audit-trail durability**
  ([decisions/ADR-027-audit-trail-durability.md](../../decisions/ADR-027-audit-trail-durability.md)).
- Anchor reconciliation closed by D3.2d.4: CASS 15 §15.10 / 5y ClickHouse
  retention is anchored on ADR-027 (cited above). Full reconciliation history
  is recorded in IL-PROJECT-DOCS-SPRINT-D3-2D-4-CITATIONS-REANCHOR-2026-05-12.
- ClickHouse Guardian: the production audit sink. Retention configuration
  (5y TTL, append-only, I-24 invariant enforced) is referenced in
  `IL-OPS-G-CASS-02-CLOSED-TRACK-D-FULLY-CLOSED-2026-05-11`.
- Owner sprint: **S14** for the CASS 15 evidence dossier
  (`docs/project/compliance/cass-15-15-10-evidence.md`, MISSING per backlog).

### A.4 SYSC 4.1 — operational resilience

- **FCA SYSC 4.1** requires robust governance arrangements and operational
  resilience for important business services.
- Currently blocking: **G-IAM-08** + **G-IAM-09** (per
  `IL-OPS-S12-1-DONE-EVIDENCE-AND-NEW-GAPS-2026-05-12`). Resolution of these
  IAM gaps is a precondition for the SYSC 4.1 attestation.
- Owner sprint: **S13** for the operational resilience plan
  (`docs/project/compliance/sysc-15a-operational-resilience.md`, MISSING per
  backlog — note path uses "sysc-15a" naming; rename to "sysc-4-1" in D3.2c).

---

## B. GDPR / UK DPA

### B.1 Art. 30 — Record of Processing Activities (RoPA)

- Target: `docs/project/data/gdpr-ropa.md` (MISSING).
- Authoring lives under `../data/`; this domain holds the compliance
  attestation cross-reference and review checklist.
- Owner sprint: **S21** (Data governance) per backlog.

### B.2 Art. 32 — Security of processing

- Cross-link: see [`../security/README.md`](../security/README.md) for technical
  measures.
- Vault adoption (long-term key management): **ADR-038**
  (`decisions/ADR-038-vault-adoption-placeholder.md`) — placeholder.
- **G-SEC-02** (Vault / Infisical adoption) DEFERRED per
  `IL-OPS-TRACKS-EF-PARTIAL-CLOSURE-2026-05-11`.
- Interim mitigations: `ADR-032 secret-rotation-policy` rotation cadence.
- Owner sprint: **S17** (Secrets rotation + IAM hardening) for the Art. 32
  attestation; the long-term Vault plan stays DEFERRED.

### B.3 Art. 33 — Personal-data breach notification (72h)

- Target: `docs/project/compliance/gdpr-breach-notification-72h.md` (MISSING).
- Statutory clock: 72 hours from awareness to ICO notification.
- Open issue: incident 2026-05-08 occurred before this SOP was authored; the
  72-hour window has elapsed. Retroactive determination of whether
  notification was required is part of the MLRO / DPO / Legal sign-off (see
  §A.2). TODO: discover the retroactive determination artifact in D3.2c.
- Owner sprint: **S25** (regulator-notification SOP family).

### B.4 Art. 15-22 — Data subject rights

- Target: `docs/project/compliance/gdpr-data-subject-rights.md` (MISSING).
- Covered rights: access (Art. 15), rectification (Art. 16), erasure (Art. 17),
  restriction (Art. 18), portability (Art. 20), objection (Art. 21),
  automated decision-making (Art. 22).
- Owner sprint: **S21** alongside the Art. 30 RoPA work.

### B.5 Cross-border transfer assessment

- Target: `docs/project/data/cross-border-transfer-assessment.md` (BLOCKED —
  per backlog S21, awaiting Legal-confirmed list of third-country processors).
- Required for Chapter V transfers (UK GDPR / EU GDPR adequacy + SCCs / IDTA).
- Owner sprint: **S21**, status **BLOCKED**.

---

## C. AML / CTF

### C.1 Risk assessment

- Target: `docs/project/compliance/aml-risk-assessment.md` (PARTIAL — referenced
  in `COMPLIANCE-ARCH.md` but standalone document not yet authored).
- Coverage required: customer risk, product risk, geographic risk, channel risk.
- Owner sprint: **S13** as part of the Compliance Pack v1.

### C.2 CDD / EDD — SumSub and Sardine.ai

- Customer Due Diligence pipeline: **SumSub** integration for KYC / KYB
  onboarding (current PARTIAL; see `docs/project/compliance/kyc-kyb-onboarding-sop.md`,
  MISSING per backlog).
- Enhanced Due Diligence + transaction monitoring: **Sardine.ai** integration
  scheduled for **Sprint S20.4**.
- TODO: discover live SumSub credentials path and Sardine.ai onboarding ETA in
  D3.2c (likely under `docs/project/security/sumsub-credential-rotation.md`).

### C.3 SAR / STR workflow

- Target: `docs/project/compliance/sar-str-workflow.md` (MISSING).
- Suspicious Activity Reports (UK NCA) / Suspicious Transaction Reports
  (relevant EU/cross-border).
- Linked to MLRO accountability (Sprint S20.8 MLRO sign-off ledger).
- Owner sprint: **S20.8**.

### C.4 JMLSG guidance alignment

- The Joint Money Laundering Steering Group (JMLSG) Guidance is the de facto
  UK industry standard for AML / CTF programmes.
- Alignment evidence required for FCA EMI authorisation.
- TODO: produce JMLSG alignment matrix (mapping each JMLSG section to BANXE
  control). Owner sprint: **S13** alongside the AML Programme SOP.

### C.5 AMLD6 / AMLR EU regulation tracking

- **AMLD6** (Directive (EU) 2018/1673) — criminal-law harmonisation; UK
  implementation via MLR 2017 (amended).
- **AMLR** (Regulation (EU) 2024/1624, in force gradually 2025–2027) — directly
  applicable in EU; UK monitoring relevant for cross-border services.
- TODO: produce regulatory-monitoring procedure that scans for AMLR rule
  changes affecting BANXE EU activities. Owner sprint: **S13**.

---

## D. Safeguarding (e-money)

- **EMR 2011 reg. 20–24** mandates safeguarding of customer funds: segregation
  in a safeguarding account, daily reconciliation, FIN-060 reporting.
- Implementation: `banxe-emi-stack/services/safeguarding` (source code; out
  of scope for this README — see backlog for compliance-side attestation).
- **Daily reconciliation** (D-recon): scheduled for **Sprint S16 D-recon**.
- **Safeguarding bank account**: provisioning requires Modulr live API key —
  scheduled for **Sprint S20.1**.
- Target dossier: `docs/project/compliance/safeguarding-fin060-procedure.md`
  (MISSING per backlog, owner sprint S20).

---

## E. Sanctions screening

### E.1 Lists in scope

- **UK OFSI** consolidated list (His Majesty's Treasury — Office of Financial
  Sanctions Implementation).
- **EU consolidated financial sanctions list** (Council of the European Union).
- **UN Security Council** sanctions list (1267, 1718, 2231, etc.).
- Optional secondary: OFAC SDN, HM Treasury CFTV, country-specific lists.

### E.2 Sardine.ai integration

- Scheduled for **Sprint S20.4** as the live screening provider.
- Pre-Sardine: list lookups via static OFSI / EU / UN list snapshots; out
  of scope for go-live attestation.

### E.3 Match adjudication workflow

- Target: `docs/project/compliance/sanctions-match-adjudication.md` (MISSING).
- Required: 4-eye review for positive / fuzzy matches, MLRO escalation path,
  HITL gate per `docs/policies/hitl-l3-agent-gate-2026-05-11.md` (PARTIAL).
- Owner sprint: **S13** alongside the sanctions screening policy at
  `SANCTIONS-POLICY.md`.

---

## F. Travel Rule (FATF)

- **FATF Recommendation 16** ("Travel Rule") for virtual asset service
  providers — originator + beneficiary information transmission alongside
  transfers above the threshold.
- TODO: verify anchor **ADR-036**. Brief states "ADR-036 CLOSED per PR #214"
  but `decisions/ADR-036-*.md` is NOT present in repo. Reconcile in D3.2c:
  either retrieve the ADR-036 artifact, or open a Travel Rule ADR under the
  next free number. Until then, treat the closure claim as unverified.
- Implementation deferred to **Sprint S21 Crypto Block** per brief.

---

## G. Sprint mapping (obligation → backlog row → target path)

| Obligation                              | Backlog sprint | Target path                                                                  |
|-----------------------------------------|----------------|------------------------------------------------------------------------------|
| AML Programme SOP                       | S13            | `docs/project/compliance/aml-programme-sop.md`                               |
| KYC / KYB onboarding SOP                | S13            | `docs/project/compliance/kyc-kyb-onboarding-sop.md`                          |
| Sanctions match adjudication            | S13            | `docs/project/compliance/sanctions-match-adjudication.md`                    |
| AML risk assessment                     | S13            | `docs/project/compliance/aml-risk-assessment.md`                             |
| JMLSG alignment matrix                  | S13            | `docs/project/compliance/jmlsg-alignment-matrix.md` (TODO)                   |
| AMLR / AMLD6 monitoring                 | S13            | `docs/project/compliance/eu-aml-monitoring.md` (TODO)                        |
| Compliance pack v1 review checklist     | S13            | `docs/project/compliance/compliance-pack-v1-review-checklist.md`             |
| FCA SYSC 4.1 operational resilience     | S13            | `docs/project/compliance/sysc-15a-operational-resilience.md` (rename to 4-1) |
| MLR 2017 Reg 27/28 evidence map         | S13            | `docs/project/compliance/mlr-2017-evidence-map.md`                           |
| CASS 15 §15.10 evidence (ADR-027)       | S14            | `docs/project/compliance/cass-15-15-10-evidence.md`                          |
| KYC FSM transitions evidence (ADR-028)  | S15            | `docs/project/compliance/kyc-fsm-transitions-evidence.md`                    |
| Secrets-in-CI scan policy (ADR-032)     | S17            | `docs/project/compliance/secrets-in-ci-scan-policy.md`                       |
| Brute-force / abuse escalation (ADR-030)| S19            | `docs/project/compliance/abuse-escalation-policy.md`                         |
| Safeguarding + FIN-060 procedure        | S20            | `docs/project/compliance/safeguarding-fin060-procedure.md`                   |
| SAR / STR workflow                      | S20.8          | `docs/project/compliance/sar-str-workflow.md`                                |
| MLRO sign-off ledger                    | S20.8          | `docs/project/compliance/mlro-signoff-ledger.md`                             |
| Travel Rule (FATF) Crypto Block         | S21            | `docs/project/compliance/travel-rule-fatf.md` (TODO)                         |
| GDPR Art. 33 breach notification SOP    | S21 / S25      | `docs/project/compliance/gdpr-breach-notification-72h.md`                    |
| GDPR Art. 15-22 data subject rights     | S21            | `docs/project/compliance/gdpr-data-subject-rights.md`                        |
| Regulator-notification SOP              | S25            | `docs/project/compliance/regulator-notification-sop.md`                      |
| Open-items register                     | S24            | `docs/project/compliance/open-items-register.md`                             |

---

## H. Open gaps for D3.2c+

Files referenced above that do not yet exist; queued for creation in D3.2c
or later sprints. Each line names the target path, anchor, and owner sprint.

- `docs/project/compliance/aml-programme-sop.md` — AML Programme SOP (S13).
- `docs/project/compliance/kyc-kyb-onboarding-sop.md` — KYC / KYB SOP (S13).
- `docs/project/compliance/sanctions-match-adjudication.md` — sanctions match
  adjudication (S13).
- `docs/project/compliance/aml-risk-assessment.md` — AML risk assessment (S13).
- `docs/project/compliance/jmlsg-alignment-matrix.md` — JMLSG alignment (S13);
  TODO: confirm canonical path naming with track-lead.
- `docs/project/compliance/eu-aml-monitoring.md` — AMLR / AMLD6 monitoring
  (S13); TODO: confirm canonical path naming with track-lead.
- `docs/project/compliance/sysc-15a-operational-resilience.md` — rename to
  `sysc-4-1-...` in D3.2c to match the actual FCA Handbook section.
- `docs/project/compliance/mlr-2017-evidence-map.md` — MLR 2017 evidence (S13).
- `docs/project/compliance/cass-15-15-10-evidence.md` — CASS 15 §15.10
  evidence (S14); cite ADR-027 audit-trail durability per §A.3.
- `docs/project/compliance/kyc-fsm-transitions-evidence.md` — KYC FSM
  evidence (S15).
- `docs/project/compliance/safeguarding-fin060-procedure.md` — safeguarding +
  FIN-060 (S20).
- `docs/project/compliance/sar-str-workflow.md` — SAR / STR workflow (S20.8).
- `docs/project/compliance/mlro-signoff-ledger.md` — MLRO sign-off ledger
  (S20.8).
- `docs/project/compliance/travel-rule-fatf.md` — Travel Rule (S21);
  TODO: verify ADR-036 anchor before authoring.
- `docs/project/compliance/gdpr-breach-notification-72h.md` — GDPR Art. 33
  SOP (S21/S25).
- `docs/project/compliance/gdpr-data-subject-rights.md` — GDPR Art. 15-22
  procedures (S21).
- `docs/project/compliance/regulator-notification-sop.md` — regulator
  notification SOP (S25).
- `docs/project/compliance/secrets-in-ci-scan-policy.md` — gitleaks coverage
  policy (S17).
- `docs/project/compliance/abuse-escalation-policy.md` — ADR-030 anchor (S19).
- `docs/project/compliance/compliance-pack-v1-review-checklist.md` — review
  checklist (S13).
- `docs/project/compliance/open-items-register.md` — open-items register (S24).
- Resolved (D3.2d.4): canonical anchor for CASS 15 §15.10 / 5y retention is
  ADR-027 audit-trail durability. See §A.3 and
  IL-PROJECT-DOCS-SPRINT-D3-2D-4-CITATIONS-REANCHOR-2026-05-12.
- TODO: verify anchor **ADR-036** for Travel Rule — not present in
  `decisions/`. If brief claim ("CLOSED per PR #214") is correct, retrieve
  artifact; otherwise open a fresh Travel Rule ADR in D3.2c.
- TODO: discover MLRO / DPO / Legal retroactive determination artifact for
  incident 2026-05-08 (referenced in §A.2 and §B.3).

---

## MISSING / TODO

| Target path                                                                  | Title                                                    | Anchor                                                  | Owner sprint |
|------------------------------------------------------------------------------|----------------------------------------------------------|---------------------------------------------------------|--------------|
| `docs/project/compliance/aml-programme-sop.md`                               | AML Programme SOP (MLR 2017 / AMLD6)                     | Backlog S13                                              | S13          |
| `docs/project/compliance/kyc-kyb-onboarding-sop.md`                          | KYC / KYB onboarding SOP                                 | Backlog S13 (PARTIAL today)                              | S13          |
| `docs/project/compliance/sysc-15a-operational-resilience.md`                 | FCA SYSC 4.1 operational resilience (renamed)             | Backlog S13                                              | S13          |
| `docs/project/compliance/mlr-2017-evidence-map.md`                           | MLR 2017 Reg 27/28 evidence map                          | Backlog S13                                              | S13          |
| `docs/project/compliance/cass-15-15-10-evidence.md`                          | CASS 15 §15.10 evidence (ADR-027)                        | Backlog S14                                              | S14          |
| `docs/project/compliance/kyc-fsm-transitions-evidence.md`                    | KYC FSM transitions evidence (ADR-028)                   | Backlog S15                                              | S15          |
| `docs/project/compliance/secrets-in-ci-scan-policy.md`                       | Secrets-in-CI scan policy (ADR-032 + gitleaks)           | Backlog S17                                              | S17          |
| `docs/project/compliance/abuse-escalation-policy.md`                         | Brute-force / abuse escalation (ADR-030)                 | Backlog S19                                              | S19          |
| `docs/project/compliance/safeguarding-fin060-procedure.md`                   | Safeguarding + FIN-060 procedure                         | Sprint S20 safeguarding                                  | S20          |
| `docs/project/compliance/mlro-signoff-ledger.md`                             | MLRO sign-off ledger                                     | Sprint S20.8 MLRO accountability                         | S20.8        |
| `docs/project/compliance/regulator-notification-sop.md`                      | Regulator-notification SOP (FCA / ICO / ECB)             | G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION, Backlog S25  | S25          |
| `docs/project/compliance/open-items-register.md`                             | Open-items register (PARTIAL/BLOCKED at S24)             | Backlog S24                                              | S24          |
| `docs/project/compliance/compliance-pack-v1-review-checklist.md`             | Compliance pack v1 review checklist                      | Backlog S13                                              | S13          |
| `docs/project/compliance/sanctions-match-adjudication.md`                    | Sanctions match adjudication (4-eye / MLRO)              | Sprint S13 (HITL link)                                   | S13          |
| `docs/project/compliance/sar-str-workflow.md`                                | SAR / STR workflow                                       | Sprint S20.8 MLRO accountability                         | S20.8        |
| `docs/project/compliance/aml-risk-assessment.md`                             | AML risk assessment (customer/product/geo/channel)        | Sprint S13                                               | S13          |
| `docs/project/compliance/gdpr-breach-notification-72h.md`                    | GDPR Art. 33 breach notification SOP                     | Sprint S21 / S25 (incident chain)                        | S21/S25      |
| `docs/project/compliance/gdpr-data-subject-rights.md`                        | GDPR Art. 15-22 data subject rights procedures           | Sprint S21                                               | S21          |
| `docs/project/compliance/travel-rule-fatf.md`                                | FATF Travel Rule (Crypto Block)                          | Sprint S21 — anchor ADR-036 TODO                         | S21          |

Each row remains MISSING until an authored document lands at the target path,
reviewed per the Definition of Done.

## Navigation

- ↑ [Master index](../PROJECT-DOCUMENTATION-MASTER-INDEX.md)
- → [Backlog S12–S25](../PROJECT-DOCUMENTATION-BACKLOG-S12-S25.md)
- → [ADR INDEX.md](../../adr/INDEX.md)
- ↔ Sibling domains:
  [architecture](../architecture/README.md) ·
  [api](../api/README.md) ·
  [runbooks](../runbooks/README.md) ·
  [security](../security/README.md) ·
  [data](../data/README.md) ·
  [operations](../operations/README.md) ·
  [governance](../governance/README.md)
