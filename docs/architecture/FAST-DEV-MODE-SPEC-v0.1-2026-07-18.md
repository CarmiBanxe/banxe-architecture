# FAST DEV MODE — spec v0.1 (sandbox/development profile)

**Status:** **DRAFT / NOT FOR MERGE** · **Date:** 2026-07-18 · **Track:** [ARCH-OM-2026-07-18]
**Producer:** factory sandbox terminal · Ветка: `agent/factory/bank-operating-model/20260718`
**Опоры:** ADR-047 + `governance/ai-cost-policy/` (README v1, agent-budget-policy.md §2/§5), `services/runtime_gate/` (BudgetManager, BudgetHaltGate, kill_switch — S-A2), ADR-046 (lineage), ADR-156 (sandbox-mode), ADR-172 draft (Autonomy Ladder).

## 1. Purpose

Ускорить итерации в sandbox/dev (меньше ложных halt'ов и алертного шума на заведомо игрушечных нагрузках), **не ломая Intent-First governance**. Принцип: safeguards не вырезаются — вводится явный профиль `dev_fast`, который **расширяет лимиты**, сохраняя production-семантику всех событий. Governance остаётся product feature: даже в dev каждый breach виден, записан и объясним.

## 2. Non-goals (запрещено ослаблять)

FAST DEV MODE **не может** удалять или обходить: Decision Lineage (ADR-046 §D4 — durable запись до всплытия halt), halt-on-exceed семантику (`BudgetHaltGate` → `BudgetExceededError`), HITL escalation-путь, append-only audit trail (I-24), границу Banking Engine ↔ Private Engine, fail-closed поведение при отсутствии политики (`BudgetConfigError`), autonomy-уровни Ladder (L2-supervised остаётся supervised). Любое предложение «выключить lineage в dev» = нарушение красной линии.

## 3. Что можно ослаблять в FAST DEV MODE

- **Повышенные budget caps:** множитель к `max_tokens_window`/`max_cost_window` (например ×10), config-as-data, не правка базовой таблицы.
- **Более широкие tier thresholds:** daily/monthly пороги INFO/WARN/ALERT сдвигаются вверх (HARD STOP остаётся, см. §4).
- **Permissive retry ceilings:** `retry_ceiling` +N в dev (каждый retry всё равно логируется).
- **Synthetic/mock HITL queue sink:** `InMemoryHitlQueue`/авто-ack-стаб вместо живой очереди — эскалация **записывается**, но не будит человека.
- **Relaxed alert noise:** 80%-алерты в dev идут в лог/локальный канал, не в PagerDuty/операторские каналы.

## 4. Что остаётся обязательным даже в FAST DEV MODE

- **BREACH-запись:** превышение расширенного лимита по-прежнему даёт `budget_breach_flag=BREACH` + halt.
- **Lineage event:** каждый halt/retry/escalation пишет полный `AgentDecisionRecord` (те же поля, что в prod).
- **Explicit flag:** каждый lineage-record и каждая эскалация несут `dev_fast_mode=true` (additive-поле/метка `policies_evaluated += ["dev-fast-profile/v0.1"]` до схемного решения) — dev-данные всегда отличимы от prod-данных.
- **Sandbox-only маркировка:** профиль активен только при `environment: sandbox`; в любом другом environment флаг игнорируется с ошибкой конфигурации (fail-closed).
- **Невключаемость в production:** активация в prod невозможна без отдельного operator/CTIO решения (HITL-013-класс) — конфиг-валидатор отклоняет `dev_fast` вне sandbox.
- Estate monthly HARD STOP (ai-cost-policy README §3) — действует без изменений.

## 5. Configuration surface

- **Флаг профиля:** `RUNTIME_PROFILE=dev_fast` (env) ИЛИ `profile: dev_fast` в конфиге; env имеет приоритет.
- **Config-as-data:** множители и стабы — отдельный файл `dev-fast-profile.yaml` (schema `dev-fast-profile/v1`): `budget_multiplier`, `retry_bonus`, `hitl_sink: mock|real`, `alert_route: log|ops`; никакой правки базовых политик.
- **Precedence:** base policy → dev_fast-множители (только вверх для caps, только mock для sink) → per-agent override запрещён (профиль общий, не точечный — исключает «тихую» настройку одного агента).
- **Kill switch:** существующий `runtime_gate/kill_switch.py` работает поверх профиля — HALTED глушит агента независимо от dev_fast; отдельная команда `profile revert` мгновенно возвращает base-лимиты без рестарта (config reload).

## 6. Acceptance criteria

1. Локальная разработка быстрее: типовой dev-сценарий (интеграционный прогон intent-цепочки) не упирается в base-caps и не будит людей.
2. Governance-скелет цел: все тесты runtime_gate (26) зелёные без модификаций; BREACH/lineage/halt-тесты проходят и в dev_fast (с расширенными числами).
3. Production path не изменён: при отсутствии флага поведение бит-в-бит текущее; diff prod-конфигурации = 0.

## 7. Risks / abuse cases

- **Accidental prod bleed:** флаг утёк в prod-env → митигация: environment-guard fail-closed (§4) + конфиг-валидатор в CI + запись активации профиля в audit trail.
- **Silent bypass of lineage:** соблазн замокать recorder «для скорости» → митигация: recorder не входит в configuration surface профиля (§5), тест AC-2 фиксирует обязательность записи.
- **Hidden divergence dev/prod semantics:** dev-поведение расходится с prod и баги governance всплывают только в prod → митигация: профиль меняет ТОЛЬКО числа и sink'и, не код-пути; один и тот же `BudgetHaltGate` исполняется в обоих режимах; периодический прогон тест-сьюта с base-лимитами в CI.

## 8. Minimal rollout

Шаг 1 (этот артефакт): spec — ратификация оператором/CTIO. Шаг 2 (отдельный артефакт, [code]): `dev-fast-profile.yaml` + environment-guard + профильная загрузка в runtime_gate + тесты AC-1..AC-3. Шаг 3 ([op]): включение в sandbox-контуре, запись активации в IL. Никакой код в этом шаге не создаётся.

---
*DRAFT / NOT FOR MERGE. Красная линия: Intent-First, governed autonomy only, governance = product feature; ослабляются числа — не принципы.*
