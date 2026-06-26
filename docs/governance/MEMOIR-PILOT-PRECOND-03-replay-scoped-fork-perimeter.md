---
id: MEMOIR-PILOT-PRECOND-03
title: Memoir pilot — Precondition #3 Replay scoped to fork+perimeter (observability-only) — verifiable contract
status: PROPOSED
date: 2026-06-27
concept_only: true
relates:
  - "ADR-137 (Memoir factory-only PILOT, ACCEPTED; this specifies its Pilot Entry Precondition #3)"
  - "MEMOIR-PILOT-PRECOND-01 (redaction) + MEMOIR-PILOT-PRECOND-02 (retention/purge) — replay composes with both"
  - "ADR-136 (agentmemory substrate envelope — replay boundaries)"
  - "ADR-117 (factory/project perimeter — replay binds to ONE fork+perimeter)"
  - "ADR-130/127 (read-only w.r.t. authority / Tier-1 — replay is observability, never re-execution)"
  - "ADR-098 (sandbox session recorder & replay) + ADR-059 (ledger shards = memory of record) — KEEP, cross-link"
  - "ADR-135 (held-out validation gate — verification criteria below must pass it)"
il_anchor: IL-565
il_anchor_note: "Provisional per ADR-119 Rule 8 — frozen to max+1 over origin/main at rebase-before-merge."
external_ref: "github.com/zhangfengcdt/memoir — referenced by ADR-137, NOT imported"
---

# MEMOIR-PILOT-PRECOND-03 — Replay scoped to fork+perimeter (observability-only)

> **Verifiable governance CONTRACT, not an implementation.** Defines WHAT Precondition #3 of ADR-137
> must guarantee and HOW it is proven. No runtime, no code, no config, no secret, no import of
> `github.com/zhangfengcdt/memoir`. Building it is the subsequent gated work item.

## 1. Scope

Applies to the **Memoir factory-only pilot** under the **ADR-137 / ADR-136 envelope** (factory fork
only; project fork disabled by default; one-substrate-per-fork). Governs how captured memory may be
**replayed**. It does **not** authorise a pilot.

## 2. Perimeter-binding (ADR-117) — fail-closed

Replay is **strictly confined to ONE fork + perimeter.** **Cross-fork and cross-perimeter replay are
FORBIDDEN** — a replay request that names a source/target outside the current fork+perimeter is
**denied (fail-closed)**, never partially served. No shared replay store; factory-fork memory is never
replayed into a (default-disabled) project fork or vice-versa.

## 3. Replay = observability ONLY (never re-execution)

Replay reproduces **past context for debugging / blame / inspection** — it **NEVER re-executes
privileged actions.** A replay MUST NOT trigger code execution, ledger writes, production-state changes,
payments, deploys, or agent dispatch. This is the **read-only-w.r.t.-authority** guarantee (ADR-130/127):
replay **describes** what happened; it never **re-does** it. Memory carries no authority.

## 4. RED zone (ADR-137 line 68)

**Capture/replay of sensitive domains — payment-core, KYC, AML, sanctions, ledger, secrets-bearing
flows, customer PII — is FORBIDDEN without a separate ADR + operator + IronClaw sign-off.** Absent that,
a replay touching the RED zone is **denied (fail-closed)**, not masked-and-served. RED zone is
AI-FORBIDDEN to the substrate by default.

## 5. Composition with #1 (redaction) and #2 (retention/purge)

Replay **cannot resurrect content that redaction (PRECOND-01) dropped or that purge (PRECOND-02)
removed** (consistent with ADR-137 lines 79-80). Replay reads only what currently, lawfully exists in
the in-scope store: **redacted content was never stored; purged content is gone** — neither is
recoverable via replay, rollback, blame, or checkout. The three preconditions compose: redact-at-write
→ bounded-retain/purge → replay-only-within-scope.

## 6. Relation to existing canon (KEEP, cross-link — not duplicated)

- **ADR-098 (sandbox session recorder & replay)** — a distinct existing replay surface (sandbox
  observability over advisory seams); Memoir replay does not replace or duplicate it.
- **ADR-059 (per-session ledger shards)** — the canonical **memory of record**; replay is convenience
  observability, never the source of truth and never an authority source.

## 7. Verification criteria — how "scoped + observability-only" is proven

Precondition #3 is **DONE only when** all hold, as a **held-out** suite passing the **ADR-135 gate with
zero regressions**:

1. **Cross-perimeter replay blocked** — replay across fork/perimeter is denied (fail-closed); only
   same-fork+perimeter replay succeeds.
2. **No privileged action on replay** — fault/observation tests confirm replay triggers **no** code/
   ledger/prod/payment/deploy/dispatch action (read-only w.r.t. authority).
3. **RED-zone replay fail-closed** — any replay touching payment/KYC/AML/sanctions/ledger/secrets/PII is
   denied absent a separate ADR + operator + IronClaw.
4. **Purged/redacted not replayable** — content dropped by #1 or removed by #2 cannot be reproduced via
   replay/rollback/blame/checkout.

## 8. Sign-off

Marking Precondition #3 = **DONE** requires **operator + IronClaw (security-review) sign-off**, recorded
in the ledger/ADR trail. Without **both**, #3 stays open and **no Memoir runtime may start** (fail-closed).

## 9. Non-goals (explicit)

Specification only. Ships **no** replay engine, no config/stub, no Memoir deployment. Implementation
(scoped replay + its tests) is a **subsequent gated work item** under ADR-137, itself subject to this
contract and ADR-135.

## Anchors

- ADR-137 (Pilot Entry Preconditions; #3 = this; L68 RED zone, L79-80 redaction/rollback),
  MEMOIR-PILOT-PRECOND-01/02 (siblings), ADR-136 (envelope), ADR-117 (perimeter), ADR-130/127 (no
  authority / Tier-1), ADR-098/059 (sandbox replay / ledger record — KEEP, cross-link), ADR-135
  (held-out gate). External: `github.com/zhangfengcdt/memoir` (referenced by ADR-137, NOT imported).
  Enforcement = CI gates + these ADRs; this spec carries no runtime/config/secret.
