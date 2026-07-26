# AGENT REGISTRY — Floor 4 (pilot) — 2026-07-21

**GOVERNANCE / AGENT REGISTRY F4 PILOT (ACTION-3) / DOCS-ONLY / READ-ONLY RUNTIME**
Populated per `AGENT-REGISTRY-TEMPLATE.md` and classified per `AGENT-CLASSIFICATION-CRITERION-2026-07-21.md`. F4 only (ai-platform / devops / security / audit-cell) as the method reference; other floors are NOT filled in this step. `human_double`/`SMF` from `../ORG-STRUCTURE.md` (CTO SMF26 for ai-platform/devops/security; Internal Audit SMF5 for audit-cell). Read-only over `~/banxe-emi-stack`.

## Registry rows (F4)

| agent_id | canonical_name | source_path | class | room | department | floor | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| AG-F4-001 | DeployAgent | services/agents/deploy_agent.py | DeployAgent | F4-devops | DevOps | F4 | CTO | SMF26 | decision | HITL-013 | active |
| AG-F4-002 | IncidentResponseAgent | services/agents/incident_response_agent.py | IncidentResponseAgent | F4-security | Security | F4 | CTO | SMF26 | decision | HITL-015 | active |
| AG-F4-003 | WebhookAgent | services/webhook_orchestrator/webhook_agent.py | WebhookAgent | F4-ai-platform | AI Platform | F4 | CTO | SMF26 | decision | - | active |
| AG-F4-004 | AuditAgent | services/audit_trail/audit_agent.py | AuditAgent | F4-audit-cell | Audit | F4 | Internal Audit | SMF5 | decision | - (I-24 append-only) | active |
| AG-F4-005 | ObservabilityAgent | services/observability/observability_agent.py | ObservabilityAgent | F4-devops | DevOps | F4 | CTO | SMF26 | tooling `[pending human ratification]` | - | proposed |
| AG-F4-006 | SwarmBaseAgent | services/swarm/agents/base_agent.py | BaseAgent | F4-ai-platform | AI Platform | F4 | - | - | tooling (framework/abstract) | - | active |
| AG-F4-007 | RepairEngine | services/watchdog/repair_engine.py | RepairEngine | F4-devops | DevOps | F4 | CTO | SMF26 | decision | - (guarded/escalation) | active |
| AG-F4-008 | GuardedActionExecutor | services/watchdog/guarded_actions.py | GuardedActionExecutor | F4-devops | DevOps | F4 | CTO | SMF26 | decision | - (guarded) | active |
| AG-F4-009 | ActionScorer | services/watchdog/decision_policy.py | DefaultActionScorer | F4-devops | DevOps | F4 | CTO | SMF26 | decision | - | active |
| AG-F4-010 | RootCauseClassifier | services/watchdog/root_cause_classifier.py | RootCauseClassifier | F4-devops | DevOps | F4 | CTO | SMF26 | decision | - | active |
| AG-F4-011 | BestSolutionScorer | services/watchdog/best_solution.py | BestSolutionScorer | F4-devops | DevOps | F4 | CTO | SMF26 | decision | - | active |
| AG-F4-012 | Watchdog | services/watchdog/watchdog.py | Watchdog | F4-devops | DevOps | F4 | CTO | SMF26 | decision | - | active |
| AG-F4-013 | AuditQueryService | services/audit/audit_query.py | AuditQueryService | F4-audit-cell | Audit | F4 | Internal Audit | SMF5 | decision | - (I-24 append-only) | active |
| AG-F4-014 | RetentionEnforcer | services/audit_trail/retention_enforcer.py | RetentionEnforcer | F4-audit-cell | Audit | F4 | Internal Audit | SMF5 | decision | - (I-24 append-only) | active |
| AG-F4-015 | ComplianceMonitor | services/observability/compliance_monitor.py | ComplianceReport/Port | F4-audit-cell | Audit | F4 | Internal Audit | SMF5 | decision | - | active |
| AG-F4-016 | RiskScorer | services/audit_dashboard/risk_scorer.py | RiskScorer | F4-audit-cell | Audit | F4 | Internal Audit | SMF5 | decision `[pending human ratification]` | - | proposed |
| AG-F4-017 | GovernanceReporter | services/audit_dashboard/governance_reporter.py | GovernanceReporter | F4-audit-cell | Audit | F4 | - | - | tooling `[pending human ratification]` | - | proposed |
| AG-F4-018 | AuditAggregator | services/audit_dashboard/audit_aggregator.py | AuditAggregator | F4-audit-cell | Audit | F4 | - | - | tooling | - | active |
| AG-F4-019 | HealthAggregator | services/observability/health_aggregator.py | HealthAggregator | F4-devops | DevOps | F4 | - | - | tooling | - | active |

## Verdict note

- **F4 rows:** 19 (6 from `*_agent.py`; 13 from the functional shortlist).
- **decision-agents:** 14 (all carry `human_double`+`SMF` as required; two are `proposed`/`[pending human ratification]`: AG-F4-005 observability, AG-F4-016 risk-scorer).
- **tooling-agents:** 5 (AG-F4-005 observability [pending, currently tooling], AG-F4-006 base, AG-F4-017 governance-reporter [pending], AG-F4-018 aggregator, AG-F4-019 health).
- **[pending human ratification]:** 3 (AG-F4-005, AG-F4-016, AG-F4-017) — lineage/decision ambiguity, not self-decided.
- **From the raw 167 non-suffix candidates:** 13 passed the filter into F4; the remainder are tests/`__init__`/utilities/duplicates/non-F4 domains.
- **Scope:** F4 only. Other floors (F1/F2/F3) are not populated in this step — this is the method reference for one-floor-at-a-time expansion.

Open: `[factory]` confirm counting canon vs files(86)/classes(77); `[audit]` ratify the 3 pending rows and confirm decision-vs-tooling for watchdog/audit entities. All legal → `[counsel]`.

---
**This does not replace legal advice.**

## Reconciliation append — 2026-07-22 (coverage closure: UNPLACED placement)

Append-only; existing rows above unchanged. Rows added per REGISTRY-COVERAGE-CLOSURE-2026-07-21.md.

| agent_id | canonical_name | source_path | class | room | department | floor | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| AG-F4-020 | MlPipelineAgent | services/agents/ml_pipeline_agent.py | MlPipelineAgent | F4-ai-platform | AI Platform | F4 | CTO | SMF26 | decision (L3) | HITL-014 | active |
| AG-F4-021 | FingerprintAgent | services/device_fingerprint/fingerprint_agent.py | FingerprintAgent | F4-security | Security | F4 | CTO | SMF26 | decision (HITLProposal) | - | active |
| AG-F4-022 | ComplianceUiAgent | services/design_pipeline/agents/compliance_ui_agent.py | ComplianceUiAgent | F4-ai-platform | AI Platform | F4 | - | - | tooling (UI pipeline) | - | active |
| AG-F4-023 | ReportUiAgent | services/design_pipeline/agents/report_ui_agent.py | ReportUiAgent | F4-ai-platform | AI Platform | F4 | - | - | tooling (UI pipeline, MASK) | - | active |
| AG-F4-024 | TransactionUiAgent | services/design_pipeline/agents/transaction_ui_agent.py | TransactionUiAgent | F4-ai-platform | AI Platform | F4 | - | - | tooling (UI pipeline) | - | active |

## Reconciliation append #2 — 2026-07-22 (coverage-closure gap fix)

Append-only. `design_pipeline/agents/onboarding_agent` was previously only a prose cross-floor note (excluded from F2) but never rowed — now placed.

| agent_id | canonical_name | source_path | class | room | department | floor | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| AG-F4-025 | DesignOnboardingUiAgent | services/design_pipeline/agents/onboarding_agent.py | OnboardingAgent | F4-ai-platform | AI Platform | F4 | - | - | tooling (UI pipeline) | - | active |
