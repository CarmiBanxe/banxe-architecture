# Governance — Project Documentation (Layer 2)

Status: SKELETON (D2)
Sprint: D2 (2026-05-12)
Layer: 2 (Product Docs per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
Anchors: IL-PROJECT-DOCS-SPRINT-D1-BASELINE-2026-05-12, SMF1–SMF17 (FCA Senior
Managers Regime, Sprint S20), Board formation, Internal Audit, Quarterly
review (Sprint S25.4)

---

## Scope

In-scope topics for this domain:

- SMR (Senior Managers Regime) mapping — SMF1–SMF17 holders, allocation of
  Prescribed Responsibilities, Statements of Responsibilities (SoR).
- Board composition, board calendar, board pack template.
- MLRO governance — appointment, escalation, decision-record retention.
- DPO governance — appointment, communication channel with ICO.
- Internal Audit charter, plan, finding-tracker.
- Change-control policy — Architecture Review Board (ARB), exception handling.
- Quarterly review cadence (Sprint S25.4 anchor).
- Sign-off ledger (final cross-functional sign-off pre-go-live).

## Out of scope

- Compliance attestations and regulatory dossiers (lives under `../compliance/`).
- HITL gate POLICY mechanics (lives under `../operations/` / `HITL-MATRIX.yaml`).
- Source code (lives in `banxe-emi-stack/`).
- Factory-side governance (Layer 1; lives in `docs/canon/` for operator canon).
- Day-to-day on-call rotation (lives under `../operations/`).

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

- `docs/governance/branch-protection.md` — branch-protection policy (existing).
- `INSTRUCTION-LEDGER.md` (repo root) — instruction ledger (governance anchors;
  referenced only, not edited here).
- `MASTER-PLAN-2026-05-05.md` (repo root) — master plan (governance anchor;
  referenced only).
- `ROADMAP.md` (repo root) — factory roadmap (anchored from governance; not edited).
- `docs/canon/HW-MODEL-UPGRADE-matrix.md` — HW matrix (governance-controlled
  inventory; factory).

## MISSING / TODO

| Target path                                                              | Title                                                | Anchor                                                  | Owner sprint |
|--------------------------------------------------------------------------|------------------------------------------------------|---------------------------------------------------------|--------------|
| `docs/project/governance/smf-mapping.md`                                 | SMF1–SMF17 mapping + Statements of Responsibility    | Sprint S20 SMR                                           | S20          |
| `docs/project/governance/board-formation.md`                             | Board composition + calendar + pack template         | Sprint S20 Board formation                               | S20          |
| `docs/project/governance/mlro-governance.md`                             | MLRO governance (appointment + escalation)           | Sprint S20.8 MLRO                                        | S20.8        |
| `docs/project/governance/dpo-governance.md`                              | DPO governance (appointment + ICO channel)           | Sprint S21 GDPR DPO anchor                               | S21          |
| `docs/project/governance/internal-audit-charter.md`                      | Internal Audit charter + plan + finding tracker      | Sprint S22 IA charter                                    | S22          |
| `docs/project/governance/change-control-policy.md`                       | Change-control policy + ARB                          | Sprint S20 ARB / change-control                          | S20          |
| `docs/project/governance/quarterly-review-cadence.md`                    | Quarterly review cadence                             | Sprint S25.4 quarterly review                            | S25.4        |
| `docs/project/governance/signoff-ledger.md`                              | Cross-functional sign-off ledger (pre-go-live)       | Backlog S25 sign-off ledger                              | S25          |

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
  [data](../data/README.md) ·
  [operations](../operations/README.md)
