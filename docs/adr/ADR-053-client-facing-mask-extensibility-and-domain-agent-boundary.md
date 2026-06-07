---
id: ADR-053
title: Client-Facing Mask Catalogue Extensibility & the Mask↔Domain-Agent Governance Boundary (extends ADR-049) for EMI BANXE AI BANK
status: PROPOSED
date: 2026-06-08
accepted: null
supersedes: []
extends:
  - "ADR-049-intent-layer-client-facing-agent-masks.md (declares the 6 initial masks the INITIAL client-facing capabilities; this ADR makes the catalogue extensible and adds the first new mask)"
related:
  - "ADR-045-intent-first-banking-architecture.md (Intent-First Banking — the four-layer model; client surface is L1→L2)"
  - "ADR-046-decision-lineage-schema.md (Decision Lineage Schema — every masked action emits an AgentDecisionRecord)"
  - "ADR-047-ai-cost-governance-policy.md (AI Cost Governance Policy — every mask carries a cost-cap; AUTO/REVIEW/BLOCK reused)"
  - "ADR-048-business-process-repository.md (Business Process Repository — intents resolve to a governed process_ref before dispatch)"
  - "../../decisions/ADR-016-ai-plane-pii-aml-routing.md (AI Plane / PII-AML routing — compliance_gate overlay)"
  - "../../decisions/ADR-025-agent-interaction-canon.md (Agent Interaction Canon)"
binding_artifact: null
il_anchor: IL-137-CLIENT-MASK-EXTENSIBILITY-DOMAIN-AGENT-BOUNDARY-2026-06-08
scope: BANXE-only
concept_only: true
---

# ADR-053: Client-Facing Mask Catalogue Extensibility & the Mask↔Domain-Agent Governance Boundary (extends ADR-049) for EMI BANXE AI BANK

**Status:** Proposed
**Date:** 2026-06-08
**Source-of-determination:** YAML frontmatter `status: PROPOSED` + body section `## Status` line `PROPOSED — 2026-06-08`
**IL-anchor:** IL-137-CLIENT-MASK-EXTENSIBILITY-DOMAIN-AGENT-BOUNDARY-2026-06-08
**Scope:** BANXE-only (governance artefact; SPECIFICATION / CONTRACT ONLY — no agent, UI, routing, or port-binding code in this ADR)

## Status

PROPOSED — 2026-06-08. This ADR **extends ADR-049**. ADR-049 specified the L1→L2 client
surface and declared **six** client-facing agent masks, calling them explicitly the
"**initial** client-facing capabilities". It did not say (a) whether and how the mask
catalogue grows beyond those six, nor (b) how a mask-governed client-facing agent relates
to the **pre-existing domain service-agents** that already implement uncovered capabilities
in `banxe-emi-stack` but were authored before ADR-049 and are **not** under Intent-First
governance. This ADR fixes both seams. It is **SPECIFICATION / CONTRACT ONLY**: it makes
the catalogue extensible, fixes the mask↔domain-agent governance boundary, defines the path
to add a capability, and adds the **Cards (C22)** mask as the first new catalogue entry. It
implements no agent, port binding, UI, or routing.

## Context

ADR-049 closed the L1→L2 client-surface seam that ADR-045 left open: it introduced the
**client-facing agent mask** (the governed surface definition of one client-facing
capability — `scope` / `autonomy_level` / `confirmation_policy` / `cost_cap` /
`lineage_obligation` / `compliance_gate`), fixed the §D2 intent-resolution gate chain
(`process_ref` [ADR-048] → mask scope → confirmation_policy → port call → L3 enforcement →
`AgentDecisionRecord` [ADR-046] + within-cap state [ADR-047], one `correlation_id`), and
declared six masks over the six CONTRACT ports produced that cycle: **Payments**
(WalletPort/PartnerPort), **FX/Exchange** (ExchangePort/WalletPort), **KYC onboarding**
(KYCProviderPort), **Notifications** (NotificationProviderPort), **Referral/CRM**
(CRMProviderPort), **Wallet** (WalletPort). IL-132 then recorded the L2 code for all six as
factory-built and merged; IL-135 hardened their lineage/cost primitives (DRY consolidation +
ADR-046 §D5 fields).

Two facts make a follow-on decision necessary now:

- **ADR-049's own wording is "initial".** ADR-049 §D3 calls its six masks the "**initial**
  client-facing capabilities and their masks" and says "adding a client-facing capability is
  a new mask (ADR/IL-gated), never an undeclared port binding." It names the *constraint* on
  growth but never specifies the *mechanism*: it does not say a new mask requires its own
  CONTRACT port, nor where the new client-facing agent lives, nor how it relates to existing
  code. The catalogue is implicitly open; this ADR makes it **explicitly extensible** with a
  fixed mechanism.

- **The capability map (PRIORITY-MAP, C1–C30) is far larger than the six masks, and several
  uncovered capabilities ALREADY have domain service-agents that are NOT mask-governed.**
  `docs/refactor/legacy/NEW-PROJECT-PRIORITY-MAP-2026-06-06.md` defines **30** capabilities
  (C1–C30). The six masks cover roughly eight of them (C1 wallet/custody, C3/C4 payments &
  BaaS via PartnerPort, C5 KYC, C6 exchange, C9 notifications, C10 referral/CRM). Many
  uncovered capabilities are **not greenfield** — they already have working domain
  service-agents in `banxe-emi-stack` that pre-date ADR-049 and do **not** enforce the §D2
  gate chain, ADR-046 lineage, or ADR-047 cost-cap:

  | Capability | Existing domain service-agent (pre-ADR-049) | PRIORITY-MAP anchor |
  |------------|---------------------------------------------|---------------------|
  | C22 Card issuance | `services/card_issuing/card_agent.py` | C22 — CardPort + Paymentology |
  | C7 Portfolio analytics | `services/reporting_analytics/analytics_agent.py` | C7 — crypto-api-portfolio |
  | Client statements | `services/client_statements/statement_agent.py` | (reporting/statements; no single Cn) |

  These agents embody real domain/business logic, but they were never client-surface
  artefacts: they have no mask, no confirmation_policy, no compliance_gate field, no
  lineage obligation, no cost-cap. If a client intent were routed straight to
  `card_agent.py`, it would reach a money-class capability (card freeze, issue, limit
  change) **bypassing every ADR-049 gate** — precisely the ungoverned-intent-path drift
  ADR-045 and ADR-049 exist to prevent.

The discovery this ADR must resolve: **mask-governed client-facing agents and pre-existing
domain service-agents are two different kinds of thing, and the boundary between them was
never stated.** Conflating them risks two equal and opposite errors — either (1) treating a
domain agent as a client surface (ungoverned money path), or (2) duplicating the domain
agent's business logic inside a new client-facing agent (drift, double-maintenance). Both
are avoided by one boundary rule, fixed below.

This ADR is **SPECIFICATION / CONTRACT ONLY**. It does not implement CardPort, the Cards
client-facing agent, or any wiring; those are a factory build sprint (§E), gated as ADR-049
§D6/§D7 already require (LLM-orchestration readiness owned by Terminal A;
`AGENT_ROUTING_ENABLED` stays false until the `.claude/rules/agents.md` ARL preconditions
are met).

## Decision

### D1 — The six masks are "initial"; the mask catalogue is EXTENSIBLE

Confirm ADR-049's framing: its six masks are the **initial** client-facing capabilities,
**not** the closed set. The client-facing mask catalogue is **extensible**. A new
client-facing capability is added by, and only by, the following fixed mechanism — the
ADR-049 §D2 gate chain continues to apply in full to every new mask, unchanged:

1. **An ADR authorises the capability** (this ADR, or a successor), recording the decision to
   make the capability client-reachable as a CLASS_B/C governance act — never an
   implementation choice an agent author makes.
2. **A CONTRACT port exists for it** (authored or confirmed). A mask's `scope` MUST
   allow-list operations on a real hexagonal CONTRACT port; **no mask may scope a capability
   that has no port.** "Mask without a port" is forbidden — it would re-introduce the
   ungoverned binding ADR-049 §D3 rules out.
3. **The mask is added to the catalogue** with all six ADR-049 §D3 fields populated
   (`scope`, `autonomy_level`, `confirmation_policy`, `cost_cap`, `lineage_obligation`,
   `compliance_gate`) — config-as-data (CLAUDE.md §10), values set in the build sprint.
4. **A mask-bound, gated client-facing agent is built** through the factory that honours the
   full §D2 chain (resolution → scope → confirmation_policy → port call → L3 enforcement →
   `AgentDecisionRecord` + within-cap state, one `correlation_id`).

No step is skippable and the order is fixed: **ADR → CONTRACT port → mask catalogue entry →
mask-bound agent.** The catalogue grows one governed mask at a time; the number of masks is
open, the *mechanism* by which it grows is closed.

### D2 — The governance boundary: client-facing mask agent ≠ domain service-agent

This is the core decision. Two kinds of agent exist and they sit on opposite sides of a
CONTRACT port:

| | **Client-facing agent** (Intent-First L2) | **Domain service-agent** (pre-existing) |
|---|---|---|
| Example | a built `CardsAgent` in `services/agents/` | `services/card_issuing/card_agent.py` |
| Governed by | a **mask** (ADR-049 §D3); §D2 gate chain; ADR-046 lineage; ADR-047 cost-cap; ADR-049 §D4 step-up | domain/business rules of its service; **NOT** Intent-First-governed |
| Client-reachable? | **Yes** — it is the client entry point, through L1→L2 | **No** — never a client entry point |
| Role | the **client surface**; calls a CONTRACT port | the **implementation behind** the port; an adapter |
| Position | **in front of** the CONTRACT port | **behind** the CONTRACT port |

**Boundary principle (canonical):**

> A client intent MUST NOT reach a domain service-agent directly. It traverses the ADR-049
> §D2 chain to a **mask-governed client-facing agent**, which calls a **CONTRACT port**. The
> pre-existing domain service-agent sits **behind that port as an adapter / implementation**
> — never as the client entry point. **Existing domain agents are adapters, not client
> surfaces.**

Consequences of the boundary:

- **Direct intent → domain-agent routing is forbidden.** Any path that lets a client intent
  invoke `card_agent.py` (or any domain service-agent) without passing through a mask and the
  §D2 gates is an ungoverned money/PII surface — an FCA-violating path, exactly what the mask
  contract exists to prevent.
- **The domain agent is NOT rewritten or duplicated.** Its business logic is preserved
  **untouched** behind the port. The client-facing agent does **not** re-implement domain
  logic; it enforces the gates and delegates the actual capability call to the port, which
  the domain agent (now an adapter) fulfils. This avoids both ungoverned exposure (error 1)
  and logic duplication/drift (error 2) named in Context.
- **The CONTRACT port is the boundary object.** It is where governance (in front) meets
  domain implementation (behind). The mask `scope` allow-lists port operations; the domain
  agent implements them. Neither side reaches across the port.
- **Pre-ADR-049 domain agents are not in violation by existing** — they are non-compliant
  **only if exposed to clients without a mask.** Bringing a capability online means putting a
  mask + client-facing agent **in front** of the existing domain agent, not deleting or
  re-governing the domain agent in place. Until that happens the domain agent remains a
  purely internal/back-office component and is simply **not** client-reachable.

### D3 — The path to add a capability (worked example: Cards, C22)

To make an uncovered capability that already has a domain service-agent client-reachable,
follow D1's mechanism with the domain agent wired **behind** the port per D2:

1. **Author / confirm a CONTRACT port** — for Cards, a **`CardPort`** (hexagonal, in the
   appropriate code repo) exposing the governed card operations (e.g. `freeze`, `block`,
   `read_card`, `read_limits`, `issue_card`, `change_limit`). The port is the allow-list
   surface; nothing outside it is reachable through the mask.
2. **Add the capability's mask to the catalogue** (D4 below) with all six fields populated as
   config-as-data — scope, autonomy, confirmation_policy, cost_cap, lineage, compliance gate.
3. **Build the client-facing agent in `services/agents/`** (mirroring the ADR-049/IL-132 L2
   agents) that calls `CardPort` through the full §D2 chain and emits an
   `AgentDecisionRecord` per action.
4. **Wire the EXISTING `services/card_issuing/card_agent.py` BEHIND `CardPort` as the
   adapter, untouched** — its Paymentology/card-issuing business logic becomes the port's
   implementation. The client-facing `CardsAgent` never calls `card_agent.py` directly; it
   calls `CardPort`, which the adapter fulfils.

The same four-step path applies to every future capability; D3 is the concrete instantiation
of D1 for the case where a domain service-agent already exists.

### D4 — The Cards mask (C22) — first new entry in the extended catalogue

The Cards mask is added as the **first** entry of the extended (post-initial-six) catalogue.
All six ADR-049 §D3 fields are present; concrete values (operation lists, materiality
thresholds, cap numbers) are **config-as-data** set in the build sprint, NOT fixed here.

| Field | Cards (C22) mask — indicative |
|-------|-------------------------------|
| `scope` | `CardPort` operations only: reads (`read_card`, `read_limits`, list) + mutations (`freeze`, `block`/`unblock`, `issue_card`, `change_limit`). The allow-list; nothing outside `CardPort` is reachable through this mask. |
| `autonomy_level` | **Mixed.** Reads and `freeze`/`block` are AUTO-with-cap (a freeze is a *protective*, low-regret action a client should be able to trigger instantly). `issue_card` and `change_limit` are REVIEW-biased (value/credit-affecting). |
| `confirmation_policy` | AUTO (within cap) for reads and for protective freeze/block. **REVIEW + biometric step-up** for `issue_card` and `change_limit` — issuance and limit increases move/expose client credit and are critical actions (ADR-049 §D4 step-up, independent of confidence band). |
| `cost_cap` | Per-request and per-window hard caps (ADR-047 §D2), token AND monetary (Decimal). Values config-as-data. |
| `lineage_obligation` | One `AgentDecisionRecord` (ADR-046) per action on every exit path — non-optional. |
| `compliance_gate` | **AML + PII gate**: card issuance and limit changes pass the AML contour; all card reads pass the PII overlay (ADR-016); Ruflo mandatory where the action is payment/compliance-classed (`.claude/rules/agents.md`). |

Behind this mask, the existing `services/card_issuing/card_agent.py` is the `CardPort`
adapter (D3 step 4), untouched.

### D5 — Other near-term catalogue candidates (to be specified next)

The following uncovered capabilities have existing domain service-agents and are the clear
near-term catalogue entries to be specified in successor ADRs/IL increments. Each follows the
D1 mechanism and the D2 boundary: a CONTRACT port is authored/confirmed, a mask added, a
client-facing agent built, and the **existing service-agent becomes the adapter behind the
port** (untouched):

| Capability | Existing domain service-agent (→ becomes adapter behind port) | Indicative port | Catalogue status |
|------------|----------------------------------------------------------------|-----------------|------------------|
| **C7 Portfolio analytics** | `services/reporting_analytics/analytics_agent.py` | `AnalyticsPort` (or read-only ReportingPort) | to be specified next — reads AUTO-with-cap; PII overlay on any client-fund data |
| **Client statements** | `services/client_statements/statement_agent.py` | `StatementPort` | to be specified next — statement generation/read; PII overlay; AUTO-with-cap reads |

These are **candidates named for sequencing**, not masks defined by this ADR. Only the Cards
(C22) mask (D4) is added to the catalogue here; C7 and statements are listed so the build
order and the adapter-behind-port treatment of their existing service-agents are on record.

### D6 — No new governance scale; all ADR-049 gates inherited unchanged

This ADR introduces **no** new confidence/threshold scale, **no** new mask field, and **no**
new gate. It reuses ADR-049 §D3 (the six mask fields), §D2 (the gate chain), §D4 (AUTO > 0.90
/ REVIEW 0.70–0.90 / BLOCK < 0.70 + biometric step-up for critical money movement), §D5
(chat-first UX), and the ADR-046/047/048 obligations verbatim. The only additions are: the
extensibility *mechanism* (D1), the mask↔domain-agent *boundary* (D2), the add-a-capability
*path* (D3), and one new catalogue *entry* (Cards, D4).

### E — Specification/contract scope only; no implementation here

This ADR authors **no** code. Deferred to a factory build sprint (produced through the
Software Factory — ADR-045 §D3/§D4; Central does not mutate project code directly), and
gated exactly as ADR-049 §D6/§D7 already require:

- authoring `CardPort` (and later `AnalyticsPort`, `StatementPort`) as hexagonal CONTRACT
  ports;
- building the `CardsAgent` (and successors) in `services/agents/` bound to the port through
  the §D2 chain;
- wiring the existing `card_agent.py` / `analytics_agent.py` / `statement_agent.py` behind
  their ports as adapters (untouched business logic);
- the concrete mask **values** (operation lists, cost-cap numbers, materiality/step-up
  thresholds) as config-as-data;
- the ADR-046 lineage and ADR-047 cost-cap wiring at each new mask boundary.

`AGENT_ROUTING_ENABLED` remains **false** until the ARL preconditions of
`.claude/rules/agents.md` (Ruflo mandatory middleware for payment/compliance/kyc) are met,
and any build presupposes Terminal-A LLM-orchestration readiness (ADR-049 §D6 / ADR-040
meta-plane). **This ADR opens no CONTRACT port to clients** — a port becomes client-reachable
only when a built, mask-bound, gated agent is deployed through the factory with all §D2 gates
in place.

## Consequences

**Positive**

+ Makes the ADR-049 mask catalogue **explicitly extensible** with a fixed, closed mechanism
  (ADR → CONTRACT port → mask entry → mask-bound agent), removing the ambiguity of "initial".
+ Fixes the **mask↔domain-agent governance boundary** as canon: client intent never reaches a
  domain service-agent directly; the domain agent is an adapter behind a CONTRACT port, never
  a client surface. This closes a real ungoverned-path risk (a client intent hitting
  `card_agent.py` and bypassing every ADR-049 gate).
+ **Reuses, not rewrites, existing domain logic.** Pre-ADR-049 service-agents are preserved
  untouched behind ports — no duplication, no drift, no double-maintenance.
+ Adds the **Cards (C22)** mask with a regulation-appropriate posture (protective freeze/block
  AUTO-with-cap; issuance/limit-change REVIEW + biometric step-up; AML/PII gate).
+ Puts the next candidates (C7 analytics, statements) and their adapter-behind-port treatment
  on record, giving the build sprint a governed sequence.

**Negative / costs**

- Specification artefact only: nothing operational changes until the factory builds the
  ports, agents, and config. Until then Cards/analytics/statements remain non-client-reachable.
- Each new capability now carries the full ADR-049 ceremony (ADR + port + mask + gated agent)
  — deliberately more friction than wiring an intent straight to an existing domain agent;
  that friction is the regulatory boundary, not overhead.
- The catalogue's coherence now depends on the CONTRACT ports, ADR-046/047/048, and the
  domain adapters staying aligned per capability; a change to any must keep the mask contract
  resolvable.
- Hard dependency (inherited from ADR-049 §D6) on Terminal-A LLM-orchestration readiness; no
  build against this spec proceeds until that precondition is met, which this ADR does not
  control.

## Alternatives considered

- **Route client intents directly to the existing domain service-agents** (rejected: a client
  intent reaching `card_agent.py` without a mask bypasses the §D2 gate chain, lineage,
  cost-cap, compliance overlay, and step-up — an FCA-violating ungoverned money/PII surface.
  This is the exact drift ADR-045/ADR-049 exist to prevent).
- **Rewrite each domain agent as a mask-governed client-facing agent in place** (rejected:
  duplicates/relocates working domain logic, invites drift and double-maintenance, and
  conflates two roles. The boundary keeps domain logic untouched behind a port and adds the
  client surface in front).
- **Treat the six masks as the closed set; no new masks** (rejected: ADR-049 explicitly calls
  them "initial", and the PRIORITY-MAP defines 30 capabilities — most uncovered. A closed set
  would leave 20+ capabilities permanently ungoverned-or-ungovernable for the client surface).
- **Allow a mask without a CONTRACT port (mask scoping a capability directly)** (rejected:
  re-introduces the undeclared port binding ADR-049 §D3 forbids; the port is the boundary
  object and the allow-list anchor — no port, no mask).
- **Add several masks (Cards, analytics, statements) in this ADR** (rejected: one new mask
  (Cards) is enough to establish the extension pattern; analytics/statements are named as
  sequenced candidates so each gets its own ADR/IL increment with its own port and values,
  per the D1 mechanism).
- **Fold this into ADR-049** (rejected: ADR-049 is accepted and scoped to the initial six and
  the L1→L2 contract; extensibility, the domain-agent boundary, and the first new mask are a
  distinct decision with their own alternatives and consequences — authored as an extending
  ADR, not a retro-edit of an accepted one).

## Relationship to ADR-049 and the governance siblings

- **ADR-049 (Intent Layer & Client-Facing Agent Masks).** This ADR **extends** it: ADR-049
  defines the mask artefact, the §D2 chain, the §D4 thresholds + step-up, and the initial six
  masks. ADR-053 makes the catalogue extensible (D1), fixes the mask↔domain-agent boundary
  (D2), defines the add-a-capability path (D3), and adds the Cards mask (D4). Every ADR-049
  gate is inherited unchanged (D6).
- **ADR-046 (Decision Lineage Schema).** Each new mask's `lineage_obligation` is an emitted
  `AgentDecisionRecord` per action — identical to the six initial masks.
- **ADR-047 (AI Cost Governance Policy).** Each new mask carries a `cost_cap` and reuses the
  AUTO/REVIEW/BLOCK bands; a cost-cap breach halts the action.
- **ADR-048 (Business Process Repository).** A new-capability intent still resolves to a
  governed `process_ref` before mask dispatch; an unresolved intent is a governance event.
- **The CONTRACT ports** are the boundary objects: the mask `scope` allow-lists port
  operations (in front); the existing domain service-agent implements them (behind). The new
  `CardPort` (and later `AnalyticsPort`, `StatementPort`) extend the six initial ports.
- **ADR-025 / `.claude/rules/agents.md`** supply the HITL bands and the Ruflo-mandatory
  compliance chain the masks reuse; **ADR-016** supplies the PII/AML overlay for the
  `compliance_gate`.
- **PRIORITY-MAP (C1–C30)** is the capability source: the six initial masks cover ~8
  capabilities; this ADR brings C22 (Cards) under governance and names C7 + statements next.
- **IL-132 / IL-135** record the L2 code of the initial six masks and their lineage/cost
  primitives — the pattern the new client-facing agents (CardsAgent, …) mirror.

## Anchors

- ADR-049 (`docs/adr/ADR-049-intent-layer-client-facing-agent-masks.md` — the initial six masks, the §D2 chain, §D3 mask fields, §D4 thresholds + step-up; this ADR extends it)
- ADR-045 (`docs/adr/ADR-045-intent-first-banking-architecture.md` — Intent-First four-layer model; client surface is L1→L2)
- ADR-046 (`docs/adr/ADR-046-decision-lineage-schema.md` — `AgentDecisionRecord`; mask `lineage_obligation` per action)
- ADR-047 (`docs/adr/ADR-047-ai-cost-governance-policy.md` — hard cost caps; AUTO/REVIEW/BLOCK; mask `cost_cap`)
- ADR-048 (`docs/adr/ADR-048-business-process-repository.md` — intent→`process_ref` resolution; precedes mask dispatch)
- ADR-025 (`decisions/ADR-025-agent-interaction-canon.md` — agent interaction canon)
- ADR-016 (`decisions/ADR-016-ai-plane-pii-aml-routing.md` — PII/AML routing overlay for `compliance_gate`)
- ADR-040 (`docs/adr/ADR-040-ai-execution-policy.md` — meta-plane vs inference-plane; the LLM-orchestration substrate L2 depends on, Terminal A)
- The CONTRACT ports — the six initial (WalletPort, PartnerPort, ExchangePort, KYCProviderPort, NotificationProviderPort, CRMProviderPort) + the new `CardPort` (and future `AnalyticsPort`, `StatementPort`) — the boundary objects masks scope and domain agents implement
- Pre-existing domain service-agents (become adapters behind ports, untouched): `services/card_issuing/card_agent.py` (C22), `services/reporting_analytics/analytics_agent.py` (C7), `services/client_statements/statement_agent.py` (statements) — all in `banxe-emi-stack`
- `docs/refactor/legacy/NEW-PROJECT-PRIORITY-MAP-2026-06-06.md` (capabilities C1–C30; the six initial masks cover ~8; C22 brought under governance here)
- `docs/canon/passports/*.yaml` (internal fleet passports — masks are the client-surface analogue, NOT these)
- `.claude/rules/agents.md` (HITL AUTO/REVIEW/BLOCK; compliance chain B — Ruflo mandatory; ARL `AGENT_ROUTING_ENABLED=false` precondition)
- `R-COMP-FCA-02` (continuous-compliance / agentic-AI auditability); DORA 2026 (operational resilience); zero-trust consumer money-movement step-up (Revolut-style) — D4 issuance/limit-change rationale
- CLAUDE.md §10 (config-over-hardcoding — mask values, caps, thresholds as governed data), §11 (no ungoverned consequential action / client-funds mutation gate), money rule (Decimal, never float)
- INSTRUCTION-LEDGER.md → IL-137-CLIENT-MASK-EXTENSIBILITY-DOMAIN-AGENT-BOUNDARY-2026-06-08
