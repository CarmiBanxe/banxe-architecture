# MIG-M2.4 — OB-delta completion note (BANXE.RAR → EMI)

<!-- Source: docs/migration/MIG-M2.4-OB-delta-completion.md | Date: 2026-06-22 | Lane: BANXE.RAR → EMI cross-context migration track | docs-only | No code, no merge. Consolidated completion of the open-banking (OB) delta sub-cycle M2.4. -->

> **Track:** cross-context migration (MIG-M2.4) — **OB-delta completion checkpoint** consolidating the
> M2.4 sub-items (INT bridge + a/b/c/d/e). **Mode:** docs-only; no code, no EMI-repo branches, no
> merges. Declares the non-gated open-banking backend backlog exhausted and names the two remaining
> gated tracks with their precondition-gates.

## 1. OB-delta summary

| Sub-item | Scope | Result | Classification | Merge-SHA / ref |
|---|---|---|---|---|
| **M2.4-INT** | open-banking integration bridge (`m24_int_bridge`: PaymentEngineContract + AccountSoTProjection) | **DONE** | integration | covered by M2.4-INT bridge |
| **M2.4a** | scheduled payments | **DONE** | covered | existing handler covered |
| **M2.4b** | scheduled payments | **DONE** | covered | existing handler covered |
| **M2.4c** | file / bulk payments | **DONE** | covered | existing batch handler covered |
| **M2.4d** | intl-scheduled payments | **DONE** | genuine-gap | scaffold (genuine-gap) |
| **M2.4e** | CBPII funds-confirmation-consent lifecycle | **DONE** | facade (thin) | see below |

**M2.4e paired-PR records:**
- **banxe-emi-stack PR #212** → merge SHA `35033ac` (squash, no `--admin`) — `services/open_banking/cbpii_consent.py` thin facade + characterization/contract/fence tests.
- **banxe-architecture PR #666** → merge SHA `74ec485` (IL-422 shard) — `python ledger/build_ledger.py --check` exit 0.

## 2. Classification breakdown

- **Covered (3):** M2.4a, M2.4b, M2.4c — existing emi-stack handlers already satisfy the OB-delta requirement; no new service.
- **Integration (1):** M2.4-INT — the `m24_int_bridge` seam (PaymentEngineContract / AccountSoTProjection) wiring open-banking to the payments + accounts SoT.
- **Genuine-gap (1):** M2.4d — intl-scheduled payments scaffold (a real missing surface, scaffolded read-only).
- **Facade (1):** M2.4e — thin CBPII consent-lifecycle facade delegating to the existing funds-confirmation check.

**Total: 6 items** (3 covered + 1 integration + 1 genuine-gap + 1 facade).

## 3. Non-gated backend backlog — EXHAUSTED

After M2.4e there are **zero remaining non-gated backend OB-delta items**. The open-banking delta
sub-cycle (M2.4-INT + M2.4a/b/c covered + M2.4d genuine-gap + M2.4e facade) is complete for every
item that does **not** sit behind a governance/precondition gate. No further non-gated backend
open-banking migration work remains in scope.

## 4. Remaining GATED tracks

Two tracks remain, both blocked on an explicit precondition-gate (neither is a backend OB-delta item):

| Track | Scope | Precondition-gate |
|---|---|---|
| **a. KYC/KYB/AML** | identity / AML migration | **I-27 HITL-L4 operator sign-off** — KYC/KYB/AML carve-out is never bypassed; migration is blocked until the operator signs off. |
| **b. M2.8 frontend** | frontend migration | **roster audit `banxe-platform` vs `banxe-ui`** — frontend cutover is blocked until the roster audit resolves which shells/components land where. |

## 5. Anti-dup summary (ADR-102 — additive, not duplicate)

Facades delegate to existing handlers rather than re-implementing them. Specifically:

- **M2.4e** — `CbpiiPort` / `CbpiiFundsConfirmationConsent` delegate the funds-confirmation step to the
  **existing** `handle_cbpii_check` (`consent_management` `/cbpii/check`) via a descriptive
  `FundsConfirmationRef` (`EXISTING_CHECK_REF`); the check is referenced, **not** re-implemented. The
  facade adds only the missing dedicated CBPII consent-lifecycle shape.
- **M2.4a/b/c** were classified **covered** precisely because the existing handlers already satisfied
  the requirement; nothing was re-implemented.

**No service was re-implemented** across the M2.4 sub-cycle. Every facade is additive (ADR-102) and
existing surfaces (`consent_management`, `psd2_flow_handler`, `pisp_service`, `m24_int_bridge`)
remained unchanged.

## 6. Governance learnings

- **Per-substep preflight** — each sub-item began with a read-only preflight on `origin/main`
  classifying the surface as covered / integration / genuine-gap / facade before any code.
- **Paired PRs** — every code substep produced a pair: emi-stack code PR + banxe-architecture IL-shard
  PR (e.g. emi-stack #212 + architecture #666).
- **Append-only ledger** — shards are append-only (ADR-059-A / I-28); `INSTRUCTION-LEDGER.md` is a
  regenerated read-only artifact (`build_ledger.py`), never hand-edited.
- **No merge without governance** — PRs opened, never auto-merged, no `--admin` / branch-protection
  bypass.
- **Classification discipline** — the covered / integration / genuine-gap / facade taxonomy kept
  scope honest and prevented duplicate re-implementation.
- **Isolated worktrees** — all work in fresh isolated git worktrees from freshly-fetched
  `origin/main` (Rule 1), never touching parallel-session branches (Rule 6).

## 7. Acceptance + what each gate unblocks

**Acceptance criteria for declaring OB-delta complete:**

- [x] Every non-gated backend OB-delta sub-item (M2.4-INT, M2.4a/b/c, M2.4d, M2.4e) is **DONE** and
  classified.
- [x] Non-gated backend backlog is **exhausted** (§3).
- [x] All facades are additive (ADR-102); no service re-implemented (§5).
- [x] Ledger consistent; `il_ts` monotonic; `python ledger/build_ledger.py --check` = exit 0.
- [x] No merge performed by this note; remaining work is purely gated.

**What each gate unblocks:**

- **KYC gate (I-27 HITL-L4 sign-off)** unblocks the **identity / AML migration tracks** — once the
  operator signs off the KYC/KYB/AML carve-out, the identity SoT and AML surfaces can migrate.
- **M2.8 gate (roster audit `banxe-platform` vs `banxe-ui`)** unblocks the **frontend migration** —
  once the roster audit resolves shell/component ownership, the frontend shells can cut over to
  `banxe-ui`.

---

**Refs:** banxe-emi-stack PR #212 (merge SHA `35033ac`); banxe-architecture PR #666 (merge SHA
`74ec485`, IL-422 shard); MIG-M2.4 (open-banking gap-audit), MIG-M2.4-INT, MIG-M2.4d (intl-scheduled
genuine-gap), MIG-M2.4e (CBPII funds-confirmation facade); MIG-M1.8 (M1 acceptance); ADR-102, ADR-103,
ADR-059-A, I-01, I-05, I-27, I-28.
