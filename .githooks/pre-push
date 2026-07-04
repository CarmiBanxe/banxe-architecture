#!/usr/bin/env bash
# pre-push-branch-name.sh — local mirror of the guardian-branch-naming gate (ADR-060)
#
# ROOT-CAUSE FIX (2026-06-21): a pre-push hook is handed the refs being pushed on STDIN
#   (git pre-push contract:  <local ref> <local sha> <remote ref> <remote sha>).
# The previous version checked `git rev-parse --abbrev-ref HEAD` instead — so
# `git push origin <bad-branch>` while HEAD sat on `main` validated `main` (allow-listed)
# and let the bad branch through (observed on evo2; Legion happened to have HEAD == the
# test branch, hiding the bug). This version validates EACH pushed ref from STDIN, with a
# manual-invocation fallback to the current branch. The pure validator `is_compliant()` is
# shared with scripts/test-branch-name-gate.sh so every host gives an identical result.
#
# Install:  git config core.hooksPath .githooks  &&  cp scripts/pre-push-branch-name.sh .githooks/pre-push
# Pattern source of truth: .github/workflows/guardian.yml (guardian-branch-naming).
#
# ADR-158 (push-safety) ADDITION (2026-07-04): beyond ADR-060 branch-name validation, this hook
# now also fails-closed on two push-safety violations, as a *versioned* client-side mirror of the
# LOCAL-only ~/.claude/settings.json deny-list (ADR-134: that file is per-host, not git-tracked) +
# server-side branch protection:
#   (1) a direct push whose REMOTE ref is a protected branch (main/master) — integration is via PR
#       merge only, never a direct push (ADR-060/ADR-102);
#   (2) a push originating from the shared/main checkout instead of a linked session worktree
#       (mirrors the ADR-120 guard already enforced in .githooks/pre-commit).
# The pure guard is_protected_ref() is exported for scripts/test-branch-name-gate.sh (unit-tested).
set -eu

# Byte-for-byte mirror of guardian.yml guardian-branch-naming PATTERN.
# specproj = ADR-TERMINAL-B-SPEC-LANE Terminal-B namespace
PATTERN='^agent/(central|right|factory|specproj)/[A-Za-z0-9]+/[a-z0-9._-]+$'

# Pure validator. arg = branch (refs/heads/ prefix tolerated). return 0 = compliant, 1 = violation.
is_compliant() {
  b="${1#refs/heads/}"
  case "$b" in
    main|master|HEAD|dependabot/*|renovate/*|revert/*) return 0 ;;
  esac
  printf '%s\n' "$b" | grep -qE "$PATTERN"
}

_violation() {
  echo "✗ pre-push BLOCKED — branch '$1' violates ADR-060 namespace." >&2
  echo "  Required: agent/(central|right|factory|specproj)/<id>/<slug>" >&2
  echo "  <id> = [A-Za-z0-9]+  (hyphen FORBIDDEN: archstacksubA ✓, archstack-subA ✗)" >&2
  echo "  <slug> = [a-z0-9._-]+ (lowercase; hyphens allowed here)" >&2
}

# Pure guard (ADR-158). arg = a REMOTE ref (refs/heads/ prefix tolerated).
# return 0 = protected integration branch → direct push forbidden; 1 = ordinary branch.
# Force-with-lease to ordinary feature branches stays allowed (parallel-session-isolation Rule 4);
# only main/master are protected here, matching the settings.json deny-list.
is_protected_ref() {
  r="${1#refs/heads/}"
  case "$r" in
    main|master) return 0 ;;
    *) return 1 ;;
  esac
}

_push_violation() {
  echo "✗ pre-push BLOCKED (ADR-158) — direct push to protected ref '$1' is forbidden." >&2
  echo "  The factory never pushes main/master directly; integrate via PR merge (ADR-060/ADR-102)." >&2
  echo "  Versioned mirror of the settings.json deny-list + server-side branch protection." >&2
}

_main() {
  rc=0; checked=0
  # ── ADR-120/ADR-158 push-safety: push only from a linked session worktree, never the shared
  #    /main checkout (mirrors the ADR-120 guard in .githooks/pre-commit). A linked worktree's
  #    git-dir lives under .git/worktrees/; the shared checkout's does not (portable detection).
  case "$(git rev-parse --absolute-git-dir 2>/dev/null || echo /)" in
    */worktrees/*) : ;;
    *)
      echo "✗ pre-push BLOCKED (ADR-120/ADR-158) — push from the shared/main checkout is forbidden." >&2
      echo "  One session = one worktree off origin/main: bash scripts/bx-session.sh agent/<plane>/<id>/<slug>." >&2
      return 1 ;;
  esac
  # Read the refs git is about to push (STDIN). Validate each branch ref.
  while read -r local_ref _lsha _rref _rsha; do
    [ -n "${local_ref:-}" ] || continue
    case "$local_ref" in
      refs/heads/*) : ;;
      *) continue ;;                 # tags / deletes (local_ref empty) — skip
    esac
    checked=1
    b="${local_ref#refs/heads/}"
    if is_compliant "$b"; then echo "pre-push OK (ADR-060 compliant: $b)"; else _violation "$b"; rc=1; fi
    # ADR-158 push-safety: block a direct push whose REMOTE target is a protected branch.
    if is_protected_ref "${_rref:-}"; then _push_violation "${_rref#refs/heads/}"; rc=1; fi
  done
  # Manual / empty-STDIN invocation → fall back to the current branch.
  if [ "$checked" -eq 0 ]; then
    b="$(git symbolic-ref --short -q HEAD || echo '')"
    [ -n "$b" ] || { echo "pre-push: detached HEAD, nothing to validate"; return 0; }
    if is_compliant "$b"; then echo "pre-push OK (ADR-060 compliant: $b)"; else _violation "$b"; rc=1; fi
  fi
  return "$rc"
}

# Execute only when run directly (not when sourced by the test harness).
if [ "${BASH_SOURCE[0]:-$0}" = "$0" ]; then
  _main
fi
