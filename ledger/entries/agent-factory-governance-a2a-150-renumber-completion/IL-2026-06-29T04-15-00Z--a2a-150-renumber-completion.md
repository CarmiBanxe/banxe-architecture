---
il_ts: 2026-06-29T04:15:00Z
session_id: agent-factory-governance-a2a-150-renumber-completion
source: CEO
status: DONE
---
### Complete a2a→ADR-150 renumber — fix 7 residual A2A-contract refs missed by #876
- **Decision:** Corrected **7 residual A2A-contract references** `ADR-145 → ADR-150` in two **live-canon** files missed by the #876 sweep: `docs/canon/intent-layer-masks.md` (×5: lines 7/86/128/131/140) + `docs/canon/passports/planner.yaml` (×2: lines 39/40). Correctness fix — `planner.yaml` declared its message contract as `ADR-145 A2AMessage`, now correctly `ADR-150`. **PREPARE-ONLY**, Draft PR.
- **Root cause (#876):** classification sweep used `grep --include=*.md`, skipping `planner.yaml` (.yaml) + not enumerating `intent-layer-masks.md`. **Lesson:** renumber back-ref sweeps MUST be **suffix-agnostic** (all extensions), verified `0 remaining` before close — recorded in the audit doc §6.
- **Scope discipline:** every changed line verified A2A-context (non-A2A sanity grep = ∅); factory⊕project ADR-145 refs untouched (none present), `ADR-049`/`ADR-048` untouched (still present), append-only shards untouched, 0 edits outside the 2 files / 7 lines. Post-fix suffix-agnostic re-grep → 0 remaining A2A↔ADR-145.
- **Audit:** `docs/governance/DUPLICATION-AUDIT-adr145-renumber-completion-2026-06-28.md` (ADR-102 five-step + per-line verdict + §6 process changelog).
- **Proof:** IL **provisional, NOT hardcoded** (ADR-119 Rule 8) — minted max+1 over origin/main (max 719) → IL-720 via central allocator (ADR-143/143-A); unique, 0 dups; orphan-gate 1:1 (ADR-144). Append-only: ONE tail shard, il_ts `2026-06-29T04:15:00Z` > origin/main max `2026-06-29T04:00:00Z`. Fresh worktree off origin/main `abae680`, commit-before-push (head≠base) (ADR-120/060). FROZEN/.canon untouched.
- **Status:** DONE — 7-line fix + audit + shard. **DRAFT PR; DO NOT MERGE — operator HITL via ADR-135.**
- **Refs:** `docs/canon/intent-layer-masks.md`, `docs/canon/passports/planner.yaml`; `docs/adr/ADR-150-a2a-inter-agent-message-contract.md`; #876 audit (`DUPLICATION-AUDIT-adr145-dup-renumber-2026-06-28.md`); ADR-102/119/142/057/120/060. Operator HITL.
