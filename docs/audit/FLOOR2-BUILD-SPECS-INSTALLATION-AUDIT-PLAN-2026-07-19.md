# FLOOR-2 BUILD-SPECS — PER-SPEC INSTALLATION AUDIT PLAN — 2026-07-19

**Status: PLAN ONLY, DRAFT, NOT FOR MERGE** · ветка `agent/factory/bank-operating-model/20260718` · producer: factory sandbox terminal

## 1. Цель

Floor-2 = операционный слой банка (EMI core / payments / accounts / reconciliation; trading — смежный интерфейс) с 17 BUILD-SPEC'ами + F-FATCA. Текущий статус плитки — **PARTIAL-READY** (`FULL-BANK-INSTALLATION-AUDIT-PLAN-2026-07-19.md`): core-реализация REAL (EMI-IMPL-STATE), но **ни один BUILD-SPEC не имеет свежего per-spec installation audit**. Этот документ — план per-spec audit'а для всех 18 спек и связанных MIG/EMI-репо; исполнение — последующими change-set'ами (A2-серия).

## 2. Scope

**18 спек** (`docs/architecture/*-BUILD-SPEC.md` + `docs/regulatory/`): A-IDV, A-KYC, A-KYB, B-EMI, B-PRICING, D-FEE, D-FIN, D-GL, E-TREASURY, G-DEVICE, G-RT, H-CRM, H-SUPPORT, I-API, L-BI, M-GATEWAY, M-SANDBOX, F-FATCA.
**External repos:** перечень покрытых репо — в `EMI-CANON-COVERAGE-10-REPOS-2026-06-06.md` / `EMI-CANON-COVERAGE-COMPLETE-2026-06-06.md` (здесь не дублируется); первичный кодовый носитель операционного слоя — banxe-emi-stack.
**Связанные миграции:** `docs/migration/` (80 файлов): серия M1.x (advisory surface), серия M2.x (BLOCKER/RESCOPE/COVERED: M2.0 mapping, M2.3 identity-auth, M2.4/M2.4a/ab/c open-banking/scheduled/batch payments, M2.5 ABS/BIF), `MIG-ABS-posting-BLOCKER-*`, `AWAITS-OPERATOR-3-web-next-unify.md`, EMI-IMPLEMENTATION-STATE.

## 3. Методология (reuse существующей)

База: `FEATURE-INSTALLATION-AUDIT-METHODOLOGY-2026-06-20.md`, `FEATURE-INSTALLATION-AUDIT-ROADMAP-2026-06-20.md`, `FEATURE-INSTALLATION-AUDIT-EXECUTION-ROADMAP-2026-06-21-v2.md`, `FULL-PROJECT-INSTALLATION-AUDIT-2026-06-21.md`, `PHASE-3-SSOT-CONFORMANCE-2026-07-05.md`.

**Per-spec audit (стандартный шаблон, применяется к каждой спеке):**
1. **Code check:** есть ли реализация в external репо (grep/ls по модулям спеки; вердикт IN-REPO / PARTIAL / NOT FOUND).
2. **Target-model check:** соответствие `TARGET-MODEL-CONFORMANCE-2026-06-25.md` (только 06-25; 06-24 superseded).
3. **MIG check:** закрыты ли связанные MIG BLOCKER/RESCOPE (COVERED/ACCEPTANCE = ок; BLOCKER/AWAITS = не installed).
4. **Fixation:** результат = audit-doc `docs/audit/spec-audits/<SPEC>-INSTALL-AUDIT-<date>.md` + IL-shard entry + статус READY/PARTIAL/GAP в плитке floor-2.

## 4. BUILD-SPEC → Audit Tasks

Для каждой спеки задачи одинаковы (шаблон §3: code check → target-model check → MIG check → fixation + обновление EMI-CANON-COVERAGE entry и PHASE-3-SSOT секции). Ниже — только специфика:

- **A-IDV:** audit-docs: EMI-CANON-COVERAGE-*, FULL-PROJECT-INSTALLATION-AUDIT; MIG: M2.3 identity-auth (BLOCKER+RESCOPE — открыты); status target: READY; риск: Sumsub/IDV credentials-gated (ED-03).
- **A-KYC:** те же audit-docs; MIG: M2.3; kyc-сервис REAL по EMI-IMPL-STATE; target: READY; риск: legacy bkyc/binancekyc PARKED-by-canon (I-27, не auto-delete).
- **A-KYB:** audit-docs: те же + kyb_onboarding в EMI-IMPL-STATE (REAL); MIG: M2.3-смежно; target: READY; риск: KYB-глубина [PX].
- **B-EMI:** ядро счетов/балансов; audit-docs: EMI-IMPL-STATE (ledger REAL), ADR-056/057; MIG: M2.0 mapping; target: READY.
- **B-PRICING:** audit-docs: FULL-PROJECT-INSTALLATION-AUDIT; MIG: не идентифицированы (OPEN POINT); target: PARTIAL.
- **D-FEE:** audit-docs: те же; MIG: M2.0; target: PARTIAL; риск: fee-Decimal инварианты (I-01) — обязательная проверка.
- **D-FIN:** отчётность/FIN060-смежно; audit-docs: EMI-IMPL-STATE (reporting REAL); target: PARTIAL; риск: FIN060-live цикл = GAP плитки.
- **D-GL:** audit-docs: `MIG-ABS-posting-BLOCKER-gl-service-already-exists.md` (**BLOCKER открыт**), adrs/ADR-CBS-01-payment-posting-gl; target: PARTIAL до закрытия BLOCKER.
- **E-TREASURY:** audit-docs: ADR-078 (CFO treasury-forecast port), EMI-IMPL-STATE (fx_engine REAL, FX-for-treasury COVERED); target: READY; риск: FX trading-core RESCOPE/DROP-остаток.
- **G-DEVICE:** audit-docs: FULL-PROJECT-INSTALLATION-AUDIT; MIG: не идентифицированы (OPEN POINT); target: PARTIAL.
- **G-RT:** realtime-контур; audit-docs: те же + tx_monitor REAL; target: READY.
- **H-CRM:** audit-docs: FULL-PROJECT-INSTALLATION-AUDIT; связка referral-CRM в intent-масках (ADR-049); target: PARTIAL.
- **H-SUPPORT:** audit-docs: EMI-IMPL-STATE (complaints case-prep REAL, fos_portal fenced); target: PARTIAL; риск: FOS portal access (ED-06).
- **I-API:** внешняя поверхность; audit-docs: ADR-147 (MCP registry), плитка floor-2 GAP-раздел; target: PARTIAL; риск: экспозиция только после S-A12 (security).
- **L-BI:** analytics/BI; audit-docs: FULL-PROJECT-INSTALLATION-AUDIT; MIG: M1.x advisory-surface серия; target: PARTIAL.
- **M-GATEWAY:** payment gateway; audit-docs: M2.4-серия (**BLOCKER open-banking + RESCOPE + OB-delta + M2.4a/ab/c scheduled/batch — частично COVERED**); target: PARTIAL до закрытия M2.4-остатков; риск: rails без ключей (ED-01/02), PSD2-router выбор = OD-R07.
- **M-SANDBOX:** audit-docs: ADR-096..101 (sandbox surface/portal); связка с floor-1 demo (intent_slice работает в этом контуре); target: READY.
- **F-FATCA:** audit-docs: EMI-IMPL-STATE (fatca_crs REAL); `docs/regulatory/F-FATCA-BUILD-SPEC.md`; target: READY.

## 5. Связь с MIG-*

Спека считается **installed** только когда её MIG-цепочка в COVERED/ACCEPTANCE. Идентифицированные связи: **M2.3** (identity-auth: BLOCKER+RESCOPE) → A-IDV/A-KYC/A-KYB; **M2.4-серия** (open-banking BLOCKER/RESCOPE/OB-delta; M2.4a scheduled BLOCKER; M2.4ab declare-covered; M2.4c batch COVERED) → M-GATEWAY; **M2.5** (ABS BLOCKER/RESCOPE; BIF target-mismatch BLOCKER) + **MIG-ABS-posting-BLOCKER** → D-GL/B-EMI; **M2.0** (mapping/shared-libs dedup) → B-EMI/D-FEE; **M1.x** (advisory surface) → L-BI; **AWAITS-OPERATOR-3-web-next-unify** → web-поверхность (H-*/I-API смежно). Статусная разметка в audit'ах: BLOCKER / RESCOPE / AWAITS (decision/operator) / ACCEPTANCE — migration-backlog напрямую определяет installation-status.

## 6. Связь с EMI-CANON-COVERAGE

Snapshot 2026-06-06 (10-REPOS + COMPLETE) **устарел** (>6 недель, с тех пор — Wave-мержи, ADR-158/160, S-A2-ветки). Per-spec audit обязан: либо выпустить **новый snapshot** EMI-CANON-COVERAGE (предпочтительно, один на серию A2), либо пометить старый как outdated со ссылкой на новые audit-doc'и. Ожидаемое действие по спекам: **refresh coverage** — A-IDV/A-KYC/A-KYB/B-EMI/D-GL/E-TREASURY/G-RT/M-GATEWAY/F-FATCA (код заведомо есть); **добавить новую запись** — M-SANDBOX/L-BI/H-SUPPORT (покрытие фрагментарно); **пометить GAP, если repo отсутствует** — B-PRICING/G-DEVICE/H-CRM/I-API (носитель кода не подтверждён — OPEN POINT).

## 7. Использование результатов (hook в R2/S2/A2)

- **A2:** исполнение этого плана = серия audit-change-set'ов (по одной спеке или батчами) во внешних EMI-репо + refresh EMI-CANON-COVERAGE.
- **R2:** результаты (READY/PARTIAL/GAP per spec) переносятся в `BANK-MASTER-ROADMAP` floor-2 блоки.
- **S2:** `BANK-SPRINT-PLAN` получает спринты, сфокусированные на конкретных спеках с GAP/PARTIAL и их MIG (в первую очередь M2.3/M2.4/M2.5/ABS-posting BLOCKER'ы).
- Фактические изменения roadmap/sprint/репо — **только отдельными change-set'ами**; этот документ ничего не меняет.

## 8. OPEN POINTS

- Точные repo-носители для B-PRICING, G-DEVICE, H-CRM, I-API не подтверждены документами — определить в первом A2-аудите.
- Связи MIG↔BUILD-SPEC для B-PRICING/G-DEVICE/L-BI(частично)/M-SANDBOX явно не документированы — выведены [INFERENCE], подтвердить при аудите.
- Cards/BIN-sponsor (UNK-09/ED-13) — не привязан ни к одной спеке (спеки нет); FIN060-live — шире D-FIN (операторский цикл HITL-010).
- Полный статус всех 80 MIG-файлов не инвентаризован в этом плане (перечислены идентифицированные серии) — полная MIG-матрица = задача первого A2-шага.
- Нумерация этажей (репо-канон FLOOR 3 vs операторская Floor 2) — см. numbering note в плитке floor-2.

## 9. Статус

**Status: PLAN ONLY, DRAFT, NOT FOR MERGE.**
Ссылки: `FULL-BANK-INSTALLATION-AUDIT-PLAN-2026-07-19.md` · `BANK-ROADMAP-AND-SPRINT-EDIT-PLAN-2026-07-19.md` · `EMI-CANON-COVERAGE-10-REPOS-2026-06-06.md` · `EMI-CANON-COVERAGE-COMPLETE-2026-06-06.md` · `FULL-PROJECT-INSTALLATION-AUDIT-2026-06-21.md` · `PHASE-3-SSOT-CONFORMANCE-2026-07-05.md`.
