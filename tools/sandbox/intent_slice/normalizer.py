"""Rule-based intent normalizer (v0.1, no LLM): text → ClientIntentRecord.

Only intent_type="transfer". Parses "переведи 500 EUR Ивану" /
"transfer 500 EUR to Ivan". SCA consent is a MOCK, but the consent-at-delegation
lineage event is always written (ADR-171: consent is recorded, not implied).
"""

from __future__ import annotations

import re
import uuid
from datetime import UTC, datetime, timedelta

from .contracts import ClientIntentRecord, LineageEvent
from .gates import AGENT_ID
from .lineage_log import SlicePaths, append_lineage_event

_PATTERN = re.compile(
    r"(?P<amount>\d+(?:[.,]\d+)?)\s*(?P<currency>[A-Za-z]{3})\s+(?:to\s+)?(?P<recipient>\S.*)$"
)


class IntentParseError(ValueError):
    """Text does not match the v0.1 transfer template."""


def normalize_intent(
    text: str, client_id: str, correlation_id: str, paths: SlicePaths
) -> ClientIntentRecord:
    match = _PATTERN.search(text.strip())
    if match is None:
        raise IntentParseError(f"cannot parse transfer intent from: {text!r}")
    amount = match.group("amount").replace(",", ".")
    now = datetime.now(UTC)
    intent = ClientIntentRecord(
        intent_id=str(uuid.uuid4()),
        client_id=client_id,
        intent_type="transfer",
        natural_language=text.strip(),
        parsed_params={
            "amount": amount,
            "currency": match.group("currency").upper(),
            "recipient": match.group("recipient").strip(),
        },
        consent_timestamp=now.isoformat(),
        consent_method="mock-sca-sandbox",
        scope_limits={"max_amount": amount, "recipients": [match.group("recipient").strip()],
                      "window": "single"},
        revocation_method="cli:--revoke",
        expires_at=(now + timedelta(hours=1)).isoformat(),
        linked_agent_id=AGENT_ID,
        linked_budget_policy_id="agent-budget-policy.md#banxe_payments_agent",
        correlation_id=correlation_id,
    )
    append_lineage_event(
        LineageEvent(
            record_id=str(uuid.uuid4()),
            timestamp=now.isoformat(),
            agent_id=AGENT_ID,
            triggering_event=f"intent:{intent.intent_id}",
            intent=intent.natural_language,
            policies_evaluated=["ADR-171:consent-at-delegation"],
            compliance_result="N/A",
            reasoning_summary="consent captured at delegation (mock SCA, sandbox)",
            confidence_score=1.0,
            action_taken="CONSENT_AT_DELEGATION_MOCK_SCA",
            human_reviewed_by=None,
            correlation_id=correlation_id,
        ),
        paths,
    )
    return intent
