# SRC-01 — Ландшафт агентских систем

**Статус:** INGESTED
**Загружен:** 2026-06-28
**Источник:** Часть аналитического корпуса, передана оператором

---

## Содержание

[ФАКТ] Корпус описывает класс агентских систем типа Manus — полностью автономные LLM-агенты, способные выполнять многошаговые задачи без постоянного участия человека.

[ФАКТ] В корпусе упомянуты 10 OSS-фреймворков как ландшафт сравнения:
- OpenManus
- OWL / CAMEL
- AutoGPT
- CrewAI
- LangGraph
- AutoGen (Microsoft)
- AgentScope (Alibaba)
- MetaGPT
- Haystack
- TaskWeaver

[НЕИЗВЕСТНО] Конкретные версии, лицензии и production-readiness каждого фреймворка в контексте BANXE — не верифицированы без отдельного технического аудита.

[ВЫВОД] Наличие развитого OSS-ландшафта означает, что BANXE-CORE-ENGINE не создаётся в вакууме: существуют проверенные паттерны, которые можно адаптировать с учётом регуляторных ограничений (HITL, AGPL, INV-AI-01).

---

## Cross-references

- ADR-060 (multi-actor orchestration) — архитектурная опора
- ADR-128 (HITL matrix) — ограничивает автономность Manus-класса
- SRC-07 (constraints) — регуляторные фильтры применения OSS
- VERIFIED-RUNTIME-SNAPSHOT.md — текущий deployment-статус

---

## Pending

SRC-03/04/05/08 могут содержать дополнительный ландшафтный материал. До их загрузки — [НЕИЗВЕСТНО].

---

## BANXE-STATUS mapping (добавлено 2026-06-28)

Привязка OSS-кандидатов из Landscape §2 к production-статусам BANXE-CORE-ENGINE.
Источник: docs/COMPLIANCE-MATRIX.md (verified D4 @ origin/main).

| OSS-кандидат (из Landscape) | BANXE-STATUS | COMPLIANCE-MATRIX ref |
|----------------------------|-------------|----------------------|
| LangGraph | DEPLOYED | S7-06/C-27/S11-11/S12-13 ✅ DONE |
| AutoGen | DEPLOYED | S7-08/C-29 ✅ DONE |
| Temporal | NOT_STARTED (infra-scope) | FA-11 ❌ → banxe-ai-infrastructure |
| Qdrant | PLANNED | — (not in matrix; ClickHouse = base) |
| MCP orchestration | PARTIAL | S12-16 (LangGraph✅/Lerian❌) |
| GigaAgent | BLOCKED | I-02/RU |
| Mem0 | EVAL | SNAPSHOT-2026-05-06 |
| Manus (closed-source) | REFERENCE | SRC-01 §1 (benchmark only) |

**[ВЫВОД]** Из 10 оцениваемых OSS-инструментов 2 уже DEPLOYED (LangGraph, AutoGen),
1 — PARTIAL (MCP), 1 — PLANNED (Qdrant), 1 — NOT_STARTED/infra (Temporal),
1 — BLOCKED (GigaAgent), остальные — REFERENCE/EVAL.

---

## OSS Descriptors (Corpus Part 1)

> Descriptor layer sourced from corpus Part 1 (operator-provided, 2026-06-28).
> OSS names and BANXE-STATUS: see existing sections above (not duplicated here).
> Format: OSS | Technical descriptor | BANXE relevance

| OSS | Technical Descriptor [ФАКТ из корпуса] | BANXE Relevance |
|-----|----------------------------------------|-----------------|
| **OpenManus** | Прямая OSS-имплементация Manus. Stack: LangChain + browser-use + computer-use. ~40k★ на момент публикации. | Реализует browser/computer-use агентов — релевантно для будущего UI-тестирующего агента и RPA-слоя. |
| **OWL (CAMEL)** | Multi-agent role-collaboration framework. GAIA benchmark: 58.18% — превосходит Manus (58.15%) и GPT-4o (34.36%). | Высший GAIA-результат среди OSS; сильная альтернатива для multi-agent reasoning задач. |
| **AutoGPT** | Пионер autonomous agents (апр 2023). ~170k★. Production-ready backend: PostgreSQL + Redis + vector store. | [DEPLOYED смотри BANXE-STATUS выше] Зрелая инфраструктура хранения состояния агентов. Persistent memory-паттерн. |
| **CrewAI** | Enterprise role-based orchestration. Агенты с явными ролями + процессными цепочками. | Ближайший архитектурный аналог 4-Partner Compliance Swarm (MLRO/AML/Sanctions/TM). |
| **LangGraph** | Граф-/FSM-оркестрация, persistent state, rollback. | [DEPLOYED смотри BANXE-STATUS выше] Compliance-workflow с откатом — прямо применимо к CASS 15 reconciliation FSM. |
| **AutoGen (MS)** | Async multi-agent (v0.4+ AgentChat). Fintech-proven. | [DEPLOYED смотри BANXE-STATUS выше] Fintech-reference; паттерн AgentChat совместим с Guardian L1-L4. |
| **AgentScope (Alibaba)** | Distributed agents + load-balancing между узлами. | Релевантно evo1 (control-plane) + evo2 (reasoning) + Legion (ops) — 3-узловая топология. |
| **MetaGPT** | Роли: PM / Architect / Dev / QA / DataAnalyst в едином pipeline. | Аналог текущего фабричного pipeline: Claude Code (Architect) + Aider (Dev) + MiroFish (QA). |
| **Haystack** | RAG + agentic pipelines. Fintech-reference implementation. | Релевантно Compliance KB (IL-CKS-01) и будущему Semantic Memory слою (ADR-136/137, GAP §4.3). |
| **TaskWeaver** | Data-analytics code-execution agent. Безопасное выполнение кода в изолированном окружении. | Прямо применимо к Analytics-агенту и к GAP Execution Sandbox (§4.5 audit report). |
| **Manus** *(reference)* | Butterfly Effect. Closed-source. GAIA 58.15% vs GPT-4o 34.36%. Async + multiagent + virtual FS. Эталон производительности. | [REFERENCE] Baseline для оценки производительности BANXE Agent Runtime. OWL превосходит по GAIA. |

### Descriptor Notes

- **BANXE-STATUS** (DEPLOYED/PLANNED/PARTIAL/BLOCKED/NOT_STARTED) — в существующей таблице выше; не дублируется.
- **★-статистика** — на момент публикации корпуса (2026-06 или ранее); может меняться.
- **GAIA-бенчмарк** — общий агентский бенчмарк (не финтех-специфичный); использовать как ориентир, не как финальный критерий.
- Источник: Corpus Part 1 (operator-provided); маркер [ФАКТ из корпуса].

---

## Rationale — why BANXE needs a Manus-class engine (Corpus §1.1)

> Источник: Corpus §1.1 [ФАКТ из корпуса §1.1], 2026-06-28.
> НЕ дублирует descriptors/name-list/BANXE-STATUS (см. §выше). Только концептуальное обоснование.

---

### Manus-класс vs chatbot+tools: принципиальное отличие

**Chatbot+tools:** запрос → один инструмент → ответ. Человек управляет каждым шагом.

**Manus-класс (агентский движок):**
- **Автономная декомпозиция задач**: получив высокоуровневую цель, агент самостоятельно разбивает её на подзадачи — без пошаговых инструкций от человека.
- **Выбор инструментов**: агент динамически определяет, какие инструменты/сервисы нужны для каждой подзадачи.
- **Параллельное/последовательное исполнение**: подзадачи выполняются одновременно (multiagent parallel) или последовательно — в зависимости от зависимостей между ними.
- **Контекст между сессиями**: промежуточные результаты сохраняются и доступны в следующих сессиях (virtual file system / persistent memory).
- **Адаптация к ошибкам без человека**: при сбое агент переключается на альтернативный путь самостоятельно, не эскалируя каждую ошибку оператору.

---

### 3 ключевых свойства Manus-класса [ФАКТ из корпуса §1.1]

| Свойство | Описание | BANXE-релевантность |
|----------|----------|-------------------|
| **Async execution** | Агент работает пока пользователь занят другим. Нет блокирующего ожидания. | Клиент инициирует перевод → агент асинхронно обрабатывает compliance/FX/routing пока клиент не ждёт. |
| **Multiagent parallel execution** | Несколько агентов выполняют независимые подзадачи одновременно. | AML-check + FX-rate-fetch + account-validation выполняются параллельно (не последовательно). |
| **Virtual file system** | Промежуточные результаты сохраняются как файлы/артефакты между шагами и сессиями. | Partial reconciliation state, draft FIN060, staged CAMT.053 — всё сохраняется между cron-запусками. |

---

### Banking-координация: почему это необходимо для BANXE [ФАКТ из корпуса §1.1]

Одна клиентская операция — международный перевод с валютной конвертацией — требует одновременной координации ДЕСЯТКОВ систем:

```
[Клиент: "отправить £5000 → EUR счёт в DE"]
             ↓
┌─────────────────────────────────────────────────────────────┐
│ Параллельный fanout (все одновременно):                     │
│  ① AML check         → services/aml/               │
│  ② Sanctions screen  → services/aml/tx_monitor      │
│  ③ FX rate fetch     → Frankfurter :8080 (ECB)      │
│  ④ Source balance    → Midaz ledger :8095            │
│  ⑤ IBAN validation   → adorsys PSD2 gateway          │
│  ⑥ Jurisdiction check→ hard-block RU/BY/IR/KP/...   │
│  ⑦ EDD threshold?    → £10k individual / £50k corp  │
│  ⑧ Counterparty KYC  → Ballerine :3000              │
└─────────────────────────────────────────────────────────────┘
             ↓ (все прошли)
┌─────────────────────────────────────────────────────────────┐
│ Последовательно:                                            │
│  ⑨  Debit source account     → Midaz create_tx()    │
│  ⑩  Credit FX conversion     → Midaz + FX adapter   │
│  ⑪  SWIFT/SEPA routing       → adorsys PSD2          │
│  ⑫  pgAudit + ClickHouse log → I-24 append-only     │
│  ⑬  Safeguarding recon update→ CASS 15 check         │
└─────────────────────────────────────────────────────────────┘
             ↓
     [Клиент получает подтверждение]
```

> **Вывод**: последовательный chatbot+tools выполнял бы шаги ①–⑧ по одному → latency ×8, ненадёжность цепочки. Manus-класс (async + multiagent parallel + virtual FS) делает эту координацию **практичной и compliant** в банковском домене.

**Соответствие BANXE-архитектуре:**
- Async: CASS 15 daily recon (cron, не блокирует клиентов) → ✅ PRESENT
- Multiagent parallel: compliance swarm (AML/KYC/Sanctions параллельно) → ✅ PRESENT (swarm.yaml)
- Virtual FS: ClickHouse audit store + Redis intermediate state + Qdrant (PLANNED) → PARTIAL
- Full banking-coordination orchestration: Intent Dispatcher ADR-049 → ❌ NOT DEPLOYED (GAP #842)
