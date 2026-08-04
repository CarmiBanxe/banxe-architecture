# CELL — DATA PROTECTION OFFICER (independent line)

**STATUS: PROPOSED — pending MC-C1 counsel-review. NOT canon.** · Sandbox-only · no push
Schema: `docs/orgcells/SCHEMA.md` (12 fields, validation V1–V6)
**Out of the department queue by design:** authored ahead of the remaining departments
because the DPO is a **statutory obligation** (GDPR Art. 37–39) sitting in a double gap —
no human appointed and no agent activated.

> **⚠ SCHEMA CONFLICT — DECLARED, NOT HIDDEN.** Under SCHEMA v1 this record cannot be made
> valid without breaking regulation. It is filed as a **schema-extension request (MC-C2)**,
> not as a passing record. See §"Why this record is not schema-valid" — that gap is the
> finding of this authoring step, not a defect to be smoothed over.

---

```yaml
cell_id: dpo
name: Data Protection Officer
kind: DEPARTMENT
reporting_line: INDEPENDENT_LINE   # ⚠ NOT a value in SCHEMA v1 — extension request MC-C2
vertical:
  manager_ref: null                # ⚠ violates V1 as written (V1 allows exactly two null-manager roots)
department_ref: null               # schema field 9: null for roots AND departments
data_policy: "sandbox-only; no secrets, no credentials, no real data"
status: PROPOSED                   # V5: no activation evidence cited → PROPOSED
```

**Why `kind: DEPARTMENT` rather than `CELL`:** `CELL` requires a non-null `department_ref`
— an owning department. Every candidate owner (CTO, COO, Risk, MLRO) is a party whose
processing the DPO must independently oversee, so ownership would itself be the conflict of
interest GDPR Art. 38(6) forbids. There is no lawful value for `department_ref` here, and
`DEPARTMENT` is the only kind whose schema shape (null `department_ref`) matches a function
area that owns leaf cells later (DPIA review, breach handling, data-subject requests).

## Why this record is not schema-valid — and why that is the correct outcome

SCHEMA v1 offers exactly two lines, `ENGINE_HIERARCHY` and `MLRO_LINE`, and exactly two
null-manager roots (V1). Placing the DPO requires choosing one of three options, and the
first two are unlawful rather than merely awkward:

| Option | Result | Verdict |
|---|---|---|
| `reporting_line: ENGINE_HIERARCHY`, `manager_ref: cto-dept` (or `engine-director`) | The CTO determines the means of processing; making the DPO its subordinate lets the controller instruct the DPO on the exercise of DPO tasks | **UNLAWFUL** — GDPR Art. 38(3) (no instructions), Art. 38(6) (no conflicting tasks) |
| `reporting_line: MLRO_LINE`, `manager_ref: mlro-root` | Schema-valid under V2, but the MLRO line itself processes personal data at scale for financial-crime purposes; the DPO would be supervised by a party whose processing it must oversee, and could be instructed by it | **UNLAWFUL for the same two articles** — independence from *every* processing owner, not just from the executive line |
| A third, independent line with no manager above it | Correct in regulation, **INVALID under V1 as written** (a third null-manager root) | **CHOSEN — filed as extension request MC-C2** |

The schema was built to make MLRO independence unrepresentable-if-violated (SCHEMA §4). The
same property now works against a second independent function it was not designed for: the
model is a **two-tree forest**, and the DPO is a third tree. Writing the DPO into either
existing tree would be silently unlawful; writing it as a third root is loudly invalid. The
loud option is the honest one, so it is the one taken.

**Proposed amendment (for counsel + schema owner, not applied here):** extend field 5 to
`ENGINE_HIERARCHY | MLRO_LINE | INDEPENDENT_LINE`, and restate V1 as *"each tree has exactly
one root with `manager_ref: null`; roots are `ENGINE_DIRECTOR`, `MLRO_ROOT`, and any cell
whose independence is statutory"* — with the statutory-independence class enumerated
(currently: DPO under GDPR Art. 37–39; Internal Audit SMF5 as third line of defence, per the
parent org canon). Until that amendment passes review, this record stays PROPOSED and
schema-INVALID by declaration.

## DPO independence — structural proof (what must hold once MC-C2 is granted)

Let `L(c)` be `reporting_line` and `M(c)` the `vertical.manager_ref` of cell `c`.

1. `L(dpo) = INDEPENDENT_LINE`, `M(dpo) = null` — no cell is above the DPO, so no record can
   be written that instructs it on DPO tasks through a `vertical` edge.
2. V2 (same-line management) is what does the work: any cell claiming `manager_ref: dpo`
   would need `L(that cell) = INDEPENDENT_LINE`, so the DPO cannot be pulled into either
   existing tree by an edge written from the other side either.
3. `L(cto-dept) = ENGINE_HIERARCHY ≠ INDEPENDENT_LINE` and `L(mlro-root) = MLRO_LINE ≠
   INDEPENDENT_LINE`. Therefore **neither the CTO department, nor the COO line, nor the
   engine, nor the MLRO root can appear anywhere on the DPO's vertical chain** — the record
   that would express it fails V2 and cannot be written.
4. The only expressible relation to any of them is `horizontal[]` — cooperation, explicitly
   not authority (V4). That is exactly the GDPR shape: the DPO **advises, monitors and
   objects**; it does not receive instructions and cannot be tasked.
5. Reporting direction: the DPO reports to the highest management level (Board), which in
   this model is represented by the absence of any manager, not by an edge to an executive.

**Conclusion:** once MC-C2 is granted, DPO independence becomes a property of the data model
in the same way MLRO independence already is — a reorganisation subordinating the DPO to the
CTO could not be written as a valid record at all.

## functions[] (PRIMARY) — the first three control duties

| # (exec order) | name | description | input → output |
|---|---|---|---|
| 1 | `dpia_oversight` | Advises on and reviews Data Protection Impact Assessments for high-risk processing, and monitors that the assessment actually precedes the processing. In this bank the standing triggers are AI-driven decisioning on customers, biometric/IDV processing, and large-scale financial-crime monitoring. | proposed processing change + risk profile → DPIA required? → DPIA opinion (advice, objection, or no-objection) recorded before processing starts |
| 2 | `data_subject_rights` | Owns the handling path for data-subject requests (access, rectification, erasure, restriction, portability, objection), including the interaction with retention duties that override erasure — AML record-keeping being the standing example. | data-subject request → verified request → routed fulfilment plan with lawful-basis and retention conflicts resolved → response within the statutory period |
| 3 | `breach_notification_72h` | Owns the personal-data-breach path: assessment of risk to data subjects, notification to the supervisory authority **within 72 hours** of becoming aware where the risk threshold is met, and communication to affected individuals where the risk is high. Owns the clock, the record, and the decision not to notify (which must itself be documented). | breach signal → risk assessment → notification decision + supervisory-authority notification within 72h (or documented no-notify) + breach register entry |

Execution order is the control rhythm: 1 is preventive (before processing), 2 is continuous
(on request), 3 is reactive with a hard statutory deadline. Further duties (records of
processing, training, supervisory-authority contact point, processor oversight) attach as
leaf cells in a later step.

## horizontal[]

| peer_ref | interaction |
|---|---|
| `cto-dept` *(ENGINE_HIERARCHY)* | **Cooperation, asymmetric by law.** The CTO department notifies this cell of processing changes, platform work with a personal-data dimension, and DPIA triggers; this cell reviews, advises and may object. The CTO department **must never** appear on this cell's `vertical` chain — it determines means of processing (Art. 38(3)/(6)). Correspondingly, this cell does not manage the CTO department either: it cannot deploy, cannot block a release by authority, and its objection is recorded and escalated, not executed. |
| `mlro-root` *(MLRO_LINE)* | **Cooperation between two independent functions — neither supervises the other.** Financial-crime monitoring processes personal data at scale; this cell oversees that processing lawfully, while the MLRO line retains sole authority over SAR/PEP/sanctions determinations. Where AML retention duties conflict with an erasure request, the two lines resolve it jointly on the record; neither can instruct the other. |
| `safeguarding-recon` *(ENGINE_HIERARCHY)* | Cooperation on customer-data handling inside safeguarding and reconciliation records; advisory and monitoring only. |

## authority

- **Alone:** issue DPIA opinions and objections; determine that a data-subject request is valid and set its fulfilment path; assess a breach and **decide that the 72-hour notification threshold is met**; maintain the breach register and the record of processing.
- **Never alone / not held at all:** this cell does not deploy, does not block releases by its own authority, does not file SARs, does not approve PEPs, and does not reverse sanctions decisions. Its instrument is a recorded objection plus escalation to the Board line, not execution.
- **Cannot be overridden downward:** an objection may be overruled only at the level this cell reports to, and the overrule must be recorded. No department, and not the engine, can dispose of a DPO objection by ordinary authority.
- **HITL binding:** breach notification and DPIA objection are **BLOCK-class** — a human decision is mandatory, never auto-resolved by confidence band.

## source_refs[] (paths only — ADR-102, never duplicated)

| Path | Resolution | What is referenced |
|---|---|---|
| `governance/CANONICAL-ORG-CHART-v2.md` | **repo-local** | DPO named in the 2nd line of defence; the independent-line pattern (MLRO to Board; Internal Audit SMF5 as third line, outside every executive department) that this record extends to the DPO |
| `docs/architecture/BANK-OPERATING-MODEL-FOUR-FLOORS-2026-07-18.md` | **repo-local** | the recorded double gap — `privacy_compliance_agent` desync (OD-5) and no human DPO appointed |
| `docs/orgcells/SCHEMA.md` | **repo-local** | field 5 / V1 / V2 — the constraints this record deliberately exceeds under MC-C2 |

## INVARIANT CHECK (exercises V1–V6 on this record)

- **V1 — VIOLATED BY DECLARATION.** A third `manager_ref: null` cell is not permitted by V1 as written. This is the extension request MC-C2, filed openly; it is not an oversight and must not be "fixed" by attaching the DPO to an existing tree — that fix would be unlawful (see the options table).
- **V2 — SATISFIED VACUOUSLY, AND LOAD-BEARING ONCE GRANTED.** No manager is referenced, so no cross-line edge exists. Once `INDEPENDENT_LINE` is a valid value, V2 is precisely the rule that keeps CTO, COO, engine and MLRO off this cell's vertical chain.
- **V3 — CHECKED, NOT TRIGGERED.** The DPO's duties are data-protection oversight, not financial-crime compliance-monitoring; V3 does not pull this cell onto `MLRO_LINE`, and doing so would be unlawful for the reason given above. If counsel reads DPIA oversight as a compliance-monitoring class under V3, that reading must be resolved **in MC-C2**, not by silent reassignment.
- **V4 — SATISFIED.** All three peers are `horizontal`; no `vertical` edge crosses any line.
- **V5 — SATISFIED.** `status: PROPOSED`; no activation evidence exists — consistent with the fact that no human DPO is appointed.
- **V6 — SATISFIED.** `source_refs[]` are paths only.

## MT-05 note

No `aml_orchestrator` reference is made or resolved here. The identity conflict stays FROZEN.

---
**This does not replace legal advice.** GDPR articles are cited as the reason a structure is
required; the sufficiency of this structure is for counsel and the DPO once appointed.
