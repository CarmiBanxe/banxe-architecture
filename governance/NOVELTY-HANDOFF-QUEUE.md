# NOVELTY-HANDOFF-QUEUE — Terminal A (Factory) Event Log

**Status:** PROPOSED (scaffolding — pipeline NOT activated)
**Owner:** Terminal A (Factory) — factory-watcher single-writer
**Consumer:** Central + operator (HITL merge gate)
**Append-only (I-24 / I-28).** No row edits. No row deletes. New event rows
appended at the bottom of the `## Entries` table by the factory-watcher only.
**ADR:** `docs/adr/ADR-159-ba-novelty-auto-handoff-pipeline.md` (Outcome-1
hand-off channel, D-1)
**Created:** 2026-07-05

---

## Purpose

A-owned append-only event log that records the **lifecycle of Terminal-B
findings** (Outcome-1 of the Terminal-B algorithm — a `status=NEW` row appended
to `governance/NOVELTY-COLLECTION-REGISTER.md`). Kept **separate** from:

- `governance/NOVELTY-COLLECTION-REGISTER.md` (B-owned finding registry —
  system-of-record for **what B has seen**);
- `governance/NOVELTY-COVERAGE-LOG.md` (B-owned coverage-confirmation log —
  Outcome-2 of the Terminal-B algorithm, proof-of-completeness).

The two-file split preserves append-only on **both** sides and the
ownership boundary (parallel-session-isolation Rules 1–7): B never writes
here; A never back-writes into B's register / coverage-log.

Per ADR-159 D-1: the **current state** of any given `finding-item` is the
**latest event row for that item** (state is derived from the log, not stored
as a mutable column elsewhere).

---

## Schema

Each row is one event. Columns:

| Column | Values | Notes |
|--------|--------|-------|
| `event` | monotonic integer | 1-based; increments per appended row across all items. |
| `finding-item` | slug | matches `item` column of `NOVELTY-COLLECTION-REGISTER.md`. |
| `status` | `picked` \| `planned` \| `sprint` \| `processed` | lifecycle stage (see below). |
| `roadmap-ref` | roadmap anchor \| `-` | link/anchor into `docs/ROADMAP-MATRIX.md` (added at `planned`). |
| `sprint-ref` | `Sprint <N>` / `IL-<NNN>` \| `-` | sprint/IL anchor (added at `sprint`). |
| `timestamp` | ISO8601Z UTC | append-time. |

**Lifecycle (per finding-item):**

```
NEW (register)
  -> picked   (factory-watcher picked up NEW row from register)
  -> planned  (roadmap update appended for the finding)
  -> sprint   (sprint-task entered; sprint-ref recorded)
  -> processed (draft-PR opened OR verdict=duplicate/failed — terminal for A)
```

`processed` is the **terminal** event for a finding-item on A-side.
Merge = HITL (operator) per CLAUDE.md §71 / ADR-156 — never appended here as
an event.

---

## Entries

| event | finding-item | status | roadmap-ref | sprint-ref | timestamp |
|-------|--------------|--------|-------------|------------|-----------|

<!-- APPEND-ONLY: rows appended below by scripts/novelty-watcher.sh only. -->
<!-- No rows yet — pipeline scaffolding is PROPOSED and not activated. -->

---

## Append Instructions (factory-watcher — single-writer)

**Only `scripts/novelty-watcher.sh` appends rows to this file.** No other
agent, workflow, or human process writes here. The pipeline-scaffolding
GitHub Actions workflow (`.github/workflows/novelty-handoff.yml`) is
**validator + detector only** — it never commits to this file.

Append discipline:

1. **Append at the bottom** of the `## Entries` table (never insert, never
   edit, never delete).
2. **Idempotent** — if the latest event for a given `finding-item` already
   matches the event about to be appended, skip.
3. **One event per row.** Never batch multiple events into a single row.
4. **Timestamp** — ISO8601Z UTC at append time.
5. **Ownership enforcement** — `.github/CODEOWNERS` restricts writes to
   `@mmber` (operator/HITL); the factory-watcher runs in a session that
   proposes changes via a PR, never direct-writes to `main`.

Cross-refs: ADR-159 §D-1 (channel), §D-5 (safety), `.claude/rules/parallel-session-isolation.md`
(Rules 1–7), CLAUDE.md §71 (operator-gated merge).
