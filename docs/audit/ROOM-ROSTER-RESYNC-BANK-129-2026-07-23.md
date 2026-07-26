# Room-Roster Resync to BANK-MASTER (129) — 2026-07-23

**GOVERNANCE-AUDIT / POST-SPLIT ROSTER RESYNC / DOCS-ONLY / READ-ONLY RUNTIME**
Room rosters were originally generated from the combined 147-row MASTER (which mixed companies). They are now regenerated from `../governance/AGENT-REGISTRY-BANK-MASTER-2026-07-22.md` (bank-only, 129). ENGINE-MANUS and REPAIR-BRIGADE agents are moved to `../governance/COMPANY-REGISTRY-*` and are **not** part of the bank headcount. Read-only over `~/banxe-emi-stack`.

## Resync table

| room | old_roster_rows (147-based) | new_roster_rows (129-based) | BANK-MASTER count | match | Δ |
|---|---|---|---|---|---|
| F1-support | 8 | 8 | 8 | yes | 0 |
| F1-marketing | 6 | 6 | 6 | yes | 0 |
| F1-customer-ops | 18 | 18 | 18 | yes | 0 |
| F1-hr-legal | 2 | 2 | 2 | yes | 0 |
| F2-identity | 8 | 8 | 8 | yes | 0 |
| F2-ledger | 9 | 9 | 9 | yes | 0 |
| F2-payments | 27 | 27 | 27 | yes | 0 |
| F2-safeguarding | 4 | 4 | 4 | yes | 0 |
| F3-risk | 10 | 6 | 6 | yes | **−4** |
| F3-aml | 10 | 9 | 9 | yes | **−1** |
| F3-treasury | 10 | 9 | 9 | yes | **−1** |
| F3-finbi | 6 | 6 | 6 | yes | 0 |
| F3-regrep | 4 | 4 | 4 | yes | 0 |
| F4-ai-platform | 7 | 1 | 1 | yes | **−6** |
| F4-devops | 9 | 3 | 3 | yes | **−6** |
| F4-security | 2 | 2 | 2 | yes | 0 |
| F4-audit-cell | 7 | 7 | 7 | yes | 0 |
| **TOTAL** | **147** | **129** | **129** | **17/17** | **−18** |

## Rooms that lost rows (engine/repair removed)

- **F3-risk −4:** swarm/* ENGINE-MANUS — geo_risk, behavior, product_limits, profile_history.
- **F3-aml −1:** swarm/* ENGINE-MANUS — sanctions_agent.
- **F3-treasury −1:** ENGINE-MANUS — fx_engine/fx_agent (contested `[pending human ratification]`, excluded pending `[audit]`).
- **F4-ai-platform −6:** ENGINE-MANUS — webhook_agent, swarm base_agent, design_pipeline ×4 (contested, excluded pending `[audit]`).
- **F4-devops −6:** REPAIR-BRIGADE — watchdog/* ×6 (self-healing infra, 0 `*_agent.py`).
- **Total removed = 18** = 12 ENGINE-MANUS + 6 REPAIR-BRIGADE.

## Verdict

- **Sum of new rosters = 129 = BANK-MASTER.** 17/17 rooms conformant; 0 `[reconcile]`.
- All 17 `agents-roster.md` bodies overwritten from BANK-MASTER (files kept, names unchanged); new header cites BANK-MASTER (bank-only, 129) and states engine/repair are out of headcount.
- Contested engine rows (fx_engine, design_pipeline ×4) **not** pulled into bank rooms; they stay in COMPANY-REGISTRY-ENGINE-MANUS with `[pending human ratification]`. If `[audit]` returns any to BANK, the relevant room roster + BANK-MASTER rise accordingly.
- Flags `[gated-counsel]` / `[pending human ratification]` on bank rows carried verbatim; not resolved here. All legal → `[counsel]`.

---
**This does not replace legal advice.**
