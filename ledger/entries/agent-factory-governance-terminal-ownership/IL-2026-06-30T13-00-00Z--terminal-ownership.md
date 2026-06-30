---
il_ts: 2026-06-30T13:00:00Z
session_id: agent-factory-governance-terminal-ownership
source: CEO
status: DONE
---
### Terminal Ownership & Write-Zone Registry (line 1 of 7 governance batch)
- **Decision:** Authored `docs/governance/TERMINAL-OWNERSHIP.md` — the single source of terminal ownership + write-zone map, resolving central-terminal recommendations 1, 2, and the zone part of 7. Registers roles (A=factory/engine/dossier/GAP-closure; B=legacy+trading/recon; Central=governance + read-only elsewhere), a write-zone map grounded in the ACTUAL `origin/main` dir listing, the no-concurrent-write-without-lease rule (by pointer), and the `[OWNER: A|B|Central]` IL/PR tag convention. **PREPARE-ONLY**, Draft PR.
- **Honest grounding (no invented zones):** read the real top-level dirs first — **no `services/`, `legacy/`, `trading/`, `recon`, or `engine` dir exists in `banxe-architecture`**; engine/trading/recon code lives in `banxe-emi-stack` (separate repo). So A's code-zone and B's legacy/trading zone are marked **[НЕИЗВЕСТНО] here / cross-repo**, not invented. Real zones registered: A→`docs/agent-engine-dossier/`; Central→`docs/governance/`+governance dirs; shared-append-only→`ledger/`,`instruction-ledger/`.
- **Anti-dup (ADR-102):** mechanism (namespace, lease, single-writer, isolation) is NOT restated — points to ADR-060 (namespace), parallel-session-isolation Rules 1–7 + ADR-120/121 (lease/isolation), AGENTS.md (single-writer), ADR-059 (append-only shards). Complements (does not overlap) the in-flight #902 terminal-topology ADR by pointer: topology=what terminals are; this=who owns which write-zone. This doc adds only the ownership/zone FACTS.
- **Scope/flow:** authored per #900 runbook — doc + paired shard ATOMIC; NO hand-edit of generated INSTRUCTION-LEDGER.md; NO hardcoded IL (build_ledger mints). ONE doc + this shard; 0 off-scope.
- **Proof:** IL provisional (ADR-119 Rule 8) — max+1 over origin/main (max 744) → IL-745 via allocator (ADR-143/143-A); unique, 0 dups; 1:1 (ADR-144). Append-only: ONE tail shard, il_ts `2026-06-30T13:00:00Z` > main max `2026-06-30T12:00:00Z`. Fresh worktree off origin/main `e73c467` (ADR-120/060). FROZEN/.canon untouched.
- **Status:** DONE — registry doc + shard. **DRAFT PR; DO NOT MERGE — operator HITL. Line 1 of 7; sequential-to-completion.**
- **Refs:** `docs/governance/TERMINAL-OWNERSHIP.md`; AGENTS.md; ADR-060/059/120/121; parallel-session-isolation; #902 (ADR-153 terminal-topology, complementary); ADR-102/119/143/144. Operator directive 2026-06-30.
