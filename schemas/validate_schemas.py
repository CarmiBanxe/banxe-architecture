#!/usr/bin/env python3
"""Validation proof for the BANXE governance JSON-Schemas (S2, IL-156 / IL-164).

banxe-architecture has no pytest harness (it is a docs/governance repo), so this
self-contained script IS the validation proof. It is also the command run by the
`guardian-schemas` CI gate (IL-164): exit 0 = pass, non-zero = CI fails.

Coverage (auto-discovered — no hand-maintained list to drift):
  1. EVERY `schemas/*.schema.json` is itself a valid Draft 2020-12 metaschema.
  2. EVERY schema must ship a matching `schemas/examples/<name>.example.json` that
     validates — so a NEW schema added without a passing example FAILS the gate.
     Pre-S2 schemas without an example yet are listed in EXAMPLE_EXEMPT (grandfathered).
  3. The ADR-046 confidence/HITL if/then rule both REJECTS a sub-0.90 record with
     human_reviewed_by=null and ACCEPTS the same record once a reviewer is present.

Run:  python3 schemas/validate_schemas.py     (requires `jsonschema`)
Exit: 0 = all proofs pass, 1 = any failure.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

try:
    from jsonschema import Draft202012Validator
    from jsonschema.exceptions import ValidationError
except ImportError:  # pragma: no cover
    print("FAIL: `jsonschema` not installed — `pip install jsonschema` to run the proof.")
    sys.exit(1)

SCHEMA_DIR = Path(__file__).resolve().parent
EXAMPLES = SCHEMA_DIR / "examples"

# Schemas that predate the S2 example-backed gate (IL-164) and have no example yet.
# Any NEW schema must ship a matching examples/<name>.example.json OR be added here
# with justification — this keeps the gate honest: a new schema without a passing
# example FAILS rather than slipping through uncovered.
EXAMPLE_EXEMPT = {
    "agent_passport.schema.json",
    "scenario_registry.schema.json",
}


def _load(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def _check_schema_set(failures: list[str]) -> None:
    """Every schemas/*.schema.json: valid metaschema + a validating example."""
    schema_files = sorted(SCHEMA_DIR.glob("*.schema.json"))
    if not schema_files:
        failures.append("no schemas/*.schema.json found — nothing to validate")
        return
    for schema_path in schema_files:
        name = schema_path.name
        schema = _load(schema_path)
        # 1. The schema must itself be a valid Draft 2020-12 schema.
        try:
            Draft202012Validator.check_schema(schema)
        except Exception as exc:  # noqa: BLE001
            failures.append(f"{name}: invalid Draft 2020-12 schema: {exc}")
            continue

        # 2. A matching example must exist and validate (unless grandfathered).
        example_path = EXAMPLES / name.replace(".schema.json", ".example.json")
        if not example_path.exists():
            if name in EXAMPLE_EXEMPT:
                print(f"SKIP  {name:<40} (example-exempt, pre-S2)")
                continue
            failures.append(
                f"{name}: no matching example {example_path.name} — every schema "
                "must ship one (add it under schemas/examples/ or to EXAMPLE_EXEMPT)."
            )
            continue

        validator = Draft202012Validator(schema)
        errors = sorted(validator.iter_errors(_load(example_path)), key=str)
        if errors:
            failures.append(
                f"{name}: example {example_path.name} INVALID: "
                + "; ".join(e.message for e in errors)
            )
        else:
            print(f"PASS  {name:<40} <- {example_path.name}")


def main() -> int:
    failures: list[str] = []
    _check_schema_set(failures)

    # 3. ADR-046 confidence/HITL if/then — negative proof: a sub-0.90 confidence
    #    record with human_reviewed_by=null MUST be rejected.
    adr046 = _load(SCHEMA_DIR / "agent_decision_record.schema.json")
    v = Draft202012Validator(adr046)
    bad = _load(EXAMPLES / "agent_decision_record.example.json")
    bad["confidence_score"] = 0.55  # BLOCK band
    bad["human_reviewed_by"] = None  # must now be rejected
    if v.is_valid(bad):
        failures.append(
            "agent_decision_record.schema.json: if/then FAILED — record with "
            "confidence_score<0.9 and human_reviewed_by=null was accepted (must be rejected)."
        )
    else:
        print("PASS  agent_decision_record if/then     <- confidence<0.9 requires human_reviewed_by")

    # 4. ADR-046 if/then positive: same low confidence WITH a reviewer must validate.
    good = _load(EXAMPLES / "agent_decision_record.example.json")
    good["confidence_score"] = 0.55
    good["human_reviewed_by"] = "mlro_agent:operator-amelia"
    try:
        v.validate(good)
        print("PASS  agent_decision_record if/then     <- confidence<0.9 + reviewer accepted")
    except ValidationError as exc:
        failures.append(f"agent_decision_record.schema.json: low-confidence+reviewer rejected: {exc.message}")

    if failures:
        print("\nFAILURES:")
        for f in failures:
            print(f"  - {f}")
        return 1
    print("\nAll governance-schema proofs passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
