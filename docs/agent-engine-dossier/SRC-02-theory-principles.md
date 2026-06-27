# SRC-02 — Теоретические принципы

**Статус:** INGESTED
**Загружен:** 2026-06-28
**Источник:** Часть аналитического корпуса, передана оператором

---

## Содержание

[ФАКТ] В корпусе упомянуты следующие теоретические паттерны для агентских систем:
- ReAct (Reasoning + Acting) — чередование рассуждения и действия
- Chain-of-Thought (CoT) — цепочка рассуждений перед действием
- MARL (Multi-Agent Reinforcement Learning) — многоагентное обучение с подкреплением
- HTN (Hierarchical Task Networks) — иерархическое планирование задач

[ФАКТ] В корпусе упомянут пример SWIFT-flow DAG как иллюстрация HTN-планирования.

[ФАКТ] Упомянута архитектура vector memory: Qdrant поверх ClickHouse — описана как PLANNED (не как deployed).

[НЕИЗВЕСТНО] Степень реализации ReAct/CoT/MARL/HTN как рабочего кода в текущем репозитории — не верифицирована без shell-аудита.

[НЕИЗВЕСТНО] Текущий deployment-статус Qdrant (порт :6333) — согласно VERIFIED-RUNTIME-SNAPSHOT.md: NOT LISTENING на момент snapshot.

[ВЫВОД] Теоретическая база обоснована и применима к BANXE-CORE-ENGINE, однако практическая реализация каждого паттерна требует отдельной верификации перед включением в sprint.

---

## Cross-references

- ADR-136 (agent memory substrate) — архитектурная основа для vector memory
- ADR-141 (self-healing / continuous learning) — связан с MARL-паттерном
- SRC-06 (academic references) — первоисточники ReAct/CoT/MARL
- VERIFIED-RUNTIME-SNAPSHOT.md — статус Qdrant / ClickHouse

---

## Pending

SRC-03/04/05/08 могут содержать расширение теоретической базы. До загрузки — [НЕИЗВЕСТНО].
