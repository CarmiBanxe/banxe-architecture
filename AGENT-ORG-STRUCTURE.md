# Оргструктура фабрики ИИ-агентов (компания-разработчик ПО)

**Создан:** 2026-06-13 | **Источники:** il188-emi/AGENTS.md, il188-emi/.ai/registries/agent-map.md, SERVICE-MAP.md
**Назначение:** функции, обученность, должности и зоны ответственности агентов фабрики и проекта EMI BANXE AI BANK.

> **Superseded in part by ADR-117 (perimeter/hardware/org); Mandate: ADR-116.** RECONCILED 2026-06-21 — см. `docs/governance/CANON-RECONCILIATION-ADR117.md`.
> Per ADR-117 (ACCEPTED 2026-06-21): Factory = Legion (64 GB, `qwen2.5-coder:14b-banxe-factory`, software-delivery only); Project = evo1/evo2 (128 GB each, operator-confirmed). **Doubled-dev (operator-confirmed):** Claude Code = Архитектор+Тимлид+Ревьюер (внешняя LLM Claude); Aider CLI ≥2× = разработчики через LiteLLM :4000; client-service/ops/it-devops → `glm-4.7-flash`. Full-cycle роли — см. раздел ниже.

---

## Уровень А — «Сотрудники фабрики» (Four-Partner Swarm)

| Партнёр | Должность в IT-компании | Функция | Обученность |
|---------|--------------------------|---------|-------------|
| Claude Code | Архитектор + Тимлид + Ревьюер | проектирование, ревью, оркестрация | внешняя LLM (Claude) |
| Ruflo | PM / оркестратор процессов | ведение многошаговых флоу | оркестратор (не модель) |
| Aider CLI (+ ADR-117: ≥2×) | Разработчики — удвоенная ёмкость (ADR-117; ранее один Aider) | пишут/правят код | через LiteLLM gateway :4000 |
| MiroFish | QA / контролёр | прогон banking/FCA/fraud-сценариев | factory-mid (исправлено 2026-06-13) |

### Full-cycle dev-company roles (ADR-117 / ADR-116) — привязка к существующим агентам

Структурные роли полного цикла (без новых людей/хостов; «planned/unassigned» = реальным агентом пока не покрыто).

| Роль (full-cycle) | Привязка (существующий агент/модель/механизм) | Статус |
|-------------------|-----------------------------------------------|--------|
| Architect / Tech-Lead / Reviewer | Claude Code (внешняя LLM Claude) | active |
| Developers (≥2×) | Aider CLI ×2 через LiteLLM :4000 | active |
| QA / Test | MiroFish + automated quality-gates | active |
| DevOps / CI | GitHub Actions guardians (guardian-factory/project/ledger), ledger-build | active (CI); infra/release DevOps — planned/unassigned |
| Security / compliance-reviewer (Controllers) | Multi-level review (pre-commit, SAST/SCA/secrets, 2-reviewer; chapter-lead для payment-core/KYC) + Auto-Verify :8094 + compliance swarm | partial; dedicated security-reviewer agent — planned/unassigned |
| Release-manager | Ruflo / Channel C (gated merge orchestration) | active (process); formal release-manager — planned/unassigned |
| Process orchestrator | Ruflo | active |

### Контроль/governance

- I-инварианты: I-05 (Decimal-only), I-08 (лог всех AML-решений), I-12 (SAR только с MLRO), I-27 (агенты только PROPOSES), I-28 (CEO STOP-check на входе оркестратора).
- Auto-Verify API :8094 — авто-контроль ответов агентов.
- HITL-гейты: SAR_filing (MLRO,24h→CEO), AML_threshold_change (MLRO,CEO,4h), sanctions_reversal (MLRO,CEO,1h), PEP_onboarding (MLRO,48h), board_report_sign_off (MLRO,BOARD,3d).
- Матрица автономии: L1 Auto → L2 Alert → L3 Propose → L4 Human-Only (SAR, разрешение расхождений, подпись FIN060).

---

## Уровень Б — 20 доменных агентов EMI («продукт»)

### Claude Code agents (2)

| Агент | Автономия | Домен | Человек-двойник |
|-------|-----------|-------|-----------------|
| ReconcAgent | L1 (alert on DISCREPANCY) | safeguarding reconciliation | MLRO |
| ReportingAgent | L1 (CFO review) | FIN060 PDF | CFO |

### Compliance Swarm (9, trust zone RED)

MLRO Agent (координатор, L2), Jube Adapter (L3), Sanctions Check (L3), AML Check (L3), Transaction Monitor (L3), CDD Review (L2), Fraud Detection (L3), Recon Analysis (L2), Breach Prediction (L2).

### MCP Server Agent (1)

Инфраструктурный страж (L2→CTIO), 15 MCP-инструментов, health каждые 6ч, метрики в ClickHouse.

### Agent Routing Layer (5)

SanctionsAgent (L1), BehaviorAgent (L2), GeoRiskAgent (L1), ProfileHistoryAgent (L2), ProductLimitsAgent (L1).

### Workflow-процессы (3)

Monthly Compliance Review, Quarterly Board Report, Daily Recon.

**Итого: 4 партнёра + 20 доменных агентов («20+4»).**

---

## Обученность (модели → роли) — SERVICE-MAP

- qwen2.5-coder:14b-banxe-factory → factory code-delivery (Legion, ADR-117)
- qwen3-banxe-v2 (~30b) → supervisor/kyc/compliance/risk/crypto (главная)
- glm-4.7-flash-abliterated → client-service/operations/it-devops
- gpt-oss-derestricted:20b → analytics/finance
- qwen3-235b-master :8082 → тяжёлое рассуждение

> **ADR-117 reconciliation:** factory model `qwen2.5-coder:14b-banxe-factory` (Legion) добавлен. PROJECT-набор (evo1/evo2) по ADR-117 дополнительно включает `qwen3:235b-a22b`, `llama3.3:70b`, `qwen3-coder-next`, `qwen3.5/30b/4b` — имена по ADR-117; точные размеры/роли/хост ожидают оператора (реестр).

## Форк EMI BANXE AI BANK

Весь рой определён в `~/wt/il188-emi/` (проект il188-emi). Память: PostgreSQL `compliance_swarm_sessions`. Аудит: ClickHouse `compliance_swarm_events` (хранение 5 лет, I-08).

## Примечание о MetaClaw

`~/MetaClaw` — инфраструктурный слой (LLM-gateway LiteLLM + память/навыки), НЕ отдельный рой доменных агентов. Содержит лишь AGENTS.md (описание окружения) и навык agent-task-handoff.
