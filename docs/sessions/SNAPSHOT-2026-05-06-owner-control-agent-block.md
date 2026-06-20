# SNAPSHOT — Owner Control Agent 1.0: KPI/Compliance/Ops Pulse for BANXE.COM Holding (TOMPAY + NEURONEXT)

> **Reconciliation note (2026-06-20, SP-PR2 / ADR-108 ACCEPTED):** BANXE.COM = **TOMPAY** (UK FCA EMI — fiat) + **PAYBIS** (MiCA CASP — crypto distribution, NON-CUSTODIAL). **NEURONEXT (own VASP/custodial) is SUPERSEDED / RETIRED** — the crypto arm migrated to Paybis distribution (BANXE = distribution agent, not CASP; client crypto off BANXE balance). Historical NEURONEXT references below are retained for history; for current state read NEURONEXT -> PAYBIS and custodial -> non-custodial. See ADR-108, GAP-071.

**Тип:** Roadmap Block  
**Дата:** 2026-05-06 (CEST)  
**Базовый чекпоинт:** `checkpoint-2026-05-06-oss-sumsub-replacement-block`  
**Тег после merge:** `checkpoint-2026-05-06-owner-control-agent-block`  
**Статус:** inventory / organisational mapping — код в `banxe-emi-stack` в этом блоке не затрагивается

**Источник:** пользовательские markdown «OWNER CONTROL AGENT 1.0 DEPLOYMENT PACKAGE» (две версии)

**Цель документа:** зафиксировать план внедрения Owner Control Agent 1.0 — внешнего KPI/compliance/operations pulse-агента для собственника группы BANXE.COM, который ежедневно собирает агрегированные (не-PII) данные по TOMPAY LTD (FCA EMI) и NEURONEXT (CASP/VASP) через 7 Google Sheets + Apps Script → ClaudeInput → Claude Project «Owner Control Agent 1.0» → ежедневный отчёт собственнику.

---

## 1. Holding Mapping (каноническое определение объёма агента)

| Юрлицо / сущность | Тип | Регулятор / лицензия | Роль в холдинге |
|---|---|---|---|
| **BANXE.COM** | Холдинг / портал | — | Владелец группы; Owner Control Agent работает на уровне BANXE.COM |
| **TOMPAY LTD** | UK Authorised Electronic Money Institution | FCA (EMD2/PSD2); Safeguarding; RegData; FIN060 | Операционный EMI: фиат, платежи, KYC, AML, Complaints, Consumer Duty |
| **NEURONEXT** | Crypto-сервис | VASP / CASP (MiCA); DAC8; FATF Travel Rule | Crypto-арм: кастодирование, обменные операции, hot/cold wallets |
| **Owner Control Agent 1.0** | Внешний KPI-агент собственника | Наблюдатель, не оператор | Observer-only; без операционных полномочий; не в FCA-периметре TOMPAY |

### Граница ответственности агента (canonical)

- Owner Control Agent **не подменяет** MLRO, Compliance Officer, Risk Function, DPO, Tax Reporting Function, KYC/AML Operations, DAC8-Owner.
- Агент работает **сверху** на агрегированных KPI и фактах, поставляемых ответственными подразделениями.
- Агент **не используется** как канал для FCA/EBA-репортов (только для внутренней визибилити собственника).
- Агент **не имеет** write-доступа к клиентским системам.
- Операционные решения, требующие MLRO/Compliance sign-off, **не сводятся** к ответам Owner-agent'а.

---

## 2. Назначение и обязанности агента

### Ежедневный мониторинг (TOMPAY — фиат/EMI)

| Категория | Что мониторит агент |
|---|---|
| Safeguarding | Баланс safeguarding account, reconciliation status, открытые breaks (0 toleranced) |
| FCA Calendar | Срок следующего RegData submission (REP-017 fraud, REP-018 op-risk, FIN060); дней до дедлайна |
| AML / Fraud | Fraud rate, rejected tx %, transaction anomalies, SAR count (total / new), AML hits |
| Complaints | Открытые жалобы, SLA breaches, DISP compliance status, Consumer Duty flags |
| Op-Risk | Инциденты (Critical/High/Low), статус митигации |
| KYC Throughput | Кол-во onboarding (new/pending/failed), time-to-decision, rejection rate |
| DAC8 Status | % self-cert coverage, кол-во клиентов в 60-day kill-switch (reminder/blocking), готовность XML CARF |

### Ежедневный мониторинг (NEURONEXT — crypto/CASP)

| Категория | Что мониторит агент |
|---|---|
| Hot/Cold Wallets | Баланс, anomaly flag, % в hot vs cold, suspicious transaction count |
| Travel Rule | Compliance rate (%), fails |
| CASP Compliance | Статус MiCA-обязательств |
| DAC8 (CASP scope) | Аналогично TOMPAY для крипто-клиентов |

### Триггеры эскалации (приоритет: немедленно в отчёт)

| Триггер | Порог |
|---|---|
| Safeguarding break | Любой (0 tolerance) |
| FCA RegData deadline | Менее 7 рабочих дней |
| AML/Fraud spike | >порога (настраивается в ClaudeInput) |
| Crypto hot wallet anomaly | Флаг в NeuronextDailyCrypto |
| Complaints SLA breach | Любой открытый breach |
| Op-Risk Critical | Любой Critical-инцидент без митигации |
| Client churn > threshold | Настраиваемый порог (DEFAULT: >5%/неделя) |

---

## 3. Структура 8 листов Google Sheets

### Лист 1: TompayDailyFiat (ежедневные фиат-операции)

| Колонка | Содержание |
|---|---|
| A | Date |
| B | Total_Transactions |
| C | Total_Volume_GBP |
| D | Successful_Transactions |
| E | Failed_Transactions |
| F | Success_Rate_Percent |
| G | Fraud_Detected |
| H | Fraud_Rate_Percent |
| I | New_Clients_Onboarded |
| J | Active_Clients_Today |
| K | Notes |

### Лист 2: SafeguardingRecon (ежедневная сверка)

| Колонка | Содержание |
|---|---|
| A | Date |
| B | Client_Funds_Liability_GBP |
| C | Safeguarding_Account_Balance_GBP |
| D | Reconciliation_Break_GBP |
| E | Break_Status (OK / BREAK) |
| F | Bank_Account_Name |
| G | Daily_Interest_Earned_GBP |
| H | Pending_Transactions_GBP |
| I | Unidentified_Funds_GBP |
| J | Audit_Trail_Link |
| K | CASS_Compliance_Status |
| L | Reviewed_By |
| M | Approved_By |
| N | Notes |

### Лист 3: FCAReportingCalendar (регуляторный календарь)

| Колонка | Содержание |
|---|---|
| A | Report_Name (FIN060, REP-017 Fraud, REP-018 Op-Risk, DISP, Consumer Duty, etc.) |
| B | Reporting_Period |
| C | Due_Date |
| D | Submission_Status (Not Started / In Progress / Submitted / Overdue) |
| E | Responsible_Team |
| F | RegData_Reference |
| G | Notes |

### Лист 4: FraudandAML (AML и fraud-метрики)

| Колонка | Содержание |
|---|---|
| A | Date |
| B | Total_Transactions_Screened |
| C | Fraud_Alerts_Generated |
| D | Confirmed_Fraud_Cases |
| E | SAR_Filed_Total |
| F | SAR_Filed_This_Period |
| G | AML_Hits_Sanctions |
| H | AML_Hits_PEP |
| I | EDD_Cases_Opened |
| J | Notes |

### Лист 5: ComplaintsSupport (жалобы и поддержка)

| Колонка | Содержание |
|---|---|
| A | Date |
| B | New_Complaints_Received |
| C | Complaints_Resolved |
| D | Complaints_Open |
| E | FOS_Escalations |
| F | Avg_Resolution_Days |
| G | SLA_Breaches |
| H | Consumer_Duty_Flags |
| I | Refunds_Issued_GBP |
| J | Notes |

### Лист 6: OpRiskIncidents (операционные риски)

| Колонка | Содержание |
|---|---|
| A | Date |
| B | Incident_ID |
| C | Severity (Critical / High / Medium / Low) |
| D | Category (IT / Compliance / Ops / Security / Third-Party) |
| E | Description (non-PII, краткое) |
| F | Status (Open / Mitigated / Closed) |
| G | Responsible_Team |
| H | Notes |

### Лист 7: NeuronextDailyCrypto (NEURONEXT ежедневно)

| Колонка | Содержание |
|---|---|
| A | Date |
| B | Hot_Wallet_Balance_BTC_equiv |
| C | Cold_Wallet_Balance_BTC_equiv |
| D | Hot_Wallet_Anomaly_Flag (Y/N) |
| E | Total_Crypto_Transactions |
| F | Suspicious_Crypto_Tx_Count |
| G | Travel_Rule_Compliance_Rate_Percent |
| H | Travel_Rule_Fails |
| I | New_CASP_Clients |
| J | Notes |

### Лист 8: ClaudeInput (агрегационный лист, output Apps Script)

- Ячейка `ClaudeInput!A1` — единый текстовый блок, генерируемый функцией `collectDataForClaude`.
- Содержит агрегаты со всех 7 листов: последний ряд каждого листа + ближайшие FCA-дедлайны + флаги.
- **Не содержит PII:** имена клиентов, IBAN, адреса, паспортные данные, MRZ, SAR-narrative, биометрию, transaction-level данные с идентификаторами не включаются.
- Собственник копирует содержимое `ClaudeInput!A1` и передаёт в Claude Project «Owner Control Agent 1.0».

---

## 4. Apps Script Code.gs (деплоймент)

Полный исходник Apps Script из пакета деплоймента. Краткое описание:

### Меню и точка входа

- При открытии таблицы создаётся меню **Owner Agent** → **Сформировать данные для Claude**.
- Функция `collectDataForClaude` вызывается вручную или по time-driven trigger.

### Логика сборки данных

```javascript
function collectDataForClaude() {
  // 1. Получает последний ряд каждого из 7 листов (TompayDailyFiat, SafeguardingRecon,
  //    FCAReportingCalendar, FraudandAML, ComplaintsSupport, OpRiskIncidents, NeuronextDailyCrypto)
  // 2. Собирает ближайшие FCA-дедлайны из FCAReportingCalendar (фильтр: Not Started / In Progress)
  // 3. Формирует структурированный текстовый блок:
  //    - Дата отчёта
  //    - Раздел по каждому листу (числа и статусы, без PII)
  //    - Секция эскалации (все Break_Status=BREAK, SLA breaches, Critical incidents, Hot Wallet Anomaly)
  //    - FCA Calendar: ближайшие дедлайны
  // 4. Записывает в ClaudeInput!A1
  // 5. Показывает alert об успешном завершении
}
```

### Time-driven trigger

- Раз в день в период 06:00–07:00 (часовой пояс UTC/London).
- Настройка: Apps Script → Triggers → `collectDataForClaude` → Time-driven → Day timer → 6am to 7am.

### Безопасность

- Внешние API-ключи (если потребуются) хранятся в **Properties Service**, не в коде.
- Сырые клиентские данные не читаются и не записываются скриптом.
- Скрипт работает на уровне агрегатов: последний ряд листа (KPI) + calendar (даты/статусы).

---

## 5. KPI-пороги

| KPI | Зелёный | Жёлтый | Красный | Эскалация |
|---|---|---|---|---|
| Fraud Rate | <0.1% | 0.1–0.3% | >0.3% | Немедленно |
| Success Rate | >99% | 97–99% | <97% | Немедленно |
| Complaints (open) | <5 | 5–10 | >10 | Daily |
| Complaints SLA breach | 0 | — | >0 | Немедленно |
| Safeguarding break | 0 (GBP) | — | Любой | Немедленно (0 tolerance) |
| Client Churn Rate | <1%/нед | 1–5%/нед | >5%/нед | Weekly |
| Operating Margin | >15% | 5–15% | <5% | Monthly |
| FCA Reporting Deadline | >7 дней | 3–7 дней | <3 дней | Daily |
| Hot Wallet Anomaly | N | — | Y (flag) | Немедленно |
| Travel Rule Compliance | >99% | 95–99% | <95% | Daily |
| Op-Risk Critical open | 0 | — | >0 | Немедленно |

---

## 6. Workflow ежедневного отчёта собственнику

```
Шаг 1: Операторы (Compliance/Finance/Ops/CS/Engineering) заполняют листы 1..7
        (TompayDailyFiat, SafeguardingRecon, FCAReportingCalendar, FraudandAML,
         ComplaintsSupport, OpRiskIncidents, NeuronextDailyCrypto)
        с конца предыдущего рабочего дня.

Шаг 2: Apps Script collectDataForClaude запускается по trigger 06:00-07:00 UTC
        (или вручную через меню Owner Agent → Сформировать данные для Claude).
        → Агрегирует последний ряд каждого листа + FCA-дедлайны
        → Пишет в ClaudeInput!A1 (plain text, non-PII aggregates only)

Шаг 3: Собственник открывает Google Sheets → лист ClaudeInput → копирует A1.

Шаг 4: Собственник открывает Claude Project «Owner Control Agent 1.0»
        (approved channel: Claude.ai с DPA, или EU-managed Claude / Bedrock-EU).
        → Вставляет скопированный блок.
        → Claude генерирует ежедневный отчёт.

Шаг 5 (weekly): Claude генерирует сводный еженедельный отчёт
        (P&L по TOMPAY, KYC throughput, AML trends, NEURONEXT KPIs).

Шаг 6 (monthly): Claude генерирует месячный отчёт
        (совмещение P&L TOMPAY + NEURONEXT, статус FIN060, Consumer Duty summary,
         DAC8 compliance progress, краткое кросс-юрлицо сравнение).
```

### Data-residency / GDPR — обязательные ограничения ClaudeInput

- В `ClaudeInput!A1` идут **только**: объективные KPI, counters, totals, breaks, severity-флаги, calendar items.
- **Запрещено** включать: имена клиентов, IBAN, адреса, паспортные данные, MRZ, биометрию, transaction-level данные с идентификаторами клиента, SAR-narrative.
- Approved AI-plane: Claude.ai с DPA **или** EU-managed Claude / Bedrock-EU. Персональные ad-hoc аккаунты для production data — запрещены.

---

## 7. Архитектурная карта (ASCII)

```
+--------------------------------------------------------------+
|  BANXE.COM (Holding, owner view)                             |
|                                                              |
|  +---------------------------+  +---------------------------+|
|  |  TOMPAY LTD (UK EMI)      |  |  NEURONEXT (CASP)         ||
|  |  FCA Safeguarding         |  |  MiCA, DAC8, Travel Rule  ||
|  |  RegData, FIN060, PSD2    |  |  crypto custody           ||
|  |  AML, Complaints, DISP    |  |  hot / cold wallets       ||
|  +------------+--------------+  +-----------+---------------+|
|               |  daily aggregated KPIs only  |               |
|               v                              v               |
|  +------------------------------------------------------------+|
|  |  Google Sheets workbook (8 sheets)                        ||
|  |  manual + semi-automated entry by Compliance/Ops/Finance  ||
|  +-----------------------------+------------------------------+|
|                                |                              |
|                                v                              |
|  +------------------------------------------------------------+|
|  |  Apps Script collectDataForClaude                         ||
|  |  trigger 06:00-07:00 UTC daily                            ||
|  |  --> ClaudeInput!A1 (aggregated, non-PII text block)      ||
|  +-----------------------------+------------------------------+|
|                                |                              |
|                                v                              |
|  +------------------------------------------------------------+|
|  |  Claude Project "Owner Control Agent 1.0"                 ||
|  |  approved channel: Claude.ai (DPA) / Bedrock-EU           ||
|  |  no PII inputs; observer-only; no write to ops systems    ||
|  +-----------------------------+------------------------------+|
|                                |                              |
|                                v                              |
|              Daily / Weekly / Monthly report                  |
|                    --> BANXE.COM owner                        |
+--------------------------------------------------------------+

Parallel (untouched by Owner Agent):
  ClickHouse audit trail (ADR-027) -- operational audit, not owner-agent
  FCA RegData / REP-017 / REP-018 / FIN060 -- regulated reporting (Compliance)
  DAC8 Tax-Reporting Function -- XML CARF (DAC8-block)
  MLRO SAR pipeline / AML case management -- operational (not via Owner Agent)
```

Данный канал не заменяет ADR-027 audit trail и не пересекается с регуляторной отчётностью. Это owner-level visibility layer: агент только читает агрегаты и формирует нарратив для собственника.

---

## 8. Ownership Matrix (canonical)

| KPI / поле | Источник в TOMPAY/NEURONEXT | Owner / подразделение BANXE |
|---|---|---|
| Safeguarding funds, breaks | TOMPAY ledger + bank-of-record | MLRO + Treasury / Safeguarding |
| Reconciliation status | Reconciliation Engine (`services/recon/*`) | Finance / Treasury |
| FCA Reporting Calendar | Compliance & Reporting (RegData / REP-017 / REP-018 / FIN060) | Compliance & Reporting |
| Fraud & AML KPIs, SAR counts | AML pipeline (Yente/Watchman/Jube/Marble, `services/aml/*`) | KYC/AML Operations under MLRO |
| Complaints, SLA | Customer Operations + DISP register (`services/complaints/*`) | Customer Operations + DPO |
| OpRisk Incidents | Incident response register | Engineering + Risk |
| Neuronext crypto wallets | Custody / Treasury crypto | Crypto Operations + Security |
| KYC/KYB throughput | Ballerine + Customer Operations (`services/kyc/*`) | KYC/AML Operations |
| DAC8 status (coverage, reminders, blocks) | DAC8 Tax-Reporting Function (`services/reporting/*`) | DAC8 Tax-Reporting Function (Compliance & Reporting) |
| Self-cert / 60-day kill-switch | Customer Lifecycle FSM (ADR-028, `services/customer_lifecycle/*`) | Customer Operations + MLRO |
| Owner output (aggregated report) | ClaudeInput → Claude Project | BANXE.COM owner |

---

## 9. Связи с ADR / Track'ами и резерв будущих ADR

### Существующие ADR и roadmap-блоки с прямой привязкой

| ADR / Блок | Тема | Привязка к Owner Agent |
|---|---|---|
| ADR-027 | Audit-trail durability (ClickHouse) | Owner Agent не пишет в audit trail; источники KPI аудитированы через ADR-027 |
| ADR-028 | KYC re-verification triggers | JURISDICTION_CHANGED / ROLE_CHANGED → отражаются в KYC throughput KPI и DAC8 Change-in-Circumstances счётчиках |
| DAC8-блок | Tax Reporting + 60-day kill switch | «DAC8 status» KPI питается из Tax-Reporting Function; Owner Agent — наблюдатель |
| OSS-Sumsub-блок | Ballerine, Yente, Jube, Marble | Основные источники AML/KYC/Fraud KPI для Owner Agent |
| Claude Finance Agents-блок | KYC/Recon/Month-end (in-scope) | Owner Agent = observer-aggregator в роли Month-end partial; маршрут через approved AI-plane |

### Резерв будущих ADR (диапазон ADR-063..069 — без коллизий с DAC8 045..049, DeFi 045..050, OSS-Sumsub 056..062)

| ADR | Тема |
|---|---|
| ADR-063 | Owner Control Agent: scope definition, holding mapping, observer-only role, FCA non-regulated channel |
| ADR-064 | Owner Control Agent: data minimisation contract (no-PII aggregation, ClaudeInput schema) |
| ADR-065 | Owner Control Agent: Google Sheets + Apps Script pipeline (trigger, Properties Service, security) |
| ADR-066 | Owner Control Agent: approved AI-plane channel (DPA, EU-managed Claude / Bedrock-EU, forbidden ad-hoc accounts) |
| ADR-067 | Owner Control Agent: KPI thresholds + escalation routing (safeguarding 0-tolerance, FCA deadline alerts) |
| ADR-068 | Owner Control Agent: multi-entity extension (TOMPAY + NEURONEXT + future entities under BANXE.COM) |
| ADR-069 | Owner Control Agent: daily/weekly/monthly report cadence + owner workflow protocol |

---

## 10. Pending Invariant Proposals (без правки INVARIANTS.md)

| ID | Формулировка | ADR для формализации |
|---|---|---|
| **I-45** | Owner Control Agent processes only aggregated, non-PII KPIs from TOMPAY/NEURONEXT; raw PII (names, IBAN, addresses, passports, MRZ, biometrics, transaction-level data with client identifiers, SAR-narrative) never leaves the corporate boundary via ClaudeInput | ADR-064 |
| **I-46** | Owner Control Agent uses approved external LLM channel (Claude.ai with DPA, or EU-managed Claude / Bedrock-EU); ad-hoc personal accounts are forbidden for production data | ADR-066 |
| **I-47** | Holding mapping: BANXE.COM (holding) contains TOMPAY LTD (FCA EMI) + NEURONEXT (CASP/VASP); Owner Control Agent is observer-only and does not modify operations, write to client systems, substitute MLRO/Compliance decisions, or serve as FCA/EBA reporting channel | ADR-063 |

---

## 11. Якоря для продолжения

- **Базовый тег:** `checkpoint-2026-05-06-oss-sumsub-replacement-block`
- **Новый тег после merge:** `checkpoint-2026-05-06-owner-control-agent-block`

### Возможные следующие шаги (отдельные треки)

| Трек | Содержание | Зависимость |
|---|---|---|
| ADR-063 | Formal scope definition + observer-only policy | Legal/Compliance + MLRO sign-off |
| ADR-064 | ClaudeInput schema: no-PII contract + validation rule | DPO approval |
| ADR-065 | Apps Script security review (Properties Service, trigger, access control) | Security Engineering |
| ADR-066 | Approved AI-plane: DPA with Anthropic / Bedrock-EU setup | Legal + IT |
| ADR-067 | KPI thresholds formalization + Safeguarding 0-tolerance SLA | Risk / MLRO |
| Deploy | Google Sheets workbook creation + Apps Script deployment + Claude Project setup | ADR-063/064/066 accepted |
| Нумерация коллизия | DAC8 ADR-045..049 vs DeFi ADR-045..050 — согласование до создания любого ADR | Operator / architecture sign-off |
| Pending legal review | DPA с Anthropic, approved AI-plane channel, PII boundary validation | Legal & Privacy (DPO) |
