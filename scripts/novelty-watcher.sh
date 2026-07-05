#!/usr/bin/env bash
# scripts/novelty-watcher.sh
# B->A novelty auto-handoff pipeline — factory-watcher v1 (PROPOSED, in-repo).
#
# Role (ADR-159 §D-2, §D-3):
#   For each row in governance/NOVELTY-COLLECTION-REGISTER.md with status=NEW
#   whose finding-item is NOT already present in governance/NOVELTY-HANDOFF-QUEUE.md,
#   run the A-side hand-off chain (idempotent, single-writer):
#     picked  -> semantic-scoring (>= threshold from novelty-pipeline-config.yaml)
#             -> ROADMAP-MATRIX update
#             -> planned
#             -> processed
#
# Discipline (v1):
#   * SINGLE-WRITER on governance/NOVELTY-HANDOFF-QUEUE.md — this script is the
#     only writer. Neither the GitHub Actions workflow nor any other agent
#     commits to the QUEUE.
#   * IDEMPOTENT — rows already tracked in the QUEUE are skipped, matched by
#     finding-item slug. Re-running is safe.
#   * NO AUTO-COMMIT / NO AUTO-PUSH (v1) — this watcher writes to the working
#     tree ONLY and logs the intended change. The commit + PR step is a
#     separate operator-driven action (or a future v2 that uses a scoped
#     factory PAT + PR-open; not shipped here). This keeps the destructive-
#     action / production-state stop-barrier (CLAUDE.md §11, safety-rules.md)
#     intact for v1.
#   * NO SECRETS — LITELLM_KEY is read from the environment; the script itself
#     contains NO literal keys. The systemd unit's EnvironmentFile is a
#     placeholder path, not a value (see systemd/novelty-watcher.service).
#   * NOT DAEMONIZED HERE — the systemd unit/timer are in-repo templates only;
#     enable/start on evo1 is operator-driven per ADR-159 §Implementation.
#
# Semantic-scoring HOOK (v1 = STUB):
#   The LiteLLM :4000 call for novelty scoring is intentionally stubbed for v1
#   (echo "score-hook: v1 stub, treat as novel"). The real hook (TODO) will:
#     - candidate extraction -> alias glm-air on evo1 (fast, short-context)
#     - semantic verification -> alias reasoning-235b on evo2 (async lane)
#     - threshold read from governance/novelty-pipeline-config.yaml (default
#       cosine < 0.85 == novel; see ADR-159 §D-4 / OI-1).
#     - key from env LITELLM_KEY (NEVER hardcoded).
#
# Anchors: ADR-159 (B->A pipeline), governance/novelty-pipeline-config.yaml
# (Central-owned config), .claude/rules/parallel-session-isolation.md (Rules 1-7),
# CLAUDE.md §71 (HITL merge), safety-rules.md (destructive-op verify-step).

set -euo pipefail

# --------------------------------------------------------------------------
# Locate repo root (this script lives at <root>/scripts/).
# --------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

REGISTER="governance/NOVELTY-COLLECTION-REGISTER.md"
QUEUE="governance/NOVELTY-HANDOFF-QUEUE.md"
CONFIG="governance/novelty-pipeline-config.yaml"
ROADMAP="docs/ROADMAP-MATRIX.md"

log() { printf 'novelty-watcher: %s\n' "$*" >&2; }
die() { printf 'novelty-watcher: ERROR: %s\n' "$*" >&2; exit 1; }

# --------------------------------------------------------------------------
# Preflight — required files must exist. Read-only checks (no state change).
# --------------------------------------------------------------------------
[ -f "${REGISTER}" ] || die "missing register: ${REGISTER}"
[ -f "${QUEUE}" ]    || die "missing queue: ${QUEUE}"
[ -f "${CONFIG}" ]   || die "missing config: ${CONFIG}"
[ -f "${ROADMAP}" ]  || die "missing roadmap: ${ROADMAP}"

# --------------------------------------------------------------------------
# Fetch origin/main so any downstream operator step (commit/PR) rebases
# cleanly. This is a read-only network op; no local branch is mutated.
# --------------------------------------------------------------------------
if git remote get-url origin >/dev/null 2>&1; then
  git fetch origin main --quiet || log "warn: git fetch origin main failed (offline?); continuing"
fi

# --------------------------------------------------------------------------
# Semantic-scoring HOOK — v1 stub. Real invocation is a TODO.
#
# TODO(v2): call LiteLLM :4000 with model `project-reason`, split as:
#     candidate extraction  -> glm-air (evo1)  [fast lane, short context]
#     semantic verification -> reasoning-235b (evo2, async)
#   Threshold read from ${CONFIG} .novelty_check.threshold (default 0.85).
#   Auth: bearer from env $LITELLM_KEY (NEVER hardcoded here).
# --------------------------------------------------------------------------
score_hook() {
  local item="$1"
  # LITELLM_KEY is only referenced to make the env-dependency explicit;
  # v1 does NOT dereference it (stub only). It MUST NOT appear in output.
  : "${LITELLM_KEY:=unset}"
  printf 'score-hook: v1 stub, treat as novel (item=%s)\n' "${item}" >&2
  # v1 always classifies as "novel" so the hand-off chain proceeds end-to-end.
  echo "novel"
}

# --------------------------------------------------------------------------
# Extract finding-item slugs already recorded in the QUEUE (any status).
# Used for idempotency: skip items already picked up.
# --------------------------------------------------------------------------
queue_has_item() {
  local item="$1"
  # A queue data row starts with "| <int> |" (event column is monotonic int).
  # Column 2 is the finding-item. Grep is intentionally strict.
  awk -F'|' '
    /^\|[[:space:]]*[0-9]+[[:space:]]*\|/ {
      # $3 is the finding-item column (fields are 1-indexed; leading | -> $1 empty).
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $3)
      if ($3 == item) found = 1
    }
    END { exit(found ? 0 : 1) }
  ' item="${item}" "${QUEUE}"
}

# --------------------------------------------------------------------------
# Compute the next monotonic event number by scanning existing rows.
# --------------------------------------------------------------------------
next_event_no() {
  local max
  max=$(awk -F'|' '
    /^\|[[:space:]]*[0-9]+[[:space:]]*\|/ {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
      if ($2+0 > m) m = $2+0
    }
    END { print m+0 }
  ' "${QUEUE}")
  echo $((max + 1))
}

# --------------------------------------------------------------------------
# Append one event row to the QUEUE (single-writer).
# Args: <finding-item> <status> <roadmap-ref> <sprint-ref>
# --------------------------------------------------------------------------
append_queue_event() {
  local item="$1" status="$2" roadmap_ref="$3" sprint_ref="$4"
  local ts ev
  ts=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
  ev=$(next_event_no)
  printf '| %d | %s | %s | %s | %s | %s |\n' \
    "${ev}" "${item}" "${status}" "${roadmap_ref}" "${sprint_ref}" "${ts}" \
    >> "${QUEUE}"
  log "queue append: event=${ev} item=${item} status=${status}"
}

# --------------------------------------------------------------------------
# Append a hand-off marker row to ROADMAP-MATRIX.md (mandatory hand-off).
# v1 = one anchor line per finding, appended at file bottom (no in-place
# edit of existing rows — preserves matrix integrity).
# --------------------------------------------------------------------------
append_roadmap_marker() {
  local item="$1"
  local ts
  ts=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
  {
    printf '\n<!-- novelty-handoff v1: %s @ %s (ADR-159 mandatory hand-off) -->\n' \
      "${item}" "${ts}"
    printf -- '- **Hand-off (novelty):** `%s` — queued for sprint planning per ADR-159 §D-3.\n' \
      "${item}"
  } >> "${ROADMAP}"
  log "roadmap append: marker for item=${item}"
  # roadmap-ref used in QUEUE row = the item slug itself for v1 (stable anchor).
  echo "roadmap:${item}"
}

# --------------------------------------------------------------------------
# Parse NEW-status rows from the register.
# Output: one finding-item slug per line.
# --------------------------------------------------------------------------
extract_new_items() {
  awk -F'|' '
    /^\|[[:space:]]*-+/ { next }         # separator row
    /^\| item[[:space:]]*\|/ { next }    # header row
    /^\|/ {
      # Expected columns:
      # | item | source-repo | floor | type | value | dedup | verdict | handoff | status |
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)   # item
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $10)  # status (10 = trailing bar splits into 11 fields; last data = $10)
      if ($10 == "NEW" || $10 == "OPEN" ) {
        # OPEN kept for backward compat with existing register schema; treat
        # both as "not-yet-picked" for v1 detection so scaffolding is
        # meaningful against the current register. Terminal-B algorithm §D-1
        # will migrate to strict "NEW" once the pipeline goes hot.
        print $2
      }
    }
  ' "${REGISTER}"
}

# --------------------------------------------------------------------------
# Main loop — process each NEW/OPEN item not yet in the QUEUE.
# --------------------------------------------------------------------------
processed_count=0
skipped_count=0
new_items=$(extract_new_items || true)

if [ -z "${new_items}" ]; then
  log "no NEW/OPEN items in ${REGISTER}; nothing to do"
  exit 0
fi

while IFS= read -r item; do
  [ -z "${item}" ] && continue
  if queue_has_item "${item}"; then
    log "skip (already in queue): ${item}"
    skipped_count=$((skipped_count + 1))
    continue
  fi

  # 1. picked
  append_queue_event "${item}" "picked" "-" "-"

  # 2. semantic-scoring hook (v1 stub — always novel)
  verdict=$(score_hook "${item}")
  if [ "${verdict}" != "novel" ]; then
    append_queue_event "${item}" "processed" "-" "verdict=duplicate"
    log "hook classified duplicate: ${item}"
    processed_count=$((processed_count + 1))
    continue
  fi

  # 3. ROADMAP-MATRIX update (mandatory hand-off, ADR-159 §D-3)
  roadmap_ref=$(append_roadmap_marker "${item}")

  # 4. planned (roadmap-ref recorded)
  append_queue_event "${item}" "planned" "${roadmap_ref}" "-"

  # 5. processed (terminal for A-side; sprint-ref left as TODO for v1 — a
  #    future v2 hook wires this into the sprint tracker automatically).
  append_queue_event "${item}" "processed" "${roadmap_ref}" "TODO-sprint-v2"

  processed_count=$((processed_count + 1))
done <<EOF
${new_items}
EOF

log "done: processed=${processed_count} skipped=${skipped_count}"

# Remind operator that v1 does NOT auto-commit/push.
log "v1 discipline: working tree modified in-place; commit + PR = operator step."
