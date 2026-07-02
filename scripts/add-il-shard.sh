#!/usr/bin/env bash
# scripts/add-il-shard.sh — one-command IL shard create + ledger rebuild.
#
# Fulfils the ORPHANED intent of merged shard `agent-factory-ledgersync-add-shard-script`
# (status PREPARED, but the actual script file never landed). Canonical procedure lives
# in ledger/SHARD-WORKFLOW.md (ADR-059 S4) — this script AUTOMATES that procedure and
# adds a FAIL-CLOSED Redis allocator precheck (ADR-143) so we never silently degrade to
# the local `max+1` path that caused the IL-827 duplicate.
#
# Usage:
#   bash scripts/add-il-shard.sh <session-slug> <description>
#   bash scripts/add-il-shard.sh --help
#
# Refs: ADR-056, ADR-057, ADR-059, ADR-119, ADR-133, ADR-143, ledger/SHARD-WORKFLOW.md.

set -euo pipefail

REDIS_HOST_DEFAULT='100.68.102.48'
REDIS_PORT_DEFAULT='6379'
REDIS_HOST="${REDIS_HOST:-$REDIS_HOST_DEFAULT}"
REDIS_PORT="${REDIS_PORT:-$REDIS_PORT_DEFAULT}"
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
     (il_ts, session_id, source=agent-factory, status=DONE) + body. NO il_number.
  4. Run: python3 ledger/build_ledger.py       (mints IL-NNN via ADR-143 allocator).
  5. Run: python3 ledger/build_ledger.py --check (must exit 0).

Fail-closed Redis precheck (ADR-143 / IL-827 duplicate root cause):
  When BANXE_IL_ALLOCATOR != 'local' (the default 'redis' mode), this script REQUIRES
  the shared allocator to be reachable BEFORE minting. Target:
    REDIS_HOST (default 100.68.102.48) : REDIS_PORT (default 6379)
  If TCP connect fails, the script exits non-zero WITHOUT minting — no automatic
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
allocator_lc="$(printf '%s' "$ALLOCATOR_MODE" | tr '[:upper:]' '[:lower:]')"
if [ "$allocator_lc" != "local" ]; then
  if ! timeout 3 bash -c ": >/dev/tcp/${REDIS_HOST}/${REDIS_PORT}" 2>/dev/null; then
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
  info "Redis allocator OK: ${REDIS_HOST}:${REDIS_PORT}"
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

# --- Regenerate ledger (mints IL-NNN via ADR-143 allocator on write path). ---
if ! python3 ledger/build_ledger.py; then
  die "build_ledger.py write failed — shard left on disk at $SHARD_FILE for inspection"
fi

# --- Verify determinism + append-only invariants. ---
if ! python3 ledger/build_ledger.py --check; then
  exit 2
fi

# --- Report the minted IL number. ---
python3 - "$SHARD_FILE" "$SID" <<'PY'
import hashlib, json, pathlib, sys
shard_rel, session_id = sys.argv[1], sys.argv[2]
root = pathlib.Path.cwd()
seq_path = root / "ledger" / "IL-SEQUENCE.json"
seq = json.loads(seq_path.read_text(encoding="utf-8"))
key = session_id + "__" + hashlib.sha1(shard_rel.encode("utf-8")).hexdigest()[:12]
num = seq.get(key)
if num is None:
    sys.stderr.write("add-il-shard: WARN: minted number for %s not found in IL-SEQUENCE.json\n" % shard_rel)
    sys.exit(0)
print("IL-%03d" % num)
PY
