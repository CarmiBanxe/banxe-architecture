"""Tests for the central Redis IL allocator (ADR-143).

Covers: incr() monotonicity (mocked RESP, no real socket); graceful fallback to
local max+1 on RedisUnavailable; --check offline-determinism (no Redis touched);
two concurrent mints over one shared counter never collide.

Pure stdlib (unittest) — no pip, runs without a real Redis.
"""
import importlib.util
import io
import pathlib
import sys
import unittest
from contextlib import redirect_stderr

ROOT = pathlib.Path(__file__).resolve().parent.parent


def _load(mod_name, rel_path):
    spec = importlib.util.spec_from_file_location(mod_name, str(ROOT / rel_path))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


fabric_redis = _load("fabric_redis_under_test", "fabric/common/fabric_redis.py")
build_ledger = _load("build_ledger_under_test", "ledger/build_ledger.py")


class TestIncr(unittest.TestCase):
    def test_incr_monotonic(self):
        """incr() returns the monotonically increasing values from INCR."""
        r = fabric_redis.RedisStreams("h", 1, "/nonexistent")
        counter = {"n": 0}

        def fake_call(*args):
            self.assertEqual(args[0], "INCR")
            counter["n"] += 1
            return counter["n"]

        r._call = fake_call  # bypass real socket/_ensure
        self.assertEqual([r.incr("k") for _ in range(4)], [1, 2, 3, 4])

    def test_incr_raises_on_io(self):
        """Any IO/connection error surfaces as RedisUnavailable (fail-closed)."""
        r = fabric_redis.RedisStreams("h", 1, "/nonexistent")

        def boom(*args):
            raise fabric_redis.RedisUnavailable("io")

        r._call = boom
        with self.assertRaises(fabric_redis.RedisUnavailable):
            r.incr("k")


class TestAllocatorFallback(unittest.TestCase):
    def test_fallback_on_redis_unavailable(self):
        """_alloc_next degrades to local max+1 + RACE warning when Redis is down."""
        orig = build_ledger._redis_allocate
        build_ledger._redis_allocate = lambda cur: (_ for _ in ()).throw(
            fabric_redis.RedisUnavailable("down")
        )
        try:
            buf = io.StringIO()
            with redirect_stderr(buf):
                got = build_ledger._alloc_next(612)
            self.assertEqual(got, 613)                       # local max+1
            self.assertIn("RACE POSSIBLE", buf.getvalue())   # loud warning
            self.assertIn("fallback to local max+1", buf.getvalue())
        finally:
            build_ledger._redis_allocate = orig

    def test_explicit_local_mode(self):
        """BANXE_IL_ALLOCATOR=local forces offline path without touching Redis."""
        import os
        sentinel = {"called": False}
        orig = build_ledger._redis_allocate
        build_ledger._redis_allocate = lambda cur: sentinel.__setitem__("called", True)
        os.environ["BANXE_IL_ALLOCATOR"] = "local"
        try:
            self.assertEqual(build_ledger._alloc_next(700), 701)
            self.assertFalse(sentinel["called"])  # Redis never consulted
        finally:
            os.environ.pop("BANXE_IL_ALLOCATOR", None)
            build_ledger._redis_allocate = orig


class TestCheckOfflineDeterministic(unittest.TestCase):
    def test_check_never_touches_redis(self):
        """`build_ledger.py --check` is offline: it must NOT call the Redis allocator
        and must return identical results on repeated runs (rc 0 on a synced repo)."""
        orig = build_ledger._redis_allocate

        def must_not_be_called(cur):
            raise AssertionError("--check must never call the Redis allocator")

        build_ledger._redis_allocate = must_not_be_called
        try:
            rc1 = build_ledger.main(["--check"])
            rc2 = build_ledger.main(["--check"])
            self.assertEqual(rc1, 0)
            self.assertEqual(rc2, 0)  # deterministic / idempotent
        finally:
            build_ledger._redis_allocate = orig


class TestConcurrentMintNoCollision(unittest.TestCase):
    def test_parallel_mints_distinct(self):
        """Two 'parallel' terminals sharing ONE atomic counter get DISTINCT numbers,
        each strictly above the frozen max — the IL-172 duplicate class is impossible."""
        shared = {"n": 612}  # one central counter, like Redis INCR

        class FakeClient:
            def __init__(self, *a, **k):
                pass

            def incr(self, key):
                shared["n"] += 1
                return shared["n"]

            def close(self):
                pass

        orig = build_ledger._load_fabric_redis
        build_ledger._load_fabric_redis = lambda: (FakeClient, fabric_redis.RedisUnavailable)
        try:
            a = build_ledger._redis_allocate(612)  # terminal A
            b = build_ledger._redis_allocate(612)  # terminal B (same counter)
            self.assertEqual({a, b}, {613, 614})  # distinct
            self.assertNotEqual(a, b)
            self.assertGreater(a, 612)
            self.assertGreater(b, 612)
        finally:
            build_ledger._load_fabric_redis = orig

    def test_monotonic_bump_when_counter_behind(self):
        """A fresh/behind counter is bumped until it exceeds the frozen max."""
        shared = {"n": 0}  # fresh counter starting at 0

        class FakeClient:
            def __init__(self, *a, **k):
                pass

            def incr(self, key):
                shared["n"] += 1
                return shared["n"]

            def close(self):
                pass

        orig = build_ledger._load_fabric_redis
        build_ledger._load_fabric_redis = lambda: (FakeClient, fabric_redis.RedisUnavailable)
        try:
            got = build_ledger._redis_allocate(612)
            self.assertEqual(got, 613)  # bumped past the frozen max
        finally:
            build_ledger._load_fabric_redis = orig


if __name__ == "__main__":
    unittest.main(verbosity=2)
