#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# engines-access.sh — simplified engine access (PREPARE-ONLY)
#
# OPERATOR-RUN ONLY. Solves "engines are hard to find": symlinks every INSTALLED
# engine into ~/bin/engines/ and provides `engines-status` (bin + version per engine).
# It installs NOTHING — it only links what is already on PATH. Provenance/install is
# scripts/engines/install-engines.sh (operator-run), bound to the #1004 guardrail.
# ═══════════════════════════════════════════════════════════════════════════════
set -euo pipefail

ENGINES_DIR="${HOME}/bin/engines"
# Only engines with a trusted / source-identified provenance (#1004). Blocked
# engines (hermes, ironclaw) and [BLOCKING] nanoclaw are intentionally excluded.
ENGINES=(openclaw aider metaclaw mirofish ruflo)

log() { echo "[engines-access] $*"; }

link_engines() {
  mkdir -p "$ENGINES_DIR"
  local n=0
  for e in "${ENGINES[@]}"; do
    local p; p="$(command -v "$e" 2>/dev/null || true)"
    if [ -n "$p" ]; then
      ln -sfn "$p" "$ENGINES_DIR/$e"
      log "linked $e -> $p"
      n=$((n+1))
    else
      log "$e not installed — skip (see install-engines.sh / #1004 guardrail)"
    fi
  done
  log "$n engine(s) linked into $ENGINES_DIR"
  log "add to PATH (operator, once):  export PATH=\"\$HOME/bin/engines:\$PATH\""
}

# `engines-status` — print bin + version for each engine (read-only)
engines-status() {
  for e in "${ENGINES[@]}"; do
    local p; p="$(command -v "$e" 2>/dev/null || true)"
    if [ -n "$p" ]; then
      local v; v="$("$e" --version 2>/dev/null | head -1 || echo '?')"
      printf '  %-10s %-45s %s\n' "$e" "$p" "$v"
    else
      printf '  %-10s %-45s %s\n' "$e" "(not installed)" "-"
    fi
  done
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  case "${1:-link}" in
    link)   link_engines ;;
    status) engines-status ;;
    *) echo "usage: $0 [link|status]"; exit 2 ;;
  esac
fi
