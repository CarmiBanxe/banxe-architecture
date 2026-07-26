# F4-security-room — agents roster (bank-only)

Generated from AGENT-REGISTRY-BANK-MASTER-2026-07-22.md (bank-only, 129). 2 bank agents in this room.

ENGINE-MANUS and REPAIR-BRIGADE agents are moved to `../../docs/governance/COMPANY-REGISTRY-*` and are **not** part of the bank headcount. Contested engine rows (fx_engine, design_pipeline) are excluded pending `[audit]`.

| agent_id | canonical_name | source_path | class | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|
| AG-F4-002 | IncidentResponseAgent | services/agents/incident_response_agent.py | IncidentResponseAgent | CTO | SMF26 | decision | HITL-015 | active |
| AG-F4-021 | FingerprintAgent | services/device_fingerprint/fingerprint_agent.py | FingerprintAgent | CTO | SMF26 | decision (HITLProposal) | - | active |

---
**This does not replace legal advice.**
