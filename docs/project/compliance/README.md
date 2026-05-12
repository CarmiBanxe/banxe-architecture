# Compliance & Regulatory — Project Documentation (Layer 2)

Status: CONTENT-PARTIAL (D3.2a — sub-domains scaffolded; full CONTENT pending in D3.2b)
Sprint: D2 (2026-05-12)
Layer: 2 (Product Docs per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
Anchors: IL-PROJECT-DOCS-SPRINT-D1-BASELINE-2026-05-12,
FCA SUP 15 / CASS 15 / SYSC 15A, GDPR Art. 30 RoPA, AMLR / AMLD6,
Safeguarding (Sprint S20), MLRO (Sprint S20.8),
G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION, Sprint S13–S25

---

## Scope

In-scope topics for this domain (regulatory sub-anchors):

- **FCA SUP 15** — supervisory notifications, periodic returns, reportable events.
- **FCA CASS 15** (Client Asset Sourcebook) — safeguarding evidence dossier, with
  particular focus on **CASS 15 §15.10** audit-trail durability (ADR-027 anchor).
- **FCA SYSC 15A** — operational resilience plan, important business services,
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
- Architectural ADRs themselves (lives under `../architecture/` / `docs/adr/`).
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

## MISSING / TODO

| Target path                                                                  | Title                                                    | Anchor                                                  | Owner sprint |
|------------------------------------------------------------------------------|----------------------------------------------------------|---------------------------------------------------------|--------------|
| `docs/project/compliance/aml-programme-sop.md`                               | AML Programme SOP (MLR 2017 / AMLD6)                     | Backlog S13                                              | S13          |
| `docs/project/compliance/kyc-kyb-onboarding-sop.md`                          | KYC / KYB onboarding SOP                                 | Backlog S13 (PARTIAL today)                              | S13          |
| `docs/project/compliance/sysc-15a-operational-resilience.md`                 | FCA SYSC 15A operational resilience                      | Backlog S13                                              | S13          |
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
