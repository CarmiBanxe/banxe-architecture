---
id: ADR-094
title: Scope closure for S6.6 / S6.7 / T7.9 / T8.0 — DROPPED, out-of-scope for 2026
status: ACCEPTED
date: 2026-06-15
accepted: 2026-06-15
supersedes: []
related:
  - "ADR-083-composable-defi-stack.md (the S6/T7/T8 spine these labels sat beside)"
  - "ADR-089-market-making-advisory-seam.md (moat sprint S12)"
  - "ADR-090-dynamic-fee-engine-advisory-seam.md (moat sprint S13)"
  - "ADR-091-quant-moat-advisory-seam.md (moat sprint S14)"
  - "ADR-092-ecosystem-marketplace-advisory-seam.md (moat sprint S15)"
  - "ADR-093-multi-venue-execution-preview-hardening.md (moat sprint S16)"
il_anchor: IL-237
scope: BANXE-only
concept_only: true
---

# ADR-094: Scope closure for S6.6 / S6.7 / T7.9 / T8.0

**Status:** ACCEPTED — 2026-06-15
**IL:** IL-237 (Sprint S17 — scope-closure for the legacy roadmap labels)
**Scope-definition only:** no code, no spec, no endpoint — a governance record that
canonically closes four dangling roadmap labels.

## Context

The labels `S6.6`, `S6.7`, `T7.9`, and `T8.0` appeared in an early BANXE
trading-platform roadmap map and are referenced in research documents. On
`origin/main` there is **no ADR, no INSTRUCTION-LEDGER entry, and no implemented
spec** under any of these four labels; prior audits flagged them as **NOT
CONFIRMED**.

Meanwhile the S6–T8 spine has been delivered and the Phase-A moat train is complete:

- DSE advisory, BaaS sandbox facade, decision-trace, provider foundation and tiers,
  execution-intent preview, and the Risk/Earn surface (T7.x / T8.1–T8.4 / T9.x).
- The mock-safe moat — market-making (S12), dynamic fee engine (S13), quant-moat
  (S14), ecosystem/marketplace (S15), multi-venue unsigned execution-preview
  hardening (S16) — accepted as ADR-089…ADR-093 and recorded as IL-223…IL-236.

Leaving four NOT CONFIRMED labels in the S6–T8 space is a governance gap: it is
ambiguous whether they are pending build obligations. This ADR removes that
ambiguity. Per the best-decision canon for 2026, the four labels are closed as
**DROPPED (out-of-scope)** rather than scheduled, because none belongs to the
minimal core plus moat layer required for 2026, and none carries an ADR, IL, or
spec that would make it a commitment.

## Decision

The four labels are canonically closed as **DROPPED — out-of-scope for the 2026
BANXE trading concept**, with no build obligation:

- **`S6.6`** — `Status: DROPPED`. Not part of the minimal core plus moat layer for
  2026; it carries no ADR, IL, or spec. May return only via a future dedicated ADR.
- **`S6.7`** — `Status: DROPPED`. Closed as out-of-scope; its original direction is
  either already subsumed by the delivered S12–S16 moat or is a deliberate choice
  not to widen the 2026 map. No ADR, IL, or spec exists.
- **`T7.9`** — `Status: DROPPED`. The delivered DSE / BaaS / preview / quant /
  marketplace coverage already provides a sufficient T7 surface; a standalone T7.9 is
  no longer needed as a mandatory element and carries no ADR, IL, or spec.
- **`T8.0`** — `Status: DROPPED`. T8 is covered by T8.1–T8.4 (and the S12–S16 moat);
  T8.0 as a standalone roadmap tag has no dedicated ADR, IL, or spec and is removed.

This ADR does not delete or invalidate prior research documents referencing S6.6,
S6.7, T7.9, or T8.0. It only states that these labels are **not** part of the
canonical BANXE trading concept for 2026 and do not carry any build obligations. Any
future implementation would require a dedicated ADR and a new IL entry.

## Consequences

- **Positive:** the S6–T8 space has **no remaining NOT CONFIRMED labels** — the
  DSE / BaaS / execution-preview / provider-foundation / product-surface map plus the
  S12–S16 moat is considered **complete for 2026**. Scope is unambiguous.
- **Neutral:** the themes originally associated with these labels survive in research
  documents as ideas, not commitments.
- **Forward path:** any future work in these thematic areas must be filed as a new
  `S-` / `T-` / `X-` / `G-` sprint with its own ADR and IL entry.

## OPERATOR DECISION REQUIRED (unchanged by this ADR)

Reviving any of S6.6 / S6.7 / T7.9 / T8.0 — or starting any live work — remains an
operator decision and would require a dedicated future ADR + IL. The G1–G4 track
(live providers, partner auth / KYB / billing, execution go-live, gamification
policy) is unaffected and remains operator- and compliance-gated.

## References

- ADR-083 (Composable DeFi Stack); ADR-089…ADR-093 (moat sprints S12–S16)
- IL-223 (S12), IL-225 (S13), IL-226 (S14), IL-227 (S15), IL-236 (S16); IL-237 (this)
- Prior roadmap / research maps referencing S6.6 / S6.7 / T7.9 / T8.0 (unchanged)
