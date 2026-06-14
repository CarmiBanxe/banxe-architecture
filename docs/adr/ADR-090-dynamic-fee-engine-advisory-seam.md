---
id: ADR-090
title: Dynamic fee engine advisory seam — fee attribution analytics, mock-only, no billing
status: ACCEPTED
date: 2026-06-14
accepted: 2026-06-14
supersedes: []
related:
  - "ADR-083-composable-defi-stack.md (venues/routes the fees attribute to)"
  - "ADR-089-market-making-advisory-seam.md (sibling moat seam; same mock-safe pattern)"
il_anchor: IL-225
scope: BANXE-only
concept_only: false
---

# ADR-090: Dynamic fee engine advisory seam

**Status:** ACCEPTED — 2026-06-14
**IL:** IL-225 (Sprint S13 / X9.2 — dynamic fee engine advisory seam, mock-safe)
**Extends:** ADR-083 (Composable DeFi Stack). Advisory-only, mock-first, no-billing
boundaries are **unchanged**.

## Context

Trades route across venues (LI.FI, dYdX, GMX, StakeKit) that each carry distinct
fee/attribution streams (integrator, builder-code, referral, performance,
maker-rebate, spread). A transparent fee profile is valuable for analytics and
partner reporting, but it must be cleanly separated from **billing** (charges,
invoices, settlement), which is a regulated, operator-gated concern. Sprint S13
opens a fee-attribution **analytics** seam — advisory and mock-safe, with no real
charges and no billing integration.

## Decision

### D1 — A fee-engine port returning an attribution decomposition

Introduce `FeeEnginePort` — it decomposes a candidate action into a list of fee
**components** (`integrator_fee`, `builder_code_fee`, `referral_fee`,
`performance_fee`, `maker_rebate`, `bid_ask_spread_capture`), each with `bps`,
`usd`, `source` and an optional `note`, plus totals. Only a deterministic
`MockFeeEngine` ships (fixture rate tables, partner-tier discount on platform-take
fees). A live fee/attribution data source is **operator-gated (ODR)**.

### D2 — Analytics-only, no billing

The response is **metadata, not money**: NO real charges, invoices, payments, or
settlement; NO Lago / Orb / Stripe; NO on-chain fee hooks; NO smart-contract
changes. It is `mode: "sandbox-mock"`, `signed: false`, `submitted: false` (like
the S12 market-making preview).

### D3 — Internal terminal endpoint, not the partner BaaS surface

Exposed only on the **internal** `POST /api/v1/fees/preview`. It is **not** added
to `dse-baas-api.yaml` and **not** served on the external `/v1/...` facade (returns
`404` there). No new public endpoint; no change to `POST /v1/dss/recommend`, the
market-making preview, or the execution-intent preview.

### D4 — Mock-default, fail-closed

`BANXE_FEE_PROVIDER` defaults to `mock`; any other value **fails closed at
startup** (operator-gated). Deterministic, no network, no keys. Invalid inputs
(empty asset, `notionalUsd ≤ 0`, bad `productType`) return `422`.

### D5 — Billing stays out of the factory train

Billing/metering enforcement remains a separate operator-decision (G-sprint),
explicitly **not** included here. This seam only makes the fee map transparent.

## Consequences

- **Positive:** a transparent, testable fee-attribution map per action; clean
  pricing/analytics-vs-billing separation; reversible behind one port.
- **Negative / cost:** real billing, invoicing, settlement, partner-tier
  enforcement, and live fee data remain future operator-gated work.
- **Risk:** scope creep toward billing — fenced by D2/D4/D5 (analytics-only,
  fail-closed, ODR).

## OPERATOR DECISION REQUIRED (gated — NOT in S13)

- Real billing/metering (Lago / Orb / Stripe), invoicing, on-chain fee settlement.
- Partner-tier *enforcement*, live fee/attribution data sources, real keys.
- Any `/v1` partner-contract change for fees.

## References

- `banxe-trading-backend/src/banxe_trading_backend/ports/fee_engine_port.py`,
  `api/fees.py`, `config.py`
- `banxe-trading-backend/docs/specs/fee-engine-sandbox.md`
- ADR-083 (Composable DeFi Stack); ADR-089 (market-making advisory seam)
