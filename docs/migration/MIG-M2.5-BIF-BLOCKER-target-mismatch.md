# MIG-M2.5-BIF — BLOCKER: target mismatch (Bifrost adapter targets live in banxe-emi-stack, not payment-core)

<!-- Source: docs/migration/MIG-M2.5-BIF-BLOCKER-target-mismatch.md | Date: 2026-06-21 | Lane: BANXE.RAR → EMI cross-context migration | advisory-only | No code, no scaffold, no merge. Target-mismatch stop-barrier (mirror MIG-M2.7). -->

> **STATUS: BLOCKED.** Mandatory read-only preflight stopped MIG-M2.5-BIF **before any scaffold.** The
> scenario named **`banxe-payment-core`** as the target, but the Bifrost Wave-D adapter's consume/extend
> targets — **`PaymentRailPort` + `LegacyAbsPaymentAdapter` + `AbsPaymentStatus`** — live in
> **`banxe-emi-stack`**, not in `banxe-payment-core`. A `BifrostAdapter(PaymentRailPort)` cannot be
> built in `banxe-payment-core` (the port + ABS adapter don't exist there; cross-repo). **STOP, no
> scaffold** (same target-mismatch posture as the MIG-M2.7 blocker). Docs-only blocker + IL-shard.

## 1. Preflight outcome (read-only, both repos)

| Check | banxe-payment-core (`428d75c`) | banxe-emi-stack (origin/main) |
|---|---|---|
| existing Bifrost/GCP adapter | none (clean) | none dedicated (only the docstring mention in `legacy_abs_payment_adapter.py`) |
| `services/` dir | **absent** | present (`services/payment/…`) |
| `PaymentRailPort` | **absent** | **`services/payment/payment_port.py`** ✓ |
| `LegacyAbsPaymentAdapter` + `AbsPaymentStatus` | **absent** | **`services/payment/legacy/legacy_abs_payment_adapter.py`** ✓ |
| ports present | `src/ports/{payment_switch,payment_engine,sepa_rail,issuer,ledger}_port.py` | `services/payment/*` (PaymentRailPort) |

## 2. The mismatch

MIG-M2.5-BIF (per MIG-M2.5 reconcile / ADR-025 §15-16) = implement the GCP Bifrost XML adapter
**behind the existing `PaymentRailPort`**, consuming `LegacyAbsPaymentAdapter` / `AbsPaymentStatus`.
Those targets were established by **MIG-M2.5** as living in **banxe-emi-stack** (`services/payment/`).
`banxe-payment-core` has **no `services/` tree, no `PaymentRailPort`, no ABS adapter** — its rails are
`payment_switch_port` (Hyperswitch), `payment_engine_port` (M2.1), `sepa_rail_port` (M2.6).

Therefore scaffolding `BifrostAdapter` in `banxe-payment-core` is impossible (nothing to implement /
consume there) and would either duplicate or cross a repo boundary → **ADR-102 / target-mismatch
violation**. The Bifrost Wave-D adapter belongs in **banxe-emi-stack**, alongside the ABS surface.

## 3. Repo-domain clarification

- **banxe-emi-stack** = ABS domain home (`LegacyAbsPaymentAdapter` behind `PaymentRailPort`; Bifrost
  Wave-D adapter belongs here per MIG-M2.5).
- **banxe-payment-core** = payment switch (Hyperswitch) + payments engine (M2.1) + SEPA rail (M2.6).
  Not the ABS/Bifrost home.

(The MIG-M2.5 reconcile already recorded ABS canonical home = banxe-emi-stack; this blocker corrects the
MIG-M2.5-BIF substep's target repo, which the scenario set to payment-core.)

## 4. Decision required (operator/governance)

- **A (recommended) — retarget MIG-M2.5-BIF to `banxe-emi-stack`:** scaffold `BifrostAdapter`
  implementing the **existing emi-stack `PaymentRailPort`** (`services/payment/`), consuming
  `LegacyAbsPaymentAdapter` / `AbsPaymentStatus`; advisory/sandbox, no live GCP calls, no Midaz, I-05.
  Mandatory preflight in emi-stack for any existing Bifrost adapter (none found — clean for additive
  scaffold). Re-issue with target = banxe-emi-stack.
- **B — defer Bifrost Wave-D** and proceed to another follow-up (e.g. MIG-M2.4a OB delta-port, or ABS
  delta/re-home) until the Bifrost retarget is scheduled.

## 5. What was / was NOT done

- **Done (read-only):** mandatory preflight in `banxe-payment-core` (services/ + src/ grep for
  bifrost/gcp + PaymentRailPort/ABS targets) + cross-check in `banxe-emi-stack`; this blocker doc +
  IL-shard (isolated worktree, Rule 1/6).
- **NOT done:** no scaffold (any repo); no `BifrostAdapter`; no backend PR; both repos untouched
  (0 `mig-m2.5-bif` factory branches in payment-core and emi-stack); no merge.

## 6. Recommended next step

Operator resolves §4 (recommend **A — retarget to banxe-emi-stack**). Then re-issue MIG-M2.5-BIF
against banxe-emi-stack (`BifrostAdapter` behind the existing `PaymentRailPort`, consuming the ABS
adapter; advisory/sandbox; no live GCP/Midaz; paired PR; no merge). Alternatively proceed to MIG-M2.4a
(OB delta-port) or ABS delta/re-home. Correct the follow-up backlog: **M2.5-BIF target = banxe-emi-stack,
not banxe-payment-core.**

## References
`docs/migration/MIG-M2.5-BIF-BLOCKER-target-mismatch.md`; read-only banxe-payment-core `428d75c`
(`src/ports/*`) + banxe-emi-stack origin/main (`services/payment/payment_port.py`,
`services/payment/legacy/legacy_abs_payment_adapter.py`); MIG-M2.5 (ABS reconcile, IL-388 — ABS home =
emi-stack), MIG-M2.7 (target-mismatch precedent), MIG-M2.8 (acceptance backlog); ADR-025 §15-16
(Bifrost), ADR-102, ADR-103, ADR-059-A, I-05, I-28; /tmp/banxe-migration-mapping-v0.claude.txt.
