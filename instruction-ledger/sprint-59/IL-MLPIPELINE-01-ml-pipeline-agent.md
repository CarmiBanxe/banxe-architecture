# IL-MLPIPELINE-01: MLPipelineAgent — Tier-4 BUILD (MLSignalPort + L3 mask, mandatory DUAL CRO+CTO sign-off on apply) — FINAL agent of the org chart

- Sprint: 59
- Status: DONE
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked PR: CarmiBanxe/banxe-emi-stack#180 (branch sprint-59/ml-pipeline-agent)
- Root ledger anchor: IL-200 (expected IL-199 raced — taken by ADR-083 dYdX on main)
- Source: ORG-STRUCTURE.md §2.7.1 line 272 (MLPipelineAgent PROPOSED); line 276 I-27
- Created: 2026-06-12

## Context
ORG-STRUCTURE §2.7.1 Data & ML Engineering lists `MLPipelineAgent` (**L3**, gate
**CRO + CTO**) as the model-retraining-proposal agent. This is the **LAST** agent in the
org chart — its implementation **COMPLETES the entire ORG-STRUCTURE agent catalogue** (every
tier, Tier-1 … Tier-4, now PROPOSED → IMPLEMENTED). Port-first: a new read/propose/apply
governance port (`MLSignalPort`) plus an ADR-049 §D2 mask (`MLPipelineAgent`).

It is the **first** agent whose gated surface carries a **dual** human sign-off (CRO **and**
CTO) — the strictest mandatory-step-up invariant in the catalogue, strengthening the prior
single-token gates (Cards biometric step-up, Incident CTO+CEO, HR CEO) into a two-of-two
requirement on any model update. It fuses the AUTO-biased read/propose posture of the
statements/analytics masks with the mandatory-gate invariant of `cards_agent` /
`credit_scoring_agent`.

**Context / distinction:** the read-only signal sources EXIST — `services/ci_governance/*`
(`drift_detector.py`, `drift_metrics_exporter.py`), `services/experiment_copilot/*`,
`services/reasoning_bank/*`. `MLSignalPort` derives drift / retraining-need signals
**read-only** from these; those domains are **NOT** modified, imported for mutation, or owned.
There is **no real ML training framework** (I-10) — `InMemoryMLSignalPort` is an in-memory
handle for tests only; a real adapter fronting the live signal sources is later-sprint work.

## The regulatory invariant (I-27 — enforced in code AND test)
ORG §2.7.1 line 272 — `MLPipelineAgent | Model retraining proposals | L3 | CRO + CTO`;
line 276 — **I-27: "No autonomous model updates. All changes require CRO sign-off"**,
STRENGTHENED here to the **dual CRO + CTO** gate column.

The agent may **ONLY PROPOSE** model retraining / threshold changes. It can **NEVER** apply a
model update autonomously. `apply_model_update` commits **only** when **BOTH** a valid CRO
token AND a valid CTO token are supplied — regardless of confidence (even at confidence 1.0).
With either missing the action **HALTS** (`HALT_DUAL_SIGN_OFF_REQUIRED`), the update is
**never applied** (`MLSignalPort.apply_model_update` is never called), and it escalates to
**CRO+CTO**. The requirement is **NOT waivable by mask config** — a permissive `auto_threshold`
cannot turn it off.

Proven by tests:
- (a) apply @ confidence=1.0 with **no tokens** → HALT, escalate→CRO+CTO, apply never called;
- (b) apply with **CRO token only** → HALT (CTO missing), apply never called;
- (c) apply with **CTO token only** → HALT (CRO missing), apply never called;
- (d) apply with **both tokens** → proceeds;
- config-floor: a permissive mask (`auto_threshold=0`, `review_floor=0`) **cannot waive** the
  dual sign-off;
- port-level `DualSignOffRequired` guard fires as defence-in-depth (emit + reraise).

## Delivered
**ETAP A — port (`services/ml_pipeline/ml_signal_port.py`):**
`MLSignalPort` (`abc.ABC`):
- `get_drift_signals(model_id) -> list[DriftSignal]` — **read-only** drift / retraining-need
  signals; unknown model → `ModelNotFound`.
- `propose_retraining(model_id) -> RetrainingProposal` — **prepare only**, no token, applies
  NOTHING (a proposal is a recommendation, never a change); unknown model → `ModelNotFound`.
- `apply_model_update(proposal, cro_token, cto_token) -> ModelUpdateResult` — the **only**
  commit seam; **raises `DualSignOffRequired` without BOTH tokens** (defence-in-depth).

`InMemoryMLSignalPort` (I-10, with a transient-failure switch) + error hierarchy
`MLSignalPortError` / `ModelNotFound` / `DualSignOffRequired` / `MLSignalSourceUnavailable`
(each carries `correlation_id`). Frozen value types `DriftSignal` / `RetrainingProposal` /
`ModelUpdateResult`; enums `DriftSeverity` / `RetrainingUrgency`. **Propose free; apply NEVER
autonomous, dual-gated.**

**ETAP B — mask (`services/agents/ml_pipeline_agent.py`):**
L3 `MLPipelineAgent`, full ADR-049 §D2 gate-chain
(process_ref → scope → band → cost_cap → compliance → **dual CRO+CTO sign-off step-up** →
port call), one ADR-046 `AgentDecisionRecord` per action on every exit path; port +
`DecisionRecorder` injected as interfaces. Read/propose AUTO-eligible within cap (below-AUTO →
`HALT_REVIEW_DEFERRED`, no HITL hold); a successful proposal carries `requires_step_up` to
signal the downstream dual sign-off. compliance non-PASS → `HALT_COMPLIANCE_BLOCK` +
escalate→CRO; cost-cap breach (per-request AND per-window) → `HALT_COST_CAP_BREACH`;
below-floor confidence → `BLOCK_LOW_CONFIDENCE` (apply escalates→CRO+CTO); off-scope op →
`REJECT_OUT_OF_SCOPE` (an ungoverned autonomous apply refused); unresolved process_ref →
`HALT_UNRESOLVED_PROCESS`; `MLSignalPortError` → emit(executed=False) + reraise
(`HALT_PROVIDER_ERROR`); invalid confidence → `ValueError`.

**Shared primitive:** `services/agents/_lineage.py` **NOT** modified — the existing
`AgentOutcome.requires_step_up` / `escalated_to` fields carry the dual-sign-off gate; the 16
existing agents are untouched.

**R-SEC (ADR-021):** lineage carries opaque handles ONLY — `model_id` / `proposal_id`; never
training data, model weights, hyper-parameters, datasets, PII, or the CRO/CTO sign-off tokens
(the tokens are routed straight to the port, never recorded; a completed dual sign-off is
recorded as the opaque roles `"CRO+CTO"`). Tested.

## Proof
`banxe-emi-stack` PR **#180** — **100% coverage on BOTH new modules**
(`services/ml_pipeline/ml_signal_port.py` + `services/agents/ml_pipeline_agent.py`); full
`tests/agents/` suite green (**744 passed**, no regression); `ruff check` + `ruff format
--check` clean. PR mergeStateStatus **BLOCKED** (required review = R3) → operator authorizes
merge separately; **NOT** --admin self-merged.

## Doc-sync (this PR)
- ORG §2.7.1 `(PROPOSED)` removed on `MLPipelineAgent` only (line 272).
- Root `INSTRUCTION-LEDGER.md` block **IL-200** (append-only; expected IL-199 raced — taken by ADR-083 dYdX on main).
- `MEMORY.md` sprint-59 block.
- This companion file `instruction-ledger/sprint-59/IL-MLPIPELINE-01-ml-pipeline-agent.md`.
- NO new ADR (fits the existing §D2 mandatory-step-up mask pattern, extended to a dual sign-off).

## Milestone
**COMPLETES the ORG-STRUCTURE agent catalogue** — every agent across every tier
(Tier-1 … Tier-4) is now PROPOSED → IMPLEMENTED. The FINAL Tier-4 build and the first
dual-human-sign-off (CRO+CTO) gate; the I-27 model-governance invariant is now enforced in
code.

## Refs
ADR-049 §D2; ADR-046; ADR-021 (R-SEC); ORG §2.7.1 I-27; IL-198 HRAgent (single CEO-gate
sibling, prior LAST Tier-3); IL-196 IncidentResponseAgent (CTO+CEO dual-role step-up sibling);
`cards_agent` (mandatory biometric step-up pattern); `credit_scoring_agent` (mandatory-gate
invariant pattern).
