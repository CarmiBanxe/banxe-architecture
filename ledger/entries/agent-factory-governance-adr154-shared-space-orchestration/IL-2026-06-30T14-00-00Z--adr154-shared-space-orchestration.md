---
il_ts: 2026-06-30T14:00:00Z
session_id: agent-factory-governance-adr154-shared-space-orchestration
source: CEO
status: DONE
---
### ADR-154 — shared-space orchestration: factory as single arbiter of shared-space boundaries (line 2 of 7)
- **Decision:** Authored `docs/adr/ADR-154-shared-space-orchestration.md` — canon making the LEFT terminal (factory) the single arbiter of shared-space boundaries, resolving Terminal-B recs 1,3,4,5,6 + Central recs 3,4. Four arbitrated boundaries (atomic IL allocation before work; branch-namespace per terminal; foreign-session & destructive-action protection; append-only ledger) + two supremacy rules (S-1 factory-arbiter supremacy; S-2 no-unarbitrated-autonomous-write). **PREPARE-ONLY**, Draft PR. ADR number assigned from current main (153 highest → 154 free; not hardcoded — confirmed at authoring).
- **Anti-dup (ADR-102) — pointer-first, no restatement:** each boundary references its existing mechanism canon: ADR-143/143-A/125 (allocator), ADR-060 (namespace), parallel-session-isolation Rules 1–7 + ADR-120/121 (lease/isolation/destructive), ADR-056/057/059/119 + #900 (append-only ledger), AGENTS.md (single-writer). Complements (no overlap) ADR-153 topology + TERMINAL-OWNERSHIP zones: topology=what terminals are; ownership=who owns which zone; this=who arbitrates boundaries.
- **Transmission caveat:** the line-2 spec was partially truncated by the shell (heredoc eaten); reconstructed faithfully from the visible structure (title, ADR-154, four-boundaries+two-supremacy frame, B-1/3/4/5/6 + Central-3/4 mapping, pointer-first). Exact boundary↔rec-number 1:1 mapping marked **[НЕИЗВЕСТНО]** in the ADR Consequences (stated by substance; operator confirms on Draft).
- **Scope/flow:** authored per #900 — doc + paired shard ATOMIC; NO hand-edit of generated ledger; NO hardcoded IL (build_ledger mints). ONE ADR + this shard; 0 off-scope.
- **Proof:** IL provisional (ADR-119 Rule 8) — max+1 over origin/main (max 748) → IL-749 via allocator (ADR-143/143-A); unique, 0 dups; 1:1 (ADR-144). Append-only: ONE tail shard, il_ts `2026-06-30T14:00:00Z` > main max `2026-06-30T13:00:00Z`. Fresh worktree off origin/main `e93c0b7` (ADR-120/060). FROZEN/.canon untouched.
- **Status:** DONE — ADR-154 + shard. **DRAFT PR; DO NOT MERGE — operator HITL. Line 2 of 7; sequential-to-completion.**
- **Refs:** `docs/adr/ADR-154-shared-space-orchestration.md`; ADR-060/143/143-A/125/120/121/056/057/059/119/153; parallel-session-isolation; TERMINAL-OWNERSHIP.md (line 1); AGENTS.md; #900; ADR-102/144. Operator directive 2026-06-30.
