# BANXE AI Bank — Наложение на эталонную структуру UK EMI: полная карта покрытия, пробелов и приоритетов восполнения

## Executive Summary

По состоянию на апрель 2026 года архитектура BANXE AI Bank (версия SERVICE-MAP.md 2026-04-05) покрывает приблизительно **30–35% полного функционального периметра** эталонной UK EMI. При этом распределение покрытия крайне неравномерно: **Compliance/AML-блок реализован на уровне 55–70%** — существенно выше отраслевого стандарта для стартапа данной стадии; однако **платёжные рельсы (0%), Treasury/ALM (0%) и Core Banking Engine (~5%)** полностью отсутствуют — без них EMI операционно не может существовать.

Структура BANXE «4 человека + 9 AI-агентов + 3 LLM-модели» является принципиально новаторской: она замещает операционный персонал (20–50 человек в обычном EMI) автономными агентами с формализованными паспортами, governance-инвариантами и чётко разграниченными уровнями доверия. Это конкурентное преимущество. Одновременно это означает, что ряд ролей, обязательных по FCA, пока не замещён ни человеком, ни агентом.[^1][^2]

***

## Раздел 1. Методология наложения

Эталонная структура UK EMI, принятая как основа, охватывает девять функциональных блоков (A–I): клиентский онбординг, продуктовый каталог, платёжные рельсы, core banking, treasury/ALM, compliance & risk, fraud prevention, customer operations и technology infrastructure. Анализ проводится поблочно: для каждого блока указывается, что в BANXE уже реализовано, что частично, и что полностью отсутствует — с привязкой к конкретным агентам, сервисам и ролям из текущей архитектуры.[^3][^4][^2]

***

## Раздел 2. Полная карта покрытия по блокам

### Блок A: Клиентский Онбординг (Remote) — Покрытие ~30%

**Что реализовано:**
- Risk scoring при онбординге: `sanctions_check` (Cat A/Cat B классификация клиентов), `tx_monitor` (velocity rules), `qwen3-banxe-v2` с ролью `kyc`[^5]
- Sanctions & PEP проверка: `yente_adapter` (OpenSanctions, 200K+ entities, PEP-screening) + `watchman_adapter` (Moov Watchman, minMatch=0.80 Jaro-Winkler)[^6]
- Enhanced DD trigger: `sanctions_check` Cat B → EDD/HOLD для 30+ юрисдикций
- PII защита при обработке: Presidio PII Proxy (:8089)[^7]

**Что частично реализовано:**
- CDD workflow: Compliance AI-агенты и Marble (:5003) позволяют управлять кейсами, но полный CDD-flow (сбор документов, верификация, решение) не описан явно в архитектуре

**Что отсутствует:**
- Верификация документов (Document OCR/IDV): нет интеграции с Onfido, Sumsub, Jumio или аналогами[^5]
- Биометрическая liveness-проверка
- NFC-чтение документов (ICAO 9303)
- KYB (Know Your Business) для юридических лиц: UBO-цепочка, Companies House API — не упоминается
- FATCA/CRS Self-certification при онбординге[^5]
- Account Agreement workflow (электронная подпись T&C)
- Customer portal / мобильное приложение для клиента

**[ВЫВОД] Требуемое восполнение — P1**: Интеграция IDV-провайдера (Sumsub рекомендован для UK/EU, есть sandbox API), KYB-верификация через Companies House API (бесплатный), FATCA self-certification форма.

***

### Блок B: Продуктовый Каталог — Покрытие ~10%

**Что частично реализовано:**
- PostgreSQL (:5432) существует — вероятно, хранит базовые данные аккаунтов
- `glm-4.7-flash-abliterated` имеет роль `client-service` — подразумевает обслуживание клиентов по продуктам

**Что отсутствует:**
- Определённый продуктовый каталог (счета, мультивалютные кошельки, FX, переводы, карты)
- Fee schedule (тарифная сетка): без неё невозможно исполнение Consumer Duty[^8]
- Карточные продукты: виртуальные/физические карты, BIN sponsorship
- FX engine / rate management
- Open Banking (PIS/AIS)

**[ВЫВОД] Требуемое восполнение — P1/P2**: Описать продуктовый каталог как ADR (banxe-architecture/decisions/). Минимальный MVP: e-money GBP account + FPS payments. Карты — следующий этап через BIN sponsor.

***

### Блок C: Платёжные Рельсы — Покрытие **0%** ⛔

Это наиболее критический пробел. В текущей архитектуре BANXE **не упоминается ни один платёжный рельс** — ни FPS, ни CHAPS, ни SEPA, ни SWIFT. EMI, которая не может двигать деньги, функционально не является EMI.[^9][^10]

**Что отсутствует полностью:**
- FPS (UK Faster Payments): мгновенные GBP-переводы, 24/7, лимит £1M[^9]
- CHAPS: крупные GBP-переводы (same-day)[^10]
- BACS: прямые дебеты, зарплатные пробеги (3-day)[^9]
- SEPA SCT / SEPA Instant: EUR-переводы для европейских клиентов[^11]
- SWIFT/MT и SWIFT GPI: международные переводы[^12]
- Карточные схемы (Visa/Mastercard): авторизация, клиринг, расчёты

**[ВЫВОД] Требуемое восполнение — P0 (доLaunch)**: Выбор BaaS-провайдера для платёжных рельсов. Рекомендация: **ClearBank** (прямой доступ к FPS, CHAPS, BACS, SEPA через BaaS API) или **Banking Circle** (FPS + SEPA + IBANs как сервис). Без этого шага EMI не может быть авторизована FCA.[^13]

***

### Блок D: Core Banking Engine — Покрытие ~5%

**Что реализовано (инфраструктура):**
- PostgreSQL (:5432): реляционная БД — потенциальная основа для CBS[^14]
- ClickHouse (:9000): append-only audit trail (DORA compliance, TTL 5 лет) — аналитика/аудит
- Redis (:6379): velocity tracking — используется в `tx_monitor`
- n8n (:5678): workflow automation

**Что отсутствует:**
- Двойная запись (Double-entry general ledger): не упоминается нигде
- Account lifecycle management (open → active → dormant → closed)
- Interest calculation engine
- Fee & charges engine (linked to product catalog)
- Balance management (available vs. ledger vs. pending)
- Reconciliation engine (internal GL ↔ external rails ↔ schemes)[^15]
- Financial reporting (P&L, balance sheet для FCA FIN-RPT)

**[ВЫВОД] Требуемое восполнение — P0**: Выбрать CBS. Варианты: **Apache Fineract** (open-source, бесплатно, активное community, используется Ко- и Revolut-клонами) или **Mambu/Unit** (SaaS BaaS, быстрый запуск). На базе PostgreSQL можно построить минимальный proprietary ledger-сервис с event sourcing — это согласуется с ADR-07 архитектурой BANXE.

***

### Блок E: Treasury & ALM — Покрытие **0%** ⛔

**Что отсутствует:**
- Safeguarding Engine: ежедневная сверка выпущенных e-money vs. остатков на safeguarding счетах. Нарушение = немедленный enforcement FCA[^4][^3]
- Liquidity management dashboard
- FX position management
- Capital adequacy monitoring (2% от объёма e-money)[^4]
- ALCO function
- Safeguarding annual report для FCA (REP017)

**[ВЫВОД] Требуемое восполнение — P0**: Safeguarding reconciliation — первейшее требование EMR Regulation 21. Минимально: daily cron-задача, которая сравнивает сумму outstanding e-money (из CBS) с остатком на safeguarding-счёте (bank API). Отклонение = alert + автоматическое уведомление MLRO.[^3]

***

### Блок F: Compliance & Risk — Покрытие ~55–70% ✅ (сильная сторона)

Это блок, в котором BANXE значительно превосходит отраслевой стандарт для стартапа.

**Что реализовано полностью или частично:**

| Функция | Агент/Компонент | Статус |
|---|---|---|
| AML Transaction Monitoring | `tx_monitor` v2.1.0 (9 правил + Redis) | ✅ |
| Sanctions Screening | `sanctions_check` v2.0.0 (OFAC, HMT, UN) | ✅ |
| PEP Screening | `yente_adapter` (OpenSanctions) | ✅ |
| ML Transaction Scoring | `jube_adapter` v1.0.0 (Jube AGPLv3) | ✅ |
| Crypto AML | `crypto_aml` v1.2.0 (darknet, mixer) | ✅ |
| SAR Workflow | MLRO-оператор + Marble :5003 | ✅ |
| Audit Trail | `clickhouse_writer` (append-only, 5 лет) | ✅ |
| HITL / Human Override | MLRO-оператор (Telegram + Marble) | ✅ |
| ExplanationBundle | Инвариант I-25 (обязателен >£10K) | ✅ |
| PII Protection | Presidio PII Proxy (:8089) | ✅ |
| Emergency Stop | Инвариант I-23 (проверка перед каждым решением) | ✅ |
| Governance Invariants | I-21 через I-25 | ✅ |

**Что частично реализовано:**
- Consumer Duty Programme: `compliance AI-agents` существуют, но явного outcomes monitoring MI не описано[^8]
- Compliance Monitoring Programme (CMP): не описан явно

**Что отсутствует:**
- Complaints Handling (DISP): нет complaints workflow, нет 8-week SLA management, нет FOS-escalation процесса[^16][^17]
- FATCA/CRS reporting engine: нет упоминания[^5]
- PCI DSS compliance programme: нет (необходимо при выпуске карт)
- Annual FCA Regulatory Reporting automation (FIN-RPT): нет

**[ВЫВОД] Восполнение — P2**: Добавить complaints management (Zendesk или n8n workflow с DISP-таймерами). FATCA/CRS: добавить self-certification при онбординге + ежегодный HMRC-отчёт.

***

### Блок G: Fraud Prevention — Покрытие ~15%

**Что реализовано частично:**
- `tx_monitor` включает velocity rules и structuring detection — это смежно с fraud, но это AML-функция, а не dedicated fraud scoring[^18][^6]

**Что отсутствует:**
- Real-time fraud scoring engine (pre-transaction, <100ms latency): нет
- Device fingerprinting и поведенческая биометрия: нет
- Account Takeover (ATO) prevention: нет
- 3DS authentication для карточных операций: нет
- APP (Authorised Push Payment) scam detection: нет — при том, что PSR обязывает возмещать жертвам APP-мошенничества с октября 2024[^19]
- Chargeback & dispute management: нет

**[ВЫВОД] Требуемое восполнение — P1**: При наличии платёжных рельсов fraud layer необходим немедленно. Рекомендуется Sardine (API-first, pre-transaction scoring) или Featurespace ARIC. Отдельно от AML-pipeline.

***

### Блок H: Customer Operations — Покрытие ~20%

**Что реализовано:**
- L1 поддержка: `glm-4.7-flash-abliterated` имеет роль `client-service` — AI-первая линия
- KYC Ops: MLRO-оператор через Marble :5003 — review кейсов
- Операционные коммуникации: Telegram-бот `@mycarmi_moa_bot` для HITL

**Что отсутствует:**
- L2/L3 support с SLA-трекингом (DISP-таймеры)[^16]
- Payments investigations workflow (SWIFT recall, FPS recall)
- Reconciliation Ops (manual breaks)
- Card operations (если карты будут)
- Явный escalation-процесс от AI-агента к человеку (описан в governance, но не в ops workflow)

**[ВЫВОД] Восполнение — P2/P3**: На ранних этапах AI-первая поддержка достаточна. Критично: добавить DISP-compliant complaints tracking перед запуском.

***

### Блок I: Technology & Infrastructure — Покрытие ~50%

**Что реализовано:**

| Компонент | Реализация | Статус |
|---|---|---|
| LLM Inference | Ollama + Qwen3/GLM/GPT-OSS | ✅ |
| Case Management | Marble :5002-5003 | ✅ |
| ML Scoring | Jube :5001 | ✅ |
| Audit Storage | ClickHouse :9000 (append-only) | ✅ |
| Cache/Velocity | Redis :6379 | ✅ |
| Relational DB | PostgreSQL :5432 | ✅ |
| Compliance API | FastAPI :8090 | ✅ |
| PII Anonymisation | Presidio :8089 | ✅ |
| Workflow Automation | n8n :5678 | ✅ |
| Sanctions Feed | Watchman :8084 + Yente | ✅ |
| Agent Monitoring | Cron evals + promptfoo | ✅ |
| HITL Terminal | Telegram bot :18789 | ✅ |

**Что отсутствует:**
- **Event Streaming** (Kafka/Pulsar): нет — необходим для платёжных событий и audit event log[^15]
- **API Gateway** (Kong, AWS API GW): нет — необходим для внешних партнёрских интеграций и BaaS-API
- **Secrets Management** (HashiCorp Vault): нет — критично при ZSP/JIT подходе[^20]
- **Service Mesh** (Istio/Linkerd): нет — mTLS между сервисами не упомянут
- **Kafka/CDC** для real-time payment events: нет
- **HSM** (Hardware Security Module): нет — необходим для карточных операций (PIN encryption)
- Disaster Recovery / BCP: не описаны (single server = single point of failure)

**[ВЫВОД] Восполнение**: Kafka — P1 при добавлении payment rails. Vault — P1 при ZSP-режиме. API Gateway — P2. Single server → DR — P2 (добавить AWS/GCP replicated backup минимум).

***

### Governance Structure — Покрытие ~40%

**Что реализовано:**

| Роль/Функция | Статус | Примечание |
|---|---|---|
| CEO (SMF1) | ✅ Moriel Carmi | |
| DEVELOPER/CTIO | ✅ Oleg | Не SMF, но критическая роль |
| MLRO (SMF17) | ⚠️ TBD | Позиция обозначена, не заполнена |
| Agent Passports | ✅ banxe-architecture/agents/passports/ | Уникальная практика |
| ADR Process | ✅ banxe-architecture/decisions/ | Excellent governance |
| Change Classification | ✅ CLASS_A/CLASS_B | |
| Governance Invariants | ✅ I-21 — I-25 | Strong |
| Three Lines (conceptual) | ⚠️ | Концептуально реализован |

**Что отсутствует:**
- CFO (SMF2): не назначен — требование FCA SMCR[^2]
- CRO (SMF4): не назначен[^21]
- CCO (SMF16): не назначен[^22]
- Board of Directors: не описан
- Audit Committee / Risk Committee: не описаны
- Internal Audit function: отсутствует
- SMF FCA Registration: не упомянута (обязательна до авторизации)[^23][^2]
- FCA Supervisory contact procedure: не описана

**[ВЫВОД] Требуемое восполнение — P0**: Назначение MLRO (TBD → конкретная персона), CFO, CCO — обязательное условие FCA авторизации. Могут быть outsourced (Interim MLRO services через специализированных провайдеров в UK).

***

## Раздел 3. Интегральная таблица покрытия

| Функциональный блок | Эталон | BANXE текущий | Покрытие | Приоритет |
|---|---|---|---|---|
| Governance & SMF roles | Обязательно FCA[^2] | CEO ✅, MLRO ⚠️ TBD, CCO/CRO/CFO ❌ | 40% | P0 |
| Remote KYC Onboarding | Обязательно | Screening ✅, IDV/biometric ❌, KYB ❌ | 30% | P1 |
| AML / Sanctions / TM | Обязательно | Полный агентный стек ✅ | 70% | — |
| SAR Workflow | Обязательно | MLRO + Marble ✅ | 80% | — |
| Fraud Prevention | Обязательно | Velocity rules ⚠️, dedicated engine ❌ | 15% | P1 |
| Consumer Duty / DISP | Обязательно FCA[^8] | Agents ⚠️, complaints flow ❌ | 20% | P1 |
| Core Banking / Ledger | Обязательно | DB infra ✅, GL logic ❌ | 5% | P0 |
| Payment Rails (FPS/SEPA/SWIFT) | Обязательно[^9] | ❌ полностью отсутствует | 0% | P0 |
| Safeguarding Engine | Обязательно EMR[^3] | ❌ полностью отсутствует | 0% | P0 |
| Treasury / ALM | Обязательно[^24] | ❌ полностью отсутствует | 0% | P0 |
| Product Catalog | Необходимо | Implied, not defined | 10% | P1 |
| Customer Interface (App) | Необходимо | AI support agent ⚠️, UI ❌ | 15% | P1 |
| FATCA / CRS Reporting | Обязательно[^5] | ❌ | 0% | P2 |
| PCI DSS (карты) | При картах | ❌ | 0% | P2 |
| Technology: Payment infra | Обязательно | Kafka ❌, API GW ❌, HSM ❌ | 30% | P1 |
| Technology: AI infra | Best practice | Полностью ✅ | 95% | — |
| Audit Trail | Обязательно DORA | ClickHouse append-only ✅ | 90% | — |

***

## Раздел 4. Приоритизированный план восполнения

### Phase 0 — Pre-launch (до FCA авторизации)
Без этих шагов авторизация невозможна:

1. **Назначить и зарегистрировать SMF-holders в FCA Connect**:[^2]
   - MLRO (SMF17) — назначить конкретного человека (можно outsourced interim MLRO)
   - CCO (SMF16) — compliance oversight function
   - CFO (SMF2) — financial function
   - CRO (SMF4) — risk function
   - CEO (SMF1) — Moriel Carmi ✅ уже есть

2. **Выбрать BaaS-провайдера для платёжных рельсов**:
   - ClearBank (FPS, CHAPS, BACS) или Modulr (FPS + SEPA) — BaaS API-first[^10][^9]
   - Срок подключения: 4–12 недель при наличии авторизованной EMI

3. **Core Banking System**:
   - Выбор: Apache Fineract (open-source) или Mambu (SaaS) для speed-to-market
   - Минимум: double-entry ledger + account lifecycle + balance management[^14]

4. **Safeguarding Engine**:
   - Открыть safeguarding account у Barclays/HSBC[^3]
   - Автоматизировать daily reconciliation (cron-задача: outstanding e-money vs. safeguarding balance = alert при gap)[^4]

### Phase 1 — Launch MVP (месяцы 1–3)
5. **IDV Integration**: Sumsub или Onfido (sandbox → production для KYC document verification + liveness)
6. **Customer App**: минимальный web-portal (React) с onboarding flow, account view, payment initiation
7. **Fraud Prevention Layer**: Sardine.ai или Featurespace ARIC (API-интеграция, отдельно от AML)
8. **Complaints Workflow**: n8n-based DISP flow (intake → 8-week timer → FOS escalation)[^16]
9. **Kafka/Event Streaming**: добавить для payment events и audit event log[^15]

### Phase 2 — Growth (месяцы 4–6)
10. **SEPA / EUR payments**: Banking Circle или SEPA direct membership (через BaaS partner)
11. **FX Engine**: LD Micro FX или внутренний rate management + hedging через IB API
12. **Treasury Dashboard**: ALCO MI — liquidity monitoring, FX positions, safeguarding report
13. **FATCA/CRS**: self-certification при онбординге + HMRC annual reporting automation
14. **API Gateway**: Kong или AWS API GW (rate limiting, OAuth2, developer portal)[^15]

### Phase 3 — Scale (месяцы 7–12)
15. **Cards**: BIN sponsor (Monavate) + virtual/physical cards + 3DS
16. **PCI DSS**: QSA assessment, CDE mapping
17. **Open Banking**: OBIE registration, PIS/AIS API
18. **Internal Audit**: outsourced IA (quarterly, FCA-ready)
19. **DR/BCP**: переезд с single GMKtec на cloud-replicated setup (AWS/GCP active-passive)[^25]
20. **Secrets Management (Vault)**: замена env-файлов на HashiCorp Vault с JIT scoping[^20]

***

## Раздел 5. Уникальные преимущества текущей архитектуры BANXE

Несмотря на значительные пробелы в банковских функциях, BANXE имеет несколько компонентов, которые **превосходят** стандарты отрасли и потребовали бы 2–4 лет для построения в традиционном EMI:

**1. Формализованные Agent Passports** — версионированные YAML-паспорта для каждого агента с zone, change_class, capabilities — это то, что KPMG называет «agent passports» как will-be standard, а BANXE уже реализовал.[^26]

**2. Governance Invariants (I-21 — I-25)** — неизменяемые правила поведения системы (emergency stop перед каждым решением, ExplanationBundle >£10K, append-only audit) — это программно-закреплённый compliance, недостижимый в ручных процессах.[^25]

**3. ExplanationBundle** — обязательное объяснение решений >£10K — соответствует требованиям FCA SS1/23 об объяснимости AI-решений в финансовых сервисах, которые многие банки пока не выполняют.[^27][^28]

**4. Adversarial Simulations (weekly cron)** + **promptfoo evaluations** — автоматическое red-teaming compliance-системы еженедельно. Это enterprise-grade QA, которого нет ни в одном из рассмотренных open-source решений (Ballerine, Marble, Jube).

**5. PII Proxy Presidio** как обязательный слой перед внешними LLM — явно размеченный как «mandatory for FCA/GDPR» — является правильным архитектурным решением, которое большинство AI-финтех-стартапов реализует постфактум после regulatory inquiry.[^29]

**6. Append-only ClickHouse audit trail с TTL 5 лет** — напрямую соответствует DORA Art. 14(2) о неизменяемости аудиторских записей, что является P1-требованием для AI-систем в финансовых сервисах.[^25]

***

## Итоговая оценка

BANXE AI Bank построен «снаружи внутрь»: сначала — самый сложный compliance-мозг, затем — операционное тело. Это нетипичная, но стратегически обоснованная последовательность для AI-first стартапа: compliance — это дифференциатор, banking operations — это commodity, которую можно получить через BaaS. Следующие 6 месяцев определяют, сможет ли проект трансформироваться из **AI compliance engine** в **полнофункциональный EMI** с реальными клиентами и движением денег.

---

## References

1. [Implementing the Three Lines Model in Neobanks - LinkedIn](https://www.linkedin.com/pulse/implementing-three-lines-model-neobanks-flamur-abdyli-87hce) - Key Roles in the Three Line of Defence Model. The Governing Body. Accepts accountability for organiz...

2. [Senior Managers Regime - FCA](https://www.fca.org.uk/firms/senior-managers-and-certification-regime/senior-managers-regime) - The most senior people in a firm who perform key roles (Senior Management Functions or SMFs) need FC...

3. [[PDF] E-Money - Prudential Supervision, Oversight, and User Protection](https://www.imf.org/-/media/files/publications/dp/2021/english/empsoupea.pdf) - Materialization of operational, business, and investment risks: EMIs will be exposed to several oper...

4. [What is EMI? A Guide to Digital Finance - InvestGlass](https://www.investglass.com/explaining-what-is-emi-electronic-money-institution-navigating-digital-finance/) - EMIs operate primarily online, allowing for fully remote onboarding and making their services more a...

5. [Core Banking ERP Part 3 – Clients, Onboarding, Risk & Compliance](https://clefincode.com/blog/global-digital-vibes/en/core-banking-erp-part-3-clients-onboarding-risk-compliance) - Modern core banking platforms must seamlessly integrate client management, onboarding, risk manageme...

6. [Neobank AML Compliance: How Digital Banks Can Balance ...](https://kyc-chain.com/neobank-aml-compliance-how-digital-banks-can-balance-innovation-regulation-and-trust/) - This article lays the groundwork for our exploration of how neobanks can balance innovation and anti...

7. [Neobank Compliance Requirements: A Practical Guide (2026)](https://www.canarie.ai/blog/neobank-compliance-requirements-guide) - Regulatory compliance requirements for neobanks and BaaS-powered fintechs. Covers BSA/AML, sponsor b...

8. [The New FCA Consumer Duty Rules: Best 101 Summary for EMIs ...](https://psplab.com/the-new-fca-consumer-duty-rules-summary/) - The ultimate summary of the new FCA Consumer Duty for payment and e-money firms explaining consumer ...

9. [Types of UK bank transfer systems: Bacs, FPS, CHAPS explained](https://polygon.technology/learn/payment/types-of-uk-bank-transfer-systems-bacs-fps-chaps-explained) - Learn types of UK bank transfer systems (Bacs, FPS, CHAPS) and cross-border GBP payments—plus where ...

10. [Payment schemes in the UK: CHAPS, BACS, FPS explained | Mambu](https://mambu.com/en/insights/articles/uk-payment-schemes) - In this article, we explore the UK local payment schemes function and how they compare to the equiva...

11. [Payment Schemes: Global Guide to SEPA, FPS, Pix, UPI,...](https://www.openbankingtracker.com/payment-schemes) - Your complete guide to payment schemes worldwide, from instant payment systems like SEPA Instant, Fa...

12. [Global Payment Rails Explained: SWIFT, SEPA, ACH, Faster ...](https://www.linkedin.com/pulse/global-payment-rails-explained-swift-sepa-ach-faster-payments-kumar-zclsc) - Every international payment travels through a rail. Most business owners have no idea which rail the...

13. [[PDF] A Guide to Supervising E-Money Issuers - CGAP](https://www.cgap.org/sites/default/files/publications/Technical-Guide-EMI-Supervision-Dec-2018.pdf) - Risk of loss or misuse of customer funds (covered in paper). This is the risk that (i) EMI employees...

14. [Core Banking Solution: How to Choose the Right One? - Baseella](https://baseella.com/core-banking-solution-how-to-choose-the-right-one/) - Payment gateways, KYC modules, fraud detection services, and other API-connected components all intr...

15. [Core Banking ERP Part 4 – Payments, Treasury, Multi-Branch ...](https://clefincode.com/blog/global-digital-vibes/en/core-banking-erp-part-4-payments-treasury-multi-branch-multi-currency) - Open Banking APIs (OAuth2, PSD2/OBIE): In a fully digital bank ... completes KYC and is active – pre...

16. [DISP 1.10B Payment services and electronic money complaints ...](https://handbook.fca.org.uk/handbook/DISP/1/10B.html) - Once a year a credit institution that provides payment services or issues electronic money must prov...

17. [DISP 1.3 Complaints handling rules - FCA Handbook](https://handbook.fca.org.uk/handbook/DISP/1/3.html) - Effective and transparent procedures for the reasonable and prompt handling of complaints must be es...

18. [How community banks use AI to prevent fraud and comply - LinkedIn](https://www.linkedin.com/posts/york-public-relations_aiinbanking-communitybanks-compliance-activity-7328479280772923394-ukJ2) - Community financial institutions face unprecedented challenges in fraud prevention and compliance, u...

19. [[PDF] Decision Reference DRN-4993418 - Financial Ombudsman Service](https://www.financial-ombudsman.org.uk/decision/DRN-4993418.pdf) - I am satisfied that, to comply with regulatory requirements (including the Financial Conduct. Author...

20. [How autonomous AI agents like OpenClaw are reshaping enterprise ...](https://www.cyberark.com/resources/blog/how-autonomous-ai-agents-like-openclaw-are-reshaping-enterprise-identity-security) - By enforcing modern identity security controls like zero standing privileges, using secrets manageme...

21. [SMCR Compliance Recruitment | SMF Roles - FD Capital](https://www.fdcapital.co.uk/smcr-compliance-recruitment/) - We place fractional and interim CFOs, MLROs, CROs and compliance leaders across FCA senior managemen...

22. [Structuring the compliance function](https://compliance.waystone.com/structuring-the-compliance-function/) - A well-structured compliance function is crucial for any financial institution. Learn which structur...

23. [Senior management functions - FCA](https://www.fca.org.uk/firms/approved-persons/senior-management-functions) - Senior management functions (SMFs) are a type of controlled function. SMFs are held by a firm's most...

24. [MXGO Solution Neobanks IBSi Article - Murex](https://www.murex.com/en/insights/article/neobanks-proliferate-and-grow-their-treasury-departments-face-critical-demands) - MXGO is built for rapidly expanding banks seeking opportunities from new technologies. MXGO covers t...

25. [Audit Trail Compliance: Requirements for Financial Services](https://matproof.com/blog/audit-trail-compliance-requirements) - A good practice is to set up a governance structure that oversees the audit trail process. This incl...

26. [[PDF] The Future of AI Governance - KPMG agentic corporate services](https://assets.kpmg.com/content/dam/kpmgsites/ae/pdf/the-future-of-ai-governance.pdf.coredownload.inline.pdf) - Create “agent passports” to track evolution, authority levels, and decisions. Embed agents into exis...

27. [Explainable AI in Compliance: Key Use Cases](https://www.lucid.now/blog/explainable-ai-compliance-use-cases/) - How XAI makes AI decisions auditable and transparent for fraud, AML, KYC and credit, aligning with G...

28. [Explainable AI in Finance - CFA Institute Research and Policy Center](https://rpc.cfainstitute.org/research/reports/2025/explainable-ai-in-finance) - Regulatory compliance and risk management: Regulators require clear explanations for AI-driven finan...

29. [Banxe-AI-agents-architecture.pdf](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/101434432/27e51362-c171-40be-bf42-ec896563b2c1/Banxe-AI-agents-architecture.pdf?AWSAccessKeyId=ASIA2F3EMEYE6RON6J7R&Signature=gBxNdWlRW2L9XaQcKUWhCg%2FlpZg%3D&x-amz-security-token=IQoJb3JpZ2luX2VjEAAaCXVzLWVhc3QtMSJHMEUCIGlRCTjZLs96klMwiodmHmHCvStFUm8Veq5o4GXTpLl8AiEA663YYkdnii8TErq4b1N81Xi848j29Y%2BHy16y7QYHBr0q%2FAQIyf%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARABGgw2OTk3NTMzMDk3MDUiDGRShk2Uey32x%2FI4NCrQBIFkVcvEB7XOvSaNtBEiSeSfgnL0AwYiOvfKOI%2FtMr1FrrgQA89NrF5iOIDiu5iVviyqmjWx811%2BTGhH06HOEp812r8ypy8BLeyR1eHeaTBwW5p4hIDX2GQRf8svzYU%2FTdgq3MEYibikJmQfuffpOs7jcdHuQFbLaO2zUr886JN6%2BntxltlkRTcHGWIsnbQsWoj6cTm8AtkTGujxwc11Da%2FDMMmUgkElwnYFfQoFGv62zEOkZNzJdW6GUijrgBwBB5ph%2BfUiwKzAgC%2FPn6lNXv6GoCHWbjVP%2BY4s2NtNvBhdRGARWqzTX%2F9w3SCyz6oOpK%2BCfK5M4DPOg9LL8gSvMyipk1DKVEHSxHikXFcbHqfU1%2Boz9t%2BIpQgYVa4FJjqkGazdvKPTX%2F4WgovugWIQKM%2B3FJaO1wuAFa6GDolNjhMhoAq8istAjGyUHqi4%2FbQw6yv17cLy7xaISPtxnitl8DltAmKaW%2F4I5KEAiBZe%2Bc72t2Y6YSuWYcFJfGNNQzCgVbR%2B4F8qCnyKOc0Hc42l3Nf3ZjlTLog9ZenBqHIotmmRRQd33jJBDthtGn0CFCohC3Pi6iFMkRRKp4R13vLModsecJRLu9tGkWJeR7ksVZ5YIxjHIjYB%2BmdxRuVNS36oVx%2Bie54tRMb2M8M9PfqfRl9ZvOQWJ8OeS9tvzuDVnd9bELC0BHyCoFoech4dXmAKY7PJ7AYwIYrEA%2BUmE0r73K2lRCM4fc4gz7pf68FhAB%2B4YrMD4ueDcu0B%2FtJooaUvMjJhjcMdOJzhGtxKUMiTVK4wgsbNzgY6mAFApfIxkG1tQF0X3IMq74%2FBEfgLVmMlKVLxFrxEqf2H9BtfoHgYO02WxdCGts9IUyDBH5OPTdc1sKTkboJTaErIFyWlPeK7hBzxFZKNZw2oPt4e0%2Fx5sqmEJvaYym0kyACXsgwQDLByhccuipTGY9r77PHKP%2F0X3K5HRrILTepgDXPEFfHYRTuJQ1pREQ%2BZTlHcU%2F1maZdY5g%3D%3D&Expires=1775464661) - Corporate IT-infrastructure
Agents observabitily 
(Lunari.ai) (data sets, 
evaluations)
AML AI-agent...

