---
il_ts: 2026-07-07T00:44:33Z
session_id: agent-factory-souls-teachers-retrofit-auditors
source: CEO
status: PROPOSED
---
### Teachers-retrofit R-auditors — apply the mandatory ## Decision Method to 3 existing teacher SOULs (prepare-only)

- **Objective:** Retrofit the mandatory `## Decision Method` section (ADR-131 standard, already amended 11→12 in PR #1077)
  into 3 EXISTING teacher SOULs — auditors first, then CFO. Applies the existing standard to older SOULs authored before
  the amendment. **Additive section ONLY** — no authority change, no status change (stay PROPOSED), no passport/config/schema,
  no ADR-131 edit, no activation.
- **Targets retrofitted (all fuzzy-confirmed SOUL-present, method-absent):**
  - `spec_first_auditor` → `agents/souls/spec-first-auditor.md` (auditor; report-only; block hands to CTIO).
  - `gap_tracker_agent` → `agents/souls/gap-tracker-agent.md` (auditor; gap-status proposal; owner / disable→CEO+CTIO).
  - `cfo_orchestration_agent` → `agents/souls/cfo-orchestration-agent.md` (orchestrator; govern/route finance; CFO, activation CEO).
- **Skips:** none (all 3 confirmed SOUL-present without `## Decision Method`).
- **Placement:** inserted immediately AFTER `## HITL Gate` (matching cohort 12b/13). Each grounded to its agent's role —
  enumerate feasible in-scope actions (no expansion) → score by the agent's own criteria (auditor: control materiality /
  independence / assurance coverage; CFO: fiscal materiality / fair-value / disclosure) via MAUT → satisfice within ITS HITL
  gate → escalate to ITS human double → fail-closed precedence (I-27, BUG-007). Pointer-first to
  best-decision-concept-2026-07-06-v2.md / BEST-DECISION-BOUNDARY / ADR-162 — not restated.
- **Diff discipline:** additions-only — 27 insertions, 0 deletions, no edit outside the inserted block; SOUL "describes
  authority, never expands it".
- **Teachers-track context:** after #1081 (IL-997) landed internal_audit_agent SOUL+method, this method-equips the remaining
  auditor teachers (spec_first_auditor, gap_tracker) + CFO orchestrator. Remaining teachers = NO-SOUL orchestrators
  (ceo/coo/aml_orchestrator) + AML-decision pair — later cohorts.
- **Perimeter / canon:** banxe-architecture only; isolated worktree off origin/main (ADR-120); no TRADING-001 /
  agent/specproj/* (Rule 6); signed; `--force-with-lease`. IL frozen-at-merge (Rule 8).
- **Deliverable:** 3 retrofitted `agents/souls/*.md` + this IL shard. ONE Draft PR, prepare-only.
- **Refs:** ADR-131 (+ amendment 2026-07-07, PR #1077); FACTORY-CANON §1.11; I-27; BUG-007; ADR-102; ADR-120; Rule 6;
  docs/sources/best-decision-concept-2026-07-06-v2.md; docs/canon/BEST-DECISION-BOUNDARY.md; docs/adr/ADR-162-best-decision-principle.md;
  cohort 13 (#1081, IL-997); cohort 12b (#1079).
