---
id: ADR-092
title: Ecosystem / marketplace advisory seam — read-only registry, mock-only, no entitlement/billing
status: ACCEPTED
date: 2026-06-14
accepted: 2026-06-14
supersedes: []
related:
  - "ADR-083-composable-defi-stack.md (the providers the registry catalogs)"
  - "ADR-089-market-making-advisory-seam.md (sibling moat seam)"
  - "ADR-090-dynamic-fee-engine-advisory-seam.md (sibling moat seam)"
  - "ADR-091-quant-moat-advisory-seam.md (sibling moat seam)"
il_anchor: IL-227
scope: BANXE-only
concept_only: false
---

# ADR-092: Ecosystem / marketplace advisory seam

**Status:** ACCEPTED — 2026-06-14
**IL:** IL-227 (Sprint S15 / X9.4 — ecosystem/marketplace read-only registry, mock-safe)
**Extends:** ADR-083 (Composable DeFi Stack). Advisory-only, mock-first boundaries
are **unchanged**.

## Context

The master research describes an open ecosystem of providers / agents / strategies
(DeFi, AgentFi, market-making, quant) with BANXE as the orchestrator. A transparent
catalog of these entities is useful for the DSE / UX / ops to surface possible
integrations — but a *live*, paid marketplace (entitlement, subscriptions,
revenue-share, billing) is a regulated, operator-gated concern. Sprint S15 opens
the catalog as a **read-only, mock-safe** registry.

## Decision

### D1 — A read-only registry of providers and strategies

Introduce a static in-repo registry of `MarketplaceProvider` and
`MarketplaceStrategy` cards (descriptive fields only), surfaced through read-only
`GET /api/v1/marketplace/providers` and `/strategies` (+ a `/strategies/{id}`
detail). It is a logical "vitrine" over the already-existing providers (LI.FI,
dYdX, GMX, StakeKit, Hummingbot-based MM, quant).

### D2 — No entitlement, no billing, no activation

The registry carries **no** entitlement, billing, partner-tiers, tokens,
revenue-share, payouts, keys, or limits. There is **no** purchase / subscription /
activation, and **no** "click → trade" — at most a card links to the already-
existing advisory endpoints. Static fixtures only, no network.

### D3 — Internal / partner-safe surface, not the external BaaS facade

The endpoints are **internal** (`/api/v1/marketplace/*`), GET-only, read-only. They
are **not** a new external `/v1` BaaS facade (`404` there) and **not** added to
`dse-baas-api.yaml`. Exposing a public marketplace is a separate ODR decision.

### D4 — CORE untouched

No change to `POST /v1/dss/recommend`, the previews, or any partner contract. The
registry is additive and reversible.

## Consequences

- **Positive:** a centralized ecosystem catalog the DSE / UX / ops can use to
  surface integrations; clean separation of catalog from commerce.
- **Negative / cost:** a live / public marketplace, revenue-share, subscriptions,
  entitlement and billing remain future operator-gated work.
- **Risk:** scope creep toward marketplace economics — fenced by D2/D3 (read-only,
  no entitlement/billing, internal-only, ODR).

## OPERATOR DECISION REQUIRED (gated — NOT in S15)

- A live / public marketplace, revenue-share, subscriptions, pay-per-use.
- Partner entitlement / tiering / billing; any "click → trade" activation.
- Any external `/v1` exposure of the registry or `/v1` partner-contract change.

## References

- `banxe-trading-backend/src/banxe_trading_backend/marketplace/catalog.py`,
  `api/marketplace.py`
- `banxe-trading-backend/docs/specs/marketplace-sandbox.md`
- ADR-083 (Composable DeFi Stack); ADR-089 / ADR-090 / ADR-091 (sibling moat seams)
