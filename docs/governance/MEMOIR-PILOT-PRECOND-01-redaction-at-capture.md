---
id: MEMOIR-PILOT-PRECOND-01
title: Memoir pilot — Precondition #1 Redaction-at-capture (fail-closed) — verifiable contract
status: PROPOSED
date: 2026-06-27
concept_only: true
relates:
  - "ADR-137 (Memoir factory-only PILOT, ACCEPTED; this specifies its Pilot Entry Precondition #1)"
  - "ADR-136 (agentmemory substrate envelope — redaction/retention/replay boundaries)"
  - "ADR-135 (held-out validation gate — verification criteria below must pass it)"
  - "ADR-130/127 (no authority expansion; Tier-1 read-only)"
  - "ADR-117 (factory/project perimeter)"
il_anchor: IL-563
il_anchor_note: "Provisional per ADR-119 Rule 8 — frozen to max+1 over origin/main at rebase-before-merge."
external_ref: "github.com/zhangfengcdt/memoir — referenced by ADR-137, NOT imported"
---

# MEMOIR-PILOT-PRECOND-01 — Redaction-at-capture (fail-closed)

> **This is a verifiable governance CONTRACT, not an implementation.** It defines WHAT
> Precondition #1 of ADR-137 must guarantee and HOW it is proven "implemented + tested". No runtime,
> no code, no config, no secret, no import of `github.com/zhangfengcdt/memoir`. Building it is the
> subsequent gated work item.

## 1. Scope

Applies to the **Memoir factory-only pilot** under the **ADR-137 / ADR-136 envelope** (factory fork
only; project fork disabled by default; one-substrate-per-fork). It governs **every capture path** into
Memoir — session/tool context, semantic paths, blame, and any stored derivative. It does **not**
authorise a pilot; ADR-137 Pilot Entry Preconditions still gate that.

## 2. Fail-closed principle (deny-by-default)

Redaction runs **before anything is persisted**. On **any** classification uncertainty — unknown class,
parser failure, partial match, ambiguous span — the item is **DROPPED, not stored** (deny-by-default).
"Allow" requires a positive, confident NON-sensitive classification; absence of a match is **not**
allow. There is **no fail-open path**: a redaction-engine error or timeout ⇒ drop the capture, never
store raw.

## 3. Data classes under MANDATORY redaction before write

A capture MUST be redacted (or dropped) before storage if it contains any of:

- **Secrets / credentials / tokens** — API keys, passwords, bearer/OAuth tokens, private keys, `.env`
  values, connection strings, session cookies.
- **PII** — customer personal data (names+identifiers, addresses, emails, phone, DOB, national IDs).
- **RED zone (ADR-137 OUT OF SCOPE)** — payment-core, **KYC, AML, sanctions, ledger** state and any
  identifiers/artefacts derived from them. RED zone is AI-FORBIDDEN to the substrate by default; it is
  **dropped**, not merely masked, absent a separate ADR + operator + IronClaw.

(The class list is **config-as-data**, operator-owned, extensible; it is never narrowed below this set.)

## 4. Coverage — redaction is end-to-end, not capture-only

Redaction MUST hold across **every** Memoir surface, so sensitive content cannot re-enter via a side
channel (consistent with **ADR-137 lines 79-80**, "Semantic paths / blame respect redaction; rollback
cannot resurrect redacted content"):

- **Semantic paths** — path keys/segments are redacted; a sensitive value cannot leak through a path.
- **Blame / checkout output** — blame and historical checkout return redacted content only.
- **Rollback / merge** — a rollback or memory-merge **cannot resurrect redacted/sensitive content**;
  redaction is applied at write so no prior version holds the raw value to roll back to.

## 5. Verification criteria — how "implemented + tested" is proven

Precondition #1 is **DONE only when** all hold:

1. A **boundary/redaction test-suite** exists covering each §3 class **and** each §4 surface (capture,
   semantic path, blame, checkout, rollback, merge), including **negative/uncertainty cases** that MUST
   drop (fail-closed) and **adversarial** cases (obfuscated secrets, split tokens, PII in free text).
2. The suite runs as a **held-out set** and passes the **ADR-135 held-out validation gate with zero
   regressions** on boundary/redaction checks (no sensitive leak; all uncertainty ⇒ drop).
3. **Coverage evidence** — every §3 class × §4 surface has at least one passing test; any gap ⇒ NOT DONE.
4. **No fail-open observed** — fault-injection (engine error/timeout) results in drop, never raw store.

## 6. Sign-off

Marking Precondition #1 = **DONE** requires **operator + IronClaw (security-review) sign-off**, recorded
in the ledger/ADR trail. Without both, #1 stays open and **no Memoir runtime may start** (fail-closed).

## 7. Non-goals (explicit)

This document is a **specification**, not a runtime. It ships **no** redaction engine, regex/classifier,
config file, or Memoir deployment. Implementation (the redaction engine + its config + tests) is a
**subsequent gated work item** under ADR-137, itself subject to this contract and ADR-135.

## Anchors

- ADR-137 (Pilot Entry Preconditions; #1 = this), ADR-136 (envelope), ADR-135 (held-out gate),
  ADR-130/127 (no authority / Tier-1), ADR-117 (perimeter). External: `github.com/zhangfengcdt/memoir`
  (referenced by ADR-137, NOT imported). Enforcement = CI gates + these ADRs; this spec carries no
  runtime and no secrets.
