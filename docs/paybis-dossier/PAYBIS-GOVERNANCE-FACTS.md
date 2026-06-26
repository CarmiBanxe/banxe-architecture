# PAYBIS governance facts — cross-check (ADR-108 / ADR-114 / GAP-REGISTER)

**Plane:** docs-plane (governance fact-check; no runtime). **Date:** 2026-06-27. Каждая строка
**traceable** к ADR/GAP-источнику (line numbers per live audit origin/main). Без выдуманных литералов.

## Fact table (governance → PAYBIS model)
| # | Fact | Source (line) | Refines |
|---|---|---|---|
| G1 | **CryptoCompliancePort** = TR-responsibility seam («receive TR status, **not originate**»); «FROZEN after design-review» для будущего Chainalysis/Elliptic-адаптера | ADR-114:8/13, README:301, SESSION-2026-05-10 | compliance seam |
| G2 | CryptoCompliancePort **НЕ в runtime-коде** EMI — 0 occurrences в `services/`/`api/` (verified) | live audit (grep=0) | code-state |
| G3 | Settlement: Paybis fiat → **TomPay dedicated IBAN (GBP)** | ADR-108:14 | dossier §3 settlement |
| G4 | Settlement: **Papaya = EU-SEPA rail (EUR)** | ADR-108:14 | dossier §3 settlement |
| G5 | **GAP-071** (distribution model Tompay+Paybis, Neuronext superseded) = 🟡 IN PROGRESS; residual: Paybis go-live, CASP T&C by 2026-07-01, Travel Rule; Sprint 14, CEO+CTIO, Q3 2026 | GAP-REGISTER:61 | status |
| G6 | **GAP-072** (Travel Rule, ADR-114) = 🟡 IN PROGRESS; MLRO+CTIO, Q3 2026 | GAP-REGISTER:62 | status |
| G7 | **Go-live gate:** ни один BANXE-originated crypto-flow не идёт live, пока НЕ оба — **Paybis TR-confirmation contract** + **MLRO oversight procedure** | ADR-114:14/22, ADR-108:18 | go-live gate |
| G8 | TR data contract — часть **SP-PR3** | ADR-114 | go-live gate |
| G9 | **CASP T&C disclosure deadline: 2026-07-01** | ADR-108 (GAP-071 residual) | go-live gate |
| G10 | Neuronext crypto VASP **RETIRED** (custodial model retired) | ADR-108:5/8 | role model |
| G11 | **BANXE = distribution agent + technical front; NOT CASP**; no MiCAR/custody liability | ADR-108:13/15 | role model |
| G12 | **NON-CUSTODIAL** (Paybis/client wallet; client crypto off BANXE balance) | ADR-108:15 | role model |
| G13 | **PAYBIS = MiCA CASP** (Latvia / Latvijas Banka, EU-passport) | ADR-108:13 | role model |

## Corrections log
- **CryptoCompliancePort — code vs governance (honest correction).** Прежнее утверждение sub-B
  «CryptoCompliancePort does not exist» верно **только для runtime-кода** (G2: 0 в `services/`/`api/`).
  В **governance** это **каноничный, design-frozen seam** (G1, ADR-114) — **not-yet-coded**, не «не
  существует». Обе истины зафиксированы: **canonical-in-ADR-114 / not-yet-coded**. → Wave C реализует
  его как TR-status seam к Paybis (рядом с `services/crypto_custody/travel_rule_engine.py`, verified present).

## Wave C implementation note
Wave C **должна** реализовать **CryptoCompliancePort** (каноничный seam, ADR-114: receive-not-originate
TR-status) **+ интеграцию `travel_rule_engine`** — gated на ADR-114 go-live (G7) + SRC-07. До этого
compliance-поверхность остаётся fenced; CryptoCompliancePort — design-frozen, но не в коде.

## Cross-ref
ADR-108 (`docs/adr/ADR-108-payment-distribution-model.md`), ADR-114
(`docs/adr/ADR-114-travel-rule-paybis-casp.md`), GAP-REGISTER §GAP-071/072, SESSION-2026-05-10;
`PLAN-ROADMAP-SPRINTS-NEURONEXT-TO-PAYBIS.md`, `PAYBIS-SANDBOX-STATE.md`, `DOSSIER-PAYBIS-CRYPTO-PROVIDER-2026-06-26.md`.
