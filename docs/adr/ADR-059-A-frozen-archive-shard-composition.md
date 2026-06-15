# ADR-059-A: Frozen archive + shard composition for INSTRUCTION-LEDGER

## Status
PROPOSED (extends ADR-059 S4 cutover)

## Context
build_ledger.py composed INSTRUCTION-LEDGER.md ONLY from ledger/entries/**.
With a frozen pre-S4 history (IL-001..IL-245) NOT migrated to shards, any real
shard + rebuild destroyed the monolith (11900 -> ~18 lines), violating ADR-057/I-28
append-only and the ADR-059 promise that history stays a frozen archive.

## Decision
1. Introduce ledger/FROZEN-ARCHIVE.md = immutable snapshot of the pre-S4 monolith.
2. render() = FROZEN-ARCHIVE (prefix) + sorted(shards).
3. Shard IL numbering continues at max(IL in frozen) + 1 (currently 246).
4. --check always compares the monolith to (frozen + shards); no early-OK on empty set.

## Consequences
- History IL-001..IL-245 preserved verbatim as immutable prefix.
- New records are shards under ledger/entries/**; monolith is generated.
- FROZEN-ARCHIVE.md is append-only/immutable; changes require a new ADR/IL.

## Refs
ADR-059 (S4 cutover), ADR-057 (append-only), ADR-056 (coupling), SHARD-WORKFLOW.md.
