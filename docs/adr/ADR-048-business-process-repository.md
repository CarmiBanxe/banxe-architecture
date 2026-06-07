---
id: ADR-048
title: S13-00 Business Process Repository (canonize banxe-business-processes) for EMI BANXE AI BANK
status: PROPOSED
date: 2026-06-07
supersedes: []
related:
  - "ADR-045-intent-first-banking-architecture.md (Intent-First Banking — L1→L2 translation & L4 Data/Intelligence; names this as future ADR D7.3)"
  - "ADR-046-decision-lineage-schema.md (Decision Lineage Schema — lineage carries a process_ref to the resolved process)"
  - "ADR-047-ai-cost-governance-policy.md (AI Cost Governance Policy — cost is attributable per process)"
  - "../../decisions/ADR-025-agent-interaction-canon.md (Agent Interaction Canon)"
  - "../../decisions/ADR-016-ai-plane-pii-aml-routing.md (AI Plane / PII-AML routing)"
binding_artifact: null
il_anchor: IL-125-BUSINESS-PROCESS-REPOSITORY-2026-06-07
scope: BANXE-only
concept_only: true
---

# ADR-048: S13-00 Business Process Repository (canonize banxe-business-processes) for EMI BANXE AI BANK

**Status:** Proposed
**Date:** 2026-06-07
**Source-of-determination:** YAML frontmatter `status: PROPOSED` + body section `## Status` line `PROPOSED — 2026-06-07`
**IL-anchor:** IL-125-BUSINESS-PROCESS-REPOSITORY-2026-06-07
**Scope:** BANXE-only (governance artefact; CANONIZATION / CONTRACT ONLY — no ArchiMate import, no resolver code, no schema execution in this ADR)

## Status

PROPOSED — 2026-06-07. **Third and FINAL** of the three future ADRs named in ADR-045
§D7. ADR-046 closed §D7.1 (Decision Lineage Schema) and ADR-047 closed §D7.2 (AI Cost
Governance Policy); this ADR closes **§D7.3 (S13-00 Business Process Repository)**. With
this ADR authored, **all three ADR-045 §D7 siblings are now written and the §D7 backlog
is closed.** This ADR **canonizes an existing repository** and defines the
intent→process resolution contract; it does **not** complete the ArchiMate import, build
the resolver, or author any schema/code. Those follow in a dedicated factory sprint once
this canon is ACCEPTED.

## Context

ADR-045 reframed EMI BANXE AI BANK as an **Intent-First / AI-agent-first** banking
product with a four-layer model: **L1 Intent** (client conversational), **L2 Execution**
(autonomous agents), **L3 Governance & Compliance** (guardrails, audit, decision
lineage, cost-policy), and **L4 Data & Intelligence**. The model's hardest seam is the
**L1→L2 translation**: a free-form client intent must be turned into a *governed,
bounded* unit of agent execution. ADR-045 §D7 named three open governance gaps to be
formalized as future ADRs; the **third** is the **S13-00 Business Process Repository** —
"the canonical repository of business processes that intents map onto, anchoring L1→L2
translation to governed, versioned process definitions."

Why this gap must be formalized:

- **The repository already EXISTS but is not yet canon.** `CarmiBanxe/banxe-business-processes`
  (description: *"ArchiMate 3.2 business process repository for AI agents"*) already exists
  as a repo. It is the natural home for the process models BANXE's architecture work has
  already produced — but it has **never been designated as the authoritative S13-00
  Business Process Repository** in any ADR. As a result, "what is the source of truth for
  a business process?" has no canonical answer, and L1→L2 translation has nothing
  governed to resolve against. **This ADR canonizes the existing repo; it does NOT propose
  creating it from scratch.**
- **The process material already exists, scattered.** BANXE has already modelled its
  business architecture: the ArchiMate **Banxe_v5** model and its derivative
  `docs/DEPARTMENT-MAP.md` (IL-031 — 10 legacy Geniusto departments mapped to AI agents,
  human doubles, FCA trust zones and autonomy levels, with a ~49% migration register),
  plus `docs/ROADMAP-MATRIX.md` (sprint/phase roadmap) and `docs/COMPLIANCE-MATRIX.md`
  (200+ requirements incl. the S17 department requirements). These are the **content** the
  canonical repository organizes as versioned ArchiMate 3.2 process models; today they
  live as architecture docs in `banxe-architecture`, not as a governed process source the
  L2 plane resolves against.
- **Intents need something governed to land on.** Without a canonical, versioned process
  source, L1→L2 translation is implicit: an agent improvises the steps of "open an
  account" or "make a payment" rather than executing a *named, versioned, governed*
  process. For a regulated EMI, the process an intent resolves to must be auditable
  ("which version of the payment process ran?") and change-controlled (a process is not
  edited ad hoc; it changes via ADR/IL) — exactly the L3 discipline ADR-045 requires.
- **Lineage and cost want a process handle.** ADR-046's `AgentDecisionRecord` records
  *why* a decision happened; ADR-047 records *what it cost*. Both become far more useful
  when each decision/cost can be attributed to a **specific process version** via a stable
  `process_ref`. Canonizing the repository gives that reference a governed target.

This ADR is **CANONIZATION / CONTRACT ONLY**: it designates the authoritative repository,
defines what it holds, fixes the intent→process resolution contract, the
versioning/governance discipline, and how it feeds L4. It does **not** complete the
ArchiMate import, build a resolver, or author schema/code.

## Decision

### D1 — Canonize `CarmiBanxe/banxe-business-processes` as the S13-00 Business Process Repository

`CarmiBanxe/banxe-business-processes` is hereby designated the **canonical S13-00
Business Process Repository** for EMI BANXE AI BANK: the **single authoritative, versioned
source of truth for business-process definitions**. Its **ArchiMate 3.2 process models are
the versioned source of truth that client intents resolve against before L2 agent
execution.** No other store, doc, or ad-hoc agent improvisation is an authoritative
process source once this ADR is ACCEPTED. The repository **already exists**; this ADR
formalizes its role, it does not create it.

### D2 — What the repository holds

The canonical repository holds the **governed process and department models**, expressed
as **ArchiMate 3.2**:

- **Business-process models** — the ArchiMate business-layer processes (e.g. KYC
  onboarding, payment execution, safeguarding reconciliation, reporting), each a named,
  versioned definition with its activities, actors, and the business-services it realizes.
- **Department / capability models** — the organizational structure already captured in
  `docs/DEPARTMENT-MAP.md` (the 10 legacy Geniusto departments → AI-agent / human-double /
  trust-zone / autonomy-level mapping from IL-031, derived from the ArchiMate **Banxe_v5**
  model). DEPARTMENT-MAP is the **content seed**; the canonical repo is its versioned,
  governed home.
- **Cross-references** — each process model links to the governing requirements in
  `docs/COMPLIANCE-MATRIX.md` (FCA / MLR / S17 etc.) and to its place in
  `docs/ROADMAP-MATRIX.md`, so a process carries its compliance and roadmap context.

The **migration of the full ArchiMate import** (porting Banxe_v5 / DEPARTMENT-MAP content
into governed ArchiMate 3.2 model files in the repo) is **deferred to a sprint** (D6); this
ADR fixes only *what the repo is for and holds*, not the completed import.

### D3 — The intent→process resolution contract (L1→L2 anchor)

The repository's primary job is to be the **resolution target for L1 intents**. The
contract:

1. **An L1 intent resolves to exactly one canonical process version before L2 executes.**
   The L1 layer (conversational intent) classifies the client's intent and **selects a
   process** from the repository — by a stable **process identifier + version**, not by
   re-deriving the steps. Resolution happens **before** any consequential L2 action.
2. **The selected process is identified by a stable `process_ref`.** A `process_ref` is a
   stable handle — `{process_id, version}` (logical form; concrete format is config/sprint
   work) — that uniquely names the canonical process definition and its version. This is
   the handle ADR-046 lineage and ADR-047 cost attribution carry (see D5).
3. **L2 executes within the bounds of the resolved process.** The agent population
   executes the resolved process definition; the process bounds *what* may be done. An
   intent that resolves to **no** canonical process is **not** executed by improvisation —
   it is a governance event (route to HITL / process-gap backlog), consistent with
   ADR-045 L3 and CLAUDE.md §11 (no ungoverned consequential action).
4. **L3 treats "resolved to a governed process version" as a precondition** for a
   consequential L2 action to proceed — the same way L3 treats the decision-lineage
   receipt (ADR-046) and the within-budget/breaker-closed state (ADR-047) as preconditions.

This ADR fixes the **contract**; the resolver implementation (classifier, lookup, the
concrete `process_ref` format) is sprint/config work (D6), not authored here.

### D4 — Versioning & governance discipline

The repository is **governed, not free-form**:

- **Versioned source of truth.** Every process definition is **versioned**; a `process_ref`
  always names a specific version. Older versions remain resolvable so a past decision's
  lineage (ADR-046) can be replayed against the process version that actually ran.
- **Change via ADR / IL only.** A process definition is **not edited ad hoc**. Material
  changes to a canonical process go through the standard governance path (ADR and/or IL
  anchor), the same change-control the rest of BANXE canon uses. This makes "who changed
  this process, when, and under what authority?" auditable.
- **Compliance-contour processes are highest-severity.** Processes touching payment, AML,
  KYC, safeguarding, or reporting follow the compliance-change chain of
  `.claude/rules/agents.md` (Ruflo mandatory; MLRO/CEO where required). A process change in
  these contours is a CLASS_B/C governance change, never a silent edit.
- **Config-over-hardcoding (CLAUDE.md §10).** Process *definitions* live as governed data
  in the canonical repository; they are not hardcoded into agent code. The repo is the
  data source; agents reference it by `process_ref`.

### D5 — Lineage & cost attribution by `process_ref` (tie to ADR-046 / ADR-047)

The canonical `process_ref` is the **shared handle** that binds this repository to the
other two §D7 siblings:

- **ADR-046 (Decision Lineage).** `AgentDecisionRecord` carries a **`process_ref`** field
  (additive, non-breaking — implementation deferred) recording *which canonical process
  version* the decision executed under. This makes "what process, which version, ran this
  decision?" answerable from the same lineage row an FCA/DORA audit already reads.
- **ADR-047 (AI Cost Governance).** Cost attributed per decision (ADR-047 D5) can be
  **aggregated per process** via the shared `process_ref`, answering "what does the
  payment process cost to run per execution?" — a governance and FinOps signal, not only
  a per-agent one.

The `process_ref` field additions to the ADR-046 record (and any ADR-047 cost rollup keyed
on it) are **additive and deferred**; this ADR fixes the *handle and the contract*, not the
migration.

### D6 — How the repository feeds L4 Data & Intelligence; scope deferral

- **Feeds L4.** The canonical processes and their executions are a **first-class L4 Data &
  Intelligence input**: process definitions (the governed "what should happen") plus the
  lineage/cost records keyed by `process_ref` (the observed "what did happen, at what
  cost") give L4 the substrate for process analytics, drift detection (executed vs.
  defined process), compliance evidence, and roadmap prioritization. The repository is the
  **process foundation** that anchors L1→L2→(L3 governed)→L4 end to end.
- **Canonization / contract scope only.** This ADR designates the repository, defines its
  holdings, the resolution contract, the governance/versioning discipline, and the L4 feed.
  It does **not** implement: the completed ArchiMate import of Banxe_v5 / DEPARTMENT-MAP
  into governed model files, the intent classifier / resolver, the concrete `process_ref`
  format, the ADR-046 `process_ref` field migration, or any agent-side instrumentation.
  All of those are **deferred to a dedicated factory sprint** and produced through the
  Software Factory (ADR-045 §D3/§D4 — Central does not mutate project code directly). No
  schema, model file, or code is authored in this ADR.

## Consequences

**Positive**

+ Closes the **third and final** of ADR-045's three named §D7 governance gaps (§D7.3);
  with ADR-046 (§D7.1) and ADR-047 (§D7.2) already authored, **the §D7 backlog is now
  complete**.
+ Gives BANXE a single canonical answer to "what is the source of truth for a business
  process?" — the existing `banxe-business-processes` repo, now governed and versioned.
+ Anchors the L1→L2 translation: intents resolve to governed, versioned process
  definitions instead of agent improvisation, satisfying ADR-045 L3 and CLAUDE.md §11.
+ Reuses already-produced material (ArchiMate Banxe_v5, DEPARTMENT-MAP, ROADMAP-MATRIX,
  COMPLIANCE-MATRIX) as the content seed — no new modelling effort to start; canonize then
  migrate.
+ The shared `process_ref` unifies the three §D7 siblings: lineage (ADR-046) and cost
  (ADR-047) both attribute to a governed process version, enabling per-process audit and
  FinOps from the existing lineage rows.
+ Feeds L4 Data & Intelligence a clean foundation (defined vs. executed process) for
  analytics, drift detection, and compliance evidence.

**Negative / costs**

- This is a canonization/contract artefact: it changes nothing operationally until the
  deferred sprint completes the ArchiMate import, builds the resolver, and adds the
  `process_ref` field. Until then, the repo is canon-designated but not yet the live
  resolution target.
- Governed (ADR/IL-gated) process change is slower than ad-hoc edits; teams used to
  changing process behaviour in code must route material process changes through
  governance.
- The intent→process resolution contract raises the L1 bar: every consequential intent
  must map to a governed process or become a governance event — more demanding than letting
  agents improvise, but that is the point.
- Cross-repo coupling: `banxe-architecture` ADRs/lineage now reference an artefact in
  `banxe-business-processes`; the two repos' versioning must stay coherent (a `process_ref`
  must always resolve).

## Alternatives considered

- **Keep process knowledge implicit in agent code / prompts** (rejected: no versioned
  source of truth, no auditability of "which process version ran", and L1→L2 translation
  stays improvised — exactly the gap ADR-045 §D7.3 exists to close).
- **Create a brand-new repository for processes** (rejected: `CarmiBanxe/banxe-business-processes`
  *already exists* and is purpose-described as the ArchiMate 3.2 process repo for AI agents.
  Canonizing the existing repo is correct; creating a parallel one would fork the source of
  truth).
- **Keep DEPARTMENT-MAP / ROADMAP / COMPLIANCE matrices as the process source inside
  `banxe-architecture`** (rejected: those are architecture *docs*, not a governed,
  versioned, agent-resolvable process store; they are the content seed, not the canonical
  runtime resolution target. They remain the seed, migrated into the canonical repo).
- **Use a non-ArchiMate / proprietary process format** (rejected: the existing repo is
  ArchiMate 3.2 and BANXE's modelling (Banxe_v5, DEPARTMENT-MAP) is already ArchiMate;
  adopting a different notation discards existing work and tooling).
- **Fold the process repository into ADR-046 or ADR-047** (rejected: ADR-045 §D7.3
  reserved it as an independent sibling with its own contract and alternatives; the lineage
  *schema*, the cost *policy*, and the process *repository* are three separate decisions,
  kept separable).
- **Defer canonization until the ArchiMate import is complete** (rejected: canonizing the
  repository and defining the contract is the governance decision; the import is sprint
  work. Canonize first so lineage/cost/L4 have a stable target to reference, then migrate).

## Relationship to ADR-045 L1→L2→L4, ADR-046, and ADR-047

- **ADR-045 §D7.3** names this exact repository as the third future ADR and ties it to the
  **L1→L2 translation** and the **L4 Data & Intelligence foundation**. ADR-048 *is* that
  ADR: it canonizes the repository, fixes the intent→process resolution contract (the L1→L2
  anchor), and defines the L4 feed.
- **ADR-046 (Decision Lineage Schema)** gains an additive **`process_ref`** so every
  decision records which canonical process version it executed under — the process handle
  this ADR canonizes.
- **ADR-047 (AI Cost Governance Policy)** can aggregate per-decision cost **per process**
  via the same `process_ref`, giving per-process FinOps/governance signal.
- **ADR-025 (Agent Interaction Canon)** and **`.claude/rules/agents.md`** (HITL thresholds;
  compliance chain B with Ruflo mandatory) supply the governance machinery a
  compliance-contour process change reuses.
- **`docs/DEPARTMENT-MAP.md` / `docs/ROADMAP-MATRIX.md` / `docs/COMPLIANCE-MATRIX.md`** and
  the **ArchiMate Banxe_v5** model (IL-031) are the **content seed** migrated into the
  canonical repository.
- **`R-COMP-FCA-02`** (continuous-compliance / agentic-AI auditability) and **DORA 2026**
  (operational resilience) are the regulatory drivers: a governed, versioned process source
  is what makes "which process, which version, under what authority" auditable.

## Sibling future ADRs — §D7 backlog now CLOSED

ADR-045 §D7 named three future ADRs. With this ADR authored, **all three are written**:

- **D7.1 — Decision Lineage Schema** → **ADR-046** (PROPOSED 2026-06-07). DONE.
- **D7.2 — AI Cost Governance Policy** → **ADR-047** (PROPOSED 2026-06-07). DONE.
- **D7.3 — S13-00 Business Process Repository** → **ADR-048** (this ADR, PROPOSED
  2026-06-07). DONE.

**The ADR-045 §D7 future-ADR backlog is CLOSED.** No further §D7 siblings remain.

## Anchors

- ADR-045 (`docs/adr/ADR-045-intent-first-banking-architecture.md` — §D7.3 names this ADR; L1→L2 translation; L4 Data & Intelligence)
- ADR-046 (`docs/adr/ADR-046-decision-lineage-schema.md` — `AgentDecisionRecord`; additive `process_ref` field)
- ADR-047 (`docs/adr/ADR-047-ai-cost-governance-policy.md` — cost attribution aggregable per process via `process_ref`)
- ADR-025 (`decisions/ADR-025-agent-interaction-canon.md` — agent interaction canon)
- ADR-016 (`decisions/ADR-016-ai-plane-pii-aml-routing.md` — AI plane routing)
- `CarmiBanxe/banxe-business-processes` (the EXISTING repo canonized here — "ArchiMate 3.2 business process repository for AI agents")
- `docs/DEPARTMENT-MAP.md` (IL-031 — 10 departments → AI-agent/human-double/trust-zone mapping; content seed)
- `docs/ROADMAP-MATRIX.md` (sprint/phase roadmap; process roadmap context)
- `docs/COMPLIANCE-MATRIX.md` (200+ requirements incl. S17; per-process compliance cross-reference)
- ArchiMate **Banxe_v5** model + **IL-031** (ArchiMate Banxe_v5 → DEPARTMENT-MAP + agent passports)
- `.claude/rules/agents.md` (HITL AUTO/REVIEW/BLOCK; compliance chain B — Ruflo mandatory for process changes in compliance contours)
- `R-COMP-FCA-02` (continuous-compliance / agentic-AI auditability); DORA 2026 (operational resilience)
- CLAUDE.md §10 (config-over-hardcoding — process definitions as governed data, not code), §11 (no ungoverned consequential action)
- INSTRUCTION-LEDGER.md → IL-125-BUSINESS-PROCESS-REPOSITORY-2026-06-07
