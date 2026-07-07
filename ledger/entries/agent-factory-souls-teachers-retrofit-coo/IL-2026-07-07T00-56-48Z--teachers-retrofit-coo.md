---
il_ts: 2026-07-07T00:56:48Z
session_id: agent-factory-souls-teachers-retrofit-coo
source: CEO
status: PROPOSED
---
### Teachers-retrofit — add ## Decision Method to coo_operations_agent (prepare-only, additive)

- **Objective:** Retrofit the mandatory `## Decision Method` (ADR-131 standard, amended 11→12 in #1077) into the
  EXISTING `coo_operations_agent` SOUL — the COO operations teacher, missed from the auditor+CFO batch (#1085) due to
  the coo naming-fuzz. **Additive section ONLY**; no authority/status change (stays PROPOSED); no passport/config/schema/ADR-131.
- **Target:** `coo_operations_agent` → `agents/souls/coo-operations-agent.md` (L2 · AMBER · CTX-04-PAYMENT; human double
  **COO (James Hargreaves)**, SMF24; 1st-line operations governor; propose-only). Method inserted after `## HITL Gate`,
  grounded fail-closed (never best-decides an operational/payment-affecting action). Pointer-first, not restated.
- **Dedup correction (ADR-102):** `coo_orchestration_agent` is a **phantom** id — no SOUL and **no passport** on main;
  NOT authored. The real COO agent is `coo_operations_agent` (this retrofit).
- **Diff discipline:** additions-only (9 insertions, 0 deletions). SOUL describes authority, never expands it.
- **Teachers-track:** with #1081 (internal_audit) + #1085 (spec_first/gap_tracker/cfo), this method-equips the COO teacher.
  Remaining: `aml_orchestrator` (SOUL exists at banxe-aml-orchestrator.md — retrofit in careful AML cohort);
  `ceo_orchestration_agent` + `case_management_agent` (genuinely NO-SOUL — author fresh; case_management = AML-decision, careful final).
- **Perimeter:** banxe-architecture; worktree off origin/main (ADR-120); no TRADING-001 / agent/specproj/* (Rule 6); signed; --force-with-lease. IL frozen-at-merge (Rule 8).
- **Refs:** ADR-131 (+#1077 amendment); FACTORY-CANON §1.11; I-27; BUG-007; ADR-102; #1085; #1081; docs/sources/best-decision-concept-2026-07-06-v2.md; docs/canon/BEST-DECISION-BOUNDARY.md; docs/adr/ADR-162-best-decision-principle.md.
