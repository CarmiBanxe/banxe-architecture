# ADR-008: Jurisdiction label — preemptive UK tagging

**Статус:** ПРИНЯТО  
**Дата:** 2026-04-05  
**Автор:** Moriel Carmi (CEO)

---

## Контекст

BANXE сейчас UK FCA EMI only. При появлении второй юрисдикции (EU EMI, UAE ADGM, или другой) потребуется routing правил по jurisdiction. Без явного label сейчас = mass refactoring потом.

## Решение

Все policy-файлы содержат явный jurisdiction header. Текущее значение: `UK`.

```python
# compliance_validator.py — _POLICY_ prefix отделяет policy scope
# от transaction/customer/counterparty jurisdictions (нет путаницы)
_POLICY_JURISDICTION = "UK"
_POLICY_REGULATOR    = "FCA"
_POLICY_FRAMEWORK    = "MLR 2017"

# banxe_aml_orchestrator.py — зеркалит validator constants
POLICY_JURISDICTION = "UK"
POLICY_REGULATOR    = "FCA"
POLICY_FRAMEWORK    = "MLR 2017"

# AMLResult — policy jurisdiction в runtime context
jurisdiction: str = "UK"  # policy jurisdiction scope

# SOUL.md — первая строка после /no_think
jurisdiction: UK  # FCA EMI scope
```

### Почему `_POLICY_` а не `_JURISDICTION_`

В compliance стеке существуют `origin_jurisdiction` (транзакция), `residence_jurisdiction` (клиент), `counterparty_jurisdiction` — без различения `_POLICY_*` от `*_jurisdiction` возникнет путаница. `_POLICY_JURISDICTION` = "правила откуда применяются". `origin_jurisdiction` = "откуда транзакция".

При появлении второй юрисдикции — routing по полю `jurisdiction` в compliance_validator, SOUL.md, и banxe_aml_orchestrator. Нулевой рефакторинг: поле уже есть, меняется только значение и routing logic.

## Последствия

- Поле `jurisdiction` появляется в `AMLResult` и `to_audit_dict()`
- ClickHouse `compliance_screenings` получит колонку `jurisdiction` при следующем schema migration
- SOUL.md первая строка после `/no_think` содержит `jurisdiction: UK`
- Нулевая операционная стоимость — поле всегда `"UK"` пока нет второй юрисдикции

## Ссылки

- `vibe-coding/src/compliance/models.py`
- `developer-core/compliance/verification/compliance_validator.py`
- `vibe-coding/src/compliance/banxe_aml_orchestrator.py`
- `vibe-coding/docs/SOUL.md`
