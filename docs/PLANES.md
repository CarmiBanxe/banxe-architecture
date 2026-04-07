# PLANES.md — Архитектура плоскостей Banxe AI Bank

**Version:** 1.0 | **Date:** 2026-04-07 | **Owner:** CEO + CTIO

---

## Концепция

Все репозитории и проекты экосистемы Banxe разделены на три плоскости (Planes).
Каждая плоскость имеет свой scope, правила изоляции и уровень FCA-значимости.

```
┌──────────────────────────────────────────────────────────┐
│  DEVELOPER PLANE  (infra, CI/CD, hooks, quality)         │
│  vibe-coding · banxe-architecture                        │
├──────────────────────────────────────────────────────────┤
│  PRODUCT PLANE    (FCA P0, бизнес-логика, финансы)       │
│  banxe-emi-stack                                         │
├──────────────────────────────────────────────────────────┤
│  STANDBY PLANE    (параллельные проекты, data isolation)  │
│  guiyon · ss1                                            │
└──────────────────────────────────────────────────────────┘
```

**Ключевой инвариант (I-18, I-20):**
GUIYON и SS1 полностью изолированы от Banxe — никакой shared code,
shared services или shared routing между Standby и Product/Developer planes.

---

## Developer Plane

**Назначение:** CI/CD, quality gates, hooks, agents, архитектурные документы, compliance tooling.
**Владелец:** CTIO + Claude Code
**FCA-значимость:** Indirect (tooling для FCA-compliant продукта)

### Репозитории

| Репо | Назначение | Ключевые артефакты |
|------|-----------|-------------------|
| `vibe-coding` | Compliance engine + quality infra + OpenClaw bots | `.claude/hooks/`, `.semgrep/`, `.qoder/`, `scripts/quality-gate.sh`, `src/compliance/` |
| `banxe-architecture` | IL, ADR, INVARIANTS, COMPLIANCE-MATRIX, SERVICE-MAP | `INSTRUCTION-LEDGER.md`, `INVARIANTS.md`, `COMPLIANCE-MATRIX.md`, `PLANES.md` |

### Инструменты Developer Plane

| Инструмент | Путь | Назначение |
|-----------|------|-----------|
| Claude Code hooks | `.claude/hooks/` | il_gate, policy_guard, invariant_check, bounded_context_check, load_architecture, quality_gate_hook |
| Semgrep | `.semgrep/banxe-rules.yml` | 10 правил: secrets, SQL injection, float money, PII, eval, shell injection, audit-delete, TTL |
| QualityGuard Agent | `.claude/agents/qualityguard-agent.md` | Единый агент качества всей экосистемы |
| quality-gate.sh | `scripts/quality-gate.sh` | Единый gate: semgrep + ruff + pytest + coverage + invariants |
| Ruff | — | Python linting |
| Pytest + coverage | — | Порог 75% |
| Qoder CLI | `.qoder/config.yml` | Three-Partner Synergy (Claude + Qoder + MiroFish) |
| MiroFish | auto-trigger | Юридические сценарии (GUIYON/SS1) — отдельная активация |

### Правила Developer Plane

1. Все изменения → `quality-gate.sh PASS` обязателен
2. Hooks обязательны для всех Claude Code сессий в этой плоскости
3. IL дисциплина (I-28) применяется ко всем плоскостям
4. Semgrep: 10 правил, расширять можно, удалять/ослаблять нельзя
5. Hooks: 6 hooks, добавлять можно, удалять нельзя

---

## Product Plane

**Назначение:** FCA compliance, payments, reconciliation, финансовая аналитика.
**Владелец:** CEO + FinDev Agent
**FCA-значимость:** Direct P0 — CASS 15, PS25/12, FCA deadline 7 May 2026

### Репозитории

| Репо | Назначение | Ключевые артефакты |
|------|-----------|-------------------|
| `banxe-emi-stack` | P0 CASS 15 Financial Analytics Stack | `services/recon/`, `services/payment/`, `services/reporting/`, `dbt/`, `scripts/` |

### Deployed Stack (GMKtec 192.168.0.72)

| Сервис | Порт | Назначение |
|--------|------|-----------|
| Midaz CBS | :8095 | Core Banking System (LedgerPort interface) |
| ClickHouse | :9000 | Audit trail, safeguarding_events, payment_events (TTL 5Y, I-08) |
| pgAudit 17.1 | :5432 | PostgreSQL audit |
| Frankfurter FX | :8181 | Self-hosted ECB FX rates |
| mock-ASPSP | :8888 | PSD2 sandbox (adorsys) |
| WeasyPrint | — | FIN060 PDF → FCA RegData |
| dbt Core | — | staging → safeguarding → fin060 models |

### Текущие метрики (2026-04-07)

| Метрика | Значение |
|---------|---------|
| Tests | **75/75 PASS** |
| Coverage (LucidShark) | **80%** |
| Ruff issues | **0** |
| S9-09 Safeguarding | **75%** (BreachDetector + FIN060, IL-015) |
| Payment Rails | IL-014 DONE (MockAdapter, Modulr ready) |
| Cron daily-recon | `0 7 * * 1-5` |
| Cron monthly-fin060 | `0 8 1 * *` |

### Правила Product Plane

1. **I-05:** Decimal only — `float()` в финансовом контексте → BLOCK
2. **I-06:** Нет секретов в коде → хранить в `/data/banxe/.env`
3. **I-08:** ClickHouse TTL ≥ 5Y, нельзя уменьшать
4. **I-24:** Audit trail append-only — нет UPDATE/DELETE в `safeguarding_events`, `payment_events`
5. Каждый commit = `feat(P0-FA-NN)` или `feat(IL-NNN)`
6. `quality-gate.sh PASS` обязателен перед push

---

## Standby Plane

**Назначение:** Параллельные проекты CEO с другой предметной областью. Полная data isolation от Banxe.
**Владелец:** CEO
**FCA-значимость:** None (не EMI, не финансовые продукты)

**Инвариант I-18:** Standby projects НЕ используют Banxe shared services, routing, ports или data.
**Инвариант I-20:** Контуры независимы и заменяемы — Standby Plane не влияет на Product Plane.

### Репозитории

| Репо | Назначение | Юрисдикция | Статус |
|------|-----------|-----------|--------|
| `guiyon` | Юридический AI-ассистент: суды, апелляции, уголовная защита | Франция | Standby |
| `ss1` | Следственный судья: расследование, анализ доказательств | Израиль | Standby |

---

### GUIYON — Французское уголовное право

**Предметная область:** Droit pénal français, procédure pénale, appels criminels.

**Ключевые юридические процессы:**
- `conclusions pénales` — уголовные выводы
- `mémoire ampliatif` — апелляционная записка
- `réquisitoire` — заключение прокурора
- `ordonnance de renvoi` — постановление о направлении дела в суд
- `Cour d'appel` — апелляционный суд
- `chambre correctionnelle` — уголовная палата

**MiroFish сценарии (`.qoder/context.md`):**
| Сценарий | Назначение |
|----------|-----------|
| `court-strategy.yml` | Судебная стратегия, реакция суда |
| `appeal-dynamics.yml` | Апелляционная динамика, сроки |
| `evidence-analysis.yml` | Анализ доказательств и процессуальных нарушений |
| `procedural-defense.yml` | Процессуальная защита, ходатайства |

**Изоляция от Banxe:**
- Отдельный GitHub репозиторий (уже существует)
- Нет shared code с vibe-coding/banxe-emi-stack
- Нет shared ClickHouse, Midaz или OpenClaw instance
- MiroFish активируется отдельно для GUIYON контекста

---

### SS1 — Израильское уголовное расследование

**Предметная область:** ישראל — חוק סדר הדין הפלילי, שופט חוקר.

**Ключевые юридические процессы:**
- `שופט חוקר` — следственный судья
- `בית משפט שלום/מחוזי` — мировой/окружной суд
- `כתב אישום` — обвинительное заключение
- `עיון בחומר חקירה` — доступ к материалам расследования
- `בקשה למעצר` — ходатайство о заключении под стражу

**Изоляция от Banxe:**
- Отдельный GitHub репозиторий (уже существует)
- Нет shared code или services с Banxe ecosystem
- Иврит + арабский языковой контекст — отдельный MiroFish профиль

---

## Межплоскостные правила

| Правило | Описание |
|---------|----------|
| **Plane isolation** | Никакого code sharing между Standby ↔ Product/Developer |
| **Secret separation** | Каждая плоскость имеет свой `.env` — нет общих credentials |
| **Agent routing** | QualityGuard Agent работает только в Developer + Product planes |
| **IL scope** | INSTRUCTION-LEDGER.md = только Banxe planes (Developer + Product) |
| **MiroFish activation** | Явная активация под конкретный проект — не смешивать контексты |

---

*Документ поддерживается: Claude Code (Developer Plane architect)*
*Обновлять при добавлении новых репозиториев или изменении plane assignments.*
