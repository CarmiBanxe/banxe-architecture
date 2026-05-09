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

