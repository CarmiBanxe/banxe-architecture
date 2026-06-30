---
il_ts: 2026-06-30T16:00:00Z
session_id: agent-factory-governance-conflict-ledger
source: CEO
status: DONE
---
### Conflict Ledger — inter-terminal deconfliction + merge discipline (line 4 of 7)
- **Decision:** Authored `docs/governance/CONFLICT-LEDGER.md` — the mechanism by which the factory deconflicts overlapping inter-terminal changes (in time or by files) + merge-discipline rules. Three additions: (1) conflict JOURNAL — factory (arbiter ADR-154) registers overlaps detected vs TERMINAL-OWNERSHIP zones, resolves by time-serialize or file-split, entry = when/who/zone-file/resolution; (2) PRIORITY rule — active operator directive > Terminal B planned work > Terminal A autonomous GAP queue (lower yields/rebases); (3) MERGE DISCIPLINE — all PRs target main never a feature branch; stacked-PRs forbidden without explicit merge-order in PR description; doc-sync/commit-log via separate append-only (ADR-059 shard) not feature branches, to avoid dirty cycles/rebases. **PREPARE-ONLY**, Draft PR.
- **Anti-dup (ADR-102) — pointer-first, no restatement:** points to ADR-154 (arbiter), LEDGER-MERGE-QUEUE.md (serialization mechanism = the 'by time' axis), TERMINAL-OWNERSHIP.md (overlap-detection basis), parallel-session-isolation Rules 1–8 (rebase-on-behind/lease), ADR-059/057 (append-only doc-sync). Adds ONLY journal+priority+discipline; LEDGER-MERGE-QUEUE already covers serialization/merge-queue so not duplicated.
- **[НЕИЗВЕСТНО] (not invented):** physical location/format of the conflict journal (file vs ledger section); enforce merge-discipline as CI gate vs advisory — both operator decisions.
- **Scope/flow:** authored per #900 — doc + paired shard ATOMIC; NO hand-edit of generated ledger; NO hardcoded IL (build_ledger mints). ONE doc + this shard; 0 off-scope.
- **Proof:** IL provisional (ADR-119 Rule 8) — max+1 over origin/main (max 750) → IL-751 via allocator (ADR-143/143-A); unique, 0 dups; 1:1 (ADR-144). Append-only: ONE tail shard, il_ts `2026-06-30T16:00:00Z` > main max `2026-06-30T15:00:00Z`. Fresh worktree off origin/main `b1efb4f` (ADR-120/060). FROZEN/.canon untouched.
- **Status:** DONE — mechanism doc + shard. **DRAFT PR; DO NOT MERGE — operator HITL. Line 4 of 7; sequential-to-completion.**
- **Refs:** `docs/governance/CONFLICT-LEDGER.md`; ADR-154; LEDGER-MERGE-QUEUE.md; TERMINAL-OWNERSHIP.md; parallel-session-isolation; ADR-059/057/060; ADR-102/119/143/144. Operator directive 2026-06-30.
