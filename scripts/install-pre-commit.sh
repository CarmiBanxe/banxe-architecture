#!/usr/bin/env bash
# install-pre-commit.sh — symlink versioned hook into .git/hooks/pre-commit
# Usage: bash scripts/install-pre-commit.sh
# Idempotent: safe to re-run.

set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
SRC="$REPO_ROOT/scripts/pre-commit-hook.sh"
DST="$REPO_ROOT/.git/hooks/pre-commit"

if [[ ! -f "$SRC" ]]; then
  echo "ERROR: $SRC not found" >&2
  exit 1
fi

# Backup existing hook if it is not already our symlink.
if [[ -f "$DST" && ! -L "$DST" ]]; then
  BACKUP="$DST.backup-$(date +%Y%m%d-%H%M%S)"
  cp "$DST" "$BACKUP"
  echo "Backed up existing $DST to $BACKUP"
fi

ln -sf "$SRC" "$DST"
chmod +x "$SRC"
echo "Installed: $DST -> $SRC"
echo "Run 'git commit' to verify; first stage should be: pytest PASS (no tests collected — canon/docs-only repo)"
