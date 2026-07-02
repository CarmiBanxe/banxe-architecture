#!/usr/bin/env bash
# test-branch-name-gate.sh — deterministic case table for the ADR-060 pre-push gate.
#
# Sources the pure validator is_compliant() from pre-push-branch-name.sh and runs a fixed
# PASS/BLOCK table. No git-state dependence → Legion, evo1, evo2 and CI give an IDENTICAL
# result. Run: `bash scripts/test-branch-name-gate.sh` (exit 0 = all green).
set -u
DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=pre-push-branch-name.sh
. "$DIR/pre-push-branch-name.sh"

cases=(
  # compliant
  "agent/factory/archstack002/sp-thin|PASS"
  "agent/factory/archstacksubA/sp-orgcanon|PASS"
  "agent/central/c1/x|PASS"
  "agent/right/r1/long-slug.with_dots-2|PASS"
  "agent/factory/UPPERID/x|PASS"
  "agent/specproj/sp01/thin-spec-lane|PASS"
  "main|PASS"
  "dependabot/pip/foo|PASS"
  "refs/heads/agent/factory/archstack002/x|PASS"
  # violations — hyphen in <id> (the evo2 bug)
  "agent/factory/archstack-subA/x|BLOCK"
  "agent/factory/archstack-subA/sp-orgcanon|BLOCK"
  "refs/heads/agent/factory/bad-id-seg/x|BLOCK"
  # other violations
  "agent/factory/UPPER-id/x|BLOCK"
  "feat/whatever|BLOCK"
  "agent/factory//empty-id|BLOCK"
  "agent/sbox/x/y|BLOCK"
)

fail=0
for c in "${cases[@]}"; do
  b="${c%|*}"; exp="${c##*|}"
  if is_compliant "$b"; then got=PASS; else got=BLOCK; fi
  if [ "$got" = "$exp" ]; then
    printf '✓ %-6s %s\n' "$got" "$b"
  else
    printf '✗ EXPECTED %s GOT %s  %s\n' "$exp" "$got" "$b"; fail=1
  fi
done
if [ "$fail" -eq 0 ]; then echo "ALL CASES GREEN (${#cases[@]} cases)"; else echo "CASES FAILED"; exit 1; fi
