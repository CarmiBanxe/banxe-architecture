---
il_ts: 2026-07-08T13:20:30Z
session_id: agent-factory-souls-retrofit-r6d-design
source: CEO
status: PROPOSED
---
### Retrofit batch R6d (Design one-off) — add ## Decision Method to design-pipeline-agent (prepare-only, additive; Variant A)

Adds the mandatory `## Decision Method` (ADR-131 Amendment 2026-07-07; ratified R6 methodology, Design cluster /
CLUSTER-D) to the single SOUL design-pipeline-agent. **Decider verbatim from SOUL:** CTO (activation-class decisions
CTO+CEO per ADR-135; I-27 at decision-time) — the double-gate is rendered exactly as the SOUL states it; no VP-layer,
ARB, or co-decider invented. Design MAUT criteria (Ds/U/B/F/T; DS-conformance Lexicographic Level-0), CLUSTER-D cases,
confidence-tiered escalation, fail-closed (taste output never satisfies a gate; never autonomously promotes/merges
generated code — I-27, ADR-135). Additive only — inserted after `## HITL Gate`; no section removed/reordered; no
passport/config/schema/_TEMPLATE/ADR-131 diff; stays PROPOSED. Pointer-first (ADR-102 — theory referenced, not restated).

**WCAG deferral (VARIANT A, intentional):** the WCAG-AA accessibility Level-0 constraint is DEFERRED to a separate
governance-PR and is NOT added by this retrofit — this batch introduces no accessibility invariant and adds no
Accessibility Engineer co-decider. R6 complete after this (R6a 3 + R6b 6 + R6c 4 + R6d 1 = 14/14).
Refs: ADR-131 Amendment; BEST-DECISION-RETROFIT-PLAN; R6-methodology; ADR-135; I-27; ADR-102 / ADR-119 / ADR-120.
