# AML Stack Layers — Banxe

Краткая справочная карточка слоёв, scoring, thresholds.  
Полная документация: `COMPLIANCE-ARCH.md`.

---

## 3-layer AML Runtime

```
LAYER 1 — Policy / Regulatory  [developer-core]
  compliance_validator.py
  _HARD_BLOCK_JURISDICTIONS | _HIGH_RISK_JURISDICTIONS
  _THRESHOLD_SAR=85 | _THRESHOLD_REJECT=70 | _THRESHOLD_HOLD=40
  _FORBIDDEN_PATTERNS  (verification guardrails)
         ↓ imported by
LAYER 2 — AML Engines  [vibe-coding/src/compliance/]
  tx_monitor.py     → 9 deterministic rules + Redis velocity
  sanctions_check.py → Watchman + fuzzy fallback
  crypto_aml.py      → OFAC wallet + heuristic flags
  aml_orchestrator.py → generic aggregator
         ↓ aggregated by
LAYER 3 — BANXE Runtime  [vibe-coding/src/compliance/]
  banxe_aml_orchestrator.py
  banxe_assess(transaction, customer, counterparty, wallet, channel)
  → BanxeAMLResult (decision, case_id, policy_version, audit_payload)
```

## Decision Thresholds

| Score | Decision | Action |
|-------|----------|--------|
| ≥ 85 | SAR | MLRO уведомлён, транзакция заблокирована |
| 70–84 | REJECT | Транзакция заблокирована |
| 40–69 | HOLD | EDD required |
| < 40 | APPROVE | Pass |
| `sanctions_hit=true` ИЛИ `HARD_BLOCK` | REJECT/SAR | Независимо от score |

## Scoring Formula (adverse media)

```
final_score = source_weight × 0.45
            + entity_match_weight × 0.35
            + topic_weight × 0.20
```

Regulatory boost: `is_regulatory=True` → contribution × 1.4  
Noise floor: articles с `final_score < 0.10` отбрасываются

## Transaction Monitor Rules

| Rule | Threshold | Score |
|------|-----------|-------|
| HARD_BLOCK_JURISDICTION | Category A | 100, short-circuit |
| HIGH_RISK_JURISDICTION | Category B | +35 |
| SINGLE_TX_THRESHOLD | ≥ £10,000 | +30 |
| VELOCITY_24H | cumulative ≥ £25,000 | +40 |
| POTENTIAL_STRUCTURING | 3+ txs × £8k-9,999 в 24h | +60 |
| ROUND_AMOUNT | round ≥ £5,000 | +15 |
| RAPID_IN_OUT | credit→debit < 1h, ≥ £1,000 | +50 |
| CRYPTO_FLAG | is_crypto=True | +20 |

## Crypto AML Rules

| Rule | Trigger | Score |
|------|---------|-------|
| CRYPTO_SANCTIONS | Watchman OFAC match | 100, short-circuit |
| CRYPTO_CRITICAL | darknet/terrorism/ransomware | 90 |
| CRYPTO_HIGH_RISK | mixer/tumbler/scam | 70 |
| CRYPTO_ELEVATED | layering/rapid_in_out/pep | 40 |
| CRYPTO_HIGH_VALUE | tx > £50,000 | 20 |

## Signal Priority (не чистая сумма)

| Ситуация | Pure summation | Priority result |
|----------|---------------|----------------|
| Cat B jurisdiction, £200 | APPROVE (score 35) | **HOLD** (floor) |
| PEP customer, clean £500 | APPROVE (score 35) | **HOLD** (PEP floor) |
| Cat A jurisdiction | depends | **REJECT** (always) |
| sanctions_confirmed | depends | **REJECT/SAR** (always) |

## Watchman Calibration

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| minMatch | 0.80 | Catches "Putin Vladimir" from "Vladimir Putin" |
| algorithm | Jaro-Winkler | Better for name transliteration |
| Lists | OFAC SDN, UK CSL, EU CSL, UN CSL, FinCEN 311 | — |
