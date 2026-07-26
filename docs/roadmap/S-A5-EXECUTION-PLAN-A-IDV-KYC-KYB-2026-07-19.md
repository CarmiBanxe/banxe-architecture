# S-A5 EXECUTION PLAN — Identity cluster A-IDV / A-KYC / A-KYB — 2026-07-19

**Status: EXECUTION PLAN ONLY, DRAFT, NOT FOR MERGE** · ветка `agent/factory/bank-operating-model/20260718` · producer: factory sandbox terminal
Первый S2.1-шаг: один BUILD-SPEC кластер, одна MIG-цепочка (M2.3), один спринт (S-A5).

## 1. Цель

S-A5 поднимает кластер A-IDV/A-KYC/A-KYB с «READY-кандидатов» до формального **READY** на floor-2: подтвердить, что (а) код реально установлен и соответствует BUILD-SPEC, (б) цепочка MIG-M2.3 (identity/auth) закрыта на уровне, достаточном для READY, (в) I-27 carve-out (KYC/KYB/AML-периметр) выполнен фактически, без скрытых зависимостей.

## 2. Scope

**In scope:** A-IDV / A-KYC / A-KYB — по каждому: code installation audit + target-model conformance (identity slice) + M2.3-часть; проверка I-27 carve-out в коде/конфиге; login-history — только в объёме identity-кластера.
**Out of scope:** изменения MASTER-ROADMAP/BANK-SPRINT-PLAN (R2/S2 EXECUTION); другие BUILD-SPEC (D-GL, B-EMI, M-GATEWAY…); физические изменения MIG-файлов (только чтение); любой cross-repo write в banxe-emi-stack (по спекам — отдельное operator-authorized действие).

## 3. Inputs (read-only; изменение любого из них в рамках S-A5 EXECUTION PLAN запрещено)

- `FULL-BANK-INSTALLATION-AUDIT-PLAN-2026-07-19.md` (floor-2 tile) · `FLOOR2-BUILD-SPECS-INSTALLATION-AUDIT-PLAN-2026-07-19.md` (§4: A-IDV/A-KYC/A-KYB) · `FLOOR2-MIG-STATUS-MATRIX-2026-07-19.md` (§4 M2.3, §5) · `output/audit-FLOOR2-MIG-STATUS-SNAPSHOT-20260719T011601.txt` · `BANK-SPRINT-PLAN-EXECUTION-DRAFT-2026-07-18.md` (S-A5) · `S2-FLOOR2-SPRINT-PLAN-UPDATE-PLAN-2026-07-19.md` (§4 S-A5).
- Spec/impl-файлы [ФАКТ, верифицировано grep'ом]: `docs/architecture/A-IDV-BUILD-SPEC.md`, `A-KYC-BUILD-SPEC.md`, `A-KYB-BUILD-SPEC.md` — все три «spec-plane only» (ADR-115/116/117): runtime → `CarmiBanxe/banxe-emi-stack`; общий контракт-порт: `docs/refactor/legacy/kyc-provider-port-CONTRACT-SPEC-2026-06-06.md` (`KYCProviderPort`: startSession/getStatus/handleWebhook/changeLevel; SumSub primary + fallback; DLQ/retry/HMAC; ADR-102 REUSE — не переизобретать).
- Login-history: `docs/migration/MIG-login-history-blocker-banxe-platform.md`.
- MIG-M2.3: `MIG-M2.3-BLOCKER-identity-auth-already-exists.md`, `MIG-M2.3-RESCOPE-identity-auth-gap-audit.md`.

## 4. Task list

**Блок 1 — Code installation audit (banxe-emi-stack, read-only):**
- A-IDV: найти impl по спеке — консьюмер `KYCProviderPort` (кандидаты [ФАКТ прежних аудитов]: `services/kyc/` eKYC, Ballerine `infra/ballerine/`, `sumsub_http_stub.py`); проверить компоненты pipeline/webhook/audit из спеки §DoD; evidence: paths + sha + config-пункты.
- A-KYC: аналогично — оркестрация поверх того же порта (спека прямо: «does NOT reimplement»); проверить отсутствие дубля порта (ADR-102).
- A-KYB: аналогично — `kyb_onboarding` (REAL по EMI-IMPL-STATE); проверить запреты спеки: no in-house registry scraping, no raw-PII persistence, borderline → MLRO HITL.
- Expected output: mini-report `docs/audit/spec-audits/A-IDENTITY-CLUSTER-INSTALL-AUDIT-<date>.md` (evidence-таблица по трём спекам).

**Блок 2 — Target-model conformance (identity slice):**
- Сверить с `BANK-OPERATING-MODEL-FOUR-FLOORS` и `TARGET-MODEL-CONFORMANCE-2026-06-25` (только 06-25); проверить отсутствие «старых» identity/IDV путей, противоречащих carve-out (legacy `bkyc`/`binancekyc` — PARKED-by-canon, наличие = норма, использование = нарушение).
- Expected output: conformance-раздел в mini-report.

**Блок 3 — MIG-M2.3 alignment:**
- Перечитать BLOCKER+RESCOPE полностью; [ФАКТ] RESCOPE «Resolves the MIG-M2.3 blocker … per pre-authorised operator decision A. KYC/KYB/AML carve-out (I-27)» — проверить, что resolution отражён в коде/конфиге (carve-out границы = фактические границы модулей); расхождения → OPEN POINT.
- Expected output: M2.3-verdict строка в mini-report (consistent / drift-list).

**Блок 4 — Login-history (identity scope):**
- [ФАКТ, верифицировано при подготовке этого плана] `MIG-login-history-blocker-banxe-platform.md` — «**Decision: NO scaffold** — canonical login-history surface already exists (covered) AND target is a frontend client (target-mismatch)» — блокер **RESOLVED-by-decision** (симметрично SRP, IL-434/#678).
- Задача сжимается до: подтвердить canonical surface в emi-stack (одна grep-проверка) и **передать кандидат-обновление в FLOOR2-MIG-STATUS-MATRIX** (строка «login-history ОТКРЫТ» → «RESOLVED-by-decision») — правка матрицы = отдельный change-set, не этот.
- Expected output: одна строка вердикта в mini-report; backlog-перенос в S2.2 не требуется, если подтверждение чистое.

## 5. Acceptance criteria (READY)

Per spec (каждый из трёх): (1) repo-носитель найден и задокументирован (paths+sha); (2) code audit позитивен ИЛИ явный список проблем; (3) M2.3-consistency подтверждена без блокеров запуска; (4) I-27 carve-out отражён в коде/конфиге (или явный OPEN POINT).
Per cluster: mini-report позволяет честно поднять status target «READY candidate»→«READY» в FLOOR2-BUILD-SPECS-INSTALLATION-AUDIT-PLAN (обновление — будущим R2/S2-шагом); все проблемы оформлены как OPEN POINTS/risks; login-history-вердикт зафиксирован.

## 6. Риски и ограничения

- Риск: текст M2.3-RESCOPE может расходиться с фактическим кодом (legacy-дрейф) — ловится Блоком 3.
- Риск: SumSub-адаптер credentials-gated (ED-03) — READY фиксируется по «wired to port, credentials pending», не по live-вызову; отметить явно.
- Риск: login-history может иметь остаточные нити во floor-3 governance (audit trail) — Блок 4 проверяет только identity-scope.
- Ограничение: никаких изменений кода/roadmap/sprint/MIG в рамках этого плана — только чтение, планирование, mini-report.

## 7. Связь с R2/S2

Результаты S-A5 execution: (а) кормят **R2** — подтверждение READY для WS9-блока «Identity/IDV/KYC/KYB» (R2.1, первый uplift MASTER-ROADMAP); (б) кормят **S2** — статус S-A5 в BANK-SPRINT-PLAN меняется на «uplift delivered» + login-history снимается из S2.2. Документ — мост между планами (A2/R2/S2 PREP) и будущими EXECUTION change-set'ами; сами правки — отдельными коммитами.

## 8. OPEN POINTS

- Точные paths/sha impl-компонентов — определяются только при execution (Блок 1), в плане не изобретаются.
- Полный текст M2.3-RESCOPE не читался целиком (только resolution-строка) — full-read в Блоке 3.
- Подтверждение canonical login-history surface в emi-stack — одна проверка Блока 4.
- Ballerine vs SumSub как primary в фактическом конфиге (спека: SumSub primary; код: Ballerine IN-REPO) — сверить при Блоке 1, расхождение возможно.
- Связь identity-audit с floor-3/4 (HITL MLRO для KYB borderline) — фиксация, не расширение scope.

## 9. Статус

**Status: EXECUTION PLAN ONLY, DRAFT, NOT FOR MERGE.**
Ссылки: `FULL-BANK-INSTALLATION-AUDIT-PLAN-2026-07-19.md` · `BANK-ROADMAP-AND-SPRINT-EDIT-PLAN-2026-07-19.md` · `BANK-SPRINT-PLAN-EXECUTION-DRAFT-2026-07-18.md` · `FLOOR2-BUILD-SPECS-INSTALLATION-AUDIT-PLAN-2026-07-19.md` · `FLOOR2-MIG-STATUS-MATRIX-2026-07-19.md` · `R2-FLOOR2-MASTER-ROADMAP-UPDATE-PLAN-2026-07-19.md` · `S2-FLOOR2-SPRINT-PLAN-UPDATE-PLAN-2026-07-19.md`.
