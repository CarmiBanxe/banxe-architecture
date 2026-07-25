# AGENT REGISTRY — Coverage Closure (23 UNPLACED + duplicates) — 2026-07-21

**GOVERNANCE-AUDIT / COVERAGE CLOSURE (ACTION-3 completion) / DOCS-ONLY / READ-ONLY RUNTIME**
Closes the reconcile gap before MASTER consolidation: 23 UNPLACED census `*_agent.py` placed, duplicate-row check resolved. Read-only over `~/banxe-emi-stack`; append-only to existing registries.

## Part A — 23 UNPLACED placed (append-only rows)

| agent | placed room | registry / id | class | flag |
|---|---|---|---|---|
| bi_agent | F3-finbi | AG-F3-034 | tooling | - |
| data_quality_agent | F3-finbi | AG-F3-035 | tooling | - |
| forecast_agent | F3-finbi | AG-F3-036 | tooling (MASK) | - |
| fpa_agent | F3-finbi | AG-F3-037 | tooling | - |
| credit_scoring_agent | F3-risk | AG-F3-038 | decision | **[gated-counsel]** Annex III credit scoring |
| ato_agent | F3-risk | AG-F3-039 | decision (HITL) | - |
| ml_pipeline_agent | F4-ai-platform | AG-F4-020 | decision (L3) | HITL-014 |
| fingerprint_agent | F4-security | AG-F4-021 | decision (HITL) | - |
| compliance_ui_agent | F4-ai-platform | AG-F4-022 | tooling (UI) | - |
| report_ui_agent | F4-ai-platform | AG-F4-023 | tooling (UI) | - |
| transaction_ui_agent | F4-ai-platform | AG-F4-024 | tooling (UI) | - |
| chargeback_agent | F2-payments | AG-F2-038 | decision (L2) | - |
| gateway_agent | F2-payments | AG-F2-039 | decision (L2) | - |
| psd2_agent | F2-payments | AG-F2-040 | decision | **[gated-counsel]** PSD2/OB AISP-PISP [needs-function-clarification] |
| dispute_agent | F2-payments | AG-F2-041 | decision (L2) | - |
| fee_agent | F2-payments | AG-F2-042 | decision (HITL) | - |
| beneficiary_agent | F2-payments | AG-F2-043 | decision (L2) | - |
| swift_agent | F2-payments | AG-F2-044 | decision (HITL) | - |
| fatca_agent | F2-identity | AG-F2-045 | decision | **[pending human ratification]** F2-identity vs F3-aml/regrep |
| compliance_automation_agent | F2-identity | AG-F2-046 | decision | **[pending human ratification]** room/type |
| compliance_sync/compliance_agent | F2-identity | AG-F2-047 | tooling | **[pending human ratification]** sync utility, room |
| compliance_calendar/calendar_agent | F2-identity | AG-F2-048 | decision | **[pending human ratification]** F2-identity vs F3-regrep |
| lending_agent | F1-customer-ops | AG-F1-034 | decision | **[pending human ratification]** F1 vs F3-risk (credit) |

- **Placed:** 23 / 23 (each verified by a read-only lineage/HITL scan; routing per AGENT-CLASSIFICATION-CRITERION).
- **[pending human ratification]:** 5 (fatca, compliance_automation, compliance_sync, calendar, lending) — routing/room genuinely contested; placed into the task-proposed room but flagged, not self-decided.
- **[gated-counsel]:** 2 (credit_scoring = Annex III; psd2 = open-banking).
- **Distribution added:** F3 +6, F4 +5, F2 +11, F1 +1.

## Part B — Duplicate-row resolution

- `customer_support_agent.py` — **exactly one table row**: `AG-F1-001` (F1-support). The mention in AGENT-REGISTRY-F2 (line ~67) is a **prose cross-floor note**, not a table row → allowed, retained as prose.
- `feedback_analytics_agent.py` — **exactly one table row**: `AG-F1-004` (F1-support). The mention in AGENT-REGISTRY-F3 (line ~52) is a **prose cross-floor note**, not a table row → allowed, retained as prose.
- **Result:** no duplicate table rows exist; no edit to existing rows was required. Cross-floor prose mentions are compliant with the one-row rule.

## Part C — Verdict

- **Census `*_agent.py` (no tests):** 86.
- **Placed after closure:** 86 → **UNPLACED remaining = 0**.
- **Duplicate table rows:** 0 (both flagged agents have a single row; other mentions are prose).
- **[pending human ratification]:** 5 (routing to be ratified by `[audit]` before MASTER consolidation).
- **[gated-counsel]:** 2 new (credit_scoring, psd2) — recorded, not closed; all legal → `[counsel]`.
- **Registry row totals after append:** F1 = 34, F2 = 48, F3 = 39, F4 = 24 (rows include functional non-`*_agent.py` entities beyond the 86 census; census coverage is the closure metric).

Ready for MASTER consolidation once `[audit]` ratifies the 5 pending routings. `[factory]` to confirm the counting canon (census 86 vs class 77 reconciliation).

---
**This does not replace legal advice.**
