# F2-identity-room — agents roster (bank-only)

Generated from AGENT-REGISTRY-BANK-MASTER-2026-07-22.md (bank-only, 129). 8 bank agents in this room.

ENGINE-MANUS and REPAIR-BRIGADE agents are moved to `../../docs/governance/COMPANY-REGISTRY-*` and are **not** part of the bank headcount. Contested engine rows (fx_engine, design_pipeline) are excluded pending `[audit]`.

| agent_id | canonical_name | source_path | class | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|
| AG-F2-001 | KycOnboardingAgent | services/agents/kyc_onboarding_agent.py | KycOnboardingAgent | Compliance-Officer/MLRO | SMF17 | decision | HITL-006 | active |
| AG-F2-002 | KybAgent | services/kyb_onboarding/kyb_agent.py | KybAgent | Compliance-Officer/MLRO | SMF17 | decision [gated-counsel] — KYB↔acquiring | HITL-002/007 | [gated-counsel] |
| AG-F2-003 | ConsentAgent | services/consent_management/consent_agent.py | ConsentAgent | Compliance-Officer/MLRO | SMF17 | decision | - (register #5 consent/DPO) | active |
| AG-F2-004 | LifecycleAgent | services/customer_lifecycle/lifecycle_agent.py | LifecycleAgent | Compliance-Officer/MLRO | SMF17 | decision | - | active |
| AG-F2-045 | FatcaAgent | services/fatca_crs/fatca_agent.py | FatcaAgent | Compliance-Officer/MLRO | SMF17 | decision `[pending human ratification]` — room F2-identity vs F3-aml/regrep | - | proposed |
| AG-F2-046 | ComplianceAutomationAgent | services/compliance_automation/compliance_automation_agent.py | ComplianceAutomationAgent | Compliance-Officer/MLRO | SMF17 | decision `[pending human ratification]` — room/type contested | - | proposed |
| AG-F2-047 | ComplianceSyncAgent | services/compliance_sync/compliance_agent.py | ComplianceAgent | - | - | tooling `[pending human ratification]` — sync utility, room contested | - | proposed |
| AG-F2-048 | ComplianceCalendarAgent | services/compliance_calendar/calendar_agent.py | CalendarAgent | Compliance-Officer/MLRO | SMF17 | decision `[pending human ratification]` — room F2-identity vs F3-regrep | - | proposed |

---
**This does not replace legal advice.**
