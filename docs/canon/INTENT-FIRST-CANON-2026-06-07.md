# Universal Canon — Intent-First Banking for EMI BANXE AI BANK

Date: 2026-06-07 CEST
Status: BINDING (foundational product-concept canon; binding from this PR's merge onwards)
Scope: BANXE-only — CONCEPT ONLY (no KYC, no Notification/CRM code)
Pairs-with: docs/adr/ADR-045-intent-first-banking-architecture.md
IL-anchor: IL-122-INTENT-FIRST-CANON-2026-06-07
Source: governance build-request 2026-06-07 ("materialize the Intent-First concept as a durable governance artefact"); existing factory/operator canon (operator-canon-2026-05.md, software-factory-canon-v1.md, House rule 13).

## Purpose

Fixes, as binding canon, *what kind of system EMI BANXE AI BANK is*. This document is
the principle-level restatement of the decision recorded in ADR-045. Where ADR-045
carries context, alternatives, and consequences, this canon states the principles that
every terminal, agent, and future ADR MUST treat as immutable framing.

## Principle 1 — Intent-First / AI-agent-first

EMI BANXE AI BANK is an **Intent-First Banking** product. The **conversational intent
layer is the primary interface**, not a traditional banking app retrofitted with AI.
Clients express intent; agents fulfil it; governance constrains it. Any design that
makes a screen/form/app the primary surface and treats the conversational layer as an
optional add-on VIOLATES this canon.

## Principle 2 — Four-layer model

The system is four layers; the boundaries between them are governed.

- **L1 Intent Layer (client conversational)** — primary interface; captures, clarifies,
  and structures client intent.
- **L2 Execution Layer (agents)** — agents that fulfil intent within their autonomy
  level.
- **L3 Governance & Compliance Layer** — guardrails, audit, **Decision Lineage**, HITL
  gates, AML/KYC enforcement, **cost-policy**. Cross-cutting enforcement plane: no L2
  action touching client funds, production state, or regulated data may bypass it.
- **L4 Data & Intelligence Layer** — ledgers, datastores, analytics, inference
  substrate, intelligence services.

## Principle 3 — Factory is REQUIRED production infrastructure

All EMI BANXE AI BANK **project code** is produced through the Software Factory. The
factory is required infrastructure, not optional tooling. This canon and its paired ADR
are CONCEPT ONLY — they produce no project code.

## Principle 4 — Central produces project code ONLY through the factory

Central never mutates project repositories directly. Central produces project code only
by issuing a task to the factory; Central's direct rights are read-only diagnostics plus
governance artefacts (docs, IL, ADRs, runbooks, canon) in banxe-architecture. Restates
operator-canon-2026-05.md and House rule 13.

## Principle 5 — Terminal A builds/improves the factory itself

Terminal A (left terminal, ~/factory) owns and perfects the factory engine. Its product
is the factory.

## Principle 6 — Terminal B is NOT an exception

Terminal B operates under the SAME Intent-First concept and the SAME factory/governance
model as everything else. There is no Terminal B carve-out from Intent-First or from the
factory requirement. Temporary admin-bypasses Terminal B uses for coordination are
delivery-mechanism exceptions only; they do not exempt it from this concept or its
governance.

## Open governance gaps (future ADRs — NOT implemented here)

These are named and reserved as future work; this canon does not design them:

1. **Decision Lineage Schema / `AgentDecisionRecord`** — durable per-decision lineage
   schema for L2 agent decisions (future ADR).
2. **AI cost governance policy** — L3 cost-policy: budgets, accounting, escalation
   thresholds, config-over-hardcoding storage (future ADR; CLAUDE.md §10).
3. **S13-00 Business Process Repository** — canonical, versioned business-process
   repository anchoring L1→L2 intent translation (future ADR).

## Acceptance

- BINDING from this PR's merge commit onwards.
- ADR-045 is the decision-record pair; this document is the binding principle
  restatement. On any apparent conflict, the two are read together; neither weakens the
  other.
- The three open gaps remain OPEN; each is to be formalized as its own future ADR.

## Anchors

- docs/adr/ADR-045-intent-first-banking-architecture.md (paired ADR)
- docs/canon/operator-canon-2026-05.md
- docs/canon/software-factory-canon-v1.md, factory-project-stack-2026-05.md
- docs/canon/UNIVERSAL-CANON-FACTORY-ROLLOUT-CONSUMER-2026-06-06.md (House rule 13)
- docs/adr/ADR-040-ai-execution-policy.md (meta-plane vs inference-plane)
- .claude/rules/agents.md (HITL thresholds)
- CLAUDE.md §10 (config-over-hardcoding), §11 (production-state mutation gate)
- INSTRUCTION-LEDGER.md → IL-122-INTENT-FIRST-CANON-2026-06-07

=== END OF INTENT-FIRST CANON ===
