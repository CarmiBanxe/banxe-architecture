# IL-LEAD-01: Front-Office LeadScoringAgent — Tier-3 BUILD (LeadSignalPort + L1 read-only mask)

- Sprint: 55
- Status: DONE
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked PR: CarmiBanxe/banxe-emi-stack#176 (branch feat/il-190-lead-scoring-agent)
- Root ledger anchor: IL-191
- Audit ref: docs/audit/ORG-CODE-RECONCILIATION-2026-06-11.md (IL-176, verdict BUILD)
- Created: 2026-06-12

## Context
The ORG↔code reconciliation audit (IL-176) verdicted `LeadScoringAgent` (ORG §2.8 Front
Office / Sales, L1 Auto, "Behavioral scoring (signup → active)") as **BUILD** (Tier-3):
unlike the Tier-2 MASK_ONLY agents, no governed read surface for behavioral lead signals
existed, so this needed a NEW read-only port plus a thin client-facing §D2 mask. This is the
**second Tier-3 BUILD** of the audit remainder (after IL-189 ChurnPredictionAgent), following
the established read-only BUILD pattern of sprint-47 RiskOversight (RiskMetricsPort, IL-173)
and sprint-48 DataQuality (DataQualityPort, IL-174).

**Distinction:** there is **no existing lead / sales / marketing domain** to derive from —
`services/referral/` and `services/crm/` exist but are NOT lead scoring — so this is a **full
BUILD** of a new read-only contract. `LeadSignalPort` is a read-only CONTRACT abstraction of
behavioral lead scoring. ORG §2.8.2 names **ClickHouse + scikit-learn** as the production
stack, but that real adapter (reading the behavioral-event stream from ClickHouse and serving
a scikit-learn propensity model behind the port) is a **later sprint** (I-10: no fake
integrations now, exactly like the analytics / churn adapters). The mask delegates to the
port's read surface only.

## Delivered
### ETAP A — Port (`services/lead_scoring/lead_signal_port.py`)
Governed READ-ONLY CONTRACT `LeadSignalPort` (the boundary the mask `scope` allow-lists):
- `get_active_leads(threshold: Decimal) -> list[ScoredLead]` (highest-score first).
- `get_lead_score(lead_id) -> LeadScore`.
- `abc.ABC` + `InMemoryLeadSignalPort` (in-memory double for unit tests) + error hierarchy
  `LeadSignalPortError` / `LeadNotFound`.
- Value types (frozen): `ScoredLead`, `LeadScore`, `LeadSignal`; enums `LeadScoreBand`
  (COLD / WARM / HOT), `LeadStage` (SIGNUP / ONBOARDING / ACTIVATED / ACTIVE — the signup →
  active funnel), `LeadSignalCode` (behavioral indicators a production adapter would derive
  behind the port).
- **READ-ONLY invariant at the contract level:** the port has NO mutate / contact / outreach /
  nurture / write method at all (I-10: no fake integrations; I-27: no autonomous customer-state
  change or outreach action).
- I-01: every numeric field (score, signal weight, threshold) is `Decimal`, never float.
- R-SEC: only opaque handles (`lead_id` / `cohort`) cross the boundary — no raw PII, no raw
  behavioral events.

### ETAP B — Mask (`services/agents/lead_scoring_agent.py`)
L1-Auto `LeadScoringAgent` in front of `LeadSignalPort`:
- Actions: `report_active_leads` (→ `get_active_leads`) and `get_lead_score`
  (→ `get_lead_score`). Both AUTO reads; below-AUTO → HALT_REVIEW_DEFERRED.
- Full ADR-049 §D2 gate-chain (process_ref → scope → band → cost_cap → compliance(PII) → port),
  one ADR-046 `AgentDecisionRecord` per action on every exit path; port + recorder injected.
- **INVARIANT (L1 read-only, tested):** scoring/reporting only — never contacts a lead or
  mutates state autonomously. Enforced three ways: (1) mask scope = the 2 read ops only;
  (2) the port has no mutate method; (3) success_actions are SCORE_/REPORT_ verbs only. Any
  contact/outreach/write op is REJECT_OUT_OF_SCOPE. Compliance non-PASS → BLOCK + escalate→DPO.
- Provider-error: `LeadSignalPortError` (incl. `LeadNotFound`) → emit(executed=False) +
  re-raise. R-SEC: only opaque handles (lead_id / cohort) in lineage — never scores, signal
  weights, raw behavioral events, or PII; the `list[ScoredLead]` / `LeadScore` ride on
  `AgentOutcome.result`.

### Domain reused (untouched)
None — full BUILD. `services/referral/*` and `services/crm/*` are NOT lead scoring and are not
touched.

## Tests & proof
- `tests/test_lead_scoring/test_lead_signal_port.py` + `tests/agents/test_lead_scoring_agent.py`
  — 43 tests, **100% coverage on BOTH new modules**.
- Covers: AUTO happy path, HALT_UNRESOLVED_PROCESS, REJECT_OUT_OF_SCOPE (contact/outreach
  refused), HALT_REVIEW_DEFERRED (port not called), BLOCK_LOW_CONFIDENCE, HALT_COST_CAP_BREACH
  (per-request + per-window), HALT_COMPLIANCE_BLOCK, HALT_PROVIDER_ERROR (emit+reraise),
  invalid confidence → ValueError, R-SEC (no scores/PII in lineage), ADR-046 (1 record/action),
  read-only INVARIANT (no lead-state mutation).
- Full suite: **10896 passed / 37 skipped / 0 failed**; `ruff check` + `ruff format --check` clean.
- PR #176 mergeStateStatus **BLOCKED** (required review = R3) → operator authorizes the merge
  separately; NOT --admin self-merged.

## Doc-sync (this PR)
- ORG §2.8: `(PROPOSED)` removed on `LeadScoringAgent` only (line 312). §2.8.2 detail row
  unchanged (it carries no PROPOSED marker).
- Root `INSTRUCTION-LEDGER.md`: new `### IL-191` block (append-only over main, I-28; renumbered from IL-190 after main raced and took IL-190 for ADR-021).
- `MEMORY.md`: sprint-55 block.
- NO new ADR — fits the existing L1 read-only ADR-049 §D2 pattern (as with ChurnPrediction /
  RiskOversight / DataQuality).

## Refs
ADR-049 §D2; ADR-046; ADR-016 (PII overlay); audit IL-176 (BUILD); IL-189 ChurnPredictionAgent;
sprint-47 RiskOversight (IL-173); sprint-48 DataQuality (IL-174).
