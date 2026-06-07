---
id: ADR-046
title: Decision Lineage Schema (AgentDecisionRecord) for EMI BANXE AI BANK
status: ACCEPTED
date: 2026-06-07
accepted: 2026-06-07
supersedes: []
related:
  - "ADR-045-intent-first-banking-architecture.md (Intent-First Banking — L3 Governance layer; names this as future ADR D7.1)"
  - "../../decisions/ADR-027-audit-trail-durability.md (Audit-Trail Durability Strategy — durable storage substrate)"
  - "../../decisions/ADR-025-agent-interaction-canon.md (Agent Interaction Canon)"
  - "ADR-040-ai-execution-policy.md (AI Execution Policy — meta-plane vs inference-plane)"
  - "../../decisions/ADR-016-ai-plane-pii-aml-routing.md (AI Plane / PII-AML routing)"
binding_artifact: null
il_anchor: IL-123-DECISION-LINEAGE-SCHEMA-2026-06-07
scope: BANXE-only
concept_only: true
---

# ADR-046: Decision Lineage Schema (AgentDecisionRecord) for EMI BANXE AI BANK

**Status:** Proposed
**Date:** 2026-06-07
**Source-of-determination:** YAML frontmatter `status: PROPOSED` + body section `## Status` line `PROPOSED — 2026-06-07`
**IL-anchor:** IL-123-DECISION-LINEAGE-SCHEMA-2026-06-07
**Scope:** BANXE-only (governance artefact; CONCEPT / SCHEMA ONLY — no migrations, DDL execution, or agent code in this ADR)

## Status

PROPOSED — 2026-06-07. First of the three future ADRs named in ADR-045 §D7. This ADR
specifies the **schema/contract** for decision lineage; it does not implement
migrations, ingestion code, or agent instrumentation. Those follow in a later sprint
once this contract is ACCEPTED.

## Context

ADR-045 reframed EMI BANXE AI BANK as an **Intent-First / AI-agent-first** banking
product whose **L3 Governance & Compliance Layer** is a cross-cutting enforcement plane
that intercepts every consequential L2 agent action. ADR-045 §D7 named three open
governance gaps to be formalized as future ADRs; the **first** of those is the
**Decision Lineage Schema (`AgentDecisionRecord`)**. This ADR closes that first gap at
the contract level.

Why this is the first gap to formalize:

- **FCA / DORA 2026 scrutiny is agentic.** Under continuous-compliance expectations and
  the increasing regulatory focus on agentic AI in regulated finance, an FCA audit of
  agent-driven transactions begins by asking: *for this action, which agent decided it,
  on what intent, against which policies, with what confidence, and who (if anyone)
  reviewed it?* Decision lineage is the **first artefact an FCA audit of agent
  transactions checks**. Without a canonical, queryable record, every audit is a manual
  archaeology exercise across logs.
- **The existing audit substrate is event-shaped, not decision-shaped.** ADR-027
  (Audit-Trail Durability) and the `guardian_audit_events` ClickHouse trail durably
  capture *what happened* (commands, bash invocations, guardian verdicts). They do not
  capture *why an agent decided what it decided* in a single, normalized, regulator-
  legible row keyed to a client intent. The HITL thresholds in `.claude/rules/agents.md`
  (AUTO >90% / REVIEW 70–90% / BLOCK <70%) and `docs/runbooks/hitl-decision-recording.md`
  already mandate logging REVIEW/BLOCK decisions "with full context" — but the *shape*
  of that context has never been fixed as a contract. This ADR fixes it.
- **Config-over-hardcoding (CLAUDE.md §10) and the Decision-Lineage clause of ADR-045
  L3** both require that the lineage record be a durable, versioned schema stored as
  data, not an ad-hoc log line.

This ADR is **CONCEPT / SCHEMA ONLY**: it defines the `AgentDecisionRecord` contract,
its field semantics, its storage target, and its relationship to the existing audit
trail. It does not implement it.

## Decision

### D1 — Canonical record: `AgentDecisionRecord`

Every **consequential L2 agent decision** (per ADR-045 L2 Execution Layer — any action
that touches client funds, production state, regulated data, or alters a client-visible
outcome) MUST emit exactly one `AgentDecisionRecord`. The record is the atomic unit of
**decision lineage**: one decision → one immutable record, linkable to the records that
preceded and followed it via `correlation_id` and the lineage references below.

"Consequential" is the same threshold L3 uses to intercept L2 in ADR-045 §D2: routine,
read-only, no-side-effect agent steps do not require a record; any decision that an FCA
auditor could ask "why did the system do that?" about does.

### D2 — Schema / contract (ClickHouse-storable)

The record is specified as a logical contract below. It is designed to be
**ClickHouse-storable** as one row per decision in an append-only, immutable table
(storage engine and DDL deferred to the implementation sprint; see §Consequences). All
field names are canonical and stable; downstream producers and consumers bind to these
names.

| Field | Type (logical) | Null? | Semantics |
|-------|----------------|-------|-----------|
| `record_id` | UUID / ULID | NO | Primary identity of this decision record. Globally unique, immutable, assigned at emit time. |
| `timestamp` | DateTime64 (UTC, ms) | NO | Instant the decision was finalized by the agent. UTC, millisecond precision. |
| `agent_id` | String | NO | Canonical id of the deciding L2 agent (e.g. `mlro_agent`, `aml_check_agent`, `sanctions_check_agent`), per `.claude/rules/agents.md` roster. |
| `triggering_event` | String / ref | NO | What caused the decision — event type + reference (e.g. inbound payment id, KYC webhook id, intent submission id). Links to the `guardian_audit_events` / source event. |
| `intent` | String / ref | NO | The client intent that this decision serves — natural-language intent text or a stable reference to the L1 Intent Layer intent record (ADR-045 L1). Anchors the decision to *what the client asked for*. |
| `policies_evaluated` | Array(String) | NO (may be empty `[]`) | Ordered list of policy / rule / invariant identifiers evaluated for this decision (e.g. `I-02`, `R-COMP-FCA-02`, sanctions ruleset version, AML scenario ids). Empty array = no policy gate applied (itself an auditable fact). |
| `compliance_result` | Enum(`PASS`,`FAIL`,`ESCALATE`,`N/A`) | NO | Net compliance outcome of the evaluated policies for this decision. |
| `reasoning_summary` | String | NO | Concise, human-legible summary of *why* the agent decided as it did. Regulator-facing; must be PII-minimized per ADR-016 routing. Not the raw chain-of-thought — a durable, reviewable rationale. |
| `confidence_score` | Float32 [0.0–1.0] | NO | The agent's confidence in the decision, on the same scale as the HITL thresholds in `.claude/rules/agents.md` (AUTO >0.90 / REVIEW 0.70–0.90 / BLOCK <0.70). |
| `action_taken` | String / ref | NO | The concrete action the agent took or proposed (e.g. `APPROVE_PAYMENT`, `HOLD_FOR_REVIEW`, `FILE_SAR`, `REJECT_KYC`) + reference to the executed operation if any. |
| `human_reviewed_by` | Nullable(String) | YES | HITL reviewer identity (MLRO / CEO / dublёr) when the decision was paused for REVIEW or BLOCK. NULL for AUTO (>0.90) decisions that required no human. Non-null is mandatory whenever `confidence_score` fell in the REVIEW/BLOCK bands. |
| `correlation_id` | String | NO | Cross-cutting trace id tying this decision to the whole intent→execution→audit chain and to sibling records in the same flow. Same `correlation_id` family used by `guardian_audit_events` and the ClickHouse audit trail. |
| `immutable_storage_ref` | String | NO | Reference/anchor to the immutable persistence of this record (e.g. ClickHouse part + offset, WORM object key, or hash chain anchor per ADR-027 durability). Proves the record itself is tamper-evident. |

**Lineage semantics.** Decision *lineage* (the "prior decisions" linkage named in
ADR-045 §D7.1) is expressed through `correlation_id` (same-flow siblings) plus
`triggering_event` (a decision triggered by a prior decision's `action_taken` carries
that reference forward). An optional `parent_record_id` MAY be added in the
implementation sprint if explicit DAG edges prove necessary; this ADR keeps the minimum
field set and defers that as a non-breaking additive extension.

### D3 — Storage target and immutability

`AgentDecisionRecord` is stored in the **ClickHouse audit trail**, alongside and
correlated with `guardian_audit_events` (ADR-027), in an **append-only, immutable**
table. No update or delete path exists for emitted records; corrections are issued as
new records referencing the corrected `record_id` via `correlation_id`. The
`immutable_storage_ref` field carries the tamper-evidence anchor defined by ADR-027's
durability strategy. Retention follows the audit-trail retention configured in repo
config (config-over-hardcoding, CLAUDE.md §10), not hardcoded here.

### D4 — Producer obligation (L2 → L3)

Emitting a valid `AgentDecisionRecord` is a **precondition for an L2 agent action of
consequence to be considered complete**. An action whose decision was not recorded is,
for governance purposes, an unaudited action and a compliance defect. This binds the
schema to the L3 enforcement plane of ADR-045 §D2: L3 does not merely permit the action,
it requires the lineage record as the receipt.

### D5 — Schema-only scope; no implementation here

This ADR defines the contract only. The ClickHouse DDL, the storage engine choice
(e.g. `MergeTree`/WORM-backed), the ingestion path, the emit-time validation, and the
agent-side instrumentation are **deferred to a dedicated implementation sprint** and
will be produced through the Software Factory (ADR-045 §D3/§D4 — Central does not mutate
project code directly). No migration is authored in this ADR.

## Consequences

**Positive**

+ Closes the first of ADR-045's three named L3 governance gaps at the contract level.
+ Gives FCA/DORA 2026 audits a single, canonical, queryable artefact: "show me the
  lineage for this transaction" resolves to a deterministic schema, not log archaeology.
+ Normalizes the "full context" already mandated for HITL REVIEW/BLOCK logging
  (`.claude/rules/agents.md`, `hitl-decision-recording.md`) into a stable shape that
  producers and consumers can bind to.
+ Reuses the existing ClickHouse audit substrate and ADR-027 durability/tamper-evidence
  rather than introducing a parallel store.

**Negative / costs**

- This is a contract artefact: it changes nothing until the implementation sprint wires
  emission into every L2 agent. Until then, lineage coverage is aspirational.
- Mandating a record per consequential decision adds write volume and an emit-time
  validation cost on the L2 hot path; the implementation sprint must size ClickHouse
  ingestion accordingly.
- `reasoning_summary` must be PII-minimized (ADR-016) yet regulator-legible — a
  standing tension that producers must handle at emit time.

## Alternatives considered

- **Reuse `guardian_audit_events` as-is, no new schema** (rejected: that trail is
  event/command-shaped — it records *what happened*, not the normalized *why/who/intent/
  confidence* of a decision keyed to client intent. An FCA decision-lineage query cannot
  be answered from command events alone).
- **Free-form JSON blob per decision** (rejected: not regulator-legible, not queryable
  by field, defeats the point of a canonical lineage contract; violates the
  config-over-hardcoding / durable-schema requirement of ADR-045 L3).
- **Fold all three ADR-045 §D7 gaps into one ADR** (rejected: scope — cost-policy and
  the S13-00 Business Process Repository are independent decisions with their own
  alternatives; ADR-045 explicitly reserved them as separate siblings).
- **Explicit decision DAG (parent_record_id edges) from day one** (deferred, not
  rejected: `correlation_id` + `triggering_event` cover lineage for the initial
  contract; an additive `parent_record_id` can be introduced non-breakingly if explicit
  DAG edges are later required).

## Relationship to ADR-045 L3 and the existing audit trail

- **ADR-045 §D2 (L3 Governance & Compliance Layer)** lists "Decision Lineage" as a first-
  class L3 responsibility and §D7.1 names this exact schema as the first future ADR.
  ADR-046 *is* that ADR: it supplies the concrete `AgentDecisionRecord` contract the L3
  layer enforces.
- **ADR-027 (Audit-Trail Durability)** provides the durable, tamper-evident ClickHouse
  substrate; `immutable_storage_ref` binds each lineage record to that durability
  guarantee. ADR-046 is a *consumer* of ADR-027's strategy, not a replacement.
- **`guardian_audit_events`** remains the event/command trail; `correlation_id` and
  `triggering_event` cross-link each `AgentDecisionRecord` to the underlying events, so
  an auditor can pivot from a decision to the raw events that produced it and back.
- **`R-COMP-FCA-02`** (continuous-compliance / agentic-AI auditability requirement) is
  the regulatory driver this schema satisfies.

## Sibling future ADRs (still pending, per ADR-045 §D7)

This ADR closes gap **D7.1** only. The remaining two named gaps stay OPEN as separate
future ADRs:

- **D7.2 — AI cost governance policy** (L3 cost-policy: budgets, per-route/per-agent
  cost accounting, escalation thresholds, config-over-hardcoding storage). PENDING.
- **D7.3 — S13-00 Business Process Repository** (canonical, versioned business processes
  that intents map onto; anchors L1→L2 translation). PENDING.

## Anchors

- ADR-045 (Intent-First Banking — L3 Governance & Compliance Layer; §D7.1 names this ADR)
- ADR-027 (`decisions/ADR-027-audit-trail-durability.md` — durable, tamper-evident audit substrate)
- ADR-025 (`decisions/ADR-025-agent-interaction-canon.md` — agent interaction canon)
- ADR-016 (`decisions/ADR-016-ai-plane-pii-aml-routing.md` — PII/AML routing for `reasoning_summary`)
- ADR-040 (`docs/adr/ADR-040-ai-execution-policy.md` — meta-plane vs inference-plane)
- `.claude/rules/agents.md` (HITL confidence thresholds AUTO/REVIEW/BLOCK; agent roster)
- `docs/runbooks/hitl-decision-recording.md` (existing "log full context" mandate this schema normalizes)
- `guardian_audit_events` / ClickHouse audit trail (correlated store)
- `R-COMP-FCA-02` (continuous-compliance / agentic-AI auditability requirement)
- CLAUDE.md §10 (config-over-hardcoding — retention/limits in config), §11 (production-state mutation gate)
- INSTRUCTION-LEDGER.md → IL-123-DECISION-LINEAGE-SCHEMA-2026-06-07
