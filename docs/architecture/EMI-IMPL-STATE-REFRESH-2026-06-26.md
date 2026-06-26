# EMI implementation-state refresh (supersedes IL-538 backlog)

**Plane:** docs-plane only (read-only evidence map; no runtime). **Date:** 2026-06-26.
**Supersedes (references, does NOT edit):** IL-538 «EMI implementation-state» (Phase-3.6 stub→L2 backlog: «19 SPEC-LOCKED-STUB», «ledger 12 stubs P1»). Append-only (ADR-119/I-28): IL-538 остаётся как исторический срез; этот документ — обновлённый срез на основе live shell-audit.
**Evidence:** banxe-emi-stack origin/main (read-only `git grep`/`git show`). Каждое состояние — `[FACT, shell-evidence]`; ничего не выдумано.

---

## [FACT] Phase-3.6 stub→L2 array CLOSED on origin/main (triple-verified shell-audit)

Бэклог IL-538 («19 SPEC-LOCKED-STUB», «ledger 12 stubs P1») **STALE**. На текущем origin/main:
- маркер-счётчик IL-538 шага-1 ловил **слова** «STUB»/«TODO» в комментариях + Protocol-`...`-тела + legacy/crypto-адаптеры — **не пустые тела**;
- **ledger 12 «stubs» = 7 crypto-адаптеров** (legacy_crypto_* + midaz_crypto_stub), уже **PARKED** в PLAN E10 (PAYBIS-cutover gated), **не** core-ledger;
- top-marker services имеют **0 реальных** NotImplementedError (вне legacy/crypto-stub) + полные модули + тест-сьюты.

---

## Former-backlog services → current state [FACT, shell-evidence]

| Service | State | Evidence |
|---|---|---|
| `ledger` (core `gl_service.py`) | **REAL** | create_account/get_balance/post_journal_entry/commit-cancel-revert/approve-reject_high_value/_validate_balance (verified L125/170/176/306/392); tests test_ledger_lifecycle/test_api_ledger/test_ledger_adapter |
| `ledger` crypto adapters | **parked-crypto** (PAYBIS-cutover gated) | legacy_crypto_{wallet,processing,rpc} + midaz_crypto_stub — PLAN E10 PARKED; FROZEN CryptoLedgerPort/CryptoRpcPort |
| `transaction_monitor` | **REAL** | 0 real NotImplementedError; full module + tests |
| `consumer_duty` | **REAL** | 0 real NotImplementedError; full module + tests (+ `models_v2` = consolidation backlog, not gap) |
| `consent_management` | **REAL** | 0 real NotImplementedError; full module + tests |
| `recon` | **REAL** + protocol-contracts | concrete BreachDetector / FCARegDataClient / MockFCARegDataClient implemented; `...` bodies = Protocol defs (see below) |
| `auth` (core) | **REAL** | provider-wiring stub fenced separately (Twilio) |
| `compliance` (core) | **REAL** | provider-wiring stub fenced separately (Sumsub) |
| `payment` (core) | **REAL** | provider-wiring stub fenced separately (Modulr) |
| `fraud` (core) | **REAL** | provider-wiring stub fenced separately (Sardine) |
| `complaints` | **REAL** (case-prep) | `prepare_case` implemented (BT-010); only `fos_portal_submit` fenced (FOS portal, P1) |
| `backup` | **REAL** + port-default | `OffsiteUploadPort` default raises at factory-resolution until offsite provider wired |

---

## Provider-wiring stubs registry — LIVE-INTEGRATION gates (NOT impl backlog)

> **[FACT, shell-evidence]** Это ВСЕ остаточные NotImplementedError вне legacy/crypto. Каждый — **прямой аналог `FencedLivePaybisTransport`**: заглушка ЗА портом, fenced до реальных provider-creds/API. **Owned by operator** (creds/contracts), не Phase-3.6 gap. Аудит оператора назвал 3; shell-audit подтвердил их и нашёл ещё 3 того же класса (полный список ниже).

| Stub | Port | External provider (gate) |
|---|---|---|
| `services/auth/production/twilio_otp_stub.py` | OtpDeliveryPort | Twilio / SendGrid |
| `services/compliance/production/sumsub_http_stub.py` | KYCWorkflowPort | Sumsub HTTP |
| `services/payment/production/modulr_sepa_stub.py` | PaymentRailPort | Modulr SEPA |
| `services/fraud/sardine_adapter.py` | FraudScoringPort | Sardine fraud API («raises NotImplementedError to prevent accidental use in production») |
| `services/complaints/fos_escalation.py` (`fos_portal_submit`) | FOS portal | FCA FOS portal API (P1) — case-prep уже REAL |
| `services/backup/offsite_upload_port.py` | OffsiteUploadPort | offsite storage (factory-resolution default) |

---

## Protocol-contract clarification

`recon` `...`-тела — это **контракты**, не gaps: `BreachClientProtocol` (`services/recon/breach_detector.py:47`), `FCARegDataClientProtocol` (`services/recon/fca_regdata_client.py:36`) — «test injection point». Конкретные классы (`BreachDetector`, `FCARegDataClient`, `MockFCARegDataClient`) реализованы. Аналогично `FOSCaseStorePort` / `OffsiteUploadPort` — Protocol-ports с реализованными in-memory/concrete адаптерами.

---

## Safeguarding-engine correction (supersedes IL-535 / 2026-06-25 row / IL-567 §4)

**[FACT, shell-evidence origin/main]** `services/safeguarding-engine` (P0 CASS 15) — **REAL/implemented, НЕ stub**:
- `app/services/*` — все 6 файлов с реальными телами: `NotImplementedError = 0` **и** bare `pass`/`...` = 0
  (verified): `audit_logger.py` 3655B, `breach_service.py` 4972B, `position_calculator.py` 3843B,
  `reconciliation_service.py` 4146B, `safeguarding_service.py` 5177B, `scheduler.py` 1673B.
- substantive logic (return/await/Decimal/raise/self): safeguarding_service 10 defs/20 logic-lines;
  breach_service 8/21; position_calculator 7/25; reconciliation_service 8/21; audit_logger 8/18.
- full test suite present (verified): `test_breach_service`, `test_position_calculator`,
  `test_reconciliation_service`, `test_audit_logger`, `test_api_{breach,reconciliation,safeguarding}`,
  `test_internal_coverage`, `test_mcp_tools`.

**[FACT, governance]** GAP-REGISTER **GAP-003** (Safeguarding Engine CASS 15) = ✅ **DONE**; **S6-15** Recon
Engine v2 = ✅ DONE (PR #24, 34 tests); **S6-01/02/05** DONE; **IL-541** safeguarding coverage 95.82% (earlier).

**[CORRECTION — append-only, NOT editing IL-535]** Прежние записи помечавшие safeguarding-engine как
unimplemented — **STALE, superseded** текущим main, где он implemented + tested + GAP-003 DONE:
- **IL-535** («safeguarding-engine runtime unimplemented; 40 NotImplementedError; STOP») — **superseded**
  (referenced, **НЕ редактируется/не перенумеровывается** — append-only, ADR-119/I-28).
- **`EMI-IMPLEMENTATION-STATE-2026-06-25.md`** row (SPEC-LOCKED-STUB) — stale.
- **IL-567 §4** (этой dossier-серии, на ветке `neuronext-retirement-adr`) повторил stale-claim из
  06-25-дока — **тоже superseded этим FACT** (честная коррекция собственной записи sub-B).

---

## [CONCLUSION]

Return-to-base primary track (**Phase-3.6 stub→L2**) **не имеет оставшихся actionable-stubs**: ledger core
(verified earlier), top marker-services (verified earlier), **и теперь safeguarding-engine** (verified REAL +
tested + GAP-003 DONE) — все REAL. Всё остаточное — **EXTERNAL-PROVIDER-GATED** (Twilio / Sumsub / Modulr /
Sardine / FOS-portal / offsite-upload / PAYBIS) → **operator-input dependent** (creds + contracts), тот же
паттерн, что PAYBIS Wave B. **Внутреннего impl-backlog не осталось**; next work = operator-input-dependent
(provider creds, SRC-06, или новый feature-track).

### Next-priority candidates (для выбора оператором — НЕ auto-start)
- **(a) provider-wiring live integrations** — каждая требует creds+contract (как PAYBIS Wave B): Twilio, Sumsub, Modulr, Sardine, FOS-portal, offsite-upload, PAYBIS.
- **(b) consolidation backlog (PLAN E10):** `_v2`×3 + `*/legacy/*`×22 — каждый own ADR-102 dup-audit + consumer-graph.
- **(c)** любой новый feature-track.

> Ни один из (a)/(b)/(c) не запускается автоматически — operator выбирает приоритет.

---

## fx_engine + complaints correction (stub-counts unreliable)

**[FACT, shell-evidence origin/main] `fx_engine` = REAL, НЕ stub** (EMI-IMPLEMENTATION-STATE claimed «15 stubs, 0 tests» — **оба ложны**):
- **0 NotImplementedError** во всех 8 файлах (verified): `fx_agent` 5042B, `fx_compliance_reporter` 5557B,
  `fx_executor` 5473B, `fx_quoter` 5757B, `hedging_engine` 5324B, `models` 8533B, `rate_provider` 9914B,
  `spread_calculator` 3576B.
- **8 test-файлов СУЩЕСТВУЮТ** (claim «0 tests» false): `tests/test_fx_engine/test_{fx_agent,fx_executor,
  fx_quoter,hedging_engine,models,rate_provider,spread_calculator}.py`. Consumer: `api/routers/fx_engine.py`.
- **[FACT, `MIG-RESIDUAL-GENUINE-GAP-REGISTER-2026-06-25.md:70`]** `fx_engine`/`fx_exchange` = **Trading-core =
  RESCOPE/DROP** (out of EMI-license scope; EMI = e-money institution, не exchange; «decide-then-drop,
  SERVER-AUDIT-REQUIRED», P3). → fx_engine **НЕ impl/refactor-target — это drop-decision** (operator/server-audit).
  *(Нюанс, :80: FX-для-treasury/ALM числится **COVERED** depth-build — drop касается trading/exchange-аспекта, не treasury-FX.)*

**[FACT, shell-evidence] `complaints` = REAL** (claim «8 stubs» false): **0 реальных NotImplementedError** в
`services/complaints/**` — `prepare_case` real; единственный fenced = `fos_portal_submit` (FOS portal API, P1,
**provider-gated**); прочие упоминания «NotImplementedError» в `fos_escalation.py` (L4/94) — **комментарии**
(«replacing/replaces the old NotImplementedError»), не gaps.

## Refactor/migration track conclusion

- **BANXE.RAR → EMI backend migration = ACCEPTED/CLOSED**; residual genuine-gaps = **0** (всё
  COVERED/RESCOPE/DROP/net-new per `MIG-RESIDUAL-GENUINE-GAP-REGISTER-2026-06-25.md`). Нет оставшегося
  legacy-порта к миграции.
- **EMI-IMPLEMENTATION-STATE-2026-06-25 stub-counts = MECHANICAL-GREP-UNRELIABLE:** disproven для
  safeguarding-engine (40→0), ledger (core real), consumer_duty (3→real), **fx_engine (15→0)**,
  **complaints (8→~0)**. Счётчики смешивают provider-wiring stubs + Protocol-контракты +
  legacy-crypto-adapter NotImplementedError с реальными gap-ами.
- **Real residual NotImplementedError = external-provider-wiring** (Twilio/Sumsub/Modulr/Sardine/FOS) —
  gated на creds, **не** impl-backlog.
- **Единственная genuinely-actionable refactor-работа = consolidation E10** (auth/legacy×6, compliance/legacy×5,
  payment/legacy×4, ledger/legacy×3 + recon/consumer_duty/reporting `_v2`) — но **в основном PARKED** на live
  consumer-ах; orphan-deletions (auth `role_guard` + `sca`/`totp`) требуют **operator go** для destructive-шага.

> **RECOMMENDATION (не decision — operator/central call, НЕ sub-B):** stub-таблицу
> `EMI-IMPLEMENTATION-STATE-2026-06-25` следует **re-baseline через TRUE-body audit** (реальные тела vs
> grep-маркеры), т.к. её counts системно завышены.

---

## FINAL re-baseline (16/16 REAL) — impl-backlog exhausted

**[FACT, shell-evidence origin/main]** Полный TRUE-body re-baseline всех 16 stub-claimed сервисов:
**0 истинных impl-stubs** (TRUE NotImpl = excl `legacy/` + `*_stub.py` + comments + Protocol `...`).
Sample + ledger-crux verified sub-B напрямую; counts per shell-audit.

| Service | claimed-stubs | TRUE NotImpl | tests |
|---|---|---|---|
| safeguarding-engine | 40 | **0** | 11 |
| fx_engine | 15 | **0** | 8 |
| complaints | 8 | **0** | 5 |
| compliance | 7 | **0** | 36 |
| payment | 4 | **0** | 24 |
| kyb_onboarding | 4 | **0** | 8 |
| fraud_tracer | 4 | **0** | 2 |
| backup | 4 | **0** | 7 |
| fatca_crs | 3 | **0** | 4 |
| consumer_duty | 3 | **0** | 11 |
| client_statements | 3 | **0** | 4 |
| auth | 3 | **0** | 7 |
| reporting | 2 | **0** | 22 |
| observability | 2 | **0** | 8 |
| fraud | 2 | **0** | 6 |
| **ledger** | 12 | **"4" — ВСЕ в `legacy/`** (см. ниже) | core REAL |

**ledger-нюанс [verified]:** «4 TRUE NotImpl» = legacy-crypto адаптеры (`legacy/legacy_crypto_processing_adapter.py:162,169`
+ `legacy/legacy_crypto_wallet_adapter.py:127,136`) — **REWRITE-7 delegate-hint stubs, уже PARKED-superseded-on-cutover**
(E10/PAYBIS); path-relative grep-фильтр их пропускал. ledger **core** (`gl_service.py`, `midaz_adapter.py`,
`payment_posting_service.py`, `approval_models.py`) = **REAL** (verified). 19 bare `...` = Protocol-defs
(`crypto_ledger_port.py` ×9 + `ledger_port.py`) — контракты, не пустой impl.

### Residual-NotImpl taxonomy (ни один не impl-backlog)
- **(a) legacy-crypto adapters** → PARKED, удаляются на Wave C PAYBIS-cutover.
- **(b) Protocol/ABC `...` bodies** → контракты (`CryptoLedgerPort`/`CryptoRpcPort`/`LedgerPort`).
- **(c) provider-wiring stubs** (`twilio_otp_stub`, `sumsub_http_stub`, `midaz_crypto_stub`, `modulr_sepa_stub` — verified present) → external-provider creds-gated.

### [CONCLUSION — FINAL]
`EMI-IMPLEMENTATION-STATE-2026-06-25` stub-table — **FULLY DISPROVEN (16/16 services REAL)**. **Внутреннего
impl/refactor-backlog («stub→L2») НЕ осталось.** BANXE.RAR→EMI migration **CLOSED** (residual genuine-gaps=0).
Единственная doable-без-внешних-входов refactor-работа = **consolidation E10 destructive orphan-deletions**
(`auth/role_guard` + `sca`/`totp`) — требует **operator go** для destructive-шага. Всё прочее **operator/creds-gated**
(provider-wiring, fx_engine drop-decision, M2.8 roster, PAYBIS live).

> **RECOMMENDATION (не decision — operator/central):** пометить `EMI-IMPLEMENTATION-STATE-2026-06-25`
> **superseded-by-this-refresh** (этот файл — append-only reference; **НЕ редактируется** sub-B).

---

### Refs
IL-538 (superseded backlog, referenced — not edited); banxe-emi-stack origin/main shell-audit (gl_service.py, twilio_otp_stub/sumsub_http_stub/modulr_sepa_stub/sardine_adapter/fos_escalation/offsite_upload_port, breach_detector/fca_regdata_client); PLAN E10 (crypto parked + consolidation backlog); ADR-126/108/114; PAYBIS Wave-A/B (FencedLivePaybisTransport analogue); ADR-119/I-28.
