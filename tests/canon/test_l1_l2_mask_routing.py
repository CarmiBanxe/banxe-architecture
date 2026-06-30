"""E1 (Sprint-E): E2E validation of L1→L2 routing per planner passport.

Source of truth: docs/canon/passports/planner.yaml (PR #865, ADR-049).
Read-only checks — no Engine logic changes.
"""
import pathlib

import pytest
import yaml

ROOT = pathlib.Path(__file__).resolve().parent.parent.parent
PASSPORT_PATH = ROOT / "docs" / "canon" / "passports" / "planner.yaml"


@pytest.fixture(scope="module")
def passport() -> dict:
    assert PASSPORT_PATH.exists(), f"passport not found: {PASSPORT_PATH}"
    data = yaml.safe_load(PASSPORT_PATH.read_text(encoding="utf-8"))
    assert isinstance(data, dict), "passport must be a YAML mapping"
    return data


@pytest.fixture(scope="module")
def entry_points(passport: dict) -> list[dict]:
    dispatcher = passport.get("dispatcher", {})
    eps = dispatcher.get("entry_points", [])
    assert isinstance(eps, list), "dispatcher.entry_points must be a list"
    return eps


def _get_ep(entry_points: list[dict], intent: str) -> dict:
    matches = [ep for ep in entry_points if ep.get("intent") == intent]
    assert matches, f"no entry_point with intent={intent!r}"
    return matches[0]


# --- Structural ---

def test_planner_passport_exists() -> None:
    assert PASSPORT_PATH.exists()


def test_passport_has_dispatcher(passport: dict) -> None:
    assert "dispatcher" in passport, "passport must have a 'dispatcher' section"


def test_dispatcher_has_entry_points(entry_points: list[dict]) -> None:
    assert len(entry_points) >= 2, "dispatcher must have at least 2 entry_points"


def test_all_entry_points_have_autonomy(entry_points: list[dict]) -> None:
    for ep in entry_points:
        assert "autonomy" in ep, f"entry_point {ep.get('intent')!r} missing 'autonomy'"
        assert ep["autonomy"] in ("L1", "L2", "L3", "L4"), (
            f"autonomy must be Lx, got {ep['autonomy']!r}"
        )


# --- L1: task_decompose ---

def test_task_decompose_autonomy_is_l1(entry_points: list[dict]) -> None:
    ep = _get_ep(entry_points, "task_decompose")
    assert ep["autonomy"] == "L1"


def test_task_decompose_route_contains_planner_agent(entry_points: list[dict]) -> None:
    ep = _get_ep(entry_points, "task_decompose")
    assert "planner-agent" in ep["route"]


def test_task_decompose_route_contains_schema_validator(entry_points: list[dict]) -> None:
    ep = _get_ep(entry_points, "task_decompose")
    assert "schema-validator" in ep["route"]


def test_task_decompose_route_contains_task_creator(entry_points: list[dict]) -> None:
    ep = _get_ep(entry_points, "task_decompose")
    assert "task-creator" in ep["route"]


def test_task_decompose_hitl_gate_is_null(entry_points: list[dict]) -> None:
    ep = _get_ep(entry_points, "task_decompose")
    # L1 = no gate required
    assert ep.get("hitl_gate") is None


# --- L2: sprint_assign ---

def test_sprint_assign_autonomy_is_l2(entry_points: list[dict]) -> None:
    ep = _get_ep(entry_points, "sprint_assign")
    assert ep["autonomy"] == "L2"


def test_sprint_assign_has_hitl_gate(entry_points: list[dict]) -> None:
    ep = _get_ep(entry_points, "sprint_assign")
    assert ep.get("hitl_gate") is not None, "L2 sprint_assign must have a hitl_gate"


def test_sprint_assign_route_contains_planner_agent(entry_points: list[dict]) -> None:
    ep = _get_ep(entry_points, "sprint_assign")
    assert "planner-agent" in ep["route"]


# --- Invariant: L2 entries must have a gate ---

def test_all_l2_entry_points_have_hitl_gate(entry_points: list[dict]) -> None:
    l2_eps = [ep for ep in entry_points if ep.get("autonomy") == "L2"]
    for ep in l2_eps:
        assert ep.get("hitl_gate") is not None, (
            f"L2 entry_point {ep.get('intent')!r} must declare a hitl_gate (ADR-049)"
        )


def test_all_l1_entry_points_have_no_hitl_gate(entry_points: list[dict]) -> None:
    l1_eps = [ep for ep in entry_points if ep.get("autonomy") == "L1"]
    for ep in l1_eps:
        assert ep.get("hitl_gate") is None, (
            f"L1 entry_point {ep.get('intent')!r} must NOT have a hitl_gate"
        )


# --- ADR-049 reference ---

def test_adr049_referenced_in_passport(passport: dict) -> None:
    notes = passport.get("notes", "")
    assert "ADR-049" in str(notes), "passport notes must reference ADR-049"
