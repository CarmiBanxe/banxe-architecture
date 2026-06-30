---
il_ts: 2026-06-30T09:00:00Z
session_id: agent-factory-governance-autonomous-ledger-flow-corrective
source: CEO
status: DONE
---
### Corrective runbook — autonomous GAP-terminal ledger flow (root fix for #894–899 failure class)
- **Decision:** Authored `docs/runbooks/autonomous-ledger-flow-corrective.md` — a **pointer-first** operational runbook fixing the ROOT cause behind PRs #894–899 (autonomous GAP terminal): all fail CI ledger gates in 2 classes — (1) #894/895/896 doc-without-shard (ADR-056 coupling), (2) #897/898/899 hardcoded/stale IL (`IL-743/744/745`, malformed `IL-CBS`/`IL-2026`) → generated≠rebuild; structural GAP-042 split across #896+#897. **PREPARE-ONLY**, Draft PR.
- **Content:** correct per-PR flow (reset onto current origin/main → doc+shard atomic same PR → `python ledger/build_ledger.py` mints max+1, NO hardcoded IL → read-back + correct refs → `--check` 0 + 1:1 + no-dups + FROZEN untouched → lease-push → behind=rebase-signal not question). Forbidden list = the observed anti-patterns. §6 remediation of the existing 6 = operator/owning-terminal action (foreign-session Rule 6/7).
- **Anti-dup (ADR-102):** `factory-loop.md` has **0** build_ledger refs; the authoritative flow lives in parallel-session-isolation Rule 8 + ADR-056/119 + guardian-ledger-il-collision-gate.md — this runbook **points** to that canon (does not restate it) + adds the operational recipe + observed anti-patterns. No parallel/duplicate runbook.
- **Scope:** ONE new runbook + this IL shard. Does NOT touch the 6 broken PRs (foreign-session). Does NOT change any gate/canon — additive operational guidance.
- **Proof:** IL provisional (ADR-119 Rule 8) — max+1 over origin/main (max 742) → IL-743 via allocator (ADR-143/143-A); unique, 0 dups; 1:1 (ADR-144). Append-only: ONE tail shard, il_ts `2026-06-30T09:00:00Z` > main max `2026-06-30T08:00:00Z`. Fresh worktree off origin/main `d60c8bb` (ADR-120/060). FROZEN/.canon untouched.
- **Status:** DONE — corrective runbook + shard. **DRAFT PR; DO NOT MERGE — operator HITL via ADR-135. Existing 6 PRs (#894–899) remain operator/owning-terminal action (rescue or close).**
- **Refs:** `docs/runbooks/autonomous-ledger-flow-corrective.md`; parallel-session-isolation Rule 8; ADR-056/057/059/059-A/119; `ledger/build_ledger.py`; guardian-ledger-il-collision-gate.md; PRs #894–899. Operator HITL.
