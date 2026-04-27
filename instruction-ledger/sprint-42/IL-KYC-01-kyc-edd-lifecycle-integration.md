# IL-KYC-01: Customer Lifecycle FSM × KYC/EDD Pipeline Integration

- Sprint: 42
- Status: PROPOSED
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked GitHub issue: <fill after issue creation>
- Created: 2026-04-27

## Context
Sprint 41 (IL-LCY-01) delivered the Customer Lifecycle FSM
(`services/customer_lifecycle/`). KYC/EDD pipeline lives in `services/kyc/` and
`services/aml/`. Currently the two are not wired: a prospect can reach `ACTIVE` state
without passing KYC screening, and EDD thresholds (I-04: £10k individual / £50k
corporate) are not enforced as FSM guards. FATCA/CRS reporting (IL-HMR-01, Sprint 41)
produces data but does not feed back into lifecycle status.

## Goal
Wire Customer Lifecycle FSM state transitions to require KYC/EDD clearance:
- `prospect → customer`: requires Ballerine KYC `APPROVED` signal
- `customer → restricted`: triggered by AML alert or EDD threshold breach
- `restricted → customer`: requires MLRO manual clearance (L4 HITL gate)
- `customer → closed`: requires FATCA/CRS reporting completion for the period

## Scope
- `services/customer_lifecycle/fsm.py` — add KYC/EDD guards to transitions
- `services/kyc/kyc_port.py` — `KYCPort` Protocol (if not exists)
- `services/aml/aml_thresholds.py` — EDD threshold check integration
- `services/hitl/hitl_service.py` — L4 gate for `restricted → customer`
- `tests/unit/test_lifecycle_kyc_integration.py`
- No changes to `services/reporting/`, `agents/`, or `.claude/*`

## Acceptance criteria
- [ ] `test_prospect_to_customer_requires_kyc_approved` — transition blocked without KYC signal
- [ ] `test_customer_restricted_on_edd_breach` — EDD breach (>£10k individual) triggers `restricted`
- [ ] `test_restricted_to_customer_requires_hitl` — L4 gate enforced, no auto-resolution
- [ ] `test_closed_requires_fatca_crs_complete` — `closed` transition blocked if reporting outstanding
- [ ] `test_blocked_jurisdiction_customer_rejected` — I-02 enforcement at onboarding
- [ ] Sanctions screening (FATCA, CRS) called on `prospect → customer` transition
- [ ] All new code: Decimal amounts (I-01), async/await, full type hints (mypy-compatible)
- [ ] Coverage ≥ 80% on `services/customer_lifecycle/` and `services/kyc/`

## Implementation notes
- FSM guard pattern: `@transition(source='prospect', target='customer', conditions=[kyc_approved])`
- `kyc_approved` condition: calls `KYCPort.get_status(customer_id)` → checks `APPROVED`
- InMemory stub: `InMemoryKYCPort` returns configurable status for tests
- EDD threshold: reuse `aml_thresholds.EDD_INDIVIDUAL_GBP` / `EDD_CORPORATE_GBP` constants
- HITL gate: `hitl_service.require_approval(gate='restricted_to_customer', approver='MLRO')`

## Risks and mitigations
- Risk: Ballerine KYC webhook latency → Mitigation: async event-driven; FSM stays in `pending_kyc` until signal received
- Risk: circular import between lifecycle and kyc services → Mitigation: KYCPort Protocol defined in `services/kyc/ports.py`, imported by lifecycle
- Risk: FATCA/CRS completion check is expensive → Mitigation: cache last report timestamp, only re-check on close request

## Related
- I-01 (Decimal), I-02 (jurisdictions), I-04 (EDD thresholds), I-27 (HITL)
- IL-LCY-01 Sprint 41 (Customer Lifecycle FSM)
- IL-HMR-01 Sprint 41 (FATCA/CRS reporting)
- `services/hitl/hitl_service.py`
- ADR-005 (Protocol DI)
