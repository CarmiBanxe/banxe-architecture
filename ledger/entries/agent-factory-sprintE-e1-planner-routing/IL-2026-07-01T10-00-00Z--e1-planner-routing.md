---
il_ts: 2026-07-01T10:00:00Z
session_id: agent-factory-sprintE-e1-planner-routing
source: factory
status: PREPARED
---

### IL-762 — Sprint-E E1: E2E Planner Passport Routing Validation (L1→L2)

**Date:** 2026-07-01  
**Status:** PREPARED  
**Sprint:** Sprint-E, item E1  
**Gate-in:** planner.yaml accepted (PR #865, IL-697)  
**Scope:** 15 pytest tests validating L1→L2 routing per `docs/canon/passports/planner.yaml`  
**Branch:** agent/factory/sprintE/e1-planner-routing

## Changes

### 1. tests/canon/test_l1_l2_mask_routing.py (NEW)

E2E validation of planner passport routing rules. Read-only checks — no Engine logic changes.

**Tests:**
- `test_planner_passport_exists` — YAML file present at canonical path
- `test_passport_has_dispatcher` — dispatcher section exists
- `test_dispatcher_has_entry_points` — at least 2 entry points declared
- `test_all_entry_points_have_autonomy` — every EP has a valid Lx autonomy field
- `test_task_decompose_autonomy_is_l1` — task_decompose routes at L1
- `test_task_decompose_route_contains_planner_agent` — chain includes planner-agent
- `test_task_decompose_route_contains_schema_validator` — chain includes schema-validator
- `test_task_decompose_route_contains_task_creator` — chain includes task-creator
- `test_task_decompose_hitl_gate_is_null` — L1 has no HITL gate
- `test_sprint_assign_autonomy_is_l2` — sprint_assign routes at L2
- `test_sprint_assign_has_hitl_gate` — L2 requires a gate
- `test_sprint_assign_route_contains_planner_agent` — chain includes planner-agent
- `test_all_l2_entry_points_have_hitl_gate` — invariant: all L2 EPs gated (ADR-049)
- `test_all_l1_entry_points_have_no_hitl_gate` — invariant: all L1 EPs ungated
- `test_adr049_referenced_in_passport` — ADR-049 cited in passport notes

**Result:** 15/15 PASS (verified locally)

## Acceptance Criteria

- [x] 15 tests, all PASS
- [x] Read-only: no Engine logic modified
- [x] Source of truth: `docs/canon/passports/planner.yaml` (PR #865, ADR-049)
- [x] ORPHAN-GATE: 0

## Regulatory Reference

- **EU AI Act Art.14:** human oversight → L2 entries require HITL gate (tested)
- **ADR-049:** intent masks define L1/L2 boundary
- **agent-authority.md:** L1 = fully automated, L2 = alert → human
