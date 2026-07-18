"""HITL queue stub (file-backed, append-only) + human decision capture.

The queue is jsonl: each state change is a NEW entry (never rewrites — I-24
spirit). Latest entry per card_id wins. Real approvals backend is a later,
separate step; the stub still genuinely changes the outcome (REAL, not mock).
"""

from __future__ import annotations

import json
import uuid
from datetime import UTC, datetime

from .contracts import ConfirmationCard, HumanDecision, LineageEvent
from .gates import AGENT_ID
from .lineage_log import SlicePaths, append_lineage_event


def _now() -> str:
    return datetime.now(UTC).isoformat()


def _append(paths: SlicePaths, entry: dict) -> None:
    paths.base.mkdir(parents=True, exist_ok=True)
    with paths.hitl_queue.open("a", encoding="utf-8") as fh:
        fh.write(json.dumps(entry, ensure_ascii=False) + "\n")


def enqueue(card: ConfirmationCard, paths: SlicePaths) -> None:
    _append(
        paths,
        {
            "type": "card",
            "card_id": card.card_id,
            "intent_id": card.intent_id,
            "correlation_id": card.correlation_id,
            "status": "pending",
            "summary": card.summary,
            "ts": _now(),
        },
    )


def queue_status(card_id: str, paths: SlicePaths) -> str | None:
    if not paths.hitl_queue.exists():
        return None
    status: str | None = None
    with paths.hitl_queue.open(encoding="utf-8") as fh:
        for line in fh:
            entry = json.loads(line)
            if entry.get("card_id") == card_id and "status" in entry:
                status = entry["status"]
    return status


def _card_entry(card_id: str, paths: SlicePaths) -> dict | None:
    if not paths.hitl_queue.exists():
        return None
    found: dict | None = None
    with paths.hitl_queue.open(encoding="utf-8") as fh:
        for line in fh:
            entry = json.loads(line)
            if entry.get("card_id") == card_id and entry.get("type") == "card":
                found = entry
    return found


def decide(card_id: str, decision: str, decided_by: str, paths: SlicePaths) -> str:
    """Apply approve|reject|revoke; returns the final status. Fail-closed on unknown card."""
    card = _card_entry(card_id, paths)
    if card is None:
        raise KeyError(f"unknown card_id: {card_id}")
    if queue_status(card_id, paths) != "pending":
        raise ValueError(f"card {card_id} is not pending — refused")
    final = {"approve": "executed", "reject": "rejected", "revoke": "revoked"}[decision]
    human = HumanDecision(
        decision_id=str(uuid.uuid4()),
        card_id=card_id,
        intent_id=card["intent_id"],
        decided_by=decided_by,
        decision=decision,
        decided_at=_now(),
    )
    _append(
        paths,
        {
            "type": "decision",
            "card_id": card_id,
            "intent_id": card["intent_id"],
            "correlation_id": card["correlation_id"],
            "status": final,
            "decision_id": human.decision_id,
            "decided_by": decided_by,
            "ts": human.decided_at,
        },
    )
    action = {
        "approve": "EXECUTE_TRANSFER_SANDBOX",
        "reject": "REJECTED",
        "revoke": "REVOKED",
    }[decision]
    append_lineage_event(
        LineageEvent(
            record_id=str(uuid.uuid4()),
            timestamp=human.decided_at,
            agent_id=AGENT_ID,
            triggering_event=f"card:{card_id}",
            intent=card["summary"],
            policies_evaluated=["ADR-172:L2-supervised", "ADR-128"],
            compliance_result="PASS" if decision == "approve" else "N/A",
            reasoning_summary=f"human decision: {decision} (sandbox ledger stub)",
            confidence_score=1.0,
            action_taken=action,
            human_reviewed_by=decided_by,
            correlation_id=card["correlation_id"],
        ),
        paths,
    )
    return final
