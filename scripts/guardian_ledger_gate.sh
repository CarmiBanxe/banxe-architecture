#!/usr/bin/env bash
# guardian_ledger_gate.sh — ledger-coupling gate (ADR-056, ADR-060) with path
# taxonomy classification per Fable-5 + Codex ruling 2026-08-05 (INDEPENDENT):
#
#   canonical       -> IL shard REQUIRED (governance/arch content, ledger/entries/*)
#   administrative  -> shard NOT required (numbering-lifecycle records: gap
#                      register, allocator recovery log) — closed machine list
#   control-infra   -> shard NOT required (security-tooling config/fixtures that
#                      govern HOW the repo is checked) — closed list of EXACT paths,
#                      default-deny: anything under tools/ not listed stays canonical
#   infra/tooling   -> shard NOT required (ADR-056 scope narrowing, unchanged)
#   derived         -> rebuild outputs are gitignored (ADR-060), never diffed here
#
# The administrative list is CLOSED: extending it is a canon change that goes
# through owner review of this script (control-infra class, LEDGER-PATH-TAXONOMY).
# A mixed PR (administrative + canonical paths) gets NO exemption — the shard
# requirement applies because of its canonical part. Renames cannot bypass the
# gate: --no-renames lists both old and new paths, so the old canonical path
# still trips the requirement.
#
# Usage: guardian_ledger_gate.sh <BASE_SHA> <HEAD_SHA>
set -euo pipefail

BASE_SHA="$1"
HEAD_SHA="$2"

LEDGER=INSTRUCTION-LEDGER.md
# Closed, machine-checkable ADMINISTRATIVE ledger paths (records ABOUT numbering,
# not canon content — a shard for a record-about-records is meta-regress):
ADMIN_RE='^ledger/(IL-GAP-REGISTER\.json|ALLOCATOR-RECOVERY-LOG\.md)$'
# Pure infra/tooling — coupling not required (ADR-056 scope, unchanged):
INFRA_RE='^(scripts/|\.github/|ledger/build_ledger\.py$)|\.sh$'
# CONTROL-INFRA allowlist — a CLOSED list of EXACT paths, never a prefix.
#
# Security tooling that configures or tests a detector is control infrastructure: it
# governs how the repository is checked, not what the repository asserts. Such files
# carry no canon and narrating each one in a shard is noise, not traceability.
#
# DEFAULT-DENY, and the shape of this variable is the enforcement. There is deliberately
# NO '^tools/' prefix: a prefix would silently exempt every future file dropped under
# tools/, including canonical content that merely happens to live there. Anchored exact
# paths mean an unlisted file under tools/ stays CANONICAL and still requires a shard.
#
# Extending this list is a canon change: it is reviewed on this script, by the operator
# (see .github/CODEOWNERS -> tools/**), in a PR of its own — never in the same PR as the
# files it would exempt.
TOOLING_ALLOWLIST_RE='^tools/gitleaks-fix/(README\.md|env-indirection-allowlist\.toml|regression_test\.sh|fixtures/(01-clickhouse-negative\.py|02-clickhouse-positive\.py|03-postgres-negative\.py|04-postgres-positive\.py|05-authsecret-negative\.yml|06-authsecret-positive\.py|07-githubpat-negative\.sh|08-githubpat-positive\.sh|09-marble-negative\.yml|10-marble-positive\.py))$'

CHANGED=$(git diff --no-renames --name-only "$BASE_SHA" "$HEAD_SHA")
echo "Changed files:"
echo "$CHANGED"

NONLEDGER=$(echo "$CHANGED" | grep -v "^$LEDGER$" || true)
NONINFRA=$(echo "$NONLEDGER" | grep -vE "$INFRA_RE" || true)
NONADMIN=$(echo "$NONINFRA" | grep -vE "$ADMIN_RE" || true)
NONADMIN=$(echo "$NONADMIN" | grep -vE "$TOOLING_ALLOWLIST_RE" || true)

if [ -n "$NONLEDGER" ] && [ -z "$NONADMIN" ]; then
  echo "guardian-ledger OK (infra/administrative/control-infra-only change — shard coupling not required; ADR-056 + LEDGER-PATH-TAXONOMY 2026-08-05/06)"
else
  if [ -n "$NONADMIN" ]; then
    NEW_SHARD=$(git diff --no-renames --name-status "$BASE_SHA" "$HEAD_SHA" -- 'ledger/entries/' | grep -E '^A' | grep -E 'IL-.*\.md$' || true)
    if [ -z "$NEW_SHARD" ]; then
      echo "FAIL: PR changes canonical tracked paths but adds no new ledger/entries shard (ADR-056 / ADR-060 — rebuild files are gitignored, add shard via scripts/add-il-shard.sh). Canonical paths in this PR:"
      echo "$NONADMIN"
      exit 1
    fi
  fi
fi

DELETED=$(git diff "$BASE_SHA" "$HEAD_SHA" -- "$LEDGER" | grep -E '^-[^-]' || true)
if [ -n "$DELETED" ]; then
  echo "FAIL: $LEDGER must be append-only (Invariant I-28); deletions detected:"
  echo "$DELETED"
  exit 1
fi

echo "guardian-ledger OK"
