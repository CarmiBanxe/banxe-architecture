#!/usr/bin/env python3
"""redis_auth_probe.py — fail-closed AUTH preflight for the shared IL allocator (ADR-143-A).

Closes the D1/D2 gap: a TCP-open gate (scripts/add-il-shard.sh reachability check)
passes even when the allocator rejects AUTH, so the mint used to fail later with an
opaque error. This probe performs a REAL authenticated PING before any mint work.

Secret channel is the vault file ONLY (fabric/common/fabric_redis.py contract:
mode-600 file, never on argv, never in env, never logged). Config comes from
ledger/build_ledger.py::_redis_config() — REDIS_HOST / REDIS_PORT / REDIS_PASS_FILE
with the same defaults — so there is exactly one source of connection truth and
this probe can never drift from the allocator it guards.

Usage:
    python3 fabric/common/redis_auth_probe.py

Exit codes (aligned with scripts/add-il-shard.sh):
    0  AUTH + PING OK (prints the counter value as a non-secret diagnostic)
    3  allocator unreachable (TCP/IO failure — the retryable class)
    4  AUTH rejected (NOAUTH / WRONGPASS / auth-plane config drift) — do NOT retry;
       the vault password is out of sync with requirepass on the allocator host.
       See docs/runbooks/allocator-redis-auth.md.
    5  vault file missing / unreadable / empty (REDIS_PASS_FILE)

Refs: ADR-143, ADR-143-A, docs/runbooks/allocator-redis-auth.md,
      docs/runbooks/EVO1-ALLOCATOR-STABILITY-2026-08-02.md.
"""
from __future__ import annotations

import importlib.util
import os
import pathlib
import stat
import sys

EXIT_OK = 0
EXIT_UNREACHABLE = 3
EXIT_AUTH_REJECTED = 4
EXIT_VAULT_MISSING = 5

IL_COUNTER_KEY = "banxe:il:counter"

# Substrings (lowercase) that mark an auth-plane failure rather than a network one.
_AUTH_ERROR_MARKERS = (
    "auth rejected",           # fabric_redis: AUTH reply was not OK
    "noauth",                  # server: command before AUTH
    "wrongpass",               # server: bad password
    "invalid password",        # older redis wording
    "no password is set",      # server has no requirepass — auth-plane config drift
)

ROOT = pathlib.Path(__file__).resolve().parent.parent.parent


def _load_module(name: str, path: pathlib.Path):
    spec = importlib.util.spec_from_file_location(name, str(path))
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def _fail(code: int, message: str) -> int:
    print(f"redis-auth-probe: FAIL ({code}): {message}", file=sys.stderr)
    return code


def _check_vault(pw_path: str) -> str | None:
    """Return an error message if the vault file is unusable, else None."""
    if not os.path.isfile(pw_path):
        return f"vault file not found: {pw_path} (set REDIS_PASS_FILE or provision per runbook)"
    try:
        st = os.stat(pw_path)
        with open(pw_path) as fh:
            content = fh.read().strip()
    except OSError as exc:
        return f"vault file unreadable: {pw_path} ({exc.__class__.__name__})"
    if not content:
        return f"vault file is empty: {pw_path}"
    if st.st_mode & (stat.S_IRWXG | stat.S_IRWXO):
        # Loose perms are a warning, not a failure — AUTH itself still decides.
        print(
            f"redis-auth-probe: WARN: vault file {pw_path} is group/other-accessible "
            "(expected chmod 600)",
            file=sys.stderr,
        )
    return None


def main() -> int:
    build_ledger = _load_module("banxe_build_ledger", ROOT / "ledger" / "build_ledger.py")
    fabric_redis = _load_module("banxe_fabric_redis", ROOT / "fabric" / "common" / "fabric_redis.py")

    host, port, pw_path = build_ledger._redis_config()

    vault_error = _check_vault(pw_path)
    if vault_error is not None:
        return _fail(EXIT_VAULT_MISSING, vault_error)

    client = fabric_redis.RedisStreams(host, port, pw_path)
    try:
        client.connect()  # TCP + AUTH from the vault file (never argv/env/logged)
        if not client.ping():
            return _fail(EXIT_UNREACHABLE, f"PING did not return PONG ({host}:{port})")
        counter = client.get(IL_COUNTER_KEY)
    except fabric_redis.RedisUnavailable as exc:
        message = str(exc)
        if any(marker in message.lower() for marker in _AUTH_ERROR_MARKERS):
            return _fail(
                EXIT_AUTH_REJECTED,
                f"AUTH rejected by {host}:{port} — vault password out of sync with "
                f"requirepass (see docs/runbooks/allocator-redis-auth.md): {message}",
            )
        return _fail(EXIT_UNREACHABLE, f"allocator unreachable {host}:{port}: {message}")
    finally:
        client.close()

    print(f"redis-auth-probe: OK — AUTH+PING {host}:{port}, {IL_COUNTER_KEY}={counter}")
    return EXIT_OK


if __name__ == "__main__":
    sys.exit(main())
