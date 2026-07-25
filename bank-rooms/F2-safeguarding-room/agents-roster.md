# F2-safeguarding-room — agents roster (bank-only)

Generated from AGENT-REGISTRY-BANK-MASTER-2026-07-22.md (bank-only, 129). 4 bank agents in this room.

ENGINE-MANUS and REPAIR-BRIGADE agents are moved to `../../docs/governance/COMPANY-REGISTRY-*` and are **not** part of the bank headcount. Contested engine rows (fx_engine, design_pipeline) are excluded pending `[audit]`.

| agent_id | canonical_name | source_path | class | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|
| AG-F2-034 | ReconAgent | services/recon/recon_agent.py | ReconAgent | COO+CFO | SMF24+SMF2 | decision | HITL-011 | active |
| AG-F2-035 | ReconEngine | services/recon/recon_engine.py | ReconEngine | COO+CFO | SMF24+SMF2 | decision | - (I-24 append-only) | active |
| AG-F2-036 | ReconciliationEngine | services/recon/reconciliation_engine.py | ReconciliationEngine | COO+CFO | SMF24+SMF2 | decision | - (I-24 append-only) | active |
| AG-F2-037 | BreachNotifyPort | services/recon/breach_notify_port.py | BreachNotifyPort | COO+CFO | SMF24+SMF2 | decision | HITL-011 | active |

---
**This does not replace legal advice.**
