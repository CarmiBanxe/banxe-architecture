---
il_ts: 2026-07-08T18:16:03Z
session_id: agent-factory-souls-retrofit-r7-bi-dashboard
source: CEO
status: PROPOSED
---
### Retrofit R7-final (BI Dashboard Governor) — add ## Decision Method (Best-Decision Canon Variant C) — prepare-only, additive

Adds the mandatory `## Decision Method` (ADR-131 Amendment 2026-07-07; **Best-Decision Canon Variant C** applied) to
the LAST factory SOUL — bi-dashboard-governor. **Decider verbatim from SOUL:** Head of Data. Variant C shape: Role
(BI Dashboard Governor / Data-Analytics) · Tier STANDARD · Execution-class gated; core algorithm enumerate → score
(MAUT: value=dashboard/dataset_quality, cost=maintenance_effort, risk=pii_exposure/rls_bypass, reversibility, strategic_fit=
data_governance, opportunity_cost=stale_insight) → satisfice within HITL → escalate; blockers B1–B5 + HARD (PII/RLS
bypass → BLOCK unconditionally; publish/certify or RLS/no-PII policy change → gated at Head of Data); explicit no-adoption-
right; ratification gate. **STATUS: PROPOSED — NOT ACTIVE** (governed config requires a separate operator + Central
human-gate). Additive only — inserted after `## HITL Gate`; no section removed/reordered; no passport/config/schema/
_TEMPLATE/ADR-131 diff; stays PROPOSED. Pointer-first (ADR-102). Completes the fleet Best-Decision retrofit.
Refs: ADR-131 Amendment; ADR-162; BEST-DECISION-RETROFIT-PLAN; I-27; ADR-102 / ADR-119 / ADR-120.
