# GITNEXUS PHASE 1 — CODE-CONTOUR README (sandbox-scope)

> ⚠ SANDBOX / TRAINING (BANXE_ENV=sandbox, data_class=TRAINING, PROD_READY=false).
> Директива-источник: `GITNEXUS-CODE-CONTOUR-DIRECTIVE.md` (enrich → impact → act).
> PHASE 0 выдача: `../audit/GITNEXUS-PHASE0-VERIFY-2026-07-27.md` (языковая матрица; fleet Python-доминантен).
> Файлы созданы в рабочем дереве, НЕ закоммичены (по приказу PHASE 1).

## LICENSING

GitNexus лицензирован **PolyForm-Noncommercial-1.0.0**.
Sandbox/TRAINING-использование — без лицензии. **«PROD/commercial use requires a purchased GitNexus
license»** — дисклеймер выводится в шапке каждого артефакта и на каждом запуске (`DISCLAIMER` в
`detect_impact.py`, `gitnexus_guard()` в `gitnexus_env.sh`). PROD-включение = покупка лицензии
(PROD-gate-спринт, G-серия).

## Что реализовано в Phase 1 (без живого MCP; 0 инструментов = штатный режим)

| Артефакт | Назначение |
|---|---|
| `scripts/gitnexus/gitnexus_env.sh` | GITNEXUS_ENV (default sandbox); `gitnexus_guard()` — fail-closed вне sandbox с лицензионным дисклеймером (exit 1); `gitnexus_probe()` — локальная проверка MCP (endpoint+binary), при 0 инструментов exit 78 (EX_CONFIG) + «reminder+fail-closed mode» |
| `.githooks/pre-commit.gitnexus` | Impact-гейт: MCP есть → `detect_impact.py`; MCP нет → обычные правки НЕ блокируются, но HIGH-RISK-пути (fleet-носители: `bank-rooms/*/runtime/*`, `tools/sandbox/intent_slice/*`, apar-паспорт, `schemas/*`, `sql/*`) требуют `GITNEXUS_ACK=1` (fail-closed) |
| `scripts/gitnexus/detect_impact.py` | Типизированный stdlib-CLI (3.11+): staged-diff → при живом MCP делегирует реальному `gitnexus detect-impact` (HIGH без ACK = exit 1; ошибка/непарсибельный вывод = fail-closed, никогда «low»); при 0 инструментов → risk="UNKNOWN", exit 78, дисклеймер — **NO-MOCK, граф не имитируется** |
| этот README | статусы, лицензия, активация, соответствие директиве |

## Осознанно отложено до Phase 2 (MCP-подключение)

Живые **enrich** (PreToolUse) и **reindex** (PostToolUse), `npx gitnexus analyze` по покрытым репо,
глобальный реестр `~/.gitnexus/` (list_repos), реальный blast-radius. Причина: MCP не подключён
(pre-condition директивы, стр. состояния) — Phase 1 обязана fail-closed'иться на 0 инструментов,
не имитировать.

## Activation (НЕ выполнено — только инструкция; существующий гейт сохранён)

Существующий **активный** `.githooks/pre-commit` (LucidShark + ADR-120 guard) **не тронут** —
перезапись сломала бы действующий quality-гейт (deviation от буквы задания «положить pre-commit»:
файл положен как `pre-commit.gitnexus`). Активация при Phase 2 — chain-call, добавить в КОНЕЦ
существующего `.githooks/pre-commit`:

```bash
# GitNexus impact gate (PHASE 2 activation)
"$(git rev-parse --show-toplevel)/.githooks/pre-commit.gitnexus" || exit $?
```

`git config` не менялся; глобальной активации нет.

## Соответствие директиве (enrich / impact / act → статус Phase 1)

| Пункт директивы | Статус в Phase 1 |
|---|---|
| **enrich** (PreToolUse, граф-контекст) | ОТЛОЖЕН (Phase 2: требует живой MCP); напоминание печатается probe'ом |
| **impact** (`detect_impact`, blast-radius до коммита) | РЕАЛИЗОВАН как fail-closed-обёртка: делегирует реальному инструменту при MCP; UNKNOWN/78 без MCP; HIGH-RISK без ACK — блок |
| **act** (правка только после enrich→impact) | Дисциплина закреплена: hook-гейт + напоминание; полная автоматизация — Phase 2 |
| reindex (PostToolUse) | ОТЛОЖЕН (Phase 2) |
| fail-closed на high-risk без подтверждения | РЕАЛИЗОВАН (`GITNEXUS_ACK=1` контракт в hook и CLI) |
| напоминание в каждом промте фабрики | ДЕЙСТВУЕТ (CLAUDE.md-секция, #1153) |
| zero-server/local, no-mock | СОБЛЮДЕНО: ни сетевых вызовов, ни установки пакета, ни имитации графа |
| backlog BNPL/credit-building | остаются blocked-by-canon (NO-CREDIT-PRODUCTS-CANON) |

---
*PHASE 1 выдача | ENGREF01 | sandbox | files-only, not committed | 2026-07-27.*
