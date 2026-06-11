# IL-CREDIT-01: CreditScoringAgent — MASK_ONLY over lending domain (HITL-on-reject)

- Sprint: 51
- Status: DONE
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked PR: CarmiBanxe/banxe-emi-stack (branch feat/sprint-51-credit-scoring)
- Root ledger anchor: IL-180
- Audit ref: docs/audit/ORG-CODE-RECONCILIATION-2026-06-11.md (IL-176, verdict MASK_ONLY)
- Created: 2026-06-11

## Context
The ORG↔code reconciliation audit (IL-176) verdicted `CreditScoringAgent` (ORG Risk/Credit;
"HITL required on all rejections"; EU AI Act high-risk) as **MASK_ONLY**: the lending/credit
domain already exists and is tested (`services/lending/*`, 8 test files), so it needed only a thin
client-facing §D2 mask. This is the second MASK_ONLY agent (after ChargebackAgent, IL-178).

## Delivered
### Mask (`services/agents/credit_scoring_agent.py`)
Thin §D2 mask delegating to the lending domain via an injected handle (`Protocol`; the real
`CreditScorer` + `LoanOriginator` conform). NO domain rewrite, NO new port.
- Actions: `score_customer` + `get_latest_score` (AUTO reads/compute; below-AUTO →
  HALT_REVIEW_DEFERRED); `decide` (credit decision).
- Full ADR-049 §D2 gate-chain (process_ref → scope → band → cost_cap → compliance(CREDIT +
  CONSUMER_DUTY) → step-up → domain), one ADR-046 `AgentDecisionRecord` per action; handle +
  recorder injected.
- Provider-error: domain `ValueError` (not-found / not-PENDING) → emit(executed=False) + re-raise.
- R-SEC: only opaque handles (customer_id / application_id) in lineage — never income, score,
  aml_risk, or PII; domain return rides on `AgentOutcome.result`.

### ⭐ Regulatory invariant (enforced in code + test) — EU AI Act Art.14 / FCA CONC / I-27
A credit **REJECTION can NEVER be finalized autonomously**. When the proposed outcome is a
rejection (`DecisionOutcome.DECLINED`), the mask sets `force_review=True` + `requires_step_up=True`
→ mandatory human review regardless of confidence; with no reviewer the action HOLDs
(HOLD_FOR_REVIEW), `handle.decide` is **never called**, and it escalates to the credit reviewer.
`test_reject_at_confidence_100_forces_hitl` proves a rejection at confidence=1.0 still HALTs with
`decide` never invoked (call-spy). Approve/refer follow the normal AUTO/REVIEW band. This composes
with the domain's own I-27 `HITL_REQUIRED` wrapping (defense in depth).

### Domain reused (untouched)
`services/lending/{credit_scorer,loan_originator,lending_agent,models,arrears_manager,
provisioning_engine,repayment_engine}.py` — read-only reference; not modified.

## Verification
- 100% coverage on the new mask module. ruff check + `ruff format --check` clean; semgrep
  (banxe-rules) clean; full repo suite green.
- Branches covered: AUTO score/read, decide-APPROVED proceed, the reject→mandatory-HITL invariant
  (reject@confidence=1.0 → HOLD, domain not called; reject-with-reviewer → proceed),
  HALT_UNRESOLVED_PROCESS, REJECT_OUT_OF_SCOPE, HALT_REVIEW_DEFERRED, BLOCK_LOW_CONFIDENCE,
  HALT_COST_CAP_BREACH (per-request + per-window), HALT_COMPLIANCE_BLOCK (escalate→credit reviewer),
  HALT_PROVIDER_ERROR (ValueError emit+reraise), ValueError on out-of-range confidence, R-SEC,
  one record per action.

## Doc-sync (this PR, banxe-architecture)
- `docs/ORG-STRUCTURE.md` (Risk/Credit, line ~406) — `(PROPOSED)` removed on CreditScoringAgent
  only; other agents untouched.
- `INSTRUCTION-LEDGER.md` — root block `### IL-180` (append-only).
- `MEMORY.md` — sprint-51 block.
- **No new ADR** — operates under existing ADR-049 §D2; no new port/contract; lending domain
  untouched.

## Next MASK_ONLY (audit Tier-2)
ContractAgent → agreement; NPSAgent → support/feedback_analytics.
