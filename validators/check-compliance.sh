#!/usr/bin/env bash
# check-compliance.sh — проверяет проект на соответствие banxe-architecture инвариантам
# Usage: bash validators/check-compliance.sh <project-path>
# Returns: 0 = PASS, 1 = FAIL

set -euo pipefail

PROJECT="${1:-}"
if [[ -z "$PROJECT" ]]; then
  echo "Usage: bash validators/check-compliance.sh <project-path>"
  echo "  e.g.: bash validators/check-compliance.sh ~/vibe-coding"
  echo "  e.g.: bash validators/check-compliance.sh ~/developer"
  exit 2
fi

if [[ ! -d "$PROJECT" ]]; then
  echo "ERROR: directory not found: $PROJECT"
  exit 2
fi

ARCH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0
WARN=0

check_pass() { echo "  ✓ $1"; ((PASS++)) || true; }
check_fail() { echo "  ✗ FAIL: $1"; ((FAIL++)) || true; }
check_warn() { echo "  ⚠ WARN: $1"; ((WARN++)) || true; }

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "  BANXE COMPLIANCE CHECK"
echo "  Project : $PROJECT"
echo "  Arch    : $ARCH_DIR"
echo "  Date    : $(date '+%Y-%m-%d %H:%M:%S')"
echo "══════════════════════════════════════════════════════════════"

# ─── CHECK 1: Decision thresholds ────────────────────────────────────────────
echo ""
echo "[1/6] Decision thresholds (SAR=85, REJECT=70, HOLD=40)"

CV_FILE=$(find "$PROJECT" -name "compliance_validator.py" 2>/dev/null | head -1)
if [[ -z "$CV_FILE" ]]; then
  check_warn "compliance_validator.py not found in $PROJECT (skip threshold checks)"
else
  if grep -q "_THRESHOLD_SAR\s*=\s*85\|THRESHOLD_SAR.*=.*85\|SAR.*=.*85" "$CV_FILE" 2>/dev/null; then
    check_pass "SAR threshold = 85"
  else
    SAR_VAL=$(grep -oE "_THRESHOLD_SAR\s*=\s*[0-9]+" "$CV_FILE" 2>/dev/null | head -1 || echo "not found")
    check_fail "SAR threshold ≠ 85 → found: $SAR_VAL"
  fi
  if grep -q "_THRESHOLD_REJECT\s*=\s*70\|REJECT.*=.*70" "$CV_FILE" 2>/dev/null; then
    check_pass "REJECT threshold = 70"
  else
    check_fail "REJECT threshold ≠ 70"
  fi
  if grep -q "_THRESHOLD_HOLD\s*=\s*40\|HOLD.*=.*40" "$CV_FILE" 2>/dev/null; then
    check_pass "HOLD threshold = 40"
  else
    check_fail "HOLD threshold ≠ 40"
  fi
fi

# ─── CHECK 2: Sanctions lists ─────────────────────────────────────────────────
echo ""
echo "[2/6] Sanctions — Category A jurisdictions"

SANCTIONS_A=("RU" "BY" "IR" "KP" "CU" "MM" "AF")
SANCTIONS_FILE=$(find "$PROJECT" -name "sanctions_check.py" -o -name "compliance_validator.py" 2>/dev/null | head -1)
if [[ -z "$SANCTIONS_FILE" ]]; then
  check_warn "sanctions file not found (skip)"
else
  ALL_PRESENT=true
  for code in "${SANCTIONS_A[@]}"; do
    if ! grep -q "\"$code\"" "$SANCTIONS_FILE" 2>/dev/null; then
      check_fail "Category A jurisdiction $code not found in $SANCTIONS_FILE"
      ALL_PRESENT=false
    fi
  done
  if $ALL_PRESENT; then
    check_pass "All core Category A jurisdictions present (${SANCTIONS_A[*]})"
  fi
fi

# ─── CHECK 3: SOUL.md has mandatory sections ──────────────────────────────────
echo ""
echo "[3/6] SOUL.md — mandatory sections"

SOUL_FILE=$(find "$PROJECT" -name "SOUL.md" 2>/dev/null | head -1)
if [[ -z "$SOUL_FILE" ]]; then
  check_warn "SOUL.md not found in $PROJECT (may be on GMKtec)"
else
  if grep -q "АВТО-ВЕРИФИКАЦИЯ\|auto-verify\|8094" "$SOUL_FILE" 2>/dev/null; then
    check_pass "SOUL.md contains auto-verify step"
  else
    check_fail "SOUL.md missing auto-verify (ШАГ 3)"
  fi
  if grep -q "САНКЦИОН\|санкц\|ЗАБЛОКИРОВАНЫ\|REJECT" "$SOUL_FILE" 2>/dev/null; then
    check_pass "SOUL.md contains sanctions rules"
  else
    check_fail "SOUL.md missing sanctions rules"
  fi
  if grep -q "СТРОГО ЗАПРЕЩЕНО\|запрещено" "$SOUL_FILE" 2>/dev/null; then
    check_pass "SOUL.md has СТРОГО ЗАПРЕЩЕНО section"
  else
    check_warn "SOUL.md missing СТРОГО ЗАПРЕЩЕНО section"
  fi
fi

# ─── CHECK 4: No fake integrations mentioned ──────────────────────────────────
echo ""
echo "[4/6] No fake integrations in SOUL.md / agent responses"

if [[ -n "$SOUL_FILE" ]]; then
  FAKE_INTEGRATIONS=("LexisNexis" "Dow Jones" "SumSub" "Jumio" "Chainalysis")
  FOUND_FAKE=false
  for fake in "${FAKE_INTEGRATIONS[@]}"; do
    if grep -q "$fake" "$SOUL_FILE" 2>/dev/null; then
      # Only fail if it's mentioned as active (not as "not connected" disclaimer)
      if ! grep -q "$fake.*не подключ\|$fake.*not connected\|не упоминать.*$fake" "$SOUL_FILE" 2>/dev/null; then
        check_warn "SOUL.md mentions $fake — verify it's flagged as 'not connected'"
        FOUND_FAKE=true
      fi
    fi
  done
  if ! $FOUND_FAKE; then
    check_pass "No active fake integrations in SOUL.md"
  fi
fi

# ─── CHECK 5: Watchman minMatch = 0.80 ────────────────────────────────────────
echo ""
echo "[5/6] Watchman minMatch = 0.80"

WATCHMAN_FILE=$(find "$PROJECT" -name "*.py" -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" 2>/dev/null | \
  xargs grep -l "minMatch\|min_match\|jaro_winkler\|watchman" 2>/dev/null | head -1)
if [[ -z "$WATCHMAN_FILE" ]]; then
  check_warn "Watchman config not found (may be in GMKtec config)"
else
  if grep -qE "minMatch.*0\.80|min_match.*0\.80|0\.80.*minMatch|threshold.*0\.80" "$WATCHMAN_FILE" 2>/dev/null; then
    check_pass "Watchman minMatch = 0.80 ($WATCHMAN_FILE)"
  else
    MATCH_VAL=$(grep -oE "minMatch.*[0-9]+\.[0-9]+" "$WATCHMAN_FILE" 2>/dev/null | head -1 || echo "not found")
    check_warn "Watchman minMatch check inconclusive → manual verify: $MATCH_VAL"
  fi
fi

# ─── CHECK 6: forbidden_patterns present ──────────────────────────────────────
echo ""
echo "[6/6] Forbidden patterns in compliance_validator.py"

if [[ -n "$CV_FILE" ]]; then
  if grep -q "_FORBIDDEN_PATTERNS" "$CV_FILE" 2>/dev/null; then
    PATTERN_COUNT=$(grep -c '^\s*r"' "$CV_FILE" 2>/dev/null || echo 0)
    if [[ "$PATTERN_COUNT" -gt 5 ]]; then
      check_pass "_FORBIDDEN_PATTERNS present ($PATTERN_COUNT regex entries)"
    else
      check_warn "_FORBIDDEN_PATTERNS present but only $PATTERN_COUNT entries — verify completeness"
    fi
  else
    check_fail "_FORBIDDEN_PATTERNS not found in compliance_validator.py"
  fi
else
  check_warn "compliance_validator.py not found (skip)"
fi

# ─── Summary ──────────────────────────────────────────────────────────────────
echo ""
echo "══════════════════════════════════════════════════════════════"
echo "  RESULT: PASS=$PASS  WARN=$WARN  FAIL=$FAIL"
echo ""
if [[ "$FAIL" -gt 0 ]]; then
  echo "  STATUS: FAIL — $FAIL critical issue(s) found"
  echo "══════════════════════════════════════════════════════════════"
  exit 1
elif [[ "$WARN" -gt 0 ]]; then
  echo "  STATUS: PASS with warnings — review $WARN item(s)"
  echo "══════════════════════════════════════════════════════════════"
  exit 0
else
  echo "  STATUS: PASS — all checks passed"
  echo "══════════════════════════════════════════════════════════════"
  exit 0
fi
