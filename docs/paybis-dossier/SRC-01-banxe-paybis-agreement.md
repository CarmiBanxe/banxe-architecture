# SRC-01 — BANXE ↔ PAYBIS agreement (legal/contractual)

**Plane:** docs-plane only (intake file; no runtime). **Track:** F-crypto-provider (PAYBIS) dossier.
**Date:** 2026-06-26 · **Source #:** 01 (legal/contractual). **Companion:** ADR-138 (IL-545), DOSSIER (IL-546), REGISTER (IL-548).

## SRC-01 — роль и статус

- **Doc role in dossier:** первичный legal/contractual источник №1 — даёт literal contractual constraints для dossier Section 3 (contractual constraints / approved environments / control obligations).
- **Doc status:** **✅ INGESTED (PRESENT).** Источник: **`Corporate-On_Off-Ramp_BANXE-LTD-rev.-1.docx`** (Corporate On/Off-Ramp, **BANXE LTD**, rev.1), предоставлен оператором (excerpt: Section 8, Sub-Section 9.3, General provisions).
- **Объём ингестии:** ниже ингестированы пункты из **предоставленного excerpt**. Полный `.docx` **не находится на диске** (предоставлен текстовый excerpt) → поля вне excerpt (approved domains/ICT/security/incident/audit/sublicensing/API) остаются **НЕИЗВЕСТНО** до получения полного документа. Контрактные термины **не выдуманы**.

## Extracted facts (FACT)

> Каждый пункт — literal contractual constraint из агримента (Corporate On/Off-Ramp, BANXE LTD rev.1). English legal terms; не перефразировано в новые обязательства.

### Party identities
- **[FACT]** Partner = **BANXE LTD**; counterparty = **Paybis**. (из заголовка + notice-emails)

### Payment terms — Section 8
- **[FACT]** Paybis disburses **Partner Fees** to Partner per Section 8.
- **[FACT]** Monthly (or as agreed), Paybis notifies Partner of the amount to be invoiced, including tax considerations.
- **[FACT]** If Partner is outside the EU, the invoice may be prepared without certain references.
- **[FACT]** All taxes on Partner Fees are the **Partner's responsibility**.
- **[FACT]** Paybis remits Partner Fees **within 30 days of receiving an invoice undisputed by Paybis**, to a Partner-specified **wallet address or bank account**.
- **[FACT]** Paybis is **not obligated to pay any fees exceeding the Partner Fees** as specified by Paybis.

### Shortfall Fee — Sub-Section 9.3
- **[FACT]** On a due **Shortfall Fee**, Paybis at sole discretion may: (1) **invoice Partner, payable within 14 days**, or (2) **set off / deduct** from accrued Partner Fees or other commissions for the relevant or subsequent period.

### General provisions
- **[FACT]** Notice emails — Partner: `invoice@banxe.com`, `finance@banxe.com`, `support@banxe.com`; Paybis: `users@paybis.com`, `legal@paybis.com`.
- **[FACT]** **Annex 1** (and any future annexes) form an integral part of the Agreement.
- **[FACT]** On conflict between the Agreement and the **Commercial Offer**, the **Agreement terms prevail**.
- **[FACT]** Paybis **disclaims warranties** (express/implied) beyond those expressly prescribed; **no warranty** that the Services are fully secure, uninterrupted, or error-free.

## Inferences (INFERENCE)

- **[INFERENCE]** Settlement поддерживает **И wallet address, И bank account** → adapter/treasury должны моделировать **оба payout-рельса** (crypto-wallet payout + fiat-bank payout).
- **[INFERENCE]** Цикл «remit within 30 days of undisputed invoice» → нужно моделировать **invoice → dispute-window → 30-day remit** в reconciliation/AR; диспут блокирует выплату.
- **[INFERENCE]** Shortfall set-off/deduct (9.3) → ledger должен поддерживать **fee netting** (Partner Fees vs Shortfall Fee, relevant/subsequent period).
- **[INFERENCE]** «no warranty fully secure/uninterrupted/error-free» → runtime обязан считать PAYBIS API **не гарантированно доступным** → resilience/retry/timeout + независимая reconciliation (не полагаться на uptime).
- **[INFERENCE]** Annexes integral + «Agreement prevails over Commercial Offer» → fee/commercial config (Annex 1) — **binding source**; нужен conflict-resolution приоритет (Agreement > Commercial Offer) в config-as-data.
- **[INFERENCE]** «monthly (or as agreed)» invoice notification → billing-cadence конфигурируемый параметр (config-as-data).

## Open / unknown (НЕИЗВЕСТНО) + кто уточняет

> Не присутствует в предоставленном excerpt; если есть в полном `.docx` — ингестировать как FACT позже; **не выдумывать**.

| Открытый вопрос | Кто уточняет |
|---|---|
| Approved domains / URLs / subdomains | **operator / legal** (полный agreement / SRC-05) |
| Approved ICT systems / environments | **operator / Paybis** (SRC-05) |
| Approved use cases (literal список) | **operator / legal** |
| Prior-written-approval change procedure | **operator / legal** |
| Security safeguards clauses | **operator / legal** |
| Incident notification timing | **operator / legal** |
| Remediation / mitigation SLA | **operator / legal** |
| Audit / assessment rights of Paybis | **operator / legal** |
| Sublicensing / third-party exposure / white-label scope | **operator / legal** |
| Full API surface / rate limits / data residency | **Paybis** (SRC-06) |
| Paybis exact legal entity name/number | **operator / Paybis** (excerpt даёт лишь «Paybis»; ADR-108 — Latvia CASP) |

## Dossier linkage

- **Relation to ADRs:** SRC-01 — материал, на который ссылаются ADR-108 (distribution model), ADR-114 (TR clause), ADR-138 (PAYBIS sole). Section 8/9.3 дают **commercial/settlement** контур под эти решения.
- **Feeds:** dossier **Section 3** (contractual constraints — payment/shortfall/general now FACT); вход для treasury/payout/reconciliation/fee-netting эпиков; control-obligations (warranty-disclaimer → resilience).
- **Residual blocker:** approved-environment + security/incident/audit + API слои всё ещё **НЕИЗВЕСТНО** (вне excerpt) → SRC-05/SRC-06 в REGISTER остаются BLOCKED; SRC-04 (agreement) — **PRESENT (excerpt ingested; full .docx pending)**.

---

### Refs
Corporate-On_Off-Ramp_BANXE-LTD-rev.-1.docx (Section 8, 9.3, General — operator excerpt); ADR-108, ADR-114, ADR-138; DOSSIER (IL-546); REGISTER (IL-548); ADR-119/I-28.
