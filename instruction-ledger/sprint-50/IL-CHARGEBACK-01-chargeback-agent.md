# IL-CHARGEBACK-01: COO ChargebackAgent — MASK_ONLY over dispute_resolution domain

- Sprint: 50
- Status: DONE
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked PR: CarmiBanxe/banxe-emi-stack (branch feat/sprint-50-chargeback)
- Root ledger anchor: IL-178
- Audit ref: docs/audit/ORG-CODE-RECONCILIATION-2026-06-11.md (IL-176, verdict MASK_ONLY)
- Created: 2026-06-11

## Context
The ORG↔code reconciliation audit (IL-176) verdicted `ChargebackAgent` (ORG §2.6.1 COO, L2 Review,
gate COO) as **MASK_ONLY**: the dispute/chargeback domain already exists and is tested
(`services/dispute_resolution/*`, 8 test files), so it only needed a thin client-facing §D2 mask —
not a new domain or a new port. Precedent: the §D2 `TreasuryAgent` mask coexists with the domain
`services/treasury/treasury_agent.py`.

## Delivered
### Mask (`services/agents/chargeback_agent.py`)
A thin client-facing §D2 mask that DELEGATES to the existing dispute_resolution domain via an
injected handle (a narrow `Protocol` for DI; the real `ChargebackBridge` conforms). NO domain
rewrite, NO new heavy port.
- Actions: `initiate_chargeback` + `submit_representment` (L2 → COO review step-up; force_review,
  no reviewer → HOLD_FOR_REVIEW, domain NOT called, escalate→COO; with reviewer → delegate);
  `get_chargeback_status` (AUTO read; below-AUTO → HALT_REVIEW_DEFERRED).
- Full ADR-049 §D2 gate-chain (process_ref → scope → band → cost_cap → compliance(DISPUTE) →
  step-up(COO) → domain call), one ADR-046 `AgentDecisionRecord` per action; handle + recorder
  injected.
- Provider-error: domain raises `ValueError` (unknown scheme / non-positive amount / not-found) →
  mask emits lineage (executed=False) then re-raises (precise catch, no blind except).
- R-SEC: only opaque handles (chargeback_id / dispute_id) in lineage — never amounts/PII/customer
  data; the domain dict return rides on `AgentOutcome.result` only.

### Domain reused (untouched)
`services/dispute_resolution/{chargeback_bridge,dispute_agent,dispute_intake,escalation_manager,
investigation_engine,resolution_engine,models}.py` — read-only reference; not modified.

## Verification
- 100% coverage on the new mask module (`services/agents/chargeback_agent.py`). ruff check +
  `ruff format --check` clean; semgrep (banxe-rules) clean; full repo suite green.
- Branches covered: AUTO read, REVIEW-with-reviewer execute, HOLD_FOR_REVIEW (no reviewer, domain
  not called), HALT_UNRESOLVED_PROCESS, REJECT_OUT_OF_SCOPE, HALT_REVIEW_DEFERRED,
  BLOCK_LOW_CONFIDENCE, HALT_COST_CAP_BREACH (per-request + per-window), HALT_COMPLIANCE_BLOCK
  (escalate→COO), HALT_PROVIDER_ERROR (ValueError emit+reraise), ValueError on out-of-range
  confidence, R-SEC, one record per action.

## Doc-sync (this PR, banxe-architecture)
- `docs/ORG-STRUCTURE.md` §2.6.1 — `(PROPOSED)` removed on ChargebackAgent only; other COO agents
  untouched.
- `INSTRUCTION-LEDGER.md` — root block `### IL-178` (append-only).
- `MEMORY.md` — sprint-50 block.
- **No new ADR** — the mask operates under existing ADR-049 §D2 and introduces no new port/contract.

## Next MASK_ONLY (audit Tier-2, same pattern)
CreditScoringAgent → lending (HITL-on-reject), ContractAgent → agreement, NPSAgent →
support/feedback_analytics.
