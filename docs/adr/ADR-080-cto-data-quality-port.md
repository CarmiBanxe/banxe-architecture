---
id: ADR-080
title: CTO DataQualityPort (read-only) + DataQualityAgent for EMI BANXE AI BANK
status: ACCEPTED
date: 2026-06-11
accepted: 2026-06-11
supersedes: []
related:
  - "ADR-049-intent-layer-client-facing-agent-masks.md (the §D2 gate-chain the agent enforces)"
  - "ADR-046-decision-lineage-schema.md (one AgentDecisionRecord per masked action)"
  - "ADR-047-ai-cost-governance-policy.md (cost_cap + AUTO/REVIEW/BLOCK bands)"
  - "ADR-079-cro-risk-metrics-port.md (sibling read-only-port-first pattern, sprint-47)"
  - "ADR-056-ledger-coupling-gate.md (this ADR ships with an IL block)"
binding_artifact: null
il_anchor: IL-174-CTO-DATA-QUALITY-PORT-2026-06-11
scope: BANXE-only
concept_only: false
---

# ADR-080: CTO DataQualityPort (read-only) + DataQualityAgent

**Status:** ACCEPTED — 2026-06-11
**Sprint:** 48 / IL-174 (companion: instruction-ledger/sprint-48/IL-DQ-01-data-quality.md)

## Context

ORG-STRUCTURE §2.7.1 (CTO / AI Platform, SMF26 — Data & ML Engineering) defines
`DataQualityAgent` — *Data drift detection* — at **L1 Auto, no gate**. Unlike its §2.7.1
siblings, it carries no contradiction: `MLPipelineAgent` (model retraining proposals) is **L3
(CRO + CTO)** and `FeedbackLoopAnalyser` (threshold proposals) is **L3 (CRO must approve)** — both
gated by **I-27 (no autonomous model updates; all changes require CRO sign-off)**. The
DataQualityAgent is the section's only L1-Auto read row: it **detects and reports** data-quality /
drift signals; it does not decide or act on them. As with the ADR-078/ADR-079 CFO/CRO agents,
the ADR-049 §D2 mask needs an injectable port — none exists — so this ADR adds one, port-first.

This sprint builds **only** DataQualityAgent. `DeployAgent` (§2.7.2, L2/L3, CTO-gated) and
`MLPipelineAgent` (§2.7.1, I-27) are explicitly **deferred** to later sprints.

## Decision

### D1 — DataQualityPort (read-only CONTRACT)

A new read-only hexagonal port `services/data_quality/data_quality_port.py` (abc.ABC + InMemory
impl + `DataQualityPortError`), mirroring the LedgerPort/AnalyticsPort/RiskMetricsPort shape.
Numeric quality metrics are `Decimal` (I-01). Read methods only:
- `get_drift_score(dataset)` → per-dataset drift signal,
- `get_quality_report(dataset)` → null-rate, schema-conformance, freshness, drift,
- `list_datasets()`, `get_freshness(dataset)`.

- **DOES:** read / detect / report data-quality and drift signals.
- **DOES NOT:** mutate data, trigger pipeline runs, or update/retrain models — there is **no**
  mutate/trigger/retrain method on the port at all. This keeps the agent compatible with **I-27**
  (no autonomous model updates) and **I-10** (no fake integrations: live data-quality adapters —
  the `services/risk_management`/pipeline/monitoring stacks — are out of scope; only an InMemory
  test impl ships here).

### D2 — DataQualityAgent (consumer, built in banxe-emi-stack this sprint)

`services/agents/data_quality_agent.py` — L1-Auto, enforces the full ADR-049 §D2 gate-chain
(process_ref → scope → band → cost_cap → compliance(DATA_QUALITY) → port), emits one ADR-046
`AgentDecisionRecord` per action, port + recorder injected. Below-AUTO read → HALT_REVIEW_DEFERRED
(no HITL hold, no step-up — L1). Compliance non-PASS → BLOCK + escalate to CTO. **Invariant
(enforced in code + test):** the mask scope allow-list contains only the four read ops; no
retrain / pipeline-trigger / data-write op is reachable (any such op is refused as out-of-scope).
R-SEC: only opaque handles (dataset names) reach a lineage record — never metric values or PII.

## Boundaries (explicit)

Detection / reporting only. The agent never mutates data, triggers a pipeline, retrains or updates
a model, or records a decision verdict. It is a governed *view* over data-quality signals; any
consequential action (retraining, threshold change) stays with the L3/I-27 agents
(`MLPipelineAgent`, `FeedbackLoopAnalyser`) under CRO sign-off.

## Consequences

**Positive:** unblocks the CTO data-quality agent on a no-fake-integration read-only surface;
preserves the I-27 boundary (the L1 detector cannot trigger model updates); consistent with the
ADR-078/079 port-first pattern. **Negative / costs:** one more contract to maintain; live
data-quality adapters remain unbuilt (InMemory only); the DATA_QUALITY overlay + CTO escalation
role are config-as-data on the mask and must stay aligned with §2.7.1.

## Alternatives considered

- **Bind the agent to the live data/ML pipeline stack** — rejected: those are
  trigger/retrain/write surfaces; coupling an L1 detector to them would breach I-27 and the
  no-act boundary.
- **Fold drift detection into MLPipelineAgent (L3)** — rejected: §2.7.1 explicitly separates the
  L1-Auto detector from the L3 retraining-proposal agent; detection ≠ decision.
- **Defer until live data-quality adapters exist** — rejected: port-first lets the governed
  read-only agent + contract land now (I-10-safe), with live adapters as a later swap.
