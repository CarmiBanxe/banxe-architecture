# SRC-04 — Framework Selection: Decision Layer
# BANXE AI Bank | Agent-Engine Dossier
# Source: Corpus Part 4 (operator-provided, 2026-06-28)
# Created: 2026-06-28 | IL-agent-factory-agenteng06-src04-framework-selection

> Данный файл = решение по выбору фреймворков (decision layer).
> НЕ дублирует SRC-01 §landscape + §BANXE-STATUS — cross-ref там для deployment-статусов.
> Маркер: [ФАКТ из корпуса Часть 4].

---

## Star-count note (важно для воспроизводимости)

> [ФАКТ из корпуса Часть 4] Star-counts в данном файле = срез **июнь 2026**.
> SRC-01 содержит star-counts из Части 1 корпуса (другой срез: AutoGPT 170k и т.д.).
> Расхождения между SRC-01 и SRC-04 star-counts = **разные срезы корпуса**, не конфликт.
> При обновлении: датировать + указывать источник каждого среза.

---

## §1 — Recommendation Table (Corpus Part 4, June 2026)

> Cross-ref: deployment BANXE-STATUS → `SRC-01-engine-landscape.md` §BANXE-STATUS.
> Эта таблица = роль + финтех-готовность + рекомендация (не дублирует deployment-статус).

| Framework | Stars (June 2026) | Fintech readiness | BANXE stack fit | Recommended role |
|-----------|------------------|--------------------|-----------------|-----------------|
| LangGraph | 12k+ | Высокая | Частично (LangChain) | Task Planner / Intent Dispatcher (see §4.1) |
| CrewAI | 35k+ | Средняя | Нет (standalone) | 4-Partner Swarm (role-based) |
| AutoGen | 40k+ | Высокая | Нет | Compliance Swarm (multi-agent conversation) |
| MetaGPT | 50k+ | Средняя | — | Фабрика кода (code generation) |
| OpenManus | 40k+ | Средняя | Нет | UI-автоматизация (browser/app agent) |
| OWL / CAMEL | 8k+ | Высокая (GAIA SOTA) | MetaClaw | Intent reasoning (GAIA-level tasks) |
| Temporal | 12k+ | Очень высокая (saga) | Уже установлен | Long transactions / CASS 15 resume (see §4.1) |
| AgentScope | 7k+ | Средняя | Частично | evo1/evo2 distributed deployment |
| Haystack | 18k+ | Высокая (RAG + agents) | Нет | Compliance RAG (KB retrieval + agent hybrid) |
| TaskWeaver | 5k+ | Средняя | Нет | Analytics agent (data + code interpreter) |

> [ФАКТ] Fintech-readiness = наличие transactional guarantees, audit-trail, access-control, compliance hooks.
> "Очень высокая" для Temporal: native saga + at-least-once + durable timers = regulatory grade.
> "GAIA SOTA" для OWL/CAMEL: top-1 GAIA benchmark score (verified SRC-01 §GAIA cross-ref).

---

## §4.1 — LangGraph + Temporal Combo Architecture

> [ФАКТ из корпуса Часть 4 §4.1] Разные уровни абстракции — НЕ дублирование функции.

### Архитектурное разделение

```
┌─────────────────────────────────────────────────────────────────┐
│              LangGraph — PLANNING / ROUTING LAYER               │
│  Repo: banxe-architecture / banxe-emi-stack                     │
│  • Граф зависимостей агентов (directed acyclic + conditional)   │
│  • Условная логика: if risk > threshold → HITL gate (I-27)      │
│  • Параллельные независимые проверки (AML ‖ Sanctions ‖ KYC)   │
│  • Кандидат: target-audit #842 GAP "Intent Dispatcher"          │
└────────────────────┬────────────────────────────────────────────┘
                     │ dispatches tasks
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│              Temporal — RELIABLE EXECUTION LAYER                │
│  Repo: banxe-ai-infrastructure (ADR-060 §6, Sprint B)           │
│  • Crash-resume с checkpoint: незавершённые ops завершаются     │
│  • At-least-once delivery (saga pattern)                        │
│  • Durable timers: FCA CASS 15 — незавершённые safeguarding     │
│    операции ДОЛЖНЫ завершаться (regulatory requirement)         │
│  • Уже установлен (SRC-01 §BANXE-STATUS: Temporal NOT_STARTED   │
│    code-wise, infra PRESENT)                                    │
└─────────────────────────────────────────────────────────────────┘
```

### LangGraph — роль в BANXE

**Функция:** Оркестрация-граф (planning/routing).

**Ключевые паттерны (из корпуса §4.1):**
1. **Граф зависимостей агентов** — задачи как узлы, зависимости как рёбра (directed).
2. **Условная логика** — `if risk_score > threshold → HITL_node` else `execution_node`.
3. **Параллельные ветки** — независимые compliance-checks выполняются параллельно (fan-out), результаты объединяются (fan-in) перед следующим шагом.

**Целевая роль — Intent Dispatcher (GAP #842):**
> LangGraph = сильный кандидат на закрытие GAP "Intent Dispatcher not deployed" (target-audit #842). Текущее состояние: ADR-049 = спецификация L1→L2 routing (НЕ ЗАДЕПЛОЕН). LangGraph даёт граф-представление этого routing.
>
> Статус деплоя LangGraph: **DEPLOYED** (SRC-01 §BANXE-STATUS — cross-ref; не дублируем здесь).

**Repo:** `banxe-architecture` (structural patterns) + `banxe-emi-stack` (services integration). Не ограничен ADR-060§6.

### Temporal — роль в BANXE

**Функция:** Надёжное выполнение долгих транзакций.

**Ключевые свойства (из корпуса §4.1):**
1. **Crash-resume**: при падении ноды Workflow продолжается с checkpoint — незавершённая операция не теряется.
2. **At-least-once**: каждый activity выполняется минимум один раз (с идемпотентностью на уровне Activity).
3. **Durable timers**: ожидание события (approval, API response) без блокировки потока.

**Regulatory basis — FCA CASS 15:**
> [ФАКТ] CASS 15 требует: незавершённые safeguarding операции должны завершаться (no silent loss). Temporal crash-resume = техническая реализация этого требования.
>
> Cross-ref: `ADR-SAF-01` (safeguarding ADR), `J-ENGINE-BUILD-SPEC` (engine build spec), `IL-SAF-01` (safeguarding IL entry).
>
> Пример: daily reconciliation cron (CASS 15) → Temporal Workflow с checkpoint → при crash следующий запуск продолжает с последнего сохранённого состояния.

**Repo:** `banxe-ai-infrastructure` (ADR-060 §6, Sprint B).
> [ADR-060§6] Temporal Saga execution = infrastructure-layer concern → принадлежит `banxe-ai-infrastructure`, НЕ `banxe-architecture`. Deployment через Sprint B инфра-работы.

**Текущий статус:** Temporal infra PRESENT (установлен), code integration NOT_STARTED. Точный статус → `SRC-01-engine-landscape.md` §BANXE-STATUS (cross-ref, не дублируем).

### Combo: уровни абстракции (не дублирование)

| Dimension | LangGraph | Temporal |
|-----------|-----------|---------|
| Абстракция | Planning / routing (WHAT and in WHAT ORDER) | Execution reliability (GUARANTEE it runs to completion) |
| Состояние | Graph node state (current step, branch taken) | Workflow history (event sourcing, checkpoint) |
| Отказ | Conditional branching on error | Automatic retry + resume from checkpoint |
| Время | Synchronous orchestration step | Durable async (hours/days timers) |
| Repo | architecture / emi-stack | banxe-ai-infrastructure (ADR-060§6) |

> Оба необходимы: LangGraph без Temporal = граф без гарантий. Temporal без LangGraph = надёжность без умной маршрутизации.

---

## §4.2 — Cross-references

| Reference | Relevance |
|-----------|-----------|
| `SRC-01-engine-landscape.md` §BANXE-STATUS | Deployment status всех 10 frameworks (LangGraph DEPLOYED, Temporal NOT_STARTED/infra) — первичный источник |
| Target-audit #842 GAP "Intent Dispatcher" | LangGraph = кандидат на закрытие; ADR-049 = спецификация (NOT DEPLOYED) |
| ADR-060 §6 | Temporal = banxe-ai-infrastructure scope (repo boundary) |
| ADR-SAF-01 | Safeguarding architecture decision (CASS 15 basis для Temporal) |
| J-ENGINE-BUILD-SPEC | Engine build spec (Temporal crash-resume requirement) |
| IL-SAF-01 | Safeguarding IL entry (implementation tracking) |
| SRC-02-theory-principles.md §SWIFT-DAG | 8-subtask DAG = LangGraph-candidate workflow graph |
| SRC-09-preaudit-synthesis.md §Behavioral canon | ADR-025 decision-policy + ADR-049 NOT DEPLOYED (related gaps) |

---

## §4.3 — Open questions / known gaps

| Gap | Description | Owner | Status |
|-----|-------------|-------|--------|
| Intent Dispatcher deployment | LangGraph wired as ADR-049 L1→L2 router | Arch | OPEN (#842) |
| Temporal code integration | Infra PRESENT, workflow code NOT_STARTED | CTIO | Sprint B |
| Haystack RAG integration | Compliance RAG (KB retrieval) — no passport/agent yet | Arch | PLANNED |
| TaskWeaver analytics | Analytics agent — no passport/agent yet | Arch | PLANNED |
