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
set -eu

# Byte-for-byte mirror of guardian.yml guardian-branch-naming PATTERN.
PATTERN='^agent/(central|right|factory)/[A-Za-z0-9]+/[a-z0-9._-]+$'

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
  echo "  Required: agent/(central|right|factory)/<id>/<slug>" >&2
  echo "  <id> = [A-Za-z0-9]+  (hyphen FORBIDDEN: archstacksubA ✓, archstack-subA ✗)" >&2
  echo "  <slug> = [a-z0-9._-]+ (lowercase; hyphens allowed here)" >&2
}

_main() {
  rc=0; checked=0
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
