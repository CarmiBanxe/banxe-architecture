#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# install-engines.sh — Sprint-B engine installation (PREPARE-ONLY)
#
# OPERATOR-RUN ONLY. The factory PREPARES this script; the OPERATOR EXECUTES it.
# Nothing here runs automatically. These engines are DUAL-USE — install only after
# the operator has reviewed provenance + license (ADR-148, CLAUDE.md §9).
#
# Provenance is bound to the Install Provenance Guardrail (#1004,
# docs/governance/FRAMEWORK-ADOPTION-SPRINT-B.md §Install Provenance Guardrail):
#   trusted             -> install from the verified publisher/local source
#   source-identified   -> build from the verified LOCAL source only
#   [BLOCKING: operator] -> do NOT install until the operator verifies the source
#   blocked             -> do NOT install (wrong/unknown publisher) — escalate
#
# Idempotent: each engine checks `command -v` (or a build marker) before acting.
# ═══════════════════════════════════════════════════════════════════════════════
set -euo pipefail

log()  { echo "[install-engines] $*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# ── trusted (already the working pattern; idempotent no-op if present) ──────────
install_openclaw() {  # guardrail: trusted (npm steipete/vincentkoc)
  if have openclaw; then log "openclaw already installed ($(openclaw --version 2>/dev/null || echo present)) — skip"; return 0; fi
  log "openclaw: install from npm (trusted publisher steipete/vincentkoc)"
  npm install -g openclaw
}

install_aider() {  # guardrail: trusted — REAL package name is aider-chat, NOT aider
  if have aider; then log "aider already installed — skip"; return 0; fi
  log "aider: install pipx package 'aider-chat' (NOT 'aider')"
  pipx install aider-chat
}

install_metaclaw() {  # guardrail: trusted (pipx venv)
  if have metaclaw; then log "metaclaw already installed — skip"; return 0; fi
  log "metaclaw: install via pipx"
  pipx install metaclaw
}

# ── source-identified: LOCAL build only (never a same-named registry package) ──
install_mirofish() {  # guardrail: source-identified, LOCAL-ONLY (~/MiroFish; CarmiBanxe/MiroFish)
  local src="${HOME}/MiroFish"
  if have mirofish; then log "mirofish already available — skip"; return 0; fi
  if [ ! -d "$src" ]; then log "[BLOCKING] mirofish local source $src not found — escalate to operator"; return 0; fi
  log "mirofish: build-from-local at $src (LOCAL-ONLY per guardrail; do NOT pull a registry 'mirofish')"
  # ~/MiroFish ships package.json + Dockerfile + docker-compose.yml (verified). Build locally:
  if [ -f "$src/docker-compose.yml" ]; then
    log "mirofish: 'docker compose build' in $src (operator choice: compose vs npm build)"
    ( cd "$src" && docker compose build )
  elif [ -f "$src/package.json" ]; then
    log "mirofish: 'npm ci' in $src"
    ( cd "$src" && npm ci )
  else
    log "[BLOCKING] mirofish: no docker-compose.yml/package.json in $src — escalate to operator"
  fi
}

# ── [BLOCKING: operator] — no trusted source yet; DO NOT install, escalate ──────
install_nanoclaw() {  # guardrail: pip 2026.3.20 publisher UNVERIFIED
  # [BLOCKING: operator — no trusted source per #1004 guardrail; verify openclaw-family publisher before install; escalate]
  log "nanoclaw: [BLOCKING: operator] publisher unverified (pip 2026.3.20) — NOT installed; verify openclaw-family source, then escalate"
}

# ── blocked — wrong/unknown publisher; NEVER install here ───────────────────────
install_hermes() {
  # BLOCKED per #1004 provenance guardrail — do NOT install; escalate to operator.
  # BANXE ADR-126 Hermes is a canon ROLE, not a public package; public npm hermes=Segment's, pip hermes 0.9.1=unknown.
  log "hermes: BLOCKED per #1004 — no verified source (BANXE canon role, not a public package). NOT installed; escalate to operator."
}
install_ironclaw() {
  # BLOCKED per #1004 provenance guardrail — do NOT install; escalate to operator.
  # Public npm ironclaw publisher=kumareth (wrong publisher / impersonation risk).
  log "ironclaw: BLOCKED per #1004 — wrong publisher (kumareth), impersonation risk. NOT installed; escalate to operator."
}

main() {
  log "PREPARE-ONLY installer — operator-run, dual-use. Provenance bound to #1004 guardrail."
  install_openclaw
  install_aider
  install_metaclaw
  install_mirofish
  install_nanoclaw   # no-op: [BLOCKING: operator]
  install_hermes     # no-op: BLOCKED
  install_ironclaw   # no-op: BLOCKED
  log "done. Blocked/blocking engines (hermes, ironclaw, nanoclaw) were NOT installed — operator escalation required."
}

# Guard: only run when invoked directly by the operator (never sourced/auto-run).
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then main "$@"; fi
