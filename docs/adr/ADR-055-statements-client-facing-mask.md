---
id: ADR-055
title: Statements Client-Facing Mask — third extended-catalogue entry (extends ADR-049 via ADR-053) for EMI BANXE AI BANK
status: PROPOSED
date: 2026-06-08
accepted: null
supersedes: []
extends:
  - "ADR-053-client-facing-mask-extensibility-and-domain-agent-boundary.md (defines the extensibility mechanism D1, the mask↔domain-agent boundary D2, the add-a-capability path D3; names client Statements in D5 as a near-term candidate. This ADR specifies that Statements mask, one mask per ADR.)"
  - "ADR-049-intent-layer-client-facing-agent-masks.md (defines the mask artefact + the six §D3 fields, the §D2 gate chain, the §D4 thresholds + step-up. This ADR adds one new mask under that contract, unchanged.)"
related:
  - "ADR-054-analytics-reporting-client-facing-mask-c7.md (Analytics / Reporting C7 mask — the second extended-catalogue entry and the first read-side / AUTO-biased mask; this ADR is the third entry and the read+generate counterpart, sharing the data-egress / export gate posture C7 established. ADR-054 §D5 explicitly deferred Statements to this successor ADR.)"
  - "ADR-045-intent-first-banking-architecture.md (Intent-First Banking — the four-layer model; client surface is L1→L2; \"show me my statement\" is a canonical conversational intent)"
  - "ADR-046-decision-lineage-schema.md (Decision Lineage Schema — every masked action emits one AgentDecisionRecord)"
  - "ADR-047-ai-cost-governance-policy.md (AI Cost Governance Policy — every mask carries a cost-cap; AUTO/REVIEW/BLOCK reused)"
  - "ADR-048-business-process-repository.md (Business Process Repository — intents resolve to a governed process_ref before dispatch)"
  - "../../decisions/ADR-016-ai-plane-pii-aml-routing.md (AI Plane / PII-AML routing — compliance_gate overlay; PII overlay on client-fund/personal data)"
  - "../../decisions/ADR-025-agent-interaction-canon.md (Agent Interaction Canon)"
binding_artifact: null
il_anchor: IL-143-STATEMENTS-CLIENT-MASK-2026-06-08
scope: BANXE-only
concept_only: true
---

# ADR-055: Statements Client-Facing Mask — third extended-catalogue entry (extends ADR-049 via ADR-053) for EMI BANXE AI BANK

**Status:** Proposed
**Date:** 2026-06-08
**Source-of-determination:** YAML frontmatter `status: PROPOSED` + body section `## Status` line `PROPOSED — 2026-06-08`
**IL-anchor:** IL-143-STATEMENTS-CLIENT-MASK-2026-06-08
**Scope:** BANXE-only (governance artefact; SPECIFICATION / CONTRACT ONLY — no agent, UI, routing, or port-binding code in this ADR)

## Status

PROPOSED — 2026-06-08. This ADR **extends ADR-049 via the ADR-053 mechanism**. ADR-053 made
the client-facing mask catalogue **extensible** (its D1 mechanism: ADR → CONTRACT port → mask
catalogue entry → mask-bound agent), fixed the **mask↔domain-agent governance boundary** (its
D2: a client intent never reaches a domain service-agent directly — the domain agent is an
adapter *behind* a CONTRACT port, never a client surface), and added the **Cards (C22)** mask
as the first extended-catalogue entry. ADR-053 §D5 named **client Statements**
(`services/client_statements/statement_agent.py` → `StatementPort`) as a clear near-term
candidate "to be specified next", and **ADR-054** then specified the **Analytics / Reporting
(C7)** mask as the second entry while its §D5 **explicitly deferred Statements to a successor
ADR** ("Statements remain to be specified in a successor ADR — they will follow the same D1
mechanism and D2 boundary: StatementPort authored/confirmed, a Statements mask added, a
client-facing agent built, `statement_agent.py` wired behind the port as the adapter,
untouched"). This ADR is that successor: under ADR-053's chosen cadence of **one new mask per
ADR**, it adds **only the Statements mask**. It is **SPECIFICATION / CONTRACT ONLY** — it
implements no agent, port binding, UI, or routing.

## Context

ADR-053 §D5 and ADR-054 §D5 both list client Statements as the next catalogue candidate with
an existing domain service-agent:

| Capability | Existing domain service-agent (→ becomes adapter behind port) | Indicative port | Note |
|------------|----------------------------------------------------------------|-----------------|------|
| **Client statements** | `services/client_statements/statement_agent.py` (+ `statement_generator.py`, `statement_models.py`) | `StatementPort` | "to be specified next — statement generation/read; PII overlay; AUTO-with-cap reads" (ADR-053 §D5; ADR-054 §D5 deferred to this ADR) |

This ADR specifies that mask. Three facts make it the right next mask after Analytics (C7):

- **Statements already have a working domain service-agent** that pre-dates ADR-049 and is
  **not** Intent-First-governed. `services/client_statements/statement_agent.py` (with
  `statement_generator.py` — `StatementGenerator.generate`, `email_statement`,
  `propose_correction`/HITL — and `statement_models.py`, fed by an internal
  `StatementDataPort`) embodies real statement-generation/delivery business logic in
  `banxe-emi-stack`, but has no mask, no `confirmation_policy`, no `compliance_gate` field, no
  `lineage_obligation`, and no `cost_cap`. Per PRIORITY-MAP, client statements are a
  reporting/statements capability with **no single Cn** (ADR-053 §D5 table) — a real
  capability with existing code, not greenfield.

- **Statements are a read+generate surface — the natural read-side companion to Analytics
  (C7), one notch heavier on egress.** Like C7, the statement operations
  (`get_statement`, `list_statements`, `generate_statement`) are **read/generate** ops: they
  do **not** move money and do **not** mutate funds. But unlike a spend summary, a generated
  statement is a **PII-bearing, funds-data artefact** (it itemises the client's own
  transactions and balances), and the existing agent already exposes a **delivery** path
  (`email_statement`). Statements therefore make the **data-egress / export gate** ADR-054
  established for C7 the *primary* gate: AUTO to read/generate the client's **own**
  statements, REVIEW to **deliver** one to an external channel/address.

- **"Show me my statement" is a canonical conversational intent.** "Send me my March
  statement", "download my Q2 statement of account" is an explicitly Intent-First
  conversational intent class (the same client-surface pattern as ADR-054's "how much did I
  spend?"). Today that intent has **no governed client surface**: routed straight to
  `statement_agent.py` it would reach generation **and `email_statement` delivery** of a
  PII-bearing funds artefact **bypassing every ADR-049 gate** (no lineage, no cost-cap on
  potentially heavy generation, no PII overlay, no data-egress gate on delivery) — exactly the
  ungoverned-intent-path drift ADR-045/049/053/054 exist to prevent.

Per ADR-053 D2, the resolution is **not** to expose `statement_agent.py` directly and **not**
to rewrite its logic into a client-facing agent: it is to put a **`StatementPort` CONTRACT
boundary** in front of it, add a **mask** governing that port's read/generate/deliver
operations, and (in a later build sprint) build a mask-bound client-facing `StatementAgent`
that calls the port through the §D2 chain — with `statement_agent.py` (and
`statement_generator.py` / `statement_models.py` / `StatementDataPort`) sitting **behind**
`StatementPort` as the adapter, **untouched**.

This ADR is **SPECIFICATION / CONTRACT ONLY**. It authors no `StatementPort`, no
client-facing `StatementAgent`, and no wiring; those are a factory build sprint (§E), gated
exactly as ADR-049 §D6/§D7, ADR-053 §E and ADR-054 §E require (`AGENT_ROUTING_ENABLED` stays
false until the `.claude/rules/agents.md` ARL preconditions are met; LLM-orchestration
readiness owned by Terminal A).

## Decision

### D1 — Add the Statements mask to the extended catalogue

The **Statements** mask is added as the **third** entry of the extended (post-initial-six)
client-facing mask catalogue, after Cards (C22, ADR-053 §D4) and Analytics / Reporting (C7,
ADR-054 §D1). It is added by the fixed ADR-053 §D1 mechanism (ADR → CONTRACT port → mask
catalogue entry → mask-bound agent) and sits under the ADR-049 §D2 gate chain and §D4
thresholds, both **unchanged**. All six ADR-049 §D3 fields are populated below; concrete
values (operation lists, the materiality of "external delivery", cap numbers) are
**config-as-data** (CLAUDE.md §10) set in the build sprint, **NOT** fixed here.

| Field | Statements mask — indicative |
|-------|------------------------------|
| `scope` | **`StatementPort` read/generate/deliver operations only** — e.g. `get_statement(statement_id)`, `list_statements(entity_id, period)`, `generate_statement(entity_id, period)`, `deliver_statement(statement_id, channel)`. Read and generation of the **client's own** statements, plus delivery of an already-generated statement. The allow-list; nothing outside `StatementPort` is reachable through this mask. **NO money-movement, NO mutation of funds, NO write to client balances** — the port exposes reads, statement generation, and delivery only. |
| `autonomy_level` | **AUTO-biased** (read/generate of the client's own statements is low consequence). Getting, listing and generating the client's own statements are AUTO-with-cap. The only non-AUTO posture is for **delivery to an external channel/address** (data-egress of a PII-bearing statement), which steps to REVIEW (see `confirmation_policy`). |
| `confirmation_policy` | **AUTO within cost-cap** for `get_statement` / `list_statements` / `generate_statement` of the **client's own** statements. **REVIEW** for **`deliver_statement` to an external channel/address** (email / export / any send of the PII-bearing statement **outside the app**) — i.e. anything that egresses personal + funds data beyond the application boundary. **NO biometric step-up** — there is no money movement, so the ADR-049 §D4 critical-money-movement step-up does not apply; the gate here is data-egress, not value-bearing-action. |
| `cost_cap` | ADR-047 **hard caps**, per-request **and** per-window, in token AND monetary (Decimal) dimensions. Statement **generation can be heavy** (multi-period itemisation, document rendering), so the per-request and per-window **token** caps are emphasised to prevent runaway generation; a cap breach halts the action (ADR-047 §D4), independent of confidence. Values config-as-data. |
| `lineage_obligation` | One `AgentDecisionRecord` (ADR-046) **per action** on every exit path — non-optional, identical to every other mask. |
| `compliance_gate` | **PII overlay (ADR-016) on any client-fund / personal data** — statements itemise the client's transactions and balances, so they are personal **and** funds data and the PII overlay applies to read, generate **and** deliver; **data-egress / export gate** on `deliver_statement` (and any operation that emits/sends a downloadable or external artefact). Ruflo applies where an action is compliance-classed per `.claude/rules/agents.md`; statement reads/generation are not payment/kyc, so Ruflo is not mandatory middleware here, but the PII + data-egress overlays are. |

Behind this mask, the existing `services/client_statements/statement_agent.py` (with
`statement_generator.py` — `StatementGenerator.generate`, `email_statement`,
`propose_correction`/HITL — `statement_models.py`, and the internal `StatementDataPort`) is
the `StatementPort` adapter (D3 step 4), **untouched**.

### D2 — Boundary treatment: `statement_agent.py` is the adapter behind `StatementPort`, untouched

Per the ADR-053 §D2 boundary principle, Statements have two kinds of agent on opposite sides
of a CONTRACT port:

| | **Client-facing agent** (Intent-First L2) | **Domain service-agent** (pre-existing) |
|---|---|---|
| Example | a built `StatementAgent` in `services/agents/` | `services/client_statements/statement_agent.py` (+ `statement_generator.py` / `statement_models.py` / internal `StatementDataPort`) |
| Governed by | the **Statements mask** (D1); §D2 gate chain; ADR-046 lineage; ADR-047 cost-cap | statement-generation/delivery business rules of its service; **NOT** Intent-First-governed |
| Client-reachable? | **Yes** — the client entry point for statement read/generate/deliver intents, through L1→L2 | **No** — never a client entry point |
| Role | the **client surface**; calls `StatementPort` | the **implementation behind** the port; an adapter |
| Position | **in front of** `StatementPort` | **behind** `StatementPort` |

Consequences (inherited verbatim from ADR-053 §D2 / ADR-054 §D2):

- **Direct intent → `statement_agent.py` routing is forbidden.** A statement read/generate/
  deliver intent traverses the ADR-049 §D2 chain to the mask-governed client-facing
  `StatementAgent`, which calls `StatementPort`. Routing an intent straight to
  `statement_agent.py` — especially to its `email_statement` delivery path — would be an
  ungoverned read/PII/egress surface (no lineage, no cost-cap, no PII overlay, no export
  gate).
- **`statement_agent.py` is NOT rewritten or duplicated.** Its generation/delivery business
  logic (`StatementGenerator.generate`, `email_statement`, `propose_correction`/HITL) is
  preserved **untouched** behind `StatementPort`; the client-facing agent enforces the gates
  and delegates the actual read/generate/deliver call to the port, which the adapter fulfils.
  This avoids both ungoverned exposure and logic duplication/drift.
- **`StatementPort` is the boundary object.** The mask `scope` allow-lists its
  read/generate/deliver operations (in front); `statement_agent.py` implements them (behind).
  Neither side reaches across the port. The pre-existing internal `StatementDataPort` is an
  implementation detail **inside** the adapter, distinct from the governance CONTRACT
  `StatementPort` that fronts it.
- **`statement_agent.py` is not in violation by existing** — it is a purely
  internal/back-office component and simply **not** client-reachable until a mask +
  client-facing agent is put in front of it. This ADR opens no such surface; it only specifies
  the mask.

### D3 — The add-a-capability path for Statements (the four ADR-053 §D1/§D3 steps)

To make Statements client-reachable, follow ADR-053's mechanism with `statement_agent.py`
wired behind the port:

1. **Author / confirm a CONTRACT port — `StatementPort`** (hexagonal, in the appropriate code
   repo) exposing the governed **read/generate/deliver** operations only (e.g.
   `get_statement(statement_id)`, `list_statements(entity_id, period)`,
   `generate_statement(entity_id, period)`, `deliver_statement(statement_id, channel)`). The
   port is the allow-list surface; nothing outside it is reachable through the mask. **No
   mutation / no money-movement operation is placed on this port.**
2. **Add the Statements mask to the catalogue** (D1 above) with all six fields populated as
   config-as-data.
3. **Build the client-facing `StatementAgent` in `services/agents/`** (mirroring the
   ADR-049/IL-132 L2 agents, the ADR-053 Cards line, and the ADR-054 Analytics line) that
   calls `StatementPort` through the full §D2 chain and emits an `AgentDecisionRecord` per
   action.
4. **Wire the EXISTING `services/client_statements/statement_agent.py` (and its
   `statement_generator.py` / `statement_models.py` / internal `StatementDataPort`) BEHIND
   `StatementPort` as the adapter, untouched** — its generation/delivery business logic
   becomes the port's implementation. The client-facing `StatementAgent` never calls
   `statement_agent.py` directly; it calls `StatementPort`, which the adapter fulfils.

No step is skippable and the order is fixed (ADR → CONTRACT port → mask entry → mask-bound
agent). Steps 1, 3 and 4 are **deferred** to a factory build sprint (§E), exactly as the Cards
line (ADR-053 §E / IL-140) and the Analytics line (ADR-054 §E) were. Only step 2 — the mask
catalogue entry — is performed by this ADR (as specification).

### D4 — L1→L2 path; StatementPort CONTRACT + client-facing StatementAgent are the next build steps (deferred)

Statements' client surface is the Intent-First **L1→L2** path (ADR-045): a client
conversational intent ("show me my statement", "send me my March statement", "download my Q2
statement of account") is resolved at L1 to a governed `process_ref` (ADR-048), checked against
the Statements mask `scope`, run through the `confirmation_policy` (AUTO for read/generate of
the client's own statements; REVIEW for delivery to an external channel/address), dispatched to
`StatementPort` at L2, enforced at L3 (PII + data-egress overlay), and recorded as one
`AgentDecisionRecord` (ADR-046) within cap (ADR-047) under one `correlation_id`.

The **`StatementPort` CONTRACT** and the **mask-bound client-facing `StatementAgent`** are the
**next build steps**, and they are **deferred** — exactly as Cards was deferred by ADR-053
(its §E left CardPort + CardsAgent to a build sprint; IL-140 recorded the Cards client-facing
line) and Analytics by ADR-054 (§E left AnalyticsPort + AnalyticsAgent). This ADR adds the
Statements mask specification only; it opens no port to clients.

### D5 — One mask per ADR; the extended catalogue after this entry

Per ADR-053's chosen cadence ("one new mask per ADR"; its Alternatives rejected adding several
masks in one ADR), this ADR adds **only** the Statements mask. With Cards (C22, ADR-053),
Analytics / Reporting (C7, ADR-054) and Statements (this ADR) the named near-term candidates of
ADR-053 §D5 are now all specified; any **further** capability (a new Cn from PRIORITY-MAP with
an existing or new domain service-agent) follows the same D1 mechanism and D2 boundary in its
own successor ADR/IL increment, with its own CONTRACT port and values.

### D6 — No new governance scale; all ADR-049/053/054 gates inherited unchanged

This ADR introduces **no** new confidence/threshold scale, **no** new mask field, and **no**
new gate. It reuses ADR-049 §D3 (the six mask fields), §D2 (the gate chain), §D4 (AUTO > 0.90
/ REVIEW 0.70–0.90 / BLOCK < 0.70; the critical-money-movement biometric step-up **does not
apply** to Statements because the mask scopes no money movement), §D5 (chat-first UX), the
ADR-053 D1 mechanism + D2 boundary, the ADR-054 data-egress / export gate posture, and the
ADR-046/047/048 obligations verbatim. The only addition is one new catalogue **entry**
(Statements, D1) and its boundary/path treatment (D2/D3) — the read+generate+deliver
counterpart of the Analytics mask, making **data-egress on delivery** the primary gate.

### E — Specification/contract scope only; no implementation here

This ADR authors **no** code. Deferred to a factory build sprint (produced through the
Software Factory — ADR-045 §D3/§D4; Central does not mutate project code directly), and gated
exactly as ADR-049 §D6/§D7, ADR-053 §E and ADR-054 §E already require:

- authoring `StatementPort` as a hexagonal CONTRACT port exposing read/generate/deliver
  operations only;
- building the client-facing `StatementAgent` in `services/agents/` bound to the port through
  the §D2 chain;
- wiring the existing `statement_agent.py` (+ `statement_generator.py` / `statement_models.py`
  / internal `StatementDataPort`) behind `StatementPort` as the adapter (untouched business
  logic);
- the concrete mask **values** (operation lists, the external-delivery materiality, cost-cap
  numbers — per-request and per-window token caps emphasised for heavy generation) as
  config-as-data;
- the ADR-046 lineage, ADR-047 cost-cap, ADR-016 PII overlay, and data-egress/export gate
  wiring at the Statements mask boundary.

`AGENT_ROUTING_ENABLED` remains **false** until the ARL preconditions of
`.claude/rules/agents.md` are met, and any build presupposes Terminal-A LLM-orchestration
readiness (ADR-049 §D6 / ADR-040 meta-plane). **This ADR opens no CONTRACT port to clients** —
`StatementPort` becomes client-reachable only when a built, mask-bound, gated `StatementAgent`
is deployed through the factory with all §D2 gates in place.

## Consequences

**Positive**

+ Adds the **Statements** mask — the third extended-catalogue entry and the read+generate+
  deliver counterpart of the Analytics mask — with a regulation-appropriate posture
  (read/generate of the client's own statements AUTO-with-cap; external delivery REVIEW; PII
  overlay + data-egress gate; no money movement, hence no biometric step-up).
+ Gives the canonical "show me / send me my statement" conversational intent a **governed
  client surface** for the first time, closing a real ungoverned read/PII/egress path (an
  intent hitting `statement_agent.py` — and its `email_statement` delivery — directly,
  bypassing lineage, cost-cap, PII overlay, and the delivery egress gate).
+ Makes **data-egress on delivery** the primary gate for a PII-bearing funds artefact,
  reusing and sharpening the export-gate posture ADR-054 established for C7 — reusable by every
  future statement/report/document mask.
+ **Reuses, not rewrites, existing domain logic.** `statement_agent.py` (+
  `statement_generator.py` / `statement_models.py` / `StatementDataPort`) is preserved
  untouched behind `StatementPort` — no duplication, no drift.
+ Completes the ADR-053 §D5 near-term candidate set (Cards, Analytics, Statements) under the
  one-mask-per-ADR cadence; further capabilities are cleanly sequenced next.

**Negative / costs**

- Specification artefact only: nothing operational changes until the factory builds
  `StatementPort`, the client-facing `StatementAgent`, and the config. Until then client
  statements remain non-client-reachable.
- Statements now carry the full ADR-049/053/054 ceremony (ADR + port + mask + gated agent) —
  deliberately more friction than wiring a statement intent straight to `statement_agent.py`;
  that friction is the regulatory boundary (PII + egress), not overhead.
- The mask's coherence depends on `StatementPort`, ADR-016 (PII), ADR-046/047, and the
  `statement_agent.py` adapter staying aligned; a change to any must keep the mask contract
  resolvable.
- Hard dependency (inherited from ADR-049 §D6) on Terminal-A LLM-orchestration readiness; no
  build against this spec proceeds until that precondition is met, which this ADR does not
  control.

## Alternatives considered

- **Route statement read/generate/deliver intents directly to `statement_agent.py`**
  (rejected: a client intent reaching the statement agent without a mask bypasses the §D2 gate
  chain, ADR-046 lineage, the ADR-047 cost-cap on heavy generation, the ADR-016 PII overlay on
  a transactions/balances artefact, and the data-egress/export gate on `email_statement`
  delivery — an ungoverned read/PII/egress surface, the exact drift ADR-045/049/053/054
  prevent).
- **Rewrite `statement_agent.py` as a mask-governed client-facing agent in place** (rejected:
  duplicates/relocates working generation/delivery logic, invites drift and double-maintenance,
  conflates the two roles ADR-053 §D2 separates; the boundary keeps domain logic untouched
  behind `StatementPort` and adds the client surface in front).
- **Add Statements together with Analytics in ADR-054 (or fold into ADR-053)** (rejected:
  ADR-053 chose one new mask per ADR and its Alternatives explicitly rejected multi-mask ADRs;
  ADR-054 §D5 explicitly deferred Statements to this successor ADR; Statements get their own
  ADR/IL increment with their own `StatementPort` and values).
- **Give the Statements mask a biometric step-up `confirmation_policy`** (rejected: ADR-049 §D4
  step-up is for *critical money movement*; Statements scope read/generate/deliver operations
  with no money movement, so step-up does not apply. The appropriate gate is data-egress for
  external delivery — REVIEW, not biometric).
- **Make `deliver_statement` AUTO like the reads** (rejected: delivery to an external
  channel/address egresses a PII-bearing funds artefact outside the application boundary; that
  is precisely the data-egress event ADR-054 placed under REVIEW — read/generate of the
  client's own statement is low-consequence, sending it out is not).
- **Put export/mutation/money operations on `StatementPort`** (rejected: `StatementPort` is a
  read/generate/deliver boundary by construction; any money-movement or fund-mutation
  capability belongs to a different port and a different mask with its own posture — keeping
  Statements free of fund mutation is what makes it AUTO-biased and low-consequence).
- **Allow a Statements mask without `StatementPort` (mask scoping the capability directly)**
  (rejected: re-introduces the undeclared port binding ADR-049 §D3 / ADR-053 D1 forbid; the
  port is the boundary object and the allow-list anchor — no port, no mask).

## Relationship to ADR-054 / ADR-053 / ADR-049 and the governance siblings

- **ADR-054 (Analytics / Reporting Client-Facing Mask C7).** This ADR is the **next
  application** after C7: the same D1 mechanism and D2 boundary, the same read-side AUTO-biased
  posture, and the **same data-egress / export gate** — here made the *primary* gate because a
  statement is a PII-bearing funds artefact with a delivery path. ADR-054 §D5 explicitly
  deferred Statements to this ADR.
- **ADR-053 (Mask Catalogue Extensibility & Mask↔Domain-Agent Boundary).** This ADR applies
  ADR-053's D1 mechanism and D2 boundary, adding the Statements mask ADR-053 §D5 named as a
  near-term candidate, with `statement_agent.py` as the adapter behind `StatementPort`.
  ADR-053's one-mask-per-ADR cadence is why Statements were sequenced after Cards and Analytics.
- **ADR-049 (Intent Layer & Client-Facing Agent Masks).** The Statements mask carries all six
  §D3 fields, runs under the §D2 gate chain, and reuses the §D4 thresholds (with no step-up, as
  Statements scope no money movement). Every ADR-049 gate is inherited unchanged.
- **ADR-046 (Decision Lineage Schema).** The Statements mask's `lineage_obligation` is one
  `AgentDecisionRecord` per action — identical to every other mask.
- **ADR-047 (AI Cost Governance Policy).** The Statements mask carries per-request and
  per-window hard caps (token + monetary Decimal); the token caps are emphasised against heavy
  statement generation; a cap breach halts the action.
- **ADR-048 (Business Process Repository).** A statement read/generate/deliver intent still
  resolves to a governed `process_ref` before mask dispatch; an unresolved intent is a
  governance event.
- **ADR-016 (AI Plane / PII-AML routing).** Supplies the **PII overlay** for the Statements
  `compliance_gate` on the transactions/balances data surfaced by a read, generate, or
  delivery.
- **`StatementPort`** is the boundary object: the mask `scope` allow-lists its
  read/generate/deliver operations (in front); the existing `statement_agent.py` implements
  them (behind). It extends the six initial ports + ADR-053's `CardPort` + ADR-054's
  `AnalyticsPort`.
- **ADR-025 / `.claude/rules/agents.md`** supply the HITL bands; statement reads/generation are
  not payment/kyc, so Ruflo is not mandatory middleware for Statements, but the PII +
  data-egress overlays are.
- **PRIORITY-MAP (C1–C30)** is the capability source: client statements are a
  reporting/statements capability with no single Cn (ADR-053 §D5), brought under governance
  here.
- **IL-132 / IL-135 / IL-140 / IL-141** record the L2 code of the initial six masks, their
  lineage/cost primitives, the Cards client-facing line, and the Analytics mask — the pattern
  the Statements client-facing `StatementAgent` mirrors.

## Anchors

- ADR-054 (`docs/adr/ADR-054-analytics-reporting-client-facing-mask-c7.md` — the second extended-catalogue entry and the read-side data-egress gate posture; its §D5 deferred Statements to this ADR)
- ADR-053 (`docs/adr/ADR-053-client-facing-mask-extensibility-and-domain-agent-boundary.md` — the D1 extensibility mechanism, D2 mask↔domain-agent boundary, D3 add-a-capability path, D5 names Statements as a near-term candidate; this ADR specifies the Statements mask)
- ADR-049 (`docs/adr/ADR-049-intent-layer-client-facing-agent-masks.md` — the mask artefact, the §D2 chain, §D3 mask fields, §D4 thresholds + step-up; this ADR adds one mask under that contract)
- ADR-045 (`docs/adr/ADR-045-intent-first-banking-architecture.md` — Intent-First four-layer model; client surface is L1→L2; "show me my statement" is a canonical conversational intent)
- ADR-046 (`docs/adr/ADR-046-decision-lineage-schema.md` — `AgentDecisionRecord`; mask `lineage_obligation` per action)
- ADR-047 (`docs/adr/ADR-047-ai-cost-governance-policy.md` — hard cost caps; AUTO/REVIEW/BLOCK; mask `cost_cap`; per-request + per-window token caps emphasised for heavy statement generation)
- ADR-048 (`docs/adr/ADR-048-business-process-repository.md` — intent→`process_ref` resolution; precedes mask dispatch)
- ADR-025 (`decisions/ADR-025-agent-interaction-canon.md` — agent interaction canon)
- ADR-016 (`decisions/ADR-016-ai-plane-pii-aml-routing.md` — PII/AML routing overlay; PII overlay for the Statements `compliance_gate` on the transactions/balances artefact)
- ADR-040 (`docs/adr/ADR-040-ai-execution-policy.md` — meta-plane vs inference-plane; the LLM-orchestration substrate L2 depends on, Terminal A)
- The CONTRACT ports — the six initial (WalletPort, PartnerPort, ExchangePort, KYCProviderPort, NotificationProviderPort, CRMProviderPort) + ADR-053's `CardPort` + ADR-054's `AnalyticsPort` + the new **`StatementPort`** — the boundary objects masks scope and domain agents implement
- Pre-existing domain service-agent (becomes adapter behind port, untouched): `services/client_statements/statement_agent.py` (+ `statement_generator.py` — `StatementGenerator.generate`, `email_statement`, `propose_correction`/HITL — `statement_models.py`, internal `StatementDataPort`) — in `banxe-emi-stack`
- `docs/refactor/legacy/NEW-PROJECT-PRIORITY-MAP-2026-06-06.md` (capabilities C1–C30; client statements = reporting/statements, no single Cn per ADR-053 §D5; brought under governance here)
- `docs/BANXE-UI-UX-SYSTEM.md` ("show me / send me my statement" — the canonical conversational intent; Intent-First chat-first surface)
- `.claude/rules/agents.md` (HITL AUTO/REVIEW/BLOCK; ARL `AGENT_ROUTING_ENABLED=false` precondition; Ruflo not mandatory for statement reads/generation)
- `R-COMP-FCA-02` (continuous-compliance / agentic-AI auditability); GDPR/UK-GDPR data-egress/export controls (D1 delivery-gate rationale)
- CLAUDE.md §10 (config-over-hardcoding — mask values, caps, external-delivery materiality as governed data), §11 (no ungoverned consequential action), money rule (Decimal, never float)
- INSTRUCTION-LEDGER.md → IL-143-STATEMENTS-CLIENT-MASK-2026-06-08
