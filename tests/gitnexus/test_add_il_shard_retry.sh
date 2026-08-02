#!/usr/bin/env bash
# Hermetic tests for the T1 retry-with-backoff allocator precheck in
# scripts/add-il-shard.sh (docs/runbooks/EVO1-ALLOCATOR-STABILITY-2026-08-02.md).
# No dependency on evo1. Fail-closed contract (exit 3, no local fallback) verified.
set -u

SCRIPT="$(cd "$(dirname "$0")/../.." && pwd)/scripts/add-il-shard.sh"
FAILS=0

check() {  # check <label> <condition-result>
  if [ "$2" -eq 0 ]; then echo "ok   - $1"; else echo "FAIL - $1"; FAILS=$((FAILS+1)); fi
}

# --- test_new_defaults_present (R-E ceiling ~170s) --------------------------
grep -q 'REDIS_RETRIES:-6' "$SCRIPT"; check "default REDIS_RETRIES extended to 6 (R-E)" $?
grep -q 'REDIS_BACKOFF:-5 10 20 30 45 60' "$SCRIPT"; check "default backoff ladder 5/10/20/30/45/60 present" $?

# --- test_fail_closed_after_retries (knobs overridden for speed) ------------
tmp_err="$(mktemp)"
before_shards="$(find "$(dirname "$SCRIPT")/../ledger/entries" -name 'IL-*.md' | wc -l)"
REDIS_HOST=127.0.0.1 REDIS_PORT=1 REDIS_RETRIES=3 REDIS_BACKOFF="0 0" \
  bash "$SCRIPT" retry-test-fail "should never mint" >/dev/null 2>"$tmp_err"
rc=$?
after_shards="$(find "$(dirname "$SCRIPT")/../ledger/entries" -name 'IL-*.md' | wc -l)"
check "exit code is 3 (fail-closed) after retries"        $([ "$rc" -eq 3 ]; echo $?)
grep -q 'attempt 1/3' "$tmp_err"; check "stderr shows attempt 1/3" $?
grep -q 'attempt 2/3' "$tmp_err"; check "stderr shows attempt 2/3" $?
grep -q 'attempt 3/3' "$tmp_err"; check "stderr shows attempt 3/3" $?
grep -q 'Remedies (pick ONE):' "$tmp_err"; check "Remedies block printed" $?
check "no shard written on fail-closed"                   $([ "$before_shards" = "$after_shards" ]; echo $?)
grep -q 'offline max+1 mint' "$tmp_err"; check "did NOT fall back to local (no offline-mint note)" $([ $? -ne 0 ]; echo $?)
rm -f "$tmp_err"

# --- test_success_first_try (hermetic local listener) -----------------------
tmp_err2="$(mktemp)"
python3 - <<'PY' &
import socketserver, threading
class H(socketserver.BaseRequestHandler):
    def handle(self): pass
with socketserver.TCPServer(("127.0.0.1", 46379), H) as srv:
    threading.Timer(10, srv.shutdown).start()
    srv.serve_forever()
PY
listener_pid=$!
sleep 1
# Listener is NOT a real redis: the precheck (reachability gate) must pass on
# attempt 1; anything after the gate is out of scope for this test.
REDIS_HOST=127.0.0.1 REDIS_PORT=46379 REDIS_RETRIES=2 REDIS_BACKOFF="0" \
  bash "$SCRIPT" retry-test-ok "precheck gate only" >/dev/null 2>"$tmp_err2"
grep -q 'Redis allocator OK (attempt 1): 127.0.0.1:46379' "$tmp_err2"
check "reachable path taken on attempt 1" $?
# cleanup: kill listener; remove any shard the (non-redis) run may have written
kill "$listener_pid" 2>/dev/null; wait "$listener_pid" 2>/dev/null
rm -rf "$(dirname "$SCRIPT")/../ledger/entries/retry-test-ok"
git -C "$(dirname "$SCRIPT")/.." reset -q -- ledger/entries/retry-test-ok 2>/dev/null
rm -f "$tmp_err2"

echo "---"
if [ "$FAILS" -eq 0 ]; then echo "ALL TESTS PASSED"; exit 0; else echo "$FAILS FAILED"; exit 1; fi
