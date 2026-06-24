---
id: ADR-119
title: Stable frozen IL numbering via IL-SEQUENCE.json (ends il_ts re-mint churn)
status: ACCEPTED
date: 2026-06-22
accepted: 2026-06-22
supersedes: []
related:
  - "ADR-059-sharded-ledger.md (sharded append-only ledger this builds on)"
  - "ADR-056-ledger-coupling.md (ledger-coupling guardian — unchanged)"
  - "ADR-057 (ledger invariants)"
  - "ledger/build_ledger.py (generator modified here)"
il_anchor: IL-457
scope: BANXE-only
concept_only: false
---

# ADR-119 — Stable frozen IL numbering via IL-SEQUENCE.json

## Context

`ledger/build_ledger.py` (ADR-059) assigned `IL-NNN` numbers by **position** in a
`(il_ts, session_id, path)`-sorted scan of `ledger/entries/**`, offset by the
`FROZEN-ARCHIVE.md` maximum. Numbering was therefore a pure function of the *whole*
shard set: a newly-added shard whose `il_ts` sorted **before** existing shards was
inserted mid-sequence and **renumbered every later entry**.

In practice every "behind" PR (origin/main advanced while the branch was open) hit this
trap: the `ledger-append-only` / `guardian-ledger` gates flagged the mid-insert, and the
only remedy was to **manually re-mint the shard's `il_ts`** (and rename its file) to push
it past the new tail. This re-mint churn recurred on nearly every governance/migration
merge (S6/S7/S8, MIG-*), was error-prone, and added no semantic value.

## Decision

Freeze each shard's `IL-NNN` **for life** in an append-only map
`ledger/IL-SEQUENCE.json` (`"<session_id>__<hex>" -> int`, where `<hex> = sha1(relative
path)[:12]`, collision-proof per shard):

1. **Initialise once** by replaying the legacy `(il_ts, session_id, path)`-sorted,
   FROZEN-offset numbering, so every existing shard keeps **exactly** its present number
   (verified: regenerated ledger is byte-identical to the prior `INSTRUCTION-LEDGER.md`).
2. **Known shards** reuse their frozen number.
3. **New shards** are assigned `max+1, …` in `(il_ts, session_id, path)` order and
   **appended** to `IL-SEQUENCE.json` — existing keys/values are never mutated or removed.
4. The ledger is **rendered in IL-number order**, so a new entry always lands at the tail
   regardless of its `il_ts`. A behind-PR no longer renumbers priors and no longer needs an
   `il_ts` re-mint.

`build_ledger.py --check` additionally verifies `IL-SEQUENCE.json` is in sync with the
shards and **append-only vs git HEAD** (no existing number mutated/removed).

## Invariants preserved (no guard weakening)

- **I-28 / append-only**: shards remain append-only; `IL-SEQUENCE.json` is itself
  append-only and self-checked. `INSTRUCTION-LEDGER.md` deletions are still rejected.
- **ADR-056 ledger-coupling** (`guardian-ledger`) and **ADR-059** sharding are unchanged;
  this only changes *how numbers are assigned*, not the coupling/append guarantees.
- Determinism: numbering is now a pure function of `IL-SEQUENCE.json + shard set`, even
  more stable than before (independent of insertion order of future shards).

## Consequences

- The recurring manual `il_ts` re-mint on behind-PRs is **eliminated**.
- `ledger/IL-SEQUENCE.json` becomes a tracked, append-only artefact (one new line per new
  shard).
- Ledger ordering is by IL number (monotonic), not by `il_ts`; `il_ts` remains recorded
  per entry for provenance.

> **`il_ts` semantics (clarification — not a defect).** The **IL number** (frozen via
> `IL-SEQUENCE.json`) is the canonical ordering **and** identity. `il_ts` is an
> **informational** provenance attribute and is **NOT required to be monotonic** with the IL
> number: a behind-PR may carry an earlier `il_ts` than an already-merged later-numbered entry
> (e.g. IL-465 @ 14:15Z appended after IL-463 @ 16:20Z). Append-only is enforced on the **number
> sequence** (`ledger-append-only` / `guardian-ledger`, I-28), **not** on `il_ts`. A
> non-monotonic `il_ts` is by-design under this ADR and must not be treated as a ledger violation.

## Verification

- Regenerated `INSTRUCTION-LEDGER.md` byte-identical to pre-change (207 shards, IL-249..455).
- Regression: a probe shard with an early `il_ts` (2026-06-01) is assigned the tail number
  (IL-457) and rendered last; **zero** prior IL numbers shift.

## Amendment 2026-06-24 — IL number frozen at MERGE time, not creation (race-proofing)

> Context: concurrent factory terminals double-claimed IL numbers (493/494/497/500/501).
> PRs #744, #749, #751 each asserted `[IL-NNN]` from a stale base; each number was already
> merged on `main` by the time the PR was ready. The duplicate violates I-28 and forced
> Claude Code to stop and ask — the "factory keeps asking" regression. No content was lost;
> the three were re-id'd to distinct contiguous numbers IL-503/504/505 by rebase + regenerate.

**Consequence (canon).** A shard's IL number is **provisional until the branch is rebased
onto current `origin/main` immediately before merge** and `build_ledger.py` (FROM ROOT) has
re-assigned it `max+1`. Therefore:

1. **Do not assert `[IL-NNN]` as final at creation.** Any number in a PR title, commit
   subject, shard body, or companion doc is provisional until the rebase-before-merge step
   confirms it equals the regenerated `max+1`. Correct every human-facing reference to match
   the regenerated number before merge.
2. **The freeze happens at merge time** via `build_ledger.py` over the up-to-date base —
   never hardcoded at creation. `main` branch protection is `strict` (up-to-date required) so
   a behind-branch carrying a stale number physically cannot merge; it must rebase, which
   regenerates the number deterministically as the next `max+1`.
3. **Concurrent ledger PRs are serialized:** merge one, rebase the next onto the new `main`,
   regenerate, merge — they cannot re-collide.
4. **A mismatch between asserted and regenerated number is an autonomous rebase signal**, not
   an operator question (best-decision canon; only data-loss / irreversibility / invariant
   breach is a stop-barrier).

Enforced by `strict` branch protection + the `guardian-ledger` pre-merge IL-collision gate
(`docs/guardian/guardian-ledger-il-collision-gate.md`) + `.claude/rules/parallel-session-isolation.md`
**Rule 8**. This amendment changes only *when* the number is considered final; it does **not**
alter the append-only / coupling guarantees above, and never renumbers a prior entry.
