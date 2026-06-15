# IL-TREAS-01: CFO Treasury & Forecast — TreasuryAgent + ForecastAgent (PROPOSED → IMPLEMENTED)

- Sprint: 46
- Status: DONE (the two CFO agents deferred from sprint-45 / IL-171)
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked PR: CarmiBanxe/banxe-emi-stack#167
- Root ledger anchor: IL-172
- ADR: ADR-078 (CFO Treasury & Forecast read-only ports)
- Created: 2026-06-09

## Context
Sprint-45 (IL-FPA-01 / IL-171) shipped FPAAgent + BIAgent because each bound to an existing
port CONTRACT. TreasuryAgent (ORG §2.5.3) and ForecastAgent (ORG §2.5.2) were deferred — they
had no injectable port: `services/recon/recon_port.py` is safeguarding-specific (not NOSTRO),
and no FX-exposure or liquidity-forecast port existed. ADR-078 closes that gap port-first.

## Delivered
### ADR-078 ports (`services/treasury/`, read-only, abc.ABC + InMemory impl + PortError)
- **FXExposurePort** — read FX positions/exposure (`get_exposure`, `get_total_exposure`). Does
  NOT execute FX trades or hedges (execution stays in fx_engine/fx_exchange).
- **NOSTROReconPort** — read internal vs external NOSTRO balances and compare
  (`get_nostro_balances`, `reconcile` → difference + matched at £0.01 tol). No transfers/mutation.
- **LiquidityForecastPort** — read-only forecast inputs (`get_forecast_inputs`,
  `get_current_position`). No ML/dbt modelling, no source mutation.
All monetary values Decimal (I-01).

### Agents (`services/agents/`, L2 Review)
- **TreasuryAgent** (§2.5.3) — FX exposure + NOSTRO recon via the two ports. The §D2 step-up
  position is the **>£100k CFO sign-off**: a material amount ≥ £100k forces the action to REVIEW
  and requires `human_reviewed_by` (escalate → CFO), regardless of confidence band.
- **ForecastAgent** (§2.5.2) — rolling liquidity forecast via LiquidityForecastPort; below-AUTO
  holds for Head-of-FP&A review (HITL hold).

Both enforce the full ADR-049 §D2 gate-chain (process_ref → scope → band → cost_cap →
compliance(FINANCIAL_DATA) → step-up → port) and emit one ADR-046 `AgentDecisionRecord` per
action. Ports + DecisionRecorder constructor-injected; shared primitives from
`services/agents/_lineage.py`. R-SEC (R-SEC-NEW-01): only opaque handles (currency_pair /
account_id) reach a lineage record — never amounts, balances, or PII; port returns ride on
`AgentOutcome.result` only.

## Naming coexistence (documented)
`services/agents/treasury_agent.py:TreasuryAgent` (the L2 client-facing mask) coexists with the
pre-existing `services/treasury/treasury_agent.py` (the IL-TLM-01 domain liquidity agent). They
live in distinct packages with no shared import; the full test suite stays green. This mirrors
the documented AnalyticsClientAgent (client mask) vs domain `analytics_agent` precedent.

## Verification
- 77 tests; 100% coverage on all five new modules (3 ports + 2 agents).
- ruff + ruff format clean; semgrep (banxe-rules) clean; full repo suite 10521 passed / 0 failed.
- Branches covered: AUTO, HALT_UNRESOLVED_PROCESS, REJECT_OUT_OF_SCOPE, BLOCK_LOW_CONFIDENCE,
  HOLD_FOR_REVIEW (no reviewer / with reviewer), £100k→CFO step-up hold, HALT_COST_CAP_BREACH
  (per-request + per-window), HALT_COMPLIANCE_BLOCK (escalate→CFO / HEAD_OF_FPA),
  HALT_PROVIDER_ERROR (emit + re-raise), R-SEC, ValueError on out-of-range confidence,
  band boundaries, one record per action.

## Doc-sync (this PR, banxe-architecture)
- `docs/adr/ADR-078-cfo-treasury-forecast-ports.md` (new).
- `docs/ORG-STRUCTURE.md` §2.5 — removed `(PROPOSED)` on TreasuryAgent (§2.5.3) + ForecastAgent
  (§2.5.2). CFO office §2.5 is now fully implemented (FPA/BI sprint-45 + Treasury/Forecast sprint-46).
- `INSTRUCTION-LEDGER.md` — root block `### IL-172` (append-only).
- `MEMORY.md` — sprint-46 block.

## Recovery note
The factory developer run broke its worktree mid-build (a stray repo-copytree removed the
`.git` link). The 12 authored files were salvaged from disk, a stray `setup_wt.py` discarded,
a fresh worktree recreated off origin/main, and the existing `services/treasury/__init__.py`
(which the developer had clobbered) restored to origin/main. Final change set is exactly the
10 in-scope code/test files; all gates re-run green on the clean worktree.
