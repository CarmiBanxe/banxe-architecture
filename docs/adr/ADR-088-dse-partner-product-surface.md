---
id: ADR-088
title: DSE partner/product surface — opt-in product metadata + sandbox partner context (non-breaking)
status: ACCEPTED
date: 2026-06-14
accepted: 2026-06-14
supersedes: []
related:
  - "ADR-084-dse-baas-foundation.md (DSE advisory foundation)"
  - "ADR-087-dse-provider-foundation.md (provider foundation + provenance)"
  - "ADR-086-risk-earn-baas-readonly-sandbox.md (read-only sandbox boundary)"
il_anchor: IL-222
scope: BANXE-only
concept_only: false
---

# ADR-088: DSE partner/product surface

**Status:** ACCEPTED — 2026-06-14
**IL:** IL-222 (Sprint S11 — DSE partner/product surface, non-breaking, mock-default)
**Extends:** ADR-084 (DSE advisory foundation), ADR-087 (provider foundation).
Advisory-only, self-custodial, mock-first boundaries are **unchanged**.

## Context

The DSE advisory engine (`POST /v1/dss/recommend`) is stable, with provenance
resolved by the S10 provider foundation (ADR-087). Sprint S11 prepares the engine
for partner-facing and terminal-facing use by surfacing **product-safe metadata**
and a **sandbox partner-context** seam — **without** changing the recommendation
contract semantics, enabling live providers, or introducing auth/billing.

## Decision

### D1 — Opt-in, non-breaking product metadata

`RecommendResponse` gains an **optional** `product` (`ProductMetadata`) block,
populated **only** when the request supplies `partnerContext` (`null` otherwise).
Existing callers see no behavioural change; ranking and utility are unchanged. The
block carries safe `providerProvenance` (per-domain class `mock | stub |
inert-live-ready`), normalized `modelVersions`, `explanationVersion` +
`explanationModel` (the utility formula), advisory, executes and self-custodial flags,
a `determinism` label, a `requestId` (= `traceId`, correlation only), the partner
echo, and a disclaimer. **No secrets, no raw env, no credentials, no internal-only
traces.**

### D2 — Sandbox partner-context seam (metering-READY only)

`RecommendRequest` gains an **optional** `partnerContext`
(`partnerId`, `clientRef`, `mode`). `partnerId`/`clientRef` are **opaque, bounded**
(≤ 64 chars, `^[A-Za-z0-9._:-]+$`) — they carry **no auth, no billing, no
entitlement**; they are correlation/metering-READY only. Only `mode: "sandbox"` is
supported.

### D3 — Fail-closed on unsupported modes

Any non-sandbox `mode` is rejected at the **schema layer** (validator → `422`,
"OPERATOR DECISION REQUIRED"). A production partner mode, auth/KYB, billing, or
entitlement is **NOT invented** — it is an OPERATOR DECISION (legal + compliance).

### D4 — Terminal explainability surface

The product block plus the existing per-recommendation `utilityBreakdown` /
`topDriver` / `reasons` give a terminal Decision Assistant panel the compact
rationale, factor breakdown, and safe provenance labels — deterministic in mock
mode. No frontend is built here.

### D5 — Advisory-only / mock-default unchanged

No live activation, no real keys, no auto-execution, no signing, no custody, no
billing/tiering. Absent `partnerContext`, the response is byte-compatible with the
prior contract. Provenance reflects the S10 tiers; live-ready surfaces as the safe
`inert-live-ready` label (still no network/credentials).

## Consequences

- **Positive:** partner/terminal-ready metadata + a reversible partner-context seam
  with zero contract break; safe provenance + explainability for UIs; fail-closed
  on unsupported modes.
- **Negative / cost:** real partner identity (auth/KYB), entitlement, billing and
  metering enforcement remain future operator-gated work.
- **Risk:** scope creep toward auth/billing — fenced by D2/D3 (metering-READY only,
  fail-closed, ODR).

## OPERATOR DECISION REQUIRED (gated — NOT in S11)

- Production partner mode, partner authentication / KYB, entitlement enforcement.
- Billing, partner-tiering, production metering.
- Any live provider activation (per ADR-087 / IL-218 options) or real credentials.
- Any compliance/legal assertion (MiCA / CASP) as a product guarantee.

## References

- `banxe-trading-backend/src/banxe_trading_backend/dse/product.py`, `dse/models.py`,
  `dse/engine.py`
- `banxe-trading-backend/docs/specs/dse-baas-api.yaml` (PartnerContext, ProductMetadata)
- `banxe-trading-backend/docs/specs/dse-baas-sandbox-guide.md` (Partner/product surface)
- ADR-084/086/087; IL-217/218 (provider foundation + live options), IL-221 (S10)
