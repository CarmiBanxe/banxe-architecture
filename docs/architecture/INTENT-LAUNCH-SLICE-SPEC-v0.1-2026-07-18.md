# INTENT LAUNCH SLICE — spec v0.1 (первый клиентский сценарий в sandbox)

**Status:** **DRAFT / NOT FOR MERGE** · **Date:** 2026-07-18 · **Track:** [ARCH-OM-2026-07-18]
**Producer:** factory sandbox terminal · Ветка: `agent/factory/bank-operating-model/20260718`
**Reuse-опоры (не переписываются, только ссылки):** ADR-172 (ClientIntentRecord + consent/revocation), ADR-173 (Autonomy Ladder, slice = max L2), ADR-046 (`AgentDecisionRecord`), `governance/ai-cost-policy/agent-budget-policy.md` (§2 мандаты, §5 runtime C-1..C-3), `LINEAGE-EXPLORER-SPEC-v0.1` (backend-обзор решений), `FAST-DEV-MODE-SPEC-v0.1` (dev-профиль), runbook `docs/runbooks/intent-dispatcher-deployment.md` + dispatcher infra#27.

## 1. Purpose & scope

Минимальный сквозной клиентский путь **«intent → confirmation card → человек → исполнение»** для первого запуска Intent Layer в sandbox под профилем `dev_fast`. Один intent_type: **`transfer`** (FPS/SEPA sandbox, без реальных денег). Два агента из launch slice: `banxe_payments_agent` (L2 Supervised) — исполняет; `banxe_analytics_agent` (L0/L1) — вне сквозного пути v0.1, только карточка-инсайт на Home (optional). Всё остальное (crypto/cards/savings/voice/L3+) — вне scope (roadmap v2 §9).

## 2. E2E flow (8 шагов, все существующими компонентами)

| # | Шаг | Компонент (reuse) | Lineage |
|---|---|---|---|
| 1 | Клиент пишет NL-intent: «переведи 500 EUR Ивану» | chat-вход (минимальный HII, S-A10) | — |
| 2 | Parse+dispatch | Intent Dispatcher (infra#27; `INTENT_LAYER_ENABLED=true` sandbox, OD-R11) | record: intent принят |
| 3 | Создание **ClientIntentRecord** (ADR-172): scope_limits, expires, `linked_budget_policy_id` | consent: SCA-hook; в sandbox — **mock-SCA** (§4) | record: consent-at-delegation |
| 4 | **Budget-гейт**: `BudgetHaltGate.charge()` по мандату агента | S-A2 C-2; при breach → BREACH-record + HITL-sink + halt | record: cost заряжен / BREACH |
| 5 | **Compliance-минимум**: sanctions-скрин получателя | Watchman (IN-REPO); FAIL → auto-block HITL-003-семантика | record: PASS/FAIL |
| 6 | **Confirmation card** (TransferCard-минимум): сумма, получатель, комиссия, **`max_cost_per_job` из agent-budget-policy §2**, **`autonomy: L2`**, кнопка revoke | клиент видит governance как фичу (красная линия) | — |
| 7 | **Человек подтверждает** (L2: всегда; клиент = confirmer своего интента; отклонение/таймаут → intent expired) | ADR-173 L2 | record: human decision |
| 8 | Исполнение через ledger-port (sandbox Midaz) → результат в чат | существующий payment/ledger стек (F3) | record: action_taken=EXECUTE_TRANSFER |

Каждая record несёт общий `correlation_id` → полная цепочка видна в **Lineage Explorer Q3** (timeline) и Q5 (если был BREACH). SMF смотрят первый запуск не по логам, а по Explorer-выборкам.

## 3. Что клиент видит (governance = product feature)

На карточке подтверждения: `max_cost` мандата агента (ADR-172: `linked_budget_policy_id` → §2 таблица), уровень автономии (`L2 — исполняю только с вашим подтверждением`), срок действия intent (`expires_at`) и **revoke-контроль** (отзыв мгновенно гасит intent — ADR-172). Ничего из этого не «служебное»: это trust-слой первого впечатления.

## 4. Dev-профиль (FAST DEV MODE, только числа и sink'и)

Запуск v0.1 идёт под `RUNTIME_PROFILE=dev_fast` (`environment: sandbox`, fail-closed guard): расширенные caps (breach всё равно пишется), **mock-SCA** на шаге 3 (запись consent-события обязательна, реальный SCA — prod-hardening), **mock HITL-sink** для budget-эскалаций (шаг 4), тихие алерты. Код-путь шагов 2–8 идентичен prod: ужесточение = замена mock-SCA→реальный SCA, mock-sink→живая очередь, base-caps, alert-routes — **ноль переписывания флоу** (FAST-DEV-MODE-SPEC §7 митигации действуют).

## 5. Acceptance criteria

1. E2E сценарий шагов 1–8 проходит в sandbox (happy path + отклонение на шаге 7 + revoke до исполнения).
2. Каждая ветка даёт полный lineage: happy path ≥5 records одной корреляции; искусственный breach на шаге 4 даёт BREACH-record, halt и видимость в Explorer Q5.
3. Sanctions-FAIL на шаге 5 блокирует до карточки (клиент не подтверждает то, что нельзя исполнить).
4. Prod-конфигурация не изменена (diff = 0); профиль активен только в sandbox.

## 6. Non-goals v0.1

Реальные деньги/рельсы (ключи — S-A7); реальный SCA; полный HII (остальные rich-cards — UX-Rich); analytics-агент в сквозном пути; L3 автономия; многовалютные/повторяющиеся intent'ы; мобильный клиент (web sandbox portal ADR-101 достаточно).

## 7. Rollout & followups

Шаг 1 — этот spec (ратификация оператором вместе с OD-R11/OD-R21). Шаг 2 [code] — реализация: маппится на существующие спринты S-A4.2 (intent capture + флаг) и S-A10-минимум (TransferCard) + интеграционный E2E-тест по §5; отдельные артефакты, по одному. Шаг 3 [op] — первый прогон в sandbox, SMF-просмотр через Lineage Explorer, фиксация в IL. Prod-hardening — после S-A3 (живые HITL-формы) и S-A5 (полный overlay), без изменения этого флоу.

---
*DRAFT / NOT FOR MERGE. Красная линия: Intent-First вход, governed autonomy (max L2), governance как продукт; dev_fast — профиль, не снятие safeguard'ов.*
