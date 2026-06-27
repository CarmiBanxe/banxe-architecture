# SRC Intake Register — BANXE-CORE-ENGINE / Агентский движок

**Досье:** BANXE-CORE-ENGINE (Manus-class agent orchestration layer)
**Namespace:** docs/agent-engine-dossier/
**Snapshot basis:** origin/main @ 6602842, 2026-06-28
**Template:** docs/paybis-dossier/SRC-INTAKE-REGISTER.md

---

## Roadmap Gating Rule

Ни один архитектурный эпик или спринт движка НЕ стартует, пока соответствующий SRC не переведён в статус INGESTED.
Статус PENDING-INTAKE = источник зарезервирован, контент не загружен, гипотезы из него — [НЕИЗВЕСТНО].

---

## Confirmed-present (INGESTED)

| ID | Источник | Статус | Traceability |
|----|---------|--------|-------------|
| SRC-01 | Ландшафт агентских систем: Manus + 10 OSS фреймворков (OpenManus, OWL/CAMEL, AutoGPT, CrewAI, LangGraph, AutoGen, AgentScope, MetaGPT, Haystack, TaskWeaver) | INGESTED | docs/agent-engine-dossier/SRC-01-engine-landscape.md |
| SRC-02 | Теоретические принципы: ReAct, CoT, MARL, HTN / SWIFT-flow DAG, vector memory (Qdrant поверх ClickHouse) | INGESTED | docs/agent-engine-dossier/SRC-02-theory-principles.md |
| SRC-06 | Академические ссылки: arxiv (Yao/Schick/Liu/Li/Wei/Hong), AMLSim, Temporal/LangGraph/AutoGen blogs | INGESTED | docs/agent-engine-dossier/SRC-06-references-academic.md |
| SRC-07 | Ограничения и guardrails: INV-AI-01 (no cloud LLM с PII), HITL I-27, AGPL Jube, 4 проблемы+решения, banxe-rag | INGESTED | docs/agent-engine-dossier/SRC-07-constraints-guardrails.md |
| SRC-09 | Pre-audit synthesis: BANXE-CORE-ENGINE как orchestration-слой поверх сервисов | INGESTED | docs/agent-engine-dossier/SRC-09-preaudit-synthesis.md |

---

## Pending-intake (НЕИЗВЕСТНО — контент не загружен)

| ID | Зарезервирован для | Статус | Примечание |
|----|--------------------|--------|-----------|
| SRC-03 | [НЕИЗВЕСТНО] — оператор не загрузил | PENDING-INTAKE | Не выдумывать контент до загрузки |
| SRC-04 | [НЕИЗВЕСТНО] — оператор не загрузил | PENDING-INTAKE | Не выдумывать контент до загрузки |
| SRC-05 | [НЕИЗВЕСТНО] — оператор не загрузил | PENDING-INTAKE | Не выдумывать контент до загрузки |
| SRC-08 | [НЕИЗВЕСТНО] — оператор не загрузил | PENDING-INTAKE | Не выдумывать контент до загрузки |

---

## Verified Architectural Base (cross-ref, не дублировать)

9 ADR подтверждены на origin/main @ 6602842:

- ADR-045 — intent-first banking architecture
- ADR-060 — multi-actor orchestration
- ADR-128 — banking agents HITL matrix
- ADR-136 — agent memory / shared memory substrate
- ADR-139 — guardian system
- ADR-141 — self-healing continuous learning loop
- ADR-042 — UFW perimeter
- ADR-123 — Claude permissions hardening
- ADR-143-A — shared-evo1 Redis IL allocator

Build-specs (verified on main):
- docs/architecture/M-GATEWAY-BUILD-SPEC.md
- docs/safeguarding/J-ENGINE-BUILD-SPEC.md
- docs/roadmap/intent-first-migration-roadmap-2026-06-08.md

---

## Existing Orchestration Layer (НЕ дублировать — ссылаться)

Не создавать новые ADR или код для следующих компонентов — они уже существуют:

- Ruflo: ruflo/ + ADR-RUFLO-01 (rule-following orchestrator)
- Aider: scripts/aider-banxe.sh + ADR-043
- MetaClaw: docs/audit/a8-metaclaw-resolution-2026-05-11.md
- Fabric/Legion: fabric/legion/gate_exec.py + fabric/common/fabric_redis.py
- Passports/Souls/Swarms: 70 passports / 20 souls / 3 swarms (verified S5/S6/S7)

BANXE-CORE-ENGINE coordinates above — does not replace them.

---

## Runtime Snapshot Reference

See: docs/agent-engine-dossier/VERIFIED-RUNTIME-SNAPSHOT.md
Snapshot @ origin/main 6602842, local host mark-legion.

---

## Change Log

| Date | Action |
|------|--------|
| 2026-06-28 | Intake register created (factory, IL via ADR-143-A allocator) |

---

## DEDUP-FINDINGS (добавлено 2026-06-28)

Файл `DEDUP-FINDINGS.md` фиксирует три категории:
1. **Existing engine scaffold** — INTENT-FIRST-CANON, planner.yaml, A4-proposal, HITL-gates, ADR-136:
   движок НЕ greenfield; досье дополняет, не заменяет каркас.
2. **Prior-art OSS** — LangGraph/Qdrant/Mem0 (SNAPSHOT-2026-05-06), Temporal (financial-analytics-research):
   PRIOR-ART; повторное исследование не требуется; GigaAgent BLOCKED (I-02/RU).
3. **Architecture boundary** — ADR-060 §6 / ADR-133: runtime (Temporal/Redis-lease) →
   `banxe-ai-infrastructure`; design contracts → `banxe-architecture`.

Sprint plan из досье: Sprint A (design) → здесь; Sprint B (runtime) → banxe-ai-infrastructure.
