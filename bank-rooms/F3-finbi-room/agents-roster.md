# F3-finbi-room — agents roster (bank-only)

Generated from AGENT-REGISTRY-BANK-MASTER-2026-07-22.md (bank-only, 129). 6 bank agents in this room.

ENGINE-MANUS and REPAIR-BRIGADE agents are moved to `../../docs/governance/COMPANY-REGISTRY-*` and are **not** part of the bank headcount. Contested engine rows (fx_engine, design_pipeline) are excluded pending `[audit]`.

| agent_id | canonical_name | source_path | class | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|
| AG-F3-028 | AnalyticsAgent | services/agents/analytics_agent.py | AnalyticsAgent | CFO | SMF2 | decision | - | active |
| AG-F3-029 | ReportingAnalyticsAgent | services/reporting_analytics/analytics_agent.py | AnalyticsAgent | - | - | tooling `[pending human ratification]` | - | proposed |
| AG-F3-034 | BiAgent | services/agents/bi_agent.py | BiAgent | - | - | tooling (L1-Auto) | - | active |
| AG-F3-035 | DataQualityAgent | services/agents/data_quality_agent.py | DataQualityAgent | - | - | tooling (L1-Auto) | - | active |
| AG-F3-036 | ForecastAgent | services/agents/forecast_agent.py | ForecastAgent | - | - | tooling (MASK) | - | active |
| AG-F3-037 | FpaAgent | services/agents/fpa_agent.py | FpaAgent | - | - | tooling (L1-Auto) | - | active |

---
**This does not replace legal advice.**
