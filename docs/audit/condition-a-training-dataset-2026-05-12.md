# Condition A — Training Dataset Template (Draft)

Document ID: COND-A-DRAFT-2026-05-12
Status: DRAFT — template only, no dataset exists
Scope: Condition A draft per Sprint 4 audit (PR #219)
Track: Innovation Sandbox / Conditions A–D batch (Clause 16)
Date: 2026-05-12

---

## 1. Scope

Condition A requires five artifacts:
1. Data source identification
2. Schema definition
3. Label / target class definition
4. Storage location approval
5. Data handling path review

This document provides a TEMPLATE for the dataset. Sub-A cannot
collect, create, or label data. The operator and data team must
populate this template with a real source and real labels.

---

## 2. Data Source

**Source: __________ (to be named by operator)**

Possible candidates (for operator consideration, not Sub-A decisions):
- Historical request logs from LiteLLM proxy (Legion)
- Compliance-api audit trail (if available and approved)
- Synthetic generation plan (operator must approve methodology)
- Manual curation from domain experts

Sub-A has no visibility into which data sources exist or are
permissible. This is entirely an operator + data team decision.

---

## 3. Schema Definition

Each sample in the dataset must conform to this schema:

```json
{
    "sample_id": "uuid",
    "ts": "ISO8601",
    "prompt": "string (sanitized, PII-stripped at ingest)",
    "label": "fraud_signal | compliance_query | reasoning_task | developer_task",
    "label_confidence": 0.0,
    "labeler": "string (identifier of who labeled this sample)",
    "split": "train | val | test"
}
```

### Field definitions

| Field | Type | Required | Description |
|---|---|---|---|
| `sample_id` | UUID | YES | Unique identifier for this sample |
| `ts` | ISO 8601 string | YES | Timestamp of the original prompt (or creation time for synthetic) |
| `prompt` | string | YES | The prompt text, sanitized and PII-stripped at ingest time |
| `label` | enum | YES | One of the 4 defined classes |
| `label_confidence` | float (0.0-1.0) | YES | Labeler's confidence in the assigned label |
| `labeler` | string | YES | Identifier of who labeled this sample (for audit trail) |
| `split` | enum | YES | Dataset split: `train`, `val`, or `test` |

### PII handling at ingest

- ALL personal data must be stripped before storage.
- Prompt text is sanitized at ingest, not retroactively.
- The sanitization method must be documented and approved.
- No raw customer data in the dataset under any circumstance.

---

## 4. Label Definitions

### fraud_signal

Prompt suggests a transaction with fraud indicators. This includes
prompts referencing unusual jurisdictions, suspicious counterparties,
structuring patterns, identity inconsistencies, or any request that
a compliance officer would flag for manual review. The presence of
fraud indicators does not mean confirmed fraud — it means the prompt
warrants elevated scrutiny.

### compliance_query

Prompt asks about FCA regulations, AML procedures, KYC requirements,
safeguarding obligations, or regulatory interpretation. This includes
both direct questions ("What are the FCA requirements for...") and
indirect references that require regulatory context to answer
correctly. When a prompt combines compliance content with another
class (e.g., coding), the regulated dimension takes precedence.

### reasoning_task

Multi-step reasoning request that is typically non-regulated. This
covers analytics, technical analysis, document drafting, strategic
planning, and general knowledge questions that do not touch fraud
or compliance domains. The distinguishing factor is that misrouting
this class has no regulatory consequence.

### developer_task

Coding or DevOps request from an internal user. This includes code
generation, debugging, infrastructure configuration, CI/CD work,
and technical tooling questions. These requests are internal and
have no regulatory sensitivity.

---

## 5. Dataset Size and Split

### Minimum size for pilot

| Split | Samples per class | Total |
|---|---|---|
| Train | 800 | 3200 |
| Validation | 100 | 400 |
| Test | 100 | 400 |
| **Total** | **1000** | **4000** |

### Split ratio

- 80% train / 10% validation / 10% test
- Stratified: each split maintains equal class distribution
- Split assignment is fixed at dataset creation — no re-splitting
  during the pilot

---

## 6. Quality Controls

### Labeling process

1. Each sample is labeled by two independent labelers.
2. Agreement is checked automatically: if both labelers assign the
   same class, the label is accepted.
3. Disagreements are escalated to a senior reviewer who makes the
   final label decision with a justification note.

### Ongoing quality

- 5% audit sample: each month, 5% of the dataset is re-labeled by
  a different labeler to check for drift.
- If re-labeling agreement drops below 90%, the labeling guidelines
  are revised and affected samples are re-reviewed.

### Documentation

- Labeling guidelines document (to be written by data team)
- Inter-annotator agreement report (produced after initial labeling)
- Monthly audit reports

---

## 7. Storage

**Storage location: __________ (to be approved by operator)**

### Constraints

- On-prem storage: PostgreSQL or ClickHouse on evo1 or evo2.
- Per FCA on-prem invariant: NO external cloud storage.
- NO upload to any cloud labeling service.
- NO export outside Banxe perimeter.
- Access restricted to authorized personnel only.
- Backup policy: same as production database backups.

---

## 8. Data Handling Path

### Ingest

```
Raw source -> PII stripping -> Schema validation -> Storage
```

- PII stripping is mandatory before any other processing.
- Schema validation rejects samples with missing required fields.
- Rejected samples are logged (without content) for review.

### Access

- Read access: classifier training pipeline, evaluation pipeline,
  authorized reviewers.
- Write access: ingest pipeline only. No manual edits after ingest.
- Delete access: operator only, with audit trail.

### Export

- NO export outside Banxe perimeter.
- Internal exports (e.g., for evaluation) must use the same access
  controls as the primary storage.

---

## 9. Operator Actions Required

- [ ] Name a data source
- [ ] Approve storage location
- [ ] Approve data handling path (ingest, access, export rules)
- [ ] Assign labelers (minimum 2 independent labelers + 1 senior reviewer)
- [ ] Approve PII sanitization method
- [ ] Approve labeling guidelines (after data team drafts them)

---

## 10. Decision

Condition A draft: COMPLETE (template only).
Execution: NOT STARTED — requires operator to name a data source and
approve handling path. Sub-A has no authority over dataset sourcing.

---

## 11. References

- PR #219 — Sprint 4 readiness audit
- PR #223 — Sprint 5 pilot plan
- `docs/audit/condition-c-evaluation-protocol-2026-05-12.md` (evaluation dependency)
