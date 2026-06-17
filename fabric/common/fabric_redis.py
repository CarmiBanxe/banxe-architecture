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
