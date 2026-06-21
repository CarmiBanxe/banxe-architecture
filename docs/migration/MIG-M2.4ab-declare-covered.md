# MIG-M2.4a + M2.4b — declare-covered reconcile-note (BANXE.RAR → EMI)

<!-- Source: docs/migration/MIG-M2.4ab-declare-covered.md | Date: 2026-06-21 | Lane: BANXE.RAR → EMI cross-context migration | advisory-only | No code, no scaffold, no merge. Resolves the MIG-M2.4a blocker (PR #643 / IL-400) per operator decision C (declare-covered, fold a+b). -->

> **Resolves** the MIG-M2.4a blocker (scheduled-payments already exists in banxe-emi-stack; PR #643 /
> IL-400). **Operator decision (2026-06-21): C — declare-covered, fold M2.4a + M2.4b.** The mounted
> `scheduled_payments` engine satisfies the domestic-scheduled + standing-orders delta. **No scaffold,
> no code, no merge.** Audit read-only on origin/main `3228d3d`.

## 1. Rationale (anti-duplication)

Mandatory preflight found the scheduled-payments capability **already mounted** in banxe-emi-stack. A
new domestic-scheduled scheduler would duplicate the existing engine (scheduling + execution +
recurrence + failure machinery) → **ADR-102 HARD RULE: reconcile, not scaffold** (same posture as M2.4 /
M2.5 / M2.3 / M2.5-BIF). M2.4a + M2.4b are therefore **done-by-existing**, folded into this note.

## 2. Existing surface (mount-status + mock-vs-live, audited)

| Item | Evidence |
|---|---|
| Router | `api/routers/scheduled_payments.py` (IL-SOD-01, Phase 32) — **MOUNTED** (`api/main.py` include_router); **non-mock** (0 mock-mentions) |
| Standing-order engine | `services/scheduled_payments/standing_order_engine.py` |
| Execution engine | `services/scheduled_payments/schedule_executor.py` — real `execute_due_payments(as_of)` (**live executor, not a stub**; does not call Midaz/ledger directly — routes via the payment layer) |
| Direct-debit engine | `services/scheduled_payments/direct_debit_engine.py` |
| Failure handling | `services/scheduled_payments/failure_handler.py` |

Endpoints: `POST /v1/standing-orders` (+cancel/pause/resume) + `GET /v1/standing-orders/customers/{id}`;
`/direct-debits/mandate` (+authorise/cancel); `/scheduled-payments/{customer}/upcoming` + `/failures`.

## 3. Coverage mapping (M2.4 gap-audit delta-candidate → existing capability)

| M2.4 gap-audit delta-candidate | Existing capability | Status |
|---|---|---|
| **M2.4a — domestic-scheduled payments** (future-dated/recurring) | `scheduled_payments` upcoming + `schedule_executor.execute_due_payments` + recurrence in `standing_order_engine` | **COVERED** |
| **M2.4b — standing-orders** | `POST /v1/standing-orders` (+cancel/pause/resume) + `standing_order_engine` | **COVERED** |
| (related) direct debits | `/direct-debits/mandate` + `direct_debit_engine` | covered (bonus — beyond delta) |

## 4. Gaps (deferred, optional — not part of "covered")

- **OB/PISP scheduled-consent facade** — OBIE `domestic-scheduled-payment-consents` +
  `domestic-scheduled-payments` (TPP-initiated, consent-gated) that **consumes** the existing
  `scheduled_payments` engine + the M2.4-INT `PaymentEngineContract`. This is an **integration facade**
  (like MIG-M2.4-INT for PISP), **not** a new scheduler — deferred, optional, only if a distinct OB/PISP
  scheduled flow is product-required.
- **Live execution wiring** of `schedule_executor` to the live payment rail / Midaz LedgerPort — a
  production-activation step, operator-gated; out of scope for this migration note.

## 5. Decision

- **MIG-M2.4a + M2.4b: CLOSED — done-by-existing.** No scaffold.
- **`scheduled_payments` (IL-SOD-01) = canonical scheduled-payments home** (standing orders, direct
  debits, scheduled/future-dated, recurrence, failures).
- **Legacy OB `domestic-scheduled` / `standing-order` = RETIRE after** (covered by the canonical home;
  merge-then-retire per the MIG-M1.1 open-banking lineage).

## 6. Backlog update (remaining OB delta + optional integrations)

| Item | Status |
|---|---|
| M2.4a domestic-scheduled / M2.4b standing-orders | **CLOSED (covered)** — removed from scaffold backlog |
| M2.4c — file (bulk/batch) payments (+consents) | open (OB delta) — preflight first (may also be covered) |
| M2.4d — international-scheduled payments (+consents) | open (OB delta) — preflight first |
| M2.4e — intl per-consent funds-confirmation + CBPII consent lifecycle | open (OB delta) — preflight first |
| OB-INT scheduled-consent facade | optional (M2.4-INT family; deferred) |
| ABS delta/re-home · M2.3 auth delta · KYC/KYB/AML (I-27) · M2.8 frontend (roster audit) | open (per MIG-M2.8 backlog) |

## 7. Preconditions / next

- M2.4a+b closed unblocks moving to **M2.4c–e** (each with mandatory preflight — may also be
  covered/blocker per the established discipline) **or** the larger **ABS delta/re-home** / **M2.3 auth
  delta** backlog.
- KYC/KYB/AML stays gated on **I-27 HITL-L4 sign-off**; M2.8 frontend stays gated on the **roster
  audit** (banxe-platform vs banxe-ui).

## References
`docs/migration/MIG-M2.4ab-declare-covered.md`; `MIG-M2.4a-BLOCKER-scheduled-payments-already-exists.md`
(IL-400, PR #643); read-only origin/main `3228d3d` banxe-emi-stack `api/routers/scheduled_payments.py`
(IL-SOD-01) + `services/scheduled_payments/{standing_order_engine,schedule_executor,direct_debit_engine,failure_handler}.py`
+ `api/main.py` + `services/open_banking/m24_int_bridge.py` (M2.4-INT); MIG-M2.4 (open-banking gap-audit),
MIG-M2.4-INT (integration precedent), MIG-M2.8 (acceptance backlog); ADR-102, ADR-103, ADR-059-A, I-27,
I-28; /tmp/banxe-migration-mapping-v0.claude.txt.
