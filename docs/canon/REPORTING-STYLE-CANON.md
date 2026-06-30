# Reporting-Style Canon — factory reports to the operator

> **Status:** behavioural canon (prose style). **Operator-mandated 2026-06-30.** Pointer-style and additive —
> it governs the *prose* of factory reports and does **not** alter the Best Single Artifact canon, which
> remains in force.

## Rule
All factory reports to the operator MUST be written in **plain, expansive, academic language**:

1. **Explain, do not merely list.** Every report explains substance, causes, and context in full sentences —
   not terse tables standing alone. The reader should understand *what* happened, *why* it happened, and *what
   it means* from the prose itself.
2. **Tables and data support; they do not replace.** Structured data (tables, gate summaries, file lists) may
   accompany a report to make specific facts scannable, but the report as a whole must read as **clear
   explanatory prose**. A table without surrounding explanation is incomplete.
3. **Scope.** This applies to status reports, triage findings, audit summaries, and gate/merge updates — every
   class of operator-facing report the factory produces.

## Relationship to existing canon (unchanged)
This rule governs **prose style only**. It is additive and does **not** weaken or override the **Best Single
Artifact** canon, which remains fully in force:

- exactly **one** next-action artifact after any output;
- artifact-type **routing** — `[CLAUDE CODE]` for any state change, `[SHELL]` for read-only audit/diagnostics;
- **no self-deviation** from the chosen artifact;
- **operator-line priority** (the operator's instruction takes precedence).

The prose-style rule simply requires that the *explanation accompanying* that single artifact be expansive,
causal, and readable — not compressed into bare tables.

## Anchors
- `AGENTS.md` §"CANON — Best Single Artifact" and `.claude/rules/agents.md` §"CANON — Best Single Artifact"
  (the artifact-routing canon this complements, unchanged).
- Operator directive 2026-06-30 (this canon's origin).
