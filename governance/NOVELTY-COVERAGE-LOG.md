# NOVELTY-COVERAGE-LOG

**B-owned, append-only** лог coverage-confirmation прогонов Terminal-B (Spec-Projects) по алгоритму ADR-159 §Terminal-B-Operating-Algorithm → Outcome-2.

Отдельно от реестра находок (`NOVELTY-COLLECTION-REGISTER.md`). Реестр фиксирует Outcome-1 (найдены новинки → hand-off A); настоящий лог фиксирует Outcome-2 (multi-pass вычитка подтвердила полное покрытие, delta=0 → auditable proof-of-completeness, hand-off A НЕ происходит). Применяется в т.ч. к уже-использованным источникам — оператор прогоняет их, чтобы удостовериться в полной вычитке.

## Схема полей

| Поле | Смысл |
|---|---|
| `source` | Файл/документ, по которому прогонялась вычитка. |
| `passes` | Число проходов multi-pass read (`multi` = ≥2). |
| `coverage` | `full` (delta=0) или `partial` (были находки, вынесенные в реестр). |
| `gaps-found` | При `full` = 0; при `partial` — перечисление `item`-ов находок из реестра. |
| `dup-refs` | Ссылки на существующие места в корпусе (`governance/` + `docs/adr/`), подтверждающие покрытие; описываются как факт, без раскрытия секретов. |
| `corpus-sha` | Короткий SHA `origin/main` HEAD на момент прогона — анкер воспроизводимости. |
| `timestamp` | UTC ISO-8601 момента append. |

## Append-инструкция

Строки добавлять **только в конец** таблицы Entries. Существующие строки НЕ редактировать, НЕ переупорядочивать, НЕ удалять (append-only, как реестр находок). Каждая новая запись фиксируется через specproj-PR как `shard + INSTRUCTION-LEDGER.md + IL-SEQUENCE.json` вместе (ADR-119, ledger discipline). Merge — HITL-оператором (CLAUDE.md §71).

## Entries

| source | passes | coverage | gaps-found | dup-refs | corpus-sha | timestamp |
|---|---|---|---|---|---|---|
| banxe-agent-engine-conclusion.md | multi | full | 0 | 11/12 фреймворков покрыты (docs/agent-engine-dossier SRC-01/SRC-04) + P0-дефекты в ADR (midaz/CASS/safeguarding) + ANTHROPIC_API_KEY=env-only, 0 hardcoded (не утечка) | 3552e73 | 2026-07-05T00:23:04Z |
