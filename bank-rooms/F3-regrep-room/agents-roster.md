# F3-regrep-room — agents roster (bank-only)

Generated from AGENT-REGISTRY-BANK-MASTER-2026-07-22.md (bank-only, 129). 4 bank agents in this room.

ENGINE-MANUS and REPAIR-BRIGADE agents are moved to `../../docs/governance/COMPANY-REGISTRY-*` and are **not** part of the bank headcount. Contested engine rows (fx_engine, design_pipeline) are excluded pending `[audit]`.

| agent_id | canonical_name | source_path | class | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|
| AG-F3-030 | RegulatoryReportingAgent | services/regulatory_reporting/regulatory_reporting_agent.py | RegulatoryReportingAgent | CFO | SMF2 | decision | HITL-010 | active |
| AG-F3-031 | ReportingAgent | services/reporting/reporting_agent.py | ReportingAgent | CFO | SMF2 | decision | HITL-010 (I-24 append-only) | active |
| AG-F3-032 | FIN060GeneratorV2 | services/reporting/fin060_generator_v2.py | FIN060Generator | CFO | SMF2 | decision | HITL-010 (I-24 append-only) | active |
| AG-F3-033 | RegDataReturn | services/reporting/regdata_return.py | RegDataReturn | CFO | SMF2 | decision | HITL-010 | active |

---
**This does not replace legal advice.**
