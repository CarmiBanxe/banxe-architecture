#!/usr/bin/env bash
# stub-classifier.sh — read-only stub counter that SEPARATES operator-gated stubs
# from genuinely non-gated ones (ADR-134). Fixes the false "non-gated stubs" indicator
# that lumped operator-gated REWRITE-7 / provider-stubs / PROPOSED-passport (I-27) stubs
# in with true non-gated stubs.
#
# Operator-gated definition (canon): a stub-bearing file that carries a gating marker per
#   docs/governance/CANON-FAST-LANE-SIMPLIFICATION.md (operator-gated additive surfaces) or
#   ADR-087 (DSE MOCK/STUB/LIVE tier matrix, mock-default) or the I-27 PROPOSED-passport gate.
# Such files CANNOT change client/production state until the operator approves → excluded
# from the "non-gated" count (they are gated, just not yet activated).
#
# Read-only: scans tracked files, mutates nothing. Output: text (default) | --json.
# Exit 0 always (informational audit). Scope: code/config (py/ts/sh/yaml), excludes docs/ + ledger/.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
JSON=0; [ "${1:-}" = "--json" ] && JSON=1

# A file is a "stub" if it carries a stub marker.
STUB_RE='\bSTUB\b|\bstub\b|NotImplementedError'
# A stub file is OPERATOR-GATED if it also carries a gating marker (FAST-LANE / ADR-087 / I-27).
GATED_RE='gated on operator|operator[ -]approval|operator-gated|PROPOSED stub|(^|[^A-Za-z])I-27([^0-9]|$)|ADR-087|provider[ _-]?(mode|stub)|REWRITE-7|legacy[ -]?crypto|MOCK/STUB/LIVE|tier matrix|mock-default'

# Candidate stub-bearing files (tracked code/config; exclude docs, ledger, the script itself).
mapfile -t stub_files < <(
  git grep -lIE "$STUB_RE" -- '*.py' '*.ts' '*.sh' '*.yaml' '*.yml' \
    ':!docs/*' ':!ledger/*' ':!scripts/stub-classifier.sh' 2>/dev/null | sort -u || true
)

gated=(); nongated=()
for f in "${stub_files[@]}"; do
  [ -n "$f" ] || continue
  if grep -qEi "$GATED_RE" "$f" 2>/dev/null; then
    gated+=("$f")
  else
    nongated+=("$f")
  fi
done

ng=${#nongated[@]}; og=${#gated[@]}; tot=$((ng + og))

if [ "$JSON" -eq 1 ]; then
  printf '{"total":%d,"non_gated_true":%d,"operator_gated_excluded":%d,' "$tot" "$ng" "$og"
  printf '"non_gated_files":['; for i in "${!nongated[@]}"; do [ "$i" -gt 0 ] && printf ','; printf '"%s"' "${nongated[$i]}"; done; printf '],'
  printf '"operator_gated_files":['; for i in "${!gated[@]}"; do [ "$i" -gt 0 ] && printf ','; printf '"%s"' "${gated[$i]}"; done; printf ']}\n'
  exit 0
fi

echo "═══ STUB CLASSIFIER (ADR-134, read-only) — total stub-bearing files: $tot ═══"
echo
echo "non-gated (TRUE): $ng"
for f in "${nongated[@]}"; do echo "  • $f"; done
[ "$ng" -eq 0 ] && echo "  (none)"
echo
echo "operator-gated (EXCLUDED — FAST-LANE / ADR-087 / I-27): $og"
for f in "${gated[@]}"; do echo "  • $f"; done
[ "$og" -eq 0 ] && echo "  (none)"
echo
echo "→ Report the TRUE non-gated figure ($ng), not the conflated total ($tot)."
exit 0
