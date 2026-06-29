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

---

## Formal Notation (Corpus Part 2)

> Источник: Corpus Part 2 (operator-provided, 2026-06-28). Маркер: [ФАКТ из корпуса].
> Статусы PRESENT/THEORY/PLANNED НЕ дублируются здесь — см. `SRC-09-preaudit-synthesis.md` §Math-Methods.
> Данный раздел: только формальная нотация принципов из теоретической базы.

### ReAct — Policy-цикл

**Цикл (из корпуса):**
```
Thought_t → Action_t → Observation_t → Thought_{t+1}
```

**Состояние:**
```
s_t = (q, a_1, o_1, …, a_{t-1}, o_{t-1})
```

**Политика:**
```
π(a_t | s_t)
```

**BANXE-привязка — banking passport = π_domain:**
Каждый banking passport в `docs/canon/passports/` реализует специализированную политику `π_domain` для своего домена:
- `planner.yaml` → π_planning
- `mlro.yaml` → π_compliance (AML/SAR decisions)
- `executor.yaml` → π_execution (payment/ledger ops)
- `kyc.yaml` (если существует) → π_kyc
- Домены: payments, KYC, FX, crypto — каждый = отдельная специализированная политика

> [ВЫВОД] 10 canon-passports в `docs/canon/passports/` = 10 специализированных π_domain. Диспетчер L1→L2 (GAP §4.1 в audit-report) = функция маршрутизации π_selector(q) → π_domain.

---

### CoT Confidence — взвешенное голосование

**Формула C(d) (из корпуса):**
```
C(d) = Σ_{i=1..n} w_i · v_i
```
где `w_i` = вес правила i, `v_i ∈ {0, 1}` = выполнено/не выполнено.

**BANXE-реализация:**
- Verify API `:8094` (PRESENT, см. `SRC-02` §CoT выше) — консенсус 2/3 голосований.
- `w_i` = веса compliance-правил (AML threshold, jurisdiction, amount limits).
- `C(d) ≥ threshold` → действие разрешено; иначе → HITL gate (I-27).

---

### MARL — многоагентный RL

**Objective J_i (из корпуса):**
```
J_i(θ_i) = E[ Σ_{t=0..T} γ^t · r_i^t ]
```
где `θ_i` = параметры политики агента i, `γ` = discount factor, `r_i^t` = reward агента i в момент t.

**MetaClaw-аппроксимация (BANXE):**
```
Δθ_i ≈ in-context skill accumulation (без GPU fine-tuning)
```
- MetaClaw (`guardian/`, ADR-019, PRESENT) = RL-аппроксимация через накопление навыков в контексте.
- `r_i^t` = implicit: успешный compliance-исход (matched recon, cleared SAR, blocked sanction).
- Истинный MARL с `J_i(θ_i)` = THEORY/PLANNED (см. SRC-09 §Math-Methods).

---

### Vector Memory — embedding и retrieval

**Embedding (из корпуса):**
```
e = f_embed(decision_context) ∈ ℝ^d
```

**Retrieval top-k:**
```
retrieval = top-k { j : cos(e_query, e_j) }
```
где `cos(·,·)` = cosine similarity между query-embedding и stored decision embedding.

**BANXE-реализация:**
- ClickHouse `:9000` (PRESENT) = structured audit store; cosine retrieval не поддерживается нативно.
- Qdrant `:6333` (PLANNED, NOT LISTENING) = vector store для `top-k` retrieval — GAP §4.3 (semantic memory).
- `f_embed` = LiteLLM-alias (factory-mid или project-reason) для генерации embeddings решений.

---

### Резюме нотаций

| Принцип | Формула | BANXE-статус |
|---------|---------|--------------|
| ReAct policy | `π(a_t \| s_t)` | passports = π_domain (PRESENT) |
| CoT confidence | `C(d) = Σ w_i·v_i` | Verify :8094 (PRESENT) |
| MARL objective | `J_i(θ_i) = E[Σ γ^t r_i^t]` | MetaClaw approx (PRESENT); full MARL = THEORY |
| Vector retrieval | `top-k cos(e_query, e_j)` | ClickHouse partial; Qdrant = PLANNED |

> Развёрнутые статусы (PRESENT/THEORY/PLANNED) и deployment-evidence: `SRC-09-preaudit-synthesis.md` §Math-Methods.

---

## SWIFT-DAG explicit mapping (Corpus §2.4)

> Источник: Corpus Part 2 §2.4 [ФАКТ из корпуса §2.4], 2026-06-28.
> HTN-иллюстрация: один международный SWIFT-перевод как DAG подзадач с явной маршрутизацией агентов.
> Cross-ref: VERIFIED-RUNTIME-SNAPSHOT.md addendum A-003 (OpenClaw + ADR-049 dispatcher).

### DAG структура

```
SUBTASK-1 ──┐
SUBTASK-2 ──┼──► SUBTASK-4 ──► SUBTASK-5 ──► SUBTASK-6* ──► SUBTASK-7 ──► SUBTASK-8
SUBTASK-3 ──┘

*SUBTASK-6 = conditional HITL gate (if risk > threshold, I-27)
```

**DAG-семантика:**
- SUBTASK-1, 2, 3 = **параллельные** (независимые compliance checks)
- SUBTASK-4 = **зависит** от SUBTASK-1 ∧ 2 ∧ 3 (все должны пройти)
- SUBTASK-5 → 6* → 7 → 8 = **последовательные**

### SWIFT-DAG subtask → agent mapping

| Subtask | Operation | Agent / Passport | Repo | Status |
|---------|-----------|-----------------|------|--------|
| **SUBTASK-1** | AML check | `aml_check` / banxe_aml_orchestrator.yaml | banxe-architecture | PRESENT |
| **SUBTASK-2** | EDD screening (T > £10k, I-04) | KYC agent | [cross-ref: A-KYC-BUILD-SPEC + IL-KYC-01; **no passport in architecture yet**] | PARTIAL (spec exists, passport absent) |
| **SUBTASK-3** | Sanctions check | `sanctions_check` passport | banxe-architecture | PRESENT |
| **SUBTASK-4** | FX rate lock | fx-engine | [**cross-repo: banxe-emi-stack** `services/providers/fx/frankfurter_client.py`; NOT in architecture] | PRESENT in emi-stack; gap in architecture |
| **SUBTASK-5** | Payment rail routing | `payment_router_agent` passport | banxe-architecture | PRESENT |
| **SUBTASK-6*** | HITL approval (if risk > threshold) | Human (MLRO / Compliance Officer) | I-27 gate; `services/hitl/hitl_service.py` (emi-stack) | PRESENT (conditional) |
| **SUBTASK-7** | Execution + ledger commit | `midaz_mcp_agent` passport | banxe-architecture | PRESENT |
| **SUBTASK-8** | Confirmation + audit | `reporting_agent` passport | banxe-architecture | PRESENT |

> **SUBTASK-2 note (KYC/EDD):** Паспорт для KYC-агента **отсутствует в banxe-architecture** (только A-KYC-BUILD-SPEC + IL-KYC-01 spec). Это known gap (spec→canon разрыв).
>
> **SUBTASK-4 note (FX):** fx-engine реализован в **banxe-emi-stack** (`services/providers/fx/frankfurter_client.py`), НЕ в banxe-architecture. Это cross-repo зависимость и architecture gap.

### Параллельность и зависимости (формально)

```
parallel { SUBTASK-1, SUBTASK-2, SUBTASK-3 }
→ await all
→ if any(FAILED) → abort + HITL escalation
→ sequential {
    SUBTASK-4 (FX rate lock),
    SUBTASK-5 (payment rail routing),
    if risk > threshold → SUBTASK-6 (HITL gate, I-27) else skip,
    SUBTASK-7 (execution + ledger commit),
    SUBTASK-8 (confirmation + audit)
  }
```

**Соответствие архитектуре:**
- Параллельный fanout {1,2,3} → compliance swarm (`agents/compliance/swarm.yaml`, PRESENT)
- HITL gate (SUBTASK-6) → `hitl_service.py` (emi-stack, PRESENT) + ADR-128 (HITL matrix)
- Ledger commit (SUBTASK-7) → Midaz `create_tx()` (emi-stack, PRESENT)
- L1→L2 orchestration routing → Intent Dispatcher ADR-049 (**NOT DEPLOYED**, GAP audit-report §4.1)

### Статус покрытия

- **PRESENT в architecture:** SUBTASK-1, 3, 5, 7, 8 passports = 5/8 ✓
- **PRESENT в emi-stack, GAP в architecture:** SUBTASK-4 (FX), SUBTASK-6 (HITL) = 2/8 partial ⚠
- **PARTIAL (spec only, no passport):** SUBTASK-2 (KYC/EDD) = 1/8 ⚠
- **Orchestrator L1→L2:** ADR-049 dispatcher = NOT DEPLOYED (GAP audit-report §4.1)

