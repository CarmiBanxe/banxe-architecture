# IL-PAY-02: Payment Processing Service — Auth, Capture, Settle, Refund Lifecycle

- Sprint: 44
- Status: DONE
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked GitHub issue: CarmiBanxe/banxe-emi-stack#21
- PR: CarmiBanxe/banxe-emi-stack#22
- Merge SHA: 86d0e4f
- Closed: 2026-04-28

## Summary

Full payment lifecycle: PENDING → AUTHORIZED → CAPTURED → SETTLED → REFUNDED.
PaymentProcessingService with Protocol DI (PaymentGatewayPort), state machine
enforcement, idempotency, EDD/HITL gate, multi-currency (GBP/EUR/USD).

## Deliverables

- services/payment/payment_processing_service.py — PaymentProcessingService
- services/payment/payment_models.py — TransactionStatus, PaymentTransaction
- services/payment/payment_gateway_port.py — PaymentGatewayPort Protocol + InMemoryGateway
- services/payment/currency_validator.py — multi-currency validation
- tests/test_payment_processing_service.py — 49 tests

## Acceptance criteria — ALL MET

- test_payment_authorize_success (Decimal, I-01) ✅
- test_payment_authorize_blocked_jurisdiction (I-02) ✅
- test_payment_capture_after_auth ✅
- test_payment_refund_after_capture (partial + full) ✅
- test_payment_duplicate_idempotency_key ✅
- test_payment_amount_exceeds_threshold_requires_edd (I-04) ✅
- test_payment_audit_trail_recorded (I-24) ✅
- Coverage 89-100%, Ruff clean ✅

## Compliance impact

- S4 Payment Rails: 0% → 15%
