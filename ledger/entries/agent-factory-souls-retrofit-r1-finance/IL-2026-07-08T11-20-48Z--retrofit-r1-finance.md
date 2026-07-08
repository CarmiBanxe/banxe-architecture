---
il_ts: 2026-07-08T11:20:48Z
session_id: agent-factory-souls-retrofit-r1-finance
source: CEO
status: PROPOSED
---
### Retrofit batch R1 (finance) — add ## Decision Method to the 11 finance SOULs (prepare-only, additive)

Adds the mandatory `## Decision Method` (ADR-131 standard, amended #1077) to the 11 R1 finance SOULs (apar-agent,
beancount-export-agent, budget-agent, cash-position-agent, consolidation-agent, finance-bi-agent, forecast-agent,
fx-exposure-agent, gl-close-agent, ifrs-agent, tax-compliance-agent). Additive only — no authority/status change, all
stay PROPOSED; no passport/config/schema/_TEMPLATE/ADR-131. Grounded per finance role (fiscal materiality / accuracy /
disclosure adequacy / reporting deadline — MAUT -> own HITL gate -> own human double -> fail-closed; never
best-decides a financial-reporting action; I-27, BUG-007). Pointer-first. 0 skips. R1 -> 11/58. Clean re-cut off
origin/main after a --theirs ledger corruption (sp40/IL-1028 preserved; I-24/I-28 append-only). Refs: ADR-131
(+#1077); BEST-DECISION-RETROFIT-PLAN; I-24/I-27/I-28/BUG-007; ADR-102/119/120; Rule 6.
