# SPRINT-6-CFO-DEEP-BUILD — Banxe AI Bank CFO Office Deep-Build Completion (NORMATIVE)

> **Status:** Sprint-6 — CFO Office (Dept 3) Deep-Build Completion (2026-06-22). **Normative** — child of the
> org canon.
> **Parent:** `governance/CANONICAL-ORG-CHART-v2.md` (frozen org structure, Sprint-1). On any conflict the
> parent canon wins for *structure*; this document is authoritative for the *CFO Office (Dept 3) 1st/2nd-line
> operating model* — the finance close, reconciliation, and prudential-reporting completion delta.
> **Companions:** `governance/STAFF-MATRIX-v2.md` (Sprint-3 staffing record — **NOT modified here**),
> `governance/SPRINT-4-MLRO-LINE.md` (the MLRO 2nd-line completion) and
> `governance/SPRINT-5-INTERNAL-AUDIT-LINE.md` (the Internal-Audit 3rd-line completion). This document is the
> **CFO Office 1st/2nd-line** counterpart.
> **Supersedes:** nothing — **append-only** over the Sprint-5 record. The Sprint-3 staffing figures recorded by
> STAFF-MATRIX-v2 are **unchanged** by this document; no Sprint-5 figures are carried in or restated here.
> **Scope (NARROWED):** completion-over-existing (ADR-102 anti-duplication) of the CFO Office (Dept 3, SMF2 =
> David Goldstein) — narrowed to the **genuinely-uncovered delta** only. This document authors a *real delta*
> in **§1 (CFO operating model)**, **§2 (accounting close + reconciliation governance)** and **§5 (prudential /
> regulatory reporting pack)**. It does **NOT** duplicate areas already covered or in-flight: **§3 Treasury/ALM**
> is COVERED / IN-FLIGHT in a **parallel session** (deferred, not re-authored), **§4 FP&A / finance BI** is
> DEFERRED (parallel / uncertain, no passport on main), and **§6 Wind-down** is **ALREADY COVERED** (referenced
> as complete, not re-authored). It is **greenfield-free**.
> **HITL note:** `HITL-MATRIX.yaml` is NOT modified — CFO-line actions are *mapped* to existing gates
> (**HITL-010** FCA RegData Submission, **HITL-011** Safeguarding Shortfall Alert, **HITL-016** Large
> Transaction >£50k) by reference only. **STAFF-MATRIX-v2 / -v1 are NOT modified.**
> **Activation note:** This is a **governance-only** document. **NO live activation.** No agent is created,
> activated, or wired by this file. `cfo_orchestration_agent` remains an **active department-head STUB that
> PROPOSES only (I-27)**; the **finance swarm** (`gl_close`, `apar`, `consolidation`, `ifrs`, `tax_compliance`,
> `beancount_export`) stays **PROPOSED**. Any new role introduced here is a **PROPOSED inline stub** only. Live
> finance execution / posting / submission remains gated on **I-27 HITL-L4 sign-off**.

---

## 1. Purpose & method

Establish the **completion delta** for the **CFO Office (Dept 3, 1st/2nd line, SMF2 = David Goldstein)**.
ORG-CHART-v2 already freezes the *structure* (Dept 3 = CFO Office, SMF2, "1st/2nd Line"; Wind-Down Planning =
CFO Office Dept 3 / Recovery & Resolution). Sprint-3 STAFF-MATRIX-v2 already records the department-head
staffing. What remains — and what this document supplies, append-only, **narrowed to the genuinely-uncovered
delta** — is the **operating-model layer** of the CFO line: how the CFO operates within the 1st/2nd-line
boundary, how the accounting close and reconciliation governance binds over the PROPOSED finance swarm, and how
the prudential / regulatory-reporting pack is assembled and validated up to the human submission boundary.

**Method = completion-over-existing (ADR-102).** Each authored section is written as
**[Existing ref] → [Gap delta]**: it first names the artefact that already covers the area, then states *only
the additive delta* this document contributes. Nothing existing is rewritten or duplicated. **Parallel-aware:**
areas owned by a parallel session or already complete are recorded as **short pointer paragraphs only** (§3,
§4, §6) — they are *not* re-authored here (Rule 6 — parallel branches are READ-ONLY awareness only).

**Existing artefacts referenced (read-first):**

| Artefact | Role | What it already covers |
|----------|------|------------------------|
| `governance/CANONICAL-ORG-CHART-v2.md` §3 / §7 | Parent canon | **Dept 3 = CFO Office**, SM&CR owner **CFO (SMF2 = David Goldstein)**, line of defence **1st/2nd Line**; **Wind-Down Planning = CFO Office Dept 3 (Recovery & Resolution)**, owner `wind_down_planning_agent` (passport ✓ · emi-stack `services/resolution/wind_down_plan.py`) |
| `agents/passports/cfo_orchestration_agent.yaml` | Passport (active STUB) | `status: active`, L2 · AMBER · `autonomy: L2_REVIEW`, **department-head** ("CFO Office"), SMF2 (CFO David Goldstein), line `1st/2nd Line — finance`. Capability = a **STUB** (`department_head_orchestration  # TODO Sprint-3: specify code-derived capabilities`); **PROPOSES only (I-27)**, NOT activated; service code deferred (GAP-078) |
| `agents/passports/finance/{gl_close,apar,consolidation,ifrs,tax_compliance,beancount_export}_agent.yaml` | Passports (**all PROPOSED**) | The PROPOSED **finance swarm** (L2 · AMBER · L2_REVIEW). e.g. `gl_close_agent`: month/quarter close prep over Odoo CE / ERPNext + Midaz/Formance; **proposes** close-journal batch, **never posts without Controller approval**; `human_double: Financial Controller / Chief Accountant`. Companions: `apar` (AP/AR), `consolidation`, `ifrs`, `tax_compliance` (`human_double: Tax Manager`), `beancount_export` |
| `agents/passports/treasury_alm_agent.yaml` | Passport (**PROPOSED**) | Head-of-Treasury line — **treasury / ALM**. **§3 COVERED / IN-FLIGHT in a parallel session** (`archstack002/sp12-treasury-alm-gap036`, ADR-078). NOT re-authored here (Rule 6) |
| `agents/passports/wind_down_planning_agent.yaml` | Passport (**PROPOSED**) | Wind-down planning support — run-off scenarios + wind-down trigger framework (FCA Approach Document). `department: Finance / Recovery & Resolution`, `human_double: CFO`. Backed by emi-stack `services/resolution/wind_down_plan.py`. **§6 ALREADY COVERED** — referenced, not re-authored |
| `HITL-MATRIX.yaml` | Gates (read-only) | **HITL-010** FCA RegData Submission (`required_roles: [CFO]`, `auto_allowed: false`, `fca_basis: CASS 15.12.4R; FCA PS7/24 FIN060`, severity high — CFO personally submits FIN060/RegData; AI drafts, CFO submits), **HITL-011** Safeguarding Shortfall (`required_roles: [CFO, MLRO]`, critical), **HITL-016** Large Transaction (>£50k; COO or CFO) |
| `banxe-emi-stack: services/resolution/wind_down_plan.py` | emi-stack code | Wind-down plan service already mapped to Dept-3 Recovery & Resolution. **No emi-stack change in this sprint** (arch-only) |

---

## 2. CFO operating model — 1st/2nd-line independence within Dept 3 (REAL DELTA)

**[Existing ref]** ORG-CHART-v2 §3: **Dept 3 = CFO Office**, SM&CR owner **CFO (SMF2 = David Goldstein)**, line
of defence **1st/2nd Line**. The `cfo_orchestration_agent` passport is `status: active` but is an explicit
**department-head STUB** — its only capability is `department_head_orchestration  # TODO Sprint-3` and it
**PROPOSES only (I-27)**; service code is deferred (GAP-078).

**[Gap delta] — explicit operating-model statement + the STUB capability replaced by a governance-only,
code-derived draft-only capability list (no activation):**

1. **1st/2nd-line position (structural):** the CFO Office is **Dept 3**, owner **CFO (SMF2 = David
   Goldstein)**, sitting across the **1st/2nd line of defence** for finance. The CFO is accountable for the
   integrity of the financial close, the regulatory-reporting pack, and prudential reporting. Independence is
   **role-segregated within the line**: finance agents **draft / propose**; the **Financial Controller / Chief
   Accountant** approves the close; the **CFO (SMF2)** owns the regulatory-reporting opinion and personally
   submits RegData (HITL-010, non-delegable). The CFO line is **distinct from** the **Internal-Audit 3rd line
   (SMF5)** that independently audits it (SPRINT-5) and from the **MLRO 2nd line (SMF17)** (SPRINT-4).
2. **Close cycles (day / month / quarter / annual):** the CFO operating cycle is governed across four cadences
   — **daily** (reconciliation evidence / cash-position drafting), **monthly** (month-end close pack drafted by
   `gl_close_agent`, Controller-approved before posting), **quarterly** (quarter-end consolidation + IFRS
   drafts), and **annual** (statutory accounts, tax-compliance pack, audit support). Each cycle is **draft →
   human approval → post**; no agent posts to the GL.
3. **Human-approval points mapped to EXISTING gates:** the CFO line maps its human-approval points to gates
   that **already exist** in `HITL-MATRIX.yaml` — **HITL-010** (FCA RegData Submission; CFO personally submits;
   `auto_allowed: false`), **HITL-016** (Large Transaction >£50k; COO or CFO approval), and **HITL-011**
   (Safeguarding Shortfall; CFO + MLRO) where a shortfall touches the finance close. **No new gate is created
   here.**
4. **Code-derived CFO orchestration capability list (replaces the STUB):** the `cfo_orchestration_agent` STUB
   capability `department_head_orchestration  # TODO` is, for governance purposes, the orchestration of the
   following **draft-only** finance capabilities (all AMBER, all PROPOSES-only, none mutating / posting):
   - `close_cycle_orchestration` — sequence the day/month/quarter/annual close (delegates to `gl_close_agent`);
   - `reconciliation_break_routing` — route reconciliation breaks to the accountable owner (see §2-reconciliation);
   - `regulatory_pack_orchestration` — assemble the RegData / prudential pack draft (see §5);
   - `consolidation_orchestration` — sequence consolidation + IFRS drafts (delegates to `consolidation` / `ifrs`);
   - `tax_pack_orchestration` — assemble the tax-compliance pack draft (delegates to `tax_compliance_agent`);
   - `close_pack_signoff_routing` — route the close pack to the Financial Controller for human sign-off.
   This is a **governance-only description**. It grants no runtime capability; it does **not** edit the passport
   file; it states what the active STUB *orchestrates by reference* once a separately-authorised sprint codes
   it. **No new capability is wired here.**
5. **No new authority is created here.** This section makes explicit what ORG-CHART-v2 §3 already implies.

---

## 3. Treasury / ALM — COVERED / IN-FLIGHT (parallel; not duplicated)

**[ref]** `agents/passports/treasury_alm_agent.yaml` (PROPOSED, Head of Treasury) + the parallel session
`archstack002/sp12-treasury-alm-gap036` + **ADR-078**. Treasury / ALM (liquidity, FTP, IRRBB, ALM gap-036) is
**covered / in-flight** in a **parallel session** and is **NOT** authored or duplicated here. Per **Rule 6**,
that branch is **READ-ONLY awareness only** — this document does not touch it, does not add a stub for it, and
**defers** the treasury/ALM operating-model delta to the parallel session. After the parallel branch merges,
treasury (§3) is reconciled into the CFO line under §7. No treasury content is restated below.

---

## 4. FP&A + finance BI — DEFERRED (parallel / uncertain; not duplicated)

**[ref]** historical sprint-45 IL (FP&A / finance-BI direction); **no FP&A / finance-BI passport exists on
`origin/main`**. FP&A (planning, forecasting, variance) and finance BI are **DEFERRED** — they are
parallel / uncertain, have no passport on main, and are **NOT** authored or duplicated here. This document
records the deferral only; the FP&A / finance-BI delta is reconciled into the CFO line under §7 once a
direction is confirmed and (if needed) a passport exists. No FP&A content is restated below.

---

## 5. Prudential / regulatory reporting pack + validation (REAL DELTA — genuine gap)

> **GOVERNANCE-ONLY — no live submission of any kind is enabled by this document.**

**[Existing ref]** `HITL-MATRIX.yaml` **HITL-010** FCA RegData Submission (`required_roles: [CFO]`,
`auto_allowed: false`, `fca_basis: CASS 15.12.4R; FCA PS7/24 FIN060`, severity high — "CFO must personally
submit FIN060 and other RegData returns. AI generates the report; CFO reviews and submits"). There is **no
dedicated regulatory-reporting passport on `origin/main`** — this is a **genuine, uncovered gap** (the existing
finance swarm covers close / reconciliation / consolidation / IFRS / tax, but not the RegData / prudential pack
assembly + validation contour).

**[Gap delta] — RegData / FINREP-style pack assembly (draft-only), validation controls, and the human
submission boundary:**

1. **Pack assembly (draft-only):** the CFO line assembles the **RegData / FINREP-style prudential reporting
   pack** — FIN060 safeguarding return, prudential / own-funds figures, and the regulatory-reporting set — as a
   **draft** sourced from the close outputs (§2). Source figures are **read / referenced** from the GL close
   and consolidation drafts; the pack agent **never posts** and **never submits**.
2. **Validation controls:** each pack carries a fixed validation skeleton — *completeness check → cross-foot /
   internal-consistency check → period-over-period variance flag → CASS 15 safeguarding-figure tie-out →
   exception list → draft sign-off cover*. Validation **flags exceptions**; it does **not** correct or override
   a source figure (corrections route back through the close, §2). Validation is **draft-only**.
3. **Submission boundary (HITL-010, non-delegable):** the boundary is **hard** — **no agent submits RegData**.
   The pack draft + validation flow stops at the **HITL-010** human gate: the **CFO (SMF2 = David Goldstein)
   personally reviews and submits** FIN060 / RegData (with MLRO involvement where the return touches
   safeguarding, per HITL-010/HITL-011 mapping). `auto_allowed: false` is canon; the agent **drafts**, the
   human **submits**. No new gate is introduced.

**Optional PROPOSED inline stub (governance-only — covers the genuine reporting gap):**

> **Anti-dup (ADR-102):** the existing finance swarm covers close / reconciliation / consolidation / IFRS /
> tax — **prefer it** for those. The single genuine gap not on any existing passport is **RegData / prudential
> pack assembly + validation (draft-only) up to the HITL-010 submission boundary**. It is recorded below as a
> **PROPOSED inline stub only** — it does **NOT** alter STAFF-MATRIX-v2's Sprint-3 record, is **NOT** created
> as a separate passport file, is **NOT** activated, and is **NOT** wired. Live execution only after **I-27
> HITL-L4 sign-off**.

```yaml
# PROPOSED — Sprint-6 forward proposal. NOT live. NOT activated. NOT a separate file.
# Does NOT alter STAFF-MATRIX-v2 (Sprint-3 staffing record unchanged).
# Live RegData/prudential pack assembly gated on I-27 HITL-L4 sign-off.

- agent_id: regulatory_reporting_agent
  status: PROPOSED                # NOT active; STAFF-MATRIX-v2 unchanged
  trust_zone: RED
  autonomy_level: L2_REVIEW
  function: >
    Draft-only assembly + validation of the RegData / FINREP-style prudential reporting
    pack (FIN060 safeguarding return, own-funds / prudential figures), sourced from the
    GL close + consolidation drafts. Never posts, never submits. Stops at the HITL-010
    human submission boundary — the CFO personally reviews and submits.
  human_double: { primary: CFO, secondary: FINANCIAL_CONTROLLER }
  hitl_gates: [HITL-010]          # FCA RegData Submission — EXISTING gate (read-only ref)
  invariants: [I-27, I-28]        # PROPOSES only; append-only reporting evidence
  forbidden_actions:
    - submit_regdata               # submission is human (CFO, HITL-010), non-delegable
    - self_sign_off                # the regulatory-reporting opinion is the CFO's, non-delegable
  activation_precondition: I-27 HITL-L4 sign-off
```

**Note (canon):** this stub is RED-zone, draft-only, forbids `submit_regdata` / `self_sign_off`, and
references the **existing HITL-010** gate by ID only. It introduces **no new gate** and **no new authority**. It
exists **only in this file** as a Sprint-6 forward proposal. **STAFF-MATRIX-v2 / -v1 and HITL-MATRIX.yaml are
NOT modified.** Prefer the existing finance swarm for close / reconciliation / consolidation / IFRS / tax; this
stub covers only the genuine RegData / prudential-pack gap.

---

## 6. Wind-down ownership — ALREADY COVERED (not a gap; not duplicated)

**[ref]** `agents/passports/wind_down_planning_agent.yaml` (PROPOSED — run-off scenarios + wind-down trigger
framework per the FCA Approach Document; `department: Finance / Recovery & Resolution`, `human_double: CFO`) +
emi-stack `services/resolution/wind_down_plan.py` + ORG-CHART-v2 §7 (**Wind-Down Planning = CFO Office Dept 3
(Recovery & Resolution)**, single owner fixed). Wind-down ownership is **ALREADY COVERED** — passport,
emi-stack service, and a fixed single owner in the org chart. It is referenced here as **complete** and is
**NOT** re-authored or duplicated. No wind-down content is restated below; activation of the PROPOSED
`wind_down_planning_agent` remains gated on I-27.

---

## 7. Acceptance criteria & gate-preconditions

**[Existing ref]** ORG-CHART-v2 §3/§7 (Dept 3 CFO Office, SMF2, Wind-Down Recovery & Resolution),
`cfo_orchestration_agent` (active dept-head STUB, PROPOSES only), the PROPOSED finance swarm, `treasury_alm_agent`
(PROPOSED), `wind_down_planning_agent` (PROPOSED), HITL-MATRIX.yaml (HITL-010 / HITL-011 / HITL-016), I-27 / I-28.

**[Gap delta] — acceptance criteria for the NARROWED Sprint-6 CFO deep-build + gate-preconditions:**

**Acceptance (this NARROWED Sprint-6 document is complete when):**
1. The CFO operating model (§1) states the 1st/2nd-line position + SMF2 (David Goldstein) accountability,
   defines the day/month/quarter/annual close cycles, maps human-approval points to **existing** gates
   (HITL-010 / HITL-016 / HITL-011), and replaces the `cfo_orchestration_agent` STUB capability with a
   code-derived **draft-only** capability list (governance description, no activation) — **done**.
2. The accounting close + reconciliation governance (§2) is stated over the **PROPOSED** finance swarm
   (data-extraction sourcing, reconciliation-break ownership / SLA, close calendar, segregation; agents draft,
   Financial Controller signs); the swarm stays PROPOSED, no passport edits — **done**.
3. The prudential / regulatory reporting pack + validation (§5) is stated as a genuine, uncovered gap — pack
   assembly (draft-only), validation controls, and the HITL-010 human submission boundary; one **PROPOSED**
   inline `regulatory_reporting_agent` stub records the gap — **done**.
4. **Treasury / ALM (§3)** is recorded as **COVERED / IN-FLIGHT in a parallel session** and **deferred** (not
   duplicated; Rule 6) — **deferred-parallel**.
5. **FP&A / finance BI (§4)** is recorded as **DEFERRED** (parallel / uncertain; no passport on main; not
   duplicated) — **deferred-parallel**.
6. **Wind-down ownership (§6)** is referenced as **ALREADY COVERED** (passport + emi-stack service + ORG-CHART
   §7 single owner) and **NOT** re-authored — **already-covered**.
7. Any new role exists as a **PROPOSED** inline stub only (§5), NOT live; the existing finance swarm is
   preferred; STAFF-MATRIX-v2 / -v1 and HITL-MATRIX.yaml are **untouched**; no separate passport files created;
   no emi-stack change — **done**.

**Gate-preconditions (what each gate unblocks):**
- **I-27 HITL-L4 sign-off** is the precondition for activating ANY PROPOSED stub — the **PROPOSED finance
  swarm** (`gl_close` / `apar` / `consolidation` / `ifrs` / `tax_compliance` / `beancount_export`, which all
  stay PROPOSED) and the §5 `regulatory_reporting_agent`. Until I-27 sign-off, live close, posting,
  reconciliation, and RegData assembly are **blocked**; the stubs remain PROPOSED. The `cfo_orchestration_agent`
  remains an active dept-head STUB that **PROPOSES only**.
- **HITL-010** (FCA RegData Submission; CFO; `auto_allowed: false`) is the existing human gate at the RegData /
  prudential submission boundary — **the CFO personally submits; no agent bypasses it**.
- **HITL-016** (Large Transaction >£50k; COO or CFO) and **HITL-011** (Safeguarding Shortfall; CFO + MLRO) are
  the existing human gates the CFO close maps to; no agent bypasses them.
- **Human sign-off (Financial Controller — close; CFO / SMF2 — regulatory opinion + RegData submission)** is the
  precondition for posting the close and submitting RegData — non-delegable; no agent may self-sign-off or post.
- **Parallel reconciliation:** **§3 treasury** is reconciled into the CFO line after the parallel
  `archstack002/sp12-treasury-alm-gap036` / ADR-078 branch merges; **§4 FP&A** is reconciled once its direction
  / passport is confirmed. Neither is authored here (Rule 6).
- This document unblocks **nothing operational**; it completes the *governance record* of the CFO Office
  (Dept 3) narrowed delta and defines the preconditions under which a later, separately-authorised sprint may
  activate the agents.

---

*Sprint-6 CFO Office Deep-Build Completion · governance-only · NO live activation ·
completion-over-existing (ADR-102), NARROWED to the genuinely-uncovered delta · child of
`governance/CANONICAL-ORG-CHART-v2.md` · append-only over `governance/SPRINT-5-INTERNAL-AUDIT-LINE.md`,
`governance/SPRINT-4-MLRO-LINE.md` and the Sprint-3 `governance/STAFF-MATRIX-v2.md` record (untouched).
`HITL-MATRIX.yaml` / STAFF-MATRIX-v2 / -v1 untouched. `cfo_orchestration_agent` stays an active dept-head STUB
that PROPOSES only (I-27); the finance swarm (`gl_close` / `apar` / `consolidation` / `ifrs` / `tax_compliance`
/ `beancount_export`) stays PROPOSED; the §5 `regulatory_reporting_agent` is a PROPOSED inline stub only — live
finance/RegData execution only after I-27 HITL-L4 sign-off. §1/§2/§5 authored (real delta); §3 Treasury/ALM
deferred-parallel (`archstack002/sp12-treasury-alm-gap036`, ADR-078 — Rule 6, not duplicated); §4 FP&A / finance
BI deferred (parallel / uncertain, no passport on main); §6 Wind-down already-covered (`wind_down_planning_agent`
+ emi-stack `services/resolution/wind_down_plan.py` + ORG-CHART §7 — not re-authored). References:
`cfo_orchestration_agent` (SMF2 David Goldstein, active/STUB-caps, PROPOSES-only), finance swarm passports
(PROPOSED, Financial Controller / Chief Accountant / Tax Manager human-doubles), `treasury_alm_agent` (PROPOSED,
Head of Treasury), `wind_down_planning_agent` (PROPOSED, CFO), ORG-CHART-v2 §3/§7, HITL-010 / HITL-011 /
HITL-016, emi-stack `services/resolution/wind_down_plan.py`. No emi-stack changes; no merge.*
