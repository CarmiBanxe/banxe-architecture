# ADR-036: FATF Travel Rule for crypto-asset transfers

**Status:** Closed (2026-05-11) — Decision recorded; implementation deferred to Sprint S21 (Crypto Block).
**Date:** 2026-05-11
**Author:** Architecture WG (audit summary by Central, 2026-05-11)
**Supersedes:** none
**Related:** decisions/ADR-014-composable-financial-stack.md, decisions/ADR-016-ai-plane-pii-aml-routing.md, decisions/ADR-029-postgres-backup-strategy.md, IL-OPS-MIRROR-BACKFILL-V3-2026-05-11.

## Context

FATF Recommendation 16 (the "Travel Rule") requires originator and beneficiary information to accompany virtual-asset transfers above the EUR/USD 1,000 threshold (UK: GBP 1,000 per HM Treasury 2022 amendment). For an FCA-authorized EMI that ingests, holds, or routes crypto assets (BANXE EMI's planned Sprint S21 Crypto Block: Neuronext custody + TomPay fiat<->crypto bridge), Travel Rule compliance is a precondition for any production crypto flow.

This ADR records the Travel Rule decision history. The detailed evaluation, three Sprint candidates considered, and the final closure rationale live in `docs/audit/adr-036-final-summary-2026-05-11.md` (88 lines, merged via PR #214, commit `6fa8f52`). This file exists in `decisions/` to make ADR-036 reachable from canonical anchor citations (compliance README, security README, future Sprint S21 docs).

## Decision

1. **Travel Rule compliance is mandatory** for any production crypto-asset transfer originated, received, or intermediated by BANXE EMI services. The threshold follows UK MLR 2017 as amended (GBP 1,000 per FATF R.16).
2. **Implementation is deferred to Sprint S21 (Crypto Block)**. The exploratory Sprint 3 candidate (full Travel Rule provider integration before Crypto Block) was **CANCELLED** to avoid building Travel Rule plumbing without a custodian counterparty.
3. **No crypto flow may go live without** (a) a Travel Rule provider integrated (candidate vendors: Notabene, Sumsub Travel Rule, Veriscope) or (b) a manual SAR/STR procedure documented and signed off by MLRO (Sprint S20.8 dependency).
4. **CryptoCompliancePort** (design referenced in MASTER-PLAN-2026-05-05 Sprint S21.2) carries Travel Rule responsibility; implementation tracked under Sprint S21.

## Implementation status

- **Decision recorded:** 2026-05-11 (this ADR + audit doc + PR #214).
- **Sprint 3 candidate:** CANCELLED 2026-05-11 (see `docs/audit/sprint3-cancellation-2026-05-11.md`).
- **Sprint S21 implementation:** PENDING; not started; blocked on Sprint S20 (MLRO appointment, custodian API keys: Neuronext, TomPay).
- **Production crypto flow:** BLOCKED until S21 completes + S21.1 ADR-036 vendor decision + MLRO sign-off.

## Severity vocabulary

- **High severity:** any production crypto transfer without Travel Rule data accompanying it.
- **Medium severity:** test/sandbox crypto flow without Travel Rule simulation harness.
- **Low severity:** non-crypto flows mistakenly flagged for Travel Rule.

## Known follow-ups

- Sprint S21.1: Travel Rule vendor selection (Notabene vs Sumsub TR vs Veriscope) — separate ADR (TODO ADR-NNN, number assigned at vendor-decision time).
- Sprint S21.2: CryptoCompliancePort interface design + adapter.
- Sprint S21.6: Crypto AML (Chainalysis/Elliptic adapter) — co-dependent with Travel Rule for chain-analysis context.
- MLRO sign-off cadence for Travel Rule SAR exceptions (Sprint S25.4 quarterly review).

## References

- Source-of-truth audit: `docs/audit/adr-036-final-summary-2026-05-11.md` (PR #214, commit 6fa8f52)
- Sprint 3 cancellation: `docs/audit/sprint3-cancellation-2026-05-11.md`
- IL anchor: `IL-OPS-MIRROR-BACKFILL-V3-2026-05-11` (Track A backfill captured ADR-036 in IL).
- Roadmap: MASTER-PLAN-2026-05-05.md Sprint S21 (Crypto Block, Phase 7).
- FATF Recommendation 16 (Wire Transfers, virtual assets).
- UK MLR 2017 as amended (HM Treasury 2022 amendment for crypto threshold).
