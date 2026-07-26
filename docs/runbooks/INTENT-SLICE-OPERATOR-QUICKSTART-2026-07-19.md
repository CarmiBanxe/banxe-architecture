# Intent Slice — Operator Quickstart

**DRAFT / NOT FOR MERGE** · 2026-07-19 · sandbox-only · ветка `agent/factory/bank-operating-model/20260718`

## Preconditions

- Рабочая директория: `~/wt/architecture-bank-operating-model-20260718` (все команды — из неё).
- Обязательно `RUNTIME_PROFILE=dev_fast`; профиль работает **только** при `SLICE_ENVIRONMENT=sandbox` (default). Любое другое окружение → отказ (fail-closed), это норма.
- Никаких реальных денег/рельсов: исполнение — sandbox-ledger-стаб; SCA и санкции — стабы.

## Happy path

```bash
RUNTIME_PROFILE=dev_fast python3 -m tools.sandbox.intent_slice.demo "переведи 500 EUR Ивану"
# в выводе: card_id, пути к card-файлам, lineage, hitl_queue; статус pending_human
```

## Approve / Reject / Revoke

```bash
RUNTIME_PROFILE=dev_fast python3 -m tools.sandbox.intent_slice.demo --decide approve <card_id>   # → executed
RUNTIME_PROFILE=dev_fast python3 -m tools.sandbox.intent_slice.demo --decide reject <card_id>    # → rejected
RUNTIME_PROFILE=dev_fast python3 -m tools.sandbox.intent_slice.demo --revoke <card_id>           # → revoked (ADR-172)
```
Каждая карточка решается один раз: повторное решение по не-pending карточке отклоняется.

## Budget-halt path

**OPEN POINT: CLI-флага budget-halt нет** — проверка только через pytest AC-5 или API:

```bash
python3 -m pytest tools/sandbox/intent_slice/tests/test_demo_e2e.py::test_ac5_budget_halt_blocks_before_card -q

RUNTIME_PROFILE=dev_fast python3 -c "
from decimal import Decimal
from tools.sandbox.intent_slice.demo import run_slice
from tools.sandbox.intent_slice.lineage_log import SlicePaths
print(run_slice('переведи 500 EUR Ивану','client-halt',SlicePaths.default(),max_cost=Decimal('0.01')))"
# ожидается: halted_budget_breach; BREACH-запись в lineage; сигнал в hitl_queue
```

## Где читать артефакты

| Что | Где |
|---|---|
| Confirmation cards (json + md) | `tools/sandbox/intent_slice/cards/` |
| Полная lineage-трасса (append-only jsonl, один `correlation_id` на заявку) | `tools/sandbox/intent_slice/logs/intent_lineage.jsonl` |
| HITL-очередь (append-only; card/decision/budget_breach записи) | `tools/sandbox/intent_slice/hitl_queue.jsonl` |
| Evidence snapshot | `tools/sandbox/intent_slice/evidence/snapshot-<UTC>/` (cards/, jsonl-копии, pytest.txt, summary.md) |

## Tests & evidence pack

```bash
python3 -m pytest tools/sandbox/intent_slice/tests -q                       # 15 тестов (AC-1..AC-7 + evidence)
RUNTIME_PROFILE=dev_fast python3 -m tools.sandbox.intent_slice.evidence_pack  # живой snapshot + summary.md
```

## Troubleshooting

- **`REFUSED: RUNTIME_PROFILE=dev_fast required…`** — не выставлен профиль; добавь `RUNTIME_PROFILE=dev_fast` перед командой.
- **`REFUSED: dev_fast is sandbox-only; SLICE_ENVIRONMENT=…`** — окружение не sandbox; это защитный отказ по дизайну (FAST-DEV-MODE-SPEC §4), не ошибка.
- **`card … is not pending — refused`** — по карточке уже принято решение (approve/reject/revoke); создай новую заявку (happy path) и решай новую карточку.
- **`unknown card_id`** — card_id не найден в `hitl_queue.jsonl`; проверь id в выводе demo или `cat tools/sandbox/intent_slice/hitl_queue.jsonl`.

---
*DRAFT / NOT FOR MERGE. Источники: INTENT-LAUNCH-SLICE-SPEC-v0.1, FAST-DEV-MODE-SPEC-v0.1, INTENT-LAUNCH-SLICE-BUILD-PROMPT-v0.1.*
