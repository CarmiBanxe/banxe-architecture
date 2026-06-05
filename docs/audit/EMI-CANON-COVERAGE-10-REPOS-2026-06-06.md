# EMI BANXE — Canon Coverage Extended to 10 Repos (v1.6.1)

Date: 2026-06-06 01:40 CEST
Status: REFERENCE (coverage increment; supersedes 8-repo count in EMI-CANON-COVERAGE-COMPLETE-2026-06-06.md)
Source: Central active build (House rule 14); factory v1.6.1 (House rule 13 consumer)

## Result

Central published 2 previously local-only git repos to GitHub and pinned them to Factory canon v1.6.1, extending coverage from 8 to 10 EMI code repos.

| # | Repo | canon | note |
|---|------|-------|------|
| 1-8 | (see EMI-CANON-COVERAGE-COMPLETE-2026-06-06.md) | v1.6.1 | prior batch |
| 9 | banxe-ai-infrastructure | v1.6.1 | published from local (38 commits, 162 files); PR #1 |
| 10 | banxe-monitoring | v1.6.1 | published from local (3 commits, 14 files); PR #1 |

## What Central did (House rule 14 active build)

- Self-audited local-only repos: found 2 ready git repos without GitHub remote (ai-infrastructure, monitoring) and 4 non-repo folders (audit, canon, dev, operator-runbooks).
- Published the 2 ready repos: gh repo create --private --source --push.
- Rolled out factory canon v1.6.1 (consumer) + merged.
- Did NOT touch the 4 non-repo folders (unclear-purpose staging; possibly other terminals' zones per House rule 10).

## Remaining local-only (NOT published — deferred)

- banxe-audit, banxe-canon, banxe-dev, banxe-operator-runbooks — plain folders, not git repos; purpose unclear (possible cross-terminal staging). Not published by Central; require operator/owner decision before becoming official EMI repos.
- banxe-legacy-unpack, banxe-incident-2026-05-07 — operational/incident scratch; not code repos for canon.

## Concept compliance

- House rule 13: factory engine untouched (consumer only).
- House rule 14: Central built actively and self-audited; published repos within its own authority (git repos with content, no remote = unowned on GitHub).
- House rule 10: did not convert unclear-purpose folders into repos.

=== END OF CANON COVERAGE 10 REPOS (snapshot 801b1ca) ===
