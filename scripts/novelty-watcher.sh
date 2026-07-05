#!/usr/bin/env bash
# scripts/novelty-watcher.sh
# B->A novelty auto-handoff pipeline — factory-watcher v2 (PROPOSED, in-repo).
#
# v2 changes vs v1.1 (see docs/canon/TERMINAL-B-OPERATING-CANON.md pointer,
# ADR-102 no-restatement — real reference only):
#   * score-hook un-stubbed: real LiteLLM :4000 semantic-scoring call
#     (OpenAI-compatible /v1/chat/completions, bearer $LITELLM_KEY, model
#     project-reason by default with glm-air / config-override supported).
#   * threshold read from ${CONFIG} .novelty_check.threshold — no hardcode
#     (>= threshold => duplicate; < threshold => novel; ADR-159 §D-4 / OI-1).
#   * FAIL-OPEN to "novel" when scoring unavailable — LITELLM_KEY missing /
#     placeholder ("<...>"), endpoint unreachable, or response unparseable.
#     Service NEVER crashes on scoring failure (set +e around the network
#     call, explicit rc capture, exit 0 unchanged). Terminal HITL merge gate
#     (CLAUDE.md §71) remains the correctness authority.
#   * Key hygiene: $LITELLM_KEY dereferenced ONLY inside the curl
#     Authorization header; never echoed to stdout/stderr; no key literal
#     in code or logs.
#
# v1.1 fixes vs v1 (shakeout defects observed 2026-07-05, PR #1033):
#   1. STATUS FILTER = strict NEW ONLY. Legacy statuses OPEN / IN-PROGRESS /
#      RESOLVED are GRANDFATHERED and skipped. v1 treated OPEN as a
#      backward-compat NEW-equivalent, which re-processed already-closed
#      findings (glm_air_distributed_second_reason_lane,
#      litellm_4000_orphan_reuseport, litellm_4000_single_listener_guard)
#      on every tick. ADR-159 §D-1 mandated strict NEW; v1.1 activates it.
#   2. OUTPUT = isolated worktree + operator draft-PR instruction. v1 wrote
#      into the shared checkout (~/banxe-architecture), leaving dirty state
#      that violates parallel-session-isolation Rule 6. v1.1 spawns/reuses
#      a dedicated linked worktree via scripts/bx-session.sh (ADR-120) off
#      freshly-fetched origin/main, writes there ONLY, and emits an
#      operator `gh pr create --draft` command for HITL merge (CLAUDE.md §71).
#   3. HOST = evo1. Install/enable happens on evo1 (`ssh evo1`), NOT Legion.
#      The systemd unit's WorkingDirectory/ExecStart resolve via %h to the
#      evo1 operator home. Legion is thin-client per Operator canon
#      Principle 1 / ADR-103 (server-only refactoring).
#
# Discipline (v1.1):
#   * SINGLE-WRITER on governance/NOVELTY-HANDOFF-QUEUE.md — this script is
#     the only writer. The GitHub Actions validator+detector workflow never
#     commits.
#   * IDEMPOTENT — rows already tracked in the QUEUE are skipped, matched by
#     finding-item slug.
#   * NO AUTO-COMMIT / NO AUTO-PUSH / NO AUTO-PR — v1.1 writes to the
#     isolated worktree ONLY and prints the exact operator command block.
#     The commit + push + `gh pr create --draft` step is operator-driven
#     (HITL, CLAUDE.md §11 §71, safety-rules.md destructive-op verify-step).
#   * NO SECRETS — LITELLM_KEY is env-only; the script contains NO literal
#     keys and MUST NOT log the value. The systemd EnvironmentFile is a
#     placeholder path — the operator populates the real file OUTSIDE the
#     repo with mode 0600 (see systemd/novelty-watcher.service).
#   * NOT DAEMONIZED HERE — the systemd unit/timer are in-repo templates
#     only; enable/start on evo1 is operator-driven.
#
# Semantic-scoring HOOK (v2 = REAL, un-stubbed):
#   Real scoring via LiteLLM :4000 (OpenAI-compatible), model project-reason
#   by default (LITELLM_MODEL env may override to glm-air etc.). Bearer from
#   env $LITELLM_KEY (systemd EnvironmentFile ~/.config/banxe/novelty-
#   watcher.env, mode 0600, operator-populated OUTSIDE the repo — NEVER
#   committed). Threshold from ${CONFIG} .novelty_check.threshold (0.85 per
#   ADR-159 §D-4 / OI-1). >= threshold => duplicate; < threshold => novel.
#   FAIL-OPEN to "novel" on any failure (key missing/placeholder, endpoint
#   down, HTTP != 200, response unparseable) + log "scoring unavailable ->
#   defaulting novel"; service never crashes (set +e around network call,
#   explicit rc capture). Endpoint override: LITELLM_ENDPOINT env,
#   default http://127.0.0.1:4000. Key hygiene: dereferenced only inside
#   the curl Authorization header; NEVER logged, NEVER printed.
#
# Anchors: ADR-159 (B->A pipeline), ADR-120 (per-session worktree),
# ADR-102 (dup-audit), ADR-103 (server-only build venue = evo1),
# governance/novelty-pipeline-config.yaml, CLAUDE.md §11 §71 (HITL merge),
# safety-rules.md, .claude/rules/parallel-session-isolation.md Rules 1-7.

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

# Reusable worktree branch for v1.1 batch runs (ADR-120). One dedicated
# worktree is spawned once and reused across ticks. Override via env
# BX_WATCHER_BRANCH for testing.
WATCHER_BRANCH="${BX_WATCHER_BRANCH:-agent/factory/watcher-handoff/current}"

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
# Fetch origin/main so any operator commit/PR step rebases cleanly. This is
# a read-only network op; no local branch is mutated by the fetch itself.
# --------------------------------------------------------------------------
if git remote get-url origin >/dev/null 2>&1; then
  git fetch origin main --quiet || log "warn: git fetch origin main failed (offline?); continuing"
fi

# --------------------------------------------------------------------------
# read_novelty_threshold — parse .novelty_check.threshold from ${CONFIG}.
# Config-over-Hardcoding (CLAUDE.md §10 / ADR-159 §D-4 / OI-1). On any parse
# failure returns "0.85" (ADR-159 starting-point default), never fails hard.
# --------------------------------------------------------------------------
read_novelty_threshold() {
  local v
  v=$(awk '
    /^novelty_check:/           { in_nc=1; next }
    in_nc && /^[a-zA-Z_]/       { in_nc=0 }
    in_nc && /^[[:space:]]+threshold:[[:space:]]*/ {
      sub(/^[[:space:]]+threshold:[[:space:]]*/, "")
      sub(/[[:space:]]*#.*$/, "")
      print; exit
    }
  ' "${CONFIG}" 2>/dev/null)
  [ -n "${v}" ] || v="0.85"
  echo "${v}"
}

# --------------------------------------------------------------------------
# build_corpus_digest — emit a compact "path: heading" list for corpus_paths
# (governance/, docs/adr/, docs/agent-engine-dossier/), skipping excludes
# (FROZEN-ARCHIVE.md, *.snapshot.md). Bounded to keep prompt within model
# context. Read-only.
# --------------------------------------------------------------------------
build_corpus_digest() {
  local max=200
  # -H prefixes filename; use grep -l to keep it simple + portable.
  find governance docs/adr docs/agent-engine-dossier -type f -name '*.md' 2>/dev/null \
    | grep -v -e 'FROZEN-ARCHIVE\.md$' -e '\.snapshot\.md$' \
    | sort \
    | head -n "${max}" \
    | while IFS= read -r f; do
        local h
        h=$(awk '/^#+[[:space:]]/ { sub(/^#+[[:space:]]*/, ""); print; exit }' "${f}" 2>/dev/null \
              | tr -d '\r' | cut -c1-120)
        printf -- '- %s: %s\n' "${f}" "${h}"
      done
}

# --------------------------------------------------------------------------
# score_hook — v2 REAL semantic-scoring via LiteLLM :4000.
#
# Behaviour:
#   1. Read threshold from ${CONFIG} (default 0.85).
#   2. If LITELLM_KEY empty / placeholder (starts with "<") -> FAIL-OPEN
#      to "novel" + log "scoring unavailable -> defaulting novel". Exit 0.
#   3. Build corpus digest (path + first heading) from corpus_paths.
#   4. POST OpenAI-compatible /v1/chat/completions to $LITELLM_ENDPOINT
#      (default http://127.0.0.1:4000), Authorization: Bearer $LITELLM_KEY.
#      Model = $LITELLM_MODEL (default project-reason). Prompt asks for a
#      SINGLE float in [0.0, 1.0] representing max similarity.
#   5. Parse a float from the response content. If any step fails -> FAIL-
#      OPEN to "novel" + log reason. Service never crashes.
#   6. score >= threshold => "duplicate"; else => "novel".
#
# Key hygiene: $LITELLM_KEY is dereferenced only inside the curl header
# argument; never echoed / logged. Prints "novel" or "duplicate" on stdout.
# --------------------------------------------------------------------------
score_hook() {
  local item="$1"
  local endpoint model threshold key digest prompt body_file resp_file
  local http_code rc score verdict

  endpoint="${LITELLM_ENDPOINT:-http://127.0.0.1:4000}"
  model="${LITELLM_MODEL:-project-reason}"
  threshold="$(read_novelty_threshold)"
  key="${LITELLM_KEY:-}"

  # (2) Key preflight — placeholder-detection uses parameter-expansion prefix
  # strip: if the value starts with "<" (e.g. "<paste-key-here>"), strip
  # returns the tail; comparing to the original tells us the leading "<" was
  # there. Never expose the value.
  if [ -z "${key}" ] || [ "${key#<}" != "${key}" ]; then
    log "score-hook: LITELLM_KEY missing/placeholder — scoring unavailable -> defaulting novel (item=${item})"
    echo "novel"
    return 0
  fi

  # (3) Corpus digest — bounded; empty digest => fail-open.
  digest="$(build_corpus_digest 2>/dev/null || true)"
  if [ -z "${digest}" ]; then
    log "score-hook: corpus digest empty — scoring unavailable -> defaulting novel (item=${item})"
    echo "novel"
    return 0
  fi

  body_file="$(mktemp 2>/dev/null || echo /tmp/nw-body.$$)"
  resp_file="$(mktemp 2>/dev/null || echo /tmp/nw-resp.$$)"

  prompt="You are a semantic-similarity judge. Given a candidate finding slug and a governance corpus digest, return ONE floating-point number in [0.0, 1.0] representing the maximum cosine-style similarity between the candidate and the closest corpus item. Output ONLY the number, no prose, no code fence.

Candidate: ${item}

Corpus digest (path: first-heading):
${digest}

Similarity score (0.0-1.0):"

  # (4) Assemble JSON body via python3 (safe quoting; NEVER embed key here).
  if ! printf '%s' "${prompt}" | python3 -c "
import json,sys
p=sys.stdin.read()
json.dump({'model':'${model}','messages':[{'role':'user','content':p}],'temperature':0.0,'max_tokens':16}, sys.stdout)
" > "${body_file}" 2>/dev/null; then
    log "score-hook: JSON body assembly failed -> defaulting novel (item=${item})"
    rm -f "${body_file}" "${resp_file}"
    echo "novel"
    return 0
  fi

  # (4) FAIL-OPEN network call — set +e locally; capture rc + http_code.
  set +e
  http_code=$(curl -sS -m 30 -o "${resp_file}" -w '%{http_code}' \
    -H "Authorization: Bearer ${key}" \
    -H 'Content-Type: application/json' \
    --data-binary "@${body_file}" \
    "${endpoint}/v1/chat/completions" 2>/dev/null)
  rc=$?
  set -e

  if [ "${rc}" -ne 0 ] || [ "${http_code}" != "200" ]; then
    log "score-hook: LiteLLM ${endpoint} unavailable (rc=${rc} http=${http_code:-none}) -> defaulting novel (item=${item})"
    rm -f "${body_file}" "${resp_file}"
    echo "novel"
    return 0
  fi

  # (5) Parse a float from the response content.
  score=$(python3 - <"${resp_file}" 2>/dev/null <<'PY'
import json,re,sys
try:
    d=json.load(sys.stdin)
    c=d.get('choices',[{}])[0].get('message',{}).get('content','') or ''
    m=re.search(r'([0-9]*\.?[0-9]+)', c)
    print(m.group(1) if m else '')
except Exception:
    print('')
PY
)
  rm -f "${body_file}" "${resp_file}"

  if [ -z "${score}" ]; then
    log "score-hook: response unparseable -> defaulting novel (item=${item})"
    echo "novel"
    return 0
  fi

  # (6) Compare score vs threshold. awk handles floats portably.
  verdict=$(awk -v s="${score}" -v t="${threshold}" \
    'BEGIN { print (s+0 >= t+0) ? "duplicate" : "novel" }')
  log "score-hook: item=${item} score=${score} threshold=${threshold} verdict=${verdict}"
  echo "${verdict}"
}

# --------------------------------------------------------------------------
# extract_new_items — v1.1 STRICT-NEW filter.
#
# Emits (stdout) one finding-item slug per line for rows with status
# EXACTLY "NEW". Rows with legacy statuses OPEN / IN-PROGRESS / RESOLVED
# are GRANDFATHERED (skipped, logged to stderr, NEVER re-processed).
#
# v1 defect fixed: v1's `status == "NEW" || status == "OPEN"` caused the
# watcher to re-pick every OPEN row on every tick (all currently-tracked
# findings are OPEN or RESOLVED — none are NEW yet), so the shakeout re-
# processed already-closed items. v1.1 enforces the strict-NEW contract
# from ADR-159 §D-1.
# --------------------------------------------------------------------------
extract_new_items() {
  awk -F'|' '
    /^\|[[:space:]]*-+/ { next }         # separator row
    /^\| item[[:space:]]*\|/ { next }    # header row
    /^\|/ {
      # Register schema:
      # | item | source-repo | floor | type | value | dedup | verdict | handoff | status |
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)    # item
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $10)   # status (trailing bar => $11 is empty)
      if ($10 == "NEW") {
        print $2
      } else if ($10 == "OPEN" || $10 == "IN-PROGRESS" || $10 == "RESOLVED") {
        printf "novelty-watcher: skip (grandfathered legacy status=%s): %s\n", $10, $2 > "/dev/stderr"
      }
    }
  ' "${REGISTER}"
}

# --------------------------------------------------------------------------
# Idempotency + event-numbering helpers.
# Read/write only within the isolated worktree once we cd there.
# --------------------------------------------------------------------------
queue_has_item() {
  local item="$1"
  awk -F'|' -v item="${item}" '
    /^\|[[:space:]]*[0-9]+[[:space:]]*\|/ {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $3)
      if ($3 == item) found = 1
    }
    END { exit(found ? 0 : 1) }
  ' "${QUEUE}"
}

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

append_roadmap_marker() {
  local item="$1"
  local ts
  ts=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
  {
    printf '\n<!-- novelty-handoff v1.1: %s @ %s (ADR-159 mandatory hand-off) -->\n' \
      "${item}" "${ts}"
    printf -- '- **Hand-off (novelty):** `%s` — queued for sprint planning per ADR-159 §D-3.\n' \
      "${item}"
  } >> "${ROADMAP}"
  log "roadmap append: marker for item=${item}"
  echo "roadmap:${item}"
}

# --------------------------------------------------------------------------
# spawn_isolated_worktree — v1.1 OUTPUT DISCIPLINE.
#
# Refuses to write into the shared checkout (parallel-session-isolation
# Rule 6 + Rule 7, safety-rules.md destructive-op verify-step). Behaviour:
#
#   * If the current CWD is already inside a linked worktree (git-dir
#     lives under .git/worktrees/): reuse it.
#   * Else: spawn/reuse the dedicated worktree via scripts/bx-session.sh
#     (ADR-120), off freshly-fetched origin/main, branch=${WATCHER_BRANCH}.
#   * If that worktree already has uncommitted changes (operator has a
#     draft-PR in flight): SKIP writes this run — do not clobber (Rule 6).
#
# Prints the target path on stdout; caller cd's there before writes.
# --------------------------------------------------------------------------
spawn_isolated_worktree() {
  local git_dir wt_path
  git_dir="$(git rev-parse --absolute-git-dir 2>/dev/null || echo /)"
  case "${git_dir}" in
    */worktrees/*)
      log "operating inside linked worktree: ${git_dir}"
      pwd
      return 0
      ;;
  esac

  log "shared checkout detected — spawning isolated worktree via bx-session.sh (ADR-120)"
  [ -x "scripts/bx-session.sh" ] || die "scripts/bx-session.sh missing or not executable"
  # bx-session.sh prints its status lines to stderr and the final path to
  # stdout; capture stdout only (its own contract).
  wt_path="$(bash scripts/bx-session.sh "${WATCHER_BRANCH}")"
  [ -d "${wt_path}" ] || die "bx-session.sh did not return a valid worktree path: ${wt_path}"

  # Rule 6: refuse to clobber a dirty worktree (operator has open work).
  if ! git -C "${wt_path}" diff --quiet || ! git -C "${wt_path}" diff --cached --quiet; then
    log "isolated worktree ${wt_path} has uncommitted changes — SKIP this run"
    log "(operator has draft-PR in flight; retry on next timer tick after merge)"
    return 1
  fi

  echo "${wt_path}"
}

# --------------------------------------------------------------------------
# emit_operator_pr_instruction — v1.1 draft-PR discipline.
#
# After writing to the isolated worktree, tell the operator EXACTLY what to
# run to open the draft-PR. v1.1 does NOT invoke `gh pr create` itself
# (destructive-op stop-barrier, CLAUDE.md §11 §71).
# --------------------------------------------------------------------------
emit_operator_pr_instruction() {
  local wt_path="$1" n_processed="$2"
  cat >&2 <<EOF
novelty-watcher: --- OPERATOR ACTION REQUIRED (HITL, CLAUDE.md §71) ---
novelty-watcher: ${n_processed} finding(s) processed into isolated worktree:
novelty-watcher:   ${wt_path}
novelty-watcher: To open the draft-PR for HITL merge:
novelty-watcher:   cd ${wt_path}
novelty-watcher:   git add governance/NOVELTY-HANDOFF-QUEUE.md docs/ROADMAP-MATRIX.md
novelty-watcher:   git commit -m 'feat(pipeline): novelty hand-off batch [factory-watcher v1.1]'
novelty-watcher:   git fetch origin main --quiet && git rebase origin/main
novelty-watcher:   git push -u origin HEAD
novelty-watcher:   gh pr create --repo CarmiBanxe/banxe-architecture --draft \\
novelty-watcher:     --title 'novelty: hand-off batch (watcher v1.1)' \\
novelty-watcher:     --body 'auto-generated by scripts/novelty-watcher.sh v1.1; HITL merge per CLAUDE.md §71'
novelty-watcher: --- END OPERATOR ACTION ---
EOF
}

# --------------------------------------------------------------------------
# Main loop — strict NEW filter, isolated-worktree writes, operator PR.
# --------------------------------------------------------------------------
processed_count=0
skipped_count=0

new_items="$(extract_new_items || true)"

if [ -z "${new_items}" ]; then
  log "no status=NEW items in ${REGISTER} (legacy OPEN/IN-PROGRESS/RESOLVED grandfathered); nothing to do"
  exit 0
fi

# NEW items present -> need an isolated worktree for writes.
wt_path="$(spawn_isolated_worktree)" || {
  log "isolated worktree unavailable this tick — deferring writes to next run"
  exit 0
}
cd "${wt_path}"
REPO_ROOT="${wt_path}"
QUEUE="governance/NOVELTY-HANDOFF-QUEUE.md"
ROADMAP="docs/ROADMAP-MATRIX.md"

while IFS= read -r item; do
  [ -z "${item}" ] && continue
  if queue_has_item "${item}"; then
    log "skip (already in queue): ${item}"
    skipped_count=$((skipped_count + 1))
    continue
  fi

  # 1. picked
  append_queue_event "${item}" "picked" "-" "-"

  # 2. semantic-scoring hook (v1.1 stub — always novel)
  verdict="$(score_hook "${item}")"
  if [ "${verdict}" != "novel" ]; then
    append_queue_event "${item}" "processed" "-" "verdict=duplicate"
    log "hook classified duplicate: ${item}"
    processed_count=$((processed_count + 1))
    continue
  fi

  # 3. ROADMAP-MATRIX update (mandatory hand-off, ADR-159 §D-3)
  roadmap_ref="$(append_roadmap_marker "${item}")"

  # 4. planned (roadmap-ref recorded)
  append_queue_event "${item}" "planned" "${roadmap_ref}" "-"

  # 5. processed (terminal for A-side; sprint-ref left as TODO for v1.1)
  append_queue_event "${item}" "processed" "${roadmap_ref}" "TODO-sprint-v2"

  processed_count=$((processed_count + 1))
done <<EOF
${new_items}
EOF

log "done: processed=${processed_count} skipped=${skipped_count}"

if [ "${processed_count}" -gt 0 ]; then
  emit_operator_pr_instruction "${wt_path}" "${processed_count}"
fi
