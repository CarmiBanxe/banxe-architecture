#!/usr/bin/env python3
"""tests/best-decision/validator.py — reference evaluator for the best-decision gate.

Applies the multi-criteria adoption-audit defined in
docs/canon/BEST-DECISION-BOUNDARY.md §3 to each YAML case in this directory and
compares the computed verdict against the case's `expected` field. Exit 0 on
green, non-zero on any mismatch.

This is a *reference* implementation (deterministic; enough to prove the gate
can accept, reject, block, and defer). The production evaluator is Central-owned
and uses the richer method-set catalogued in
docs/sources/best-decision-concept-2026-07-06.md §16.
"""
from __future__ import annotations

import pathlib
import sys

import yaml

ACCEPT_THRESHOLD = 0.65
REJECT_THRESHOLD = 0.40
REVERSIBILITY_FLOOR_DEFAULT = 0.30
MIN_VALUE_FOR_ACCEPT = 0.40

CRITERIA = (
    "value",
    "cost_inverse",
    "risk_inverse",
    "reversibility",
    "strategic_fit",
    "opportunity_cost_inverse",
)


def weighted_sum(scores: dict, weights: dict) -> float:
    return sum(scores[c] * weights[c] for c in CRITERIA)


def evaluate(case: dict) -> str:
    """Return one of: accept | reject-as-not-worth | blocked-out-of-scope | defer."""
    constraints = case.get("constraints", {})

    if constraints.get("emi_scope") == "out":
        return "blocked-out-of-scope"

    weights = case["weights"]
    weight_sum = sum(weights.values())
    if abs(weight_sum - 1.0) > 1e-6:
        raise ValueError(f"{case['id']}: weights must sum to 1.0, got {weight_sum}")

    regime = case.get("regime", "risk-known")

    if regime == "ambiguity-maxmin":
        opt = case["scores_optimistic"]
        pes = case["scores_pessimistic"]
        u_opt = weighted_sum(opt, weights)
        u_pes = weighted_sum(pes, weights)
        u_worst = min(u_opt, u_pes)

        rev_floor = constraints.get("reversibility_floor", REVERSIBILITY_FLOOR_DEFAULT)
        if pes["reversibility"] < rev_floor:
            return "defer" if constraints.get("voi_positive", False) else "reject-as-not-worth"

        if u_worst >= ACCEPT_THRESHOLD:
            return "accept"
        if constraints.get("voi_positive", False):
            return "defer"
        if u_worst <= REJECT_THRESHOLD:
            return "reject-as-not-worth"
        return "defer"

    scores = case["scores"]
    u = weighted_sum(scores, weights)
    rev_floor = constraints.get("reversibility_floor", REVERSIBILITY_FLOOR_DEFAULT)
    if scores["reversibility"] < rev_floor:
        return "reject-as-not-worth"

    if u >= ACCEPT_THRESHOLD and scores["value"] >= MIN_VALUE_FOR_ACCEPT:
        return "accept"

    if u <= REJECT_THRESHOLD or scores["value"] < MIN_VALUE_FOR_ACCEPT:
        return "reject-as-not-worth"

    return "defer"


def run() -> int:
    here = pathlib.Path(__file__).parent
    cases = sorted(here.glob("case-*.yaml"))
    if not cases:
        print("no cases found", file=sys.stderr)
        return 2

    failed = 0
    for path in cases:
        with path.open("r", encoding="utf-8") as fh:
            case = yaml.safe_load(fh)
        expected = case["expected"]
        try:
            actual = evaluate(case)
        except Exception as exc:  # narrow-scope reference evaluator; surface any bug
            print(f"FAIL {case['id']:8} {path.name} — evaluator error: {exc}")
            failed += 1
            continue
        status = "PASS" if actual == expected else "FAIL"
        print(f"{status} {case['id']:8} {path.name} expected={expected} actual={actual}")
        if actual != expected:
            failed += 1

    total = len(cases)
    passed = total - failed
    print(f"\nsummary: {passed}/{total} passed")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    sys.exit(run())
