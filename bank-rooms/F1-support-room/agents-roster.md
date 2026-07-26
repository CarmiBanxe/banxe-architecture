# F1-support-room — agents roster (bank-only)

Generated from AGENT-REGISTRY-BANK-MASTER-2026-07-22.md (bank-only, 129). 8 bank agents in this room.

ENGINE-MANUS and REPAIR-BRIGADE agents are moved to `../../docs/governance/COMPANY-REGISTRY-*` and are **not** part of the bank headcount. Contested engine rows (fx_engine, design_pipeline) are excluded pending `[audit]`.

| agent_id | canonical_name | source_path | class | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|
| AG-F1-001 | CustomerSupportAgent | services/support/customer_support_agent.py | CustomerSupportAgent | Head of Support/COO | SMF24 | decision | - | active |
| AG-F1-002 | ComplaintTriageAgent | services/support/complaint_triage_agent.py | ComplaintTriageAgent | Head of Support/COO | SMF24 | decision | - (FOS relevance) | active |
| AG-F1-003 | EscalationAgent | services/support/escalation_agent.py | EscalationAgent | Head of Support/COO | SMF24 | decision | - | active |
| AG-F1-004 | FeedbackAnalyticsAgent | services/support/feedback_analytics_agent.py | FeedbackAnalyticsAgent | - | - | tooling | - | active |
| AG-F1-005 | TicketRoutingAgent | services/support/ticket_routing_agent.py | TicketRoutingAgent | - | - | tooling | - | active |
| AG-F1-006 | ComplaintsAgent | services/complaints/complaints_agent.py | ComplaintsAgent | Head of Support/COO | SMF24 | decision | - (FOS) | active |
| AG-F1-007 | ComplaintsEngine | services/complaints/complaints_engine.py | ComplaintsEngine | Head of Support/COO | SMF24 | decision | - (FOS) | active |
| AG-F1-008 | FosEscalation | services/complaints/fos_escalation.py | FosEscalation | Head of Support/COO | SMF24 | decision | - (FOS) | active |

---
**This does not replace legal advice.**
