---
il_ts: 2026-07-02T03:30:00Z
session_id: agent-factory-governance-lesson-capture-e2e-test
source: CEO
status: DONE
---
### [OWNER: A] End-to-end TEST of factory-native lesson-capture (#951) — add real lesson L-10 through the pipeline
- **Decision:** Per operator "end-to-end test of factory-native lesson-capture", exercised the mechanism (#951/IL-798) by adding one **real** register entry **L-10** to `docs/governance/FACTORY-LESSON-CAPTURE.md` through the full prepare-only pipeline. Proves the "add a lesson" process works: passes gates, mints IL (not hardcoded), does NOT touch CLAUDE.md, produces a valid Draft PR. **PREPARE-ONLY**, Draft PR. Owner A.
- **L-10 (real, not fictional):** Symptom = `--auto` merge did not land the PR at serialize-flicker + `gh pr ready` skipped for a Draft; Root cause = `gh pr merge --auto` aborted on the `main-merge-serialize` GraphQL error and never armed, `gh pr ready` omitted from the merge block; Corrective = at behind-0 + CLEAN use a direct `gh pr merge` (not `--auto`), always include `gh pr ready` before merge for a Draft (consolidates L-03 + L-04); Ref = #887, #934, #936, #942. Updated "L-01..L-09" → "L-01..L-10" in the doc footer.
- **Verification (the point of the test):** register = **10 lessons (L-01..L-10)**; **CLAUDE.md NOT touched** (safe-by-design holds under a real add); shard created + IL minted by build_ledger (not hardcoded); gates green (build_ledger --check 0, guardian-ledger+shards, adr117, adr-traceability, semgrep 0, FROZEN untouched) = **adding a lesson passes quality-gate WITHOUT bypass**; valid Draft PR. Change = FACTORY-LESSON-CAPTURE.md + this shard only.
- **Anti-dup note (honest):** L-10 deliberately consolidates the already-present L-03 (gh pr ready) + L-04 (direct merge at behind-0) into one operational rule — noted inline in the entry, not a hidden duplicate; per operator's exact test payload.
- **Boundaries:** CLAUDE.md NOT touched; `.claude/` NOT touched; perimeter/tools NOT touched; no external code; no gate bypass. Only the register doc + this shard. 0 off-scope.
- **Anti-dup (ADR-102) pointer-first:** in-place register append to the single existing FACTORY-LESSON-CAPTURE.md (#951); references #887/#934/#936/#942 — no parallel doc, no code.
- **Scope/flow:** authored per #900 — doc + paired shard ATOMIC; NO hand-edit of generated ledger; NO hardcoded IL (build_ledger mints, ADR-119 Rule 8). Re-mint discipline if collision: reset onto origin/main + regenerate; recreate shard AFTER reset (L-05/#933).
- **Proof:** IL provisional (ADR-119 Rule 8) — max+1 over origin/main (max 798) via allocator (ADR-143/143-A); unique, 0 dups; 1:1 (ADR-144). Append-only: ONE tail shard, il_ts `2026-07-02T03:30:00Z` > main max. Fresh worktree off origin/main (ADR-120/060). FROZEN/.canon untouched.
- **Status:** DONE — L-10 added + shard; mechanism proven end-to-end. **DRAFT PR; DO NOT MERGE — operator HITL. Test record is REAL: merge (keep the lesson) or close (clean test) = operator's decision.**
- **Refs:** `docs/governance/FACTORY-LESSON-CAPTURE.md` (#951/IL-798); #887/#934/#936/#942 (L-10 source incidents); ADR-102/119; #900. Operator directive 2026-07-02 (end-to-end test of lesson-capture).
