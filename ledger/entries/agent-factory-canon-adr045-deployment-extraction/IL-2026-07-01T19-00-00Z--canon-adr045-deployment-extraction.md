---
il_ts: 2026-07-01T19:00:00Z
session_id: agent-factory-canon-adr045-deployment-extraction
source: factory
status: PREPARED
parent_il: IL-122-INTENT-FIRST-CANON-2026-06-07
---
### IL-777 — Resolve CONFLICT-1 (IL-122 audit): extract ADR-045 deployment spec to runbook

- **Task:** Restore ADR-045 to true CONCEPT-ONLY status by extracting the
  "Deployment & Activation" section into a dedicated runbook.
- **Root cause (IL-122 audit CONFLICT-1):** ADR-045 is labelled "CONCEPT ONLY — no
  KYC/Notification/CRM code" but contained a full operational spec (planner.yaml block,
  runtime deps table, deployment trigger, backward-compat note). The label was untruthful.
- **Changes:**
  1. **Created** `docs/runbooks/intent-dispatcher-deployment.md` — contains the FULL
     "Deployment & Activation" content (planner.yaml, Dispatcher Runtime Dependencies,
     Deployment Trigger, Backward Compatibility) moved verbatim from ADR-045.
     Frontmatter: `il_anchor: IL-122-INTENT-FIRST-CANON-2026-06-07`,
     `source_adr: ADR-045`, `extraction_il: IL-777`.
  2. **Modified** `docs/adr/ADR-045-intent-first-banking-architecture.md` — §"Deployment
     & Activation" replaced with a 3-line pointer to the runbook. ADR label "CONCEPT ONLY"
     is now truthful.
  3. **Modified** `docs/canon/INTENT-FIRST-CANON-2026-06-07.md` — Anchors list extended
     with the new runbook path. Canon text and principles unchanged.
- **Canon preserved:** INTENT-FIRST-CANON-2026-06-07.md content is NOT weakened;
  ADR-045 decision text (D1–D7, Consequences, Alternatives) is unmodified.
- **Invariants:** I-24 (append-only); scope governance artefacts only (no project code).
- **Parent IL:** IL-122-INTENT-FIRST-CANON-2026-06-07.
- **Gate-out:** ADR-045 CONCEPT-ONLY label is now truthful; runbook holds all ops detail.
- **Status:** PREPARED — operator HITL before merge.
