#!/usr/bin/env bash
# evaluate.sh — Software Factory Canon §7.4 Evaluation Orchestrator
# Chains: pytest -> ruff -> Guardian 16-rule -> Canon Judge (audit)
# Usage: bash scripts/evaluate.sh [--diff <file>] [--promptfoo]
set -uo pipefail

DIFF_FILE="${1:-}"
RUN_PROMPTFOO=false
[[ "${2:-}" == "--promptfoo" ]] && RUN_PROMPTFOO=true

VERDICT="PASS"
REPORT=""

log() { echo "[eval] $(date +%H:%M:%S) $*"; }
fail() { VERDICT="BLOCK"; REPORT="$REPORT\n[BLOCK] $*"; }
warn() { [[ "$VERDICT" != "BLOCK" ]] && VERDICT="WARN"; REPORT="$REPORT\n[WARN] $*"; }

# ── Stage 1: pytest ──
log "Stage 1: pytest"
if command -v pytest >/dev/null 2>&1; then
  pytest --tb=short -q 2>&1 | tail -5
  PYTEST_EC=${PIPESTATUS[0]}
  if [[ $PYTEST_EC -eq 0 ]]; then
    log "pytest PASS"
  elif [[ $PYTEST_EC -eq 5 ]]; then
    log "pytest PASS (no tests collected — canon/docs-only repo)"
  else
    fail "pytest failures detected (exit $PYTEST_EC)"
  fi
else
  warn "pytest not found in PATH"
fi

# ── Stage 2: ruff ──
log "Stage 2: ruff"
if command -v ruff >/dev/null 2>&1; then
  RUFF_OUT=$(ruff check . --select E,W,F --ignore E501 2>&1 | tail -5)
  if echo "$RUFF_OUT" | grep -q "^All checks passed"; then
    log "ruff PASS"
  else
    warn "ruff issues: $RUFF_OUT"
  fi
else
  warn "ruff not found in PATH"
fi

# ── Stage 3: Guardian 16-rule check ──
log "Stage 3: Guardian audit"
if [[ "${GUARDIAN_OFF:-0}" == "1" ]]; then
  log "Guardian SKIP (GUARDIAN_OFF=1 — Legion-local commit, Guardian lives on evo1)"
  return 0 2>/dev/null || true
fi
GUARDIAN_URL="http://127.0.0.1:8195/audit"
if curl -sf --max-time 10 "$GUARDIAN_URL" -X POST \
  -H "Content-Type: application/json" \
  -d "{\"subject_type\":\"prompt\",\"subject_id\":\"eval-$(date +%s)\",\"scope\":\"factory\",\"prompt\":\"evaluation check\",\"actor\":\"evaluate.sh\"}" \
  > /tmp/guardian-eval-result.json 2>/dev/null; then
  GVERDICT=$(jq -r '.verdict.result // "unknown"' /tmp/guardian-eval-result.json)
  log "Guardian verdict: $GVERDICT"
  [[ "$GVERDICT" == "fail" ]] && fail "Guardian BLOCK"
  [[ "$GVERDICT" == "warn" ]] && warn "Guardian WARN"
else
  warn "Guardian unreachable at $GUARDIAN_URL"
fi

# ── Stage 4: Canon Judge (audit mode) ──
log "Stage 4: Canon Judge"
warn "Canon Judge in audit mode — no blocking (Sprint 8 will enable enforce)"

# ── Stage 5 (optional): promptfoo adversarial ──
if $RUN_PROMPTFOO; then
  log "Stage 5: promptfoo adversarial"
  export PATH="/home/mmber/.nvm/versions/node/v22.22.0/bin:$PATH"
  export OPENAI_API_KEY="sk-banxe-llm-gateway-2026"
  export OPENAI_BASE_URL="http://127.0.0.1:4000/v1"
  if command -v promptfoo >/dev/null 2>&1; then
    PFOO_OUT=$(npx promptfoo eval -c ~/developer/compliance/training/promptfoo.yaml 2>&1 | tail -5)
    log "promptfoo: $PFOO_OUT"
  else
    warn "promptfoo not found"
  fi
fi

# ── Verdict aggregation (S4-07) ──
echo ""
echo "════════════════════════════════════════"
echo "  EVALUATION VERDICT: $VERDICT"
echo "════════════════════════════════════════"
echo -e "$REPORT"
echo ""
[[ "$VERDICT" == "BLOCK" ]] && exit 1
[[ "$VERDICT" == "WARN" ]] && exit 0
exit 0
