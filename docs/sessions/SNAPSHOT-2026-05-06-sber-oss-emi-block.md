# SNAPSHOT — Sber OSS for EMI BANXE AI BANK (v2, EMI-corrected)

## Метаданные

| Поле | Значение |
|------|----------|
| Тип | Roadmap Block (Sber OSS for EMI BANXE) |
| Дата | 2026-05-06 (CEST) |
| Базовый чекпоинт | `checkpoint-2026-05-06-progress-snapshot` → `24ad91a` |
| Источники | v1 «Open Source Сбера для EMI BANXE» (исторический контекст, кредитные сценарии исключены) + v2 «Open Source Сбера для EMI BANXE — EMI-corrected» (каноническая) |
| Каноническая версия | v2 (EMI-corrected): AML/fraud/KYC/SAR/MiCA-фокус, без кредитования, с GDPR-ограничением GigaChat |
| Тег после merge | `checkpoint-2026-05-06-sber-oss-emi-block` (ставит оператор) |

**Цель документа:** зафиксировать как часть roadmap инвентаризацию Open Source-инструментов Сбера, применимых в EMI BANXE AI BANK, с явным разделением «применимо / не применимо», регуляторными ограничениями и точками интеграции в существующий стек. Это документ-план; код в banxe-emi-stack в этом ходе не создаётся.

---

## 1. Регуляторный контекст EMI

### Что разрешает EMI-лицензия (EMD2 / PSD2)

- Выпуск электронных денег (e-money issuance)
- IBAN-счета и хранение клиентских средств (safeguarding по CASS 15)
- Переводы: SEPA, SWIFT, FPS, CHAPS
- Карты (prepaid / debit, Mastercard / Visa)
- Money remittance и FX-конвертация
- PIS / AIS (PSD2 Open Banking)
- EMT (Electronic Money Token) под MiCA

### Что НЕ разрешает EMI-лицензия

- Кредитование, займы, BNPL
- Привлечение депозитов
- Инвестиционные услуги
- PD-модели (Probability of Default), credit scoring

### Главный AML/CFT-приоритет EMI (EBA)

Transaction monitoring и SAR/STR-генерация. Именно здесь Sber OSS даёт максимальный ROI для BANXE.

### Коррекция v1

PD-модели, кредитный скоринг, BNPL — полностью исключены из применений Sber OSS в BANXE. Только применения в рамках EMI-периметра.

---

## 2. Экосистема Sber OSS — релевантные продукты

### Группа A — AI-агенты и LLM (ai-forever / GigaChain)

| Продукт | Репозиторий | Суть | Лицензия |
|---------|-------------|------|----------|
| gigachat | ai-forever/gigachat | Python SDK для GigaChat API (OpenAI-совместимый интерфейс) | MIT |
| langchain-gigachat | ai-forever/langchain-gigachat | LangChain-интеграция: chains, agents, RAG поверх GigaChat | MIT |
| GigaAgent | ai-forever/GigaAgent | Готовые compliance-агенты: Document Extraction, Sanctions & PEP, Risk Scoring | MIT |
| gpt2giga | ai-forever/gpt2giga | Drop-in OpenAI → GigaChat прокси; меняет базовый URL, не меняет код | MIT |
| gigachain | ai-forever/gigachain | Fork LangChain с нативной GigaChat-поддержкой и Russian-optimized prompts | MIT |

### Группа B — ML для финансового мониторинга (Sberbank AI Lab)

| Продукт | Репозиторий | Суть | Лицензия |
|---------|-------------|------|----------|
| LightAutoML | sberbank-ai/LightAutoML | AutoML для табличных данных: fraud, AML risk scoring, быстрый цикл обучения | Apache 2.0 |
| pytorch-lifestream | dllllb/pytorch-lifestream | Sequence embeddings транзакционных потоков (RNN/Transformer); anomaly detection | Apache 2.0 |
| AutoMLWhitebox | sberbank-ai/AutoMLWhitebox | Интерпретируемые linear/tree-модели; feature importance для регуляторных объяснений | Apache 2.0 |

---

## 3. Применения в EMI-операциях BANXE

### 3.1 AML Transaction Monitoring (G-KYC-01/02, ADR-027/028)

**Стек:** `pytorch-lifestream` → `LightAutoML` → `AutoMLWhitebox`

**Пайплайн:**

```
Транзакционный поток (event_bus.py: PAYMENT_COMPLETED)
        │
        ▼
pytorch-lifestream: TrxEncoder + RnnSeqEncoder
(sequence embeddings по customer_id за скользящее окно 90д)
        │
        ▼
LightAutoML: TabularAutoML
(feature importance: velocity, counterparty network, geo-anomaly)
        │
        ▼
AutoMLWhitebox: интерпретируемая модель
(объяснение для SAR, регуляторный аудит)
        │
        ▼
AML Alert → MLRO Queue (HITL L4, I-27)
    или
Автоматическая заморозка (PAYMENT_FROZEN event) при score > threshold
```

**Python-фрагмент (концептуальный):**

```python
from ptls.frames import PaddedBatch
from ptls.nn import TrxEncoder, RnnSeqEncoder

trx_encoder = TrxEncoder(
    embeddings={
        "mcc": {"in": 400, "out": 24},
        "currency": {"in": 50, "out": 4},
    },
    numeric_values={"amount": "identity"},
)
seq_encoder = RnnSeqEncoder(trx_encoder, hidden_size=256)

# customer_sequences: список транзакций за 90 дней
customer_emb = seq_encoder(PaddedBatch(customer_sequences, seq_lens))
```

**Связь с существующим стеком:** события `BanxeEventType.PAYMENT_COMPLETED` из `services/events/event_bus.py`; результаты → `services/aml/`; аудит → ClickHouse (I-08, I-24).

---

### 3.2 Fraud Detection на платёжных операциях

**Стек:** `LightAutoML` + `pytorch-lifestream`

**Применение:** Real-time fraud scoring при поступлении `PAYMENT_INITIATED` — до авторизации. LightAutoML обучается на исторических сигналах (velocity checks, device fingerprint, IP geolocation). pytorch-lifestream даёт sequence-фичи для поведенческого профиля клиента.

**Python-фрагмент (концептуальный):**

```python
from lightautoml.automl.presets.tabular_presets import TabularAutoML
from lightautoml.tasks import Task

task = Task("binary")
automl = TabularAutoML(
    task=task,
    timeout=300,
    cpu_limit=4,
    reader_params={"n_jobs": 4, "cv": 5},
)
# train_data: DataFrame с фичами транзакций + sequence embeddings
oof_pred = automl.fit_predict(train_data, roles={"target": "is_fraud"})
```

**Порог и HITL:** fraud_score >= 0.8 → автоблокировка + `PAYMENT_FROZEN`; 0.6–0.8 → HITL L3 (Fraud Analyst, agent-authority.md).

---

### 3.3 KYC и онбординг

**Стек:** `GigaAgent` + `langchain-gigachat`

**Агентные роли (4 субагента):**

1. **Document Extraction Agent** — извлечение данных из паспорта/utility bill через Vision
2. **Sanctions & PEP Agent** — проверка по OFAC, EU Consolidated List, UN списки
3. **Risk Scoring Agent** — оценка риска клиента (jurisdictions I-02, EDD I-04)
4. **Onboarding Decision Agent** — финальное решение → HITL L4 для PEP/high-risk

**Python-фрагмент (концептуальный):**

```python
from langchain_gigachat import GigaChat
from langchain.agents import create_react_agent
from langgraph.checkpoint.postgres import PostgresSaver

llm = GigaChat(
    credentials="<GIGACHAT_CREDENTIALS>",
    scope="GIGACHAT_API_PERS",  # или GIGACHAT_API_CORP для Enterprise
    verify_ssl_certs=True,
)

# PostgresSaver: checkpoint состояния агента в PostgreSQL (уже развёрнут в BANXE)
checkpointer = PostgresSaver.from_conn_string(settings.DATABASE_URL)

kyc_agent = create_react_agent(
    llm, tools=[doc_extraction_tool, sanctions_tool, risk_score_tool],
    checkpointer=checkpointer,
)
```

**Связь:** `services/kyc/kyc_port.py`, `KYCLifecycleEngine.notify_attribute_change()` (ADR-028). GDPR: документы клиента — EU/EEA PII, обязателен on-premise GigaChat или EU-LLM (см. §6).

---

### 3.4 AI Customer Support

**Стек:** `GigaAgent` / `langchain-gigachat` + RAG (Qdrant) + Mem0

**Применение:**

- FAQ о тарифах, лимитах, статусах транзакций
- Escalation path к агентам (HITL L2 → L4 в зависимости от типа запроса)
- Multilingual: RU + EN + (опционально другие EU-языки)

**Примеры запросов:**

```
"Почему моя транзакция заморожена?" → поиск по event_bus истории → объяснение (маскированное)
"Как повысить лимит перевода?" → ссылка на KYC upgrade process
"Мне нужна выписка за последние 3 месяца" → services/statements/ → PDF генерация
```

**GDPR-замечание:** разговоры с клиентами содержат PII. Обязателен EU-хостинг модели (OpenAI EU, Anthropic EU Azure) через LangChain-интерфейс — тот же код, другой LLM.

---

### 3.5 Drop-in замена OpenAI → GigaChat (gpt2giga)

**Стек:** `gpt2giga`

**Применение:** Все существующие OpenAI-интеграции в BANXE переключаются на GigaChat без изменения кода — только меняется `base_url` и `api_key`.

**docker-compose фрагмент:**

```yaml
services:
  gpt2giga-proxy:
    image: ai-forever/gpt2giga:latest
    environment:
      GIGACHAT_CREDENTIALS: "${GIGACHAT_CREDENTIALS}"
      GIGACHAT_SCOPE: "GIGACHAT_API_CORP"  # Enterprise on-premise
    ports:
      - "8765:8765"
    # Все сервисы BANXE с OPENAI_BASE_URL=http://gpt2giga-proxy:8765/v1
```

**Когда применять:** неперсонализированные внутренние задачи (summarization регуляторных документов, code generation, internal tooling). PII клиентов — только через EU-LLM или on-premise.

---

### 3.6 Автогенерация SAR (Suspicious Activity Report)

**Стек:** `langchain-gigachat` + `LangGraph` + RAG (регуляторные шаблоны FCA/NCA)

**Пайплайн:**

```
AML Alert (score > threshold)
        │
        ▼
LangGraph SAR Workflow:
  Step 1: Сбор контекста (transaction history, customer risk profile)
  Step 2: Поиск по регуляторным шаблонам FCA/NCA via RAG
  Step 3: GigaChat: генерация черновика SAR
  Step 4: HITL L4 — MLRO review (обязательно по POCA 2002 s.330)
  Step 5: Submit to NCA (go-AML или аналог)
```

**Ключевое ограничение (I-27):** AI ПРЕДЛАГАЕТ черновик SAR, MLRO ПРИНИМАЕТ решение и подписывает. Никакой автоподачи SAR без человека L4.

**GDPR:** черновик SAR содержит PII подозреваемого — строго on-premise или EU LLM.

---

### 3.7 Crypto / MiCA / Travel Rule мониторинг

**Стек:** `pytorch-lifestream` + `GigaAgent` + `LightAutoML`

**Применение:**

- **On-chain embeddings:** pytorch-lifestream применяется к последовательностям on-chain транзакций (wallet address as customer_id, txn amount/type как фичи) для обнаружения mixer/tumbler-паттернов
- **Wallet risk classifier:** LightAutoML обучается на on-chain сигналах (VASP jurisdiction, counterparty wallet history, layering patterns)
- **Travel Rule compliance:** GigaAgent + langchain-gigachat для автоформатирования IVMS101-сообщений при переводах > 1000 EUR (MiCA Art.68)
- **EMT monitoring:** для EMT (Electronic Money Token) — интеграция с Phase 6 Crypto Block roadmap

**Связь:** Phase 6 (ROADMAP.md), prompts/22-crypto-compliance-flow.md (открытый prompt).

---

## 4. Архитектурная карта

```
+---------------------------------------------------------------------+
|                    EMI BANXE AI Bank                                |
+----------------------+----------------------------------------------+
|  Mobile / Web App    |  Compliance Dashboard                        |
|  (React 19 / Expo)   |  (AML alerts, SAR queue, KYC status)         |
+----------------------+----------------------------------------------+
                              |
                              v
+---------------------------------------------------------------------+
|                    FastAPI Backend (banxe-emi-stack)                |
|  services/payment/ | services/aml/ | services/kyc/ | services/auth/ |
|  services/customer_lifecycle/ | services/events/event_bus.py        |
+---------------------------------------------------------------------+
                              |
                              v
+---------------------------------------------------------------------+
|              Sber OSS Integration Layer                             |
+-----------------------+---------------------+-----------------------+
|  GigaAgent / LangGraph|  gpt2giga proxy     |  pytorch-lifestream   |
|  (KYC, SAR, Support)  |  (drop-in OpenAI)   |  (trx embeddings)     |
+-----------------------+---------------------+-----------------------+
|  LightAutoML                                |  AutoMLWhitebox       |
|  (fraud/AML scoring, wallet risk)           |  (interpretable SAR)  |
+---------------------------------------------+-----------------------+
                              |
                              v
+---------------------------------------------------------------------+
|                    Audit & Storage                                  |
|  ClickHouse (I-08, I-24) | PostgreSQL 17 | Redis | RabbitMQ         |
+---------------------------------------------------------------------+
```

### Стыковка с существующим стеком BANXE

| Sber OSS-компонент | Точка интеграции BANXE |
|-------------------|------------------------|
| pytorch-lifestream embeddings | Подписчик на `BanxeEventType.PAYMENT_COMPLETED` / `PAYMENT_FROZEN` через `InMemoryEventBus` / `RabbitMQEventBus` |
| LightAutoML fraud scorer | Вызывается в `services/aml/` pipeline до авторизации платежа |
| GigaAgent KYC | Реализует `KYCGuardPort` (Protocol DI); вызывается из `KYCLifecycleEngine.transition()` |
| langchain-gigachat SAR | Запускается HITL-очередью `services/hitl/hitl_service.py` (L4 gate) |
| gpt2giga proxy | Подменяет `OPENAI_BASE_URL` для внутренних tooling-задач |
| AutoMLWhitebox | Генерирует feature importance для ClickHouse audit trail (I-24) |

Deadlines для интеграции в этом документе не устанавливаются.

---

## 5. Матрица приоритетов

| Приоритет | Продукт | EMI-применение | Сложность | Лицензия |
|-----------|---------|----------------|-----------|----------|
| Высокий | `gpt2giga` | Drop-in OpenAI proxy для внутренних задач | Низкая (только конфиг) | MIT |
| Высокий | `gigachat` Python SDK | AML alert summarization, SAR drafting | Низкая | MIT |
| Высокий | `LightAutoML` | Fraud detection, AML risk scoring | Средняя | Apache 2.0 |
| Высокий | `pytorch-lifestream` | Transaction sequence embeddings | Средняя | Apache 2.0 |
| Средний | `AutoMLWhitebox` | Interpretable models для SAR explainability | Средняя | Apache 2.0 |
| Средний | `langchain-gigachat` + LangGraph | SAR workflow, KYC agent orchestration | Высокая | MIT |
| Долгосрочный | `GigaAgent` (полный) | Autonomous KYC + compliance workflow | Высокая | MIT |

---

## 6. Регуляторные ограничения и GDPR

### 6.1 GigaChat API — запрет на EU/EEA PII

**Жёсткое правило (кандидат-инвариант):**

> **Pending invariant proposal I-37 — Sber GigaChat: no EU/EEA PII to public GigaChat endpoint**
>
> Персональные данные клиентов EMI BANXE, находящихся в EU/EEA (в т.ч. имена, адреса, IBAN,
> документы, транзакционная история), не передаются в публичный GigaChat API
> (`gigachat.devices.sberbank.ru`).

Статус: pending proposal — инвариант не добавляется в `INVARIANTS.md` в этом PR, требует отдельного ADR.

**Допустимые режимы использования GigaChat:**

| Сценарий | Допустимость | Условие |
|----------|-------------|---------|
| Агрегированные/анонимизированные задачи (summarization документов, code gen) | Допустимо | Нет PII клиентов |
| GigaChat Enterprise on-premise (BANXE-owned инфраструктура) | Допустимо | Данные не покидают периметр |
| Клиентские чат-боты с EU/EEA PII | Запрещено через публичный endpoint | Обязателен EU LLM через тот же LangChain-интерфейс |
| KYC-агент с документами клиента | Запрещено через публичный endpoint | On-premise или EU LLM |
| SAR-черновик с PII подозреваемого | Запрещено через публичный endpoint | On-premise или EU LLM |

### 6.2 ML-библиотеки Sberbank AI Lab — без GDPR-рисков

`LightAutoML`, `pytorch-lifestream`, `AutoMLWhitebox` — чистые Python-пакеты. Обучение и инференс происходят на инфраструктуре BANXE. Данные не покидают периметр. GDPR Article 28 (processor) не применяется.

### 6.3 Лицензионная чистота

| Группа | Лицензия | Коммерческое использование |
|--------|----------|---------------------------|
| ai-forever/* (gigachat, langchain-gigachat, GigaAgent, gpt2giga, gigachain) | MIT | Разрешено |
| Sberbank AI Lab/* (LightAutoML, pytorch-lifestream, AutoMLWhitebox) | Apache 2.0 | Разрешено |

---

## 7. Связи с существующими ADR и Track'ами

### Точки пересечения с активными треками

| Track / ADR | Связь с Sber OSS |
|-------------|-----------------|
| **Track A · ADR-028** (KYC re-trigger events) | KycReTriggerEvent (ROLE_CHANGED, JURISDICTION_CHANGED) может запускать GigaAgent KYC sub-workflow |
| **ADR-027** (audit-trail durability) | Все Sber OSS-инференсы логируются в ClickHouse через существующий audit-trail (I-08, I-24) |
| **Phase 6** (Crypto Block) | pytorch-lifestream embeddings + GigaAgent для MiCA/Travel Rule мониторинга |
| **prompts/19** (Customer Support AI) | GigaAgent + langchain-gigachat как реализация customer support блока |
| **prompts/20** (Marketing AI) | langchain-gigachat для персонализированных (анонимизированных) кампаний |
| **prompts/23** (Agent Communication Bus) | GigaAgent субагенты регистрируются в agent-communication-bus через `services/events/event_bus.py` |

### Резервные ADR (создавать в этом PR не нужно)

| ADR ID (резерв) | Тема | Приоритет |
|-----------------|------|-----------|
| ADR-039 | Sber OSS integration policy — правила использования, тест-план, GDPR-матрица | P1 |
| ADR-040 | GigaChat data residency boundary — формальное закрепление I-37 | P1 |

---

## 8. Якоря для продолжения

- **Базовый тег:** `checkpoint-2026-05-06-progress-snapshot`
- **Тег этого блока** (ставит оператор после merge): `checkpoint-2026-05-06-sber-oss-emi-block`
- **Следующие возможные блоки** (без обязательств):
  - ADR-039 — Sber OSS integration policy (формализация правил, GDPR-матрица)
  - ADR-040 — GigaChat data residency boundary (закрепление pending I-37)
  - PoC: gpt2giga + LightAutoML на реальных транзакционных данных (staging)
  - PoC: pytorch-lifestream embeddings на банковских транзакциях BANXE

---

## 9. Дополнения

*(append-only — новые записи ниже этой строки)*
