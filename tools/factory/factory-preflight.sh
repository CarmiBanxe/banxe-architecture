#!/usr/bin/env bash
# factory-preflight.sh — READ-ONLY git/ledger preflight for factory ledger sprints.
# Complements: .github/workflows/main-serialize.yml (base-drift, hard) and
# docs/governance/LEDGER-MERGE-QUEUE.md (single-writer procedure). Performs NO
# mutation, NO commit, NO push. Distinct from canon/scripts/canon_preflight.sh
# (that is a CANON-module hook, a different concern).
#
# Usage: tools/factory/factory-preflight.sh [--check]
#   --check  also run `python ledger/build_ledger.py --check` (offline-deterministic).
# Exit: non-zero on any HARD fail (detached HEAD, >1 other ledger PR, Redis down).
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$REPO_ROOT" ] || { echo "FAIL: not inside a git repository"; exit 1; }
cd "$REPO_ROOT"

FAIL=0
pass() { printf '  [PASS] %s\n' "$1"; }
warn() { printf '  [WARN] %s\n' "$1"; }
fail() { printf '  [FAIL] %s\n' "$1"; FAIL=1; }

echo "== factory-preflight (read-only) =="

# 1. NAMED BRANCH (fail if detached)
if BR="$(git symbolic-ref --quiet --short HEAD)"; then pass "named branch: $BR"
else fail "detached HEAD — check out a named branch before any push"; BR=""; fi

# 1a. BRANCH-NAME (ADR-060) — verbatim parity with .github/workflows/guardian.yml
#     (guardian-branch-naming). Surfaces a non-compliant <id> (e.g. a hyphen) at STEP-0
#     instead of only at push-time (see PR #1125's 'gh-guard' block).
if [ -n "$BR" ]; then
  ADR060_PATTERN='^agent/(central|right|factory|specproj)/[A-Za-z0-9]+/[a-z0-9._-]+$'
  if printf '%s' "$BR" | grep -qE '^(dependabot|renovate|revert)/'; then
    pass "branch-name (ADR-060): allow-listed prefix ($BR)"
  elif printf '%s' "$BR" | grep -qE "$ADR060_PATTERN"; then
    pass "branch-name (ADR-060): $BR"
  else
    fail "branch '$BR' violates ADR-060 agent/<actor>/<id>/<slug> — <id> must be [A-Za-z0-9]+ (no hyphen); see guardian-branch-naming"
  fi
fi

# 1b. ACTIVE-GH-ACCOUNT (HARD): factory git/gh ops MUST run as the canonical account.
#     Carmi61 is retained for occasional operator confirmations only — never the active
#     account during factory work (docs/governance/CANONICAL-GH-ACCOUNT.md, ADR-170).
EXPECT_GH="CarmiBanxe"
ACTIVE_GH="$(gh api user -q .login 2>/dev/null || echo "")"
if [ -z "$ACTIVE_GH" ]; then warn "gh not authenticated / offline — cannot verify active account (expected $EXPECT_GH)"
elif [ "$ACTIVE_GH" = "$EXPECT_GH" ]; then pass "active-gh-account: $ACTIVE_GH"
else fail "active gh account '$ACTIVE_GH' != '$EXPECT_GH' — run: gh auth switch --user $EXPECT_GH  (Carmi61 is confirmations-only)"; fi

# 2. FETCH
if git fetch --all --prune >/dev/null 2>&1; then pass "git fetch --all --prune"
else warn "git fetch failed (offline?) — base-drift/singleton checks may be stale"; fi

# 3. BASE-DRIFT vs origin/main (informational; CI main-serialize enforces)
if git rev-parse --verify --quiet origin/main >/dev/null; then
  BEHIND="$(git rev-list --count HEAD..origin/main 2>/dev/null || echo '?')"
  AHEAD="$(git rev-list --count origin/main..HEAD 2>/dev/null || echo '?')"
  if [ "$BEHIND" = "0" ]; then pass "base-drift: behind=0 ahead=$AHEAD (up-to-date with origin/main)"
  else fail "stale main: behind=$BEHIND — run git pull --ff-only origin main before starting a sprint (ADR-170)"; fi
else warn "origin/main not found — cannot compute base-drift"; fi

# 4. SINGLETON-OPEN: at most one OTHER open ledger-touching PR (LEDGER-MERGE-QUEUE single-writer)
LEDGER_RE='INSTRUCTION-LEDGER|IL-SEQUENCE|ledger/entries|governance/'
if command -v gh >/dev/null 2>&1; then
  CUR_PR=""
  [ -n "$BR" ] && CUR_PR="$(gh pr list --head "$BR" --state open --json number --jq '.[0].number' 2>/dev/null || true)"
  OTHERS=""
  for n in $(gh pr list --state open --json number --jq '.[].number' 2>/dev/null); do
    [ "$n" = "$CUR_PR" ] && continue
    paths="$(gh pr view "$n" --json files --jq '.files[].path' 2>/dev/null || true)"
    if printf '%s\n' "$paths" | grep -qE "$LEDGER_RE"; then OTHERS="$OTHERS #$n"; fi
  done
  OTHERS="${OTHERS# }"
  CNT=0; [ -n "$OTHERS" ] && CNT="$(printf '%s\n' $OTHERS | wc -l | tr -d ' ')"
  if [ "$CNT" -ge 1 ]; then
    fail "singleton-open: $CNT OTHER ledger-touching PR(s) open ($OTHERS) — single-writer violated; see docs/governance/LEDGER-MERGE-QUEUE.md"
  else pass "singleton-open: no other ledger-touching PR open (LEDGER-MERGE-QUEUE single-writer OK)"; fi
else warn "gh not available — cannot check singleton-open"; fi

# 5. REDIS allocator (ADR-143) — PING via REDISCLI_AUTH (never echo secret)
ENV_FILE="${REDIS_ENV_FILE:-$HOME/banxe-dev/redis-evo1.env}"
if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  set -a; . "$ENV_FILE"; set +a
  RH="${REDIS_HOST:-100.68.102.48}"; RP="${REDIS_PORT:-6379}"
  REDISCLI_AUTH="${REDIS_PASSWORD:-${REDIS_AUTH:-${REDIS_PASS:-}}}"; export REDISCLI_AUTH
  if [ -z "$REDISCLI_AUTH" ]; then fail "redis: no password var in $ENV_FILE (REDIS_PASSWORD/REDIS_AUTH/REDIS_PASS)"
  else
    PONG="$(redis-cli -h "$RH" -p "$RP" PING 2>&1 || true)"
    if [ "$PONG" = "PONG" ]; then pass "redis allocator PING=PONG ($RH:$RP)"
    else fail "redis allocator unreachable/auth ($RH:$RP): $PONG"; fi
  fi
  unset REDISCLI_AUTH
else warn "redis env file not found ($ENV_FILE) — allocator check skipped"; fi

# 5b. LEDGER-WRITER-LOCK (advisory, read-only). Surfaces cross-terminal contention
#     EARLY: if this branch is ledger-touching and another terminal currently holds
#     banxe:ledger:writer, warn (do NOT fail — the lock is acquired at PUSH time, not
#     preflight; this is just an early heads-up). ADR-170 advisory writer-lock.
LEDGER_RE_LOCK='INSTRUCTION-LEDGER|IL-SEQUENCE|ledger/entries|governance/|docs/adr/|\.py$'
# branch is ledger-touching if its committed delta OR working-tree changes hit those paths
LEDGER_TOUCH="$( { git diff --name-only origin/main...HEAD 2>/dev/null; git status --porcelain 2>/dev/null | sed 's/^...//'; } | grep -E "$LEDGER_RE_LOCK" | head -1 || true )"
if [ -n "$LEDGER_TOUCH" ] && [ -f "$ENV_FILE" ] && command -v redis-cli >/dev/null 2>&1; then
  # shellcheck disable=SC1090
  set -a; . "$ENV_FILE"; set +a
  RH="${REDIS_HOST:-100.68.102.48}"; RP="${REDIS_PORT:-6379}"
  REDISCLI_AUTH="${REDIS_PASSWORD:-${REDIS_AUTH:-${REDIS_PASS:-}}}"; export REDISCLI_AUTH
  MY_ID="$( [ -f .TERMINAL-ROLE ] && head -1 .TERMINAL-ROLE || hostname )"
  HOLDER="$(redis-cli -h "$RH" -p "$RP" GET banxe:ledger:writer 2>/dev/null || true)"
  if [ -n "$HOLDER" ] && [ "$HOLDER" != "$MY_ID" ]; then
    warn "ledger-writer-lock: held by '$HOLDER' (you are '$MY_ID') — another terminal may be mid-ledger-write; coordinate before push (advisory, ADR-170)"
  else
    pass "ledger-writer-lock: free or self ('${HOLDER:-unset}'; you are '$MY_ID')"
  fi
  unset REDISCLI_AUTH
fi

# 6. Optional --check (offline-deterministic ledger rebuild verify)
if [ "${1:-}" = "--check" ]; then
  PY="$(command -v python3 || command -v python || true)"
  if [ -z "$PY" ]; then fail "build_ledger --check: no python3/python interpreter found"
  elif OUT="$("$PY" ledger/build_ledger.py --check 2>&1)"; then pass "build_ledger --check: $OUT"
  else fail "build_ledger --check: $OUT"; fi
fi

echo "== summary: $([ "$FAIL" -eq 0 ] && echo 'ALL HARD CHECKS PASS' || echo 'HARD FAIL — see [FAIL] above') =="
exit "$FAIL"
