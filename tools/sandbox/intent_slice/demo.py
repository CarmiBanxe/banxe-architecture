"""CLI demo: the 8-step sandbox flow intent → confirmation card → human.

Usage (from repo root, RUNTIME_PROFILE=dev_fast required):
  python3 -m tools.sandbox.intent_slice.demo "переведи 500 EUR Ивану"
  python3 -m tools.sandbox.intent_slice.demo --decide approve <card_id>
  python3 -m tools.sandbox.intent_slice.demo --decide reject <card_id>
  python3 -m tools.sandbox.intent_slice.demo --revoke <card_id>
"""

from __future__ import annotations

import argparse
import uuid
from decimal import Decimal

from . import card as card_mod
from . import gates, hitl_stub, normalizer
from .contracts import STATUS_HALTED, STATUS_PENDING, LineageEvent
from .lineage_log import SlicePaths, append_lineage_event
from .profile import ProfileError, require_dev_fast


def _classify(intent_type: str) -> str | None:
    """Autonomy ladder slice mapping (ADR-172): transfer→L2; ≥L3 unsupported."""
    return {"transfer": "L2", "insight": "L1"}.get(intent_type)


def run_slice(
    text: str,
    client_id: str,
    paths: SlicePaths,
    *,
    cost: Decimal = Decimal("0.05"),
    max_cost: Decimal | None = None,
    sanctions: set[str] | None = None,
) -> dict:
    """Steps 1–6 of the flow; steps 7–8 happen via decide()/revoke()."""
    correlation_id = str(uuid.uuid4())  # step 1: receive
    intent = normalizer.normalize_intent(text, client_id, correlation_id, paths)  # step 2

    autonomy = _classify(intent.intent_type)  # step 3
    append_lineage_event(
        LineageEvent(
            record_id=str(uuid.uuid4()),
            timestamp=intent.consent_timestamp,
            agent_id=gates.AGENT_ID,
            triggering_event=f"intent:{intent.intent_id}",
            intent=intent.natural_language,
            policies_evaluated=["ADR-172:ladder"],
            compliance_result="PASS" if autonomy else "FAIL",
            reasoning_summary=f"autonomy classified: {autonomy or 'unsupported (>L2)'}",
            confidence_score=1.0,
            action_taken=f"AUTONOMY_{autonomy}" if autonomy else "REJECT_AUTONOMY",
            human_reviewed_by=None,
            correlation_id=correlation_id,
        ),
        paths,
    )
    if autonomy != "L2":
        intent.status = STATUS_HALTED
        return {"outcome": "rejected_autonomy", "correlation_id": correlation_id}

    budget = gates.budget_gate(intent, paths, cost=cost, max_cost=max_cost)  # step 4a
    if budget.verdict == "breach":
        intent.status = STATUS_HALTED
        return {
            "outcome": "halted_budget_breach",
            "correlation_id": correlation_id,
            "breach_record_id": budget.breach_record_id,
        }

    guardrail = gates.guardrail_gate(intent, paths, sanctions=sanctions)  # step 4b
    if guardrail.verdict != "clear":
        intent.status = STATUS_HALTED
        return {
            "outcome": f"halted_guardrail_{guardrail.check}",
            "correlation_id": correlation_id,
        }

    confirmation = card_mod.build_confirmation_card(intent, budget, autonomy)  # step 5
    json_path, md_path = card_mod.save_card(confirmation, paths)
    hitl_stub.enqueue(confirmation, paths)  # step 6
    intent.status = STATUS_PENDING
    return {
        "outcome": "pending_human",
        "correlation_id": correlation_id,
        "card_id": confirmation.card_id,
        "card_json": json_path,
        "card_md": md_path,
        "lineage": str(paths.lineage),
        "hitl_queue": str(paths.hitl_queue),
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("text", nargs="?", help="intent text, e.g. 'переведи 500 EUR Ивану'")
    parser.add_argument("--client", default="client-demo")
    parser.add_argument("--decide", choices=["approve", "reject"], metavar="DECISION")
    parser.add_argument("--revoke", metavar="CARD_ID")
    parser.add_argument("card_id", nargs="?", help="card_id for --decide")
    args = parser.parse_args(argv)

    try:
        require_dev_fast()
    except ProfileError as exc:
        print(f"REFUSED: {exc}")
        return 2

    paths = SlicePaths.default()
    if args.decide:
        card_id = args.card_id or args.text  # single positional lands in `text`
        if not card_id:
            parser.error("--decide requires <card_id>")
        final = hitl_stub.decide(card_id, args.decide, "operator-sandbox", paths)  # 7–8
        print(f"card {card_id}: {final} · lineage: {paths.lineage}")
        return 0
    if args.revoke:
        final = hitl_stub.decide(args.revoke, "revoke", "client-demo", paths)  # ADR-171 revoke
        print(f"card {args.revoke}: {final} · lineage: {paths.lineage}")
        return 0
    if not args.text:
        parser.error("provide intent text, or --decide/--revoke")

    result = run_slice(args.text, args.client, paths)
    for key, value in result.items():
        print(f"{key}: {value}")
    if result["outcome"] == "pending_human":
        print("next: python3 -m tools.sandbox.intent_slice.demo --decide approve "
              f"{result['card_id']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
