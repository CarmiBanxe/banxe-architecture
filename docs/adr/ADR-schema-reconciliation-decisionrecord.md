# ADR — Schema Reconciliation: Two DecisionRecord Schemas
# Status: SUPERSEDED by operator alignment 2026-07-10
# Original date: 2026-07-10 | Branch: feat/bdsl-foundation
# Superseded on: feat/bdsl-activation-prep (2026-07-10)
# OUTCOME: schemas/agent/decisionrecord.schema.json marked SUPERSEDED.
#           Canon = schemas/agent_decision_record.schema.json (ADR-046, sha a95d8e95…).
#           Option A (coexistence) was REPLACED by Option C-rev (ADR-046 supersedes BDSL schema).
# Related: ADR-046 (Decision Lineage Schema), docs/canon/BEST-DECISION-SELF-LEARNING-LOOP.md

---
## ⚠️ STATUS UPDATE (2026-07-10, feat/bdsl-activation-prep)

During fleet alignment to ORG-CODE-RECONCILIATION-v2, `schemas/agent/decisionrecord.schema.json`
was identified as a **non-canonical duplicate** of `schemas/agent_decision_record.schema.json` (ADR-046).

**Decision supersedes this ADR:**
- Option A (coexistence) is NOT adopted.
- `schemas/agent/decisionrecord.schema.json` is marked SUPERSEDED.
- Canon = `schemas/agent_decision_record.schema.json` (ADR-046, sha a95d8e95…).
- Any future MAUT fields should be added as optional extensions to ADR-046 schema (Option B), gated by a new human-gated ADR.

The rest of this document is preserved as historical record of the reasoning.

---

---

## Context

Two schemas for agent decision records now coexist in the repository:

### Schema 1 — ADR-046 Lineage Record (existing, runtime-live)

- **File:** `schemas/agent_decision_record.schema.json`
- **Origin:** ADR-046 Decision Lineage Schema; implemented in `_lineage.py`
- **Purpose:** Lightweight, mandatory audit trail — captures WHAT was decided and WHY at a regulatory-compliance level. Emitted by 9 client-facing agents today.
- **Fields (key):** `record_id`, `timestamp`, `agent_id`, `triggering_event`, `intent`, `policies_evaluated`, `compliance_result`, `reasoning_summary`, `confidence_score`, `action_taken`, `human_reviewed_by`, `correlation_id`, `cost_tokens`, `cost_amount`, `budget_window_ref`, `budget_breach_flag`, `immutable_storage_ref`
- **Audience:** FCA/regulatory auditors, MLRO, compliance team
- **Status:** LIVE — agents emit this record today; schema validates runtime records

### Schema 2 — BDSL MAUT Record (proposed, foundation artifact)

- **File:** `schemas/agent/decisionrecord.schema.json`
- **Origin:** BDSL pinned source §1.1 (`docs/sources/best-decision-self-learning-loop-2026-07-07.md`, body-sha c4f71e...30553f)
- **Purpose:** Rich MAUT evaluation structure — captures HOW the decision was reached, enabling outcome feedback and self-learning loop operation. Not yet emitted by any agent.
- **Fields (key):** `record_id`, `agent_id`, `decision_space{D, pruned}`, `criteria[](weight, score, method)`, `utility_computation(MAUT_additive)`, `chosen(confidence, tier)`, `stopping_rule`, `bias_flags`, `minimax_regret`, `human_review`, `schema_hash`, `prev_record_hash`, `emitted_to`
- **Audience:** BDSL learning loop, model evaluation, governance analytics
- **Status:** PROPOSED — exists as foundation artifact, no agents emit it yet

---

## Problem

The two schemas overlap conceptually (both are "decision records") but serve different purposes and different audiences. Without explicit reconciliation:

1. Future agent developers may emit one, the other, or both — inconsistently
2. A future "merge" attempt may break the live ADR-046 audit trail
3. The BDSL loop cannot start without clarity on which record feeds it

---

## Decision Options Considered

### Option A — Coexistence with clear separation (RECOMMENDED)

Keep both schemas permanently. Define strict ownership:
- ADR-046 schema = **Compliance Lineage Record**: mandatory for all consequential agents, feeds FCA audit trail
- BDSL schema = **Decision Evaluation Record**: feeds BDSL learning loop, emitted in addition to ADR-046 for enrolled agents

Agents that are BDSL-enrolled emit BOTH records per decision. The two records are linked via `record_id` / `trace_id` cross-reference.

**Pros:** Zero breaking change. Both audit trail and BDSL work independently. Rollback is trivial.
**Cons:** Double emission per decision (minor overhead). Two schemas to maintain.

### Option B — BDSL schema extends ADR-046 (deferred)

Add MAUT fields as optional extensions to `agent_decision_record.schema.json`. One schema covers both purposes.

**Pros:** Single schema, single emit.
**Cons:** Breaks existing ADR-046 contract (additionalProperties: false). Requires migration of live agents. Risk to existing FCA audit trail.

### Option C — BDSL schema supersedes ADR-046 (rejected)

Deprecate `agent_decision_record.schema.json`, migrate all agents to BDSL schema.

**Pros:** Single schema long-term.
**Cons:** Breaking change to live audit trail. Requires FCA/MLRO sign-off on changed record format. High risk; no benefit over Option A in near term.

---

## Decision

**OPTION A — Coexistence with clear separation is ADOPTED (PROPOSED status pending ratification).**

### Canonical ownership

| Schema | Canonical purpose | Mandatory for | Fed into |
|--------|------------------|---------------|----------|
| `schemas/agent_decision_record.schema.json` | Compliance lineage audit | ALL consequential agents | FCA audit trail (ClickHouse, WORM) |
| `schemas/agent/decisionrecord.schema.json` | BDSL MAUT evaluation | BDSL-enrolled agents only | BDSL learning loop, governance analytics |

### Cross-reference contract

BDSL-enrolled agents that emit both records MUST link them:
- ADR-046 record: include `trace_id` = BDSL record's `record_id`
- BDSL record: include `trace_id` = ADR-046 record's `correlation_id`

This creates a bidirectional link without merging the schemas.

### Naming disambiguation

To prevent developer confusion, both schema files MUST carry a `$comment` field stating:

- `agent_decision_record.schema.json`: `"See also: schemas/agent/decisionrecord.schema.json (BDSL MAUT record). These are distinct schemas with different purposes."`
- `schemas/agent/decisionrecord.schema.json`: `"See also: schemas/agent_decision_record.schema.json (ADR-046 lineage record). These are distinct schemas with different purposes."` (already present in $comment of the BDSL schema)

---

## Migration Plan (phased, all steps human-gated)

| Phase | Action | Target | Gate |
|-------|--------|--------|------|
| Phase 0 (now) | Both schemas exist; no agent emits BDSL schema | 2026-07-10 | — |
| Phase 1 | Ratify this ADR via PR | 2026-08-01 | Human-gated PR |
| Phase 2 | Update `agent_decision_record.schema.json` `$comment` to reference BDSL schema | 2026-08-01 | PR |
| Phase 3 | First BDSL-enrolled agent emits BDSL record (pilot: `tx_monitor` in sandbox) | 2026-09-01 | MLRO + CTIO sign-off |
| Phase 4 | Full ENROL rollout to all 42 confirmed agents | 2026-10-01 | Human-gated fleet PR |
| Phase 5 | (Optional) Evaluate Option B merge — only if double-emission causes measurable overhead | 2027-Q1 | ADR update |

---

## Consequences

**Positive:**
- No breaking change to live ADR-046 audit trail
- BDSL can start independently of ADR-046 migration
- Clear ownership prevents schema drift

**Risks:**
- Double emission adds ~2× ClickHouse write volume per decision for enrolled agents — acceptable per current capacity estimates; re-evaluate at Phase 4
- Developer confusion risk mitigated by `$comment` cross-references and this ADR
- Schema divergence risk mitigated by Phase 5 evaluation gate

**Invariants preserved:**
- I-24: append-only audit trail — ADR-046 schema unchanged
- I-27: HITL gate — BDSL schema's `human_review` section; ADR-046's `human_reviewed_by` allOf constraint
- I-BDSL-1: append-only immutability — both schemas are write-once records

---

## Alternatives Considered and Rejected

- **Option C (supersession):** Rejected — breaks live FCA audit trail with no proportionate benefit.
- **Immediate Option B (extension):** Deferred to Phase 5 — would require schema migration of live agents under operational risk.
- **No action / leave ambiguous:** Rejected — developer confusion and inconsistent agent behaviour are certain without explicit guidance.

---

## Ratification Required

This ADR is **PROPOSED**. It becomes effective only after:
1. Human review and approval via PR on `feat/bdsl-foundation` → `main`
2. MLRO acknowledgement that the coexistence approach satisfies FCA audit trail requirements
3. CTIO sign-off on the cross-reference contract (Phase 2)

No agent code changes until ratification.

---

## References

- ADR-046 Decision Lineage Schema (existing): `docs/adr/` (search for ADR-046)
- BDSL canon pointer: `docs/canon/BEST-DECISION-SELF-LEARNING-LOOP.md`
- BDSL MAUT schema: `schemas/agent/decisionrecord.schema.json`
- ADR-046 lineage schema: `schemas/agent_decision_record.schema.json`
- HITL anchor BUG-007: `.claude/rules/agents.md#BUG-007`
- Fleet classification: `docs/audit/bdsl-fleet-classification-2026-07-10.md`
- Governance config: `governance/novelty-pipeline-config.yaml`
