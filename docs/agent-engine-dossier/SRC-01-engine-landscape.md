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
