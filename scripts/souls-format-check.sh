#!/usr/bin/env bash
# souls-format-check.sh — read-only lint for agents/souls/*.md against the ADR-131 format standard.
#
# Verifies every soul carries the MANDATORY sections (all 19 already do — keeps the gate green today)
# and REPORTS the 4 advisory sections added by ADR-131 (Voice/Memory Policy/Core Truths/Pet Peeves)
# without failing, so existing souls can be migrated incrementally. Read-only: edits nothing.
#
# Exit 0 = all souls carry every mandatory section. Exit 1 = at least one mandatory section missing.
# Intended for a FUTURE CI gate; not wired into CI by ADR-131 (concept-only).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SOULS_DIR="$ROOT/agents/souls"

# Mandatory sections "label|regex" — regex is metachar-safe ERE matched after the heading hashes.
# Data Sources is matched by family (any of the 3 current header variants) so the gate stays green
# today; the exact unified header '## Data Sources (read-only)' is the migration target (advisory).
MANDATORY=(
  "Identity|Identity"
  "Core Responsibilities|Core Responsibilities"
  "Tools Available|Tools Available"
  "Data Sources (any → unify to read-only)|Data Sources"
  "Constraints|Constraints"
  "Escalation|Escalation"
  "HITL Gate|HITL Gate"
)
# Advisory sections (ADR-131 extension — reported, never fail).
ADVISORY=("Voice" "Memory Policy" "Core Truths" "Pet Peeves")

rc=0
checked=0
shopt -s nullglob
files=("$SOULS_DIR"/*.md)
# Skip the template itself from the population check.
for f in "${files[@]}"; do
  base="$(basename "$f")"
  [ "$base" = "_TEMPLATE.md" ] && continue
  checked=$((checked + 1))
  for entry in "${MANDATORY[@]}"; do
    label="${entry%%|*}"
    rx="${entry##*|}"
    if ! grep -qE "^#{2,} +${rx}" "$f"; then
      echo "MISSING (mandatory): $base → '$label'"
      rc=1
    fi
  done
  for sec in "${ADVISORY[@]}"; do
    if ! grep -qE "^#{2,} +${sec}" "$f"; then
      echo "advisory (ADR-131, non-failing): $base → '## $sec'"
    fi
  done
done

if [ "$rc" -eq 0 ]; then
  echo "souls-format-check: OK — all mandatory ADR-131 sections present in ${checked} soul(s)."
fi
exit "$rc"
