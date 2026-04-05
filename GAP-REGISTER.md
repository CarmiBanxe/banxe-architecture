# GAP-REGISTER.md — Реестр архитектурных пробелов BANXE

**Версия аудита:** v3 (2026-04-05)
**Следующий пересмотр:** 2026-07-01 (до EU AI Act дедлайна 2026-08-02)
**Всего пробелов:** 22 (P1: 7, P2: 11, P3: 4)

Каждый gap отслеживается: приоритет, принцип, описание, статус, sprint.

---

## P1 — Критические (регуляторный и security риск)

| ID   | Пробел                                                        | Принцип                  | Дедлайн    | Статус  |
|------|---------------------------------------------------------------|--------------------------|------------|---------|
| G-01 | Нет immutable audit trail / Decision Event Log                | CQRS+ES, DORA 14(2)      | —          | OPEN    |
| G-02 | Нет XAI / ExplanationBundle в BanxeAMLResult                  | XAI, FCA SS1/23          | —          | OPEN    |
| G-03 | HITL не формализован по EU AI Act Art.14                      | EU AI Act Art.14         | 2026-08-02 | PAUSED  |
| G-04 | Нет trust boundaries между агентами (Orchestration Tree)      | Multi-agent security     | —          | OPEN    |
| G-05 | feedback_loop.py может менять SOUL.md без governance gate     | Self-rewriting risk      | —          | PARTIAL |
| G-16 | Нет формализованных Ports & Adapters для агентов              | Hexagonal Architecture   | —          | OPEN    |
| G-17 | Нет Event Sourcing для решений агентов (domain events)        | Event Sourcing / CQRS    | —          | OPEN    |

**G-03 примечание:** `emergency_stop.py` + `api.py` созданы (d5c1007), syntax OK.
Остаётся: integration tests + Marble UI кнопка + production deploy. PAUSED, PRIORITY #1.

**G-05 примечание:** `governance/change-classes.yaml` создан (3886ac0) — CLASS_B_SOUL_AGENTS
`can_apply: NEVER` задекларирован. Технического enforcement (CI check) нет — Sprint 3.

---

## P2 — Существенные (compliance провал при масштабировании)

| ID   | Пробел                                                        | Принцип              | Статус   |
|------|---------------------------------------------------------------|----------------------|----------|
| G-06 | Нет Bounded Context Map в коде                                | DDD                  | OPEN     |
| G-07 | Compliance thresholds захардкожены в Python                   | 12-Factor Factor III | OPEN     |
| G-08 | Нет drift detection для policy-файлов                         | GitOps               | OPEN     |
| G-09 | Pre-tx gate без Redis hot-path (<80ms p99)                    | Latency / DIP        | DEFERRED |
| G-10 | Нет Zero Standing Privileges для агентов                      | ZSP / JIT secrets    | OPEN     |
| G-11 | Партнёрский доступ не разграничен (Zone RED/AMBER)            | Trust zones          | OPEN     |
| G-12 | Нет формального agent passport                                | KPMG AIGF            | PARTIAL  |
| G-18 | DDD: плоская структура модулей, нет 5 bounded contexts        | DDD                  | OPEN     |
| G-19 | Нет controls-as-code (OPA/Rego) — только bash-скрипт         | FINOS AIGF v2.0      | OPEN     |
| G-20 | 12-Factor: нет release pipeline + structured logging          | 12-Factor            | OPEN     |
| G-21 | Нет зонирования AI-генерации в Claude Code hooks              | Vibe-coding governance | OPEN   |

**G-09 примечание:** DEFERRED — EMI-масштаб BANXE пока не требует. Пересмотреть при
transaction volume > 10K/day.
**G-12 примечание:** SOUL.md + ADR частично закрывают. Не хватает `agent_id`, `version`,
`capabilities[]` как structured metadata.
**G-18 vs G-06:** G-06 = отсутствие документа; G-18 = отсутствие структуры в коде (разные gaps).

---

## P3 — Улучшения зрелости

| ID   | Пробел                                                        | Принцип              | Статус |
|------|---------------------------------------------------------------|----------------------|--------|
| G-13 | Нет compliance bundle для аудиторов                           | Compliance-as-Code   | OPEN   |
| G-14 | Нет OPA/Rego runtime enforcement (пилот)                      | FINOS AIGF           | OPEN   |
| G-15 | Нет multi-agent review pattern в feedback pipeline            | Plan→Build→Review    | OPEN   |
| G-22 | FINOS AIGF v2.0 risk catalogue не замаплен на GAP-REGISTER    | FINOS alignment      | PARTIAL|

**G-22 примечание:** PARTIAL — таблица маппинга создана в SPRINT-0-PLAN.md.
G-14 и G-19 связаны: G-19 = реализация, G-14 = пилот runtime enforcement.

---

## Спринт-план

### Sprint 0 (архитектурный) — НОВЫЙ (добавлен аудит v3)
- [ ] G-16: Формализовать Port-интерфейсы — PolicyPort, DecisionPort, AuditPort, EmergencyPort
- [ ] G-18: Задокументировать 5 bounded contexts — Compliance, Decision Engine, Policy, Audit, Operations
- [ ] G-21: Настроить 4 обязательных Claude Code hooks (policy-guard, invariant-check, bounded-context-check, load-architecture)
- [ ] G-22: Замапить AIGF v2.0 risk catalogue → GAP-REGISTER (см. SPRINT-0-PLAN.md)

### Sprint 1 (модифицированный)
- [x] G-05: `governance/change-classes.yaml` создан (3886ac0)
- [x] I-21..I-25: Новые инварианты добавлены в INVARIANTS.md (3886ac0)
- [ ] G-03: Завершить (тесты + Marble UI + deploy) — emergency_stop.py уже есть, PRIORITY #1
- [ ] G-16: Emergency stop → реализовать как EmergencyPort adapter
- [ ] G-17: Базовый event store (append-only) для решений агентов

### Sprint 2 (2–4 недели)
- [ ] G-02: `ExplanationBundle` dataclass → DecisionPort output
- [ ] G-01: Decision Event Log (append-only ClickHouse/PostgreSQL)
- [ ] G-07: `compliance_config.yaml` — externalize пороги из compliance_validator.py
- [ ] G-18: Миграция на 5 bounded contexts (директорная структура)

### Sprint 3 (4–8 недель)
- [ ] G-11: Zone RED/AMBER/GREEN в CONTRIBUTING.md + branch protection
- [ ] G-08: Policy checksum verification в CI
- [ ] G-15: Review agent step в feedback_loop.py
- [ ] G-19: OPA/Rego pilot — 3 критических правила (I-21, I-22, I-23)
- [ ] G-20: Structured logging (correlation ID: tx_id + case_id + scenario_id)
- [ ] G-05: CI enforcement для change-classes (технический gate)

### Sprint 4 (8–16 недель)
- [ ] G-09: Redis hot-path pre-tx gate
- [ ] G-10: Vault-based JIT agent credential scoping
- [ ] G-14: OPA sidecar полная реализация
- [ ] G-13: `compliance_snapshot.py`
- [ ] G-20: Release pipeline (immutable releases)

---

## FINOS AIGF v2.0 → GAP маппинг

| AIGF Risk                     | GAP    | Контроль                              | Статус   |
|-------------------------------|--------|---------------------------------------|----------|
| Agent autonomy creep          | G-05   | CLASS_B_SOUL_AGENTS (change-classes)  | PARTIAL  |
| Uncontrolled agent actions    | G-03   | Emergency stop endpoint               | PAUSED   |
| Audit trail integrity         | G-01   | I-24 декларирован, Event Sourcing нет | OPEN     |
| Explainability gap            | G-02   | I-25 (>£10K) — задекларирован         | OPEN     |
| Model drift / feedback loops  | G-05   | I-21: feedback_loop не патчит SOUL.md | PARTIAL  |
| Trust boundary violation      | G-04   | Orchestration Tree — не реализован   | OPEN     |
| Policy drift                  | G-08   | Checksum CI — не реализован           | OPEN     |

---

## Что реализовано лучше стандарта

| Преимущество                               | Почему это важно                                                  |
|--------------------------------------------|-------------------------------------------------------------------|
| feedback_loop.py + REFUTED corpus          | Monzo строил 4+ года. BANXE имеет с фундамента.                  |
| SOUL.md + AGENTS.md в Git (версионированы) | KPMG называет это «agent passport». Редкость у нео-банков.        |
| ADR-007..011 + CI schema gate              | FCA supervisory reviews требуют именно такую документацию.        |
| Policy provenance chain до ClickHouse      | policy_scope в audit_trail — прямое доказательство FCA MLR 2017  |
| scenario_registry.yaml I-1..I-10           | Machine-verifiable invariants — редкость на этом этапе.          |
| change-classes.yaml CLASS_B governance     | Closes FINOS AIGF "agent autonomy creep" risk — задекларировано.  |
