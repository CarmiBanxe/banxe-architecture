#!/usr/bin/env bash
# scripts/preflight.sh — allocator preflight: authenticated PING, vault channel only.
#
# D1 fix (allocator-redis-auth advisory, option B): a bare TCP-open check on 6379
# passes even when the allocator rejects AUTH (NOAUTH/WRONGPASS), so the mint used
# to fail later with an opaque error. This preflight performs a REAL auth-PING via
# fabric/common/redis_auth_probe.py, which reads the password ONLY from the vault
# file (fabric_redis contract: never on argv, never in env, never logged).
# No redis-cli, no password env vars — the env path is explicitly forbidden
# (docs/runbooks/allocator-redis-auth.md).
#
# Config (same source as ledger/build_ledger.py::_redis_config()):
#   REDIS_HOST      allocator host (default: evo1 100.68.102.48)
#   REDIS_PORT      allocator port (default: 6379)
#   REDIS_PASS_FILE vault file (default: ~/banxe-fabric/.vault/redis.pass)
#
# Exit codes:
#   0  AUTH + PING OK
#   3  allocator unreachable (TCP/IO — retryable class)
#   4  AUTH rejected — vault password out of sync with requirepass; do NOT retry,
#      follow docs/runbooks/allocator-redis-auth.md
#   5  vault file missing/unreadable/empty
#
# Refs: ADR-143, ADR-143-A, docs/runbooks/allocator-redis-auth.md.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

exec python3 "$REPO_ROOT/fabric/common/redis_auth_probe.py"
