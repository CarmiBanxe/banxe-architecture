# ADR-114: Travel Rule Responsibility under Paybis Distribution Model

**Status:** PROPOSED
**Date:** 2026-06-19
**Resolves:** ADR-036 gate (a/b) under ADR-108 distribution model

## Context
ADR-036: no crypto flow live without (a) Travel Rule provider OR (b) MLRO manual SAR/STR procedure; CryptoCompliancePort carries TR responsibility. ADR-108 (on main): Paybis = MiCA CASP, all crypto liability on Paybis; BANXE = distribution agent (not CASP).

## Decision
- Travel Rule (FATF R.16, UK MLR 2017 GBP 1,000 threshold) responsibility sits with PAYBIS as the licensed CASP executing crypto transfers — satisfies ADR-036 option (a) (TR-provider = Paybis, MiCA-mandated).
- BANXE retains MLRO oversight as fallback control (option b): MLRO reviews TR-flagged cases surfaced by Paybis; documents manual SAR/STR procedure for edge cases.
- CryptoCompliancePort (ADR-036) becomes the integration seam to Paybis TR data (receive TR status, not originate TR plumbing).
- No BANXE-originated crypto flow goes live until Paybis TR confirmation contract + MLRO oversight procedure are both in place.

## Compliance
- MiCA: TR is Paybis CASP obligation (consistent with ADR-108 crypto-liability-on-Paybis). FATF R.16 threshold GBP 1,000. UK MLR 2017.
- BANXE distribution agent: no TR plumbing to build; MLRO oversight only. Reduces BANXE regulatory surface.

## Consequences
- Positive: closes ADR-036 gate via distribution model; no BANXE TR-provider build (cost/risk off BANXE); aligned with ADR-108.
- Negative/residual: dependency on Paybis TR data contract (part of SP-PR3 Distribution/Outsourcing Agreement); MLRO oversight procedure to document.

## Related
- ADR-036 (Travel Rule), ADR-108 (distribution model), ADR-111 (crypto-AML graph), GAP-025 (NCA SARs), GAP-072 (new). SP-PR3 (legal agreement carries TR data clause).
