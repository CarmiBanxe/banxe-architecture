# Session Canon: 2026-05-09 — Sprint 10 BANXE.RAR Dobor

**Status:** ACTIVE
**Date:** 2026-05-09
**Operator:** Moriel Carmi
**Repo:** CarmiBanxe/banxe-architecture
**Source listing:** docs/inventories/BANXE-RAR-LISTING-2026-05-06.txt (100488 files)
**Category map:** docs/inventories/BANXE-RAR-CATEGORY-MAP-2026-05-06.md

---

## Scope (Sprint 10)

Goal: classify **deferred** BANXE.RAR fragments (≈58439 files) into PASS / REWRITE / REJECT relative to EMI BANXE AI BANK.

Priority candidates (per Phase 3 notes and EMI roadmap):

- `banxe/banxe-shared-libs` — DTOs, error maps, utilities
- `internal_dev/support-services` — internal tools
- `internal_dev/trigger-system-services` — event triggers / cron
- `internal_dev/fintech-services` — fintech utilities
- `banxe-digital/v-accounting` — accounting / AML hooks
- `banxe-digital/crypto-exchange-api` — exchange API
- `banxe/banxe-uikit` — UI components
- `consul-configs/*` — config-only
- `neuron/*` — separate ecosystem, EMI relevance TBC

---

## Classification legend

- **PASS:** Domain logic / models / mappings worth porting into EMI stack behind existing ports/adapters.
- **REWRITE:** Legacy implementation discarded; only domain idea / flow kept, re-implemented natively in EMI.
- **REJECT:** Out of EMI scope, obsolete, or UI-only / infra-only.

Each fragment entry MUST include:
- BANXE.RAR path prefix
- Files count (from listing)
- Proposed classification (PASS / REWRITE / REJECT)
- If PASS/REWRITE: intended EMI boundary (module + port)

---

## Candidates — initial classification (Draft)

_TODO_

---

## Next action

Derive exact path counts for the first priority candidate from `BANXE-RAR-LISTING-2026-05-06.txt` and append the first classification block here.

---

## Classification block 1 — `banxe/banxe-shared-libs`

**Files:** 2481 (verified: `grep -c '^banxe/banxe-shared-libs/' BANXE-RAR-LISTING-2026-05-06.txt`)
**Stack:** TypeScript monorepo (package.json + packages/)
**Top-level packages:** abs-common, bank-common, common, core, graphql, rabbit-mq

### Per-package classification

| Package | Classification | EMI boundary | Rationale |
|---|---|---|---|
| `packages/bank-common` | **REWRITE-reference** | `services/payment/payment_port.py` + `services/ledger/ledger_port.py` (domain DTO alignment only) | Banking-domain DTOs/types — extract semantics, not code (TS → Python rewrite already covered by FROZEN ports) |
| `packages/abs-common` | **REWRITE-reference** | `services/payment/legacy/legacy_abs_payment_adapter.py` (already exists) | ABS payment domain — already mirrored in legacy adapter; use only for cross-check of state machine / fields |
| `packages/common` | **REJECT** | — | Generic TS utils — EMI has Python-native equivalents |
| `packages/core` | **REJECT** | — | Generic TS core — out of EMI Python scope |
| `packages/graphql` | **REJECT** | — | EMI uses REST/FastAPI; no GraphQL surface in canon roadmap |
| `packages/rabbit-mq` | **REJECT** | — | EMI event bus already implemented (`services/events/event_bus.py`); no TS adapter port |

### Net decision

- **Overall:** REWRITE-reference (2 packages: bank-common, abs-common) + REJECT (4 packages: common, core, graphql, rabbit-mq).
- **No code import** into EMI; only domain semantics cross-checked against existing FROZEN ports (`PaymentRailPort`, `LedgerPort`, `CryptoLedgerPort`).
- **No new EMI files** required from this fragment in Sprint 10.


---

## Classification block 2 — `banxe-digital/v-accounting`

**Files:** 785 (verified: `grep -c '^banxe-digital/v-accounting/' BANXE-RAR-LISTING-2026-05-06.txt`)
**Stack:** NestJS / TypeScript + GraphQL + TypeORM + RabbitMQ
**Top-level src modules:** account, address, amplitude, app, app-config, auth, balance, config, crypto-exchange-api, documentation, dust-transfer, file, income, migrations, notification, order, payment-account, pro-wallet, project, rabbitmq, rabbitmq-publisher, report, shared, transaction, user

### Per-module classification

| Module | Classification | EMI boundary | Rationale |
|---|---|---|---|
| `src/account` | **REWRITE-reference** | `services/ledger/ledger_port.py` + `services/ledger/midaz_adapter.py` | Account domain — cross-check semantics against Midaz GL accounts |
| `src/balance` | **REWRITE-reference** | `services/ledger/*` + `services/recon/recon_port.py` | Balance projection — cross-check against LedgerPort + recon engine |
| `src/transaction` | **REWRITE-reference** | `services/ledger/midaz_adapter.py` (TransactionRecord) + `services/payment/payment_port.py` | Transaction domain — semantics already mirrored in FROZEN ports |
| `src/payment-account` | **REWRITE-reference** | `services/payment/payment_port.py` | Payment account aggregation — cross-check only |
| `src/income` | **REWRITE-reference** | `services/recon/*` + `services/safeguarding-engine/*` | Income recognition — cross-check vs safeguarding/recon flows |
| `src/report` | **REWRITE-reference** | `services/client_statements/statement_generator.py` + `services/recon/*` | Reporting domain — semantics for statements/recon outputs |
| `src/order` | **REWRITE-reference** | `services/payment/*` (order→payment intent mapping) | Order→payment mapping — cross-check only |
| `src/dust-transfer` | **REJECT** | — | Crypto-exchange micro-flow — out of EMI core scope |
| `src/pro-wallet` | **REJECT** | — | Product-level wallet feature — out of EMI core scope |
| `src/crypto-exchange-api` | **REJECT (duplicate)** | — | Already covered by separate repo `banxe-digital/crypto-exchange-api` (Wave E) |
| `src/auth` | **REJECT** | — | Auth already closed by Wave A (`services/auth/*`) |
| `src/notification` | **REJECT** | — | EMI uses dedicated channels (OTP/email adapters Sprint 6) |
| `src/rabbitmq`, `src/rabbitmq-publisher` | **REJECT** | — | EMI event bus already implemented (`services/events/event_bus.py`) |
| `src/file`, `src/address`, `src/amplitude`, `src/app`, `src/app-config`, `src/config`, `src/documentation`, `src/migrations`, `src/project`, `src/shared`, `src/user` | **REJECT** | — | Generic infra/UI/config — Python-native equivalents in EMI |

### Net decision

- **Overall:** REWRITE-reference (7 modules: account, balance, transaction, payment-account, income, report, order) + REJECT (rest, including crypto-exchange-api as duplicate of Wave E source).
- **No code import** into EMI; only domain semantics cross-checked against existing FROZEN ports (`LedgerPort`, `PaymentRailPort`, `recon_port`, safeguarding flows).
- **No new EMI files** required from this fragment in Sprint 10.


---

## Classification block 3 — `internal_dev/*`

**Total files:** 5639 (finthech-services 580 + support-services 2819 + trigger-system-services 2240)

### `internal_dev/finthech-services` (580 files)

| Submodule | Classification | EMI boundary | Rationale |
|---|---|---|---|
| `auto-acquiring` | **REWRITE-reference** | `services/payment/*` (acquiring flows, future) | Acquiring automation semantics — cross-check only |
| `auto-reconciliation` | **REWRITE-reference** | `services/recon/*` (recon engine + midaz_reconciliation) | Auto-recon flow — semantics for daily recon pipeline |
| `crypto-admin-panel` | **REJECT** | — | Admin UI — out of EMI core scope |
| `document-import` | **REWRITE-reference** | `services/kyc/*` (document ingestion) | Document import flow — cross-check vs SumSub adapter |
| `fin-monitoring` | **REWRITE-reference** | `services/safeguarding-engine/*` + `services/recon/*` | Financial monitoring — cross-check safeguarding/recon alerts |

### `internal_dev/support-services` (2819 files)

| Submodule | Classification | EMI boundary | Rationale |
|---|---|---|---|
| `clarification-forms` | **REWRITE-reference** | `services/compliance/*` (legacy adapters) | Compliance clarification flow — semantics only |
| `edd-forms` | **REWRITE-reference** | `services/compliance/legacy/legacy_sumsub_adapter.py` (I-04 EDD) | EDD form domain — cross-check threshold + state machine |
| `jira-scrapper` | **REJECT** | — | Ops tooling — out of EMI scope |
| `sendgrid-webhook` | **REJECT** | — | EMI has dedicated `SendGridOtpAdapter` (Sprint 6) |

### `internal_dev/trigger-system-services` (2240 files)

| Submodule | Classification | EMI boundary | Rationale |
|---|---|---|---|
| `triggers` | **REWRITE-reference** | `services/events/event_bus.py` + cron jobs | Event triggers — cross-check semantics |
| `services` | **REWRITE-reference** | `services/events/*` | Trigger service runners — cross-check |
| `control` | **REJECT** | — | Admin/control plane UI |
| `dev-tools` | **REJECT** | — | Internal dev tooling |
| `frontend` | **REJECT** | — | UI — out of EMI scope |

### Net decision

- **Overall:** REWRITE-reference (8 submodules across 3 repos) + REJECT (6 submodules).
- **No code import** into EMI; only domain semantics for recon, safeguarding, KYC document flows, EDD, and event triggers.
- **No new EMI files** required from this fragment in Sprint 10.

