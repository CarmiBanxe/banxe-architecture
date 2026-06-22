# SPRINT-8 — COO Resilience Interface & AI-Governance of COO-Ops (governance-only normative doc, NARROWED delta, completion-over-existing, no merge)

> **Type:** NORMATIVE governance doc, child of `governance/CANONICAL-ORG-CHART-v2.md` (§4 Dept-4 COO
> Office, SMF24 James Hargreaves). Companion to SPRINT-4..SPRINT-7. **Governance-only; NO live
> activation.**
> **Method:** completion-over-existing (ADR-102 anti-dup), NARROWED to the genuinely-uncovered COO
> delta. Each section = **[existing/owner ref] → [gap delta]**.
> **CRITICAL anti-dup / single-owner boundary:** **Operational Resilience / DORA / BCP-DR / ICT
> third-party is the FIXED single-owner domain of CTO Dept 5** (`resilience_agent`, emi-stack
> `services/incident_response/dora_continuity.py`; org-chart §7 "single owners fixed"). S8 does **NOT**
> usurp, re-author, or duplicate it — S8 adds only the **COO business-service-owner interface** to
> that framework + **AI-governance of COO-operations agents**.
> **Canon:** ADR-102, ADR-059-A (append-only), Rule 1/6, I-27 (HITL-L4 activation gate), I-28.
> STAFF-MATRIX-v2 (44/44, 0 PROPOSED)/-v1 / HITL-MATRIX.yaml / passports **untouched**. No Sprint-5
> 57/29. Baseline origin/main `4c1d68d` (after S7 merge).

---

## 0. Scope & anti-dup base (verified, read-only)

Existing on main (referenced, NOT recreated / NOT usurped):
- **Operational Resilience / DORA = CTO Dept 5** (`resilience_agent` PROPOSED, owner CTIO;
  capabilities: DR/BCP scenarios, incident-response runbooks, **ict_thirdparty_risk_tracking**, DORA
  EU 2022/2554) + emi-stack `services/incident_response/dora_continuity.py`. **Single-owner, fixed.**
- **AI-Governance framework** = `governance/aigf-risk-mapping.yaml` (BANXE × FINOS AIGF v2.0, 46
  risks incl. AIGF-A-03 model-drift, GovernanceGate, XAI/I-25), `governance/trust-zones.md/.yaml`
  (RED/AMBER/GREEN), `HITL-MATRIX.yaml`, BUG-007 HITL thresholds (AUTO>90 / REVIEW70-90 / BLOCK<70),
  EU AI Act Art.14. **Framework exists.**
- COO canon (S7 / org-chart §4): SMF24 James Hargreaves; COO-ops agents (S7 PROPOSED stubs:
  `payment_exception_agent`, `reconciliation_break_agent`, `shortfall_escalation_agent`,
  `complaints_agent`, `disputes_agent`, `customer_remediation_agent`).
- Resolution/wind-down: S7 §5 coverage-note + `wind_down_planning_agent` (CFO) + emi-stack
  `services/resolution/wind_down_plan.py`.

S8 adds ONLY: (a) the COO **important-business-service (IBS) owner interface** to the CTO-owned
resilience framework, and (b) **AI-governance applied to COO-ops agents**. It duplicates none of the
above.

---

## 1. COO incident & operational-continuity interface — NARROW DELTA

**[ref / owner]** CTO Dept 5 `resilience_agent` owns DR/BCP scenarios + incident-response runbooks +
DORA (`dora_continuity.py`). **Not duplicated.**
**[delta]** COO **business-side** continuity interface for COO-owned services only:
- COO names the **operational owner** for each COO important business service (payments ops,
  safeguarding ops, customer ops) that feeds the CTO/DORA runbook (COO consumes the framework,
  does not define it).
- **Ops-side invocation governance:** who (COO function head) declares a COO-service operational
  incident, how it hands to the CTO `resilience_agent` runbook, and the COO-side decision log.
- COO continuity is an **input** to the CTO-owned BCP/DR — RTO/RPO targets are **set in the DORA
  framework (CTO Dept 5)**; S8 records only the COO-service criticality ranking that informs them.

---

## 2. Operational resilience — COVERAGE-NOTE (CTO Dept 5) + narrow IBS-owner delta

**[ref / COVERAGE-NOTE]** Operational Resilience / DORA (SYSC 15A / FCA PS21/3, DORA EU 2022/2554) =
**CTO Dept 5 single-owner** (`resilience_agent` + `dora_continuity.py`, org-chart §7). Severe-but-
plausible scenarios, impact-tolerance methodology, the resilience self-assessment = **CTO-owned, NOT
re-authored here.**
**[delta — narrow]** SMF24-COO mapping for **COO-owned important business services** only: COO is the
**business-service owner** that supplies (to the CTO framework) the IBS list for COO domains
(payments execution, safeguarding ops, customer ops/complaints) + the business-impact input per
service. Impact tolerances themselves are **set/owned in the DORA framework**; S8 only fixes the COO
ownership-of-input. No scenario library re-authored (anti-dup).

---

## 3. Third-party / outsourcing (COO operational vendors) — COVERAGE-NOTE + narrow delta

**[ref / COVERAGE-NOTE]** ICT third-party risk = `resilience_agent.ict_thirdparty_risk_tracking`
(CTO Dept 5, DORA ICT-TPRM). Internal Audit outsourcing (Grant Thornton) = SMF5 (org-chart). **Not
duplicated.**
**[delta — narrow]** COO **operational** (non-ICT) outsourcing interface only: COO-operations vendor
oversight (e.g. payment-scheme operational partners, customer-ops BPO if any) — SLA/exit/concentration
governance from the **business-operations** angle, handed to the CTO ICT-TPRM register where ICT.
No new TPRM framework (CTO owns it).

---

## 4. AI-Governance of COO-Operations agents — REAL DELTA (scoped)

**[ref / COVERAGE-NOTE]** AI-gov framework = `aigf-risk-mapping.yaml` (FINOS AIGF v2.0, 46 risks),
`trust-zones.md/.yaml`, `HITL-MATRIX.yaml`, BUG-007 thresholds (AUTO>90 / REVIEW70-90 / BLOCK<70), EU
AI Act Art.14, GovernanceGate / I-25 XAI. **Framework NOT duplicated.**
**[delta]** application of that framework to the **COO-ops agents** specifically (S7 PROPOSED stubs):
- **Model-risk classification** per COO-ops agent (tier by impact: shortfall-escalation = highest,
  complaints = medium) — mapping to existing AIGF risks (e.g. AIGF-A-03 drift) per agent.
- **HITL chain** per COO-ops agent = the existing BUG-007 thresholds + canonical gates (no new
  thresholds): e.g. `shortfall_escalation_agent` BLOCK-class (never suppress; auto-FCA-alert immutable),
  `payment_exception_agent` ≥£50k → HITL-016.
- **Drift / eval gates:** governance that each COO-ops agent has a pre-activation eval + ongoing
  drift-monitor referencing the AIGF catalogue — gate is **descriptive**; activation gated I-27.
- **Audit trail:** every COO-ops agent decision logged (correlation_id, agent_id, confidence, reason)
  per existing HITL canon — referenced, not re-specified.
- Trust-zone placement of COO-ops agents (AMBER for ops-mutating; none RED-bypassing) per
  `trust-zones`.

---

## 5. Resolution / wind-down linkage — COVERAGE-NOTE only

**[ref / COVERAGE-NOTE]** Covered by S7 §5 + `wind_down_planning_agent` (CFO) + emi-stack
`services/resolution/wind_down_plan.py` + parallel SP-THIN. **Not duplicated.** S8 adds nothing
beyond noting the COO operational-continuity feed (§1) into the CFO-owned resolution pack. No stub,
no re-authoring (Rule 6).

---

## 6. PROPOSED roles & stubs (INLINE, dormant — activation I-27 HITL-L4)

> **PROPOSED only** (RED, draft-only). **STAFF-MATRIX NOT modified** (matrix-update = separate gated
> step). Activation precondition: **I-27 HITL-L4 sign-off**. None activated; none live; none bypasses
> canonical HITL gates; none usurps CTO Dept 5 resilience ownership.

| Stub | Domain (COO-scoped) | Human double | Existing refs / gates | Forbids |
|---|---|---|---|---|
| `coo_continuity_liaison_agent` | §1 COO-service incident → CTO runbook handoff | SMF24 COO | CTO `resilience_agent` (owner); DORA runbook | declare DR scope (CTO-owned); self-invoke BCP |
| `coo_ibs_owner_agent` | §2 COO IBS list/criticality input to DORA | SMF24 COO | `resilience_agent` impact-tolerance framework | set impact tolerances (CTO-owned) |
| `coo_ops_vendor_agent` | §3 COO operational (non-ICT) vendor oversight | Head of Payments/Customer Ops | CTO ICT-TPRM register | manage ICT-TPRM (CTO-owned) |
| `coo_ai_gov_monitor_agent` | §4 drift/eval/HITL monitor for COO-ops agents | SMF24 COO + (model-risk 2nd line) | `aigf-risk-mapping.yaml`, HITL-MATRIX, BUG-007 | weaken HITL thresholds; bypass GovernanceGate |

Invariants on all stubs: I-27 (HITL-L4 activation), I-28 (IL-recorded), no live mutation, no
shortfall suppression (absolute), **no usurpation of CTO Dept 5 Operational-Resilience/DORA single
ownership**.

---

## 7. Acceptance + gate-preconditions

- §1 = narrow COO continuity-interface delta (CTO Dept 5 owns the framework).
- §2/§3 = coverage-note (CTO Dept 5 op-resilience/DORA/ICT-TPRM) + narrow COO IBS-owner / ops-vendor
  delta.
- §4 = real delta — AI-governance **applied to COO-ops agents** (framework referenced, not duplicated).
- §5 = coverage-note (S7 §5 / CFO resolution).
- All new roles/stubs = **PROPOSED, dormant**; activation ONLY after **I-27 HITL-L4 sign-off**.
- STAFF-MATRIX-v2/v1 + HITL-MATRIX.yaml + passports + `resilience_agent` + `aigf-risk-mapping.yaml` +
  `trust-zones.*` untouched.
- **Single-owner boundary respected:** Operational Resilience / DORA stays CTO Dept 5; safeguarding
  shortfall auto-FCA-alert / no-AI-suppress = immutable.

---

### Refs
`governance/CANONICAL-ORG-CHART-v2.md` (§4 COO SMF24; §7 single-owners incl. Op-Resilience/DORA = CTO
Dept 5); `agents/passports/resilience_agent.yaml` (CTO Dept 5 owner, DORA) + emi-stack
`services/incident_response/dora_continuity.py`; `governance/aigf-risk-mapping.yaml` (FINOS AIGF v2.0,
46 risks); `governance/trust-zones.md/.yaml`; `HITL-MATRIX.yaml` + BUG-007 thresholds; companions
SPRINT-4..SPRINT-7 (S7 COO ops-stubs + §5 resolution); `wind_down_planning_agent` + emi-stack
`services/resolution/wind_down_plan.py`; ADR-102, ADR-059-A, Rule 1/6, I-25, I-27, I-28; EU AI Act
Art.14, DORA EU 2022/2554, FCA SYSC 15A / PS21/3.
