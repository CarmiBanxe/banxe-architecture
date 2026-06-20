# MIG-M2.5 — BLOCKER: ABS surface already exists in banxe-emi-stack (no scaffold)

<!-- Source: docs/migration/MIG-M2.5-BLOCKER-abs-already-exists.md | Date: 2026-06-21 | Lane: BANXE.RAR → EMI cross-context migration | advisory-only | No code, no scaffold, no merge. ADR-102 duplication stop-barrier. -->

> **STATUS: BLOCKED.** Mandatory read-only preflight + ADR-102 Duplication Audit stopped MIG-M2.5
> **before any scaffold.** banxe-emi-stack **already implements the ABS (account-based-settlement)
> surface** as `LegacyAbsPaymentAdapter` — a semantic rewrite of the legacy `abs-api`, with the Bifrost
> layer explicitly modelled. Scaffolding a new `AbsPort`/`AbsBifrostPort` would duplicate it. Per the
> MIG-M2.5 blocker instruction + ADR-102 HARD RULE (no new structure without repo-wide duplication
> verification; fail-closed) → **STOP, no scaffold.** Docs-only blocker report + IL-shard. (Same
> anti-dup posture as the MIG-M2.4 open-banking blocker.)

## 1. Preflight outcome (read-only, origin/main 1a90a41)

- **api/routers + api/models grep (exact tokens `account-based-settlement` / `bifrost` / `AbsPort` /
  `@abs/common`):** no match. No `abs.py`/`bifrost.py` in `api/`; no abs/bifrost router registered in
  `api/main.py`. (Case-insensitive `abs` hits in `multi_currency.py`/`intent.py`/`account_sot.py` were
  false positives — "absolute"/substrings.)
- **BUT repo-wide (the M2.4 lesson — audit beyond api/):** the ABS surface lives under `services/`:
  - **`services/payment/legacy/legacy_abs_payment_adapter.py`** — `LegacyAbsPaymentAdapter`.
  - Tests: `tests/test_legacy_abs_payment_adapter.py` (dedicated), plus `tests/test_src_settlement.py`
    and `tests/test_merchant_acquiring/test_settlement_engine.py` (different domains — see §4).

## 2. The existing ABS surface (what `LegacyAbsPaymentAdapter` already is)

From the module header + symbols:

- **Semantic rewrite of `abs-customer-payment.service.ts` (banxe-fiat-backend/abs-api)** → Python
  (REWRITE-2). The legacy ABS is **already migrated**.
- Implements **`PaymentRailPort`** (`services/payment/payment_port.py`).
- `AbsPaymentStatus(str, Enum)` — **ABS state-machine**.
- `AbsPaymentRecord(BaseModel, frozen=True)` — **ABS intent/record DTO**.
- `AbsAuditRecord` + `AbsApplicationError(code=...)` — **audit + error-map**.
- Methods: `submit_payment(intent)` (← `createOrUpdateCustomerPayment`), `advance_to(payment_id,
  status)` (← `approveCustomerPayment`, state-machine transition via `assert_valid_transition`),
  `get_payment_status`, `list_payments`, `collect_audit_records`.
- **Bifrost layer explicitly modelled (ADR-025 §15-16):** GCP Bifrost XML gateway
  (`requestToGCPProcessing`) transport dropped in the rewrite; *"Production: replace with GCP Bifrost
  XML adapter + ClickHouse audit sink (Wave D)"* — the Bifrost adapter is a **documented planned
  production replacement behind `PaymentRailPort`**.
- Decimal amounts (I-01); `assert_valid_transition` state-machine; `BaseAuditRecord`.

## 3. Why scaffold is blocked + why this already IS the LAYERED model

MIG-M2.5 proposed `api/models/abs.py` with `AbsPort` (canonical operational ABS), `AbsBifrostPort`
(thin upstream Bifrost adapter), ABS intent/status DTO + state-machine, `@abs/common`-aligned shape.
**Every layer already exists:**

| MIG-M2.5 proposed (per M1.2 LAYERED) | Already present |
|---|---|
| Canonical operational ABS surface (nested-derived) | `LegacyAbsPaymentAdapter` (rewrite of nested `abs-api`), `AbsPaymentStatus`/`AbsPaymentRecord` + state-machine |
| Top-level Bifrost adapter (`AbsBifrostPort`, retained) | Bifrost layer modelled per ADR-025 §15-16 (Wave D production GCP Bifrost XML adapter behind `PaymentRailPort`) |
| ABS error-map | `AbsApplicationError(code=...)` |
| Consume accounts SoT projection | via `PaymentIntent` account fields (payment_port) |

So the **MIG-M1.2 LAYERED outcome is already realised** (operational canonical = `LegacyAbsPaymentAdapter`; Bifrost = planned production adapter behind the port). A new `AbsPort`/`AbsBifrostPort` would be a **parallel duplicate** competing with `PaymentRailPort` → ADR-102 violation (existing surface has consumers: `legacy/__init__.py`, dedicated test).

## 4. Not-ABS (excluded from the duplication, for clarity)

- `services/merchant_acquiring/settlement_engine.py` (`SettlementEngine`, `FEE_RATE`) = **merchant/card
  acquiring settlement** — different domain, not account-based-settlement.
- `src/settlement/` = separate settlement module (not ABS).
- These are **not** part of the ABS surface and are out of scope here.

## 5. Decision required (operator/governance)

- **A (recommended) — re-scope MIG-M2.5 → reconcile/gap-audit** (as MIG-M2.4): ADR-102 audit of the
  legacy `abs-api` (top-level + nested, `banxe-fiat-backend/abs-api`) **vs** `LegacyAbsPaymentAdapter`
  → delta (what the legacy TS has that the Python rewrite lacks) + keep/merge/retire. **No new
  scaffold.**
- **B — Bifrost production-adapter substep** (the actual remaining ABS work, Wave D per ADR-025 §15-16):
  implement the GCP Bifrost XML adapter **behind the existing `PaymentRailPort`** (not a new parallel
  port) — operator-gated, no live calls in advisory path.
- **C — rename clarity** (optional): `LegacyAbsPaymentAdapter` is the canonical ABS adapter now; the
  "legacy" prefix may be reconsidered (cosmetic, separate).

## 6. What was / was NOT done

- **Done (read-only):** mandatory preflight (api/ grep + main.py) + repo-wide ABS audit (services/);
  read `legacy_abs_payment_adapter.py` + `payment_port.py`; this blocker doc + IL-shard (isolated
  worktree, Rule 1/6).
- **NOT done:** no scaffold (any repo); no `abs.py`/`AbsPort`/`AbsBifrostPort` created; no backend PR;
  banxe-emi-stack untouched (0 `mig-m2.5` factory branches); no merge.

## 7. Recommended next step

Operator resolves §5 (recommend **A — reconcile/gap-audit**, mirroring MIG-M2.4). Then either re-issue
MIG-M2.5 as a reconcile substep (no scaffold) and/or schedule **B** (Bifrost Wave D adapter behind
`PaymentRailPort`). MIG-M2.3 (identity/auth) is unaffected and remains the next sequencing candidate
(gate: KYC carve-out sign-off). Correct the M2-sequencing note: **M2.5 = reconcile, not scaffold.**

## References
`docs/migration/MIG-M2.5-BLOCKER-abs-already-exists.md`; read-only origin/main `1a90a41`
banxe-emi-stack `services/payment/legacy/legacy_abs_payment_adapter.py`, `services/payment/payment_port.py`,
`tests/test_legacy_abs_payment_adapter.py`; legacy `abs-api` (top-level + `banxe-fiat-backend/abs-api`);
MIG-M1.2 (ABS dup-audit, LAYERED), MIG-M2.0 (@abs/common canonical), MIG-M2.4 (open-banking blocker
precedent), MIG-M2.2 (accounts SoT); ADR-025 §15-16 (Bifrost transport), ADR-102, ADR-103, ADR-059-A,
I-01, I-28; /tmp/banxe-migration-mapping-v0.claude.txt.
