# Sprint 7 — AI Governance, Agentic Domains and Risk Lanes Overview

**PHASE-1 ROADMAP / GOVERNANCE / FIRST MATERIALISATION / NO LEGAL STATUS**

## Purpose & role

- Sprint 7 defines how agentic AI is governed across the bank in Phase 1.
- It connects agent roles, domains, and risk lanes to the existing operating model (Sprint 3–6 overviews, S-GATE-REPAIR, Floor-2 lanes).
- It is a map for governance and risk, not a compliance verdict; [counsel] owns all legal classification.

## Existing artefacts consumed

Sprint 7 is a wrapper above the following verified artefacts; details live there.

- `docs/roadmap/SPRINT-3-PHASE1-NEW-PRODUCTS-OVERVIEW-2026-07-20.md` · `SPRINT-4-PHASE1-MIDAZ-WEBHOOKS-DORA-ICT-RISK-OVERVIEW-2026-07-20.md` · `SPRINT-5-PHASE1-PAYMENTS-RESILIENCE-OVERVIEW-2026-07-20.md` · `SPRINT-6-PHASE1-AI-AGENT-ROLE-ROUTING-AND-CODE-LIFT-OVERVIEW-2026-07-20.md`.
- `docs/roadmap/S-GATE-REPAIR-EXECUTION-PLAN-UNIFIED-GATEWAY-AUTH-LEDGER-PAYMENTS-2026-07-20.md`.
- `docs/roadmap/S-A5-EXECUTION-PLAN-A-IDV-KYC-KYB-2026-07-19.md` · `S-A6-EXECUTION-PLAN-D-GL-B-EMI-2026-07-19.md` · `S-A7-EXECUTION-PLAN-M-GATEWAY-BIF-WEB-2026-07-19.md` and the A-IDV/A-KYC/A-KYB, LEDGER-EMI, M-GATEWAY-WEB install-audits.
- `docs/briefs/FLOOR2-A-CHAIN-CONTEXT-FOR-CONSULTANTS.md`.
- `docs/briefs/HIGH-RISK-AI-REGISTER-OPERATOR-MEMO.md`.
- `docs/briefs/CRO-CTO-IDV-KYB-TRACEABILITY-MEMO.md`.
- External-consultant brief positions: IDV/KYC "non-Annex-III, high-risk internally by policy"; KYB + merchant acquiring as a joint perimeter; correlation_id as technical fault-trace only, with separate decision-trace needs.

## Agentic domains

High-level domains; for each: agent type, tied lane, internal-policy risk stance.

- **Identity and onboarding** — verification/screening assistants (proposal-only). Lane: S-A5 / A-IDV/A-KYC/A-KYB. High-risk by internal policy [counsel].
- **Products and origination** — product-eligibility and origination assistants. Lane: Sprint 3. High-risk by policy where KYB gates merchant acquiring (joint perimeter); otherwise medium.
- **Ledger and safeguarding** — posting/reconciliation assistants. Lane: S-A6 / LEDGER-EMI. High-risk by internal policy (value-bearing).
- **Payments and treasury** — payment routing/resilience assistants. Lane: Sprint 5 / S-A7 / S-GATE-REPAIR. High-risk by internal policy (value-bearing).
- **Webhooks / ICT / incidents** — event-dispatch and incident-triage assistants. Lane: Sprint 4. Medium, escalating to high on ledger/payment-impacting incidents.
- **Tax / reporting** — reporting and reconciliation-cycle assistants. Lane: Sprint-5-tagged reporting materials. Medium, high where figures feed regulated submissions [counsel].
- **Factory / self-repair** — orchestration and repair assistants. Lane: Sprint 6 / FACTORY-FULL-AUDIT. Medium; high when touching critical-route code (routed via S-GATE-REPAIR).

## Risk lanes

Four-lane model; for each: what goes there, governance/HITL, correlation_id vs decision-trace.

- **Low-risk / efficiency** — internal tooling, drafting, indexing. Governance: light; L1 auto acceptable. Trace: correlation_id sufficient.
- **Medium-risk / augmentation** — analysis and proposals feeding human decisions (products, ICT, reporting). Governance: L2 alert-to-human. Trace: correlation_id plus outcome logging.
- **High-risk-by-policy** — IDV/KYC/KYB, gateway/auth, payments, ledger. Governance: L3 auto-up-to-gate with mandatory HITL at value-bearing/decision points; agents propose, humans decide. Trace: correlation_id is not sufficient — full decision-trace required (initiator, input data, decision outcome, override trail).
- **Counsel-only / legal classification** — Annex III stance, EMI/PSD2/DORA characterisation, High-Risk Map legal entries. Governance: L4 human-only; no agent output. Trace: n/a (not an agent lane).

## Mapping canon to external frameworks

Conceptual and non-binding; [counsel] owns actual classification.

- Internal "high-risk by policy" (identity, ledger, payments, gateway) maps conceptually toward AI Act high-risk categories, but the Annex III determination is a [counsel] act, not asserted here.
- The gateway/auth/ledger/payments perimeter (S-GATE-REPAIR, S-A6/S-A7) relates conceptually to DORA operational-resilience and PSD2 protection expectations; sufficiency is [counsel].
- Agentic-domain structure aligns conceptually with common AI-governance framework elements — model/agent inventory, risk tiering, autonomy levels — without claiming conformity to any named standard.

## Ownership and roles

Governance-level reuse of the Sprint-6 role model (roles, not names).

- **Domain ownership:** each agentic domain has an accountable business/tech owner (e.g. identity → identity lane owner; ledger/payments → treasury/ledger owner; ICT → CTO/ops; factory → project brain).
- **Risk-lane ownership:** a risk owner (CRO-aligned) owns lane definitions and lane transitions.
- **High-risk deployment approval:** agent deployment in high-risk-by-policy domains requires named human approval (supervisor/routing role + domain owner + risk owner).
- **High-Risk Map and decision-trace:** maintained by the operator/CRO-CTO owners per the traceability memo; legal entries remain [counsel].

## Guardrails for agents

- Autonomy limits per lane: low → auto; medium → act-and-alert; high-risk-by-policy → pause and escalate at any value-bearing or identity decision; counsel-only → no agent action.
- Prohibited in high-risk-by-policy domains: bypassing the gateway/auth perimeter; direct ledger/gateway access outside documented control surfaces; auto-approving KYB/merchant activation; producing legal classification.
- Production requirements: consistent logging (correlation_id) plus decision-trace fields for high-risk lanes; evaluation and monitoring of agent outputs; escalation wiring into HITL/incident structures.

## Relationship to future execution sprints

- Feeds repair sprints (e.g. S-GATE-REPAIR) by fixing which domains/lanes a repair must protect.
- Feeds install-audit expansions by defining the decision-trace and HITL checks each lane's audit must include.
- Feeds product-domain sprints by tagging each product's agentic domain and risk lane before build.
- Feeds factory self-repair sprints by setting autonomy limits and guardrails the factory must operate within.

## What this overview does not do

- Does not prove compliance or resilience.
- Does not assign legal status — all classification remains [counsel].
- Does not authorise new agent autonomy.
- Does not change the existing High-Risk Map or any legal positions.
