#!/usr/bin/env bash
# test_merge_group_coverage.sh — synthetic merge_group readiness check.
#
# Asserts that every workflow producing a REQUIRED status context also declares a
# `merge_group:` trigger. Without it, the context is never produced in a queue build
# and the entry times out waiting for a check that will never arrive — the same
# failure shape as a required context with no producer at all (GUARDIAN-E2E-REPORT).
#
# Runs offline: the required-context list is pinned below rather than fetched, so the
# test is deterministic in CI and a change to branch protection shows up as a test
# edit rather than as a silent drift.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/../.."

# Required contexts on main (branch protection, 2026-08-06) -> producing workflow.
declare -A PRODUCER=(
  ["guardian-adr117"]="guardian.yml"
  ["guardian-branch-naming"]="guardian.yml"
  ["guardian-factory"]="guardian.yml"
  ["guardian-ledger"]="guardian.yml"
  ["guardian-ledger-shards"]="guardian.yml"
  ["guardian-project"]="guardian.yml"
  ["guardian-schemas"]="guardian.yml"
  ["guardian-traceability"]="guardian.yml"
  ["ledger-append-only"]="guardian.yml"
  ["ledger-build"]="ledger-build.yml"
  ["cosign-sign"]="cosign-sign.yml"
  ["main-merge-serialize"]="main-serialize.yml"
  ["osv-scanner-scan"]="osv-scanner.yml"
  ["sbom-cyclonedx"]="sbom.yml"
  ["codeql-analyze (python) (python)"]="codeql.yml"
)

fail=0; pass=0
for ctx in "${!PRODUCER[@]}"; do
  wf=".github/workflows/${PRODUCER[$ctx]}"
  if [ ! -f "$wf" ]; then
    echo "FAIL: '$ctx' -> $wf does not exist"; fail=$((fail+1)); continue
  fi
  # only the header (everything before `jobs:`) counts as the trigger block
  if sed '/^jobs:/,$d' "$wf" | grep -q 'merge_group'; then
    pass=$((pass+1))
  else
    echo "FAIL: '$ctx' produced by $wf, which declares NO merge_group trigger"; fail=$((fail+1))
  fi
done

echo "merge_group coverage: $pass ok, $fail missing (of ${#PRODUCER[@]} required contexts)"
[ "$fail" -eq 0 ] || { echo "A merge queue enabled in this state would time out on every entry."; exit 1; }
echo "PASS: every required context has a merge_group-capable producer."
