---
id: MEMOIR-PILOT-PRECOND-04
title: Memoir pilot — Precondition #4 One-substrate-per-fork (agentmemory XOR Memoir) — verifiable contract
status: PROPOSED
date: 2026-06-27
concept_only: true
relates:
  - "ADR-137 (Memoir factory-only PILOT, ACCEPTED; this specifies its Pilot Entry Precondition #4; L81-82, L104)"
  - "ADR-136 (agentmemory substrate — the PRIMARY substrate; Memoir is pilot/alternative, not a 2nd store)"
  - "MEMOIR-PILOT-PRECOND-01/02/03 (redaction / retention / replay — one substrate ⇒ one set of boundaries per fork)"
  - "ADR-059 (per-session ledger shards = memory of record / source of truth, regardless of substrate)"
  - "ADR-126 (Hermes Tier-1 3-tier memory) + docs/SKILLS-MATRIX.md Skill 1 CMS — KEEP, cross-link"
  - "ADR-098 (sandbox session recorder/replay) — KEEP, cross-link"
  - "ADR-135 (held-out validation gate — verification criteria below must pass it)"
il_anchor: IL-566
il_anchor_note: "Provisional per ADR-119 Rule 8 — frozen to max+1 over origin/main at rebase-before-merge."
external_ref: "github.com/zhangfengcdt/memoir — referenced by ADR-137, NOT imported"
---

# MEMOIR-PILOT-PRECOND-04 — One-substrate-per-fork (agentmemory XOR Memoir)

> **Verifiable governance CONTRACT, not an implementation.** Defines WHAT Precondition #4 of ADR-137
> must guarantee and HOW it is proven. No runtime, no code, no config, no secret, no import of
> `github.com/zhangfengcdt/memoir`. Building it is the subsequent gated work item.

## 1. Scope

Applies to the **Memoir factory-only pilot** under the **ADR-137 / ADR-136 envelope** (factory fork
only; project fork disabled by default). Governs **how many** production memory substrates a fork may
run. It does **not** authorise a pilot.

## 2. XOR invariant

Each fork runs **EXACTLY ONE** production memory substrate — **agentmemory XOR Memoir** — **never both
as competing production stores** (ADR-137 L81-82, L104). The two are mutually exclusive per fork: if
agentmemory is the active substrate, the Memoir pilot is not running in that fork as a production store,
and vice-versa.

## 3. Primary substrate

**agentmemory (ADR-136) remains the PRIMARY substrate.** Memoir is a **pilot / alternative backend**,
not a second production store; it does not displace agentmemory by default. Running the Memoir pilot in
a fork means that fork's single substrate is Memoir **for the pilot's duration**, under all preconditions
— it does not mean both coexist.

## 4. Source of truth (independent of substrate choice)

The **ledger (ADR-059) is ALWAYS the source of truth**, regardless of which substrate a fork runs.
Choosing agentmemory or Memoir changes **only** the convenience/observability substrate; it **never**
changes ledger authority. No substrate is ever the source of truth and none carries authority (composes
with read-only-w.r.t.-authority, ADR-130/127).

## 5. Fail-closed enforcement

- **Two active substrates in one fork ⇒ fail-closed** — detection of both agentmemory and Memoir active
  as production stores in the same fork halts: **no pilot start / no writes** (deny-by-default).
- **Substrate switch is an explicit operator action** — moving a fork from agentmemory to Memoir (or
  back) requires a deliberate operator decision; it is **never automatic** and never silently inferred.
  Ambiguous/contended substrate state ⇒ fail-closed.

## 6. Composition with #1 / #2 / #3

One substrate per fork ⇒ **one coherent set of boundaries per fork**: the active substrate's
redaction (#1), retention/purge (#2), and replay-scope (#3) are the fork's boundaries. There is no
second store to leak around them; the XOR invariant prevents a sensitive item from existing in a
parallel, differently-bounded substrate within the same fork.

## 7. Relation to existing canon (KEEP, cross-link — not duplicated)

- **ADR-136 / agentmemory** — the primary substrate line (unchanged).
- **ADR-059 (ledger shards)** — source of truth (unchanged).
- **ADR-126 (Hermes 3-tier memory) + CMS (SKILLS-MATRIX Skill 1)** — distinct memory layers (process /
  Hermes), not production substrates; unaffected by the XOR rule.
- **ADR-098 (sandbox recorder/replay)** — distinct observability surface.

## 8. Verification criteria — how the XOR invariant is proven

Precondition #4 is **DONE only when** all hold, as a **held-out** suite passing the **ADR-135 gate with
zero regressions**:

1. **Two substrates in one fork → blocked/fail-closed** — attempting both active in a fork is denied;
   the fork refuses to start/write.
2. **agentmemory primary** — default substrate is agentmemory; Memoir runs only as an explicitly-selected
   pilot.
3. **Ledger remains source of truth** — under either substrate, the ledger (ADR-059) is authoritative;
   substrate choice does not alter ledger authority.
4. **Switch requires operator** — substrate change is gated on an explicit operator action; no automatic
   switch; contended/ambiguous state ⇒ fail-closed.

## 9. Sign-off

Marking Precondition #4 = **DONE** requires **operator + IronClaw (security-review) sign-off**, recorded
in the ledger/ADR trail. Without **both**, #4 stays open and **no Memoir runtime may start** (fail-closed).

## 10. Non-goals (explicit)

Specification only. Ships **no** substrate selector, no config/stub, no Memoir deployment. Implementation
(the XOR enforcement + tests) is a **subsequent gated work item** under ADR-137, itself subject to this
contract and ADR-135.

## Anchors

- ADR-137 (Pilot Entry Preconditions; #4 = this; L81-82, L104), MEMOIR-PILOT-PRECOND-01/02/03 (siblings),
  ADR-136 (primary substrate), ADR-059 (source of truth), ADR-126 + CMS (distinct memory layers),
  ADR-098 (sandbox replay), ADR-130/127 (no authority / Tier-1), ADR-135 (held-out gate). External:
  `github.com/zhangfengcdt/memoir` (referenced by ADR-137, NOT imported). Enforcement = CI gates + these
  ADRs; this spec carries no runtime/config/secret.
