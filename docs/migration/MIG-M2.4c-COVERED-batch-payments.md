# MIG-M2.4c — COVERED by existing batch/file-payments surface (BANXE.RAR → EMI)

<!-- Source: docs/migration/MIG-M2.4c-COVERED-batch-payments.md | Date: 2026-06-22 | Lane: BANXE.RAR → EMI cross-context migration | advisory-only | No code, no scaffold, no merge. Resolves the MIG-M2.4c blocker (PR #662 / IL-418) per operator decision A (declare-covered). -->

> **Resolves** the MIG-M2.4c blocker (batch/file/bulk-payments already exists in banxe-emi-stack; PR
> #662 / IL-418). **Operator decision (2026-06-22): A — declare-covered.** The mounted `batch_payments`
> engine (+ the OB/PISP bulk path) satisfies the file/bulk-payments delta. **No scaffold, no code, no
> merge.**

## 1. Decision

- **MIG-M2.4c (file/bulk payments OB delta): CLOSED — done-by-existing.** Covered by the
  `batch_payments` bounded context + the OB/PISP `create_bulk_payment` path. **No new engine.**
- **`batch_payments` (`api/routers/batch_payments.py` + `services/batch_payments/`) = canonical
  batch/file-payments home**; the OB/PISP bulk path lives in `pisp_service.create_bulk_payment`.
- **Legacy OB `file-payments` / `file-payment-consents` = RETIRE after** (covered; merge-then-retire per
  the MIG-M1.1 open-banking lineage).

## 2. Covering surface (on main)

| Capability | Covered by |
|---|---|
| Batch create / items / validate / submit / dispatch / status / reconciliation | `api/routers/batch_payments.py` (9 endpoints `/v1/batch-payments/`, **MOUNTED** main.py:244) |
| **File ingestion / parsing** | `services/batch_payments/file_parser.py` |
| Batch creation / limits / dispatch / reconciliation | `services/batch_payments/{batch_creator,limit_checker,payment_dispatcher,reconciliation_engine,batch_agent,models}.py` |
| OB/PISP bulk payment | `services/open_banking/pisp_service.py` → `create_bulk_payment()` |

The batch lifecycle + file parsing + dispatch + limit-check + reconciliation machinery is already
implemented and mounted — a parallel file/bulk engine would duplicate it (ADR-102).

## 3. Residual (deferred, optional — not part of "covered")

The only candidate slice is a thin **OBIE `file-payment-consents` + `file-payments` consent facade**
(TPP-initiated, consent-gated) that **consumes** the existing `batch_payments` engine + the M2.4-INT
`PaymentEngineContract` — an **integration facade** (like MIG-M2.4-INT for PISP), **not** a new engine,
no live execution. Deferred, optional, only if a distinct OB/PISP file-consent flow is product-required
(tracked under the M2.4-INT family). Legacy source: `banxe-open-banking/src/file/`
(`file-payment-consent.entity` + `file-payment.entity`).

## 4. Backlog update

- **file/bulk/batch-payments (M2.4c)** → already in emi-stack (`batch_payments`, mounted); removed from
  the OB-delta scaffold backlog.
- **Remaining OB delta:** **M2.4d** international-scheduled payments (+consents) — preflight-first (note:
  M2.4a showed scheduled is covered → M2.4d likely covered too); **M2.4e** intl per-consent
  funds-confirmation + CBPII consent lifecycle — preflight-first (note: MIG-M2.4 reconcile showed CBPII
  `/cbpii/check` already exists).
- (Sibling backlog unchanged: KYC/KYB/AML pending I-27; M2.8 frontend after roster audit.)

## 5. What was / was NOT done

- **Done (read-only):** mandatory preflight + ADR-102 audit (blocker #662); this covered-note + IL-shard.
- **NOT done:** no scaffold (any repo); no file/bulk-payment module; no backend PR; banxe-emi-stack /
  `ledger.py` / Midaz / KYC carve-out untouched; no merge.

## 6. Recommended next step

Proceed to **M2.4d** (international-scheduled — preflight-first; likely covered by `scheduled_payments`
per M2.4a) **or** **M2.4e** (intl funds-confirmation + CBPII — preflight-first; CBPII partially present
per M2.4 reconcile). After M2.4d+e the OB-delta backlog is exhausted; the only remaining gated tracks are
KYC/KYB/AML (I-27) and M2.8 frontend (roster audit).

## References
`docs/migration/MIG-M2.4c-COVERED-batch-payments.md`; `MIG-M2.4c-BLOCKER-batch-payments-already-exists.md`
(IL-418, PR #662); read-only origin/main banxe-emi-stack `api/routers/batch_payments.py` +
`services/batch_payments/*` + `services/open_banking/pisp_service.py` (`create_bulk_payment`) +
`services/open_banking/m24_int_bridge.py` (M2.4-INT); legacy `banxe-open-banking/src/file/`; MIG-M2.4
(open-banking gap-audit), MIG-M2.4a (declare-covered precedent), MIG-ABS-posting (covered precedent),
MIG-M2.4-INT (integration precedent), MIG-coverage-acceptance (IL-415/416); ADR-102, ADR-103, ADR-059-A,
I-01, I-05, I-27, I-28; /tmp/banxe-migration-mapping-v0.claude.txt.
