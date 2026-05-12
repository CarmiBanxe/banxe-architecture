# D3.2c — ADR Reconciliation Findings

Date: 2026-05-12 12:00 CEST
Sprint: D3.2c (diagnostic only; no structural changes executed here)
Executor: Central (per IL-CANON-DOCUMENTATION-OWNED-BY-CENTRAL-2026-05-12)
Pair-IL: IL-PROJECT-DOCS-SPRINT-D3-2C-ADR-RECONCILIATION-FINDINGS-2026-05-12 (pending)

## Background

Sprint D3.2b (compliance + security content expansion, commit 8c84370) raised 5 open questions about anchor consistency. Read-only diagnostic on Legion (mark-legion) 2026-05-12 11:55-12:00 CEST established the facts below. No file rename, renumbering, or restructure is performed in this audit doc.

## Finding 1 — ADR-019 / CASS-15 mismatch (Q1)

- `decisions/ADR-019-ai-guardian-two-family.md` (ACCEPTED, locked, 2026-05-03) is AI Guardian two-family architecture. NOT CASS 15.
- `decisions/ADR-027-audit-trail-durability.md` (ACCEPTED, 2026-05-09, 9755 B) is the correct CASS 15 / audit-trail-durability anchor.
- Compliance README §A.3 cites ADR-019 for CASS 15 — brief error inherited from D3.2b prompt.
- Resolution path (D3.2d): re-anchor CASS 15 / ClickHouse 5y retention citations to `decisions/ADR-027-audit-trail-durability.md`.

## Finding 2 — ADR-036 absent as decisions/ artifact (Q2)

- `decisions/ADR-036-*.md` does NOT exist.
- `docs/audit/adr-036-final-summary-2026-05-11.md` exists; PR #214 (commit 6fa8f52) recorded "Sprint 3 CANCELLED + ADR-036 CLOSED".
- ADR-036 (FATF Travel Rule) was CLOSED via audit document, not via decisions/ artifact.
- Resolution path (D3.2d): either treat audit doc + PR #214 as canonical anchor, OR open `decisions/ADR-036-travel-rule.md` summarizing the closed decision.

## Finding 3 — ADR-033 collision (Q3)

- `decisions/ADR-033-alert-routing-strategy.md` (Accepted 2026-05-11, closes G-OBS-01/02).
- `docs/adr/ADR-033-ufw-perimeter.md` (ACCEPTED 2026-05-03, ufw perimeter posture).
- Both real, both ACCEPTED, both numbered 033. Part of wider collision (Finding 6).

## Finding 4 — G-FACTORY-05 not in GAP-REGISTER.md (Q4)

- `GAP-REGISTER.md` (407+ lines, root of repo) contains G-FACTORY-02, G-FACTORY-04. NOT G-FACTORY-05.
- `docs/GAP-REGISTER.md` also exists (duplicate or alternate).
- G-FACTORY-05 (Legion :8180 logical collision with evo1 KC) referenced only in IL-OPS-S12-1-DONE-EVIDENCE-AND-NEW-GAPS-2026-05-12 (line 7938).
- Resolution path (D3.2d): add G-FACTORY-05 row to GAP-REGISTER.md using G-FACTORY-04 row as template.

## Finding 5 — S19.7 attribution invented (Q5)

- Searches in ROADMAP.md, MASTER-PLAN-2026-05-05.md, PROJECT-DOCUMENTATION-BACKLOG-S12-S25.md found NO "S19.7" occurrence.
- Vault adoption real anchors: G-SEC-02 (OPEN), Track F (partially-closed), Sprint S17 (per backlog row 279), DEFERRED status.
- "S19.7" in security README §C is invented anchor from D3.2b brief.
- Resolution path (D3.2d): replace "S19.7" with "Sprint S17 / G-SEC-02 / Track F" in security README.

## Finding 6 — STRUCTURAL: ADR dual-catalogue + 5 collisions

Two ADR catalogues coexist:

- `decisions/` — 36 files: ADR-001..035, ADR-038, ADR-074..076. Primary canonical catalogue.
- `docs/adr/` — 6 files: ADR-027, ADR-031..035. Created by Sprint D2 as Layer 2 catalogue.

Collisions (same number, different content, both real):

| ADR | decisions/                                    | docs/adr/                                       |
|-----|-----------------------------------------------|------------------------------------------------|
| 027 | audit-trail-durability                        | claude-code-permissions-reclassification        |
| 032 | secret-rotation-policy                        | glm45-air-distributed                           |
| 033 | alert-routing-strategy                        | ufw-perimeter                                   |
| 034 | webhook-reliability-kyc                       | aider-routes                                    |
| 035 | ci-smoke-gate-policy                          | ai-pool-roadmap-2026-05-11                      |

ADR INDEX.md scope: only covers 6 files in docs/adr/. 30 ADRs in decisions/ are invisible to INDEX.md.

## Required Central decisions before D3.2d / D3.3 reconciliation work

1. Which catalogue is canonical: `decisions/` (Layer 1 / factory, 36 files) or `docs/adr/` (Layer 2 / project, 6 files)?
2. Collision renumbering: rename which side of each pair? (e.g. docs/adr/ADR-033-ufw-perimeter → ADR-039 or ADR-077?)
3. ADR-036 canonical form: audit-doc-only OR backfill new decisions/ADR-036-travel-rule.md?
4. ADR INDEX.md scope: extend to cover both catalogues OR split into two INDEX files?
5. CANON-DOC-MANDATORY-TWO-LAYER application: Layer 1 ADRs should live where, Layer 2 ADRs where, what about cross-cutting ADRs?

## Risk if not resolved

- All Layer 2 docs (compliance/security/data/runbooks/...) that cite ADR numbers will inherit ambiguity.
- ADR INDEX.md remains incomplete (30 ADRs invisible).
- D3.2d / D3.3 / S12-S25 documentation will keep referencing wrong ADR with wrong content.
- Auditor cannot enforce ADR-pairing per IL-CANON-DOC-MANDATORY-TWO-LAYER if ADR identity is non-unique.

## Status

DIAGNOSTIC ONLY. No structural change in this audit doc. Pending Central + operator decision on 5 questions above to proceed with D3.2d execution.
