---
id: MEMOIR-PILOT-PRECOND-07
title: Memoir pilot — Precondition #7 No authority expansion (memory describes, never authorizes) — verifiable contract
status: PROPOSED
date: 2026-06-27
concept_only: true
relates:
  - "ADR-137 (Memoir factory-only PILOT, ACCEPTED; this specifies its Pilot Entry Precondition #7; L67-68 RED zone)"
  - "ADR-136 (agentmemory substrate — read-only w.r.t. authority; memory VCS authority is content-only)"
  - "ADR-130 (no authority expansion — the general rule this precondition enforces for the pilot)"
  - "ADR-127 (Hermes Tier-1 read-only / no dispatch)"
  - "MEMOIR-PILOT-PRECOND-01/03/05/06 (redaction / replay-scope / factory-fork-only / sensitive-OOS — compose)"
  - "ADR-135 (held-out validation gate — any authority expansion passes the gate, plus operator + IronClaw)"
il_anchor: IL-607
il_anchor_note: "Provisional per ADR-119 Rule 8 — NOT hardcoded; build_ledger mints max+1 over current origin/main (max 606 after #823 serialization + #824 GAP-087 merged → 607) at rebase-before-merge. Serialized rebuild under LEDGER-MERGE-QUEUE single-writer discipline (#817 first; #818/#821 re-mint on their turn)."
external_ref: "github.com/zhangfengcdt/memoir — referenced by ADR-137, NOT imported"
---

# MEMOIR-PILOT-PRECOND-07 — No authority expansion (memory describes, never authorizes)

> **Verifiable governance CONTRACT, not an implementation.** Defines WHAT Precondition #7 of ADR-137
> must guarantee and HOW it is proven. No runtime, no code, no config, no secret, no import of
> `github.com/zhangfengcdt/memoir`. Building it is the subsequent gated work item.

## 1. Scope

Applies to the **Memoir factory-only pilot** under the **ADR-137 / ADR-136 envelope**. Governs whether
the pilot may **acquire authority** through memory. It does **not** authorise a pilot.

## 2. Core rule — memory describes, never authorizes

The Memoir / agentmemory pilot **MUST NOT expand authority** over any **sensitive flow or production
domain.** Holding memory **of** or **about** an action confers **no right to perform it.** Authority
stays where canon puts it — CI gates + ADRs (ADR-130/127); memory is **read-only with respect to
authority** and is never an authority source.

## 3. Memory VCS authority is memory-content-only (ADR-136/137)

Memoir's Git-like operations — **branch / commit / merge / rollback / checkout / blame** — act **ONLY on
memory content.** They **NEVER** acquire authority over:

- **code** (no commit/merge/deploy of repo content);
- **ledger** (no write to `INSTRUCTION-LEDGER.md` / `IL-SEQUENCE.json` / shards; ADR-059 stays source of
  truth);
- **production state** (no service start/stop, no prod mutation);
- **payment / KYC / AML / sanctions** (no transaction, screening, or case action);
- **secrets / PII** (no access/exfiltration; RED zone, ADR-137 L67-68);
- **dispatch** (no triggering of agents/jobs/workflows).

A memory "merge" or "rollback" is a memory-content operation; it is **not** a git merge, a deploy, a
payment, or a dispatch — and may never be wired to become one within the pilot.

## 4. Expansion gate

**Any** authority expansion (granting the pilot any write/act right over §3) requires a **SEPARATE
future ADR + operator approval + IronClaw PASS**, gated through the **ADR-135 held-out validation gate**
(zero regression on authority/boundary checks). Absent all of these, authority expansion is
**forbidden** — there is no path via config, flags, or precedent.

## 5. Fail-closed (ambiguous = deny)

On any ambiguity about whether an operation would confer or exercise authority, the pilot **denies by
default**: the operation does not run, and **no pilot start** if an authority-expansion path cannot be
excluded. "Might act" is treated as "acts" ⇒ deny. A control/classifier error ⇒ deny.

## 6. Composition with #1 / #3 / #5 / #6

- **#1 (redaction)** + **#6 (sensitive OOS)** — RED-zone content is excluded/dropped, so the pilot can
  hold no sensitive material to act on; #7 adds that even non-sensitive memory grants no authority.
- **#3 (replay = observability-only)** — replay never re-executes privileged actions; #7 generalises:
  **no** memory operation (replay, rollback, merge, checkout) ever executes a privileged action.
- **#5 (factory-fork-only)** — confined to the factory fork, the no-authority rule holds within a single
  bounded perimeter; crossing to project/production needs its own ADR + operator.

## 7. Verification criteria — how "no authority expansion" is proven

Precondition #7 is **DONE only when** all hold, as a **held-out** suite passing the **ADR-135 gate with
zero regressions**:

1. **No code/ledger/prod write via memory** — memory branch/commit/merge/rollback/checkout produce **no**
   repo/ledger/production mutation.
2. **No payment/KYC/AML/sanctions/secrets/PII/dispatch action via memory** — no memory operation triggers
   a privileged action.
3. **Ambiguous → deny** — uncertain authority implications fail closed (no act / no pilot start).
4. **Expansion without ADR+operator+IronClaw+ADR-135 → forbidden** — no authority is granted absent the
   full gate.

## 8. Sign-off

Marking Precondition #7 = **DONE** requires **operator + IronClaw (security-review) sign-off**, recorded
in the ledger/ADR trail. Without **both**, #7 stays open and **no Memoir runtime may start**
(fail-closed).

## 9. Non-goals (explicit)

Specification only. Ships **no** authority-enforcement engine, no config/stub, no Memoir runtime.
Implementation (the no-authority enforcement + tests) is a **subsequent gated work item** under ADR-137,
itself subject to this contract and ADR-135.

## Anchors

- ADR-137 (Pilot Entry Preconditions; #7 = this; L67-68 RED zone), ADR-136 (read-only w.r.t. authority),
  ADR-130 (no authority expansion), ADR-127 (Tier-1 read-only), MEMOIR-PILOT-PRECOND-01/03/05/06
  (compose), ADR-135 (held-out gate). External: `github.com/zhangfengcdt/memoir` (referenced by ADR-137,
  NOT imported). Enforcement = CI gates + these ADRs; this spec carries no runtime/config/secret.
