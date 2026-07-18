# CANON AMENDMENT — Parallel Orchestration
# Status: BINDING (operator-ratified 2026-07-11, session BANXE EMI)
# Additive to: one-artifact-per-turn canon, STOP-after-block, I-71, §72.

## Core Rule (unchanged)
One artifact per turn: one prompt OR one shell command block. Then STOP and await output.

## Where Parallelism Lives
Parallelism lives INSIDE the artifact, not between artifacts.

A single prompt or single shell block MAY — and SHOULD — advance MULTIPLE independent
tracks simultaneously. This is not a violation of one-artifact-per-turn; it is the
correct use of that turn's capacity.

## Motivation
BANXE EMI operates across Legion (local) + evo1/evo2 (remote) + heavy model tiers.
Multiple concurrent workstreams (Private Engine, Sprint plan, Watchdog brigade, etc.)
must not block on each other. A turn that advances only one track wastes orchestration
capacity and creates artificial sequencing.

## How to Apply

### In a single prompt (Claude Code / factory):
- Write multiple files in one Write-block (as this turn demonstrates).
- Emit decisions for multiple tracks in one response.
- Run independent sub-agents in parallel if the task warrants.

### In a single shell block:
- Chain independent commands with `&&` or `;` only when they are truly independent.
- Do NOT chain commands that depend on prior output — sequence those across turns.

### Across turns:
- Turns remain sequential (one turn → await output → next turn).
- Each turn may carry N parallel sub-tasks, as long as they share one artifact boundary.

## Hard Constraints (unchanged)

| Constraint | Rule |
|------------|------|
| §72 dup-check | Before any new artifact, verify it does not duplicate an existing one. |
| I-71 single-writer | Operator-only: git push, PR merge, tag, install, systemctl enable/start. |
| STOP-after-block | After emitting the artifact, stop. Do not pre-run the next step. |
| I-27 HITL | Agents propose; humans decide. No autonomous write to banking. |
| ADR-060 branch regex | ^agent/(central|right|factory|specproj)/[A-Za-z0-9]+/[a-z0-9._-]+$ |

## Active Parallel Tracks (current session)

| Track | ID | State |
|-------|----|-------|
| Private Engine config | T1 | PR #1126 open; config must become autonomous/local |
| Sprint plan | T2 | commit 5c41cb1; L-1 must reflect autonomous local model |
| Watchdog brigade | T3 | I-27 intact; independent; do not block on T1/T2 |

Tracks are never dropped between turns. SESSION-STATE.md carries them across context resets.

## Rationale
Orchestration across multiple machines and model tiers requires multi-track capacity
in every turn. Sequential single-track turns are correct for dependent steps; for
independent tracks, parallelism inside a turn is the canon-correct approach.
