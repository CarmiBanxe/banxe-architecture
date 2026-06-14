---
id: ADR-091
title: Quant-moat advisory seam — quant-analytics port, mock-only, no live models
status: ACCEPTED
date: 2026-06-14
accepted: 2026-06-14
supersedes: []
related:
  - "ADR-083-composable-defi-stack.md (venues the quant signals contextualize)"
  - "ADR-089-market-making-advisory-seam.md (sibling moat seam; same mock-safe pattern)"
  - "ADR-090-dynamic-fee-engine-advisory-seam.md (sibling moat seam)"
il_anchor: IL-226
scope: BANXE-only
concept_only: false
---

# ADR-091: Quant-moat advisory seam

**Status:** ACCEPTED — 2026-06-14
**IL:** IL-226 (Sprint S14 / X9.3 — quant-moat advisory seam, mock-safe)
**Extends:** ADR-083 (Composable DeFi Stack). Advisory-only, mock-first boundaries
are **unchanged**.

## Context

The master research describes a heavy quant stack (Remizov Solver, Heston /
rough-Heston vol models, scenario engines, FNO / PINN surrogates, deep hedging, RL
market-making) as a **moat / edge** layer — explicitly **not** a mandatory part of
CORE, and not something production can switch on without a dedicated operator
decision (heavy compute, model-risk, data-licensing). Sprint S14 opens this as an
**optional, advisory, mock-safe** analytics seam.

## Decision

### D1 — A quant-analytics port emitting advisory signals

Introduce `QuantEnginePort` — it emits quant **signals** (fair-value gap, stress
scenario, volatility regime, flash-crash / inventory flags) plus summary fields
(fair value, gap bps, downside stress, regime) as **advisory metadata**. Only a
deterministic `MockQuantEngine` ships (light logic + fixtures — it emulates the
*shape* of signals). A live quant stack is **operator-gated (ODR)**.

### D2 — Mock-safe, no live models

NO live quant engine (no Heston / rough-Heston / Remizov / FNO / PINN / deep
hedging), NO live price/IV feeds, NO keys, NO network, NO trading decisions. The
response is always `mode: "sandbox-mock"`. Deterministic for a given input.

### D3 — Optional / additive, CORE unaffected

The signals are **additive metadata, never a critical input**. Every CORE endpoint
(`/v1/dss/recommend`, `/v1/risk/greeks`, `/v1/earn/rates`,
`/api/v1/execution/intent-preview`, `/api/v1/mm/preview`, `/api/v1/fees/preview`)
works unchanged whether or not a quant provider is present (mock is the default).

### D4 — Internal terminal endpoint, not the partner BaaS surface

Exposed only on the **internal** `POST /api/v1/quant/preview`. It is **not** added
to `dse-baas-api.yaml` and **not** served on the external `/v1/...` facade (returns
`404` there). No new public endpoint; no change to any `/v1` partner contract.

### D5 — Mock-default, fail-closed

`BANXE_QUANT_PROVIDER` defaults to `mock`; any other value **fails closed at
startup** (operator-gated). Invalid inputs (empty asset, `notionalUsd ≤ 0`,
`horizonDays ≤ 0`, bad `productType`) return `422`.

## Consequences

- **Positive:** a reversible quant-signal seam that the DSE / previews can enrich
  with; clear separation of edge-analytics from CORE; ready for a future live quant
  stack behind one port.
- **Negative / cost:** the real quant models, live feeds, model-risk governance and
  heavy compute remain future operator-gated work.
- **Risk:** scope creep toward live models / trading decisions — fenced by
  D2/D3/D5 (advisory, additive, fail-closed, ODR).

## OPERATOR DECISION REQUIRED (gated — NOT in S14)

- A live quant stack (Remizov / Heston / rough-Heston / FNO / PINN / deep hedging /
  RL market-making) and the compute + model-risk governance it requires.
- Live price / IV / market-data feeds and real keys.
- Any `/v1` partner-contract change for quant signals.

## References

- `banxe-trading-backend/src/banxe_trading_backend/ports/quant_engine_port.py`,
  `api/quant.py`, `config.py`
- `banxe-trading-backend/docs/specs/quant-engine-sandbox.md`
- ADR-083 (Composable DeFi Stack); ADR-089 / ADR-090 (sibling moat seams)
