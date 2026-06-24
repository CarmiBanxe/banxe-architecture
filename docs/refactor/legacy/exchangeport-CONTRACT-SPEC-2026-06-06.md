# ExchangePort CONTRACT SPEC — contract definition (C6 trading)

- Family: exchangeport-contract
- Target: banxe-payment-core / exchange contract
- Scope: src/exchangeport/**

Date: 2026-06-06
Status: CONTRACT SPEC (contract-only; defines ExchangePort interface, types, semantics, and conformance requirements for NEW capability C6 trading)
Source SPECs: trading-ui-group-SPEC-2026-05-23.md; crypto-ops-subgroup-SPEC-2026-05-25.md
NEW capability: C6 (crypto exchange / trading) per ADR-016 + NEW-PROJECT-PRIORITY-MAP
Related: ADR-016; ADR-021 ExchangePort; RISK_REGISTER R-SEC-NEW-03 (order regression) + R-COMP-FCA-02 (order audit)
Owner: Terminal B (smart refactor) authors contract + owns Phase C adapter impl

## Purpose

Define the canonical ExchangePort contract: types, interface, operation semantics, idempotency rules, error model, and conformance test requirements. This SPEC is the single source of truth for what any ExchangePort adapter MUST satisfy. It does not prescribe specific adapter implementations, infrastructure schemas, or shadow-comparison harnesses — those belong to follow-up impl-phase SPECs.

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

- getRate: read-only; honour ttlSeconds. Stale rate (past ttl) MUST be refused, not used. Rate source is an external dependency (see Out of scope).
- placeOrder: MUST be idempotent on clientOrderId. Re-submission returns original OrderResult; never double-executes.
- cancelOrder: idempotent; cancelling an already-final order returns false without error.
- getOrderStatus: read-only; safe to poll.

## Idempotency rules

- clientOrderId is caller-generated UUID v4, unique per order intent.
- Adapter stores (clientOrderId -> orderId) BEFORE calling the exchange.
- Retry same clientOrderId -> return stored OrderResult; do NOT re-place.
- Same clientOrderId + different OrderRequest payload -> IdempotencyConflict.
- Retention of the idempotency mapping >= 90 days (dispute window).

## Error model

| Error class | Meaning | Caller action |
|---|---|---|
| ValidationError | bad symbol/amount/price | fix, resubmit; do not retry blindly |
| IdempotencyConflict | same clientOrderId, different payload | reject; caller bug |
| StaleRate | rate past ttl | re-fetch getRate, then retry |
| ExchangeUnavailable | exchange API down/timeout | retry with backoff; circuit-breaker recommended |
| InsufficientBalance | account underfunded | surface to user; no retry |
| ComplianceBlock | KYC tier / sanctions / Travel Rule gate | escalate to MLRO; never auto-retry |
| PartialFillTimeout | order partially filled then expired | reconcile; settle partial |

All errors MUST carry correlationId + clientOrderId. All errors MUST be persisted to an audit log (schema defined by impl phase).

## Conformance test suite (one suite, all adapters)

Any adapter claiming ExchangePort conformance MUST pass all 11 tests:

1. getRate(valid pair) -> bid/ask present; ttlSeconds > 0.
2. getRate then wait past ttl -> StaleRate on reuse (no stale trade).
3. placeOrder(valid) -> state accepted|filled|partial; orderId present.
4. placeOrder same clientOrderId twice -> identical OrderResult; exchange called once (mock assert).
5. placeOrder same clientOrderId + different payload -> IdempotencyConflict.
6. placeOrder bad symbol -> ValidationError; exchange NOT called.
7. cancelOrder on open order -> true; on final order -> false (no error).
8. getOrderStatus -> consistent state; no side effects.
9. exchange timeout -> ExchangeUnavailable; circuit-breaker opens after threshold.
10. compliance gate -> ComplianceBlock; escalation logged; never retried.
11. every operation emits exactly one audit event with correlationId + clientOrderId.

## Out of scope (follow-up impl phase)

The following items are referenced by this contract but belong to separate impl-phase SPECs:

- **Adapter implementations:** PrimaryExchangeAdapter (from legacy fast-exchange), CCXTFallbackAdapter (build-fresh CCXT Pro), HyperswitchAdapter (build-fresh routing-layer). Each is a distinct impl deliverable against this contract.
- **Shadow-mode Phase D harness:** comparison of NEW adapters vs legacy fast-exchange (0 mismatch on getRate; equivalent settlement on placeOrder). Requires its own test-harness SPEC.
- **CASS 15 retention table + guardian_audit_events schema:** 5-year retention for orders moving client money is a shared infrastructure concern (ADR-027). The audit event schema and storage belong to a cross-cutting infra SPEC, not this contract.
- **Rate source (crypto-ops-monitor RPC):** getRate semantics require a rate provider. The RPC interface to crypto-ops-monitor (SPEC #7) is an external dependency that requires its own interface SPEC before adapter impl can proceed.
- **Failover topology:** Primary -> CCXT failover via EXCHANGE_PROVIDER config flag + circuit-breaker is an operational concern for the adapter-selection layer.

## Acceptance criteria

- ExchangePort interface frozen as defined above; changes require a CONTRACT revision.
- Any adapter passes all 11 conformance tests against this contract.
- Idempotency semantics (clientOrderId dedup, conflict detection) verified by tests 3-5.
- Error model completeness: all 7 error classes exercised by tests 6-10.
- Audit: every operation emits exactly one audit event (test 11).

## References

- trading-ui-group-SPEC-2026-05-23.md (parent SPEC #4; ExchangePort high-level)
- crypto-ops-subgroup-SPEC-2026-05-25.md (rate via crypto-ops-monitor RPC)
- ADR-016 trading-ui; ADR-021 ExchangePort; ADR-027 audit trail
- NEW-PROJECT-PRIORITY-MAP-2026-06-06.md (C6 trading capability)
- wallet-port-CONTRACT-SPEC-2026-06-06.md (sibling CONTRACT pattern)
- SPEC #6 fiat-backend-utils (@banxe/circuit-breaker)
- SPEC #8 kyc-provider-port (ComplianceBlock via KYCProviderPort)
- RISK_REGISTER-2026-05-22.md (R-SEC-NEW-03, R-COMP-FCA-02)
- UNIVERSAL-CANON 1-12 + worktree-isolation

=== END OF ExchangePort CONTRACT SPEC (contract-only; C6 trading) ===
