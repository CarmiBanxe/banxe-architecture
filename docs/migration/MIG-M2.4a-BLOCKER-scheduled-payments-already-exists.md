# MIG-M2.4a — BLOCKER: scheduled-payments surface already exists in banxe-emi-stack (no scaffold)

<!-- Source: docs/migration/MIG-M2.4a-BLOCKER-scheduled-payments-already-exists.md | Date: 2026-06-21 | Lane: BANXE.RAR → EMI cross-context migration | advisory-only | No code, no scaffold, no merge. ADR-102 duplication stop-barrier. -->

> **STATUS: BLOCKED.** Mandatory read-only preflight + ADR-102 Duplication Audit stopped MIG-M2.4a
> **before any scaffold.** banxe-emi-stack **already implements a mounted scheduled-payments surface**
> (Standing Orders + Direct Debits + scheduled-payments engine). Scaffolding a new domestic-scheduled
> scheduler would duplicate it → **STOP, no scaffold** (ADR-102 HARD RULE; same posture as MIG-M2.4 /
> M2.5 / M2.3). Docs-only blocker + IL-shard.

## 1. Preflight outcome (read-only, origin/main 3228d3d)

| Surface | Existing in emi-stack | Mounted? |
|---|---|---|
| Standing Orders + Direct Debits + scheduled-payments | `api/routers/scheduled_payments.py` (IL-SOD-01, Phase 32) | **MOUNTED** (main.py:232) |
| Scheduling / execution engine | `services/scheduled_payments/`: `standing_order_engine`, **`schedule_executor`**, `direct_debit_engine`, `failure_handler`, `notification_bridge`, `scheduled_payments_agent`, `models` | — |

Endpoints: `POST /v1/standing-orders` (+cancel/pause/resume) + `GET /v1/standing-orders/customers/{id}`;
`POST /v1/direct-debits/mandate` (+authorise/cancel); `GET /v1/scheduled-payments/{customer}/upcoming`
+ `/failures`. (OB/PISP markers = 0; scheduled markers = 27 — this is the **internal scheduled-payments
bounded context**, not the open_banking PISP path.)

## 2. The duplication

MIG-M2.4a proposed scaffolding a **domestic-scheduled-payment** surface (port/DTO + state-machine +
`execution_date`/recurrence + a scheduler). The **scheduling + execution + standing-order + recurrence +
failure machinery already exists** (`standing_order_engine` + `schedule_executor` + `failure_handler`,
mounted, IL-SOD-01). A new OB-side scheduler would **duplicate** that engine → ADR-102 violation
(existing surface has registered consumers + tests).

The M2.4 gap-audit had listed "domestic-scheduled payments" + "standing-orders" as legacy → emi-stack
GAPs; the preflight now shows they are **already present** (in the dedicated `scheduled_payments` domain,
not the `open_banking` PISP router). This corrects the M2.4 gap-matrix.

## 3. Distinction (what is genuinely absent)

- **Present (do not duplicate):** the internal scheduled-payments **engine** (standing orders, direct
  debits, schedule execution, recurrence, failures).
- **Possibly absent (the only candidate delta):** a **thin OB/PISP layer** — OBIE
  `domestic-scheduled-payment-consents` + `domestic-scheduled-payments` (TPP-initiated, consent-gated,
  future-dated) that **consumes** the existing `scheduled_payments` engine + the M2.4-INT
  `PaymentEngineContract` — i.e. an **integration**, not a new scheduler.

## 4. Decision required (operator/governance)

- **A — reconcile/gap-audit** (mirror M2.4/M2.5): ADR-102 audit of legacy OB `domestic-scheduled` +
  `standing-order` vs the existing `scheduled_payments` engine → delta + keep/merge/retire. No scaffold.
- **B — thin OB-integration** (mirror M2.4-INT): a thin `open_banking` domestic-scheduled-consent layer
  consuming the EXISTING `scheduled_payments` engine + `PaymentEngineContract` (M2.4-INT) — advisory,
  no new scheduler, no live execution. (Only if a distinct OB/PISP scheduled flow is required.)
- **C — declare covered**: the existing `scheduled_payments` surface satisfies the M2.4a delta;
  mark M2.4a done-by-existing and proceed to another follow-up (M2.4b standing-orders is ALSO covered →
  likely same outcome; or ABS delta/re-home).

## 5. What was / was NOT done

- **Done (read-only):** mandatory preflight (`services/open_banking` + `api/` grep for scheduled/
  standing-order/recurring) + classification of `scheduled_payments.py` (IL-SOD-01); confirmed
  consume-targets (`m24_int_bridge.py` PaymentEngineContract/AccountSoTProjection) present; this blocker
  doc + IL-shard (isolated worktree, Rule 1/6).
- **NOT done:** no scaffold (any repo); no domestic-scheduled module; no backend PR; banxe-emi-stack
  untouched (0 `mig-m2.4a` factory branches); KYC carve-out not touched; no merge.

## 6. Recommended next step

Operator resolves §4 (recommend **C — declare covered**, or **B — thin OB-integration** only if a
distinct OB/PISP scheduled flow is product-required; **A** if a full delta audit is wanted). Note: the
M2.4b (standing-orders) backlog item is **also already covered** by this same `scheduled_payments`
surface — likely fold M2.4a+M2.4b into one reconcile/covered outcome. Correct the M2-backlog:
**domestic-scheduled + standing-orders = already in emi-stack (`scheduled_payments`, IL-SOD-01).**

## References
`docs/migration/MIG-M2.4a-BLOCKER-scheduled-payments-already-exists.md`; read-only origin/main `3228d3d`
banxe-emi-stack `api/routers/scheduled_payments.py` (IL-SOD-01) + `services/scheduled_payments/*` +
`api/main.py` + `services/open_banking/m24_int_bridge.py` (M2.4-INT consume-targets); MIG-M2.4
(open-banking reconcile/gap-audit — delta listed domestic-scheduled/standing-orders), MIG-M2.4-INT
(integration precedent), MIG-M2.5 / M2.3 (reconcile precedents); ADR-102, ADR-103, ADR-059-A, I-01,
I-05, I-27, I-28; /tmp/banxe-migration-mapping-v0.claude.txt.
