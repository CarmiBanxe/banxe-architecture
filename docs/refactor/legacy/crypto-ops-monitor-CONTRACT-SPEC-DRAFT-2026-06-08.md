# crypto-ops-monitor CONTRACT SPEC — DRAFT

- Family: crypto-ops-monitor-contract
- Target: CarmiBanxe/crypto-ops-monitor
- Scope: src/**
- Status: DRAFT (not buildable; requires Arch WG review before promotion to PROPOSED)

Date: 2026-06-08
Source: crypto-ops-subgroup-SPEC-2026-05-25.md (parent SPEC #7); ADR-050 Option B (per-capability split)
NEW capability: C6 trading (rate provider), C18 crypto ops monitoring
Related: ADR-021 (WalletPort); ADR-050 (delivery model); ADR-051/052
Verified repo: CarmiBanxe/crypto-ops-monitor EXISTS, main HEAD = 725dd0a (PR #9, Sprint 34/B4)

## Purpose

Define the contract for crypto-ops-monitor as a standalone multi-chain RPC ops gateway. This service provides blockchain RPC abstraction (multi-chain pool, error handling, health monitoring) and is the rate source for ExchangePort.getRate(). Split from crypto-ops-subgroup per ADR-050 Option B to enable independent factory build.

## Domain boundary

- IN scope: multi-chain RPC pool management, blockchain node health monitoring, rate quote aggregation, Prometheus metrics exposure, chain-specific error handling.
- OUT of scope: portfolio analytics (banxe-portfolio), news aggregation (banxe-news), order execution (ExchangePort adapters), wallet key management (WalletPort).

## Contract ports

### Provided (this service exposes)

- **RpcGateway** (internal, not a public Hexagonal port per ADR-050 Q2 resolution): multi-chain RPC abstraction for BTC, LTC, ETH, BSC, TRX, XRP.
  - `getRate(base, quote)` → RateQuote (consumed by ExchangePort adapters)
  - `getBlockHeight(chain)` → number
  - `getTransactionStatus(chain, txHash)` → TxStatus
  - `healthCheck()` → per-chain status map

### Consumed (this service depends on)

- Blockchain RPC endpoints (external; per-chain node URLs via config).
- WalletPort chain registry (SPEC #1) — RPC pool only serves chains WalletPort supports.

## Key constraints

- Replace ethers v5 with viem 2.x (ADR-017 vendor-to-OSS).
- Drop PM2 (ecosystem.config.js) for systemd unit.
- Expose Prometheus metrics from day 1 (R3 observability, R-OPS-02).
- Rate TTL enforcement: stale rates MUST NOT propagate (ExchangePort StaleRate contract).
- NestJS 10+ / Node 18+.

## Conformance requirements

1. getRate returns bid/ask with ttlSeconds > 0 for all supported pairs.
2. Stale rate (past TTL) is refused, not served.
3. healthCheck reports per-chain status; unhealthy chain excluded from rate aggregation.
4. Prometheus /metrics endpoint exposes rpc_request_duration_seconds, rpc_error_total, chain_health_status.
5. Chain coverage matches WalletPort supported chains (5-6).

## Open questions (carried from parent SPEC)

- RpcGateway as public Hexagonal port vs internal: PROPOSED internal (ADR-050 Q2). Promote to port only if second consumer emerges.

## References

- crypto-ops-subgroup-SPEC-2026-05-25.md (parent SPEC #7)
- ADR-050 (delivery model Option B)
- ADR-021 (WalletPort chain coverage)
- exchangeport-CONTRACT-SPEC-2026-06-06.md (rate consumer)
- RISK_REGISTER R-OPS-02 (Prometheus), R-MIG-02 (legacy on evo1)
