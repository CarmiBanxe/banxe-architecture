# MIG-M2.4c — BLOCKER: batch/file/bulk-payments surface already exists in banxe-emi-stack (no scaffold)

<!-- Source: docs/migration/MIG-M2.4c-BLOCKER-batch-payments-already-exists.md | Date: 2026-06-22 | Lane: BANXE.RAR → EMI cross-context migration | advisory-only | No code, no scaffold, no merge. ADR-102 duplication stop-barrier. -->

> **STATUS: BLOCKED.** Mandatory read-only preflight + ADR-102 Duplication Audit stopped MIG-M2.4c
> **before any scaffold.** banxe-emi-stack **already implements a mounted batch/file/bulk-payments
> surface** (+ an OB/PISP bulk path). Scaffolding a new file/bulk-payment engine would duplicate it →
> **STOP, no scaffold** (ADR-102 HARD RULE; same posture as M2.4a / abs-posting). Docs-only blocker +
> IL-shard.

## 1. Preflight outcome (read-only, origin/main 1e39ad1)

| Surface | Existing in emi-stack | Mounted? |
|---|---|---|
| Batch-payments REST (create / items / validate / submit / dispatch / status / reconciliation) | `api/routers/batch_payments.py` (9 endpoints under `/v1/batch-payments/`) | **MOUNTED** (main.py:244) |
| Batch engine (incl. **file ingestion**) | `services/batch_payments/`: `batch_creator`, **`file_parser`**, `payment_dispatcher`, `limit_checker`, `reconciliation_engine`, `batch_agent`, `models` | — |
| **OB/PISP bulk path** | `services/open_banking/pisp_service.py` → `create_bulk_payment()` | (under open_banking) |

## 2. The duplication

MIG-M2.4c proposed scaffolding a file/bulk-payment OB surface (port/DTO + bulk/file-payment-consent
state-machine + processing). The **batch lifecycle + file parsing + dispatch + limit-check +
reconciliation machinery already exists** (`services/batch_payments/*`, mounted, with `file_parser`),
**and** the OB/PISP bulk-payment path already exists (`pisp_service.create_bulk_payment`). A new engine
would **duplicate** them → ADR-102 violation (existing surfaces have registered consumers + tests).

The M2.4 gap-audit listed "file (bulk/batch) payments (+consents)" as a legacy→emi-stack GAP; the
preflight now shows it is **already present** (the `batch_payments` domain + the OB PISP bulk method).
This corrects the M2.4 gap-matrix.

## 3. Distinction (what is genuinely absent)

- **Present (do not duplicate):** the batch/file-payments **engine** (creation, file parsing, items,
  validate, submit, dispatch, status, reconciliation) + the OB/PISP `create_bulk_payment` path.
- **Possibly absent (the only candidate):** a thin **OBIE `file-payment-consents` + `file-payments`
  consent facade** (TPP-initiated, consent-gated) that **consumes** the existing `batch_payments` engine
  + `PaymentEngineContract` (M2.4-INT) — an **integration facade**, not a new engine. Legacy
  `banxe-open-banking/src/file/` has `file-payment-consent.entity` + `file-payment.entity`.

## 4. Decision required (operator/governance)

- **A — declare-covered** (mirror M2.4a / abs-posting): batch/file/bulk-payments satisfied by the
  `batch_payments` engine + OB PISP bulk; legacy OB file-payments = retire-after; no scaffold.
- **B — thin OB-consent facade** (mirror M2.4-INT): a thin `open_banking` file-payment-consent layer
  consuming the existing `batch_payments` engine + `PaymentEngineContract` — advisory, no new engine,
  no live execution. Only if a distinct OB/PISP file-consent flow is product-required.
- **C — reconcile/gap-audit**: ADR-102 audit of legacy OB `file-payments` vs the existing
  `batch_payments` engine → delta + keep/merge/retire.

## 5. What was / was NOT done

- **Done (read-only):** mandatory preflight (`services/` + `api/` grep for file/bulk/batch-payment) +
  classification of `batch_payments` (mounted) + the OB PISP bulk path; confirmed `m24_int_bridge`
  consume-targets; this blocker doc + IL-shard (isolated worktree, Rule 1/6).
- **NOT done:** no scaffold (any repo); no file/bulk-payment module; no backend PR; banxe-emi-stack
  untouched (0 `mig-m2.4c` factory branches); `ledger.py`/Midaz/KYC carve-out not touched; no merge.

## 6. Recommended next step

Operator resolves §4 (recommend **A — declare-covered**, or **B — thin OB-consent facade** only if a
distinct OB/PISP file-consent flow is required). Then proceed to **M2.4d** (international-scheduled —
preflight-first; note M2.4a showed scheduled is covered → M2.4d likely covered too) / **M2.4e** (intl
funds-confirmation + CBPII — preflight-first; M2.4 reconcile showed CBPII `/cbpii/check` exists).
Correct the backlog: **file/bulk/batch-payments = already in emi-stack (`batch_payments`, mounted).**

## References
`docs/migration/MIG-M2.4c-BLOCKER-batch-payments-already-exists.md`; read-only origin/main `1e39ad1`
banxe-emi-stack `api/routers/batch_payments.py` + `services/batch_payments/*` + `api/main.py` +
`services/open_banking/pisp_service.py` (`create_bulk_payment`) + `services/open_banking/m24_int_bridge.py`
(M2.4-INT consume-targets); legacy `banxe-open-banking/src/file/` (file-payment-consent + file-payment
entities); MIG-M2.4 (open-banking gap-audit — file-payments delta), MIG-M2.4a (declare-covered precedent),
MIG-ABS-posting (covered precedent), MIG-M2.4-INT (integration precedent); ADR-102, ADR-103, ADR-059-A,
I-01, I-05, I-27, I-28; /tmp/banxe-migration-mapping-v0.claude.txt.
