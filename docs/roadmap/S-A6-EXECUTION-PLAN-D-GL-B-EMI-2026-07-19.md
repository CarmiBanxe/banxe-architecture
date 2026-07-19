# S-A6 EXECUTION PLAN — Ledger/EMI cluster D-GL / B-EMI + M2.5-BIF verdict — 2026-07-19

**Status: EXECUTION PLAN ONLY, DRAFT, NOT FOR MERGE** · ветка `agent/factory/bank-operating-model/20260718` · producer: factory sandbox terminal
S2.2-шаг: сердце floor-2 — один ledger-кластер, две MIG-цепочки (ABS sanity + M2.5 deep-dive), один спринт.

## 1. Цель

S-A6 фокусируется на D-GL и B-EMI (ledger/EMI core) и цепочке M2.5-BIF. Цель: получить **evidence-based вердикт по M2.5-BIF** (реальный BLOCKER / stop-barrier без остаточной работы / требует redirect-решения), подтвердить состояние ABS/GL/EMI-слоя кодовым аудитом и подготовить uplift D-GL/B-EMI до READY. Без этого аудита любое решение по BIF/M2.5 — догадка.

## 2. Scope

**In:** D-GL (code audit GL/ledger; связь с ABS/EMI core; привязка MIG-ABS-\*/MIG-M2.5-\*); B-EMI (audit EMI core; связь с M2.5-BIF и ABS); полная M2.5-цепочка (BIF-BLOCKER, ABS-BLOCKER, ABS-RESCOPE); ABS-цепочка sanity (BLOCKER, COVERED, identity-coverage-audit).
**Out:** правки MASTER-ROADMAP/BANK-SPRINT-PLAN; правки `docs/migration/*` (только чтение); другие BUILD-SPEC (M-GATEWAY, web и т.д.); любые code changes (read-only audit); cross-repo write.

## 3. Inputs (read-only; изменение запрещено в рамках этого плана)

- Планы: `FULL-BANK-INSTALLATION-AUDIT-PLAN-2026-07-19.md` (floor-2 tile) · `FLOOR2-BUILD-SPECS-INSTALLATION-AUDIT-PLAN-2026-07-19.md` (§4 D-GL/B-EMI) · `FLOOR2-MIG-STATUS-MATRIX-2026-07-19.md` (§4 ABS/M2.5) · `output/audit-FLOOR2-MIG-STATUS-SNAPSHOT-20260719T011601.txt` · `R2-…-UPDATE-PLAN` §«EMI core / D-GL / B-EMI» · `S2-…-UPDATE-PLAN` §4 S-A6 · `BANK-SPRINT-PLAN-EXECUTION-DRAFT-2026-07-18.md` (S-A6).
- Spec/impl [ФАКТ, верифицировано grep'ом]: `docs/architecture/D-GL-BUILD-SPEC.md` — «Midaz PRIMARY / Fineract FALLBACK», double-entry GL core, `LedgerPort.post_journal_entry()/get_balance()`, chart-of-accounts = config-as-data, «exists in emi-stack (IL-FIN-01)», спека **консолидирует** уже существующее; `docs/architecture/B-EMI-BUILD-SPEC.md` — продукты как декларативные YAML/JSON-записи (versioned, immutable-per-version), product accounts **map to** GL accounts, «no second ledger, no posting logic here» (ADR-102); обе — spec-plane only (ADR-115/116/117), runtime → banxe-emi-stack.
- MIG: `MIG-ABS-posting-BLOCKER/COVERED-*`, `MIG-ABS-identity-coverage-audit.md`; `MIG-M2.5-BIF-BLOCKER-target-mismatch.md`, `MIG-M2.5-BLOCKER-abs-already-exists.md`, `MIG-M2.5-RESCOPE-abs-gap-audit.md`.

## 4. Task list

**Блок 1 — Code installation audit (banxe-emi-stack, read-only):**
- D-GL: найти GL/ledger services (кандидаты [ФАКТ прежних аудитов]: Midaz-клиент `services/ledger/`, LedgerPort ABC, journal/balance API); зафиксировать paths+sha, chart-of-accounts конфиг, posting rules; проверить Midaz-primary/Fineract-fallback фактическое состояние.
- B-EMI: найти EMI core stack (счета/продукты/оркестрация); проверить декларативные product-records (YAML/JSON) и маппинг product→GL accounts; подтвердить «no second ledger» (grep на дубли posting-логики — ADR-102).
- Output: секции 1–2 мини-отчёта `docs/audit/spec-audits/D-GL-B-EMI-INSTALL-AUDIT-<date>.md`.

**Блок 2 — MIG-ABS sanity check:**
- Перечитать полностью BLOCKER+COVERED+identity-audit; [ФАКТ] COVERED «Resolves the MIG-ABS-posting blocker (PR #648/IL-404) per operator decision A» — подтвердить резолюцию **и по коду** (GL/posting surface реально покрывает ABS-требования); остаточные риски — списком.
- Output: ABS-verdict секция.

**Блок 3 — M2.5 deep-dive (ядро спринта):**
- [ФАКТ, полный header прочитан] BIF-BLOCKER = **target-mismatch stop-barrier, зеркальный M2.7**: сценарий целил `banxe-payment-core`, а цели Bifrost Wave-D адаптера (`PaymentRailPort`+`LegacyAbsPaymentAdapter`+`AbsPaymentStatus`) живут в banxe-emi-stack; «STOP, no scaffold».
- **Рабочая гипотеза для проверки:** (а) BIF не блокирует D-GL/B-EMI — он про payment-rail адаптер (скорее WS8/M-GATEWAY-scope); (б) как и у M2.7, блокер снимается redirect-решением («строить в emi-stack»), которого может не существовать → искать redirect/RESCOPE-док; при отсутствии — BIF остаётся AWAITS-decision, но **вне** ledger-критического пути.
- Прочитать M2.5-ABS-BLOCKER + RESCOPE полностью; проверить «Resolves»-строку RESCOPE ([INFERENCE] матрицы); сопоставить с кодом: что из ABS-требований реализовано, где реальный mismatch.
- Вердикт-фиксация: какие части M2.5 честно закрыты; что остаётся настоящим BLOCKER'ом и **чьим** (ledger vs rails); развязка противоречия с «M2.1–M2.7 closed» (M2.8-acceptance) — какой док авторитетнее и почему.
- Output: M2.5-verdict секция (главный deliverable).

**Блок 4 — Target-model conformance (ledger/EMI):**
- Сверить фактический GL/EMI слой с `TARGET-MODEL-CONFORMANCE-2026-06-25` и `BANK-OPERATING-MODEL-FOUR-FLOORS` (операционный слой); особое внимание ABS/BIF-схемам и append-only инвариантам (ADR-056/057, I-24, Decimal I-01).
- Output: conformance-секция + сводный статус кластера.

## 5. Acceptance criteria

- **D-GL:** носитель кода найден и задокументирован; GL/ABS/posting-path согласован с ABS-chain; скрытых M2.5-блокеров для GL-части нет ИЛИ они явно зафиксированы.
- **B-EMI:** EMI core задокументирован; связь с D-GL (LedgerPort) и с M2.5 ясна; реальные блокеры описаны.
- **Кластер:** честный вердикт — «D-GL/B-EMI READY-candidates» (при BIF вне ledger-пути, с OPEN POINTS) ЛИБО «остаются PARTIAL» с конкретными причинами; M2.5-verdict сформулирован так, что R2/S2 могут обновить статусы в A2-плане и MASTER-ROADMAP со ссылкой на этот audit.

## 6. Риски и ограничения

- Риск: BIF-противоречие (M2.5 vs M2.8-acceptance) — разрешается Блоком 3, не предположением.
- Риск: дрейф MIG-текстов и кода (спека D-GL сама говорит о «scattered 5%» — консолидационный долг).
- Риск: перенос BIF в rails-scope может потребовать правки привязок в A2-плане (M-GATEWAY) — фиксировать как proposed-update, не править сейчас.
- Ограничения: no changes в `docs/migration/*`, MASTER-ROADMAP/SPRINT-PLAN/A2/R2/S2-доках, коде.

## 7. Связь с R2/S2/A2

Результаты: (а) **A2** — обновление секций D-GL/B-EMI (и, при подтверждении гипотезы, перенос BIF-привязки к M-GATEWAY) в FLOOR2-BUILD-SPECS-INSTALLATION-AUDIT-PLAN + строка матрицы M2.5; (б) **R2** — uplift D-GL/B-EMI в MASTER-ROADMAP (R2.2) или мотивированный PARTIAL; (в) **S2** — уточнение S-A7/S-A8 (если BIF уходит в rails-scope, он попадает в S-A7-периметр). Все правки — отдельными change-set'ами после execution.

## 8. OPEN POINTS

- Существует ли redirect/RESCOPE-док для BIF (аналог M2.7-RESCOPE) — не найден при подготовке; поиск = задача Блока 3; при отсутствии — операторское decision-кандидат.
- «Resolves»-строка M2.5-ABS-RESCOPE — не верифицирована ([INFERENCE] матрицы), full-read в Блоке 3.
- Фактический Midaz-vs-Fineract статус (primary/fallback) — по коду в Блоке 1.
- Контент `MIG-coverage-acceptance.md` — влияет на ABS/GL coverage-строки; чтение в Блоке 2.
- Cross-floor: append-only/audit-инварианты GL затрагивают floor-3/4 governance — фиксация, не расширение scope.

## 9. Статус

**Status: EXECUTION PLAN ONLY, DRAFT, NOT FOR MERGE.**
Ссылки: `FULL-BANK-INSTALLATION-AUDIT-PLAN-2026-07-19.md` · `BANK-ROADMAP-AND-SPRINT-EDIT-PLAN-2026-07-19.md` · `BANK-SPRINT-PLAN-EXECUTION-DRAFT-2026-07-18.md` · `FLOOR2-BUILD-SPECS-INSTALLATION-AUDIT-PLAN-2026-07-19.md` · `FLOOR2-MIG-STATUS-MATRIX-2026-07-19.md` · `R2-FLOOR2-MASTER-ROADMAP-UPDATE-PLAN-2026-07-19.md` · `S2-FLOOR2-SPRINT-PLAN-UPDATE-PLAN-2026-07-19.md`.
