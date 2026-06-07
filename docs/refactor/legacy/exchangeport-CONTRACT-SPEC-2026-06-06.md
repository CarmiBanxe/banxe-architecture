# ExchangePort CONTRACT SPEC — executable contract (C6 trading)

Date: 2026-06-06
Status: CONTRACT SPEC (executable; deepens SPEC #4 ExchangePort; serves NEW capability C6 trading)
Scope: canonical ExchangePort contract — types, operations, idempotency, error model, audit, conformance tests
Source SPECs: trading-ui-group-SPEC-2026-05-23.md; crypto-ops-subgroup-SPEC-2026-05-25.md (rate via RPC)
NEW capability: C6 (crypto exchange / trading) per ADR-016 + NEW-PROJECT-PRIORITY-MAP
Related: ADR-016; ADR-021 ExchangePort; RISK_REGISTER R-SEC-NEW-03 (order regression) + R-COMP-FCA-02 (order audit)
Owner: Terminal B (smart refactor)

## Purpose

Deepen SPEC #4 ExchangePort into an executable contract. Order placement governs financial transactions, so initiatePayment-equivalents (placeOrder) MUST be idempotent and fully audited. Terminal B implements PrimaryExchangeAdapter (from fast-exchange), CCXT fallback, and a Hyperswitch-compatible adapter against this contract. NEW-driven: C6 trading capability is authoritative; legacy fast-exchange is reused only because it serves C6.

## Contract types

```typescript
export type AssetSymbol = string;
export type OrderSide = "buy" | "sell";
export type OrderType = "market" | "limit";
export type Amount = string; // decimal string, never float

export interface RateQuote {
  baseAsset: AssetSymbol;
  quoteAsset: AssetSymbol;
  bid: Amount;
  ask: Amount;
  ttlSeconds: number;
  quotedAt: string;
}

export interface OrderRequest {
  baseAsset: AssetSymbol;
  quoteAsset: AssetSymbol;
  side: OrderSide;
  type: OrderType;
  amount: Amount;
  limitPrice?: Amount;
  clientOrderId: string;   // idempotency key, caller-generated UUID v4
  correlationId: string;
}

export type OrderState = "accepted" | "filled" | "partial" | "rejected" | "expired" | "cancelled";

export interface OrderResult {
  orderId: string;
  state: OrderState;
  filledAmount: Amount;
  averagePrice?: Amount;
  fee?: Amount;
  raw?: Record<string, unknown>;
}
```

## Operations

```typescript
export interface ExchangePort {
  getRate(base: AssetSymbol, quote: AssetSymbol): Promise<RateQuote>;
  placeOrder(order: OrderRequest): Promise<OrderResult>;
  cancelOrder(orderId: string): Promise<boolean>;
  getOrderStatus(orderId: string): Promise<OrderResult>;
}
```

## Operation semantics

- getRate: read-only; honour ttlSeconds; rate sourced via crypto-ops-monitor RPC (SPEC #7). Stale rate (past ttl) MUST be refused, not used.
- placeOrder: MUST be idempotent on clientOrderId. Re-submission returns original OrderResult; never double-executes.
- cancelOrder: idempotent; cancelling an already-final order returns false without error.
- getOrderStatus: read-only; safe to poll.

## Idempotency rules

- clientOrderId is caller-generated UUID v4, unique per order intent.
- Adapter stores (clientOrderId -> orderId) BEFORE calling the exchange.
- Retry same clientOrderId -> return stored OrderResult; do NOT re-place.
- Same clientOrderId + different OrderRequest payload -> IdempotencyConflict.
- Retention >= 90 days (dispute window); 5y if order moves client money (CASS 15).

## Error model

| Error class | Meaning | Caller action |
|---|---|---|
| ValidationError | bad symbol/amount/price | fix, resubmit; do not retry blindly |
| IdempotencyConflict | same clientOrderId, different payload | reject; caller bug |
| StaleRate | rate past ttl | re-fetch getRate, then retry |
| ExchangeUnavailable | exchange API down/timeout | retry with backoff via @banxe/circuit-breaker (SPEC #6) |
| InsufficientBalance | account underfunded | surface to user; no retry |
| ComplianceBlock | KYC tier / sanctions / Travel Rule gate | escalate to MLRO; never auto-retry |
| PartialFillTimeout | order partially filled then expired | reconcile; settle partial |

All errors carry correlationId + clientOrderId and persist to guardian_audit_events.

## Audit obligations (ADR-027 + R-COMP-FCA-02)

- Every getRate, placeOrder, cancelOrder, getOrderStatus emits one guardian_audit_events row.
- Required fields: correlationId, clientOrderId, orderId, operation, state, http_status, latency_ms, timestamp_utc.
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

1. getRate(valid pair) -> bid/ask present; ttlSeconds > 0.
2. getRate then wait past ttl -> StaleRate on reuse (no stale trade).
3. placeOrder(valid) -> state accepted|filled|partial; orderId present.
4. placeOrder same clientOrderId twice -> identical OrderResult; exchange called once (mock assert).
5. placeOrder same clientOrderId + different payload -> IdempotencyConflict.
6. placeOrder bad symbol -> ValidationError; exchange NOT called.
7. cancelOrder on open order -> true; on final order -> false (no error).
8. getOrderStatus -> consistent state; no side effects.
9. exchange timeout -> ExchangeUnavailable; circuit-breaker opens after threshold; failover to CCXTFallbackAdapter.
10. compliance gate -> ComplianceBlock; escalation logged; never retried.
11. every operation emits exactly one guardian_audit_events row with correlationId + clientOrderId.

## Acceptance criteria

- ExchangePort interface frozen as defined; changes require CONTRACT revision.
- 3 adapters each pass the 11-test conformance suite.
- Idempotency table + retention implemented.
- Shadow-mode (Phase D) vs legacy fast-exchange: 0 mismatch on getRate; placeOrder verified equivalent settlement.
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
