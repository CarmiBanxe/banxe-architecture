"""T07–T09: bounded retention + purge + config fail-closed (PRECOND-02)."""

from __future__ import annotations

from dataclasses import replace

import pytest

from factory.memoir.errors import MemoirError, RetentionConfigError
from factory.memoir.retention import load_retention

VALID = """\
schema: memoir-retention/v1
engine: memoir
scope: {fork: factory, perimeter: factory}
bounds: {max_age: P30D, max_entries: 20000, hard_cap_bytes: 268435456}
purge: {purge_schedule: "0 3 * * *", strategy: oldest_first}
"""


def test_T07_retention_bounds_live_count(policy, make_store):
    st = make_store(replace(policy, max_entries=3))
    for i in range(6):
        st.store(f"k{i}", f"content number {i}")
    assert st.count() <= 3  # oldest-first eviction bounds the live set


def test_T08_hard_cap_refuses_oversize(policy, make_store):
    st = make_store(replace(policy, hard_cap_bytes=50))
    with pytest.raises(MemoirError):
        st.store("big", "x" * 200)  # single entry > hard cap ⇒ refuse


def test_T08b_hard_cap_evicts_to_bound(policy, make_store):
    st = make_store(replace(policy, max_entries=10_000, hard_cap_bytes=400))
    for i in range(20):
        st.store(f"k{i}", "y" * 100)
    assert st.live_bytes() <= 400


def test_T09_config_fail_closed_absent(tmp_path):
    with pytest.raises(RetentionConfigError):
        load_retention(tmp_path / "nope.yaml")


def test_T09_config_fail_closed_unbounded(tmp_path):
    bad = VALID.replace("max_entries: 20000", "max_entries: 0")
    p = tmp_path / "r.yaml"
    p.write_text(bad, encoding="utf-8")
    with pytest.raises(RetentionConfigError):
        load_retention(p)


def test_T09_config_valid_loads(tmp_path):
    p = tmp_path / "r.yaml"
    p.write_text(VALID, encoding="utf-8")
    pol = load_retention(p)
    assert pol.engine == "memoir" and pol.fork == "factory"
    assert pol.max_entries == 20000 and pol.hard_cap_bytes == 268435456


def test_T09_config_bad_schema(tmp_path):
    p = tmp_path / "r.yaml"
    p.write_text(VALID.replace("memoir-retention/v1", "bogus/v9"), encoding="utf-8")
    with pytest.raises(RetentionConfigError):
        load_retention(p)
