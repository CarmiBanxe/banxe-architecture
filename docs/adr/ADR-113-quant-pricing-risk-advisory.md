# ADR-113: Quant Pricing & Risk Advisory Engine (advisory-seam)

**Status:** PROPOSED
**Date:** 2026-06-19

## Context
DSE (36) + Software Factory + DeFi venues + ADR-079 CRO risk-port + QuantLib (9, Treasury ALM GAP-036) exist. MISSING: quant option-pricing models (SABR=1, Bates=1, Avellaneda=1, market-making=0). Trading TaaS block requires pricing/Greeks/VaR for DSE recommendations.

## Decision
- Add quant pricing/risk as ADVISORY-SEAM layer (feeds DSE recommendations + ADR-079 risk-port), NOT live execution (MiCA broker-dealer avoidance, consistent ADR-089/090/091/093).
- Pricing: Heston ADI + SABR/SVI/eSSVI vol-surface + Bates-SVJ (QuantLib already in stack). Spec specs/heston-solver.yaml (latency<1ms target precomputed).
- Market-making advisory: Avellaneda-Stoikov optimal-spread + Remizov solver (analytical) — feeds DSE, NOT autonomous MM.
- Risk API: Greeks/VaR99/stress (CMS-VAE) advisory endpoints; integrate ADR-079 CRO risk-metrics-port.
- Deep Hedging/PINN/FNO: research-stage, preview only (optional).

## Compliance
- All advisory/preview: pricing+Greeks+VaR+DSE recommendation only. NO autonomous order execution (MiCA). Human/HITL decides per intent-first ADR-049 masks.
- gamification (if any) stays demo/educational + anti-addiction + jurisdiction-restricted.

## Consequences
- Positive: completes Trading TaaS quant layer; reuses QuantLib+DSE+ADR-079; advisory-safe (no MiCA broker-dealer).
- Negative/residual: model calibration/ops effort; GPU for Monte Carlo (Bates); Deep-Hedging research-stage.

## Related
- DSE (ADR-085), ADR-079 (CRO risk-port), ADR-089/090/091 (advisory-seams), ADR-093 (execution-preview), GAP-036 (Treasury QuantLib), GAP-020 (ICARA), GAP-070 (new).
