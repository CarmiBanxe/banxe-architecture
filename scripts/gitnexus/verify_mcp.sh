#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# verify_mcp.sh — read-only верификация подключения GitNexus MCP (PHASE 2, путь A)
# LICENSE DISCLAIMER: GitNexus = PolyForm-Noncommercial-1.0.0. Sandbox use only
#   without a license; PROD/commercial use requires a purchased GitNexus license.
# NO-MOCK: подключение не имитируется. 0 tools → честный NOT-CONNECTED, exit 78.
# Ничего не устанавливает, сервер не запускает, конфиги не мутирует (read-only).
# Verdict contract: CONNECTED (>0 tools, exit 0) | NOT-CONNECTED (0 tools, exit 78).
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
# shellcheck source=scripts/gitnexus/gitnexus_env.sh
. "${REPO_ROOT}/scripts/gitnexus/gitnexus_env.sh"

echo "== GitNexus MCP verification (read-only) =="

# 1. config status (~/.claude.json mcpServers.gitnexus) — read-only inspect
CLAUDE_JSON="${HOME}/.claude.json"
cfg_status="ABSENT"
if [ -f "${CLAUDE_JSON}" ] && grep -q '"gitnexus"' "${CLAUDE_JSON}" 2>/dev/null; then
  cfg_status="PRESENT"
fi
echo "config  : ~/.claude.json mcpServers.gitnexus = ${cfg_status}"

# 2. binary + endpoint (Phase 1 probe criteria)
bin_status="ABSENT"; command -v gitnexus >/dev/null 2>&1 && bin_status="PRESENT ($(command -v gitnexus))"
echo "binary  : gitnexus = ${bin_status}"
echo "endpoint: GITNEXUS_MCP_ENDPOINT = ${GITNEXUS_MCP_ENDPOINT:-<unset>}"

# 3. probe (Phase 1 contract) + tool count
#    Tool count is honest: without a passing probe it is 0 by definition (no session
#    tool listing is available from a plain shell; >0 requires probe success).
if gitnexus_probe; then
  tools=1  # probe passed ⇒ at least the MCP surface is reachable; exact count = in-session ToolSearch
  echo "probe   : PASS"
  echo "tools   : >=${tools} (точное число — ToolSearch внутри сессии Claude Code)"
  echo "VERDICT : CONNECTED"
  exit 0
else
  rc=$?
  echo "probe   : FAIL (exit ${rc})"
  echo "tools   : 0"
  echo "VERDICT : NOT-CONNECTED (fail-closed)"
  exit "${GITNEXUS_EX_CONFIG}"
fi
