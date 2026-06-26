---
id: MEMOIR-PILOT-PRECOND-06
title: Memoir pilot — Precondition #6 Sensitive domains OUT OF SCOPE by default (RED zone) — verifiable contract
status: PROPOSED
date: 2026-06-27
concept_only: true
relates:
  - "ADR-137 (Memoir factory-only PILOT, ACCEPTED; this specifies its Pilot Entry Precondition #6; L67-68)"
  - "ADR-136 (agentmemory substrate — sensitive OUT OF SCOPE envelope)"
  - "MEMOIR-PILOT-PRECOND-01 (redaction — RED zone dropped at capture) / 03 (replay — RED zone replay forbidden) / 05 (non-prod project excludes RED zone)"
  - "ADR-130/127 (no authority expansion / Tier-1 read-only — no authority over sensitive flows; precursor to #7)"
  - "ADR-135 (held-out validation gate — verification criteria below must pass it)"
il_anchor: IL-602
il_anchor_note: "Provisional per ADR-119 Rule 8 — frozen to max+1 over origin/main at rebase-before-merge."
external_ref: "github.com/zhangfengcdt/memoir — referenced by ADR-137, NOT imported"
---

# MEMOIR-PILOT-PRECOND-06 — Sensitive domains OUT OF SCOPE by default (RED zone)

> **Verifiable governance CONTRACT, not an implementation.** Defines WHAT Precondition #6 of ADR-137
> must guarantee and HOW it is proven. No runtime, no code, no config, no secret, no import of
> `github.com/zhangfengcdt/memoir`. Building it is the subsequent gated work item.

## 1. Scope

Applies to the **Memoir factory-only pilot** under the **ADR-137 / ADR-136 envelope**. Governs which
data **domains** the pilot may touch. It does **not** authorise a pilot.

## 2. RED zone definition (ADR-137 L67-68)

The **RED zone** is: **payment-core, KYC, AML, sanctions, ledger, secrets-bearing flows, and customer
PII.** The RED zone is **AI-FORBIDDEN** to the substrate.

## 3. OUT OF SCOPE by default

RED-zone domains are **EXCLUDED from the pilot by default.** There is **no capture, no store, and no
replay** of RED-zone content. The default posture is exclusion, not inclusion-with-controls.

## 4. Expansion gate

**Any** pilot access to the RED zone requires a **SEPARATE ADR + operator + IronClaw sign-off**
(ADR-137 L68). Without all three, RED-zone access is **forbidden** — there is no path to sensitive
domains through configuration, flags, or precedent alone.

## 5. Fail-closed detection (deny-by-default)

On **detection OR uncertainty** of RED-zone classification, the pilot **denies by default**:
**drop / no-store / no-replay**, and **no pilot start** if RED-zone exposure cannot be excluded.
**"Possibly sensitive" is treated as sensitive** — absence of a confident NON-sensitive classification
is not permission. A classifier error/timeout ⇒ treat as sensitive ⇒ exclude.

## 6. Composition with #1 / #3 / #5

- **#1 (redaction)** — RED-zone content is **dropped before write** (fail-closed); #6 makes that
  exclusion a domain-level default, not just a field-level filter.
- **#3 (replay-scope)** — RED-zone **replay is forbidden**; even in-scope replay cannot surface RED-zone
  content (it was never stored).
- **#5 (factory-fork-only / non-prod project)** — even a (default-disabled, operator-approved) non-prod
  project fork **excludes the RED zone**; sensitive domains are out of scope in every fork.

## 7. No authority over sensitive flows (precursor to #7)

The pilot acquires **no authority** over payment / dispatch / ledger / merge / deploy. Memory of (or
about) a sensitive flow confers **no right to act** on it — memory describes, never authorizes
(ADR-130/127). #7 makes this the general no-authority-expansion rule; #6 fixes it for the sensitive
domains specifically.

## 8. Verification criteria — how "RED zone out of scope" is proven

Precondition #6 is **DONE only when** all hold, as a **held-out** suite passing the **ADR-135 gate with
zero regressions**:

1. **RED-zone capture → blocked** — attempts to capture/store payment/KYC/AML/sanctions/ledger/secrets/
   PII are denied (fail-closed).
2. **RED-zone replay → blocked** — no replay surfaces RED-zone content.
3. **Ambiguous → treated as sensitive** — uncertain classification fails closed (drop/no-store), never
   stored "just in case".
4. **Access without a separate ADR → forbidden** — no RED-zone access absent a separate ADR + operator
   + IronClaw.

## 9. Sign-off

Marking Precondition #6 = **DONE** requires **operator + IronClaw (security-review) sign-off**, recorded
in the ledger/ADR trail. Without **both**, #6 stays open and **no Memoir runtime may start**
(fail-closed).

## 10. Non-goals (explicit)

Specification only. Ships **no** classifier, no config/stub, no Memoir runtime. Implementation (RED-zone
detection/exclusion + tests) is a **subsequent gated work item** under ADR-137, itself subject to this
contract and ADR-135.

## Anchors

- ADR-137 (Pilot Entry Preconditions; #6 = this; L67-68 RED zone), MEMOIR-PILOT-PRECOND-01/03/05
  (compose), MEMOIR-PILOT-PRECOND-02/04 (siblings), ADR-136 (envelope), ADR-130/127 (no authority /
  Tier-1), ADR-135 (held-out gate). External: `github.com/zhangfengcdt/memoir` (referenced by ADR-137,
  NOT imported). Enforcement = CI gates + these ADRs; this spec carries no runtime/config/secret.
