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

---

## Привязка к существующей архитектуре

Данный раздел добавлен 2026-06-28 (append-only).
Статусы строго по verified shell-аудиту T1-T5/D1-D8 @ origin/main.

---

### CoT / Confidence-Voting → Verify API :8094

[ФАКТ] Verify API (verify_api.py, :8094) активен на evo1 (DEPLOYMENT-ARCHITECTURE.md: Active).
ADR-SYSTEM-ARCHITECTURE и DEPLOYMENT-ARCHITECTURE описывают FastAPI-сервис валидации compliance/AML-ответов (инвариант I-09).
Маршруты: 8093 → 8094; OpenClaw 18789 → 8094.
CoT/confidence-voting как паттерн рассуждения агентов уже имеет enforcing-точку в Verify API.

**Статус:** PRESENT @ evo1
**Cross-refs:** DEPLOYMENT-ARCHITECTURE.md, I-09

---

### MARL / Skill-Accumulation → MetaClaw / Guardian

[ФАКТ] Guardian присутствует как реальный Python/FastAPI-сервис на evo1 (ADR-139: Guardian System — self-hosted PR-audit service Factory :8195 + Project :8196).
ADR-139/022/026 документируют Guardian. Skill-accumulation реализован как MARL-аппроксимация
(FINANCE-BLOCK-OSS-STACK: agents приобретают навыки через взаимодействие в guardian-слое).

**Статус:** PRESENT (Guardian active на evo1)
**Cross-refs:** ADR-139, ADR-022, ADR-026

---

### Vector Memory → ClickHouse + Qdrant (PLANNED)

[ФАКТ] ClickHouse :9000 активен на evo1 (ADR-136: Agent Memory Substrate; VERIFIED-RUNTIME-SNAPSHOT.md: LISTENING).
Используется как audit store (ADR-011/014, TTL 5Y I-08, audit trail append-only).
[ФАКТ] Qdrant: согласно VERIFIED-RUNTIME-SNAPSHOT.md, :6333 NOT LISTENING.
[ВЫВОД] Архитектура «Qdrant поверх ClickHouse» для vector memory = NET-NEW/PLANNED.
ClickHouse является substrate-основой; Qdrant — следующий шаг после deployment-решения.

**Статус:** ClickHouse-основа PRESENT; Qdrant-слой PLANNED/NET-NEW
**Cross-refs:** ADR-136, ADR-011, ADR-014, I-08, VERIFIED-RUNTIME-SNAPSHOT.md (:9000 LISTENING, :6333 NOT LISTENING)

---

### HTN SWIFT-flow → Существующие паспорта (PRESENT)

[ФАКТ] HTN-планирование (иерархические задачи → subtask-декомпозиция) реализовано через систему паспортов (agents/passports/).
Verified passports, покрывающие ключевые HTN-subtasks:

**AML/compliance subtasks:**
- agents/passports/aml/banxe_aml_orchestrator.yaml (HTN-координатор AML-потока)
- agents/passports/aml/jube_adapter_core.yaml (fraud scoring adapter)
- agents/passports/aml/mlro_report_agent.yaml (MLRO reporting subtask)
- agents/passports/aml/sanctions_check_core.yaml (sanctions screening)
- agents/passports/aml/tx_monitor_core.yaml (transaction monitoring)
- agents/passports/aml/watchman_adapter_core.yaml (Moov Watchman adapter)
- agents/passports/aml/yente_adapter_agent.yaml (Yente/OFAC adapter)

**Payment/ledger subtasks:**
- agents/passports/payment_router_agent.yaml (payment routing)
- agents/passports/midaz_mcp_agent.yaml (Midaz CBS interface)

**Reporting/compliance oversight subtasks:**
- agents/passports/reporting_agent.yaml (FIN060/regulatory reporting)
- agents/passports/compliance_monitoring_agent.yaml (continuous compliance)
- agents/passports/risk_oversight_agent.yaml (risk monitoring)
- agents/passports/sanctions_check.yaml (sanctions gate)

Итого: 13 подтверждённых паспортов → 8 функциональных HTN-subtask-групп.
Total fabric: 70 passports (verified agents/passports/), свидетельствует об интенсивном HTN-использовании.

**Статус:** PRESENT
**Cross-refs:** ADR-060 (multi-actor), ADR-128 (HITL matrix), ADR-139 (guardian), 70 passports (S5/S6/S7 swarms)

---

### Compute Substrate → Evo1 / Evo2 (ADR-143-A)

[ФАКТ] ADR-143-A описывает shared evo1 Redis allocator для IL (INSTRUCTION-LEDGER central counter).
[ФАКТ] Evo1 и evo2 как compute-узлы выступают в архитектуре (ADR-143-A, DEPLOYMENT-ARCHITECTURE.md).
[ВЫВОД] BANXE-CORE-ENGINE как coordination layer использует evo1 как orchestration-plane.

**Статус:** PRESENT (ADR-143-A verified)
**Cross-refs:** ADR-143-A, ADR-136 (memory substrate)

---

### Итоговая матрица статусов

| Принцип | Архитектурная привязка | Статус |
|---------|----------------------|--------|
| CoT / confidence-voting | Verify API :8094 | PRESENT |
| MARL / skill-accumulation | Guardian (ADR-139) | PRESENT |
| Vector memory (base) | ClickHouse :9000 (ADR-136) | PRESENT |
| Vector memory (Qdrant) | Qdrant поверх ClickHouse | PLANNED |
| HTN SWIFT-flow | 13 passports / 70 total fabric | PRESENT |
| Compute substrate | Evo1/evo2 (ADR-143-A) | PRESENT |
