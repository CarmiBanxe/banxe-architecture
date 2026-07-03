---
il_number: 830
il_ts: 2026-07-02T00:00:00Z
description: "T2.6 — Stale Clone Cleanup Plan (Legion Workstation)"
owner: factory
status: proposed
session_id: agent-factory-t26-stale-clone-cleanup
source: factory
---

# T2.6: Stale Clone Cleanup Plan — Legion Workstation

## Summary

Stale local clone and worktree cleanup plan for Legion workstation.

**Deliverables:**
- Full inventory: 31 local clones, 43 worktrees, 24 merged branches
- Phase 1 cleanup (safe, reversible): ~80–100M recovery
- Phase 2 cleanup (approval required): ~2.5–3.5G recovery
- I-24 compliance (REMOVED=0)

## Output

`governance/T2.6-STALE-CLONE-CLEANUP-PLAN.md` — Complete plan with:
- Clone status classification (ACTIVE/REVIEW/STALE/UNKNOWN)
- Merged branch cleanup commands
- Stale clone deletion checklist
- Disk recovery estimates
- Phase 1 (safe) vs Phase 2 (approval) breakdown

## Completion Criteria

- Operator reads plan
- Operator approves Phase 1 execution
- Operator verifies and approves Phase 2 items individually

