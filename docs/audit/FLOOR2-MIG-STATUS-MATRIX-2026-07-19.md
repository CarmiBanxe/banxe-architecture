# FLOOR-2 MIG STATUS MATRIX — 2026-07-19

**Status: PLAN + SNAPSHOT, DRAFT, NOT FOR MERGE** · ветка `agent/factory/bank-operating-model/20260718` · producer: factory sandbox terminal
Метод: статусы присвоены **по содержимому файлов** (заголовки/резолюции проверены grep'ом), не по именам. Ключевой верифицированный паттерн серии: BLOCKER-док фиксирует стоп (ADR-102), а парный **RESCOPE/declare-covered/COVERED-док явно резолвит BLOCKER по операторскому решению** — т.е. RESCOPE здесь = resolution-класс, не «открытая работа».

## 1. Цель

MIG-файлы — мост legacy (BANXE.RAR) → target operating model (EMI BANXE). 43 файла baseline-периметра (M1/M2/ABS/RESIDUAL/SAR/SRP) описывают миграции, BLOCKER'ы и решения. Цель документа: статусная матрица (BLOCKER/RESCOPE/COVERED/ACCEPTANCE/AWAITS) + привязка цепочек к BUILD-SPEC'ам floor-2 (особенно D-GL, B-EMI, A-IDV/KYC/KYB, M-GATEWAY, web-слой) как прямой вход для A2.

## 2. Scope

Baseline = 43 файла (precheck 2026-07-19): MIG-M1.\* (10) · MIG-M2.\* (27) · MIG-ABS-\* (3) · MIG-RESIDUAL-GENUINE-GAP-REGISTER-2026-06-25.md (1) · MIG-SAR-\* (1) · MIG-SRP-\* (1). Плюс два смежных, подтверждённых на диске: `MIG-coverage-acceptance.md`, `MIG-login-history-blocker-banxe-platform.md`. Остальные ~35 файлов `docs/migration/` — вне первого круга (добавляются при A2 по мере привязки).

## 3. Классификация статусов

- **BLOCKER** — миграция явно блокирует включение BUILD-SPEC/функции (ADR-102 stop-barrier).
- **RESCOPE** — меняет scope/подход; в этой серии обычно **резолвит** парный BLOCKER (проверять строку «Resolves the … blocker per operator decision»).
- **COVERED** — зафиксировано, что blocker закрыт существующей поверхностью (declare-covered).
- **ACCEPTANCE** — финальное принятие результата цикла.
- **AWAITS** — ожидает решения (operator/decision).

## 4. Матрица MIG → статус (по цепочкам, verified)

**ABS-posting chain → D-GL/B-EMI:**
- `MIG-ABS-posting-BLOCKER-gl-service-already-exists.md` — BLOCKER (исходный)
- `MIG-ABS-posting-COVERED-gl-service.md` — COVERED; [ФАКТ] «Resolves the MIG-ABS-posting blocker (PR #648/IL-404) per operator decision A»
- `MIG-ABS-identity-coverage-audit.md` — audit-support
- **Вывод: RESOLVED (COVERED).**

**M2.3 identity chain → A-IDV/A-KYC/A-KYB:**
- `MIG-M2.3-BLOCKER-identity-auth-already-exists.md` — BLOCKER
- `MIG-M2.3-RESCOPE-identity-auth-gap-audit.md` — RESCOPE-resolution; [ФАКТ] «Resolves the MIG-M2.3 blocker (PR #632/IL-389) per pre-authorised operator decision A. KYC/KYB/AML carve-out (I-27)»
- **Вывод: RESOLVED (RESCOPE-resolution); carve-out I-27 сохраняется как условие.**

**M2.4 open-banking chain → M-GATEWAY (+B-EMI смежно):**
- `MIG-M2.4-BLOCKER-open-banking-already-exists.md` — BLOCKER; `MIG-M2.4-RESCOPE-open-banking-gap-audit.md` — RESCOPE; `MIG-M2.4-OB-delta-completion.md` — delta-completion
- `MIG-M2.4a-BLOCKER-scheduled-payments…` — BLOCKER; `MIG-M2.4ab-declare-covered.md` — COVERED; [ФАКТ] «Resolves the MIG-M2.4a blocker (PR #643/IL-400) per operator decision C (fold a+b)»
- `MIG-M2.4c-BLOCKER-batch-payments…` — BLOCKER; `MIG-M2.4c-COVERED-batch-payments.md` — COVERED; [ФАКТ] «Resolves … (PR #662/IL-418) per operator decision A»
- **Вывод: RESOLVED по всем под-веткам (a/ab/c COVERED; корень — RESCOPE+delta).** [INFERENCE] строка «Resolves» в корневом RESCOPE не грепалась — подтвердить при A2.

**M2.5 ABS/BIF chain → D-GL/B-EMI:**
- `MIG-M2.5-BLOCKER-abs-already-exists.md` — BLOCKER (ADR-102 stop-barrier, verified)
- `MIG-M2.5-RESCOPE-abs-gap-audit.md` — RESCOPE ([INFERENCE] по паттерну серии — resolution; строка «Resolves» не верифицирована)
- `MIG-M2.5-BIF-BLOCKER-target-mismatch.md` — BLOCKER **без видимого парного resolution-дока**
- **Вывод: PARTIAL — ABS-ветка вероятно RESOLVED [INFERENCE], BIF-ветка ОТКРЫТА (OPEN POINT).**
- Важно [ФАКТ]: `MIG-M2.8-acceptance.md` утверждает «**M2 core cycle (M2.1–M2.7) is closed and on main**» — это покрывает и M2.5; противоречие BIF-BLOCKER ↔ acceptance разрешить при A2 (какой док позднее/авторитетнее).

**M2.7 platform chain → shared-libs/platform (I-API/B-EMI смежно):**
- `MIG-M2.7-BLOCKER-platform-target-mismatch.md` — BLOCKER; `MIG-M2.7-RESCOPE-consume-from-shared-libs.md` — RESCOPE-resolution; [ФАКТ] «Resolves the MIG-M2.7 blocker (PR #612/IL-370) per operator decision»
- **Вывод: RESOLVED.**

**M2.8 frontend/roster/web chain (12 файлов) → H-CRM/H-SUPPORT/I-API (web-слой):**
- `MIG-M2.8-PRE-*` (collision-matrix, frontend-roster-audit, shell-inventory, tompayment-provenance, verify-resolution) — PRE-audits
- `MIG-M2.8-AWAITS-OPERATOR-decision-brief.md` — AWAITS; `MIG-M2.8-DECISION-2026-06-23.md` — DECISION, но [ФАКТ] внутри: «**AWAITS OPERATOR #3 — canonical web target = banxe-ui/apps/web-next**» + существует отдельный `AWAITS-OPERATOR-3-web-next-unify.md`
- `MIG-M2.8-roster-c-*` (gate-resolution, split-spec), `scaffold-execution-plan`, `preflight-readiness`, `acceptance`
- **Вывод: ACCEPTANCE по циклу M2.1–M2.7 зафиксирован, но M2.8-web-ветка = AWAITS (operator #3, web-next unify) → PARTIAL.**

**RESIDUAL / SAR / SRP / прочие:**
- `MIG-RESIDUAL-GENUINE-GAP-REGISTER-2026-06-25.md` — DECISION-stage definitive register [ФАКТ] — ACCEPTANCE-класс (residual genuine-gaps = 0 по EMI-IMPL-STATE)
- `MIG-SAR-MODULES-FINALIZATION-2026-06-25.md` — [ФАКТ] конвертирует записи регистра в финальные **DROP/RESCOPE** вердикты — ACCEPTANCE-класс
- `MIG-SRP-blocker-banxe-platform.md` — BLOCKER-report с [ФАКТ] «Decision: NO scaffold — canonical SRP surface …» — RESOLVED-by-decision
- `MIG-coverage-acceptance.md` — ACCEPTANCE (migration coverage) [ФАКТ существования; контент — проверить при A2]
- `MIG-login-history-blocker-banxe-platform.md` — BLOCKER, resolution-док не идентифицирован — **ОТКРЫТ (OPEN POINT)**
- `MIG-M1.8-acceptance.md` — [ФАКТ] «M1.x audit cycle — closed substeps» — M1-цикл ACCEPTANCE.

## 5. Привязка MIG ↔ BUILD-SPEC (aggregate)

- **D-GL:** chains: ABS-posting (RESOLVED), M2.5 (PARTIAL: BIF открыт). → aggregate: **PARTIAL с uplift-кандидатом до READY** после подтверждения M2.5-BIF (или примата M2.8-acceptance).
- **B-EMI:** chains: ABS-posting (RESOLVED), M2.5 (PARTIAL), M2.0 mapping. → **PARTIAL→READY-кандидат** (те же условия + code-check A2).
- **A-IDV/A-KYC/A-KYB:** chain: M2.3 (RESOLVED, I-27 carve-out). → **миграционно чисто; READY-кандидаты** после code-check; carve-out обязателен к соблюдению.
- **M-GATEWAY:** chains: M2.4 (RESOLVED по под-веткам), M2.7 (RESOLVED). → **миграционно чисто; PARTIAL** остаётся только из-за rails-ключей (ED-01/02) и OD-R07 — не из-за MIG.
- **H-CRM/H-SUPPORT/I-API (web-слой):** chain: M2.8 (AWAITS #3 web-next). → **PARTIAL до операторского решения #3.**
- **L-BI:** chain: M1.x (ACCEPTANCE). → миграционно чисто.
- **Остальные спеки (B-PRICING, D-FEE, D-FIN, E-TREASURY, G-DEVICE, G-RT, M-SANDBOX, F-FATCA):** прямых MIG-цепочек в baseline не идентифицировано → MIG-нейтральны; их статус определяется только code/target-model-check A2.

## 6. EMI-CANON-COVERAGE hook

Новый snapshot EMI-CANON-COVERAGE должен выпускаться после подтверждения при A2: (1) ABS-posting/M2.3/M2.4/M2.7 resolutions (двигают coverage-записи D-GL/B-EMI/identity/M-GATEWAY в CONFIRMED), (2) развязки M2.5-BIF противоречия, (3) операторского решения M2.8-#3 (web-строки coverage). До этого snapshot 2026-06-06 помечается outdated со ссылкой на этот документ.

## 7. Summary / Next steps (для A2)

**Chains: 8.** RESOLVED/ACCEPTANCE: **5** (ABS-posting, M2.3, M2.4, M2.7, M1.x + RESIDUAL/SAR/SRP-класс). PARTIAL: **2** (M2.5 — BIF-ветка; M2.8 — AWAITS #3). ОТКРЫТО вне цепочек: **1** (login-history blocker).
**Uplift-кандидаты в READY (по MIG-измерению):** D-GL, B-EMI, A-IDV/A-KYC/A-KYB, M-GATEWAY (у последнего остаток — ключи, не MIG). **Остаются PARTIAL:** web-слой (H-*/I-API) до решения #3.
**Следующий A2 change-set:** «FLOOR2-MIG-STATUS-MATRIX EXECUTION» — верификация трёх [INFERENCE]-строк (M2.4-корень, M2.5-RESCOPE, coverage-acceptance контент), развязка BIF↔acceptance противоречия, затем per-spec code-check по плану и refresh coverage.

## 8. OPEN POINTS

- M2.5-BIF-BLOCKER: resolution-док не найден И противоречит M2.8-acceptance («M2.1–M2.7 closed») — нужен авторитетный вердикт при A2.
- `MIG-login-history-blocker-banxe-platform.md` — открытый BLOCKER без привязки к спеке (ближайшая — A-IDV/auth; [INFERENCE]).
- M2.4-корневой RESCOPE и M2.5-RESCOPE: строка «Resolves…» не грепалась — [INFERENCE] по паттерну, верифицировать.
- Привязка M2.7 → I-API/B-EMI — [INFERENCE]; RESIDUAL/SAR/SRP → governance/risk элементы без прямой спеки.
- `MIG-coverage-acceptance.md` — контент не читался (только существование).
- AWAITS operator: M2.8-#3 (web-next unify) — операторское решение, вне полномочий фабрики.

## 9. Статус

**Status: PLAN + SNAPSHOT, DRAFT, NOT FOR MERGE.**
Ссылки: `FLOOR2-BUILD-SPECS-INSTALLATION-AUDIT-PLAN-2026-07-19.md` · `EMI-CANON-COVERAGE-10-REPOS-2026-06-06.md` · `EMI-CANON-COVERAGE-COMPLETE-2026-06-06.md` · `FULL-PROJECT-INSTALLATION-AUDIT-2026-06-21.md` · `PHASE-3-SSOT-CONFORMANCE-2026-07-05.md`.
