---
il_ts: 2026-07-05T01:44:40Z
session_id: agent-factory-fleetaudit-passport-binding-conformance
source: agent-factory
status: PROPOSED
---

# Fleet passport-binding conformance audit — corrects the "14 UNMAPPED" survey read

## What

Rigorous, schema-aware re-check of agents/passports/** vs a crude survey grep that flagged ~14 "UNMAPPED/THIN".
Report: `docs/audit/FLEET-PASSPORT-BINDING-CONFORMANCE-2026-07-05.md`.

## Findings

- Crude "14 unmapped" is WRONG. Rigorous no-org-field set = 13, splitting: **9 conformant infra adapters**
  (bound by bounded_context + call-graph, org-placement in the matrix — no defect); **3 schema-nonconformant
  governor stubs** (adverse_media/regulatory_returns/safeguarding_recon — ad-hoc id/status/gap format missing
  ~6-9 schema-required fields — the real gap); **1 intentional dev-plane** (spec_first_auditor, #1012).
- False positives (aml/ SMF17-format, nested data_lake_elt/treasury_alm, gap_tracker) confirmed BOUND.
- Systemic note: matrix→passport placement-sync gap (clickhouse_writer/spec_first_auditor placements from #1012
  not written back into passports).

## Recommendation

Upgrade the 3 governor stubs to agent_passport.schema.json shape (prepare-only, no activation); decide on
matrix→passport department back-write; consider CI passport-vs-schema validation.

## Boundaries

Doc-only, prepare-only, read-only. No passport edited, no agent activated (all stay PROPOSED, I-27). IL minted
redis-serialized at ratification.

## Anchors

`docs/audit/FLEET-PASSPORT-BINDING-CONFORMANCE-2026-07-05.md` · `schemas/agent_passport.schema.json` ·
`governance/STAFF-MATRIX-v3.md` · `docs/governance/AGENT-ORG-ASSIGNMENT-MATRIX.md` · #1012.
