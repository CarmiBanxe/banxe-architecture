# GitNexus — OPERATOR UNBLOCK (sandbox) + запрос на активацию к фабрике

**ADR-102 aligned.** Sandbox/governance/TRAINING only; **no PROD, no commercial use.**

## OPERATOR DECISION (ратифицировано 2026-07-28)
GitNexus (PolyForm-Noncommercial-1.0.0) **РАЗБЛОКИРОВАН для использования.**
Обоснование оператора: вся работа ведётся в **песочнице / non-commercial**; коммерческого
использования нет → **покупная лицензия НЕ требуется**, PolyForm-NC разрешает sandbox/training.
Прежний «PROD/commercial blocked» гейт **НЕ применяется** к нашему контуру (мы не в PROD).
Этот пункт снимает FAIL-CLOSED из PHASE0-verify для sandbox-объёма.

## Запрос к фабрике — АКТИВАЦИЯ (не разрешение — оно дано оператором)
1. Активировать GitNexus в sandbox-режиме: MCP + hooks + CI-gate. Подтвердить объём активации.
2. Подключить для предстоящих Wave -1 (repo-consolidation, 35 репо) и Wave 0 (org-structure).
3. Соблюсти инвариант: код-граф GitNexus = ТОЛЬКО код-связи; орг-слой держать ОТДЕЛЬНО
   (не помещать орг-узлы в KuzuDB код-граф) — заменяемость инструмента сохраняется.
4. Вернуть статус активации (что включено: MCP/hooks/CI-gate) для отметки в roadmap Wave -1.2.

## Границы
Sandbox/non-commercial. Если появится PROD/commercial сценарий — отдельный gate + покупная лицензия
(вне текущего контура). Fork O1/O2/O3 — только при переходе к PROD, сейчас не требуется.
