# LEDGER-PATH-TAXONOMY — классификация путей ledger-системы

**Источник:** Fable-5 + Codex ruling 2026-08-05 (INDEPENDENT, полное схождение).
**Принцип:** обязанность трассируемости определяется СЕМАНТИКОЙ файла, а не
расположением рядом с ledger. Список исключений — закрытый и машинно проверяемый
(`scripts/guardian_ledger_gate.sh`: ADMIN_RE / INFRA_RE); расширение списка =
канон-изменение через owner review скрипта.

| Категория | Примеры | IL-шард-трассируемость |
|---|---|---|
| Авторитетный канон-контент | `ledger/entries/*`, суперсидинг финансовых/контрольных фактов, docs/governance, ADR | **Обязательна** |
| Канонические правила интерпретации | schema, mapping, accounting/control policy (меняют смысл/валидацию записей) | **Обязательна** либо эквивалентная control-record процедура |
| Производные артефакты | агрегаты (INSTRUCTION-LEDGER.md), индексы, manifests, rendered views | Без нового шарда; должны воспроизводиться и проверяться (ADR-060) |
| Административное состояние нумерации | `ledger/IL-GAP-REGISTER.json`, `ledger/ALLOCATOR-RECOVERY-LOG.md` | Без шарда; аудируемый change-record (append-only, суперсидинг-записи) |
| Контрольная инфраструктура | CI checks, guardian rules, build scripts | Без шарда; owner review + тесты + change-management |
| Disclosure/publication | README, disclosure manifests, redaction reports | Без шарда, если не меняет канонический факт |
| Секреты и операционные конфиги | `.env*`, credentials, account identifiers | Вне ledger-трассируемости; отдельная security/compliance политика |

**Правила гейта:** смешанный PR (administrative + canonical) исключения не
получает — требование шарда применяется из-за canonical-части. Rename не
обходит проверку (`--no-renames`: старый canonical-путь остаётся в диффе).
Тесты: `tests/guardian-ledger/test_gate.sh` (5 кейсов).
