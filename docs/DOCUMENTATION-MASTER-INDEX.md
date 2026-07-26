# DOCUMENTATION MASTER INDEX — banxe-architecture

> ⚠ SANDBOX / TRAINING context (BANXE_ENV=sandbox). Navigation only — this index moves NOTHING.
> STEP8, ENGREF01, 2026-07-26. Counts measured at origin/main cc40eb3 (~1881 .md total).
> Companion: `DOCUMENTATION-AUDIT-2026-07-26.md` (findings + PROPOSED cleanup recommendations).

## 1. ADR — ТРИ серии (НЕ дубли, НЕ объединять)

| Серия | Путь | Объём | Назначение | Правило |
|---|---|---|---|---|
| **Числовая (канон)** | `docs/adr/` | 123 | Текущий канон ADR-1xx (ADR-102…ADR-174+); индексы: `docs/adr/INDEX.md` + `docs/adr/README.md` | **Новые ADR создаются ТОЛЬКО здесь** (номер = max+1, Rule 8 ADR-119) |
| **Историческая** | `decisions/` | 41 | Старая серия ADR-001…041; **73 файла ссылаются на эти пути** | Пути НЕ трогать (замороженная история; перенос сломает 73 ссылки) |
| **Доменная** | `adrs/` | 14 | Доменные ADR-CBS/CST/FIN/FOS/FRAUD/GOV-* (по bounded-context) | Дополняется по доменному ключу; не пересекается с числовой |

## 2. Canon — ТРИ корня

| Корень | Содержимое | Статус |
|---|---|---|
| `docs/canon/` | 39 предметных канонов (AGENT-INTERACTION, SYNC, REPORTING-STYLE, FEATURE-EVALUATION, S-A-NAMESPACE, TERMINAL-B …) | Предметный слой — канонические правила по темам |
| `canon/` | CANON.md + modules/ (CORE, DECISION, DEV, DOC, **LEGAL**) | Модульный свод |
| `.canon/` | CANON.md + modules/ (CORE, DECISION, DEV, DOC — **без LEGAL**) | Скрытая копия модульного свода |
| ⚠ **Рассинхрон подтверждён (2026-07-26):** `canon/CANON.md` ↔ `.canon/CANON.md` расходятся (20 diff-строк); `modules/CORE.md` расходятся (37 строк); DECISION/DEV/DOC совпадают; `LEGAL.md` есть только в `canon/`. Консолидация = отдельный PROPOSED change-set (см. аудит §3). До неё считать источником правды более полный `canon/` и сверяться с diff. | | |

## 3. docs/ подпапки (назначение + счётчик .md)

| Папка | Файлов | Назначение |
|---|---|---|
| `adr/` | 123 | числовая ADR-серия (см. §1) |
| `audit/` | 116 | аудит-отчёты (install-audits, spec-audits, GENERAL-LINE, GL-серии) |
| `governance/` | 115 | governance-артефакты (комитеты, 3LoD, quarantine, UI-UX design canon) |
| `migration/` | 80 | MIG-файлы (blockers/rescopes/covered; M2.x-цепочки) |
| `runbooks/` | 60 | операционные runbook'и (evo1, recovery, deploy) |
| `roadmap/` | 41 | roadmap/спринт-планы (S-A*, Phase-2, BANXE-E0-E6) |
| `canon/` | 39 | предметные каноны (см. §2) |
| `refactor/` | 33 | refactor/legacy-треки (kyc-provider-port CONTRACT и др.) |
| `project/` | 29 | проектные доки; содержит свой `PROJECT-DOCUMENTATION-MASTER-INDEX.md` |
| `architecture/` | 28 | BUILD-SPEC'и (A-IDV/A-KYC/D-GL/B-EMI/M-GATEWAY…), спеки слайсов |
| `sprints/` | 18 | спринт-доки + operator-index |
| `sessions/` | 18 | session-state снапшоты |
| `agent-engine-dossier/` | 14 | досье агентного движка |
| `sources/` | 13 | источники/интейки (README-индекс) |
| `paybis-dossier/` | 9 | paybis-досье |
| `specs/` | 8 | прочие спеки |
| `briefs/` | 8 | брифы (консультанты, floor-2 контекст) |
| `handoff/` | 7 | handoff-отчёты |
| `regulatory/` | 6 | регуляторные материалы |
| `safeguarding/`, `master-document/` | 4+4 | CASS-safeguarding; мастер-документ |
| `policies/`, `payments/`, `ops/`, `incidents/`, `factory/`, `engine/` | 3×6 | политики; платёжные; ops (sandbox-CH runbook — в `ops/sandbox/` корня); инциденты; фабричные; **engine-reference (ENGREF01: AI-ENGINE-REFERENCE, MATH, SECURITY-OWASP + session-report/prod-gate после #1146)** |
| `reviews/`, `privacy/`, `odr/` | 2×3 | ревью; privacy; ODR |
| — файлы прямо в `docs/` | ~12 | BANXE-UI-* (4 UI-канона), COMPLIANCE-MATRIX, BLOCKED-TASKS, financial-analytics-research, D-RECON-DESIGN, ROADMAP-STATUS и др. |

## 4. Root-level docs (27) — назначение; кандидаты на будущий перенос ПОМЕЧЕНЫ (без переноса сейчас)

**Остаются в корне (инфраструктурные/канонические):** `README.md` · `CLAUDE.md` (авто-контекст) · `MEMORY.md` (не трогать) · `CONTRIBUTING.md` · `CHANGELOG.md` · `INSTRUCTION-LEDGER.md` (ГЕНЕРИРУЕМЫЙ — править только шардами) · `INVARIANTS.md` · `GAP-REGISTER.md` · `AGENTS.md` · `ROADMAP.md` · `SANCTIONS-POLICY.md` · `OPERATOR-PLAYBOOK.md` · `PRIVILEGE-MODEL.md` · `PROMPT-CANON-DEVELOPER.md` / `PROMPT-CANON-PROJECT.md` · `banxe-subagent-context.md` (читается tooling'ом по этому пути)

**Кандидаты на перенос в docs/ (будущий change-set, git mv + правка ссылок):**
`MASTER-PLAN-2026-05-05.md` → docs/project/ · `SESSION-HANDOFF-2026-06-07.md` → docs/sessions/ · `SPRINT-0-PLAN.md` → docs/sprints/ · `PHASE1_EXECUTION_LEDGER.md` → docs/project/ · `COMPLIANCE-ARCH.md`, `COMPOSABLE-ARCH.md`, `STACK-LAYERS.md`, `SERVICE-MAP.md` → docs/architecture/ · `AGENT-ORG-STRUCTURE.md`, `SOUL-TEMPLATE.md` → docs/governance/ или agents/ · `DEFERRED-PROJECTS.md` → docs/project/

## 5. Существующие индексы (свод)

- `docs/adr/INDEX.md` + `docs/adr/README.md` — два индекса числовой ADR-серии (кандидат на слияние, см. аудит)
- `docs/project/PROJECT-DOCUMENTATION-MASTER-INDEX.md` — проектный индекс (предшественник; данный мастер-индекс — верхний уровень над ним)
- `docs/sprints/sprint-1-4-operator-index.md` — операторский индекс спринтов
- `docs/sources/README.md` — индекс источников
- `ledger/README.md` / `ledger/SHARD-WORKFLOW.md` — реестр и правило шардов

---
## 6. Организационный roadmap (STEP9)

- `docs/roadmap/BANK-ORGANIZATION-ROADMAP.md` — сквозной roadmap организации банка (35 репо, S0–S7+Z, Director-centric, Fable5-canon-on-demand) — PROPOSED
- `docs/architecture/DIRECTOR-CONTROL-PLANE.md` — спецификация «директора банка» (central control plane) — PROPOSED

*STEP8 | ENGREF01 | навигация без перемещений; рекомендации по уборке — в `DOCUMENTATION-AUDIT-2026-07-26.md` (все PROPOSED).*
