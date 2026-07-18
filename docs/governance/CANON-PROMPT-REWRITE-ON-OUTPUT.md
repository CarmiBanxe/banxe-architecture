# CANON AMENDMENT — Prompt Rewrite on New Output
# Status: BINDING (operator-ratified 2026-07-11, session BANXE EMI)
# Additive to: CANON-PARALLEL-ORCHESTRATION.md, CANON-MEMORY-FIRST-AUDIT-CONFIRMS.md

## Problem This Solves

In multi-track orchestration, a terminal may have composed a pending prompt for Track N
while the executor (Claude / shell) is busy on Track M. New output arrives from Track M
before the Track N prompt has been sent. If the Track N prompt is sent unchanged,
it may be stale, contradicted by the new output, or contain a duplicate instruction.
Accumulation of stale pending prompts causes prompt-desync and wasted turns.

## Rule

When new Claude/shell output arrives AND a previously-composed prompt has NOT yet
been delivered (because the executor was busy), the terminal MUST:

1. **HALT delivery** of the old prompt.
2. **REWRITE** the pending prompt, folding in the new output:
   - Run §72 dup-check against the new output (new files or facts may already cover what the pending prompt requested).
   - Update facts that changed (new commit hashes, new states, resolved items).
   - Remove instructions that were already satisfied by the new output.
   - Add any new context the new output revealed.
3. **Deliver ONE rewritten prompt** — not the old one, not both.

## What Is Forbidden

- Delivering a pending prompt unchanged when the new output materially affects it.
- Queuing and delivering two prompts in succession without a STOP between them.
- Merging a stale prompt with a new one by concatenation without dup-checking.

## What Is Allowed

A pending prompt that is FULLY independent of the new output (different track, no
shared facts, no dup-check risk) MAY be delivered unchanged. The terminal must
explicitly confirm independence before delivering.

## Procedure

```
NEW OUTPUT ARRIVES
  │
  ├─ Pending prompt exists?
  │   NO → normal flow; compose next prompt if needed.
  │   YES ↓
  │
  ├─ Is pending prompt fully independent of new output?
  │   YES → deliver as-is (state independence reason).
  │   NO  ↓
  │
  ├─ §72 dup-check: does new output already cover pending prompt's scope?
  │   FULLY COVERED → discard pending prompt; move on.
  │   PARTIALLY COVERED → rewrite: remove covered parts, keep remainder.
  │   NOT COVERED → rewrite: fold in new facts, update hashes/states.
  │
  └─ Deliver ONE rewritten prompt. STOP.
```

## Track State Persistence

All track states are recorded in `SESSION-STATE.md` (section PARALLEL TRACKS).
When rewriting a prompt, consult SESSION-STATE.md to confirm which OI items,
commits, and blocker states are current before issuing the revised instruction.

## Rationale

Prompt-desync is the primary failure mode of multi-track orchestration.
A rewritten prompt costs one extra composition step; a desync'd prompt
costs N recovery turns and risks contradictory state. Rewrite is always cheaper.

## References

- Parallel track canon: `docs/governance/CANON-PARALLEL-ORCHESTRATION.md`
- Memory-first canon: `docs/governance/CANON-MEMORY-FIRST-AUDIT-CONFIRMS.md`
- Live track state: `docs/governance/SESSION-STATE.md`
- §72 dup-check: BANXE canon (applied before every artifact creation)
- I-71 single-writer: operator executes; terminal composes.
