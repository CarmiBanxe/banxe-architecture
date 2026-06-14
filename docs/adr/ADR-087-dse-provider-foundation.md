---
id: ADR-087
title: DSE provider foundation — market, sentiment and stress abstractions, tier matrix, mock-default
status: ACCEPTED
date: 2026-06-14
accepted: 2026-06-14
supersedes: []
related:
  - "ADR-084-dse-baas-foundation.md (DSE advisory foundation)"
  - "ADR-085-dse-risk-earn-scope.md (Risk & Earn advisory content)"
  - "ADR-086-risk-earn-baas-readonly-sandbox.md (read-only sandbox + provider-layer follow-up)"
il_anchor: IL-221
scope: BANXE-only
concept_only: false
---

# ADR-087: DSE provider foundation

**Status:** ACCEPTED — 2026-06-14
**IL:** IL-221 (Sprint S10 — DSE live-provider foundation, mock-default preserved)
**Extends:** ADR-084 (DSE advisory foundation), ADR-085 (Risk & Earn scope),
ADR-086 (read-only sandbox; T8.3 provider-layer follow-up + T8.4 live-providers
options). Advisory-only, self-custodial boundaries are **unchanged**.

## Context

T8.3 (IL-217) wired a provider-layer with an overall `ProviderMode`
(mock | sandbox-live | prod-live) + env seams, mock-enforced. T8.4 (IL-218) wrote
the ODR options package for the first live providers (DECISION PENDING). Sprint
S10 formalizes the **per-domain provider abstractions** the DSE reads from —
market/risk, sentiment, stress — behind explicit interfaces with a reversible
tier matrix, so a future live implementation can plug in **without** changing the
public contract and **without** any live activation now.

## Decision

### D1 — Explicit per-domain provider abstractions

The DSE resolves three data-source domains through Protocol abstractions:
`MarketDataProvider` (new), `SentimentProvider`, `StressProvider` (existing). The
engine consumes sentiment + stress through the resolved foundation; market data is
resolved + validated + provenance-exposed and **staged** for future scoring (wiring
market inputs into the utility is a separate operator-gated step — utility/ranking
are unchanged here).

### D2 — Tier matrix: MOCK / STUB / LIVE_READY, default mock

Each domain has a tier `BANXE_DSE_<DOMAIN>_TIER`:
- **mock** (default) — deterministic fixtures, no network/keys.
- **stub** — minimal neutral fixtures (contract/fallback testing).
- **live-ready** — a **CI-safe INERT scaffold**: selectable and constructible but
  performs **no network** and needs **no credentials**; returns mock-equivalent
  deterministic data, so behaviour is unchanged. It marks the seam where a real
  adapter will plug in.

The runtime default everywhere is **mock**. `live-ready` never reaches a network
this sprint.

### D3 — Fail-closed resolution; live activation is operator-gated (ODR)

`resolve_foundation(settings)` validates at startup (`create_app`) **and** in
`MockDseEngine.from_settings`:
- unknown tier → fail closed;
- `live-ready` with the master switch `BANXE_DSE_LIVE_ALLOWED` off → **inert**
  (system remains fully functional in mock mode);
- `live-ready` with the switch **on** but credentials missing → **fail closed**;
- `live-ready` with the switch on and credentials present → **fail closed**,
  because no live network adapter is wired (OPERATOR DECISION REQUIRED).

No real network adapter, no real credentials, and no live activation exist in this
sprint. Live activation requires a future ADR/ODR + compliance sign-off (MiCA /
BaaS).

### D4 — Contract stability + safe provenance

`POST /v1/dss/recommend` is **unchanged** — no request/response field is added, and
utility/ranking are identical across tiers (mock and inert live-ready produce the
same output). Per-domain provenance (tier + source class name, **no secrets**) is
exposed **internally only**: the BaaS structured log (`foundationTiers`) and the
internal `/internal/health/dse-baas` `foundation` check.

### D5 — Advisory-only / self-custodial unchanged

No auto-execution, no wallet signing, no partner production activation, no billing
or tiering. Absent live env vars, the system is fully functional in mock mode.

## Consequences

- **Positive:** a reversible, testable seam for future live data per domain;
  fail-closed safety; provenance for proofs without secrets; zero contract churn.
- **Negative / cost:** market data is resolved but not yet fed into scoring (staged);
  live adapters + secrets management remain future operator-gated work.
- **Risk:** accidental live activation — fenced by D3 (fail-closed) and the
  default-off master switch.

## OPERATOR DECISION REQUIRED (gated — NOT in S10)

- Selecting a live provider per domain (see IL-218 options package) and its contract.
- Setting `BANXE_DSE_LIVE_ALLOWED=true`, any tier to `live-ready` for real
  activation, or any `BANXE_DSE_<DOMAIN>_API_KEY` / `_BASE_URL` (via secret store).
- Wiring the live network adapters; production scoring; billing / partner-tiering.
- MiCA / CASP review confirming each source is an advisory data vendor (not
  execution/custody); sentiment PII handling.

## References

- `banxe-trading-backend/src/banxe_trading_backend/dse/provider_foundation.py`,
  `provider_layer.py`, `dse/engine.py`, `config.py`
- `banxe-trading-backend/docs/specs/dse-baas-api.yaml` (Data providers & modes)
- `banxe-architecture/docs/specs/dse-live-providers-options.md` (IL-218, PENDING/ODR)
- ADR-084/085/086; IL-217 (T8.3), IL-218 (T8.4)
