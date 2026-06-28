---
il_ts: 2026-06-29T02:15:00Z
session_id: agent-factory-governance-adr-closed-loop-criteria
source: CEO
status: DONE
---
### ADR-149 (DRAFT) — Closed-loop completion-criteria for prepare-only factory tasks
- **Decision:** Created `docs/adr/ADR-149-closed-loop-completion-criteria.md` (PROPOSED, **PREPARE-ONLY**). Codifies how a prepare-only factory task self-terminates: (1) completion-criteria = first-class declarative stop-condition in the IL shard (`--check=0 AND behind-0 AND back-refs-resolved AND FROZEN-untouched`); (2) **closed looping only** for regulated/EMI, open looping FORBIDDEN (token-burn/slop/egress/FCA); (3) self-correcting loop in the PREPARE phase only — STOP at ANY mutation = HITL ADR-135 (merge/renumber/permissions/push); (4) egress only via LiteLLM seam, external loop-service runtime FORBIDDEN. Agent-looping research (`@shannholmberg`/Steinberger; `loops.elorm.xyz`) = patterns only, NOT a dependency/runtime.
- **Motivation:** the 4× wave-drift churn on #869/#872 — an `auto-rebase-until-behind-0` closed loop (gate-terminated) would have absorbed it autonomously while preserving HITL on the irreversible merge.
- **Canon:** authority factory-only (ADR-117); HITL on mutations (ADR-135); allocator determinism (ADR-119/143/143-A) bounds the loop; self-reflective ≠ gate (ADR-148). NO RED-zone, NO new runtime, NO external dependency.
- **Proof:** docs/adr governance-only; **no install/clone/import/runtime/secret**. IL **provisional, NOT hardcoded** (ADR-119 Rule 8) — minted max+1 over origin/main (max 716) → IL-717 via central allocator (ADR-143/143-A); unique, 0 dups; orphan-gate 1:1 (ADR-144). Append-only: ONE tail shard, il_ts `2026-06-29T02:15:00Z` > origin/main max `2026-06-29T02:00:00Z`. Fresh worktree off origin/main `ee6021e`, commit-before-push (head≠base, anti-auto-close) (ADR-120/060). FROZEN/.canon untouched.
- **Status:** DONE — DRAFT ADR-149 + shard. **DRAFT PR; DO NOT MERGE — operator HITL via ADR-135.**
- **Refs:** `docs/adr/ADR-149-closed-loop-completion-criteria.md`; ADR-117/135/148/119/143/143-A/120; parallel-session-isolation Rule 6/7; agent-looping pattern ref (not imported). Operator HITL.
