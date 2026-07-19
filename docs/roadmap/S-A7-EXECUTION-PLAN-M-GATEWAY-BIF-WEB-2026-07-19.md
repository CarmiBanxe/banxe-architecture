# S-A7 EXECUTION PLAN — M-GATEWAY / BIF / web-слой — 2026-07-19

**Status: EXECUTION PLAN ONLY, DRAFT, NOT FOR MERGE** · ветка `agent/factory/bank-operating-model/20260718` · producer: factory sandbox terminal
S2.3-шаг цепочки S-A5 (identity) → S-A6 (ledger) → **S-A7 (gateway/web)**.

## 1. Цель

S-A7 фокусируется на BIF/M2.5-части в контексте payment-rails (WS8), спеке M-GATEWAY и web/API surface (H-*/I-API) для операций, идущих через ledger. Цель: (а) evidence-based вердикт по BIF на уровне gateway/rails; (б) подтвердить/опровергнуть гипотезу S-A6 «BIF не блокирует ledger, только rail-адаптер»; (в) убедиться, что gateway/web-слой использует **один** ledger (no second ledger, ADR-102), уважает identity-решения (S-A5) и не нарушает append-only/Decimal-инварианты (S-A6).

**Важное уточнение scope [ФАКТ, спека верифицирована]:** `M-GATEWAY-BUILD-SPEC` — это **developer-platform productisation wrapper**, НЕ платёжный гейтвей: «no second gateway» — runtime-гейтвей (routing/authN-authZ/rate-limit) владеет **I-API**; M-gateway публикует через него; LiteLLM-gateway — другой plane (AI). Payment-rail wiring к ledger идёт через `PaymentRailPort` в banxe-emi-stack (там же живут цели BIF). План использует эту фактическую топологию.

## 2. Scope

**In:** MIG-файлы BIF/M2.5 в rails-контексте (+M2.7 как образец redirect); `M-GATEWAY-BUILD-SPEC` и связанные носители; web/API surface — ключевые endpoints платежей/ledger, их связь с identity и ledger; mini-report S-A6 (как вход, когда появится).
**Out:** правки MASTER-ROADMAP / A2/R2/S2-доков / `docs/migration/*` / кода; новые ADR/инварианты.

## 3. Inputs (read-only; изменения = отдельные operator change-sets)

- `S-A6-EXECUTION-PLAN-D-GL-B-EMI-2026-07-19.md` + (после исполнения) `docs/audit/spec-audits/D-GL-B-EMI-INSTALL-AUDIT-<date>.md`.
- `FLOOR2-MIG-STATUS-MATRIX-2026-07-19.md` (§4 M2.5/BIF).
- MIG: `MIG-M2.5-BIF-BLOCKER-target-mismatch.md`, `MIG-M2.5-BLOCKER-abs-already-exists.md`, `MIG-M2.5-RESCOPE-abs-gap-audit.md`, `MIG-M2.7-*` (образец redirect-резолюции), **`MIG-CLOSURE-non-gated-complete.md`** [ФАКТ pre-scan: упоминает bif/bifrost — первоочередной кандидат на BIF-closure].
- Спека: `docs/architecture/M-GATEWAY-BUILD-SPEC.md` [ФАКТ: spec-plane only; runtime → banxe-emi-stack отдельным operator-authorized действием; запреты: no second gateway, no IAM/key-store reimpl (I-security), no pricing (B-pricing/D-fee), no AI-routing (LiteLLM), no sandbox mock-rails (M-sandbox)].
- Web/API: `I-API-BUILD-SPEC.md`, `H-CRM/H-SUPPORT-BUILD-SPEC.md`; target-доки: `BANK-OPERATING-MODEL-FOUR-FLOORS`, `BANK-LAUNCH-CONTROL-PANEL`, EMI-CANON-COVERAGE (секции gateway/web, если есть).

## 4. Task list

**Блок 1 — BIF redirect fact-check (первый по порядку):**
- Прочитать полностью `MIG-CLOSURE-non-gated-complete.md` — подтвердить/опровергнуть, что он закрывает BIF (это главный кандидат по pre-scan).
- Просканировать `docs/migration/*` на redirect/RESCOPE-доки со ссылкой на BIF/M2.5 и решения «Bifrost → banxe-emi-stack»; сравнить с паттерном M2.7-RESCOPE («Resolves the … blocker per operator decision»).
- Сопоставить с BIF-BLOCKER: есть ли Resolves/Covered-связь; нет — gap.
- Output: секция mini-report — redirect найден (куда именно) ИЛИ gap + **черновик operator-decision текста** (redirect Bifrost-адаптера в emi-stack `PaymentRailPort`, по образцу M2.7) — черновик в mini-report, MIG не трогаем.

**Блок 2 — Gateway ↔ D-GL/B-EMI wiring audit:**
- С учётом уточнения §1: проверять **два** слоя: (а) I-API internal gateway runtime (носитель — code-check, repo-carrier до сих пор не подтверждён — известный OPEN POINT A2), (б) rail-адаптеры `PaymentRailPort` в emi-stack (modulr_sepa_stub и родня).
- Зафиксировать paths+sha+конфиги: какие ledger-endpoints вызываются; как проходит `LedgerPort.post_journal_entry()/get_balance()`; grep на обходы (direct DB, альтернативный ledger).
- Output: wiring-карта «gateway-слой → ledger endpoint», вердикт «no second ledger» подтверждён/нарушен, OPEN POINTS.

**Блок 3 — Web/API conformance (H-*/I-API):**
- Идентифицировать ключевые endpoints, вызывающие платежи/ledger (emi-stack `api/routers/*`).
- Проверить: аутентификация через identity-контур (A-IDV/KYC/KYB решения, Keycloak/IAM); путь web → gateway-слой → ledger; grep на прямые обходы (web → ledger минуя gateway/port).
- Output: карта endpoints→ledger, список рисков обхода инвариантов, OPEN POINTS.

**Блок 4 — Cross-floor invariants:**
- Свести identity-решения (S-A5 mini-report), ledger-инварианты (append-only ADR-056/057, Decimal I-01 — из S-A6) и фактические пути web/gateway.
- Отметить: где инварианты соблюдены / нарушены / под угрозой.
- Output: финальная секция mini-report — cross-floor summary + список мест для будущих change-set'ов (без реализации).

Общий output: `docs/audit/spec-audits/M-GATEWAY-BIF-WEB-INSTALL-AUDIT-<date>.md`.

## 5. Acceptance criteria

- **BIF:** найден redirect/closure-док + подтверждённая реализация ЛИБО честный operator-decision-draft (что и где делать).
- **Gateway-слой:** wiring к ledger задокументирован; «no second ledger» подтверждён или нарушения зафиксированы; «no second gateway» (M-gateway vs I-API) проверен по той же логике.
- **Web/API:** ключевые endpoints описаны с путями до ledger и identity-привязкой; обходы/риски — в OPEN POINTS.
- **Cross-floor:** ясная картина связей identity/ledger/gateway/web; R2/S2 получают evidence для обновления статусов M-GATEWAY/web-блоков и решения по BIF.

## 6. Риски и ограничения

- Риск: дрейф MIG↔код для gateway/web; отсутствие redirect-доков при фактических обводах в коде (ловится grep'ами Блоков 2–3).
- Риск: repo-носитель I-API не подтверждён (известный A2 OPEN POINT) — Блок 2 может завершиться вердиктом GAP, это валидный исход.
- Ограничения: no changes в `docs/migration/*`, A2/R2/S2/MASTER-ROADMAP, коде; no ADR/INVARIANTS; неоднозначности → best-decision + OPEN POINT.

## 7. Связь с A2/R2/S2

Результаты S-A7: (а) **A2** — обновление секций M-GATEWAY/I-API/H-* в audit-плане + строка BIF в MIG-матрице (перенос привязки из ledger-scope в rails-scope при подтверждении); (б) **R2** — статусы WS8/web-блоков в MASTER-ROADMAP + снятие BIF из R2-risks либо его формализация как operator-decision; (в) **S2** — закрытие/уточнение линии S2.2-S2.3 по BIF/gateway/web. Без S-A7 любой update по gateway/web/BIF — догадка; после — evidence-based.

## 8. OPEN POINTS

- Закрывает ли `MIG-CLOSURE-non-gated-complete.md` BIF — главный вопрос Блока 1 (pre-scan дал только упоминание).
- Repo-носитель I-API internal gateway runtime (A2 OPEN POINT, не решён).
- Возможные обходы web→ledger мимо port'ов — до grep-проверки не утверждается ни наличие, ни отсутствие.
- Ключи rails (ED-01/02) и OD-R07 — вне S-A7 (внешние гейты), но их статус влияет на глубину проверяемого wiring (стабы vs live).
- Cross-floor: web-экспозиция затрагивает floor-3/4 HITL/security-гейты — фиксация, не расширение scope.

## 9. Статус

**Status: EXECUTION PLAN ONLY, DRAFT, NOT FOR MERGE.**
Ссылки: `S-A5-EXECUTION-PLAN-A-IDV-KYC-KYB-2026-07-19.md` · `S-A6-EXECUTION-PLAN-D-GL-B-EMI-2026-07-19.md` · `FLOOR2-BUILD-SPECS-INSTALLATION-AUDIT-PLAN-2026-07-19.md` · `FLOOR2-MIG-STATUS-MATRIX-2026-07-19.md` · `R2-FLOOR2-MASTER-ROADMAP-UPDATE-PLAN-2026-07-19.md` · `S2-FLOOR2-SPRINT-PLAN-UPDATE-PLAN-2026-07-19.md`.
