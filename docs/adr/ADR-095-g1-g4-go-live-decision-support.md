---
id: ADR-095
title: G1–G4 go-live decision-support matrix (MiCA 2026) — PROPOSED, materials-only, activates nothing
status: PROPOSED
date: 2026-06-15
accepted: null
supersedes: []
related:
  - "ADR-083-composable-defi-stack.md (self-custodial unsigned execution; the venues)"
  - "ADR-089-market-making-advisory-seam.md (moat sprint S12)"
  - "ADR-090-dynamic-fee-engine-advisory-seam.md (moat sprint S13)"
  - "ADR-091-quant-moat-advisory-seam.md (moat sprint S14)"
  - "ADR-092-ecosystem-marketplace-advisory-seam.md (moat sprint S15)"
  - "ADR-093-multi-venue-execution-preview-hardening.md (moat sprint S16)"
  - "ADR-094-scope-closure-s6.6-s6.7-t7.9-t8.0.md (scope closure S17)"
il_anchor: IL-238
scope: BANXE-only
concept_only: true
binding_artifact: null
---

# ADR-095: G1–G4 go-live decision-support matrix (MiCA 2026)

**Status:** PROPOSED — 2026-06-15 (NOT ACCEPTED)
**IL:** IL-238 (G1–G4 operator decision-support; materials-only)

> **This ADR activates NOTHING.** It is a governance **decision-support** artifact
> prepared by the factory per the governance canon ("the LLM assistant prepares
> materials only; governance decisions are rules-based with mandatory
> human-in-the-loop"). Every row carries a **RECOMMENDED DEFAULT** and a blank
> **RATIFICATION** cell that only the operator + MLRO/legal may complete. Until a
> row is ratified in writing AND credentials are provisioned out-of-band, the
> estate stays **mock / advisory / unsigned / fail-closed**. This is regulatory
> context, **not legal advice** — final determinations require qualified
> compliance/legal sign-off. Moving any row to YES/PHASED requires a follow-up ADR
> flipping this one to ACCEPTED (or superseding it) plus a new IL.

## Context

The tech spine S6–T11, the moat S12–S16 (ADR-089…093, IL-223…236), and the scope
closure S17 (ADR-094, IL-237) are on protected main and considered complete for
2026. The whole estate is mock / advisory / unsigned / fail-closed — the MiCA-safe
resting state. The MiCA CASP regime is fully mandatory after 1 July 2026 once the
transitional period ends. Four go-live tracks remain entirely operator- and
compliance-gated: G1 live providers, G2 partner auth / KYB / billing, G3 execution
go-live, G4 gamification policy. This ADR records the prepared decision-support
matrix so the operator can ratify cell-by-cell; it does not decide.

## Decision (PROPOSED defaults — pending ratification)

Legend: **Default** = factory-recommended conservative posture · **Ratify** = blank,
operator/MLRO completes (YES / NO / PHASED + conditions + date + signer).

### G1 — Live providers

| Sub-block | Recommended default | Escalation conditions | Ratify (operator/MLRO) |
|---|---|---|---|
| Market/execution venues (dYdX v4, GMX, LI.FI, StakeKit, …) | NO — mock/sandbox | PHASED only post-CASP: EEA-only whitelist, majors only, per-user + per-day notional caps, blocklist (anon/mixing protocols, non-MiCA / unbacked tokens, sanctioned). No retail pre-suitability. | ☐ ______ |
| Data/analytics (prices, IV, sentiment, stress, quant) | PHASED — advisory-only OK; NO as best-execution input | Advisory feeds: public, read-only, no-key now. Exec-grade feed only once G3 live + licensing/quality documented. Tag every feed advisory-vs-execution. | ☐ ______ |
| Logging / decision-lineage | YES — mandatory prerequisite | Per request: inputs, normalized features, provider+model version, output, rationale, correlationId, partner/user id, timestamp; append-only/immutable; retention ≥5y (confirm vs MiCA/AML). Buildable mock-safe now. | ☐ ______ |

### G2 — Partner auth / KYB / billing / entitlement

| Sub-block | Recommended default | Conditions | Ratify (operator/MLRO) |
|---|---|---|---|
| Partner eligibility | Licensed CASP/EMI/credit institution → eligible (sandbox first → live after KYB + contract); unlicensed fintech → sandbox only; retail/unverified → prohibited | MiCA-compatible status is a precondition; evidence retained. | ☐ ______ |
| KYB/KYC minimums | Standard KYB all live partners; enhanced (EDD) for higher-risk | TFR/Travel Rule: crypto transfers carry no de-minimis under EU TFR — full originator/beneficiary data; only TFR-capable counterparties admissible. | ☐ ______ |
| Entitlement & billing | Sandbox/Free enabled now; paid tiers (Starter/Pro/Enterprise) OFF — operator decision | If paid: recommend Lago (OSS, metered post-paid) for auditability; rev-share only after legal review; tier limits map to G1 caps. | ☐ ______ |

### G3 — Execution go-live

| Product | Recommended default | Conditions | Ratify (operator/MLRO) |
|---|---|---|---|
| Spot / swaps | Advisory-only (preview + DSE) | Limited live only post-CASP with written best-execution policy (price, cost, speed, likelihood, settlement), EEA-only, majors, caps, monitoring. | ☐ ______ |
| Perpetuals / derivatives | Sandbox/education only — recommend NO live 2026 | Suitability/appropriateness, leverage caps, margin, stress tests, likely MiFID overlap; needs dedicated licensing + suitability engine. | ☐ ______ |
| Earn / staking / yield | Advisory rate-preview only | Live earn can touch EMT / e-money / collective-investment regimes; product-by-product legal classification + risk/counterparty disclosures first. | ☐ ______ |
| Technical guardrails | Non-custodial, client-side signing only (backend holds no keys) | Chain/protocol whitelist; fail-closed on: no CASP licence, missing/stale best-exec data, stale KYC, sanctioned counterparty, off-whitelist venue/protocol, slippage/limit breach. | ☐ ______ |

### G4 — Gamification policy

| Sub-block | Recommended default | Conditions | Ratify (operator/MLRO) |
|---|---|---|---|
| Demo/advisory-only mechanics | Leaderboards, streaks, quests, tournaments — paper/sim only, clearly labelled, zero real money/risk | Disclaimers, max-notify / max-engagement caps, geo-exclusion where restricted. | ☐ ______ |
| Hard prohibitions | NO — variable-ratio rewards on real trading, near-miss visuals on real PnL, loss-chasing nudges, deposit-inducement mechanics | Anything readable as predatory gamblification or an unfair inducement under MiCA consumer-protection / fair-marketing. Matches the standing canon (gamification excluded). | ☐ ______ |

## Consequences

- **If ACCEPTED as defaults:** the estate stays mock / advisory / unsigned /
  fail-closed; the only safe-to-build-now item is G1 decision-lineage logging
  (mock-safe, non-activating). All other rows stay gated until individually ratified.
- **Forward path:** each ratified row that opens PHASED/YES requires a dedicated
  follow-up ADR (flipping or superseding this one) plus a new IL, the relevant
  licence in force, and credentials provisioned out-of-band by the operator.
- **No change to code, endpoints, contracts, or providers** results from this ADR.

## OPERATOR DECISION REQUIRED

Every Ratify cell above. No factory action moves any row to PHASED/YES. Real keys /
secrets, credentialed provider activation, live execution, partner billing, and
legal/compliance classifications remain operator + compliance decisions.

## References

- ADR-083; ADR-089…093 (S12–S16); ADR-094 (S17)
- IL-223 (S12), IL-225 (S13), IL-226 (S14), IL-227 (S15), IL-236 (S16), IL-237 (S17)
- MiCA CASP regime (full effect after the transitional period ends 1 July 2026)
