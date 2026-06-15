---
id: ADR-101
title: Sandbox portal / UX shell (SBOX-6) — internal demo shell over SBOX-1..5
status: ACCEPTED
date: 2026-06-15
accepted: 2026-06-15
supersedes: []
related:
  - "ADR-096-unified-sandbox-mode-surface.md (status, SBOX-1)"
  - "ADR-097-sandbox-demo-scenarios.md (scenarios, SBOX-2)"
  - "ADR-098-sandbox-session-recorder-replay.md (sessions, SBOX-3)"
  - "ADR-099-partner-sandbox-pack.md (partners, SBOX-4)"
  - "ADR-100-sandbox-educational-gamification.md (gamification, SBOX-5)"
  - "ADR-095-g1-g4-go-live-decision-support.md (public/live portal would be G-gated)"
il_anchor: IL-246
scope: BANXE-only
concept_only: false
---

# ADR-101: Sandbox portal / UX shell (SBOX-6)

**Status:** ACCEPTED — 2026-06-15
**IL:** IL-246 (Sprint SBOX-6 — sandbox portal / UX shell)
**Extends:** the SBOX-1..5 sandbox surfaces. Internal-only; no live activation.

## Context

The advisory stack plus SBOX-1..5 are on main, each as a separate internal
`/api/v1/sandbox/*` surface. There was no single demonstration entry point. SBOX-6
adds a light **internal** sandbox portal (docs + a minimal UI) that composes those
surfaces into one shell for operators, partner-success, and compliance — with a clear
"no live execution" banner and no public rollout.

## Decision

### D1 — An internal sandbox portal that composes SBOX-1..5

A devportal section + a minimal internal UI screen with: a **Sandbox Overview**
(reads `…/sandbox/status`, SBOX-1); **Demo Scenarios** (lists scenarios + a
walkthrough hint, SBOX-2); **Sessions & Replay** (lists/views sessions, SBOX-3);
**Partner Sandbox** (sample partners + bundles, SBOX-4); **Educational Gamification**
(badges + streak, SBOX-5); and a global banner: "Sandbox / Advisory-only / No live
execution, billing, KYB, or keys."

### D2 — Read-only over the sandbox API; no live action

The portal only **reads** the existing `/api/v1/sandbox/*` endpoints (plus, for the
gamification demo, the opt-in sandbox gamification event). It exposes **no** button or
path that calls `/v1/orders*` or any live endpoint, and holds no keys, billing, or KYB.

### D3 — Internal / dev-only; no public rollout; no contract change

The UI is an internal tool (dev/sandbox-only, opt-in) and adds no new backend
endpoint. No `/v1` facade or public BaaS/TaaS endpoint changes. Any future
public-facing portal is a separate ADR + G-ratification.

## Consequences

- **Positive:** one "entry" into the sandbox for demos and training (investor,
  partner, regulator), entirely over the existing advisory/mock surfaces.
- **Neutral:** a presentation shell; it adds no capability, provider, or contract.
- **Gated:** a public / live portal remains operator-gated (separate ADR + G).

## OPERATOR DECISION REQUIRED (unchanged)

A public-facing or live portal, and any live execution / billing / KYB behind it,
remain operator- and compliance-gated. SBOX-6 delivers none of it.

## References

- banxe-trading-frontend: `src/features/sandbox-portal/*`, `src/pages/sandbox-portal/*`
- banxe-architecture: `docs/devportal/sandbox-portal.md`
- ADR-096..100 (SBOX-1..5); ADR-095 (G-gates)
- `docs/runbooks/g1-g4-mica-aml-runbook.md` (portal is a view over the sandbox)
