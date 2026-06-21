#!/usr/bin/env bash
# adr117-gate-check.sh — pre-apply / CI guard for ADR-117 PROPOSED -> ACCEPTED.
# Canon: "Operator = canon"; no facts beyond ADR-117/evidence; RAM evo1/evo2 set by operator.
# Blocks the ACCEPTED flip while any <OPERATOR-DECISION placeholder remains.
# Read-only. Exit 1 = gate fail. Override root for tests: GATE_ROOT=/path bash ...
set -uo pipefail
ROOT="${GATE_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
PLACEHOLDER='<OPERATOR-DECISION'
shopt -s nullglob; adr_files=( "$ROOT"/docs/adr/ADR-117*.md ); shopt -u nullglob
[ "${#adr_files[@]}" -eq 0 ] && { echo "GATE ERROR: ADR-117 file not found"; exit 2; }
adr_file="${adr_files[0]}"
TARGETS=( "$ROOT/docs/DEPLOYMENT-ARCHITECTURE.md" "$ROOT/AGENT-ORG-STRUCTURE.md" "${adr_files[@]}" )
TARGETS=( $(for f in "${TARGETS[@]}"; do [ -f "$f" ] && echo "$f"; done) )
status="$(grep -m1 -E '^- *Status:' "$adr_file" | sed -E 's/^- *Status:[[:space:]]*//' | awk '{print $1}')"
echo "ADR-117 file:   $adr_file"
echo "ADR-117 status: ${status:-UNKNOWN}"
ph_hits="$(grep -rnF "$PLACEHOLDER" "${TARGETS[@]}" 2>/dev/null || true)"
ph_count="$(printf '%s\n' "$ph_hits" | grep -c . || true)"
echo "OPERATOR-DECISION placeholders: $ph_count"
if [ "$status" = "ACCEPTED" ] && [ "$ph_count" -gt 0 ]; then
  echo "GATE FAIL: unfilled OPERATOR-DECISION while ACCEPTED"; printf '%s\n' "$ph_hits"; exit 1
fi
if [ "$status" = "ACCEPTED" ]; then
  ram_open="$(grep -rniE 'RAM[ |:=]{1,4}OPEN' "${TARGETS[@]}" 2>/dev/null || true)"
  if [ -n "$ram_open" ]; then
    if [ "${ADR117_RAM_OPEN_APPROVED:-0}" = "1" ]; then
      echo "GATE WARN: RAM=OPEN under ACCEPTED — allowed (operator Q2=OPEN-follow-up)"
    else
      echo "GATE WARN: RAM=OPEN under ACCEPTED — allowed ONLY if Q2=OPEN-follow-up; set ADR117_RAM_OPEN_APPROVED=1"
    fi
  fi
fi
echo "GATE OK (status=${status:-UNKNOWN}, placeholders=$ph_count)."; exit 0
