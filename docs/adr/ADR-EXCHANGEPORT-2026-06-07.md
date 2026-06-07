# ADR-ExchangePort — Trade/Quote/Settlement boundary (claim 5)
Status: Proposed
Date: 2026-06-07
IL-anchor: IL-111-R0-ADR-EXCHANGEPORT-2026-06-07
Source-spec: docs/refactor/legacy/exchange-port-CONTRACT-SPEC-2026-06-06.md
Scope: BANXE-only

## Context
Claim 5 (IL-110) verified as UNBLOCKED, ADR-pending. ExchangePort isolates
crypto/fiat exchange interactions behind a stable contract port, consistent
with the other CONTRACT-SPEC ports (wallet, kyc, notification, partner, crm).

## Decision
Define ExchangePort as a hexagonal outbound port: quote(), executeTrade(),
getSettlementStatus(); adapters live outside the domain; no vendor types leak
across the boundary.

## Consequences
+ Domain decoupled from exchange vendors; testable via fakes.
- Requires adapter conformance tests; settlement reconciliation out of scope here.

## Alternatives considered
- Inline vendor SDK in domain (rejected: coupling).
- Merge with WalletPort (rejected: distinct lifecycle/SLA).
