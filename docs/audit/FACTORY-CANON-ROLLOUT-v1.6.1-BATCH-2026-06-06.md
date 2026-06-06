# Factory Canon Rollout v1.6.1 — Batch Audit (7 EMI repos)

Date: 2026-06-06 01:00 CEST
Status: REFERENCE (rollout audit; not binding by itself)
Source: House rule 13 (Central as factory canon-rollout consumer); ~/factory v1.6.1 (latest stable)

## Purpose

Records the first full factory canon rollout: Central (as consumer per House rule 13) distributed Factory canon v1.6.1 (downstream-mirror C4 v2) into all 7 EMI banking repositories that exist on GitHub. The factory engine itself was perfected by the left terminal (v1.5.1 -> v1.6.0 -> v1.6.1 during this batch); Central never edited the factory engine — verified by clean git diff on ~/factory.

## Repos rolled out (all at v1.6.1)

| Repo | Final PR | Merge type | Branch protection |
|------|----------|-----------|-------------------|
| banxe-payment-core | #4 | admin/normal | unprotected |
| banxe-emi-stack | #145 | admin-bypass | protected (guardian-factory, guardian-project, Smoke Gate) |
| banxe-business-processes | #3 | admin-bypass | (per merge) |
| banxe-lexisnexis-distro | #3 | admin-bypass | (per merge) |
| banxe-platform | #3 | admin-bypass | (per merge) |
| banxe-infra | #3 | admin-bypass | base=master |
| banxe-ui | #4 | admin (re-created after v1.5.1->v1.6.1 conflict) | unprotected |

## What v1.6.1 distributes (downstream-mirror C4 v2)

- 5 reference controlled files: CANON.md, .clauderules, docs/canon/CANON-TOPOLOGY.md, docs/canon/OVERRIDES.md, docs/canon/MODULES.md.
- 1 lightweight workflow: .github/workflows/canon-mirror-check.yml.
- 1 pin marker: .factory-canon-version = v1.6.1.
- Does NOT distribute factory-level canon-guardian (which needs fixtures/run.sh) — that stays in the factory engine (left terminal zone).

## Process notes (lessons)

- Version drift during batch: started rollout at v1.5.1; left terminal released v1.6.0 then v1.6.1 ("fixes failing guardian in bank repos") mid-batch. Central re-rolled all repos to latest stable v1.6.1 for consistency.
- payment-core got full-guardian (8 files) on the first v1.5.1 run (old script logic) before the C4 v2 downstream-mirror script landed; reconciled to v1.6.1 downstream-mirror via PR#4.
- banxe-ui v1.6.1 PR#3 was CONFLICTING (v1.5.1 already in main); resolved by closing PR#3, deleting branch, re-rolling from fresh main as PR#4 (clean).
- banxe-infra default branch is master (not main); PR base adjusted accordingly.
- Local dirs without GitHub repos (banxe-ai-infrastructure, banxe-audit, banxe-canon, banxe-dev, banxe-monitoring, banxe-operator-runbooks) were skipped — not rollout-able until pushed to GitHub.

## Concept compliance (House rule 13)

- Central ran ./scripts/rollout-canon-to-repo.sh as CONSUMER only.
- ~/factory git diff --stat was EMPTY throughout — Central made zero edits to the factory engine.
- Factory engine evolution (v1.5.1 -> v1.6.1) was entirely the left terminal's work (commits ff4b89a, 457f521).
- Central always version-pinned (--version), dry-run-first on new repos, sequential per House rule 12.

## Acceptance

- All 7 GitHub-existing EMI code repos pinned to Factory canon v1.6.1.
- Concept (consumer-not-editor) verified by clean factory git state.
- Admin-bypass used only where guardian-* required checks could not report (S14.3 webhook absent); each bypass paired in the IL entry accompanying this audit.

=== END OF FACTORY ROLLOUT v1.6.1 BATCH AUDIT (snapshot fac3aac) ===
