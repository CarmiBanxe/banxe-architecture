# Conflict Ledger — inter-terminal deconfliction + merge discipline

> **Status:** governance mechanism. **Date:** 2026-06-30. **Line 4 of 7.** **Pointer-first and additive** — it
> adds the deconfliction *journal*, the *priority* ordering, and the *merge-discipline* rules, and points to the
> existing arbitration, merge-queue, and ownership canon for everything else (ADR-102, no restatement).

## 1. Conflict journal
When two terminals — Central, B (right), or A (factory) — touch **overlapping write-zones or files** (overlap
detected against `TERMINAL-OWNERSHIP.md`), the factory, as arbiter (**ADR-154**), **registers** the overlap and
**deconflicts** it along one of two axes:

- **By time** — serialize: one change merges first, the other rebases onto the new `main` and regenerates. The
  *serialization mechanism* itself is the merge queue (`LEDGER-MERGE-QUEUE.md`); this journal records *that a
  conflict occurred and how it was resolved*.
- **By files** — split: the change is partitioned so each terminal owns a disjoint file set, removing the
  overlap entirely.

A journal entry records, at minimum: **when**, **which terminals**, **the overlapping zone/file**, and **the
resolution** (time-serialized or file-split). Where the journal physically lives is **[НЕИЗВЕСТНО]** — a
dedicated file versus an append-only ledger section is an operator decision (§5).

## 2. Priority rule
When directives compete for the same zone or file, precedence is:

> **active operator directive  >  Terminal B planned work  >  Terminal A autonomous GAP queue.**

The higher-priority work proceeds; the lower-priority work **yields** — it defers, or rebases onto the result of
the higher-priority change. This makes the autonomous GAP queue (Terminal A) always cede to planned work and to
any live operator directive, which is consistent with the NO-WAIT discipline (Central never blocks on A, and A's
autonomous output never blocks a directive).

## 3. Merge discipline
1. **All PRs target `main`** — never another feature branch.
2. **Stacked PRs are forbidden** unless the **merge order is explicitly declared in the PR description**. An
   undeclared stack is rejected, because its hidden ordering is exactly what produces merge races.
3. **Doc-sync / commit-log files** are handled by a **separate append-only mechanism**, NOT carried in feature
   branches. They append (per the ADR-059 shard pattern) rather than being edited on a branch, which avoids the
   dirty cycles and repeated rebases that branch-carried sync files produce.

## 4. Pointer-first — existing canon this binds (ADR-102, not restated)
- **ADR-154** — the factory is the single arbiter of shared-space boundaries (this journal is how it records and
  resolves them).
- `docs/governance/LEDGER-MERGE-QUEUE.md` — the serialization mechanism / merge-queue procedure for
  ledger-touching PRs (the "by time" axis above).
- `docs/governance/TERMINAL-OWNERSHIP.md` — the write-zone registry against which overlap is detected.
- `.claude/rules/parallel-session-isolation.md` (Rules 1–8) — rebase-on-behind, lease, "a duplicate is a rebase
  signal."
- **ADR-059 / ADR-057** — append-only per-session shards (the doc-sync mechanism in §3.3).

## 5. [НЕИЗВЕСТНО]
- The physical location/format of the conflict journal (dedicated file vs ledger section) — operator decision.
- Whether the merge-discipline rules (§3) are enforced as a CI / Guardian gate or remain advisory — operator
  decision.

## Anchors
ADR-154 · `LEDGER-MERGE-QUEUE.md` · `TERMINAL-OWNERSHIP.md` · `parallel-session-isolation` (Rules 1–8) ·
ADR-059 / ADR-057 · ADR-060. Complements line-1 (ownership), line-2 (ADR-154 arbitration), line-3 (CTIO
carry-forward). Operator directive 2026-06-30 (line 4 of 7).
