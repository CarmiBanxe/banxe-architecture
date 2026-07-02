---
il_ts: 2026-07-02T21:35:00Z
session_id: agent-factory-terminalb-spec-lane
source: operator
status: DONE
---

### ADR-TERMINAL-B-SPEC-LANE — Parallel Novelty-Hunting Lane with IL Anti-Collision

**Context:** Operator needs to run novelty hunting in parallel to the general line (Terminal A / Factory)
without blocking; existing infrastructure (Redis IL counter, session-namespace isolation) supports it.

**Decision:** Establish Terminal B as a second Orchestrating-Terminal instance with strict namespace
separation (`agent/specproj/<id>/<slug>`), shared Redis IL counter (no fork), rebase-freshness invariant,
and hand-off protocol via `governance/NOVELTY-COLLECTION-REGISTER.md` (append-only, I-24).

**Files:**
- `decisions/ADR-TERMINAL-B-SPEC-LANE.md` — formal ADR (ACCEPTED)
- `governance/NOVELTY-COLLECTION-REGISTER.md` — hand-off register (append-only) with schema + seed entries

**Quality:** Semgrep 0; ADR-120/121 (worktree-only git); ADR-060 (namespace); GUIYON security rule applied.

**Status:** DONE. Ready for operator review and merge to main.
