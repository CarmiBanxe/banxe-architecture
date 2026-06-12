# IL-CAMPAIGN-01: Marketing CampaignAgent — Tier-3 BUILD (CampaignPort + L2 mask, MANDATORY MLRO publish gate)

- Sprint: 56
- Status: DONE
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked PR: CarmiBanxe/banxe-emi-stack#177 (branch feat/campaign-agent-il192)
- Root ledger anchor: IL-193
- Audit ref: docs/audit/ORG-CODE-RECONCILIATION-2026-06-11.md (IL-176, verdict BUILD)
- Created: 2026-06-12

## Context
The ORG↔code reconciliation audit (IL-176) verdicted `CampaignAgent` (ORG §2.8.2 Marketing &
Growth, L2 Review, gate **MLRO for financial promotions**, Listmonk) as **BUILD** (Tier-3).
This is the **third Tier-3 BUILD** of the audit remainder (after IL-189 ChurnPredictionAgent
and IL-191 LeadScoringAgent), but the **first** Tier-3 BUILD with a **write/publish** surface:
where Churn/Lead are L1 read-only masks over new read-only ports, CampaignAgent is an L2
client-facing mask with a regulated send path, following the established pattern of the L2
masks `services/agents/kyc_onboarding_agent.py` (mandatory-HITL) and `crm_agent.py` (L2 gate).

**Distinction:** `services/referral/campaign_manager.py` EXISTS, but it owns the
*referral-reward* campaign lifecycle (DRAFT→ACTIVE→PAUSED→ENDED, budget tracking) — a
different bounded context, **not** marketing email/push orchestration. It is **untouched**.
`CampaignPort` is a new CONTRACT abstraction of marketing campaign orchestration. ORG §2.8.2
names **Listmonk (AGPL)** as the production engine, but that real adapter (plus UK GDPR
opt-in/consent + mandatory unsubscribe) is a **later sprint** (I-10: no fake integrations
now). This ships the contract + an in-memory double for unit tests only.

## The regulatory invariant (COBS 4 — enforced in code AND test)
ORG §2.8.2 line 349: *"All marketing content involving financial products MUST be reviewed by
MLRO before publication. AI may draft but NEVER auto-publish."*

A campaign action that **PUBLISHES** financial-promotion content can **NEVER** be executed
autonomously — it is a **mandatory step-up to MLRO regardless of confidence**:

- Drafting (`prepare_campaign`) is **free** — an AI may compose/store a draft at will.
- Publishing a financial promotion proceeds **only** with a valid, campaign-bound
  `MlroReviewToken`. With no/invalid token the action **HALTS** (`HALT_MLRO_REVIEW_REQUIRED`),
  the domain publish (`CampaignPort.publish_campaign`) is **never called**, and the action
  **escalates to the MLRO**. This holds even at `confidence=1.0` (AUTO band).
- The token requirement is a hard regulatory floor: a financial promotion requires it
  irrespective of the mask's `require_mlro_for_publish` flag (which can only *strengthen* the
  gate to cover every publish, never disable it).

This is defence-in-depth: the mask enforces the step-up at the governance layer, and the port
re-checks (`MlroReviewRequired`) at the I/O seam.

## Delivered
### ETAP A — Port (`services/campaign/campaign_port.py`)
Marketing campaign orchestration CONTRACT `CampaignPort` (the boundary the mask `scope`
allow-lists):
- `prepare_campaign(draft: CampaignDraft) -> CampaignDraft` — free draft (no human gate).
- `publish_campaign(draft, mlro_token: MlroReviewToken) -> PublishedCampaign` — regulated
  send; raises `MlroReviewRequired` for a financial promotion without a valid bound token.
- `list_campaigns() -> tuple[CampaignDraft, ...]` — read-only.
- `abc.ABC` + `InMemoryCampaignPort` (in-memory double) + error hierarchy `CampaignPortError`
  / `CampaignNotFound` / `MlroReviewRequired` / `ProviderUnavailable` (each carries
  `correlation_id`).
- Value types (frozen): `CampaignDraft`, `MlroReviewToken` (campaign-bound `is_valid_for`),
  `PublishedCampaign`; enums `CampaignChannel` (EMAIL / PUSH), `CampaignStatus`
  (DRAFT / PUBLISHED). `Decimal` for every numeric (budget).

### ETAP B — Mask (`services/agents/campaign_agent.py`)
L2 `CampaignAgent` enforcing the ORG §2.8.2 / COBS 4 campaign mask in the fixed ADR-049 §D2
gate-chain order:

    process_ref → scope → confidence-band → cost_cap → compliance → MLRO publish step-up → port

- One ADR-046 `AgentDecisionRecord` per action, emitted on **every** exit path; port and
  `DecisionRecorder` injected as interfaces (pure governance logic, no live infra).
- Drafting is REVIEW-biased (HITL hold in the REVIEW band, proceeds with a reviewer); reads
  are AUTO-only (below-AUTO → `HALT_REVIEW_DEFERRED`); publishing a financial promo is the
  mandatory MLRO step-up.
- compliance non-PASS → BLOCK + escalate→MLRO; `CampaignPortError` → emit(executed=False) +
  reraise (`HALT_PROVIDER_ERROR`); invalid confidence → `ValueError`.
- **R-SEC (ADR-021):** the lineage record carries opaque handles ONLY —
  `campaign_id` / `segment` / `channel`; never the marketing content (subject/body) or
  recipient PII. Content rides on the intent's `CampaignDraft` straight to the port and is
  returned on `AgentOutcome.result`, never recorded (tested).

## Proof
- `banxe-emi-stack` PR #177 — **37 tests, 100% coverage on BOTH new modules**
  (`services/campaign/campaign_port.py` + `services/agents/campaign_agent.py`).
- Tests cover: draft AUTO/REVIEW happy paths, the **mandatory-MLRO-on-publish invariant**
  (publish @ conf=1.0 no token → HALT, publish never called, escalate→MLRO) + publish-with-token
  proceeds + COBS-4-hard (token required even when mask waives it), `HALT_UNRESOLVED_PROCESS`,
  `REJECT_OUT_OF_SCOPE`, `HALT_REVIEW_DEFERRED`, `BLOCK_LOW_CONFIDENCE`, `HALT_COST_CAP_BREACH`
  (per-request + per-window), `HALT_COMPLIANCE_BLOCK` (escalate→MLRO), `HALT_PROVIDER_ERROR`
  (emit + reraise), invalid-confidence `ValueError`, R-SEC (no content/PII in lineage),
  ADR-046 (one record per action).
- `ruff check` + `ruff format --check` clean.
- PR mergeStateStatus **BLOCKED** (required review = R3) → operator authorizes merge
  separately; **NOT** `--admin` self-merged.

## Doc-sync (this PR)
- ORG §2.8 `(PROPOSED)` removed on `CampaignAgent` only (line 313).
- Root ledger anchor `### IL-193` (main raced and took IL-192 — banxe-trading-backend guardian; renumbered to next free, I-28).
- MEMORY sprint-56 block.
- NO new ADR (fits the existing L2 §D2 mask pattern — KYC onboarding / CRM).

## Milestone
Advances audit IL-176 **Tier-3 BUILD** — Churn + Lead + Campaign done; remaining: Incident/HR
+ Tier-4 MLPipeline (I-27). First Tier-3 BUILD with a publish/write surface and a
mandatory-HITL regulatory gate.

## Refs
ADR-049 §D2; ADR-046; ADR-021 (R-SEC); ORG §2.8.2 COBS 4; audit IL-176 (BUILD);
IL-191 LeadScoringAgent; IL-189 ChurnPredictionAgent; `kyc_onboarding_agent` (mandatory-HITL).
