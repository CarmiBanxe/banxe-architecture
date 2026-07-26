from __future__ import annotations

import sys
from pathlib import Path

import pytest

# repo root: .../tools/sandbox/intent_slice/tests/conftest.py -> parents[3]
sys.path.insert(0, str(Path(__file__).resolve().parents[4]))

from tools.sandbox.intent_slice.lineage_log import SlicePaths  # noqa: E402


@pytest.fixture
def paths(tmp_path) -> SlicePaths:
    return SlicePaths(tmp_path / "slice")


@pytest.fixture(autouse=True)
def dev_fast_env(monkeypatch):
    monkeypatch.setenv("RUNTIME_PROFILE", "dev_fast")
    monkeypatch.setenv("SLICE_ENVIRONMENT", "sandbox")
