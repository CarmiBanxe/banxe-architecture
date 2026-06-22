# SPRINT-7 — COO Office Deep-Build (governance-only normative doc, NARROWED delta, completion-over-existing, no merge)

> **Type:** NORMATIVE governance doc, child of `governance/CANONICAL-ORG-CHART-v2.md` (§4 Dept-4 COO
> Office, SMF24 James Hargreaves). Companion to SPRINT-4-MLRO-LINE / SPRINT-5-INTERNAL-AUDIT-LINE /
> SPRINT-6-CFO-DEEP-BUILD. **Governance-only; NO live activation.**
> **Method:** completion-over-existing (ADR-102 anti-dup), NOT greenfield, **NARROWED to the
> genuinely-uncovered delta**. Each section = **[existing/parallel ref] → [gap delta]**.
> **Canon:** ADR-102 (anti-dup), ADR-059-A (append-only ledger), Rule 1/6, I-27 (HITL-L4 activation
> gate), I-28. STAFF-MATRIX-v2 (44/44, 0 PROPOSED) / -v1 / HITL-MATRIX.yaml / passports **untouched**.
> No Sprint-5 figures (57/29). Baseline origin/main `948b79f` (after S6 merge).

---

## 0. Scope & anti-dup base (verified, read-only)

Existing on main (referenced, NOT recreated):
- `CANONICAL-ORG-CHART-v2.md` §4 — **Dept-4 COO Office, SMF24 James Hargreaves**;
  `coo_operations_agent` = active dept-head STUB (MANDATORY-TODO); safeguarding daily ops under COO
  (`safeguarding_recon_governor`); **annual safeguarding audit = 3rd line (NOT COO)**.
- STAFF-MATRIX-v2: `coo_operations_agent` active dept-head STUB; gates HITL-009 / HITL-016.
- Passports (ref only): `coo_operations_agent`, `payment_router_agent`, `customer_lifecycle_agent`,
  `safeguarding_recon_governor`, `safeguarding_audit_agent`.
- HITL canon (ORG-STRUCTURE): PaymentRouter ≥£50k→L2 COO/CFO; MassPayment→CFO; Chargeback→COO;
  CASS7 daily recon L1; BreachDetector streak≥3 days→L3 MLRO+CFO; FIN060→CFO signs; ResolutionPack
  CASS10A 48h→CFO+MLRO; **"Safeguarding shortfall = automatic FCA alert, NO AI authorised to
  suppress"**; CustomerLifecycle→COO on block; Complaints DISP 8-week / FOS.

This doc adds ONLY the operating-governance delta on top; it duplicates none of the above.

---

## 1. COO operating model (SMF24 James Hargreaves) — REAL DELTA

**[ref]** org-chart Dept-4 + `coo_operations_agent` (MANDATORY-TODO dept-head STUB).
**[delta]** operating cadence + exception governance + escalation matrix:

- **Operating calendar:** daily (start-of-day readiness, exception-queue triage, cut-off checkpoints,
  end-of-day close), weekly (SLA-breach review, backlog ageing, capacity), monthly (ops scorecard,
  control-attestation roll-up to SMF24), day-2 procedures (reprocessing, manual-intervention log).
- **Exception-queue governance:** every operational exception has owner, SLA-clock, escalation tier,
  and disposition (resolve / escalate / write-off-with-approval). No exception sits unowned.
- **Cross-dept SLA chain:** COO ↔ CFO (settlement/treasury handoff), COO ↔ MLRO (suspicious-activity
  handoff), COO ↔ Customer (complaint↔ops feedback). Each handoff has a named SLA + breach-escalation.
- **Escalation matrix:** L1 ops agent → L2 Head-of-function → SMF24 COO → (regulatory/financial
  threshold) existing HITL gates. COO escalation never bypasses canonical HITL gates (HITL-009/016).

---

## 2. Payments Operations — REAL DELTA (governance only)

**[ref]** existing `payment_router_agent` + ChannelC*Orchestrator passports (routing already canon).
**[delta]** exception / break / cut-off governance ONLY — routing logic NOT rewritten:

- **Payment exception model:** failed/returned/repaired/suspended states, owner per state, max
  dwell-time before escalation.
- **Cut-off monitoring:** scheme cut-off windows tracked; missed-cut-off → escalation + next-cycle
  reschedule governance.
- **Scheme reconciliation:** outbound-vs-scheme-ack reconciliation; mismatch → break record.
- **Settlement mismatch:** settlement-vs-ledger break ownership; ≥£50k value impact routes via
  existing PaymentRouter L2 (COO/CFO) gate (HITL canon — not duplicated). MassPayment remains CFO.

---

## 3. Safeguarding Operations (CASS 7) — COVERAGE-NOTE + narrow delta

**[ref / COVERAGE-NOTE]** `safeguarding_recon_governor` + HITL canon: CASS7 daily recon L1;
BreachDetector streak≥3 days→L3 MLRO+CFO; FIN060→CFO signs; ResolutionPack CASS10A 48h→CFO+MLRO;
**"Safeguarding shortfall = automatic FCA alert, NO AI authorised to suppress"**. These gates are
**already canon — NOT duplicated, NOT weakened**.
**[delta — narrow]** reconciliation-**break-queue ownership** only: break classification (timing /
true-shortfall / data-quality), break-owner assignment, ageing SLA before the existing streak≥3 →
L3 escalation fires. The auto-FCA-alert / no-suppress rule is referenced verbatim and unchanged.
**Out of scope (COVERAGE-NOTE):** annual safeguarding audit = **3rd line** (`safeguarding_audit_agent`),
NOT COO — referenced complete, not re-authored.

---

## 4. Customer Operations & Disputes — REAL DELTA

**[ref]** `customer_lifecycle_agent` + ChargebackAgent (lifecycle/chargeback already canon;
CustomerLifecycle→COO on block; Complaints DISP 8-week/FOS = HITL canon).
**[delta]** complaints / remediation hierarchy + QA loop:

- **Complaints governance:** intake → triage → DISP 8-week clock → FOS-referral boundary (existing
  canon, referenced). Ownership ladder + breach-of-clock escalation to COO.
- **Disputes / chargeback:** dispute lifecycle states + chargeback handoff (ChargebackAgent→COO per
  canon); evidence-pack SLA.
- **Remediation:** customer-remediation case model (root-cause → remediation plan → sign-off);
  systemic-issue → COO + (if regulatory) existing gates.
- **Service recovery + QA loop:** post-resolution QA sampling feeding back into ops exception model
  (§1) — continuous-improvement governance.

---

## 5. Resolution / wind-down linkage — COVERAGE-NOTE only

**[ref / COVERAGE-NOTE]** COO↔resolution/wind-down touchpoint is covered by parallel SP-THIN +
existing `wind_down_planning_agent` (CFO-owned, §6 of SPRINT-6) + emi-stack
`services/resolution/wind_down_plan.py`. **Anti-dup: not duplicated here** — referenced as the COO
operational-continuity input to the CFO-owned resolution pack. No stub, no re-authoring (Rule 6,
parallel branches untouched).

---

## 6. PROPOSED roles & worker stubs (INLINE, dormant — activation I-27 HITL-L4)

> All below = **PROPOSED only** (RED, draft-only). **STAFF-MATRIX NOT modified** (matrix-update is a
> separate gated step). Activation precondition: **I-27 HITL-L4 sign-off** (operator governance).
> None activated; none persists live state; none bypasses canonical HITL gates.

**Proposed Heads (under SMF24 COO):**
- Head of Payments Ops · Head of Safeguarding Ops · Head of Customer Ops.

**Proposed worker stubs (draft-only capability descriptions, no passports created):**
| Stub | Domain | Human double | Existing gates referenced | Forbids |
|---|---|---|---|---|
| `payment_exception_agent` | §2 payment exceptions/cut-off | Head of Payments Ops | PaymentRouter L2 ≥£50k (HITL-016) | self-release ≥£50k |
| `reconciliation_break_agent` | §2/§3 break classification | Head of Safeguarding/Payments Ops | — (escalation only) | suppress shortfall |
| `shortfall_escalation_agent` | §3 CASS7 break→streak handoff | Head of Safeguarding Ops | BreachDetector streak≥3→L3 MLRO+CFO; auto-FCA-alert | suppress / delay FCA alert |
| `complaints_agent` | §4 DISP intake/clock | Head of Customer Ops | Complaints DISP 8-week/FOS | close past-clock without review |
| `disputes_agent` | §4 disputes/chargeback | Head of Customer Ops | Chargeback→COO | self-decide chargeback |
| `customer_remediation_agent` | §4 remediation cases | Head of Customer Ops | systemic→COO | auto-remediate funds |

Invariants on all stubs: I-27 (HITL-L4 activation), I-28 (IL-recorded), no live mutation, no
shortfall suppression (absolute).

---

## 7. Acceptance + gate-preconditions

- §1/§2/§4 = authored real delta (operating governance over existing canon).
- §3 = coverage-note + narrow break-queue delta (existing CASS7 gates NOT duplicated/weakened).
- §5 = coverage-note (parallel SP-THIN / CFO resolution — not duplicated).
- All new roles/stubs = **PROPOSED, dormant**; activation ONLY after **I-27 HITL-L4 sign-off**.
- STAFF-MATRIX-v2/v1 + HITL-MATRIX.yaml + passports untouched (matrix-update = separate gated step).
- Safeguarding shortfall auto-FCA-alert / no-AI-suppress = referenced verbatim, **immutable**.

---

### Refs
`governance/CANONICAL-ORG-CHART-v2.md` (§4 Dept-4 COO SMF24 James Hargreaves); companions
SPRINT-4-MLRO-LINE / SPRINT-5-INTERNAL-AUDIT-LINE / SPRINT-6-CFO-DEEP-BUILD; passports (ref only)
`coo_operations_agent`, `payment_router_agent`, `customer_lifecycle_agent`,
`safeguarding_recon_governor`, `safeguarding_audit_agent`; `HITL-MATRIX.yaml` (HITL-009/016,
BreachDetector, FIN060, CASS10A — read-only); emi-stack `services/resolution/wind_down_plan.py`
(§5 ref); ADR-102, ADR-059-A, Rule 1/6, I-27, I-28.
