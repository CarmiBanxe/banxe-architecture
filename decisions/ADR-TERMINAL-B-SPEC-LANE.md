# ADR — Terminal-B Spec-Projects Lane (Novelty Hunting)

**Status:** ACCEPTED  
**Date:** 2026-07-02  
**Deciders:** Operator (CEO/CTIO)  
**IL:** assigned via add-il-shard.sh  
**Related:** ADR-018 (5-layer AI compute), GLOBAL-PROGRAM-PLAN.md, MASTER-ORG-CODE-RUNTIME-DOSSIER.md, main-serialize.yml  

---

## Context

The Orchestrating-Terminal model currently runs a single general line (Terminal A / Factory):
sequential build → review → merge → next. This saturates one Claude Code session but leaves
parallel novelty-hunting work (feature collection, subproject scoping, analytics) either
unscheduled or blocking the general line.

Two-loop model (operator-approved): Terminal A (Central/Factory) = general line, write-capable,
sequential. Terminal B (Spec-Projects / novelty hunting) = collect features, subprojects,
analytics findings in parallel, write only to its own namespace.

Infra already supports it:
- Redis atomic IL anti-collision between terminal sessions (same INCR counter, no race).
- Session-namespace isolation in IL-SEQUENCE (session_id prefix).
- main-serialize concurrency gate in CI (prevents simultaneous main writes).
- Orchestrating-Terminal canon (ADR-153 equivalent) — B operates as second orchestrating instance.

The missing pieces are: a formal namespace for B branches, a rebase-freshness invariant,
and a canonical hand-off register so Terminal A can consume B findings without direct branch coupling.

---

## Decision

Terminal B runs as a second Orchestrating-Terminal instance with the following constraints:

### 1. NAMESPACE

All B branches: `agent/specproj/<id>/<slug>` where `<id>` = alphanumeric, NO hyphens (ADR-060).
Ledger shard session_id prefix: `specproj-`.
B NEVER touches general-line branches (`agent/factory/*`, `agent/central/*`).
A NEVER writes to B's namespace.

### 2. LEDGER — IL ANTI-COLLISION

B mints IL numbers via the same Redis atomic INCR counter as A (single global sequence, no fork).
Every B PR uses `scripts/add-il-shard.sh <slug> <description>` — shard + rebuild in one atomic
commit — no manual ledger steps, no squash-merge desync.
Shard session_id format: `specproj-<slug>` (distinguishes B's entries in INSTRUCTION-LEDGER.md).

### 3. REBASE-FRESHNESS INVARIANT

Every B branch MUST run `git rebase origin/main` immediately before push.
No exceptions. This prevents the stale-branch cycle (INSTRUCTION-LEDGER.md / IL-SEQUENCE.json
conflict) observed in general-line sessions (see T2.5 rebase in this session).

### 4. HAND-OFF PROTOCOL

B writes all findings to `governance/NOVELTY-COLLECTION-REGISTER.md` (append-only, I-24).
Format: item | source-repo | floor(1-4) | type | value | dedup | verdict | handoff | status.
Terminal A polls this register as input for the next factory task — it does NOT consume
B branches directly. Adopted items flow through A's general line (factory task → PR → merge).
B proposals that require operator approval are flagged with `handoff: OD-NN` or `handoff: GAP-NN`.

### 5. NO PARALLEL WRITE COLLISION

B writes only to:
- `agent/specproj/*` branches (own namespace)
- `governance/NOVELTY-COLLECTION-REGISTER.md` (append-only via own PR)
- `ledger/entries/specproj-*` shard files

B does NOT write to: `decisions/`, `constitution/`, `governance/GLOBAL-PROGRAM-PLAN.md`,
`governance/MASTER-ORG-CODE-RUNTIME-DOSSIER.md`, `governance/CONSOLIDATION-PLAN.md`,
STAFF-MATRIX, or any file owned by Terminal A's current in-flight PR.

---

## Consequences

**Positive:**
- Operator can run novelty hunting in parallel without blocking the general line.
- No IL collision (Redis global counter shared).
- No stale-branch conflicts (rebase-freshness invariant enforced before every push).
- No manual ledger steps (add-il-shard.sh handles shard + rebuild atomically).
- Clean hand-off: A consumes a register, not B's raw branches.

**Negative:**
- B must strictly respect namespace; any cross-namespace write = canon violation.
- Items adopted into bank proper always flow through A's general line after register hand-off.
- Requires operator to start a second Claude Code session for B (Terminal B is a session, not a thread).

---

## Implementation Notes

- ADR-060 branch naming enforced: `agent/specproj/<id>/<slug>`, `<id>` alphanumeric, NO hyphens.
- GUIYON security rule applies to all B output (excluded person never referenced).
- I-24 append-only: NOVELTY-COLLECTION-REGISTER.md uses append-only rows; no retroactive edits.
- ADR-120/121: all B git operations in worktrees only.

---

## References

- `scripts/add-il-shard.sh` — IL-819+, one-shot shard+rebuild+stage
- `.github/workflows/main-serialize.yml` — concurrency gate
- `governance/GLOBAL-PROGRAM-PLAN.md` — 8-phase program, Phase 1 MASTER DOSSIER
- `governance/MASTER-ORG-CODE-RUNTIME-DOSSIER.md` — census, system-of-record, duplicates
- `governance/NOVELTY-COLLECTION-REGISTER.md` — hand-off register (created alongside this ADR)
- `governance/CONSOLIDATION-PLAN.md` — OD-1..OD-N duplicate resolution tasks
- `INSTRUCTION-LEDGER.md` — append-only ledger (IL sequence)
