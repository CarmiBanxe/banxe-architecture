# PartnerPort CONTRACT SPEC — executable migration contract for EMI banking layer

Date: 2026-06-06
Status: CONTRACT SPEC (executable; deepens SPEC #5 PartnerPort into an unambiguous adapter contract for Terminal B)
Scope: canonical PartnerPort contract — types, operations, error model, idempotency, audit, conformance tests
Source SPECs: emi-banking-services-SPEC-2026-05-23.md; emi-banking-repos-SCAFFOLD-SPEC-2026-05-23.md
Related: ADR-021 five-new-ports (PartnerPort); ADR-027 audit trail; ADR-020 VABS-to-open-banking; RISK_REGISTER R-REG-01/04 + R-COMP-FCA-02
Owner: Terminal B (smart refactor) authors contract + owns Phase B/C adapter impl

## Purpose

SPEC #5 defined PartnerPort at a high level. This CONTRACT SPEC turns it into an executable migration contract: exact types, operation semantics, error taxonomy, idempotency rules, audit obligations, and conformance tests. Terminal B implements OpenBankingAdapter, SepaAdapter, BaasAdapter against this contract without further design decisions.

## Contract types

```python
from __future__ import annotations

import abc
from dataclasses import dataclass
from enum import Enum
from typing import Any, Mapping


class PartnerType(str, Enum):
    OPEN_BANKING = "open_banking"
    SEPA = "sepa"
    BAAS = "baas"
    CARD_ACQUIRING = "card_acquiring"


Currency = str  # ISO 4217
Iban = str
Amount = str  # decimal string, never float


@dataclass
class PartnerAccountId:
    partner: PartnerType
    external_account_id: str


@dataclass
class PaymentInstruction:
    from_account: PartnerAccountId
    to_iban: Iban
    amount: Amount
    currency: Currency
    reference: str
    idempotency_key: str  # caller-generated UUID v4
    correlation_id: str  # trace id for audit


class PaymentStatus(str, Enum):
    ACCEPTED = "accepted"
    SETTLED = "settled"
    REJECTED = "rejected"
    PENDING = "pending"
    UNKNOWN = "unknown"


@dataclass
class PaymentResult:
    status: PaymentStatus
    partner_tx_id: str | None = None
    settled_at: str | None = None
    reason: str | None = None
    raw: Mapping[str, Any] | None = None  # provider response for audit


@dataclass
class MismatchDetail:
    partner_tx_id: str
    expected: Amount
    actual: Amount


@dataclass
class ReconcileResult:
    date: str
    count: int
    mismatches: int
    mismatch_details: list[MismatchDetail]
```

## Operations

```python
class PartnerPort(abc.ABC):
    @abc.abstractmethod
    async def initiate_payment(self, instruction: PaymentInstruction) -> PaymentResult: ...

    @abc.abstractmethod
    async def get_payment_status(self, partner_tx_id: str) -> PaymentResult: ...

    @abc.abstractmethod
    async def reconcile(self, date: str) -> ReconcileResult: ...
```

Operation semantics:
- initiate_payment: MUST be idempotent on idempotency_key. Re-submitting the same key returns the original PaymentResult, never a duplicate payment.
- get_payment_status: read-only; safe to poll; no side effects.
- reconcile: compares partner-side ledger vs midaz-ledger for the given date; feeds banxe-recon (R-REG-01 CASS 15).

## Error model

| Error class | Meaning | Caller action |
|---|---|---|
| ValidationError | malformed instruction (bad IBAN, negative amount) | fix and resubmit; do NOT retry blindly |
| IdempotencyConflict | same key, different payload | reject; caller bug |
| PartnerUnavailable | partner API down/timeout | retry with backoff; circuit-breaker (SPEC #6) |
| InsufficientFunds | source account underfunded | surface to user; do not retry |
| ComplianceBlock | Travel Rule / sanctions / KYC tier gate | escalate to MLRO; never auto-retry |
| UnknownPartnerState | partner returned ambiguous status | reconcile() resolves; mark pending |

All errors carry correlation_id and persist to guardian_audit_events.

## Adapter mapping (3 adapters from SPEC #5)

| Adapter | Legacy source | Partner | Notes |
|---|---|---|---|
| OpenBankingAdapter | banxe-fiat-backend/banxe-open-banking | open_banking | Plaid/TrueLayer per ADR-020; AIS + PIS flows |
| SepaAdapter | banxe/sepa-service | sepa | SCT + SCT Inst; partner Modulr/ClearBank per S20 |
| BaasAdapter | banxe-fiat-backend/banxe-baas | baas | partner-bank rails; account issuance |

All three implement the identical PartnerPort interface; routing by PaymentInstruction.from_account.partner.

## Idempotency rules

- idempotency_key is caller-generated UUID v4, unique per logical payment intent.
- Adapter stores (idempotency_key -> partner_tx_id) mapping in its own table BEFORE calling the partner API.
- On retry with same key: return stored PaymentResult; do NOT re-call partner.
- On same key + different payload: raise IdempotencyConflict.
- Key retention: minimum 90 days (covers partner dispute windows); aligned with CASS 15 evidence retention where the payment is client-money.

## Audit obligations (ADR-027 + R-COMP-FCA-02)

- Every initiate_payment, get_payment_status, reconcile call emits one guardian_audit_events row.
- Required fields: correlation_id, idempotency_key, partner, operation, status, http_status, latency_ms, timestamp_utc.
- PaymentResult.raw (provider response) stored for MLRO + FCA Section 4 evidence; PII redacted per ADR-021 PII routing.
- Retention 5 years (CASS 15) for any client-money payment.

## Conformance test suite (one suite, all adapters)

Every adapter MUST pass this shared suite before Phase E cut-over:

1. initiate_payment with valid instruction -> status accepted|pending; partner_tx_id present.
2. initiate_payment with same idempotency_key twice -> identical PaymentResult; partner called once (assert via mock).
3. initiate_payment with same key + different payload -> IdempotencyConflict.
4. initiate_payment with bad IBAN -> ValidationError; partner NOT called.
5. get_payment_status on known partner_tx_id -> consistent status; no side effects.
6. get_payment_status on unknown id -> UnknownPartnerState, not exception.
7. reconcile on a date with 0 mismatches -> mismatches=0.
8. reconcile on a seeded mismatch -> mismatches>=1 with details.
9. partner timeout -> PartnerUnavailable; circuit-breaker opens after threshold.
10. compliance gate (KYC tier / sanctions) -> ComplianceBlock; escalation logged; never retried.
11. every operation emits exactly one guardian_audit_events row with correlation_id.

## Acceptance criteria

- PartnerPort interface frozen as defined here; any change requires a CONTRACT SPEC revision.
- 3 adapters (OpenBankingAdapter, SepaAdapter, BaasAdapter) each pass the 11-test conformance suite.
- Idempotency table + retention implemented per Idempotency rules section.
- Audit obligations met: 1 row per operation; raw response stored with PII redaction.
- reconcile() output wired into banxe-recon (closes R-REG-01 dependency).
- Contract is the single source of truth for Phase C adapter implementation; SPEC #5 references this CONTRACT.

## References

- emi-banking-services-SPEC-2026-05-23.md (parent SPEC #5; high-level PartnerPort)
- emi-banking-repos-SCAFFOLD-SPEC-2026-05-23.md (repo boundaries)
- ADR-021 five-new-ports (PartnerPort)
- ADR-020 VABS-to-open-banking
- ADR-027 audit-trail durability (CASS 15 5y)
- RISK_REGISTER-2026-05-22.md (R-REG-01, R-REG-04, R-COMP-FCA-02)
- SPEC #6 fiat-backend-utils (@banxe/circuit-breaker for PartnerUnavailable retry)
- SPEC #8 kyc-provider-port (ComplianceBlock gate via KYCProviderPort)
- BANXE-LEGACY-REFACTOR-INDEX-2026-05-25.md
- UNIVERSAL-CANON 2026-05-22 + TOPOLOGY + BEST-SOLUTION-AND-SEQUENTIAL (House rules 1-12)

=== END OF PartnerPort CONTRACT SPEC (executable; deepens SPEC #5) ===
