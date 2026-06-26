#!/bin/bash
# adr-traceability-check.sh — CI guard for ADR-132 (ADR↔implementation & souls↔SKILLS-MATRIX traceability).
# Modelled on scripts/adr117-gate-check.sh. Read-only: edits nothing.
#
# Checks:
#   (a) every agents/souls/*.md is referenced in docs/SKILLS-MATRIX.md;
#   (b) every ACCEPTED ADR that carries an implementation (NOT concept_only) has a non-empty refs:.
#
# Scope: HARD-fails (exit 1) only on CHANGED/new tracked paths vs the base ref, so the historical debt
# (19 souls not yet in SKILLS-MATRIX) is reported as WARN, never hard-failing (ADR-132 §scope).
# If no base ref is resolvable, runs in soft mode (WARN only, exit 0). Override base: BASE_REF=… .
set -euo pipefail

ROOT="${GATE_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
SKILLS_MATRIX="$ROOT/docs/SKILLS-MATRIX.md"
BASE_REF="${BASE_REF:-origin/main}"

# Resolve the set of files changed vs base (empty if base unresolvable → soft mode).
changed=""
if git -C "$ROOT" rev-parse --verify -q "$BASE_REF" >/dev/null 2>&1; then
  changed="$(git -C "$ROOT" diff --name-only "$BASE_REF"...HEAD 2>/dev/null || true)"
  scope_mode="scoped to changes vs $BASE_REF"
else
  scope_mode="SOFT (base '$BASE_REF' unresolvable — WARN only)"
fi
echo "adr-traceability-check: $scope_mode"

is_changed() { [ -n "$changed" ] && printf '%s\n' "$changed" | grep -qxF "$1"; }

hard=0
warns=0

# ---- (a) souls ↔ SKILLS-MATRIX -------------------------------------------------
if [ -f "$SKILLS_MATRIX" ]; then
  shopt -s nullglob
  for soul in "$ROOT"/agents/souls/*.md; do
    base="$(basename "$soul")"
    [ "$base" = "_TEMPLATE.md" ] && continue
    rel="agents/souls/$base"
    if ! grep -qF "$base" "$SKILLS_MATRIX"; then
      if is_changed "$rel"; then
        echo "FAIL (a): new/changed soul '$rel' is NOT referenced in docs/SKILLS-MATRIX.md"
        hard=$((hard + 1))
      else
        echo "warn (a): historical soul '$rel' not yet in SKILLS-MATRIX (debt — follow-up IL)"
        warns=$((warns + 1))
      fi
    fi
  done
  shopt -u nullglob
else
  echo "warn (a): docs/SKILLS-MATRIX.md not found — skipping souls↔matrix check"
  warns=$((warns + 1))
fi

# ---- (b) ACCEPTED ADR with implementation must have non-empty refs: -------------
shopt -s nullglob
for adr in "$ROOT"/docs/adr/ADR-*.md; do
  rel="docs/adr/$(basename "$adr")"
  status="$(grep -m1 -iE '^(status|- *Status):' "$adr" 2>/dev/null | sed -E 's/^[^:]*:[[:space:]]*//' | awk '{print $1}' || true)"
  [ "$status" = "ACCEPTED" ] || continue
  # concept_only ADRs carry no implementation → traceability refs not required.
  if grep -qiE '^concept_only:[[:space:]]*true' "$adr"; then continue; fi
  # non-empty refs:/relates: block = at least one list item under it.
  if grep -qiE '^(refs|relates):' "$adr" && \
     awk '/^(refs|relates):/{f=1;next} f&&/^[[:space:]]*-[[:space:]]*\S/{print;exit} f&&/^[^[:space:]]/{f=0}' "$adr" | grep -q .; then
    : # ok — has at least one ref
  else
    if is_changed "$rel"; then
      echo "FAIL (b): new/changed implementing ADR '$rel' (ACCEPTED, not concept_only) has empty refs:"
      hard=$((hard + 1))
    else
      echo "warn (b): historical implementing ADR '$rel' has empty refs: (debt — follow-up IL)"
      warns=$((warns + 1))
    fi
  fi
done
shopt -u nullglob

echo "adr-traceability-check: hard=$hard warn=$warns"
if [ "$hard" -gt 0 ]; then
  echo "FAIL: $hard traceability violation(s) on new/changed paths."
  exit 1
fi
echo "adr-traceability-check: OK (no violations on in-scope paths; $warns historical-debt warning(s))."
exit 0
