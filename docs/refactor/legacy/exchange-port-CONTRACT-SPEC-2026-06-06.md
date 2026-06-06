# ExchangePort CONTRACT SPEC — executable contract (C6 trading)

Date: 2026-06-06
Status: CONTRACT SPEC (executable; deepens SPEC #4 ExchangePort; serves NEW capability C6 trading)
Scope: canonical ExchangePort contract — types, operations, idempotency, error model, audit, conformance tests
Source SPECs: trading-ui-group-SPEC-2026-05-23.md; crypto-ops-subgroup-SPEC-2026-05-25.md (rate via RPC)
NEW capability: C6 (crypto exchange / trading) per ADR-016 + NEW-PROJECT-PRIORITY-MAP
Related: ADR-016; ADR-021 ExchangePort; RISK_REGISTER R-SEC-NEW-03 (order regression) + R-COMP-FCA-02 (order audit)
Owner: Terminal B (smart refactor)

## Purpose

Deepen SPEC #4 ExchangePort into an executable contract. Order placement governs financial transactions, so initiate_payment-equivalents (place_order) MUST be idempotent and fully audited. Terminal B implements PrimaryExchangeAdapter (from fast-exchange), CCXT fallback, and a Hyperswitch-compatible adapter against this contract. NEW-driven: C6 trading capability is authoritative; legacy fast-exchange is reused only because it serves C6.

## Contract types

```python
from __future__ import annotations

import abc
from dataclasses import dataclass
from enum import StrEnum
from typing import Any, Mapping


AssetSymbol = str
Amount = str  # decimal string, never float


class OrderSide(StrEnum):
    BUY = "buy"
    SELL = "sell"


class OrderType(StrEnum):
    MARKET = "market"
    LIMIT = "limit"


class OrderState(StrEnum):
    ACCEPTED = "accepted"
    FILLED = "filled"
    PARTIAL = "partial"
    REJECTED = "rejected"
    EXPIRED = "expired"
    CANCELLED = "cancelled"


@dataclass
class RateQuote:
    base_asset: AssetSymbol
    quote_asset: AssetSymbol
    bid: Amount
    ask: Amount
    ttl_seconds: int
    quoted_at: str


@dataclass
class OrderRequest:
    base_asset: AssetSymbol
    quote_asset: AssetSymbol
    side: OrderSide
    type: OrderType
    amount: Amount
    client_order_id: str  # idempotency key, caller-generated UUID v4
    correlation_id: str
    limit_price: Amount | None = None


@dataclass
class OrderResult:
    order_id: str
    state: OrderState
    filled_amount: Amount
    average_price: Amount | None = None
    fee: Amount | None = None
    raw: Mapping[str, Any] | None = None
```

## Operations

```python
class ExchangePort(abc.ABC):
    @abc.abstractmethod
    async def get_rate(self, base: AssetSymbol, quote: AssetSymbol) -> RateQuote: ...

    @abc.abstractmethod
    async def place_order(self, order: OrderRequest) -> OrderResult: ...

    @abc.abstractmethod
    async def cancel_order(self, order_id: str) -> bool: ...

    @abc.abstractmethod
    async def get_order_status(self, order_id: str) -> OrderResult: ...
```

## Operation semantics

- get_rate: read-only; honour ttl_seconds; rate sourced via crypto-ops-monitor RPC (SPEC #7). Stale rate (past ttl) MUST be refused, not used.
- place_order: MUST be idempotent on client_order_id. Re-submission returns original OrderResult; never double-executes.
- cancel_order: idempotent; cancelling an already-final order returns False without error.
- get_order_status: read-only; safe to poll.

## Idempotency rules

- client_order_id is caller-generated UUID v4, unique per order intent.
- Adapter stores (client_order_id -> order_id) BEFORE calling the exchange.
- Retry same client_order_id -> return stored OrderResult; do NOT re-place.
- Same client_order_id + different OrderRequest payload -> IdempotencyConflict.
- Retention >= 90 days (dispute window); 5y if order moves client money (CASS 15).

## Error model

| Error class | Meaning | Caller action |
|---|---|---|
| ValidationError | bad symbol/amount/price | fix, resubmit; do not retry blindly |
| IdempotencyConflict | same client_order_id, different payload | reject; caller bug |
| StaleRate | rate past ttl | re-fetch get_rate, then retry |
| ExchangeUnavailable | exchange API down/timeout | retry with backoff via @banxe/circuit-breaker (SPEC #6) |
| InsufficientBalance | account underfunded | surface to user; no retry |
| ComplianceBlock | KYC tier / sanctions / Travel Rule gate | escalate to MLRO; never auto-retry |
| PartialFillTimeout | order partially filled then expired | reconcile; settle partial |

All errors carry correlation_id + client_order_id and persist to guardian_audit_events.

## Audit obligations (ADR-027 + R-COMP-FCA-02)

- Every get_rate, place_order, cancel_order, get_order_status emits one guardian_audit_events row.
- Required fields: correlation_id, client_order_id, order_id, operation, state, http_status, latency_ms, timestamp_utc.
- OrderResult.raw stored for MLRO + FCA Section 4; PII redacted per ADR-021 PII routing.
- Retention 5 years for any order that moves client money (CASS 15).

## Adapter mapping

| Adapter | Source | Role |
|---|---|---|
| PrimaryExchangeAdapter | legacy fast-exchange (SPEC #4) | primary venue |
| CCXTFallbackAdapter | build-fresh (CCXT Pro) | fallback venue on PrimaryExchange outage |
| HyperswitchAdapter | build-fresh | routing-layer integration per vendor-to-OSS |

All three implement identical ExchangePort; selection via config flag EXCHANGE_PROVIDER + circuit-breaker failover.

## Conformance test suite (one suite, all adapters)

1. get_rate(valid pair) -> bid/ask present; ttl_seconds > 0.
2. get_rate then wait past ttl -> StaleRate on reuse (no stale trade).
3. place_order(valid) -> state accepted|filled|partial; order_id present.
4. place_order same client_order_id twice -> identical OrderResult; exchange called once (mock assert).
5. place_order same client_order_id + different payload -> IdempotencyConflict.
6. place_order bad symbol -> ValidationError; exchange NOT called.
7. cancel_order on open order -> True; on final order -> False (no error).
8. get_order_status -> consistent state; no side effects.
9. exchange timeout -> ExchangeUnavailable; circuit-breaker opens after threshold; failover to CCXTFallbackAdapter.
10. compliance gate -> ComplianceBlock; escalation logged; never retried.
11. every operation emits exactly one guardian_audit_events row with correlation_id + client_order_id.

## Acceptance criteria

- ExchangePort interface frozen as defined; changes require CONTRACT revision.
- 3 adapters each pass the 11-test conformance suite.
- Idempotency table + retention implemented.
- Shadow-mode (Phase D) vs legacy fast-exchange: 0 mismatch on get_rate; place_order verified equivalent settlement.
- Audit: 1 row per operation; raw stored with PII redaction.
- Failover (Primary -> CCXT) verified under induced outage.

## References

- trading-ui-group-SPEC-2026-05-23.md (parent SPEC #4; ExchangePort high-level)
- crypto-ops-subgroup-SPEC-2026-05-25.md (rate via crypto-ops-monitor RPC)
- ADR-016 trading-ui; ADR-021 ExchangePort; ADR-027 audit trail
- NEW-PROJECT-PRIORITY-MAP-2026-06-06.md (C6 trading capability)
- emi-banking-partnerport-CONTRACT-SPEC-2026-06-06.md + wallet-port-CONTRACT-SPEC-2026-06-06.md (sibling CONTRACT pattern)
- SPEC #6 fiat-backend-utils (@banxe/circuit-breaker for failover)
- SPEC #8 kyc-provider-port (ComplianceBlock via KYCProviderPort)
- RISK_REGISTER-2026-05-22.md (R-SEC-NEW-03, R-COMP-FCA-02)
- UNIVERSAL-CANON 1-12 + worktree-isolation

=== END OF ExchangePort CONTRACT SPEC (executable; C6 trading) ===

## Naming-collision note (parallel Central coordination)

A parallel Central process committed an 8-line stub at docs/refactor/legacy/exchangeport-CONTRACT-SPEC-2026-06-06.md (no dash, commit 63c8312). This file (exchange-port-CONTRACT, with dash, 147 lines) is the DEFINITIVE ExchangePort contract. Resolution per House rule 10 (coordination via main merge): the stub should be superseded by / merged into this file at push time. Terminal B implementers MUST use this dashed file as the authoritative ExchangePort contract; the stub is a placeholder only.
