# F3-treasury-room — agents roster (bank-only)

Generated from AGENT-REGISTRY-BANK-MASTER-2026-07-22.md (bank-only, 129). 9 bank agents in this room.

ENGINE-MANUS and REPAIR-BRIGADE agents are moved to `../../docs/governance/COMPANY-REGISTRY-*` and are **not** part of the bank headcount. Contested engine rows (fx_engine, design_pipeline) are excluded pending `[audit]`.

| agent_id | canonical_name | source_path | class | human_double | SMF | decision_or_tooling | hitl_gate | status |
|---|---|---|---|---|---|---|---|---|
| AG-F3-018 | TreasuryAgent | services/treasury/treasury_agent.py | TreasuryAgent | CFO | SMF2 | decision | HITL-016 | active |
| AG-F3-019 | TreasuryAgentAlt | services/agents/treasury_agent.py | TreasuryAgent | - | - | tooling (MASK-ONLY) | - | active |
| AG-F3-020 | FxRateAgent | services/fx_rates/fx_rate_agent.py | FxRateAgent | CFO | SMF2 | decision | - | active |
| AG-F3-022 | FxExchangeAgent | services/fx_exchange/fx_agent.py | FxAgent | CFO | SMF2 | decision `[pending human ratification]` | - | proposed |
| AG-F3-023 | MultiCurrencyAgent | services/multi_currency/multicurrency_agent.py | MultiCurrencyAgent | - | - | tooling `[pending human ratification]` | - | proposed |
| AG-F3-024 | SweepEngine | services/treasury/sweep_engine.py | SweepEngine | CFO | SMF2 | decision | - | active |
| AG-F3-025 | LiquidityMonitor | services/treasury/liquidity_monitor.py | LiquidityMonitor | - | - | tooling `[pending human ratification]` | - | proposed |
| AG-F3-026 | FxExposurePort | services/treasury/fx_exposure_port.py | FxExposurePort | - | - | tooling (port) | - | active |
| AG-F3-027 | BalanceEngine | services/multi_currency/balance_engine.py | BalanceEngine | - | - | tooling `[pending human ratification]` | - | proposed |

---
**This does not replace legal advice.**
