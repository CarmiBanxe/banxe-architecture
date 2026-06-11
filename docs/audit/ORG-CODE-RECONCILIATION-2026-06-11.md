# ORG-STRUCTURE ↔ Code Reconciliation Audit — 2026-06-11

**Mode:** read-only. **Repos:** banxe-emi-stack @ `d176b91`, banxe-architecture @ `527fb08`.
**Purpose:** reconcile the ORG chart's `(PROPOSED)` agent list against actual code so remaining
work targets only what is genuinely missing, and never re-builds an existing domain service.

## Key distinction (the source of the drift)

- **Domain service** = the business logic (e.g. `services/lending/credit_scorer.py`). The repo has
  **60+ domain `*_agent.py`** across `services/*` — deep coverage.
- **§D2 client-facing mask** = a `services/agents/<x>_agent.py` that runs the full ADR-049 §D2
  gate-chain (process_ref → scope → band → cost_cap → compliance → step-up → port) and emits one
  ADR-046 `AgentDecisionRecord` per action. Only **12** exist: analytics, bi, cards, crm,
  data_quality, forecast, fpa, kyc_onboarding, notification, risk_oversight, statement, treasury.
- A `(PROPOSED)` ORG row often means "no **mask** yet" — NOT "no code". Precedent: the §D2
  `TreasuryAgent` mask coexists with the pre-existing domain `services/treasury/treasury_agent.py`.

**None of the 11 `(PROPOSED)` agents has a §D2 mask in `services/agents/` yet** (verified).

## A. Per-agent matrix

| Agent | ORG block | Domain code (banxe-emi-stack) | §D2 mask | Tests | VERDICT | Notes |
|-------|-----------|-------------------------------|----------|-------|---------|-------|
| `ChargebackAgent` | §2.6 COO (L2/CTO→COO) | **YES** — `services/dispute_resolution/` (chargeback_bridge, dispute_agent, resolution_engine, investigation_engine, escalation_manager) | NO | 8 domain test files | **MASK_ONLY** | Thin L2 mask over dispute_resolution; gate=COO. |
| `CreditScoringAgent` | Risk/Credit §App (L1 + HITL on reject) | **YES** — `services/lending/` (credit_scorer, lending_agent, loan_originator, provisioning_engine) | NO | 8 domain test files | **MASK_ONLY** | Not pure L1: HITL/REVIEW required on every rejection — mask needs a REVIEW path on reject. |
| `ContractAgent` | §2.9 Legal (L2/Legal Counsel) | **YES** — `services/agreement/` (agreement_service, agreement_port) | NO | 1 domain test file | **MASK_ONLY** | Agreement domain ≈ contract; thin L2 mask, gate=Legal Counsel. |
| `NPSAgent` | §2.8 Front/NPS (L1) | **PARTIAL** — `services/support/feedback_analytics_agent.py` (+ support_models) | NO | 9 support test files | **MASK_ONLY** (partial) | feedback-analytics domain backs an NPS read mask; confirm field coverage before building. |
| `ChurnPredictionAgent` | §2.6 COO (L1) | **NONE** (no churn module; `services/customer_lifecycle/` has dormant-state FSM — adjacent, not churn prediction) | NO | — | **BUILD** | Port-first; could read customer_lifecycle / analytics signals. No churn domain today. |
| `CampaignAgent` | §2.8 Marketing (L1) | **PARTIAL/ADJACENT** — `services/referral/campaign_manager.py`, `services/loyalty/models.py` (referral & loyalty campaigns only) | NO | referral/loyalty tests | **BUILD** | No general marketing-campaign domain; referral campaign_manager is reusable scaffolding, not the §2.8 surface. |
| `IncidentResponseAgent` | §2.7.4 CTO Security (L2; CTO+CEO on CRITICAL) | **NONE** for security-incident (support/escalation_agent is *customer* support, different domain) | NO | — | **BUILD** | Security incident triage; CRITICAL→CEO notify ≤2h (FCA SYSC 8.1). Port-first. |
| `LeadScoringAgent` | §2.8 Sales (L1) | **NONE** ("lead" hits are case_management/design_pipeline false-positives) | NO | — | **BUILD** | No sales/lead domain. Port-first. |
| `HRAgent` | §2.9 HR (L1; CEO for SMF hires) | **NONE** (no HR/recruit/payroll module) | NO | — | **BUILD** | No HR domain. Port-first; CEO gate on SMF-holder hiring. |
| `MLPipelineAgent` | §2.7.1 CTO (L3, I-27) | **NONE** (no retrain pipeline; `services/experiment_copilot/agents/*` adjacent: change_proposer/experiment_designer) | NO | — | **DEFER/GATED** | **I-27: no autonomous model updates; CRO+CTO sign-off.** Build only as a propose-only, human-gated mask — like DeployAgent prod. |
| `DeployAgent` | §2.7.2 CTO (L2 staging / L3 prod) | **IN-FLIGHT** (sprint-49; no `services/deploy` on origin/main yet) | IN-FLIGHT | in-flight | **DEFER/GATED** | Being built now (ADR-081). Prod-L3 = mandatory CTO approval token; no autonomous prod execute. **⚠ IL note below.** |

### ⚠ Ledger-number note
The in-flight sprint-49 DeployAgent task assumed **IL-175**, but **IL-175 is already taken** on
arch `origin/main` (`527fb08`, PR #404 — banxe-trading-frontend branch protection). The DeployAgent
doc-sync must use **IL-176** (next free), not IL-175.

## B. Reverse cross-check — implemented, NOT in ORG chart (chart gaps)

The chart under-represents code massively. Two classes of gap:

1. **Built §D2 masks with no explicit ORG row** (or only implied): `cards_agent`, `statement_agent`,
   `analytics_agent` (C7), `crm_agent`, `notification_agent`, `kyc_onboarding_agent` — these are
   implemented governed masks; ORG §2.x should list them as IMPLEMENTED where missing.
2. **Large domain-agent layer absent from the chart** (~60 `services/*/*_agent.py`), e.g.:
   `savings`, `lending`, `loyalty`, `insurance`, `merchant_acquiring`, `kyb_onboarding`,
   `scheduled_payments`, `batch_payments`, `beneficiary_management`, `multi_currency`,
   `swift_correspondent`, `open_banking`, `psd2_gateway`, `consumer_duty`, `fatca_crs`,
   `regulatory_reporting`, `device_fingerprint`, `ato_prevention`, `fraud_tracer`,
   `sanctions_screening`, `recon`, `customer_lifecycle`, `complaints`, `consent_management`,
   `swarm/agents/*`, `design_pipeline/agents/*`, `experiment_copilot/agents/*`.
   These are domain services, not §D2 masks — but the ORG chart claims to map "all technical
   platform agents" (§2.7) and should either reference them or scope itself to client-facing masks.

**Recommendation:** ORG-STRUCTURE should explicitly state it enumerates **client-facing §D2 masks**,
with domain services tracked separately — otherwise the (PROPOSED) drift will keep recurring.

## C. Prioritized remaining-work plan (cheapest → most sensitive)

### Tier 1 — DOC_ONLY (none)
No `(PROPOSED)` agent is already fully implemented *with a mask*. (The just-shipped FPA/BI/Treasury/
Forecast/RiskOversight/DataQuality were the DOC_ONLY-after-build cases; nothing remains here.)

### Tier 2 — MASK_ONLY (cheapest real work: thin §D2 mask over an existing, tested domain)
1. **ChargebackAgent** → mask over `services/dispute_resolution/` (L2, gate COO). Domain has 8 tests.
2. **CreditScoringAgent** → mask over `services/lending/credit_scorer` (L1 read + **REVIEW/HITL on reject**). 8 tests.
3. **ContractAgent** → mask over `services/agreement/` (L2, gate Legal Counsel).
4. **NPSAgent** → mask over `services/support/feedback_analytics_agent` (L1 read) — verify field fit first.
   *Each needs only a read/validate Port facade (if the domain isn't already a clean port) + the mask + tests.*

### Tier 3 — BUILD (port-first sprint: no domain yet)
5. **ChurnPredictionAgent** (L1) — read-only churn-signal port (can source customer_lifecycle/analytics).
6. **LeadScoringAgent** (L1) — read-only lead-scoring port.
7. **CampaignAgent** (L1) — campaign port (reuse referral/loyalty campaign scaffolding as adapter later).
8. **IncidentResponseAgent** (L2) — security-incident port; CRITICAL→CEO ≤2h (SYSC 8.1).
9. **HRAgent** (L1) — HR port; CEO gate on SMF-holder hires.

### Tier 4 — DEFER/GATED (sensitive; human-mandatory, build with strict invariants)
10. **DeployAgent** — IN-FLIGHT (sprint-49, ADR-081). Prod-L3 mandatory CTO approval token; no autonomous execute. Use **IL-176**.
11. **MLPipelineAgent** — I-27: no autonomous model updates. Build only as propose-only, CRO+CTO-gated mask (same token-gated pattern as DeployAgent prod). Sequence AFTER DeployAgent establishes the pattern.

### Suggested sequencing
DeployAgent (finish in-flight) → the 4 MASK_ONLY (cheap, domain+tests already exist) → the 5 BUILD
(L1-biased, low risk) → MLPipelineAgent last (most sensitive, reuses DeployAgent's gated pattern).
Plus a one-line ORG-STRUCTURE scoping note (Section B) to stop future drift.
