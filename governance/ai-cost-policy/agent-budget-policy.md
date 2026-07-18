# Agent Budget Policy — per-agent financial mandates (S-A2 deliverable)

**Status:** **DRAFT / NOT FOR MERGE** — ратификация CTIO (+IL entry по правилу README §2)
**Date:** 2026-07-18 · **Track:** [ARCH-OM-2026-07-18] · Producer: factory sandbox terminal
**Source of truth (reuse, НЕ дублируется):** `governance/ai-cost-policy/README.md` v1 (ACCEPTED 2026-07-01) — tier-реестр (§1), базовая per-agent таблица tokens/call + calls/day + daily caps (§2), monthly hard caps (§3), alerting (§4). **ADR-047** (ACCEPTED) — framework: budget unit = паспорт агента (`cost_budget`-блок, P-EXT), масштабирование по `risk_ceiling`, circuit-breaker доктрина.
**Concept input [PLAN-CONCEPT]:** intent-layer-launch (Part II) — поля halt/retry/escalation/mandate и значения для клиентских агентов; ратификация схем — OD-R21 (ADR-171/172).

## 1. Relationship to existing canon

Этот документ **расширяет** README v1, не заменяя его: tier'ы, tokens/call, calls/day, daily/monthly caps и alerting наследуются оттуда без изменений. Добавляются четыре измерения, которых в v1 нет: (а) `max_cost_per_job`, (б) `retry_ceiling` + `halt_on_exceed`, (в) `escalation_path` per agent, (г) `client_mandate_required` — привязка к ClientIntentRecord (ADR-171). Enforcement-точки: LiteLLM gateway + `services/arl/cost_tracker.py` (per README §2). Конфликтов с v1 нет; при расхождении значений источник истины — README v1 до отдельного IL-решения.

Границы применения (красная линия): политика покрывает **Banking Engine circuit** (регулируемые агенты банка). Фабричные/внутренние инструменты (Experiment Copilot, Design Pipeline, KB Query, Intent Dispatcher как инфраструктура) остаются под README v1 без mandate-полей — они не исполняют клиентских финансовых намерений.

## 2. Per-agent policy table (10 агентов)

Значения tokens — [ФАКТ] из README §2 (reuse); значения `max_cost_per_job` — **PROPOSED baseline** ([PLAN-CONCEPT] для двух клиентских агентов — явные из концепта; для остальных — tier-производные: T1≈0.05 / T2≈0.25 / T3≈2.00 USD), финальные числа утверждает CTIO (IL entry). Money-значения — governance baseline, не хардкод (config-as-data, README §1).

| agent_id | Purpose | Tier | max_tokens_per_task | max_cost_per_job (USD) | retry_ceiling | halt_on_exceed | escalation_path | client_mandate_required |
|---|---|---|---|---|---|---|---|---|
| `banxe_payments_agent` *(new, launch slice L2)* | исполнение платёжных намерений клиента | T2 | 30 000 [PLAN-CONCEPT] | 0.30 [PLAN-CONCEPT] | 2 | true | human_review_queue | **TRUE** — активный ClientIntentRecord обязателен (ADR-171) |
| `banxe_analytics_agent` *(new, launch slice L0/L1)* | инсайты/аналитика для клиента, read-only | T2 | 80 000 [PLAN-CONCEPT] | 0.80 [PLAN-CONCEPT] | 2 | true | human_review_queue | false (read-only; intent_id логируется при клиентском триггере) |
| `sanctions_check_core` | санкционный скрининг (Tier-A, ADR-173) | T1 | 2 000 | 0.05 | 1 | true | mlro_queue | false (system-triggered) |
| AML Check Agent | AML-скрининг/EDD-триггеры | T2 | 4 000 | 0.25 | 3 | true | compliance_officer_queue | false |
| `tx_monitor_core` | транзакционный мониторинг | T1 | 1 500 | 0.05 | 1 | true | compliance_officer_queue | false |
| CDD Review Agent | CDD/KYC-ревью | T2 | 8 000 | 0.25 | 2 | true | compliance_officer_queue | false |
| Fraud Detection Agent (Jube adapter) | fraud-скоринг | T1 | 2 000 | 0.05 | 1 | true | fraud_analyst_queue | false |
| `banxe_aml_orchestrator` (MLRO Coordinator) | координация AML-свormа, SAR-драфты | T3 | 16 000 | 2.00 | 3 | true, **кроме SAR-path** (hard-stop exemption README §3: T2, ≤10 calls/h) | mlro_direct (HITL-001) | false (MLRO-мандат, не клиентский) |
| Reconciliation Agent | daily safeguarding recon | T2 | 6 000 | 0.25 | 2 | true | ops_queue → CFO+MLRO при shortfall (HITL-011) | false |
| Reporting Agent (FIN060) | генерация FIN060 | T2 | 12 000 | 0.25 | 2 | true | cfo_queue (HITL-010) | false |

Семантика полей: `max_tokens_per_task`/`max_cost_per_job` — жёсткий потолок одной задачи; `retry_ceiling` — максимум повторов до эскалации (не тихих ретраев); `halt_on_exceed: true` — при превышении агент останавливается (BudgetExceededError), задача уходит в `escalation_path`, продолжение — только человеком; `client_mandate_required` — без активного ClientIntentRecord агент не получает inference вовсе.

## 3. LiteLLM runtime mapping [ФАКТ, верифицировано F-01]

| Механизм (существует) | Где | Роль в этой политике |
|---|---|---|
| Global `max_budget: 500 USD / 30d` | `banxe-ai-infrastructure/deploy/config.yaml:124-127` | estate-потолок; согласован с monthly caps README §3 |
| Per-key budgets (`/key/generate`, `max_budget`/`budget_duration`) | `docs/llm/auth-and-quotas.md` §4 | носитель per-agent бюджета: **один key = один agent_id** (см. followup C-1) |
| Per-class caps (gateway-level, daily) | `auth-and-quotas.md` §5.2 | tier-уровень (T1/T2/T3 ↔ classes) |
| 80% alert semantics | `auth-and-quotas.md` §5 + observability.md | pre-limit эскалация в HITL-очередь ДО достижения cap (circuit-breaker из ADR-047/концепта) — alert-правило уже есть, донастроить маршрут в `escalation_path` |

## 4. Code follow-ups (остаток S-A2, [code])

- **C-1 agent→key linkage:** выпуск per-agent ключей (`/key/generate` с `max_budget` из таблицы §2) + прошивка agent_id→key в конфиг агентов; без этого бюджеты остаются per-class, не per-agent.
- **C-2 halt-on-exceed semantics:** обработка BudgetExceededError во всех agent-раннерах → стоп + запись в Decision Lineage (ADR-046) + постановка в `escalation_path`-очередь (не тихий retry).
- **C-3 BudgetExceeded test:** интеграционный тест: агент с искусственно низким cap → превышение → halt → эскалационная запись; exit-критерий S-A2.

---
*DRAFT / NOT FOR MERGE. Красная линия: governed autonomy only; политика — product feature (клиент видит max_cost в IntentRecord); граница Banking/Private Engine соблюдена (§1).*
