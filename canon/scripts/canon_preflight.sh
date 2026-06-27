#!/bin/bash
# CANON Preflight — запускается как Claude Code hook (PreToolUse)
# Проверяет что CANON modules загружены и доступны

CANON_DIR="$(dirname "$0")/.."
REQUIRED_MODULES=("CORE.md" "DEV.md" "DECISION.md")
ERRORS=0

for mod in "${REQUIRED_MODULES[@]}"; do
  if [ ! -f "$CANON_DIR/modules/$mod" ]; then
    echo "CANON PREFLIGHT FAIL: missing $mod"
    ERRORS=$((ERRORS + 1))
  fi
done

# Check active profile
PROFILE="${CANON_PROFILE:-DEV}"
# FR_MODULE.md relocated to legal-reference-fr (legal-separation, ADR-140/GAP-085)
# FR_MODULE.md is no longer required in banking canon — LEGAL profile passes without it.

if [ $ERRORS -gt 0 ]; then
  echo "CANON PREFLIGHT: $ERRORS errors — fix before proceeding"
  exit 1
fi

echo "CANON PREFLIGHT OK — profile: $PROFILE, modules: $(ls $CANON_DIR/modules/*.md | wc -l)"
exit 0
