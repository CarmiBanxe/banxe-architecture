#!/usr/bin/env bash
# banxe-build.sh — BANXE UI/app modular build pipeline
# Plane: Developer | Repo: banxe-ui (run from banxe-ui root)
# Usage:
#   bash scripts/banxe-build.sh                  # full pipeline
#   bash scripts/banxe-build.sh --stage 3        # single stage
#   bash scripts/banxe-build.sh --from-stage 4   # resume from stage
#   bash scripts/banxe-build.sh --stage quality-gate

set -euo pipefail

# ─── Config ──────────────────────────────────────────────────────────────────

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PIPELINE_DIR="$ROOT/.pipeline"
LOG_DIR="$PIPELINE_DIR/logs"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"

START_STAGE="${FROM_STAGE:-1}"
SINGLE_STAGE=""

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --stage)       SINGLE_STAGE="$2"; shift 2 ;;
    --from-stage)  START_STAGE="$2"; shift 2 ;;
    *)             echo "Unknown arg: $1"; exit 1 ;;
  esac
done

mkdir -p "$PIPELINE_DIR" "$LOG_DIR"

# ─── Helpers ─────────────────────────────────────────────────────────────────

log()  { echo "[$(date -u +%H:%M:%S)] $*"; }
pass() { echo "✅ $*"; }
fail() { echo "⛔ $*" >&2; exit 1; }
skip() { echo "⏩ $*"; }

write_stage_result() {
  local stage="$1" status="$2" notes="$3"
  cat > "$PIPELINE_DIR/stage${stage}.json" <<EOF
{"stage":${stage},"status":"${status}","notes":"${notes}","timestamp":"${TIMESTAMP}"}
EOF
}

should_run() {
  local stage="$1"
  [[ -z "$SINGLE_STAGE" ]] && [[ "$stage" -ge "$START_STAGE" ]] && return 0
  [[ "$SINGLE_STAGE" == "$stage" ]] && return 0
  return 1
}

# ─── Stage 1: Research / Spec Load ───────────────────────────────────────────

run_stage_1() {
  log "STAGE 1: Research / Spec Load"

  local required_docs=(
    "$HOME/banxe-architecture/docs/BANXE-UI-UX-RESEARCH.md"
    "$HOME/banxe-architecture/docs/BANXE-UI-UX-SYSTEM.md"
    "$HOME/banxe-architecture/docs/BANXE-SCREEN-INVENTORY.md"
    "$HOME/banxe-architecture/docs/BANXE-UI-ARCHITECTURE.md"
  )

  local missing=()
  for doc in "${required_docs[@]}"; do
    [[ -f "$doc" ]] || missing+=("$doc")
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    for f in "${missing[@]}"; do echo "  MISSING: $f"; done
    write_stage_result 1 "FAILED" "Missing spec docs"
    fail "Stage 1 FAILED — missing required architecture docs"
  fi

  # Write context summary
  cat > "$PIPELINE_DIR/stage1-context.json" <<EOF
{
  "stage": 1,
  "status": "PASS",
  "timestamp": "${TIMESTAMP}",
  "spec_docs_loaded": $(echo "${required_docs[@]}" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read().split()))"),
  "screens_required": ["W-01","W-02","W-03","W-04","W-05","W-06","M-01","M-02","M-03","M-04","M-05","M-06"],
  "components_required": ["BalanceWidget","TransactionRow","StatusChip","AmountInput","AIInsightCard","ComplianceFlag"]
}
EOF

  pass "Stage 1 PASS — all spec docs present"
}

# ─── Stage 2: Token Build ─────────────────────────────────────────────────────

run_stage_2() {
  log "STAGE 2: Token Validation"

  local tokens_dir="$ROOT/packages/design-tokens"

  if [[ ! -d "$tokens_dir" ]]; then
    write_stage_result 2 "SKIPPED" "packages/design-tokens not yet created"
    skip "Stage 2: design-tokens package not found — run scaffold first"
    return 0
  fi

  cd "$tokens_dir"

  if ! npm run build 2>&1 | tee "$LOG_DIR/stage2-tokens.log"; then
    write_stage_result 2 "FAILED" "Token build failed — see logs/stage2-tokens.log"
    fail "Stage 2 FAILED — token build error"
  fi

  write_stage_result 2 "PASS" "Tokens built: css + js + rn"
  pass "Stage 2 PASS — design tokens built"
  cd "$ROOT"
}

# ─── Stage 3: TypeScript Check ────────────────────────────────────────────────

run_stage_3() {
  log "STAGE 3: TypeScript Check"

  if [[ ! -f "$ROOT/tsconfig.base.json" ]]; then
    write_stage_result 3 "SKIPPED" "No tsconfig — scaffold not yet run"
    skip "Stage 3: no tsconfig found"
    return 0
  fi

  if ! npx tsc --noEmit 2>&1 | tee "$LOG_DIR/stage3-tsc.log"; then
    write_stage_result 3 "FAILED" "TypeScript errors — see logs/stage3-tsc.log"
    fail "Stage 3 FAILED — TypeScript errors"
  fi

  write_stage_result 3 "PASS" "TypeScript clean"
  pass "Stage 3 PASS"
}

# ─── Stage 4: Lint ────────────────────────────────────────────────────────────

run_stage_4() {
  log "STAGE 4: ESLint"

  if [[ ! -f "$ROOT/.eslintrc.json" ]]; then
    write_stage_result 4 "SKIPPED" "No .eslintrc.json"
    skip "Stage 4: no ESLint config"
    return 0
  fi

  if ! npx eslint . --ext .ts,.tsx --max-warnings 0 2>&1 | tee "$LOG_DIR/stage4-lint.log"; then
    write_stage_result 4 "FAILED" "Lint violations — see logs/stage4-lint.log"
    fail "Stage 4 FAILED — lint errors"
  fi

  write_stage_result 4 "PASS" "Lint clean"
  pass "Stage 4 PASS"
}

# ─── Stage 5: Unit Tests ──────────────────────────────────────────────────────

run_stage_5() {
  log "STAGE 5: Unit Tests (Vitest)"

  if [[ ! -d "$ROOT/tests/unit" ]]; then
    write_stage_result 5 "SKIPPED" "No tests/unit directory"
    skip "Stage 5: no unit tests yet"
    return 0
  fi

  if ! npx vitest run --reporter=json 2>&1 | tee "$LOG_DIR/stage5-unit.log"; then
    write_stage_result 5 "FAILED" "Unit test failures — see logs/stage5-unit.log"
    fail "Stage 5 FAILED — unit tests"
  fi

  write_stage_result 5 "PASS" "Unit tests pass"
  pass "Stage 5 PASS"
}

# ─── Stage 6: Storybook Build ─────────────────────────────────────────────────

run_stage_6() {
  log "STAGE 6: Storybook Build"

  if [[ ! -d "$ROOT/storybook" ]]; then
    write_stage_result 6 "SKIPPED" "No storybook directory"
    skip "Stage 6: Storybook not set up yet"
    return 0
  fi

  cd "$ROOT/storybook"
  if ! npm run build-storybook 2>&1 | tee "$LOG_DIR/stage6-storybook.log"; then
    write_stage_result 6 "FAILED" "Storybook build failed — component render error"
    fail "Stage 6 FAILED — Storybook build error"
  fi

  write_stage_result 6 "PASS" "Storybook built successfully"
  pass "Stage 6 PASS"
  cd "$ROOT"
}

# ─── Stage 7: Accessibility ───────────────────────────────────────────────────

run_stage_7() {
  log "STAGE 7: Accessibility Check"

  if [[ ! -f "$ROOT/scripts/check-a11y.sh" ]]; then
    write_stage_result 7 "SKIPPED" "check-a11y.sh not yet created"
    skip "Stage 7: accessibility check script not found"
    return 0
  fi

  if ! bash "$ROOT/scripts/check-a11y.sh" 2>&1 | tee "$LOG_DIR/stage7-a11y.log"; then
    write_stage_result 7 "FAILED" "Accessibility critical violations found"
    fail "Stage 7 FAILED — fix critical a11y violations before proceeding"
  fi

  write_stage_result 7 "PASS" "Accessibility: 0 critical violations"
  pass "Stage 7 PASS"
}

# ─── Stage 8: Final Report ────────────────────────────────────────────────────

run_quality_gate() {
  log "STAGE 8: Quality Gate / Final Report"

  local all_pass=true
  local results=()

  for s in 1 2 3 4 5 6 7; do
    local file="$PIPELINE_DIR/stage${s}.json"
    if [[ -f "$file" ]]; then
      local status
      status="$(python3 -c "import json,sys; d=json.load(open('$file')); print(d.get('status','UNKNOWN'))")"
      results+=("\"stage${s}\": \"${status}\"")
      [[ "$status" != "PASS" && "$status" != "SKIPPED" ]] && all_pass=false
    else
      results+=("\"stage${s}\": \"NOT_RUN\"")
      all_pass=false
    fi
  done

  local overall="PASS"
  $all_pass || overall="FAIL"

  local promotion_eligible="false"
  $all_pass && promotion_eligible="true"

  python3 -c "
import json
report = {
  'timestamp': '${TIMESTAMP}',
  $(IFS=,; echo "${results[*]}"),
  'overall': '${overall}',
  'promotion_eligible': ${promotion_eligible}
}
print(json.dumps(report, indent=2))
" > "$PIPELINE_DIR/stage8-report.json"

  cat "$PIPELINE_DIR/stage8-report.json"

  if [[ "$overall" == "PASS" ]]; then
    pass "QUALITY GATE PASS — prototype eligible for stakeholder review"
    [[ "$promotion_eligible" == "true" ]] && echo ""
    echo "  ⚠️  Promotion to Product Plane requires CEO review + IL entry."
  else
    fail "QUALITY GATE FAIL — fix issues above before promotion"
  fi
}

# ─── Main ─────────────────────────────────────────────────────────────────────

main() {
  echo "═══════════════════════════════════════════════"
  echo "  BANXE UI Build Pipeline — ${TIMESTAMP}"
  echo "═══════════════════════════════════════════════"
  echo "  Root: $ROOT"
  echo "  Pipeline dir: $PIPELINE_DIR"
  [[ -n "$SINGLE_STAGE" ]] && echo "  Single stage: $SINGLE_STAGE"
  [[ -z "$SINGLE_STAGE" ]] && echo "  From stage: $START_STAGE"
  echo ""

  if [[ "$SINGLE_STAGE" == "quality-gate" ]]; then
    run_quality_gate
    exit 0
  fi

  should_run 1 && run_stage_1
  should_run 2 && run_stage_2
  should_run 3 && run_stage_3
  should_run 4 && run_stage_4
  should_run 5 && run_stage_5
  should_run 6 && run_stage_6
  should_run 7 && run_stage_7

  if [[ -z "$SINGLE_STAGE" ]]; then
    echo ""
    run_quality_gate
  fi
}

main "$@"
