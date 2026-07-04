---
il_ts: 2026-07-04T19:58:04Z
session_id: agent-factory-governance-unmapped-agents-placement
source: agent-factory
status: PROPOSED
---

# UNMAPPED-agents placement proposal — clickhouse_writer + spec_first_auditor

## What

Close the `§UNMAPPED` gap in `docs/governance/AGENT-ORG-ASSIGNMENT-MATRIX.md` (#1006) by proposing an
evidence-grounded org placement for the two agents that carried **no `department` field** — derived **only
from each agent's passport function**, nothing invented. Final org-call = operator's (ratification).

## Artifacts

- **NEW** `docs/governance/UNMAPPED-AGENTS-PLACEMENT.md` — the two placement PROPOSALS + rationale + alternative,
  each marked "awaiting operator ratification".
- **EDIT** `docs/governance/AGENT-ORG-ASSIGNMENT-MATRIX.md` §UNMAPPED — from **2 escalated/unmapped** to
  **`PROPOSED → <dept> (pending ratification)`** (70/70 placed as proposals; 0 unmapped remaining).

## Proposals (from passport function)

- **`clickhouse_writer`** → **CTO / Technology-Data-AI · Data-Analytics** (Head of Data, 1st Line). Evidence:
  "ClickHouse Audit Writer", GREEN L3 adapter persisting DecisionEvents to ClickHouse (CTX-03, DORA 5-yr TTL) —
  peer of `data_lake_elt_agent` / `bi_dashboard_governor`. Alt: Internal Audit (consumer, not owner).
- **`spec_first_auditor`** → **Developer/Factory plane governance-tooling (OUT-OF-BANK-ORG)**. Evidence:
  CTX-00-DEVELOPER, methodology controller, `~/developer/` audit script. Alt: CTO / Engineering-Developer-Platform
  (if it must sit in-bank).

## Boundaries

PROPOSAL only (operator ratifies). No passport edited, no agent activated, no department invented. No
GUIYON / specproj / NOVELTY-REGISTER touched; no secret read. Prepare-only — no merge/push to main.

## Anchors

`docs/governance/AGENT-ORG-ASSIGNMENT-MATRIX.md` · `docs/governance/UNMAPPED-AGENTS-PLACEMENT.md` ·
`agents/passports/clickhouse_writer.yaml` · `agents/passports/spec_first_auditor.yaml` ·
`governance/CANONICAL-ORG-CHART-v2.md` · `governance/STAFF-MATRIX-v3.md`. ADR-102 (additive, pointer-first).
