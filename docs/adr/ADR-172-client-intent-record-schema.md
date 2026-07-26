# ADR-172: ClientIntentRecord Schema v1.0 (consent-at-delegation, revocation)

**Status:** Proposed (DRAFT / NOT FOR MERGE — операторский HITL; закрывает часть OD-R21)
**Date:** 2026-07-18
**Numbering note:** номер 171 выделен локально как следующий свободный после ADR-170; при merge Central подтверждает отсутствие коллизий с параллельными ветками.
**Source discipline:** схема — [PLAN-CONCEPT] из intent-layer-launch корпуса (`/home/mmber/MetaClaw/docs/sources/`, вне репо); данный ADR переводит её в канон.

## Context

Intent Layer (ADR-045/049) определяет вход банка, но не формализует **мандат клиента**: что именно клиент делегировал агенту, с какими лимитами, как согласие получено и как отзывается. Без этого L2 Supervised запуск (launch slice, roadmap v2 §9) не имеет юридически объяснимой основы делегирования (PSR 2017, Consumer Duty, EU AI Act Art.14).

## Decision

Ввести `ClientIntentRecord` как обязательную запись при любом делегировании:

- Поля: `intent_id`, `client_id`, `intent_type`, `natural_language`, `parsed_params`, `consent_timestamp`, `consent_method`, `scope_limits {max_amount, recipients, window}`, `revocation_method`, `expires_at`, `linked_agent_id`, `linked_budget_policy_id`.
- **Consent-at-delegation:** SCA-аутентификация при создании записи (первичное делегирование), не при каждом исполнении в рамках scope_limits.
- **Revocation:** клиент отменяет запись в любой момент; отмена мгновенно блокирует связанные agent-действия; полная история — в Decision Lineage (ADR-046).
- Хранение: append-only, привязка каждого AgentDecisionRecord к `intent_id`.
- Ни одно агентское действие с деньгами клиента без активного ClientIntentRecord.

## Consequences

**Positive:** объяснимое делегирование для FCA; клиентский контроль (лимиты/отзыв) как product-feature; основа Delegation Center UI. **Negative/costs:** SCA-интеграция в flow создания intent; миграция существующего dispatcher-контракта (infra#27) на intent_id-привязку.

## Alternatives considered

(а) Согласие на каждое исполнение — отвергнуто: ломает agentic-модель, деградация до «формы с подтверждениями»; (б) неявное согласие через T&C — отвергнуто: не проходит Consumer Duty/Art.14 объяснимость.
