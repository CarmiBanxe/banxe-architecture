#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# engine-health-check.sh — engine liveness check (PREPARE-ONLY, READ-ONLY)
#
# OPERATOR-RUN ONLY. One-shot health probe of installed engines: checks bin presence
# and (where applicable) a listening port. Prints STATUS; on failure prints ALERT.
# It changes NOTHING. 7/24 daemonisation is the OPERATOR's to run (systemd timer /
# cron) — this script does NOT daemonise itself. Implements the read-only probe of
# the EngineHealthAgent passport (config/agents/passports/engine-health-agent.yaml).
# ═══════════════════════════════════════════════════════════════════════════════
set -uo pipefail   # NB: no -e — a single engine being down must not abort the sweep

log()   { echo "[engine-health] $*"; }
alert() { echo "[engine-health] ALERT: $*" >&2; }

have()   { command -v "$1" >/dev/null 2>&1; }
port_up() { (exec 3<>"/dev/tcp/127.0.0.1/$1") >/dev/null 2>&1; }   # read-only TCP connect

# engine -> optional port (empty = bin-only check). Only trusted/source-identified engines.
check_engine() {
  local name="$1" port="${2:-}"
  if have "$name"; then
    if [ -n "$port" ]; then
      if port_up "$port"; then log "OK   $name (bin + port $port up)"; else alert "$name bin present but port $port DOWN"; fi
    else
      log "OK   $name (bin present)"
    fi
  else
    # blocked/blocking engines are expected-absent — report, do not alert as failure
    log "MISS $name (not installed)"
  fi
}

main() {
  log "read-only health sweep $(command -v date >/dev/null && date -u '+%FT%TZ' || echo now)"
  check_engine openclaw ""
  check_engine aider    ""
  check_engine metaclaw ""
  check_engine mirofish 3001     # MiroFish research agent port (per .claude/rules/agents.md)
  check_engine ruflo    ""
  # gateways the engines route through (read-only reachability, no auth attempted):
  port_up 4000  && log "OK   litellm-gateway :4000" || alert "litellm-gateway :4000 DOWN"
  port_up 11434 && log "OK   ollama :11434"          || alert "ollama :11434 DOWN"
  log "sweep done. blocked engines (hermes/ironclaw) + [BLOCKING] nanoclaw are expected-absent per #1004."
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then main "$@"; fi
