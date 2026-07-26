# Sprint 8 — Consent, DPO and GDPR Governance Overview

**PHASE-1 ROADMAP / GOVERNANCE / FIRST MATERIALISATION / NO LEGAL STATUS**

## Purpose & role

- Sprint 8 defines how consent and GDPR-relevant decisions are governed in Phase 1.
- It connects the identity-room, consentagent, the DPO role, and the Sprint-7 risk lanes into one governance map.
- It is a governance map for consent, not a legal opinion; DPO appointment and the lawful-basis model are [counsel]/Board decisions.

## Existing artefacts consumed

Sprint 8 wraps the following verified artefacts; it does not replace them.

- Identity-room kit and consentagent notes (front boundary of identity).
- `docs/roadmap/SPRINT-3-PHASE1-NEW-PRODUCTS-OVERVIEW-2026-07-20.md` · `SPRINT-4-...`, `SPRINT-5-...`, `SPRINT-6-...`, `SPRINT-7-PHASE1-AI-GOVERNANCE-AGENTIC-DOMAINS-AND-RISK-LANES-OVERVIEW-2026-07-20.md`.
- `docs/roadmap/S-A5-EXECUTION-PLAN-A-IDV-KYC-KYB-2026-07-19.md` and the `A-IDV-INSTALL-AUDIT-2026-07-20.md` · `A-KYC-INSTALL-AUDIT-2026-07-20.md` · `A-KYB-INSTALL-AUDIT-2026-07-20.md`.
- `docs/briefs/HIGH-RISK-AI-REGISTER-OPERATOR-MEMO.md`.
- `docs/briefs/CRO-CTO-IDV-KYB-TRACEABILITY-MEMO.md`.
- External-consultant brief section on consent/DPO/GDPR (problem area 5): consentagent in the identity-room linked to GDPR; DPO vacancy with interim CEO line; open questions on lawful-basis, logging, retention, explainability, and accountability mapping.

## Consent domain and flows

- Consent decisions live in the identity-room, at the front boundary of the bank — consent and identity are a first-class perimeter, not an afterthought.
- Main flow types: onboarding consent, marketing consent, profiling consent, data-sharing consent.
- Each flow links conceptually to a lawful basis and to data-subject rights (subject access, erasure, objection); the actual lawful-basis model and rights handling are [counsel].
- Governance must sit at the point where a consent state is set, changed, or relied upon by a downstream decision — that is where logging and HITL attach.

## DPO role and interim governance

- **Target state:** a formally appointed DPO owning lawful-basis oversight, data-subject-rights handling, and GDPR accountability.
- **Current interim arrangement:** DPO vacant; CEO in the accountability line; Compliance/Ops providing support. This is a stated interim, not a target.
- **Decision split:** decisions that fix or change lawful basis, approve new profiling, or sign off GDPR posture should wait for a formal DPO appointment; routine consent capture and existing-basis operation can proceed under interim governance with logging.
- Appointment timing and the sufficiency of the interim arrangement are [counsel] topics; not resolved here.

## AI agents in consent & identity

Consistent with the Sprint-7 domains/lanes.

- consentagent and related identity assistants sit in the **Identity and onboarding** domain, **high-risk-by-policy** lane.
- Allowed autonomy: proposal-only for anything affecting rights, lawful basis, or profiling — agents propose, humans decide.
- HITL gates apply at: setting/withdrawing a lawful basis, any material profiling change, and any consent reclassification that changes what downstream systems may do with the data.

## Logging, retention and explainability expectations

Phase-1, high-level; conceptual link to the traceability memo, no regulation quoted.

- **Log for each consent decision:** who (subject + initiator), what (consent type and scope), when (timestamp), basis (declared lawful basis), and change (prior→new state on any update).
- **Retention:** consent records retained for a period appropriate to the basis and downstream reliance (conceptual, not dated); records are not silently discarded.
- **Explainability for AI-assisted consent decisions:** a reviewer must be able to see the initiator, the input data used, the outcome, and any override — correlation_id alone is not sufficient (decision-trace, per the traceability memo).

## Ownership and accountability mapping

- **Compliance Officer:** operational GDPR/consent oversight in the interim.
- **DPO (target):** accountable owner once appointed; interim responsibilities held in the CEO line with Compliance/Ops support.
- **Ops:** execution and record-keeping of consent flows.
- **CEO:** interim accountability holder until DPO appointment.
- Canonical consent documentation is held in the identity-room; the room migration must make the accountable owner for each consent artefact unambiguous.

## Guardrails

- **Human-only decisions:** withdrawal or change of a lawful basis; major profiling changes; GDPR-posture sign-off.
- **AI may propose, not decide:** drafting consent language, flagging inconsistent consent states, suggesting reclassification for human review.
- **Agent constraints:** no silent reclassification of consent; no hidden profiling; no reliance on a consent state without a logged basis.

## Relationship to future execution and migration sprints

- Feeds the identity-room documentation migration into `bank-rooms/` — consent artefacts and their owners land there.
- Informs future install-audits for identity/consent — the logging, retention, and decision-trace expectations become audit checks.
- Interacts with factory self-repair by fencing consent flows: no "free" or incidental changes to consent behaviour; any change routes through governed sprints.

## What this overview does not do

- Does not appoint a DPO or define lawful basis.
- Does not prove GDPR compliance.
- Does not authorise new consent-related automation.
- Does not change existing legal positions or High-Risk Map entries — all such matters remain [counsel].
