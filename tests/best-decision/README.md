# tests/best-decision/

Canonical evidence-set for the best-decision adoption-audit gate defined in
`docs/canon/BEST-DECISION-BOUNDARY.md` and formalised by
`docs/adr/ADR-162-best-decision-principle.md`.

## Run

```
python3 tests/best-decision/validator.py
```

Exit 0 = all cases pass. Non-zero = a case's expected verdict did not match the gate's evaluation.

## Layout

- `validator.py` — the small deterministic evaluator that applies the gate to each YAML case.
- `case-a-accept-high-value-low-cost.yaml` — item passes the audit → verdict `accept`.
- `case-b-reject-low-value-high-cost.yaml` — item fails → verdict `reject-as-not-worth`.
- `case-c-credit-blocked.yaml` — item drifts to CREDIT (out-of-scope EMI, `B-EMI-CREDIT-GATE-001`) → verdict `blocked-out-of-scope`.
- `case-d-uncertainty-eu.yaml` — ambiguity-heavy regime; maxmin-EU → expected verdict per case.

The gate logic in `validator.py` is a **deterministic reference implementation** — the operational
gate is Central-owned and richer (real methods per SSOT §16). This is enough evidence that the
gate can accept, reject, block, and defer — proof-of-behaviour, not the production evaluator.

## Cross-refs

- `docs/canon/BEST-DECISION-BOUNDARY.md` §3 (criteria) and §4 (terminal outcomes).
- `docs/sources/best-decision-concept-2026-07-06.md` §16 (workflow).
- `docs/adr/ADR-162-best-decision-principle.md` §D-7.
- `governance/COORDINATION-NOTES.md` — DIRECTIVE B-EMI-CREDIT-GATE-001 (CASE-C anchor).
