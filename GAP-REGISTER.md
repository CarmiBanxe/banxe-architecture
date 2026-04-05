# GAP-REGISTER.md — Реестр архитектурных пробелов BANXE

**Версия аудита:** v3 (2026-04-05)
**Следующий пересмотр:** 2026-07-01 (до EU AI Act дедлайна 2026-08-02)

Каждый gap отслеживается: приоритет, принцип, описание, статус, sprint.

## P1 — Критические (регуляторный и security риск)

| ID | Пробел | Принцип | Дедлайн | Статус |
|----|--------|---------|---------|--------|
| G-01 | Нет immutable audit trail / Decision Event Log | CQRS+ES, DORA 14(2) | — | OPEN |
| G-02 | Нет XAI / ExplanationBundle в BanxeAMLResult | XAI, FCA SS1/23 | — | OPEN |
| G-03 | HITL не формализован по EU AI Act Art.14 | EU AI Act Art.14 | 2026-08-02 | PAUSED |
| G-04 | Нет trust boundaries между агентами (Orchestration Tree) | Multi-agent security | — | OPEN |
| G-05 | feedback_loop.py может менять SOUL.md без governance gate | Self-rewriting risk | — | OPEN |
| G-16 | Нет формализованных Ports & Adapters для агентов | Hexagonal Architecture | — | OPEN |
| G-17 | Нет Event Sourcing для решений агентов | Event Sourcing / CQRS | — | OPEN |

**G-03 примечание:** `emergency_stop.py` + `api.py` созданы (d5c1007), syntax OK. Остаётся: integration tests + Marble UI кнопка + production deploy. PAUSED, priority #1.

**G-16 примечание:** Агентная архитектура концептуально близка к Hexagonal, но не формализована через порты. Требуется: `PolicyPort` (read-only), `DecisionPort` (output), `AuditPort` (append-only), `EmergencyPort` (stop channel). Инвариант I-22 станет архитектурным ограничением (отсутствие write-порта), а не только правилом.

**G-17 примечание:** I-24 (append-only audit trail) декларирован, но нет архитектурного паттерна Event Sourcing, гарантирующего это. Каждое решение агента = DomainEvent. CQRS: отдельные модели для записи событий и чтения состояния.

## P2 — Существенные (compliance провал при масштабировании)

| ID | Пробел | Принцип | Статус |
|----|--------|---------|--------|
| G-06 | Нет Bounded Context Map в коде | DDD | OPEN |
| G-07 | Compliance thresholds захардкожены в Python | 12-Factor Factor III | OPEN |
| G-08 | Нет drift detection для policy-файлов | GitOps | OPEN |
| G-09 | Pre-tx gate без Redis hot-path (<80ms p99) | Latency / DIP | DEFERRED |
| G-10 | Нет Zero Standing Privileges для агентов | ZSP / JIT secrets | OPEN |
| G-11 | Партнёрский доступ не разграничен (Zone RED/AMBER) | Trust zones | OPEN |
| G-12 | Нет формального agent passport | KPMG AIGF | PARTIAL |
| G-18 | Нет bounded contexts — плоская структура модулей | DDD Bounded Contexts | OPEN |
| G-19 | Нет controls-as-code (OPA/Rego) — только bash-скрипт | FINOS AIGF v2.0 | OPEN |
| G-20 | 12-Factor: отсутствует release pipeline и structured logging | 12-Factor App | OPEN |
| G-21 | Нет зонирования для AI-генерированного кода в Claude Code hooks | Vibe-coding governance | OPEN |

**G-12 примечание:** SOUL.md + ADR частично закрывают. Не хватает `agent_id`, `version`, `capabilities[]` как structured metadata.
**G-09 примечание:** DEFERRED — EMI-масштаб BANXE пока не требует. Пересмотреть при transaction volume > 10K/day.

**G-18 примечание:** 5 bounded contexts: Compliance, Decision Engine, Policy, Audit, Operations. Модули (sanctions_check, registry_loader) живут в плоской структуре без явных границ.

**G-19 примечание:** `check-compliance.sh` — зародыш controls-as-code. Нужно масштабировать до OPA/Rego engine. FINOS AIGF v2.0 рекомендует executable controls.

**G-20 примечание:** Config вне кода (change-classes.yaml) — частично. Отсутствует: immutable release pipeline, structured logging format.

**G-21 примечание:** Три зоны: RED (Policy Layer — AI-генерация запрещена), AMBER (Decision Engine — через Claude Code + review), GREEN (Infrastructure — свободная vibe-coding + hooks).

## P3 — Улучшения зрелости

| ID | Пробел | Принцип | Статус |
|----|--------|---------|--------|
| G-13 | Нет compliance bundle для аудиторов | Compliance-as-Code | OPEN |
| G-14 | Нет OPA/Rego runtime enforcement | FINOS AIGF | OPEN |
| G-15 | Нет multi-agent review pattern в feedback pipeline | Plan>Build>Review | OPEN |
| G-22 | AIGF v2.0 risk catalogue не замаплен на GAP-REGISTER | FINOS alignment | OPEN |

**G-22 примечание:** FINOS AI Governance Framework v2.0 вводит каталог рисков для agentic AI в финансах (46+ рисков). Необходимо замапить на наши gaps и добавить недостающие контроли.

## Спринт-план

### Sprint 0 (архитектурный, 0-1 неделя) — НОВЫЙ

- [ ] G-16: Формализовать Port-интерфейсы: PolicyPort, DecisionPort, AuditPort, EmergencyPort
- [ ] G-18: Реструктурировать в 5 bounded contexts (Compliance, Decision Engine, Policy, Audit, Operations)
- [ ] G-21: Настроить Claude Code hooks (policy-guard, invariant-check, bounded-context-check, load-architecture)
- [ ] G-22: Замапить AIGF v2.0 risk catalogue на GAP-REGISTER

См. подробности: `SPRINT-0-PLAN.md`

### Sprint 1 (немедленно, 1-2 недели)

- [ ] G-05: `governance/change-classes.yaml` — запрет auto-apply для Class B (SOUL.md/AGENTS.md)
- [ ] G-04: Orchestration Tree в AGENTS.md + новые инварианты I-21..I-25 в INVARIANTS.md
- [ ] G-03: Завершить G-03 (тесты + Marble UI + deploy) — `emergency_stop.py` уже есть
- [ ] G-17: Базовый event store (append-only) для решений агентов

### Sprint 2 (2-4 недели)

- [ ] G-02: `ExplanationBundle` dataclass в `risk_contract.py`
- [ ] G-01: Decision Event Log — append-only таблица в ClickHouse/PostgreSQL
- [ ] G-07: `compliance_config.yaml` — externalize пороги из compliance_validator.py
- [ ] G-19: OPA/Rego для критических инвариантов (I-21, I-22, I-23)
- [ ] G-20: Structured logging + release pipeline

### Sprint 3 (4-8 недель)

- [ ] G-11: Zone RED/AMBER/GREEN в CONTRIBUTING.md + branch protection
- [ ] G-08: Policy checksum verification в CI
- [ ] G-15: Review agent step в feedback_loop.py

### Sprint 4 (8-16 недель)

- [ ] G-09: Redis hot-path pre-tx gate
- [ ] G-10: Vault-based JIT agent credential scoping
- [ ] G-14: OPA sidecar pilot (3 критических правила)
- [ ] G-13: `compliance_snapshot.py`

## Что реализовано лучше стандарта

| Преимущество | Почему это важно |
|-------------|------------------|
| feedback_loop.py + REFUTED corpus | Monzo строил 4+ года. BANXE имеет с фундамента. |
| SOUL.md + AGENTS.md в Git (версионированы) | KPMG называет это «agent passport». Редкость у нео-банков. |
| ADR-007..011 + CI schema gate | FCA supervisory reviews требуют именно такую документацию. |
| Policy provenance chain до ClickHouse | policy_scope в audit_trail — прямое доказательство FCA MLR 2017 |
| scenario_registry.yaml I-1..I-10 | Machine-verifiable invariants — редкость на этом этапе. |
| governance/change-classes.yaml (CLASS_B) | Защита от auto-rewriting SOUL.md — опережает FINOS AIGF рекомендации. |
