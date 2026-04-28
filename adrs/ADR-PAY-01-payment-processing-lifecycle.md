# ADR-PAY-01: Payment Processing Service — Full Lifecycle State Machine

## Status
Accepted

## Context
FCA PSR 2017 and PSD2 require EMI firms to maintain complete, auditable payment
processing with clear state transitions. The existing payment infrastructure
(IL-PAY-01, Sprint 43) provides authorization guards and Modulr/Mock adapters,
but lacks a unified lifecycle state machine covering the full flow:
authorize → capture → settle → refund/chargeback.

S4 (Payment Rails) was at 0% coverage — the most critical compliance gap.
Without a structured lifecycle, payment state transitions are ad-hoc, making
it impossible to provide FCA-auditable evidence of payment processing controls.

## Decision
A dedicated `PaymentProcessingService` in `services/payment/` manages the full
payment lifecycle via an explicit state machine (`VALID_TRANSITIONS`). States:
`PENDING → AUTHORIZED → CAPTURED → SETTLED → REFUNDED/PARTIALLY_REFUNDED/CHARGEBACK/FAILED`.

Key design choices:
1. **Protocol DI**: `PaymentGatewayPort` Protocol decouples business logic from
   gateway adapters (Hyperswitch, Modulr, InMemory). No concrete SDK dependency
   in the service layer.
2. **State machine enforcement**: `VALID_TRANSITIONS` dict defines all legal
   transitions. Invalid transitions raise `InvalidTransitionError`.
3. **Idempotency**: `DuplicateIdempotencyKeyError` prevents double-charging.
4. **EDD threshold gate**: Amounts ≥ £10k return `EDDHITLProposal` requiring
   MLRO approval (I-04, I-27). Never auto-submitted.
5. **Multi-currency**: GBP, EUR, USD with per-currency scheme limits.
6. **Audit trail**: Every state transition records an immutable `AuditEntry`
   via `AuditPort` Protocol (I-24).

## Consequences
Positive:
- S4 coverage moves from 0% to ~15% (initiation, auth, settlement, refund).
- FCA-auditable lifecycle with immutable state transition log.
- Protocol DI enables testing without external gateway dependencies.
- EDD/HITL gates enforce I-04 and I-27 at the payment level.

Negative:
- Real gateway adapters (Hyperswitch, ClearBank) not yet wired — InMemory only.
- Settlement is in-process (not bank-confirmed); real settlement requires webhook
  integration from payment provider.
- Chargeback handling is modeled but not yet connected to dispute resolution service.

## References
- IL-PAY-02 (Sprint 44)
- PR: CarmiBanxe/banxe-emi-stack#22
- I-01 (Decimal), I-02 (jurisdictions), I-04 (EDD), I-24 (audit), I-27 (HITL)
- FCA PSR 2017, PSD2 Strong Customer Authentication
