---
id: ADR-100
title: Sandbox educational gamification (SBOX-5) — demo-only, no real-money / G4 mechanics
status: ACCEPTED
date: 2026-06-15
accepted: 2026-06-15
supersedes: []
related:
  - "ADR-097-sandbox-demo-scenarios.md (the scenarios gamified, SBOX-2)"
  - "ADR-098-sandbox-session-recorder-replay.md (the sessions gamified, SBOX-3)"
  - "ADR-099-partner-sandbox-pack.md (the partner profiles used as labels, SBOX-4)"
  - "ADR-095-g1-g4-go-live-decision-support.md (G4 gamification policy is gated here)"
il_anchor: IL-245
scope: BANXE-only
concept_only: false
---

# ADR-100: Sandbox educational gamification (SBOX-5)

**Status:** ACCEPTED — 2026-06-15
**IL:** IL-245 (Sprint SBOX-5 — educational gamification-only sandbox layer)
**Extends:** ADR-097 / ADR-098 / ADR-099 (sandbox scenarios, sessions, partners). No
live activation; G4 (real) gamification intentionally absent.

## Context

The master research describes a strong gamification layer AND a separate compliance
stance that prohibits variable-ratio reward schedules (VRRS), near-miss UX, and other
gamblification patterns for real trading. We are in the sandbox phase, so only a
**learning/demo** gamification layer is appropriate now — and it must be fenced from
anything that could become a G4 (real-money / addictive-design) concern.

## Decision

### D1 — A sandbox-only educational gamification layer

Introduce badges, a learning streak, scenario completions, and a session-replay
achievement, bound **only** to the sandbox demo flows: SBOX-2 scenarios, SBOX-3
sessions, and SBOX-4 partner profiles (used only as a label). Canonical badges: a
first-completed-scenario badge, a full-walkthrough (all scenarios) badge, and a
session-replay-viewed badge. The streak is a purely educational counter.

### D2 — Internal API, demo state only

Two routes under `/api/v1/sandbox/gamification` — a `GET` `…/state` read and a
`POST` `…/event` apply (events `SCENARIO_COMPLETED`, `SESSION_REPLAY_VIEWED`) — over
an in-memory demo store. Event handling is fully independent of the real trading
APIs (`/v1/orders*`, `/v1/price*`, `/v1/risk*`).

### D3 — Hard exclusions (no G4 / gamblification)

NO real-money or quasi-real-money rewards; NO token / NFT / on-chain incentives; NO
variable-ratio reward schedules in production; NO near-miss UX that nudges toward real
trading; NO link to real balances, volumes, or PnL. The state model exposes only
descriptive fields (no money / PnL / volume / reward field exists).

### D4 — Internal only; no external surface, no contract change

Mounted under `/api/v1/sandbox/*`; not on the external `/v1` facade (404 there); no
existing contract changes.

## Consequences

- **Positive:** partners and operators can demonstrate a "gameful" sandbox for
  training and onboarding, safely.
- **Neutral:** descriptive demo state over existing sandbox flows; no provider,
  network, money, or token mechanic added.
- **Gated:** real (G4) gamification remains operator-gated — it requires a dedicated
  G4 ratification (an ADR-095 cell) + a separate ACCEPTED ADR. ADR-095 / G4 stays
  PROPOSED and untouched by this ADR.

## OPERATOR DECISION REQUIRED (unchanged)

Any real-money, token, or behaviourally-addictive (VRRS / near-miss) mechanic is G4
and stays operator- and compliance-gated. SBOX-5 delivers none of it.

## References

- banxe-trading-backend: `services/sandbox_gamification.py`, `api/sandbox_gamification.py`
- ADR-097 / ADR-098 / ADR-099 (SBOX-2/3/4); ADR-095 (G4 gate)
- `docs/runbooks/g1-g4-mica-aml-runbook.md` (educational gamification vs G4 policy)
