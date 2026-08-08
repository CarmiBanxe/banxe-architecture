# ADR-166: Memory Layering — Decision-Memory + Working-Memory + Ledger SoT (complementary, XOR clarified)

- **Status:** proposed
- **Date:** 2026-07-09
- **Relates:** ADR-136 (agentmemory shared-memory substrate), ADR-137 (memoir versioned-memory pilot), ADR-059 (IL append-serialization / ledger SoT), ADR-130 (SOUL.md persona layer — no authority), ADR-127 (Hermes factory-delegation contract), ADR-117 (factory/project perimeter), ADR-102 (no-restate / pointer-first)
- **Amended-by:** ADR-166-A (MemoHarness layer-promotion amendment, merged #1212, ed99da5c)

## Context

Operator ruling: the two memory contours must **COEXIST, complement each other, and add reliability
— not either/or**. This ADR records that ruling and resolves the apparent tension with the memoir
XOR precondition. It is **document-only** and changes no code, config, or perimeter.

Audited facts (current `main`, referenced not restated per ADR-102):

- **reasoning_bank** (emi-stack) = **PROJECT decision-memory**. Append-only / immutable — *"a stored
  decision is never edited or deleted"*; carries EU AI Act Art.13 explainability; feedback is **never
  auto-applied** (I-27). It is the **authoritative decision-record** of *what was decided and why*.
- **memoir** (`factory/memoir`) = **FACTORY working-memory**. Git-plumbing versioned recall,
  explicitly **non-authoritative** — *"Ledger ADR-059 stays source of truth"*; regenerable; **never
  touches code / ledger / prod / dispatch**. It is fast versioned recall of *how the agent worked*.
- **Ledger** (ADR-059) = the **canonical memory of record**, the **supreme source of truth**.

The precondition in question — **PRECOND-04 (XOR)** from the memoir pilot — forbids two memory
substrates on one fork. Read naively, that could be taken to bar reasoning_bank and memoir from
coexisting. The operator ruling and this ADR clarify that reading: XOR is **role-scoped**, not
contour-scoped.

## Decision — three complementary layers (reliability by defense-in-depth)

1. **Authority hierarchy.** `Ledger (ADR-059 SoT)` **>** `reasoning_bank (authoritative
   decision-memory)` **>** `memoir (non-authoritative working-memory)`. Each lower layer **defers**
   to the higher; **none overrides the ledger**. Conflicts resolve upward.

2. **Role separation (why they coexist).** Decision-memory answers **WHAT was decided** (immutable,
   audit-grade, Art.13-explainable); working-memory answers **HOW the agent worked** (versioned,
   disposable). These are **different questions on different perimeters** — reasoning_bank is
   *project*, memoir is *factory* — not two answers to the same question.

3. **XOR clarification (PRECOND-04).** The XOR forbids **two substrates OF THE SAME ROLE on one
   fork** (e.g. `agentmemory` XOR `memoir` as the *working-memory* substrate). It does **NOT** forbid
   a **decision-memory layer and a working-memory layer coexisting** — they are different roles, not
   competing production stores. **reasoning_bank + memoir coexistence is PERMITTED.**

4. **Reliability (defense-in-depth).** Losing working-memory (memoir) loses **nothing authoritative**
   — memoir is regenerable, and the ledger + reasoning_bank immutability preserve the record. memoir
   adds **fast versioned recall without ever becoming authority**. Layering increases reliability;
   it never concentrates it in a disposable store.

5. **Perimeter (ADR-117).** Factory `memoir` and project `reasoning_bank` share **NO store**; there
   is **no cross-perimeter memory**. Coexistence is *across perimeters*, never a shared substrate.

6. **No authority (ADR-130 / ADR-127).** All layers are **read-only w.r.t. authority**; a recall
   **never confers a permission** and never mutates code / ledger / prod / dispatch.

## Consequences

**Positive**

- The two contours are **canonically recognized as complementary** (operator ruling satisfied), with
  the **XOR precondition intact** (re-scoped to *same-role-on-one-fork*, not weakened).
- **Reliability via layering:** ledger SoT + immutable decision-memory + regenerable working-memory —
  no single memory store is both authoritative and disposable.

**Negative / constraints**

- A **future project working-memory** (a working-memory layer on the project fork) remains
  **XOR-gated within its role** and would require **its own ADR + IronClaw** review before adoption —
  this ADR does not pre-authorize it.

## Alternatives Considered

- **Single unified memoir for both forks** — **REJECTED**: violates the ADR-117 factory/project
  perimeter and the memoir PRECOND-05 (factory-only) constraint.
- **Two competing substrates of the same role on one fork** — **REJECTED**: this is exactly what
  PRECOND-04 (XOR) forbids; only role-distinct layers may coexist.

## Anchors

- ADR-136 (agentmemory shared-memory substrate envelope)
- ADR-137 (memoir versioned-memory pilot — PRECOND-04 XOR, PRECOND-05 factory-only)
- ADR-059 (IL append-serialization — ledger as supreme source of truth)
- ADR-130 / ADR-127 (no authority; recall confers no permission)
- ADR-117 (factory/project perimeter — no cross-perimeter memory)
- reasoning_bank soul (emi-stack) — authoritative, append-only decision-memory
- `factory/memoir` README — non-authoritative, regenerable working-memory
