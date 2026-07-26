"""Budget + guardrail gates (build-spec §4.4/§4.5, 8-step flow step 4).

budget_gate: ADR-047 / agent-budget-policy §2/§5 semantics — over cap ⇒ BREACH
lineage record (durable first), HITL signal, verdict "breach"; flow halts
before the confirmation card. guardrail_gate: Tier-A sanctions stub (ADR-173 —
only Tier-A may block) + INVARIANTS.md checks (positive Decimal amount,
blocked jurisdictions). Every block leaves a lineage record.
"""

from __future__ import annotations

import json
import uuid
from datetime import UTC, datetime
from decimal import Decimal, InvalidOperation

from .contracts import BudgetGateResult, ClientIntentRecord, GuardrailDecision, LineageEvent
from .lineage_log import SlicePaths, append_lineage_event
from .profile import DEV_FAST_BUDGET_MULTIPLIER

AGENT_ID = "banxe_payments_agent"
# agent-budget-policy.md §2: max_cost_per_job baseline (USD) for banxe_payments_agent.
BASE_MAX_COST = Decimal("0.30")
ESCALATION_QUEUE = "human_review_queue"
# INVARIANTS.md (I-02): hard-blocked jurisdictions.
BLOCKED_JURISDICTIONS = {"RU", "BY", "IR", "KP", "CU", "MM", "AF", "VE", "SY"}
# Tier-A sanctions stub (mock provider; verdict controllable in tests).
SANCTIONS_STUB: set[str] = {"SANCTIONED-TEST"}


def _now() -> str:
    return datetime.now(UTC).isoformat()


def effective_max_cost(override: Decimal | None = None) -> Decimal:
    """dev_fast widens the cap (numbers only); an explicit override wins (tests)."""
    return override if override is not None else BASE_MAX_COST * DEV_FAST_BUDGET_MULTIPLIER


def _hitl_breach_signal(paths: SlicePaths, record_id: str, reason: str) -> None:
    paths.base.mkdir(parents=True, exist_ok=True)
    entry = {
        "type": "budget_breach",
        "queue": ESCALATION_QUEUE,
        "record_id": record_id,
        "reason": reason,
        "ts": _now(),
    }
    with paths.hitl_queue.open("a", encoding="utf-8") as fh:
        fh.write(json.dumps(entry, ensure_ascii=False) + "\n")


def budget_gate(
    intent: ClientIntentRecord,
    paths: SlicePaths,
    *,
    tokens: int = 1200,
    cost: Decimal = Decimal("0.05"),
    max_cost: Decimal | None = None,
) -> BudgetGateResult:
    cap = effective_max_cost(max_cost)
    if cost > cap:
        reason = f"{AGENT_ID} over budget (cost {cost}/{cap}) — halted"
        record = LineageEvent(
            record_id=str(uuid.uuid4()),
            timestamp=_now(),
            agent_id=AGENT_ID,
            triggering_event=f"intent:{intent.intent_id}",
            intent=intent.natural_language,
            policies_evaluated=["agent-budget-policy/v1", "ADR-047", "dev-fast-profile/v0.1"],
            compliance_result="ESCALATE",
            reasoning_summary=f"budget halt: {reason}",
            confidence_score=1.0,
            action_taken="HALT_BUDGET_EXCEEDED",
            human_reviewed_by=None,
            correlation_id=intent.correlation_id,
            cost_tokens=tokens,
            cost_amount=str(cost),
            budget_breach_flag="BREACH",
            escalated_to=ESCALATION_QUEUE,
        )
        append_lineage_event(record, paths)  # durable before the halt surfaces
        _hitl_breach_signal(paths, record.record_id, reason)
        return BudgetGateResult(
            agent_id=AGENT_ID,
            charged_tokens=tokens,
            charged_cost=str(cost),
            verdict="breach",
            breach_record_id=record.record_id,
            escalation_queue=ESCALATION_QUEUE,
        )
    record = LineageEvent(
        record_id=str(uuid.uuid4()),
        timestamp=_now(),
        agent_id=AGENT_ID,
        triggering_event=f"intent:{intent.intent_id}",
        intent=intent.natural_language,
        policies_evaluated=["agent-budget-policy/v1", "ADR-047", "dev-fast-profile/v0.1"],
        compliance_result="PASS",
        reasoning_summary=f"budget charged within cap ({cost}/{cap})",
        confidence_score=1.0,
        action_taken="BUDGET_CHARGED",
        human_reviewed_by=None,
        correlation_id=intent.correlation_id,
        cost_tokens=tokens,
        cost_amount=str(cost),
    )
    append_lineage_event(record, paths)
    return BudgetGateResult(
        agent_id=AGENT_ID, charged_tokens=tokens, charged_cost=str(cost), verdict="ok"
    )


def guardrail_gate(
    intent: ClientIntentRecord,
    paths: SlicePaths,
    *,
    sanctions: set[str] | None = None,
) -> GuardrailDecision:
    blocked = SANCTIONS_STUB if sanctions is None else sanctions
    recipient = intent.parsed_params.get("recipient", "")
    jurisdiction = intent.parsed_params.get("recipient_jurisdiction", "")

    decision: GuardrailDecision
    try:
        amount_ok = Decimal(intent.parsed_params.get("amount", "0")) > 0
    except InvalidOperation:
        amount_ok = False

    if not amount_ok:
        decision = GuardrailDecision("invariant", "A", "block", "INVARIANTS.md:amount>0 Decimal")
    elif jurisdiction in BLOCKED_JURISDICTIONS:
        decision = GuardrailDecision("jurisdiction", "A", "block", f"I-02:{jurisdiction}")
    elif recipient in blocked:
        decision = GuardrailDecision("sanctions", "A", "block", f"tier-a-stub:{recipient}")
    else:
        decision = GuardrailDecision("sanctions", "A", "clear", "tier-a-stub:no-match")

    record = LineageEvent(
        record_id=str(uuid.uuid4()),
        timestamp=_now(),
        agent_id=AGENT_ID,
        triggering_event=f"intent:{intent.intent_id}",
        intent=intent.natural_language,
        policies_evaluated=["ADR-173:tier-a", "INVARIANTS.md"],
        compliance_result="PASS" if decision.verdict == "clear" else "FAIL",
        reasoning_summary=f"guardrail {decision.check}: {decision.verdict} ({decision.ref})",
        confidence_score=1.0,
        action_taken="GUARDRAIL_CLEAR" if decision.verdict == "clear" else "BLOCK_GUARDRAIL",
        human_reviewed_by=None,
        correlation_id=intent.correlation_id,
    )
    append_lineage_event(record, paths)
    return decision
