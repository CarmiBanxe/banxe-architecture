# DOCUMENTATION AUDIT — 2026-07-26 (STEP8, ENGREF01)

> ⚠ SANDBOX / TRAINING context. Read-only audit — nothing moved/renamed/deleted in this change-set.
> Base: origin/main cc40eb3, ~1881 .md. Companion navigation: `DOCUMENTATION-MASTER-INDEX.md`.

## 1. Находки

1. **Три ADR-серии** (подтверждено): `docs/adr/` (123, числовая канон-серия, 2 индекса: INDEX.md + README.md) ·
   `decisions/` (41, историческая ADR-001…041) · `adrs/` (14, доменная CBS/CST/FIN/FOS/FRAUD/GOV).
   Это НЕ дубли — три осмысленных слоя; риск только в отсутствии единой карты (закрыто мастер-индексом).
2. **Три canon-корня** с пересекающимися именами: `docs/canon/` (39 предметных) · `canon/` (CANON.md + 5 modules,
   incl. LEGAL) · `.canon/` (CANON.md + 4 modules, без LEGAL).
3. **Canon-рассинхрон ПОДТВЕРЖДЁН** (read-only diff на origin/main cc40eb3):
   - `canon/CANON.md` ↔ `.canon/CANON.md` — **РАСХОДЯТСЯ** (20 diff-строк)
   - `canon/modules/CORE.md` ↔ `.canon/modules/CORE.md` — **РАСХОДЯТСЯ** (37 diff-строк)
   - `modules/DECISION.md`, `modules/DEV.md`, `modules/DOC.md` — СОВПАДАЮТ
   - `modules/LEGAL.md` — существует ТОЛЬКО в `canon/`
4. **Два индекса в docs/adr/** (INDEX.md + README.md) — частичное дублирование назначения.
5. **27 разрозненных .md в корне репо** — смесь инфраструктурных (README, CLAUDE.md, INVARIANTS…) и
   переносимых исторических (MASTER-PLAN-2026-05-05, SESSION-HANDOFF-2026-06-07, SPRINT-0-PLAN…).
   Классификация — в мастер-индексе §4.

## 2. Риски

- **73 файла ссылаются на `decisions/ADR-*`** — любой перенос/переименование этой серии ломает
  73 кросс-ссылки → пути `decisions/` замораживаются как исторические.
- Canon-рассинхрон (CANON.md/CORE.md): агенты, читающие `.canon/`, получают версию, отличную от `canon/` —
  риск расхождения поведения; до консолидации требуется явное указание источника правды.
- INSTRUCTION-LEDGER.md — генерируемый: любой ручной перенос/правка = поломка ledger-гейтов (урок D2-CS1).

## 3. РЕКОМЕНДАЦИИ (каждая = PROPOSED; отдельный change-set; НИЧЕГО не исполнено в этом шаге)

| # | Рекомендация | Метод | Статус |
|---|---|---|---|
| R1 | **Консолидация canon-корней**: свести `canon/` и `.canon/` к одному источнику правды после построчного diff-ревью CANON.md+CORE.md (20+37 строк) оператором; LEGAL.md учесть; второй корень — симлинк/генерат или удалить с редиректом | отдельный change-set, operator review обязателен (канон-файлы) | PROPOSED |
| R2 | **Слияние `docs/adr/INDEX.md` + `README.md`** в один индекс (второй — краткий указатель на первый) | отдельный change-set | PROPOSED |
| R3 | **Поэтапный перенос корневых кандидатов** (11 файлов из мастер-индекса §4) в docs/-подпапки | git mv + правка всех входящих ссылок, по одному файлу за change-set | PROPOSED |

## 4. Perimeter

Не тронуты: MEMORY.md, `.claude/`, `.canon/`, INSTRUCTION-LEDGER.md, `config/runtime_gate/` (§72), PR #1133,
чужие stash. Никаких перемещений/переименований/удалений .md в этом change-set.

---
*STEP8 | ENGREF01 | sandbox-labeled | вход: shell-аудит origin/main; выход: карта+рекомендации (PROPOSED).*
