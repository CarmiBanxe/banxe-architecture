"""AC-1..AC-7 (build-spec §8): end-to-end sandbox slice."""

from __future__ import annotations

import json
from decimal import Decimal

import pytest

from tools.sandbox.intent_slice import hitl_stub
from tools.sandbox.intent_slice.demo import run_slice
from tools.sandbox.intent_slice.lineage_log import read_lineage
from tools.sandbox.intent_slice.profile import ProfileError, require_dev_fast

TEXT = "переведи 500 EUR Ивану"


def test_ac1_ac2_demo_intent_end_to_end_produces_card(paths):
    result = run_slice(TEXT, "client-e2e", paths)
    assert result["outcome"] == "pending_human"
    card = json.loads((paths.cards_dir / f"card-{result['card_id']}.json").read_text())
    assert card["autonomy_level"] == "L2"
    assert Decimal(card["max_cost"]) > 0
    assert card["amount"] == "500"
    assert (paths.cards_dir / f"card-{result['card_id']}.md").exists()


def test_ac3_approve_and_reject_change_outcome(paths):
    approved = run_slice(TEXT, "client-a", paths)
    rejected = run_slice(TEXT, "client-b", paths)
    assert hitl_stub.decide(approved["card_id"], "approve", "op", paths) == "executed"
    assert hitl_stub.decide(rejected["card_id"], "reject", "op", paths) == "rejected"
    actions = [e["action_taken"] for e in read_lineage(paths)]
    assert "EXECUTE_TRANSFER_SANDBOX" in actions
    assert "REJECTED" in actions


def test_ac3_revoke_before_decision(paths):
    result = run_slice(TEXT, "client-r", paths)
    assert hitl_stub.decide(result["card_id"], "revoke", "client-r", paths) == "revoked"
    with pytest.raises(ValueError):  # not pending anymore — decision refused
        hitl_stub.decide(result["card_id"], "approve", "op", paths)


def test_ac4_lineage_full_trace_single_correlation(paths):
    result = run_slice(TEXT, "client-t", paths)
    hitl_stub.decide(result["card_id"], "approve", "op", paths)
    events = read_lineage(paths)
    assert {e["correlation_id"] for e in events} == {result["correlation_id"]}
    actions = [e["action_taken"] for e in events]
    for expected in (
        "CONSENT_AT_DELEGATION_MOCK_SCA",
        "AUTONOMY_L2",
        "BUDGET_CHARGED",
        "GUARDRAIL_CLEAR",
        "EXECUTE_TRANSFER_SANDBOX",
    ):
        assert expected in actions
    assert len(events) >= 5


def test_ac5_budget_halt_blocks_before_card(paths):
    result = run_slice(TEXT, "client-h", paths, max_cost=Decimal("0.01"))
    assert result["outcome"] == "halted_budget_breach"
    assert not paths.cards_dir.exists()  # halted BEFORE the confirmation card
    breach = [e for e in read_lineage(paths) if e["budget_breach_flag"] == "BREACH"]
    assert breach and breach[0]["escalated_to"] == "human_review_queue"
    queue = [json.loads(x) for x in paths.hitl_queue.read_text().splitlines()]
    assert any(q["type"] == "budget_breach" for q in queue)


def test_ac6_dev_fast_keeps_guardrails_and_is_sandbox_only(paths, monkeypatch):
    # guardrails intact under dev_fast: breach still halts (AC-5 semantics)
    halted = run_slice(TEXT, "client-g", paths, max_cost=Decimal("0.01"))
    assert halted["outcome"] == "halted_budget_breach"
    # fail-closed outside sandbox
    monkeypatch.setenv("SLICE_ENVIRONMENT", "production")
    with pytest.raises(ProfileError):
        require_dev_fast()
    monkeypatch.setenv("SLICE_ENVIRONMENT", "sandbox")
    monkeypatch.delenv("RUNTIME_PROFILE")
    with pytest.raises(ProfileError):
        require_dev_fast()


def test_ac7_sanctions_fail_blocks_before_card(paths):
    result = run_slice("переведи 500 EUR SANCTIONED-TEST", "client-s", paths)
    assert result["outcome"] == "halted_guardrail_sanctions"
    assert not paths.cards_dir.exists()
