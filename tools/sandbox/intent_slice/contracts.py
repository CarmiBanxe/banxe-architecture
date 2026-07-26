"""Data contracts (shape per build-spec §5; ADR-171 / ADR-046 field names).

Money crosses boundaries as DecimalStr (str) — never float (INVARIANTS.md).
Every artefact of one request carries the same correlation_id.
"""

from __future__ import annotations

from dataclasses import dataclass, field

DecimalStr = str

# ClientIntentRecord.status values
STATUS_CREATED = "created"
STATUS_PENDING = "pending"
STATUS_CONFIRMED = "confirmed"
STATUS_REJECTED = "rejected"
STATUS_REVOKED = "revoked"
STATUS_EXPIRED = "expired"
STATUS_EXECUTED = "executed"
STATUS_HALTED = "halted"


@dataclass
class ClientIntentRecord:
    """ADR-171 mandate: what the client delegated, limits, consent, revocation."""

    intent_id: str
    client_id: str
    intent_type: str
    natural_language: str
    parsed_params: dict[str, str]
    consent_timestamp: str
    consent_method: str
    scope_limits: dict[str, object]
    revocation_method: str
    expires_at: str
    linked_agent_id: str
    linked_budget_policy_id: str
    correlation_id: str
    status: str = STATUS_CREATED


@dataclass
class ConfirmationCard:
    card_id: str
    intent_id: str
    correlation_id: str
    summary: str
    amount: DecimalStr
    currency: str
    recipient: str
    fee: DecimalStr
    max_cost: DecimalStr
    autonomy_level: str
    expires_at: str
    actions: list[str] = field(default_factory=lambda: ["confirm", "change", "revoke"])


@dataclass
class HumanDecision:
    decision_id: str
    card_id: str
    intent_id: str
    decided_by: str
    decision: str  # approve | reject
    decided_at: str
    comment: str | None = None


@dataclass
class LineageEvent:
    """ADR-046 AgentDecisionRecord shape (subset used by the slice)."""

    record_id: str
    timestamp: str
    agent_id: str
    triggering_event: str
    intent: str
    policies_evaluated: list[str]
    compliance_result: str  # PASS | FAIL | ESCALATE | N/A
    reasoning_summary: str
    confidence_score: float
    action_taken: str
    human_reviewed_by: str | None
    correlation_id: str
    cost_tokens: int = 0
    cost_amount: DecimalStr = "0"
    budget_breach_flag: str = "NONE"  # NONE | WARN | BREACH
    escalated_to: str | None = None


@dataclass
class BudgetGateResult:
    agent_id: str
    charged_tokens: int
    charged_cost: DecimalStr
    verdict: str  # ok | breach
    breach_record_id: str | None = None
    escalation_queue: str | None = None


@dataclass
class GuardrailDecision:
    check: str  # sanctions | jurisdiction | invariant
    source_tier: str  # A | B | C (ADR-173)
    verdict: str  # clear | block | flag
    ref: str
