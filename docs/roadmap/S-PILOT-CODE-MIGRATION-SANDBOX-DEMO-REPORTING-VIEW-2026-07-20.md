# S-PILOT Code-Migration Sprint (Sandbox) — DEMO Reporting View

**PHASE-2 EXECUTION / SANDBOX PILOT CODE-MIGRATION SPRINT / NO REAL DEPLOY / NO LEGAL STATUS**

## Purpose & sandbox scope

- This is a sandbox-only pilot migration sprint for the synthetic family DEMO-FAM-REPORTING-VIEW.
- It rehearses the Phase-2 migration pattern (phases C/D/E) on synthetic components only — a paper pilot with no actual code move, deploy, or refactor.
- It does NOT touch any real EMI/bank code, systems, or data.
- It is part of the Banksy project, a next-generation bank design; this is training and design, not a production change.

## Pilot family description (SANDBOX)

- **Family ID:** DEMO-FAM-REPORTING-VIEW (SANDBOX).
- **Components:** demo_report_builder.py.
- **Location:** banksy-sandbox-repo / services/demo-reporting-view.
- **Lane:** other (Reporting / Analytics).
- **Owner role:** Reporting / Analytics Engineer.
- **Risk level:** low (read-only over synthetic demo data).

Synthetic, read-only — no real metrics, customers, or payments involved.

## Migration plan (sandbox-only)

Conceptual target for this DEMO family; no commands, no actual code.

- Target pattern: move demo_report_builder.py behind the governed "other" lane perimeter (a shared sandbox reporting framework) in banksy-sandbox-repo.
- No change to semantics: it still reads only synthetic demo data, with no write paths introduced.
- Instrumentation: add sandbox-only logging to support future audits, with no PII and no real data.
- Dependency alignment: ensure it reaches sandbox services via approved sandbox gateways, not directly.
- Evidence expectations: pre-define what post-migration evidence should look like (architecture note, config snippet, code-path reference, ops log sample) under docs/sandbox/ paths.
- Reversibility: the original sandbox location and config are preserved so the move can be undone.

## Step-by-step execution plan (SANDBOX)

All steps are hypothetical and sandbox-based; none is executable by itself.

1. Confirm DEMO-FAM-REPORTING-VIEW presence in the Phase-2 inventory (Family ID, lane, owner, risk level).
2. Review the current sandbox reporting architecture (diagrams/text) to locate demo-reporting-view.
3. Define the target sandbox location (e.g. banksy-sandbox-repo / services/reporting-framework/demo-reporting-view).
4. Draft a sandbox-only migration script plan — what would move and how configs would be updated (plan only).
5. Identify the required verification gates (audit-evidence gate, rollback readiness gate; no ledger/identity/gateway gates here).
6. Design the rollback plan for this DEMO family (how to revert to the original sandbox location if needed).
7. Define post-migration checks (synthetic data counts, log hooks, config sanity).
8. Prepare evidence IDs for planned artefacts (architecture, config, code-path, ops logs) under docs/sandbox/ paths.
9. Schedule a hypothetical pilot window in the sandbox (no real environment involved).
10. Record a dry-run walkthrough of the plan with the owner role for review (paper exercise).
11. Log all pilot assumptions and limitations (sandbox-only, no performance guarantees, no real users).

## Verification gates (applied to the pilot)

Gates in the sandbox plan, not real pass/fail events.

**Audit-evidence gate (required)**
- Must be shown: a reporting-lane install-audit exists (or is drafted) and its checks cover the synthetic view; demo_report_builder.py reads only sandbox sources.
- Sandbox evidence collected: architecture note (DEMO-ARCH-REPORT-VIEW-001), config snippet (DEMO-CONF-REPORT-SOURCES-001), code-path reference (DEMO-CODE-REPORT-READONLY-001), ops log sample (DEMO-OPS-REPORT-RUN-001).

**Rollback readiness gate (required)**
- Trigger conditions (hypothetical): mismatched demo outputs, broken sandbox scripts, or errors in sandbox logs.
- Rollback outline: restore demo_report_builder.py to its original sandbox path and revert the config.

**Ledger / identity / gateway gates (not applicable here)**
- This pilot does not touch the ledger, identity, or gateway lanes.
- The corresponding gates remain out of scope for this DEMO sprint.

## Rollback strategy (sandbox-only)

- **Trigger conditions:** demo-reporting-view fails its synthetic checks, or sandbox logs show errors after the (hypothetical) move.
- **Rollback steps:** restore demo_report_builder.py to its original sandbox folder and revert any changed sandbox configs to their prior values.
- **Evidence of rollback:** sandbox log entries recording the revert, plus a simple "rollback completed" note against the pilot record.
- **Impact assessment:** in the sandbox, none for real users — this is purely training, with no real business continuity or disaster-recovery implications.

## Post-migration audit & evidence (sandbox design)

A hypothetical post-migration audit for this DEMO family would cover:

- **Synthetic data checks:** row counts and simple aggregates match the pre-move demo baseline.
- **Config review:** demo_report_builder.py points only to sandbox data sources, no real endpoints.
- **Log sampling:** sandbox logs show successful demo runs with no errors.
- **Finding classification:** likely "low impact, sandbox training only".

This shows how post-migration audits should be structured for low-risk components before the pattern is applied to anything real.

## Boundaries and non-goals

- Does not move or deploy any real code.
- Does not update real configs or infrastructure.
- Does not involve real data, customers, or payments.
- Does not test performance or SLAs for production.
- Does not change the Phase-1 or Phase-2 master roadmaps.

This sprint is training and design only.

## What this pilot sprint is for

- To train operators and architects on the migration pattern in a safe sandbox.
- To refine the Phase-2 migration playbook on a low-risk synthetic case.
- To illustrate how gates, rollback, and post-migration evidence fit together.
- To prepare for future real migration sprints without touching real systems.
