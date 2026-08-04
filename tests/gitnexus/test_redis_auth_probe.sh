#!/usr/bin/env bash
# Hermetic tests for fabric/common/redis_auth_probe.py and the AUTH gate in
# scripts/add-il-shard.sh (D1/D2 closure, docs/runbooks/allocator-redis-auth.md).
# No dependency on evo1 or a real Redis: auth-plane behaviour is exercised with a
# tiny in-test RESP responder. Fail-closed contract (exit 3/4/5, no local fallback,
# no shard written) verified.
set -u

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PROBE="$ROOT/fabric/common/redis_auth_probe.py"
SHARD="$ROOT/scripts/add-il-shard.sh"
PREFLIGHT="$ROOT/scripts/preflight.sh"
FAILS=0

check() {  # check <label> <condition-result>
  if [ "$2" -eq 0 ]; then echo "ok   - $1"; else echo "FAIL - $1"; FAILS=$((FAILS+1)); fi
}

VAULT="$(mktemp)"; printf 'test-password\n' > "$VAULT"; chmod 600 "$VAULT"

# Fake RESP server: parses one command per RESP array, replies from a fixed list,
# then closes. Enough to drive AUTH (+PING/GET on the OK path) deterministically.
fake_redis() {  # fake_redis <port> <reply1;reply2;...>  (replies RESP-encoded, \r\n added)
  # NOTE: stdout/stderr MUST be redirected — a backgrounded child holding the
  # command-substitution pipe would block $(fake_redis ...) until server timeout.
  python3 - "$1" "$2" <<'PY' >/dev/null 2>&1 &
import socketserver, sys, threading
port, replies = int(sys.argv[1]), sys.argv[2].split(";")
class H(socketserver.StreamRequestHandler):
    def read_command(self):
        line = self.rfile.readline()
        if not line or not line.startswith(b"*"):
            return None
        for _ in range(int(line[1:].strip())):
            n = int(self.rfile.readline()[1:].strip())
            self.rfile.read(n + 2)
        return True
    def handle(self):
        for reply in replies:
            if self.read_command() is None:
                return
            self.wfile.write(reply.encode().replace(b"\\n", b"\r\n") + b"\r\n")
class S(socketserver.TCPServer):
    allow_reuse_address = True
with S(("127.0.0.1", port), H) as srv:
    threading.Timer(15, srv.shutdown).start()
    srv.serve_forever()
PY
  echo $!
}

# --- exit 5: vault file missing (checked before any network I/O) ------------
REDIS_PASS_FILE=/nonexistent/redis.pass REDIS_HOST=127.0.0.1 REDIS_PORT=1 \
  python3 "$PROBE" >/dev/null 2>&1
check "probe: missing vault file -> exit 5" "$([ $? -eq 5 ]; echo $?)"

# --- exit 5: vault file empty ------------------------------------------------
EMPTY_VAULT="$(mktemp)"; chmod 600 "$EMPTY_VAULT"
REDIS_PASS_FILE="$EMPTY_VAULT" REDIS_HOST=127.0.0.1 REDIS_PORT=1 \
  python3 "$PROBE" >/dev/null 2>&1
check "probe: empty vault file -> exit 5" "$([ $? -eq 5 ]; echo $?)"
rm -f "$EMPTY_VAULT"

# --- exit 3: TCP unreachable -------------------------------------------------
REDIS_PASS_FILE="$VAULT" REDIS_HOST=127.0.0.1 REDIS_PORT=1 \
  python3 "$PROBE" >/dev/null 2>&1
check "probe: unreachable host -> exit 3" "$([ $? -eq 3 ]; echo $?)"

# --- exit 4: WRONGPASS on AUTH ----------------------------------------------
pid="$(fake_redis 46390 '-WRONGPASS invalid username-password pair')"
sleep 1
err4="$(mktemp)"
REDIS_PASS_FILE="$VAULT" REDIS_HOST=127.0.0.1 REDIS_PORT=46390 \
  python3 "$PROBE" >/dev/null 2>"$err4"
rc=$?
check "probe: WRONGPASS -> exit 4"                    "$([ "$rc" -eq 4 ]; echo $?)"
grep -q 'allocator-redis-auth' "$err4"; check "probe: exit-4 message points to runbook" $?
if ! grep -q 'test-password' "$err4"; then pw_leak=0; else pw_leak=1; fi
check "probe: password never in output" "$pw_leak"
kill "$pid" 2>/dev/null; wait "$pid" 2>/dev/null; rm -f "$err4"

# --- exit 0: AUTH + PING + GET happy path ------------------------------------
# shellcheck disable=SC2016  # $4 is RESP bulk-string syntax, not a shell variable
pid="$(fake_redis 46391 '+OK;+PONG;$4\n1234')"
sleep 1
out0="$(mktemp)"
REDIS_PASS_FILE="$VAULT" REDIS_HOST=127.0.0.1 REDIS_PORT=46391 \
  python3 "$PROBE" >"$out0" 2>&1
rc=$?
check "probe: happy path -> exit 0"                   "$([ "$rc" -eq 0 ]; echo $?)"
grep -q 'banxe:il:counter=1234' "$out0"; check "probe: counter diagnostic printed" $?
kill "$pid" 2>/dev/null; wait "$pid" 2>/dev/null; rm -f "$out0"

# --- preflight.sh delegates to the probe (missing vault -> 5) ----------------
REDIS_PASS_FILE=/nonexistent/redis.pass REDIS_HOST=127.0.0.1 REDIS_PORT=1 \
  bash "$PREFLIGHT" >/dev/null 2>&1
check "preflight.sh: missing vault -> exit 5" "$([ $? -eq 5 ]; echo $?)"

# --- add-il-shard: TCP gate passes, AUTH rejected -> exit 4, no shard --------
pid="$(fake_redis 46392 '-WRONGPASS invalid username-password pair')"
sleep 1
errs="$(mktemp)"
before_shards="$(find "$ROOT/ledger/entries" -name 'IL-*.md' | wc -l)"
REDIS_PASS_FILE="$VAULT" REDIS_HOST=127.0.0.1 REDIS_PORT=46392 \
  REDIS_RETRIES=2 REDIS_BACKOFF="0" \
  bash "$SHARD" auth-test-wrongpass "must never mint" >/dev/null 2>"$errs"
rc=$?
after_shards="$(find "$ROOT/ledger/entries" -name 'IL-*.md' | wc -l)"
check "add-il-shard: WRONGPASS after TCP gate -> exit 4" "$([ "$rc" -eq 4 ]; echo $?)"
grep -q 'rejected AUTH' "$errs"; check "add-il-shard: explicit NOAUTH/WRONGPASS message" $?
check "add-il-shard: no shard written on AUTH failure"   "$([ "$before_shards" = "$after_shards" ]; echo $?)"
kill "$pid" 2>/dev/null; wait "$pid" 2>/dev/null; rm -f "$errs"
rm -rf "$ROOT/ledger/entries/auth-test-wrongpass"

# --- add-il-shard: vault missing -> exit 5, no shard -------------------------
pid="$(fake_redis 46393 '+OK')"
sleep 1
before_shards="$(find "$ROOT/ledger/entries" -name 'IL-*.md' | wc -l)"
REDIS_PASS_FILE=/nonexistent/redis.pass REDIS_HOST=127.0.0.1 REDIS_PORT=46393 \
  REDIS_RETRIES=2 REDIS_BACKOFF="0" \
  bash "$SHARD" auth-test-novault "must never mint" >/dev/null 2>&1
rc=$?
after_shards="$(find "$ROOT/ledger/entries" -name 'IL-*.md' | wc -l)"
check "add-il-shard: missing vault -> exit 5"            "$([ "$rc" -eq 5 ]; echo $?)"
check "add-il-shard: no shard written on missing vault"  "$([ "$before_shards" = "$after_shards" ]; echo $?)"
kill "$pid" 2>/dev/null; wait "$pid" 2>/dev/null
rm -rf "$ROOT/ledger/entries/auth-test-novault"

rm -f "$VAULT"
echo "---"
if [ "$FAILS" -eq 0 ]; then echo "ALL TESTS PASSED"; exit 0; else echo "$FAILS FAILED"; exit 1; fi
