# ADR: Eliminate Two-Terminal Ledger Merge Race (Option A)

**Date:** 2026-07-03
**Status:** Accepted
**Supersedes:** ADR-143 Redis allocator (still used on main; deprecated for branch-level minting)

## Context

Root cause (audited 2026-07-03): `INSTRUCTION-LEDGER.md` and `ledger/IL-SEQUENCE.json`
were committed into every feature branch and rebuilt per-branch via `build_ledger.py`.
When two terminals create branches from the same main tip, they both mint the same next
IL number. The result: every second PR conflicts on these two files, requiring manual
rebase before each merge.

Shard files under `ledger/entries/*/IL-*.md` never conflict because each shard has a
unique directory name (slug + timestamp + hash suffix).

## Decision

**Option A:** remove the conflicting files from branches entirely.

1. Add `INSTRUCTION-LEDGER.md` and `ledger/IL-SEQUENCE.json` to `.gitignore` and
   untrack them (`git rm --cached`).
2. Add `.github/workflows/ledger-rebuild.yml`: triggers on push to main, runs
   `BANXE_IL_ALLOCATOR=local python3 ledger/build_ledger.py`, commits back with
   `[skip ci]`. Requires `GH_PAT` secret or GitHub Actions push bypass on main.
3. Update `guardian-ledger` check: require `NEW_SHARD` (shard file added) only;
   drop `ADDED_IL` condition (rebuild files no longer appear in PRs).
4. Update `scripts/add-il-shard.sh`: create shard file only, do not run
   `build_ledger.py` in branch.

## Consequences

- **Branches never conflict** on ledger files — both terminals write in parallel,
  no force-push needed, no sequential rebase loop.
- **Redis allocator (ADR-143)** still used on main's rebuild run when available;
  graceful fallback to `local max+1` when Redis unavailable.
- **One CI commit per merge** to main (`[skip ci]` prevents cascade).
- **Requires:** `GH_PAT` secret in banxe-architecture repo settings, OR branch
  protection must allow GitHub Actions push to main.

## Alternatives Considered

**Option B (Redis allocator):** Have concurrent terminals allocate unique IL numbers
via Redis INCR before minting. Rejected as primary fix because: (a) requires Redis
running on every machine where factory agents run; (b) does not eliminate the file
conflict — branches still commit INSTRUCTION-LEDGER.md with allocated numbers, still
conflict on that file content if two allocations happen simultaneously.
