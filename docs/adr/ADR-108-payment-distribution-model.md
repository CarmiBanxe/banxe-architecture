# ADR-108: Payment Distribution Model — Tompay + Paybis (Neuronext superseded)

**Status:** ACCEPTED (2026-06-20, operator sanction via Paybis distribution guide; both open-items resolved — strategy Neuronext->Paybis confirmed)
**Date:** 2026-06-19
**Supersedes:** Owner-Control SNAPSHOT BANXE.COM=TOMPAY+NEURONEXT (Neuronext crypto VASP retired)

## Context
BANXE.COM = distribution front for two regulated providers. Crypto arm migrates from Neuronext (own VASP/custodial) to Paybis (MiCA CASP, Latvia/Latvijas Banka, EU-passport 27). BANXE = distribution agent, NOT CASP.

## Decision
- Tompay (UK EMI, FCA): GBP/UK fiat rail, 100% fiat margin.
- Paybis (MiCA CASP): all crypto (on/off-ramp, custody, execution); BANXE distribution fee 30-40%.
- BANXE: distribution agent + technical front; not CASP, no MiCAR/custody liability.
- [RESOLVED — SETTLEMENT, operator 2026-06-20]: Paybis fiat settlement via Tompay dedicated IBAN (GBP); Papaya remains EU-SEPA rail for EUR per rails-v4.
- [RESOLVED — CUSTODY, operator 2026-06-20]: NON-CUSTODIAL (Paybis/client wallet; client crypto stays off BANXE balance); Neuronext custodial model retired.

## Compliance
- MiCAR/CASP/custody liability on Paybis (distribution model). T&C CASP disclosure by 2026-07-01.
- Travel Rule (ADR-036): crypto go-live needs Paybis TR handling OR MLRO manual procedure.
- Outsourcing (KYC/AML): Paybis = data processor, BANXE = data controller (GDPR Art.28).

## Consequences
- Positive: clean regulatory profile (no CASP), Mass Payouts new revenue, compliance cost off P&L.
- Negative: -60-70% crypto gross margin (distribution fee vs own spread); single-provider concentration (mitigate: Stellar/Circle CPN as 2nd rail).

## Related
- ADR-015 (payment-stack), ADR-036 (travel-rule). Owner-Control SNAPSHOT (Neuronext refs to update). rails-v4 + Paybis-guide blocks.
