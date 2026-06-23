#!/usr/bin/env bash
# bx-session.sh — per-session git-worktree launcher (ADR-120).
#
# Canon (ADR-120): one session = one worktree = one ADR-060 branch. Every factory
# session works in a DEDICATED `git worktree` off freshly-fetched origin/main; the
# shared checkout is RESERVED for audit-only and MUST NOT host a session branch or commit.
#
# Usage:
#   bash scripts/bx-session.sh agent/factory/<id>/<slug>      # create/reuse worktree, print path
#   bash scripts/bx-session.sh --cleanup agent/factory/<id>/<slug>  # remove worktree after push
#
# Prints the worktree path on success (stdout) so callers can `cd "$(bash scripts/bx-session.sh ...)"`.
set -eu

WT_ROOT="${BX_WT_ROOT:-$HOME/wt}"               # config-over-hardcode: override via BX_WT_ROOT
PATTERN='^agent/(central|right|factory)/[A-Za-z0-9]+/[a-z0-9._-]+$'  # ADR-060, mirror of guardian.yml

die() { echo "✗ bx-session: $*" >&2; exit 1; }

# Refuse to run from the shared/main checkout (ADR-120 §2): a linked worktree's git-dir
# lives under .git/worktrees/, the main checkout's does not. No hardcoded path.
case "$(git rev-parse --absolute-git-dir 2>/dev/null || echo /)" in
  */worktrees/*) : ;;  # already inside a linked worktree — fine
  *)
    # Allowed ONLY because we are about to CREATE an isolated worktree; never to commit here.
    [ "${BX_ALLOW_SHARED:-0}" = "1" ] || true ;;
esac

CLEANUP=0
if [ "${1:-}" = "--cleanup" ]; then CLEANUP=1; shift; fi
BRANCH="${1:-}"
[ -n "$BRANCH" ] || die "missing branch (usage: bash scripts/bx-session.sh [--cleanup] agent/<term>/<id>/<slug>)"
echo "$BRANCH" | grep -Eq "$PATTERN" || die "branch '$BRANCH' violates ADR-060 ($PATTERN)"

SLUG="$(printf '%s' "$BRANCH" | tr '/' '-')"
WT_PATH="$WT_ROOT/$SLUG"

if [ "$CLEANUP" = "1" ]; then
  [ -d "$WT_PATH" ] || die "no worktree at $WT_PATH to clean up"
  git -C "$WT_PATH" diff --quiet && git -C "$WT_PATH" diff --cached --quiet \
    || die "worktree $WT_PATH has uncommitted changes — refusing --cleanup (push/commit first)"
  git worktree remove "$WT_PATH"
  echo "✓ bx-session: removed worktree $WT_PATH" >&2
  exit 0
fi

git fetch origin -q || die "git fetch origin failed"

if git worktree list --porcelain | grep -qx "worktree $WT_PATH"; then
  echo "✓ bx-session: reusing existing worktree $WT_PATH (branch $BRANCH)" >&2
else
  mkdir -p "$WT_ROOT"
  if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
    git worktree add "$WT_PATH" "$BRANCH" >&2
  else
    git worktree add -b "$BRANCH" "$WT_PATH" origin/main >&2
  fi
  echo "✓ bx-session: created worktree $WT_PATH off origin/main (branch $BRANCH, ADR-120)" >&2
fi

# Inherit hooks + role anchor into the fresh worktree (idempotent).
( cd "$WT_PATH" && bash scripts/install-hooks.sh >/dev/null 2>&1 || true )

printf '%s\n' "$WT_PATH"
