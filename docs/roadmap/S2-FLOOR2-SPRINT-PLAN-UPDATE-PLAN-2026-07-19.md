# S2 — FLOOR-2 SPRINT-PLAN UPDATE PLAN — 2026-07-19

**Status: PLAN ONLY, DRAFT, NOT FOR MERGE** · ветка `agent/factory/bank-operating-model/20260718` · producer: factory sandbox terminal
Sprint-планы этим документом **не редактируются** — это план будущего S2 change-set'а, парный к R2 PREP.

## 1. Цель

Синхронизировать спринты (`BANK-SPRINT-PLAN-EXECUTION-DRAFT` + engine/agent-fleet планы) с verified-статусом floor-2 (A2): переориентировать формулировки с «future features / строительство» на (а) uplift READY-кандидатов через per-spec code-check, (б) закрытие остаточных MIG-open points (M2.5-BIF, login-history), (в) подготовку prerequisites для R2-изменений MASTER-ROADMAP.

## 2. Inputs

- `docs/roadmap/BANK-SPRINT-PLAN-EXECUTION-DRAFT-2026-07-18.md` — S-A0..S-A13; floor-2-релевантные: S-A5 (compliance/KYC), S-A6 (CASS/ledger), S-A7 (rails), S-A8 (CFO/reporting), S-A10/S-A11 (web/API), S-A12 (security/audit); floor-1-связка: S-A4/S-A10.
- `docs/agent-engine-dossier/SPRINT-PLAN.md` — engine Sprint-A/B (A1..A5 merged; B1..B9, B8/B9 blocked ADR-133).
- `docs/governance/AGENT-FLEET-SPRINT-CD.md`, `docs/governance/AGENT-FLEET-CLEANUP-SPRINT-D.md` — agent-fleet серии C/D.
- `BANK-ROADMAP-AND-SPRINT-EDIT-PLAN-2026-07-19.md` §Floor-2 · `FULL-BANK-INSTALLATION-AUDIT-PLAN-2026-07-19.md` (floor-2 tile) · `FLOOR2-BUILD-SPECS-INSTALLATION-AUDIT-PLAN-2026-07-19.md` · `FLOOR2-MIG-STATUS-MATRIX-2026-07-19.md` · `R2-FLOOR2-MASTER-ROADMAP-UPDATE-PLAN-2026-07-19.md`.

## 3. FLOOR2 Sprint Focus Map

| Блок | Состав | Цель спринтов |
|---|---|---|
| READY-candidates | A-IDV/A-KYC/A-KYB (I-27 carve-out); L-BI, E-TREASURY, G-RT, M-SANDBOX, F-FATCA | **audit/uplift**: per-spec code-check + evidence → формальный READY |
| PARTIAL uplift | D-GL/B-EMI | **blockers**: вердикт M2.5-BIF → затем code-check → READY |
| PARTIAL не-MIG | M-GATEWAY (ключи/OD-R07); H-CRM/H-SUPPORT/I-API (AWAITS #3) | **governance/ext**: единая точка снятия каждого гейта; спринт-задачи не плодить до решения |
| Code-check-dependent | B-PRICING, G-DEVICE | **code-check**: найти repo-носитель или зафиксировать GAP |
| MIG-open points | M2.5-BIF противоречие; login-history blocker; coverage-acceptance контент | **blockers/audit**: вердикты + чтение, вход для нового coverage-snapshot |

## 4. Маппинг S-A\* спринтов → FLOOR2 задачи (current → proposed под S2)

- **S-A5 (Compliance overlay + L2 + KYC live):** current — «wiring KYC/санкции + overlay»; proposed — добавить под-задачу «per-spec code-check A-IDV/A-KYC/A-KYB (MIG-чисты, M2.3 resolved) + I-27 carve-out проверка»; **status target: "A-IDV/A-KYC/A-KYB uplift to READY"**.
- **S-A6 (CASS/safeguarding closure):** current — recon live + FIN060 dry-run; proposed — переформулировать ledger-часть в «activate+audit» (код REAL), добавить «resolve M2.5-BIF (verdict) + code-check D-GL/B-EMI»; **status target: "D-GL/B-EMI uplift to READY; BIF verdict recorded"**.
- **S-A7 (Rails activation):** current — hardening+ключи+switch-on; proposed — убрать миграционные формулировки (M2.4/M2.7 resolved), оставить только ED-01/02 + OD-R07; **status target: "controlled-live FPS/SEPA; MIG-долг явно = 0"**.
- **S-A8 (CFO/reporting):** current — finance-агенты + RegData; proposed — привязать D-FIN/D-FEE code-check и FIN060-live как операторский цикл; **status target: "D-FIN/D-FEE audited; первый live FIN060"**.
- **S-A10 (HII/web минимум):** current — минимальная клиентская поверхность; proposed — собрать web-задачи под единый гейт **AWAITS #3** (H-CRM/H-SUPPORT-связка), floor-1 минимум не блокируется гейтом; **status target: "operator decision #3 executed → web-задачи разблокированы"**.
- **S-A11 (API/BaaS exposure):** current — внешняя поверхность [PX]; proposed — добавить I-API code-check (repo-носитель!) как предусловие любой экспозиции; **status target: "I-API carrier confirmed or GAP recorded"**.
- **S-A12 (Security/audit closure):** current — GAP-082/090 + дашборды; proposed — добавить «per-spec audit-серия для neutral specs (L-BI/E-TREASURY/G-RT/M-SANDBOX/F-FATCA/G-DEVICE/B-PRICING)» либо выделить в отдельный audit-спринт S-A12.1; **status target: "все neutral specs имеют verdict READY/GAP"**.
- **login-history blocker** — не ложится ни в один существующий S-A\*: предлагается микро-задача в S-A5 (auth-периметр) со **status target: "spec-or-deprecation decision"** [INFERENCE-привязка, OPEN POINT].

## 5. Agent/engine SPRINT-PLAN alignment

- **Engine SPRINT-PLAN (dossier):** Sprint-B B8/B9 (Temporal saga) остаются blocked ADR-133 — не тянуть в S2; синхронизация: engine-задача «lineage/Explorer-потребители» (Q3/Q5 по floor-1/2 evidence) согласуется с S-A12-audit-серией. Переориентация не требуется — только cross-ref.
- **AGENT-FLEET-SPRINT-CD / CLEANUP-SPRINT-D:** синхронизировать волны активации паспортов с floor-2 uplift'ом: compliance-агенты (AML/sanctions/tx-monitor) — под S-A5-uplift; finance-агенты — под S-A8; web/CRM-агенты — под гейт AWAITS #3; cleanup-задачи серии D — включить guardrails-проверку M2.5/login-history артефактов (не удалять до вердиктов, I-24/PARKED-by-canon). Всё — отдельными change-set'ами.

## 6. S2 Priorities

- **S2.1:** uplift READY-кандидатов (A-IDV/KYC/KYB + L-BI/E-TREASURY/G-RT/M-SANDBOX/F-FATCA) до формального READY: per-spec code-check + evidence-фиксация (audit-doc + IL).
- **S2.2:** вердикты по M2.5-BIF (развязка противоречия с M2.8-acceptance) и login-history (spec-or-deprecation) — миграционно-спековый долг → 0.
- **S2.3:** подготовить операторский пакет decision #3 (web-next unify) и после решения обновить web-спринты (S-A10/S-A11 связка H-*/I-API).
- **S2.4:** новый EMI-CANON-COVERAGE snapshot — после подтверждения readiness групп S2.1/S2.2 (условия — в MIG-matrix §6).

## 7. Связь с R2

S2-outcomes = prerequisites R2: R2.1 (закрепление READY в MASTER-ROADMAP) требует S2.1-evidence; R2-risk-строки (BIF/login-history) снимаются S2.2; R2-web-блок редактируется только после S2.3 (#3 executed); coverage-строки roadmap — после S2.4. Порядок фактических коммитов: **S2 execution → R2 edit → (при необходимости) повторный S2-тюнинг** — каждый отдельным change-set'ом.

## 8. OPEN POINTS

- Привязка login-history к S-A5 — [INFERENCE] (auth-периметр); альтернатива — отдельная микро-задача вне S-A\*.
- AWAITS OPERATOR #3 — операторское решение; до него web-распределение задач между S-A10/S-A11 условно.
- Пересечение с floor-3/4 governance: gateway/web-экспозиция затрагивает HITL/security-гейты (S-A12, HITL-013-класс) — координация при фактическом S2.
- Разбиение S-A12 vs новый S-A12.1 (audit-спринт neutral specs) — решить при S2 execution по объёму.
- Engine B8/B9 (ADR-133) — вне S2, но упоминание в sprint-плане потребует сноски «not-S2».
- Repo-носители B-PRICING/G-DEVICE/I-API — до code-check распределение их задач по спринтам условно.

## 9. Статус

**Status: PLAN ONLY, DRAFT, NOT FOR MERGE.**
Ссылки: `BANK-SPRINT-PLAN-EXECUTION-DRAFT-2026-07-18.md` · `docs/agent-engine-dossier/SPRINT-PLAN.md` · `docs/governance/AGENT-FLEET-SPRINT-CD.md` · `docs/governance/AGENT-FLEET-CLEANUP-SPRINT-D.md` · `BANK-ROADMAP-AND-SPRINT-EDIT-PLAN-2026-07-19.md` · `FULL-BANK-INSTALLATION-AUDIT-PLAN-2026-07-19.md` · `FLOOR2-BUILD-SPECS-INSTALLATION-AUDIT-PLAN-2026-07-19.md` · `FLOOR2-MIG-STATUS-MATRIX-2026-07-19.md` · `R2-FLOOR2-MASTER-ROADMAP-UPDATE-PLAN-2026-07-19.md`.
