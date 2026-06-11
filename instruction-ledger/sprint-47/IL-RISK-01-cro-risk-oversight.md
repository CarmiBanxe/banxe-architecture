# IL-RISK-01: CRO RiskOversightAgent + RiskMetricsPort (PROPOSED → IMPLEMENTED)

- Sprint: 47
- Status: DONE
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked PR: CarmiBanxe/banxe-emi-stack (branch feat/sprint-47-cro-risk-oversight)
- Root ledger anchor: IL-173
- ADR: ADR-079 (CRO RiskMetricsPort + L1/L3 resolution)
- Created: 2026-06-11

## Context
ORG-STRUCTURE §2.2 (CRO, SMF4) defines `RiskOversightAgent` but is self-contradictory on its
autonomy: the section **header** says "Autonomy: L3 — CRO sign-off required / 🔴 RED", while the
**agent table** row says `RiskOversightAgent | Risk dashboard | L1 Auto | No`. A read-only
dashboard cannot also require L3 sign-off on every action; the §D2 mask needs an unambiguous band.

## Resolution (ADR-079, operator-approved)
`RiskOversightAgent` = **L1-Auto, read-only DASHBOARD** (aggregate + display risk metrics only).
The L3-RED header applies to the **CRO function as a whole** — the consequential §2.2
responsibilities (AI model risk assessment, fraud/AML **threshold approval**, material-risk Board
escalation), which remain **L3, human CRO** (EU AI Act Art.14 meaningful human oversight). Pattern:
monitoring/read = L1 (cf. `FraudScoringAgent` "monitoring only"); decision = L3. ORG §2.2 now
carries an explicit clarifying note; ADR-079 records the decision and boundaries.

## Delivered
### ADR-079 port (`services/risk/risk_metrics_port.py`, read-only)
`RiskMetricsPort` — abc.ABC + `InMemoryRiskMetricsPort` + `RiskMetricsPortError`. Read methods:
`get_aggregate_exposure`, `get_monitoring_counters`, `get_consumer_duty_signals`,
`get_risk_dashboard`. Value DTOs frozen; Decimal where monetary (I-01). **No** mutate/approve/
threshold method exists on the port at all. Live integrations (`services/risk_management/*`, fraud/
AML pipelines, Consumer Duty services) are out of scope — InMemory test impl only (I-10).

### Agent (`services/agents/risk_oversight_agent.py`, ORG §2.2, L1 Auto)
Read-only risk dashboard, full ADR-049 §D2 gate-chain (process_ref → scope → band → cost_cap →
compliance(RISK_DATA) → port), one ADR-046 `AgentDecisionRecord` per action, port + recorder
injected. Below-AUTO read → HALT_REVIEW_DEFERRED (no HITL hold, no step-up — L1). Compliance
non-PASS → BLOCK + escalate to CRO. **INVARIANT (enforced + tested):** the mask scope allow-list
contains only the four read ops; no approve/threshold/decision op is reachable. R-SEC: only opaque
handles in lineage — never metric values or PII; port returns ride on `AgentOutcome.result` only.

## Verification
- 39 tests; 100% coverage on both new modules (`risk_metrics_port.py` 57 stmts,
  `risk_oversight_agent.py` 142 stmts). ruff + ruff format clean; semgrep (banxe-rules) clean.
- Branches covered: AUTO (4 reads + e2e), HALT_UNRESOLVED_PROCESS, REJECT_OUT_OF_SCOPE,
  HALT_REVIEW_DEFERRED (port not called), BLOCK_LOW_CONFIDENCE, HALT_COST_CAP_BREACH (per-request
  + per-window, tokens + monetary), HALT_COMPLIANCE_BLOCK (FAIL + ESCALATE → CRO),
  HALT_PROVIDER_ERROR (emit + re-raise), ValueError on out-of-range confidence, band boundaries,
  R-SEC, one record per action, and the two invariant tests (scope read-only; approve op always
  out-of-scope).

## Doc-sync (this PR, banxe-architecture)
- `docs/adr/ADR-079-cro-risk-metrics-port.md` (new).
- `docs/ORG-STRUCTURE.md` §2.2 — `(PROPOSED)` removed on RiskOversightAgent + explicit L1/L3
  clarifying note resolving the header-vs-table contradiction.
- `INSTRUCTION-LEDGER.md` — root block `### IL-173` (append-only).
- `MEMORY.md` — sprint-47 block.
