---
id: ADR-054
title: Analytics / Reporting Client-Facing Mask (C7) — second extended-catalogue entry (extends ADR-049 via ADR-053) for EMI BANXE AI BANK
status: PROPOSED
date: 2026-06-08
accepted: null
supersedes: []
extends:
  - "ADR-053-client-facing-mask-extensibility-and-domain-agent-boundary.md (defines the extensibility mechanism D1, the mask↔domain-agent boundary D2, the add-a-capability path D3; names C7 Analytics in D5 as the next candidate. This ADR specifies that C7 mask, one mask per ADR.)"
  - "ADR-049-intent-layer-client-facing-agent-masks.md (defines the mask artefact + the six §D3 fields, the §D2 gate chain, the §D4 thresholds + step-up. This ADR adds one new mask under that contract, unchanged.)"
related:
  - "ADR-045-intent-first-banking-architecture.md (Intent-First Banking — the four-layer model; client surface is L1→L2; spend-analysis is a canonical conversational intent)"
  - "ADR-046-decision-lineage-schema.md (Decision Lineage Schema — every masked action emits one AgentDecisionRecord)"
  - "ADR-047-ai-cost-governance-policy.md (AI Cost Governance Policy — every mask carries a cost-cap; AUTO/REVIEW/BLOCK reused)"
  - "ADR-048-business-process-repository.md (Business Process Repository — intents resolve to a governed process_ref before dispatch)"
  - "../../decisions/ADR-016-ai-plane-pii-aml-routing.md (AI Plane / PII-AML routing — compliance_gate overlay; PII overlay on client-fund/personal data)"
  - "../../decisions/ADR-025-agent-interaction-canon.md (Agent Interaction Canon)"
binding_artifact: null
il_anchor: IL-141-ANALYTICS-REPORTING-CLIENT-MASK-C7-2026-06-08
scope: BANXE-only
concept_only: true
---

# ADR-054: Analytics / Reporting Client-Facing Mask (C7) — second extended-catalogue entry (extends ADR-049 via ADR-053) for EMI BANXE AI BANK

**Status:** Proposed
**Date:** 2026-06-08
**Source-of-determination:** YAML frontmatter `status: PROPOSED` + body section `## Status` line `PROPOSED — 2026-06-08`
**IL-anchor:** IL-141-ANALYTICS-REPORTING-CLIENT-MASK-C7-2026-06-08
**Scope:** BANXE-only (governance artefact; SPECIFICATION / CONTRACT ONLY — no agent, UI, routing, or port-binding code in this ADR)

## Status

PROPOSED — 2026-06-08. This ADR **extends ADR-049 via the ADR-053 mechanism**. ADR-053 made
the client-facing mask catalogue **extensible** (its D1 mechanism: ADR → CONTRACT port → mask
catalogue entry → mask-bound agent), fixed the **mask↔domain-agent governance boundary** (its
D2: a client intent never reaches a domain service-agent directly — the domain agent is an
adapter *behind* a CONTRACT port, never a client surface), and added the **Cards (C22)** mask
as the first extended-catalogue entry. ADR-053 §D5 named **C7 Portfolio analytics**
(`services/reporting_analytics/analytics_agent.py`) and **client statements** as the clear
near-term candidates "to be specified next", and ADR-053 chose **one new mask per ADR** (its
"Alternatives considered" rejected adding several masks in one ADR). This ADR honours that
sequencing: it adds **only the Analytics / Reporting (C7) mask**; client **Statements** remain
deferred to a later ADR. It is **SPECIFICATION / CONTRACT ONLY** — it implements no agent,
port binding, UI, or routing.

## Context

ADR-053 §D5 listed two near-term catalogue candidates with existing domain service-agents:

| Capability | Existing domain service-agent (→ becomes adapter behind port) | Indicative port | ADR-053 §D5 note |
|------------|----------------------------------------------------------------|-----------------|------------------|
| **C7 Portfolio analytics** | `services/reporting_analytics/analytics_agent.py` | `AnalyticsPort` (or read-only ReportingPort) | "to be specified next — reads AUTO-with-cap; PII overlay on any client-fund data" |
| **Client statements** | `services/client_statements/statement_agent.py` | `StatementPort` | "to be specified next — statement generation/read; PII overlay; AUTO-with-cap reads" |

This ADR specifies the **first** of those two, C7. Three facts make it the right next mask:

- **C7 already has a working domain service-agent** that pre-dates ADR-049 and is **not**
  Intent-First-governed. `services/reporting_analytics/analytics_agent.py` (with its
  `data_aggregator` / `report_builder` / `export_engine` collaborators) embodies real
  reporting/analytics business logic in `banxe-emi-stack`, but has no mask, no
  `confirmation_policy`, no `compliance_gate` field, no `lineage_obligation`, and no
  `cost_cap`. Per PRIORITY-MAP, C7 (Portfolio analytics) is `legacy-serves (rewrite Python)`
  / `crypto-api-portfolio (SPEC #7)` — a real capability with existing code, not greenfield.

- **C7 is a low-consequence read/reporting surface — the cleanest possible extension after
  Cards.** Unlike Cards (a money-class capability with protective/credit-affecting
  mutations), the `reporting_analytics` operations are **read/aggregate/report** ops:
  aggregate, multi-source aggregate, time-series rollup, report request/export. They do
  **not** move money and do **not** mutate funds. This makes C7 the natural AUTO-biased
  counterpart to the Mixed-autonomy Cards mask — it exercises the read end of the mask
  contract and establishes the **data-egress / export** gate posture for the catalogue.

- **Spend analysis is a canonical conversational intent.** "How much did I spend on FX last
  month?" is an explicitly listed Intent-First conversational intent
  (`docs/BANXE-UI-UX-SYSTEM.md`), the same intent class that products built around
  conversational banking (the bunq "how much did I spend" pattern) treat as a first-class
  surface. Today that intent has **no governed client surface**: routed straight to
  `analytics_agent.py` it would reach the reporting capability **bypassing every ADR-049
  gate** (no lineage, no cost-cap on potentially compute-heavy aggregation, no PII overlay on
  client-fund data, no export/egress gate) — exactly the ungoverned-intent-path drift
  ADR-045/049/053 exist to prevent.

Per ADR-053 D2, the resolution is **not** to expose `analytics_agent.py` directly and **not**
to rewrite its logic into a client-facing agent: it is to put an **`AnalyticsPort` CONTRACT
boundary** in front of it, add a **mask** governing that port's read/report operations, and
(in a later build sprint) build a mask-bound client-facing `AnalyticsAgent` that calls the
port through the §D2 chain — with `analytics_agent.py` sitting **behind** `AnalyticsPort` as
the adapter, **untouched**.

This ADR is **SPECIFICATION / CONTRACT ONLY**. It authors no `AnalyticsPort`, no
client-facing `AnalyticsAgent`, and no wiring; those are a factory build sprint (§E), gated
exactly as ADR-049 §D6/§D7 and ADR-053 §E require (`AGENT_ROUTING_ENABLED` stays false until
the `.claude/rules/agents.md` ARL preconditions are met; LLM-orchestration readiness owned by
Terminal A).

## Decision

### D1 — Add the Analytics / Reporting (C7) mask to the extended catalogue

The **Analytics / Reporting (C7)** mask is added as the **second** entry of the extended
(post-initial-six) client-facing mask catalogue, after Cards (C22, ADR-053 §D4). It is added
by the fixed ADR-053 §D1 mechanism (ADR → CONTRACT port → mask catalogue entry → mask-bound
agent) and sits under the ADR-049 §D2 gate chain and §D4 thresholds, both **unchanged**. All
six ADR-049 §D3 fields are populated below; concrete values (operation lists, materiality
thresholds for "large/sensitive export", cap numbers) are **config-as-data** (CLAUDE.md §10)
set in the build sprint, **NOT** fixed here.

| Field | Analytics / Reporting (C7) mask — indicative |
|-------|----------------------------------------------|
| `scope` | **`AnalyticsPort` read-only / reporting operations only** — e.g. `get_spending_summary`, `get_portfolio_view`, `get_report`, `list_available_reports`, `request_export`, plus the underlying read primitives (`aggregate`, `multi_source_aggregate`, `time_series_rollup`). The allow-list; nothing outside `AnalyticsPort` is reachable through this mask. **NO money-movement, NO mutation of funds, NO write to client balances** — the port exposes reads/reporting only. |
| `autonomy_level` | **AUTO-biased** (read-only, low consequence). Summaries, portfolio views, time-series rollups and report reads are AUTO-with-cap. The only non-AUTO posture is for data-egress (export) of large/sensitive datasets, which steps to REVIEW (see `confirmation_policy`). |
| `confirmation_policy` | **AUTO within cost-cap** for reads and summaries (spend summary, portfolio view, report read, list-reports). **REVIEW** only for **export of large/sensitive datasets** (data-egress crossing the configured materiality) **or** anything **templating client-funds data** into an exportable artefact. **NO biometric step-up** — there is no money movement, so the ADR-049 §D4 critical-money-movement step-up does not apply; the gate here is data-egress, not value-bearing-action. |
| `cost_cap` | ADR-047 **hard caps**, per-request **and** per-window, in token AND monetary (Decimal) dimensions. Analytics can be **compute-heavy** (multi-source aggregation, long time-series rollups), so the per-request and per-window **token** caps are emphasised to prevent runaway aggregation; a cap breach halts the action (ADR-047 §D4), independent of confidence. Values config-as-data. |
| `lineage_obligation` | One `AgentDecisionRecord` (ADR-046) **per action** on every exit path — non-optional, identical to every other mask. |
| `compliance_gate` | **PII overlay (ADR-016) on any client-fund / personal data** surfaced by a read or summary; **data-egress / export gate** for `request_export` (and any operation that emits a downloadable/exportable artefact). Ruflo applies where an action is compliance-classed per `.claude/rules/agents.md`; analytics reads are not payment/kyc, so Ruflo is not mandatory middleware here, but the PII + data-egress overlays are. |

Behind this mask, the existing `services/reporting_analytics/analytics_agent.py` (with
`data_aggregator` / `report_builder` / `export_engine`) is the `AnalyticsPort` adapter (D3
step 4), **untouched**.

### D2 — Boundary treatment: `analytics_agent.py` is the adapter behind `AnalyticsPort`, untouched

Per the ADR-053 §D2 boundary principle, C7 has two kinds of agent on opposite sides of a
CONTRACT port:

| | **Client-facing agent** (Intent-First L2) | **Domain service-agent** (pre-existing) |
|---|---|---|
| Example | a built `AnalyticsAgent` in `services/agents/` | `services/reporting_analytics/analytics_agent.py` (+ `data_aggregator` / `report_builder` / `export_engine`) |
| Governed by | the **Analytics (C7) mask** (D1); §D2 gate chain; ADR-046 lineage; ADR-047 cost-cap | reporting/analytics business rules of its service; **NOT** Intent-First-governed |
| Client-reachable? | **Yes** — the client entry point for spend/portfolio/report intents, through L1→L2 | **No** — never a client entry point |
| Role | the **client surface**; calls `AnalyticsPort` | the **implementation behind** the port; an adapter |
| Position | **in front of** `AnalyticsPort` | **behind** `AnalyticsPort` |

Consequences (inherited verbatim from ADR-053 §D2):

- **Direct intent → `analytics_agent.py` routing is forbidden.** A spend/portfolio/report
  intent traverses the ADR-049 §D2 chain to the mask-governed client-facing `AnalyticsAgent`,
  which calls `AnalyticsPort`. Routing an intent straight to `analytics_agent.py` would be an
  ungoverned read/PII/egress surface (no lineage, no cost-cap, no PII overlay, no export
  gate).
- **`analytics_agent.py` is NOT rewritten or duplicated.** Its aggregation/report/export
  business logic is preserved **untouched** behind `AnalyticsPort`; the client-facing agent
  enforces the gates and delegates the actual read/report call to the port, which the adapter
  fulfils. This avoids both ungoverned exposure and logic duplication/drift.
- **`AnalyticsPort` is the boundary object.** The mask `scope` allow-lists its read/report
  operations (in front); `analytics_agent.py` implements them (behind). Neither side reaches
  across the port.
- **`analytics_agent.py` is not in violation by existing** — it is a purely internal/back-office
  component and simply **not** client-reachable until a mask + client-facing agent is put in
  front of it. This ADR opens no such surface; it only specifies the mask.

### D3 — The add-a-capability path for C7 (the four ADR-053 §D1/§D3 steps)

To make C7 client-reachable, follow ADR-053's mechanism with `analytics_agent.py` wired
behind the port:

1. **Author / confirm a CONTRACT port — `AnalyticsPort`** (hexagonal, in the appropriate code
   repo) exposing the governed **read/report** operations only (e.g. `get_spending_summary`,
   `get_portfolio_view`, `get_report`, `list_available_reports`, `request_export`, over the
   `aggregate` / `multi_source_aggregate` / `time_series_rollup` primitives). The port is the
   allow-list surface; nothing outside it is reachable through the mask. **No mutation / no
   money-movement operation is placed on this port.**
2. **Add the C7 mask to the catalogue** (D1 above) with all six fields populated as
   config-as-data.
3. **Build the client-facing `AnalyticsAgent` in `services/agents/`** (mirroring the
   ADR-049/IL-132 L2 agents and the ADR-053 Cards line) that calls `AnalyticsPort` through the
   full §D2 chain and emits an `AgentDecisionRecord` per action.
4. **Wire the EXISTING `services/reporting_analytics/analytics_agent.py` (and its
   `data_aggregator` / `report_builder` / `export_engine`) BEHIND `AnalyticsPort` as the
   adapter, untouched** — its reporting/analytics business logic becomes the port's
   implementation. The client-facing `AnalyticsAgent` never calls `analytics_agent.py`
   directly; it calls `AnalyticsPort`, which the adapter fulfils.

No step is skippable and the order is fixed (ADR → CONTRACT port → mask entry → mask-bound
agent). Steps 1, 3 and 4 are **deferred** to a factory build sprint (§E), exactly as the
Cards line was (ADR-053 §E). Only step 2 — the mask catalogue entry — is performed by this
ADR (as specification).

### D4 — L1→L2 path; AnalyticsPort CONTRACT + client-facing AnalyticsAgent are the next build steps (deferred)

C7's client surface is the Intent-First **L1→L2** path (ADR-045): a client conversational
intent ("how much did I spend on FX last month?", "show my portfolio", "export my Q2
statement of holdings") is resolved at L1 to a governed `process_ref` (ADR-048), checked
against the C7 mask `scope`, run through the `confirmation_policy` (AUTO for the read; REVIEW
if it is a large/sensitive export), dispatched to `AnalyticsPort` at L2, enforced at L3
(PII + data-egress overlay), and recorded as one `AgentDecisionRecord` (ADR-046) within cap
(ADR-047) under one `correlation_id`.

The **`AnalyticsPort` CONTRACT** and the **mask-bound client-facing `AnalyticsAgent`** are
the **next build steps**, and they are **deferred** — exactly as Cards was deferred by
ADR-053 (its §E left CardPort + CardsAgent to a build sprint; IL-140 recorded the Cards
client-facing line). This ADR adds the C7 mask specification only; it opens no port to
clients.

### D5 — One mask per ADR; Statements remain deferred

Per ADR-053's chosen cadence ("one new mask per ADR"; its Alternatives rejected adding
several masks in one ADR), this ADR adds **only** the Analytics / Reporting (C7) mask.
**Client Statements** (`services/client_statements/statement_agent.py` → `StatementPort`),
the other ADR-053 §D5 candidate, remain **to be specified in a successor ADR** — they will
follow the same D1 mechanism and D2 boundary (StatementPort authored/confirmed, a Statements
mask added, a client-facing agent built, `statement_agent.py` wired behind the port as the
adapter, untouched).

### D6 — No new governance scale; all ADR-049/053 gates inherited unchanged

This ADR introduces **no** new confidence/threshold scale, **no** new mask field, and **no**
new gate. It reuses ADR-049 §D3 (the six mask fields), §D2 (the gate chain), §D4 (AUTO > 0.90
/ REVIEW 0.70–0.90 / BLOCK < 0.70; the critical-money-movement biometric step-up **does not
apply** to C7 because the mask scopes no money movement), §D5 (chat-first UX), the ADR-053 D1
mechanism + D2 boundary, and the ADR-046/047/048 obligations verbatim. The only addition is
one new catalogue **entry** (Analytics / Reporting, C7, D1) and its boundary/path treatment
(D2/D3) — the read-side counterpart of the Cards mask, establishing the **data-egress /
export** gate posture for the catalogue.

### E — Specification/contract scope only; no implementation here

This ADR authors **no** code. Deferred to a factory build sprint (produced through the
Software Factory — ADR-045 §D3/§D4; Central does not mutate project code directly), and gated
exactly as ADR-049 §D6/§D7 and ADR-053 §E already require:

- authoring `AnalyticsPort` as a hexagonal CONTRACT port exposing read/report operations only;
- building the client-facing `AnalyticsAgent` in `services/agents/` bound to the port through
  the §D2 chain;
- wiring the existing `analytics_agent.py` (+ `data_aggregator` / `report_builder` /
  `export_engine`) behind `AnalyticsPort` as the adapter (untouched business logic);
- the concrete mask **values** (operation lists, the large/sensitive-export materiality
  threshold, cost-cap numbers — per-request and per-window token caps emphasised) as
  config-as-data;
- the ADR-046 lineage, ADR-047 cost-cap, ADR-016 PII overlay, and data-egress/export gate
  wiring at the C7 mask boundary.

`AGENT_ROUTING_ENABLED` remains **false** until the ARL preconditions of
`.claude/rules/agents.md` are met, and any build presupposes Terminal-A LLM-orchestration
readiness (ADR-049 §D6 / ADR-040 meta-plane). **This ADR opens no CONTRACT port to clients** —
`AnalyticsPort` becomes client-reachable only when a built, mask-bound, gated `AnalyticsAgent`
is deployed through the factory with all §D2 gates in place.

## Consequences

**Positive**

+ Adds the **Analytics / Reporting (C7)** mask — the second extended-catalogue entry and the
  first **read-side / AUTO-biased** mask — with a regulation-appropriate posture (reads/summaries
  AUTO-with-cap; large/sensitive export REVIEW; PII overlay + data-egress gate; no money
  movement, hence no biometric step-up).
+ Gives the canonical "how much did I spend?" conversational intent a **governed client
  surface** for the first time, closing a real ungoverned read/PII/egress path (an intent
  hitting `analytics_agent.py` directly, bypassing lineage, cost-cap, PII overlay, and export
  gate).
+ Establishes the **data-egress / export** gate posture and the **per-request + per-window
  token cap** discipline for compute-heavy aggregation at the mask boundary — reusable by every
  future read/reporting mask.
+ **Reuses, not rewrites, existing domain logic.** `analytics_agent.py` (+ its aggregator /
  report-builder / export-engine collaborators) is preserved untouched behind `AnalyticsPort` —
  no duplication, no drift.
+ Keeps the catalogue growing **one governed mask at a time** (ADR-053 cadence); Statements are
  cleanly sequenced next.

**Negative / costs**

- Specification artefact only: nothing operational changes until the factory builds
  `AnalyticsPort`, the client-facing `AnalyticsAgent`, and the config. Until then C7 analytics
  remains non-client-reachable.
- C7 now carries the full ADR-049/053 ceremony (ADR + port + mask + gated agent) — deliberately
  more friction than wiring a spend-summary intent straight to `analytics_agent.py`; that
  friction is the regulatory boundary (PII + egress), not overhead.
- The mask's coherence depends on `AnalyticsPort`, ADR-016 (PII), ADR-046/047, and the
  `analytics_agent.py` adapter staying aligned; a change to any must keep the mask contract
  resolvable.
- Hard dependency (inherited from ADR-049 §D6) on Terminal-A LLM-orchestration readiness; no
  build against this spec proceeds until that precondition is met, which this ADR does not
  control.

## Alternatives considered

- **Route spend/portfolio/report intents directly to `analytics_agent.py`** (rejected: a client
  intent reaching the reporting agent without a mask bypasses the §D2 gate chain, ADR-046
  lineage, the ADR-047 cost-cap on compute-heavy aggregation, the ADR-016 PII overlay on
  client-fund data, and the data-egress/export gate — an ungoverned read/PII/egress surface,
  the exact drift ADR-045/049/053 prevent).
- **Rewrite `analytics_agent.py` as a mask-governed client-facing agent in place** (rejected:
  duplicates/relocates working reporting logic, invites drift and double-maintenance, conflates
  the two roles ADR-053 §D2 separates; the boundary keeps domain logic untouched behind
  `AnalyticsPort` and adds the client surface in front).
- **Add both Analytics and Statements masks in this ADR** (rejected: ADR-053 chose one new mask
  per ADR and its Alternatives explicitly rejected multi-mask ADRs; Statements get their own
  ADR/IL increment with their own `StatementPort` and values).
- **Give the C7 mask a biometric step-up `confirmation_policy`** (rejected: ADR-049 §D4 step-up
  is for *critical money movement*; C7 scopes read/report operations with no money movement, so
  step-up does not apply. The appropriate gate is data-egress for large/sensitive exports —
  REVIEW, not biometric).
- **Put export/mutation/money operations on `AnalyticsPort`** (rejected: `AnalyticsPort` is a
  read/report boundary by construction; any money-movement or fund-mutation capability belongs
  to a different port and a different mask with its own posture — keeping C7 read-only is what
  makes it AUTO-biased and low-consequence).
- **Allow a C7 mask without `AnalyticsPort` (mask scoping the capability directly)** (rejected:
  re-introduces the undeclared port binding ADR-049 §D3 / ADR-053 D1 forbid; the port is the
  boundary object and the allow-list anchor — no port, no mask).
- **Fold this into ADR-053** (rejected: ADR-053 is the extensibility + boundary + first-mask
  decision and explicitly defers C7 to "be specified next" under one-mask-per-ADR; C7 is a
  distinct catalogue entry with its own port, posture, and alternatives — authored as an
  extending ADR, not a retro-edit).

## Relationship to ADR-053 / ADR-049 and the governance siblings

- **ADR-053 (Mask Catalogue Extensibility & Mask↔Domain-Agent Boundary).** This ADR is the
  **next application** of ADR-053's D1 mechanism and D2 boundary: it adds the C7 mask ADR-053
  §D5 named as next, with `analytics_agent.py` as the adapter behind `AnalyticsPort`. ADR-053's
  one-mask-per-ADR cadence is the reason Statements are deferred (D5).
- **ADR-049 (Intent Layer & Client-Facing Agent Masks).** The C7 mask carries all six §D3
  fields, runs under the §D2 gate chain, and reuses the §D4 thresholds (with no step-up, as C7
  scopes no money movement). Every ADR-049 gate is inherited unchanged.
- **ADR-046 (Decision Lineage Schema).** The C7 mask's `lineage_obligation` is one
  `AgentDecisionRecord` per action — identical to every other mask.
- **ADR-047 (AI Cost Governance Policy).** The C7 mask carries per-request and per-window hard
  caps (token + monetary Decimal); the token caps are emphasised against runaway compute-heavy
  aggregation; a cap breach halts the action.
- **ADR-048 (Business Process Repository).** A spend/portfolio/report intent still resolves to a
  governed `process_ref` before mask dispatch; an unresolved intent is a governance event.
- **ADR-016 (AI Plane / PII-AML routing).** Supplies the **PII overlay** for the C7
  `compliance_gate` on any client-fund/personal data surfaced by a read, summary, or export.
- **`AnalyticsPort`** is the boundary object: the mask `scope` allow-lists its read/report
  operations (in front); the existing `analytics_agent.py` implements them (behind). It extends
  the six initial ports + ADR-053's `CardPort`.
- **ADR-025 / `.claude/rules/agents.md`** supply the HITL bands; analytics reads are not
  payment/kyc, so Ruflo is not mandatory middleware for C7, but the PII + data-egress overlays
  are.
- **PRIORITY-MAP (C1–C30)** is the capability source: C7 (Portfolio analytics) is brought under
  governance here; Statements named next.
- **IL-132 / IL-135 / IL-140** record the L2 code of the initial six masks, their lineage/cost
  primitives, and the Cards client-facing line — the pattern the C7 client-facing `AnalyticsAgent`
  mirrors.

## Anchors

- ADR-053 (`docs/adr/ADR-053-client-facing-mask-extensibility-and-domain-agent-boundary.md` — the D1 extensibility mechanism, D2 mask↔domain-agent boundary, D3 add-a-capability path, D5 names C7 next; this ADR specifies the C7 mask)
- ADR-049 (`docs/adr/ADR-049-intent-layer-client-facing-agent-masks.md` — the mask artefact, the §D2 chain, §D3 mask fields, §D4 thresholds + step-up; this ADR adds one mask under that contract)
- ADR-045 (`docs/adr/ADR-045-intent-first-banking-architecture.md` — Intent-First four-layer model; client surface is L1→L2; spend-analysis is a canonical conversational intent)
- ADR-046 (`docs/adr/ADR-046-decision-lineage-schema.md` — `AgentDecisionRecord`; mask `lineage_obligation` per action)
- ADR-047 (`docs/adr/ADR-047-ai-cost-governance-policy.md` — hard cost caps; AUTO/REVIEW/BLOCK; mask `cost_cap`; per-request + per-window token caps emphasised for compute-heavy aggregation)
- ADR-048 (`docs/adr/ADR-048-business-process-repository.md` — intent→`process_ref` resolution; precedes mask dispatch)
- ADR-025 (`decisions/ADR-025-agent-interaction-canon.md` — agent interaction canon)
- ADR-016 (`decisions/ADR-016-ai-plane-pii-aml-routing.md` — PII/AML routing overlay; PII overlay for the C7 `compliance_gate` on client-fund/personal data)
- ADR-040 (`docs/adr/ADR-040-ai-execution-policy.md` — meta-plane vs inference-plane; the LLM-orchestration substrate L2 depends on, Terminal A)
- The CONTRACT ports — the six initial (WalletPort, PartnerPort, ExchangePort, KYCProviderPort, NotificationProviderPort, CRMProviderPort) + ADR-053's `CardPort` + the new **`AnalyticsPort`** (and future `StatementPort`) — the boundary objects masks scope and domain agents implement
- Pre-existing domain service-agent (becomes adapter behind port, untouched): `services/reporting_analytics/analytics_agent.py` (+ `data_aggregator` / `report_builder` / `export_engine`), C7 — in `banxe-emi-stack`
- `docs/refactor/legacy/NEW-PROJECT-PRIORITY-MAP-2026-06-06.md` (capabilities C1–C30; C7 = Portfolio analytics, `legacy-serves (rewrite Python)` / `crypto-api-portfolio (SPEC #7)`; brought under governance here)
- `docs/BANXE-UI-UX-SYSTEM.md` (spend analysis — "How much did I spend on FX last month?" — the canonical conversational intent; bunq-style "how much did I spend" Intent-First pattern)
- `.claude/rules/agents.md` (HITL AUTO/REVIEW/BLOCK; ARL `AGENT_ROUTING_ENABLED=false` precondition; Ruflo not mandatory for analytics reads)
- `R-COMP-FCA-02` (continuous-compliance / agentic-AI auditability); GDPR/UK-GDPR data-egress/export controls (D1 export-gate rationale)
- CLAUDE.md §10 (config-over-hardcoding — mask values, caps, export-materiality threshold as governed data), §11 (no ungoverned consequential action), money rule (Decimal, never float)
- INSTRUCTION-LEDGER.md → IL-141-ANALYTICS-REPORTING-CLIENT-MASK-C7-2026-06-08
