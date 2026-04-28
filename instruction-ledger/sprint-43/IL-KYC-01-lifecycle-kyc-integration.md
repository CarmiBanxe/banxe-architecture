# IL-KYC-01: Customer Lifecycle FSM × KYC/EDD Pipeline Integration

- Sprint: 43
- Status: DONE
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked GitHub issue: CarmiBanxe/banxe-emi-stack#5
- PR: CarmiBanxe/banxe-emi-stack#16
- Merge SHA: 4f19c95
- Closed: 2026-04-28

## Summary

Wired Customer Lifecycle FSM state transitions to require KYC/EDD clearance:
- `prospect → customer`: requires Ballerine KYC `APPROVED` signal
- `customer → restricted`: triggered by AML alert or EDD threshold breach
- `restricted → customer`: requires MLRO manual clearance (L4 HITL gate)
- `customer → closed`: requires FATCA/CRS reporting completion

## Deliverables

- `services/customer_lifecycle/fsm.py` — KYC/EDD guards on transitions
- `services/kyc/kyc_port.py` — KYCPort Protocol
- `services/aml/aml_thresholds.py` — EDD threshold check integration
- `services/hitl/hitl_service.py` — L4 gate for restricted → customer
- `tests/unit/test_lifecycle_kyc_integration.py`

## Acceptance criteria — ALL MET

- test_prospect_to_customer_requires_kyc_approved ✅
- test_customer_restricted_on_edd_breach ✅
- test_restricted_to_customer_requires_hitl ✅
- test_closed_requires_fatca_crs_complete ✅
- test_blocked_jurisdiction_customer_rejected ✅
- Coverage ≥ 80% ✅
- Ruff clean, mypy clean ✅

## Related

- I-01 (Decimal), I-02 (jurisdictions), I-04 (EDD thresholds), I-27 (HITL)
- Deferred from Sprint 42 IL-KYC-01
