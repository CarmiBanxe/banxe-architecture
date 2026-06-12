# IL-INCIDENT-01: Security IncidentResponseAgent — Tier-3 BUILD (IncidentSignalPort + L2 mask, CRITICAL→CTO+CEO step-up)

- Sprint: 57
- Status: DONE
- Owner: mmber
- Source-of-truth repo: banxe-architecture
- Linked code repo: banxe-emi-stack
- Linked PR: CarmiBanxe/banxe-emi-stack#178 (branch agent/sprint-57/IL-INCIDENT-01)
- Root ledger anchor: IL-196
- Audit ref: docs/audit/ORG-CODE-RECONCILIATION-2026-06-11.md (IL-176, verdict BUILD)
- Created: 2026-06-12

## Context
The ORG↔code reconciliation audit (IL-176) verdicted `IncidentResponseAgent` (ORG §2.7.4
Security & Compliance, **L2**, gate **CTO + CEO for CRITICAL**) as **BUILD** (Tier-3). This is
the **fourth Tier-3 BUILD** of the audit remainder (after IL-189 ChurnPredictionAgent, IL-191
LeadScoringAgent and IL-193 CampaignAgent), and the **second** whose mask carries a hard
mandatory-step-up regulatory invariant — sibling of the L2 masks
`services/agents/campaign_agent.py` (COBS 4 MLRO publish gate) and
`services/agents/kyc_onboarding_agent.py` (mandatory-HITL identity).

**Context / distinction:** there is **no** security/incident bounded context to mask over —
but read-only signal sources already EXIST: `services/observability/*`
(compliance_monitor / health_aggregator / metrics_collector),
`services/device_fingerprint/anomaly_detector`, and `services/ato_prevention/*`
(ato_engine / velocity_checker). `IncidentSignalPort` **derives** incident signals
**read-only** from these (tagged via the `IncidentSource` enum); those domains are **NOT**
modified, imported, or mutated. ORG §2.7.4 implies a real SIEM/pager, but that integration is
a **later sprint** (I-10: no fake integrations now) — this ships the contract + an in-memory
double for unit tests only.

## The regulatory invariant (FCA SYSC 8.1 — enforced in code AND test)
ORG §2.7.4 line 304: *"Security incident CRITICAL: CEO must be notified within 2h (FCA SYSC
8.1)."* — and the escalation matrix line 430: `Security incident CRITICAL | CTO + CEO | 2h | NO`.

A security incident classified **CRITICAL** can **NEVER** be auto-resolved / suppressed /
closed by the agent — it is a **mandatory step-up to CTO + CEO regardless of confidence**:

- Reads (`list_incidents` / `inspect_incident`) and non-critical triage are normal L2.
- A **CRITICAL** triage proceeds **only** with a human (CTO + CEO) reviewer. With no reviewer
  the action **HALTS** (`HALT_CRITICAL_ESCALATION_REQUIRED`), the triage disposition is
  **never committed**, and it **escalates to CTO + CEO** flagged with a **≤2h SLA**
  (`sla_hours = 2`). This holds even at `confidence = 1.0` (AUTO band).
- The CRITICAL step-up is a hard regulatory floor: mask config can only *strengthen* it
  (escalation role / SLA), never disable it — a permissive mask (`auto_threshold = 0`) still
  forces the step-up.
- **Strongest enforcement:** the signal port exposes **no close/resolve/suppress seam at
  all**, so auto-closure is impossible by construction — defence-in-depth alongside the mask
  gate. AI may triage / classify and propose; CRITICAL closure requires a human.

## Delivered
### ETAP A — Port (`services/incident_response/incident_signal_port.py`)
Read-only security-incident triage CONTRACT `IncidentSignalPort` (the boundary the mask
`scope` allow-lists):
- `get_incidents(severity: IncidentSeverity | None = None) -> tuple[IncidentSignal, ...]` —
  read, optional severity filter.
- `get_incident(incident_id: str) -> IncidentSignal` — read; raises `IncidentNotFound`.
- `classify_severity(signal_score: int) -> IncidentSeverity` — pure read-only triage helper
  (score-banded like `fraud_port`: <40 LOW / 40–69 MEDIUM / 70–84 HIGH / ≥85 CRITICAL).
- **READ + classify only** — there is intentionally NO close/resolve/suppress method.
- `abc.ABC` + `InMemoryIncidentSignalPort` (in-memory double, with a transient-failure
  switch) + error hierarchy `IncidentSignalPortError` / `IncidentNotFound` /
  `SignalSourceUnavailable` (each carries `correlation_id`).
- Frozen value type `IncidentSignal`; enums `IncidentSeverity` (LOW / MEDIUM / HIGH /
  **CRITICAL**), `IncidentStatus` (open / triaged / escalated / closed), `IncidentSource`
  (the six read-only derivation sources).

### ETAP B — Mask (`services/agents/incident_response_agent.py`)
L2 `IncidentResponseAgent` enforcing the ORG §2.7.4 / SYSC 8.1 incident mask in the fixed
ADR-049 §D2 gate-chain order:

    process_ref → scope → confidence-band → cost_cap → compliance → CRITICAL CTO+CEO step-up → port

- One ADR-046 `AgentDecisionRecord` per action, emitted on **every** exit path; port and
  `DecisionRecorder` injected as interfaces (pure governance logic, no live infra).
- Reads (list / inspect) are AUTO-only (below-AUTO → `HALT_REVIEW_DEFERRED`); non-critical
  triage is REVIEW-biased (HITL hold in the REVIEW band, proceeds with a reviewer); a CRITICAL
  triage is the mandatory CTO + CEO step-up.
- compliance non-PASS → BLOCK + escalate→CTO+CEO; `IncidentSignalPortError` →
  emit(executed=False) + reraise (`HALT_PROVIDER_ERROR`); invalid confidence → `ValueError`.
- **R-SEC (ADR-021):** the lineage record carries opaque metadata ONLY — `incident_id` and the
  derived `severity` / `source`; never raw security payloads, log lines, credentials, or PII.
  The `IncidentSignal` rides on `AgentOutcome.result` only, never recorded (tested).

### Shared primitive (additive, non-breaking)
`services/agents/_lineage.py` — `AgentOutcome` gains an additive `sla_hours: int | None = None`
field to surface the FCA SYSC 8.1 2h CRITICAL notification SLA. Defaults `None`; other masks
do not set it and are unaffected (full `tests/agents/` suite green — no regression).

## Proof
- `banxe-emi-stack` PR #178 — **39 tests, 100% coverage on BOTH new modules**
  (`services/incident_response/incident_signal_port.py` + `services/agents/incident_response_agent.py`).
- Tests cover: AUTO reads (list/inspect) + severity-filter labelling, non-critical triage
  AUTO + REVIEW (hold then proceed), the **CRITICAL-escalation invariant** (critical @ conf=1.0,
  no reviewer → `HALT_CRITICAL_ESCALATION_REQUIRED`, escalate→CTO+CEO, `sla_hours=2`,
  disposition never committed / incident left OPEN) + critical-with-reviewer proceeds + the
  config-floor test (permissive mask cannot waive the step-up) + critical low-confidence
  BLOCK-with-SLA, `HALT_UNRESOLVED_PROCESS`, `REJECT_OUT_OF_SCOPE` (auto-close refused),
  `HALT_REVIEW_DEFERRED`, `BLOCK_LOW_CONFIDENCE` (critical + non-critical),
  `HALT_COST_CAP_BREACH` (per-request + per-window), `HALT_COMPLIANCE_BLOCK` (escalate→CTO+CEO),
  `HALT_PROVIDER_ERROR` (emit + reraise), invalid-confidence `ValueError`, R-SEC (no raw
  data/PII in lineage), ADR-046 (one record per action).
- `ruff check` + `ruff format --check` clean.
- PR mergeStateStatus **BLOCKED** (required review = R3) → operator authorizes merge
  separately; **NOT** `--admin` self-merged.

## Doc-sync (this PR)
- ORG §2.7.4 `(PROPOSED)` removed on `IncidentResponseAgent` only (line 302).
- Root ledger anchor `### IL-196` (main raced twice and took IL-193 Campaign + IL-194 backend
  skeleton + IL-195 FE↔backend WS order-book — expected IL-193 renumbered to next free IL-196,
  append-only union, I-28).
- MEMORY sprint-57 block.
- NO new ADR (fits the existing L2 §D2 mandatory-escalation mask pattern — Campaign / KYC).

## Milestone
Advances audit IL-176 **Tier-3 BUILD** — Churn + Lead + Campaign + Incident done; remaining:
**HR** + Tier-4 MLPipeline (I-27). Second Tier-3 BUILD with a mandatory-step-up regulatory gate
(after Campaign's COBS 4 MLRO publish gate).

## Refs
ADR-049 §D2; ADR-046; ADR-021 (R-SEC); ORG §2.7.4 FCA SYSC 8.1; audit IL-176 (BUILD);
IL-193 CampaignAgent (mandatory-step-up sibling); IL-191 LeadScoringAgent;
IL-189 ChurnPredictionAgent; `kyc_onboarding_agent` (mandatory-HITL pattern).
