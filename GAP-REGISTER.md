# GAP-REGISTER.md — Реестр архитектурных пробелов BANXE

**Версия аудита:** v2 (2026-04-05)
**Следующий пересмотр:** 2026-07-01 (до EU AI Act дедлайна 2026-08-02)

Каждый gap отслеживается: приоритет, принцип, описание, статус, sprint.

---

## P1 — Критические (регуляторный и security риск)

| ID   | Пробел                                               | Принцип              | Дедлайн     | Статус     |
|------|------------------------------------------------------|----------------------|-------------|------------|
| G-01 | Нет immutable audit trail / Decision Event Log       | CQRS+ES, DORA 14(2)  | —           | OPEN       |
| G-02 | Нет XAI / ExplanationBundle в BanxeAMLResult         | XAI, FCA SS1/23      | —           | OPEN       |
| G-03 | HITL не формализован по EU AI Act Art.14             | EU AI Act Art.14     | 2026-08-02  | PAUSED     |
| G-04 | Нет trust boundaries между агентами (Orchestration Tree) | Multi-agent security | —       | OPEN       |
| G-05 | feedback_loop.py может менять SOUL.md без governance gate | Self-rewriting risk  | —      | OPEN       |

**G-03 примечание:** `emergency_stop.py` + `api.py` созданы (d5c1007), syntax OK.
Остаётся: integration tests + Marble UI кнопка + production deploy. PAUSED, priority #1.

---

## P2 — Существенные (compliance провал при масштабировании)

| ID   | Пробел                                               | Принцип              | Статус     |
|------|------------------------------------------------------|----------------------|------------|
| G-06 | Нет Bounded Context Map в коде                       | DDD                  | OPEN       |
| G-07 | Compliance thresholds захардкожены в Python          | 12-Factor Factor III | OPEN       |
| G-08 | Нет drift detection для policy-файлов                | GitOps               | OPEN       |
| G-09 | Pre-tx gate без Redis hot-path (<80ms p99)           | Latency / DIP        | DEFERRED   |
| G-10 | Нет Zero Standing Privileges для агентов             | ZSP / JIT secrets    | OPEN       |
| G-11 | Партнёрский доступ не разграничен (Zone RED/AMBER)   | Trust zones          | OPEN       |
| G-12 | Нет формального agent passport                       | KPMG AIGF            | PARTIAL    |

**G-12 примечание:** SOUL.md + ADR частично закрывают. Не хватает `agent_id`, `version`,
`capabilities[]` как structured metadata.
**G-09 примечание:** DEFERRED — EMI-масштаб BANXE пока не требует. Пересмотреть при
transaction volume > 10K/day.

---

## P3 — Улучшения зрелости

| ID   | Пробел                                               | Принцип              | Статус     |
|------|------------------------------------------------------|----------------------|------------|
| G-13 | Нет compliance bundle для аудиторов                  | Compliance-as-Code   | OPEN       |
| G-14 | Нет OPA/Rego runtime enforcement                     | FINOS AIGF           | OPEN       |
| G-15 | Нет multi-agent review pattern в feedback pipeline   | Plan→Build→Review    | OPEN       |

---

## Спринт-план

### Sprint 1 (немедленно, 0–1 неделя)
- [ ] G-05: `governance/change-classes.yaml` — запрет auto-apply для Class B (SOUL.md/AGENTS.md)
- [ ] G-04: Orchestration Tree в AGENTS.md + новые инварианты I-21..I-25 в INVARIANTS.md
- [ ] G-03: Завершить G-03 (тесты + Marble UI + deploy) — `emergency_stop.py` уже есть

### Sprint 2 (2–4 недели)
- [ ] G-02: `ExplanationBundle` dataclass в `risk_contract.py`
- [ ] G-01: Decision Event Log — append-only таблица в ClickHouse/PostgreSQL
- [ ] G-07: `compliance_config.yaml` — externalize пороги из compliance_validator.py

### Sprint 3 (4–8 недель)
- [ ] G-11: Zone RED/AMBER/GREEN в CONTRIBUTING.md + branch protection
- [ ] G-08: Policy checksum verification в CI
- [ ] G-15: Review agent step в feedback_loop.py

### Sprint 4 (8–16 недель)
- [ ] G-09: Redis hot-path pre-tx gate
- [ ] G-10: Vault-based JIT agent credential scoping
- [ ] G-14: OPA sidecar pilot (3 критических правила)
- [ ] G-13: `compliance_snapshot.py`

---

## Что реализовано лучше стандарта

| Преимущество                               | Почему это важно                                                 |
|--------------------------------------------|------------------------------------------------------------------|
| feedback_loop.py + REFUTED corpus          | Monzo строил 4+ года. BANXE имеет с фундамента.                 |
| SOUL.md + AGENTS.md в Git (версионированы) | KPMG называет это «agent passport». Редкость у нео-банков.       |
| ADR-007..011 + CI schema gate              | FCA supervisory reviews требуют именно такую документацию.       |
| Policy provenance chain до ClickHouse      | policy_scope в audit_trail — прямое доказательство FCA MLR 2017 |
| scenario_registry.yaml I-1..I-10           | Machine-verifiable invariants — редкость на этом этапе.         |
