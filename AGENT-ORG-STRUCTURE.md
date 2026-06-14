# Оргструктура фабрики ИИ-агентов (компания-разработчик ПО)

**Создан:** 2026-06-13 | **Источники:** il188-emi/AGENTS.md, il188-emi/.ai/registries/agent-map.md, SERVICE-MAP.md
**Назначение:** функции, обученность, должности и зоны ответственности агентов фабрики и проекта EMI BANXE AI BANK.

---

## Уровень А — «Сотрудники фабрики» (Four-Partner Swarm)

| Партнёр | Должность в IT-компании | Функция | Обученность |
|---------|--------------------------|---------|-------------|
| Claude Code | Архитектор + Тимлид + Ревьюер | проектирование, ревью, оркестрация | внешняя LLM (Claude) |
| Ruflo | PM / оркестратор процессов | ведение многошаговых флоу | оркестратор (не модель) |
| Aider CLI | Единственный разработчик | пишет/правит код | через LiteLLM gateway :4000 |
| MiroFish | QA / контролёр | прогон banking/FCA/fraud-сценариев | factory-mid (исправлено 2026-06-13) |

### Контроль/governance
- I-инварианты: I-05 (Decimal-only), I-08 (лог всех AML-решений), I-12 (SAR только с MLRO), I-27 (агенты только PROPOSES), I-28 (CEO STOP-check на входе оркестратора).
- Auto-Verify API :8094 — авто-контроль ответов агентов.
- HITL-гейты: SAR_filing (MLRO,24h→CEO), AML_threshold_change (MLRO,CEO,4h), sanctions_reversal (MLRO,CEO,1h), PEP_onboarding (MLRO,48h), board_report_sign_off (MLRO,BOARD,3d).
- Матрица автономии: L1 Auto → L2 Alert → L3 Propose → L4 Human-Only (SAR, разрешение расхождений, подпись FIN060).

---

## Уровень Б — 19 доменных агентов EMI («продукт»)

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

**Итого: 4 партнёра + 19 доменных агентов («19+4»).**

---

## Обученность (модели → роли) — SERVICE-MAP
- qwen3-banxe-v2 (~30b) → supervisor/kyc/compliance/risk/crypto (главная)
- glm-4.7-flash-abliterated → client-service/operations/it-devops
- gpt-oss-derestricted:20b → analytics/finance
- qwen3-235b-master :8082 → тяжёлое рассуждение

## Форк EMI BANXE AI BANK
Весь рой определён в `~/wt/il188-emi/` (проект il188-emi). Память: PostgreSQL `compliance_swarm_sessions`. Аудит: ClickHouse `compliance_swarm_events` (хранение 5 лет, I-08).

## Примечание о MetaClaw
`~/MetaClaw` — инфраструктурный слой (LLM-gateway LiteLLM + память/навыки), НЕ отдельный рой доменных агентов. Содержит лишь AGENTS.md (описание окружения) и навык agent-task-handoff.
