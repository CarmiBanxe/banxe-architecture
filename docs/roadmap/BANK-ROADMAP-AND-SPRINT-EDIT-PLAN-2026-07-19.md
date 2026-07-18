# BANK ROADMAP & SPRINT — EDIT PLAN — 2026-07-19

**Status: PLAN ONLY, DRAFT, NOT FOR MERGE** · ветка `agent/factory/bank-operating-model/20260718`
Назначение: план будущих правок `BANK-MASTER-ROADMAP-TO-100-PERCENT-LAUNCH-READINESS-DRAFT.md` и `BANK-SPRINT-PLAN-EXECUTION-DRAFT-2026-07-18.md`. **Сами документы этим файлом НЕ изменяются** — каждая фактическая правка = отдельный change-set.

---

### Floor 1 – Intent demo alignment (intent_slice)

**1. Observations:**
- Floor-1 клиентский intent demo («переведи 500 EUR Ивану») уже реализован в `tools/sandbox/intent_slice/` и описан в:
  - `INTENT-LAUNCH-SLICE-SPEC-v0.1-2026-07-18.md`
  - `BANK-FOUR-FLOOR-MEMO` (floor 1)
  - `BANK-FLOOR1-INTENT-DEMO-MAPPING-2026-07-19.md`
  - `LINEAGE-EXPLORER-QUICKSTART-INTENT-SLICE-2026-07-19.md`
- `BANK-MASTER-ROADMAP` §9 и `BANK-SPRINT-PLAN` (S-A4/S-A10) частично рассматривают этот demo как future/partial, при том что demo+evidence уже существуют (snapshot `snapshot-20260718T222645Z`, 15/15 тестов PASS).

**2. Proposed roadmap edits (PLAN ONLY, NO CHANGE YET):**
- В `BANK-MASTER-ROADMAP`:
  - отметить floor-1 intent demo как “baseline demo implemented in sandbox with evidence & lineage”, с явными ссылками на три runbook'а;
  - перенести часть задач по floor-1 demo из future в accomplished/ongoing, с чётким указанием остающихся GAP (Dispatcher, Explorer UI, budget-halt CLI).
- В `BANK-SPRINT-PLAN`:
  - скорректировать S-A4/S-A10 так, чтобы они:
    - ссылались на уже существующий intent_slice demo и evidence;
    - фокусировались на закрытии OPEN POINTS (Dispatcher integration, Explorer UI, budget-halt CLI, rails mocks);
    - убрали дубликаты задач, уже фактически выполненных (intent capture-скелет, confirmation card-минимум, e2e-тест цепочки — сделаны в sandbox-slice).

**3. Dependencies:**
- Любые фактические изменения в `BANK-MASTER-ROADMAP` и `BANK-SPRINT-PLAN` происходят отдельным change-set'ом после:
  - наполнения `docs/audit/FULL-BANK-INSTALLATION-AUDIT-PLAN-2026-07-19.md` (включая другие подсистемы — floors 2–4, agent fleet);
  - проверки соответствия intent_slice demo ADR-171/172/173 (ратификация остаётся OPEN POINT, OD-R21).

**4. Next change-sets:**
- **Change-set R1:** фактический update `BANK-MASTER-ROADMAP` по floor-1 demo.
- **Change-set S1:** фактический update `BANK-SPRINT-PLAN` по S-A4/S-A10.
- **Change-set D1:** решение по Dispatcher integration / `INTENT_LAYER_ENABLED` (separate design/ADR; операторский гейт OD-R11).

**5. Status:** PLAN ONLY, DRAFT, NOT FOR MERGE.

---
*Producer: factory sandbox terminal. Источники: BANK-FOUR-FLOOR-MEMO, BANK-MASTER-ROADMAP, BANK-SPRINT-PLAN, INTENT-LAUNCH-SLICE-SPEC, LINEAGE-EXPLORER-SPEC, ADR-046/047/049/128/171/172/173, agent-budget-policy, runtime-guardrails-policy, runbooks intent_slice.*
