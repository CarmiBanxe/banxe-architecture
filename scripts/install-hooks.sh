#!/usr/bin/env bash
# install-hooks.sh — idempotent installer for the local git hooks (ADR-060).
#
# Wires the repo to use .githooks/ and installs the pre-push branch-name gate
# (scripts/pre-push-branch-name.sh → .githooks/pre-push), a local mirror of the
# server-side guardian-branch-naming check. Safe to run repeatedly.
#
# Usage:  bash scripts/install-hooks.sh   (from the repo root or anywhere inside it)
#
# Session isolation (ADR-120): do NOT work or commit in the shared checkout — every
# session runs in a DEDICATED git worktree off origin/main. Launch one with:
#     bash scripts/bx-session.sh agent/<central|right|factory>/<id>/<slug>
# The .githooks/pre-commit installed here enforces ADR-120 (refuses commits from the
# shared/main checkout).
set -eu

# Resolve repo root (works from any subdir).
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$ROOT" ]; then
  echo "✗ install-hooks: not inside a git repository"; exit 1
fi
cd "$ROOT"

# 0. Propagate the per-terminal role anchor into linked worktrees.
#    The role-guard pre-commit (.git/hooks/pre-commit) reads .TERMINAL-ROLE at the
#    worktree root, but `git worktree add` does NOT copy this untracked/excluded
#    anchor (.git/info/exclude) — so every fresh sprint worktree warns
#    "[role-guard] WARN: no .TERMINAL-ROLE anchor — skipping".
#    Inherit it from the MAIN worktree (same terminal identity) when absent here.
#    Idempotent; never silences a genuinely-missing anchor — copies ONLY when the
#    main worktree actually has one.
if [ ! -f "$ROOT/.TERMINAL-ROLE" ]; then
  COMMON_DIR="$(git rev-parse --git-common-dir 2>/dev/null || true)"
  MAIN_ROOT="$(cd "$COMMON_DIR/.." 2>/dev/null && pwd || true)"
  if [ -n "$MAIN_ROOT" ] && [ "$MAIN_ROOT" != "$ROOT" ] && [ -f "$MAIN_ROOT/.TERMINAL-ROLE" ]; then
    cp "$MAIN_ROOT/.TERMINAL-ROLE" "$ROOT/.TERMINAL-ROLE"
    echo "✓ install-hooks: propagated .TERMINAL-ROLE from main worktree → $ROOT (role-guard anchor)"
  else
    echo "⚠ install-hooks: no .TERMINAL-ROLE here and none to inherit — role-guard will warn (set manually)"
  fi
fi

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
