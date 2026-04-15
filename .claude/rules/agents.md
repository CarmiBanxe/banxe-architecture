---
paths: ["**"]
alwaysApply: true
---

# Agent Orchestration Rules — BANXE AI BANK

## КОЛЛАБОРАНТЫ (рой агентов)

| Агент | Роль | Порт | Когда вызывать |
|-------|------|------|----------------|
| Claude Code | Lead Orchestrator | — | Всегда (координация, design docs, IL) |
| Aider | Code Agent | — | Scaffold, типизация, тесты |
| Ruflo | Review Agent | — | PR review, invariants, BC boundaries |
| MiroFish | Research Agent | :3001/:5004 | API research, changelog, feature parity |

---

## SKILLS GOVERNANCE (IL-042)

### Определение

Skill — многократно используемая операционная процедура (не плагин), которую Claude Code вызывает для специфического класса задач. Полная матрица — `docs/SKILLS-MATRIX.md`. Операционная модель — `docs/SKILLS-OPERATING-MODEL.md`.

### Жёсткие правила (нарушение = STOP)

1. **Ни один skill не обходит quality-gate.sh** — gate всегда запускается после skill.
2. **Ни один skill не обходит инварианты I-01..I-28** — инварианты имеют высший приоритет.
3. **Ни один skill не пересекает границы репо неявно** — cross-repo действия только по явной инструкции CEO.
4. **Ни один skill не смешивает Banxe данные с GUIYON/SS1** — I-18, I-20 абсолютны.
5. **Ни один skill не запускается без IL-записи** если результатом является новая реализация (I-28).

### Приоритет (от высшего к низшему)

```
FCA regulations > Invariants I-01..I-28 > ADRs > quality-gate.sh > IL (I-28) > Skill MANDATORY > Skill ADVISORY
```

### Права доступа по умолчанию

| Plane | Skills | Ограничения |
|-------|--------|-------------|
| Developer | Все 10 | CI/CD MANDATORY; остальные per SKILLS-MATRIX.md |
| Product | Все, кроме Auto Refactor Pro на compliance контурах | CONTROLLED = CEO approval + IL |
| Standby | Все — только ADVISORY | Нет пересечения с Banxe данными (I-18, I-20) |

---

## SKILLS ORCHESTRATION RULES (IL-044)

Full model: `docs/SKILLS-ORCHESTRATION.md`.

### Critical distinction

> `allowed_skills` in a passport = **permission to use**.
> Orchestration rules = **obligation to run in order**.
> These are different. Orchestration rules take precedence over local agent discretion.

### Agent behavior expectations

1. Before any implementation: run **Context Memory Sync** + **Rapid Spec Builder** (if IL not yet written).
2. Before any interface/API/schema change: run **API Contract Guardian**.
3. Before any commit in Product Plane: **quality-gate.sh MUST pass**.
4. After any code change: run **Clean Architecture Enforcer** check.
5. For compliance contours (AML, payments, safeguarding, reporting): **Auto Refactor Pro MUST NOT run** as primary driver.

### Scenario → Sequence reference

| Scenario | Sequence |
|----------|---------|
| A. New feature | CMS → RSB → ACG → CAE → STG → gate |
| B. Product code | CMS → CAE → EHS → ACG → STG → gate |
| C. Safe refactor | CMS → ARP → CAE → STG → gate |
| D. Performance | CMS → PS → DO? → STG → gate |
| E. API/integration | CMS → RSB → ACG → EHS → STG → gate |
| F. Error model | CMS → EHS → CAE → STG → gate |
| G. Deps cleanup | CMS → DO → CAE → STG → gate |
| H. Test coverage | CMS → STG → gate |
| I. Governance | CMS → RSB → CAE → gate? |
| J. Standby | CMS → RSB → local → STG? |

*Abbreviations: CMS=Context Memory Sync, RSB=Rapid Spec Builder, ACG=API Contract Guardian, CAE=Clean Architecture Enforcer, EHS=Error Handling Standardizer, PS=Performance Scanner, DO=Dependency Optimizer, STG=Smart Test Generator, ARP=Auto Refactor Pro*

### quality-gate.sh is always the final enforcement layer

No skill output, no agent decision, no CEO instruction removes the obligation to pass `quality-gate.sh` before a Product Plane commit. If the gate is failing, fix the root cause — do not add skip flags.

---

## FINDEV AGENT — Роль и полномочия (IL-009)

**FinDev Agent** — специализированный AI-агент для финансово-аналитического блока Banxe AI Bank.

### Специализация:
- Deployment финансово-аналитического стека (dbt, Blnk, pgAudit, JasperReports)
- FCA CASS 15 compliance: ежедневный recon, FIN060 reports, audit trail
- Интеграция компонентов через API и event-driven паттерны
- Код: Python, SQL, YAML, Docker Compose

### Приоритетная матрица (CASS 15 deadline 7 May 2026):
```
P0 (до 7 May): pgAudit, Blnk recon, bankstatementparser, dbt, JasperReports, Frankfurter, adorsys PSD2
P1 (Q2-Q3):   Metabase/Superset, Great Expectations, Debezium/Sequin, Temporal, Kafka
P2 (Q4):      Camunda 7, OpenMetadata, Airbyte, Apache Flink
P3 (Year 2+): FinGPT, OpenBB, Apache Camel, Mojaloop, Beancount
```

### Repo: `banxe-emi-stack/` (отдельный репо — IL-009 Step 2+)

---

## Agent Checklist (MANDATORY — выполнять перед каждым коммитом)

- [ ] `banxe-subagent-context.md` передан каждому субагенту через `--context-file` (BUG-003)
