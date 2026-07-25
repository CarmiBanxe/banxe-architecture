# F2-ledger-room — agents roster (bank-only)

Generated from AGENT-REGISTRY-BANK-MASTER-2026-07-22.md (bank-only, 129). 9 bank agents in this room.

ENGINE-MANUS and REPAIR-BRIGADE agents are moved to `../../docs/governance/COMPANY-REGISTRY-*` and are **not** part of the bank headcount. Contested engine rows (fx_engine, design_pipeline) are excluded pending `[audit]`.

| agent_id | canonical_name | source_path | class | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|
| AG-F2-005 | MidazMcpAgent | services/midaz_mcp/midaz_agent.py | MidazAgent | CFO | SMF2 | decision [gated-counsel] — Midaz/MCP→ledger | - (external review) | [gated-counsel] |
| AG-F2-006 | MidazClient | services/midaz_mcp/midaz_client.py | MidazClient | CFO | SMF2 | decision [gated-counsel] — Midaz/MCP→ledger | - | [gated-counsel] |
| AG-F2-007 | GLService | services/ledger/gl_service.py | GLService | CFO | SMF2 | decision | - (I-24 append-only) | active |
| AG-F2-008 | PaymentPostingService | services/ledger/payment_posting_service.py | PaymentPostingService | CFO | SMF2 | decision | - (I-24 append-only) | active |
| AG-F2-009 | PostingRuleEngine | services/ledger/posting_rules.py | PostingRuleEngine | CFO | SMF2 | decision | - (I-24 append-only) | active |
| AG-F2-010 | MidazAdapter | services/ledger/midaz_adapter.py | MidazAdapter | CFO | SMF2 | decision [gated-counsel] — Midaz/MCP→ledger | - | [gated-counsel] |
| AG-F2-011 | CryptoApplicationService | services/ledger/crypto_application_service.py | CryptoApplicationService | CFO | SMF2 | decision [gated-counsel] — crypto/CASP | - | [gated-counsel] |
| AG-F2-012 | CryptoLedgerPort | services/ledger/crypto_ledger_port.py | CryptoLedgerPort | - | - | tooling [gated-counsel] — crypto/CASP | - | [gated-counsel] |
| AG-F2-013 | ApprovalModels | services/ledger/approval_models.py | (models) | - | - | tooling | - | active |

---
**This does not replace legal advice.**
