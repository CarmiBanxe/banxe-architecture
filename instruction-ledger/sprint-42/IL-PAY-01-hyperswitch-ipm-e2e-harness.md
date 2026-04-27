# IL-PAY-01: Hyperswitch + Mastercard IPM End-to-End Harness

- Sprint: 42
- Status: DEFERRED_TO_SPRINT_43
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked GitHub issue: CarmiBanxe/banxe-emi-stack#7
- Created: 2026-04-27

## Context
Payment rail integration (ClearBank/Modulr, Hyperswitch PSP, Mastercard IPM) is listed as
Critical P1 in the banxe-emi-stack backlog. No end-to-end harness exists that covers the
full lifecycle: auth → SCA challenge → settlement → reconciliation against Midaz ledger.
Invariants I-01 (Decimal amounts) and I-02 (blocked jurisdictions) must be enforced at
every step. The current CI has no payment integration tests.

## Goal
Build an end-to-end test harness in `tests/integration/payments/` covering:
1. Payment authorisation via Hyperswitch adapter
2. SCA (Strong Customer Authentication) challenge and completion
3. Settlement notification processing
4. Reconciliation of settled amount against Midaz ledger balance
5. Blocked-jurisdiction rejection (I-02: RU/BY/IR/KP/CU/MM/AF/VE/SY)

## Scope
- `services/payment/` — Hyperswitch adapter implementation
- `services/recon/` — settlement reconciliation
- `tests/integration/payments/test_ipm_e2e.py` — harness entry point
- `tests/integration/payments/fixtures/` — IPM message fixtures (CAMT.053-style)
- `services/aml/aml_thresholds.py` — jurisdiction block integration
- No changes to `services/reporting/`, `services/kyc/`, or `agents/`

## Acceptance criteria
- [ ] `test_payment_auth_success` — happy path auth returns `AUTHORISED` status
- [ ] `test_payment_sca_challenge` — SCA flow completes and payment resumes
- [ ] `test_payment_settlement_reconciled` — settled amount matches Midaz balance (Decimal, I-01)
- [ ] `test_payment_blocked_jurisdiction_rejected` — RU/IR/KP origin raises `JurisdictionBlockedError` (I-02)
- [ ] `test_payment_duplicate_idempotency_key` — replay returns same result, no double-charge
- [ ] All tests use InMemory stubs for Hyperswitch and Midaz (no external calls in CI)
- [ ] Coverage ≥ 80% on `services/payment/`
- [ ] Ruff clean, Semgrep clean, no float for amounts

## Implementation notes
- Hyperswitch API: self-hosted at `:8080` (dev), env var `HYPERSWITCH_BASE_URL`
- IPM fixtures: use synthetic CAMT.053 XML derived from real Mastercard IPM structure
- Decimal invariant (I-01): all amounts as `Decimal`, never `float`; Semgrep rule `banxe-float-money` enforces
- SCA adapter: use `services/auth/sca_adapter.py` (committed in Sprint 41 `82b69b2`)
- Protocol DI: `PaymentPort` Protocol → `HyperswitchAdapter` (real) / `InMemoryPaymentAdapter` (tests)

## Risks and mitigations
- Risk: Mastercard IPM format complexity → Mitigation: start with synthetic fixtures, real format in Sprint 43
- Risk: Decimal precision mismatch between Hyperswitch (string) and Midaz (Decimal) → Mitigation: explicit `Decimal(str(amount))` conversion at adapter boundary
- Risk: SCA timeout in test → Mitigation: inject deterministic clock, no real sleeps in tests

## Related
- I-01 (Decimal invariant), I-02 (jurisdiction block)
- `services/auth/sca_adapter.py` (Sprint 41, `82b69b2`)
- `services/recon/` (reconciliation engine)
- IL-KYC-01 (KYC/EDD pipeline integration)
- ADR-005 (Protocol DI pattern)
