# IL-NPS-01: Front-Office NPSAgent — MASK_ONLY over support feedback domain (L1 read-only)

- Sprint: 53
- Status: DONE
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked PR: CarmiBanxe/banxe-emi-stack (branch feat/sprint-53-nps)
- Root ledger anchor: IL-187
- Audit ref: docs/audit/ORG-CODE-RECONCILIATION-2026-06-11.md (IL-176, verdict MASK_ONLY)
- Created: 2026-06-11

## Context
The ORG↔code reconciliation audit (IL-176) verdicted `NPSAgent` (ORG §2.8 Front Office / NPS,
L1 Auto) as **MASK_ONLY**: the support feedback domain already exists and is tested
(`services/support/feedback_analytics_agent.py`, NPS/CSAT + Consumer Duty PS22/9), so it needed
only a thin client-facing §D2 mask. This is the **fourth and final** MASK_ONLY agent (after
Chargeback IL-178, CreditScoring IL-180, Contract IL-182) — completing audit Tier-2.

**Distinction:** `NPSAgent` (the L1 client-facing mask built here, §2.8) is distinct from the
existing `FeedbackAnalyticsAgent` (§2.8.1 domain agent). The mask delegates to that domain agent's
read surface — it does not replace or rewrite it.

## Delivered
### Mask (`services/agents/nps_agent.py`)
Thin §D2 mask (L1 Auto, read-only) delegating to the support feedback domain via an injected handle
(`Protocol`; the real `FeedbackAnalyticsAgent` conforms). NO domain rewrite, NO new port.
- Action: `get_feedback_metrics` (AUTO read → `FeedbackAnalyticsAgent.get_metrics(period_days)`,
  returning the NPS + CSAT aggregate). Below-AUTO → HALT_REVIEW_DEFERRED.
- Full ADR-049 §D2 gate-chain (process_ref → scope → band → cost_cap → compliance(CONSUMER_DUTY) →
  domain), one ADR-046 `AgentDecisionRecord` per action; handle + recorder injected.
- **L1 read-only invariant (tested):** the mask scope contains only the read op `get_metrics`; the
  write `submit_csat` is out-of-scope and refused. Compliance non-PASS → BLOCK + escalate→CRO.
- Provider-error: domain `ValueError` → emit(executed=False) + re-raise.
- R-SEC: only opaque handles (survey_id / cohort / period_days) in lineage — never raw customer
  feedback text, CSAT comments, or PII (the support domain is a RED trust zone); the
  `FeedbackMetrics` aggregate rides on `AgentOutcome.result`.

### Domain reused (untouched)
`services/support/{feedback_analytics_agent,support_models}.py` — read-only reference; not modified.

## Verification
- 100% coverage on the new mask module. ruff check + `ruff format --check` clean; semgrep
  (banxe-rules) clean; full repo suite green.
- Branches covered: AUTO read (get_feedback_metrics), HALT_UNRESOLVED_PROCESS, REJECT_OUT_OF_SCOPE
  (submit_csat write refused — the read-only invariant), HALT_REVIEW_DEFERRED (below AUTO → domain
  not called), BLOCK_LOW_CONFIDENCE, HALT_COST_CAP_BREACH (per-request + per-window),
  HALT_COMPLIANCE_BLOCK (escalate→CRO), HALT_PROVIDER_ERROR (ValueError emit+reraise), ValueError on
  out-of-range confidence, R-SEC, one record per action.

## Doc-sync (this PR, banxe-architecture)
- `docs/ORG-STRUCTURE.md` §2.8 (line ~315) — `(PROPOSED)` removed on NPSAgent only (LeadScoringAgent
  + CampaignAgent remain PROPOSED — BUILD-tier; FeedbackAnalyticsAgent already implemented).
- `INSTRUCTION-LEDGER.md` — root block `### IL-187` (append-only).
- `MEMORY.md` — sprint-53 block.
- **No new ADR** — operates under existing ADR-049 §D2; no new port/contract; support domain
  untouched.

## Milestone — audit Tier-2 (MASK_ONLY) COMPLETE
All four MASK_ONLY agents delivered: ChargebackAgent (IL-178), CreditScoringAgent (IL-180),
ContractAgent (IL-182), NPSAgent (IL-187). Remaining per the IL-176 audit: Tier-3 BUILD
(ChurnPrediction, LeadScoring, Campaign, IncidentResponse, HR) and Tier-4 DEFER/GATED
(MLPipelineAgent, I-27).
