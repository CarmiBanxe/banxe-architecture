---
id: ADR-144
title: Orphan shard_key prune + orphan-detecting --check — close the orphan-from-rebase IL class
status: PROPOSED
date: 2026-06-28
amends: [ADR-119, ADR-143]
relates:
  - "ADR-119 (frozen IL numbering — live shard numbers stay frozen; prune never touches them)"
  - "ADR-143 / ADR-143-A (central allocator — this PR's new IL minted via it; --check stays offline)"
  - "ADR-057 / ADR-059-A (append-only — clarified: protects RECORDED entries-with-shard, not stale index keys)"
  - "ADR-133 (uniqueness gate / {540} allowlist), ADR-125 (IL-540 triple-collision — the orphan cleaned here)"
il_anchor: IL-623
il_anchor_note: "Provisional per ADR-119 Rule 8 — minted by the central allocator over current origin/main. Frozen at rebase-before-merge."
scope: BANXE-ledger-tooling
concept_only: false
---

# ADR-144 — Orphan shard_key prune + orphan-detecting `--check`

## Context — the orphan-from-rebase class

`shard_key(rec) = session_id + sha1(relative_path)[:12]`. When a branch is force-updated / rebuilt and a
shard's **path changes**, its `shard_key` changes too. `assign()` only ever **added** keys (`if k not in
numbering: base += 1`) and **never removed** them, so the **old key lingers in `IL-SEQUENCE.json` with no
backing shard** — an **orphan index-key**. It inflates `base` and shows up as a phantom IL (the IL-603/604
and IL-620/#835 incidents). The old `--check` compared by map keys and **did not catch it** (a bug).

## Decision

### A. Prune (write path)
`prune_orphans(numbering, records)` removes every key that is **in the ACTIVE range** (`value >
frozen_offset()`) and has **no live shard** in `ledger/entries/**`. `assign()` runs it **before**
numbering, so orphans neither inflate `base` nor persist in the written map.
- **FROZEN range is never pruned:** keys with `value <= frozen_offset` are FROZEN-ARCHIVE entries that
  legitimately have no `entries/` shard — they are not orphans.
- **Live numbers stay frozen (ADR-119):** prune only deletes keys with no shard; every live shard keeps
  its exact IL.

### B. Detect (`--check`)
`--check` now computes `find_orphans(records, committed_sequence)` and **FAILS loudly** if any exist:
`FAIL: ORPHAN shard_key(s) in IL-SEQUENCE.json without an entries shard: <k>=IL-NNN — run
build_ledger.py to prune them (ADR-144).` It does **not** silently prune — it forces a regenerate. After
regenerate the orphan is gone and `--check` passes. **`--check` stays fully offline + deterministic** (no
Redis; `use_allocator=not args.check` unchanged) so CI without Redis passes.

### C. Append-only clarification (so guardian-ledger / ledger-append-only do NOT flag the prune)
`check_append_only` now **permits removal of an orphan key** (no live shard, active range): an orphan is
**not a recorded IL** — it has no shard in the ledger, so pruning it does **not** violate append-only of
PRIOR ENTRIES (ADR-057/059-A). Removal of a **live shard's** key, or any **frozen** key, or any **value
mutation**, is still a hard violation. (`INSTRUCTION-LEDGER.md` is unaffected by the prune — an orphan has
no shard, so it was never rendered there; only `IL-SEQUENCE.json` loses the stale key.)

## This PR also cleans the existing orphan

**Audit of `origin/main` 6602842 (corrected):** `IL-SEQUENCE.json` = **373 keys**, live shard files =
**372**, so **exactly ONE** active-range orphan exists (not 4 — the figure had drifted):

| Orphan key | IL | Why it's an orphan |
|---|---|---|
| `agent-factory-handoff-0625__session0625` | **IL-540** | suffix `session0625` is a **legacy literal**, not a sha1 path-hash → a pre-ADR-125 hand-authored relic of the IL-540 triple-collision; no live shard |

Pruning it cleans the last orphan and resolves the `{540:2}` duplicate to **`{540:1}`**: the **live**
key `agent-factory-governance-claude-permissions-hardening__86396a3bf6c1` **keeps IL-540** (ADR-119). The
ADR-133 `ALLOWED_DUP_VALUES = {540}` allowlist is thereby rendered **vacuous but harmless** (1 ≤ allowed);
it is left in place — removing it is an optional follow-up. **FROZEN-ARCHIVE is untouched.**

## Consequences
- The orphan-from-rebase class is closed: prune removes existing/future orphans on regenerate; `--check`
  catches any that appear, in CI, going forward.
- `IL-SEQUENCE.json` becomes 1:1 with shard files (+ this PR's own shard). `removed` in the diff is the
  stale orphan index-key only — not a recorded entry (ADR-057/059-A unviolated).
- No live IL changes; FROZEN range and ADR-133 gate behaviour unchanged.

## Anchors
- `ledger/build_ledger.py` (`find_orphans` / `prune_orphans` / `assign` prune / `check_append_only`
  orphan-exempt / `--check` orphan detection), `tests/test_orphan_prune.py`. ADR-119/143/143-A,
  ADR-057/059-A, ADR-133/125. No secrets; `--check` offline.
