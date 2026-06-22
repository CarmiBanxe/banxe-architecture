# SPRINT-5-INTERNAL-AUDIT-LINE — Banxe AI Bank Internal Audit Independent Line Completion (NORMATIVE)

> **Status:** Sprint-5 — Internal Audit Independent Line Completion (2026-06-22). **Normative** — child of the
> org canon.
> **Parent:** `governance/CANONICAL-ORG-CHART-v2.md` (frozen org structure, Sprint-1). On any conflict the
> parent canon wins for *structure*; this document is authoritative for the *Internal Audit (3rd-line)
> independent-line operating model*. **Companions:** `governance/STAFF-MATRIX-v2.md` (Sprint-3 staffing
> record — **NOT modified here**) and `governance/SPRINT-4-MLRO-LINE.md` (the sibling MLRO 2nd-line
> completion — this document is the 3rd-line counterpart).
> **Supersedes:** nothing — **append-only** over the Sprint-4 record. The Sprint-3 staffing figures
> (44/44 passports active, 0 PROPOSED remaining, 21 gated under I-27) are unchanged by this document.
> **Scope:** completion-over-existing (ADR-102 anti-duplication) of the Internal Audit independent **3rd
> line of defence** that ORG-CHART-v2 §4/§6 (SMF5, outsourced Grant Thornton sandbox) already establishes.
> This document adds ONLY the *delta* — the operating model, annual safeguarding-audit contour, audit
> plan/workpaper model, finding/remediation lifecycle, Audit-Committee reporting chain, evidence binding to
> the existing immutable trail, and acceptance gates — over the artefacts that already exist. It is
> **greenfield-free**.
> **HITL note:** `HITL-MATRIX.yaml` is NOT modified — Internal-Audit actions are *mapped* to existing gates
> (esp. **HITL-011** Safeguarding Shortfall Alert) by reference only. **STAFF-MATRIX-v2 / -v1 are NOT
> modified.**
> **Activation note:** This is a **governance-only** document. **NO live activation.** No agent is created,
> activated, or wired by this file. The `safeguarding_audit_agent` remains **PROPOSED**; the
> `internal_audit_agent` remains an **active department-head STUB that PROPOSES only** (I-27). Any new role
> introduced here is a **PROPOSED inline stub** only. Live audit execution / finding issuance remains gated
> on **I-27 HITL-L4 sign-off**.

---

## 1. Purpose & method

Establish the **completion delta** for the Internal Audit independent **3rd line of defence**. ORG-CHART-v2
already freezes the *structure* (Internal Audit = SMF5, outsourced Grant Thornton UK sandbox, reports to the
**Audit Committee / Board**, NOT under any executive; read-only — humans issue findings). Sprint-3
STAFF-MATRIX-v2 already records the department-head staffing. What remains — and what this document supplies,
append-only — is the **operating-model layer** of the Internal Audit line: how the annual safeguarding audit
contour is scoped, how the risk-based audit plan and workpapers are structured, how findings flow through
remediation, how the Audit-Committee pack reaches the Board, and how audit evidence binds to the existing
immutable trail.

**Method = completion-over-existing (ADR-102).** Each section below is written as
**[Existing ref] → [Gap delta]**: it first names the artefact that already covers the area, then states
*only the additive delta* this document contributes. Nothing existing is rewritten or duplicated.

**Existing artefacts referenced (read-first):**

| Artefact | Role | What it already covers |
|----------|------|------------------------|
| `governance/CANONICAL-ORG-CHART-v2.md` §4/§5/§6 | Parent canon | Internal Audit = **3rd independent line**, SMF5 (Grant Thornton UK, outsourced sandbox), reports to **Audit Committee / Board** (NOT under CEO/CFO/COO), read-only / humans issue findings; "Annual Safeguarding Audit" owned by Internal Audit 3rd line (NOT smeared across COO; daily ops stay under COO Dept-4 `safeguarding_recon_governor`) |
| `agents/passports/internal_audit_agent.yaml` | Passport (active STUB) | `status: active`, L1 · RED · `autonomy: L2_REVIEW`, **dept-head** ("Internal Audit (independent)"), SMF5, 3rd line to Audit Committee / Board, `human_double: Grant Thornton UK (outsourced)`. Capabilities = a **STUB** (`department_head_orchestration  # TODO Sprint-3: specify code-derived capabilities`); **PROPOSES only (I-27)**, NOT activated |
| `agents/passports/safeguarding_audit_agent.yaml` | Passport (**PROPOSED**) | `status: PROPOSED`, L2 · RED · `autonomy: L2_REVIEW`; caps `safeguarding_audit_prep`, `reconciliation_evidence_collect`, `cass15_control_check`, `audit_finding_draft`; `human_double: Head of Internal Audit`; ports `AuditRequestPort` (in) / `CompliancePort` + `AuditPort` (out); invariants **I-27** (PROPOSES only) / **I-28** (append-only audit evidence); FCA refs PS25/12 (relevant funds > GBP 100k) + CASS 15 |
| `agents/passports/spec_first_auditor.yaml` | Passport (ACTIVE, dev-plane) | AMBER · L2_REVIEW; Developer-Plane Spec-First control; **NO Write/Edit — audits/blocks only, never fixes**. Cited as precedent for the read-only-auditor discipline |
| `agents/passports/board_reporting_agent.yaml` | Passport (exists) | Board / committee reporting-pack preparation; board sign-off gate (the §5 reporting chain target) |
| `decisions/ADR-027-audit-trail-durability.md` | ADR (Accepted) | FCA **CASS 15 §15.10** evidence chain via **ClickHouse `banxe.safeguarding_audit`** written by `src/safeguarding/audit_trail.py`; durable / append-only audit-trail strategy; invariants I-32/I-33; **I-28** append-only durability |
| `HITL-MATRIX.yaml` | Gates (read-only) | **HITL-011** Safeguarding Shortfall Alert (`required_roles: [CFO, MLRO]`, `auto_allowed: false`, `fca_basis: CASS 7.15.17R; CASS 7.13.6R`, severity critical) and the full HITL-001…017 set |
| `banxe-emi-stack: src/safeguarding/annual_audit.py` (SP-THIN) · `src/safeguarding/audit_trail.py` | emi-stack code | already mapped to the Internal-Audit 3rd line in ORG-CHART-v2 §7. **No emi-stack change in this sprint** (arch-only) |

---

## 2. Internal Audit operating model — 3rd-line independence

**[Existing ref]** ORG-CHART-v2 §4 + §6: Internal Audit is the **3rd independent line**, owner = Internal
Audit (SMF5, outsourced Grant Thornton UK sandbox), **reports to the Audit Committee / Board**, "Read-only;
humans issue findings". The `internal_audit_agent` passport is `status: active` but is an explicit
**department-head STUB** — its only capability is `department_head_orchestration  # TODO Sprint-3` and it
**PROPOSES only (I-27)**.

**[Gap delta] — explicit operating-model statement + the STUB capability replaced by a code-derived audit
capability list (governance-only description, no activation):**

1. **Independence (structural):** Internal Audit reports **only** to the **Audit Committee / Board**. No
   executive (CEO SMF1, CFO SMF2, COO SMF24, CRO) may instruct, override, or suppress an audit finding, scope,
   or opinion. The SMF5 holder (Grant Thornton UK, outsourced sandbox) owns the audit opinion; findings are
   **issued by humans**, non-delegable.
2. **Read-only discipline (canon, mirrors `spec_first_auditor`):** all Internal-Audit-line agents are
   **RED-zone, read-only auditors** — they may *read evidence, run controls checks, draft workpapers and
   findings*, but **never** *mutate a production record, sign off a finding, or close an audit item*. As with
   `spec_first_auditor` (no Write/Edit — audits/blocks only), the audit agents **PROPOSE only**; the human
   (Head of Internal Audit / SMF5) issues.
3. **Code-derived audit capability list (replaces the STUB):** the `internal_audit_agent` STUB capability
   `department_head_orchestration  # TODO` is, for governance purposes, the orchestration of the following
   **draft-only** audit capabilities (all RED, all PROPOSES-only, none mutating):
   - `audit_plan_draft` — risk-based annual audit plan (see §3);
   - `workpaper_assemble` — assemble workpapers / test evidence (see §3);
   - `cass15_control_check` — CASS 15 / safeguarding control testing (already on `safeguarding_audit_agent`);
   - `reconciliation_evidence_collect` — pull reconciliation evidence (already on `safeguarding_audit_agent`);
   - `audit_finding_draft` — draft finding text (already on `safeguarding_audit_agent`);
   - `remediation_track_draft` — draft finding-remediation status (see §4);
   - `audit_committee_pack_draft` — assemble the Audit-Committee pack (see §5; delegates rendering to
     `board_reporting_agent`).
   This is a **governance-only description**. It grants no runtime capability; it does **not** edit the
   passport file; it states what the active STUB *orchestrates by reference* once a separately-authorised
   sprint codes it. **No new capability is wired here.**
4. **No new authority is created here.** This section makes explicit what ORG-CHART-v2 §4/§6 already implies.

---

## 3. Annual safeguarding audit contour (FCA safeguarding regime · CASS 15 · PS25/12)

> **GOVERNANCE-ONLY — no live audit execution is enabled by this document.**

**[Existing ref]** `safeguarding_audit_agent` (PROPOSED) prepares evidence/findings for the **annual
safeguarding audit** (PS25/12; **relevant funds > GBP 100k**) against **CASS 15**; ORG-CHART-v2 §7 fixes
"Annual Safeguarding Audit" to the **Internal Audit 3rd line** (NOT smeared across COO), with emi-stack
`src/safeguarding/annual_audit.py` (SP-THIN). Daily safeguarding **operations** stay under **COO Dept-4
`safeguarding_recon_governor`**.

**[Gap delta] — the annual-audit contour / scope, distinct from daily COO safeguarding ops:**

1. **Boundary (annual assurance vs daily ops):** the **daily** reconciliation / shortfall-detection contour
   (`safeguarding_recon_governor`, 1st/2nd-line operations) is **out of scope** of this line except as an
   *object under audit*. The Internal-Audit 3rd line performs the **independent annual safeguarding audit** —
   an assurance review *over* those operations — under PS25/12, only where **relevant funds > GBP 100k**.
2. **Scope of the annual audit (governance description):** segregation of relevant funds; daily internal
   reconciliation evidence (CASS 15 §15.10); resolution-pack / acknowledgement-letter completeness;
   shortfall-handling controls; FIN060 submission integrity. Evidence is **collected, not generated** —
   `reconciliation_evidence_collect` / `cass15_control_check` *read* the existing trail (§6).
3. **Trigger / cadence:** annual (PS25/12), plus event-driven where a **HITL-011 Safeguarding Shortfall
   Alert** (CASS 7.15.17R / 7.13.6R, `required_roles: [CFO, MLRO]`, severity critical) indicates a
   control weakness that the audit plan (§3) must pick up at the next cycle or as an out-of-cycle review.
4. **Owner:** the audit is owned by the **Head of Internal Audit / SMF5 (Grant Thornton UK)**; the
   `safeguarding_audit_agent` only *prepares* — it remains **PROPOSED**, draft-only, until I-27.

---

## 4. Audit plan + workpaper model

**[Existing ref]** `internal_audit_agent` is the **department-head** (orchestration) agent of the line; its
capabilities are a STUB pending code derivation (§2). `safeguarding_audit_agent` provides
`safeguarding_audit_prep` and `reconciliation_evidence_collect`.

**[Gap delta] — risk-based annual audit plan + workpaper structure (governance model):**

1. **Risk-based annual audit plan (`audit_plan_draft`, draft-only):** the line maintains a **risk-based
   annual audit universe** — each auditable entity (safeguarding, AML/financial-crime line, prudential
   reporting, ICT/DORA resilience, outsourcing) carries a residual-risk rating that drives audit frequency.
   The agent **drafts** the plan; the **Audit Committee approves** it (human, non-delegable). No agent
   self-approves a plan.
2. **Workpaper model (`workpaper_assemble`, draft-only):** each audit produces a workpaper set with a fixed
   skeleton — *scope → control population → test design → evidence reference (ClickHouse trail, §6) →
   exception list → draft finding → draft opinion*. Workpapers are **append-only** (I-28): the agent assembles
   and references; it never edits a prior workpaper or a source record.
3. **Independence preserved:** plan and workpapers are draft artefacts presented to the human auditor; the
   agent has **no authority to conclude** — opinions are issued by the Head of Internal Audit / SMF5.

---

## 5. Issue / finding follow-up + remediation tracking

**[Existing ref]** `safeguarding_audit_agent` provides `audit_finding_draft` (draft only); invariant **I-27**
(agent PROPOSES only — Internal Audit signs off).

**[Gap delta] — finding lifecycle · owner · remediation SLA · re-test:**

1. **Finding lifecycle (governance model):**
   `audit_finding_draft (RED, draft)` → **Head of Internal Audit review & issue (human, I-27)** →
   **remediation owner assigned (1st/2nd-line management)** → **remediation SLA tracked** → **re-test by
   Internal Audit** → **finding closed (human sign-off only)**.
2. **Owner:** every issued finding has **exactly one accountable remediation owner** in the line being
   audited (never Internal Audit itself — independence). No finding is unowned.
3. **Remediation SLA:** each finding carries a severity-graded remediation SLA; **breaches are surfaced in the
   Audit-Committee pack** (§5/§reporting) as overdue-remediation control flags. A **HITL-011** safeguarding
   shortfall escalates immediately, independent of the audit-plan cadence.
4. **Re-test (independence + append-only):** closure requires an **independent re-test**; the
   `remediation_track_draft` capability *drafts* status only. **No agent closes a finding** — closure is a
   human (Head of Internal Audit) sign-off, recorded append-only (I-28). Findings cannot be self-signed-off.

---

## 6. Audit reporting line + Audit-Committee pack (GOVERNANCE-ONLY)

> **GOVERNANCE-ONLY — no live submission of any kind is enabled by this document.**

**[Existing ref]** ORG-CHART-v2 §4/§5/§6: Internal Audit reports to **Audit Committee / Board**;
`board_reporting_agent` (passport exists) prepares board/committee reporting packs with a board sign-off gate;
the line is "read-only — humans issue findings".

**[Gap delta] — Audit-Committee reporting chain + pack; non-delegable human sign-off:**

1. **Reporting chain (drafts → human sign-off → Audit Committee → Board):**
   `internal_audit_agent` / `safeguarding_audit_agent` (workpapers + findings, RED/draft) →
   **Head of Internal Audit (SMF5) review & sign (human, non-delegable)** → `board_reporting_agent`
   (assemble Audit-Committee pack, draft render) → **Audit Committee** → **Board**. Agents produce **drafts
   only**; every committee-facing artefact carries a human sign-off before presentation.
2. **Audit-Committee pack (`audit_committee_pack_draft`):** the periodic pack carries — audit-plan progress,
   open findings by severity, overdue-remediation flags (§4), the annual safeguarding-audit opinion (§3), and
   any HITL-011 shortfall escalations. Rendering delegates to `board_reporting_agent`; content is drafted by
   the audit-line agents and **signed by the Head of Internal Audit (human)**.
3. **Non-delegable sign-off (canon):** the audit opinion and every issued finding are **signed off by the
   Head of Internal Audit / SMF5 (human)** — **non-delegable to any agent**. Agents **draft only**. No agent
   submits a committee pack or issues an opinion.

---

## 7. Evidence binding to existing services / audit trail

**[Existing ref]** **ADR-027** (Accepted): the FCA **CASS 15 §15.10** evidence chain runs through
**ClickHouse `banxe.safeguarding_audit`**, written by `src/safeguarding/audit_trail.py`; the durability
strategy makes the trail **append-only** (I-28, I-32/I-33). `safeguarding_audit_agent` outbound `AuditPort`
is described as "append-only audit trail of findings (I-28)".

**[Gap delta] — how audit evidence binds to the existing immutable trail (reference, NOT re-implementation):**

1. **Bind, do not rebuild:** the Internal-Audit line **reads** the existing **ClickHouse
   `banxe.safeguarding_audit`** trail (via the ADR-027 path `src/safeguarding/audit_trail.py`) as its
   primary evidence source. `reconciliation_evidence_collect` and `cass15_control_check` **reference** trail
   rows; they do **not** create a parallel audit store. **No new persistence is introduced here.**
2. **Append-only evidence (I-28):** finding-evidence and workpaper references are recorded append-only through
   the existing `AuditPort` semantics (I-28). The audit line never mutates or deletes a trail row — consistent
   with ADR-027's durability decision and I-32/I-33 integrity invariants.
3. **No emi-stack change (arch-only):** this sprint **references** `src/safeguarding/audit_trail.py` /
   `src/safeguarding/annual_audit.py` (SP-THIN) and the ClickHouse schema; it makes **no code change** to
   emi-stack. Any future wiring is a separately-authorised, gated change.

---

## 8. Optional PROPOSED inline stub (governance-only — prefer the existing `safeguarding_audit_agent`)

> **Anti-dup (ADR-102):** the existing **`safeguarding_audit_agent`** (PROPOSED) already covers
> safeguarding-audit prep, reconciliation evidence, CASS 15 control checks, and finding drafting — **prefer it
> over inventing new roles**. The single genuine gap not already on an existing passport is the
> **finding-remediation tracking + Audit-Committee-pack drafting** orchestration described in §4–§6. It is
> recorded below as a **PROPOSED inline stub only** — it does **NOT** alter STAFF-MATRIX-v2's Sprint-3 record
> (44/44 active, 0 PROPOSED remaining), is **NOT** created as a separate passport file, is **NOT** activated,
> and is **NOT** wired. Live execution only after **I-27 HITL-L4 sign-off**.

```yaml
# PROPOSED — Sprint-5 forward proposal. NOT live. NOT activated. NOT a separate file.
# Does NOT alter STAFF-MATRIX-v2 (Sprint-3: 44/44 active, 0 PROPOSED remaining).
# Live audit-tracking / pack-drafting gated on I-27 HITL-L4 sign-off.

- agent_id: audit_remediation_tracker_agent
  status: PROPOSED                # NOT active; STAFF-MATRIX-v2 unchanged
  trust_zone: RED
  autonomy_level: L2_REVIEW
  function: >
    Draft-only orchestration of finding-remediation tracking + Audit-Committee pack
    assembly (delegating render to board_reporting_agent). Read-only auditor; never
    closes a finding, never signs an opinion, never mutates a source record.
  human_double: { primary: HEAD_OF_INTERNAL_AUDIT, secondary: SMF5_GRANT_THORNTON }
  hitl_gates: [HITL-011]          # Safeguarding Shortfall Alert — EXISTING gate (read-only ref)
  invariants: [I-27, I-28]        # PROPOSES only; append-only audit evidence
  forbidden_actions:
    - self_sign_off                # findings/opinions are human (Head of Internal Audit), non-delegable
    - close_finding_without_human
    - mutate_audit_trail           # ADR-027 trail is append-only (I-28)
    - issue_audit_opinion
  activation_precondition: I-27 HITL-L4 sign-off
```

**Note (canon):** this stub is RED-zone, draft-only, forbids self-sign-off / opinion issuance / trail
mutation, and references the **existing HITL-011** gate by ID only. It introduces **no new gate** and **no new
authority**. It exists **only in this file** as a Sprint-5 forward proposal. **STAFF-MATRIX-v2 / -v1 and
HITL-MATRIX.yaml are NOT modified.** Prefer the existing `safeguarding_audit_agent` for all
safeguarding-audit work; this stub covers only the genuine remediation-tracking / pack-drafting gap.

---

## 9. Acceptance criteria & gate-preconditions

**[Existing ref]** ORG-CHART-v2 §4/§6 (Internal Audit 3rd line frozen), `internal_audit_agent` (active
dept-head STUB, PROPOSES only), `safeguarding_audit_agent` (PROPOSED), ADR-027 (audit-trail durability),
HITL-MATRIX.yaml (HITL-011), I-27 / I-28.

**[Gap delta] — acceptance criteria for S5 line-completion + gate-preconditions:**

**Acceptance (this Sprint-5 document is complete when):**
1. The Internal-Audit operating model (§2) states 3rd-line independence + read-only discipline explicitly, and
   replaces the `internal_audit_agent` STUB capability with a code-derived **draft-only** audit capability
   list (governance description, no activation) — **done**.
2. The annual safeguarding-audit contour (§3) is scoped distinctly from daily COO safeguarding ops
   (PS25/12, CASS 15, relevant funds > GBP 100k) — **done**.
3. The risk-based audit plan + append-only workpaper model (§4) is stated — **done**.
4. The finding lifecycle / owner / remediation SLA / re-test (§5) is stated — **done**.
5. The Audit-Committee reporting chain + pack (§6) fixes the non-delegable human sign-off; agents draft only —
   **done**.
6. Evidence binding (§7) references the existing ClickHouse `banxe.safeguarding_audit` trail (ADR-027,
   `src/safeguarding/audit_trail.py`, I-28) — reference, not re-implementation — **done**.
7. Any new role exists as a **PROPOSED** inline stub only (§8), NOT live; the existing
   `safeguarding_audit_agent` is preferred; STAFF-MATRIX-v2 / -v1 and HITL-MATRIX.yaml are **untouched**; no
   separate passport files created; no emi-stack change — **done**.

**Gate-preconditions (what each gate unblocks):**
- **I-27 HITL-L4 sign-off** is the precondition for activating ANY PROPOSED stub — both the existing
  **`safeguarding_audit_agent`** (which stays PROPOSED) and the §8 `audit_remediation_tracker_agent`. Until
  I-27 sign-off, live safeguarding-audit execution, finding issuance, and remediation tracking are
  **blocked**; the stubs remain PROPOSED. The `internal_audit_agent` remains an active dept-head STUB that
  **PROPOSES only**.
- **HITL-011** (Safeguarding Shortfall Alert; CFO + MLRO; `auto_allowed: false`) is the existing human gate
  that escalates a safeguarding shortfall surfaced by audit; **no agent bypasses it**.
- **Human sign-off (Head of Internal Audit / SMF5)** is the precondition for issuing any finding or audit
  opinion — non-delegable; no agent may self-sign-off.
- This document unblocks **nothing operational**; it completes the *governance record* of the Internal-Audit
  3rd line and defines the preconditions under which a later, separately-authorised sprint may activate the
  agents.

---

*Sprint-5 Internal Audit Independent Line Completion · governance-only · NO live activation ·
completion-over-existing (ADR-102) · child of `governance/CANONICAL-ORG-CHART-v2.md` · append-only over
`governance/SPRINT-4-MLRO-LINE.md` and the Sprint-3 `governance/STAFF-MATRIX-v2.md` record (untouched: 44/44
active, 0 PROPOSED remaining). `HITL-MATRIX.yaml` / STAFF-MATRIX-v2 / -v1 untouched. The `internal_audit_agent`
stays an active dept-head STUB that PROPOSES only (I-27); `safeguarding_audit_agent` stays PROPOSED; the §8
`audit_remediation_tracker_agent` is a PROPOSED inline stub only — live audit execution only after I-27
HITL-L4 sign-off. References: `internal_audit_agent` (SMF5, Grant Thornton UK, active/STUB-caps),
`safeguarding_audit_agent` (PROPOSED, CASS 15 / PS25-12, relevant funds > GBP 100k), `spec_first_auditor`
(read-only-auditor precedent), `board_reporting_agent`, ADR-027 (ClickHouse `banxe.safeguarding_audit`,
`src/safeguarding/audit_trail.py`, I-28), ORG-CHART-v2 §4/§6 (3rd line, Audit Committee / Board), HITL-011,
emi-stack `src/safeguarding/annual_audit.py` (SP-THIN). No emi-stack changes; no merge.*
