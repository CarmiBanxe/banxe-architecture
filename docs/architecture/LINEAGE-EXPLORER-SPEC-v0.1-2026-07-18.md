# Lineage Explorer — spec v0.1 (internal SMF/compliance tool)

**Status:** **DRAFT / NOT FOR MERGE** · **Date:** 2026-07-18 · **Track:** [ARCH-OM-2026-07-18]
**Producer:** factory sandbox terminal · Ветка: `agent/factory/bank-operating-model/20260718`
**Схема-источник (reuse, ничего нового не вводится):** ADR-046 `AgentDecisionRecord` (ACCEPTED) + additive-поля §D5, уже реализованные в `banxe-emi-stack/services/agents/_lineage.py` [FACT-REPO]; хранилище `banxe.decision_records` (ClickHouse migration 006); BREACH-записи от `services/runtime_gate/budget_halt.py` (S-A2 C-2, ветка costgov).

## 1. Purpose

Внутренний **read-only** инструмент для SMF/комплаенса (MLRO, CFO, CTIO, Compliance Officer): просмотр и выборка decision-lineage записей — «какой агент, по какому intent, по каким политикам, с какой уверенностью решил, кто из людей ревьюил, сколько это стоило и где сработал budget-halt». Закрывает evidence-петлю PS25/12 / SM&CR: monthly SMF review (условие L4 в Autonomy Ladder, ADR-172 draft) получает готовые выборки вместо ручных SQL. Не клиентский продукт; не пишет данные (I-24 append-only, только SELECT).

## 2. Data source & fields (все существующие)

Единственный источник: `banxe.decision_records`. Поля v0.1 (полный набор ADR-046 + cost-lineage): `record_id`, `timestamp`, `agent_id`, `triggering_event`, `intent`, `policies_evaluated[]`, `compliance_result`, `reasoning_summary`, `confidence_score`, `action_taken`, `human_reviewed_by`, `correlation_id`, `cost_tokens`, `cost_amount`, `budget_window_ref`, `budget_breach_flag`, `escalated_to`, `immutable_storage_ref`, `input_tokens`, `output_tokens`. Новых полей и таблиц v0.1 НЕ добавляет.

R-SEC: интерфейс отображает только opaque-метаданные записи; `reasoning_summary` уже PII-minimized на стороне продюсера (ADR-046) — Explorer ничего не дообогащает.

## 3. Filters (v0.1)

`agent_id` · `intent` (substring/ref) · `correlation_id` · time range (UTC) · `compliance_result` (PASS/FAIL/ESCALATE/N/A) · `budget_breach_flag` (NONE/WARN/BREACH) · `escalated_to` · `action_taken` · confidence band (AUTO >0.90 / REVIEW 0.70–0.90 / BLOCK <0.70 — пороги из ADR-046/agents-канона) · `human_reviewed_by` (включая IS NULL).

## 4. Base queries (обязательные)

| Q | Запрос | Ключ |
|---|---|---|
| Q1 | По клиентскому намерению: все решения одного intent/цепочки | `intent` + `correlation_id` (timeline, oldest→newest) |
| Q2 | По агенту: решения агента за период | `agent_id` + time range |
| Q3 | По intent_id/correlation: полная цепочка intent→execution→audit | `correlation_id` |
| Q4 | По исходу: все FAIL/ESCALATE или конкретный `action_taken` | `compliance_result`, `action_taken` |
| Q5 | **Budget-halt view (новое поверх C-2):** все `action_taken=HALT_BUDGET_EXCEEDED` / `budget_breach_flag=BREACH` — по агенту, очереди эскалации, сумме `cost_amount` | `budget_breach_flag`, `escalated_to` |
| Q6 | HITL-долг: записи с `escalated_to` NOT NULL и `human_reviewed_by` IS NULL (ожидают человека) | pending-review контроль |

## 5. Views (v0.1 — три экрана, не больше)

1. **Decision timeline** — Q1/Q3: хронология записей одной корреляции с полями confidence/compliance/cost.
2. **Budget-halt dashboard** — Q5: BREACH-счётчики per agent (сверка с метрикой `budget_exceeded` runtime_gate), суммарный cost, распределение по `escalated_to`-очередям.
3. **SMF evidence pack** — Q2+Q4+Q6 за календарный месяц, экспорт в один файл (markdown/CSV) для monthly review (вход L4-гейта ADR-172; поставщик evidence для Audit Pack Builder OSINT-P1-6).

## 6. Non-goals v0.1

Нет записи/мутаций (I-24); нет клиентского доступа; нет новых таблиц/полей; нет XAI-визуализации (ADR-169 — отдельный трек); нет real-time стриминга (периодический запрос достаточен); UI-обвязка (web) — вне v0.1: интерфейс v0.1 = запросный слой поверх `DecisionRecorder.query()`-поверхности (InMemory) и эквивалентных SELECT к ClickHouse.

## 7. Implementation notes & followups

- v0.1 реализуем как модуль `services/lineage_explorer/` (Port/Protocol + InMemory/ClickHouse адаптеры — тот же паттерн, что recorders.py) — [code], кандидат в S-A4.1/G2 (Sprint plan: Epic «Governed Intent Layer v1», G2 «Lineage Explorer»).
- Роли/доступ: read-only, L1 auto по agent-authority; доступ SMF-ролям через существующий IAM (Keycloak) — конфиг, не код.
- Followup L-1 [code]: экспорт SMF evidence pack (view 3). Followup L-2 [op]: включение view 3 в регламент monthly review (MLRO/CTIO).

---
*DRAFT / NOT FOR MERGE. Красная линия соблюдена: governance-как-продукт, только существующая схема, read-only, Banking Engine circuit.*
