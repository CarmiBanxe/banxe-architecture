# IL-DQ-01: CTO DataQualityAgent + DataQualityPort (PROPOSED → IMPLEMENTED)

- Sprint: 48
- Status: DONE
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked PR: CarmiBanxe/banxe-emi-stack#169
- Root ledger anchor: IL-174
- ADR: ADR-080 (CTO DataQualityPort read-only)
- Created: 2026-06-11

## Context
ORG-STRUCTURE §2.7.1 (CTO / AI Platform, SMF26 — Data & ML Engineering) defines
`DataQualityAgent` — *Data drift detection* — at **L1 Auto, no gate**. Its siblings are L3 and
I-27-gated: `MLPipelineAgent` (model retraining proposals, L3 CRO+CTO) and `FeedbackLoopAnalyser`
(threshold proposals, L3 CRO must approve). The ADR-049 §D2 mask needs an injectable port — none
existed — so ADR-080 adds one port-first. Only DataQualityAgent is built this sprint; DeployAgent
(§2.7.2) and MLPipelineAgent (§2.7.1) are deferred.

## Delivered
### ADR-080 port (`services/data_quality/data_quality_port.py`, read-only)
`DataQualityPort` — abc.ABC + `InMemoryDataQualityPort` + `DataQualityPortError`. Read methods:
`get_drift_score`, `get_quality_report` (null-rate / schema-conformance / freshness / drift),
`list_datasets`, `get_freshness`. Frozen DTOs; Decimal where numeric (I-01). **No** mutate /
trigger / retrain method exists on the port at all. Live data-quality/pipeline adapters are out of
scope — InMemory test impl only (I-10). The read-only surface preserves I-27 (no autonomous model
updates).

### Agent (`services/agents/data_quality_agent.py`, ORG §2.7.1, L1 Auto)
Detect + report data drift/quality, full ADR-049 §D2 gate-chain (process_ref → scope → band →
cost_cap → compliance(DATA_QUALITY) → port), one ADR-046 `AgentDecisionRecord` per action, port +
recorder injected. Below-AUTO read → HALT_REVIEW_DEFERRED (no HITL hold, no step-up — L1).
Compliance non-PASS → BLOCK + escalate to CTO. **INVARIANT (enforced + tested):** the mask scope
allow-list contains only the four read ops; no retrain / pipeline-trigger / data-write op is
reachable. R-SEC: only opaque handles (dataset names) reach a lineage record — never metric values
or PII; port returns ride on `AgentOutcome.result` only.

## Verification
- 54 tests; 100% coverage on both new modules (`data_quality_port.py` 55 stmts,
  `data_quality_agent.py` 145 stmts). ruff + ruff format clean; semgrep (banxe-rules) clean;
  full repo suite 10614 passed / 0 failed.
- Branches covered: AUTO (4 reads), HALT_UNRESOLVED_PROCESS, REJECT_OUT_OF_SCOPE,
  HALT_REVIEW_DEFERRED (port not called), BLOCK_LOW_CONFIDENCE, HALT_COST_CAP_BREACH (per-request +
  per-window, tokens + monetary), HALT_COMPLIANCE_BLOCK (FAIL + ESCALATE → CTO), HALT_PROVIDER_ERROR
  (emit + re-raise), ValueError on out-of-range confidence, band boundaries, R-SEC, one record per
  action, and the invariant tests (scope detect/report only; trigger/retrain op always out-of-scope;
  all success_actions are detect/report verbs).

## Doc-sync (this PR, banxe-architecture)
- `docs/adr/ADR-080-cto-data-quality-port.md` (new).
- `docs/ORG-STRUCTURE.md` §2.7.1 — `(PROPOSED)` removed on DataQualityAgent ONLY; MLPipelineAgent
  and DeployAgent remain `(PROPOSED)`.
- `INSTRUCTION-LEDGER.md` — root block `### IL-174` (append-only).
- `MEMORY.md` — sprint-48 block.
