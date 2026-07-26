from __future__ import annotations

import uuid
from decimal import Decimal

from tools.sandbox.intent_slice import gates
from tools.sandbox.intent_slice.lineage_log import read_lineage
from tools.sandbox.intent_slice.normalizer import normalize_intent


def _intent(paths, text="переведи 500 EUR Ивану"):
    return normalize_intent(text, "client-t", str(uuid.uuid4()), paths)


def test_budget_gate_ok_within_cap(paths):
    intent = _intent(paths)
    result = gates.budget_gate(intent, paths, cost=Decimal("0.05"))
    assert result.verdict == "ok"
    actions = [e["action_taken"] for e in read_lineage(paths)]
    assert "BUDGET_CHARGED" in actions
    assert not paths.hitl_queue.exists()


def test_budget_gate_breach_halts_with_lineage_and_hitl(paths):
    intent = _intent(paths)
    result = gates.budget_gate(intent, paths, cost=Decimal("0.05"), max_cost=Decimal("0.01"))
    assert result.verdict == "breach"
    assert result.escalation_queue == "human_review_queue"
    breach = [e for e in read_lineage(paths) if e["budget_breach_flag"] == "BREACH"]
    assert len(breach) == 1
    assert breach[0]["action_taken"] == "HALT_BUDGET_EXCEEDED"
    assert breach[0]["record_id"] == result.breach_record_id
    assert paths.hitl_queue.exists()  # breach signal enqueued


def test_guardrail_gate_clear(paths):
    intent = _intent(paths)
    decision = gates.guardrail_gate(intent, paths)
    assert decision.verdict == "clear"
    assert decision.source_tier == "A"


def test_guardrail_gate_sanctions_fail_blocks(paths):
    intent = _intent(paths, "переведи 500 EUR SANCTIONED-TEST")
    decision = gates.guardrail_gate(intent, paths)
    assert decision.verdict == "block"
    assert decision.check == "sanctions"
    actions = [e["action_taken"] for e in read_lineage(paths)]
    assert "BLOCK_GUARDRAIL" in actions


def test_guardrail_gate_blocked_jurisdiction(paths):
    intent = _intent(paths)
    intent.parsed_params["recipient_jurisdiction"] = "RU"
    decision = gates.guardrail_gate(intent, paths)
    assert decision.verdict == "block"
    assert decision.check == "jurisdiction"
