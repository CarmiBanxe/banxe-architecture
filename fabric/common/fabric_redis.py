"""evo1/Legion fabric redis-streams client — stdlib RESP, no pip (F1.5 stage-2/3.1).

Reads the requirepass ONLY from a mode-600 vault file (never on argv, never logged). Uses
Redis **streams** (XADD / XREVRANGE / XLEN / XGROUP / XREADGROUP / XACK / DEL) — it does NOT
implement the disabled admin commands (CONFIG / FLUSHALL / FLUSHDB / DEBUG). fail-closed: any
connect / AUTH / IO failure raises RedisUnavailable so callers degrade per ADR-104 §5.
"""
from __future__ import annotations

import socket
from typing import Any, Dict, List, Optional


class RedisUnavailable(Exception):
    """Raised on connect/AUTH/IO failure — callers must fail-closed (degraded)."""


class RedisStreams:
    def __init__(self, host: str, port: int, password_path: str, timeout: float = 10.0) -> None:
        self._host = host
        self._port = port
        self._pw_path = password_path
        self._timeout = timeout
        self._sock: Optional[socket.socket] = None
        self._f = None

    def _password(self) -> str:
        with open(self._pw_path) as fh:  # vault file, mode 600 — never echoed
            return fh.read().strip()

    def connect(self) -> None:
        try:
            self._sock = socket.create_connection((self._host, self._port), timeout=self._timeout)
            self._f = self._sock.makefile("rb")
            if self._call("AUTH", self._password()) != "OK":
                raise RedisUnavailable("AUTH rejected")
        except RedisUnavailable:
            raise
        except Exception as exc:
            self._sock = None
            raise RedisUnavailable(f"connect: {exc}") from exc

    def _ensure(self) -> None:
        if self._sock is None:
            self.connect()

    @staticmethod
    def _encode(*args: Any) -> bytes:
        out = b"*%d\r\n" % len(args)
        for a in args:
            b = a if isinstance(a, bytes) else str(a).encode()
            out += b"$%d\r\n%s\r\n" % (len(b), b)
        return out

    def _read(self) -> Any:
        line = self._f.readline()
        if not line:
            raise RedisUnavailable("eof")
        tag, rest = line[:1], line[1:-2]
        if tag == b"+":
            return rest.decode()
        if tag == b"-":
            raise RedisUnavailable("redis error: " + rest.decode())
        if tag == b":":
            return int(rest)
        if tag == b"$":
            n = int(rest)
            if n < 0:
                return None
            data = self._f.read(n)
            self._f.read(2)
            return data.decode(errors="replace")
        if tag == b"*":
            n = int(rest)
            if n < 0:
                return None
            return [self._read() for _ in range(n)]
        raise RedisUnavailable("bad RESP: " + repr(line))

    def _call(self, *args: Any) -> Any:
        self._ensure()
        try:
            self._sock.sendall(self._encode(*args))
            return self._read()
        except RedisUnavailable:
            self._sock = None
            raise
        except Exception as exc:
            self._sock = None
            raise RedisUnavailable(f"io: {exc}") from exc

    def ping(self) -> bool:
        return self._call("PING") == "PONG"

    def incr(self, key: str) -> int:
        """Atomic INCR key -> new integer value (cross-process safe).

        Used by the central IL allocator (ADR-143) so concurrent terminals on
        different worktrees can never mint the same number. Any connect / AUTH /
        IO failure raises RedisUnavailable (via _call), so callers fail-closed and
        degrade per ADR-104 §5.
        """
        return int(self._call("INCR", key))

    def get(self, key: str) -> Optional[str]:
        """GET key -> value (str) or None if unset. Fail-closed via _call.

        Used by the IL allocator (ADR-143-A) to read the shared counter before
        seeding its floor to the frozen sequence max.
        """
        return self._call("GET", key)

    def set(self, key: str, value: Any) -> str:
        """SET key value -> 'OK'. Fail-closed via _call.

        Used by the IL allocator (ADR-143-A) to seed the shared counter floor
        (never a secret; value is the integer IL counter).
        """
        return self._call("SET", key, value)

    def set_nx_ex(self, key: str, value: Any, ttl_seconds: int) -> bool:
        """Atomic advisory-lock acquire: SET key value NX EX ttl.

        Returns True iff the key was set (lock acquired); False if the key is
        already held by another owner (NX prevented the write). The single
        SET ... NX EX round-trip is atomic in Redis, so two terminals racing to
        acquire cannot both win. TTL bounds the lock so a crashed holder cannot
        wedge the writer slot forever (ADR-170 cross-terminal writer-lock).

        Any connect / AUTH / IO failure raises RedisUnavailable (via _call), so
        callers fail-closed and degrade per ADR-104 §5 (never a silent 'acquired').

        Unit-test notes: (1) first call on a fresh key => True; (2) second call
        with a different value while the key is live => False; (3) after DEL/expiry
        => True again; (4) a broken socket => RedisUnavailable, not False.
        """
        # RESP: SET key value NX EX ttl -> 'OK' on set, nil (None) when NX blocks.
        return self._call("SET", key, value, "NX", "EX", int(ttl_seconds)) == "OK"

    def release_if_owner(self, key: str, expected_value: Any) -> bool:
        """Best-effort advisory-lock release: DEL key only if we still own it.

        GET key; if it equals ``expected_value`` (this terminal's token), DEL it
        and return True. Returns False if the key is unset or held by someone else
        (do NOT delete another owner's lock).

        CAVEAT — NOT fully atomic: the GET and DEL are two round-trips, so a
        pathological interleave (our TTL expires and another terminal acquires
        between our GET and DEL) could delete the new owner's lock. A Redis Lua
        CAS (GET==value ? DEL) is the atomic ideal and is listed as an ADR-170
        follow-up; for this ADVISORY lock the GET+DEL window is acceptable because
        TTL already bounds staleness and push-time re-check is the real guard.

        Fail-closed: connect / AUTH / IO failure raises RedisUnavailable via _call.

        Unit-test notes: (1) release with the owning token after acquire => True and
        key gone; (2) release with a wrong token => False and key untouched;
        (3) release on an unset key => False.
        """
        if self._call("GET", key) != expected_value:
            return False
        return int(self._call("DEL", key) or 0) == 1

    def xadd(self, stream: str, fields: Dict[str, str]) -> str:
        flat: List[str] = []
        for k, v in fields.items():
            flat += [k, v]
        return self._call("XADD", stream, "*", *flat)

    def xrevrange(self, stream: str, count: int = 1) -> List[Any]:
        return self._call("XREVRANGE", stream, "+", "-", "COUNT", count) or []

    def xlen(self, stream: str) -> int:
        return int(self._call("XLEN", stream) or 0)

    def xgroup_create(self, stream: str, group: str, start: str = "$", mkstream: bool = True) -> str:
        """Create a consumer group (idempotent: BUSYGROUP => EXISTS)."""
        args = ["XGROUP", "CREATE", stream, group, start]
        if mkstream:
            args.append("MKSTREAM")
        try:
            return self._call(*args)
        except RedisUnavailable as exc:
            if "BUSYGROUP" in str(exc):
                return "EXISTS"
            raise

    def xreadgroup(self, group: str, consumer: str, stream: str,
                   count: int = 10, block_ms: int = 2000, new_only: bool = True) -> List[Any]:
        """Return a list of [id, [field, value, ...]] entries (empty on timeout)."""
        last = ">" if new_only else "0"
        reply = self._call("XREADGROUP", "GROUP", group, consumer, "COUNT", count,
                           "BLOCK", block_ms, "STREAMS", stream, last)
        out: List[Any] = []
        if not reply:
            return out
        for _stream_name, entries in reply:
            for entry in entries or []:
                out.append(entry)
        return out

    def xack(self, stream: str, group: str, *ids: str) -> int:
        return int(self._call("XACK", stream, group, *ids) or 0)

    def close(self) -> None:
        try:
            if self._sock:
                self._sock.close()
        finally:
            self._sock = None


def fields_of(row: Any) -> Dict[str, str]:
    """Parse a stream row [id, [k, v, k, v, ...]] into a dict."""
    if not row or len(row) < 2 or not row[1]:
        return {}
    flat = row[1]
    return {flat[i]: flat[i + 1] for i in range(0, len(flat) - 1, 2)}
