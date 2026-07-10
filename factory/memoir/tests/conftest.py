from __future__ import annotations

from dataclasses import replace
from datetime import timedelta

import pytest

from factory.memoir import registry
from factory.memoir.redaction import RegexEntropyRedactor
from factory.memoir.retention import RetentionPolicy
from factory.memoir.store import GitMemoryStore


@pytest.fixture(autouse=True)
def _reset_registry():
    registry.reset()
    yield
    registry.reset()


@pytest.fixture
def policy() -> RetentionPolicy:
    return RetentionPolicy(
        engine="memoir", fork="factory", max_age=timedelta(days=30),
        max_entries=5, hard_cap_bytes=10_000, purge_schedule="0 3 * * *")


@pytest.fixture
def make_store(tmp_path):
    def _make(pol: RetentionPolicy) -> GitMemoryStore:
        return GitMemoryStore(tmp_path / "mem.git", pol,
                              redactor=RegexEntropyRedactor())
    return _make


@pytest.fixture
def store(policy, make_store) -> GitMemoryStore:
    return make_store(policy)


@pytest.fixture
def with_entries(policy):
    return replace
