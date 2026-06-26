---
id: MEMOIR-PILOT-PRECOND-05
title: Memoir pilot — Precondition #5 Factory-fork-only / Project-fork disabled by default — verifiable contract
status: PROPOSED
date: 2026-06-27
concept_only: true
relates:
  - "ADR-137 (Memoir factory-only PILOT, ACCEPTED; this specifies its Pilot Entry Precondition #5; L65, L87, L105)"
  - "ADR-136 (agentmemory substrate — factory/project fork split; envelope)"
  - "ADR-117 (factory/project perimeter — factory and project are distinct perimeters)"
  - "MEMOIR-PILOT-PRECOND-01/02/03/04 (redaction / retention / replay / one-substrate — boundaries hold in the factory fork)"
  - "ADR-135 (held-out validation gate — verification criteria below must pass it)"
il_anchor: IL-567
il_anchor_note: "Provisional per ADR-119 Rule 8 — frozen to max+1 over origin/main at rebase-before-merge."
external_ref: "github.com/zhangfengcdt/memoir — referenced by ADR-137, NOT imported"
---

# MEMOIR-PILOT-PRECOND-05 — Factory-fork-only / Project-fork disabled by default

> **Verifiable governance CONTRACT, not an implementation.** Defines WHAT Precondition #5 of ADR-137
> must guarantee and HOW it is proven. No runtime, no code, no config, no secret, no import of
> `github.com/zhangfengcdt/memoir`. Building it is the subsequent gated work item.

## 1. Scope

Applies to the **Memoir factory-only pilot** under the **ADR-137 / ADR-136 envelope**. Governs **where**
the pilot may run (which fork / perimeter). It does **not** authorise a pilot.

## 2. Factory-fork-first (ADR-137 L65)

The pilot executes **ONLY on the factory node, in the factory fork.** There is **no execution outside
the factory fork.** Any attempt to run the pilot outside the factory fork is **denied (fail-closed)**.

## 3. Project-fork disabled by default (ADR-137 L105)

The **project fork is DISABLED by default.** Enabling it requires an **EXPLICIT operator approval** — it
is **never automatic** and **never enabled by config alone**. Absent a deliberate, recorded operator
decision, the project fork does not run.

## 4. No project deployment without operator approval — fail-closed

Any project deployment **without explicit operator approval ⇒ fail-closed** (deny-by-default): **no
writes / no pilot start** in the project fork. "Config says enabled" is not approval; only a recorded
operator action authorises a project fork.

## 5. Non-prod project constraints (ADR-137 L87)

Even **with** operator approval, a project fork is limited to **non-sensitive / non-production** context
only:

- **RED zone EXCLUDED** — payment-core, KYC, AML, sanctions, ledger, secrets-bearing flows, customer PII
  are out of scope (AI-FORBIDDEN); their capture/replay needs a separate ADR + operator + IronClaw.
- **Production project FORBIDDEN within the pilot** — the pilot never runs against a production project
  environment; non-prod only.

## 6. Perimeter-binding (ADR-117)

Factory and project are **distinct perimeters.** The pilot **does not cross the factory↔project
perimeter** without explicit operator approval; factory-fork memory never flows into a project fork (or
vice-versa) by default. This composes with PRECOND-03 (replay scoped to fork+perimeter).

## 7. Composition with #1 / #2 / #3 / #4

Factory-fork-only ⇒ the pilot's redaction (#1), retention/purge (#2), replay-scope (#3) and
one-substrate-per-fork (#4) boundaries all apply **within the factory fork**. Confining execution to the
factory fork keeps every prior precondition's guarantees inside a single, bounded perimeter.

## 8. Verification criteria — how "factory-fork-only / project-off" is proven

Precondition #5 is **DONE only when** all hold, as a **held-out** suite passing the **ADR-135 gate with
zero regressions**:

1. **Execution outside the factory fork → blocked/fail-closed.**
2. **Project fork off by default** — it does not run absent explicit operator approval; config-only
   enablement is rejected.
3. **Project deploy without approval → fail-closed** (no writes / no pilot start).
4. **RED zone in project → forbidden**; production project → forbidden within the pilot (even with
   approval, only non-sensitive/non-prod).

## 9. Sign-off

Marking Precondition #5 = **DONE** requires **operator + IronClaw (security-review) sign-off**, recorded
in the ledger/ADR trail. Without **both**, #5 stays open and **no Memoir runtime may start**
(fail-closed).

## 10. Non-goals (explicit)

Specification only. Ships **no** deployment selector, no config/stub, no Memoir runtime. Implementation
(the fork/perimeter gating + tests) is a **subsequent gated work item** under ADR-137, itself subject to
this contract and ADR-135.

## Anchors

- ADR-137 (Pilot Entry Preconditions; #5 = this; L65 factory-fork-first, L87 non-prod project, L105
  project-off-by-default), MEMOIR-PILOT-PRECOND-01/02/03/04 (siblings), ADR-136 (fork split), ADR-117
  (perimeter), ADR-135 (held-out gate). External: `github.com/zhangfengcdt/memoir` (referenced by
  ADR-137, NOT imported). Enforcement = CI gates + these ADRs; this spec carries no runtime/config/secret.
