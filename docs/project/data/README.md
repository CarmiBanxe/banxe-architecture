# Data Governance — Project Documentation (Layer 2)

Status: SKELETON (D2)
Sprint: D2 (2026-05-12)
Layer: 2 (Product Docs per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
Anchors: IL-PROJECT-DOCS-SPRINT-D1-BASELINE-2026-05-12, GDPR Art. 30 RoPA
(Sprint S21), GDPR Art. 32 (security of processing), UK data residency,
ADR-029 backup / DR (data side), ClickHouse 5-year audit retention,
Sprint S14 audit-trail retention

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

## MISSING / TODO

| Target path                                                                  | Title                                                | Anchor                                                  | Owner sprint |
|------------------------------------------------------------------------------|------------------------------------------------------|---------------------------------------------------------|--------------|
| `docs/project/data-governance/gdpr-ropa.md`                                  | GDPR Art. 30 Record of Processing Activities         | Backlog S21 RoPA                                         | S21          |
| `docs/project/data-governance/data-flow-diagrams.md`                         | Data-flow diagrams per business process              | Backlog S21                                              | S21          |
| `docs/project/data-governance/retention-schedule.md`                         | Retention schedule per data class                    | Backlog S21; I-21 5-year audit retention                 | S21          |
| `docs/project/data-governance/erasure-procedure.md`                          | Right-to-erasure (GDPR Art. 17) procedure            | Backlog S21                                              | S21          |
| `docs/project/data-governance/cross-border-transfer-assessment.md`           | Cross-border transfer assessment                     | Backlog S21 BLOCKED (Track I — vendor contracts)         | S21          |
| `docs/project/data-governance/audit-trail-retention.md`                      | Audit-trail retention + erasure policy               | Backlog S14 audit-trail retention                        | S14          |
| `docs/project/data-governance/uk-data-residency-posture.md`                  | UK data residency posture + exceptions               | UK data residency anchor                                 | S21          |
| `docs/project/data-governance/data-lineage.md`                               | Data lineage (ingest → ledger → audit sink)          | I-24 append-only chain                                   | S21          |

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
  [compliance](../compliance/README.md) ·
  [security](../security/README.md) ·
  [operations](../operations/README.md) ·
  [governance](../governance/README.md)
