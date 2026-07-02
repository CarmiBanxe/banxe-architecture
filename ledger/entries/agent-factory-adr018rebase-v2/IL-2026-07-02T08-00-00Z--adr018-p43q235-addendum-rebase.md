---
il_ts: 2026-07-02T08:00:00Z
session_id: agent-factory-adr018rebase-v2
source: factory
status: COMPLETED
---

# ADR-018 P4.3-Q235 Addendum (Rebased over IL-802/IL-803)

Rebased ADR-018 hybrid 5-layer AI compute decision with P4.3-Q235 addendum content.
Resolved IL sequence violation from PR #956 (was minted against stale main before IL-802/IL-803 merged).
Re-minted as IL-806 after current main state.

## Task

- Checkout `decisions/ADR-018-hybrid-5-layer-ai-compute.md` from `origin/agent/factory/adr018/qwen3inference`
- Clean ledger state from origin/main (INSTRUCTION-LEDGER.md, IL-SEQUENCE.json)
- Re-run build_ledger.py to assign next available IL (IL-806)
- Commit with proper IL reference
- Close PR #956 and open superseding PR from agent/factory/adr018rebase/v2

## Invariant Checks

- REMOVED=0 ✓ (no deletions)
- GUIYON=0 ✓ (no guiyon found in ADR-018)
- build_ledger.py --check: PENDING (will run after shard staging)

## Supersedes

PR #956 (agent/factory/adr018/qwen3inference) — IL sequence violation fixed on rebase
