#!/usr/bin/env bash
# XOR guard (PRECOND-04, ADR-165 §7): a fork runs agentmemory XOR memoir, never both.
# CI-enforceable layer (config engine-key + this guard + runtime single-registry).
# Fail (exit 1) if BOTH engines are active/present. Ledger (ADR-059) stays source of truth.
set -euo pipefail

REPO_ROOT="${1:-.}"
CFG="$REPO_ROOT/config/memoir/retention.yaml"

# 1) the single source-of-truth engine key
ENGINE=""
if [ -f "$CFG" ]; then
  ENGINE="$(grep -E '^engine:' "$CFG" | head -1 | awk '{print $2}')"
fi
if [ -z "$ENGINE" ]; then
  echo "XOR-guard: no memoir engine config (config/memoir/retention.yaml) — memoir inactive."
  # absence of memoir config is fine (agentmemory-only or neither); nothing to enforce here.
  exit 0
fi
if [ "$ENGINE" != "memoir" ] && [ "$ENGINE" != "agentmemory" ]; then
  echo "XOR-guard: FAIL — unknown engine '$ENGINE' in $CFG"; exit 1
fi

# 2) a conflicting active agentmemory config = both engines → FAIL
AGENTMEM_ACTIVE=0
for f in "$REPO_ROOT"/config/agentmemory/*.enabled \
         "$REPO_ROOT"/config/agentmemory/enabled.yaml; do
  [ -e "$f" ] && AGENTMEM_ACTIVE=1
done

if [ "$ENGINE" = "memoir" ] && [ "$AGENTMEM_ACTIVE" = "1" ]; then
  echo "XOR-guard: FAIL — both memoir AND agentmemory active in the same fork (PRECOND-04)"; exit 1
fi

echo "XOR-guard: OK — exactly one memory engine active ('$ENGINE')."
exit 0
