#!/usr/bin/env bash
# install-hooks.sh — idempotent installer for the local git hooks (ADR-060).
#
# Wires the repo to use .githooks/ and installs the pre-push branch-name gate
# (scripts/pre-push-branch-name.sh → .githooks/pre-push), a local mirror of the
# server-side guardian-branch-naming check. Safe to run repeatedly.
#
# Usage:  bash scripts/install-hooks.sh   (from the repo root or anywhere inside it)
set -eu

# Resolve repo root (works from any subdir).
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$ROOT" ]; then
  echo "✗ install-hooks: not inside a git repository"; exit 1
fi
cd "$ROOT"

SRC="scripts/pre-push-branch-name.sh"
if [ ! -f "$SRC" ]; then
  echo "✗ install-hooks: $SRC not found (expected ADR-060 pre-push gate)"; exit 1
fi

# 1. Point git at the in-repo hooks dir (idempotent).
mkdir -p .githooks
git config core.hooksPath .githooks

# 2. Install the pre-push hook (copy, not symlink — portable across evo1/evo2/Legion).
cp "$SRC" .githooks/pre-push
chmod +x .githooks/pre-push scripts/pre-push-branch-name.sh 2>/dev/null || true

echo "✓ install-hooks: core.hooksPath=$(git config --get core.hooksPath); .githooks/pre-push installed (ADR-060 branch-name gate)."

# 3. Self-heal self-check — fast, idempotent; safe to call as the FIRST step of EVERY session.
#    Re-asserts activation (no-op if already correct) and fails loudly if it could not.
HP="$(git config --get core.hooksPath || true)"
if [ "$HP" != ".githooks" ] || [ ! -x .githooks/pre-push ]; then
  echo "✗ install-hooks self-check FAILED (hooksPath=$HP, pre-push exec=$([ -x .githooks/pre-push ] && echo yes || echo no))"; exit 1
fi
echo "✓ install-hooks self-check OK (ADR-060 pre-push gate active)"
