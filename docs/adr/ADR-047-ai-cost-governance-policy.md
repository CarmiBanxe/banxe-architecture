---
id: ADR-047
title: AI Cost Governance Policy (per-agent budgets & cost caps) for EMI BANXE AI BANK
status: ACCEPTED
date: 2026-06-07
accepted: 2026-06-07
supersedes: []
related:
  - "ADR-045-intent-first-banking-architecture.md (Intent-First Banking — L3 Governance layer; names this as future ADR D7.2)"
  - "ADR-046-decision-lineage-schema.md (Decision Lineage Schema — cost recorded as a lineage field)"
  - "ADR-043-aider-routes.md (LiteLLM routes — the enforcement seam for rate/cost limits)"
  - "ADR-040-ai-execution-policy.md (AI Execution Policy — meta-plane vs inference-plane)"
  - "../../decisions/ADR-016-ai-plane-pii-aml-routing.md (AI Plane / PII-AML routing)"
binding_artifact: null
il_anchor: IL-124-AI-COST-GOVERNANCE-POLICY-2026-06-07
scope: BANXE-only
concept_only: true
---

# ADR-047: AI Cost Governance Policy (per-agent budgets & cost caps) for EMI BANXE AI BANK

**Status:** Proposed
**Date:** 2026-06-07
**Source-of-determination:** YAML frontmatter `status: PROPOSED` + body section `## Status` line `PROPOSED — 2026-06-07`
**IL-anchor:** IL-124-AI-COST-GOVERNANCE-POLICY-2026-06-07
**Scope:** BANXE-only (governance artefact; POLICY / FRAMEWORK ONLY — no config files, gateway rules, or agent code in this ADR)

## Status

PROPOSED — 2026-06-07. **Second** of the three future ADRs named in ADR-045 §D7
(after ADR-046 Decision Lineage Schema, which closed §D7.1). This ADR specifies the
**cost-governance policy and its enforcement points**; it does not author the LiteLLM
gateway config, the per-agent budget values, the circuit-breaker thresholds, or any
agent code. Those are config-as-data and follow in a dedicated factory sprint once this
policy is ACCEPTED.

## Context

ADR-045 reframed EMI BANXE AI BANK as an **Intent-First / AI-agent-first** banking
product whose **L2 Execution Layer** is a population of autonomous agents (the 10 HITL
agents of `.claude/rules/agents.md` plus client-facing conversational agents) and whose
**L3 Governance & Compliance Layer** is a cross-cutting enforcement plane intercepting
every consequential L2 action. ADR-045 §D7 named three open governance gaps to be
formalized as future ADRs; the **second** of those is the **AI cost governance policy**
(§D7.2). This ADR closes that gap at the policy level.

Why this gap must be formalized:

- **Autonomous agents fail by spending.** The dominant operational risk of agent-first
  systems is not a single bad answer but **uncontrolled token / cost spend** — a looping
  agent that re-invokes inference indefinitely, a retry storm, or a fan-out that never
  terminates. The industry has a documented worst case: an agent that ran up roughly
  **$30,000 of inference spend in ~6 hours** before anyone noticed. For a regulated EMI
  running agents against client funds and production state, an unbounded-spend incident
  is simultaneously a **cost event, an availability event (DORA 2026 operational
  resilience), and a control-failure event** an auditor will ask about.
- **BANXE already has PARTIAL cost governance, not a policy.** Two mechanisms exist today
  but were never unified into a stated governance policy:
  1. **LiteLLM gateway route limits.** All agent inference is routed through the LiteLLM
     gateway aliases of ADR-043 (`ai` / `ai-heavy` / `reasoning`, and the factory/project
     route families of `.claude/rules/agents.md`). LiteLLM already supports per-key /
     per-route rate limits (RPM/TPM) and budget ceilings — a partial, infrastructure-level
     guardrail.
  2. **Per-agent passport baseline.** Each agent passport in `docs/canon/passports/*.yaml`
     already binds an agent to its `litellm_routes`, a `risk_ceiling` (LOW/MEDIUM/HIGH),
     and a `gate_authority` (none/auto/operator/mlro/ctio). This is the natural per-agent
     unit on which a budget belongs — but the passport schema (`schema.yaml`) carries **no
     budget or cost-cap field today**.
  These are real controls, but they are scattered, implicit, and not expressed as a
  governance policy with hard caps, loop detection, breach escalation, and cost
  attribution. ADR-045 L3 requires the policy; this ADR states it.
- **Config-over-hardcoding (CLAUDE.md §10).** Every budget, cap, window, and threshold in
  this policy is a **governance parameter** and MUST live in repo configuration (as data),
  not in code and not in this ADR. This ADR fixes the *framework and the field set*; the
  *values* are deferred to config produced by the factory sprint.
- **Cost is a lineage field.** ADR-046's `AgentDecisionRecord` is the per-decision audit
  receipt. Cost attribution belongs there: this ADR ties cost accounting to ADR-046 so
  that "what did this decision cost, and did it breach budget?" is answerable from the
  same lineage row an FCA/DORA audit already reads.

This ADR is **POLICY / FRAMEWORK ONLY**: it defines the budget unit, the cap dimensions,
the loop/circuit-breaker doctrine, the breach-escalation path, the cost-attribution
fields, and the enforcement seams. It does not implement them.

## Decision

### D1 — Budget unit: the agent passport

The **unit of cost governance is the agent passport** (`docs/canon/passports/*.yaml`).
Every L2 agent — the 10 HITL agents of `.claude/rules/agents.md` (incl. `mlro_agent`,
`aml_check_agent`, `sanctions_check_agent`) **and** client-facing conversational agents
(L1→L2 surface) — MUST have an associated **cost budget** declared as passport data. The
passport schema (`schema.yaml`) is extended (in the implementation sprint, non-breaking
additive) with a `cost_budget` block. No agent runs inference without a declared budget;
an agent with no budget is, for governance purposes, ungoverned and MUST NOT be promoted
past dev (ADR-045 L3 / CLAUDE.md §11 promotion gate).

The existing passport `risk_ceiling` (LOW/MEDIUM/HIGH) and `litellm_routes` are the
**baseline this policy formalizes**: budget magnitude scales with `risk_ceiling`, and the
enforcement binds to the agent's declared `litellm_routes`.

### D2 — Cap dimensions: per-request and per-time-window, token AND cost

The policy defines **hard caps** on two axes, each expressed in BOTH a token dimension
and a monetary (cost) dimension so neither a cheap-but-infinite loop nor a single
expensive call can escape:

| Cap | Scope | Dimensions | Semantics |
|-----|-------|-----------|-----------|
| **Per-request cap** | one agent invocation / decision | max tokens (in+out) AND max cost | A single inference request that would exceed either ceiling is **refused at the gateway** before completion. Bounds the blast radius of one runaway call. |
| **Per-window cap** | one agent, rolling time window (e.g. per-minute, per-hour, per-day) | max tokens AND max cost per window | The agent's **budget** over a window. Breach triggers the circuit-breaker (D3) and escalation (D4). Windows are config-as-data. |

Caps are **hard** (a breach blocks/halts, it does not merely warn), consistent with
CLAUDE.md §11 (production-state / client-funds mutation gate) and the FCA-grade posture
of an EMI. The **values** of every cap and window length are config-as-data (CLAUDE.md
§10), deferred to the implementation sprint; this ADR fixes only the *dimensions and the
hard-cap doctrine*.

### D3 — Loop detection & circuit-breaker on runaway agents

The policy mandates a **circuit-breaker** that trips on runaway behaviour before a budget
is fully drained. Trip signals (config-as-data thresholds):

- **Per-window budget breach** (D2) — token or cost ceiling for the window reached.
- **Loop / runaway heuristics** — repeated near-identical requests from one agent in a
  short window, request count per `correlation_id` exceeding a ceiling, or unbounded
  self-fan-out (an agent spawning successors without converging).
- **Velocity** — request or token rate exceeding the agent's `litellm_routes` rate-limit
  envelope.

On trip, the breaker **halts further inference for that agent** (open state), emits a
breach event, and routes to escalation (D4). Recovery from open→half-open→closed follows
a config-as-data cooldown; recovery for an agent above a `risk_ceiling` threshold or in a
compliance contour (payment/AML/KYC/safeguarding) requires **human (HITL) reset**, never
automatic, per CLAUDE.md §11 and the HITL doctrine of `.claude/rules/agents.md`.

### D4 — Escalation / HITL trigger on budget breach

A budget breach or breaker trip is a **governance event**, not a silent throttle. The
escalation path reuses the existing HITL machinery of `.claude/rules/agents.md`:

- **Breach → BLOCK-equivalent halt** for the affected agent, with notification to the
  dublёr (MLRO / CEO) via the existing alert routing (ADR-033) — same operator-notify
  path as a `<70%` confidence BLOCK.
- **No silent budget extension.** A budget is not raised to clear a breach automatically;
  any increase is a governance change (passport edit + IL/ADR anchor), human-approved,
  config-as-data — never a code or runtime override.
- **Compliance-contour breaches** (payment, AML, KYC, safeguarding) are treated at the
  highest severity: halt + mandatory human reset, consistent with the compliance-change
  chain B of `.claude/rules/agents.md` (Ruflo mandatory) and CLAUDE.md §11.

### D5 — Cost attribution recorded (tie to ADR-046 AgentDecisionRecord)

Cost is **attributed and recorded per decision**, reusing the ADR-046 lineage row rather
than a parallel store. ADR-046's `AgentDecisionRecord` is extended (implementation
sprint, additive, non-breaking) with cost fields. Logical field set introduced by this
policy:

| Field | Type (logical) | Null? | Semantics |
|-------|----------------|-------|-----------|
| `cost_tokens_input` | UInt32 | NO | Input/prompt tokens consumed by the decision's inference. |
| `cost_tokens_output` | UInt32 | NO | Output/completion tokens generated. |
| `cost_amount` | Decimal | NO | Monetary cost of the decision's inference, in the reporting currency. **Decimal, never float** (CLAUDE.md money rule). |
| `cost_currency` | String | NO | ISO currency of `cost_amount` (e.g. `GBP`/`USD`), config-as-data default. |
| `litellm_route` | String | NO | The LiteLLM route/alias that served the inference (ADR-043) — the enforcement seam that metered this cost. |
| `budget_window_ref` | String | NO | Reference to the per-window budget bucket this decision counted against (agent + window id). |
| `budget_breach_flag` | Enum(`NONE`,`WARN`,`BREACH`) | NO | Whether this decision crossed a cap: `NONE` within budget, `WARN` within a configured soft band, `BREACH` over a hard cap (D2) — itself an auditable fact tied to the breaker trip (D3). |

`correlation_id` (already in ADR-046) ties per-decision cost into the aggregate that the
per-window cap (D2) and breaker (D3) evaluate. This makes cost a **first-class lineage
field**: an FCA/DORA query of "what did this transaction's agent decisions cost, and did
any breach budget?" resolves from the same `AgentDecisionRecord` rows decision lineage
already reads.

### D6 — Enforcement seams

The policy names two enforcement seams and where each control lives:

1. **LiteLLM gateway (primary, infrastructure seam).** All agent inference is metered and
   capped here. Per-request caps (D2), per-route/per-key rate and budget limits, and the
   token/cost metering that feeds cost attribution (D5) are enforced at the gateway. This
   formalizes the existing LiteLLM rate-limit mechanism (ADR-043) as the canonical
   metering and hard-cap point.
2. **Passport + L3 governance plane (policy seam).** The per-agent budget (D1), the
   circuit-breaker doctrine (D3), and the escalation path (D4) are expressed as passport
   data and enforced by the L3 plane (ADR-045 §D2). L3 treats "within budget / breaker
   closed" as a **precondition for a consequential L2 action to proceed**, the same way it
   treats the decision-lineage receipt (ADR-046 D4).

### D7 — Policy-only scope; no implementation here

This ADR defines the policy and its enforcement points only. The passport `cost_budget`
schema extension, the concrete budget/cap/window **values**, the LiteLLM gateway limit
config, the loop-detection thresholds, the breaker state machine, the ADR-046 cost-field
migration, and any agent-side instrumentation are **deferred to a dedicated factory
sprint** and produced through the Software Factory (ADR-045 §D3/§D4 — Central does not
mutate project code directly). No config file or migration is authored in this ADR.

## Consequences

**Positive**

+ Closes the second of ADR-045's three named L3 governance gaps (§D7.2) at the policy
  level.
+ Converts BANXE's PARTIAL, scattered cost controls (LiteLLM route limits + passport
  `risk_ceiling`/`litellm_routes`) into a single stated policy with hard caps, loop
  detection, breach escalation, and cost attribution.
+ Directly addresses the documented agent-first failure mode (runaway-spend, e.g. the
  ~$30K/6h incident) with a hard per-window cap + circuit-breaker rather than a soft
  alert.
+ Makes cost a first-class lineage field by reusing ADR-046 — no parallel cost store; one
  audit row answers both "why" and "what did it cost / did it breach".
+ Keeps every governance parameter as config-as-data (CLAUDE.md §10) and every breach
  escalation human-gated (CLAUDE.md §11), satisfying FCA/DORA 2026 operational-resilience
  expectations.

**Negative / costs**

- This is a policy artefact: it changes nothing until the implementation sprint extends
  the passport schema, wires LiteLLM caps, and instruments agents. Until then, cost
  governance remains the existing PARTIAL state.
- Hard per-request and per-window caps introduce a real failure mode: a legitimate
  long-running agent task can be halted by a cap. The implementation sprint must size
  budgets per `risk_ceiling` carefully and provide a human-approved (not automatic)
  budget-raise path (D4).
- Per-decision cost metering and the `budget_breach_flag` evaluation add write/compute
  cost on the L2 hot path and storage to the ADR-046 row; the sprint must size LiteLLM
  metering and ClickHouse ingestion accordingly.
- Loop-detection heuristics carry false-positive risk (a legitimately iterative agent
  tripped as "runaway"); thresholds are config-as-data and must be tuned.

## Alternatives considered

- **Rely on existing LiteLLM route rate-limits alone, no policy** (rejected: rate-limits
  cap velocity, not cumulative per-agent budget; they have no loop-detection, no breach
  escalation to HITL, and no cost attribution into decision lineage. That is the PARTIAL
  state this ADR exists to close).
- **Soft alerts / budget warnings only, no hard caps** (rejected: the ~$30K/6h failure
  mode is precisely the case where an alert fires and no one acts in time. For a regulated
  EMI touching client funds, the cap must be hard and halt — CLAUDE.md §11).
- **Global gateway-wide budget instead of per-agent** (rejected: a single global ceiling
  cannot attribute spend, cannot isolate one runaway agent, and trips for everyone at
  once. The passport is the natural per-agent unit that also carries `risk_ceiling` to
  scale the budget).
- **A separate cost-accounting store decoupled from decision lineage** (rejected: defeats
  ADR-046's purpose; a duplicate store re-introduces the log-archaeology problem for the
  question "what did this decision cost?". Cost is an additive field on the existing
  lineage row).
- **Fold cost policy into ADR-046** (rejected: ADR-045 §D7 explicitly reserved the cost
  policy as an independent sibling with its own alternatives; the lineage *schema* and the
  cost *policy* are separate decisions, kept separable).
- **Hardcode budget/cap values in this ADR or in agent code** (rejected: CLAUDE.md §10
  config-over-hardcoding — all thresholds are governance parameters stored as repo config,
  not in code or in canon docs).

## Relationship to ADR-045 L3, ADR-046, and the enforcement seams

- **ADR-045 §D2 (L3 Governance & Compliance Layer)** lists **cost-policy** as a first-class
  L3 responsibility and §D7.2 names this exact policy as the second future ADR. ADR-047
  *is* that ADR: it supplies the concrete budget/cap/breaker/escalation/attribution policy
  the L3 layer enforces, and L3 treats "within budget / breaker closed" as a precondition
  for a consequential L2 action (parallel to the ADR-046 lineage-receipt precondition).
- **ADR-046 (Decision Lineage Schema)** is the carrier for cost attribution (D5): the cost
  fields are additive, non-breaking extensions to `AgentDecisionRecord`, sharing its
  `correlation_id` so per-decision cost aggregates into the per-window budget the breaker
  evaluates.
- **ADR-043 (LiteLLM / Aider routes)** is the **enforcement seam**: the gateway is where
  inference is metered and hard-capped, and the existing route rate-limits are the
  baseline this policy formalizes into a complete cost governance.
- **The passport baseline** (`docs/canon/passports/*.yaml` + `schema.yaml`): `litellm_routes`,
  `risk_ceiling`, and `gate_authority` are the existing per-agent fields this policy builds
  the `cost_budget` block onto.
- **`.claude/rules/agents.md` HITL thresholds** (AUTO/REVIEW/BLOCK) and **ADR-033 alert
  routing** supply the escalation machinery a budget breach reuses (D4).
- **`R-COMP-FCA-02`** (continuous-compliance / agentic-AI auditability) and **DORA 2026
  operational-resilience** are the regulatory drivers — runaway spend is an availability
  and control-failure event, not only a cost event.

## Sibling future ADRs (still pending, per ADR-045 §D7)

This ADR closes gap **D7.2** only. With ADR-046 (D7.1, Decision Lineage Schema) already
PROPOSED, the **one remaining** named gap stays OPEN as a separate future ADR:

- **D7.3 — S13-00 Business Process Repository** (the canonical, versioned repository of
  business processes that client intents map onto; anchors the L1→L2 translation). PENDING
  — the last of the three ADR-045 §D7 siblings.

## Anchors

- ADR-045 (Intent-First Banking — §D2 L3 Governance & cost-policy; §D7.2 names this ADR)
- ADR-046 (`docs/adr/ADR-046-decision-lineage-schema.md` — `AgentDecisionRecord`; cost as additive lineage fields)
- ADR-043 (`docs/adr/ADR-043-aider-routes.md` — LiteLLM routes; enforcement seam / rate-limit baseline)
- ADR-040 (`docs/adr/ADR-040-ai-execution-policy.md` — meta-plane vs inference-plane)
- ADR-033 (`decisions/ADR-033-alert-routing-strategy.md` — operator/dublёr alert routing for breach escalation)
- ADR-016 (`decisions/ADR-016-ai-plane-pii-aml-routing.md` — AI plane routing)
- `docs/canon/passports/*.yaml` + `docs/canon/passports/schema.yaml` (per-agent baseline: `litellm_routes`, `risk_ceiling`, `gate_authority`; `cost_budget` extension)
- `.claude/rules/agents.md` (10 HITL agents; AUTO/REVIEW/BLOCK thresholds; compliance chain B)
- `R-COMP-FCA-02` (continuous-compliance / agentic-AI auditability); DORA 2026 (operational resilience)
- CLAUDE.md §10 (config-over-hardcoding — all budgets/caps/windows in config), §11 (production-state / client-funds mutation gate), money rule (Decimal, never float)
- INSTRUCTION-LEDGER.md → IL-124-AI-COST-GOVERNANCE-POLICY-2026-06-07
