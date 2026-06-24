#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Traffic-light Redis session trigger hook — Sprint S-FAC-65 (R1), §4.2.
# Blocks on the fabric/legion session-start stream (S-FAC-62 convention
# fabric:<type-with-colons>, docs/runbooks/bus-redis-streams-2026-06-17.md) and
# runs an ON-DEMAND traffic-light audit whenever a session-start event arrives.
#
# This is the "Redis fabric/legion session trigger" half of §4.2 triggers (the
# other half = cron 08:00/20:00 CEST, deploy/cron/traffic-light.crontab).
#
# HOST-SIDE (operator): run under a supervisor (systemd unit / tmux) on the host
# that owns the fabric redis. This file is the ARTIFACT — not installed from CI.
#   Env: TL_SESSION_STREAM, TL_REDIS_HOST, TL_REDIS_PORT (config/traffic-light.env)
# READ-ONLY: only XREAD (blocking) on the stream; never mutates a service.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${TL_CONFIG_FILE:-$SCRIPT_DIR/../config/traffic-light.env}"
[ -r "$CONFIG_FILE" ] || { echo "STOP: config not readable: $CONFIG_FILE" >&2; exit 2; }
# shellcheck disable=SC1090
. "$CONFIG_FILE"

: "${TL_SESSION_STREAM:?config missing TL_SESSION_STREAM}"
HOST="${TL_REDIS_HOST:-127.0.0.1}"; PORT="${TL_REDIS_PORT:-6379}"

command -v redis-cli >/dev/null 2>&1 || { echo "STOP: redis-cli absent (host-side, AWAITS OPERATOR)" >&2; exit 2; }

# --self-test: prove the wiring parses + the audit runs green, without redis.
if [ "${1:-}" = "--self-test" ]; then
  echo "self-test: trigger hook OK; invoking traffic-light --self-test"
  exec "$SCRIPT_DIR/traffic-light.sh" --self-test
fi

echo "traffic-light trigger: blocking on stream '$TL_SESSION_STREAM' ($HOST:$PORT) …"
last_id='$'   # only new events from now
while true; do
  # BLOCK up to 0 (forever) for the next entry; read-only.
  resp="$(redis-cli -h "$HOST" -p "$PORT" XREAD BLOCK 0 COUNT 1 STREAMS "$TL_SESSION_STREAM" "$last_id" 2>/dev/null || true)"
  [ -z "$resp" ] && continue
  echo "session-start event received → running on-demand traffic-light audit"
  "$SCRIPT_DIR/traffic-light.sh" || true   # verdict recorded; never abort the loop
done
