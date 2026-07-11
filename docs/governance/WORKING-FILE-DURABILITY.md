# Working-File Durability — commit important artifacts, never leave them untracked

**Status:** ACTIVE · **Added:** 2026-07-11 (R-SYNC) · **ADR:** ADR-170 · **Cross-ref:** ADR-120.

> Pointer-first, additive rule (ADR-102). It does not restate ADR-120 (session-worktree
> isolation) — it records the *durability* consequence that isolation makes easy to forget.

## Rule

**Important working artifacts MUST be git-committed on a named branch — never left untracked.**
This covers handoff packages, consultant verdicts, design notes, and any decision-input document
another terminal (or a later session) needs to see.

**Why:** untracked files live only in one worktree's working directory. Worktree/branch hygiene
(`git worktree remove`, branch cleanup, checkout switches) **destroys** them — they are invisible to
git and to every other terminal. This is not hypothetical: four handoff files were lost exactly this
way and had to be reconstructed from Claude Code file-history + the session transcript
(**PR #1123** recovery).

## How

- Put the artifact under a tracked path (e.g. `docs/handoff/`), then commit it on a named branch
  (per **ADR-120**: one session = one worktree off `origin/main`; commits happen in the worktree,
  not the shared/main checkout).
- A tracked change outside the infra-exemption `^(scripts/|\.github/|ledger/build_ledger\.py$)|\.sh$`
  requires a ledger shard (guardian-ledger, ADR-056/060) — so a docs-only durability commit still
  carries a shard.
- Do **not** rely on a working file surviving a worktree cleanup, a branch switch, or another
  terminal's hygiene sweep. If it matters, it is committed.

## Anchors
- **ADR-170** (cross-terminal registration sync — the writer-lock + stale-main gate + this rule).
- **ADR-120** (session-worktree isolation), **ADR-056/060** (ledger coupling), PR #1123 (the recovery
  that motivated this rule).
