#!/usr/bin/env bash
# Sandbox pilot smoke harness — read-only, skip-if-absent.
# Document: TOOLS-SANDBOX-SMOKE-2026-05-12
# Purpose: one-shot check of Conditions A/B/C/D readiness before
#          Step 6 (apply LiteLLM shadow-tap).
# Sub-A authority: read-only. No mutations. Skips checks that depend
#                  on unavailable components rather than failing them.

set -u
PASS=0; FAIL=0; SKIP=0
report() {
  local code="$1"; shift
  case "$code" in
    PASS) echo "[PASS] $*"; PASS=$((PASS+1)) ;;
    FAIL) echo "[FAIL] $*"; FAIL=$((FAIL+1)) ;;
    SKIP) echo "[SKIP] $*"; SKIP=$((SKIP+1)) ;;
  esac
}

echo "=== Sandbox pilot smoke harness — $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="

# 1. Step 1 — qwen2.5:0.5b on evo2
if ssh -o ConnectTimeout=3 evo2 'ollama list 2>/dev/null' \
     | grep -qiE "qwen2\.5:0\.5b"; then
  report PASS "Step 1: qwen2.5:0.5b present on evo2"
else
  report FAIL "Step 1: qwen2.5:0.5b NOT on evo2"
fi

# 2. Condition D — ClickHouse audit table
CH_HOST="${CLICKHOUSE_HOST:-100.68.102.48}"
CH_PORT="${CLICKHOUSE_PORT:-9000}"
if command -v clickhouse-client >/dev/null 2>&1; then
  if clickhouse-client --host "$CH_HOST" --port "$CH_PORT" --query \
       "EXISTS TABLE banxe_audit.hitl_decisions" 2>/dev/null \
     | grep -q "^1$"; then
    report PASS "Condition D: banxe_audit.hitl_decisions exists"
  else
    report FAIL "Condition D: hitl_decisions table missing"
  fi
else
  report SKIP "Condition D: no local clickhouse-client to verify"
fi

# 3. Condition B — classify-prompt endpoint
BAPI="${BANXE_COMPLIANCE_API_URL:-}"
TOKEN="${BANXE_INTERNAL_SVC_TOKEN:-}"
if [[ -n "$BAPI" && -n "$TOKEN" ]]; then
  CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -X POST "$BAPI/v1/internal/classify-prompt" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"prompt_hash":"smoke","prompt_excerpt":"hello",
         "metadata":{"source":"smoke_test","model":"classifier:qwen2.5-0.5b",
                     "ts":"'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"}}')
  if [[ "$CODE" == "200" ]]; then
    report PASS "Condition B: endpoint returned 200"
  else
    report FAIL "Condition B: endpoint returned HTTP $CODE"
  fi
else
  report SKIP "Condition B: BANXE_COMPLIANCE_API_URL or token unset"
fi

# 4. Condition C — reviewer named in eval protocol doc
EVAL=/home/mmber/banxe-architecture/docs/audit/condition-c-evaluation-protocol-2026-05-12.md
if [[ -f "$EVAL" ]] && grep -qE "Reviewer:[* ]+[A-Za-z]" "$EVAL"; then
  report PASS "Condition C: reviewer slot filled"
else
  report FAIL "Condition C: reviewer NOT named (blank slot)"
fi

# 5. Condition A — dataset pointer
DATASET=/home/mmber/banxe-architecture/docs/audit/condition-a-training-dataset-2026-05-12.md
if [[ -f "$DATASET" ]] && grep -qE "^[* ]*Source:[* ]+[^_<]" "$DATASET"; then
  report PASS "Condition A: dataset source named"
else
  report FAIL "Condition A: dataset source NOT named (placeholder)"
fi

# 6. LiteLLM cache + canonical config sanity
LITELLM_CFG=/home/mmber/litellm-config.yaml
if [[ -f "$LITELLM_CFG" ]] && grep -q "model_name: default" "$LITELLM_CFG"; then
  report PASS "LiteLLM canonical config present"
else
  report FAIL "LiteLLM canonical config missing or malformed"
fi

# 7. Classifier shadow-tap NOT yet active (must remain absent until Step 6)
if [[ -f "$LITELLM_CFG" ]] && grep -q "shadow_classifier_tap" "$LITELLM_CFG"; then
  report FAIL "Shadow tap already wired (violates apply gating)"
else
  report PASS "Shadow tap not yet wired (expected at this stage)"
fi

echo "=== summary: PASS=$PASS FAIL=$FAIL SKIP=$SKIP ==="
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
