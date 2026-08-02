#!/usr/bin/env bash
# gitnexus-freshen.sh — freshness mechanism for the GitNexus code graph.
#
# LICENSE: GitNexus = PolyForm-Noncommercial-1.0.0. Sandbox/TRAINING use only
# (GITNEXUS_ENV=sandbox); PROD/commercial use requires a purchased license.
#
# CANON (ADR-176 red line): the graph is an ANALYTICAL dev-plane cache —
# regenerable in ~25s, never a record, never a runtime dependency. Freshness may
# label/warn, NEVER block (FAIL-SOFT: every error path exits 0 with a warning).
# ADR-102: ONE graph per repo; THIS script is the graph's ONLY writer.
# .gitnexus/ stays local + gitignored, keep-1 (cache, not record).
#
# What it does (idempotent, worktree-safe):
#   1. Read indexed_commit from .gitnexus/graph-stamp.json (absent -> "none").
#   2. Compare with HEAD and origin/main.
#   3. If stale: take the lockfile, re-index (gitnexus analyze), release.
#   4. Write .gitnexus/graph-stamp.json:
#      {indexed_commit, indexed_at, main_head, commits_behind, verdict FRESH|STALE}
#
# Consumers (detect_impact / emit_org_overlay readers) MUST read graph-stamp.json
# and label reports from a STALE graph — see
# docs/architecture/gitnexus-two-terminal-protocol.md (ARBITER RULE).
#
# ── Operator install snippets (DOCUMENTED ONLY — installing = operator act) ──
# (a) post-merge hook (worktree-safe via --git-path):
#       cat > "$(git rev-parse --git-path hooks)/post-merge" <<'HOOK'
#       #!/usr/bin/env bash
#       exec bash "$(git rev-parse --show-toplevel)/scripts/gitnexus-freshen.sh" || true
#       HOOK
#       chmod +x "$(git rev-parse --git-path hooks)/post-merge"
# (b) daily cron backstop:
#       17 6 * * * cd $HOME/banxe-architecture && bash scripts/gitnexus-freshen.sh >/dev/null 2>&1
# ─────────────────────────────────────────────────────────────────────────────
set -u  # NO -e: fail-soft by contract — errors warn and exit 0.

warn() { printf 'gitnexus-freshen: WARN: %s\n' "$*" >&2; }
info() { printf 'gitnexus-freshen: %s\n' "$*" >&2; }

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { warn "not a git repo"; exit 0; }
cd "$REPO_ROOT" || { warn "cannot cd to repo root"; exit 0; }
REPO_NAME="$(basename "$REPO_ROOT")"
STAMP_DIR="$REPO_ROOT/.gitnexus"
STAMP="$STAMP_DIR/graph-stamp.json"
LOCK="/tmp/gitnexus-freshen.${REPO_NAME}.lock"

HEAD_SHA="$(git rev-parse HEAD 2>/dev/null)" || { warn "no HEAD"; exit 0; }
MAIN_HEAD="$(git rev-parse origin/main 2>/dev/null || echo "$HEAD_SHA")"

indexed_commit="none"
if [ -f "$STAMP" ]; then
  indexed_commit="$(python3 -c "import json;print(json.load(open('$STAMP')).get('indexed_commit','none'))" 2>/dev/null || echo none)"
fi

write_stamp() {  # write_stamp <indexed_commit>
  mkdir -p "$STAMP_DIR" 2>/dev/null || { warn "cannot create $STAMP_DIR"; return 0; }
  behind="$(git rev-list --count "${1}..${MAIN_HEAD}" 2>/dev/null || echo unknown)"
  verdict="STALE"
  [ "$behind" = "0" ] && verdict="FRESH"
  python3 - "$1" "$MAIN_HEAD" "$behind" "$verdict" "$STAMP" <<'PY' 2>/dev/null || warn "stamp write failed"
import datetime, json, sys
ic, mh, behind, verdict, path = sys.argv[1:6]
json.dump({"indexed_commit": ic,
           "indexed_at": datetime.datetime.now(datetime.timezone.utc)
                         .strftime("%Y-%m-%dT%H:%M:%SZ"),
           "main_head": mh,
           "commits_behind": behind if behind == "unknown" else int(behind),
           "verdict": verdict}, open(path, "w"), indent=2)
PY
}

if [ "$indexed_commit" = "$HEAD_SHA" ]; then
  info "graph already indexed at HEAD ($HEAD_SHA) — refreshing stamp only"
  write_stamp "$HEAD_SHA"
  exit 0
fi

if ! command -v gitnexus >/dev/null 2>&1; then
  warn "gitnexus binary not on PATH — stamping current state as-is (fail-soft, no block)"
  write_stamp "$indexed_commit"
  exit 0
fi

# ── lockfile: refuse concurrent re-index (mkdir is atomic); analyze-readers are
#    unaffected — the lock only serialises WRITERS (ADR-102: one graph, one writer).
if ! mkdir "$LOCK" 2>/dev/null; then
  warn "another freshen holds $LOCK — skipping (fail-soft); stamp untouched"
  exit 0
fi
trap 'rmdir "$LOCK" 2>/dev/null' EXIT

info "re-indexing ($indexed_commit -> $HEAD_SHA, ~25s)..."
if GITNEXUS_ENV=sandbox gitnexus analyze . --index-only --skip-agents-md >/dev/null 2>&1; then
  write_stamp "$HEAD_SHA"
  info "re-index OK; stamp written ($STAMP)"
else
  warn "gitnexus analyze failed — keeping previous graph; stamping honestly as stale"
  write_stamp "$indexed_commit"
fi
exit 0
