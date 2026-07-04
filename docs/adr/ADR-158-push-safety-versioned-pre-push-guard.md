# ADR-158 — Push-safety: versioned client-side pre-push guard (force / protected-ref / shared-checkout)

- **Status:** Proposed (prepare-only; awaiting operator ratification + merge)
- **Date:** 2026-07-04
- **Deciders:** Operator (CEO) — ratifies; Software Factory (Left/Orchestrating Terminal) — prepares
- **Supersedes / amends:** none (additive to ADR-060)
- **Related:** ADR-060 (multi-actor orchestration / branch namespace), ADR-102 (duplication verification), ADR-120 (session-worktree isolation), ADR-134 (settings.json is LOCAL, not git-tracked), ADR-TERMINAL-B-SPEC-LANE (Terminal-B rebase-before-push)

## Context

Push-safety in this repository was, until now, enforced **asymmetrically** across three layers with a
gap in the middle:

1. **Server-side** — GitHub branch protection on `main` is `strict` (up-to-date required, no direct
   force). This holds regardless of client, but it is the *last* line and gives no fast-fail locally.
2. **Local operator config** — `~/.claude/settings.json` carries a `deny` list
   (`git push --force *`, `git push * HEAD:main`, `git push origin main`, …). Per **ADR-134** this file
   is **LOCAL and not git-tracked** — it protects only the host that happens to have it. A fresh terminal,
   a new host, or any agent shell without that file inherits **no** client-side push-safety.
3. **Versioned client-side** — `.githooks/pre-push` (source of truth `scripts/pre-push-branch-name.sh`,
   installed by `scripts/install-hooks.sh`) validated **only** the ADR-060 branch *name*. It did **not**
   block a direct push to `main`/`master`, nor a push originating from the shared/main checkout.

The audit (2026-07-04) confirmed no versioned force/protected-ref guard existed anywhere
(`grep` over `origin/main` returned only the ADR-120 *commit* guard in `pre-commit`/`install-hooks.sh`).
So the only git-tracked, host-independent client defense was the branch-name gate — the actual
push-target safety lived exclusively in a non-versioned local file.

## Decision

Extend the **existing** versioned pre-push hook (extend, not rewrite) so that, in addition to ADR-060
branch-name validation, it **fails closed** on two push-safety violations — a versioned, host-independent
mirror of the `settings.json` deny-list and the server-side protection:

1. **Protected-ref guard** — block any push whose **remote** ref is `refs/heads/main` or
   `refs/heads/master`. The factory never pushes a protected branch directly; integration is via PR
   merge only (ADR-060/ADR-102). Implemented as a pure, unit-tested `is_protected_ref()` helper.
2. **Shared-checkout guard** — block any push originating from the shared/main checkout rather than a
   linked session worktree (a linked worktree's git-dir lives under `.git/worktrees/`; the shared
   checkout's does not). This mirrors the ADR-120 guard already enforced in `pre-commit`.

**Deliberately NOT blocked:** `--force-with-lease` to ordinary feature branches — it is *required* by
parallel-session-isolation Rule 4 for rebase-before-merge. Only `main`/`master` are protected. (A git
pre-push hook cannot observe the `--force` flag directly; the protected-ref guard is the correct and
sufficient mirror, since a force *to main* is a push whose remote ref is `main` and is therefore blocked.)

Both `scripts/pre-push-branch-name.sh` (source of truth) and `.githooks/pre-push` (installed copy) are
updated **byte-for-byte identically**. The pure guard is covered by deterministic cases in
`scripts/test-branch-name-gate.sh` (16 name + 7 push-safety cases, all green; no git-state dependence).

## Consequences

- **Positive:** every checkout that has run `install-hooks.sh` now fails fast on a direct main/master
  push or a shared-checkout push, independent of any local `settings.json`. Defense-in-depth: three
  aligned layers (server protection · local deny-list · versioned hook).
- **Neutral:** legitimate flows are unaffected — feature-branch pushes and `--force-with-lease` rebases
  still pass; PR merges happen server-side (GitHub Actions / `gh`), which do not run this local hook.
- **Cost:** the hook must stay in sync with its source-of-truth copy (already a documented install step);
  the test harness guards the pure logic against drift.

## Duplication Audit (ADR-102)

- **Repo-wide search** for an existing force/protected-ref/shared-checkout push guard: none found on
  `origin/main` (only ADR-120 *commit* guard in `pre-commit` + `install-hooks.sh`). `ADR-TERMINAL-B-SPEC-LANE`
  mandates *rebase-before-push* but specifies no protected-ref/force guard. No duplication.
- **Source of truth + consumers:** `scripts/pre-push-branch-name.sh` is the source; `.githooks/pre-push`
  is its installed copy (`install-hooks.sh`); `scripts/test-branch-name-gate.sh` sources the pure
  validators. All three updated consistently; `is_compliant()` left untouched (existing tests stay green).
- **Decision per match:** *extend* the existing hook (keep), *add* `is_protected_ref()` (new), *do not*
  create any new standalone guard file — that would duplicate and drift.
- **No hidden consumers:** `settings.json` deny-list and server-side branch protection remain in force
  and are complemented, not replaced.
- **Uncertainty:** none blocking. Fail-closed by construction.

## Anchors

`scripts/pre-push-branch-name.sh` · `.githooks/pre-push` · `scripts/test-branch-name-gate.sh` ·
`scripts/install-hooks.sh` · `.github/workflows/guardian.yml` (branch-naming pattern SoT) ·
ADR-060 · ADR-102 · ADR-120 · ADR-134 · ADR-TERMINAL-B-SPEC-LANE. Operator orchestration audit 2026-07-04.
