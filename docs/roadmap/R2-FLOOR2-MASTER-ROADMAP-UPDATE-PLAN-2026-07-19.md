# R2 — FLOOR-2 MASTER-ROADMAP UPDATE PLAN — 2026-07-19

**Status: PLAN ONLY, DRAFT, NOT FOR MERGE** · ветка `agent/factory/bank-operating-model/20260718` · producer: factory sandbox terminal
Roadmap-файлы этим документом **не редактируются** — это operator-friendly план будущего R2 change-set'а.

## 1. Цель

Floor-2 = операционный слой (EMI core / payments / accounts / reconciliation; trading — смежный интерфейс) с 18 BUILD-SPEC (17 + F-FATCA); текущая плитка — **PARTIAL-READY**. Цель R2 PREP: спроецировать результаты A2 (per-spec plan + verified MIG matrix + snapshot) на `BANK-MASTER-ROADMAP`, определив по-блочно current view → factual view → proposed change, без фактического редактирования roadmap.

## 2. Inputs (связка R2 ← A2)

- `docs/roadmap/BANK-MASTER-ROADMAP-TO-100-PERCENT-LAUNCH-READINESS-DRAFT.md` — floor-2 покрывают: §4 WS7 (safeguarding/ledger/recon), WS8 (payments/rails), WS9 (KYC/KYB), WS10 (CFO/reporting), WS12/WS13 (UX/API-поверхность), §5 спринты S-A5..S-A8/S-A11, §7 ED-реестр, §8 UNK.
- `docs/roadmap/BANK-ROADMAP-AND-SPRINT-EDIT-PLAN-2026-07-19.md` §«Floor 2 – Operational alignment» (R2/S2/A2 определены там).
- `docs/audit/FULL-BANK-INSTALLATION-AUDIT-PLAN-2026-07-19.md` (floor-2 tile, PARTIAL-READY).
- `docs/audit/FLOOR2-BUILD-SPECS-INSTALLATION-AUDIT-PLAN-2026-07-19.md` (per-spec задачи).
- `docs/audit/FLOOR2-MIG-STATUS-MATRIX-2026-07-19.md` (verified статусы 8 цепочек).
- A2 snapshot: `output/audit-FLOOR2-MIG-STATUS-SNAPSHOT-20260719T011601.txt` (13.8K, read-only, подтверждён на диске).

## 3. Аггрегированный статус floor-2 (по A2)

- **READY-кандидаты (миграционно чисты; остаётся code-check):** A-IDV, A-KYC, A-KYB (M2.3 resolved, I-27 carve-out обязателен); L-BI (M1.x acceptance); F-FATCA, G-RT, E-TREASURY, M-SANDBOX (MIG-нейтральны, код REAL по EMI-IMPL-STATE).
- **PARTIAL с понятным условием uplift:** D-GL, B-EMI → READY после развязки M2.5-BIF (единственный оставшийся MIG-узел ledger-контура).
- **Устойчиво PARTIAL/GAP по не-MIG причинам:** M-GATEWAY (MIG-чист; остаток = ключи ED-01/02 + OD-R07); H-CRM/H-SUPPORT/I-API (AWAITS OPERATOR #3 web-next unify).
- **MIG-нейтральные с неподтверждённым носителем кода:** B-PRICING, G-DEVICE (+частично H-CRM, I-API) — статус определит только code-check A2.

Сводно: после MIG-matrix **floor-2 заметно ближе к READY, чем выглядел** — из 8 цепочек 5 закрыты операторскими решениями ещё в июне, и «миграционный долг» сжался до одного противоречия (M2.5-BIF vs M2.8-acceptance) и одного одиночного блокера (login-history). Крупные остаточные риски — не миграции, а внешние ключи (ED-01/02), операторское решение #3 по web и отсутствие per-spec code-check.

## 4. Маппинг BUILD-SPEC → блоки MASTER-ROADMAP

| Roadmap-блок (current view) | BUILD-SPEC | Factual view (A2) |
|---|---|---|
| WS7 «Safeguarding/Ledger/Recon» — ongoing/activation | D-GL, B-EMI | PARTIAL→READY-кандидат (усл.: M2.5-BIF) |
| WS9 «KYC/KYB/Onboarding» — LC, Sumsub-gated | A-IDV, A-KYC, A-KYB | READY-кандидат (MIG чист; ext = ED-03) |
| WS8 «Payments/Rails» — LC, ключи | M-GATEWAY (+D-FEE смежно) | PARTIAL (только ключи/OD-R07; MIG чист) |
| WS12/WS13 «UX/API-поверхность» — LC-min/[PX] | H-CRM, H-SUPPORT, I-API | PARTIAL (AWAITS #3) |
| WS10 «CFO/Reporting» — PL | D-FIN, D-FEE | PARTIAL (FIN060-live = операторский цикл) |
| WS10-смежно/WS7 | E-TREASURY | READY-кандидат |
| WS14/sandbox-контур | M-SANDBOX, G-RT, G-DEVICE | READY-кандидаты / G-DEVICE — code-check |
| Lane 2/PX аналитика | L-BI, B-PRICING | L-BI READY-кандидат; B-PRICING — code-check |
| Регуляторка | F-FATCA | READY-кандидат |

Current-view статусы в MASTER-ROADMAP местами «future/строительство» — фактура A2 показывает «activation/audit» (совпадает с выводом EDIT-PLAN §Floor-2 Observations).

## 5. Предлагаемые изменения (PLAN ONLY, описательно)

- **Section «EMI core / D-GL / B-EMI»:** current: WS7 ongoing + S-A6 «closure»; factual: код REAL, ABS-posting resolved, остаток M2.5-BIF; proposed: пометить «partially implemented (BUILD-SPEC D-GL/B-EMI; MIG: ABS-posting RESOLVED, M2.5-BIF pending)», перевести формулировки S-A6-блока из «строить» в «activate+audit», BIF — в явный roadmap-risk.
- **Section «Identity / IDV / KYC / KYB»:** current: WS9 LC с ext-гейтом; factual: MIG чист (M2.3 resolved, I-27 carve-out); proposed: пометить «migration-clean, READY after code-check», uplift в ранний milestone (кандидат на первый R2.1-фикс), carve-out I-27 — обязательная сноска.
- **Section «Open Banking / Gateway»:** current: WS8 ждёт ключи; factual: M2.4/M2.7 resolved — блокеров-миграций нет; proposed: явно разделить «MIG-долг = 0» и «внешний долг = ED-01/02 + OD-R07», чтобы roadmap не переоценивал объём работ.
- **Section «Web / CRM / Support / API»:** current: WS12-min LC / WS13 PX; factual: M2.8 AWAITS #3; proposed: зафиксировать зависимость всех web-задач от операторского решения #3 (единая точка), не плодить под-задачи до него.
- **Section «Neutral specs (L-BI, E-TREASURY, G-RT, M-SANDBOX, F-FATCA, B-PRICING, G-DEVICE, D-FEE, D-FIN)»:** proposed: пометить «MIG-neutral; статус определяется per-spec code-check A2»; для B-PRICING/G-DEVICE — «repo-носитель не подтверждён» как отдельная строка риска.

## 6. Приоритеты (R2 focus)

- **R2.1:** закрепить READY-кандидатов: A-IDV/A-KYC/A-KYB (+D-GL/B-EMI при решении M2.5-BIF) — максимальный uplift за минимальные действия.
- **R2.2:** зафиксировать GAP'ы M-GATEWAY (ключи/OD-R07) и web-слоя (AWAITS #3) как внешне-гейтованные, с единственной точкой снятия каждого.
- **R2.3:** перенести MIG-open points (M2.5-BIF противоречие, login-history, непрогрепанные «Resolves»-строки) в явные roadmap-risks с владельцами (operator/A2).

## 7. Связь с S2 (SPRINT-PLAN)

Будущий S2 (отдельный документ/коммит): S-A5/S-A6 — включить задачи «code-check READY-кандидатов» (uplift-подтверждение); отдельная задача «M2.5-BIF verdict» + «login-history: spec-or-deprecation decision»; web-задачи S-A10/S-A11 — собрать под гейт AWAITS #3; S-A7 — оставить только ключи/OD-R07 (миграционные формулировки убрать как выполненные).

## 8. OPEN POINTS (checklist для R2/S2)

- BIF-противоречие: `MIG-M2.5-BIF-BLOCKER` vs «M2.1–M2.7 closed» (M2.8-acceptance) — нужен авторитетный вердикт.
- `login-history` blocker без спеки — spec-or-deprecation decision.
- `MIG-coverage-acceptance.md` — контент не читан; может менять coverage-строки roadmap.
- AWAITS OPERATOR #3 (web-next unify) — операторское, вне полномочий фабрики.
- Нумерация этажей (репо-канон FLOOR 3 vs операторская Floor 2) — влияет на привязку epics при фактическом R2-редактировании; закрепить при ратификации.
- Непрогрепанные «Resolves»-строки M2.4-корня и M2.5-RESCOPE ([INFERENCE] в matrix §4).

## 9. Статус

**Status: PLAN ONLY, DRAFT, NOT FOR MERGE.**
Ссылки: `BANK-MASTER-ROADMAP-TO-100-PERCENT-LAUNCH-READINESS-DRAFT.md` · `BANK-ROADMAP-AND-SPRINT-EDIT-PLAN-2026-07-19.md` · `FULL-BANK-INSTALLATION-AUDIT-PLAN-2026-07-19.md` · `FLOOR2-BUILD-SPECS-INSTALLATION-AUDIT-PLAN-2026-07-19.md` · `FLOOR2-MIG-STATUS-MATRIX-2026-07-19.md` · `output/audit-FLOOR2-MIG-STATUS-SNAPSHOT-20260719T011601.txt`.
