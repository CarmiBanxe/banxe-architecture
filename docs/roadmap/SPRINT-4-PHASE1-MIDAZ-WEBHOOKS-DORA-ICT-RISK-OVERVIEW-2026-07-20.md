# Sprint 4 — ICT / Webhooks / DORA Risk Overview

**PHASE-1 ROADMAP / PLANNING-ONLY / FIRST MATERIALISATION / NO LEGAL STATUS**

## Purpose & role

Sprint 4 is the ICT / webhooks / DORA / operational-risk line of Phase 1. It frames the event, integration, and third-party-dependency perimeter that sits behind the products of Sprint 3 and beneath the payment behaviours of Sprint 5: where Sprint 3 asks "is the product ready" and Sprint 5 asks "does the payment keep moving — or stop safely — under failure", Sprint 4 asks "do the event flows, dispatch controls, and incident paths that carry those signals hold together". It aligns with the Floor-2 execution line (S-A5 identity, S-A6 ledger/EMI, S-A7 web/gateway) by referencing the identity/ledger/gateway facts those lanes produce — it does not re-derive or replace their install-audits.

## Existing artefacts

This overview is a navigation layer above the following verified artefacts; details live there, not here.

- `docs/sprints/sprint-4-webhook-event-lifecycle.md` — webhook/event lifecycle template (dispatch, retry, DLQ, signing patterns).
- `docs/sprints/sprint-4-dora-ict-risk-framework.md` — DORA-style ICT risk & incident framework.
- `docs/sprints/sprint-4-third-party-roi-skeleton.md` — third-party / Register-of-Information skeleton.
- `docs/briefs/WEBHOOK-ICT-CONTROLS-OPERATOR-MEMO.md` — operator memo: what is documented vs what remains open on webhook/ICT controls.
- `docs/roadmap/ERROR-RECONCILIATION-ROADMAP-2026-07-01.md` — reconciliation backbone for event-completion and failure handling.
- `docs/roadmap/S-A5-EXECUTION-PLAN-A-IDV-KYC-KYB-2026-07-19.md` · `S-A6-EXECUTION-PLAN-D-GL-B-EMI-2026-07-19.md` · `S-A7-EXECUTION-PLAN-M-GATEWAY-BIF-WEB-2026-07-19.md` — Floor-2 execution plans supplying identity / ledger / gateway facts.

## ICT / webhooks / DORA perimeter

High-level surfaces; each tagged with what it touches (payments resilience / identity-ledger-gateway / DORA-ICT framing — no legal conclusions).

- Event/webhook entry and dispatch paths — touches payments resilience (payment events drive downstream flows); DORA-ICT framing for delivery integrity.
- Retry / DLQ / replay patterns at event level — touches payments resilience (shared retry/DLQ inputs with Sprint 5); DORA-ICT framing for bounded recovery.
- Incident detection and routing surfaces — touches identity/ledger/gateway (failures surface across all three); DORA-ICT framing for incident classification.
- Third-party provider integration points — touches gateway surfaces (provider calls at the edge); DORA-ICT framing for concentration/Register-of-Information.
- Monitoring / logging / correlation for ICT events — touches gateway (correlation_id propagation); DORA-ICT framing for observability. correlation_id supports technical fault tracing but is not alone sufficient for regulatory decision traceability [counsel]; decision-layer fields sit above it.

## Failure / incident themes at ICT layer

Themes only; no implementation detail.

- Event delivery failure and backlog.
- Mis-routed or duplicate events.
- Provider / API outages on webhook endpoints.
- Monitoring blind spots and delayed detection.
- Manual / human intervention hooks in event chains.
- Escalation paths from ICT incidents into HITL / ops structures.

## Dependencies on other lines

- **Sprint 3 (products):** events are sourced from product actions; every product domain emits into this perimeter.
- **Sprint 5 (payments resilience):** events drive payment retries, fallbacks, and controlled stops; retry/DLQ/incident patterns here are shared inputs.
- **S-A5 (identity), S-A6 (ledger/EMI), S-A7 (gateway/web):** underlying layers whose facts this overview references, not redefines.
- **Existing incident / ops escalation structures:** where an ICT incident exceeds automated handling, it becomes a human-governed event through the established HITL and ops escalation paths.

## Evidence posture

- The existing Sprint-4 sprint docs and the WEBHOOK-ICT operator memo define patterns and expectations (dispatch controls, ICT risk framework, third-party/RoI skeleton).
- Full operational resilience is NOT proven by this overview; it orients the perimeter and points at where evidence must land.
- Install-audits, incident logs, runbooks, and failure simulations must bind back to this overview and to the Floor-2 execution artefacts (by anchor or check reference) to build the evidence picture.

## What this overview does not do

- Does not prove DORA/ICT compliance or operational resilience.
- Does not create legal classification; all such characterisations remain [counsel].
- Does not replace install-audits, runbooks, or execution evidence.
- Does not change ADRs, registers, or roadmap master files.

## Next documentation steps

- Identify where ICT/webhook behaviours must be captured in install-audits or runbooks (e.g. the M-GATEWAY-WEB install-audit's replay/retry/DLQ and incident checks).
- Define incident classes and bind them to the Sprint-4 perimeter and to payment-failure scenarios.
- Link third-party / provider dependency registers to Sprint-4 themes, building on the third-party/RoI skeleton.
- Plan future evidence artefacts (S2/R2 or similar) that will attach to this overview as the execution layer advances.
