---
il_ts: 2026-07-05T23:27:00Z
session_id: agent-factory-souls-cohort5-ctx03-complete
source: CEO
status: PROPOSED
---
### Cohort 5 — complete CTX-03: author 3 Tech/Data platform governor SOULs, prepare-only, no activation

- **Objective:** Author the final 3 SOUL charters for the CTX-03 (Tech/Data platform) context, closing CTX-03 to 8/8 SOULs after Cohort 4 (#1050). Targets: `clickhouse_writer`, `cto_platform_agent`, `experiment_copilot_agent`. Forward-path continuation of the #1040 readiness audit (after Cohorts 1/#1042, 2/#1044, 3/#1046, 4/#1050).
- **Facts grounded in each passport (origin/main), NOT normalised to memory — the three differ materially:**
  - `clickhouse_writer` — **L3 · GREEN · CLASS_A** append-only audit *adapter* (not an AMBER governor). Invariants **I-17** (DORA 5-yr retention) + **I-24** (append-only, no UPDATE/DELETE). Inbound `AuditPort` (`src/compliance/ports/audit_port.py`, adapter `decision_event_log.py`); callers banxe_aml_orchestrator/aml_orchestrator; callees none. Owner **Platform Engineering**, org placement **Head of Data** (no `human_double` field — escalation via owner/placement). `auto_refactor_pro` prohibited. FCA: DORA Art.14(2), MLR 2017 Reg.40.
  - `cto_platform_agent` — L2 · AMBER · CLASS_B **department-head stub**. human_double **CTO (Oleg @p314pm)**; SMF26 / SM&CR / 1st Line; approvers CEO. **No service code yet** (GAP-078, Sprint 3); capabilities intentionally a stub. PROPOSED per description/non_goals (I-27) despite a `status: active` field. Parent canon governance/CANONICAL-ORG-CHART-v2.md.
  - `experiment_copilot_agent` — L2 · AMBER · CLASS_B. human_double **CTO**; inbound `ExperimentPort`, callee `clickhouse_writer`, caller admin_panel; invariants I-27 + I-08. Service code sparse (`ExperimentConfig` only — SOUL does not overstate the surface). FCA: EU AI Act Art.14 (human oversight of experiments).
- **Route-not-reimplement (canon):** each SOUL governs/orchestrates/routes the existing service or port; none reimplements. `cto_platform_agent` has no service code — SOUL is honest that implementation is a gated Sprint-3 workstream (GAP-078), coordination/proposal only. SOUL **describes** authority, never expands it — enforcement in CI + ADR-117/128/121.
- **Prepare-only (canon):** 3 SOUL docs only. **No passport touched; every agent stays PROPOSED.** PROPOSED→LIVE remains an I-27 HITL-L4 operator act (CLAUDE.md §11) — CTO (+ CEO for cto_platform_agent; Platform Engineering/Head of Data for clickhouse_writer). The Factory never activates. Per FACTORY-CANON.md (IL-932).
- **ADR-102 duplication audit:** `agents/souls/` checked — no pre-existing/near-duplicate SOUL for any of the 3 stems. **Decision: add net-new (3).** No merge/delete; no hidden consumer.
- **Format:** each SOUL = 12 sections (Identity, Core Responsibilities, Tools Available, Data Sources (read-only), Constraints, Escalation, HITL Gate, HITL Workflow, Voice, Memory Policy, Core Truths, Pet Peeves), 64 lines. House style consistent with Cohorts 1–4.
- **Perimeter / canon:** banxe-architecture only; authored in isolated worktree off origin/main (ADR-120), not the shared checkout; no TRADING-001 / agent/specproj/* (Rule 6); no secrets; no code/runtime change; signed; `--force-with-lease` only.
- **Deliverable:** 3 `agents/souls/*.md` + this IL shard. ONE Draft PR, prepare-only. IL frozen-at-merge (Rule 8) — minted via build_ledger.py on current origin/main immediately before merge, not hardcoded here.
- **Fleet impact:** 35 → 38 SOULs; CTX-03 complete (8/8). Remaining SOUL-less after this: 37 of 57 passports.
- **Refs:** SOUL cohorts #1042 (IL-925) / #1044 (IL-930) / #1046 (IL-934) / #1050 (IL-936); FACTORY-CANON.md (#1047, IL-932); passports agents/passports/{clickhouse_writer,cto_platform_agent,experiment_copilot_agent}.yaml; CLAUDE.md §11; I-27; I-24; I-17; I-08; ADR-102; ADR-117/120/121/128; parallel-session-isolation Rule 6; GAP-078; governance/CANONICAL-ORG-CHART-v2.md.
