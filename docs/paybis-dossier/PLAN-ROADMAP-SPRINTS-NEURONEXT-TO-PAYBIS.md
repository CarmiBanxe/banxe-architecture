# PLAN / ROADMAP / SPRINTS — NeuroNext → PAYBIS

**Plane:** docs-plane only (план; no runtime). **Track:** F-crypto-provider (PAYBIS). **Date:** 2026-06-26.
**Source-of-truth:** SRC-01/04 (FACT contractual), SRC-05/06/07 (PARTIAL structural), code-seam (FROZEN `CryptoLedgerPort` + `MidazCryptoAdapter`; **`CryptoCompliancePort` = canonical design-frozen seam в ADR-114, но NOT-YET-CODED** — 0 в runtime; Wave C реализует его + `travel_rule_engine`), ADR-108/114/138, audit (0 NeuroNext/0 Bitrix). См. `PAYBIS-GOVERNANCE-FACTS.md`.

---

## 1. Scope & guardrails

- **[ADR-138]** PAYBIS = **единственный** external crypto provider; NeuroNext **запрещён** к реинтродукции (forward-guard, не legacy-cleanup — в коде следа нет).
- **Microservice consolidation principle:** сокращать duplicate/versioned/legacy-варианты (`*/legacy/*`, `*/production/*_stub.py`, `*_v2`) **сохраняя** микросервисную архитектуру; только через **ADR-102 dup-audit** (проверка всех consumer-ов).
- **Invariants:** **I-27** (KYC/KYB/AML → HITL-gate, где движутся средства/PII); **I-01** Decimal-only money; **ADR-102** dup-audit перед любым новым файлом; **I-SEC** secrets не в repo.
- **FROZEN-port правило:** `CryptoLedgerPort` НЕ менять — добавляется **новый адаптер** `PaybisCryptoAdapter` (рядом с `MidazCryptoAdapter`). Контракт широко потребляется → слом запрещён.
- **GATING RULE:** literal-spec-зависимая работа **GATED** на чистый **SRC-06** (API spec) + **SRC-07** (TR schema) + **SRC-08**; structural/mock работа может идти **сейчас**. **Ни один live PAYBIS-вызов** не идёт до закрытия **ADR-114 go-live gate**.
- **GO-LIVE GATE (concrete, governance-traced — см. `PAYBIS-GOVERNANCE-FACTS.md`):** ни один **BANXE-originated crypto-flow** не идёт live, пока НЕ выполнены **оба** — **Paybis TR-confirmation contract** (часть SP-PR3) **+ MLRO oversight procedure** (ADR-114:14/22, ADR-108:18). Плюс **CASP T&C disclosure deadline 2026-07-01** (GAP-071). Статус: **GAP-071/072 = 🟡 IN PROGRESS** (Q3 2026).
- **SETTLEMENT route (concrete, ADR-108:14):** Paybis fiat → **TomPay dedicated IBAN (GBP)**; **Papaya = EU-SEPA rail (EUR)** — конкретизирует generic SP-PR3 «wallet/bank».

---

## 1A. MANDATORY TRACK — Architecture Conformance & Service Consolidation

> **HARD REQUIREMENT (не nice-to-have).** Сквозной обязательный трек поверх всех волн PAYBIS-миграции. Каждая консолидационная правка — только через factory orchestration и только на shell-audit evidence (read-only); ADR-102 dup-audit обязателен.

### Required sub-goals
1. **Preserve microservice architecture** — система остаётся микросервисной (никакого монолита).
2. **Reduce microservice count** где возможна smart-consolidation (без слома контрактов/consumer-ов).
3. **Eliminate legacy/versioned/deprecated duplicate services** (`*_v2`, `*/legacy/*`, `*/production/*_stub.py`, `_old/_deprecated/_copy/_new`).
4. **Remove Bitrix process footprint** полностью.
5. **Remove NeuroNext process footprint** полностью → заменить PAYBIS-backed процессами под существующим agreement.
6. **Map legacy processes onto existing target architecture & ports** (адаптировать к целевой архитектуре, **не** транспортировать вслепую).
7. **Shell-audit evidence для каждого consolidation-решения** (read-only, в factory).

### Baseline (shell-audit, emi origin/main @ a27ab27 — evidence, не память)
| Метрика | Значение |
|---|---|
| service dirs | **107** |
| `*_v[0-9]` variants | **3** |
| `*/legacy/*` files | **22** |
| `*/production/*_stub.py` | **5** |
| `_old/_deprecated/_copy/_new` | **0** |
| **neuronext** footprint (services/app) | **0** (removal уже выполнен — forward-guard) |
| **bitrix** footprint (services/app) | **0** (removal уже выполнен — forward-guard) |

> Bitrix/NeuroNext в новом коде **0** → их «removal» = (a) forward-guard CI (E9) против реинтродукции + (b) маппинг любых их *процессов* на PAYBIS/целевые порты, а не удаление кода (кода нет). Консолидация = реальная работа над 3+22+5 вариантами.

### Track epics
- **E9** NeuroNext + Bitrix forward-guard CI — **DONE** (emi cfe185d: 2 ERROR deny-rules in .semgrep/banxe-rules.yml — banxe-no-neuronext-reintroduction + banxe-no-bitrix-reintroduction; verified 0 findings clean-tree + positive in-repo detection + quality-gate exit 0).
- **E10** Consolidation pass (ADR-102 dup-audit `services/ledger/{legacy,production}` + repo-wide `_v2`/legacy/stub) — keep/merge/delete матрица на evidence — READY.
- **E12** Architecture-conformance map: legacy-процессы → существующие target-порты (`CryptoLedgerPort`, `LedgerPort`, `travel_rule_engine`, …); фиксировать «adapt, not transplant» — **DONE** (E12-result below: all processes → existing ports, 0 new contracts, FROZEN intact).

### E10 — consolidation audit RESULT (ledger crypto perimeter) — [FACT, read-only shell-evidence emi origin/main]

> **NO runtime deletion** этим шагом: все варианты — на **live consumer-ах** (verified `api/deps.py:229-231` DI-binding всех трёх legacy-адаптеров). FROZEN `CryptoLedgerPort`/`CryptoRpcPort` широко потребляются. ZERO orphan duplicates в периметре.

| Module | Verdict | Justification (shell-evidence) |
|---|---|---|
| `legacy/legacy_crypto_wallet_adapter.py` | **PARKED (superseded-on-cutover)** | live via `api/deps.py` (wallet=LegacyCryptoWalletAdapter()); удалить только после того, как `PaybisCryptoAdapter` выигрывает DI в Wave B и покрывает wallet use-cases. refs (non-test/def)=3 |
| `legacy/legacy_crypto_processing_adapter.py` | **PARKED (superseded-on-cutover)** | live via `api/deps.py` (processing=…); та же condition. refs=4 |
| `legacy/legacy_crypto_rpc_adapter.py` | **PARKED (superseded-on-cutover)** | live via `api/deps.py` (rpc=…, `CryptoRpcPort`); та же condition. refs=5 |
| `production/midaz_crypto_adapter.py` | **KEEP** | production Midaz CryptoLedgerPort path; не дубликат к удалению |
| `production/midaz_crypto_stub.py` | **PARKED (conformance-stub)** | structural FROZEN-port guarantee; держать до стабилизации live-провайдеров. refs=2 |

**Итог периметра:** ledger crypto = **ZERO orphan duplicates** → удаления нет; все leftovers **explicitly PARKED с обоснованием + removal-condition** (§5A-совместимо).

#### PARKED consolidation backlog (вне периметра — отдельные будущие scoped-эпики, НЕ этот шаг)
> Каждый требует **own ADR-102 dup-audit + consumer-graph per module** перед любым merge/delete.
- `*_v2` (3): `services/recon/reconciliation_engine_v2.py`, `services/consumer_duty/models_v2.py`, `services/reporting/fin060_generator_v2.py` — **wave-1 AUDITED, см. ниже**.
- `*/legacy/*` (22) across `compliance/` `payment/` `auth/` и др. — **wave-2 pending** (own per-module ADR-102).

#### E10 — `_v2` dup-audit RESULT (wave 1) — [FACT, read-only shell-evidence emi origin/main]

> **NO runtime change / deletion / rename этим шагом.** 0 orphan deletions: 2 MERGE-PLANNED (recon, fin060) + 1 RENAME-DEBT (consumer_duty), все PARKED с verdict + condition + blast-radius.

| Module | Verdict | Reason (shell-evidence) | Condition | Blast-radius |
|---|---|---|---|---|
| `recon/reconciliation_engine_v2.py` vs `reconciliation_engine.py` | **MERGE-PLANNED (PARKED)** | BOTH live: `api/routers/safeguarding_recon.py` импортит оба (verified: `_v2` StatementEntry+ReconciliationEngineV2); `_v2` также в camt053_parser/recon_agent; original в batch_payments/breach_detector/midaz_reconciliation/safeguarding_adapters. `_v2` несёт ReconStorePort/InMemoryReconStore/HITLProposal | unify на один engine + migrate consumer imports в отдельном scoped-refactor | ~8 файлов (incl api router + tests) |
| `consumer_duty/models_v2.py` (vs `models.py` **MISSING**) | **NOT-A-DUPLICATE → RENAME-DEBT (PARKED)** | `services/consumer_duty/models.py` **НЕ существует** (verified) → `models_v2` = единственная real-impl; весь пакет импортит `models_v2`. «original importers» в step-1 = generic grep false-positives на слово `models`, не `consumer_duty.models` | косметический rename `models_v2 → models` (atomic rename + import-update) | 12+ импортеров |
| `reporting/fin060_generator_v2.py` vs `fin060_generator.py` | **MERGE-PLANNED (PARKED)** | BOTH live: `reporting_agent` импортит оба (incomplete v1→v2 migration; verified `_v2` FIN060Generator+HITLProposal); original в `api/routers/safeguarding.py`/`regdata_return.py`/reporting_agent/tests | unify после migrating `api/routers/safeguarding.py`+`regdata_return.py` off original | ~8 файлов |

**Итог wave-1:** `_v2`×3 AUDITED → **0 orphan deletions**; 2 MERGE-PLANNED + 1 RENAME-DEBT, все **PARKED с условием**. `*/legacy/*`×22 = **wave-2** (own per-module ADR-102). FROZEN-порты не затронуты.

#### Refactor rule (per `_v2` verdict)
Каждый **MERGE-PLANNED** исполняется как **СВОЙ scoped track**: (1) migrate consumers off the superseded file, (2) unify на один модуль, (3) delete superseded — **gated, тесты green ≥90% до удаления**. **RENAME-DEBT** — atomic rename + import-update с полным test-pass. Этим шагом — **ничего не удаляется/не переименовывается**.

#### E10 — legacy dup-audit RESULT (wave 2) — [FACT, read-only shell-evidence emi origin/main]

> **Коррекция счёта:** total `*/legacy/*` .py (excl `__init__`) = **18** (verified), а не 22 (PLAN/память). **NO deletion этим шагом.**
> **Key lesson (canon «verify before delete»):** простой import-count недостаточен. Полная **full-symbol + re-export + dynamic + test-ref** проверка переклассифицировала **4/7** import-count-кандидатов; а **независимая re-verification** sub-B уточнила даже «0 refs»-орфанов → они **test-coupled** (только 1 из 3 — чистый орфан). Fail-closed: ничего не удаляется без consumer-enumeration на момент execution.

| Module | Verdict | Reason (shell-evidence) | Condition |
|---|---|---|---|
| `compliance/legacy/legacy_bkyc_adapter.py` | **PARKED (I-27 KYC perimeter — operator decision)** | KYCWorkflowPort KYB-legacy внутри I-27 perimeter; часть cohesive Wave-D KYC-слоя (sumsub/bkyc/binancekyc); 0 prod refs **но есть** `tests/test_legacy_bkyc_adapter.py` (verified) + `kyb_onboarding` service существует → «не импортится сейчас» ≠ «не нужен» (возможная future KYB-активация). Deletion = destructive в licensed-perimeter, value < barrier | **NEVER auto-delete** — только explicit operator + MLRO/HITL-L4 |
| `auth/legacy/role_guard.py` | **PARKED — NOT-ORPHAN** (final, 2026-06-27) | НЕ orphan: `tests/test_wave_a_adapter_seam_scaffold.py` имеет **3 functional-теста** — `test_legacy_role_guard_constructs_with_roles` (L116), `test_make_legacy_role_guard_factory` (L123), `test_legacy_role_guard_check_invariant` (L131, **production security-invariant** «role ∈ allowed AND status == ACTIVE»: `guard.check` True/False). Удаление/strip теста снимает coverage реального auth role/status инварианта. Supersedes IL-558 «DELETE-ELIGIBLE-WITH-TEST» + IL-569 «BLOCKED→PARKED» | **KEEP** — НЕ consolidation-deletion candidate |
| `compliance/legacy/legacy_binancekyc_adapter.py` | **PARKED (I-27 KYC perimeter — same rule)** | тот же cohesive KYC-слой; нельзя частично удалить один из трёх KYC-адаптеров в licensed-perimeter; 0 prod refs но dedicated `tests/test_legacy_binancekyc_adapter.py` + `BinanceKYCError` в shared `tests/test_shared_errors.py` | **NEVER auto-delete** — operator + MLRO/HITL-L4 |
| `auth/legacy/legacy_sca_adapter.py` + `legacy_totp_adapter.py` | **✅ DELETED** (emi `998040a`, branch `agent/factory/consolidation/auth-legacy-orphans`) | re-verified clean (0 non-test refs; only dedicated tests; totp intra-cluster only via sca); deleted as pair + 2 dedicated tests | DONE — gates green (collect OK, 185 auth tests pass, ruff+semgrep clean, 0 residual) |
| `payment/legacy/bifrost_adapter.py` | **PARKED (reclassified — NOT orphan)** | `to_minor_units` used by `open_banking/intl_scheduled.py` + `m24_int_bridge.py` (verified 2 live consumers) | extract helper first, если когда-то удалять |
| `payment/legacy/legacy_transactions_adapter.py` | **PARKED (reclassified — NOT orphan)** | `TransactionRecord` → `ledger/midaz_adapter.py` (verified 13×); `TransactionApplicationError` → `services/shared/errors.py` | live; cannot delete |
| auth/legacy `{legacy_otp_adapter, jwks_models, jwt_strategy}`, compliance/legacy `{_edd, _jurisdictions, legacy_sumsub_adapter}`, payment/legacy `{legacy_abs_payment_adapter, legacy_sepa_adapter}`, ledger/legacy `legacy_crypto_*` | **PARKED (live consumers / E10 PAYBIS-gated)** | live non-test consumers (1–3 каждый); crypto = PAYBIS-cutover gated | per-module own ADR-102 / cutover |

> #### CANON RULE — I-27 perimeter is never consolidation-deletable
> **KYC/KYB/AML legacy-модули (I-27 perimeter) НИКОГДА не являются кандидатами на consolidation-deletion — только PARKED.** Удаление любого I-27-компонента требует **explicit operator + MLRO/HITL-L4 authorization**, никогда не best-decision auto. Обоснование: licensed-compliance perimeter, destructive + необратимо, «не импортится» ≠ «не нужен» (cohesive KYC-слой + возможная future-активация). Referenced in §5A.

**Итог wave-2 (18 legacy):** I-27 KYC-адаптеры (`legacy_bkyc`, `legacy_binancekyc`) → **PARKED-by-canon** (operator decision). **Execution 2026-06-27 (operator-authorized):** `sca`+`totp` pair → **✅ DELETED** (emi `998040a`); `role_guard` → **ABORTED/PARKED** (re-verify нашёл non-dedicated test consumer `test_wave_a_adapter_seam_scaffold.py` вне deletion-set). Всё прочее **PARKED**.

#### Deletion-execution rule (wave-2)
Deletion scope теперь = **только auth-orphans, non-I-27** (operator go обязателен для destructive-шага): (1) `role_guard` — delete adapter + dedicated test одним коммитом; (2) `sca`/`totp` — DI-trace, затем pair-delete. **I-27 KYC (`bkyc`/`binancekyc`) исключены из deletion scope (PARKED-by-canon).** Во всех случаях: **full test-suite green + gitleaks clean + ADR-102 re-confirm at execution time** (main двигается). Этим docs-шагом — **никаких удалений**.

#### E10 consolidation wave-1 — CLOSED (2026-06-27)

- **Executed:** `sca`+`totp` pair **DELETED** (emi `998040a`, branch `agent/factory/consolidation/auth-legacy-orphans`; gates green: collect OK, 185 auth tests pass, ruff+semgrep clean, 0 residual) — единственное verified-safe orphan-удаление.
- **`role_guard`:** **PARKED — NOT-ORPHAN** (final, this audit) — live functional tests (3, incl. production role/status security-invariant) в `test_wave_a_adapter_seam_scaffold.py`; **НЕ** deletion candidate.
- **All other legacy: PARKED** — live consumers (`otp`/`jwks`/`jwt`/`_edd`/`_jurisdictions`/`sumsub`/`abs`/`sepa`/`bifrost`/`transactions`); **I-27 KYC** (`bkyc`/`binancekyc`) PARKED-by-canon; **ledger-crypto** → Wave-C PAYBIS cutover.
- **Net result:** E10 сократил legacy-surface на **1 module-pair (`sca`+`totp`)**; **дальнейших orphan-удалений без внешних решений НЕТ** (`role_guard` нужен test-refactor decision; остальное live/parked).
- **Lesson (canon):** **verify-before-delete сработал дважды на `role_guard`** — механическая «orphan»-классификация (0 prod refs) была неверна оба раза; **test-consumers считаются**. Superseded: IL-558 (DELETE-ELIGIBLE-WITH-TEST), IL-569 (BLOCKED→PARKED) → **final = PARKED-NOT-ORPHAN**.

#### Cutover rule
Каждый **PARKED-superseded** модуль удаляется **только в Wave C production cutover**, gated, **после** того как PAYBIS-провайдер live в DI **и** NeuroNext/Bitrix guard зелёный; **rollback никогда не реинтродуцирует NeuroNext**.

### E12 — conformance-map RESULT (legacy/PAYBIS processes → existing target ports) — [FACT, read-only shell-evidence emi origin/main]

> **Принцип (adapt, not transplant):** каждый PAYBIS/legacy-процесс ложится на **СУЩЕСТВУЮЩИЙ** порт — **никакого нового контракта не создаётся**, FROZEN-порты не меняются. Verified: 49 `*_port.py` (hexagonal Protocol/ABC); все anchor-порты ниже подтверждены на origin/main. Где literal mapping требует API/TR-spec — **НЕИЗВЕСТНО** (SRC-06/07), не выдумано.

| Process (PAYBIS/legacy) | Target port (existing) | Adapt/Map note |
|---|---|---|
| BuyCrypto/SellCrypto, create_tx, fee_estimate, balance, wallet-addr, health | **CryptoLedgerPort** (FROZEN) `services/ledger/crypto_ledger_port.py` | `PaybisCryptoAdapter` implements port; non-custodial → balance/wallet_addr `OUT_OF_PAYBIS_SCOPE` (ADR-108) |
| crypto RPC / block/tx lookup (`legacy_crypto_rpc`) | **CryptoRpcPort** (FROZEN) | legacy adapter PARKED; no new port |
| Order/Refund lifecycle, payment events | **CryptoLedgerPort** create_tx + status; **webhooks/reliability_port** для callback delivery | map pending/completed/cancelled/rejected/expired → FROZEN `CryptoTransactionStatus` |
| Travel-Rule (TR-status от PAYBIS) | **TravelRuleEngine** (+`TravelRuleData`) `services/crypto_custody/` | E5 uses `travel_rule_engine` (verified methods); **CryptoCompliancePort** = canonical design-frozen TR-status seam (receive-not-originate, ADR-114) — **NOT-YET-CODED**, Wave C implements |
| compliance gating / verdicts | **ComplianceCheckPort** `services/observability/compliance_monitor.py` | existing seam; KYB/TR на стороне Paybis per ADR-108/114; `CryptoCompliancePort` canonical-in-ADR-114 / not-yet-coded (`PAYBIS-GOVERNANCE-FACTS.md`) |
| KYC/KYB provider hand-off | **KYCProviderPort** / **KYCWorkflowPort** `services/kyc/` | I-27 HITL gate; literal data-sharing **НЕИЗВЕСТНО** (SRC-07) |
| settlement (Partner Fees: wallet+bank, 30-day, shortfall netting) | **LedgerPort** + **treasury/\*** ports (`fx_exposure`/`liquidity_forecast`/`nostro_recon`) | SRC-04 FACT; fiat → **TomPay GBP IBAN** + **Papaya SEPA EUR** (ADR-108:14) |
| webhook idempotency (`partnerOrderId`/`transactionId`) | **webhooks/reliability_port.py** | verified callback + idempotency |

**Conformance verdict:** все процессы приземляются на **существующие** порты; **0 новых контрактов**, FROZEN `CryptoLedgerPort`/`CryptoRpcPort` неизменны → **adapt, not transplant** соблюдён (precedent: legacy/production adapter-семейства auth×7/compliance×6/payment×5/ledger×4/…). Literal API/TR-маппинг → **НЕИЗВЕСТНО** до SRC-06/07.

---

### Consolidation track — CLOSED (audit phase) — [operator decision]

> Architecture-Conformance mandatory track **закрыт на текущей точке**: полный audit-map готов, I-27 защищён, §5A satisfied. Destructive execution **намеренно отложена**. Audit-deliverables стоят как **каноническая consolidation-map**.

- **Status:** **E9 DONE** (NeuroNext/Bitrix forward-guard, IL-555) + **E10 DONE** (audit: `_v2` wave-1 IL-557 + legacy wave-2 IL-558 + I-27 park IL-559, full map) + **E12 DONE** (conformance-map, IL-556). **§5A points 2/3/4 — satisfied.**
- **0 deletions executed** — docs-plane only на всём протяжении; destructive execution **deferred** by operator decision.
- **Residual deferred-execution backlog** (каждый: **operator go + full-suite-green + ADR-102 re-confirm at execution time**, main двигается):
  - **auth-orphans (non-I-27):** `role_guard` (DELETE-WITH-TEST), `sca`/`totp` (DELETE-AS-PAIR после DI-trace).
  - **`_v2` merge-planned:** recon engine, fin060 generator (consumer-migration → unify → delete).
  - **rename-debt:** `consumer_duty/models_v2` → `models`.
  - **I-27 KYC legacy (`bkyc`/`binancekyc`):** **PARKED-by-canon — НЕ в deletion scope** (§1A CANON RULE; operator+MLRO/HITL-L4 only).
  - **`bifrost`/`legacy_transactions` + live-consumer legacy:** PARKED.
- **Re-entry rule:** при возобновлении — **re-run ADR-102 dup-audit per module против текущего main перед любым удалением** (audit может устареть; main двигается).

**Эта запись ЗАКРЫВАЕТ consolidation execution-фазу на текущий момент**; audit-deliverables (E9/E10/E12 + §5A) — каноническая consolidation-map. Next → operator next-priority selection.

---

## 2. Epics (с dependency graph)

| Epic | Goal | Depends-on | Gate-status | Repo | Invariants |
|---|---|---|---|---|---|
| **E1** | `PaybisCryptoAdapter` scaffold за FROZEN `CryptoLedgerPort` (injectable-mock, ≥90% cov на mock, live transport fenced) | seam | **READY (structural)** | emi-stack | ADR-102, I-01 |
| **E2** | BuyCrypto/SellCrypto + Order/Refund ↦ `create_tx` + status | E1 | **READY structural / GATED-on-SRC-06** (literal) | emi-stack | I-01, I-27 |
| **E3** | Webhook/callback endpoint: verified signature + idempotency на `partnerOrderId`/`transactionId` | E1,E2 | **READY structural / GATED-on-SRC-06** (webhook schema) | emi-stack | I-SEC |
| **E4** | Signed-request/widget signing (HMAC-style) | E1 | **GATED-on-SRC-06** (signature algorithm) | emi-stack | I-SEC |
| **E5** | Travel-Rule via `travel_rule_engine`; consume TR-status от PAYBIS | E1,E2 | **GATED-on-SRC-07 + ADR-114 go-live** (TR contract + MLRO) | emi-stack | I-27, ADR-114 |
| **E6** | Settlement/treasury: dual payout rails (wallet+bank), 30-day undisputed-invoice recon window, shortfall fee-netting (SRC-04 FACT) | E1 | **READY (domain logic) / GATED-on-SRC-06** (literal fee %) | emi-stack | I-01 |
| **E7** | DI wiring: выбор PAYBIS-provider в container/deps/settings (сейчас unwired) | E1 | **READY for mock / GATED-on-SRC-06** (live) | emi-stack | ADR-102 |
| **E8** | Sandbox/prod env switch (config-as-data) + secrets boundary (gitleaks, no secrets in repo) | E1 | **READY structural / GATED-on-SRC-06** (base-URLs+creds) | emi-stack | I-SEC |
| **E9** | NeuroNext + Bitrix forward-guard: CI/lint deny-rules (semgrep) | — | **DONE** (emi cfe185d) | emi-stack | ADR-138 |
| **E10** | Microservice consolidation pass на crypto/ledger dirs (dedupe superseded legacy adapters) | audit | **READY (audit-driven, ADR-102)** | emi-stack | ADR-102 |
| **E11** | Compliance/governance: SRC-08 MLRO owner + CASP T&C disclosure (2026-07-01) | — | **GATED (operator/compliance)** | architecture | I-27, ADR-114 |

**Dependency graph (сжатый):** E1 → {E2,E3,E4,E6,E7,E8}; E2 → {E3,E5}; E5 ⟸ E11(MLRO/CASP) + ADR-114; E9/E10 независимы. Live-ветки (E2/E3/E4 literal, E5, E7-live, E8-live) ⟸ SRC-06/07/08.

---

## 3. Roadmap (waves)

### Wave A — READY now (no literal spec; всё mock/fenced, ≥90% cov)
**E1** scaffold · **E9** guard · **E10** consolidation audit · **E6** domain logic (recon-window/fee-netting/dual-rail модель) · **E8** structural env-switch · **E7** mock-DI.
- **Unblocks:** ничего внешнего не нужно — seam + SRC-01/04/05 структурного достаточно.

### Wave B — GATED on **SRC-06** (clean API spec)
**E2/E3/E4** literal (endpoints/schemas/webhook-payload/signature-algorithm) · **E7** live-DI · **E8** live env (base-URLs+creds).
- **Unblocks ⟸:** чистый SRC-06 (endpoints/auth/signature/schemas/webhook).

### Wave C — GATED on **SRC-07 + ADR-114 go-live + SRC-08**
**E5** TR live · go-live gate (TR-confirmation contract + MLRO procedure) · production cutover (NeuroNext→PAYBIS, rollback не реинтродуцирует NeuroNext).
- **Unblocks ⟸:** SRC-07 TR-schema + SRC-08 MLRO/CASP-T&C + закрытый ADR-114 gate.

---

## 4. Sprints (Wave A — детально; B/C — gated outlines)

> Cadence: single-artifact-per-step (sub-B canon); каждый спринт = ветка `agent/factory/paybis/<slug>` off emi origin/main, injectable-mock тесты, **≥90% cov**, **ADR-102 dup-audit** checkpoint, hand-to-MAIN.

### Wave A sprints
- **A-S1 — E1 PaybisCryptoAdapter scaffold.** Deliverable: `PaybisCryptoAdapter(CryptoLedgerPort)` + injectable `PaybisTransportPort` (live fenced). Tests: mock-transport unit (get_balance/create_wallet_address/create_tx/get_fee_estimate/health), in-mem/mock pattern (как safeguarding). Cov ≥90%. Dup-audit: нет существующего PaybisCryptoAdapter (verify). Hand-to-MAIN.
- **A-S2 — E9 NeuroNext guard.** Deliverable: CI/lint rule (grep-gate) — fail если `neuronext` появляется в `services/`/`app/`. Tests: rule fires on a fixture. Cov n/a (CI). Hand-to-MAIN.
- **A-S3 — E10 consolidation audit.** Deliverable: ADR-102 dup-audit doc по `services/ledger/{legacy,production}` crypto-вариантам — keep/merge/delete матрица (без слома FROZEN-контракта; без удаления без consumer-проверки). Hand-to-MAIN.
- **A-S4 — E6 settlement domain logic.** Deliverable: Decimal-only модели dual payout rail (wallet/bank), 30-day undisputed-invoice recon-window, shortfall fee-netting (set-off Partner Fees vs Shortfall, relevant/subsequent) — чистая логика, без live. Tests ≥90%. Hand-to-MAIN.
- **A-S5 — E8 env-switch structural + E7 mock-DI.** Deliverable: config-as-data sandbox/prod switch + DI выбор PAYBIS provider (mock), secrets-boundary (gitleaks-clean, no creds). Tests ≥90% (mock). Hand-to-MAIN.

### Wave B sprints (GATED-on-SRC-06 — outline only)
- B-S1 E2 literal mapping; B-S2 E3 webhook verify+idempotency; B-S3 E4 signature; B-S4 E7-live/E8-live. **Не стартуют до SRC-06.**

### Wave C sprints (GATED-on-SRC-07/ADR-114/SRC-08 — outline only)
- C-S1 E5 TR-live; C-S2 go-live gate; C-S3 production cutover + rollback drill (no-NeuroNext). **Не стартуют до SRC-07 + ADR-114 + SRC-08.**

---

## 5. Operator/Paybis dependencies (the gate list)

| Зависимость | Блокирует | Owner |
|---|---|---|
| **SRC-06** clean API spec: endpoints/methods, auth, signature algorithm+signed fields, per-flow schemas, webhook event/payload/verify, retry/timeout/rate-limit/SLA, sandbox/prod base-URLs+creds | Wave B (E2/E3/E4 literal, E7-live, E8-live) | **Paybis** |
| **SRC-07** TR data contract / TR-status schema | Wave C (E5) | **Paybis / MLRO** |
| **SRC-08** MLRO oversight owner + CASP T&C disclosure (2026-07-01) | Wave C go-live (E11) | **operator / compliance** |
| Full agreement `.docx` (approved domains/ICT, change-approval, security/incident/audit, sublicensing) — dossier §3b | approved-env/control-obligations | **operator / legal** |
| data-residency, exact integration fee % | E6 literal, E8 | **Paybis / operator** |

> Всё literal — **НЕИЗВЕСТНО** до источника; не выдумывается.

---

## 5A. Migration-completeness acceptance (HARD GATE — каждая волна)

> **Ни одна migration-волна не считается завершённой**, пока ВСЕ четыре пункта не выполнены и не зафиксированы (shell-audit evidence + IL):
> 1. **Provider/process replacement done** — соответствующие крипто-процессы идут через PAYBIS (или явно отложены с обоснованием); NeuroNext-процессы заменены, Bitrix-процессы устранены.
> 2. **Architecture conformance checked** — изменения адаптированы к существующей target-архитектуре/портам (`CryptoLedgerPort` FROZEN и т.п.), а не транспортированы вслепую. **✅ §1A E12-map: все PAYBIS/legacy-процессы → существующие порты, 0 новых контрактов, FROZEN intact.**
> 3. **Service-count / duplication reduction audited** — проведён ADR-102 shell-audit на `_v2`/legacy/stub/duplicate; найденные возможности консолидации либо реализованы, либо запаркованы. **✅ ledger crypto perimeter (§1A E10): ZERO orphan. ✅ `_v2` wave-1: 2 MERGE-PLANNED + 1 RENAME-DEBT. ✅ `*/legacy/*` wave-2 AUDITED (18 modules): 1 confirmed orphan + 1 delete-with-test + 1 verify-then-delete + 1 pair-candidate + rest PARKED.** (verify-before-delete переклассифицировал 4/7 + уточнил test-coupling).
> 4. **Legacy/versioned leftovers** — либо удалены, либо **explicitly parked с обоснованием** (parked-list в IL/доке; «молчаливого» остатка не допускается). **✅ ledger + `_v2`×3 + legacy×18 = all с verdict+condition. I-27 KYC legacy (`bkyc`/`binancekyc`) = permanently PARKED-by-canon (§1A CANON RULE — НЕ «pending», never auto-delete без operator+MLRO/HITL-L4). Deletion scope сужен до auth-orphans (`role_guard` + `sca`/`totp` pair), всё ещё требует operator go для destructive-шага; NO deletion этим шагом.**
>
> Acceptance для PAYBIS-completeness в целом дополнительно требует: ADR-114 go-live gate закрыт (TR contract + MLRO), SRC-06/07/08 ingested, neuronext/bitrix footprint = 0 (CI-guard E9 зелёный).

---

## 6. Return-to-base

**[Canon]** По завершении PAYBIS-трека (или при паузе на ожидание SRC-06/07/08) sub-B **возвращается к основной роли** (RIGHT terminal) и **возобновляет приостановленный primary track** — очередь Phase-3.6 stub→L2 (per EMI-implementation-state IL-538). PAYBIS-трек — временный; постоянной крипто-роли sub-B не удерживает.

---

### Refs
SRC-01/04 (IL-547/549), SRC-05/06 map (IL-550), REGISTER (IL-548), DOSSIER (IL-546), ADR-138 (IL-545); ADR-108/114; `services/ledger/crypto_ledger_port.py` (FROZEN) + `MidazCryptoAdapter`; `travel_rule_engine`; EMI-impl-state IL-538; ADR-102/119; I-01/I-27/I-SEC. **Literal API spec — НЕИЗВЕСТНО (SRC-06/07/08 pending).**
