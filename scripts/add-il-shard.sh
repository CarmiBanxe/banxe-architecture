#!/usr/bin/env bash
# scripts/add-il-shard.sh — one-command IL shard create.
#
# Fulfils the ORPHANED intent of merged shard `agent-factory-ledgersync-add-shard-script`
# (status PREPARED, but the actual script file never landed). Canonical procedure lives
# in ledger/SHARD-WORKFLOW.md (ADR-059 S4) — this script AUTOMATES that procedure and
# adds a FAIL-CLOSED Redis allocator precheck (ADR-143) so we never silently degrade to
# the local `max+1` path that caused the IL-827 duplicate.
#
# NOTE: INSTRUCTION-LEDGER.md and IL-SEQUENCE.json are gitignored and rebuilt
# automatically on main by .github/workflows/ledger-rebuild.yml after each merge.
# This script ONLY creates shard files in branches — no build_ledger.py invocation.
#
# Usage:
#   bash scripts/add-il-shard.sh <session-slug> <description>
#   bash scripts/add-il-shard.sh --help
#
# Refs: ADR-056, ADR-057, ADR-059, ADR-119, ADR-133, ADR-143, ledger/SHARD-WORKFLOW.md.

set -euo pipefail

REDIS_HOST_DEFAULT='127.0.0.1'   # align with build_ledger.py post-#990 default (banxe-redis host-net on localhost); prior 100.68.102.48 was the evo1 tailscale IP which is not reachable from every terminal
REDIS_PORT_DEFAULT='6379'
REDIS_HOST="${REDIS_HOST:-$REDIS_HOST_DEFAULT}"
REDIS_PORT="${REDIS_PORT:-$REDIS_PORT_DEFAULT}"
REDIS_RETRIES="${REDIS_RETRIES:-3}"          # attempts before fail-closed (T1, EVO1-ALLOCATOR-STABILITY-2026-08-02)
REDIS_BACKOFF="${REDIS_BACKOFF:-5 10 15}"    # seconds between attempts (space-separated; last reused)
ALLOCATOR_MODE="${BANXE_IL_ALLOCATOR:-redis}"   # matches build_ledger.py default

die() { printf 'add-il-shard: ERROR: %s\n' "$*" >&2; exit 1; }
info() { printf 'add-il-shard: %s\n' "$*" >&2; }

usage() {
  cat <<'EOF'
Usage:
  bash scripts/add-il-shard.sh <session-slug> <description>
  bash scripts/add-il-shard.sh --help

Arguments:
  <session-slug>  Free-form; normalised to session_id (lowercase; [^a-z0-9] -> '-';
                  squeeze repeats; trim '-').
  <description>   Short one-line description (goes into the shard body Instruction line).

Behaviour (per ledger/SHARD-WORKFLOW.md):
  1. Compute session_id (normalised slug) and salt = sha1(session_id)[:6].
  2. il_ts = current UTC (ISO8601Z); if <= current max shard il_ts, bump strictly greater.
  3. Write ledger/entries/<session_id>/IL-<il_ts_filename>--<salt>.md with front-matter
     (il_ts, session_id, source=agent-factory, status=DONE) + body.
  4. Stage shard file via git add.
  (NOTE: IL-SEQUENCE.json and INSTRUCTION-LEDGER.md are rebuilt on main by CI.)

Fail-closed Redis precheck (ADR-143 / IL-827 duplicate root cause):
  When BANXE_IL_ALLOCATOR != 'local' (the default 'redis' mode), this script REQUIRES
  the shared allocator to be reachable BEFORE minting. Target:
    REDIS_HOST (default 127.0.0.1)     : REDIS_PORT (default 6379)
    REDIS_RETRIES (default 3)          — precheck attempts before fail-closed
    REDIS_BACKOFF (default "5 10 15")  — seconds between attempts (space-separated;
                                         the last value is reused if fewer values
                                         than attempts). Retry only widens the
                                         transient window (evo1 load spikes) —
                                         fail-closed semantics are UNCHANGED.
  If TCP connect fails after all attempts, the script exits non-zero WITHOUT minting — no automatic
  fallback to local max+1 (that silent fallback caused the IL-827 duplicate on
  concurrent terminals). To mint offline on a single terminal at your own risk:
    BANXE_IL_ALLOCATOR=local bash scripts/add-il-shard.sh <slug> <desc>

Exit codes:
  0  success
  1  usage / argument / normalisation error
  2  ledger build/check failure
  3  fail-closed: shared Redis allocator unreachable in Redis mode
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

# Locate repo root (this script lives at <root>/scripts/) and cd there — the ledger
# builder MUST be invoked from the repo root (ROOT is derived from build_ledger.py's
# own location, but working-dir-relative paths in the shard-write below need root).
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

[ -f "ledger/build_ledger.py" ] || die "not a Banxe ledger repo (missing ledger/build_ledger.py) at $REPO_ROOT"
[ -f "ledger/SHARD-WORKFLOW.md" ] || die "missing ledger/SHARD-WORKFLOW.md — expected canonical procedure at $REPO_ROOT"

if [ $# -ne 2 ]; then
  usage
  die "expected 2 arguments (session-slug, description) — got $#"
fi

RAW_SLUG="$1"
DESC="$2"

[ -n "$RAW_SLUG" ] || die "session-slug is empty"
[ -n "$DESC" ] || die "description is empty"

# --- session_id normalisation: lowercase; [^a-z0-9] -> '-'; squeeze; trim '-'. ---
SID="$(printf '%s' "$RAW_SLUG" \
       | tr '[:upper:]' '[:lower:]' \
       | sed -E 's/[^a-z0-9]+/-/g; s/-+/-/g; s/^-+//; s/-+$//')"
[ -n "$SID" ] || die "session_id is empty after normalisation of '$RAW_SLUG'"

# --- salt = sha1(session_id)[:6] ---
SALT="$(printf '%s' "$SID" | sha1sum | cut -c1-6)"

# --- il_ts: current UTC. Front-matter uses ':'; filename replaces ':' with '-'. ---
FRONT_TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Ensure il_ts is STRICTLY greater than the current max shard il_ts so build_ledger's
# (il_ts, session_id, path)-sorted assignment places this shard at the tail. If a same-
# second collision would occur, bump by one second (bounded loop; hard fail after 120s).
CURR_MAX_TS="$(python3 - <<'PY'
import pathlib, re
root = pathlib.Path.cwd()
entries = root / "ledger" / "entries"
front = re.compile(r"^il_ts:\s*(\S+)", re.MULTILINE)
best = ""
if entries.is_dir():
    for p in entries.rglob("IL-*.md"):
        try:
            txt = p.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            continue
        m = front.search(txt)
        if m and m.group(1) > best:
            best = m.group(1)
print(best)
PY
)"

if [ -n "$CURR_MAX_TS" ] && [[ ! "$FRONT_TS" > "$CURR_MAX_TS" ]]; then
  bump=1
  now_s="$(date -u +%s)"
  while [[ ! "$FRONT_TS" > "$CURR_MAX_TS" ]]; do
    FRONT_TS="$(date -u -d "@$(( now_s + bump ))" +%Y-%m-%dT%H:%M:%SZ)"
    bump=$((bump + 1))
    if [ "$bump" -gt 120 ]; then
      die "cannot advance il_ts past current max ($CURR_MAX_TS) within 120s window"
    fi
  done
  info "il_ts bumped by ${bump}s to stay strictly > current max ($CURR_MAX_TS)"
fi

FILE_TS="${FRONT_TS//:/-}"
SHARD_DIR="ledger/entries/$SID"
SHARD_FILE="$SHARD_DIR/IL-${FILE_TS}--${SALT}.md"

if [ -e "$SHARD_FILE" ]; then
  die "shard already exists: $SHARD_FILE (refuse to overwrite — append-only)"
fi

# --- FAIL-CLOSED Redis allocator precheck (ADR-143 / IL-827 duplicate root cause) ---
# T1 (docs/runbooks/EVO1-ALLOCATOR-STABILITY-2026-08-02.md): retry-with-backoff widens
# the transient window (evo1 load spikes) BEFORE the unchanged fail-closed exit 3.
# NEVER falls back to local — after all attempts the original Remedies + exit 3 apply.
redis_reachable() { timeout 3 bash -c ": >/dev/tcp/${REDIS_HOST}/${REDIS_PORT}" 2>/dev/null; }

allocator_lc="$(printf '%s' "$ALLOCATOR_MODE" | tr '[:upper:]' '[:lower:]')"
if [ "$allocator_lc" != "local" ]; then
  read -r -a backoffs <<< "$REDIS_BACKOFF"
  reachable=0
  attempt=1
  while [ "$attempt" -le "$REDIS_RETRIES" ]; do
    if redis_reachable; then
      info "Redis allocator OK (attempt ${attempt}): ${REDIS_HOST}:${REDIS_PORT}"
      reachable=1
      break
    fi
    if [ "$attempt" -lt "$REDIS_RETRIES" ]; then
      idx=$((attempt - 1))
      if [ "${#backoffs[@]}" -eq 0 ]; then
        delay=5
      else
        [ "$idx" -ge "${#backoffs[@]}" ] && idx=$(( ${#backoffs[@]} - 1 ))
        delay="${backoffs[$idx]}"
      fi
      printf 'add-il-shard: allocator unreachable (attempt %s/%s) — retrying in %ss...\n' \
        "$attempt" "$REDIS_RETRIES" "$delay" >&2
      sleep "$delay"
    else
      printf 'add-il-shard: allocator unreachable (attempt %s/%s)\n' \
        "$attempt" "$REDIS_RETRIES" >&2
    fi
    attempt=$((attempt + 1))
  done
  if [ "$reachable" -ne 1 ]; then
    {
      printf 'add-il-shard: FAIL-CLOSED — shared Redis allocator %s:%s unreachable.\n' \
        "$REDIS_HOST" "$REDIS_PORT"
      printf '  ADR-143 requires the atomic INCR counter for cross-terminal anti-collision.\n'
      printf '  The silent local max+1 fallback caused the IL-827 duplicate — this script\n'
      printf '  refuses to mint in Redis mode when the allocator is unreachable.\n'
      printf '  Remedies (pick ONE):\n'
      printf '    1. Bring up the shared Redis (evo1) and retry.\n'
      printf '    2. Point REDIS_HOST / REDIS_PORT at the reachable allocator.\n'
      printf '    3. At your own risk, single-terminal only:\n'
      printf '         BANXE_IL_ALLOCATOR=local bash scripts/add-il-shard.sh <slug> <desc>\n'
    } >&2
    exit 3
  fi
else
  info "BANXE_IL_ALLOCATOR=local — offline max+1 mint (explicit opt-in, single-terminal only)"
fi

# --- Write the shard (append-only; no il_number field — assigned by build_ledger). ---
mkdir -p "$SHARD_DIR"

# Strip control chars from description so a malformed input can't break YAML.
CLEAN_DESC="$(printf '%s' "$DESC" | tr -d '\r' | tr -d '\000-\010\013\014\016-\037')"

{
  printf '%s\n' '---'
  printf 'il_ts: %s\n' "$FRONT_TS"
  printf 'session_id: %s\n' "$SID"
  printf 'source: %s\n' 'agent-factory'
  printf 'status: %s\n' 'DONE'
  printf '%s\n' '---'
  printf '### %s\n\n' "$SID"
  printf -- '- **Instruction:** %s\n' "$CLEAN_DESC"
  printf -- '- **Refs:** ADR-056, ADR-057, ADR-059, ADR-119, ADR-143, ledger/SHARD-WORKFLOW.md\n'
} > "$SHARD_FILE"

info "wrote shard $SHARD_FILE"

# --- Stage shard file (ledger rebuild happens on main by CI). ---
git add "$SHARD_FILE"
info "staged shard: $SHARD_FILE"

# --- Note: IL-NNN will be assigned when this PR is merged and the CI rebuild job runs. ---
info "(IL number will be assigned by ledger-rebuild.yml workflow after merge to main)"
