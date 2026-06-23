---
id: ADR-120
title: Per-session git-worktree isolation (shared checkout is audit-only)
status: ACCEPTED
date: 2026-06-23
accepted: 2026-06-23
supersedes: []
related:
  - "ADR-060-branch-namespace.md (one session = one ADR-060 branch)"
  - "ADR-119-stable-frozen-il-numbering.md (ledger regen determinism this protects)"
  - ".claude/rules/parallel-session-isolation.md (Rule 1–6, operational mirror)"
  - "scripts/install-hooks.sh (session bootstrap; bx-session.sh launcher)"
  - "ledger/build_ledger.py (regen must run in an isolated tree)"
il_anchor: IL-483
scope: BANXE-only
concept_only: false
---

# ADR-120 — Per-session git-worktree isolation (shared checkout is audit-only)

## Context

Multiple factory sessions (central / right / factory) operate on one Legion host against a
single repository. Without an enforced isolation rule they edit the **same shared working tree**
(`/home/mmber/banxe-architecture`), which produces the exact incidents repeatedly observed:

- **Working-tree pollution across sessions.** Audit @ 2026-06-23 ~19:40 UTC found the shared
  checkout in **detached HEAD @4c9904f** holding **uncommitted deletions of files already
  committed on `origin/main`** — leaked from ≥2 parallel sessions (S-PROD-1 safeguarding:
  `S-PROD-1-SAFEGUARDING-EXECUTION-BRIEF.md` + shard `b8f3d1`; refactor-index: PHASE-B doc +
  shards `c4a9f7`, `b8e2f1`), plus a dirty `INSTRUCTION-LEDGER.md` / `IL-SEQUENCE.json` from a
  ledger regen run on the **depleted** tree.
- **Append-only violations (I-28).** Regenerating the ledger from a tree missing other sessions'
  shards drops their `IL-SEQUENCE.json` keys → `ledger-append-only` / `guardian-ledger` fail.
  This is not a numbering bug (ADR-119 fixed that) — it is **cross-session tree contamination**.
- **Branch-state confusion.** A second checkout (`/home/mmber/banxe-architecture-main`) was also
  left in detached HEAD; session branches lived in the shared tree.

`.claude/rules/parallel-session-isolation.md` (Rule 1–6) already mandates *verify-before-stage*
and *report-don't-resolve* behaviours, but **no canon required the structural fix** — physical
isolation of each session into its own `git worktree`. This ADR adds that rule.

## Decision

1. **One session = one worktree = one ADR-060 branch.** Every factory session MUST operate in a
   **dedicated `git worktree`** created off `origin/main`, on a fresh ADR-060-compliant branch
   (`agent/(central|right|factory)/<id>/<slug>`). The worktree is **removed on session end**.
2. **The shared checkout `/home/mmber/banxe-architecture` is RESERVED for audit-only.** It MUST
   NOT be edited, committed from, or used to hold a session branch. Read-only diagnostics
   (`git status/log/show`, `gh ... view`, file reads) are the only permitted use.
3. **Ledger regen + all commits happen ONLY inside the session worktree.** `ledger/build_ledger.py`
   regeneration and every `git commit` run in the isolated tree, so the regen sees the full,
   uncontaminated shard set (preserves **I-28 append-only** and ADR-119 determinism).
4. **Detached-HEAD shared checkouts are forbidden as work trees.** A shared/main checkout left in
   detached HEAD must not be used to stage or commit; restore it to a clean tracking state.
5. **Never resolve another session's working-tree pollution.** Per parallel-session canon Rule 6,
   uncommitted changes you did not author are operator-owned: report, do not stash/restore/discard.

## Enforcement

- **Launcher:** `scripts/bx-session.sh` creates/reuses `/home/mmber/wt/<branch-slug>` via
  `git worktree add` off freshly-fetched `origin/main`, refuses to run from the shared checkout,
  and supports `--cleanup` to remove the worktree after push. Wired into `scripts/install-hooks.sh`
  session docs.
- **Pre-commit guard:** `.githooks/pre-commit` blocks any commit whose worktree is **not** a linked
  worktree (detected portably via `git rev-parse --absolute-git-dir` matching `*/worktrees/*`, no
  hardcoded path) — i.e. commits from the shared/main checkout are refused with an ADR-120 message.
- **Server-side:** existing `guardian-branch-naming` (ADR-060) continues to enforce the branch
  namespace; this ADR adds the *physical-isolation* dimension the gates assumed but never enforced.

## Consequences

- **Positive:** no cross-session tree pollution; ledger regen is always full-set ⇒ no spurious
  append-only failures; session state is self-contained and disposable; the shared checkout stays
  a clean audit surface.
- **Cost:** one `git worktree add`/`remove` per session (seconds; `bx-session.sh` automates it) and
  a small disk footprint per active session under `/home/mmber/wt/`.
- **Migration:** existing detached/dirty shared checkouts are operator-cleaned (not by this ADR —
  see Decision §5). New sessions adopt `bx-session.sh` from bootstrap.

## Anchors

- Worktree audit 2026-06-23 ~19:40 UTC (`git worktree list`; shared-checkout pollution status).
- ADR-060 (branch namespace); ADR-119 (frozen IL numbering); I-28 (append-only).
- `.claude/rules/parallel-session-isolation.md` (operational Rule 1–6 mirror).
- `scripts/bx-session.sh`; `scripts/install-hooks.sh`; `.githooks/pre-commit`.
