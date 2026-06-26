# DOSSIER — PAYBIS as sole external crypto provider (NeuroNext retired)

**Тип:** досье для последующего plan/roadmap/sprints. **Plane:** docs-plane only — без runtime-изменений.
**Дата:** 2026-06-26 · **Трек:** F-crypto-provider (PAYBIS) · **Статус:** входные материалы (не план).
**Дисциплина:** заземлено ТОЛЬКО на ADR-108, ADR-114, ADR-138, BANXE↔PAYBIS agreement (SP-PR3) и live-audit факт. Каждое утверждение помечено **[FACT]** / **[INFERENCE]** / **НЕИЗВЕСТНО**. Runtime-факты не выдумываются.

> **Источники истины (и их доступность):**
> - ADR-108 (payment distribution model) — на main, прочитан **[доступен]**.
> - ADR-114 (Travel Rule / PAYBIS CASP) — на main, прочитан **[доступен]**.
> - ADR-138 (NeuroNext retired, PAYBIS sole crypto) — этот трек, IL-545 **[доступен]**.
> - **BANXE↔PAYBIS agreement (SP-PR3 Distribution/Outsourcing) / Paybis distribution guide** — **НЕ НАЙДЕН в репозитории** (ADR-108/114 на него ссылаются как на «operator-provided», но сам документ в repo отсутствует). Все пункты, требующие его текста, помечены **НЕИЗВЕСТНО**.
> - Live-audit: banxe-emi-stack origin/main `b23593c` — **0** `neuronext` и **0** `bitrix` в `services/`/`app/` **[FACT, audit]**.

---

## 1. Executive framing

- **[FACT, ADR-108/138]** PAYBIS полностью замещает все крипто-процессы, ранее относившиеся к NeuroNext (on/off-ramp, custody, execution, payouts, treasury-side crypto). NeuroNext (собственный VASP/custodial) ретирован; ADR-108 «Neuronext superseded», ADR-138 — запрет на повторное введение.
- **[FACT, ADR-138]** NeuroNext запрещён к реинтродукции в целевой архитектуре: ни один новый code path не вводит NeuroNext как активного участника (licensing/processing/data-exchange/orchestration); dual-provider логика запрещена.
- **[FACT, audit]** Текущий EMI-кодбейс (`b23593c`) не содержит активного следа NeuroNext/Bitrix в `services/`/`app/` → это **не** legacy-cleanup, а **forward-only governance guard + greenfield PAYBIS implementation track**.
- **[FACT, ADR-108]** BANXE = distribution agent + technical front, **не** CASP; крипто-ответственность (MiCAR/custody/CASP) — на PAYBIS.

---

## 2. Source-of-truth constraints — FACT vs INFERENCE vs UNKNOWN

### FACT (прямо из ADR-108)
- PAYBIS = MiCA CASP, Latvia / Latvijas Banka, EU-passport (27). BANXE ≠ CASP.
- Модель: PAYBIS — весь крипто (on/off-ramp, custody, execution); BANXE distribution fee 30–40%.
- Custody: **NON-CUSTODIAL** — крипто на стороне PAYBIS/клиентского кошелька, вне баланса BANXE.
- Settlement: PAYBIS fiat-settlement через Tompay dedicated IBAN (GBP); Papaya = EU-SEPA EUR rail.
- Outsourcing (KYC/AML): PAYBIS = data **processor**, BANXE = data **controller** (GDPR Art.28).
- T&C CASP disclosure до 2026-07-01; single-provider concentration risk (митигировать 2-м rail: Stellar/Circle CPN) — **inference-flag оставлен ADR-ом, не обязателен для PAYBIS-трека.**

### FACT (прямо из ADR-114)
- Travel Rule (FATF R.16, UK MLR 2017, порог GBP 1,000) — ответственность PAYBIS как лицензированного CASP.
- BANXE сохраняет MLRO-oversight как fallback-контроль (ADR-036 option b).
- `CryptoCompliancePort` (ADR-036) = seam к PAYBIS TR-данным (получать TR-status, не строить TR-plumbing).
- Ни один BANXE-originated крипто-поток не идёт live, пока не оформлены: (1) PAYBIS TR-confirmation contract, (2) MLRO oversight procedure.

### FACT (прямо из ADR-138)
- PAYBIS = единственный external crypto processor; seams = `CryptoLedgerPort` / `CryptoCompliancePort`; no dual-provider; rollback не реинтродуцирует NeuroNext; PAYBIS-adapter = отдельный gated runtime-таск.

### INFERENCE (выводимо, помечено как вывод, не факт)
- **[INFERENCE]** Реализация PAYBIS-адаптера ляжет за существующие `services/ledger/crypto_ledger_port.py` (`CryptoLedgerPort`/`CryptoRpcPort`) — там 12 неимплементированных stub-методов (`get_balance`/`create_wallet_address`/`create_tx`/`get_fee_estimate`/`health`). Основание: ADR-138 называет именно этот seam; сам маппинг method→PAYBIS-API в ADR не зафиксирован → детали **НЕИЗВЕСТНО**.
- **[INFERENCE]** Паттерн реализации (injectable-mock + fenced live API + HITL для движения средств) выводится из уже идущих `BT-xxx`-PR репозитория; не закреплён ADR-ом.

### НЕИЗВЕСТНО (требует подтверждения)
- Точный текст BANXE↔PAYBIS agreement (SP-PR3) и Paybis distribution guide — **в repo отсутствуют**.
- Конкретный PAYBIS API-контракт (endpoints, auth, webhook-схемы, sandbox) — **НЕИЗВЕСТНО**.
- Method→PAYBIS-operation mapping для `CryptoLedgerPort` — **НЕИЗВЕСТНО**.

---

## 3. Contractual constraints (из Paybis agreement) — **частично INGESTED (SRC-01)**

> Источник: `Corporate-On_Off-Ramp_BANXE-LTD-rev.-1.docx` (BANXE LTD rev.1) — excerpt (Section 8, 9.3, General) предоставлен оператором → commercial/settlement-слой = **[FACT]**. Полный `.docx` ещё не на диске → approved-environment + security/incident/audit + API остаются **НЕИЗВЕСТНО**. Деталь — в `docs/paybis-dossier/SRC-01-banxe-paybis-agreement.md`.

### 3a. Commercial / settlement — [FACT, agreement §8/§9.3/General]
| Пункт | Значение |
|---|---|
| Party identities | Partner = **BANXE LTD**; counterparty = **Paybis** |
| Partner Fees disbursement | Paybis выплачивает Partner Fees (§8); **remit within 30 days of an invoice undisputed by Paybis**; в **wallet address ИЛИ bank account** (Partner-specified) |
| Invoicing | Monthly (or as agreed) Paybis уведомляет Partner о сумме к инвойсу (incl. tax); вне-EU Partner — invoice без отдельных references |
| Taxes | все налоги на Partner Fees — **ответственность Partner** |
| Fee cap | Paybis **не обязан** платить сверх Partner Fees, как specified by Paybis |
| Shortfall Fee (§9.3) | Paybis по своему усмотрению: (1) **invoice, payable within 14 days**, ИЛИ (2) **set off / deduct** из accrued Partner Fees/commissions (relevant/subsequent period) |
| Annexes | **Annex 1** (и будущие) — integral part of the Agreement |
| Conflict rule | при конфликте **Agreement prevails over Commercial Offer** |
| Warranty | Paybis **disclaims warranties** beyond expressly prescribed; **no warranty** что Services fully secure/uninterrupted/error-free |
| Notice emails | Partner: invoice@/finance@/support@banxe.com; Paybis: users@/legal@paybis.com |

### 3b. Approved-environment / control-obligations / TR — **НЕИЗВЕСТНО (вне excerpt)**
| Пункт | Значение | Источник |
|---|---|---|
| Approved legal entity (точн. Paybis юр.лицо/№) | PAYBIS = MiCA CASP Latvia/Latvijas Banka [FACT, ADR-108]; **точное юр.лицо — НЕИЗВЕСТНО** | [FACT, ADR-108] / agreement: вне excerpt |
| Approved domains / URLs / subdomains | **НЕИЗВЕСТНО** | вне excerpt → SRC-05 |
| Approved ICT systems / environments / use cases | use-cases on/off-ramp/custody/execution/payouts [FACT, ADR-108]; ICT-перечень **НЕИЗВЕСТНО** | [FACT, ADR-108] / вне excerpt |
| Prior-written-approval change procedure | **НЕИЗВЕСТНО** | вне excerpt |
| Security obligations / incident / remediation / audit rights | **НЕИЗВЕСТНО** (excerpt даёт лишь warranty-disclaimer); GDPR Art.28 processor/controller [FACT, ADR-108] | [FACT, ADR-108] / вне excerpt |
| Sublicensing / white-label scope | BANXE = distribution/technical front [INFERENCE, ADR-108]; ограничения **НЕИЗВЕСТНО** | [INFERENCE] / вне excerpt |
| TR data clause | TR responsibility на PAYBIS [FACT, ADR-114]; точная формулировка **НЕИЗВЕСТНО** | [FACT, ADR-114] / вне excerpt → SRC-07 |

### 3c. Архитектурные импликации — [INFERENCE из §3a]
- Treasury/adapter моделируют **оба payout-рельса** (wallet + bank); **fee netting** (Shortfall set-off); **30-day undisputed-invoice** dispute/recon-окно; warranty-disclaimer → **resilience** (API не гарантированно доступен) + независимая reconciliation; Annex 1 как binding fee-config, Agreement > Commercial Offer.

**Требует от оператора/legal:** полный `.docx` (approved domains/ICT, change-approval, security/incident/audit, sublicensing) + SRC-05/SRC-06/SRC-07.

---

## 4. Architecture target

- **[FACT, ADR-138]** PAYBIS = sole external crypto provider; **no dual-provider logic**.
- **[FACT, ADR-138/114]** Seam placement: крипто-операции — за `CryptoLedgerPort` (`services/ledger/crypto_ledger_port.py`); compliance/Travel-Rule — за `CryptoCompliancePort` (ADR-036/114, «получать TR-status, не originate»).
- **[FACT, ADR-138]** Rollback-правило: откат не реинтродуцирует NeuroNext (rollback = halt/queue/MLRO-manual, никогда не re-route на NeuroNext).
- **[FACT, ADR-108]** BANXE non-custodial: крипто вне баланса BANXE; fiat-settlement через Tompay IBAN.
- **Microservice consolidation principle [INFERENCE из операторской формулировки]:** сохранить микросервисную архитектуру, но сократить duplicate/versioned/legacy-варианты (`*/legacy/*`, `*/production/*_stub.py`, `*_v2`) — консолидация только через ADR-102 dup-audit (проверка всех consumer-ов) и без слома `CryptoLedgerPort`-контракта (он широко потребляется: abs, fpa_agent, auth, open_banking ×3 — менять контракт нельзя).
- **[HARD REQUIREMENT — MANDATORY TRACK]** «Architecture Conformance & Service Consolidation» — обязательный сквозной трек (PLAN §1A + acceptance §5A): preserve microservice arch · reduce service count (smart) · eliminate legacy/versioned/deprecated duplicates · **remove Bitrix + NeuroNext process footprint** · map legacy→target ports («adapt, not transplant») · **shell-audit evidence** для каждого решения. Ни одна волна не complete без §5A (replacement done + conformance checked + duplication audited + leftovers removed-or-parked). Baseline (a27ab27): 107 services, 3 `_v2`, 22 legacy, 5 stub; neuronext/bitrix footprint = 0.

---

## 5. Implementation dossier map (инвентарь для будущего runtime-плана)

| Область | Что должно войти | Источник / статус |
|---|---|---|
| Provider adapter scope | PAYBIS-адаптер за `CryptoLedgerPort`/`CryptoRpcPort`: `get_balance`, `create_wallet_address`, `create_tx`, `get_fee_estimate`, `health` (+ tx-status) | [FACT seam, ADR-138]; method→API mapping **НЕИЗВЕСТНО** |
| Compliance / Travel-Rule | `CryptoCompliancePort` приём TR-status от PAYBIS; MLRO-oversight fallback; go-live gate (TR-contract + MLRO procedure) | [FACT, ADR-114] |
| KYC/KYB/AML touchpoints + I-27 | PAYBIS = data processor, BANXE = controller (GDPR Art.28); решения L2+ под I-27 HITL; крипто-AML граф (ADR-111) — **референс, не реимплементация** | [FACT, ADR-108]; пороги/процедуры **НЕИЗВЕСТНО** |
| Treasury / exchange / custody / payout | non-custodial (PAYBIS/клиентский кошелёк); payouts = новый revenue; treasury-crypto через PAYBIS | [FACT, ADR-108]; операционные детали **НЕИЗВЕСТНО** |
| Wallet / balance / fee / tx-status | методы `CryptoLedgerPort` + результаты/статусы из `crypto_ledger_port.py` (`CryptoBalance`/`CryptoWalletAddress`/`CryptoTransactionResult`/`CryptoFeeEstimate`) | [FACT, code seam]; PAYBIS-семантика **НЕИЗВЕСТНО** |
| Webhook / event handling | приём async статусов/событий от PAYBIS (tx confirmations, TR-flags) | **НЕИЗВЕСТНО** (нет API-контракта) |
| Secrets / env / config | PAYBIS API-ключ/FRN/endpoints как env/secrets (никогда не в repo, I-SEC); config-as-data для порогов | **НЕИЗВЕСТНО** конкретика; принцип [FACT, canon] |
| Observability / audit / reconciliation | audit-trail крипто-операций; recon PAYBIS-side vs ledger; D-recon как источник (read-only) | принцип [FACT]; детали **НЕИЗВЕСТНО** |
| Test strategy | injectable mock (unit, ≥90%) + fenced live PAYBIS API (no live integration в тестах) | [INFERENCE, repo-pattern] |
| Operator gates / legal deps | SP-PR3 текст; TR-confirmation contract; MLRO procedure; CASP T&C disclosure (2026-07-01) | [FACT gates, ADR-108/114]; статус **НЕИЗВЕСТНО** |

---

## 6. Roadmap inputs (только входы, не сам roadmap)

**Epics (кандидаты):**
- E1: `CryptoLedgerPort` PAYBIS-adapter (wallet/balance/tx/fee/status) — injectable-mock + fenced-live.
- E2: `CryptoCompliancePort` PAYBIS TR-status seam + MLRO-oversight fallback (go-live gate).
- E3: Webhook/event ingestion (tx confirmations, TR-flags).
- E4: Observability/audit/reconciliation крипто-потоков.
- E5: Config/secrets boundary (PAYBIS credentials, I-SEC).
- E6: Consolidation guard (ADR-102) duplicate/legacy crypto-variants — без слома контракта.

**Dependency graph (выводимо):** E2 (TR/MLRO gate) **блокирует** go-live E1; E3 зависит от E1 (tx-модель); E4 зависит от E1/E3; E5 — кросс-зависимость всех; E6 параллельно.

**Unknowns / blockers:** PAYBIS API-контракт; method→API mapping; SP-PR3 текст; webhook-схемы; пороги AML/TR; sandbox-доступ.

**Data needed from operator:** полный SP-PR3 + Paybis distribution guide; approved domains/ICT; CASP T&C статус; MLRO procedure owner.

**Data needed from PAYBIS:** API spec (endpoints/auth/webhooks/sandbox); TR-status data contract; FRN/entity; SLA/incident/audit clauses.

**Data needed from emi-stack shell audit:** актуальное состояние `crypto_ledger_port.py` consumer-ов; live state stub-методов; пересечения с open `BT-xxx` PR (избежать коллизий: #205/#231/#233–238).

---

## 7. Return-to-base rule

**[Canon]** По завершении трека реализации PAYBIS sub-B **возвращается к своей основной роли/канону** (RIGHT terminal, primary track) и **возобновляет приостановленную основную активность**. Текущий трек (NeuroNext→PAYBIS governance + дальнейший greenfield-build) — временный; после его закрытия — return-to-base, без удержания крипто-трека как постоянной роли.

---

### Refs
ADR-108 (distribution model), ADR-114 (Travel Rule / PAYBIS CASP), ADR-138 (NeuroNext retired / PAYBIS sole crypto); `services/ledger/crypto_ledger_port.py`; ADR-036 (CryptoCompliancePort), ADR-111 (crypto-AML graph); residual-gap register IL-516; live-audit `b23593c`. **BANXE↔PAYBIS agreement (SP-PR3) — НЕ в repo, требуется от оператора.**
