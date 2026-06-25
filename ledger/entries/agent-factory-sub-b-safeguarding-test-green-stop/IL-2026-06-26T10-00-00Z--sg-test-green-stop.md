---
il_ts: 2026-06-26T10:00:00Z
session_id: agent-factory-sub-b-safeguarding-test-green-stop
source: CEO
status: BLOCKED
---
### safeguarding-engine test-green — STOP-CONDITION invoked: runtime is unimplemented (Phase 3.6 stubs)

- **Objective:** Make the 9 safeguarding-engine test files GREEN by fixing TEST-AUTHORING defects only (constructor arity, missing fixtures, MCP naming) — no app/ runtime change, no fabricated passes.
- **Live audit (source of truth, not memory):** banxe-emi-stack origin/main@ebfeac6; PR #213 branch agent/factory/sgfix/safeguarding-install-path (install-path + DI providers + conftest Settings already fixed). banxe-architecture origin/main@b7e57f0, IL max=534 → this provisional max+1=IL-535 (Rule 8 frozen-at-merge; MAIN regenerates).
- **Finding (decisive, evidence-grounded):** the entire safeguarding-engine `app/` runtime is an unimplemented scaffold — **27 `raise NotImplementedError` stubs** ("Implement in Phase 3.6" / "Implement MCP tool"): safeguarding_service 6, breach_service 6, reconciliation_service 4, position_calculator 4, audit_logger 3, + 4 MCP tools. API handlers (`app/api/*`) call these stubbed service methods, so API tests bottom out in the same stubs.
- **Tests target a non-existent (future) API:** beyond arity, several tests call methods with NO runtime equivalent at all — `AuditLogger.log/query/update` (runtime has `log_event/query_events/generate_fca_report`), `PositionCalculator.calculate/compute_shortfall` (runtime has `calculate_position/get_client_fund_total/get_safeguarded_total/check_shortfall`). These cannot be "renamed to the real method": no real method matches the test's shape/args/return.
- **Why STOP (per STOP-CONDITION):** making any of the 9 tests GREEN requires IMPLEMENTING the service business logic (Phase 3.6) — i.e. changing `app/` runtime — which is explicitly forbidden for this task. Even fixing every test-authoring defect (fixtures, arity, MCP non-suffixed names) only moves each test from ImportError/TypeError to a `NotImplementedError` wall; none reaches green. Per canon: never modify runtime to force a green, never fabricate passes (e.g. assert-it-raises). Therefore: STOP all 9, document as a runtime-implementation follow-up.
- **No churn edits made:** did NOT apply cosmetic test edits that still cannot reach green (would imply progress that isn't real and partly cannot be done — `compute_shortfall`/`log` have no runtime counterpart). PR #213's legitimate, already-green-relevant fixes (install path, DI provider wiring, conftest↔Settings alignment) remain valid and unchanged.
- **ADR-102 dup-check:** no prior safeguarding test-green or runtime-impl IL on main (verified); non-duplicative; references PR #213 prior shards (install/DI/conftest).
- **Recommended follow-up (separate, operator-gated — P0 CASS 15):** implement Phase 3.6 service business logic for safeguarding-engine (position calc, breach detection/reporting, reconciliation, ClickHouse audit, MCP tools), THEN align the 9 test files to the implemented API and drive to green. This is a runtime feature build, not a test-authoring fix — out of scope for a tests-only remediation and gated by I-27 / governance for a CASS-15 P0 surface.
- **Perimeter / canon:** banxe-emi-stack tests/ + app/ NOT modified this round (STOP); no secrets; no runtime change; no fabricated passes; isolated worktree off origin/main@b7e57f0; signed; sub-B hands to MAIN per §71/§74; --force-with-lease only.
- **Deliverable:** this IL shard (BLOCKED finding). No banxe-emi-stack code change this round.
- **Refs:** PR #213 (banxe-emi-stack) install-path/DI/conftest commits; app/services/*.py + app/mcp/tools/*.py (27 NotImplementedError); app/api/*.py; STOP-CONDITION (tests-only mandate); ADR-102; I-27 (CASS 15 P0).
