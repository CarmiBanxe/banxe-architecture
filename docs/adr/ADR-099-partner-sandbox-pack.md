---
id: ADR-099
title: Partner sandbox pack (SBOX-4) — sample partner profiles + demo bundles, mock-only
status: ACCEPTED
date: 2026-06-15
accepted: 2026-06-15
supersedes: []
related:
  - "ADR-096-unified-sandbox-mode-surface.md (the sandbox surface, SBOX-1)"
  - "ADR-097-sandbox-demo-scenarios.md (the demo journeys, SBOX-2)"
  - "ADR-098-sandbox-session-recorder-replay.md (the sessions, SBOX-3)"
  - "ADR-095-g1-g4-go-live-decision-support.md (G2 partner onboarding is gated here)"
il_anchor: IL-244
scope: BANXE-only
concept_only: false
---

# ADR-099: Partner sandbox pack (SBOX-4)

**Status:** ACCEPTED — 2026-06-15
**IL:** IL-244 (Sprint SBOX-4 — partner sandbox pack)
**Extends:** ADR-096 / ADR-097 / ADR-098 (sandbox surface, scenarios, sessions). No
live activation; G2 onboarding intentionally absent.

## Context

The advisory stack plus SBOX-1/2/3 is on main. To show the product to a prospective
partner — a neo-bank, wallet, broker — there was no partner-shaped demo layer. SBOX-4
adds sample partner profiles and demo bundles so partner-success and compliance can
run a partner-framed demonstration, **without crossing into G2** (real onboarding).

## Decision

### D1 — Sample partner profiles (hard-wired, mock)

Introduce `SandboxPartnerProfile` (id, slug, name, segment, region, use case, enabled
modules, a sample rate-limit tier, disclaimer) as a static, deterministic registry of
at least three profiles (`foobank-neo`, `walletco-demo`, `brokerx-sandbox`). The
`enabledModules` reference only existing advisory/sandbox modules.

### D2 — Internal partner API + demo bundle

`GET /api/v1/sandbox/partners` (list), `.../{id}` (by id or slug), and
`.../{id}/bundle` (a demo bundle: profile + recommended SBOX-2 scenarios + the SBOX-1
status link + an SBOX-3 sessions how-to + disclaimers). Description only — no
credentials or secrets.

### D3 — No G2 capability

There is **no** KYB, no billing / subscriptions, no tier activation, no partner fee
withdrawal, and no real API keys or tokens. The `sampleRateLimitTier` is a descriptive
label (`sandbox-free` / `sandbox-pro`), not an entitlement. Profiles expose only
descriptive fields.

### D4 — Internal only; no external surface, no contract change

Mounted under `/api/v1/sandbox/*`; not on the external `/v1` facade (404 there); no
existing contract changes.

## Consequences

- **Positive:** partner-success / compliance get a safe, partner-framed demo layer
  built on the existing seams.
- **Neutral:** descriptive mock profiles; no provider, network, or capability added.
- **Gated:** real partner onboarding remains **G2** — an ADR-095 ratification cell +
  a dedicated ACCEPTED ADR + operator/MLRO decision; this ADR delivers none of it.

## OPERATOR DECISION REQUIRED (unchanged)

Live partner onboarding (KYB, entitlement, billing, tiering, keys) is G2 and stays
operator- and compliance-gated. SBOX-4 activates none of it.

## References

- banxe-trading-backend: `services/sandbox_partner_profiles.py`, `api/sandbox_partners.py`
- ADR-096 / ADR-097 / ADR-098 (SBOX-1/2/3); ADR-095 (G2 gate)
- `docs/devportal/dse-baas-component.md`, `docs/runbooks/g1-g4-mica-aml-runbook.md`
