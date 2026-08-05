# banxe-architecture — Арбитр архитектурных решений

**Статус:** КАНОН  
**Владелец:** CarmiBanxe (CEO: Moriel Carmi)  
**Обновление:** 2026-04-05

---

## Назначение

Этот репозиторий — **единственный источник истины** для архитектурных решений Banxe AI Bank.

Если решение зафиксировано здесь — **ни один проект не может от него отклониться** без:
1. Создания нового ADR в `decisions/`
2. Одобрения CEO (Moriel Carmi)

## Структура

| Файл | Назначение |
|------|-----------|
| `INVARIANTS.md` | Неизменяемые правила — нельзя менять без review |
| `PRIVILEGE-MODEL.md` | Разделение: разработчик vs оператор-дублёр |
| `COMPLIANCE-ARCH.md` | AML 3-layer runtime, пороги, формулы |
| `SANCTIONS-POLICY.md` | Санкционная политика UK FCA |
| `STACK-LAYERS.md` | Слои AML стека, scoring, thresholds |
| `SOUL-TEMPLATE.md` | Эталон SOUL.md для всех агентов |
| `SERVICE-MAP.md` | Все сервисы, порты, статусы |
| `DEFERRED-PROJECTS.md` | Отложенные проекты (не делать сейчас) |
| `decisions/` | ADR — Architecture Decision Records |
| `docs/canon/FACTORY-FULL-CYCLE-COMPANY.md` | **Идентичность фабрики (ADR-177)**: компания-разработчик полного цикла — Team Topologies, Spotify model, AI DLC; фабрика проектирует и пишет код руками |
| `docs/adr/ADR-181-fable5-second-opinion-codex.md` | **Второе мнение (ADR-181)**: каждая консультация Fable-5 — параллельный Codex + согласованное резюме |
| `validators/` | Скрипты проверки соответствия |
| `docs/project/` | **Project documentation programme** — master index + S12-S25 backlog (start here for project-implementation docs) |

## Как использовать

### Проверить соответствие проекта
```bash
bash validators/check-compliance.sh ~/vibe-coding
bash validators/check-compliance.sh ~/developer
```

### Добавить новое архитектурное решение
1. Создай `decisions/ADR-NNN-название.md`
2. Заполни по шаблону (статус, контекст, решение, последствия)
3. Обнови соответствующий `.md` в корне
4. PR → одобрение CEO

### Изменить инвариант
Нельзя. Инварианты в `INVARIANTS.md` требуют совместного review с MLRO + CEO.

## Проекты, обязанные соответствовать

| Репозиторий | Статус проверки |
|-------------|----------------|
| `CarmiBanxe/vibe-coding` | primary |
| `CarmiBanxe/developer-core` | policy source |
| `CarmiBanxe/banxe-training-data` | corpus |

## Стратегия: Reference vs Dependency

Подробно: `decisions/ADR-011-reference-vs-dependency.md`

| Тип | Примеры | Подход |
|-----|---------|--------|
| **Ядро (незаменяемое)** | compliance_validator.py, feedback_loop.py, orchestrator | Собственное, не зависит от внешних лицензий |
| **Operational dependency (заменяемое)** | Marble, Watchman, Yente | Используем в production, меняем при лицензионном конфликте |
| **Reference (не зависим)** | Jube, Tazama, AMLTRIX | Учимся паттернам, не создаём dependency |

**Принцип:** собственные validators + feedback loop = ядро. Внешние компоненты = заменяемые. Open-source платформы с restrictive licenses = reference только.

---

## Consultation canon

Every governance consultation carries a **mandatory independent second opinion** — see
`docs/governance/FABLE5-CONSULTATION-ADDENDUM-R2-SECOND-OPINION.md` (ADDENDUM R2, operator
decision 2026-08-04): the brief goes to Codex in parallel, the response reproduces it verbatim
with an independence label and an explicit reconciliation of divergences, and an unreachable
reviewer is marked, never waited on.
