# MIG-M2.4 — BLOCKER: PSD2 open-banking surface already exists in banxe-emi-stack (no scaffold)

<!-- Source: docs/migration/MIG-M2.4-BLOCKER-open-banking-already-exists.md | Date: 2026-06-21 | Lane: BANXE.RAR → EMI cross-context migration | advisory-only | No code, no scaffold, no merge. ADR-102 duplication stop-barrier. -->

> **STATUS: BLOCKED.** Read-only preflight + ADR-102 Duplication Audit stopped MIG-M2.4 **before any
> scaffold.** banxe-emi-stack **already has a comprehensive PSD2 open-banking surface** — scaffolding a
> new `open_banking` model/router/port would **duplicate it and collide on the `open_banking.py`
> filename**. Per the MIG-M2.4 blocker instruction + ADR-102 HARD RULE (no new structure without
> repo-wide duplication verification; fail-closed on uncertainty) → **STOP, no scaffold.** This is a
> docs-only blocker report + IL-shard.

## 1. Preflight outcome (read-only)

banxe-emi-stack = EMI backend (FastAPI/Python) — layout re-confirmed (`api/models` + `api/routers`,
`account_sot` from M2.2 present). **But the PSD2 open-banking target is already populated** by THREE
existing routers (the migration destination is not empty):

| Existing surface | Ledger ref | Covers |
|---|---|---|
| `api/routers/open_banking.py` | IL-OBK-01 (Phase 15) | **AISP consents** (create / get / **authorise** / revoke) + **PISP** `/payments` initiate + `/payments/{id}/status` + `/accounts` + `/aspsps` |
| `api/routers/psd2_gateway.py` | IL-PSD2GW-01 (adorsys XS2A AISP) | `/psd2/consents` (HITL L4) + `/psd2/accounts` + `/psd2/transactions` + `/psd2/balances` + auto-pull; DecimalString (I-01), IBAN (I-02) |
| `api/routers/consent_management.py` | IL-CNS-01 (Phase 49) | consent grants / validate + **PISP `/pisp/initiate`** + **AISP `/aisp/complete`** + **CBPII `/cbpii/check` (confirmation of funds)** + TPP registry |

## 2. The duplication (why scaffold is blocked)

MIG-M2.4 proposed to scaffold `api/models/open_banking.py` + `api/routers/open_banking.py` +
`OpenBankingPort` with AISP **account-consent** state-machine, PISP **payment-initiation** (domestic/
international), and **funds-confirmation** DTOs. **Every one of those already exists and is FCA-wired:**

- **AISP account-consent state-machine** → `open_banking.py` consents (create→authorise→revoke) +
  `consent_management.py` grants/validate + `/aisp/complete`.
- **PISP payment-initiation** → `open_banking.py` `/payments` + `consent_management.py` `/pisp/initiate`.
- **Funds-confirmation (CBPII)** → `consent_management.py` `/cbpii/check` ("confirmation of funds").
- **accounts** → `open_banking.py` `/accounts` + `psd2_gateway.py` `/psd2/accounts`.

A new `api/routers/open_banking.py` would **collide on the exact filename** and a new
model/port would **re-implement a more mature, HITL-L4 + I-01/I-02 wired surface**. ADR-102 forbids
this (no delete/merge/new-structure until hidden deps confirmed; fail-closed on doubt). The existing
surface has consumers (registered routers, IL-OBK-01/PSD2GW-01/CNS-01) — **not safe to shadow.**

## 3. Mismatch vs the migration plan

MIG-M1.1 framed open-banking as "migrate canonical top-level legacy `banxe-open-banking` →
banxe-emi-stack (nested merge-then-retire)". Reality at M2.4 time: **banxe-emi-stack ALREADY
implements the PSD2 open-banking surface** (3 routers). So M2.4 is **not a green-field scaffold** — it
is a **reconcile / gap-audit** between the legacy canonical `banxe-open-banking` and the existing
emi-stack surface. Treating it as "scaffold new" would create a 4th overlapping surface.

## 4. Impact

- MIG-M2.4 cannot run as a "scaffold new open_banking" step against banxe-emi-stack.
- The M2-sequencing note "M2.4 = open-banking scaffold" is incorrect — M2.4 must be re-scoped to
  reconcile/align (delta against the existing surface), not scaffold.
- Note (informational, not this task's scope): emi-stack itself carries **three overlapping PSD2
  routers** (`open_banking` / `psd2_gateway` / `consent_management`) — a pre-existing internal
  consolidation candidate, surfaced here for governance awareness.

## 5. Decision required (operator/governance)

- **A. Re-scope MIG-M2.4 → reconcile/gap-audit** (recommended): ADR-102 Duplication Audit of legacy
  canonical `banxe-open-banking` **vs** the existing emi-stack surface (open_banking + psd2_gateway +
  consent_management). Output = delta (what legacy has that emi-stack lacks) + keep/merge/retire
  decisions. **No new parallel scaffold.**
- **B. Integration-only step**: wire the EXISTING open-banking surface to consume PaymentEnginePort
  (M2.1) + accounts SoT (M2.2) projection where it currently uses its own/mock logic — an integration
  PR against the existing routers, not a new module.
- **C. Internal consolidation** (separate, optional): consolidate the three overlapping emi-stack PSD2
  routers into one bounded context (own substep, ADR-102) — governance-gated, independent of the
  legacy migration.

## 6. What was / was NOT done

- **Done (read-only):** preflight banxe-emi-stack layout; ADR-102 audit of open_banking / psd2_gateway
  / consent_management; this blocker doc + IL-shard (isolated worktree, Rule 1/6).
- **NOT done:** no scaffold (any repo); no `open_banking` model/router/port created; no backend PR;
  banxe-emi-stack untouched (0 `mig-m2.4` factory branches); no merge.

## 7. Recommended next step

Operator resolves §5 (recommend **A — reconcile/gap-audit**). Then either re-issue MIG-M2.4 as a
Duplication-Audit/reconcile substep (no scaffold), or skip to **MIG-M2.5 (ABS)** while the
open-banking reconcile is scheduled. Correct the M2-sequencing note (M2.4 = reconcile, not scaffold).

## References
`docs/migration/MIG-M2.4-BLOCKER-open-banking-already-exists.md`; read-only banxe-emi-stack
`api/routers/{open_banking,psd2_gateway,consent_management}.py` (IL-OBK-01 / IL-PSD2GW-01 / IL-CNS-01),
`api/models/ledger.py` (Midaz live SoT), `api/models/account_sot.py` (M2.2); MIG-M1.1 (open-banking
dup-audit), MIG-M2.1 (payment engine), MIG-M2.2 (accounts SoT); ADR-102, ADR-103, ADR-059-A, I-01,
I-02, I-28; /tmp/banxe-migration-mapping-v0.claude.txt.
