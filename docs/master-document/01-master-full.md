# BANXE AI Bank — Мастер-документ: Полная Архитектура UK EMI на Open-Source Стеке

**Версия:** 3.0 (финальная компиляция) | **Дата:** Апрель 2026  
**Статус:** Единый согласованный документ — компиляция из трёх источников  
**Область применения:** Замена Geniusto [GO] Suite, FCA UK EMI авторизация, AI-агентная операционная модель

***

## Executive Summary

Проект **Banxe AI Bank** строит EMI (Electronic Money Institution) нового поколения, где основными «сотрудниками» являются AI-агенты с людьми-дублёрами в роли HITL-надзора. Цель — заменить проприетарный Geniusto [GO] Suite на composable open-source стек.[^1]

По состоянию на апрель 2026 года текущая архитектура Banxe покрывает приблизительно **30–35% полного функционального периметра** эталонной UK EMI: Compliance/AML-блок реализован на уровне 55–70% — существенно выше отраслевого стандарта — однако **платёжные рельсы (0%), Treasury/ALM (0%) и Core Banking Engine (~5%)** полностью отсутствуют, без них EMI операционно не может существовать.[^2]

**Единое решение CBS-иерархии:**
- **PRIMARY CBS/Ledger:** Midaz (LerianStudio) — AI-native, Apache 2.0, Go, event-driven, cloud-native[^3]
- **FALLBACK CBS:** Apache Fineract — если потребуются loan products или более зрелая community[^1]
- **PROGRAMMABLE LEDGER:** Formance Ledger — для сложных split-payment, marketplace, FX-flow[^3]
- **Geniusto GO Suite** — заменяемая система с идентифицированными структурными ограничениями[^1]

Анализ FINOS 2025 State of Open Source in Financial Services показывает, что открытые стандарты, open-source модели и фреймворки имеют наибольшее влияние на развитие AI в финансовом секторе (56%, 54% и 52% соответственно).[^4][^3]

***

## Раздел 1. Контекст: Что такое Banxe и чем является EMI

**Banxe** работает как дистрибьютор TomPay Ltd — FCA-regulated EMI, предоставляя клиентам счета с IBAN, SEPA/SWIFT переводы, 350+ криптовалютных кошельков и мультивалютные операции.[^1]

**EMI (Electronic Money Institution)** — регуляторная категория, позволяющая выпускать электронные деньги и предоставлять платёжные услуги без полной банковской лицензии. Начальный капитал в ЕС — 350 000 EUR; 100% e-money обеспечивается реальными фиатными резервами.[^1]

### Обязательные функции АБС для EMI

| Функция | Обязательность | Примечание |
|---|---|---|
| Выпуск e-money (электронные кошельки) | ✅ Критично | Основа EMI |
| IBAN-счета, multi-currency | ✅ Критично | EUR, GBP, USD минимум |
| SEPA / SEPA Instant | ✅ Критично | Европейские переводы |
| SWIFT / cross-border | ✅ Критично | Международные платежи |
| KYC/KYB onboarding | ✅ Критично | Регуляторное требование FCA |
| AML / Transaction Monitoring | ✅ Критично | FATF, EMD2, MiCAR |
| Double-entry ledger + Reconciliation | ✅ Критично | Safeguarding (CASS 15) |
| Safeguarding Engine | ✅ Критично P0 | FCA PS25/12, вступает 7 мая 2026[^2] |
| Card management (debit/prepaid) | ✅ Важно | BIN sponsor (Monavate) |
| Crypto wallet (для Banxe) | ✅ Важно | 350+ крипто[^1] |
| Open Banking / PSD2 | ✅ Важно | Европейский рынок |
| Кредитование, ипотека | ❌ Не нужно для EMI | Банковские функции |

***

## Раздел 2. Geniusto [GO] Suite — Анализ заменяемой системы

### 2.1 История и клиенты

Geniusto International предоставила **[GO] Digital Banking Management Suite** компании Banxe Ltd (дистрибьютор TomPay Ltd); также обеспечила интеграцию TomPayment с Tribe Payments для card issuance. Geniusto в 2025 году присоединилась к SWIFT Partner Programme как Business Connect Enabler. Клиенты: Banxe (UK EMI, крипто+фиат), TomPayment (FCA-regulated EMI), Agribank Philippines, Transact Pro (Латвия), City of Riga (транспортная система).[^3][^1]

### 2.2 Архитектура [GO] Suite

[GO] Suite состоит из четырёх интегрированных модулей:[^1]

- **[GO] Core Banking** — облачный multi-tenant ledger, real-time отчётность, мультивалютность, автоматические проводки
- **[GO] Payments** — SWIFT, SEPA, ACH, cross-border оркестрация, 80+ нативных интеграций
- **[GO] Onboarding** — KYC/KYB с биометрией, liveness-checking, configurable risk scoring, case management
- **[GO] Omni-channel** — веб и мобильный банкинг, кастомизируемый frontend

**Технический слой:** REST API (Bifrost layer), микросервисная архитектура, OAuth 2.0/OpenAPI, PSD2/AISP/PISP compliant, PostgreSQL/Oracle/MS SQL.[^3][^1]

### 2.3 SWOT-анализ Geniusto для Banxe AI Bank

| | Плюсы | Минусы |
|---|---|---|
| **Strengths** | Proven EMI use case, PSD2, multi-entity, SWIFT+SEPA | Закрытый код, vendor lock-in |
| **Weaknesses** | Нет AI-native, нет MCP/agent integration | Высокая зависимость от вендора |
| **Opportunities** | — | Open-source стек превзошёл бы по гибкости |
| **Threats** | Pricing непрозрачный, customization дорогая | AI Bank требует глубокой интеграции |

### 2.4 Структурные ограничения Geniusto (причины замены)

- **Vendor lock-in:** закрытый код → невозможность прямой интеграции AI-агентных workflow в core logic[^3][^1]
- **Нет контроля над roadmap:** изменения платформы диктует вендор
- **Непрозрачный pricing:** custom-only[^3]
- **Ограниченная AI-native интеграция:** SaaS-архитектура несовместима с model-as-operator patterns и agentic orchestration
- **Отсутствие controllability над compliance workflows:** при FCA CASS 15 (7 мая 2026) банку нужна полная управляемость safeguarding reconciliation engine[^2][^3]
- Независимый анализ констатирует: Geniusto требует «significant expertise and training» и «may not fully cater to the complex requirements of larger, more diversified financial institutions»[^3]

***

## Раздел 3. Ландшафт Open-Source АБС: Полный Каталог

### 3.1 Midaz (LerianStudio) — PRIMARY CBS ⭐ [ВЫБРАН]

**Репозиторий:** `github.com/LerianStudio/midaz` | **Лицензия:** Apache 2.0

Midaz — open-source, cloud-native, immutable, multi-currency, multi-asset Core Ledger Application, разработанный LerianStudio (Бразилия, основан в 2024). Описывается как «first open-source core banking stack for the AI era»: AI-native (GenAI + real-time event publishing), battle-tested (N:N transactions, multi-currency, self-reconciliation).[^1][^3]

**Ключевые характеристики:**

| Параметр | Значение |
|---|---|
| Лицензия | Apache 2.0 — коммерчески свободно[^3] |
| Язык | Go (cloud-native, высокая производительность) |
| Архитектура | CQRS, Hexagonal, Event-Driven, Microservices[^3] |
| Double-entry | Нативный, N:N транзакции[^3] |
| Multi-currency | Нативный, multi-asset (fiat, crypto, loyalty)[^3] |
| Immutability | Нативная — все записи неизменны[^3] |
| AI-native | Да — real-time event publishing, GenAI интеграция[^3] |
| MCP Server | Прямая интеграция Claude, ChatGPT с banking API[^1] |
| Compliance | SOC-2, GDPR, PCI-DSS ready[^3] |
| SDK | Go, TypeScript[^3] |
| Deployment | Docker Compose / Kubernetes (Helm charts)[^3] |
| IaC | Terraform для AWS/GCP/Azure[^3] |
| Observability | OpenTelemetry + Grafana[^3] |

**Экосистема Lerian Studio:**

| Компонент | Назначение |
|---|---|
| **Midaz** | Core ledger, account management |
| **Tracer** | Real-time transaction validation, fraud prevention (<100ms) |
| **Matcher** | Transaction reconciliation, multi-source matching |
| **Reporter** | Async report generation (PDF, HTML, CSV) |
| **Flowker** | Workflow orchestration engine |
| **lerian-mcp-server** | AI assistant ↔ Banking API bridge[^1] |

**Почему Midaz — PRIMARY для Banxe AI Bank (а не Fineract):**

1. **Event-driven native:** каждая транзакция публикует событие — AI-агенты подписываются без polling[^3]
2. **Go vs Java:** cloud-native, меньше latency, меньше footprint для microservices
3. **CQRS pattern:** разделение command/query упрощает интеграцию AI-агентов как command handlers
4. **Immutable ledger нативно:** критично для DORA и FCA audit[^3]
5. **MCP Server:** прямой programmatic доступ AI к banking operations — фундаментальное требование AI Bank[^1]
6. **Designed for fintechs 2024+:** не перегружен legacy MFI-функциональностью Fineract
7. Для EMI loan modules не нужны — главное преимущество Fineract снято[^1]

**Честный анализ ограничений Midaz:**
- Основан в 2024 — меньше production deployments, чем у Fineract[^3]
- Нет встроенных loan/credit products (для EMI не критично)
- Нет built-in KYC, AML, payment connectors — требует модульной интеграции[^3]
- Community меньше, чем у Fineract или Formance

**Lerian привлекла ~$3M** для разработки «next open source stack for financial services»; для контекста — Formance одновременно подняла $21M на аналогичном открытом подходе.[^3]

***

### 3.2 Apache Fineract — FALLBACK CBS

**Репозиторий:** `github.com/apache/fineract` | **Лицензия:** Apache 2.0

Apache Fineract — наиболее зрелое open-source решение для core banking, используется в 80+ странах сотнями организаций; Java/Spring Boot, Docker/Kubernetes, REST API-first. Функционал: loans, savings, KYC support, double-entry accounting, multi-tenancy, flexible financial product configuration.[^1]

**Когда выбрать Fineract вместо Midaz:**
- Если потребуются встроенные loan products (кредитный портфель)
- Если нужна более широкая community поддержка
- Если команда лучше знает Java экосистему[^3]

**Mifos Payment Hub EE** (отдельный компонент): SEPA, UK Faster Payments, US FedNow, ISO 20022, MPL 2.0; признан Digital Public Good — применим при Mojaloop interoperability или сложной multi-rail orchestration.[^1][^3]

***

### 3.3 Formance Stack — PROGRAMMABLE MONEY-FLOW ОПЦИЯ

**Репозиторий:** `github.com/formancehq/ledger` | **Лицензия:** Apache 2.0 (ledger), open-core (stack)

Formance — open-source инфраструктура, финансируемая YC (2022). Ключевой компонент — **Numscript DSL**: встроенный язык программирования для моделирования движения денег. Atomic multi-postings транзакции, immutable log, pre-built use-case templates, 8.4M+ операций обработано.[^1]

**Formance Stack включает:** Ledger (double-entry, immutable), Payments (unified payments API), Reconciliation (balance verification против payment providers), Numscript VM.[^3]

**Когда выбрать Formance вместо Midaz:**
- Сложные split-payment, marketplace, FX-flow сценарии
- Приоритет — программируемость через DSL
- Crypto+fiat flows (350+ cryptocurrencies Banxe)[^1]

***

### 3.4 Blnk Finance — Developer-First Ledger

**Репозиторий:** `github.com/blnkfinance/blnk` | **Лицензия:** Apache 2.0

Production-grade double-entry ledger для быстрого запуска fintech продуктов (последнее обновление апрель 2026). Функции: balance monitoring, inflight transactions (резервирование средств), scheduling, overdrafts, bulk transactions, PII tokenization, **Blnk Watch** — DSL для real-time transaction monitoring rules. TypeScript SDK, Go SDK — хорошая интеграция с AI системами.[^1]

***

### 3.5 Дополнительные Open-Source CBS кандидаты

| Платформа | Лицензия | EMI-Ready | SEPA/SWIFT | AI-Ready | Применение |
|---|---|---|---|---|---|
| **Midaz** | Apache 2.0[^3] | ✅ Ledger | ❌ нужен hub | ⭐⭐⭐ MCP | PRIMARY CBS[^3] |
| **Formance** | Apache 2.0[^3] | ✅ Ledger | ❌ нужен hub | ⭐⭐ | Programmable flows[^1] |
| **Fineract** | Apache 2.0[^1] | ⚠️ Кастомизация | ✅ Payment Hub | ⭐ | FALLBACK CBS[^1] |
| **Blnk** | Apache 2.0[^1] | ✅ Ledger | ❌ нужен hub | ⭐⭐ | Developer-first option |
| **Moov.io** | Apache 2.0[^1] | ✅ Протоколы | ✅ ACH/wires | ⭐ | Payment protocols layer |
| **OBP-API** | AGPL[^1] | ✅ API Layer | ✅ PSD2/SEPA | ⭐ | Open Banking gateway |
| **Adorsys Ledgers** | Apache 2.0[^1] | ✅ ASPSP | ✅ SEPA | ⭐ | PSD2-compliant option |
| **OpenCBS Cloud** | GPL-3.0[^1] | ⚠️ MFI focus | ❌ | ⭐ | Not suitable for EMI |

***

## Раздел 4. Платёжная Инфраструктура (Payment Rails) — КРИТИЧЕСКИЙ P0

### 4.1 Текущий статус и неотложность

**Блок C (Платёжные рельсы) имеет покрытие 0%** — наиболее критический пробел. EMI, которая не может двигать деньги, функционально не является EMI. В текущей архитектуре не упоминается ни один платёжный рельс: ни FPS, ни CHAPS, ни SEPA, ни SWIFT.[^2]

### 4.2 BaaS-провайдеры — первичный выбор (UK + EU)

Banxe как EMI не имеет прямого доступа к UK payment schemes — используются BaaS-партнёры:[^3]

| Провайдер | Схемы | Тип | Статус |
|---|---|---|---|
| **ClearBank** | FPS, CHAPS, BACS | Full UK Banking Licence, API-first[^3] | P0 — первичный UK rails |
| **Modulr** | FPS, BACS, CHAPS, SEPA, SEPA Instant[^3] | UK EMI, API-first | P0 — UK + EU rails |
| **Banking Circle** | SEPA, multi-currency IBANs | EU bank | P1 — EUR расчёты |

ClearBank описывается как «enabler of real-time clearing and embedded banking», обеспечивает прямой API-доступ к FPS, BACS, CHAPS, FSCS-protected accounts; партнёрство с Plaid для open banking payments. Modulr реализовал SEPA Verification of Payee в июне 2025.[^3]

### 4.3 Hyperswitch — Open-Source Payment Orchestration

**Репозиторий:** `github.com/juspay/hyperswitch` | **Лицензия:** Apache 2.0

Hyperswitch (Juspay) — open-source modular payments platform; 40,000+ GitHub stars; обрабатывает до 175 миллионов транзакций в день; поддерживает 50+ PSP (Adyen, Stripe, PayPal, Worldpay и др.). В марте 2025 вышел на US, EU и UK рынки; intelligent routing, 3DS, fraud management, token vault, reconciliation, unified analytics.[^3]

**Роль в Banxe:** Payment orchestration layer между Midaz CBS и внешними PSP/BaaS — routing, failover, cost optimization между ClearBank, Modulr и другими коннекторами.[^3]

***

## Раздел 5. Compliance, AML, KYC/KYB Стек

### 5.1 Текущее состояние — сильная сторона

Compliance/AML-блок реализован на уровне 55–70% — существенно выше отраслевого стандарта для стартапа данной стадии.[^2]

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
| Emergency Stop | Инвариант I-23 | ✅ |
| Governance Invariants | I-21 через I-25 | ✅ |

### 5.2 Marble — Transaction Monitoring и Case Management

**Репозиторий:** `github.com/checkmarble/marble` | **Лицензия:** Open Source

Marble — open-source real-time decision engine для fraud и AML: rule builder, batch + real-time transaction monitoring, case management для investigation. В марте 2025 Marble интегрировался с OpenSanctions, создав «первое полностью open-source решение для transaction screening», self-hosted и privacy-first.[^3]

**Роль в Banxe:** PRIMARY AML case management (порт 5003). AI-агенты триггерят cases через Marble API, MLRO и compliance-офицеры обрабатывают через Marble UI (HITL).

### 5.3 Jube — ML Transaction Scoring

**Репозиторий:** `github.com/jube-home/aml-fraud-transaction-monitoring` | **Лицензия:** AGPLv3

Jube — open-source AML platform с real-time transaction monitoring, AI/ML scoring, case management. Поддерживает FATF compliance framework, anomaly detection, classification через rule-based и ML модели.[^3]

**Роль в Banxe:** ML scoring adapter (порт 5001). Jube classifies risk per transaction → Marble case при превышении score threshold.

### 5.4 OpenSanctions / Yente — Sanctions и PEP Screening

Yente — open-source Docker-based API server для screening против sanctions databases; автоматически обновляет OFAC, HMT (UK), UN, EU и PEP databases (несколько раз в день); требует ElasticSearch (~16GB RAM). OpenSanctions для бизнеса имеет платную лицензию на данные, но self-hosted yente flat-rate — данные клиентов на инфраструктуре компании.[^3]

**Роль в Banxe:** yente-adapter (порт 8084) — real-time sanction + PEP screening при onboarding и transaction monitoring.

### 5.5 Moov Watchman — OFAC/HMT Screening

**Репозиторий:** `github.com/moov-io/watchman` | **Лицензия:** Apache 2.0

High-performance compliance screening: AML/CTF/KYC/OFAC; US OFAC, US CSL, UK, EU sanctions lists; Jaro-Winkler fuzzy matching (minMatch=0.80); HTTP API + Go library; не требует external database.[^2][^3]

**Роль в Banxe:** watchman-adapter (порт 8084) — дополнительный слой screening для UK HMT и OFAC.

### 5.6 Ballerine — KYC/KYB Workflow Engine

**Репозиторий:** `github.com/ballerine-io/ballerine` | **Лицензия:** MIT

Open-source risk management infrastructure: workflow engine, case management, KYC/KYB collection flow, rule engine, unified API для 3rd-party vendors (Sumsub, Onfido, Jumio). Поднял $5M seed от Team8.[^1][^3]

**Роль в Banxe:** Опциональный KYC/KYB orchestration layer — позволяет менять IDV-вендора без переписывания кода.

### 5.7 IDV и KYB провайдеры (SaaS, API-first)

| Провайдер | Функциональность | Приоритет |
|---|---|---|
| **Sumsub** | IDV, liveness, NFC ICAO 9303, KYB, AML | P0 — primary IDV UK+EU[^3] |
| **Onfido** | Document OCR, biometric liveness | P0 — alternative/backup[^3] |
| **Companies House API** | KYB, UBO check (UK) | P0 — free, FCA-required[^3] |

### 5.8 Fraud Prevention

| Компонент | Инструмент | Статус |
|---|---|---|
| Pre-transaction fraud scoring | Sardine.ai / Featurespace ARIC | P1 — SaaS API (<100ms latency) |
| Velocity rules | txmonitor + Redis | P0 — open source |
| APP scam detection | Custom rules + Sardine | P1 — PSR APP 2024 obligation |
| 3DS | BIN sponsor (Monavate) | P1 — при картах |

**Текущий пробел (Fraud — покрытие ~15%):** нет real-time fraud scoring engine (<100ms pre-transaction), нет device fingerprinting, нет ATO prevention, нет 3DS, нет APP scam detection — при PSR APP 2024, обязывающем возмещать жертвам APP-мошенничества с октября 2024.[^2]

***

## Раздел 6. Safeguarding Engine (CASS 15 — КРИТИЧЕСКИЙ P0)

### 6.1 Регуляторный контекст

FCA PS25/12 вступает в силу **7 мая 2026**: обязательные ежедневные reconciliations, monthly safeguarding returns через RegData, annual safeguarding audit, CASS 10A resolution pack (48h retrieval). Исторически среднее покрытие клиентских средств при несостоятельности платёжных фирм составляло ~35% (65% shortfall) — это причина введения CASS 15.[^2][^3]

**Текущий статус в Banxe: покрытие 0% ⛔** — safeguarding engine полностью отсутствует.[^2]

### 6.2 Blueprint Safeguarding Engine

Для Banxe нет готового open-source «safeguarding engine» — строится как custom microservice поверх Midaz:

| Компонент | Решение | Обоснование |
|---|---|---|
| Outstanding e-money balance | Midaz Ledger → PostgreSQL | Источник правды[^3] |
| Safeguarding bank balance | BaaS API (Barclays/HSBC) → polling | Внешняя bank API |
| Daily reconciliation (CASS 15.8) | Custom cron job → Midaz API + Bank API | Ежедневно[^3] |
| Shortfall alert | n8n workflow → MLRO Telegram | Немедленное уведомление |
| Monthly FCA return | n8n automation → FCA RegData | Автоматически[^3] |
| Annual audit | External auditor | Обязательно для >£100k[^3] |
| CASS 10A resolution pack | ClickHouse + PostgreSQL backup | 48h retrieval SLA[^3] |

***

## Раздел 7. AI-Агенты и HITL Архитектура

### 7.1 Операционная модель «4 человека + 9 AI-агентов + 3 LLM-модели»

Структура BANXE «4 человека + 9 AI-агентов + 3 LLM-модели» является принципиально новаторской: замещает операционный персонал (20–50 человек в обычном EMI) автономными агентами с формализованными паспортами, governance-инвариантами и чётко разграниченными уровнями доверия. По данным исследований: банки сообщают о сокращении времени onboarding на 40% и снижении false positives AML на 30% при AI-агентной архитектуре.[^2][^1]

Регуляторы и industry best practices требуют HITL controls для moderate и high-risk decisions; целевая эскалационная ставка: 10-15% всех решений → человеку, 85-90% → автоматически.[^3]

### 7.2 Уровни автономности (L1–L4)

| Уровень | Тип решения | Агент / Человек |
|---|---|---|
| L1 Auto | KYC score >95%, velocity check OK | Агент автоматически → approve |
| L2 Review | KYC score 70-95%, sanctions yellow | Агент флаг → compliance officer review |
| L3 MLRO | SAR trigger, Cat B EDD, large TX | Агент готовит пакет → MLRO approval |
| L4 Board/Invariant | Emergency stop (I-21 to I-25) | Только человек[^3] |

### 7.3 AI Agent Frameworks

LangGraph (LangChain) использует граф-based оркестрацию — узел графа на каждый агент/функцию, state transitions как banking workflows. Лучший для state management и sequential decision-making: portfolio management, order execution, KYC verification flows. CrewAI специализируется на role-based multi-agent collaboration — имитация банковских команд: compliance officer, risk manager, KYC specialist. AutoGen (Microsoft) — для advisory и customer service tasks.[^1]

**Lerian MCP Server** позволяет Claude, ChatGPT и другим AI напрямую взаимодействовать с Midaz Core Banking APIs: автоматизированная обработка транзакций, управление аккаунтами, генерация финансовых отчётов, real-time ledger operations.[^1]

### 7.4 AI Infrastructure Stack

| Компонент | Инструмент | Назначение |
|---|---|---|
| LLM Inference | Ollama (Qwen3, GLM-4) | Локальный self-hosted inference[^3] |
| PII Protection | Microsoft Presidio (MIT)[^3] | Обязательный PII proxy перед LLM |
| HITL Terminal | Telegram bot (@mycarmi_moa_bot) | MLRO/compliance HITL UI[^3][^2] |
| Case Management | Marble (5002-5003) | AI-агенты создают cases, люди закрывают[^3] |
| Agent Evaluation | promptfoo (cron evals) | Adversarial testing, red-teaming[^2] |
| Workflow Automation | n8n (self-hosted, 5678) | Compliance workflow orchestration[^3] |
| Agent Passports | YAML + governance registry | Authority, capabilities, change class[^2] |

**Microsoft Presidio** (MIT) — open-source SDK для PII detection и anonymization в тексте и изображениях; Docker deployment; позволяет удалять/маскировать PII перед отправкой в LLM — критично для FCA/GDPR compliance.[^3]

**n8n** — open-source workflow automation platform с 200+ built-in интеграциями; самохостинг — полный контроль данных; адаптирован для KYC onboarding, AML monitoring, regulatory reporting.[^3]

### 7.5 Уникальные преимущества архитектуры Banxe (превосходит industry standard)

1. **Формализованные Agent Passports** — версионированные YAML-паспорта для каждого агента с zone, change_class, capabilities — то, что KPMG называет «agent passports» как будущий стандарт, Banxe реализовал уже.[^2]
2. **Governance Invariants (I-21 — I-25)** — неизменяемые программно-закреплённые правила поведения системы: emergency stop, ExplanationBundle >£10K, append-only audit.[^2]
3. **ExplanationBundle** >£10K — соответствует FCA SS1/23 об объяснимости AI-решений, которые многие банки пока не выполняют.[^2]
4. **Adversarial Simulations (weekly cron) + promptfoo** — автоматическое red-teaming compliance-системы еженедельно — enterprise-grade QA, которого нет ни в одном из рассмотренных open-source решений.[^2]
5. **PII Proxy Presidio** как mandatory слой перед внешними LLM — правильное архитектурное решение, которое большинство AI-финтех-стартапов реализует постфактум.[^2]
6. **ClickHouse audit trail с TTL 5 лет** — напрямую соответствует DORA Art. 14(2) о неизменяемости аудиторских записей.[^2]

***

## Раздел 8. Технологическая Инфраструктура

### 8.1 Базы данных и хранилища

| Роль | Технология | Обоснование |
|---|---|---|
| Primary relational DB | PostgreSQL :5432 | CBS, customer records, audit tables[^3] |
| Append-only audit trail | ClickHouse :9000, TTL 5 лет | DORA Art. 14, immutable audit[^3] |
| Cache / Velocity tracking | Redis / Valkey :6379 | txmonitor, session, token[^3] |
| Metadata / flexible schema | MongoDB | Midaz Onboarding metadata[^3] |
| High-perf ledger (опция) | TigerBeetle | 42k TPS, 2.8x быстрее PostgreSQL[^3] |
| Internal messaging (Midaz) | RabbitMQ | Transaction lifecycle events[^3] |

TigerBeetle — специализированная финансовая БД для double-entry accounting; в benchmarks: 42k TPS vs 15k TPS PostgreSQL-batched; latency ~1.3ms; Zig, fault-tolerant consensus protocol — применима как hot-path слой под Midaz при >10k TPS.[^3]

### 8.2 Event Streaming и Networking

| Компонент | Технология | Роль |
|---|---|---|
| Primary event bus | Kafka / Pulsar | Payment events, audit event log |
| API Gateway | Kong / AWS API GW | Rate limiting, OAuth2, developer portal[^2] |
| Service Mesh | Istio / Linkerd (mTLS) | mTLS между сервисами[^3] |
| Secrets Management | HashiCorp Vault (ZSP/JIT) | Zero-standing privileges[^3] |

### 8.3 Governance и смежная инфраструктура

| Компонент | Технология |
|---|---|
| Metrics / Tracing | OpenTelemetry + Grafana[^3] |
| HSM | Hardware Security Module для PIN encryption |
| DR/BCP | AWS/GCP active-passive replica[^3][^2] |
| Compliance API | FastAPI :8090 для compliance microservice |
| Container Orchestration | Kubernetes + Helm charts[^3] |
| IaC | Terraform (Midaz native support)[^3] |

***

## Раздел 9. Полная Карта Покрытия UK EMI

### 9.1 Интегральная таблица по блокам

| Функциональный блок | Эталон | Текущий статус Banxe | Покрытие | Приоритет |
|---|---|---|---|---|
| Governance & SMF roles | Обязательно FCA | CEO ✅, MLRO ⚠️ TBD, CCO/CRO/CFO ❌ | 40% | **P0** |
| Remote KYC Onboarding | Обязательно | Screening ✅, IDV/biometric ❌, KYB ❌ | 30% | **P1** |
| AML / Sanctions / TM | Обязательно | Полный агентный стек ✅ | 70% | — |
| SAR Workflow | Обязательно | MLRO + Marble ✅ | 80% | — |
| Fraud Prevention | Обязательно | Velocity rules ⚠️, dedicated engine ❌ | 15% | **P1** |
| Consumer Duty / DISP | Обязательно FCA | Agents ⚠️, complaints flow ❌ | 20% | **P1** |
| Core Banking / Ledger | Обязательно | DB infra ✅, GL logic ❌ | 5% | **P0** |
| Payment Rails (FPS/SEPA/SWIFT) | Обязательно | ❌ полностью отсутствует | 0% | **P0** |
| Safeguarding Engine | Обязательно EMR | ❌ полностью отсутствует | 0% | **P0** |
| Treasury / ALM | Обязательно | ❌ полностью отсутствует | 0% | **P0** |
| Product Catalog | Необходимо | Implied, not defined | 10% | **P1** |
| Customer Interface (App) | Необходимо | AI support agent ⚠️, UI ❌ | 15% | **P1** |
| FATCA / CRS Reporting | Обязательно | ❌ | 0% | P2 |
| PCI DSS (карты) | При картах | ❌ | 0% | P2 |
| Technology: Payment infra | Обязательно | Kafka ❌, API GW ❌, HSM ❌ | 30% | **P1** |
| Technology: AI infra | Best practice | Полностью ✅ | 95% | — |
| Audit Trail (DORA) | Обязательно | ClickHouse append-only ✅ | 90% | — |

***

## Раздел 10. Полная Таблица Компонентов Стека

| Домен | Компонент | Технология | Лицензия | GitHub / Источник |
|---|---|---|---|---|
| **PRIMARY CBS** | Core Ledger / Accounts | Midaz (LerianStudio) | Apache 2.0[^3] | github.com/LerianStudio/midaz |
| **FALLBACK CBS** | Core Banking (loans) | Apache Fineract | Apache 2.0[^1] | github.com/apache/fineract |
| **LEDGER OPTION** | Programmable money-flow | Formance Ledger | Apache 2.0[^3] | github.com/formancehq/ledger |
| **LEDGER HIGH-PERF** | Hot-path transactions | TigerBeetle (опция) | Apache 2.0[^3] | github.com/tigerbeetle/tigerbeetle |
| **LEDGER ALT** | Developer-first | Blnk Finance | Apache 2.0[^1] | github.com/blnkfinance/blnk |
| **DB: PRIMARY** | Relational data | PostgreSQL | Open Source | postgresql.org |
| **DB: AUDIT** | Append-only audit trail | ClickHouse | Apache 2.0[^3] | clickhouse.com |
| **DB: CACHE** | Velocity, sessions | Redis / Valkey | BSD | redis.io |
| **DB: METADATA** | Flexible schema | MongoDB | SSPL | mongodb.com |
| **PAYMENT RAILS UK** | FPS, CHAPS, BACS | ClearBank BaaS | Commercial[^3] | clear.bank |
| **PAYMENT RAILS EU** | FPS, SEPA, BACS | Modulr BaaS | Commercial[^3] | modulr.finance |
| **PAYMENT RAILS EUR** | SEPA, multi-currency | Banking Circle | Commercial | bankingcircle.com |
| **PAYMENT ORCH** | PSP routing, 3DS | Hyperswitch | Apache 2.0[^3] | github.com/juspay/hyperswitch |
| **PAYMENT HUB** | ISO 20022, FPS, FedNow | Mifos Payment Hub EE | MPL 2.0[^1] | payments.mifos.org |
| **KYC/KYB FLOW** | Onboarding workflow | Ballerine | MIT[^3] | github.com/ballerine-io/ballerine |
| **IDV** | Document + Liveness | Sumsub | Commercial | sumsub.com |
| **IDV** | Document OCR | Onfido | Commercial | onfido.com |
| **KYB** | UBO, Company check | Companies House API | Free (Gov UK)[^3] | developer.companieshouse.gov.uk |
| **OPEN BANKING** | PSD2, XS2A, API GW | OBP-API | AGPL[^1] | github.com/OpenBankProject/OBP-API |
| **AML/TM** | Transaction Monitoring + Cases | Marble | Open Source[^3] | github.com/checkmarble/marble |
| **ML SCORING** | AML/Fraud ML engine | Jube | AGPLv3[^3] | github.com/jube-home/aml-fraud-transaction-monitoring |
| **SANCTIONS** | Self-hosted sanctions/PEP | OpenSanctions/Yente | OSS + data license[^3] | opensanctions.org/docs/on-premise |
| **SANCTIONS** | OFAC/HMT/UN screening | Moov Watchman | Apache 2.0[^3] | github.com/moov-io/watchman |
| **FRAUD** | Pre-tx fraud scoring | Sardine.ai | Commercial | sardine.ai |
| **PII** | LLM input anonymization | Microsoft Presidio | MIT[^3] | github.com/microsoft/presidio |
| **LLM** | Local AI inference | Ollama (Qwen3, GLM) | MIT | ollama.ai |
| **AI ORCHESTRATION** | Banking workflows | LangGraph | Open Source[^1] | github.com/langchain-ai/langgraph |
| **AI ROLES** | Compliance teams | CrewAI | Open Source[^1] | github.com/joaomdmoura/crewAI |
| **AI CHAT** | Customer service | AutoGen | Open Source[^1] | github.com/microsoft/autogen |
| **AI↔BANKING** | MCP bridge | Lerian MCP Server | Open Source[^1] | github.com/LerianStudio/lerian-mcp-server |
| **WORKFLOW** | Compliance automation | n8n (self-hosted) | Fair-code[^3] | n8n.io |
| **EVENTS** | Payment/audit event log | Kafka / Pulsar | Apache 2.0 | kafka.apache.org |
| **API GW** | Rate limiting, auth | Kong / AWS API GW | Open Core | konghq.com |
| **SECRETS** | ZSP/JIT secrets | HashiCorp Vault | BSL | vaultproject.io |
| **CARDS** | BIN sponsor, 3DS | Monavate | Commercial | monavate.com |
| **INFRA** | K8s deployment | Kubernetes + Helm | Apache 2.0 | kubernetes.io |
| **IaC** | Cloud infra | Terraform | MPL 2.0 | terraform.io |
| **SERVICE MESH** | mTLS service-to-service | Istio / Linkerd | Apache 2.0 | istio.io |
| **MONITORING** | Metrics, tracing | OpenTelemetry + Grafana | Apache 2.0 | grafana.com |
| **HITL TERMINAL** | Human override UI | Telegram bot | N/A | @mycarmi_moa_bot |
| **AGENT EVAL** | Red-teaming, evals | promptfoo | Open Source | promptfoo.dev |
| **AGENT PASSPORTS** | AI governance | YAML + governance registry | N/A | banxe-architecture/agents/ |

***

## Раздел 11. Layer-by-Layer Архитектура

```
┌──────────────────────────────────────────────────────────────────┐
│  CUSTOMER LAYER                                                   │
│  React Web App / Mobile / OBP-API (Open Banking OBIE)           │
└───────────────────────────┬──────────────────────────────────────┘
                            │ OAuth2 / mTLS
┌───────────────────────────▼──────────────────────────────────────┐
│  API GATEWAY: Kong / AWS API GW                                  │
│  Rate Limiting, Auth, Developer Portal                           │
└───────────────────────────┬──────────────────────────────────────┘
         ┌─────────────────┼──────────────────┐
         │                 │                  │
┌────────▼────────┐ ┌──────▼──────────┐ ┌───▼──────────────┐
│  KYC/KYB LAYER  │ │ COMPLIANCE LAYER │ │  PAYMENT LAYER   │
│  Ballerine      │ │ Marble + Jube    │ │  Hyperswitch     │
│  Sumsub / Onfido│ │ OpenSanctions    │ │  + BaaS APIs     │
│  Companies House│ │ Watchman         │ │  ClearBank FPS   │
│  FATCA/CRS flow │ │ Presidio PII     │ │  Modulr SEPA     │
│  MCP ↔ LangGraph│ │ n8n DISP flow    │ │  Banking Circle  │
└────────┬────────┘ └──────┬──────────┘ └───┬──────────────┘
         └─────────────────┴──────────────────┘
                            │ Events / API calls
┌───────────────────────────▼──────────────────────────────────────┐
│  PRIMARY CBS: MIDAZ (LerianStudio)                               │
│  Onboarding Domain | Transaction Domain                          │
│  PostgreSQL + MongoDB | RabbitMQ | Go microservices              │
│  Apache 2.0 | CQRS | Event-Driven | Immutable | Double-Entry    │
│  MCP Server ← → Claude / GPT / Ollama                           │
│  SAFEGUARDING ENGINE (custom cron + CASS 15 reconciliation)      │
└───────────────────────────┬──────────────────────────────────────┘
                            │ Events
┌───────────────────────────▼──────────────────────────────────────┐
│  EVENT STREAMING: Kafka / Pulsar                                 │
│  Payment Events | Audit Events | Alert Triggers                  │
└──────────────┬─────────────────────┬──────────────────────┬──────┘
               │                     │                      │
┌──────────────▼──────┐  ┌──────────▼──────────┐  ┌───────▼──────┐
│  AUDIT              │  │  AI AGENTS           │  │  OBSERV.    │
│  ClickHouse :9000   │  │  Ollama LLM          │  │  OpenTelemetry│
│  Append-only 5yr    │  │  LangGraph / CrewAI  │  │  Grafana    │
│  DORA Art.14 ✅     │  │  n8n Workflows       │  │  Prometheus │
│                     │  │  HITL: Marble +      │  │             │
│                     │  │  Telegram @bot       │  │             │
└─────────────────────┘  └──────────────────────┘  └─────────────┘
```

***

## Раздел 12. Gap Analysis: Geniusto → Open Stack

| Geniusto функция | Open-source замена | Статус |
|---|---|---|
| Core Ledger (accounts, balances, GL) | Midaz Ledger[^3] | ✅ Полное покрытие |
| Double-entry accounting | Midaz Transaction Domain | ✅ Полное покрытие |
| Multi-currency accounts | Midaz Assets + multi-ledger | ✅ Полное покрытие |
| Loan products | Fineract (если нужно)[^1] | ✅ Fallback |
| eKYC / eKYB | Ballerine + Sumsub + Companies House[^3] | ✅ Полное покрытие |
| AML monitoring | Marble + Jube[^3] | ✅ Лучше чем Geniusto |
| Sanctions / PEP | Yente + Watchman[^3] | ✅ Полное покрытие |
| Payment hub / routing | Hyperswitch + BaaS[^3] | ✅ Полное покрытие |
| SWIFT connectivity | Prowide Core (ISO 20022, Apache 2.0) | ✅ С доп. интеграцией |
| Omni-channel / UI | React + OBP-API[^1] | ⚠️ Нужна разработка |
| PSD2 / Open Banking | OBP-API / adorsys[^1] | ⚠️ Phase 2 |
| FCA reporting | n8n automation + FastAPI | ✅ Через CASS 15 engine |
| Safeguarding engine | Custom cron + Midaz API[^3] | ✅ P0 buildout |
| AI monitoring | Marble + Jube + Ollama + LangGraph | ✅ Превосходит Geniusto |
| HITL governance | Marble cases + Telegram HITL | ✅ Уникальная возможность |
| Crypto flows | Formance Numscript[^1] | ✅ Отсутствовало у Geniusto |
| Agent orchestration | LangGraph + Lerian MCP | ✅ Отсутствовало у Geniusto |

***

## Раздел 13. Governance — Статус и Пробелы

| Роль/Функция | Статус | Примечание |
|---|---|---|
| CEO (SMF1) | ✅ Moriel Carmi | Заполнено |
| DEVELOPER/CTIO | ✅ Oleg | Не SMF, но критическая роль |
| MLRO (SMF17) | ⚠️ TBD | Обязательно назначить до авторизации[^2] |
| CFO (SMF2) | ❌ Не назначен | Требование FCA SMCR[^2] |
| CRO (SMF4) | ❌ Не назначен | Требование FCA[^2] |
| CCO (SMF16) | ❌ Не назначен | Требование FCA[^2] |
| Agent Passports | ✅ banxe-architecture/agents/passports/ | Уникальная практика |
| ADR Process | ✅ banxe-architecture/decisions/ | Excellent governance |
| Change Classification | ✅ CLASS_A/CLASS_B | |
| Governance Invariants | ✅ I-21 — I-25 | Strong |
| Board of Directors | ❌ Не описан | Нужен для авторизации |
| Internal Audit | ❌ Отсутствует | Outsourced IA как минимум |
| SMF FCA Registration | ❌ Не упомянута | Обязательна до авторизации[^2] |

MLRO, CCO, CFO могут быть **outsourced** через interim-провайдеров в UK — это распространённая практика для стартующих EMI.[^2]

***

## Раздел 14. Phased Roadmap

### Phase 0: Pre-Launch FCA (Месяцы 1–3) — без этого авторизация невозможна

1. **SMF-holders в FCA Connect:** MLRO (outsourced interim), CCO, CRO, CFO, CEO (Moriel Carmi ✅)[^2]
2. **Midaz deployment:** Docker Compose → GMKtec; Onboarding domain: org → ledger (GBP) → accounts; Transaction domain: FPS flow[^3]
3. **BaaS onboarding:** ClearBank или Modulr — sandbox API, FPS test flows[^3]
4. **Safeguarding account:** Barclays/HSBC; cron-reconciliation (Midaz balance vs bank API)[^2][^3]
5. **IDV Integration:** Sumsub sandbox → production KYC; Companies House API для KYB[^3]
6. **AML Pipeline:** Marble + Jube + Yente/Watchman → базовые velocity rules и sanctions screening[^3]
7. **PII Proxy:** Presidio — обязателен для всех LLM calls[^3]
8. **CASS 15 Preparation:** daily reconciliation tooling, resolution pack structure, FCA RegData test submission[^3]

### Phase 1: MVP Launch (Месяцы 4–6)

9. **Kafka event streaming:** payment events → ClickHouse append-only audit trail[^2]
10. **Complaints workflow:** n8n DISP flow, 8-week timer, FOS escalation[^2]
11. **Customer App:** React web-portal — onboarding, account view, payment initiation[^2]
12. **SEPA/EUR:** Banking Circle onboarding, EUR ledger в Midaz[^3]
13. **FX Engine:** rate management, Midaz multi-currency[^3]
14. **Fraud Prevention Layer:** Sardine.ai / Featurespace ARIC — отдельно от AML[^2]
15. **API Gateway:** Kong → developer portal, rate limiting[^2]

### Phase 2: Growth (Месяцы 7–12)

16. **Cards:** Monavate BIN sponsor, virtual/physical, 3DS[^3]
17. **PCI DSS:** QSA assessment, CDE mapping[^2]
18. **Open Banking:** OBP-API, OBIE registration, PIS/AIS[^1]
19. **DR/BCP:** GMKtec + AWS/GCP active-passive backup[^2]
20. **Secrets Management:** HashiCorp Vault с JIT scoping[^3]
21. **FATCA/CRS:** self-certification при онбординге + HMRC annual reporting automation[^2]

### Phase 3: Scale (Год 2+)

22. **Agent Passports:** полная YAML-based governance с CLASS-A/CLASS-B классификацией[^2]
23. **Adversarial Simulations:** weekly cron promptfoo red-teaming для compliance AI[^2]
24. **TigerBeetle:** миграция hot-path transactions с PostgreSQL если >10k TPS[^3]
25. **Formance Reconciliation:** для сложных FX/marketplace splits[^3]
26. **LangGraph full deployment:** все banking workflows как state graphs с HITL[^1]

***

## Раздел 15. Регуляторные Дедлайны

| Дедлайн | Требование | Статус |
|---|---|---|
| **7 мая 2026** | FCA CASS 15 daily reconciliation, monthly returns[^3][^2] | ❌ Safeguarding engine не готов — P0 |
| **FCA Authorization** | SMF-holders, MLRO, compliance function[^2] | ⚠️ MLRO/CFO/CCO не назначены — P0 |
| **DORA (ongoing)** | 5yr append-only audit trail[^3] | ✅ ClickHouse готов |
| **GDPR / UK GDPR** | PII anonymization в AI pipelines[^3] | ✅ Presidio готов |
| **PSR APP 2024** | APP scam detection, реимбурсмент с октября 2024[^2] | ❌ Нет fraud engine — P1 |
| **Consumer Duty** | Fair outcomes MI, complaints SLA[^2] | ❌ Нет DISP workflow — P1 |
| **PCI DSS** | При выпуске карт | Отложено до Phase 2 |

***

## Итоговая Оценка

Banxe AI Bank построен «снаружи внутрь»: сначала самый сложный compliance-мозг (AI-агенты, governance invariants, adversarial testing), затем — операционное тело (ledger, payment rails). Это нетипичная, но стратегически обоснованная последовательность для AI-first стартапа: compliance — дифференциатор, banking operations — commodity, получаемая через BaaS.[^2]

Ключевой вывод: **готового единого open-source решения класса «всё-в-одном» для EMI не существует**, однако правильно скомпонованный стек из Midaz (PRIMARY CBS) + Mifos Payment Hub EE + Ballerine + Moov Watchman + Marble + LangGraph + Lerian MCP Server полностью перекрывает функциональность Geniusto GO Suite и превосходит её в части AI-native возможностей.[^1]

Критическое отличие от Geniusto: open-source стек позволяет AI-агентам иметь **прямой программный доступ** ко всем banking операциям через API и MCP протоколы — что невозможно в проприетарной системе. Это фундаментальное требование для архитектуры AI Bank, где агенты — не надстройка, а основные «сотрудники».[^1]

Ближайшие **6 месяцев** определяют, сможет ли проект трансформироваться из **AI compliance engine** в **полнофункциональный EMI** с реальными клиентами и движением денег. Три критических P0-шага: (1) назначить SMF-holders, (2) выбрать BaaS-провайдера, (3) развернуть Midaz + safeguarding reconciliation engine до 7 мая 2026.[^2][^3]

---

## References

1. [Banxe-AI-Bank-Open-Source-ABS-dlia-EMI-Issledovanie-i-Strategiia-zameny-Geniusto.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/101434432/1a3cf8ec-5640-4271-a2d0-d9889e0f49b9/Banxe-AI-Bank-Open-Source-ABS-dlia-EMI-Issledovanie-i-Strategiia-zameny-Geniusto.md?AWSAccessKeyId=ASIA2F3EMEYEUYJHNSGD&Signature=rpliOtHVGR8Q%2B6gPPfob3GwwfNo%3D&x-amz-security-token=IQoJb3JpZ2luX2VjEAgaCXVzLWVhc3QtMSJIMEYCIQC%2BUklgvrLlzUAhC5W%2BkBkwiPIJ%2B5Y4Ehjn%2FE6yuqcGxAIhAK1fJ%2FqQDBbZDs3fRqJYcJkobUw7tLojS0T3i%2FUbbPQqKvwECND%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEQARoMNjk5NzUzMzA5NzA1IgyRQRxNcyXULtbGKqoq0ATnP0oG890%2FMrdhaVk4FO2hIpyhmEfgj%2BPtWlWpUhH1avk2gQJJDH4pkAAr9WHI5QBOI10zW0BXDfvy9wkyVbXQi8XbnG6%2BWMtUd3BAFifOIyGu3NVjjuxGShmxuVbtxEhmzNsXjrvqdn%2FeBInnuWFxz00qZc1M5Y%2FVADxrrIYJseOyrsWLoPAeKaK0qByUvFd1psa43sirZt%2BvCLuIAjjofqoawFvT1PJyFbWAYi1aRHG57DZOQYz5lv5SDOQvwrgXG7xY328b52y1tW%2FloXd3ubkAI6jJYF3W4GgfNudeEvb%2FLx0BVT7xcDeaEXCFRSyixTAZriLVHVGiVtKskoR1G8M9H8blo3R8sYsRkLaBwmtbuugTFZP7M%2FE7TpvkMawj81ZWkppjY%2FRMm1FOMEpTwZqmmKfoLp5w9M8H4HQDy%2BDgutq%2FyVRxaRGEnqwkBPEpms6SMWg2bRU2Ss0TX%2F1mQUNgPMT5lW1Xl2ImxyNsONDtyyd1UGYjaqKLpqlwx19x95XFPgyh83mLPNPUTYhgX4rRyBkgcDRTAZeMFFGqSswzNQZlHNdqvEvX8dQhktYczLiccgyIh0FXjMUE99aWa%2BIMdg10bfH5l5ZkFuwBg%2BIdUyH%2F%2BHfShIz5ya9kYDy%2BjcxhekLvuuwQgtVVjLuG8%2B1XXe1Rq0r%2FB0vxlYZ3TXHwOvKy99VOxQYdGvPJCrx4%2FwnrtVr0TuWvPTs6MMnwXlAVc6bbVBHvVH7Pre2B0FGN4hgS0baGCLxyrVFqpJdFzQ3XCZ1YGrwNcDu1MWeMMMuYz84GOpcBoRizT0VmLKOiyGn4%2BZuAud%2BhpnFdRdh7MWx9T5bwhB30ZjH3%2BDBaNknkl%2BKzwc3F0jEOw4L%2Far8Ra7ZQjTa%2FwoCGvgoq%2FivwtZTL5mjaCw0Fkggpi2skPi1FsNqVugHpHREC%2FqZwIVSAc4Ilb9SRoJIXd4ZbBLj%2BPWu7xPaj%2B2YEFelUmmolAAy4lYEt%2BqeAF3zFSvD86w%3D%3D&Expires=1775491614) - # Banxe AI Bank: Open-Source АБС для EMI
## Исследование решений для замены Geniusto [GO] Suite с ар...

2. [BANXE-AI-Bank-Nalozhenie-na-etalonnuiu-strukturu-UK-EMI-polnaia-karta-pokrytiia-probelov-i-priori.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/101434432/87ca7d2f-2351-4201-bf12-47d615e2a267/BANXE-AI-Bank-Nalozhenie-na-etalonnuiu-strukturu-UK-EMI-polnaia-karta-pokrytiia-probelov-i-prioritetov-vospolneniia.md?AWSAccessKeyId=ASIA2F3EMEYEUYJHNSGD&Signature=DtV2RmTxtSVEmquBA2oitMNNcpo%3D&x-amz-security-token=IQoJb3JpZ2luX2VjEAgaCXVzLWVhc3QtMSJIMEYCIQC%2BUklgvrLlzUAhC5W%2BkBkwiPIJ%2B5Y4Ehjn%2FE6yuqcGxAIhAK1fJ%2FqQDBbZDs3fRqJYcJkobUw7tLojS0T3i%2FUbbPQqKvwECND%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEQARoMNjk5NzUzMzA5NzA1IgyRQRxNcyXULtbGKqoq0ATnP0oG890%2FMrdhaVk4FO2hIpyhmEfgj%2BPtWlWpUhH1avk2gQJJDH4pkAAr9WHI5QBOI10zW0BXDfvy9wkyVbXQi8XbnG6%2BWMtUd3BAFifOIyGu3NVjjuxGShmxuVbtxEhmzNsXjrvqdn%2FeBInnuWFxz00qZc1M5Y%2FVADxrrIYJseOyrsWLoPAeKaK0qByUvFd1psa43sirZt%2BvCLuIAjjofqoawFvT1PJyFbWAYi1aRHG57DZOQYz5lv5SDOQvwrgXG7xY328b52y1tW%2FloXd3ubkAI6jJYF3W4GgfNudeEvb%2FLx0BVT7xcDeaEXCFRSyixTAZriLVHVGiVtKskoR1G8M9H8blo3R8sYsRkLaBwmtbuugTFZP7M%2FE7TpvkMawj81ZWkppjY%2FRMm1FOMEpTwZqmmKfoLp5w9M8H4HQDy%2BDgutq%2FyVRxaRGEnqwkBPEpms6SMWg2bRU2Ss0TX%2F1mQUNgPMT5lW1Xl2ImxyNsONDtyyd1UGYjaqKLpqlwx19x95XFPgyh83mLPNPUTYhgX4rRyBkgcDRTAZeMFFGqSswzNQZlHNdqvEvX8dQhktYczLiccgyIh0FXjMUE99aWa%2BIMdg10bfH5l5ZkFuwBg%2BIdUyH%2F%2BHfShIz5ya9kYDy%2BjcxhekLvuuwQgtVVjLuG8%2B1XXe1Rq0r%2FB0vxlYZ3TXHwOvKy99VOxQYdGvPJCrx4%2FwnrtVr0TuWvPTs6MMnwXlAVc6bbVBHvVH7Pre2B0FGN4hgS0baGCLxyrVFqpJdFzQ3XCZ1YGrwNcDu1MWeMMMuYz84GOpcBoRizT0VmLKOiyGn4%2BZuAud%2BhpnFdRdh7MWx9T5bwhB30ZjH3%2BDBaNknkl%2BKzwc3F0jEOw4L%2Far8Ra7ZQjTa%2FwoCGvgoq%2FivwtZTL5mjaCw0Fkggpi2skPi1FsNqVugHpHREC%2FqZwIVSAc4Ilb9SRoJIXd4ZbBLj%2BPWu7xPaj%2B2YEFelUmmolAAy4lYEt%2BqeAF3zFSvD86w%3D%3D&Expires=1775491614) - # BANXE AI Bank — Наложение на эталонную структуру UK EMI: полная карта покрытия, пробелов и приорит...

3. [BANXE-AI-Bank-Edinyi-arkhitekturnyi-stek-dlia-UK-EMI.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/101434432/ab1421f0-3209-4d51-94c1-42091ef0531f/BANXE-AI-Bank-Edinyi-arkhitekturnyi-stek-dlia-UK-EMI.md?AWSAccessKeyId=ASIA2F3EMEYEUYJHNSGD&Signature=CDIslhzmBz4xHI5aY0%2FSVVyIBLA%3D&x-amz-security-token=IQoJb3JpZ2luX2VjEAgaCXVzLWVhc3QtMSJIMEYCIQC%2BUklgvrLlzUAhC5W%2BkBkwiPIJ%2B5Y4Ehjn%2FE6yuqcGxAIhAK1fJ%2FqQDBbZDs3fRqJYcJkobUw7tLojS0T3i%2FUbbPQqKvwECND%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEQARoMNjk5NzUzMzA5NzA1IgyRQRxNcyXULtbGKqoq0ATnP0oG890%2FMrdhaVk4FO2hIpyhmEfgj%2BPtWlWpUhH1avk2gQJJDH4pkAAr9WHI5QBOI10zW0BXDfvy9wkyVbXQi8XbnG6%2BWMtUd3BAFifOIyGu3NVjjuxGShmxuVbtxEhmzNsXjrvqdn%2FeBInnuWFxz00qZc1M5Y%2FVADxrrIYJseOyrsWLoPAeKaK0qByUvFd1psa43sirZt%2BvCLuIAjjofqoawFvT1PJyFbWAYi1aRHG57DZOQYz5lv5SDOQvwrgXG7xY328b52y1tW%2FloXd3ubkAI6jJYF3W4GgfNudeEvb%2FLx0BVT7xcDeaEXCFRSyixTAZriLVHVGiVtKskoR1G8M9H8blo3R8sYsRkLaBwmtbuugTFZP7M%2FE7TpvkMawj81ZWkppjY%2FRMm1FOMEpTwZqmmKfoLp5w9M8H4HQDy%2BDgutq%2FyVRxaRGEnqwkBPEpms6SMWg2bRU2Ss0TX%2F1mQUNgPMT5lW1Xl2ImxyNsONDtyyd1UGYjaqKLpqlwx19x95XFPgyh83mLPNPUTYhgX4rRyBkgcDRTAZeMFFGqSswzNQZlHNdqvEvX8dQhktYczLiccgyIh0FXjMUE99aWa%2BIMdg10bfH5l5ZkFuwBg%2BIdUyH%2F%2BHfShIz5ya9kYDy%2BjcxhekLvuuwQgtVVjLuG8%2B1XXe1Rq0r%2FB0vxlYZ3TXHwOvKy99VOxQYdGvPJCrx4%2FwnrtVr0TuWvPTs6MMnwXlAVc6bbVBHvVH7Pre2B0FGN4hgS0baGCLxyrVFqpJdFzQ3XCZ1YGrwNcDu1MWeMMMuYz84GOpcBoRizT0VmLKOiyGn4%2BZuAud%2BhpnFdRdh7MWx9T5bwhB30ZjH3%2BDBaNknkl%2BKzwc3F0jEOw4L%2Far8Ra7ZQjTa%2FwoCGvgoq%2FivwtZTL5mjaCw0Fkggpi2skPi1FsNqVugHpHREC%2FqZwIVSAc4Ilb9SRoJIXd4ZbBLj%2BPWu7xPaj%2B2YEFelUmmolAAy4lYEt%2BqeAF3zFSvD86w%3D%3D&Expires=1775491614) - # BANXE AI Bank — Единый Архитектурный Стек для UK EMI

**Версия:** 2.0 | **Дата:** April 2026 | **С...

4. [[PDF] The 2025 State of Open Source in Financial Services](https://www.linuxfoundation.org/hubfs/Research%20Reports/05_FINOS_2025_Report.pdf?hsLang=en) - In 2025, no discussion of technology in finance is complete without AI. Open source is already shapi...

