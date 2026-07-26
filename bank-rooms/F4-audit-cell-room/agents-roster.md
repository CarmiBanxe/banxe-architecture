# F4-audit-cell-room — agents roster (bank-only)

Generated from AGENT-REGISTRY-BANK-MASTER-2026-07-22.md (bank-only, 129). 7 bank agents in this room.

ENGINE-MANUS and REPAIR-BRIGADE agents are moved to `../../docs/governance/COMPANY-REGISTRY-*` and are **not** part of the bank headcount. Contested engine rows (fx_engine, design_pipeline) are excluded pending `[audit]`.

| agent_id | canonical_name | source_path | class | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|
| AG-F4-004 | AuditAgent | services/audit_trail/audit_agent.py | AuditAgent | Internal Audit | SMF5 | decision | - (I-24 append-only) | active |
| AG-F4-013 | AuditQueryService | services/audit/audit_query.py | AuditQueryService | Internal Audit | SMF5 | decision | - (I-24 append-only) | active |
| AG-F4-014 | RetentionEnforcer | services/audit_trail/retention_enforcer.py | RetentionEnforcer | Internal Audit | SMF5 | decision | - (I-24 append-only) | active |
| AG-F4-015 | ComplianceMonitor | services/observability/compliance_monitor.py | ComplianceReport/Port | Internal Audit | SMF5 | decision | - | active |
| AG-F4-016 | RiskScorer | services/audit_dashboard/risk_scorer.py | RiskScorer | Internal Audit | SMF5 | decision `[pending human ratification]` | - | proposed |
| AG-F4-017 | GovernanceReporter | services/audit_dashboard/governance_reporter.py | GovernanceReporter | - | - | tooling `[pending human ratification]` | - | proposed |
| AG-F4-018 | AuditAggregator | services/audit_dashboard/audit_aggregator.py | AuditAggregator | - | - | tooling | - | active |

---
**This does not replace legal advice.**
