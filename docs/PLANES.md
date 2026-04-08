# PLANES.md — Архитектура плоскостей Banxe AI Bank

**Version:** 1.1 | **Date:** 2026-04-08 | **Owner:** CEO + CTIO

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

## Skills Distribution by Plane

Skills governance is defined in full in SKILLS-MATRIX.md and SKILLS-OPERATING-MODEL.md.
This section provides the per-plane summary.

### Developer Plane — Shared Tooling and Governance Skills

| Skill | Mode | Notes |
|-------|------|-------|
| Context Memory Sync | MANDATORY | IL continuity, session handoff |
| CI/CD Quick Setup | MANDATORY | All pipeline changes must pass quality-gate |
| Rapid Spec Builder | MANDATORY | IL entry required before implementation |
| Error Handling Standardizer | ADVISORY | Enforced by ruff in Product Plane |
| Performance Scanner | ADVISORY | No production data in Developer Plane |
| API Contract Guardian | ADVISORY | Full enforcement in Product Plane |
| Dependency Optimizer | ADVISORY | Licence audit still required |
| Smart Test Generator | ADVISORY | Outputs advisory until human-reviewed |
| Auto Refactor Pro | ADVISORY | All tests must pass after refactor |
| Clean Architecture Enforcer | MANDATORY (advisory) | Proposes semgrep rules; blocks only where rule exists |

### Product Plane — Product-Safe Execution Skills Only

Enforcement is stricter here because `banxe-emi-stack` is FCA P0.

| Skill | Mode | Notes |
|-------|------|-------|
| Context Memory Sync | MANDATORY | — |
| CI/CD Quick Setup | CONTROLLED | CEO explicit approval + QRAA for any pipeline or GMKtec change |
| Rapid Spec Builder | MANDATORY | No IL = no action (I-28) |
| Error Handling Standardizer | MANDATORY | Ruff/semgrep blocks on violation |
| Performance Scanner | MANDATORY | Payment/AML/recon path changes only |
| API Contract Guardian | MANDATORY | Any port or router change triggers contract diff |
| Dependency Optimizer | CONTROLLED | IL entry required; licence audit mandatory |
| Smart Test Generator | CONTROLLED | Human review before counting toward coverage gate |
| Auto Refactor Pro | CONTROLLED | Prohibited on compliance contours; IL required |
| Clean Architecture Enforcer | MANDATORY (blocking where rule exists) | Semgrep enforces |

### Standby Plane — Isolated Local-First, Document-Heavy

GUIYON (France, criminal law) and SS1 (Israel, investigative judge) are fully isolated from Banxe.

| Skill | Mode | Key constraint |
|-------|------|----------------|
| Context Memory Sync | ADVISORY | No Banxe IL, no Banxe memory files referenced |
| CI/CD Quick Setup | CONTROLLED | Local pipelines only; no Banxe infra connections |
| Rapid Spec Builder | ADVISORY | Spec stays in Standby repo; no Banxe IL IDs |
| Error Handling Standardizer | ADVISORY | Local conventions only |
| Performance Scanner | ADVISORY | No Banxe data |
| API Contract Guardian | ADVISORY | Local APIs only |
| Dependency Optimizer | ADVISORY | No shared packages with Banxe services |
| Smart Test Generator | ADVISORY | No Banxe fixtures |
| Auto Refactor Pro | ADVISORY | Local refactor only |
| Clean Architecture Enforcer | ADVISORY | Local architecture conventions |

**Absolute rules for Standby Plane skills (I-18, I-20):**
- No Banxe ClickHouse, Midaz, Redis, or `.env` access
- No shared MiroFish context with Banxe sessions
- No propagation of Standby output to Developer or Product planes
- No Banxe IL entries for Standby-only work

---

## Skills Orchestration by Plane

Full orchestration detail is in **SKILLS-ORCHESTRATION.md**. This section provides the per-plane summary.

### Developer Plane — Allowed Orchestrations

All 10 scenarios (A–J) are allowed. Enforcement is **advisory** for most scenarios; **mandatory** for CI/CD and IL registration (I-28).

| Scenario | Mode in Developer Plane |
|----------|------------------------|
| A. New feature / IL | MANDATORY — IL entry required (I-28) |
| B. Product code modification | N/A — code changes here are tooling, not FCA P0 |
| C. Safe refactor | ADVISORY — quality-gate.sh must pass |
| D. Performance-sensitive | ADVISORY — no production data |
| E. API / integration work | ADVISORY — full enforcement when code ships to Product Plane |
| F. Error model hardening | ADVISORY |
| G. Dependency cleanup | ADVISORY — licence audit still required |
| H. Test coverage expansion | ADVISORY |
| I. Cross-repo governance | MANDATORY — IL + consistency validation |
| J. Standby workflows | Not applicable — Standby is isolated |

### Product Plane — Mandatory Orchestrations

Enforcement is **stricter** here because `banxe-emi-stack` is FCA P0. `quality-gate.sh` is the final blocker for all scenarios.

| Scenario | Mode in Product Plane |
|----------|----------------------|
| A. New feature / IL | MANDATORY — Rapid Spec Builder + IL before any implementation |
| B. Product code modification | MANDATORY — full sequence B required |
| C. Safe refactor | CONTROLLED — MUST NOT touch compliance contours |
| D. Performance-sensitive | MANDATORY — Performance Scanner before any performance claim |
| E. API / integration work | MANDATORY — API Contract Guardian MUST run; QRAA for breaking changes |
| F. Error model hardening | MANDATORY — ruff/semgrep block on bare-except |
| G. Dependency cleanup | CONTROLLED — IL entry + licence audit mandatory |
| H. Test coverage expansion | MANDATORY — 75% coverage gate enforced |
| I. Cross-repo governance | MANDATORY |
| J. Standby workflows | PROHIBITED — Product Plane code MUST NOT be used in Standby context |

### Standby Plane — Local-First and Isolated

Only Scenario J applies. All other scenarios are local advisory.

| Rule | Detail |
|------|--------|
| Context Memory Sync | MUST — local Standby context only; no Banxe IL IDs referenced |
| Rapid Spec Builder | SHOULD — spec stays in Standby repo |
| No Product Plane scenarios | Scenarios A–I must not cross into Standby plane |
| No Banxe data | No ClickHouse, Midaz, Redis, or `.env` from Banxe |
| No shared MiroFish context | Separate activation per project |
| Output isolation | Standby outputs MUST NOT propagate to Developer or Product planes |

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
