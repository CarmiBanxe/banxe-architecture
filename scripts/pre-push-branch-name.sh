#!/usr/bin/env bash
# pre-push-branch-name.sh — local mirror of the guardian-branch-naming gate (ADR-060)
#
# Catches a non-compliant branch namespace BEFORE `git push` / PR creation, so the
# #644 → #646 round-trip (hyphen in the <id> segment) is not repeated.
#
# Install:  ln -sf ../../scripts/pre-push-branch-name.sh .git/hooks/pre-push
#   (or)    git config core.hooksPath .githooks  &&  cp scripts/pre-push-branch-name.sh .githooks/pre-push
# Source of truth for the pattern: .github/workflows/guardian.yml (guardian-branch-naming).
set -e

# ADR-060 canonical namespace. <id> = [A-Za-z0-9]+ (NO hyphen); <slug> = [a-z0-9._-]+.
PATTERN='^agent/(central|right|factory)/[A-Za-z0-9]+/[a-z0-9._-]+$'

branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')"

# Allow-listed automation prefixes (mirror guardian.yml) + main/HEAD.
case "$branch" in
  main|HEAD|dependabot/*|renovate/*|revert/*)
    echo "pre-push-branch-name OK (allow-listed: $branch)"; exit 0 ;;
esac

if ! echo "$branch" | grep -qE "$PATTERN"; then
  echo "✗ pre-push BLOCKED — branch '$branch' violates ADR-060 namespace."
  echo "  Required: agent/(central|right|factory)/<id>/<slug>"
  echo "  <id> = [A-Za-z0-9]+  (ALPHANUMERIC ONLY — hyphen FORBIDDEN, e.g. archstacksubA ✓, archstack-subA ✗)"
  echo "  <slug> = [a-z0-9._-]+ (lowercase; hyphens allowed here)"
  echo "  Rename:  git branch -m '<compliant-name>'  then re-push."
  exit 1
fi
echo "pre-push-branch-name OK (ADR-060 compliant: $branch)"
exit 0
