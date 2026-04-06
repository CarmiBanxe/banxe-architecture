# Ruflo Review Report — IL-006 (Block D Transaction API)

**Reviewer:** Ruflo (Review Agent)  
**Date:** 2026-04-06  
**Commit reviewed:** vibe-coding `8ae7dd0`  
**IL:** IL-006 Step 6

---

## Checklist

### ☑ I-28: LedgerPort invariant — нет прямых HTTP в обход Port

**PASS.**

- `ledger_port.py` — 0 строк с `requests.`, `http`, `HTTP`. Порт содержит только `ABC` + `abstractmethod`. HTTP изолирован в адаптере.
- `midaz_adapter.py` — единственное место где вызывается `requests.post/get`. Все методы реализованы как конкретный адаптер, не как прямые вызовы из бизнес-логики.
- `test_midaz_transaction.py` — все HTTP вызовы через `unittest.mock.patch("compliance.adapters.midaz_adapter.requests.*")`. Ни один тест не делает реального сетевого вызова.

Нарушений I-28 нет.

---

### ☑ CTX-06 boundary — нет импортов из CTX-01..05 напрямую

**PASS.**

`midaz_adapter.py` импортирует только из:
- `os`, `decimal`, `typing` (stdlib)
- `requests` (HTTP library)
- `compliance.ports.ledger_port` (CTX-06 internal port)

Нет импортов из:
- `compliance.decision.*` (CTX-01)
- `compliance.policy.*` (CTX-02)
- `compliance.audit.*` (CTX-03)
- `compliance.api.*` (CTX-04)
- `compliance.agent.*` (CTX-05)

Граница CTX-06 не нарушена.

---

### ☑ Trust zone AMBER — файлы в правильной зоне

**PASS.**

Все 4 файла commit `8ae7dd0` находятся в `src/compliance/`:
- `ports/ledger_port.py` — определение контракта (AMBER ✓)
- `adapters/midaz_adapter.py` — реализация адаптера (AMBER ✓)
- `test_midaz_transaction.py` — тесты (GREEN/test scope ✓)
- `test_midaz_adapter.py` — тесты (GREEN/test scope ✓)

Ни один файл не записан в RED zone (`governance/`, `rego/`, `SOUL.md`, `compliance_config.yaml`).

---

### ☑ Safeguarding accounts — корректны в transaction flow

**PASS.**

В `test_midaz_transaction.py` используются реальные ADR-013 IDs:
```
OP_ACCOUNT  = "019d6332-f274-709a-b3a7-983bc8745886"  # operational (asset)
CF_ACCOUNT  = "019d6332-da7f-752f-b9fd-fa1c6fc777ec"  # client_funds (liability)
ORG_ID      = "019d6301-32d7-70a1-bc77-0a05379ee510"
LEDGER_ID   = "019d632f-519e-7865-8a30-3c33991bba9c"
```

T-06 (`test_T06_account_alias_is_uuid`) проверяет, что `accountAlias` = UUID напрямую (без `@alias`), что соответствует нашей конфигурации где алиасы не заданы.

T-04 (`test_T04_request_amounts_balanced`) проверяет ключевой Midaz constraint: `send.value == from[].amount.value == to[].amount.value`.

Safeguarding flow операционально корректен.

---

### ☑ Tests coverage ≥ 15 (T-01..T-15)

**PASS. 15/15 тестов, 15 passed.**

| Test | Что проверяет |
|------|---------------|
| T-01 | create_transaction success (201) |
| T-02 | _to_smallest_unit: pence conversion |
| T-03 | _from_smallest_unit: back-conversion |
| T-04 | send.value == from.value == to.value |
| T-05 | correct endpoint URL |
| T-06 | accountAlias = UUID |
| T-07 | description included when non-empty |
| T-08 | description omitted when empty |
| T-09 | 422 ErrInsufficientFunds → RuntimeError |
| T-10 | 404 account not found → RuntimeError |
| T-11 | list_transactions success (2 items) |
| T-12 | list_transactions empty |
| T-13 | list_transactions limit capped at 100 |
| T-14 | TransactionRequest frozen (FrozenInstanceError) |
| T-15 | TransactionResult frozen (FrozenInstanceError) |

---

### ☑ Frozen dataclass — no mutable state

**PASS.**

```python
@dataclass(frozen=True)  # line 34 — TransactionRequest
@dataclass(frozen=True)  # line 56 — TransactionResult
```

`metadata` в `TransactionRequest` объявлен с `field(hash=False, compare=False)` — исключён из hash для поддержки dict-значений. Это корректный паттерн для frozen dataclass с опциональными метаданными.

`source`/`destination` в `TransactionResult` — `tuple` (hashable). Корректно.

---

### ☑ IL-006 steps отмечены

**PASS.** IL-006 содержит Steps 1-5 ✅, Step 7 ✅. Step 6 (этот review) в процессе. Step 8 ожидает CEO.

---

## Итог

| Пункт | Статус |
|-------|--------|
| I-28: нет прямых HTTP в обход Port | ✅ PASS |
| CTX-06 boundary не нарушена | ✅ PASS |
| Trust zone AMBER корректна | ✅ PASS |
| Safeguarding accounts в тестах | ✅ PASS |
| Tests ≥ 15 | ✅ PASS (15/15) |
| Frozen dataclasses | ✅ PASS |
| IL-006 steps | ✅ PASS |

**OVERALL: APPROVED** — код готов к CEO verify (IL-006 Step 8).

---

## Замечания (non-blocking)

1. `_AMOUNT_SCALE = 2` захардкожен. Для multi-currency (JPY scale=0, KWD scale=3) потребуется расширение. **Non-blocking** для Sprint 8/9 — BANXE работает только с GBP.
2. `list_transactions` возвращает `List[TransactionResult]` без метаданных пагинации (cursor, total). При необходимости листать большие списки — добавить `ListTransactionsResult` wrapper. **Non-blocking** для текущего спринта.
3. В `midaz_adapter.py` нет retry логики для `ErrLockVersionAccountBalance` (409 race condition). Midaz рекомендует retry. **Non-blocking** — корнер-кейс, можно добавить в Sprint 10.
