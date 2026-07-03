"""Tests for the central Redis IL allocator (ADR-143).

Covers: incr() monotonicity (mocked RESP, no real socket); FAIL-LOUD (RuntimeError)
on RedisUnavailable — NO silent local fallback unless BANXE_IL_ALLOCATOR=local;
--check offline-determinism (no Redis touched); two concurrent mints over one shared
counter never collide.

Pure stdlib (unittest) — no pip, runs without a real Redis.
"""
import importlib.util
import pathlib
import sys
import unittest

ROOT = pathlib.Path(__file__).resolve().parent.parent


def _load(mod_name, rel_path):
    spec = importlib.util.spec_from_file_location(mod_name, str(ROOT / rel_path))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


fabric_redis = _load("fabric_redis_under_test", "fabric/common/fabric_redis.py")
build_ledger = _load("build_ledger_under_test", "ledger/build_ledger.py")


def _fake_shared_client(shared):
    """A FakeClient class backed by one shared dict — models the single evo1
    Redis counter (get/set/incr atomic on that one integer)."""

    class FakeClient:
        def __init__(self, *a, **k):
            pass

        def get(self, key):
            return str(shared["n"])

        def set(self, key, value):
            shared["n"] = int(value)
            return "OK"

        def incr(self, key):
            shared["n"] += 1
            return shared["n"]

        def close(self):
            pass

    return FakeClient


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


class TestAllocatorFailLoud(unittest.TestCase):
    def test_fail_loud_on_redis_unavailable(self):
        """_alloc_next FAILS LOUD (RuntimeError) when Redis is down — it does NOT
        silently fall back to a local max+1 counter (the IL-thrash collision cause)."""
        import os
        os.environ.pop("BANXE_IL_ALLOCATOR", None)  # ensure no explicit local override
        orig = build_ledger._redis_allocate
        build_ledger._redis_allocate = lambda cur: (_ for _ in ()).throw(
            fabric_redis.RedisUnavailable("down")
        )
        try:
            with self.assertRaises(RuntimeError) as ctx:
                build_ledger._alloc_next(612)
            msg = str(ctx.exception)
            self.assertIn("REFUSED", msg)                    # refuses silent degrade
            self.assertIn("BANXE_IL_ALLOCATOR=local", msg)   # names the explicit escape hatch
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
        shared = {"n": 612}  # ONE central counter (the shared evo1 Redis)
        FakeClient = _fake_shared_client(shared)
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

    def test_seed_floor_when_counter_behind(self):
        """A fresh/behind counter is SEEDED to the frozen max, then incremented —
        so it never hands out a number below an already-assigned one."""
        shared = {"n": 0}  # fresh counter starting at 0
        FakeClient = _fake_shared_client(shared)
        orig = build_ledger._load_fabric_redis
        build_ledger._load_fabric_redis = lambda: (FakeClient, fabric_redis.RedisUnavailable)
        try:
            got = build_ledger._redis_allocate(612)
            self.assertEqual(got, 613)        # seeded to 612 then INCR
            self.assertEqual(shared["n"], 613)
        finally:
            build_ledger._load_fabric_redis = orig


class TestSharedHostConfig(unittest.TestCase):
    def test_targets_evo1_not_localhost(self):
        """Allocator targets the SHARED evo1 Redis by default, NOT local 127.0.0.1."""
        import os
        for var in ("REDIS_HOST", "REDIS_PORT"):
            os.environ.pop(var, None)
        host, port, pw = build_ledger._redis_config()
        self.assertEqual(host, "100.68.102.48")   # evo1 over tailscale
        self.assertNotEqual(host, "127.0.0.1")
        self.assertEqual(port, 6379)
        self.assertIn("redis.pass", pw)            # vault path, not a secret

    def test_explicit_env_override(self):
        """Explicit REDIS_HOST/REDIS_PORT override the evo1 default."""
        import os
        os.environ["REDIS_HOST"] = "10.0.0.9"
        os.environ["REDIS_PORT"] = "6380"
        try:
            host, port, _ = build_ledger._redis_config()
            self.assertEqual((host, port), ("10.0.0.9", 6380))
        finally:
            os.environ.pop("REDIS_HOST", None)
            os.environ.pop("REDIS_PORT", None)

    def test_fail_loud_error_names_target_host(self):
        """When Redis is down, the RuntimeError names the shared evo1 host so the
        miss on the shared counter is visible (not silently 'all ok')."""
        import os
        for var in ("REDIS_HOST", "REDIS_PORT", "BANXE_IL_ALLOCATOR"):
            os.environ.pop(var, None)
        orig = build_ledger._redis_allocate
        build_ledger._redis_allocate = lambda cur: (_ for _ in ()).throw(
            fabric_redis.RedisUnavailable("connect refused")
        )
        try:
            with self.assertRaises(RuntimeError) as ctx:
                build_ledger._alloc_next(613)
            self.assertIn("100.68.102.48:6379", str(ctx.exception))  # evo1 host named
        finally:
            build_ledger._redis_allocate = orig


if __name__ == "__main__":
    unittest.main(verbosity=2)
