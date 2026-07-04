# Factory Operating Rules — pointer / entry-point (NOT a canon source)

This document is an **index only**. It is a navigation entry-point to the factory operating
rules that are **already canonical elsewhere** in this repository. It is **not** a normative
source: it defines no rule, and it does not restate rule bodies. It exists because a
duplication-audit (ADR-102) concluded that a fresh standalone "factory canon" file would
duplicate existing canon and drift from it — so this file only **links** to the source-of-truth.

## Source of Truth

Execution-lane rules ("all work through the factory; shell only for read-only audit"):
- [`.claude/rules/agents.md`](../../.claude/rules/agents.md) — § "Factory-Only Execution", § "Best Single Artifact"
- [`AGENTS.md`](../../AGENTS.md) — mirror of the above
- [`CLAUDE.md`](../../CLAUDE.md) — global "CENTRAL TERMINAL" rules

Duplication gate ("mandatory duplication check before any structural change / code"):
- [`docs/adr/ADR-102-no-smart-refactor-without-duplication-verification.md`](../adr/ADR-102-no-smart-refactor-without-duplication-verification.md)
- [`.claude/rules/agents.md`](../../.claude/rules/agents.md) — restates the ADR-102 hard rule

Consolidated context:
- [`docs/canon/software-factory-canon-v1.md`](../canon/software-factory-canon-v1.md)
- [`docs/factory/FACTORY-CANON-ADDENDUM-2026-05-12.md`](./FACTORY-CANON-ADDENDUM-2026-05-12.md)

## How to Use

- For **execution-lane rules** → read `.claude/rules/agents.md` / `AGENTS.md` / `CLAUDE.md`.
- For the **duplication gate** → read `ADR-102` first, before any structural change.
- For **consolidated context** → read `software-factory-canon-v1.md` and the addendum.

## Non-Goals

- This file **does not duplicate** canon — it links to it.
- This file **does not supersede** any ADR or rule — the linked sources always take precedence.
- This file **remains link-only** except for the minimal navigation text above; if a rule changes,
  update the source-of-truth file, never this pointer.
