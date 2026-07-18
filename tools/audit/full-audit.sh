#!/usr/bin/env bash
# full-audit.sh — BANXE EMI Factory: Canonical read-only system audit
# Canon: docs/governance/CANON-SINGLE-AUDIT-SCRIPT.md
# Rule: READ-ONLY. No writes, no restarts, no installs, no git mutations.
# Rule: Full output saved to /tmp/full-audit-<UTC>.txt. Summary to stdout.
# Rule: No section may abort the script. Use || true / || echo UNREACHABLE.
# Rule: No | head truncation on fact-bearing sections in the saved file.

set -euo pipefail

AUDIT_TS=$(date -u +%Y%m%dT%H%M%SZ)
OUTFILE="/tmp/full-audit-${AUDIT_TS}.txt"

# ── helpers ──────────────────────────────────────────────────────────────────

section() {
    local label="$1"
    echo "" | tee -a "$OUTFILE"
    echo "════════════════════════════════════════════════════════════" | tee -a "$OUTFILE"
    echo "  ${label}" | tee -a "$OUTFILE"
    echo "════════════════════════════════════════════════════════════" | tee -a "$OUTFILE"
}

log() { echo "$@" | tee -a "$OUTFILE"; }
logf() { echo "$@" >> "$OUTFILE"; }  # file-only (no screen)

# Summary buffer — printed at end
SUMMARY=""
sum_add() { SUMMARY="${SUMMARY}  $*\n"; }

# ── header ───────────────────────────────────────────────────────────────────

echo "BANXE EMI — Full System Audit  ${AUDIT_TS}" | tee "$OUTFILE"
echo "Canon: tools/audit/full-audit.sh" | tee -a "$OUTFILE"
echo "Output: ${OUTFILE}" | tee -a "$OUTFILE"

# ─────────────────────────────────────────────────────────────────────────────
section "[HW] Hardware"
# ─────────────────────────────────────────────────────────────────────────────

log "--- CPU ---"
log "Threads: $(nproc 2>/dev/null || echo UNKNOWN)"
lscpu 2>/dev/null | grep -E "^Model name|^CPU\(s\)|^Thread|^Core" | tee -a "$OUTFILE" || true

log ""
log "--- Memory ---"
free -h 2>/dev/null | tee -a "$OUTFILE" || log "free: UNREACHABLE"

log ""
log "--- GPU (nvidia-smi) ---"
nvidia-smi \
    --query-gpu=name,memory.total,memory.free,memory.used,utilization.gpu,driver_version \
    --format=csv,noheader 2>/dev/null | tee -a "$OUTFILE" \
    || log "nvidia-smi: UNREACHABLE (no GPU or driver not loaded)"

log ""
log "--- Disk ---"
df -h ~ / 2>/dev/null | tee -a "$OUTFILE" || log "df: UNREACHABLE"

# summary
GPU_LINE=$(nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv,noheader 2>/dev/null \
    | head -1 || echo "NO GPU")
RAM_AVAIL=$(free -h 2>/dev/null | awk '/^Mem/{print $7}' || echo "?")
sum_add "[HW]  GPU: ${GPU_LINE} | RAM avail: ${RAM_AVAIL}"

# ─────────────────────────────────────────────────────────────────────────────
section "[PORTS] Listening Ports of Interest"
# ─────────────────────────────────────────────────────────────────────────────

log "Checking: :3000 :4000 :8000 :8080 :8081 :11434"
ss -tlnp 2>/dev/null | grep -E ":3000|:4000|:8000|:8080|:8081|:11434" \
    | tee -a "$OUTFILE" || log "ss: UNREACHABLE"

# Also catch "not listening" ports explicitly for summary
PORTS_ACTIVE=""
for PORT in 3000 4000 8000 8080 8081 11434; do
    if ss -tlnp 2>/dev/null | grep -q ":${PORT}"; then
        PORTS_ACTIVE="${PORTS_ACTIVE} :${PORT}"
    fi
done
sum_add "[PORTS] Active: ${PORTS_ACTIVE:-NONE}"

# ─────────────────────────────────────────────────────────────────────────────
section "[LITELLM] LiteLLM Gateway :4000"
# ─────────────────────────────────────────────────────────────────────────────

LITELLM_BASE="http://127.0.0.1:4000"
LITELLM_KEY="sk-banxe-llm-gateway-2026"

log "--- Health ---"
curl -s --connect-timeout 4 "${LITELLM_BASE}/health" 2>/dev/null \
    | tee -a "$OUTFILE" || log "LiteLLM /health: UNREACHABLE"

log ""
log "--- Liveliness ---"
curl -s --connect-timeout 4 "${LITELLM_BASE}/health/liveliness" 2>/dev/null \
    | tee -a "$OUTFILE" || log "LiteLLM /health/liveliness: UNREACHABLE"

log ""
log "--- /v1/models (full list) ---"
MODELS_JSON=$(curl -s --connect-timeout 4 \
    -H "Authorization: Bearer ${LITELLM_KEY}" \
    "${LITELLM_BASE}/v1/models" 2>/dev/null || echo '{"error":"UNREACHABLE"}')
echo "$MODELS_JSON" >> "$OUTFILE"   # full JSON to file only (may be long)

# Screen: count + IDs only
MODEL_COUNT=$(echo "$MODELS_JSON" | python3 -c \
    "import sys,json; d=json.load(sys.stdin); print(len(d.get('data',[])), 'models')" \
    2>/dev/null || echo "parse error")
MODEL_IDS=$(echo "$MODELS_JSON" | python3 -c \
    "import sys,json; d=json.load(sys.stdin); [print(' -',m['id']) for m in d.get('data',[])]" \
    2>/dev/null || echo "parse error")
log "Count: ${MODEL_COUNT}"
log "${MODEL_IDS}"

sum_add "[LITELLM] ${MODEL_COUNT}"

# ─────────────────────────────────────────────────────────────────────────────
section "[OLLAMA-LOCAL] Ollama :11434 (Legion local)"
# ─────────────────────────────────────────────────────────────────────────────

OLLAMA_LOCAL="http://127.0.0.1:11434"

TAGS_JSON=$(curl -s --connect-timeout 4 "${OLLAMA_LOCAL}/api/tags" 2>/dev/null \
    || echo '{"error":"UNREACHABLE"}')
echo "$TAGS_JSON" >> "$OUTFILE"   # full JSON to file

log "--- Models on Legion Ollama ---"
echo "$TAGS_JSON" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    models = d.get('models', [])
    if not models:
        print('  (no models or UNREACHABLE)')
    for m in models:
        size_gb = m.get('size', 0) / 1e9
        print(f\"  {m['name']}  ({size_gb:.1f} GB)  modified: {m.get('modified_at','?')[:10]}\")
except Exception as e:
    print(f'  parse error: {e}')
" | tee -a "$OUTFILE" || true

LOCAL_MODELS=$(echo "$TAGS_JSON" | python3 -c \
    "import sys,json; d=json.load(sys.stdin); print(', '.join(m['name'] for m in d.get('models',[])))" \
    2>/dev/null || echo "UNREACHABLE")
sum_add "[OLLAMA-LOCAL] ${LOCAL_MODELS:-NONE}"

# ─────────────────────────────────────────────────────────────────────────────
section "[EVO2] Ollama on evo2 (192.168.0.15:11434)"
# ─────────────────────────────────────────────────────────────────────────────

EVO2_TAGS=$(curl -s --connect-timeout 4 "http://192.168.0.15:11434/api/tags" 2>/dev/null \
    || echo '{"error":"UNREACHABLE"}')
echo "$EVO2_TAGS" >> "$OUTFILE"

log "--- Models on evo2 ---"
echo "$EVO2_TAGS" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    models = d.get('models', [])
    if not models:
        print('  (no models or UNREACHABLE)')
    for m in models:
        size_gb = m.get('size', 0) / 1e9
        print(f\"  {m['name']}  ({size_gb:.1f} GB)\")
except Exception as e:
    print(f'  parse error: {e}')
" | tee -a "$OUTFILE" || true

EVO2_MODELS=$(echo "$EVO2_TAGS" | python3 -c \
    "import sys,json; d=json.load(sys.stdin); print(', '.join(m['name'] for m in d.get('models',[])))" \
    2>/dev/null || echo "UNREACHABLE")
sum_add "[EVO2] ${EVO2_MODELS:-NONE}"

# ─────────────────────────────────────────────────────────────────────────────
section "[EVO1] Ollama on evo1 (100.68.102.48:11434) + API :8090"
# ─────────────────────────────────────────────────────────────────────────────

EVO1_TAGS=$(curl -s --connect-timeout 4 "http://100.68.102.48:11434/api/tags" 2>/dev/null \
    || echo '{"error":"UNREACHABLE"}')
echo "$EVO1_TAGS" >> "$OUTFILE"

log "--- Models on evo1 (Tailscale 100.68.102.48) ---"
echo "$EVO1_TAGS" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    models = d.get('models', [])
    if not models:
        print('  (no models or UNREACHABLE)')
    for m in models:
        size_gb = m.get('size', 0) / 1e9
        print(f\"  {m['name']}  ({size_gb:.1f} GB)\")
except Exception as e:
    print(f'  parse error: {e}')
" | tee -a "$OUTFILE" || true

EVO1_MODELS=$(echo "$EVO1_TAGS" | python3 -c \
    "import sys,json; d=json.load(sys.stdin); print(', '.join(m['name'] for m in d.get('models',[])))" \
    2>/dev/null || echo "UNREACHABLE")
sum_add "[EVO1-OLLAMA] ${EVO1_MODELS:-NONE}"

log ""
log "--- evo1 API :8090/health ---"
EVO1_HEALTH_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 4 \
    "http://100.68.102.48:8090/health" 2>/dev/null || echo "UNREACHABLE")
log "HTTP ${EVO1_HEALTH_CODE}"
sum_add "[EVO1-API] :8090/health → HTTP ${EVO1_HEALTH_CODE}"

# ─────────────────────────────────────────────────────────────────────────────
section "[GIT] Repository State"
# ─────────────────────────────────────────────────────────────────────────────

audit_repo() {
    local LABEL="$1"
    local REPO="$2"

    log ""
    log "=== ${LABEL}: ${REPO} ==="

    if [[ ! -d "${REPO}/.git" && ! -f "${REPO}/.git" ]]; then
        log "  REPO NOT FOUND or not a git repo"
        sum_add "[GIT ${LABEL}] REPO NOT FOUND"
        return
    fi

    # Fetch prune (network; may fail — non-fatal)
    git -C "$REPO" fetch --prune origin 2>/dev/null \
        | tee -a "$OUTFILE" \
        || log "  fetch: UNREACHABLE or error (continuing)"

    local CURR_BRANCH
    CURR_BRANCH=$(git -C "$REPO" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "UNKNOWN")
    log "  Current branch: ${CURR_BRANCH}"

    local MAIN_LOCAL
    MAIN_LOCAL=$(git -C "$REPO" rev-parse --short main 2>/dev/null \
        || git -C "$REPO" rev-parse --short HEAD 2>/dev/null \
        || echo "UNKNOWN")
    log "  main (local) SHA: ${MAIN_LOCAL}"

    local ORIGIN_MAIN
    ORIGIN_MAIN=$(git -C "$REPO" rev-parse --short origin/main 2>/dev/null || echo "UNKNOWN")
    log "  origin/main SHA:  ${ORIGIN_MAIN}"

    # Ahead/behind relative to origin/main
    local AHEAD BEHIND
    AHEAD=$(git -C "$REPO" rev-list --count origin/main..HEAD 2>/dev/null || echo "?")
    BEHIND=$(git -C "$REPO" rev-list --count HEAD..origin/main 2>/dev/null || echo "?")
    log "  Ahead origin/main: ${AHEAD}  Behind: ${BEHIND}"

    # Dirty file count
    local DIRTY
    DIRTY=$(git -C "$REPO" status --porcelain 2>/dev/null | wc -l || echo "?")
    log "  Dirty files: ${DIRTY}"

    # Open PRs
    log "  Open PRs:"
    gh pr list --repo "$(git -C "$REPO" remote get-url origin 2>/dev/null | sed 's/.*github.com[:/]//' | sed 's/\.git$//')" \
        --state open --limit 10 \
        --json number,title,headRefName \
        --template '{{range .}}    #{{.number}} {{.headRefName}} — {{.title}}{{"\n"}}{{end}}' \
        2>/dev/null | tee -a "$OUTFILE" \
        || log "    gh: UNREACHABLE or not authenticated"

    sum_add "[GIT ${LABEL}] branch=${CURR_BRANCH}  local-main=${MAIN_LOCAL}  origin=${ORIGIN_MAIN}  ahead=${AHEAD}  behind=${BEHIND}  dirty=${DIRTY}"
}

audit_repo "banxe-architecture" "${HOME}/banxe-architecture"
audit_repo "banxe-emi-stack" "${HOME}/banxe-emi-stack"

# ─────────────────────────────────────────────────────────────────────────────
section "[WORKTREES] Git Worktree List"
# ─────────────────────────────────────────────────────────────────────────────

for REPO_LABEL in "banxe-architecture:${HOME}/banxe-architecture" \
                  "banxe-emi-stack:${HOME}/banxe-emi-stack"; do
    LABEL="${REPO_LABEL%%:*}"
    REPO="${REPO_LABEL##*:}"
    log ""
    log "=== ${LABEL} worktrees ==="
    git -C "$REPO" worktree list 2>/dev/null | tee -a "$OUTFILE" \
        || log "  REPO NOT FOUND"
done

# ─────────────────────────────────────────────────────────────────────────────
section "[GH-ACCOUNTS] GitHub Auth Status"
# ─────────────────────────────────────────────────────────────────────────────

log "--- gh auth status (tokens masked) ---"
gh auth status 2>&1 | sed 's/\(Token:\s*\)[^ ]*/\1***MASKED***/g' \
    | tee -a "$OUTFILE" \
    || log "gh: UNREACHABLE or not authenticated"

log ""
log "--- CarmiBanxe repo count ---"
gh repo list CarmiBanxe --limit 200 --json name 2>/dev/null \
    | python3 -c "import sys,json; repos=json.load(sys.stdin); print(f'{len(repos)} repos')" \
    | tee -a "$OUTFILE" \
    || log "  CarmiBanxe: UNREACHABLE or no access"

log ""
log "--- Carmi61 repo count ---"
gh repo list Carmi61 --limit 200 --json name 2>/dev/null \
    | python3 -c "import sys,json; repos=json.load(sys.stdin); print(f'{len(repos)} repos')" \
    | tee -a "$OUTFILE" \
    || log "  Carmi61: UNREACHABLE or no access"

# ─────────────────────────────────────────────────────────────────────────────
section "[SERVICES] Systemd Service States"
# ─────────────────────────────────────────────────────────────────────────────

log "--- is-active checks ---"
for SVC in litellm-lan-gateway ollama llama-qwen; do
    STATE=$(systemctl is-active "$SVC" 2>/dev/null || echo "unknown/not-found")
    log "  ${SVC}: ${STATE}"
done

log ""
log "--- Units matching llama/qwen/manus ---"
systemctl list-units --all --no-pager 2>/dev/null \
    | grep -iE "llama|qwen|manus" \
    | tee -a "$OUTFILE" \
    || log "  systemctl: UNREACHABLE or no matches"

# ─────────────────────────────────────────────────────────────────────────────
section "[TRACKS] SESSION-STATE.md — TRACK BOARD"
# ─────────────────────────────────────────────────────────────────────────────

SESSION_STATE="${HOME}/wt/private-engine-openmanus/docs/governance/SESSION-STATE.md"

if [[ -f "$SESSION_STATE" ]]; then
    log "Source: ${SESSION_STATE}"
    log ""
    # Extract everything from "## TRACK BOARD" to end of file (full read, no head)
    awk '/^## TRACK BOARD/,0' "$SESSION_STATE" >> "$OUTFILE"
    # Screen: show the section header + table only (until next ##)
    awk '/^## TRACK BOARD/{p=1} p && /^## / && !/^## TRACK BOARD/{exit} p{print}' \
        "$SESSION_STATE" | head -30
else
    log "SESSION-STATE.md NOT FOUND at ${SESSION_STATE}"
fi

# ─────────────────────────────────────────────────────────────────────────────
# SUMMARY
# ─────────────────────────────────────────────────────────────────────────────

echo "" | tee -a "$OUTFILE"
echo "════════════════════════════════════════════════════════════" | tee -a "$OUTFILE"
echo "  AUDIT SUMMARY  ${AUDIT_TS}" | tee -a "$OUTFILE"
echo "════════════════════════════════════════════════════════════" | tee -a "$OUTFILE"
printf "%b" "$SUMMARY" | tee -a "$OUTFILE"
echo "" | tee -a "$OUTFILE"
echo "FULL OUTPUT: ${OUTFILE}"
