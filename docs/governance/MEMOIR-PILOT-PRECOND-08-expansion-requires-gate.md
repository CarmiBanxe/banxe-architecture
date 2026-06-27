---
id: MEMOIR-PILOT-PRECOND-08
title: Memoir pilot — Precondition #8 (FINAL) Expansion requires ADR-135 gate + operator + IronClaw — verifiable contract
status: PROPOSED
date: 2026-06-27
concept_only: true
relates:
  - "ADR-137 (Memoir factory-only PILOT, ACCEPTED; this specifies its Pilot Entry Precondition #8 — the final gate; L67-68 RED zone)"
  - "ADR-135 (held-out skill-evolution validation gate — every expansion is routed through it)"
  - "ADR-136 (agentmemory substrate — primary; expansion to additional substrates is what this gates)"
  - "ADR-130/127 (no authority expansion / Tier-1 read-only)"
  - "MEMOIR-PILOT-PRECOND-01..07 (the seven preconditions this one composes and back-stops)"
il_anchor: IL-608
il_anchor_note: "Provisional per ADR-119 Rule 8 — NOT hardcoded; build_ledger mints max+1 over current origin/main (max 607 after #814/#817 precond-06/07 merged as IL-602/607 + #823/#824 → 608) at rebase-before-merge. Serialized rebuild under LEDGER-MERGE-QUEUE single-writer discipline; #821/ADR-141 re-mints on its turn."
external_ref: "github.com/zhangfengcdt/memoir — referenced by ADR-137, NOT imported"
---

# MEMOIR-PILOT-PRECOND-08 (FINAL) — Expansion requires ADR-135 gate + operator + IronClaw

> **Verifiable governance CONTRACT, not an implementation.** The **final** Pilot Entry Precondition of
> ADR-137: the back-stop that makes the whole envelope expandable **only** through an explicit triple
> gate. No runtime, no code, no config, no secret, no import of `github.com/zhangfengcdt/memoir`.
> Building anything beyond this spec is the subsequent gated work item.

## 1. Scope

Applies to the **Memoir factory-only pilot** under the **ADR-137 / ADR-136 envelope**. Governs **any
expansion** of the pilot beyond its factory-only, concept-level governance scope. It does **not**
authorise a pilot.

## 2. What counts as "expansion"

Any of the following is an **expansion** and is **FORBIDDEN by default**:

- **Into production** — running against any production environment (factory or project).
- **Additional substrates** — adding a memory substrate beyond the one agentmemory-XOR-Memoir slot per
  fork (PRECOND-04), or standing up a second store.
- **Authority over sensitive flows** — acquiring any write/act right over code, ledger, production,
  payment, KYC, AML, sanctions, secrets, PII (RED zone, ADR-137 L67-68), or dispatch (PRECOND-06/07).
- **Beyond factory-only** — enabling a project fork or crossing the factory↔project perimeter
  (PRECOND-05), or widening any of PRECOND-01..07's boundaries.

## 3. The triple gate (ALL required; fail-closed)

An expansion is permitted **only if it passes ALL THREE**, routed through the **ADR-135 held-out
validation gate**:

1. **A SEPARATE future ADR** explicitly authorizing the specific expansion (scope, boundaries, risks);
2. **Explicit operator approval (HITL)** — a recorded human decision, never implied;
3. **IronClaw security PASS** — security-review sign-off.

All three are routed through the **ADR-135 held-out skill-evolution gate** (zero regression on the
boundary/authority/redaction checks of PRECOND-01..07). **Absent ANY of the three ⇒ DENIED**
(deny-by-default). There is no path to expansion via config, flags, precedent, or partial approval.

## 4. Fail-closed

On any ambiguity about whether an action constitutes an expansion, it is **treated as an expansion** and
**denied** until the full triple gate passes. A control/gate error ⇒ deny. **"Possibly an expansion" =
expansion.** No expansion may start while any gate element is missing, stale, or unverified.

## 5. Composition — the back-stop over #1..#7

PRECOND-08 is the **closing rule** that makes #1..#7 non-bypassable:

- #1 redaction · #2 retention/purge · #3 replay-scope · #4 one-substrate-per-fork · #5 factory-fork-only
  · #6 sensitive-OOS · #7 no-authority-expansion each fix a boundary; **#8 forbids widening ANY of them**
  without the triple gate.
- Where #6/#7 already require "a separate ADR + operator + IronClaw" for the RED zone / authority,
  **#8 generalises that to every expansion** of the pilot and routes it through the ADR-135 gate.
- Net effect: the pilot can only **grow** through an explicit, audited, human-gated, security-reviewed,
  held-out-validated path — never by drift.

## 6. Verification criteria — how "expansion is gated" is proven

Precondition #8 is **DONE only when** all hold, as a **held-out** suite passing the **ADR-135 gate with
zero regressions**:

1. **Expansion without a separate ADR → denied.**
2. **Expansion without operator approval → denied.**
3. **Expansion without IronClaw PASS → denied.**
4. **Expansion not routed through the ADR-135 gate → denied.**
5. **Ambiguous-as-expansion → denied** (fail-closed); partial/stale approval → denied.

## 7. Sign-off

Marking Precondition #8 = **DONE** requires **operator + IronClaw (security-review) sign-off**, recorded
in the ledger/ADR trail. Without **both**, #8 stays open and **no Memoir runtime may start**
(fail-closed). With #1..#8 all DONE, the *runtime pilot* is still a SEPARATE gated work item (ADR-137).

## 8. Non-goals (explicit)

Specification only. Ships **no** gate engine, no config/stub, no Memoir runtime. Implementation (the
expansion-gate enforcement + tests) is a **subsequent gated work item** under ADR-137, itself subject to
this contract and ADR-135.

## Anchors

- ADR-137 (Pilot Entry Preconditions; #8 = this, the final gate; L67-68 RED zone), ADR-135 (held-out
  validation gate), ADR-136 (substrate), ADR-130/127 (no authority / Tier-1),
  MEMOIR-PILOT-PRECOND-01..07 (composed and back-stopped). External: `github.com/zhangfengcdt/memoir`
  (referenced by ADR-137, NOT imported). Enforcement = CI gates + these ADRs; this spec carries no
  runtime/config/secret.
