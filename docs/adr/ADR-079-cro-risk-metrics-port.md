---
id: ADR-079
title: CRO RiskMetricsPort (read-only) + RiskOversightAgent L1/L3 resolution for EMI BANXE AI BANK
status: ACCEPTED
date: 2026-06-11
accepted: 2026-06-11
supersedes: []
related:
  - "ADR-049-intent-layer-client-facing-agent-masks.md (the §D2 gate-chain the agent enforces)"
  - "ADR-046-decision-lineage-schema.md (one AgentDecisionRecord per masked action)"
  - "ADR-047-ai-cost-governance-policy.md (cost_cap + AUTO/REVIEW/BLOCK bands)"
  - "ADR-078-cfo-treasury-forecast-ports.md (sibling read-only-port-first pattern)"
  - "ADR-056-ledger-coupling-gate.md (this ADR ships with an IL block)"
binding_artifact: null
il_anchor: IL-173-CRO-RISK-METRICS-PORT-2026-06-11
scope: BANXE-only
concept_only: false
---

# ADR-079: CRO RiskMetricsPort (read-only) + RiskOversightAgent L1/L3 resolution

**Status:** ACCEPTED — 2026-06-11
**Sprint:** 47 / IL-173 (companion: instruction-ledger/sprint-47/IL-RISK-01-risk-oversight.md)

## Context

ORG-STRUCTURE §2.2 defines the CRO (SMF4) AI agent `RiskOversightAgent`, but the section is
**self-contradictory** on its autonomy:

- The CRO **header** says: *Trust Zone 🔴 RED · Autonomy: L3 — CRO sign-off required* (and
  EU AI Act Art.14 meaningful human oversight).
- The CRO **agent table** row says: `RiskOversightAgent | Risk dashboard | L1 Auto | CRO gate? No`.

A read-only "risk dashboard" agent at L1-Auto cannot simultaneously require L3 CRO sign-off on
every action. The contradiction must be resolved before the agent can be built (the ADR-049 §D2
mask needs an unambiguous autonomy band).

## Decision

### D1 — L1/L3 contradiction resolution (operator-approved)

`RiskOversightAgent` is an **L1-Auto, read-only DASHBOARD** agent: it aggregates and presents
risk metrics only. It **MUST NOT** approve models, change thresholds, or make any risk decision.

The **L3-RED / "CRO sign-off required" posture in the header applies to the CRO FUNCTION as a
whole** — specifically the §2.2 responsibilities that ARE consequential decisions: *AI model
risk assessment before production deployment*, *threshold approval for fraud/AML models*, and
material-risk Board escalation. Those remain **L3, human CRO** (or other agents gated on CRO
sign-off, e.g. `AMLPipelineAgent` "on threshold change"). The read-only dashboard agent is the
§2.2 table's explicit `L1 Auto / No` row and is not a decision surface.

This is consistent with the table's other rows (`FraudScoringAgent` L1 Auto "monitoring only";
decision-bearing agents L2/L3 gated): **monitoring/read = low autonomy; decision = L3.** The
dashboard reads; it never decides.

### D2 — RiskMetricsPort (read-only CONTRACT)

A new read-only hexagonal port `services/risk/risk_metrics_port.py` (abc.ABC + InMemory impl +
`RiskMetricsPortError`), mirroring the LedgerPort/AnalyticsPort/recon-port shape. Monetary values
are `Decimal` (I-01). It exposes read methods only — aggregate exposure, fraud/AML monitoring
counters, Consumer Duty (PS22/9) outcome signals, and a combined dashboard view.

- **DOES:** read/aggregate risk metrics for the dashboard.
- **DOES NOT:** change thresholds, approve models, write, or mutate anything — there is **no**
  mutating/approve/threshold method on the port at all. Live integrations (the
  `services/risk_management/*` engines, fraud/AML pipelines, Consumer Duty services) are out of
  scope; only an InMemory test impl ships here. Fabricating live integrations would violate I-10.

### D3 — RiskOversightAgent (consumer, built in banxe-emi-stack this sprint)

`services/agents/risk_oversight_agent.py` — L1-Auto, enforces the full ADR-049 §D2 gate-chain
(process_ref → scope → band → cost_cap → compliance(RISK_DATA) → port), emits one ADR-046
`AgentDecisionRecord` per action, port + recorder injected. **Invariant (enforced in code +
test):** the mask scope allow-list contains only the four read ops; no approve/threshold/decision
op is reachable (any such op is refused as out-of-scope). R-SEC: only opaque handles reach a
lineage record — never metric values or PII.

## Boundaries (explicit)

Read + aggregate only. The agent never moves money, changes a threshold, approves a model, or
records a decision verdict. It is a governed *view* over risk metrics; all consequential CRO
decisions remain L3 / human CRO (ADR-049 §D6 human-oversight posture; EU AI Act Art.14).

## Consequences

**Positive:** resolves the §2.2 header-vs-table contradiction in canon; unblocks the CRO
dashboard agent on a no-fake-integration read-only surface; keeps model/threshold approval firmly
L3/human. **Negative / costs:** one more contract to maintain; live risk-metric adapters remain
unbuilt (InMemory only); the RISK_DATA overlay + CRO escalation role are config-as-data on the
mask and must stay aligned with §2.2.

## Alternatives considered

- **Take the header literally (L3 on the dashboard)** — rejected: an L3 sign-off on every
  read-only dashboard view contradicts the table's explicit `L1 Auto / No` and the
  monitoring-is-low-autonomy pattern; it would also make a passive view a decision surface.
- **Bind the agent to `services/risk_management/*` engines** — rejected: those are decision/
  scoring/threshold engines, not a read-only metrics CONTRACT; coupling a read mask to them blurs
  the no-decide boundary.
- **Defer until live risk adapters exist** — rejected: port-first lets the governed read-only
  agent + contract land now (I-10-safe), with live adapters as a later swap.
