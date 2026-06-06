# Transfer Package (VERIFIED) — Terminal B — 2026-06-06 CEST
> Supersedes earlier draft. Prior package claimed commit da26607 / IL-109 / 29-files-on-main — INVALID. Below = git-verified.

## Verified state (git)
- REPO: CarmiBanxe/banxe-architecture
- origin/main HEAD: acfb13c — "CONSOLIDATED 270-project smart refactor (21 SPECs + 6 CONTRACTs + INDEX + PRIORITY-MAP) (#325)"
- prior main commits: eb3279a (restore guardian workflows #324), 10651bd (WalletPort CONTRACT pilot)
- legacy refactor files on main: 29 (.md in docs/refactor/legacy/)
- WORK BRANCH: feat/docs-refactor-SPRINT-PLAN-and-TRANSFER-2026-06-06 (from origin/main, tracks origin/main)
- NOTE: local `main` is locked by worktree /home/mmber/ba-merge-exchange — do NOT checkout main here; branch from origin/main.

## Last IL entries (verified on main)
- IL-OPS-TERMINAL-B-REFACTOR-CONSOLIDATED-PUSH-2026-06-06 (owner: Central, executor: Terminal B) — 24-file consolidated admin-bypass, BINDING-TEMPORARY, auto-revoked at guardian webhook live.
- IL-OPS-CANON-BYPASS-EXCEPTION-EXTEND-TO-TWENTYSIX-2026-06-06.
- NEXT IL: IL-110.

## Open items
- 7 UNVERIFIED claims in docs/project/UNVERIFIED-CLAIMS-LEGACY-DISCOVERY.md (39 lines) — all UNVERIFIED.
- 42-43 isolated feature branches feat/docs-refactor-* — content already in #325 consolidated; safe to prune after verification.

## Active blockers (CEO action)
- BT-001 Modulr API key · BT-005 Companies House API key · BT-010 FCA RegData API key
- BT-011 UNBLOCKED (Keycloak deployed) · BT-012/013 Saga + Three-Balance patterns

## Invariants
- I-01 Decimal GBP (not float) · I-02 hard-block RU/BY/IR/KP/CU/MM · I-08 ClickHouse TTL >= 5yr
- I-24 append-only audit · I-27 HITL supervised (never auto) · I-28 IL after each step · I-29 doc standard

## House rules
- 10 coordination-via-merge · 11 best-solution · 12 sequential · split-large-commands · 13/14 (central self-audit/rollout)

## Next session start sequence
1. git fetch origin main --quiet
2. git checkout -b <new-feat-branch> origin/main   # NOT `git checkout main` (worktree lock)
3. ls docs/refactor/legacy/*.md | wc -l  # expect 29
4. Resolve IL-110 (verify 7 claims) before any Phase B code.
