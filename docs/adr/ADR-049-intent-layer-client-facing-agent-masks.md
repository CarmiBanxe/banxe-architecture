---
id: ADR-049
title: Intent Layer & Client-Facing Agent Masks (L1 specification & the L1→L2 client surface) for EMI BANXE AI BANK
status: PROPOSED
date: 2026-06-07
supersedes: []
related:
  - "ADR-045-intent-first-banking-architecture.md (Intent-First Banking — defines L1 Intent Layer & the four-layer model; this ADR specifies HOW L1 intents surface as governed L2 agent actions)"
  - "ADR-046-decision-lineage-schema.md (Decision Lineage Schema — every masked action emits an AgentDecisionRecord)"
  - "ADR-047-ai-cost-governance-policy.md (AI Cost Governance Policy — every mask carries a cost-cap; AUTO/REVIEW/BLOCK reused)"
  - "ADR-048-business-process-repository.md (Business Process Repository — intents resolve to a governed process_ref before dispatch)"
  - "../../decisions/ADR-025-agent-interaction-canon.md (Agent Interaction Canon)"
  - "../../decisions/ADR-016-ai-plane-pii-aml-routing.md (AI Plane / PII-AML routing)"
binding_artifact: null
il_anchor: IL-126-INTENT-LAYER-CLIENT-MASKS-2026-06-07
scope: BANXE-only
concept_only: true
---

# ADR-049: Intent Layer & Client-Facing Agent Masks (L1 specification & the L1→L2 client surface) for EMI BANXE AI BANK

**Status:** Proposed
**Date:** 2026-06-07
**Source-of-determination:** YAML frontmatter `status: PROPOSED` + body section `## Status` line `PROPOSED — 2026-06-07`
**IL-anchor:** IL-126-INTENT-LAYER-CLIENT-MASKS-2026-06-07
**Scope:** BANXE-only (governance artefact; SPECIFICATION / CONTRACT ONLY — no agent, UI, routing, or port-binding code in this ADR)

## Status

PROPOSED — 2026-06-07. This ADR **specifies the L1 Intent Layer and the L1→L2 client
surface** that ADR-045 defined but left unspecified. ADR-045 named L1 (the conversational
intent layer, the primary interface) and the four-layer model; its three §D7 siblings
(ADR-046 Decision Lineage, ADR-047 AI Cost Governance, ADR-048 Business Process
Repository) supplied the L3 governance machinery. None of them say **HOW a client intent
becomes a bounded agent action, nor which agents are client-facing.** This ADR fixes that
seam. It is **SPECIFICATION / CONTRACT ONLY**: it defines the intent-resolution contract
and the client-facing agent **masks**; it does **not** implement agents, UI, or routing —
those defer to a factory build sprint (see §D7).

## Context

ADR-045 reframed EMI BANXE AI BANK as **Intent-First / AI-agent-first**: the
**conversational intent layer (L1) is the primary interface**, not a banking GUI with an
AI assistant bolted on. Its four-layer model — **L1 Intent**, **L2 Execution** (agents),
**L3 Governance & Compliance**, **L4 Data & Intelligence** — names L1 as "captures and
clarifies client intent in natural language; translates intent into structured, auditable
requests," and L3 as the cross-cutting plane every consequential L2 action must pass
through. But ADR-045 deliberately stopped at the *concept*: it does **not** specify HOW a
free-form client intent is captured, clarified, resolved, and dispatched to an agent that
calls real banking capabilities, nor **which agents face the client at all.**

That seam is now specifiable, because the building blocks it needs already exist in canon:

- **Six CONTRACT-layer ports — the L2 surface.** This refactor cycle produced six
  hexagonal ports the L2 agents call: **WalletPort**, **PartnerPort**, **ExchangePort**
  (in `banxe-payment-core`) and **KYCProviderPort**, **NotificationProviderPort**,
  **CRMProviderPort** (in `banxe-emi-stack`). These are *the* governed operations a
  client-facing agent may invoke. Without a spec binding intents to these ports, "what can
  a client actually make an agent do?" has no governed answer.
- **The intent→process anchor (ADR-048).** ADR-048 canonized the S13-00 Business Process
  Repository and fixed the **intent→process resolution contract**: an L1 intent resolves
  to exactly one canonical, versioned process (`process_ref = {process_id, version}`)
  before any consequential L2 action, and an intent with no canonical process is a
  governance event, never improvised. This ADR consumes that contract: resolution to a
  `process_ref` is the step *between* intent capture and agent dispatch.
- **Lineage (ADR-046) and cost (ADR-047).** ADR-046's `AgentDecisionRecord` records *why*
  each L2 decision happened (intent, confidence, HITL outcome, `correlation_id`,
  `process_ref`); ADR-047 records *what it cost* and supplies the **hard caps** plus the
  HITL thresholds **AUTO > 0.90 / REVIEW 0.70–0.90 / BLOCK < 0.70** (aligned with
  `.claude/rules/agents.md`). A client-facing agent must honour both: a lineage record per
  action and a cost-cap per mask.
- **Internal passports exist; client-facing masks do NOT.** `docs/canon/passports/*.yaml`
  hold the **internal** fleet passports (canon-judge, executor, mlro, planner, reviewer,
  guardian-factory, guardian-project, ctio, operator, schema). These govern the
  factory/governance plane — they are **not** client-facing. The capability a *client*
  reaches (pay, exchange, onboard, get notified, refer a friend, manage a wallet) has **no
  governed surface definition today.** That is the gap this ADR fills, with a new artefact
  type: the **client-facing agent mask.**

Why this seam must be specified now (and not left to the build sprint to improvise):

- **The client surface is a regulatory boundary.** For a regulated EMI, *which* operations
  a client can trigger through conversation, *at what autonomy*, *with which confirmation*,
  and *under which compliance gate* is a CLASS_B/C governance decision — it cannot be an
  implementation detail an agent author chooses. It must be fixed as contract, then built.
- **Intent-First raises the L3 bar (ADR-045 Consequences).** ADR-045 already flagged that
  "treating the conversational layer as primary raises the bar for L3 guardrails — every
  intent path must be governed." A free-form intent surface with no mask is exactly the
  ungoverned path ADR-045 warns against. The mask is what makes each intent path governed.
- **Chat-first UX has no governed map without this.** ADR-045 makes conversation the
  primary interface; without a spec for how visual components, confirmations, and
  step-ups attach to intents, "chat-first" risks drifting back into screen-first.

This ADR is **SPECIFICATION / CONTRACT ONLY**: it specifies the intent-resolution contract
and the client-facing mask schema and instances. It does **not** implement the intent
classifier, the agents, the chat UI, the routing layer, or the port bindings. Those are a
factory build sprint (§D7), and **L2 execution depends on the LLM-orchestration layer
being operational — a precondition owned by Terminal A, NOT delivered here** (§D6).

## Decision

### D1 — Specify the L1 Intent Layer responsibilities (the client conversational surface)

The L1 Intent Layer is the **primary interface** (ADR-045 D1). It is responsible for, and
bounded to, four jobs — it does **not** itself execute banking operations:

1. **Capture** — receive a free-form natural-language client intent in conversation.
2. **Clarify** — ask the minimum disambiguating questions to make the intent actionable
   (amount, recipient, currency, account) without leading the client.
3. **Resolve** — turn the clarified intent into a canonical process reference via the
   ADR-048 intent→process contract (`process_ref = {process_id, version}`). An intent that
   resolves to **no** canonical process is a **governance event** (HITL / process-gap),
   **never improvised** into ad-hoc steps.
4. **Hand off** — emit a **structured, auditable request** (ADR-045 L1 definition) that
   names the resolved `process_ref` and the client-facing **mask** (D3) that will fulfil
   it, and pass it across the L1→L2 boundary.

L1 produces requests; it does not call ports. All port calls happen in L2, under a mask,
through L3.

### D2 — The intent-resolution contract (L1 → L2)

The canonical L1→L2 contract is a fixed, ordered chain. Every consequential client intent
traverses it in order; no step is skippable:

```
client intent (NL, L1)
  → capture + clarify (L1)
  → resolve to process_ref = {process_id, version}   (ADR-048 intent→process contract)
  → select client-facing agent mask                  (D3 — scope/autonomy/gates for this capability)
  → confirmation_policy check                         (D4 — AUTO / REVIEW / BLOCK + biometric step-up)
  → L2 agent executes within mask scope: calls the relevant CONTRACT port(s)
  → L3 enforcement intercepts (compliance overlay, ADR-046 lineage, ADR-047 cost-cap)
  → AgentDecisionRecord emitted (ADR-046), carrying intent, process_ref, confidence, cost, correlation_id
  → response surfaced to client in L1 (chat-first, D5)
```

Contract invariants:

- **No port call without a resolved `process_ref`.** Resolution (ADR-048) precedes
  dispatch. An unresolved intent halts as a governance event.
- **No port call outside the selected mask's scope** (D3). The mask is the allow-list.
- **No consequential action without an emitted `AgentDecisionRecord`** (ADR-046) and a
  within-budget cost state (ADR-047). The lineage receipt and the within-cap state are
  *preconditions* for the action to be considered complete — exactly as ADR-046 §D4,
  ADR-047 §D4, and ADR-048 §D3 each require for their own concern. This ADR composes the
  three into one ordered client-surface contract.
- **One `correlation_id` spans the whole chain**, tying the L1 intent record, the
  `process_ref`, the lineage record, and the cost rollup together (ADR-046 `correlation_id`).

### D3 — Client-facing agent MASK (new governed artefact)

A **client-facing agent mask** is the governed surface definition of one client-facing
capability. It is the *client-surface analogue* of an internal passport
(`docs/canon/passports/*.yaml`) — internal passports govern the fleet/factory plane; masks
govern what a **client** can reach. A mask is **config-as-data** (CLAUDE.md §10), not
hardcoded in agent code. Each mask declares, at minimum:

| Field | Meaning |
|-------|---------|
| `scope` | The exact CONTRACT port(s) **and operations** the masked agent may invoke. Nothing outside this set is reachable through this mask (the allow-list). |
| `autonomy_level` | How far the agent may act without a human, expressed on the existing HITL scale (AUTO/REVIEW/BLOCK bands of `.claude/rules/agents.md`, ADR-047). |
| `confirmation_policy` | When HITL and/or **biometric step-up** is required before the action commits (D4). |
| `cost_cap` | The per-request and per-window hard caps (ADR-047 D2) this mask runs under, in token AND monetary (Decimal) dimensions. |
| `lineage_obligation` | The mask MUST emit an `AgentDecisionRecord` (ADR-046) **per action** — non-optional. |
| `compliance_gate` | The L3 real-time compliance overlay the action passes through (AML/KYC/sanctions per the contour; Ruflo mandatory for payment/compliance/kyc per `.claude/rules/agents.md`). |

The **initial client-facing capabilities and their masks** (one mask per capability;
values such as concrete caps, thresholds, and operation lists are config-as-data set in the
build sprint, NOT fixed here):

| Capability | `scope` (ports) | Indicative autonomy | `confirmation_policy` (indicative) | `compliance_gate` |
|------------|-----------------|---------------------|-------------------------------------|-------------------|
| **Payments** | `WalletPort`, `PartnerPort` | REVIEW-biased for money movement | Biometric step-up + HITL for critical money movement (D4); AUTO only for trivial, within-cap, low-risk reads | AML + sanctions + Travel Rule contour; Ruflo mandatory |
| **FX / Exchange** | `ExchangePort`, `WalletPort` | REVIEW-biased | Biometric/HITL above a config threshold; AUTO for quotes/reads | AML; market-abuse overlay; Ruflo mandatory |
| **KYC onboarding** | `KYCProviderPort` | REVIEW (identity decisions are L2 HITL) | HITL on identity acceptance/decline; biometric where required by KYC flow | KYC + sanctions; MLRO escalation per `.claude/rules/agents.md` |
| **Notifications** | `NotificationProviderPort` | AUTO-biased (low consequence) | AUTO for informational sends within cap; REVIEW for anything templating client funds data | PII-handling overlay (ADR-016) |
| **Referral / CRM** | `CRMProviderPort` | AUTO-biased | AUTO for routine CRM/referral updates; REVIEW for incentive/payout-linked actions | PII + anti-abuse overlay |
| **Wallet** | `WalletPort` | Mixed (reads AUTO; mutations REVIEW) | Reads AUTO within cap; balance-affecting mutations follow the Payments policy (biometric/HITL) | AML for value movement; PII for balance reads |

Every mask without exception carries all six fields above; the table shows the *scope and
indicative posture*, not a reduced field set. A capability not represented by a mask is
**not** client-reachable — adding a client-facing capability is a new mask (ADR/IL-gated),
never an undeclared port binding.

### D4 — AUTO / REVIEW / BLOCK boundary + biometric step-up for critical money movement

The mask's `confirmation_policy` reuses the existing HITL thresholds verbatim — this ADR
introduces **no new threshold scale**:

- **AUTO (confidence > 0.90)** — the masked agent executes within scope and cap; logged via
  ADR-046, no human review required.
- **REVIEW (0.70 ≤ confidence ≤ 0.90)** — paused; notify the human double (MLRO/CEO per
  `.claude/rules/agents.md`); time-boxed wait, then escalate to BLOCK on no response.
- **BLOCK (confidence < 0.70)** — full stop; human confirmation mandatory; no timeout.

**Step-up on top of the band — critical money movement.** For operations that move client
funds at or above a configured materiality (payments, FX settlement, wallet
balance-affecting mutations), the mask additionally requires a **biometric / step-up
confirmation** before commit, **independent of the confidence band** — i.e. a high-confidence
(AUTO) money-movement intent still requires step-up. This is the zero-trust posture for
consumer money movement (step-up authentication for value-bearing actions, as practised by
zero-trust consumer-banking products such as Revolut), applied here at the mask boundary so
the conversational surface never moves material client funds on intent alone. The
**materiality thresholds, which operations require step-up, and the step-up mechanism are
config-as-data** (CLAUDE.md §10) — never hardcoded, never set in this ADR.

This composes with ADR-047: a BLOCK-equivalent halt also fires on a cost-cap breach
(ADR-047 D4), so an action can be stopped by *either* low confidence, *or* missing
step-up, *or* a budget breach — any one is sufficient to halt.

### D5 — Chat-first UX principle: visual components are agent responses, not primary nav

Per ADR-045 D1 (conversational layer is the primary interface), this ADR fixes the UX
boundary for the client surface:

- **Conversation is the primary surface.** The client expresses intent in natural language;
  the agent (under a mask) fulfils it and replies *in the conversation*.
- **Visual components are agent responses, not primary navigation.** Cards, forms,
  confirmation sheets, biometric prompts, and balance views are **rendered as responses to
  an intent within the conversation** — they are how an agent asks for the D4 confirmation
  or shows a result, not a screen-first navigation tree the client browses instead of
  speaking. A design that makes a screen/form the entry point and the conversation an
  optional add-on contradicts ADR-045 D1 and this ADR.
- **Step-up surfaces in-conversation.** The D4 biometric/HITL confirmation is itself an
  agent-response component in the chat flow, keeping the whole intent→confirm→execute loop
  inside the conversational surface.

### D6 — Precondition: L2 execution depends on the LLM-orchestration layer (Terminal A)

The client-facing masks describe **L2 agent execution**. L2 execution presupposes an
**operational LLM-orchestration layer** (the meta-plane/inference substrate that runs the
agents — ADR-040 meta-plane vs inference-plane; the factory/AI-pool infrastructure). That
**infrastructure readiness is a precondition for any build against this spec, and it is
owned by Terminal A** (which builds/improves the factory and AI substrate per ADR-045 D5),
**not delivered by this ADR.** This ADR specifies the *contract the masks must satisfy*; it
does not stand up the orchestration layer, and a build sprint MUST treat
LLM-orchestration readiness as a gating dependency before instrumenting client-facing
agents.

### D7 — Specification/contract scope only; no implementation here

This ADR authors **no** agent, UI, routing, classifier, or port-binding code. Specifically
deferred to a dedicated **factory build sprint** (produced through the Software Factory —
ADR-045 §D3/§D4, Central does not mutate project code directly):

- the intent classifier / resolver wiring to the ADR-048 `process_ref`;
- the L2 client-facing agents and their binding to the six CONTRACT ports;
- the chat-first UI and the in-conversation visual/biometric components (D5);
- the agent-routing layer that dispatches intent → mask → agent (note: `AGENT_ROUTING_ENABLED`
  remains **false** until the ARL preconditions of `.claude/rules/agents.md` — Ruflo
  mandatory middleware for payment/compliance/kyc — are met);
- the concrete mask **values** (operation lists, cost-cap numbers, materiality and step-up
  thresholds) as config-as-data;
- the ADR-046 lineage instrumentation and ADR-047 cost-cap wiring at the mask boundary.

**Crucially, this ADR specifies the client surface; it does NOT itself open any port to
clients.** No CONTRACT port becomes client-reachable by virtue of this ADR — a port becomes
reachable only when a built, mask-bound, gated agent is deployed through the factory with
all of D2's governance gates (resolution, lineage, cost-cap, compliance overlay, step-up)
in place. The masks are the *contract for* that opening, not the opening itself.

## Consequences

**Positive**

+ Closes the L1→L2 client-surface seam ADR-045 left open: there is now a governed answer to
  "how does a client intent become a bounded agent action?" and "which agents face the
  client?".
+ Introduces the **client-facing mask** as a first-class governed artefact, the
  client-surface analogue of the internal passports — every client capability has an
  explicit scope, autonomy, confirmation, cost-cap, lineage obligation, and compliance gate.
+ Binds the six new CONTRACT ports (Wallet, Partner, Exchange, KYCProvider,
  NotificationProvider, CRMProvider) to a governed client surface instead of leaving "what
  can a client trigger?" implicit.
+ Composes the three §D7 governance siblings into one ordered client contract: ADR-048
  resolution, ADR-046 lineage, ADR-047 cost-cap + thresholds — each becomes a precondition
  on the same chain, under one `correlation_id`.
+ Fixes the zero-trust money-movement posture (biometric step-up independent of confidence)
  at the mask boundary, so the conversational surface never moves material client funds on
  intent alone.
+ Makes chat-first UX governable: visual/biometric components are agent responses inside
  the conversation, preventing drift back to screen-first navigation.

**Negative / costs**

- This is a specification artefact: it changes nothing operationally until the deferred
  factory sprint builds the agents, UI, routing, and config. Until then the masks are
  defined but no client capability is live.
- A mask per capability plus mandatory step-up/HITL on money movement raises latency and
  friction versus a frictionless auto-execute surface — that friction is the regulatory
  point, not an accident.
- Cross-artefact coupling: the client contract now depends on ADR-048 (`process_ref`),
  ADR-046 (lineage), ADR-047 (cost-cap), and the six ports staying coherent; a change to any
  must keep the mask contract resolvable.
- Hard dependency on Terminal A's LLM-orchestration readiness (D6): no build against this
  spec can proceed until that precondition is met, which this ADR does not control.

## Alternatives considered

- **Let each agent author decide its own client surface ad hoc** (rejected: which
  operations a client can trigger, at what autonomy, under which gate, is a CLASS_B/C
  regulatory decision — it must be fixed as governed contract, not chosen per-agent. This is
  the ungoverned-intent-path drift ADR-045 explicitly warns against).
- **Reuse the internal passports (`docs/canon/passports/*.yaml`) for client-facing agents**
  (rejected: those govern the fleet/factory/governance plane and were never designed as a
  client surface. The client surface needs its own artefact — the mask — with
  confirmation_policy and compliance_gate fields the internal passports do not carry).
- **Fold the client surface into ADR-045** (rejected: ADR-045 is CONCEPT ONLY and
  explicitly defers the "how"; specifying masks and the resolution contract is a separate
  decision with its own scope, alternatives, and consequences).
- **Fold it into ADR-048** (rejected: ADR-048 fixes intent→`process_ref`; it stops at the
  process handle and does not specify the agent surface, autonomy, confirmation, or cost
  boundary that consumes that handle. This ADR consumes ADR-048's contract, it does not
  duplicate it).
- **Introduce a new confidence/threshold scale for the client surface** (rejected: the
  AUTO > 0.90 / REVIEW 0.70–0.90 / BLOCK < 0.70 bands of `.claude/rules/agents.md` and
  ADR-047 already exist and are invariant; reusing them keeps one governance scale).
- **Open the six ports to clients directly via a thin API, no masks** (rejected: a port
  reachable without the resolution/lineage/cost/compliance/step-up gates is an FCA-violating
  ungoverned money surface — exactly what the mask contract exists to prevent. This ADR
  opens no port to clients).
- **Build first, specify later** (rejected: the client surface is a regulatory boundary;
  it must be contract before code. Specify the masks, then build through the factory).

## Relationship to ADR-045 (L1) and the three §D7 siblings (the governance the masks honour)

- **ADR-045 (Intent-First; L1 & the four-layer model).** ADR-045 *defines* L1 (the
  conversational intent layer, primary interface) and the L1→L2→L3→L4 model but stops at the
  concept. **ADR-049 *is* the specification of L1's responsibilities and the L1→L2 client
  surface** ADR-045 left open — it makes "every intent path must be governed" (ADR-045
  Consequences) concrete via the mask.
- **ADR-046 (Decision Lineage Schema).** Every masked action's `lineage_obligation` is an
  emitted `AgentDecisionRecord` carrying the intent, `process_ref`, confidence, HITL
  outcome, and `correlation_id` — the mask makes the ADR-046 producer obligation (L2→L3)
  concrete on the client surface.
- **ADR-047 (AI Cost Governance Policy).** Every mask carries a `cost_cap` (ADR-047 D2 hard
  caps) and reuses the AUTO/REVIEW/BLOCK thresholds; a cost-cap breach halts the action
  (ADR-047 D4), one of the three independent halt conditions in D4.
- **ADR-048 (Business Process Repository).** The mask is selected *after* the intent
  resolves to a governed `process_ref` (ADR-048 intent→process contract); resolution is the
  D2 step between capture and dispatch, and an unresolved intent is a governance event.
- **The six CONTRACT ports** (WalletPort, PartnerPort, ExchangePort, KYCProviderPort,
  NotificationProviderPort, CRMProviderPort) are the **L2 surface** the masks' `scope` fields
  allow-list — the masks bound *which* port operations a client can reach, through the gates.
- **ADR-025 (Agent Interaction Canon)** and **`.claude/rules/agents.md`** (HITL
  AUTO/REVIEW/BLOCK; compliance chain B with Ruflo mandatory for payment/compliance/kyc;
  ARL `AGENT_ROUTING_ENABLED=false` precondition) supply the governance machinery the masks
  reuse.

## Anchors

- ADR-045 (`docs/adr/ADR-045-intent-first-banking-architecture.md` — L1 Intent Layer & four-layer model; this ADR specifies L1 + the L1→L2 client surface)
- ADR-046 (`docs/adr/ADR-046-decision-lineage-schema.md` — `AgentDecisionRecord`; mask `lineage_obligation` per action)
- ADR-047 (`docs/adr/ADR-047-ai-cost-governance-policy.md` — hard cost caps; AUTO/REVIEW/BLOCK thresholds; mask `cost_cap`)
- ADR-048 (`docs/adr/ADR-048-business-process-repository.md` — intent→`process_ref` resolution contract; precedes mask dispatch)
- ADR-025 (`decisions/ADR-025-agent-interaction-canon.md` — agent interaction canon)
- ADR-016 (`decisions/ADR-016-ai-plane-pii-aml-routing.md` — PII/AML routing overlay for compliance_gate)
- ADR-040 (`docs/adr/ADR-040-ai-execution-policy.md` — meta-plane vs inference-plane; the LLM-orchestration substrate D6 depends on)
- The six CONTRACT ports — `WalletPort`, `PartnerPort`, `ExchangePort` (banxe-payment-core); `KYCProviderPort`, `NotificationProviderPort`, `CRMProviderPort` (banxe-emi-stack) — the L2 surface the masks scope
- `docs/canon/passports/*.yaml` (the EXISTING internal passports; client-facing masks are the new client-surface analogue, NOT these)
- `.claude/rules/agents.md` (HITL AUTO/REVIEW/BLOCK; compliance chain B — Ruflo mandatory; ARL `AGENT_ROUTING_ENABLED=false` precondition)
- `R-COMP-FCA-02` (continuous-compliance / agentic-AI auditability); DORA 2026 (operational resilience); zero-trust consumer money-movement step-up (Revolut-style) — D4 rationale
- CLAUDE.md §10 (config-over-hardcoding — mask values, caps, thresholds as governed data), §11 (no ungoverned consequential action / client-funds mutation gate), money rule (Decimal, never float)
- INSTRUCTION-LEDGER.md → IL-126-INTENT-LAYER-CLIENT-MASKS-2026-06-07
