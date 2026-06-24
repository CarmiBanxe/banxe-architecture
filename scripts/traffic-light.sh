#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Traffic-light ("Светофор") audit agent — core. Sprint S-FAC-65 (R1).
# Spec: docs/roadmap/FACTORY-ROADMAP-2026-06-23.md §4.2.
#
# WHAT: read-only health audit across the factory hosts/services; emits a single
#       verdict 🔴 / 🟡 / 🟢 + machine-readable reason; writes an append-only
#       ledger verdict shard per run; publishes the verdict to the Redis fabric
#       stream (S-FAC-62 channel) for dashboard/DORA consumption.
# RULES (§4.2 Constraints): READ-ONLY audit — NO service mutation; HITL on RED
#       (escalation per resilience_agent passport); no --admin/bypass;
#       config-as-data thresholds (config/traffic-light.env, CLAUDE.md §10).
# Owner agents: agents/passports/internal_audit_agent.yaml (primary),
#       agents/passports/resilience_agent.yaml (RED-escalation co-owner).
#
# Verdict rule: any audited service RED ⇒ 🔴; else any YELLOW ⇒ 🟡; else 🟢.
# Exit codes: 0 = GREEN, 10 = YELLOW, 20 = RED, 2 = usage/config error.
#   (Self-test forces a deterministic GREEN regardless of host reachability.)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_FILE="${TL_CONFIG_FILE:-$REPO_ROOT/config/traffic-light.env}"

SELF_TEST=0
PUBLISH=1
WRITE_SHARD=1
for arg in "$@"; do
  case "$arg" in
    --self-test|--dry-run) SELF_TEST=1; PUBLISH=0; WRITE_SHARD=0 ;;
    --no-publish)          PUBLISH=0 ;;
    --no-shard)            WRITE_SHARD=0 ;;
    -h|--help)
      grep -E '^# ' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "STOP: unknown arg '$arg'" >&2; exit 2 ;;
  esac
done

[ -r "$CONFIG_FILE" ] || { echo "STOP: config not readable: $CONFIG_FILE" >&2; exit 2; }
# shellcheck disable=SC1090
. "$CONFIG_FILE"
: "${TL_PROBE_TIMEOUT_SEC:?config missing TL_PROBE_TIMEOUT_SEC}"
: "${TL_VERDICT_STREAM:?config missing TL_VERDICT_STREAM}"
: "${TL_TARGETS:?config missing TL_TARGETS}"

# UTC timestamp helper (audit-only; no host mutation).
now_utc() { date -u +%Y-%m-%dT%H:%M:%SZ; }

# ── Probe one target, read-only. Echo: green | yellow | red ────────────────────
# Reachable+healthy ⇒ green. Unreachable: critical ⇒ red, noncritical ⇒ yellow.
probe() {
  local kind="$1" target="$2" crit="$3" rc=0
  if [ "$SELF_TEST" -eq 1 ]; then echo "green"; return 0; fi
  case "$kind" in
    http)
      command -v curl >/dev/null 2>&1 || { echo "$([ "$crit" = critical ] && echo red || echo yellow)"; return 0; }
      curl -fsS --max-time "$TL_PROBE_TIMEOUT_SEC" -o /dev/null "$target" 2>/dev/null || rc=$? ;;
    tcp)
      local host="${target%%:*}" port="${target##*:}"
      timeout "$TL_PROBE_TIMEOUT_SEC" bash -c "exec 3<>/dev/tcp/$host/$port" 2>/dev/null || rc=$? ;;
    redis)
      local host="${target%%:*}" port="${target##*:}"
      if command -v redis-cli >/dev/null 2>&1; then
        [ "$(timeout "$TL_PROBE_TIMEOUT_SEC" redis-cli -h "$host" -p "$port" PING 2>/dev/null)" = "PONG" ] || rc=1
      else rc=1; fi ;;
    cmd)
      timeout "$TL_PROBE_TIMEOUT_SEC" bash -c "$target" >/dev/null 2>&1 || rc=$? ;;
    *) rc=1 ;;
  esac
  if [ "$rc" -eq 0 ]; then echo "green"
  elif [ "$crit" = critical ]; then echo "red"
  else echo "yellow"; fi
}

# ── Run all probes; aggregate to a single verdict ─────────────────────────────
worst="green"; reasons=""
while IFS='|' read -r name kind tgt crit; do
  [ -z "${name// }" ] && continue
  case "$name" in \#*) continue ;; esac
  st="$(probe "$kind" "$tgt" "$crit")"
  reasons="${reasons}${reasons:+; }${name}=${st}"
  case "$st" in
    red) worst="red" ;;
    yellow) [ "$worst" = "red" ] || worst="yellow" ;;
  esac
done <<EOF
$(printf '%s\n' "$TL_TARGETS")
EOF

case "$worst" in
  green)  EMOJI="🟢"; CODE=0  ;;
  yellow) EMOJI="🟡"; CODE=10 ;;
  red)    EMOJI="🔴"; CODE=20 ;;
esac

TS="$(now_utc)"
REASON="services: ${reasons:-none}"
[ "$SELF_TEST" -eq 1 ] && REASON="SELF-TEST (no host access; forced GREEN) — ${REASON}"

# Verdict event — S-FAC-62 field contract (service/status/reason/ts/source).
VERDICT_JSON=$(printf '{"verdict":"%s","status":"%s","reason":"%s","ts":"%s","source":"traffic-light.sh","owner":"internal_audit_agent","dora_ref":"%s"}' \
  "$worst" "$worst" "$REASON" "$TS" "${TL_DORA_REF:-}")

# ── HITL on RED (resilience_agent passport): announce escalation, do NOT act ───
if [ "$worst" = "red" ] && [ "$SELF_TEST" -eq 0 ]; then
  echo "HITL-ESCALATION (RED): notify resilience_agent / CTIO+COO — read-only audit, NO auto-remediation (I-27)." >&2
fi

# ── Output (always) ───────────────────────────────────────────────────────────
echo "$EMOJI  TRAFFIC-LIGHT $worst  @ $TS"
echo "$VERDICT_JSON"

# ── Publish to Redis fabric stream (skipped in self-test / --no-publish) ──────
if [ "$PUBLISH" -eq 1 ]; then
  if command -v redis-cli >/dev/null 2>&1; then
    redis-cli -h "${TL_REDIS_HOST:-127.0.0.1}" -p "${TL_REDIS_PORT:-6379}" \
      XADD "$TL_VERDICT_STREAM" '*' verdict "$worst" reason "$REASON" ts "$TS" \
      source "traffic-light.sh" >/dev/null 2>&1 \
      && echo "published → $TL_VERDICT_STREAM" \
      || echo "WARN: redis publish failed (degraded; verdict still recorded)" >&2
  else
    echo "WARN: redis-cli absent — publish skipped (host-side wiring AWAITS OPERATOR)" >&2
  fi
fi

# ── Append-only verdict shard per run (skipped in self-test / --no-shard) ─────
if [ "$WRITE_SHARD" -eq 1 ]; then
  shard_dir="$REPO_ROOT/${TL_VERDICT_SHARD_DIR:-ledger/entries/traffic-light-verdicts}"
  mkdir -p "$shard_dir"
  slot="${TS//:/-}"
  shard="$shard_dir/IL-${slot}--verdict-${worst}.md"
  {
    echo "---"
    echo "il_ts: $TS"
    echo "session_id: traffic-light-verdicts"
    echo "source: internal_audit_agent"
    echo "status: DONE"
    echo "---"
    echo "### Traffic-light verdict $EMOJI $worst @ $TS"
    echo "- **verdict:** $worst ($EMOJI)"
    echo "- **reason:** $REASON"
    echo "- **published:** $TL_VERDICT_STREAM"
    echo "- **DORA ref (read-only):** ${TL_DORA_REF:-}"
    echo "- **Refs:** FACTORY-ROADMAP-2026-06-23.md §4.2; KPI-DORA-FRAMEWORK.md; S-FAC-65."
  } > "$shard"
  echo "verdict shard → ${shard#$REPO_ROOT/}"
fi

exit "$CODE"
