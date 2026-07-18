# CANON AMENDMENT — Ledger Event After Every Block
# Status: BINDING (operator-ratified 2026-07-11, session BANXE EMI)
# Additive to: CANON-MEMORY-FIRST-AUDIT-CONFIRMS.md, CANON-PARALLEL-ORCHESTRATION.md
# I-24: append-only. ADR-059: ledger namespace.

## Problem This Solves

Sessions are lost when context is compacted or the terminal restarts. The TRACK BOARD in
SESSION-STATE.md records state, but state is a snapshot — it does not carry the sequence
of events that produced it. Any terminal can reconstruct what happened by reading
SESSION-STATE.md, but cannot reconstruct the causal chain.

A ledger event log — append-only, one line per closed block — provides the causal chain.
Together with SESSION-STATE.md, it enables full session reconstruction without operator recall.

## Rule

After EVERY closed block (a Write, an Edit, a findings extraction, a governance file creation,
a config change, a PR action), the factory MUST append ONE event line to its ledger namespace.

### Event format (one line per block, append-only):

```
{timestamp_utc} | track={TRACK-ID} | action={ACTION} | sha_or_pr={SHA|PR#|—} | artifacts=[file1, file2] | open_items=[OI-IDs or —] | note={free-text summary ≤ 120 chars}
```

### Ledger namespace path:

```
ledger/entries/<TRACK-ID>/<YYYY-MM-DD>.log
```

Examples:
```
ledger/entries/T1/2026-07-11.log
ledger/entries/T-MEM/2026-07-11.log
```

Each file is one track's daily log. Lines are appended; never overwritten or deleted (ADR-059).

## Append-Only Invariant (I-24)

- NEVER rewrite past ledger events.
- NEVER delete a ledger entry file.
- If an event was incorrect, append a CORRECTION event on the NEXT line:
  ```
  {timestamp} | track=T1 | action=CORRECTION | note=Prior event SHA was wrong; correct SHA is abc1234
  ```

## Relationship to INSTRUCTION-LEDGER.md

`INSTRUCTION-LEDGER.md` is a human-readable projection for the operator. It is never
hand-edited by the factory. It is regenerated from ledger events by `scripts/doc-sync.py`
or equivalent. The ledger namespace IS the source of truth; INSTRUCTION-LEDGER.md is a view.

## Relationship to SESSION-STATE.md TRACK BOARD

SESSION-STATE.md TRACK BOARD = current snapshot (point-in-time).
Ledger events = causal history (sequence of snapshots).

When SESSION-STATE.md is updated, a ledger event for track=T-MEM is also appended, recording
the fact that the snapshot was updated and what changed.

## What Counts as a "Closed Block"

A block is closed when:
- A file was written or edited (Write / Edit tool completed successfully).
- A shell command produced a result that changes state (git commit, PR created/updated).
- An extraction task completed (OI-LOCAL-1 findings file written).
- A governance artifact was created or extended.

A block is NOT closed by:
- A read-only audit (reading files, listing directories).
- A failed tool call.
- An operator question answered from memory only.

## Minimum Viable Event (if time-critical)

If the full format is too verbose for a fast block, append at minimum:
```
{timestamp_utc} | track={ID} | action={one word} | note={≤ 80 chars}
```
Full format on next opportunity.

## How to Resume a Session

1. Read `docs/governance/HANDOFF-LIVE.md` → get operator context and active canons.
2. Read `docs/governance/SESSION-STATE.md` → get current TRACK BOARD snapshot.
3. Read `ledger/entries/<TRACK-ID>/<today>.log` for each active track → get causal chain.
4. Read `docs/ops/legion-private-engine/OI-LOCAL-1-FINDINGS.md` → get OI status.
5. Resume from last event. Do NOT ask the operator to recap.

## References

- Session memory: `docs/governance/SESSION-STATE.md`
- Handoff snapshot: `docs/governance/HANDOFF-LIVE.md`
- Memory-first canon: `docs/governance/CANON-MEMORY-FIRST-AUDIT-CONFIRMS.md`
- ADR-059: append-only ledger
- I-24: audit trail invariant (append-only, never delete)
- doc-sync script: `scripts/doc-sync.py`
