# PAYBIS — legacy crypto-flow → PAYBIS mapping + governance-drift flag

**Plane:** docs-plane (mapping + drift surface; no runtime). **Date:** 2026-06-27. Каждый факт
цитирует `CRYPTO-BLOCK.md` / ADR line. Несогласованное по агрименту → **НЕИЗВЕСТНО** (SRC-06/legal).
sub-B **НЕ редактирует** `CRYPTO-BLOCK.md` (central/governance doc) — только флагует drift.

## 1. Legacy crypto-flow → PAYBIS mapping (ADR-108: non-custodial, MiCA CASP)
Legacy-модель — NeuroNext (`CRYPTO-BLOCK.md:157-161`); target — PAYBIS distribution.

| Flow | Legacy (NeuroNext) `CRYPTO-BLOCK.md:157-161` | PAYBIS target (ADR-108) |
|---|---|---|
| **Buy crypto (fiat)** | TomPay customer acc → Neuronext corp; FCA fiat + Polish VASP crypto | **PAYBIS on-ramp (BuyCrypto)**; fiat settle → **TomPay GBP IBAN** / **Papaya SEPA EUR**; **non-custodial** (client/Paybis wallet, off BANXE balance) |
| **Sell crypto (fiat)** | Neuronext wallet → TomPay customer; Polish VASP + FCA fiat | **PAYBIS off-ramp (SellCrypto)**; same settlement route; non-custodial |
| **Card top-up crypto** | Neuronext wallet → TomPay card; Polish VASP + FCA | **PAYBIS off-ramp → TomPay card balance (GBP)** |
| **Crypto-to-crypto** | Neuronext wallet A → B; Polish VASP only | **PAYBIS-side** ИЛИ **OUT OF SCOPE**, если не входит в distribution-agreement — **НЕИЗВЕСТНО** (SRC-06 / agreement) |
| **Fiat transfer** | TomPay → external; FCA only (NOT crypto) | **UNCHANGED** — TomPay FCA, не crypto, **не PAYBIS** (out of scope) |

## 2. Invariant impact — NeuroNext → PAYBIS (Latvia MiCA CASP)
Source invariants: `CRYPTO-BLOCK.md:372/374/375/378` (CANON).

| Inv | Legacy meaning | Под PAYBIS |
|---|---|---|
| **I-30** No crypto services for UK residents | Neuronext T&C restriction | **Re-evaluate под PAYBIS T&C** (была NeuroNext T&C) — **НЕИЗВЕСТНО** (operator/legal; PAYBIS CASP T&C deadline 2026-07-01) |
| **I-32** Dual AML reporting | TomPay→NCA/UKFIU; Neuronext→GIIF (Poland) | **PL-GIIF-leg уходит**; crypto-AML теперь **PAYBIS-side (Latvia/MiCA)**; BANXE сохраняет **MLRO oversight** (ADR-114). **Reporting-топология меняется** |
| **I-33** No auto-SAR / legal firewall | TomPay ↔ Neuronext firewall | NeuroNext gone → firewall теперь **TomPay ↔ PAYBIS** (data-processor/controller, GDPR Art.28, ADR-108) |
| **I-36** Neuronext = TomPay client | Corporate acc for settlement | **БОЛЬШЕ НЕ ПРИМЕНЯЕТСЯ** (NeuroNext retired); settlement теперь **Paybis → TomPay GBP IBAN** |

> Все «meaning under PAYBIS» строки требуют governance-ратификации (re-base инвариантов) — это central/legal решение, не sub-B.

## 3. GOVERNANCE DRIFT flag (для operator/MAIN)
**[FACT, audit]** `docs/CRYPTO-BLOCK.md` **НЕ согласован** с ADR-108/138: **0** упоминаний `ADR-108`/`paybis`/`retired`/`superseded`, при этом **46** упоминаний `neuronext` (verified grep on origin/main) — документ всё ещё описывает NeuroNext как **активный** VASP, тогда как ADR-108 (на main) ретайрит NeuroNext → PAYBIS.

**Рекомендация (central/governance, НЕ sub-B):**
1. Пометить `CRYPTO-BLOCK.md` как **superseded-by-ADR-108** (crypto-VASP-слой).
2. Re-base **I-30/I-32/I-33/I-36** на PAYBIS-модель (per §2 выше) — с legal/MLRO ратификацией.
3. До этого — расхождение задокументировано здесь; sub-B **surfaces, does not edit** central doc.

## 4. Primary-track note (CORRECTED — see superseding record)
**[FACT, shell-evidence + governance]** **safeguarding-engine (P0 CASS 15) = REAL/DONE**: `app/services/*`
**0 NotImplementedError** + full test suite (verified); **GAP-REGISTER GAP-003 = ✅ DONE**; **IL-541**
coverage 95.82%. **F-aml = REAL+TESTED (~80%)** (по-прежнему точно).

> **[SUPERSEDED]** Прежняя формулировка в этой §4 — «safeguarding-engine = SPEC-LOCKED-STUB, 40
> NotImplementedError, IL-535 STOP» (из `EMI-IMPLEMENTATION-STATE-2026-06-25.md:19/29/64`) — **STALE**,
> отменена авторитетной коррекцией: `docs/architecture/EMI-IMPL-STATE-REFRESH-2026-06-26.md` (**IL-552**,
> branch `agent/factory/phase36/impl-state-refresh @ 1728a2a`). **IL-535** — referenced superseded, **НЕ
> редактируется/не перенумеровывается** (append-only, ADR-119/I-28).

→ Return-to-base: **safeguarding-engine — НЕ open primary-track gap (DONE)**. Внутреннего runtime-stub не
осталось; остаточное — только **external-provider-gated** (Twilio/Sumsub/Modulr/Sardine/FOS-portal/
offsite-upload), тот же класс, что PAYBIS live.

## 5. Cross-ref
ADR-108 (`docs/adr/ADR-108-payment-distribution-model.md`), ADR-114, ADR-138; `PAYBIS-GOVERNANCE-FACTS.md`;
`CRYPTO-BLOCK.md:157-161` (flows) / `:372-378` (invariants); `PLAN-ROADMAP-SPRINTS-NEURONEXT-TO-PAYBIS.md`.
