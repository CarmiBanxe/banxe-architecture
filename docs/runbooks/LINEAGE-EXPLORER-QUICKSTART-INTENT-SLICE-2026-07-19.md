# Lineage Explorer Quickstart — чтение intent_slice snapshot

**DRAFT / NOT FOR MERGE** · 2026-07-19 · sandbox-only · ветка `agent/factory/bank-operating-model/20260718`

## Цель

Как оператору/SMF прочитать evidence snapshot существующего Intent Launch Slice через призму `docs/architecture/LINEAGE-EXPLORER-SPEC-v0.1-2026-07-18.md` (запросы Q1–Q6) — **вручную по jsonl**, до появления полноценного Explorer-инструмента.

## Предпосылки

- `RUNTIME_PROFILE=dev_fast`; demo и evidence_pack уже выполнены — см. `docs/runbooks/INTENT-SLICE-OPERATOR-QUICKSTART-2026-07-19.md`.

## Артефакты

Snapshot: `tools/sandbox/intent_slice/evidence/snapshot-<UTC>/` (живой пример: `snapshot-20260718T222645Z/`). Explorer-релевантные файлы:
- `intent_lineage.jsonl` — decision-lineage записи (основной источник, Q1–Q6);
- `hitl_queue.jsonl` — card/decision/budget_breach записи (Q5/Q6, human verdicts);
- `cards/card-<id>.json|.md` — confirmation cards (контекст для Q1: сумма/получатель/max_cost/autonomy).

## Маппинг полей на ADR-046 / LINEAGE-EXPLORER-SPEC

[ФАКТ, по коду `tools/sandbox/intent_slice/contracts.py::LineageEvent`] Каждая строка `intent_lineage.jsonl` несёт канонические поля ADR-046: `record_id`, `timestamp`, `agent_id`, `triggering_event`, `intent`, `policies_evaluated[]`, `compliance_result` (PASS/FAIL/ESCALATE/N/A), `reasoning_summary`, `confidence_score`, `action_taken`, `human_reviewed_by`, `correlation_id` + cost-lineage: `cost_tokens`, `cost_amount`, `budget_breach_flag` (NONE/WARN/BREACH), `escalated_to`.

Как читать ключевое:
- **correlation_id** — общий для всех записей одной заявки (SPEC Q3 timeline): `grep <correlation_id> intent_lineage.jsonl`.
- **intent_id** — в `triggering_event` формата `intent:<intent_id>` и в `cards/*.json` (`intent_id`).
- **human verdict** — запись с `action_taken` ∈ {`EXECUTE_TRANSFER_SANDBOX`,`REJECTED`,`REVOKED`} и заполненным `human_reviewed_by`; дублируется в `hitl_queue.jsonl` (`type:"decision"`, `status`).
- **budget-halt (SPEC Q5)** — записи `budget_breach_flag:"BREACH"`, `action_taken:"HALT_BUDGET_EXCEEDED"`, `escalated_to:"human_review_queue"` + `type:"budget_breach"` в очереди.

OPEN POINT (не эмитятся slice-кодом, в SPEC/ADR-046 есть): `immutable_storage_ref`, `input_tokens`/`output_tokens`; хранилище — jsonl, не ClickHouse `banxe.decision_records` (Explorer-запросы к ClickHouse неприменимы к snapshot).

## Пример сценария (уже отыгран в snapshot-20260718T222645Z)

Intent «переведи 500 EUR Ивану» → verdict `executed`:
```bash
cd ~/wt/architecture-bank-operating-model-20260718
SNAP=tools/sandbox/intent_slice/evidence/snapshot-20260718T222645Z
cat "$SNAP"/summary.md                                  # счётчики + correlation_id + verdict
python3 -c "import json,sys;[print(e['timestamp'],e['action_taken'],e['compliance_result']) for e in map(json.loads,open('$SNAP/intent_lineage.jsonl'))]"   # Q3 timeline
grep '"type": "decision"' "$SNAP"/hitl_queue.jsonl      # human verdict
cat "$SNAP"/cards/card-*.md                             # что видел человек при подтверждении
```
Ожидаемая последовательность action_taken: `CONSENT_AT_DELEGATION_MOCK_SCA → AUTONOMY_L2 → BUDGET_CHARGED → GUARDRAIL_CLEAR → EXECUTE_TRANSFER_SANDBOX`.

## Troubleshooting

- **Нет файлов/пустой snapshot:** demo не отыгран — выполни happy path из INTENT-SLICE-OPERATOR-QUICKSTART, затем `evidence_pack`; `summary.md` честно покажет `Card artifacts: 0 / (none)`.
- **Некорректный формат строки jsonl:** файл append-only — не редактируй; повреждённая строка = инцидент, зафиксируй и создай новый прогон (старый лог не чинить, I-24).
- **Не находится correlation_id:** возьми его из `summary.md` секции `## correlation_id`, не из памяти.

## OPEN POINT — конфигурация Explorer

Конфигурационный файл для полнофункционального Lineage Explorer остаётся OPEN POINT; текущий шаг — только ручной просмотр jsonl/logs по спецификации (SPEC v0.1 определяет запросы/поля, но не формат конфига/CLI — конфиг не изобретаем).

---
*DRAFT / NOT FOR MERGE. Источники: LINEAGE-EXPLORER-SPEC-v0.1, ADR-046, INTENT-SLICE-OPERATOR-QUICKSTART-2026-07-19, код tools/sandbox/intent_slice/.*
