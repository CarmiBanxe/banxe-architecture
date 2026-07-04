---
il_ts: 2026-07-04T22:42:05Z
session_id: agent-factory-adr160-bilateral-renumber
source: agent-factory
status: PROPOSED
---

# ADR-160 — corrective renumber of the bilateral ADR (was duplicate ADR-158 on main)

## What

#1018 merged the bilateral orchestration ADR numbered **ADR-158**, colliding with the already-merged
push-safety ADR-158 (#1016) — a duplicate ordinal violating ADR-119's unique-number invariant. This forward
corrective renames `docs/adr/ADR-158-bilateral-orchestration-write-gate.md` → `ADR-160-…` (159 held by #1017)
and adds an honest Renumber & Status note.

## Also documented (factual) + defects flagged for follow-up

- D-2's write-gate guards **DID land** in main's committed `.githooks/pre-push` as a v2 union (G-1..G-4 +
  G-5 branch-name + G-5+ push-safety `is_protected_ref` from #1016).
- **⚠ Landed defect — hook/source desync:** `scripts/pre-push-branch-name.sh` was NOT updated (push-safety
  only), so `install-hooks.sh` (source→installed) silently **reverts the write-gate guards** on bootstrap,
  breaking the #1016 byte-identical invariant. Flagged for a **dedicated hook-sync follow-up** (that PR also
  relabels the hook's G-1..G-4 comments ADR-158→ADR-160; keep G-5+ = ADR-158). Not fixed here (relabeling
  the installed copy alone would be reverted by install-hooks).
- Flagged (not resolved): §G/§F governance conflict — "Terminal A (Central)" fuses A≠Central (ADR-153) and
  the guardian role contradicts ADR-154 (factory=arbiter) — deferred to a follow-up amendment.

## Boundaries

Doc-only, prepare-only. Renames one ADR file (158→160) + adds an honest note; **no hook change** (main's
committed v2 union hook is left untouched — the desync fix is a separate follow-up); merged shard +
ACTION-LEDGER rows left append-only (historical). No governance semantics rewritten. IL minted
redis-serialized at ratification.

## Anchors

`docs/adr/ADR-160-bilateral-orchestration-write-gate.md` · `docs/adr/ADR-158-push-safety-versioned-pre-push-guard.md`
(the surviving 158) · ADR-119 (unique ordinal) · ADR-153/154 (deferred reconciliation). Corrective for #1018.
