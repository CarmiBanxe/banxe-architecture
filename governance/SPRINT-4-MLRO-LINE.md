# SPRINT-4-MLRO-LINE — Banxe AI Bank MLRO Independent Line Completion (NORMATIVE)

> **Status:** Sprint-4 — MLRO Independent Line Completion (2026-06-22). **Normative** — child of the org canon.
> **Parent:** `governance/CANONICAL-ORG-CHART-v2.md` (frozen org structure, Sprint-1). On any conflict the
> parent canon wins for *structure*; this document is authoritative for the *MLRO independent-line operating
> model*. **Companion:** `governance/STAFF-MATRIX-v2.md` (Sprint-3 staffing record — **NOT modified here**).
> **Supersedes:** nothing — **append-only** over the Sprint-3 record. The Sprint-3 staffing figures
> (70 passports (STAFF-MATRIX-v3, 2026-07-02) active, 0 PROPOSED remaining, 21 gated under I-27) are unchanged by this document.
> **Scope:** completion-over-existing (ADR-102 anti-duplication) of the MLRO / Financial-Crime independent
> line that ORG-CHART-v2 §3 (Dept-6) already establishes. This document adds ONLY the *delta* — the
> operating model, queue/triage flow, reporting/SAR boundary, case governance, HITL mapping, PROPOSED
> worker stubs, and acceptance gates — over the artefacts that already exist. It is **greenfield-free**.
> **HITL note:** `HITL-MATRIX.yaml` is NOT modified — MLRO actions are *mapped* to the existing 17 gates
> (HITL-001…017) by reference only. **STAFF-MATRIX-v2 / -v1 are NOT modified.**
> **Activation note:** This is a **governance-only** document. **NO live activation.** No agent is created,
> activated, or wired by this file. PROPOSED worker stubs (§6) are forward proposals; live KYC/KYB/sanctions
> processing remains gated on **I-27 HITL-L4 sign-off**.

---

## 1. Purpose & method

Establish the **completion delta** for the MLRO / Financial-Crime independent line. ORG-CHART-v2 already
freezes the *structure* (Dept-6, independent line to the Board, SMF17). Sprint-3 STAFF-MATRIX-v2 already
*staffs* the department heads. What remains — and what this document supplies, append-only — is the
**operating-model layer** of the MLRO line: how cases flow, how reports reach the Board, where the SAR/
sanctions submission boundary sits, how the human-approval matrix maps to existing HITL gates, and which
worker agents are still only PROPOSED.

**Method = completion-over-existing (ADR-102).** Each section below is written as
**[Existing ref] → [Gap delta]**: it first names the artefact that already covers the area, then states
*only the additive delta* this document contributes. Nothing existing is rewritten or duplicated.

**Existing artefacts referenced (read-first):**

| Artefact | Role | What it already covers |
|----------|------|------------------------|
| `governance/CANONICAL-ORG-CHART-v2.md` | Parent canon | Dept-6 = MLRO/Financial-Crime; independent line **to Board**, NOT under CFO/COO; SMF17 = **Sarah Mitchell**; `banxe_aml_orchestrator` = MLRO head (SAR/sanctions/PEP non-delegable); de-dup from Compliance 2nd-line |
| `agents/passports/aml/mlro_report_agent.yaml` | Passport (IL-068) | L2 · RED · `human_double` MLRO/HEAD_OF_FINCRIME · `hitl_gates: []` · reporting only (`build_board_pack`, `generate_mlro_report_draft`) · forbids `submit_SAR` |
| `agents/souls/mlro-report-agent.md` | Soul (IL-068) | RED/L2; drafts only; reads ClickHouse/Marble/Jube; no operational HITL; MLRO signs Board report (non-delegable) |
| `docs/canon/passports/mlro.yaml` | Canon passport | `role_id: mlro` · SMF17 · `gate_authority: mlro` · `risk_ceiling: HIGH` · invariants INV-03/04/07 · interim actor Moriel Carmi |
| `HITL-MATRIX.yaml` | Gates (read-only) | HITL-001…017 — SAR Filing, EDD, Sanctions, AML block, KYC rejection, PEP, fraud, etc. |
| `banxe-emi-stack: services/aml`, `services/sanctions_screening`, `services/crypto_aml_graph` | emi-stack services | already mapped to Dept-6 in ORG-CHART-v2 §"emi-stack mapping" |

---

## 2. MLRO operating model — independence & escalation authority

**[Existing ref]** ORG-CHART-v2 §3 (Dept-6) + §"corrected contradiction": `banxe_aml_orchestrator` is the
**MLRO / Financial-Crime head only**, independent line **to the Board**, NOT inside Compliance, NOT under
CFO/COO; SMF17 = Sarah Mitchell; Compliance 2nd-line monitoring is a *distinct* function with no SAR/
sanctions authority. The `mlro_report_agent` passport sits in trust-zone RED, autonomy L2.

**[Gap delta] — explicit operating-model statement of independence + escalation authority:**

1. **Independence (structural):** The MLRO line reports to the **Board** directly. No executive (CEO SMF1,
   CFO SMF2, COO SMF24) may instruct, override, or suppress an MLRO determination on SAR, sanctions, or PEP
   matters. These remain **non-delegable to SMF17 (Sarah Mitchell)**.
2. **Trust-zone discipline:** all MLRO-line agents operate in **RED**. RED-zone agents may *analyse, draft,
   triage, and escalate* but never *submit* a regulatory filing or *release* a sanctions block — those are
   human-gated (see §3, §5).
3. **Escalation authority:** the MLRO may escalate directly to the Board / Audit Committee, bypassing the
   executive chain, where a financial-crime determination would otherwise be impeded. This is the structural
   guarantee that makes the line "independent" in operating-model terms, not just in the org chart.
4. **No new authority is created here.** This section only states explicitly what ORG-CHART-v2 already
   implies; it grants no agent any operational capability.

---

## 3. Reporting model — Board / Audit-Committee chain & SAR/MyFCA submission boundary

> **GOVERNANCE-ONLY — no live submission of any kind is enabled by this document.**

**[Existing ref]** `mlro_report_agent` provides `build_board_pack` and `generate_mlro_report_draft`; the
soul states the MLRO **signs and presents** the annual report to the Board (non-delegable); the passport
**forbids `submit_SAR`** and sets `hitl_gates: []` (reporting agent initiates no gate).

**[Gap delta] — Board/Audit-Committee chain + explicit SAR boundary:**

1. **Reporting chain (drafts → human sign-off → Board):**
   `mlro_report_agent` (draft, RED/L2) → **MLRO (SMF17)** review & sign → **Board Risk/Compliance Committee**
   → **Audit Committee** (3rd-line assurance, read-only). Agents produce *drafts only*; every Board-facing
   artefact carries a human sign-off before presentation.
2. **SAR / MyFCA submission boundary (canon):** SAR authority is held by the **MLRO (SMF17), human, via
   HITL-001 (SAR Filing)**. **No agent submits a SAR.** The `mlro_report_agent` explicitly forbids
   `submit_SAR`; any future worker stub (§6) that *detects* a reportable matter may only *raise* a case for
   the MLRO to file — never file. MyFCA / NCA SAR submission is a human action outside the agent boundary.
3. **Sanctions submission boundary:** sanctions BLOCK is auto (HITL-003); BLOCK *reversal* requires
   **MLRO + CEO** (HITL-004). No agent reverses a sanctions block.

---

## 4. Queue model — Marble / Jube case intake, triage, escalation

**[Existing ref]** `services/aml` (emi-stack, mapped to Dept-6); the soul reads **Marble** case statistics
and **Jube** TM logs; ClickHouse holds AML/TM/sanctions event logs (I-08, 5-year retention).

**[Gap delta] — queue / triage / escalation flow (governance description of the existing surfaces):**

```
intake          triage                 escalation
─────────       ─────────────          ───────────────────────────────
Jube/TM alert ─▶ Marble case open ─▶ RED-zone agent triage (draft) ─▶ MLRO review
sanctions hit ─▶ Marble case open ─▶ HITL-003 auto-BLOCK            ─▶ HITL-004 (MLRO+CEO) for reversal
KYC/EDD flag  ─▶ Marble case open ─▶ Compliance (HITL-002/006)      ─▶ MLRO if SAR-relevant (HITL-001)
```

1. **Intake:** alerts originate in Jube (transaction monitoring) and sanctions screening; each becomes a
   **Marble case**.
2. **Triage:** RED-zone agents may *classify, enrich, and prioritise* a case (draft outputs only). No agent
   *closes* a case with a regulatory consequence without the corresponding human gate.
3. **Escalation:** SAR-relevant cases escalate to the MLRO (HITL-001); sanctions to HITL-003/004; EDD to
   HITL-002. The queue model is **descriptive of existing services** — no new queue is built here.

---

## 5. Human-approval matrix → mapping to EXISTING HITL gates

> `HITL-MATRIX.yaml` is **NOT modified.** The mapping below references existing gate IDs only.

**[Existing ref]** `HITL-MATRIX.yaml` HITL-001…017; `docs/canon/passports/mlro.yaml` `gate_authority: mlro`.

**[Gap delta] — which MLRO-line actions map to which existing gate:**

| MLRO-line action | Existing gate | Approver (per HITL-MATRIX) |
|------------------|---------------|----------------------------|
| File a SAR | **HITL-001** (SAR Filing) | MLRO (SMF17) — human, non-delegable |
| Retract a SAR | **HITL-008** (SAR Retraction) | MLRO |
| EDD sign-off | **HITL-002** (EDD Sign-off) | Compliance / MLRO |
| Sanctions auto-BLOCK | **HITL-003** (Sanctions AUTO-BLOCK) | auto + MLRO notified |
| Sanctions BLOCK reversal | **HITL-004** (Sanctions Reversal) | **MLRO + CEO** (both) |
| Customer BLOCK (AML) | **HITL-005** (Customer BLOCK) | MLRO |
| KYC rejection (HIGH/PROHIBITED) | **HITL-006** (KYC Rejection) | Compliance |
| PEP onboarding | **HITL-007** (PEP Onboarding) | MLRO/Compliance |
| Fraud HIGH transaction HOLD | **HITL-009** (Transaction HOLD) | Ops/MLRO |
| AML threshold change | **HITL-012** (AML Threshold Change) | MLRO |
| FCA RegData submission | **HITL-010** (FCA RegData) | MLRO/CFO |

The `mlro_report_agent` itself remains `hitl_gates: []` — it is a reporting agent and triggers no gate.
The mapping above governs the **PROPOSED worker stubs** of §6 once (and only once) they are activated.

---

## 6. Missing worker agents — PROPOSED passport stubs (governance-only, NOT live)

> **PROPOSED forward proposals.** These do **NOT** alter STAFF-MATRIX-v2's Sprint-3 record (44/44 active,
> 0 PROPOSED remaining). They live **only in this file** as Sprint-4 forward proposals, are **NOT created**
> as separate passport files, **NOT activated**, and **NOT wired**. **Live KYC/KYB/sanctions/AML/fraud/EDD
> processing only after I-27 HITL-L4 sign-off.** Each stub references existing HITL gates by ID; none
> introduces a new gate.

**[Existing ref]** ORG-CHART-v2 §"3 Lines of Defence" lists the MLRO line; emi-stack `services/aml`,
`services/sanctions_screening`, `services/crypto_aml_graph` exist; HITL gates HITL-001…017 exist.

**[Gap delta] — the six worker agents that the line still lacks, as PROPOSED stubs:**

```yaml
# PROPOSED — Sprint-4 forward proposal. NOT live. NOT activated. NOT a separate file.
# Live processing gated on I-27 HITL-L4 sign-off.

- agent_id: kyc_worker_agent
  status: PROPOSED            # NOT active; STAFF-MATRIX-v2 unchanged
  trust_zone: RED
  autonomy_level: L3
  function: KYC identity verification / risk classification (draft only)
  human_double: { primary: COMPLIANCE_OFFICER, secondary: MLRO }
  hitl_gates: [HITL-006]      # KYC Rejection (HIGH/PROHIBITED) — existing gate
  forbidden_actions: [reject_customer_without_gate, submit_SAR]
  activation_precondition: I-27 HITL-L4 sign-off

- agent_id: kyb_worker_agent
  status: PROPOSED
  trust_zone: RED
  autonomy_level: L3
  function: KYB business onboarding / UBO mapping (draft only)
  human_double: { primary: COMPLIANCE_OFFICER, secondary: MLRO }
  hitl_gates: [HITL-006, HITL-007]   # KYC rejection + PEP onboarding — existing
  forbidden_actions: [onboard_without_gate, submit_SAR]
  activation_precondition: I-27 HITL-L4 sign-off

- agent_id: sanctions_worker_agent
  status: PROPOSED
  trust_zone: RED
  autonomy_level: L3
  function: sanctions/PEP screening triage (draft only; NO reversal)
  human_double: { primary: MLRO, secondary: HEAD_OF_FINCRIME }
  hitl_gates: [HITL-003, HITL-004]   # auto-BLOCK + reversal (MLRO+CEO) — existing
  forbidden_actions: [reverse_block, release_sanctions_hold, submit_SAR]
  activation_precondition: I-27 HITL-L4 sign-off

- agent_id: aml_tm_worker_agent
  status: PROPOSED
  trust_zone: RED
  autonomy_level: L3
  function: AML transaction-monitoring alert triage (Jube/Marble; draft only)
  human_double: { primary: MLRO, secondary: HEAD_OF_FINCRIME }
  hitl_gates: [HITL-005, HITL-001]   # customer BLOCK + SAR filing — existing
  forbidden_actions: [block_customer_without_gate, submit_SAR, change_AML_thresholds]
  activation_precondition: I-27 HITL-L4 sign-off

- agent_id: fraud_worker_agent
  status: PROPOSED
  trust_zone: RED
  autonomy_level: L3
  function: fraud-signal triage / HOLD recommendation (draft only)
  human_double: { primary: COMPLIANCE_OFFICER, secondary: MLRO }
  hitl_gates: [HITL-009]      # Transaction HOLD (Fraud HIGH) — existing
  forbidden_actions: [release_hold_without_gate, submit_SAR]
  activation_precondition: I-27 HITL-L4 sign-off

- agent_id: edd_worker_agent
  status: PROPOSED
  trust_zone: RED
  autonomy_level: L3
  function: Enhanced Due Diligence pack preparation (draft only)
  human_double: { primary: COMPLIANCE_OFFICER, secondary: MLRO }
  hitl_gates: [HITL-002]      # EDD Sign-off — existing
  forbidden_actions: [sign_off_edd, submit_SAR]
  activation_precondition: I-27 HITL-L4 sign-off
```

**Note (canon):** every stub is RED-zone, draft-only, forbids `submit_SAR`, and references an **existing**
HITL gate. None grants operational authority. **Live KYC/KYB/sanctions processing only after I-27
HITL-L4 sign-off** — until then these remain PROPOSED governance proposals with no runtime footprint.

---

## 7. Acceptance criteria & gate-preconditions

**[Existing ref]** ORG-CHART-v2 §3 (Dept-6 frozen), STAFF-MATRIX-v2 §6 (GAP-078 closed, I-27 gating),
HITL-MATRIX.yaml (gates), `mlro_report_agent` passport (reporting-only).

**[Gap delta] — acceptance criteria for S4 line-completion + gate-preconditions:**

**Acceptance (this Sprint-4 document is complete when):**
1. The MLRO operating model (§2) states independence + escalation authority explicitly — **done**.
2. The queue model (§4) describes intake/triage/escalation over existing Marble/Jube/ClickHouse — **done**.
3. The reporting model (§3) fixes the Board/Audit-Committee chain and the SAR/MyFCA boundary — **done**.
4. Case governance (ownership / SLA / evidence trail) is stated (§ below) — **done**.
5. The human-approval matrix (§5) maps every MLRO action to an **existing** HITL gate — **done**.
6. The six missing worker agents (§6) exist as **PROPOSED** stubs only, NOT live — **done**.
7. STAFF-MATRIX-v2 / -v1 and HITL-MATRIX.yaml are **untouched**; no separate passport files created — **done**.

**Case governance (ownership · SLA · evidence trail — the §4 delta, restated for acceptance):**
- **Ownership:** every Marble case has exactly one accountable owner (MLRO line); no case is unowned.
- **SLA:** triage SLA and escalation SLA are tracked in Marble; breaches surface in the `mlro_report_agent`
  Board pack as control-weakness flags (per the soul's escalation clause).
- **Evidence trail:** all AML/TM/sanctions events are logged to **ClickHouse** (I-08, 5-year retention),
  giving an immutable evidence trail for SAR/EDD/sanctions decisions.

**Gate-preconditions (what each gate unblocks):**
- **I-27 HITL-L4 sign-off** is the precondition for activating ANY §6 worker stub. Until I-27 sign-off,
  live KYC/KYB/sanctions/AML-TM/fraud/EDD processing is **blocked**; the stubs remain PROPOSED.
- **HITL-001** (human, MLRO) is the precondition for any SAR submission — no agent may bypass it.
- **HITL-004** (MLRO + CEO) is the precondition for any sanctions-block reversal.
- This document unblocks **nothing operational**; it completes the *governance record* of the line and
  defines the preconditions under which a later, separately-authorised sprint may activate the workers.

---

*Sprint-4 MLRO Independent Line Completion · governance-only · NO live activation · completion-over-existing
(ADR-102) · child of `governance/CANONICAL-ORG-CHART-v2.md` · append-only over `governance/STAFF-MATRIX-v2.md`
(Sprint-3 record untouched: 44/44 active, 0 PROPOSED remaining). `HITL-MATRIX.yaml` / STAFF-MATRIX-v2 / -v1
untouched. PROPOSED worker stubs (KYC/KYB/sanctions/AML-TM/fraud/EDD) are forward proposals — live
KYC/sanctions only after I-27 HITL-L4 sign-off. References: `banxe_aml_orchestrator`, `mlro_report_agent`
(IL-068), ORG-CHART-v2 Dept-6 SMF17 (Sarah Mitchell), emi-stack `services/aml` · `services/sanctions_screening`
· `services/crypto_aml_graph`. No emi-stack changes; no merge.*
