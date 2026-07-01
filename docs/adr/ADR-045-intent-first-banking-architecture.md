---
id: ADR-045
title: Intent-First Banking Architecture for EMI BANXE AI BANK
status: ACCEPTED
date: 2026-06-07
supersedes: []
refs:
  - "ADR-040-ai-execution-policy.md (Meta-Plane vs Inference-Plane)"
  - "ADR-039-claude-code-permissions-reclassification.md (Claude Code permissions)"
  - "../../decisions/ADR-014-composable-financial-stack.md (Composable Financial Stack)"
  - "../../decisions/ADR-018-hybrid-5-layer-ai-compute.md (Hybrid 5-layer AI Compute)"
  - "../../decisions/ADR-025-agent-interaction-canon.md (Agent Interaction Canon)"
  - "../canon/software-factory-canon-v1.md (Software Factory canon)"
  - "../canon/factory-project-stack-2026-05.md (Factory / project stack)"
  - "../canon/operator-canon-2026-05.md (Operator canon)"
  - "../canon/UNIVERSAL-CANON-FACTORY-ROLLOUT-CONSUMER-2026-06-06.md (House rule 13)"
  - "../canon/INTENT-FIRST-CANON-2026-06-07.md (paired canon restatement)"
binding_artifact: docs/canon/INTENT-FIRST-CANON-2026-06-07.md
il_anchor: IL-122-INTENT-FIRST-CANON-2026-06-07
scope: BANXE-only
---

# ADR-045: Intent-First Banking Architecture for EMI BANXE AI BANK

**Status:** Accepted
**Date:** 2026-06-07
**Source-of-determination:** YAML frontmatter `status: ACCEPTED` + body section `## Status` line `ACCEPTED — 2026-06-07`
**IL-anchor:** IL-122-INTENT-FIRST-CANON-2026-06-07
**Scope:** BANXE-only (governance artefact; CONCEPT ONLY — no KYC, Notification, or CRM code in this ADR)

## Status

ACCEPTED — 2026-06-07. Foundational product-architecture decision; paired with the
binding canon restatement `docs/canon/INTENT-FIRST-CANON-2026-06-07.md`.

## Context

EMI BANXE AI BANK has, until now, been described implicitly across many ADRs, canon
docs, and the INSTRUCTION-LEDGER as "a banking stack with AI agents bolted on". That
framing is wrong and keeps re-introducing the assumption that the product is a
traditional banking app that was later retrofitted with AI. Every downstream design
decision (interface ownership, agent autonomy, governance gates, cost policy) inherits
that assumption and drifts.

This ADR fixes the canonical framing once, in a durable form, so subsequent ADRs,
sprints, and agent passports have an unambiguous reference for *what kind of system
this is*.

The decision sits alongside, and does not replace, the existing execution-plane and
factory canon:

- **ADR-040** separates the meta-plane (Claude Code, orchestration) from the
  inference-plane (local model servers). That is *how AI runs*.
- The **Software Factory canon** (`docs/canon/software-factory-canon-v1.md`,
  `factory-project-stack-2026-05.md`, `operator-canon-2026-05.md`) defines *how project
  code is produced* — through the factory, never by direct mutation from Central.
- **This ADR** defines *what the product is*: an Intent-First Banking / AI-agent-first
  system whose primary interface is a conversational intent layer.

## Decision

### D1 — EMI BANXE AI BANK is Intent-First / AI-agent-first

EMI BANXE AI BANK is an **Intent-First Banking** product. The **conversational intent
layer is the primary interface** through which a client expresses what they want
("intent"), not a traditional banking GUI with an AI assistant added on the side. The
banking capabilities (accounts, payments, FX, compliance) are surfaced *through*
intent, fulfilled by agents, and constrained by governance — they are not the entry
point themselves.

This reframing is canonical: any design that treats a screen/form/app as the primary
surface and the conversational layer as an optional add-on contradicts this ADR.

### D2 — Four-layer reference model

The system is structured as four layers. Each layer has a distinct responsibility and
a governed boundary to the layers above and below it.

| Layer | Name | Responsibility |
|-------|------|----------------|
| L1 | **Intent Layer** (client conversational) | Captures and clarifies client intent in natural language; primary interface. Translates intent into structured, auditable requests. |
| L2 | **Execution Layer** (agents) | Agents that fulfil intent — planning, orchestration, calling ports/adapters, carrying out banking operations within their autonomy level. |
| L3 | **Governance & Compliance Layer** | Guardrails, audit trail, **Decision Lineage**, HITL gates, AML/KYC enforcement, **cost-policy**. Every L2 action of consequence passes through here. |
| L4 | **Data & Intelligence Layer** | Ledgers, datastores, analytics, model/inference substrate, feature/intelligence services feeding the layers above. |

Layer ordering is not a call stack; L3 (Governance & Compliance) is a cross-cutting
enforcement plane that intercepts L2 execution. No agent in L2 may bypass L3 for any
action that touches client funds, production state, or regulated data (consistent with
CLAUDE.md §11 and the HITL confidence thresholds in `.claude/rules/agents.md`).

### D3 — The factory remains REQUIRED production infrastructure

All **project code** for EMI BANXE AI BANK is produced through the **Software Factory**.
The factory is not optional tooling; it is the required production infrastructure for
the project codebase. This ADR records the Intent-First *concept* only — it produces no
project code itself.

### D4 — Central produces project code ONLY through the factory

Central does **not** mutate project repositories directly. Central produces project
code exclusively by issuing a task to the factory (spec-build / `claude -p` task).
Central's direct rights are read-only diagnostics plus governance artefacts (docs, IL,
ADRs, runbooks, canon) in `banxe-architecture`. This restates the standing canon
(`operator-canon-2026-05.md`, House rule 13 in
`UNIVERSAL-CANON-FACTORY-ROLLOUT-CONSUMER-2026-06-06.md`) and binds it to the
Intent-First model.

### D5 — Terminal A builds/improves the factory itself

Terminal A (the "left terminal", `~/factory`) owns and perfects the factory engine —
the canon-guardian factory, checks, fixtures, regression, templates. Terminal A's
product is the factory, not banking features.

### D6 — Terminal B operates under the SAME Intent-First concept and factory/governance model

Terminal B is **not an exception**. It produces EMI BANXE AI BANK work under the *same*
Intent-First concept, the *same* required-factory model, and the *same* governance
(HITL, Decision Lineage, cost-policy, invariants). There is no "Terminal B carve-out"
from Intent-First or from the factory requirement. Any temporary admin-bypass that
Terminal B uses for coordination (per existing IL canon-exceptions) is a *delivery
mechanism* exception only and does not exempt it from the conceptual or governance
model defined here.

### D7 — Three open governance gaps to formalize later (NOT implemented here)

The following are explicitly named as **future ADRs**. They are referenced so the
Intent-First model is complete-on-paper, but they are **not designed or implemented in
this ADR**:

1. **Decision Lineage Schema / `AgentDecisionRecord`** — a durable schema capturing,
   for every consequential L2 agent decision, the intent, the agent, the inputs, the
   confidence, the HITL outcome, and the lineage to prior decisions. (Future ADR;
   complements `.claude/rules/agents.md` HITL thresholds and
   `docs/runbooks/hitl-decision-recording.md`.)
2. **AI cost governance policy** — the L3 cost-policy: budgets, per-route/per-agent cost
   accounting, escalation thresholds, and config-over-hardcoding storage of all cost
   limits (CLAUDE.md §10). (Future ADR.)
3. **S13-00 Business Process Repository** — the canonical repository of business
   processes that intents map onto, anchoring L1→L2 translation to governed, versioned
   process definitions. (Future ADR.)

These three gaps remain OPEN after this ADR; this ADR's only obligation to them is to
name them and reserve them as future work.

## Consequences

**Positive**

+ One canonical answer to "what kind of system is this": Intent-First, AI-agent-first.
+ Future ADRs/sprints inherit a stable four-layer reference and stop re-deriving the
  framing.
+ The factory-required and Central/Terminal-role canon is bound to the product concept,
  closing the "AI bolted on" drift.
+ Three named gaps give a clear, bounded backlog of future governance ADRs.

**Negative / costs**

- This is a concept artefact: it changes framing, not code. The three open gaps must
  still be formalized before the governance layer (L3) is fully specified.
- Treating the conversational layer as primary raises the bar for L3 guardrails — every
  intent path must be governed, which is more demanding than gating a fixed set of GUI
  actions.

## Alternatives considered

- **Treat AI as an add-on to a traditional banking app** (rejected: this is the exact
  drift this ADR exists to stop; it inverts the primary interface).
- **Record the concept only as a canon doc, no ADR** (rejected: the framing is a
  decision with alternatives and consequences — it belongs in the ADR catalogue;
  paired with a canon doc for the binding-principle restatement).
- **Fold the three open gaps into this ADR** (rejected: scope; each warrants its own
  ADR with proper design. CONCEPT ONLY mandate.).

## Deployment & Activation

Operational activation is specified in
`docs/runbooks/intent-dispatcher-deployment.md` (IL-777).
This ADR remains **CONCEPT ONLY** — no operational specs here.

## Anchors

- `docs/canon/INTENT-FIRST-CANON-2026-06-07.md` — paired binding canon restatement
- ADR-040 (AI Execution Policy — meta-plane vs inference-plane)
- ADR-039 (Claude Code permissions reclassification)
- `docs/canon/software-factory-canon-v1.md`, `factory-project-stack-2026-05.md`,
  `operator-canon-2026-05.md`
- `docs/canon/UNIVERSAL-CANON-FACTORY-ROLLOUT-CONSUMER-2026-06-06.md` (House rule 13)
- `.claude/rules/agents.md` (HITL confidence thresholds; agent-chain × GSD matrix)
- CLAUDE.md §10 (config-over-hardcoding), §11 (production-state mutation gate)
- INSTRUCTION-LEDGER.md → IL-122-INTENT-FIRST-CANON-2026-06-07
