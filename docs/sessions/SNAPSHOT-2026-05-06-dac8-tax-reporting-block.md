# SNAPSHOT — DAC8 EMI Compliance: Tax Reporting + Customer Notification + 60-day Kill Switch + Ownership Matrix

**Тип:** Roadmap Block  
**Дата:** 2026-05-06 (CEST)  
**Базовый чекпоинт:** `checkpoint-2026-05-06-defi-stack-binance-replacement-block`  
**Тег после merge:** `checkpoint-2026-05-06-dac8-tax-reporting-block`  
**Статус:** inventory / organisational mapping — код в `banxe-emi-stack` в этом блоке не затрагивается

**Источники:**
- Council Directive (EU) 2023/2226 of 17 October 2023 (DAC8)
- OECD CARF (Crypto-Asset Reporting Framework) + CRS 2.0 XML schema
- MiCA Regulation (EU) 2023/1114
- GDPR Regulation (EU) 2016/679
- AMLR (EU) / AMLD6
- Директива 2011/16/EU (DAC) — базовый документ, к которому DAC8 является поправкой

---

## 1. Регуляторный контекст

DAC8 (Council Directive (EU) 2023/2226) — поправка к Directive 2011/16/EU (DAC) об административном сотрудничестве в сфере налогообложения. Вступила в силу 13 ноября 2023 г.; обязанности RFI по отчётности начинают действовать **с 1 января 2026 г.** Первый отчётный период — 2026 fiscal year; первый срок отчётности — **January–July 2027** (по странам); автоматический межстрановой обмен — **до 30 сентября 2027 г.**

EMI BANXE (Electronic Money Institution, лицензия EMD2/PSD2) квалифицируется как **Reporting Financial Institution (RFI)** по CRS 2.0 и как оператор **Specified Electronic Money Products (SEMPs)** по DAC8. Обязанность возникает в момент хранения электронных денег (e-money balances), обслуживания крипто-активов или крипто-переводов в рамках MiCA.

### Таблица регуляторных слоёв

| Слой | Регулятор / Стандарт | Роль для BANXE |
|---|---|---|
| Базовый | Council Directive (EU) 2023/2226 (DAC8) | Обязательная ежегодная отчётность RFI в EU MS налоговую |
| Данные | OECD CARF + CRS 2.0 XML schema | Формат данных для XML-выгрузки |
| Крипто | MiCA Regulation (EU) 2023/1114 | CASP/SEMP: дополнительный scope для крипто-активов |
| Privacy | GDPR Regulation (EU) 2016/679, Art. 6(1)(c) | Обязательное уведомление клиента о передаче данных в налоговую |
| AML/CDD | AMLR (EU) / AMLD6 Art. 33 | Пересечение CDD-блокировки с 60-day kill-switch |
| Налог. обмен | DAC (Directive 2011/16/EU) + DAC8 Annex VI | Автоматический межстрановой обмен между EU MS |

---

## 2. Что обязан делать BANXE как EMI (резюме обязанностей)

| № | Обязанность | Правовое основание |
|---|---|---|
| 1 | Self-certification от каждого клиента (физ + юр + Controlling Persons / UBO) | DAC8 Annex VI, Section II |
| 2 | Сбор TIN (Tax Identification Number) и юрисдикций налогового резидентства | DAC8 Annex VI, Section I; CRS 2.0 |
| 3 | Ежегодная XML CARF отчётность в национальный налоговый орган страны регистрации BANXE | DAC8 Annex VI, Section I; OECD CARF schema |
| 4 | 60-day kill-switch: self-certification → напоминания → блокировка reportable transactions | DAC8 Annex VI, Section V(A)(2) |
| 5 | GDPR-обязательное уведомление клиента о передаче его данных в налоговую | GDPR Art. 13/14; Art. 6(1)(c) |
| 6 | Change-in-Circumstances мониторинг и пересмотр юрисдикций | DAC8 Annex VI, Section IV |
| 7 | Conflicting Indicia review (противоречивые адреса / юрисдикции) | DAC8 Annex VI, Section III; CRS 2.0 §C |
| 8 | Due Diligence процедуры для Passive NFEs / Controlling Persons | DAC8 Annex VI, Section V |
| 9 | DAC8 Register: документирование выполнения обязанностей и audit trail отправок | DAC8 Art. 25a; GDPR Art. 30 |
| 10 | Сохранение данных self-certification минимум 5 лет | DAC8; GDPR Art. 5(1)(e) |

---

## 3. Customer Notification (GDPR-обязательное)

Уведомление клиента о передаче его данных в налоговые органы **обязательно** по DAC8 и реализуется через GDPR Art. 13/14. Это EU-специфичное требование; в OECD CARF и §6045 США аналога нет.

### Где включать

| Точка контакта | Содержание |
|---|---|
| **Privacy Policy** | Отдельный раздел «Tax Reporting (DAC8/CRS)»: какие данные, кому, на каком основании, как долго хранятся |
| **Onboarding flow** | Just-in-time notice при сборе self-certification на шаге KYC |
| **Self-certification request email** | Явное указание: «данные будут переданы в [налоговый орган страны регистрации]» |
| **Annual reminder email** | При Change-in-Circumstances или смене юрисдикции |
| **Terms & Conditions** | Право BANXE на блокировку reportable transactions при непредоставлении self-cert в 60 дней |

### Правовое основание

- Lawful basis: **GDPR Art. 6(1)(c)** — legal obligation (DAC8 как обязательный EU закон)
- Data subject rights: информирование по Art. 13 (при сборе) и Art. 14 (при получении из иных источников)
- Срок хранения: минимум 5 лет (DAC8) / 5 лет по CASS / GDPR data minimisation

### Минимальный набор формулировок (черновой) `legal-review-required`

```
[EN — draft, not legally reviewed]
"Banxe (EMI) is required under Council Directive (EU) 2023/2226 (DAC8) and the Common
Reporting Standard (CRS) to collect and annually report certain account holder information
— including Tax Identification Numbers (TINs), jurisdiction(s) of tax residence, and
account balance/transaction data — to [country of registration] tax authorities.
This data may subsequently be exchanged automatically with EU Member State tax authorities
where you are tax resident. The legal basis for this processing is GDPR Article 6(1)(c)
(legal obligation). You have the right to access, rectify, or raise objections regarding
this processing; contact privacy@banxe.com or our DPO."
```

---

## 4. 60-Day Kill-Switch — Операционный пайплайн

Annex VI, Section V(A)(2) DAC8 обязывает BANXE заблокировать **reportable transactions** (не весь аккаунт) через 60 дней после первичного запроса self-certification, если клиент не предоставил ответ.

```
Day 0    : initial self-certification request (email + in-app notification)
           → start 60-day timer in Customer Lifecycle FSM
           → audit event: DAC8_SELF_CERT_REQUESTED logged to ClickHouse

Day +20  : reminder 1 (email + in-app push)
           → audit event: DAC8_SELF_CERT_REMINDER_1

Day +45  : reminder 2 (email + in-app push) + SMS if available
           → audit event: DAC8_SELF_CERT_REMINDER_2

Day +60  : block reportable transactions (lifecycle FSM state: DAC8_OVERDUE)
           → audit event: DAC8_SELF_CERT_OVERDUE_BLOCK
           → non-reportable transactions (e.g., e-money top-up in own jurisdiction)
             remain unaffected pending legal review
           → notification to client: "Your account has a restriction on reportable
             transactions pending tax self-certification. Please complete at [link]."

Day >60  : escalate to MLRO/AML for AMLR Art. 33 CDD review
           → if Conflicting Indicia confirmed → treat as higher-risk jurisdiction
           → possible account closure path per T&C
           → refund of remaining e-money balance per EMD2 safeguarding rules
```

### Привязки к реализации (future-design — не имплементируем в этом PR)

| Компонент | Привязка |
|---|---|
| Lifecycle FSM | `services/customer_lifecycle/*` — новое состояние `DAC8_OVERDUE` |
| Event type | Рассмотреть `BanxeEventType.DAC8_SELF_CERT_OVERDUE` (или переиспользование `KycReTriggerEvent` — решение в ADR-047) |
| Блокировка транзакций | Через payment service + transaction guard, аналогично AML-блокировке |
| Audit trail | ClickHouse append-only (ADR-027), отдельный канал `dac8_events` |
| Terms & Conditions | Clauses: право BANXE на блокировку, возврат баланса по EMD2, срок уведомления клиента |

---

## 5. Ownership Matrix (каноническое распределение)

| Роль | Подразделение BANXE | Главные обязанности | Артефакты в репо |
|---|---|---|---|
| **RFI Owner / DAC8 Reporter** | Tax Reporting & Regulatory Reporting Function (Compliance & Reporting, под MLRO / Head of Compliance) | XML CARF выгрузка, отправка в национальный налоговый орган, DAC8 register, audit-лог отправок, annual DAC8 report | `services/reporting/*`, FIN060 pipeline, ADR-027 audit trail, Consumer Duty annual report, SAR auto-filing |
| **Data Ingestion Co-owner** | Customer Operations (KYC / Onboarding / CS) | Сбор self-certification (TIN, юрисдикции, Controlling Persons / UBO), customer notification, 60-day reminders, эскалация при Change-in-Circumstances / Conflicting Indicia | `services/kyc/*`, `services/customer_lifecycle/*`, `services/notifications/*`, `services/customer_management/*`, Privacy Policy / T&C templates |
| **Privacy / DPO** | Legal & Privacy | GDPR Art. 13/14 notice, Privacy Policy DAC8 section, lawful basis documentation (Art. 6(1)(c)), DPIA | Privacy Policy templates, DPIA register |
| **MLRO / AML** | AML Function | AMLR Art. 33 / AMLD6 пересечения (CDD-блокировка при overdue self-cert), Conflicting Indicia эскалация, SAR при подозрении на уклонение | `services/aml/*`, sanctions/PEP pipeline, AML audit trail |
| **Engineering / Platform** | Platform Engineering | Tax-Reporting Service, FSM-интеграция, DAC8 outbox (надёжная доставка XML), audit-канал, event types | `banxe-emi-stack`, future ADR-045..049 |

### Принцип разделения ответственности

- **Tax Reporting Function** = единственный RFI для целей DAC8; владеет форматом и отправкой XML; отвечает перед налоговым органом.
- **Customer Operations** = единственный канал коммуникации с клиентом по self-cert; не имеет прямого доступа к XML-выгрузке.
- Пересечение: Customer Operations эскалирует Change-in-Circumstances → Tax Reporting Function пересматривает reportability.
- AML и DAC8 — **параллельные** блокировки с отдельными audit reasons; одна блокировка не снимается другой.

---

## 6. Архитектурная карта (ASCII)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         BANXE EMI — DAC8 FLOW                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  BANXE Customer UI                                                      │
│        │                                                                │
│        ▼                                                                │
│  Customer Operations (KYC/Onboarding/CS)                               │
│  ├── self-certification request (TIN + jurisdictions + UBO/CPs)         │
│  ├── GDPR notification (Privacy Policy + onboarding just-in-time)       │
│  ├── 60-day reminders (Day 0 / +20 / +45)                               │
│  └── Change-in-Circumstances / Conflicting Indicia detection            │
│        │                                                                │
│        ▼                                                                │
│  Customer Lifecycle FSM (services/customer_lifecycle/*)                 │
│  ├── 60-day timer → DAC8_OVERDUE state                                  │
│  ├── KycReTriggerEvent / DAC8_SELF_CERT_OVERDUE event                   │
│  └── Block reportable transactions (payment guard)                      │
│        │                          │                                     │
│        │                          ▼                                     │
│        │                   AML/MLRO Function                            │
│        │                   (AMLR Art. 33 CDD review,                    │
│        │                    Conflicting Indicia, account closure)        │
│        │                                                                │
│        ▼                                                                │
│  Tax Reporting & Regulatory Reporting Function                          │
│  (Compliance & Reporting, under MLRO / Head of Compliance)              │
│  ├── aggregate reportable account data                                  │
│  ├── generate XML (OECD CARF schema / DAC8 Annex VI)                   │
│  ├── maintain DAC8 Register                                             │
│  └── submit to national tax authority (country of EMI registration)     │
│        │                                                                │
│        ▼                                                                │
│  National Tax Authority (country of EMI registration)                   │
│        │                                                                │
│        ▼ (automatic exchange)                                           │
│  EU Member State Tax Authorities (where customers are tax resident)     │
│        │                                                                │
│        ▼ (parallel, all events)                                         │
│  ClickHouse Audit Trail (ADR-027, append-only, TTL ≥ 5 years)          │
│  dac8_events table: DAC8_SELF_CERT_*, CARF_REPORT_SUBMITTED, etc.      │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Связи с ADR / Track'ами и резерв будущих ADR

### Существующие ADR с прямой привязкой

| ADR | Тема | Привязка к DAC8 |
|---|---|---|
| ADR-027 | Audit-trail durability (append-only ClickHouse) | Обязателен для DAC8-отправок; отдельный канал `dac8_events` |
| ADR-028 | KYC re-verification triggers (`BanxeEventType.JURISDICTION_CHANGED`) | Триггерит DAC8 Change-in-Circumstances пересмотр юрисдикций |
| ADR-033 | Alert routing | DAC8 reminders (Day +20, +45, +60) маршрутизируются через тот же alert/notification pipeline |
| ADR-034 | Webhook reliability | DAC8 reporting outbox (надёжная доставка XML в налоговый орган) |

### Резерв будущих ADR (создание не в этом PR)

| ADR | Тема |
|---|---|
| ADR-045 | DAC8 Tax Reporting Service: domain model, XML CARF schema, outbox pattern |
| ADR-046 | DAC8 self-certification flow: onboarding + Change-in-Circumstances + Conflicting Indicia |
| ADR-047 | DAC8 60-day kill-switch: lifecycle FSM integration + Terms & Conditions clauses |
| ADR-048 | DAC8 customer notification: GDPR Art. 6(1)(c) embedding into Privacy Policy and onboarding |
| ADR-049 | DAC8 ↔ AMLR Art. 33 boundary: shared blocking semantics, separate audit reasons |

> **Примечание:** ADR-045..049 конфликтуют с ранее зарезервированными ADR-045..050 (DeFi Stack, см. SNAPSHOT-2026-05-06-defi-stack-binance-replacement-block.md). Перед созданием ADR необходимо согласовать нумерацию с владельцем реестра.

---

## 8. Pending Invariant Proposals (без правки `INVARIANTS.md`)

| ID | Формулировка | ADR для формализации |
|---|---|---|
| **I-40** | DAC8 Tax Reporting Function is the canonical RFI within BANXE; no DAC8 reportable data is sent to third parties outside of OECD CARF / EU MS tax authorities; customer notification is mandatory by GDPR/DAC8 and embedded in Privacy Policy + onboarding flow | ADR-045 + ADR-048 |
| **I-41** | 60-day self-certification kill-switch must be enforced by lifecycle FSM and reflected in Terms & Conditions; blocking transactions before 60 days is prohibited; after 60 days, blocking reportable transactions is mandatory | ADR-047 |

---

## 9. Якоря для продолжения

- **Базовый тег:** `checkpoint-2026-05-06-defi-stack-binance-replacement-block`
- **Новый тег после merge:** `checkpoint-2026-05-06-dac8-tax-reporting-block`

### Возможные следующие шаги (отдельные треки, не в этом блоке)

| Трек | Содержание | Зависимость |
|---|---|---|
| ADR-045..049 | Формализация DAC8 domain model, self-cert flow, 60-day FSM, GDPR notice, AMLR boundary | После согласования нумерации с DeFi-треком (ADR-045..050) |
| Privacy Policy update sprint | Раздел DAC8/CRS, GDPR Art. 13/14 notice — `legal-review-required` | Legal & Privacy (DPO) approval |
| T&C update sprint | Clauses о 60-day kill-switch, блокировке reportable transactions, закрытии счёта, возврате e-money баланса | Legal & Privacy (DPO) + MLRO approval |
| Tax-Reporting Service (banxe-emi-stack) | Prototype: XML CARF schema, outbox, submit endpoint | ADR-045 accepted |
| Customer Lifecycle FSM extension | `DAC8_OVERDUE` state, `DAC8_SELF_CERT_OVERDUE` event type | ADR-047 accepted |
| Pending legal review | ADR-045..049 нумерация, T&C и Privacy Policy формулировки | Operator / legal sign-off |
