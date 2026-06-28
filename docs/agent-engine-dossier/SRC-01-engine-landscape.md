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
