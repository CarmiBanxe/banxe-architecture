# BANXE AI Bank — Единый Архитектурный Стек для UK EMI

**Версия:** 2.0 | **Дата:** April 2026 | **Статус:** Пересобранный и согласованный документ  
**Контекст:** Замена Geniusto [GO] Suite для EMI-проекта Banxe AI Bank (UK FCA), где операционной моделью является коллаборация AI-агентов с людьми-дублёрами (HITL).

***

## Executive Summary

Предыдущая версия документа содержала противоречие: в теле документа Apache Fineract значился как первичный CBS, тогда как уточнение задачи указывает на **Midaz (LerianStudio)** как предпочтительный AI-native core.

**Исправление и единое решение:** Настоящий документ приводит все рекомендации к единому согласованному стеку, где:

- **PRIMARY CBS / Ledger:** Midaz (LerianStudio) — open-source, Apache 2.0, Go, event-driven, AI-native, cloud-native[^1][^2]
- **BACKUP / Fallback CBS:** Apache Fineract — если потребуются loan products или нужна более зрелая community[^3][^4]
- **PROGRAMMABLE LEDGER (опция):** Formance Ledger — для сложных программируемых money-flow сценариев[^5][^6]
- **Geniusto GO Suite** — исследована как заменяемая система; идентифицированы её ограничения[^7][^8]

[ФАКТ] Анализ FINOS 2025 State of Open Source in Financial Services показывает, что открытые стандарты, open-source модели и open-source фреймворки имеют наибольшее влияние на развитие AI в финансовом секторе (56%, 54% и 52% соответственно).[^9]

***

## Часть 1. Geniusto [GO] Suite — Анализ заменяемой системы

### 1.1 Что такое Geniusto

[ФАКТ] Geniusto позиционирует [GO] Suite как all-in-one платформу для banks, EMIs, digital-only banks, credit unions, cooperatives, PSPs и remittance-компаний. Платформа включает [GO] Core Banking, GO Omni-Channel, GO Onboarding, GO Payment и смежные модули. Клиенты — Transact Pro (Латвия), Camalig Bank, Agribank.[^8][^10][^11][^12]

[ФАКТ] В 2025 году Geniusto присоединилась к SWIFT Partner Programme как Business Connect Enabler, что повысило её ценность для международной connectivity. Платформа является PSD2-совместимой, поддерживает OAuth 2.0, AISP/PISP функциональность и cloud-agnostic deployment (AWS, Azure, GCP).[^13][^8]

### 1.2 Технические характеристики Geniusto

| Параметр | Значение |
|---|---|
| Тип | Проприетарная, закрытый исходный код |
| Лицензия | SaaS / Commercial, custom pricing[^14] |
| Deployment | Cloud / SaaS / Web-based[^15] |
| Database | PostgreSQL (рекомендована), Oracle 19, MS SQL 2019[^8] |
| API | REST (Bifrost layer)[^8] |
| Low-code | Да (business process configuration)[^16] |
| AML/KYC | Built-in eKYC, eKYB, AML мониторинг[^16] |
| Язык | Английский |
| Публичные отзывы | Практически отсутствуют (0 reviews на Capterra)[^15] |

### 1.3 Почему Geniusto нужно заменить

[ФАКТ] Независимый анализ на fintegrator.eu констатирует: Geniusto требует "significant expertise and training" и "may not fully cater to the complex requirements of larger, more diversified financial institutions".[^8]

Ключевые структурные ограничения:

- **Vendor lock-in**: проприетарный закрытый код → невозможность прямой интеграции AI-агентных workflow в core logic[^14][^8]
- **Нет контроля над roadmap**: изменения в платформе диктует вендор
- **Непрозрачный pricing**: custom-only, без публичных тарифов[^14]
- **Ограниченная AI-native интеграция**: SaaS-архитектура плохо подходит для model-as-operator patterns, agentic orchestration и deep event hooks
- **Ограниченная кастомизация compliance workflows**: при CASS 15 FCA (вступает 7 мая 2026) банку нужна полная controllability over safeguarding reconciliation engine[^17][^18]

***

## Часть 2. Сравнение Open-Source CBS/Ledger систем

### 2.1 Midaz (LerianStudio) — PRIMARY CBS [ВЫБРАН]

[ФАКТ] Midaz — open-source, cloud-native, immutable, multi-currency, multi-asset Core Ledger Application, разработанный LerianStudio (Бразилия, основан в 2024); лицензия Apache 2.0; язык — Go.[^19][^1]

[ФАКТ] Архитектура Midaz реализует domain-driven design с двумя основными доменами: Onboarding Domain (organizations, ledgers, assets, account types, accounts, portfolios, segments) и Transaction Domain (balances, operation routes, operations, transaction routes, transactions). Система построена на CQRS + Hexagonal Architecture с event-driven processing через RabbitMQ.[^2][^1]

**Ключевые характеристики Midaz:**

| Параметр | Значение |
|---|---|
| Лицензия | Apache 2.0 — коммерчески свободно[^19] |
| Язык | Go (cloud-native, высокая производительность) |
| Archit | CQRS, Hexagonal, Event-Driven, Microservices[^1] |
| Double-entry | Нативный, n:n транзакции[^1] |
| Multi-currency | Нативный, multi-asset (fiat, crypto, loyalty)[^1] |
| Immutability | Нативная — все записи неизменны[^1] |
| AI-native | Да — real-time event publishing, GenAI интеграция[^20] |
| Compliance | SOC-2, GDPR, PCI-DSS ready[^1] |
| SDK | Go, TypeScript[^19][^21] |
| Deployment | Docker Compose (локально), Kubernetes (Helm charts)[^22] |
| IaC | Terraform для AWS/GCP/Azure[^23] |
| Observability | OpenTelemetry + Grafana[^1] |

[ФАКТ] В LinkedIn-публикациях Midaz описывается как "first open-source core banking stack for the AI era" с характеристиками: open-core, AI-native (GenAI + real-time event publishing), battle-tested (N:N transactions, multi-currency, self-reconciliation).[^20]

[ФАКТ] Lerian привлекла ~$3M для разработки "next open source stack for financial services"; для контекста — Formance одновременно подняла $21M на аналогичном открытом подходе, что свидетельствует об инвесторском интересе к open core banking.[^24]

**Почему Midaz лучше для Banxe AI Bank, чем Fineract:**

1. **Event-driven native**: Midaz нативно публикует события для каждой транзакции — AI-агенты подписываются и реагируют в реальном времени без polling[^25][^1]
2. **Go vs Java**: Go более cloud-native, контейнеры меньше, latency ниже, footprint лучше для microservices architecture
3. **CQRS pattern**: разделение command/query упрощает интеграцию AI-агентов как command handlers
4. **Immutable ledger нативно**: критически важно для DORA и FCA audit requirements[^18]
5. **Designed for fintechs 2024+**: не перегружен legacy MFI-функциональностью Fineract

**Ограничения Midaz (честный анализ):**

- Компания основана в 2024 — меньше production deployments, чем у Fineract[^26]
- Нет встроенных loan/credit products (для EMI это не критично)
- Нет built-in KYC, AML, payment connectors — требует интеграции отдельных компонентов[^1]
- Community меньше, чем у Fineract или Formance

### 2.2 Apache Fineract — FALLBACK CBS

[ФАКТ] Apache Fineract — open-source core banking platform под Apache Software Foundation, лицензия Apache 2.0, Java/Spring Boot, используется в 80+ странах. Функционал: loans, savings, KYC support, double-entry accounting, REST API.[^4][^3]

[ФАКТ] В документе Banxe (file:536) Apache Fineract уже присутствует в Roadmap Phase 0 как CBS-кандидат с комментарием "open-source, зрелое сообщество" — как альтернатива Mambu SaaS.[^27]

**Когда выбрать Fineract вместо Midaz:**
- Если потребуются встроенные loan products (кредитный портфель)
- Если нужна более широкая community поддержка
- Если команда лучше знает Java экосистему

### 2.3 Formance Ledger — PROGRAMMABLE MONEY-FLOW ОПЦИЯ

[ФАКТ] Formance Ledger — programmable open-source financial ledger с Numscript DSL для моделирования сложных money movements; поддерживает atomic multi-postings transactions; GitHub: formancehq/ledger, лицензия Apache 2.0.[^6][^5]

[ФАКТ] Formance Stack включает: Ledger (double-entry, immutable), Payments (unified payments API), Reconciliation (balance verification против payment providers), Numscript VM.[^28][^6]

**Когда выбрать Formance вместо Midaz:**
- Если нужны очень сложные split-payment, marketplace, FX-flow сценарии
- Если приоритет — программируемость через DSL, а не только API

### 2.4 Сводная таблица CBS-кандидатов

| Критерий | Midaz (PRIMARY) | Fineract (FALLBACK) | Formance (OPTION) |
|---|---|---|---|
| Лицензия | Apache 2.0[^19] | Apache 2.0[^4] | Apache 2.0[^5] |
| Язык | Go | Java | Go |
| Архитектура | CQRS + Event-driven[^1] | MVC + Batch | Microservices + DSL[^6] |
| AI-native | ✅ Да[^20] | ❌ Нет | ✅ Частично |
| Cloud-native | ✅ Native[^1] | ⚠️ Адаптирован | ✅ Native |
| Зрелость | ⚠️ 2024, молодой[^26] | ✅ 2009+, Apache[^4] | ✅ 2021, 14k stars |
| EMI ledger | ✅ Отлично | ✅ Хорошо | ✅ Хорошо |
| Loan products | ❌ Нет | ✅ Да[^3] | ❌ Нет |
| Immutable native | ✅ Да[^1] | ❌ Нет | ✅ Да |
| Payment connectors | ❌ Нет | ⚠️ Частично | ✅ Да[^6] |
| Kubernetes/Helm | ✅ Helm charts[^22] | ⚠️ Да | ✅ Да |
| Terraform IaC | ✅ Да[^23] | ⚠️ Community | ✅ Да |

***

## Часть 3. Платёжная инфраструктура (Payment Rails)

### 3.1 BaaS-провайдеры (UK + EU)

Banxe как EMI не имеет прямого доступа к UK payment schemes — используются BaaS-партнёры:[^29]

| Провайдер | Схемы | Тип | Статус |
|---|---|---|---|
| **ClearBank** | FPS, CHAPS, BACS | Full UK Banking Licence, API-first[^29] | P0 — первичный UK rails |
| **Modulr** | FPS, BACS, CHAPS, SEPA, SEPA Instant[^30][^31] | UK EMI, API-first | P0 — UK + EU rails |
| **Banking Circle** | SEPA, multi-currency IBANs | EU bank | P1 — EUR расчёты |

[ФАКТ] ClearBank описывается как "enabler of real-time clearing and embedded banking", обеспечивает прямой API-доступ к FPS, BACS, CHAPS, FSCS-protected accounts; недавно запустил партнёрство с Plaid для open banking payments.[^32][^29]

[ФАКТ] Modulr как EMI предоставляет виртуальные счета, FPS/BACS/CHAPS/SEPA programmatic payments; в июне 2025 реализовал SEPA Verification of Payee.[^30][^31][^33]

### 3.2 Hyperswitch — Open-Source Payment Orchestration

[ФАКТ] Hyperswitch (Juspay) — open-source modular payments platform, лицензия Apache 2.0; 40,000+ GitHub stars; обрабатывает до 175 миллионов транзакций в день; поддерживает 50+ PSP (Adyen, Stripe, PayPal, Worldpay и др.).[^34][^35][^36]

[ФАКТ] В марте 2025 Hyperswitch вышел на US, EU и UK рынки; поддерживает intelligent routing, 3DS, fraud management, token vault, reconciliation и unified analytics.[^34]

**Роль в Banxe:** Payment orchestration layer между Midaz CBS и внешними PSP/BaaS провайдерами — позволяет routing, failover, cost optimization между ClearBank, Modulr и другими коннекторами.

### 3.3 Mifos Payment Hub EE

[ФАКТ] Payment Hub EE — open-source payments orchestration engine с connectorized architecture, поддерживающий core banking systems, switching networks и payment rail components; признан Digital Public Good.[^37][^38][^39]

**Роль в Banxe:** Если потребуется Mojaloop interoperability или сложная multi-rail orchestration за пределами западной инфраструктуры.

***

## Часть 4. Compliance, AML и KYC стек

### 4.1 Marble — Transaction Monitoring и Case Management

[ФАКТ] Marble — open-source real-time decision engine для fraud и AML, предназначенный для PSPs, neobanks, BaaS и marketplace; включает rule builder, batch + real-time transaction monitoring, case management для investigation.[^40][^41]

[ФАКТ] В марте 2025 Marble интегрировался с OpenSanctions, создав "первое полностью open-source решение для transaction screening", self-hosted и privacy-first. Активные production releases подтверждены репозиторием.[^42][^43]

**Роль в Banxe:** PRIMARY AML case management (порт 5003 в документе). AI-агенты триггерят cases через Marble API, MLRO и compliance-офицеры обрабатывают через Marble UI (HITL).

### 4.2 Jube — ML Transaction Scoring

[ФАКТ] Jube — open-source AML software и fraud detection platform с real-time transaction monitoring, AI/ML scoring, case management, AGPLv3 license. Поддерживает FATF compliance framework, anomaly detection, classification через rule-based и ML модели.[^44][^45][^46]

**Роль в Banxe:** ML scoring adapter (порт 5001 в документе). Jube classifies risk per transaction → Marble case если score превышает threshold.

### 4.3 OpenSanctions / Yente — Sanctions и PEP Screening

[ФАКТ] Yente — open-source Docker-based API server для screening против sanctions databases; автоматически загружает и обновляет данные OFAC, HMT (UK), UN, EU и PEP databases; требует ElasticSearch (~16GB RAM); обновления несколько раз в день.[^47][^48]

[ФАКТ] OpenSanctions бесплатен для некоммерческого использования; для бизнеса — платная лицензия на данные, но self-hosted yente — flat-rate и остаётся на инфраструктуре компании; данные клиентов никуда не передаются.[^47]

**Роль в Banxe:** yente-adapter (порт 8084 в документе). Используется совместно с Marble для real-time sanction + PEP screening при onboarding и transaction monitoring.

### 4.4 Moov Watchman — OFAC/HMT Screening

[ФАКТ] Moov Watchman — high-performance open-source compliance screening tool для AML/CTF/KYC/OFAC; автоматически загружает US OFAC, US CSL, UK, EU sanctions lists; использует Jaro-Winkler fuzzy matching; HTTP API + Go library; не требует external database.[^49][^50][^51]

**Роль в Banxe:** watchman-adapter (порт 8084 в документе) — дополнительный слой screening, особенно для UK HMT и OFAC.

### 4.5 Ballerine — KYC/KYB Workflow Engine

[ФАКТ] Ballerine — open-source risk management infrastructure; включает workflow engine, case management, KYC/KYB collection flow, rule engine, unified API для 3rd-party vendors; позволяет интегрировать Sumsub, Onfido, Jumio через единый слой. Поднял $5M seed от Team8.[^52][^53][^54]

**Роль в Banxe:** Опциональный KYC/KYB orchestration layer — вместо прямой интеграции с IDV-провайдером позволяет менять вендора без переписывания кода.

### 4.6 IDV провайдеры (SaaS, API-first)

| Провайдер | Функциональность | Рекомендация |
|---|---|---|
| **Sumsub** | IDV, liveness, NFC ICAO 9303, KYB, AML | P0 — primary IDV UK+EU[^27] |
| **Onfido** | Document OCR, biometric liveness | P0 — alternative/backup[^27] |
| **Companies House API** | KYB, UBO check (UK) | P0 — free, FCA-required[^27] |

### 4.7 Fraud Prevention

[ФАКТ] Документ Banxe рекомендует Sardine.ai как API-first pre-transaction scoring с <100ms latency для fraud layer. Для AML detection в pipeline используется Jube adapter.[^27]

| Компонент | Инструмент | Статус |
|---|---|---|
| Pre-transaction fraud scoring | Sardine.ai / Featurespace ARIC | P1 — SaaS API[^27] |
| Velocity rules | txmonitor + Redis | P0 — open source |
| APP scam detection | Custom rules + Sardine | P1[^27] |
| 3DS | BIN sponsor (Monavate) | P1 |

***

## Часть 5. Safeguarding Engine (CASS 15 — критический P0)

### 5.1 Регуляторный контекст

[ФАКТ] FCA PS25/12 (вступает в силу 7 мая 2026) вводит обязательные ежедневные reconciliations, monthly safeguarding returns через RegData, annual safeguarding audit для EMI, CASS 10A resolution pack (48h retrieval).[^55][^56][^18]

[ФАКТ] Среднее покрытие клиентских средств при несостоятельности платёжных фирм исторически составляло ~35% (65% shortfall), что и стало причиной введения CASS 15.[^17]

### 5.2 Реализация Safeguarding Engine

[ВЫВОД] Для Banxe нет готового open-source "safeguarding engine" — он строится как custom microservice поверх CBS (Midaz) с использованием следующих компонентов:

| Компонент | Решение | Обоснование |
|---|---|---|
| Outstanding e-money balance | Midaz Ledger → PostgreSQL | Источник правды[^1] |
| Safeguarding bank balance | BaaS API (Barclays/HSBC) → polling | Внешняя bank API[^27] |
| Daily reconciliation (CASS 15.8) | Custom cron job → Midaz API + Bank API | Ежедневно в reconciliation day[^18] |
| Shortfall alert | n8n workflow → MLRO Telegram | Немедленное уведомление[^27] |
| Monthly FCA return | n8n automation → FCA RegData | Автоматически[^18] |
| Annual audit | External auditor | Обязательно для >£100k[^56] |
| CASS 10A resolution pack | ClickHouse + PostgreSQL backup | 48h retrieval SLA[^17] |

***

## Часть 6. AI-агенты и HITL архитектура

### 6.1 Принцип операционной модели Banxe

[ФАКТ] Регуляторы и industry best practices требуют HITL controls в банкинге для moderate и high-risk decisions; рекомендованная целевая эскалационная ставка: 10-15% всех решений → человеку, 85-90% → автоматически.[^57][^58]

[ФАКТ] KPMG описывает agent passports как механизм отслеживания evolution, authority levels и decisions AI-агентов; организации с наибольшим успехом встраивают агентов в существующие структуры управления.[^27]

### 6.2 Уровни автономности агентов

| Уровень | Тип решения | Агент / Человек |
|---|---|---|
| L1 Auto | KYC score >95%, velocity check OK | Агент автоматически → approve |
| L2 Review | KYC score 70-95%, sanctions yellow | Агент флаг → compliance officer review |
| L3 MLRO | SAR trigger, Cat B EDD, large TX | Агент готовит пакет → MLRO approval |
| L4 Board/Invariant | Emergency stop (I-21 to I-25) | Только человек[^27] |

### 6.3 AI Infrastructure Stack

| Компонент | Инструмент | Назначение |
|---|---|---|
| LLM Inference | Ollama (Qwen3, GLM-4) | Локальный self-hosted inference[^27] |
| PII Protection | Microsoft Presidio (MIT)[^59][^60] | Обязательный PII proxy перед LLM |
| HITL Terminal | Telegram bot (mycarmimoabot) | MLRO/compliance HITL UI[^27] |
| Case Management | Marble (5002-5003) | AI-агенты создают cases, люди закрывают[^41] |
| Agent Evaluation | promptfoo (cron evals) | Adversarial testing, red-teaming[^27] |
| Workflow Automation | n8n (self-hosted, 5678) | Compliance workflow orchestration[^61] |
| Agent Passports | YAML + governance registry | Authority, capabilities, change class[^27] |

[ФАКТ] Microsoft Presidio — open-source SDK для PII detection и anonymization в тексте и изображениях; Python framework, Docker deployment; MIT лицензия; позволяет удалять/маскировать PII перед отправкой в LLM, что критично для FCA/GDPR compliance.[^62][^63][^60][^59]

[ФАКТ] n8n — open-source workflow automation platform с 200+ built-in интеграциями; самохостинг обеспечивает полный контроль данных и compliance; специально адаптирован для fintech compliance workflows: KYC onboarding, AML monitoring, regulatory reporting.[^61][^64]

***

## Часть 7. Технологическая инфраструктура

### 7.1 Базы данных и хранилища

| Роль | Технология | Обоснование |
|---|---|---|
| Primary relational DB | PostgreSQL 5432 | CBS, customer records, audit tables[^1] |
| Append-only audit trail | ClickHouse 9000, TTL 5 лет | DORA Art. 14, immutable audit[^27][^65] |
| Cache / Velocity tracking | Redis / Valkey 6379 | txmonitor, session, token[^1] |
| Metadata / flexible schema | MongoDB | Midaz Onboarding metadata[^1] |
| High-perf ledger option | TigerBeetle (опция) | 42k TPS, 2.8x быстрее PostgreSQL[^66] |

[ФАКТ] TigerBeetle — специализированная финансовая БД для double-entry accounting; в benchmarks показала 42k TPS vs 15k TPS PostgreSQL-batched; latency ~1.3ms; написана на Zig, fault-tolerant consensus protocol. Может использоваться как hot-path транзакционный слой под Midaz.[^67][^66]

[ФАКТ] ClickHouse — open-source OLAP база данных для real-time analytics; хорошо подходит для append-only audit trail с TTL-retention; нативные коннекторы к Grafana, Kafka, Prometheus.[^65]

### 7.2 Event Streaming и Messaging

| Компонент | Технология | Порт / Роль |
|---|---|---|
| Primary event bus | Kafka / Pulsar | Payment events, audit event log[^27] |
| Internal messaging (Midaz) | RabbitMQ | Transaction lifecycle events[^1] |
| API Gateway | Kong / AWS API GW | Rate limiting, OAuth2, developer portal[^27] |
| Service Mesh | Istio / Linkerd (mTLS) | mTLS между сервисами[^27] |
| Secrets Management | HashiCorp Vault (ZSP/JIT) | Zero-standing privileges[^27] |

### 7.3 Observability и безопасность

| Компонент | Технология |
|---|---|
| Metrics / Tracing | OpenTelemetry + Grafana[^1] |
| HSM | Hardware Security Module для PIN encryption[^27] |
| DR/BCP | AWS/GCP active-passive replica[^27] |
| Compliance API | FastAPI (8090) для compliance microservice[^27] |

***

## Часть 8. Полная карта компонентов (единый стек)

### 8.1 Layer-by-layer архитектура

```
┌─────────────────────────────────────────────────────────────┐
│  CUSTOMER LAYER                                              │
│  React Web App / Mobile / Open Banking OBIE API             │
└────────────────────────┬────────────────────────────────────┘
                         │ OAuth2 / mTLS
┌────────────────────────▼────────────────────────────────────┐
│  API GATEWAY (Kong / AWS API GW)                             │
│  Rate Limiting, Auth, Developer Portal                       │
└────────────────────────┬────────────────────────────────────┘
                         │
      ┌──────────────────┼──────────────────┐
      │                  │                  │
┌─────▼──────┐  ┌────────▼───────┐ ┌───────▼────────┐
│  KYC/KYB   │  │  COMPLIANCE    │ │  PAYMENTS      │
│  Ballerine │  │  Marble+Jube   │ │  Hyperswitch   │
│  Sumsub    │  │  OpenSanctions │ │  + BaaS APIs   │
│  Companies │  │  Watchman      │ │  ClearBank     │
│  House API │  │  Presidio PII  │ │  Modulr        │
└─────┬──────┘  └────────┬───────┘ └───────┬────────┘
      │                  │                  │
      └──────────────────▼──────────────────┘
                         │ Events / API calls
┌────────────────────────▼────────────────────────────────────┐
│  PRIMARY CBS: MIDAZ (LerianStudio)                           │
│  Onboarding Domain | Transaction Domain                      │
│  PostgreSQL + MongoDB | RabbitMQ | Go microservices          │
│  Apache 2.0 | Event-driven | Immutable | CQRS                │
└────────────────────────┬────────────────────────────────────┘
                         │ Events
┌────────────────────────▼────────────────────────────────────┐
│  EVENT STREAMING: Kafka / Pulsar                             │
│  Payment Events | Audit Events | Alert Triggers             │
└────────────────────────┬────────────────────────────────────┘
                         │
      ┌──────────────────┼──────────────────┐
      │                  │                  │
┌─────▼──────┐  ┌────────▼───────┐ ┌───────▼────────┐
│  AUDIT     │  │  AI AGENTS     │ │  OBSERVABILITY │
│  ClickHouse│  │  Ollama LLM    │ │  OpenTelemetry │
│  Append-   │  │  n8n Workflow  │ │  Grafana       │
│  only 5yr  │  │  HITL: Marble  │ │  Prometheus    │
│  TTL       │  │  + Telegram    │ │                │
└────────────┘  └────────────────┘ └────────────────┘
```

### 8.2 Полная таблица компонентов стека

| Домен | Компонент | Технология | Лицензия | Источник |
|---|---|---|---|---|
| **PRIMARY CBS** | Core Ledger / Accounts | Midaz (LerianStudio) | Apache 2.0[^19] | github.com/LerianStudio/midaz[^1] |
| **FALLBACK CBS** | Core Banking (loans etc.) | Apache Fineract | Apache 2.0[^4] | fineract.apache.org |
| **LEDGER OPTION** | Programmable money-flow | Formance Ledger | Apache 2.0[^5] | github.com/formancehq/ledger |
| **DB: HOT LEDGER** | High-perf transactions | TigerBeetle (опция) | Apache 2.0 | tigerbeetle.com[^67] |
| **DB: PRIMARY** | Relational data | PostgreSQL | Open Source | postgresql.org |
| **DB: AUDIT** | Append-only audit trail | ClickHouse | Apache 2.0[^65] | clickhouse.com |
| **DB: CACHE** | Velocity, sessions | Redis / Valkey | BSD | redis.io |
| **DB: METADATA** | Flexible schema | MongoDB | SSPL | mongodb.com |
| **PAYMENT RAILS** | FPS, CHAPS, BACS (UK) | ClearBank BaaS | Commercial[^29] | clear.bank |
| **PAYMENT RAILS** | FPS, SEPA, BACS | Modulr BaaS | Commercial[^30] | modulr.finance |
| **PAYMENT RAILS** | SEPA, multi-currency | Banking Circle | Commercial | bankingcircle.com |
| **PAYMENT ORCH** | PSP routing, 3DS | Hyperswitch | Apache 2.0[^34] | github.com/juspay/hyperswitch |
| **KYC/KYB FLOW** | Onboarding workflow | Ballerine | Open Source[^52] | github.com/ballerine-io/ballerine |
| **IDV** | Document + Liveness | Sumsub | Commercial | sumsub.com |
| **IDV** | Document OCR | Onfido | Commercial | onfido.com |
| **KYB** | UBO, Company check | Companies House API | Free (Gov UK) | developer.companieshouse.gov.uk |
| **AML/TM** | Transaction Monitoring + Cases | Marble | Open Source[^41] | github.com/checkmarble/marble |
| **ML SCORING** | AML/Fraud ML engine | Jube | AGPLv3[^45] | github.com/jube-home/aml-fraud-transaction-monitoring |
| **SANCTIONS** | Self-hosted sanctions/PEP | OpenSanctions/Yente | OSS + data license[^47] | opensanctions.org/docs/on-premise |
| **SANCTIONS** | OFAC/HMT/UN screening | Moov Watchman | Apache 2.0[^50] | github.com/moov-io/watchman |
| **FRAUD** | Pre-tx fraud scoring | Sardine.ai | Commercial | sardine.ai |
| **PII** | LLM input anonymization | Microsoft Presidio | MIT[^59] | github.com/microsoft/presidio |
| **LLM** | Local AI inference | Ollama (Qwen3, GLM) | MIT | ollama.ai |
| **WORKFLOW** | Compliance automation | n8n (self-hosted) | Fair-code[^61] | n8n.io |
| **EVENTS** | Payment/audit event log | Kafka / Pulsar | Apache 2.0 | kafka.apache.org |
| **API GW** | Rate limiting, auth | Kong / AWS API GW | Open Core | konghq.com |
| **SECRETS** | ZSP/JIT secrets | HashiCorp Vault | BSL | vaultproject.io |
| **CARDS** | BIN sponsor, 3DS | Monavate | Commercial | monavate.com |
| **INFRA** | K8s deployment | Kubernetes + Helm | Apache 2.0 | kubernetes.io |
| **IaC** | Cloud infra | Terraform | MPL 2.0 | terraform.io |
| **SERVICE MESH** | mTLS service-to-service | Istio / Linkerd | Apache 2.0 | istio.io |
| **MONITORING** | Metrics, tracing | OpenTelemetry + Grafana | Apache 2.0 | grafana.com |
| **HITL TERMINAL** | Human override UI | Telegram bot (mycarmimoabot) | N/A | Внутренний |
| **AGENT EVAL** | Red-teaming, evals | promptfoo | Open Source | promptfoo.dev |

***

## Часть 9. Phased Roadmap (Пересобранный)

### Phase 0: Pre-Launch FCA (Месяцы 1-3)

**Критический P0 — без этого FCA authorization невозможна:**

1. **SMF-holders**: CEO (Moriel Carmi), MLRO (interim outsourced), CCO, CRO, CFO — регистрация в FCA Connect[^27]
2. **Midaz deployment**: Docker Compose → локальный сервер (GMKtec); Onboarding domain: org → ledger (GBP) → accounts; Transaction domain: FPS inbound/outbound flow
3. **BaaS onboarding**: ClearBank или Modulr — sandbox API, FPS test flows
4. **Safeguarding account**: открыть у Barclays/HSBC; cron-reconciliation скрипт (Midaz balance vs bank API)[^18]
5. **IDV Integration**: Sumsub sandbox → production KYC; Companies House API для KYB
6. **AML Pipeline**: Marble + Jube + Yente/Watchman → базовые velocity rules и sanctions screening
7. **PII Proxy**: Presidio → обязателен для всех LLM calls[^60]
8. **CASS 15 Preparation**: daily reconciliation tooling, resolution pack structure, FCA RegData test submission[^18]

### Phase 1: MVP Launch (Месяцы 4-6)

9. **Kafka event streaming**: payment events → ClickHouse append-only audit trail
10. **Complaints workflow**: n8n DISP flow, 8-week timer, FOS escalation
11. **Customer App**: React web-portal — onboarding, account view, payment initiation
12. **SEPA/EUR**: Banking Circle onboarding, EUR ledger в Midaz
13. **FX Engine**: rate management, Midaz multi-currency
14. **HITL Telegram**: MLRO Marble review workflow, agent passport YAML

### Phase 2: Growth (Месяцы 7-12)

15. **Cards**: Monavate BIN sponsor, virtual/physical, 3DS
16. **PCI DSS**: QSA assessment, CDE mapping
17. **Open Banking**: OBIE registration, PIS/AIS API
18. **API Gateway**: Kong → developer portal, rate limiting
19. **DR/BCP**: GMKtec + AWS/GCP active-passive backup[^27]
20. **Hyperswitch**: PSP routing layer (Adyen/Stripe connectors для card processing)

### Phase 3: Scale (Год 2+)

21. **Agent Passports**: полная реализация YAML-based governance с change classification CLASS-A/CLASS-B
22. **Adversarial Simulations**: weekly cron promptfoo red-teaming для compliance AI
23. **TigerBeetle**: миграция hot-path transactions с PostgreSQL на TigerBeetle если >10k TPS
24. **SWIFT GPI**: direct connection через Geniusto → замена на Prowide/ISO 20022 tooling
25. **Formance Reconciliation**: для сложных FX/marketplace splits

***

## Часть 10. Gap Analysis: Geniusto → Open Stack

| Geniusto функция | Open-source замена | Статус |
|---|---|---|
| Core Ledger (accounts, balances, GL) | Midaz Ledger[^1] | ✅ Полное покрытие |
| Double-entry accounting | Midaz Transaction Domain[^2] | ✅ Полное покрытие |
| Multi-currency accounts | Midaz Assets + multi-ledger | ✅ Полное покрытие |
| Loan products | Fineract (если нужно)[^3] | ✅ Fallback |
| eKYC / eKYB | Ballerine + Sumsub + Companies House | ✅ Полное покрытие |
| AML monitoring | Marble + Jube[^40][^45] | ✅ Лучше чем Geniusto |
| Sanctions / PEP screening | Yente + Watchman[^47][^50] | ✅ Полное покрытие |
| Payment hub / routing | Hyperswitch + BaaS[^34] | ✅ Полное покрытие |
| SWIFT connectivity | Prowide Core (ISO 20022, Apache 2.0) | ✅ С доп. интеграцией |
| Omni-channel / UI | Custom React + n8n | ⚠️ Нужна разработка |
| PSD2 / Open Banking | adorsys / WSO2 / OBIE | ⚠️ Phase 2 |
| Low-code config | Midaz API + n8n workflow | ⚠️ Менее out-of-box |
| FCA reporting | n8n automation + FastAPI | ✅ Через CASS 15 engine |
| Safeguarding engine | Custom cron + Midaz API | ✅ P0 buildout |
| AI monitoring | Marble + Jube + Ollama | ✅ Превосходит Geniusto |
| HITL governance | Marble cases + Telegram HITL | ✅ Уникальная возможность |

***

## Часть 11. Решение противоречия в документации

**Что было:** Apache Fineract указан как CBS в тексте и Roadmap Phase 0.  
**Что должно быть:** Midaz PRIMARY, Fineract FALLBACK.  
**Причина расхождения:** Ранняя версия документа (file:536) опиралась на традиционный open-source выбор; Midaz появился позднее и не был учтён.

**Консолидированное решение:**

[ФАКТ] Midaz превосходит Fineract по ключевым AI-native критериям: event-driven архитектура, Go (cloud-native), CQRS, immutable ledger; Fineract зрелее, но создан до cloud-native эпохи.[^3][^20][^1]

[ФАКТ] Для EMI (не кредитный бизнес) loan modules Fineract не нужны — это снимает его главное преимущество перед Midaz.[^3]

[ВЫВОД] **Banxe должен начать с Midaz как PRIMARY CBS.** Если в процессе развёртывания команда столкнётся с production-readiness gaps (молодость платформы), параллельно готовится Fineract fallback deployment. Formance Ledger — опция для scenarios с программируемым money-flow.

***

## Часть 12. Регуляторные сроки и критические зависимости

| Дедлайн | Требование | Зависимость |
|---|---|---|
| **7 мая 2026** | FCA CASS 15 daily reconciliation, monthly returns[^18] | Safeguarding engine P0 |
| **FCA Authorization** | SMF-holders, MLRO, compliance function | Governance P0[^27] |
| **DORA (ongoing)** | 5yr append-only audit trail[^27] | ClickHouse P1 |
| **GDPR / UK GDPR** | PII anonymization в AI pipelines[^60] | Presidio P0 |
| **PSR APP 2024** | APP scam detection, reimbursement | Fraud layer P1 |
| **Consumer Duty** | Fair outcomes MI, complaints SLA[^27] | n8n DISP P1 |

***

## Заключение

[ФАКТ] Banxe AI Bank может заменить Geniusto полностью open-source и коммерчески открытым стеком, где центральным элементом является **Midaz** — AI-native, cloud-native, event-driven ledger platform (Apache 2.0).[^20][^1]

[ВЫВОД] Главное преимущество open-stack перед Geniusto — **полный контроль**: над event hooks для AI-агентов, над compliance workflows, над safeguarding engine, над audit trail — что критично для модели, где AI-агенты являются операционными сотрудниками, а люди — дублёрами с правом override.[^58][^57]

[ВЫВОД] Это не "бесплатный продукт, заменяющий Geniusto" — это **composable financial operating system**: 7-8 открытых компонентов + 3-4 BaaS/SaaS API-first партнёра, объединённых event-driven шиной, Kafka, и AI-агентным оркестрационным слоем (OpenClaw/MetaClaw).

---

## References

1. [Lerian Midaz: Enterprise-Grade Open-Source Ledger System - GitHub](https://github.com/lerianstudio/midaz) - Lerian Midaz is a modern, open-source ledger system designed for building financial infrastructure t...

2. [About Midaz - Lerian Docs](https://docs.lerian.studio/en/midaz/about-midaz) - Midaz is a domain-driven ledger platform designed for reliability, flexibility, and governance. ... ...

3. [Understanding Apache Fineract: A Scalable Core Banking Engine ...](https://blogs.fintrens.com/understanding-apache-fineract-a-scalable-core-banking-engine-for-the-digital-age/) - Introduction In an era where digital-first banking is reshaping financial landscapes, Apache Finerac...

4. [Apache Fineract®](https://fineract.apache.org)

5. [The programmable open source ledger for fintechs - GitHub](https://github.com/formancehq/ledger) - The programmable open source core ledger for fintech - formancehq/ledger

6. [formancehq/stack: Open Source Infrastructure for the Financial Internet](https://github.com/formancehq/stack) - Formance Ledger - Programmable double-entry, immutable source of truth to record internal financial ...

7. [CASS 15 – payment services and e-money - Johnston Carmichael](https://johnstoncarmichael.com/insights/cass-15-payment-services-and-e-money) - Firms must ensure that they have reliable data and effective systems and controls to support the acc...

8. [Geniusto GO-Suite: Advanced Core Banking with Payment ...](https://www.fintegrator.eu/analytics/geniusto) - Discover Geniusto GO-Suite, offering advanced payment system integration solutions for seamless bank...

9. [[PDF] The 2025 State of Open Source in Financial Services](https://www.linuxfoundation.org/hubfs/Research%20Reports/05_FINOS_2025_Report.pdf?hsLang=en) - And open source technologies are increasingly prevalent across all levels of the technology stack, i...

10. [Geniusto brings full digital banking services to Camalig Bank](https://business.inquirer.net/290818/geniusto-brings-full-digital-banking-services-to-camalig-bank) - The Omni-Channel Banking uses open API (application programming interface) to simplify the payment e...

11. [Transact Pro picks Geniusto tech platform - Finextra Research](https://www.finextra.com/pressarticle/88128/transact-pro-picks-geniusto-tech-platform) - Transact Pro, based in Riga, Latvia ( E.U.), has chosen Geniusto as its new banking ledger (core) sy...

12. [AGRIBANK goes live with their new, powerful Mobile Banking App ...](https://www.agribank.com.ph/AGRIBANK-goes-live-with-their-new-powerful-mobile-banking-app-provided-by-geniusto-international/) - Working in concert with Geniusto Mobile Banking is Oradian's advanced cloud-based core banking syste...

13. [SWIFT appoints Geniusto as a technology partner](https://geniusto.com/geniusto-joins-the-swift-partner-programme/) - Clients can now enjoy a seamless experience with enhanced transparency and traceability, ensuring th...

14. [Geniusto Pricing](https://www.g2.com/products/geniusto/pricing) - Learn more about the cost of Geniusto, different pricing plans, starting costs, free trials, and mor...

15. [[GO] Suite Pricing, Cost & Reviews - Capterra UK 2026](https://www.capterra.co.uk/software/1049396/go-suite) - The Geniusto [GO] Suite is a robust, all-in-one software platform for Banks, EMIʼs, and Payment Prov...

16. [Why - Geniusto](https://geniusto.com/why/) - Future-proof your systems—with more brains behind them. Manage the challenges of the digital economy...

17. [New Safeguarding Rules for Payment & E‑Money Firms - Ramparts](https://ramparts.gi/new-safeguarding-rules-for-payment-e-money-firms/) - Perform both internal and external safeguarding reconciliations at least once each reconciliation da...

18. [Safeguarding: How Payment and E-money Firms Can Stay ...](https://aurum.solutions/resources/safeguarding-how-payment-and-e-money-firms-can-stay-compliant-with-cass-15) - Prepare for the FCA's new safeguarding rules for May 2026. Automate reconciliation and strengthen co...

19. [GitHub - LerianStudio/midaz-sdk-golang](https://github.com/LerianStudio/midaz-sdk-golang) - This project is licensed under the Apache License, Version 2.0 - see the LICENSE.md file for details...

20. [Introducing Midaz, an open-source core banking stack for fintechs ...](https://www.linkedin.com/posts/anujcodes21_breaking-the-first-open-source-core-banking-activity-7349129830048636929-0V03) - The Latin American-born ledger that's rewriting financial infrastructure: Open-core, AI-native (Gene...

21. [CHANGELOG.md - LerianStudio/midaz-sdk-typescript - GitHub](https://github.com/LerianStudio/midaz-sdk-typescript/blob/main/CHANGELOG.md) - Release Process: Enhanced the release management process with multiple updates to the CHANGELOG, ens...

22. [GitHub - LerianStudio/helm: Official Helm charts for deploying Midaz ...](https://github.com/LerianStudio/midaz-helm) - Official Helm charts for deploying Midaz, Reporter, Tracer, Matcher, and the full ecosystem of plugi...

23. [LerianStudio/midaz-terraform-foundation - GitHub](https://github.com/LerianStudio/midaz-terraform-foundation) - This project contains the entire foundation infrastructure base in the 3 main public clouds for the ...

24. [123: Core Banking in an Open World - W Fintechs Newsletter](https://wfintechs.substack.com/p/123-corebanking-en) - Core banking is the operating system of the financial sector. From fintechs to large banks, all dail...

25. [Core features - Lerian Docs](https://docs.lerian.studio/en/midaz/core-features) - Midaz natively publishes events for real-time tracking and integration, allowing seamless observabil...

26. [Lerian Studio Case Study | Distr](https://distr.sh/case-studies/lerian/) - How Lerian uses Distr to power their Lifecycle Management platform for banking and financial infrast...

27. [BANXE-AI-Bank-Nalozhenie-na-etalonnuiu-strukturu-UK-EMI-polnaia-karta-pokrytiia-probelov-i-priori.md](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/101434432/2dd1174a-d609-4f7c-8209-1d82e10860c9/BANXE-AI-Bank-Nalozhenie-na-etalonnuiu-strukturu-UK-EMI-polnaia-karta-pokrytiia-probelov-i-prioritetov-vospolneniia.md?AWSAccessKeyId=REDACTED_AWS_TOKEN&Signature=x%2F%2FxvOWGWm9sMfTqg56rfndyhNY%3D&x-amz-security-token=IQoJb3JpZ2luX2VjEAIaCXVzLWVhc3QtMSJGMEQCIAizPbpwe84U8ffGTufO2DFlH69vP%2BpCoESu5ClqNckQAiBocc2wwJC3Id%2Bsm80KS%2BCbVra9zJChv97wDsEGQXPjRir8BAjK%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAEaDDY5OTc1MzMwOTcwNSIMoaD27%2ByiFRvGqYTWKtAErxeEViOGC9oT%2F3ombTIde136npIvTe6PRBLwNJPUftC7XX8v%2BtrwdnghALQuYoPCqIQQiv8Z3%2BifZJWuqozOWin6Unh4616sbdkTkSS95MfS7JLasSF2VEPd8oREISrK1a%2F08ZP0vh81FiIf9lNdfUaB6IcKmC%2F5jCzxnW26HI2rL2FbUfZuo664TwN%2BHW6wZ7GlLO4AdoRSE78TxYSGqFQkXk%2B8sZGWt6AIBskQYnFy8o4Xt73urb0Kh6NF9CpQ2Vms9WR99%2FP8%2BumgXA4E%2Bpclae3c8hwuVmipVXZ9zOODo3%2Fe5tTxty2Ak7ZDzDkd0YT4zNFx%2FgsBNvlc%2FdPu6WodTmbPY8n8sUO%2F7%2B8KjNnBmFFltqUQU4YwDSwHxVlsrg9eXEgFakjIbFLFaiifnKimm%2BxP9UjuJF75ki2vzyNmS6y2TAW1C1Vh9mVPxUrv1RoDZh1W100R9Fa%2FdgWOu9ZT00G%2FAPR9jTl634hlHqErtEdZnH0D8DUVIwHCcN0lq7l20UuiaGgpTjac%2F3bgmbxEWgafypCBXhlQsIFIaozMq4Gp4m04h3C%2BWh3WVPfKGdG1%2Fq4HdLs0g7IfG1FAkbkinu%2BNmbKT8NKtdE72cqTP%2FkuOwLfRolCcMkDEz42OioPVMGATaXBWZAj70N8Ch8ogPMMbnpSr5y9VrVvvXN1v1O4qlIehDAg4qcZIh72ONTpbmq8tkSsNWCh%2FoSviL3FrDPCZIdbfyZSRcfM9fDrh2cW1ZIRNlzjVuqSTLhBlvKi7B%2FUz%2FAetbnWqz1xS9zCS783OBjqZAWOlZg0FvO9iaszTEh9q4alUo45I6%2BFJlpdZBQa8PtpBSdvg8jSdxLpg%2FBjub%2BkA7CT7i2U%2Bjl3shd2FPi7cSGhzG%2BMAJu6JkpQfaFzgTJfSD5JUEFKeQIDf%2FbMGZjkB8PXkq5TnkHRVpUFNRb0mG0XU9WJpp3PslpFyeya22UHkqu6cQKqPO0J%2B%2F5vzBwNpDBYMflV7ITYBLg%3D%3D&Expires=1775469925) - 2026 BANXE AI Bank SERVICE-MAP.md 2026-04-05 3035 UK EMI. ComplianceAML- 5570 0, TreasuryALM 0 Core ...

28. [This project tries to reconciliate your Ledger's transactions flow with ...](https://github.com/formancehq/reconciliation) - Formance Reconciliation compares balances between your Formance Ledger and cash pools to verify fina...

29. [Best BaaS Providers in the UK - Gemba Finance](https://ge.mba/research/best-baas-providers-in-the-uk) - ClearBank provides direct API access to all major UK payment schemes, including Faster Payments, BAC...

30. [ModConnect June 2025 - Modulr Developer](https://modulr.readme.io/changelog/modconnect-june-2025) - In June 2024, the Open Banking Implementation Entity released Version 4 of the Open Banking API stan...

31. [Modulr launches SEPA Instant service - Fintech Finance](https://ffnews.com/newsarticle/modulr-launches-sepa-instant-service-to-supercharge-real-time-european-business-payments/) - The new service enables customers to build and launch embedded real-time Euro payment propositions v...

32. [ClearBank partners with Plaid to power real-time open banking…](https://clear.bank/learn/news/clearbank-partners-with-plaid-to-power-real-time-open-banking-payments-in-the-uk) - ClearBank partners with Plaid to power real-time open banking payments in the UK. News — 4th Decembe...

33. [6 Best Embedded Payments APIs in the UK for 2025](https://blog.finexer.com/best-embedded-payments-apis/) - Looking to add embedded payments to your B2B platform? Find top 6 UK APIs that support Pay by Bank, ...

34. [Hyperswitch by Juspay: World's First Open-Source Payment ...](https://ffnews.com/newsarticle/paytech/hyperswitch-by-juspay-worlds-first-open-source-payment-orchestration-platform-expands-to-the-us-europe-and-uk/) - This includes advanced functionalities like intelligent routing, customizable checkout, secure token...

35. [Hyperswitch: Modular, Open-Source and Full-Stack Payments Platform](https://www.youtube.com/watch?v=SWAaMmRFshU) - ... payments #orchestration #opensource #opensourcecommunity #innovation #paymentsolutions #engineer...

36. [juspay/hyperswitch-prism: Open-Source Payments Connector Service](https://github.com/juspay/hyperswitch-prism) - A high-performance payment abstraction library, and part of Juspay Hyperswitch — the open-source, co...

37. [mifos-documentation/payment-hub-ee/overview/README.md at ...](https://github.com/openMF/mifos-documentation/blob/master/payment-hub-ee/overview/README.md) - The Payment Hub is a self contained application to enable a financial institution (DFSP - digital fi...

38. [Payment Hub EE - Digital Public Good for Orchestrating Payments](https://www.youtube.com/watch?v=osngBv7NA2k) - Overview of Payment Hub EE - a modern orchestration engine for payments enabling a number of use cas...

39. [openMF/ph-ee-start-here: Payment Hub Enterprise Edition ... - GitHub](https://github.com/openMF/ph-ee-start-here) - Payment Hub Enterprise Edition middleware for integration to real-time payment systems. For detailed...

40. [Marble - the real time decision engine for fraud and AML - GitHub](https://github.com/checkmarble/marble) - Marble is the flexible alternative to Comply Advantage, Actimize or Fiserv for Transaction Monitorin...

41. [What is Marble?](https://docs.checkmarble.com/docs/what-is-marble) - Marble is the only Open-Source Fraud and Compliance automation platform for Transaction Monitoring, ...

42. [Releases · checkmarble/marble - GitHub](https://github.com/checkmarble/marble/releases) - Bug fixes. In the case manager, the cases count in inboxes now only counts open cases; Case search b...

43. [Marble & OpenSanctions team up for the first fully open source ...](https://discuss.opensanctions.org/t/marble-opensanctions-team-up-for-the-first-fully-open-source-transaction-monitoring-solution/71) - Our open source friends at Marble have built a transaction screening platform with our data collecti...

44. [Welcome | aml-fraud-transaction-monitoring](https://jube-home.github.io/aml-fraud-transaction-monitoring/) - Jube is open-source, real-time, Anti-Money Laundering and Fraud Detection Transaction Monitoring sof...

45. [jube-home/aml-fraud-transaction-monitoring: Open-source ...](https://github.com/jube-home/aml-fraud-transaction-monitoring) - Open source AML and Fraud Detection using Machine Learning for Real-Time Transaction Monitoring - ju...

46. [[PDF] Anti-Money Laundering (AML) Monitoring Compliance Guidance ...](https://jube.io/JubeAMLMonitoringComplianceGuidance.pdf) - This document outlines a framework designed to assist in monitoring compliance with. Anti-Money Laun...

47. [Should I use the SaaS API or a yente on-premise? - OpenSanctions](https://www.opensanctions.org/faq/163/license-cost/) - Pros: Unlimited internal usage; Customer data remains entirely on your systems; Ideal for large-scal...

48. [On-premise OpenSanctions API](https://www.opensanctions.org/docs/on-premise/) - The API server application, yente, is simple to install and will update itself with the latest OpenS...

49. [Introduction | Moov Watchman](https://moov-io.github.io/watchman/intro/) - Watchman delivers enterprise-grade compliance screening with: Data Management: Automatic downloading...

50. [moov-io/watchman: AML/CTF/KYC/OFAC Search of global ...](https://github.com/moov-io/watchman) - AML/CTF/KYC/OFAC Search of global watchlist and sanctions - moov-io/watchman

51. [Overview | Moov Watchman](https://moov-io.github.io/watchman/) - Moov Watchman is a high-performance sanctions screening and compliance tool that helps businesses me...

52. [Fintech Company Ballerine Announces $5 Million Seed Funding to ...](https://via.tt.se/pressmeddelande/3348530/fintech-company-ballerine-announces-5-million-seed-funding-to-deliver-open-source-risk-decisioning-platform?publisherId=259167) - Ballerine, an open-source risk decisioning platform, has raised $5 Million in a seed funding round l...

53. [Introduction - Ballerine Documentation](https://docs.ballerine.com/en/getting_started/introduction/) - Ballerine is an Open-Source Risk Management Infrastructure that helps global payment companies, mark...

54. [https://github.com/ballerine-io/ballerine | Ecosyste.ms: Awesome](https://awesome.ecosyste.ms/projects/github.com%2Fballerine-io%2Fballerine) - Ballerine is an Open-Source Risk Management Infrastructure that helps global payment companies, mark...

55. [[PDF] PS25/12: Changes to the safeguarding regime for payments and e ...](http://www.fca.org.uk/publication/policy/ps25-12.pdf) - Separate to the reconciliation requirements, payments firms are required to maintain records and acc...

56. [UK e-money and payment institutions must comply with new ...](https://www.ashurst.com/en/insights/uk-emoney-and-payment-institutions-must-comply-with-new-safeguarding-rules-from-7-may-2026/) - The new rules include more prescriptive requirements on reconciliation processes than the current gu...

57. [Agentic AI in Banking: From Architecture and Governance to a 90 ...](https://8allocate.com/blog/agentic-ai-in-banking-from-architecture-and-governance-to-a-90-day-pilot/) - Human Oversight and Intervention (HITL). No matter how autonomous an AI agent is, human-in-the-loop ...

58. [How to Build Human-in-the-Loop Oversight for AI Agents | Galileo](https://galileo.ai/blog/human-in-the-loop-agent-oversight) - This guide demonstrates how to build production-ready HITL systems that balance autonomous efficienc...

59. [Installing Presidio - Microsoft Open Source](https://microsoft.github.io/presidio/installation/) - This document describes the installation of the entire Presidio suite using pip (as Python packages)...

60. [Microsoft Presidio: An Open Source Tool Specialized in Personal ...](https://developer.mamezou-tech.com/en/blogs/2025/01/04/presidio-intro/) - Presidio is a Python framework designed to detect and anonymize personally identifiable information ...

61. [Fintech Automation with n8n: 8 Workflows for Compliance Teams](https://chronexa.io/blog/fintech-automation-with-n8n-8-workflows-for-compliance-teams) - This guide explores how fintech automation using n8n allows you to build self-healing, audit-proof c...

62. [Microsoft Presidio for PII Detection & Anonymization - LinkedIn](https://www.linkedin.com/pulse/microsoft-presidio-pii-detection-anonymization-rohit-khanna-cge9f) - Microsoft Presidio is an open-source SDK that identifies and anonymizes sensitive data (text, images...

63. [Why self-host Microsoft Presidio - Hoop.dev](https://hoop.dev/blog/why-self-host-microsoft-presidio) - Full control over sensitive data. A self-hosted instance of Microsoft Presidio gives you precision d...

64. [Top 10 Open-Source Tools for Workflow Automation | Collect Blog](https://www.usecollect.com/blog/top-10-open-source-tools-for-workflow-automation/) - n8n is a visual workflow automation platform that simplifies creating automated workflows through an...

65. [How to choose a database for real-time analytics in 2026 - ClickHouse](https://clickhouse.com/resources/engineering/how-to-choose-a-database-for-real-time-analytics-in-2026) - Fast open-source OLAP database for real-time analytics. ClickStack. Open-source observability stack ...

66. [TigerBeetle vs PostgreSQL Performance: Benchmark Setup, Local ...](https://softwaremill.com/tigerbeetle-vs-postgresql-performance-benchmark-setup-local-tests/) - In this article, we'll cover the test design and provide the results of initial, single-node, local ...

67. [1B Payments/Day - TigerBeetle & PostgreSQL | How It Works](https://backend.how/posts/1b-payments-per-day/) - TigerBeetle #. TigerBeetle is a high-performance, distributed financial database designed for missio...

