# IL-CONTRACT-01: Legal ContractAgent — MASK_ONLY over agreement domain

- Sprint: 52
- Status: DONE
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked PR: CarmiBanxe/banxe-emi-stack (branch feat/sprint-52-contract)
- Root ledger anchor: IL-182
- Audit ref: docs/audit/ORG-CODE-RECONCILIATION-2026-06-11.md (IL-176, verdict MASK_ONLY)
- Created: 2026-06-11

## Context
The ORG↔code reconciliation audit (IL-176) verdicted `ContractAgent` (ORG §2.9 Legal, L2 Review,
gate Legal Counsel) as **MASK_ONLY**: the agreement domain already exists with an injectable port
(`services/agreement/agreement_port.py`, `AgreementPort` Protocol) + service, so it needed only a
thin client-facing §D2 mask — no new domain, no new port. Third MASK_ONLY agent (after
ChargebackAgent IL-178, CreditScoringAgent IL-180).

## Delivered
### Mask (`services/agents/contract_agent.py`)
Thin §D2 mask delegating to the agreement domain via the injected `AgreementPort` Protocol
(imported and used directly — no new adapter). NO domain rewrite.
- Actions: `create_agreement` + `record_signature` (L2 → Legal Counsel review step-up: force_review,
  no reviewer → HOLD_FOR_REVIEW, domain NOT called, escalate→LEGAL_COUNSEL; with reviewer →
  delegate); `get_agreement` (AUTO read; below-AUTO → HALT_REVIEW_DEFERRED).
- Full ADR-049 §D2 gate-chain (process_ref → scope → band → cost_cap → compliance(LEGAL) →
  step-up(LEGAL_COUNSEL) → domain), one ADR-046 `AgentDecisionRecord` per action; handle + recorder
  injected.
- Provider-error: domain `AgreementError` (code/message) → emit(executed=False) + re-raise.
- R-SEC: only opaque handles (agreement_id / customer_id / product_type) in lineage — never terms
  content, signature data, or PII; the domain `Agreement` rides on `AgentOutcome.result`.

### Domain reused (untouched)
`services/agreement/{agreement_port,agreement_service}.py` — read-only reference; not modified.

## Verification
- 100% coverage on the new mask module. ruff check + `ruff format --check` clean; semgrep
  (banxe-rules) clean; full repo suite green.
- Branches covered: AUTO read (get_agreement), REVIEW-with-reviewer execute (create_agreement /
  record_signature), HOLD_FOR_REVIEW (no reviewer, domain not called, escalate→LEGAL_COUNSEL),
  HALT_UNRESOLVED_PROCESS, REJECT_OUT_OF_SCOPE, HALT_REVIEW_DEFERRED, BLOCK_LOW_CONFIDENCE,
  HALT_COST_CAP_BREACH (per-request + per-window), HALT_COMPLIANCE_BLOCK (escalate→LEGAL_COUNSEL),
  HALT_PROVIDER_ERROR (AgreementError emit+reraise), ValueError on out-of-range confidence, R-SEC,
  one record per action.

## Doc-sync (this PR, banxe-architecture)
- `docs/ORG-STRUCTURE.md` §2.9 (line ~362) — `(PROPOSED)` removed on ContractAgent only (HRAgent
  remains PROPOSED; AgreementAgent already implemented, distinct).
- `INSTRUCTION-LEDGER.md` — root block `### IL-182` (append-only).
- `MEMORY.md` — sprint-52 block.
- **No new ADR** — operates under existing ADR-049 §D2; no new port/contract; agreement domain
  untouched.

## Remaining MASK_ONLY (audit Tier-2)
NPSAgent → support/feedback_analytics (last of Tier-2).
