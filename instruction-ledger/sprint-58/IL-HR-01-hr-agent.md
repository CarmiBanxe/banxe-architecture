# IL-HR-01: HRAgent — Tier-3 BUILD (HRPort + L1 mask, mandatory CEO gate on SMF hires) — LAST Tier-3

- Sprint: 58
- Status: DONE
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked PR: CarmiBanxe/banxe-emi-stack#179 (branch feat/il-197-hr-agent)
- Root ledger anchor: IL-198
- Audit ref: docs/audit/ORG-CODE-RECONCILIATION-2026-06-11.md (IL-176, verdict BUILD)
- Created: 2026-06-12

## Context
The ORG↔code reconciliation audit (IL-176) verdicted `HRAgent` (ORG §2.9 HR / Legal /
Compliance Admin, **L1 Auto**, gate **CEO for hiring SMF holders**) as **BUILD** (Tier-3).
This is the **fifth and LAST Tier-3 BUILD** of the audit remainder (after IL-189
ChurnPredictionAgent, IL-191 LeadScoringAgent, IL-193 CampaignAgent and IL-196
IncidentResponseAgent) — it **completes the Tier-3 BUILD set**. It is the **third** whose
mask carries a hard mandatory-step-up regulatory invariant (after Campaign's COBS 4 MLRO
publish gate and Incident's SYSC 8.1 CRITICAL→CTO+CEO step-up), and the **first** that
fuses an L1-AUTO routine surface with a mandatory step-up gate — the L1-routine pattern of
`services/agents/churn_prediction_agent.py` combined with the mandatory-gate invariant of
`services/agents/credit_scoring_agent.py`.

**Context / distinction:** `services/compliance_automation/*` EXISTS with the SM&CR
registry (`smcr_framework.py` / `smcr_models.py` / `smcr_registry.py` — the registry of SMF
holders and certified persons). The HR mask reads SMF / role data from it through a
**read-only** `SMCRReadHandle` Protocol (structurally compatible with the existing
`InMemorySMCRRegistry`); `compliance_automation` is **NOT** modified, imported for mutation,
or owned. ORG §2.9 implies a real HRIS, but that integration is a **later sprint** (I-10: no
fake integrations now) — this ships the contract + in-memory doubles for unit tests only.

## The regulatory invariant (FCA SM&CR — enforced in code AND test)
ORG §2.9 line 361: `HR | HRAgent | L1 Auto | CEO (hiring SMF holders)`.

Routine people-ops (training tracking, conduct-rule attestations, headcount reporting) are
**L1 AUTO**. BUT hiring / appointing / changing a holder of a **Senior Management Function
(SMF)** can **NEVER** be done autonomously — it is a **mandatory step-up to the CEO
regardless of confidence**:

- Routine reads/writes (`check_training` / `attest_conduct`) are normal L1 — AUTO-eligible
  within cap, below-AUTO → `HALT_REVIEW_DEFERRED` (no HITL hold).
- An SMF appointment (`appoint_smf`) proceeds **only** with a valid CEO authorization token.
  With no token the action **HALTS** (`HALT_SMF_CEO_STEP_UP_REQUIRED`), the appointment is
  **never applied** (`apply_smf_appointment` is never called), and it **escalates to the
  CEO** (`requires_step_up = True`). This holds even at `confidence = 1.0` (AUTO band).
- The CEO step-up is a hard regulatory floor: mask config can only *strengthen* it
  (escalation role), never disable it — a permissive mask (`auto_threshold = 0`) still
  forces the step-up.
- **Defence-in-depth:** `HRPort.apply_smf_appointment` itself raises
  `CEOAuthorizationRequired` without a CEO token, so an SMF holder cannot be appointed
  through the port even if the mask gate were bypassed. AI may prepare a proposal; appointing
  an SMF holder requires the CEO.

## Delivered
### ETAP A — Port (`services/hr/hr_port.py`)
People-operations CONTRACT `HRPort` (the boundary the mask `scope` allow-lists):
- `get_training_status(employee_id, course_id) -> TrainingStatus` — routine L1 read;
  raises `EmployeeNotFound`.
- `record_conduct_attestation(employee_id, tier, *, attested) -> ConductAttestation` —
  routine L1 bookkeeping (not an appointment, so it never trips the SMF gate).
- `propose_smf_appointment(role, candidate, *, incumbent_id=None) -> SMFAppointmentProposal`
  — **prepare only**: builds a token-less proposal and appoints nothing.
- `apply_smf_appointment(proposal, ceo_token) -> SMFAppointment` — the **only** commit seam;
  **raises `CEOAuthorizationRequired` without a non-empty CEO token**.
- `abc.ABC` + `InMemoryHRPort` (in-memory double, with a transient-failure switch) +
  `InMemorySMCRReadHandle` + error hierarchy `HRPortError` / `EmployeeNotFound` /
  `HRSourceUnavailable` / `CEOAuthorizationRequired` (each carries `correlation_id`).
- Frozen value types `TrainingStatus` / `ConductAttestation` / `SMFAppointmentProposal` /
  `SMFAppointment`; enum `ConductRuleTier` (TIER_1 / TIER_2).
- **Read-only SM&CR handle:** `SMCRReadHandle` Protocol — `get_senior_manager(person_id)`;
  the mask reads the current SMF holder through it and never mutates the registry (there is
  intentionally no register/file method). Return type `object | None` for loose coupling.

### ETAP B — Mask (`services/agents/hr_agent.py`)
L1 `HRAgent` enforcing the ORG §2.9 / SM&CR HR mask in the fixed ADR-049 §D2 gate-chain
order:

    process_ref → scope → confidence-band → cost_cap → compliance → CEO SMF step-up → port

- One ADR-046 `AgentDecisionRecord` per action, emitted on **every** exit path; port,
  read-only SM&CR handle, and `DecisionRecorder` injected as interfaces (pure governance
  logic, no live infra).
- Routine ops are AUTO-only (below-AUTO → `HALT_REVIEW_DEFERRED`, L1 — no HITL hold); the SMF
  appointment is the mandatory CEO step-up (gated by a valid `ceo_token` regardless of band).
- compliance non-PASS → BLOCK + escalate→CEO; `HRPortError` → emit(executed=False) + reraise
  (`HALT_PROVIDER_ERROR`); invalid confidence → `ValueError`.
- **R-SEC (ADR-021):** the lineage record carries opaque metadata ONLY — `employee_id` /
  `role` / `candidate_id`; never names, salary, performance data, PII, or the CEO
  authorization token (the token is routed straight to the port, never recorded; CEO sign-off
  is recorded as the opaque role `"CEO"`). Tested.

### Shared primitive (NOT modified)
`services/agents/_lineage.py` is **unchanged** — the existing `AgentOutcome.requires_step_up`
/ `escalated_to` fields carry the SMF gate; the 15 existing agents are untouched (full
`tests/agents/` suite green — 710 passed, no regression).

## Proof
- `banxe-emi-stack` PR #179 — **100% coverage on BOTH new modules**
  (`services/hr/hr_port.py` + `services/agents/hr_agent.py`).
- Tests (`tests/test_hr/test_hr_port.py` + `tests/agents/test_hr_agent.py`) cover: routine
  AUTO happy path (training read + conduct attestation), the routine below-AUTO re-check
  (`HALT_REVIEW_DEFERRED`), the **SMF-CEO-gate invariant** (appoint-SMF @ confidence=1.0, no
  CEO token → `HALT_SMF_CEO_STEP_UP_REQUIRED`, escalate→CEO, `requires_step_up`,
  `apply_smf_appointment` never called) + appoint-with-CEO-token-proceeds (new + change via
  the read-only handle) + a REVIEW-band proceed-with-token + a config-floor test (permissive
  mask cannot waive the step-up) + the empty-token-treated-as-no-token path,
  `HALT_UNRESOLVED_PROCESS`, `REJECT_OUT_OF_SCOPE`, `BLOCK_LOW_CONFIDENCE` (routine +
  SMF→escalate CEO), `HALT_COST_CAP_BREACH` (per-request + per-window),
  `HALT_COMPLIANCE_BLOCK` (escalate→CEO), `HALT_PROVIDER_ERROR` (emit + reraise),
  invalid-confidence `ValueError`, R-SEC (no PII/salary/token in lineage), ADR-046 (one
  record per action). Port tests additionally prove the defence-in-depth port refusal
  (`apply_smf_appointment` without a token raises) and the read-only handle double.
- Full `tests/agents/` suite green — **710 passed** (15 existing agents intact).
- `ruff check` + `ruff format --check` clean.
- PR mergeStateStatus **BLOCKED** (required review = R3) → operator authorizes merge
  separately; **NOT** `--admin` self-merged.

## Doc-sync (this PR)
- ORG §2.9 `(PROPOSED)` removed on `HRAgent` only (line 361).
- Root ledger anchor `### IL-198` (main raced — expected IL-197 was taken by ADR-083
  Composable DeFi Stack #426 during this PR; renumbered to next free IL-198, append-only).
- MEMORY sprint-58 block.
- NO new ADR (fits the existing §D2 mandatory-step-up mask pattern — Campaign / Incident).

## Milestone
**Completes audit IL-176 Tier-3 BUILD** — Churn + Lead + Campaign + Incident + **HR** all
done. Third Tier-3 BUILD with a mandatory-step-up regulatory gate (after Campaign's COBS 4
MLRO publish gate and Incident's SYSC 8.1 CRITICAL step-up), and the first to fuse an L1-AUTO
routine surface with a mandatory step-up. Remaining audit work: Tier-4 MLPipeline (I-27).

## Refs
ADR-049 §D2; ADR-046; ADR-021 (R-SEC); ORG §2.9 FCA SM&CR; audit IL-176 (BUILD);
IL-196 IncidentResponseAgent (mandatory-step-up sibling); IL-193 CampaignAgent
(mandatory-step-up sibling); IL-189 ChurnPredictionAgent (L1-routine pattern);
`services/agents/credit_scoring_agent.py` (mandatory-gate invariant pattern);
`services/compliance_automation/smcr_registry.py` (read-only SM&CR source).
