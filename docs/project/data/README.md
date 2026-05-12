# Data Governance — Project Documentation (Layer 2)

Status: CONTENT (D3.3.4 — full sub-domain content landed)
Sprint: D3.3.4 (2026-05-12)
Layer: 2 (Product Docs per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
Anchors: IL-PROJECT-DOCS-SPRINT-D1-BASELINE-2026-05-12,
IL-PROJECT-DOCS-SPRINT-D3-3-1-ARCHITECTURE-CONTENT-2026-05-12 (Layer-2 peer),
IL-PROJECT-DOCS-SPRINT-D3-3-2-API-CONTENT-2026-05-12 (Layer-2 peer),
IL-PROJECT-DOCS-SPRINT-D3-3-3-RUNBOOKS-CONTENT-2026-05-12 (Layer-2 peer),
IL-OPS-S12-1-DONE-EVIDENCE-AND-NEW-GAPS-2026-05-12,
ADR-013 (Midaz CBS — ledger data home),
ADR-014 (composable financial stack), ADR-015 (payment processing stack),
ADR-016 (AI plane / PII-AML routing),
ADR-027 (audit-trail durability — ClickHouse Guardian 5y, CASS 15),
ADR-028 (KYC re-verification triggers),
ADR-029 (Postgres backup strategy),
ADR-036 (FATF Travel Rule — deferred S21),
G-IAM-09 (KC backup gap — prep landed in banxe-emi-stack PR #134),
GDPR Art. 30 / 32 / 33 / 15-22, AMLR 2017, FCA SUP / SYSC, CASS 15 §15.10,
UK data residency, Sprint S14, S16.4, S18, S21, S25

---

## Scope

In-scope topics for this domain:

- Data models — customer data, transactional data, audit records, PII boundaries.
- Retention schedule per data class (ClickHouse 5-year audit retention is the
  load-bearing anchor for CASS 15-aligned events).
- Data lineage — flow from ingest (HTTP / webhook) through ledger (Midaz) to
  audit sink (BufferedAuditPort → ClickHouse).
- GDPR Art. 30 RoPA — authoritative RoPA for the bank perimeter.
- GDPR Art. 32 — security of processing controls cross-reference.
- Right-to-erasure (GDPR Art. 17) procedure.
- Cross-border transfer assessment (third-country processors).
- UK data residency posture and exception handling.

> Naming convention: backlog rows target `docs/project/data-governance/...`.
> This README's canonical path is `data/` per the master-index 8-domain table.
> New documents land under `data/` and target paths will be reconciled in D3+.
>
> Note on `.gitignore`: the repo root carries a `data/` rule (line 5) which
> matches `docs/project/data/` as well as legacy `data/` artefact paths. Files
> under this domain MUST be staged with `git add -f` per the D2 precedent
> (OI-2 carry-forward). The auditor accepts force-add for this domain only.

## Out of scope

- Compliance attestations + regulator-facing dossiers (lives under `../compliance/`).
- Implementation source code that handles data (lives in `banxe-emi-stack/`).
- Architectural rationale for data planes (lives under `../architecture/`).
- Operational drain / restore runbooks (lives under `../operations/`).

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

- `docs/privacy/customer-privacy-right-v2.md` — customer privacy rights.
- `docs/privacy/ghost-mode-spec.md` — ghost-mode spec.
- `docs/compliance/ai-data-flow.md` — AI data flow (PARTIAL).
- `docs/governance/branch-protection.md` — branch-protection (data-change governance).
- `INVARIANTS.md` (repo root) — bank invariants (I-21 5-year retention,
  I-24 append-only audit, etc.).
- `decisions/ADR-013-midaz-cbs-primary.md` — Midaz as the ledger data home.
- `decisions/ADR-027-audit-trail-durability.md` — audit-trail durability (CASS 15).
- `decisions/ADR-029-postgres-backup-strategy.md` — Postgres backup strategy.

---

## A. Data model overview

The five data classes anchor every project-side data discussion. Each class
carries different retention, classification, and processing controls (see
§B-§D).

### A.1 Customer (KYC) data

- Identity (name, DoB, government ID), contact (email, phone, address), and
  current **KYC status** per the FSM transitions defined in
  [decisions/ADR-028-kyc-reverification-triggers.md](../../decisions/ADR-028-kyc-reverification-triggers.md).
- SumSub verification artefacts (applicant ID, review status, document
  attachments) — stored alongside the customer record; access bounded by
  ADR-016 PII-routing rules (see §B).
- Re-verification events: `ROLE_CHANGED`, `BENEFICIAL_OWNER_CHANGED`,
  `JURISDICTION_CHANGED` (per ADR-028).

### A.2 Financial data

- **E-money balances** — outstanding e-money per customer (safeguarding
  obligation, see §A.5 audit + §E backup).
- **Transactions** — payment events through Hyperswitch + Paymentology
  ([decisions/ADR-015-payment-processing-stack.md](../../decisions/ADR-015-payment-processing-stack.md)).
- **Safeguarding reconciliation runs** — daily D-recon outputs per Sprint
  S16.4; break records, threshold breaches, MLRO co-sign artefacts.
- **Midaz ledger entries** — primary CBS records per
  [decisions/ADR-013-midaz-cbs-primary.md](../../decisions/ADR-013-midaz-cbs-primary.md).
- **Payment events** — per-route audit emission (cross-link
  `../api/README.md` §F.2 for the 429 audit emission contract).

### A.3 Compliance data

- SAR / STR records (NCA-bound; restricted access).
- Sanctions hits (OFSI / EU / UN list matches + adjudication state).
- AML risk scores (customer-risk model, transaction-risk model).
- MLRO sign-offs (counter-signed compliance decisions; HITL-MATRIX entries).

### A.4 Audit data

- Authoritative anchor:
  [decisions/ADR-027-audit-trail-durability.md](../../decisions/ADR-027-audit-trail-durability.md)
  — `BufferedAuditPort` (append-only, I-24 invariant) feeding ClickHouse
  Guardian.
- 5-year retention horizon per CASS 15 §15.10.
- Cross-link: `../compliance/README.md` §A.3 for the regulatory mapping;
  `../architecture/README.md` §C for the architectural pattern.

### A.5 Crypto data (Sprint S21 future)

- Travel-Rule originator + beneficiary info per
  [decisions/ADR-036-travel-rule.md](../../decisions/ADR-036-travel-rule.md)
  (Status: Closed 2026-05-11; **implementation deferred to Sprint S21
  Crypto Block**). Schema and retention covered in S21.

---

## B. Data classification & sensitivity

### B.1 Classification tiers

- **PII** — customer identity, KYC documents, transaction beneficiary
  data. Routing constraint: must terminate inside the trusted plane per
  [decisions/ADR-016-ai-plane-pii-aml-routing.md](../../decisions/ADR-016-ai-plane-pii-aml-routing.md).
- **Financial** — balances, payment instructions, settlement records.
  Encryption at rest mandatory; access scoped to relevant service.
- **Audit** — immutable, retention-bound. Append-only contract enforced
  by `BufferedAuditPort` (ADR-027 anchor).
- **Compliance internal** — SAR / STR, sanctions adjudication; restricted
  to MLRO / DPO / Legal roles.
- **Operational** — health metrics, infra telemetry; no PII, looser
  retention.

### B.2 Classification matrix — TODO

- Target: `docs/project/data/data-classification-matrix.md` (MISSING).
- Owner sprint: **S21** (alongside RoPA work).
- Matrix axes: data class × storage location × encryption × access role ×
  retention bucket.

---

## C. GDPR / UK DPA

### C.1 Art. 30 — Record of Processing Activities (RoPA)

- Target: `docs/project/data/gdpr-ropa.md` (MISSING — D3.x backfill;
  owner sprint **S21**).
- Required fields: processor name, lawful basis, data classes, retention,
  cross-border transfer mechanism, technical + organisational measures.
- Cross-link: `../compliance/README.md` §B.1 for the compliance-side
  attestation cross-reference.

### C.2 Art. 32 — Security of processing

- Cross-link to `../security/README.md` for the technical measures
  catalogue (threat model, secret rotation under ADR-032, KC IAM,
  perimeter posture).
- Vault adoption (long-term key management) is DEFERRED — Sprint S17 /
  G-SEC-02 / Track F (see security README §C).

### C.3 Art. 33 — Personal-data breach notification (72 h)

- Cross-link to `../compliance/README.md` §B.3 + the MISSING target
  `docs/project/compliance/gdpr-breach-notification-72h.md` (owner sprint
  **S21 / S25**).
- Detection-side responsibility (data-layer): emit a structured
  `PII_BREACH_DETECTED` audit event via ADR-027 buffered port; downstream
  procedure lives under compliance.

### C.4 Art. 15-22 — Data subject rights

- Target: `docs/project/data/data-subject-rights-procedure.md` (MISSING).
- Covered rights: access (Art. 15), rectification (Art. 16), erasure
  (Art. 17), restriction (Art. 18), portability (Art. 20), objection
  (Art. 21), automated decision-making (Art. 22).
- Owner sprint: **S21** alongside the Art. 30 RoPA work.

### C.5 Cross-border transfer assessment

- Target: `docs/project/data/cross-border-transfer-assessment.md`
  (**BLOCKED** per backlog D3.1; UK-EU adequacy + SCCs / IDTA decisions
  pending Legal confirmation of third-country processors).
- Required for Chapter V transfers (UK GDPR / EU GDPR adequacy + SCCs /
  IDTA).
- Status stays BLOCKED until the operator-confirmed vendor list lands;
  see §G.2 for the current third-country processor inventory.

---

## D. Retention schedule

### D.1 Retention by class

| Class                           | Retention                | Authority                                                  | Status                          |
|---------------------------------|--------------------------|------------------------------------------------------------|---------------------------------|
| KYC records                     | 5 years (post-closure)   | AMLR 2017 / MLR 2017                                       | TODO — confirm with MLRO        |
| Audit trail                     | 5 years                  | ADR-027 (CASS 15 §15.10), FCA SUP                          | DONE (Track D closure)          |
| Transactions                    | 6 years                  | FCA SYSC record-keeping                                    | TODO — confirm horizon          |
| Customer data on closure        | per Art. 5(1)(e) GDPR    | UK GDPR storage limitation                                 | TODO — define schedule          |
| Compliance (SAR/STR)            | 5 years                  | MLR 2017 Reg. 40                                           | TODO — confirm with MLRO        |
| Operational telemetry           | 90 days (typical)        | Operator decision                                          | TODO — finalise per service     |

### D.2 Master retention schedule — MISSING

- Target: `docs/project/data/retention-schedule.md` (MISSING).
- Owner sprint: **S21**.
- Codifies the D.1 table, named owners, review cadence, and the
  pre-closure / post-closure timeline per data class.

### D.3 Storage-limitation principle

Art. 5(1)(e) UK GDPR requires that personal data is kept "no longer than
necessary". Implementation discipline (until the retention-schedule doc
lands):

- Audit data is **append-only** and time-bound (5 y TTL in ClickHouse
  Guardian) — implemented.
- Customer data follows the per-class schedule above — TODO.
- Erasure procedure (see §C.4) is the deletion path for the
  GDPR Art. 17 case; the retention-schedule doc names automatic-deletion
  triggers for the storage-limitation case.

---

## E. Backup & recovery

### E.1 Postgres backup strategy

- Authoritative ADR:
  [decisions/ADR-029-postgres-backup-strategy.md](../../decisions/ADR-029-postgres-backup-strategy.md)
  (ACCEPTED 2026-05-10). Implementation chain on banxe-emi-stack covers
  base backup, WAL archiving, restore-drill port, offsite upload port +
  InMemory adapter, backup-chain smoke tests.
- Frequency, encryption, off-host pattern: per the ADR + per-service
  amendment in the operational runbook target
  `docs/project/operations/postgres-backup-runbook.md` (MISSING; owner
  sprint **S18**).

### E.2 Keycloak DB backup

- **G-IAM-09** — KC backup gap. **Prep landed** in banxe-emi-stack
  PR **#134** (29/29 PASS — cross-repo evidence; not in this docs repo).
- Production deploy of the KC backup procedure is **HITL-gated** — Sprint
  S12.6 fix + operator sign-off.
- Restore drill cadence: **monthly** target (G-IAM-09 follow-up). First
  drill operator-signed; cadence enforced via cron + audit emission per
  ADR-027.

### E.3 ClickHouse audit DB backup

- **TODO** — confirm backup strategy for the ClickHouse Guardian audit
  store. Options:
  - Extend ADR-029 to cover ClickHouse (single backup ADR, two engines),
    or
  - Open a fresh ADR specific to ClickHouse audit-store backup (different
    durability profile — append-only, 5y retention, large volume).
- Audit-store loss is a CASS 15 §15.10 breach; backup posture must close
  before any audit-store change-management window. Owner sprint **S18**
  alongside the Postgres dossier.

### E.4 Restore drill cadence

- Monthly cadence per E.2 (KC). Quarterly drill across all stores
  (Postgres + ClickHouse + KC export) target — Sprint **S18**.
- Drill validation: `RUNBOOK_ROLLBACK_EXECUTED` or
  `RESTORE_DRILL_EXECUTED` audit event per ADR-027.
- Drill target runbooks: `docs/project/operations/postgres-restore-drill-runbook.md`
  (MISSING; **S18**) and `docs/project/operations/restore-drill-runbook.md`
  (MISSING; G-IAM-09 follow-up; **S12.6**).

---

## F. Data lineage & flow

### F.1 Inter-service flow

Per the composable financial stack
([decisions/ADR-014-composable-financial-stack.md](../../decisions/ADR-014-composable-financial-stack.md)),
each service owns its data; cross-service data crosses port-and-adapter
boundaries with explicit contracts.

- **Payment processing** — Hyperswitch + Paymentology stack per ADR-015;
  payment events flow from gateway → service → Midaz ledger → audit sink.
- **Ledger** — Midaz CBS per ADR-013 is the primary system of record for
  account balances and journal entries.
- **AI-plane routing** — PII / AML payloads routed per ADR-016 inside the
  trusted plane (see §B.1).

### F.2 Per-process diagrams — MISSING

- Target: `docs/project/data/data-flow-diagrams.md` (MISSING; owner
  sprint **S21**).
- Required diagrams: KYC onboarding (SumSub ingest → KYC FSM → ledger
  ready), payment processing (gateway → Hyperswitch → Midaz → audit),
  reconciliation (Midaz balances + safeguarding-bank balances → break
  detection → MLRO co-sign), SAR/STR (compliance trigger → MLRO sign-off
  → NCA submission), audit emission (any service event → BufferedAuditPort
  → ClickHouse Guardian).

### F.3 Audit-emission chain (visible from data side)

Every privileged state transition emits via the `BufferedAuditPort`
contract (ADR-027 anchor). Failure surface: ERROR-level log on
dual-failure path (verified by G-CASS-02 E2E tests — see compliance
README §A.3). The data-side responsibility is **timely emission**; the
buffer + drain mechanism is the durability contract.

---

## G. UK data residency

### G.1 Primary residency

- **Primary data hosted in the UK** per FCA EMI authorisation requirement.
- Production hosts: **evo1** (UK-based) and **Legion** (UK-based mark).
- TODO: confirm Tailscale topology UK-routing (whether any control-plane
  traffic transits a non-UK exit node). Owner sprint **S21** alongside
  the cross-border transfer assessment.

### G.2 Third-country / vendor data processors

Current third-country processor inventory (data-side view; full SCC /
IDTA matrix lives in `docs/project/data/cross-border-transfer-assessment.md`
when it lands):

| Processor    | Country / region    | Adequacy basis                          | Status                |
|--------------|---------------------|-----------------------------------------|-----------------------|
| Modulr       | UK                  | Domestic                                | OK                    |
| SumSub       | UK                  | Domestic                                | OK                    |
| Sardine.ai   | US                  | DPF Art. 45 adequacy                    | TODO — confirm in S21 |
| Marble       | TBD                 | TBD                                     | TODO — onboarding TBD |
| Telegram     | TBD (multi-region)  | TBD                                     | TODO — alert path only|

The Sardine.ai integration scheduled for **Sprint S20.4** (cross-link
`../compliance/README.md` §C.2) carries a third-country transfer; its
adequacy basis must be confirmed before go-live.

### G.3 Cross-border transfer assessment

- Status: **OPEN / BLOCKED** in the backlog (D3.1 carry-forward; awaits
  the operator-confirmed list of third-country processors with active
  contracts).
- Target: `docs/project/data/cross-border-transfer-assessment.md`
  (MISSING). Owner sprint **S21**.

---

## H. Open gaps for D3.3.5+

Data-domain MISSING target files queued for creation in later D3.3.x
sub-sprints or owner backlog sprints. Each row carries an owner sprint.

- `docs/project/data/gdpr-ropa.md` — GDPR Art. 30 RoPA (owner sprint
  **S21**).
- `docs/project/data/data-subject-rights-procedure.md` — Art. 15-22
  procedures (S21).
- `docs/project/data/data-classification-matrix.md` — classification
  matrix (S21).
- `docs/project/data/retention-schedule.md` — master retention schedule
  per data class (S21).
- `docs/project/data/data-flow-diagrams.md` — per-process diagrams
  (S21).
- `docs/project/data/cross-border-transfer-assessment.md` — cross-border
  transfer assessment (**BLOCKED** per backlog D3.1; S21).
- `docs/project/data/audit-trail-retention.md` — audit-trail retention +
  erasure policy (S14 audit-trail dossier).
- `docs/project/data/erasure-procedure.md` — right-to-erasure (Art. 17)
  procedure (S21).

### Carried-forward (not data-specific but visible here)

- **20 UNKNOWN-status ADRs** — `**Status:**` backfill queued per
  IL-PROJECT-DOCS-SPRINT-D3-2D-3-ADR-INDEX-UNIFIED-2026-05-12.
- **G-IAM-09** — KC backup gap; prep in banxe-emi-stack PR #134
  (29/29 PASS); production deploy HITL-gated; first restore drill
  operator-signed.
- **ClickHouse audit DB backup strategy TBD** (see §E.3); owner sprint
  **S18** alongside the Postgres dossier.
- **`.gitignore` data/ rule (OI-2)** — root `.gitignore` line 5 matches
  `docs/project/data/`; new files in this domain require `git add -f`.
  Carried since D2; reconciliation is a Sprint D3.3.5 / D3.4 housekeeping
  candidate.

---

## MISSING / TODO

| Target path                                                                  | Title                                                | Anchor                                                  | Owner sprint |
|------------------------------------------------------------------------------|------------------------------------------------------|---------------------------------------------------------|--------------|
| `docs/project/data/gdpr-ropa.md`                                             | GDPR Art. 30 Record of Processing Activities         | Backlog S21 RoPA                                         | S21          |
| `docs/project/data/data-flow-diagrams.md`                                    | Data-flow diagrams per business process              | Backlog S21                                              | S21          |
| `docs/project/data/retention-schedule.md`                                    | Retention schedule per data class                    | Backlog S21; I-21 5-year audit retention                 | S21          |
| `docs/project/data/erasure-procedure.md`                                     | Right-to-erasure (GDPR Art. 17) procedure            | Backlog S21                                              | S21          |
| `docs/project/data/cross-border-transfer-assessment.md`                      | Cross-border transfer assessment                     | Backlog S21 BLOCKED (Track I — vendor contracts)         | S21          |
| `docs/project/data/audit-trail-retention.md`                                 | Audit-trail retention + erasure policy               | Backlog S14 audit-trail retention                        | S14          |
| `docs/project/data/uk-data-residency-posture.md`                             | UK data residency posture + exceptions               | UK data residency anchor                                 | S21          |
| `docs/project/data/data-lineage.md`                                          | Data lineage (ingest → ledger → audit sink)          | I-24 append-only chain                                   | S21          |
| `docs/project/data/data-classification-matrix.md`                            | Data classification matrix                           | Backlog S21                                              | S21          |
| `docs/project/data/data-subject-rights-procedure.md`                         | GDPR Art. 15-22 data subject rights procedures       | Backlog S21                                              | S21          |

Each row remains MISSING until an authored document lands at the target path,
reviewed per the Definition of Done.

## Navigation

- ↑ [Master index](../PROJECT-DOCUMENTATION-MASTER-INDEX.md)
- → [Backlog S12–S25](../PROJECT-DOCUMENTATION-BACKLOG-S12-S25.md)
- → [ADR INDEX.md (unified)](../../adr/INDEX.md)
- ↔ Sibling domains:
  [architecture](../architecture/README.md) ·
  [api](../api/README.md) ·
  [runbooks](../runbooks/README.md) ·
  [compliance](../compliance/README.md) ·
  [security](../security/README.md) ·
  [operations](../operations/README.md) ·
  [governance](../governance/README.md)
