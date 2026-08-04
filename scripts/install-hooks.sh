#!/usr/bin/env bash
# install-hooks.sh — idempotent installer for the local git hooks (ADR-060).
#
# Wires the repo to use .githooks/ and installs the pre-push branch-name gate
# (scripts/pre-push-branch-name.sh → .githooks/pre-push), a local mirror of the
# server-side guardian-branch-naming check. Safe to run repeatedly.
#
# Usage:  bash scripts/install-hooks.sh   (from the repo root or anywhere inside it)
#
# Protection-on-wake (MT-11, ADR-120 EXTENSION): also verifies and, when missing or
# stale, installs the session-lock layer into the WORKING TREE — the hook, its chain
# block in .githooks/pre-commit, and its .gitignore entries — so a worktree woken from
# an older branch acquires the guard without a per-branch commit. Writes files only.
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

# 2b. Protection-on-wake: session-lock layer (MT-11 / ADR-120 EXTENSION).
#     Self-healing and fail-loud. A worktree woken from a branch that predates the
#     session-lock work carries no session-axis guard; this step installs one from a
#     canonical copy WITHOUT requiring a commit on that branch. Writes files only.
SESSION_LOCK_SHA256="b92ba8785196b05522ee5bd939fb7ba2b5379c9b175744d2fccb157d1e564783"
LOCK_HOOK=".githooks/pre-commit-session-lock"

_sl_sha() { if [ -f "$1" ]; then sha256sum "$1" 2>/dev/null | cut -d' ' -f1; else echo ""; fi; }

# (i) the hook itself — install/repair from a verified canonical copy when absent or stale.
if [ "$(_sl_sha "$LOCK_HOOK")" != "$SESSION_LOCK_SHA256" ]; then
  SL_SRC=""
  COMMON_DIR="$(git rev-parse --git-common-dir 2>/dev/null || true)"
  MAIN_ROOT="$(cd "$COMMON_DIR/.." 2>/dev/null && pwd || true)"
  for _wt in "$MAIN_ROOT" $(git worktree list --porcelain 2>/dev/null | sed -n 's/^worktree //p'); do
    _cand="$_wt/$LOCK_HOOK"
    if [ -f "$_cand" ] && [ "$(_sl_sha "$_cand")" = "$SESSION_LOCK_SHA256" ]; then SL_SRC="$_cand"; break; fi
  done
  if [ -n "$SL_SRC" ]; then
    cp -p "$SL_SRC" "$LOCK_HOOK" && chmod +x "$LOCK_HOOK"
    echo "✓ install-hooks: session-lock hook installed from $SL_SRC (MT-11 protection-on-wake)"
  else
    echo "⚠ install-hooks: no canonical session-lock hook found (expected sha256 $SESSION_LOCK_SHA256)."
    echo "  This worktree has NO session-axis guard. Copy it from a worktree that carries it,"
    echo "  or merge the MT-11 branch. Refusing to install an unverified copy (fail-loud)."
  fi
fi

# (ii) chain block in .githooks/pre-commit — inserted once, after the ADR-120
#      shared-checkout guard (the first 'esac'), before ADR-121. Same block as canon.
if [ -f .githooks/pre-commit ] && ! grep -q "pre-commit-session-lock" .githooks/pre-commit; then
  awk '
    BEGIN { done = 0 }
    { print }
    /^esac$/ && !done {
      print ""
      print "# ── ADR-120 EXTENSION (2026-08-01): session-lock backstop, layer-3 ──"
      print "# Parallel-terminal collision guard: commit only while holding this worktree'"'"'s"
      print "# exclusive .SESSION-LOCK and while HEAD still matches the holder'"'"'s observed SHA."
      print "_lock_hook=\"$(git rev-parse --show-toplevel)/.githooks/pre-commit-session-lock\""
      print "if [ -x \"$_lock_hook\" ]; then"
      print "  \"$_lock_hook\" || exit 1"
      print "fi"
      done = 1
    }
  ' .githooks/pre-commit > .githooks/pre-commit.mt11.tmp \
    && mv .githooks/pre-commit.mt11.tmp .githooks/pre-commit \
    && chmod +x .githooks/pre-commit \
    && echo "✓ install-hooks: session-lock chain block wired into .githooks/pre-commit"
fi

# (iii) .gitignore entries for the lock's runtime artifacts (per-worktree, local-only).
if [ -f .gitignore ] && ! grep -q '^\.SESSION-LOCK$' .gitignore; then
  printf '%s\n%s\n%s\n' \
    "# Session lock — per-worktree, local-only (ADR-120 EXTENSION session axis)" \
    ".SESSION-LOCK" \
    ".SESSION-LOCK.prestaged" >> .gitignore
  echo "✓ install-hooks: .gitignore entries added for .SESSION-LOCK / .SESSION-LOCK.prestaged"
fi

# 3. Self-heal self-check — fast, idempotent; safe to call as the FIRST step of EVERY session.
#    Re-asserts activation (no-op if already correct) and fails loudly if it could not.
HP="$(git config --get core.hooksPath || true)"
if [ "$HP" != ".githooks" ] || [ ! -x .githooks/pre-push ]; then
  echo "✗ install-hooks self-check FAILED (hooksPath=$HP, pre-push exec=$([ -x .githooks/pre-push ] && echo yes || echo no))"; exit 1
fi
echo "✓ install-hooks self-check OK (ADR-060 pre-push gate active)"

# 3b. Session-lock self-check — reports state. Does NOT fail the installer when the
#     canonical hook was unavailable (already warned loudly above), so ADR-060
#     bootstrap keeps working on worktrees that have not received MT-11 yet.
if [ -x "$LOCK_HOOK" ] && grep -q "pre-commit-session-lock" .githooks/pre-commit; then
  echo "✓ install-hooks self-check OK (session-lock layer active — claim with: bash $LOCK_HOOK --claim)"
else
  echo "⚠ install-hooks self-check: session-lock layer NOT active in this worktree (see warning above)"
fi
