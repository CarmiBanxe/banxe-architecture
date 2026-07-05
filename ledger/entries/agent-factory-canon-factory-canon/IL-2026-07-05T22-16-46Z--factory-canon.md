---
il_ts: 2026-07-05T22:16:46Z
session_id: agent-factory-canon-factory-canon
source: CEO
status: PROPOSED
---
### FACTORY-CANON.md — concise daily operational rulebook for the Software Factory (Terminal A / LEFT)

- **Objective:** Author `docs/factory/FACTORY-CANON.md` — a short, strict daily rulebook for how the Factory (Terminal A / LEFT) brings PROPOSED agents to READY-for-activation **without activating** any of them. 7 sections: Purpose; Operating Principles; Execution Pattern; Hard Boundaries; Output Rule; Parallel Mode; Definition of Done. No philosophy, minimal prose, maximal clear rules.
- **Prepare-only (canon):** documentation artifact only. No passport touched; every agent stays **PROPOSED**. PROPOSED→LIVE remains an I-27 HITL-L4 operator + MLRO/CTIO act (CLAUDE.md §11) — the Factory never activates.
- **ADR-102 duplication audit:** repo-wide search for existing factory-canon docs returned `docs/canon/software-factory-canon-v1.md` (broad canon), `docs/factory/FACTORY-OPERATING-RULES.md` (pointer #1014), `docs/factory/FACTORY-CANON-ADDENDUM-2026-05-12.md`, and two dated audit snapshots. **Decision: keep all; add net-new.** FACTORY-CANON.md is a *concise daily rulebook* distinct from the broad canon — it **references** those (Anchors §) and does **not** restate them. No merge/delete; no hidden consumer. Non-duplicative.
- **Placement:** `docs/factory/` — grouped with FACTORY-OPERATING-RULES.md and the addendum.
- **Perimeter / canon:** banxe-architecture only; authored in isolated worktree off origin/main (ADR-120), not the shared checkout; no secrets; no code/runtime change; signed; `--force-with-lease` only.
- **Deliverable:** `docs/factory/FACTORY-CANON.md` + this IL shard. Draft PR, prepare-only.
- **Refs:** CLAUDE.md §11; I-27 (HITL-L4 activation); ADR-117 (perimeter); ADR-120 (worktree); ADR-121 (destructive); ADR-128 (HITL); parallel-session-isolation Rule 6/7; ADR-102; SOUL cohorts #1042 / #1044 / #1046.
