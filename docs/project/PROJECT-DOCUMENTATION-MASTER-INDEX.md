# BANXE EMI Bank — Project Documentation Master Index

**Status:** Sprint D1 baseline (initial publication)
**Owner:** CEO + CTIO (project documentation)
**Created:** 2026-05-12
**Programme horizon:** Sprint S12 → Sprint S25 (per [`PROJECT-DOCUMENTATION-BACKLOG-S12-S25.md`](./PROJECT-DOCUMENTATION-BACKLOG-S12-S25.md))

---

## 1. Purpose

This index is the single navigation entry-point for **BANXE EMI Bank project implementation
documentation**. It maps the documentation programme from current state through to FCA-EMI
go-live, marks coverage status against eight delivery domains, and points at the sprint-by-sprint
backlog that drives execution.

The index is the read-first artifact for:

- New engineers onboarding to the bank project
- External auditors / MLRO / DPO / Legal reviewing project assurance
- Operator-side go-live readiness assessment
- Track-leads ensuring their domain documentation is complete

## 2. Scope and bounded context

This index covers **project implementation documentation only** — the artifacts that describe
how the BANXE EMI Bank product is built, operated, secured, and brought into FCA-regulated
production.

### 2.1 In scope (project documentation layer)

- Architecture decisions and reference designs (`docs/adr/`, `docs/master-document/`)
- Infrastructure inventories and topology (`docs/PLANES.md`, infrastructure runbooks)
- IAM and security model (`PRIVILEGE-MODEL.md`, KC realm docs, secret-rotation runbooks)
- Compliance and regulatory pack (`docs/compliance/`, `COMPLIANCE-ARCH.md`, `SANCTIONS-POLICY.md`)
- Operations and runbooks (`docs/runbooks/`, `docs/ops/`)
- Testing and QA strategy (test plans, coverage targets, traceability matrices)
- Data governance and privacy (`docs/privacy/`, GDPR ROPA, retention)
- Go-live readiness pack (BCP/DR, regulator notification SOPs, ops handover)

### 2.2 Out of scope (factory / process canon — DO NOT add here)

The following authority artifacts live elsewhere and are **explicitly excluded** from the
project documentation programme:

- **Factory / operator-terminal process canon** — owned by `docs/canon/`, `ROADMAP.md`,
  `INSTRUCTION-LEDGER.md`, `GAP-REGISTER.md` at repository root.
- **Sub-terminal interaction rules, IL/GAP authoring conventions, two-loop mirror
  protocol** — owned by `docs/canon/SESSION-CANON-2026-05-11.md`, `AGENTS.md`, `CLAUDE.md`.
- **Incident dossiers (V-XMRIG, etc.)** — owned by `docs/incidents/`.

If a contributor is tempted to file a process or operator-canon rule under `docs/project/`,
the right home is `docs/canon/` instead. Project docs describe **the bank product**;
factory canon describes **how the bank is built**.

## 3. Definition of "100 % project documentation"

A project is considered to have 100 % documentation coverage when **every domain in the
table below shows DONE for every deliverable required by the regulatory and operational
go-live readiness pack** (Sprint S24/S25 of the backlog).

A deliverable is DONE when **all four** of the following are true:

1. Document exists at a stable canonical path under `docs/project/` or a domain folder.
2. Document has named owner, version, and last-reviewed date in its header.
3. Document has been reviewed by the relevant track-lead and reflects current production
   reality (no stale architectural references, no removed services, no unmerged ADRs).
4. Document is reachable from this index in two hops or fewer (index → backlog → doc, or
   index → domain table → doc).

## 4. Coverage status legend

Every deliverable in this index and in the backlog is tagged with exactly one status:

| Tag       | Meaning                                                                         |
|-----------|---------------------------------------------------------------------------------|
| DONE      | Exists, owned, current, reachable from this index. Requires no further action.  |
| PARTIAL   | Exists but incomplete — a section, an example, or a domain is missing.          |
| MISSING   | Required by go-live but not yet authored.                                       |
| BLOCKED   | Authoring blocked on an external dependency (operator, MLRO, vendor contract).  |
| DEFERRED  | Explicitly postponed past go-live. Carries an IL anchor justifying deferral.    |

## 5. Domain coverage table (Sprint D1 baseline)

The eight domains form the rows; the columns show what already exists in the repository
versus what is required by the S12–S25 backlog. Statuses reflect Sprint D1 baseline
publication on 2026-05-12 and will be re-asserted at the close of each sprint.

| Domain                       | Existing artifacts (samples)                                                                                       | Sprint D1 status |
|------------------------------|--------------------------------------------------------------------------------------------------------------------|------------------|
| Architecture                 | `docs/master-document/01-master-full.md`, `docs/adr/` (ADR-027/028/029/030/032/033/034/035), `docs/PLANES.md`      | PARTIAL          |
| Infrastructure               | `docs/canon/HW-MODEL-UPGRADE-matrix.md`, `docs/runbooks/legion-do-not-do.md`, partial topology in master-document  | PARTIAL          |
| IAM / Security               | `PRIVILEGE-MODEL.md`, `INVARIANTS.md`, ADR-030 (rate-limit), ADR-032 (secret rotation)                             | PARTIAL          |
| Compliance / Regulatory      | `COMPLIANCE-ARCH.md`, `SANCTIONS-POLICY.md`, `docs/compliance/`, `docs/policies/`, GAP-REGISTER (factory mirror)   | PARTIAL          |
| Operations / Runbooks        | `docs/runbooks/`, `docs/ops/`, `docs/runbooks/hitl-decision-recording.md`                                          | PARTIAL          |
| Testing / QA                 | (Test strategy doc not yet under `docs/project/`)                                                                   | MISSING          |
| Data governance              | `docs/privacy/`, `docs/governance/`, `docs/compliance/ai-data-flow.md`                                             | PARTIAL          |
| Go-live readiness            | (No consolidated go-live dossier yet — assembled in S24/S25)                                                        | MISSING          |

PARTIAL entries are unpacked deliverable-by-deliverable in the [backlog](./PROJECT-DOCUMENTATION-BACKLOG-S12-S25.md).

## 6. Sprint horizon

| Sprint | Phase anchor (canon ROADMAP)                              | Documentation theme                                           |
|--------|-----------------------------------------------------------|---------------------------------------------------------------|
| S12    | Phase F7 — Production transition (canonical)              | Go-live readiness baseline, architecture freeze               |
| S13    | F7 (extension — defined by this programme)                | Compliance / regulatory pack v1                               |
| S14    | F7 (extension — defined by this programme)                | Audit-trail durability dossier (ADR-027 / CASS 15 §15.10)     |
| S15    | F7 (extension — defined by this programme)                | Webhook reliability + KYC integration ops doc (ADR-034)       |
| S16    | F7 (extension — defined by this programme)                | Alert routing + observability ops doc (ADR-033)               |
| S17    | F7 (extension — defined by this programme)                | Secrets rotation + IAM hardening (ADR-032)                    |
| S18    | F7 (extension — defined by this programme)                | Postgres backup + restore drill (ADR-029)                     |
| S19    | F7 (extension — defined by this programme)                | Auth rate-limit + abuse policies (ADR-030)                    |
| S20    | F7 (extension — defined by this programme)                | CI smoke-gate + change management (ADR-035)                   |
| S21    | F7 (extension — defined by this programme)                | Data governance, GDPR ROPA, retention                         |
| S22    | F7 (extension — defined by this programme)                | Testing / QA programme + traceability matrix                  |
| S23    | F7 (extension — defined by this programme)                | Operations / runbooks consolidation                           |
| S24    | F7 (extension — defined by this programme)                | Pre-go-live audit pack (MLRO / DPO / Legal sign-off bundle)   |
| S25    | F7 close — Go-live                                        | Go-live + post-go-live handover dossier (BCP / DR / handover) |

> **Note on canon provenance.** The canonical `ROADMAP.md` defines Sprints S1–S12 with
> S12 = Phase F7 production transition. S13–S25 are introduced **here** as project-documentation
> sprints under (and beyond) Phase F7. They are scoped by this index and the linked backlog;
> they do not amend factory canon.

## 7. Where existing documentation already lives

| Area                          | Path                                              | Notes                                                              |
|-------------------------------|---------------------------------------------------|--------------------------------------------------------------------|
| Master architecture           | `docs/master-document/`                           | High-level project architecture, EMI functional periphery (RU)     |
| Architecture decision records | `docs/adr/`                                       | ADR-027 through ADR-035 accepted; new ADRs added per programme     |
| Compliance & policies         | `docs/compliance/`, `docs/policies/`              | AML/KYC, sanctions, HITL gates                                     |
| Privacy & governance          | `docs/privacy/`, `docs/governance/`               | GDPR-relevant artifacts                                            |
| Runbooks & ops                | `docs/runbooks/`, `docs/ops/`                     | Operational procedures                                             |
| Audit & incidents             | `docs/audit/`, `docs/incidents/`                  | Audit trail, incident dossiers                                     |
| Inventories                   | `docs/inventories/`                               | Asset / service inventories                                        |
| Diagrams                      | `docs/diagrams/`                                  | Architecture diagrams                                              |
| Project-programme docs        | `docs/project/` *(this index, the backlog)*       | Programme-level navigation and sprint backlog                      |

## 8. Approval flow

A new or revised project-documentation deliverable is published when:

1. Authored under the correct domain folder (or under `docs/project/` for programme docs).
2. Reviewed by the relevant track-lead (architecture, IAM, compliance, ops, etc.).
3. Status row updated in the backlog (`PROJECT-DOCUMENTATION-BACKLOG-S12-S25.md`).
4. Linked from this index if it is a top-level deliverable.

## 9. Change log

| Date       | Change                                                          | Sprint |
|------------|-----------------------------------------------------------------|--------|
| 2026-05-12 | Sprint D1 — initial publication of master index + S12-S25 backlog | D1     |
