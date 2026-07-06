---
il_ts: 2026-07-06T01:15:42Z
session_id: agent-factory-souls-cohort10-dev-data-gov
source: CEO
status: PROPOSED
---
### Cohort 10 — dev/data/governance leftovers: author 3 governor SOULs, prepare-only, no activation

- **Objective:** Author SOUL charters for the 3 SOUL-less dev/data/governance agents that showed parsing anomalies (?/UNKNOWN context) in the fleet audit: `spec_first_auditor`, `gap_tracker_agent`, `data_lake_elt_agent`. Forward-path continuation of the #1040 readiness audit (after Cohorts 1–9). All 3 were responsibly groundable — **none dropped**.
- **Schema-nonconformance reported honestly (each passport uses a different, non-standard schema):**
  - `spec_first_auditor` — hyphenated `agent_id: spec-first-auditor`; `tools`/`audit_checklist`/`territory_enforcement` instead of `capabilities`/`ports`/`invariants`. Groundable via its clear remit.
  - `gap_tracker_agent` — `id:` (not `agent_id:`); NO `bounded_context` / `change_class`; `purpose`/`checks`/`invariant`/`session_rule`. Groundable.
  - `data_lake_elt_agent` — `apiVersion: banxe.dev/v1` / `kind: AgentPassport` / `metadata`/`spec` (k8s-style); declares NO `trust_zone` / `level` / `bounded_context`. Grounded on what IS present (mission/invariants/non_goals). Fields absent were NOT invented.
- **Status verdicts (body-check, [[passport-status-active-on-stub-is-unreliable]]):**
  - `spec_first_auditor` — `status: ACTIVE` = **genuinely live** (real `audit_script` ~/developer/spec-first/audit/spec_first_auditor.py; NOT a GAP-078 stub). Evidence: real checklist + territory_enforcement + il_ref IL-045. Org-placement `PROPOSED (pending ratification)` (#1012). SOUL documents a live dev-plane tool; Factory touched no passport.
  - `gap_tracker_agent` — `status: ACTIVE` = **genuinely live** (real `scripts/gap-tracker.py`; IL-GAP-001; created 2026-04-13; passport invariant 'cannot be disabled without CEO+CTIO'). SOUL documents a live governance agent.
  - `data_lake_elt_agent` — `status: PROPOSED` (Channel C, `activation.enabled: false`). Genuine PROPOSED.
  - Distinction: unlike the dept-head stubs (cto_platform/board_reporting/cfo_orchestration/front_office/legal_corporate — stray-active on GAP-078 stubs), spec_first_auditor + gap_tracker are REAL active agents with real scripts → documentation-only SOULs, honestly ACTIVE.
- **Facts grounded per passport (origin/main), NOT normalised:**
  - `spec_first_auditor` — CTX-00-DEVELOPER · AMBER · L2 · CLASS_B · CTIO. Enforces Spec-First territory (files ONLY in ~/developer/; blocks leaks into banxe-emi-stack/banxe-architecture). Tools Read/Bash/Glob/Grep — **NO Write/Edit** (audits + blocks, never fixes; independence). auto_refactor_pro + cicd_quick_setup prohibited. Invoked after each IL-045 block.
  - `gap_tracker_agent` — GREEN · L1_AUTO · CTIO. GAP-REGISTER.md enforcement (SSOT); session_start/pre_commit/Mon-09:00; overdue P0 = BLOCK; SMF17/SMF2 vacancy = RED ALERT alert_ceo. Report/track only, no autonomous state change; cannot be disabled without CEO+CTIO.
  - `data_lake_elt_agent` — owner/human_double CTIO; Channel C; GAP-040; ADR-060/102. Orchestrates residual ~70% ClickHouse Data Lake (dbt/Airbyte ELT PSP→ClickHouse/Debezium+Kafka CDC/OpenMetadata lineage/Airflow DAGs). Invariants I-08 (TTL not reduced), I-24 (AuditPort append-only — write path stays clickhouse_writer), I-28. non_goals: direct_clickhouse_writes (owned by clickhouse_writer), bi_dashboards (bi_dashboard_governor/L-bi). Route-not-reimplement; no direct write path; no dashboards.
- **Route-not-reimplement / lane discipline (canon):** each governs/orchestrates within its lane; none reimplements or absorbs a neighbour (data_lake_elt explicitly NOT the write path, NOT BI). SOUL **describes** authority, never expands it — enforcement in CI + ADR-117/128/121.
- **ADR-102 duplication audit:** `agents/souls/` checked — no pre-existing/near-duplicate SOUL for any of the 3 stems. **Decision: add net-new (3).** No merge/delete; no hidden consumer.
- **Format:** each SOUL = 12 sections, 64–68 lines. House style consistent with Cohorts 1–9.
- **Perimeter / canon:** banxe-architecture only; isolated worktree off origin/main (ADR-120), not shared checkout; no TRADING-001 / agent/specproj/* (Rule 6); no secrets; no code/runtime change; signed; `--force-with-lease` only; NO-PASSPORT-DIFF guard before push. Serial single PR.
- **Deliverable:** 3 `agents/souls/*.md` + this IL shard. ONE Draft PR, prepare-only. IL frozen-at-merge (Rule 8); churn-resilient mint (factory re-rebases on conflict).
- **Fleet impact:** 51 → 54 SOULs. Remaining SOUL-less after this: the two high-sensitivity finals — CTX-04 payments (4) + CTX-01 compliance/AML (~16) + treasury_alm_agent.
- **Refs:** SOUL cohorts #1042/#1044/#1046/#1050/#1053/#1056/#1057/#1060/#1062; FACTORY-CANON.md (#1047, IL-932); passports agents/passports/{spec_first_auditor,gap_tracker_agent,data_lake_elt_agent}.yaml; CLAUDE.md §11; I-08; I-24; I-27; I-28; ADR-102; ADR-117/120/121/128; ADR-060; GAP-040; IL-045; IL-GAP-001; docs/governance/UNMAPPED-AGENTS-PLACEMENT.md (#1012).
