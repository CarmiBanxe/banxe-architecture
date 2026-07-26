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
  - проверки соответствия intent_slice demo ADR-172/172/173 (ратификация остаётся OPEN POINT, OD-R21).

**4. Next change-sets:**
- **Change-set R1:** фактический update `BANK-MASTER-ROADMAP` по floor-1 demo.
- **Change-set S1:** фактический update `BANK-SPRINT-PLAN` по S-A4/S-A10.
- **Change-set D1:** решение по Dispatcher integration / `INTENT_LAYER_ENABLED` (separate design/ADR; операторский гейт OD-R11).

**5. Status:** PLAN ONLY, DRAFT, NOT FOR MERGE.

---

### Floor 2 – Operational alignment (EMI / core bank)

**1. Observations** (по BANK-MASTER-ROADMAP, DELTA-MEMO, BANK-SPRINT-PLAN и новой floor-2 плитке FULL-BANK-INSTALLATION-AUDIT-PLAN):
- **Roadmap опережает реализацию:** cards-контур упомянут в WS8 без спеки/кода (UNK-09); внешняя API/BaaS-поверхность (WS13/S-A11) — спеки I-API/M-GATEWAY есть, реализация/audit нет; live FIN060→RegData цикл — future.
- **Реализация опережает roadmap:** 16/16 core-сервисов REAL и recon v2 DONE (EMI-IMPL-STATE) — при этом S-A6/S-A7 в sprint-плане местами читаются как «строительство», а фактическая работа = активация+ключи; 17 BUILD-SPEC'ов операционного слоя вообще не отражены в BANK-SPRINT-PLAN как исполненный слой спецификаций.
- **Дубли/противоречия между roadmap'ами:** FACTORY-ROADMAP (R0–R5) — фабричный, не bank-scope, но пересекается по observability/tools с WS14; TARGET-MODEL-CONFORMANCE-2026-06-24 superseded версией 06-25 (86%) — ссылки должны идти только на 06-25; ERROR-RECONCILIATION-ROADMAP и TRADING-BLOCK-ROADMAP ведут собственные спринт-серии (S6.x), не синхронизированные с S-A нумерацией — риск двойного учёта задач recon/trading.

**2. Proposed roadmap edits (PLAN ONLY):**
- Для `BANK-MASTER-ROADMAP`:
  - пометить floor-2 блоки WS7 (safeguarding/recon) и core-часть WS8 как **already partially implemented** (со ссылкой на EMI-IMPL-STATE + floor-2 плитку), а BUILD-SPEC-слой (B/D/E/G/H/I/L/M-серии) — как **require fresh audit before go-live**;
  - очерёдность: сначала SSOT/EMI-конформность (PHASE-3-SSOT + per-spec audit), затем новые функции (BaaS/cards/deep-analytics);
  - ссылки на conformance — только TARGET-MODEL-2026-06-25 (06-24 superseded).
- Для `BANK-SPRINT-PLAN`:
  - S-A6/S-A7: перевести формулировки в режим **"audit & conformance + activation"** вместо «новых фич» (код REAL — работа = live-режим, ключи, HITL-циклы);
  - S-A12: добавить под-задачу «per-spec implementation audit 17 BUILD-SPEC'ов» либо вынести в отдельный audit-спринт при плитке floor-2;
  - S-A8/S-A11: сфокусировать на GAP'ах floor-2 плитки (FIN060 live, API-поверхность по I-API/M-GATEWAY спекам), убрать пересечения с trading S6.x (мандат Terminal B);
  - убрать дубликаты: задачи recon-строительства (recon v2 уже DONE), error-handling задачи, уже покрытые ERROR-RECONCILIATION-ROADMAP.

**3. Dependencies:**
- installation-audits внешних EMI-репо (по EMI-CANON-COVERAGE-10-REPOS/COMPLETE; snapshot 2026-06-06 устарел → план A2);
- PHASE-3-SSOT-CONFORMANCE — предусловие статуса «floor-2 готов»;
- связь с floor-1: без исправного операционного слоя floor-1 intent-demo не может исполнять реальные операции (сейчас sandbox-ledger-стаб) — цепочка D1 (Dispatcher) → floor-2 activation.

**4. Next change-sets:**
- **R2:** фактический update `BANK-MASTER-ROADMAP` по floor-2.
- **S2:** фактический update `BANK-SPRINT-PLAN` по floor-2 (EMI/core).
- **A2:** отдельный installation-audit change-set для внешних EMI-репо (PLAN: refresh EMI-CANON-COVERAGE + per-spec audit 17 BUILD-SPEC'ов).

**5. Status:** PLAN ONLY, DRAFT, NOT FOR MERGE.

---
*Producer: factory sandbox terminal. Источники: BANK-FOUR-FLOOR-MEMO, BANK-MASTER-ROADMAP, BANK-SPRINT-PLAN, INTENT-LAUNCH-SLICE-SPEC, LINEAGE-EXPLORER-SPEC, ADR-046/047/049/128/171/172/173, agent-budget-policy, runtime-guardrails-policy, runbooks intent_slice; floor-2: EMI-IMPL-STATE-REFRESH, *-BUILD-SPEC, EMI-CANON-COVERAGE-*, FULL-PROJECT-INSTALLATION-AUDIT, PHASE-3-SSOT-CONFORMANCE, TARGET-MODEL-CONFORMANCE-06-25, ERROR-RECONCILIATION-ROADMAP, TRADING-BLOCK-ROADMAP, ADR-045/056/057/078..081/096..101.*
