# F4 Functional Agent Shortlist (filtered from raw grep) — 2026-07-21

**FLOOR-4 / FUNCTIONAL SHORTLIST (ACTION-3 pilot, step 1) / DOCS-ONLY / READ-ONLY RUNTIME**
Filters the raw 167 non-suffix grep candidates down to genuine F4 agentic entities, classified per `../governance/AGENT-CLASSIFICATION-CRITERION-2026-07-21.md`. Read-only over `~/banxe-emi-stack`.

## Filter applied

- **Kept:** class with orchestration/decision behaviour, OR carries `HITLProposal`, OR affects a regulated/operational outcome.
- **Dropped:** tests, `__init__`, pure utilities without a decision, duplicate references to one module.
- Scope: F4 zones only (`watchdog`, `deploy`, `audit`, `audit_trail`, `audit_dashboard`, `observability`, `security`). Domain swarm agents (sanctions/geo_risk/product_limits/etc.) are **F3** and out of this F4 pilot.

## Shortlist (non-`*_agent.py` functional entities)

| path | signal | decision\|tooling | proposed-room |
|---|---|---|---|
| `services/watchdog/repair_engine.py` | `RepairEngine.evaluate_and_act` — autonomous repair decision + verify | decision | F4-devops |
| `services/watchdog/guarded_actions.py` | `GuardedActionExecutor` — state-changing guarded ops (restart/config/recreate) | decision | F4-devops |
| `services/watchdog/decision_policy.py` | `ActionScorer` / `DefaultActionScorer` — action scoring/decision | decision | F4-devops |
| `services/watchdog/root_cause_classifier.py` | `RootCauseClassifier` (+LLM) — feeds repair decision | decision | F4-devops |
| `services/watchdog/best_solution.py` | `BestSolutionScorer.select` — repair-action selection (lineage L1 but decision-behaviour) | decision | F4-devops |
| `services/watchdog/watchdog.py` | node-state monitor/orchestration loop | decision | F4-devops |
| `services/audit/audit_query.py` | L2 + `HITLProposal` + `export_audit_report` | decision | F4-audit-cell |
| `services/audit_trail/retention_enforcer.py` | `HITLProposal` + `schedule_purge` (retention decision on audit records) | decision | F4-audit-cell |
| `services/observability/compliance_monitor.py` | `HITLProposal` + compliance invariant checks | decision | F4-audit-cell (devops cross-link) |
| `services/audit_dashboard/risk_scorer.py` | risk scoring (no lineage/HITL tag; scoring may affect outcome) | decision `[pending human ratification]` | F4-audit-cell |
| `services/audit_dashboard/governance_reporter.py` | governance report generation (human submits) | tooling `[pending human ratification]` | F4-audit-cell |
| `services/audit_dashboard/audit_aggregator.py` | read/aggregate audit data | tooling | F4-audit-cell |
| `services/observability/health_aggregator.py` | health/metric aggregation | tooling | F4-devops |

**Count into F4:** 13 non-`*_agent.py` functional entities passed the filter from the raw 167 (the rest are tests/`__init__`/utilities/duplicates/non-F4 domains — not re-listed here).

---
**This does not replace legal advice.**
