#!/usr/bin/env python3
"""Validation proof for the BANXE governance JSON-Schemas (S2, IL-156).

banxe-architecture has no pytest harness (it is a docs/governance repo), so this
self-contained script IS the validation proof: it loads each Draft 2020-12 schema,
checks the schema itself is a valid Draft 2020-12 metaschema, validates the matching
schemas/examples/*.json sample, and asserts the ADR-046 confidence/HITL if/then rule
both passes (valid record) and fails (negative case).

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

# schema file -> example file
PAIRS = {
    "agent_decision_record.schema.json": "agent_decision_record.example.json",
    "cost_cap.schema.json": "cost_cap.example.json",
    "process_ref.schema.json": "process_ref.example.json",
}


def _load(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> int:
    failures: list[str] = []

    for schema_name, example_name in PAIRS.items():
        schema = _load(SCHEMA_DIR / schema_name)
        # 1. The schema must itself be a valid Draft 2020-12 schema.
        try:
            Draft202012Validator.check_schema(schema)
        except Exception as exc:  # noqa: BLE001
            failures.append(f"{schema_name}: invalid Draft 2020-12 schema: {exc}")
            continue

        validator = Draft202012Validator(schema)
        # 2. The matching example must validate.
        example = _load(EXAMPLES / example_name)
        errors = sorted(validator.iter_errors(example), key=str)
        if errors:
            failures.append(
                f"{schema_name}: example {example_name} INVALID: "
                + "; ".join(e.message for e in errors)
            )
        else:
            print(f"PASS  {schema_name:<40} <- {example_name}")

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
