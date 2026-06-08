# Intent-First Repo Audit Matrix — 2026-06-09

> Companion machine-readable matrix to the IL-152 conformity audit — see [`docs/audit/intent-first-conformity-audit-2026-06-08.md`](./intent-first-conformity-audit-2026-06-08.md).

## Scope

Machine-readable conformity matrix of EMI BANXE AI BANK repositories against the
accepted Intent-First Banking concept (ADR-045–049 + INTENT-FIRST-CANON-2026-06-07).
Each row is derived strictly from verified diagnostic facts: `repo_status`,
`concept_docs`, `code_markers`, `process_linkage`. `audit_status` and `next_sprint`
are computed deterministically from those facts by the rules below — no inference,
no repo state invented.

### Derivation rules

- `audit_status`:
  - **ALIGNED** — concept_docs=YES AND code_markers=YES AND process_linkage=YES
  - **PARTIAL** — concept_docs=YES AND code_markers=YES AND process_linkage=NO
  - **GAP** — anything else (with repo_status != MISSING)
  - **MISSING** — repo_status=MISSING
- `next_sprint`:
  - ALIGNED → `protect and reuse`
  - PARTIAL → `add process linkage`
  - GAP → `concept bootstrap`
  - MISSING → `restore local clone / verify repo existence`

## Matrix

| repo | repo_status | concept_docs | code_markers | process_linkage | audit_status | next_sprint |
|------|-------------|--------------|--------------|-----------------|--------------|-------------|
| banxe-architecture | CLEAN | YES | YES | YES | ALIGNED | protect and reuse |
| banxe-payment-core | CLEAN | YES | YES | NO | PARTIAL | add process linkage |
| banxe-emi-stack | DIRTY | YES | YES | NO | PARTIAL | add process linkage |
| banxe-platform | DIRTY | NO | NO | NO | GAP | concept bootstrap |
| banxe-ui | DIRTY | NO | NO | NO | GAP | concept bootstrap |
| banxe-ai-infrastructure | DIRTY | NO | NO | NO | GAP | concept bootstrap |
| banxe-monitoring | DIRTY | NO | NO | NO | GAP | concept bootstrap |
| banxe-business-processes | CLEAN | YES | YES | YES | ALIGNED | protect and reuse |
| banxe-collaboration | MISSING | NO | NO | NO | MISSING | restore local clone / verify repo existence |
| banxe-infra | CLEAN | NO | NO | NO | GAP | concept bootstrap |
| banxe-lexisnexis-distro | CLEAN | NO | NO | NO | GAP | concept bootstrap |

## Observed constraints

- DIRTY repos require isolation/worktree before any edits — never mutate a shared
  checkout with uncommitted changes.
- A MISSING local repo blocks verification — its facts cannot be confirmed until the
  clone is restored / repo existence is verified.
