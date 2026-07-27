#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# gitnexus_env.sh — GitNexus code-contour environment (PHASE 1, sandbox-scope)
# LICENSE DISCLAIMER: GitNexus is licensed under PolyForm-Noncommercial-1.0.0.
#   Sandbox/TRAINING use only without a license. PROD/commercial use requires
#   a purchased GitNexus license.
# Directive: docs/canon/GITNEXUS-CODE-CONTOUR-DIRECTIVE.md (enrich → impact → act)
# BANXE_ENV=sandbox · data_class=TRAINING · PROD_READY=false
# Idempotent: safe to source multiple times. NO-MOCK: no graph data is faked here.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

export GITNEXUS_ENV="${GITNEXUS_ENV:-sandbox}"

# EX_CONFIG per sysexits.h — "MCP not connected" contract code
GITNEXUS_EX_CONFIG=78

# gitnexus_guard — fail-closed outside sandbox (license boundary).
# Returns 0 in sandbox; prints disclaimer and returns 1 otherwise.
gitnexus_guard() {
  if [ "${GITNEXUS_ENV}" != "sandbox" ]; then
    echo "GitNexus license: PolyForm-Noncommercial-1.0.0." >&2
    echo "PROD/commercial use requires a purchased GitNexus license." >&2
    echo "GITNEXUS_ENV=${GITNEXUS_ENV} is not 'sandbox' — fail-closed." >&2
    return 1
  fi
  return 0
}

# gitnexus_probe — detect live MCP availability WITHOUT network calls.
# Criteria (both local): GITNEXUS_MCP_ENDPOINT set AND `gitnexus` binary on PATH.
# 0 tools ⇒ exit code 78 (EX_CONFIG) + reminder-mode message (NO-MOCK: nothing is simulated).
gitnexus_probe() {
  if [ -n "${GITNEXUS_MCP_ENDPOINT:-}" ] && command -v gitnexus >/dev/null 2>&1; then
    return 0
  fi
  echo "MCP not connected — enrich/reindex unavailable; running in reminder+fail-closed mode" >&2
  return "${GITNEXUS_EX_CONFIG}"
}
