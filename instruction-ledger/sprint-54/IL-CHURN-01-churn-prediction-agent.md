# IL-CHURN-01: Customer-Operations ChurnPredictionAgent — Tier-3 BUILD (ChurnSignalPort + L1 read-only mask)

- Sprint: 54
- Status: DONE
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked PR: CarmiBanxe/banxe-emi-stack#175 (branch feat/il-188-churn-prediction-agent)
- Root ledger anchor: IL-189
- Audit ref: docs/audit/ORG-CODE-RECONCILIATION-2026-06-11.md (IL-176, verdict BUILD)
- Created: 2026-06-12

## Context
The ORG↔code reconciliation audit (IL-176) verdicted `ChurnPredictionAgent` (ORG §2.6.3
Customer Operations, L1 Auto, "At-risk customer alerts") as **BUILD** (Tier-3): unlike the
Tier-2 MASK_ONLY agents, no governed read surface for churn / at-risk signals existed, so this
needed a NEW read-only port plus a thin client-facing §D2 mask. This is the **first Tier-3
BUILD** of the audit remainder (Churn / Lead / Campaign / Incident / HR), following the
established read-only BUILD pattern of sprint-47 RiskOversight (RiskMetricsPort, IL-173) and
sprint-48 DataQuality (DataQualityPort, IL-174).

**Distinction:** ChurnSignalPort exposes **derived, read-only** at-risk signals over the
**existing** `services/customer_lifecycle/` customer-state domain (DORMANT / SUSPENDED /
inactivity). It is **not a new ML model** and writes nothing — `customer_lifecycle` is left
untouched (the production adapter that reads the lifecycle domain behind the port is a later
sprint, exactly like the analytics adapter). The mask delegates to the port's read surface only.

## Delivered
### ETAP A — Port (`services/churn/churn_signal_port.py`)
Governed READ-ONLY CONTRACT `ChurnSignalPort` (the boundary the mask `scope` allow-lists):
- `get_at_risk_customers(threshold: Decimal) -> list[AtRiskCustomer]` (highest-risk first).
- `get_churn_signals(customer_id) -> ChurnSignalSet`.
- `abc.ABC` + `InMemoryChurnSignalPort` (in-memory double for unit tests) + error hierarchy
  `ChurnSignalPortError` / `CustomerNotFound`.
- Value types (frozen): `AtRiskCustomer`, `ChurnSignalSet`, `ChurnSignal`; enums `RiskBand`,
  `ChurnSignalCode` (DORMANCY / SUSPENSION / INACTIVITY / REACTIVATION_LAPSE — mirroring the
  `CustomerState` signals the adapter reads behind the port).
- **READ-ONLY invariant at the contract level:** the port has NO mutate / trigger / retention /
  write method at all (I-10: no fake integrations; I-27: no autonomous customer-state change).
- I-01: every numeric field (risk_score, signal weight, threshold) is `Decimal`, never float.
- R-SEC: only opaque handles (`customer_id` / `cohort`) cross the boundary — no raw PII.

### ETAP B — Mask (`services/agents/churn_prediction_agent.py`)
L1-Auto `ChurnPredictionAgent` in front of `ChurnSignalPort`:
- Actions: `report_at_risk_customers` (→ `get_at_risk_customers`) and `get_churn_signals`
  (→ `get_churn_signals`). Both AUTO reads; below-AUTO → HALT_REVIEW_DEFERRED.
- Full ADR-049 §D2 gate-chain (process_ref → scope → band → cost_cap → compliance(PII) → port),
  one ADR-046 `AgentDecisionRecord` per action on every exit path; port + recorder injected.
- **INVARIANT (L1 read-only, tested):** detection/reporting only — never modifies customer
  state or triggers a retention action. Enforced three ways: (1) mask scope = the 2 read ops
  only; (2) the port has no mutate method; (3) success_actions are DETECT_/REPORT_ verbs only.
  Any write/retention-trigger op is REJECT_OUT_OF_SCOPE. Compliance non-PASS → BLOCK +
  escalate→DPO.
- Provider-error: `ChurnSignalPortError` (incl. `CustomerNotFound`) → emit(executed=False) +
  re-raise. R-SEC: only opaque handles (customer_id / cohort) in lineage — never risk scores,
  signal weights, or PII; the `list[AtRiskCustomer]` / `ChurnSignalSet` ride on
  `AgentOutcome.result`.

### Domain reused (untouched)
`services/customer_lifecycle/{fsm,lifecycle_agent,lifecycle_engine,lifecycle_models,lifecycle_observer}.py`
— read-only reference for the derivation; not modified.

## Tests & proof
- `tests/test_churn/test_churn_signal_port.py` + `tests/agents/test_churn_prediction_agent.py`
  — 43 tests, **100% coverage on BOTH new modules**.
- Covers: AUTO happy path, HALT_UNRESOLVED_PROCESS, REJECT_OUT_OF_SCOPE (write/retention
  refused), HALT_REVIEW_DEFERRED (port not called), BLOCK_LOW_CONFIDENCE, HALT_COST_CAP_BREACH
  (per-request + per-window), HALT_COMPLIANCE_BLOCK, HALT_PROVIDER_ERROR (emit+reraise),
  invalid confidence → ValueError, R-SEC (no scores/PII in lineage), ADR-046 (1 record/action),
  read-only INVARIANT (no customer-state mutation).
- Full suite: **10853 passed / 37 skipped / 0 failed**; `ruff check` + `ruff format --check` clean.

## Doc-sync (this PR)
- ORG §2.6.3: `(PROPOSED)` removed on `ChurnPredictionAgent` only.
- Root `INSTRUCTION-LEDGER.md`: new `### IL-189` block (append-only over main, I-28; renumbered from IL-188 after main raced and took IL-188).
- `MEMORY.md`: sprint-54 block.
- NO new ADR — fits the existing L1 read-only ADR-049 §D2 pattern (as with RiskOversight /
  DataQuality).

## Refs
ADR-049 §D2; ADR-046; ADR-016 (PII overlay); audit IL-176 (BUILD); sprint-47 RiskOversight
(IL-173); sprint-48 DataQuality (IL-174).
