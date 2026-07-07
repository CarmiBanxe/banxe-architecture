---
title: "Open Source & Free AI Agent Solutions for Next-Generation Banking (BANXE AI Bank)"
source-origin: "operator Downloads (Legion), staged evo1 zero-loss"
intake-date: 2026-07-07
sha256-body: 50c2f6677d224d56917dee2f6560947eb334253d102f1a0dab3c6fe44ab6743b
body-bytes: 69737
verify: "tail -c 69737 <this-file> | sha256sum == sha256-body"
related-findings: "#1059 (OSS intake), #1051 (EMI-stack intake)"
status: SSOT-RESTORED
---
# Open Source & Free AI Agent Solutions for Next-Generation Banking (BANXE AI Bank)

> **Целевой контекст:** EMI BANXE AI Bank — сборка собственного агентного движка из открытых компонентов. Документ охватывает более 120 верифицированных open source проектов, фреймворков и инструментов с указанием лицензий, GitHub-репозиториев и банковской применимости.

***

## Executive Summary

2026 год — переломный для агентного ИИ в банкинге. По данным Oracle, банки переходят от пилотов к продуктивному развертыванию агентных систем, которые оркестрируют сервисы от онбординга до комплаенса. Согласно FinTech Futures, крупные банки движутся к полной операционализации AI-агентов уже в 2026 году. Для BANXE AI Bank это означает возможность собрать production-grade агентный движок из open source компонентов, избежав vendor lock-in и существенно снизив CAPEX.[^1][^2]

***

## 1. Агентные Фреймворки — Ядро Движка

### 1.1 Python-first фреймворки

#### LangGraph (LangChain Inc.)
- **Репозиторий:** https://github.com/langchain-ai/langgraph
- **Лицензия:** MIT
- **Суть:** Stateful graph runtime для многошаговых агентов — моделирует агентов как графы с явными узлами, рёбрами и состоянием. Kensho (S&P Global) использует LangGraph как фундамент унифицированного мульти-агентного фреймворка.[^3][^4]
- **Применение в банке:** оркестрация сложных рабочих процессов (KYC → AML → кредитный скоринг), stateful диалоги с клиентами, ветвление по бизнес-правилам.
- **Производительность:** в тестах 2026 года показал лучшие результаты для production-сценариев с комплексной логикой.[^5]

#### CrewAI
- **Репозиторий:** https://github.com/crewAIInc/crewAI
- **Лицензия:** MIT
- **Суть:** Role-based мульти-агентный фреймворк — команды агентов с ролями (аналитик, комплаенс-офицер, риск-менеджер) и структурированными задачами. Версия Enterprise 2025 года существенно расширила корпоративные возможности.[^6][^7]
- **Применение в банке:** имитация банковских команд (KYC-агент + AML-агент + Fraud-агент), параллельная обработка заявок.
- **Предупреждение:** На Reddit сообщалось о проблемах отладки в продакшене из-за непрозрачной архитектуры.[^8]

#### AutoGen / AG2 (Microsoft)
- **Репозиторий:** https://github.com/microsoft/autogen
- **Лицензия:** MIT
- **Суть:** Conversation-centric фреймворк; объединён с Semantic Kernel в единую платформу Microsoft Agent Framework. Преимущества для исследовательских и advisory сценариев с расширенными диалогами агентов.[^9][^10][^11]
- **Применение в банке:** финансовые исследования, внутренние advisory-боты для аналитиков, multi-turn комплаенс-диалоги.

#### Strands Agents SDK (Amazon/AWS)
- **Репозиторий:** https://github.com/strands-agents/sdk-python
- **Лицензия:** Apache 2.0
- **Суть:** Open source Python SDK от AWS Labs с model-driven подходом; задеплоен через `agentcore deploy` на Amazon Bedrock.[^12][^13]
- **Применение в банке:** memory-powered мульти-агентный финансовый советник с sub-агентами (портфель, рынок, новости) и Bedrock Guardrails для комплаенса.[^14]

#### Agno (PhiData)
- **Репозиторий:** https://github.com/agno-agi/agno
- **Лицензия:** Mozilla Public License 2.0
- **Суть:** Лёгкий Python full-stack фреймворк для multimodal агентов; поставляет преднастроенный Agent API server для продакшена.[^15][^16]
- **Применение в банке:** быстрый прототип агентов с памятью, knowledge base и инструментами без избыточного boilerplate.

#### CAMEL-AI
- **Репозиторий:** https://github.com/camel-ai/camel
- **Лицензия:** Apache 2.0
- **Суть:** Community-driven open-source мульти-агентный фреймворк для масштабных симуляций (от одного до миллиона агентов). Поддерживает интеграцию с SurrealDB для vector search.[^17][^18]
- **Применение в банке:** симуляции поведения клиентов, стресс-тестирование агентных сценариев, исследовательские бенчмарки.

#### MetaGPT
- **Репозиторий:** https://github.com/FoundationAgents/MetaGPT
- **Лицензия:** MIT
- **Суть:** Meta-programming фреймворк с SOP (Standard Operating Procedures) — агенты выполняют роли продакт-менеджера, архитектора, инженера, QA. Принят на ICLR 2024.[^19][^20][^21]
- **Применение в банке:** автоматизация разработки внутреннего ПО, code review, генерация технической документации.

#### DeerFlow 2.0 (ByteDance)
- **Репозиторий:** https://github.com/bytedance/deer-flow
- **Лицензия:** Apache 2.0
- **Суть:** Open source SuperAgent harness на базе LangGraph; оркестрирует суб-агенты, память и sandbox; #1 GitHub Trending за 24 часа после релиза, 60 000+ звёзд.[^22][^23][^24]
- **Применение в банке:** комплексные исследовательские задачи (due diligence, анализ регуляторных документов), автономное программирование и создание отчётности.

#### Smolagents (HuggingFace)
- **Репозиторий:** https://github.com/huggingface/smolagents
- **Лицензия:** Apache 2.0
- **Суть:** Минималистичный фреймворк от HuggingFace; входит в топ сравнений 2026 года.[^25]
- **Применение в банке:** быстрое прототипирование, лёгкие агенты для внутренних задач.

#### Goose (Block / Jack Dorsey)
- **Репозиторий:** https://github.com/block/goose
- **Лицензия:** Apache 2.0
- **Суть:** Non-commercial open-source AI agent framework от Block (Square/Cash App); соединяет вывод LLM с реальными действиями.[^26][^27]
- **Применение в банке:** автоматизация DevOps-задач, внутренние инструменты разработчиков, написание и тестирование кода.

### 1.2 TypeScript-first фреймворки

#### Mastra
- **Репозиторий:** https://github.com/mastra-ai/mastra
- **Лицензия:** Apache 2.0 (core)
- **Суть:** TypeScript-first «batteries-included» фреймворк от команды Gatsby (YC W25, $13M); версия 1.0 — январь 2026; поддерживает 81 провайдера / 2436+ моделей. Replit перешёл на Mastra и поднял успешность задач с 80% до 96%.[^28][^29][^30]
- **Применение в банке:** агенты на Next.js/Node.js стеке, воркфлоу с памятью и эвалами, деплой на Vercel/Cloudflare Workers.

#### LangChain.js / LangGraph.js
- **Репозиторий:** https://github.com/langchain-ai/langchainjs
- **Лицензия:** MIT
- **Применение в банке:** фронтенд-агенты, интеграция с банковскими API, streaming для чат-интерфейсов.

***

## 2. Manus-подобные Автономные Агенты

Эти проекты — прямые open-source аналоги Manus AI (general-purpose автономные агенты):

| Проект | GitHub | Лицензия | Особенность |
|--------|--------|----------|-------------|
| **OpenManus** | github.com/FoundationAgents/OpenManus | MIT | 33 000+ звёзд за 10 дней[^31]; RL-based tuning для LLM-агентов[^32] |
| **OpenManus-RL** | github.com/OpenManus/OpenManus-RL | Apache 2.0 | Расширение с GRPO RL-методами, UIUC + MetaGPT[^33] |
| **AgenticSeek** | github.com/Fosowl/agenticSeek | Apache 2.0 | Полностью локальный Manus. Без API, без $200/мес; думает, браузит, пишет код[^34] |
| **Suna** | github.com/kortix-ai/suna | Apache 2.0 | Open-source generalist агент от Kortix AI (апрель 2025); похож на Manus, GenSpark[^35] |
| **OpenHands** | github.com/OpenHands/openhands | MIT | Лидирующий coding агент; #1 на SWE-bench[^36][^37] |
| **Cline** | github.com/cline/cline | Apache 2.0 | Топ-1 open source autonomous coding агент 2025[^38] |
| **AutoGPT** | github.com/Significant-Gravitas/AutoGPT | MIT | Один из первых автономных агентов; #1 GitHub stars[^39] |

***

## 3. Финансово-специализированные AI-агенты

### FinRobot (AI4Finance Foundation)
- **Репозиторий:** https://github.com/AI4Finance-Foundation/FinRobot
- **Лицензия:** Apache 2.0
- **Суть:** Open-source платформа агентов для финансового анализа, поддерживающая множество финансово-специализированных агентов на базе LLM. Опубликована в arXiv (2405.14767).[^40][^41][^42][^43]
- **Возможности:** анализ акций, фундаментальный и технический анализ, генерация equity research отчётов.
- **Применение в банке:** кредитный анализ, risk due diligence, автоматизация инвестиционных отчётов.

### FinGPT (AI4Finance Foundation)
- **Репозиторий:** https://github.com/AI4Finance-Foundation/FinGPT
- **Ресурс:** https://fingpt.io
- **Лицензия:** MIT
- **Суть:** Open-source финансовые LLM; используются для сентимент-анализа, прогнозирования рынков, финансового NLP.[^44][^45]
- **Применение в банке:** анализ новостного фона, оценка кредитного сентимента, мониторинг регуляторных изменений.

### AI4Finance Foundation
- **Ресурс:** https://ai4finance.org
- **Суть:** Экосистема open-source финансового ИИ — FinGPT, FinRobot и сопутствующие проекты.[^44]

***

## 4. Агенты KYC / AML / Комплаенс

### OpenKYC
- **Ресурс:** https://node.uk/security/openkyc/
- **Суть:** Open source identity verification — верификация документов, liveness detection, биометрическое сопоставление, скрининг watchlist (санкции, PEP, adverse media); без per-verification pricing.[^46]
- **Применение:** онбординг клиентов BANXE без зависимости от коммерческих KYC-провайдеров.

### Verifiable Agent Kit
- **Репозиторий:** https://github.com/ICME-Lab/verifiable-agent-kit
- **Суть:** Production-ready фреймворк для privacy-preserving агентов с ZK-proof (Nova recursive proofs); KYC Compliance Proof без раскрытия персональных данных.[^47]
- **Применение:** DeFi compliance, регуляторные доказательства для PSD2/AML.

### McKinsey: Agentic AI в борьбе с финансовыми преступлениями
- Agentic AI автоматизирует end-to-end KYC и AML процессы, повышает эффективность.[^48]
- В продакшен-развёртываниях Resolution Rate превышает 80%.[^49]

### Agentic AI Fraud Detection (GitHub)
- **Репозиторий:** https://github.com/kirtis111/agentic-ai-fraud-detection
- **Суть:** Анализирует 284 000+ банковских транзакций через time-series anomaly detection и агентное расследование.[^50]

***

## 5. Финансовый Леджер и Core Banking (Open Source)

### Formance Ledger
- **Репозиторий:** https://github.com/formancehq/ledger
- **Лицензия:** MIT
- **Суть:** Программируемый open-source core ledger; MIT-licensed, self-hostable на Kubernetes; для money-movement приложений.[^51][^52]
- **Финансирование:** $21M (январь 2025), позиционируется как «AWS для fintech инфраструктуры».[^53]
- **Применение:** центральное ядро платёжного движка BANXE; двойная запись, программируемые правила транзакций.

### Blnk Finance
- **Ресурс:** https://blnkfinance.com
- **Суть:** Иммутабельный open-source ledger для управления балансами и записи транзакционных воркфлоу.[^54]

### Cyclos
- **Ресурс:** goodfirms.co/banking-software/
- **Суть:** Масштабируемое free open source банковское решение с полным набором функций.[^55]

### LedgerSMB
- **Ресурс:** https://ledgersmb.org
- **Суть:** Open source ERP с бухгалтерией, инвойсингом, обработкой заказов.[^56]

### Hyperledger Fabric
- **Репозиторий:** lfdecentralizedtrust.org/projects/fabric
- **Суть:** Enterprise blockchain framework от LF Decentralized Trust; модульная архитектура.[^57][^58]
- **Применение:** аудит-трейл транзакций, settlement, межбанковские расчёты.

***

## 6. RAG, Память и Knowledge Layer

### LlamaIndex
- **Репозиторий:** https://github.com/run-llama/llama_index
- **Лицензия:** MIT
- **Суть:** Data framework для LLM-приложений; построение RAG-систем за минуты. Поддерживает финансовый анализ 10-K документов.[^59][^60]
- **Применение:** документальная база знаний BANXE (нормативные акты, продуктовые условия, тарифы).

### Weaviate
- **Репозиторий:** https://github.com/weaviate/weaviate
- **Лицензия:** BSD 3-Clause
- **Суть:** Open-source AI database для vector search, RAG и памяти; GraphQL API.[^61][^62]
- **Применение:** семантический поиск по банковской документации, хранение embeddings клиентских профилей.

### Qdrant
- **Репозиторий:** https://github.com/qdrant/qdrant
- **Лицензия:** Apache 2.0
- **Суть:** Высокопроизводительный vector search engine на Rust.[^63][^61]
- **Применение:** быстрый поиск похожих транзакций, fraud pattern matching.

### Mem0
- **Репозиторий:** https://github.com/mem0ai/mem0
- **Лицензия:** Apache 2.0
- **Суть:** Наиболее популярный open-source memory layer для AI-агентов, 5k+ звёзд.[^64]
- **Применение:** долгосрочная память агентов о клиентских предпочтениях, истории взаимодействий.

### Zep
- **Репозиторий:** https://github.com/getzep/zep
- **Суть:** Long-term memory service для LLM Apps; факты из истории чата.[^65][^64]
- **Применение:** персонализация клиентского опыта, сохранение контекста между сессиями.

***

## 7. Автоматизация Workflow и Оркестрация

### n8n
- **Репозиторий:** https://github.com/n8n-io/n8n
- **Лицензия:** Sustainable Use License (self-hosted free)
- **Суть:** Open-source workflow automation в стиле Zapier с LLM-действиями и AI Agent node. Активное использование в финансовых воркфлоу.[^66][^67]
- **Применение:** оркестрация банковских процессов, интеграция CRM + Core Banking + Compliance.

### Dify
- **Репозиторий:** https://github.com/langgenius/dify
- **Лицензия:** Apache 2.0
- **Суть:** LLM application development platform с визуальным workflow builder; один из топ фреймворков 2026.[^25]
- **Применение:** no-code / low-code создание агентных workflow, быстрый прототип банковских ассистентов.

### Flowise
- **Репозиторий:** https://github.com/FlowiseAI/Flowise
- **Лицензия:** Apache 2.0
- **Суть:** Open-source flow builder для LLM/Agents/VectorDBs.[^68]
- **Применение:** визуальное построение агентных цепочек без кода.

### Apache Airflow
- **Репозиторий:** https://github.com/apache/airflow
- **Лицензия:** Apache 2.0
- **Суть:** Наиболее популярная open-source платформа оркестрации данных; 90% пользователей применяют для ETL/ELT.[^69]
- **Применение:** Data pipeline для финансовой отчётности, scheduled compliance проверки.

### Temporal
- **Репозиторий:** https://github.com/temporalio/temporal
- **Лицензия:** MIT
- **Суть:** Open-source durable execution system; идеален для финансовых транзакций и subscription management. Используется Cash App, Progressive Insurance.[^70][^71]
- **Применение:** долгосрочные дюрабл воркфлоу (loan origination, KYC, onboarding), fault-tolerant агенты.

### Prefect
- **Репозиторий:** https://github.com/PrefectHQ/prefect
- **Лицензия:** Apache 2.0
- **Суть:** Python workflow orchestration с error handling, scheduling, retry logic.[^72][^71]
- **Применение:** ML pipeline для fraud detection, регуляторная отчётность, daily reconciliation.

### Kestra
- **Репозиторий:** https://github.com/kestra-io/kestra
- **Суть:** Event-driven declarative YAML orchestration control plane; мост между data pipelines и AI агентами.[^70]

***

## 8. Model Context Protocol (MCP) и API-Интеграции

### MCP (Anthropic)
- **Репозиторий:** https://github.com/modelcontextprotocol/specification
- **Лицензия:** MIT
- **Суть:** Открытый стандарт двусторонних соединений между AI-моделями и внешними источниками данных. Используется Stripe, Block, PayPal.[^73][^74]
- **Применение:** стандартный интерфейс агентов BANXE для подключения к banking API, ledger, CRM.

### Bank-MCP
- **Ресурс:** https://mcpmarket.com/server/bank
- **Суть:** MCP-сервер для безопасного read-only доступа к банковским счетам; подключение к 15 000+ банков США/ЕС через Plaid, Tink.[^75]

### Open Banking Gateway (Adorsys)
- **Репозиторий:** https://github.com/adorsys/open-banking-gateway
- **Лицензия:** Apache 2.0
- **Суть:** RESTful API, адаптеры и коннекторы для прозрачного доступа к Open Banking API (PSD2, XS2A).[^76]
- **Применение:** интеграция с европейскими банками для BANXE.

### Stripe AI SDK
- **Репозиторий:** https://github.com/stripe/ai
- **Суть:** One-stop shop для построения AI-powered продуктов на Stripe.[^77]

### Formance MCP-совместимая инфраструктура
- Formance позиционирует себя как программируемый финансовый леджер, совместимый с современными AI-агентными архитектурами.[^78][^52]

***

## 9. Браузерные Агенты и Web Automation

| Инструмент | GitHub | Особенность |
|-----------|--------|-------------|
| **Browser Use** | github.com/browser-use/browser-use | Python, LLM-first, autonomous reasoning[^79] |
| **Stagehand** | github.com/browserbase/stagehand | TypeScript, Playwright + AI hybrid, кэширование действий[^80][^79] |
| **Skyvern** | github.com/skyvern-automation/skyvern | Vision-based, 85.8% WebVoyager, CAPTCHA/2FA[^79] |
| **Playwright** | github.com/microsoft/playwright | Дефолтный browser engine для AI-агентов 2026[^81] |

**Применение в банке:** автоматизация регуляторных форм, веб-скрейпинг финансовых данных, тестирование банковских UI.

***

## 10. Локальные LLM и Privacy-First Инфраструктура

### Ollama
- **Репозиторий:** https://github.com/ollama/ollama
- **Лицензия:** MIT
- **Суть:** Инструмент для запуска LLM локально; поддерживает шифрование и приватную обработку данных.[^82][^83]
- **Применение:** обработка чувствительных банковских данных без отправки на внешние API; соответствие GDPR/data residency требованиям.

### Open WebUI
- **Репозиторий:** https://github.com/open-webui/open-webui
- **Суть:** Self-hosted UI для локальных LLM; используется в secure banking deployments.[^84]

### LM Studio / llama.cpp
- Open source runtime для локального запуска квантизированных моделей — идеально для edge-деплоя в ограниченных окружениях.

***

## 11. Безопасность, Guardrails и Compliance

### NeMo Guardrails (NVIDIA)
- **Репозиторий:** https://github.com/NVIDIA-NeMo/Guardrails
- **Лицензия:** Apache 2.0
- **Суть:** Open-source toolkit для программируемых guardrails в LLM-приложениях; content moderation, safety checks.[^85][^86][^87]
- **Применение:** предотвращение нежелательных ответов банковского агента, соответствие регуляторным ограничениям.

### OWASP Top 10 для LLM и Агентов
- **Ресурс:** https://genai.owasp.org
- **Суть:** Open-source security project; OWASP Top 10 LLM (LLM01-LLM10) + OWASP Top 10 Agents (ASI01-ASI10).[^88][^89][^90]
- **Критические риски для банка:** Prompt Injection (LLM01), Sensitive Information Disclosure (LLM02), Excessive Agency (LLM06), Cascading Failures (ASI08), Rogue Agents (ASI10).[^90]
- **Митигации:** mTLS между агентами, circuit breakers, zero-trust model, короткоживущие токены.[^91][^90]

### Guardrails AI
- **Репозиторий:** https://github.com/guardrails-ai/guardrails
- **Лицензия:** Apache 2.0
- **Суть:** Валидация и исправление вывода LLM через спецификации; структурированный output для финансовых решений.

***

## 12. Observability и Evaluation

| Инструмент | Тип | Ключевая особенность |
|-----------|-----|---------------------|
| **Langfuse** | Open source / Self-hosted | Лидер для self-hosted tracing + evals, OpenTelemetry[^92][^93][^94] |
| **Arize Phoenix** | Open source | ML monitoring + GenAI observability[^92][^95] |
| **LangSmith** | SaaS (с OSS SDK) | Unified agent engineering platform[^96] |
| **DeepEval** | Open source | Evaluation framework с 20+ метриками[^97] |
| **Ragas** | Open source | RAG-специфичная оценка[^97] |
| **MLflow** | Open source | Эксперимент-трекинг, model registry[^92] |
| **Promptfoo** | Open source | LLM testing, красная команда[^97] |

**Применение:** полный аудит-трейл агентных решений, требуемый PSD2/EU AI Act/GDPR.

***

## 13. Голосовые Интерфейсы

### Whisper (OpenAI)
- **Репозиторий:** https://github.com/openai/whisper
- **Лицензия:** MIT
- **Суть:** ASR система, обученная на 680 000 часов мультиязычных данных; лидер open source STT.[^98][^99]
- **Применение:** голосовой ввод для банковских операций, voice KYC, call center automation.

### Open-Source TTS Модели
- Coqui TTS, Kokoro, StyleTTS2 — топ open source TTS для call centers 2026.[^100][^101]
- **Применение:** синтез речи для голосового банкинга, IVR-системы.

***

## 14. Потоковые Данные и Инфраструктура

### Apache Kafka
- **Репозиторий:** https://github.com/apache/kafka
- **Лицензия:** Apache 2.0
- **Суть:** Real-time event streaming platform; банковский стандарт де-факто.[^102][^103]
- **Применение:** streaming транзакций, real-time fraud detection, event-driven банковская архитектура.

### dbt (data build tool)
- **Репозиторий:** https://github.com/dbt-labs/dbt-core
- **Лицензия:** Apache 2.0
- **Суть:** Open-source data transformation; dbt Core бесплатный, идеален с Airflow.[^104]
- **Применение:** финансовая аналитика, regulatory reporting, data quality checks.

***

## 15. Кредитный Скоринг и Fraud Detection

### Open Source Credit Scoring
- **Топ-5 инструментов:** Scorecard-based (R/Python), FICO альтернативы, LightGBM/XGBoost пайплайны.[^105]
- **Finance Agent Benchmark v2:** тестирует LLM-агентов на реальных финансово-аналитических задачах; лучший результат — 57.86% (Gemini 3.5 Flash).[^106]

### Agentic AI Fraud Detection
- IBM: AI-модели распознают разницу между подозрительными и легитимными транзакциями.[^107]
- Sardine.ai: agentic risk platform для fraud prevention и AML.[^108]

***

## 16. Научные Публикации и Академические Источники

| Публикация | Источник | Значимость |
|-----------|---------|-----------|
| FinRobot: An Open-Source AI Agent Platform | arXiv 2405.14767[^43] | Базовая статья по финансовым агентам |
| MetaGPT: Meta Programming for Multi-Agent | arXiv 2308.00352; ICLR 2024[^20][^21] | SOP для мульти-агентных систем |
| OpenHands: An Open Platform for AI Software Developers | arXiv 2407.16741; OpenReview[^109][^110] | Coding агенты |
| Agentic AI Systems in Financial Services | arXiv 2502.05439[^111] | Агентные crew с human-in-the-loop для финансов |
| AI Agents in Financial Markets: Architecture, Applications | arXiv 2603.13942[^112][^113][^114] | Comprehensive survey агентов в финансах |
| Agentic Artificial Intelligence in Finance: A Comprehensive Survey | arXiv 2604.21672[^115] | Newest survey 2026 — architecture, market apps, regulation |
| Voice-to-Voice AI Assistant for Banking | CSE AUA PDF[^116] | RAG + голос для банковской поддержки |
| Finance Agent Benchmark (FABv2) | Vals.ai[^106] | Бенчмарк LLM для финансового анализа |

***

## 17. Форумные Обсуждения и Социальные Сети

### Reddit
- **r/AI_Agents — CrewAI vs LangGraph:** Практики сообщают о проблемах с непрозрачной архитектурой CrewAI в продакшене.[^8]
- **r/LangChain — Long-term memory:** Обсуждение Zep Cloud как turn-key memory service.[^65]
- **r/LangChain — Developers who built AI agents:** Comprehensive comparison 20+ фреймворков в 2026.[^117]
- **r/Entrepreneurs — AI Agents 2026:** «2025 был эрой AI-агентов, 2026 будет эрой агентных сетей».[^118]
- **r/programming — Build a Digital Bank:** Плейлист step-by-step с Spring Boot microservices.[^119]
- **r/machinelearningnews — DeerFlow:** ByteDance open-sources modular multi-agent framework на LangGraph.[^120]
- **r/selfhosted — European bank sync:** Open banking API интеграция с self-hosted Actual Budget.[^121]

### LinkedIn
- Hemant Mishra: AI в банкинге 2026 — agentic KYC/AML с Resolution Rate >80% в продакшене; EU AI Act обязывает к auditability кредитных решений.[^49]
- Статья о MCP в retail banking: MCP соединяет AI, LLMs и банковские системы для автоматизации.[^122]
- Статья о Next-Generation Neobank: «Neobank следующего поколения должен завоевать доверие машин».[^123]

### HuggingFace Blog
- Open Source AI Agents Directory (2025): каталог 100+ агентов — Adala, AgentForge, Agent4Rec и другие.[^124]

### GitHub Blog
- «From MCP to multi-agents: Top 10 new open source AI projects» (апрель 2025): анализ всех проектов за 99 дней.[^125]
- Awesome AI Agents 2026: 300+ агентов, фреймворков и инструментов.[^126]
- 500+ AI Agent Projects: production примеры на LangGraph, CrewAI и других.[^127]

### Huawei Enterprise Blog
- Architecture of Agentic Banking: открытые модели + гибридные архитектуры; шесть структурных измерений; R.A.C.E. data framework.[^128][^129]

***

## 18. Аналитика и Индустриальные Отчёты

| Источник | Ключевой вывод |
|---------|---------------|
| **BCG (фев. 2026)**[^130] | Back office — приоритет для агентного ИИ в розничном банкинге |
| **Oracle (2025)**[^1] | 2026 = Banking 4.0; агентные флоты как новый операционный layer |
| **McKinsey (авг. 2025)**[^48] | Agentic AI меняет KYC/AML — end-to-end автоматизация |
| **FinTech Futures (2025)**[^2] | Production-scale AI агенты в банках к 2026 |
| **FinTech Weekly (2026)**[^131] | AI агенты повлияли на $262B продаж; банки без agent-readiness не попадают в checkout |
| **Tyk / 2026 APIs**[^132] | 70% банков уже деплоят agentic AI в production |
| **Neontri Implementation Guide**[^133] | 12-18 месяцев: первый агент в production после пилота |
| **Flowable 2026 Trends**[^134] | Швейцарский банк сократил onboarding на 99% с AI оркестрацией |
| **arXiv Agentic Finance Survey**[^115] | Агентный ИИ трансформирует trading, portfolio, risk, compliance |

***

## 19. Рекомендуемый Технологический Стек BANXE AI Bank

На основе исследования, следующий open source стек покрывает все агентные потребности банка:

### Ядро Агентного Движка
```
Оркестрация агентов:   LangGraph (Python) + Mastra (TypeScript/frontend)
Мульти-агентные роли:  CrewAI или MetaGPT (для специализированных команд)
Автономные задачи:     DeerFlow / OpenHands (research + coding)
Инструменты агентов:   MCP Protocol (стандартный интерфейс)
```

### Финансовая Инфраструктура
```
Core Ledger:           Formance (MIT) — программируемый двойной учёт
Open Banking:          Adorsys Open Banking Gateway (PSD2/XS2A)
Payments:              Stripe AI SDK + MCP
Blockchain audit:      Hyperledger Fabric
```

### Знания и Память
```
RAG:                   LlamaIndex + Qdrant/Weaviate
Долгосрочная память:   Mem0 + Zep
LLM (cloud):           Anthropic Claude / OpenAI
LLM (on-premise):      Ollama + Qwen/Llama для privacy-sensitive данных
```

### KYC / AML / Compliance
```
KYC:                   OpenKYC (document + liveness + biometrics)
AML Fraud:             Кастомные модели на LightGBM/XGBoost + агентное расследование
Guardrails:            NeMo Guardrails + Guardrails AI
Безопасность:          OWASP Top 10 LLM + Agents как чеклист
```

### Workflow и Data Pipeline
```
Оркестрация:           Temporal (дюрабл воркфлоу) + Prefect (data pipelines)
Automation:            n8n (no-code интеграции) + Dify/Flowise (прототипы)
Streaming:             Apache Kafka (real-time транзакции)
ETL:                   Apache Airflow + dbt
```

### Observability
```
Tracing:               Langfuse (self-hosted, OpenTelemetry)
Evaluation:            Arize Phoenix + DeepEval
Monitoring:            MLflow
```

### Голосовой Layer
```
STT:                   Whisper (OpenAI, MIT)
TTS:                   Kokoro / StyleTTS2 (open source)
Voice Agent:           LiveKit (open source WebRTC)
```

***

## 20. Критические Предупреждения и Ограничения

1. **EU AI Act (август 2026):** Системы кредитного скоринга классифицируются как high-risk AI — обязательны auditability, explainability, human oversight.[^132][^49]
2. **OWASP Agents ASI06-ASI10:** Межагентное доверие, cascading failures и rogue agents — специфические риски banking AI. Использовать mTLS между агентами, circuit breakers, zero-trust.[^90]
3. **Зрелость фреймворков:** LangGraph наиболее production-ready; CrewAI имеет известные проблемы с отладкой в сложных продакшен-сценариях.[^5][^8]
4. **Finance Agent Benchmark:** Даже лучшие LLM набирают лишь 57.86% на сложных финансово-аналитических задачах — human-in-the-loop обязателен для критических решений.[^106]
5. **Data residency:** Чувствительные клиентские данные нельзя отправлять во внешние LLM API без соответствия GDPR. Использовать Ollama + локальные модели для PII.[^135][^82]
6. **Стоимость инференса:** Необходимо внедрить cost-ceilings и rate-limiting для агентов, иначе возможен «финансовый DoS» от петель агентов.[^90]

---

## References

1. [The Future of Banking: Scaling AI Agents in 2026 & Beyond | Oracle](https://www.oracle.com/financial-services/banking/future-banking/) - Banks will deploy fleets of specialized, customer-facing, and domain-specific agents to orchestrate ...

2. [Banking in 2026: Production scale AI agents - FinTech Futures](https://www.fintechfutures.com/ai-in-fintech/banking-in-2026-production-scale-ai-agents) - Autonomous AI agents are set to disrupt the 2026 financial landscape, with major banks expected to m...

3. [8 Best TypeScript AI Agent Frameworks in 2026 - AY Automate](https://www.ayautomate.com/blog/best-typescript-ai-agent-frameworks) - Mastra is the most ambitious "batteries-included" TypeScript agent framework to emerge in 2025. ... ...

4. [How Kensho built a multi-agent framework with LangGraph to solve ...](https://www.langchain.com/blog/customers-kensho) - The framework, developed using several LangGraph tools, is a foundational solution for unifying data...

5. [Top AI Agent Frameworks in 2026: A Production-Ready Comparison](https://pub.towardsai.net/top-ai-agent-frameworks-in-2026-a-production-ready-comparison-7ba5e39ad56d) - We tested 8 AI agent frameworks in production across healthcare, logistics, and fintech. Here's what...

6. [LangGraph vs CrewAI: Let's Learn About the Differences - ZenML Blog](https://www.zenml.io/blog/langgraph-vs-crewai) - However, CrewAI's 2025 enterprise features are challenging this pattern, particularly for use cases ...

7. [Crewai vs. LangGraph: Multi agent framework comparison - Zams' AI](https://zams.com/blog/crewai-vs-langgraph) - In this blog, we will compare the two in detail - on their features, benefits, and ideal use cases, ...

8. [CrewAI vs LangGraph : r/AI_Agents - Reddit](https://www.reddit.com/r/AI_Agents/comments/1q567hp/crewai_vs_langgraph/) - At my company, we're using CrewAI in production, and under the hood it's causing real trouble: Archi...

9. [LangGraph vs. CrewAI vs. AutoGen: Which Framework ... - LinkedIn](https://www.linkedin.com/posts/hanane-d-algo-trader_langgraph-vs-crewai-vs-autogen-which-framework-activity-7411682825298419713-b_zK) - ▪️ AutoGen showed advantages for research and advisory applications requiring extended agent dialogu...

10. [AutoGen + Semantic Kernel = Microsoft Agent Framework - Reddit](https://www.reddit.com/r/AutoGenAI/comments/1o0p73u/autogen_semantic_kernel_microsoft_agent_framework/) - Welcome to Microsoft's comprehensive multi-language framework for building, orchestrating, and deplo...

11. [Microsoft's Agentic Frameworks: AutoGen and Semantic Kernel](https://devblogs.microsoft.com/autogen/microsofts-agentic-frameworks-autogen-and-semantic-kernel/) - Microsoft's agentic AI frameworks, Semantic Kernel and AutoGen are deeply collaborating to provide t...

12. [Amazon Open Sources Strands Agents SDK for Building AI Agents](https://www.infoq.com/news/2025/06/amazon-strands-agents-sdk/) - Amazon has released Strands Agents, an open source SDK that simplifies AI agent development through ...

13. [Strands Agents - AWS Prescriptive Guidance](https://docs.aws.amazon.com/prescriptive-guidance/latest/agentic-ai-frameworks/strands-agents.html) - Learn about Strands Agents, an open-source SDK for building autonomous AI agents that integrate with...

14. [Build a Memory-Powered Multi-Agent Financial Advisor with Strands ...](https://dev.to/aws-builders/build-a-memory-powered-multi-agent-financial-advisor-with-strands-sdk-amazon-bedrock-e08) - Strands is an open-source Python framework from AWS Labs that makes building production agents drama...

15. [Build production-grade Agentic AI apps in pure Python! | Sumanth P](https://www.linkedin.com/posts/sumanth077_build-production-grade-agentic-ai-apps-in-activity-7313821103104110593-NS2G) - Agno is a lightweight Python agent framework for building Multimodal Agents. It exposes LLMs as a un...

16. [AI Agents X : Agno — Agentic Framework | by DhanushKumar](https://ai.plainenglish.io/ai-agents-x-agno-agentic-framework-2a2abba49604) - Agno is an open-source, full-stack Python framework for building ... For production deployment, Agno...

17. [CAMEL | AI Native Landscape](https://landscape.jimmysong.io/projects/camel/) - CAMEL is an open-source framework for large-scale multi-agent research, supporting simulation, data ...

18. [Introducing CAMEL-AI: A Scalable Multi-Agent Framework - LinkedIn](https://www.linkedin.com/posts/surrealdb_building-a-multi-agent-ai-solution-camel-ai-activity-7354132706131156992-4e7s) - Building a multi-agent AI solution? CAMEL-AI is a new framework that specialises in scalability and ...

19. [GitHub - FoundationAgents/MetaGPT: The Multi-Agent Framework](https://github.com/foundationagents/metagpt) - MGX (MetaGPT X) - the world's first AI agent development team. MetaGPT includes product managers / a...

20. [MetaGPT: Meta Programming for a Multi-Agent Collaborative ... - arXiv](https://arxiv.org/html/2308.00352v6) - MetaGPT is an open-source framework that facilitates interactive communication between multiple agen...

21. [MetaGPT: Meta Programming for A Multi-Agent Collaborative ...](https://iclr.cc/virtual/2024/oral/19756) - Here we introduce MetaGPT, an innovative meta-programming framework incorporating efficient human wo...

22. [GitHub - bytedance/deer-flow: An open-source long-horizon ...](https://github.com/bytedance/deer-flow) - DeerFlow (Deep Exploration and Efficient Research Flow) is an open-source super agent harness that o...

23. [DeerFlow 2.0 Deep Dive — ByteDance's Open-Source SuperAgent ...](https://www.sotaaz.com/post/deerflow-intro-en) - In February 2026, ByteDance released DeerFlow 2.0. It hit #1 on GitHub Trending within 24 hours and ...

24. [DeerFlow Review 2026 – Open-Source SuperAgent - Vibe Coding](https://vibecoding.app/blog/deerflow-review) - On February 28, 2026, ByteDance quietly open-sourced DeerFlow. Within days it hit #1 trending on Git...

25. [The best open source frameworks for building AI agents in 2026](https://www.firecrawl.dev/blog/best-open-source-agent-frameworks) - Ten open source agent frameworks compared: LangGraph, CrewAI, AutoGen, Google ADK, Dify, OpenAI Agen...

26. [Block Launches Open-Source AI Framework Codename Goose - InfoQ](https://www.infoq.com/news/2025/02/codename-goose/) - Block's Open Source Program Office has launched Codename Goose, an open-source, non-commercial AI ag...

27. [The Ultimate Guide to Open-Source AI Agent Frameworks in 2025](https://watercrawl.dev/blog/The-Ultimate-Guide-to-Open-Source) - Developed by Jack Dorsey's Block. · AI agent Goose assists with: Writing code snippets; Generating d...

28. [Mastra: TypeScript AI Framework for Agents and Apps](https://mastra.ai) - Mastra is a TypeScript framework for building AI agents and AI-powered applications. Mastra agents u...

29. [Mastra: TypeScript AI Agent Framework Guide 2026](https://noqta.tn/en/blog/mastra-typescript-ai-agent-framework-guide-2026) - Mastra is the TypeScript-first agent framework production teams adopt in 2026. See its agents, workf...

30. [AI Agent Frameworks in 2026: A Developer's Field Guide to What ...](https://www.socialcrawl.dev/blog/ai-agent-frameworks-2026-developer-field-guide) - LangGraph, CrewAI, Mastra, Pydantic AI compared with real production numbers. Which AI agent framewo...

31. [OpenManus Achieves 33000 GitHub Stars in Under 10 Days](https://pub.towardsai.net/openmanus-achieves-33-000-github-stars-in-under-10-days-a-technical-analysis-230f47d448da) - Let's illustrate OpenManus's capabilities with a real-world coding example: an AI-powered research a...

32. [FoundationAgents/OpenManus: No fortress, purely open ... - GitHub](https://github.com/FoundationAgents/OpenManus) - An open-source project dedicated to reinforcement learning (RL)- based (such as GRPO) tuning methods...

33. [OpenManus-RL - GitHub](https://github.com/OpenManus/OpenManus-RL) - OpenManus-RL is an open-source initiative collaboratively led by Ulab-UIUC and MetaGPT. This project...

34. [GitHub - Fosowl/agenticSeek: Fully Local Manus AI. No APIs, No ...](https://github.com/Fosowl/agenticSeek) - Fully Local Manus AI. No APIs, No $200 monthly bills. Enjoy an autonomous agent that thinks, browses...

35. [Suna Review 2026: Digital Employee Platform + 6 Alternatives](https://www.taskade.com/blog/suna-review) - What Is Suna? Suna is an open-source generalist AI agent built by Kortix AI, founded by Marko Kraeme...

36. [OpenHands | The Open Platform for Cloud Coding Agents](https://www.openhands.dev) - Meet OpenHands, the open-source, model-agnostic platform for cloud coding agents. Automate real engi...

37. [Local AI for Developers OpenHands AMD Bring Coding Agents to ...](https://www.amd.com/en/developer/resources/technical-articles/2025/OpenHands.html) - OpenHands is the leading open-source AI coding agent, consistently ranked as a top performing agent ...

38. [Top 11 Open-Source Autonomous Agents & Frameworks in 2025](https://cline.ghost.io/top-11-open-source-autonomous-agents-frameworks-in-2025/) - Top Open-source Autonomous Agents & Frameworks for Coding in 2025 · 1. Cline · 2. OpenDevin · 3. Sup...

39. [10 Open-Source AI Agent Frameworks to Automate Your Work in 2026](https://pasqualepillitteri.it/en/news/1476/10-open-source-ai-agent-frameworks-2026) - The four most-starred open-source AI agent frameworks on GitHub in April 2026: AutoGPT, LangChain, O...

40. [FinRobot: An Open-Source AI Agent Platform for Financial Analysis ...](https://github.com/ai4finance-foundation/finrobot) - FinRobot is an AI Agent platform tailored for financial applications, surpassing FinGPT's single-mod...

41. [FinRobot: An Open-Source AI Agent Platform for Financial ... - arXiv](https://arxiv.org/html/2405.14767v2) - In this paper, we introduce FinRobot, a novel open-source AI agent platform supporting multiple fina...

42. [[PDF] FinRobot: An Open-Source AI Agent Platform for Financial ...](https://www.semanticscholar.org/paper/FinRobot:-An-Open-Source-AI-Agent-Platform-for-Yang-Zhang/780881ba7440fb95ebc7114d8f219466275102f8) - FinRobot is introduced, a novel open-source AI agent platform supporting multiple financially specia...

43. [[2405.14767] FinRobot: An Open-Source AI Agent Platform ... - arXiv](https://arxiv.org/abs/2405.14767) - In this paper, we introduce FinRobot, a novel open-source AI agent platform supporting multiple fina...

44. [AI4Finance Foundation | Open Source Financial AI](https://ai4finance.org) - FinGPT is a game-changer for financial NLP. We use it daily for sentiment analysis and it outperform...

45. [FinGPT — Open-Source Financial Large Language Models](https://fingpt.io) - Open-Source Financial AI Platform ... Build, evaluate, and deploy financial AI applications with ope...

46. [OpenKYC Identity Verification | Node Digital](https://node.uk/security/openkyc/) - KYC identity verification with OpenKYC: document checks, liveness detection, face matching and AML s...

47. [ICME-Lab/verifiable-agent-kit: Natural language prompts ... - GitHub](https://github.com/ICME-Lab/verifiable-agent-kit) - KYC Compliance Proof. Proves identity verification without revealing personal information. Use cases...

48. [How agentic AI can change the way banks fight financial crime](https://www.mckinsey.com/capabilities/risk-and-resilience/our-insights/how-agentic-ai-can-change-the-way-banks-fight-financial-crime) - Discover how agentic AI is reshaping banking compliance by automating end-to-end KYC and AML process...

49. [Top AI Use Cases for Banks in 2026 | Hemant Mishra posted on the ...](https://www.linkedin.com/posts/hemant-mishra-4b229122_ai-in-financial-services-2026-from-experimentation-activity-7474383974170116096-eKQR) - Agentic AI for customer onboarding, KYC & AML The qualitative leap of 2026. Agents autonomously plan...

50. [kirtis111/agentic-ai-fraud-detection - GitHub](https://github.com/kirtis111/agentic-ai-fraud-detection) - This project analyzes 284000+ banking transactions to detect suspicious activity using time-series a...

51. [GitHub - formancehq/ledger: The programmable open source core ...](https://github.com/formancehq/ledger) - Formance Ledger is a programmable financial core ledger that provides a foundation for all kind of m...

52. [Money movement infrastructure is fintech's most important layer](https://www.apideck.com/blog/money-movement-infrastructure-fintech-ledger-as-a-service) - Formance takes the opposite approach. It is an open-source programmable ledger: MIT-licensed, self-h...

53. [Formance raises $21M to build the AWS for fintech infrastructure](https://techcrunch.com/2025/01/29/formance-raises-21-million-to-build-the-aws-of-fintech-infrastructure/) - French startup Formance started out trying to capitalize on this need with an open source, programma...

54. [Blnk Finance | Immutable, Open-Source Ledger Designed for ...](https://www.blnkfinance.com) - Open-source financial software for developers. Our Core provides an immutable, open-source ledger to...

55. [Best 4 Free & Open Source Banking Software Solutions - Goodfirms](https://www.goodfirms.co/banking-software/blog/the-best-8-free-and-open-source-banking-software-solutions-1) - #1 Cyclos Cyclos is a scalable and reliable free and open source banking solution that comes with a ...

56. [Open Source ERP: accounting, invoicing and more | LedgerSMB](https://ledgersmb.org) - The LedgerSMB project provides small and mid-size businesses with solid open source accounting softw...

57. [Hyperledger Fabric - LF Decentralized Trust](https://www.lfdecentralizedtrust.org/projects/fabric) - Hyperledger Fabric is a blockchain framework implementation intended as a foundation for developing ...

58. [What Is Hyperledger Fabric? - IBM](https://www.ibm.com/think/topics/hyperledger) - Hyperledger Fabric is the flexible blockchain framework behind the IBM Blockchain Platform that's dr...

59. [Financial document analysis with LlamaIndex - OpenAI Developers](https://developers.openai.com/cookbook/examples/third_party/financial_document_analysis_with_llamaindex) - We showcase how LlamaIndex can support a financial analyst in quickly extracting information and syn...

60. [Financial Document OCR RAG System - GitHub](https://github.com/LorenzoWandB/Llama-Index-OCR-Powered-Document-Summarization-in-Banking-with-W-B-Weave) - This project demonstrates how to build a trustworthy AI system for financial services that combines:...

61. [We Tried and Tested 10 Best Vector Databases for RAG Pipelines](https://www.zenml.io/blog/vector-databases-for-rag) - Weaviate: An open-source graph-based vector store. Features a GraphQL API and a modular design. Qdra...

62. [Weaviate: The AI database developers love](https://weaviate.io) - Design, build and ship complete AI experiences. Vector search, RAG, and memory - all in one open-sou...

63. [Qdrant - Vector Search Engine](https://qdrant.tech) - Qdrant is an Open-Source Vector Search Engine written in Rust. It provides fast and scalable vector ...

64. [Best AI Agent Memory Tools 2026 - AgDex](https://agdex.ai/blog/best-ai-agent-memory-tools-2026.html) - Mem0 is the most widely adopted open-source memory layer for AI agents. ... Zep — Long-Term Memory f...

65. [Long term memory for agents? : r/LangChain - Reddit](https://www.reddit.com/r/LangChain/comments/1eat8c4/long_term_memory_for_agents/) - Zep Cloud offers a turn-key memory service for Assistants and Agents. Foundational to Zep's memory a...

66. [Best Dify Alternatives for AI Workflow Automation - Dynamiq](https://www.getdynamiq.ai/post/best-dify-alternatives-for-ai-workflow-automation) - n8n brings Zapier‑style flows to open source with self‑hosting. It supports LLM actions and an AI Ag...

67. [5 Things I Learned Building 3 Finance Automation Workflows in n8n ...](https://community.n8n.io/t/5-things-i-learned-building-3-finance-automation-workflows-in-n8n-with-easybits/281750) - Over the last few weeks I've built three finance automation workflows in n8n, all using easybits Ext...

68. [Integrate Botpress with Flowise: FREE Stack AI Replacement](https://www.youtube.com/watch?v=NjXmnZQdYFA) - In this video we will look at a free StackAI replacement called Flowise, an open-source flow builder...

69. [Open Source ETL Tools: Comparison Guide 2026 - DataExpert.io](https://www.dataexpert.io/blog/open-source-etl-tools-comparison-guide-2026) - Apache Airflow has become a go-to tool for orchestrating data pipelines, with 90% of users leveragin...

70. [Best Temporal Alternatives & Competitors in 2026 - Kestra](https://kestra.io/resources/infrastructure/temporal-alternatives) - Prefect: Pythonic Workflow Automation. Prefect is a modern workflow orchestration platform that also...

71. [Prefect is a workflow orchestration framework for building ... - GitHub](https://github.com/PrefectHQ/prefect) - Prefect is a workflow orchestration framework for building data pipelines in Python. It's the simple...

72. [Prefect - Workflow orchestration for AI and data engineering projects](https://www.adesso.ch/en/news/blog/prefect-workflow-orchestration-for-ai-and-data-engineering-projects-3.jsp) - This blog post introduces Prefect, an intuitive tool for orchestrating workflows in AI development.

73. [AI: How Stripe, Block, and PayPal are using Model Context Protocol](https://lex.substack.com/p/ai-how-stripe-block-and-paypal-are) - Model Context Protocol is an Anthropic open framework enabling seamless interactions between AI mode...

74. [Introducing the Model Context Protocol - Anthropic](https://www.anthropic.com/news/model-context-protocol) - The Model Context Protocol is an open standard that enables developers to build secure, two-way conn...

75. [Bank-MCP: Empower AI with Secure Read-Only Bank Account Access](https://mcpmarket.com/server/bank) - Bank-MCP provides secure, read-only access to your bank accounts for AI assistants. Connect to 15000...

76. [GitHub - adorsys/open-banking-gateway: Provides RESTful API ...](https://github.com/adorsys/open-banking-gateway) - Provides RESTful API, tools, adapters, and connectors for transparent access to open banking API's (...

77. [GitHub - stripe/ai: One-stop shop for building AI-powered products ...](https://github.com/stripe/ai) - This repo is the one-stop shop for building AI-powered products and businesses on top of Stripe. It ...

78. [Formance Review 2026: Embedded Finance Platform & APIs](https://www.openbankingtracker.com/embedded-finance/formance) - Open-source financial ledger and money movement platform. Formance provides programmable, double-ent...

79. [Browser Use vs Stagehand: Which is Better? (February 2026)](https://www.skyvern.com/blog/browser-use-vs-stagehand-which-is-better/) - Browser Use offers autonomous Python agents while Stagehand adds AI to Playwright code · Stagehand c...

80. [Stagehand](https://stagehand.dev) - The SDK for browser agents. Stagehand is an open source SDK that uses AI to make your browser agents...

81. [Playwright for Browser Automation in AI Agents - ByteTunnels](https://bytetunnels.com/posts/playwright-for-browser-automation-in-ai-agents/) - Playwright has become the default browser engine powering the AI agent ecosystem. Browser Use, Stage...

82. [Run Ollama Private LLMs Locally | AI Solutions & IT Services](https://www.mol-tech.us/blog/private-llms-locally-ollama-secure-ai) - Moltech Solutions shows how running private LLMs locally with Ollama improves privacy, saves costs, ...

83. [Secure Minions: private collaboration between Ollama and frontier ...](https://ollama.com/blog/secureminions) - The local LLM messages are encrypted before being sent to the GPU enclave, where they're safely decr...

84. [Build Your Own Secure Local AI Assistant for Cyber ... - YouTube](https://www.youtube.com/watch?v=VuO6B34tzps) - In this video, you'll learn how to install and configure Ollama with Open WebUI to create a secure, ...

85. [NeMo Guardrails 2026: NVIDIA's LLM Safety Toolkit - AppSec Santa](https://appsecsanta.com/nemo-guardrails) - NVIDIA NeMo Guardrails is an open-source AI security toolkit for adding programmable guardrails to L...

86. [NVIDIA NeMo Guardrails library - GitHub](https://github.com/NVIDIA-NeMo/Guardrails) - NeMo Guardrails is an open-source toolkit for easily adding programmable guardrails to LLM-based con...

87. [Content Moderation and Safety Checks with NVIDIA NeMo Guardrails](https://developer.nvidia.com/blog/content-moderation-and-safety-checks-with-nvidia-nemo-guardrails/) - In this post, I give you an easy-to-implement demonstration of how to add safety and content moderat...

88. [OWASP Top 10 for Large Language Model Applications](https://owasp.org/www-project-top-10-for-large-language-model-applications/) - The OWASP GenAI Security Project is a global, open-source initiative dedicated to identifying, mitig...

89. [OWASP Gen AI Security Project: Home](https://genai.owasp.org) - The OWASP Top 10 for LLMs has become an indispensable resource for organizations addressing the chal...

90. [OWASP Top 10 Agents & AI Vulnerabilities (2026 Cheat Sheet)](https://blog.alexewerlof.com/p/owasp-top-10-ai-llm-agents) - A pragmatic engineering guide and cheat sheet for the OWASP Top 10 AI, OWASP Top 10 LLM, and OWASP T...

91. [The best providers for authenticating AI agents via OAuth and OIDC ...](https://workos.com/blog/best-oauth-oidc-providers-for-authenticating-ai-agents-2025) - Open-source and self-hosted: Full ownership of agent identity infrastructure. Robust OAuth/OIDC supp...

92. [Top 5 LLM and Agent Observability Tools in 2026 - MLflow](https://mlflow.org/top-5-agent-observability-tools/) - Arize Phoenix is the open source observability tool from Arize AI, a company that started in classic...

93. [8 Best AI Agent Observability Tools in 2026 - AY Automate](https://www.ayautomate.com/blog/best-ai-agent-observability-tools) - Langfuse and Arize Phoenix lead the open-source field for self-hosted tracing plus evals, both built...

94. [AI Agent Observability, Tracing & Evaluation with Langfuse](https://langfuse.com/blog/2024-07-ai-agent-observability-with-langfuse) - Langfuse is an open-source AI engineering platform that provides deep insights into metrics such as ...

95. [AI Agent Observability Tools Compared 2026: LangSmith vs ...](https://spanora.ai/blog/ai-agent-observability-tools-compared-2026) - Open source LLM monitoring options in 2026 · Langfuse OSS for an open-source tracing platform with c...

96. [8 LLM Observability Tools to Monitor & Eval AI Agents - LangChain](https://www.langchain.com/resources/llm-observability-tools) - LangSmith is a unified agent engineering platform that provides observability, evaluations, and prom...

97. [Open Source and Free AI Agent Evaluation Tools - DataTalks.Club](https://datatalks.club/blog/open-source-free-ai-agent-evaluation-tools.html) - Compare 7 free and open-source AI agent evaluation tools including Arize Phoenix, LangSmith, DeepEva...

98. [The Top Open Source Speech-to-Text (STT) Models in 2025 - Modal](https://modal.com/blog/open-source-stt) - Exploring the top open-source STT models based on Hugging Face's trending models and the Open ASR Le...

99. [Introducing Whisper - OpenAI](https://openai.com/index/whisper/) - Whisper is an automatic speech recognition (ASR) system trained on 680,000 hours of multilingual and...

100. [The Best Open Source AI Models for Call Centers in 2026](https://www.siliconflow.com/articles/en/best-open-source-AI-models-for-call-centers) - Open source AI models for call centers are specialized text-to-speech (TTS) systems designed to enha...

101. [Best Open-Source AI Voice Generators in 2026 - Dograh](https://www.dograh.com/feeds/blog/open-source-ai-voice-generator) - This article evaluates six leading open-source TTS models based on speech quality, licensing, multil...

102. [Revolutionizing Banking with Real-Time Event Streaming ... - LinkedIn](https://www.linkedin.com/pulse/revolutionizing-banking-real-time-event-streaming-devarasetti-ud--k6uof) - Apache Kafka's real-time streaming capabilities empower banks to innovate, optimize processes, and d...

103. [Comprehending Real-Time Event Processing with Kafka - XenonStack](https://www.xenonstack.com/blog/real-time-event-processing-with-kafka) - Apache Kafka is an open-source event streaming platform that provides data storing, reading, and ana...

104. [Agence dbt & Airflow : Pipeline Data & Orchestration - Flowt](https://flowt.fr/technologies/agence-dbt-airflow/) - dbt Core est open source et gratuit, idéal avec Airflow pour l'orchestration. dbt Cloud offre une in...

105. [Open Source Credit Scoring Software: Top 5 Tools | Nected Blogs](https://www.nected.ai/blog/credit-scoring-software-open-source) - Open source credit scoring software is a freely available tool that lenders and fintech teams can us...

106. [Finance Agent v2 - Vals AI](https://www.vals.ai/benchmarks/fabv2) - The benchmark tests a model's ability to perform the work of entry-level financial analysts — answer...

107. [AI Fraud Detection in Banking | IBM](https://www.ibm.com/think/topics/ai-fraud-detection-in-banking) - AI models can learn to recognize the difference between suspicious activities and legitimate transac...

108. [Agentic Financial Crime Platform for Fraud Prevention & AML](https://www.sardine.ai) - The top agentic risk platform used by leading banks and merchants worldwide to stop fraud in real-ti...

109. [An Open Platform for AI Software Developers as Generalist Agents](https://arxiv.org/abs/2407.16741) - In this paper, we introduce OpenHands (fka OpenDevin), a platform for the development of powerful an...

110. [OpenHands: An Open Platform for AI Software Developers as...](https://openreview.net/forum?id=OJd3ayDDoF) - The paper presents OpenHands, an open-source platform designed to facilitate the development of AI a...

111. [Agentic AI Systems Applied to tasks in Financial Services - arXiv](https://arxiv.org/html/2502.05439v2) - This paper explores agentic system workflows in the financial services industry. In particular, we b...

112. [AI Agents in Financial Markets: Architecture, Applications ... - arXiv](https://arxiv.org/html/2603.13942v2) - This paper develops an integrative framework for analysing agentic finance: financial market environ...

113. [AI Agents in Financial Markets: Architecture, Applications ... - arXiv](https://arxiv.org/html/2603.13942v1) - This paper develops an integrative framework for analysing agentic finance: financial market environ...

114. [AI Agents in Financial Markets: Architecture, Applications ... - arXiv](https://arxiv.org/html/2603.13942v3) - New surveys synthesize the rise of agentic AI architectures in general and AI-agent applications in ...

115. [Agentic Artificial Intelligence in Finance: A Comprehensive Survey](https://arxiv.org/html/2604.21672v1) - Financial markets are experiencing a profound transformation as artificial intelligence evolves from...

116. [[PDF] Voice-to-Voice AI Assistant for Banking](https://cse.aua.am/wp-content/uploads/2025/06/Voice-to-Voice-AI.pdf) - By implementing RAG in AI voice assistants in banking customer support, it can help customers to get...

117. [Developers who actually built AI agents, what's the real learning ...](https://www.reddit.com/r/LangChain/comments/1s3dw4r/developers_who_actually_built_ai_agents_whats_the/) - Comprehensive comparison of every AI agent framework in 2026 — LangChain, LangGraph, CrewAI, AutoGen...

118. [r/Entrepreneurs on Reddit: 2025 Was the Era of AI Agents. 2026 Will ...](https://www.reddit.com/r/Entrepreneurs/comments/1rg1bk3/2025_was_the_era_of_ai_agents_2026_will_be_the/) - In 2025, everyone was obsessed with AI agents. Solo copilots. Task automators. Smart little bots tha...

119. [Build a Digital Bank (Step-by-Step Playlist) : r/programming - Reddit](https://www.reddit.com/r/programming/comments/1ov9epi/build_a_digital_bank_stepbystep_playlist/) - This series walks through how to build a digital bank from scratch Tech Stack Spring Boot microservi...

120. [ByteDance Open-Sources DeerFlow: A Modular Multi-Agent ... - Reddit](https://www.reddit.com/r/machinelearningnews/comments/1kj3in1/bytedance_opensources_deerflow_a_modular/) - ByteDance has open-sourced DeerFlow, a modular multi-agent framework built on LangChain and LangGrap...

121. [automatically sync your European bank to Actual Budget via open ...](https://www.reddit.com/r/selfhosted/comments/1rt2knk/bridge_bank_automatically_sync_your_european_bank/) - Hey r/selfhosted , I built a small tool that connects European banks to self-hosted Actual Budget us...

122. [Harnessing Model Context Protocol (MCP) with AI Agents - LinkedIn](https://www.linkedin.com/pulse/harnessing-model-context-protocol-mcp-ai-agents-retail-robert-collins-qbnae) - In this blog post, we'll explore how MCP empowers AI agents, using a relatable story of a retail ban...

123. [How the Next-Generation Neobank Should Be Built for the Agentic ...](https://www.linkedin.com/pulse/how-next-generation-neobank-should-built-agentic-economy-johnny-le-toxre) - The neobank of the next decade has to win machine trust. It has to be the platform an autonomous age...

124. [Open Source AI Agents | Github/Repo List | [2025] - Hugging Face](https://huggingface.co/blog/tegridydev/open-source-ai-agents-directory) - Adala: Autonomous Data Labeling Agent framework. · Agent4Rec: Recommender system simulator (1,000 ag...

125. [From MCP to multi-agents: The top 10 new open source AI projects ...](https://github.blog/open-source/maintainers/from-mcp-to-multi-agents-the-top-10-open-source-ai-projects-on-github-right-now-and-why-they-matter/) - We analyzed every open source project created in the last 99 days (as of March 29, 2025), and ranked...

126. [caramaschiHG/awesome-ai-agents-2026: The most comprehensive ...](https://github.com/caramaschiHG/awesome-ai-agents-2026) - The most comprehensive list of AI agents, frameworks & tools in 2026. 300+ resources · 20+ categorie...

127. [500+ AI Agent Projects & Use Cases - GitHub](https://github.com/ashishpatel26/500-AI-Agents-Projects) - A curated collection of 500+ AI agent projects — production examples, tutorials, and working code sp...

128. [The Architecture of Agentic Banking – Huawei Enterprise Blog](https://e.huawei.com/cz/blogs/2026/industries/finance/architecture-of-agentic-banking) - The transition to Agentic Banking represents a fundamental shift from human-initiated workflows to a...

129. [The Architecture of Agentic Banking – Huawei Enterprise Blog](https://e.huawei.com/fr/blogs/2026/industries/finance/architecture-of-agentic-banking) - By leveraging open-source models and an open ecosystem, Huawei, together with 10 RONGHAI ecosystem p...

130. [How Retail Banks Can Put Agentic AI to Work | BCG](https://www.bcg.com/publications/2026/how-retail-banks-can-put-agentic-ai-to-work) - While AI can streamline the customer onboarding experience, the back office is where it will deliver...

131. [The New Invisible Battlefield for Banks: AI Drives $262 Billion in Sales](https://www.fintechweekly.com/magazine/articles/ai-agents-262-billion-sales-banks-agentic-commerce-lending-2026) - AI agents influenced $262 billion in holiday sales. Banks that aren't readable by AI won't appear at...

132. [2026: The Year APIs and AI Become Non-Negotiable for Financial ...](https://tyk.io/blog/2026-the-year-apis-and-ai-become-non-negotiable-for-financial-services/) - Learn how APIs and financial services will shape the industry as AI and regulatory changes revolutio...

133. [Agentic AI in Banking: 2026 Implementation Guide - Neontri](https://neontri.com/blog/agentic-ai-banking/) - Months 12–18: Production deployment. First agent in production. Move the first agent into production...

134. [Financial Services & AI: 2026 Trends Report - Flowable](https://www.flowable.com/resources/banking-trends-report) - 2026 Trends Report: How banks are driving growth, control, and customer trust through AI-driven orch...

135. [Local LLM Deployment: Privacy-First AI Complete Guide](https://www.digitalapplied.com/blog/local-llm-deployment-privacy-guide-2025) - Conclusion. Local LLM deployment has matured into a viable option for organizations prioritizing dat...

