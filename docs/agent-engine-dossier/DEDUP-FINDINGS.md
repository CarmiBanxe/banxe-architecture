# DEDUP-FINDINGS — Agent Engine Dossier
# Создано: 2026-06-28 | Ветка: agent/factory/agenteng01/intake-dossier | PR #838
# Статусы: PRESENT = подтверждено shell-аудитом; [НЕИЗВЕСТНО] = путь не найден.
# Назначение: зафиксировать существующий каркас и prior-art, исключить дублирование в досье.

---

## 1. Existing Engine Scaffold

Следующие артефакты уже существуют в banxe-architecture и **не воспроизводятся** в dosier —
dosier ссылается на них как на первичные источники.

| Артефакт | Что покрывает | Статус | Как на него ссылается досье |
|----------|--------------|--------|-----------------------------|
| `docs/canon/INTENT-FIRST-CANON-2026-06-07.md` | ADR-045-производный канон: система принимает user intent, агентская декомпозиция; архитектурный фундамент движка | PRESENT¹ | SRC-09 §Coordination Layer, SRC-INTAKE-REGISTER §Existing Orchestration |
| `docs/audit/intent-first-conformity-audit-2026-06-08.md` | Аудит соответствия intent-first canon по всем репозиториям | PRESENT¹ | Контекст для оценки «зрелости» каркаса |
| `docs/audit/INTENT-FIRST-REPO-AUDIT-MATRIX-2026-06-09.md` | Матрица repo → intent-first compliance | PRESENT¹ | Контекст для оценки «зрелости» каркаса |
| `docs/canon/passports/planner.yaml` | Planner passport — уже реализован; HTN-разложение задач на подзадачи | PRESENT¹ | SRC-02 §HTN SWIFT-flow: planner.yaml = HTN-реализация в продакшн |
| `docs/roadmap/audit-2026-05/A4-agents-orchestration-proposal.md` | A4 orchestration proposal: координационный слой над существующими сервисами | PRESENT¹ | SRC-09 §Coordination Layer и SRC-INTAKE-REGISTER §Existing Orchestration |
| `docs/policies/hitl-l3-agent-gate-2026-05-11.md` | HITL L3 gate policy: человеческое одобрение на L3+-решениях (EU AI Act Art.14) | PRESENT¹ | SRC-07 §Guardrails, SRC-09 §ADR-128 |
| `docs/audit/hitl-decisions-*.md` | Журнал HITL-решений (append-only) | PRESENT¹ | SRC-07 §Audit trail |
| ADR-136 (agentmemory) | Shared agent memory substrate; external ref: github.com/rohitg00/agentmemory | PRESENT² | SRC-INTAKE-REGISTER §ADR cross-refs, SRC-02 §Vector Memory |

¹ Подтверждено shell-аудитом A-004 (origin/main @ 267172e).
² ADR-136 referenced — external library NOT imported; подтверждён через grep ADR-списка.

**Вывод [ВЫВОД]:** Движок как «coordination layer» — НЕ greenfield. Intent-first canon
(ADR-045 → INTENT-FIRST-CANON), planner.yaml, A4-proposal, HITL-gates образуют
существующий каркас. Досье расширяет его теоретической базой и runtime-картой, не заменяет.

---

## 2. OSS Candidates — Prior Art (уже оценивались)

Следующие OSS-кандидаты **уже оценивались** в ранних сессиях. Досье ссылается на
эти оценки как на PRIOR-ART; повторное исследование не требуется.

| Инструмент | Где оценивался | Контекст оценки | Метка |
|-----------|----------------|-----------------|-------|
| **LangGraph** | `docs/sessions/SNAPSHOT-2026-05-06-sber-oss-emi-block.md` | SAR Workflow, KYC orchestration (LangGraph + Qdrant комбинация) | PRIOR-ART |
| **Qdrant** | То же + SRC-02 §Vector Memory | Векторная память агентов; в SNAPSHOT оценивался в паре с LangGraph | PRIOR-ART / PLANNED |
| **Mem0** | То же (SNAPSHOT-2026-05-06) | Persistent agent memory, сравнение с agentmemory (ADR-136) | PRIOR-ART |
| **GigaAgent** | То же (SNAPSHOT-2026-05-06) | Оценивался в OSS-блоке; юрисдикционный риск (RU-origin) — BLOCKED (I-02) | PRIOR-ART / BLOCKED |
| **Temporal** | `docs/financial-analytics-research.md` | MIT, saga-паттерн, exactly-once, Phase 1 backlog; workflow orchestration | PRIOR-ART |

**GigaAgent**: [ФАКТ] оценён в SNAPSHOT; [ВЫВОД] заблокирован invariant I-02 (RU-jurisdiction).
Не рассматривать в дальнейших sprint'ах без пересмотра I-02.

**Temporal**: [ФАКТ] упомянут в financial-analytics-research.md как Phase 1 backlog.
[ВЫВОД] runtime-saga-оркестрация → граница runtime (см. §3 ниже); досье фиксирует
Temporal как PRIOR-ART + оценивает в рамках runtime-boundary rule.

---

## 3. Architecture Boundary — Runtime → banxe-ai-infrastructure

**[ФАКТ]** ADR-060 §6 и ADR-133 устанавливают границу: runtime-оркестрация
(Temporal/saga, Redis-lease, etcd/Consul distributed lock) находится **вне scope**
`banxe-architecture` и принадлежит репозиторию `banxe-ai-infrastructure`.

**Следствия для досье:**

- **Движок-RUNTIME** (Temporal DAG-executor, Redis-lease coordinator, evo2-worker pool) →
  spec/код адресовать в `banxe-ai-infrastructure`, НЕ здесь.
- **Движок-DESIGN** (agent patterns, HITL gates, memory schema, orchestration contracts) →
  остаётся в `banxe-architecture` (ADR, soul files, passports, this dossier).
- **Граница:** `banxe-architecture` публикует *что* агенты делают и *какие контракты*
  соблюдают; `banxe-ai-infrastructure` реализует *как* они исполняются в runtime.

**[ВЫВОД]** Спринты, вытекающие из досье:
- Sprint A (design contracts, ADR-обновления, soul-файлы) → `banxe-architecture`
- Sprint B (Temporal workflow code, Redis-lease, evo1/evo2 wiring) → `banxe-ai-infrastructure`

**Не поднимать PR в banxe-architecture** с runtime-кодом Temporal/Redis-lease.

**Cross-refs:** ADR-060 §6, ADR-133, VERIFIED-RUNTIME-SNAPSHOT.md (evo1/evo2 topology),
SRC-09 §Coordination Layer thesis.

---

## Метаданные

- **Shell-аудит источника:** A-004 dup-check @ origin/main 267172e
- **Принцип:** append-only. Этот файл НЕ заменяет и НЕ дублирует перечисленные артефакты.
- **Обновление:** при поступлении SRC-03/04/05/08 проверить этот файл на новые дубли.
