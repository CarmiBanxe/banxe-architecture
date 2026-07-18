# Floor-1 Banking Demo — маппинг сценария на intent_slice

**DRAFT / NOT FOR MERGE** · 2026-07-19 · sandbox-only · ветка `agent/factory/bank-operating-model/20260718`

## Выбранный сценарий floor-1 (best-decision, без вопросов)

По `docs/architecture/BANK-FOUR-FLOOR-MEMO-2026-07-18-DRAFT.md` §2: **FLOOR 1 = CLIENT / INTENT-FIRST** — клиентский вход, intent-слой, agent masks (ADR-049); операционная логика здания: «клиент входит на FLOOR 1 → намерение диспетчеризуется на FLOOR 2 → деньги двигаются на FLOOR 3 → каждый значимый шаг поднимается лифтом HITL на FLOOR 4». Выбран ЕДИНСТВЕННЫЙ канонический floor-1 сценарий этого описания: **клиентский платёжный intent — элементарный перевод**.

**Представляющий demo intent:** `"переведи 500 EUR Ивану"`, `intent_type="transfer"` — уже отыгран в `tools/sandbox/intent_slice/` (snapshot `snapshot-20260718T222645Z`, verdict `executed`).

## Как сценарий отражается в канонических слоях

| Слой | Отражение в demo | Канон |
|---|---|---|
| ClientIntentRecord | `normalizer.py` создаёт запись: intent_id, scope_limits{max_amount=500}, consent (mock-SCA, событие пишется), `revocation_method`, expires_at, linked_agent_id=`banxe_payments_agent`, linked_budget_policy_id | ADR-171 |
| Autonomy ladder | `transfer`→**L2 Supervised** (исполнение только после подтверждения человека); `insight`→L0/L1; ≥L3 → reject. Карточка показывает `autonomy_level: L2` клиенту | ADR-172 (L0–L2 slice) |
| Budget / guardrail | `gates.budget_gate`: cap из agent-budget-policy §2 (×dev_fast); превышение → BREACH-lineage + HITL-сигнал + halt до карточки. `gates.guardrail_gate`: Tier-A sanctions-стаб + I-02 юрисдикции + Decimal-инвариант | ADR-047, `governance/ai-cost-policy/agent-budget-policy.md`, `governance/runtime-guardrails-policy.md`, ADR-173 |
| Lineage | 5 записей одной корреляции: CONSENT → AUTONOMY_L2 → BUDGET_CHARGED → GUARDRAIL_CLEAR → EXECUTE_TRANSFER_SANDBOX; читается по Q3/Q5 | ADR-046, LINEAGE-EXPLORER-SPEC-v0.1 + `LINEAGE-EXPLORER-QUICKSTART-INTENT-SLICE-2026-07-19.md` |
| HITL | confirmation card → человек решает (approve/reject/revoke), решение фиксируется в queue+lineage с `human_reviewed_by`; budget-breach эскалируется в `human_review_queue` | ADR-128, ADR-172 L2 |

## Запуск demo оператором

По `docs/runbooks/INTENT-SLICE-OPERATOR-QUICKSTART-2026-07-19.md` (happy path → approve/reject/revoke → budget-halt через pytest AC-5/API → `evidence_pack`). Чтение результата — по `LINEAGE-EXPLORER-QUICKSTART-INTENT-SLICE-2026-07-19.md`.

## Чем сценарий «представляет банк» на floor-1

Это минимальная живая реализация launch slice из `BANK-MASTER-ROADMAP-…DRAFT.md` §9 («intent → confirmation card → человек», L2, FPS/SEPA-класс операции в sandbox-стабе) и спринтов S-A4/S-A10 из `BANK-SPRINT-PLAN-EXECUTION-DRAFT-2026-07-18.md`: губернанс — как product feature (клиент видит max_cost/автономию/право отзыва), каждое движение объяснимо через lineage. [ВЫВОД] Демонстрация «тончайшего этажа» здания в работающем виде — first executable floor-1 banking demo.

## OPEN POINTS

- Интеграция с боевым Intent Dispatcher (infra#27) и флагом `INTENT_LAYER_ENABLED` — вне demo; операторский акт (OD-R11); контракт двух intent-роутингов не ратифицирован.
- CLI-флаг budget-halt отсутствует (проверка pytest AC-5 / API `run_slice(max_cost=…)`).
- Полный Lineage Explorer (UI/конфиг) — OPEN POINT SPEC v0.1; сейчас ручной jsonl-просмотр.
- Реальные SCA/санкции/рельсы — mock/stub до соответствующих спринтов (S-A5/S-A7) и ключей (ED-01..05).
- Ратификация ADR-171/172/173 (OD-R21) — до неё контракты slice остаются DRAFT-совместимыми.

---
*DRAFT / NOT FOR MERGE. Источники: BANK-FOUR-FLOOR-MEMO, BANK-MASTER-ROADMAP, BANK-SPRINT-PLAN, INTENT-LAUNCH-SLICE-SPEC, ADR-046/047/049/128/171/172/173.*
