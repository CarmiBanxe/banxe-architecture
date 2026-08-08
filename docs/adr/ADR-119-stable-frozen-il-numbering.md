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

## Amendment 2026-08-08 — central Redis allocator (ADR-143 alignment)

> Wording-only reconciliation. The **rule** is unchanged — *a new shard takes the next unused
> integer; existing keys and values are never mutated or removed* (§Decision.4, append-only).
> Only the **mechanism** described below is brought up to date. §Decision.3–4 and the
> 2026-06-24 amendment above are preserved as written; where they say `max+1` or "always
> lands at the tail", read this section instead.

**What changed.** Since **ADR-143** (`accepted` 2026-07-09) — as amended by **ADR-143-A**
(`ACCEPTED` 2026-07-12, which fixed the config so the counter is genuinely shared) — new IL
numbers are no longer computed locally as `max+1`. They are minted from a single central Redis
counter, `banxe:il:counter`, implemented in `ledger/build_ledger.py` (`_redis_config` /
`_redis_allocate`). Local `max+1` was the root cause of the cross-terminal duplicate class
(IL-159/172, IL-827); an atomic counter removes the race at its source rather than detecting
it after the fact.

**Mechanism (current).**

1. **Allocation** — atomic `INCR` on `banxe:il:counter`, repeated until the value exceeds the
   frozen sequence maximum. On first contact the counter floor is seeded to that maximum (set
   only when the counter sits below it), so a freshly provisioned counter can never hand out a
   number at or below one already assigned.
2. **Target host** — default `100.68.102.48:6379` (evo1, over tailscale), password from
   `REDIS_PASS_FILE` (default `~/banxe-fabric/.vault/redis.pass`); `REDIS_HOST` / `REDIS_PORT`
   override. Every terminal — evo1, evo2, Legion — must increment the *same* counter; that
   shared target is the whole anti-collision guarantee.
3. **Local fallback is disabled.** Redis unreachable ⇒ `build_ledger.py` raises and refuses to
   proceed. The offline `max+1` path exists only behind an explicit `BANXE_IL_ALLOCATOR=local`
   escape hatch, which accepts the cross-terminal race and is forbidden in normal operation.
   Fail-loud replaced the silent degrade that produced the duplicates.

**Two observable consequences that §Decision.4's "always lands at the tail" no longer covers.**

- **Mint order ≠ merge order, so a new entry may render above an older one.** Verified on
  `main`: `adr135-a-memoharness-amendment-draft` (A1, PR #1199, `f9e90d42`) merged *before*
  `fable5-adr136a-memory-fabric` (A2, PR #1204, `8ce6376c`), yet A1 holds **IL-1148** and A2
  holds **IL-1147**. Because the ledger renders in IL-number order, the later-merged shard
  renders *above* the earlier-merged one. This is correct behaviour, not a defect.
- **The sequence is monotonic but not contiguous.** `INCR` consumes a number at mint time; if
  that branch is abandoned or its PR closed, the number is never claimed by a merged shard and
  the gap is permanent. Present gaps on `main` in the 1100–1153 range: **1116–1120, 1138, 1139,
  1141, 1149, 1150**. Gaps are expected; they must never be back-filled, since re-using a
  consumed number would break the frozen-for-life guarantee.

**Unchanged by this amendment.** Rebase-before-merge (2026-06-24 amendment) still applies: the
mint itself is race-free, but `strict` branch protection still requires an up-to-date base, and
a shard's number stays provisional until the pre-merge regeneration. Append-only enforcement
(`build_ledger.py --check` vs git HEAD), the `guardian-ledger` collision gate, and Rule 8 in
`.claude/rules/parallel-session-isolation.md` are untouched.

**Cross-references.** `docs/adr/ADR-143-redis-central-il-allocator.md` (base, `accepted`),
`docs/adr/ADR-143-A-shared-evo1-redis-allocator.md` (`ACCEPTED` — shared-evo1 config fix).
Note `docs/adr/ADR-143-B-allocator-relocation-evo2.md` (relocate the primary counter to evo2)
is **Proposed, not in force**; should it be accepted, the host named in point 2 above becomes
stale and must be re-synced here.
