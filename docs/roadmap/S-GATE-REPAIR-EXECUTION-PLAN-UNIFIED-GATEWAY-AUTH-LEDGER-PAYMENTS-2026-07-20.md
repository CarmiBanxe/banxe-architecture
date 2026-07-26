# S-GATE-REPAIR Execution Plan — Unified Gateway/Auth Perimeter for Ledger and Payments

**FLOOR-2 / REPAIR-PLANNING / GATEWAY-AUTH / NO LEGAL STATUS**

## Purpose

- S-GATE-REPAIR exists to close the structural gap where payments and ledger routes are not consistently protected by a single gateway / auth / rate-limiting perimeter.
- It translates the I-API install-audit, the FACTORY-FULL-AUDIT repair candidates, and the external-consultant brief constraints into a repair roadmap.
- It is design, not direct code change; the factory will later self-repair against this plan, under the project brain's design authority.

## Inputs

S-GATE-REPAIR must align with all of the following:

- `I-API-INSTALL-AUDIT-2026-07-20.md` — gateway/auth findings.
- S-A8 reconciliation artefact — M-GATEWAY vs I-API, "no second gateway".
- FACTORY-FULL-AUDIT top-5 repair candidates — gateway/auth perimeter as the highest-severity structural defect.
- `docs/roadmap/S-A5-EXECUTION-PLAN-A-IDV-KYC-KYB-2026-07-19.md` · `S-A6-EXECUTION-PLAN-D-GL-B-EMI-2026-07-19.md` · `S-A7-EXECUTION-PLAN-M-GATEWAY-BIF-WEB-2026-07-19.md`.
- `docs/roadmap/SPRINT-3-PHASE1-NEW-PRODUCTS-OVERVIEW-2026-07-20.md` · `SPRINT-4-PHASE1-MIDAZ-WEBHOOKS-DORA-ICT-RISK-OVERVIEW-2026-07-20.md` · `SPRINT-5-PHASE1-PAYMENTS-RESILIENCE-OVERVIEW-2026-07-20.md`.
- `docs/briefs/FLOOR2-A-CHAIN-CONTEXT-FOR-CONSULTANTS.md`.
- External-consultant brief positions (canon constraints, consumed not re-argued):
  - IDV/KYC High-Risk Map — "non-Annex-III, high-risk internally by policy"; counsel owns the Annex III classification.
  - KYB + merchant acquiring — one joint regulatory perimeter where KYB gates activation.
  - correlation_id — sufficient for technical fault tracing, not sufficient alone for regulatory decision traceability (needs initiator, input data, decision outcome, override trail).

## Problem statement (as-is)

Structural facts from the audit and brief, no blame:

- Fragmented gateway/auth mechanisms with no single perimeter.
- Orphan gateway layer (`src/api/gateway.py`) with tests but no wiring.
- Key-management service (`services/api_gateway/`) that is not a full request-fronting gateway.
- Partial auth coverage (`api/deps.py::require_auth` / Keycloak on a subset of routers); many routes unguarded.
- Rate limiting (Redis) only on login.
- Payments/ledger routes unprotected in this repo (no visible auth dependency along their path).
- External gate (reverse-proxy/ingress) presence/behaviour unknown.
- KYB decisions gate merchant acquiring, but no unified perimeter around those joint product paths.
- correlation_id present, but no full decision-trace fields attached to value-bearing routes.

## Target perimeter (to-be)

Behaviour and responsibilities only; no code.

One clearly defined gateway / auth / rate-limiting perimeter that:

- Fronts all payment-related and ledger-related routes.
- Enforces identity, permissions, and limits before any value-bearing action.
- Applies rate limiting and logging consistently across critical routes.
- Integrates with the S-A5 identity lane and the S-A6 ledger lane rather than re-implementing them.
- Respects MCP/Midaz and AI-agent control surfaces, so agents pass through the same perimeter.
- Supports correlation_id plus decision-trace fields (initiator, input data, decision outcome, override trail) for regulated decisions.

## Design principles

- Every step of a money/ledger path must be guarded, not just login.
- Identity/KYC/KYB checks are high-risk by internal policy and must not be bypassed.
- KYB + merchant acquiring must be treated as a joint perimeter.
- Gateway/auth logic should be centralised, not re-implemented per router.
- An external reverse-proxy can be part of the perimeter but must be explicit and auditable.
- Rate limiting is part of resilience and protection for critical routes, not only login hardening.
- AI agents may not bypass the perimeter.
- correlation_id is for technical fault tracing; decision traceability needs richer fields.

## Repair workstreams

**WS1 — Wiring discovery**
- Goal: confirm actual traffic paths to payments/ledger (internal and external), including where KYB/merchant flows enter.
- Inputs: I-API audit, infra/docker-compose, route inventory, FLOOR2-A-CHAIN context.
- Outputs: traffic-path map + external-gate verdict.
- Owners: execution-audit role, project-coordination role.

**WS2 — Unified gateway design**
- Goal: design a single front-door perimeter (no second gateway) combining `gateway.py`, `api_gateway`, `require_auth`, the rate limiter, and the external gate if present.
- Inputs: WS1 map, S-A7 topology, S-A8 reconciliation, consultant positions.
- Outputs: perimeter design note (responsibilities, single front door, integration seams to S-A5/S-A6, decision-trace requirements).
- Owners: project brain (design authority), gateway/web role.

**WS3 — Coverage expansion**
- Goal: plan bringing all payments/ledger and KYB+merchant routes under the perimeter.
- Inputs: route inventory, WS2 design.
- Outputs: coverage plan per route group (with KYB+merchant groups called out explicitly).
- Owners: execution-audit role, product/perimeter role.

**WS4 — External gate coordination**
- Goal: plan how reverse-proxy/ingress participates in protection without becoming an unaudited shadow gate.
- Inputs: WS1 external-gate verdict, infra configs.
- Outputs: coordination note (what it guards, what remains for the app perimeter).
- Owners: gateway/web role, project-coordination role.

**WS5 — Evidence and audit binding**
- Goal: define future install-audit checks and evidence-binding for the new perimeter, including correlation_id + decision-trace fields.
- Inputs: WS2–WS4, M-GATEWAY-WEB and LEDGER-EMI install-audits, High-Risk Map.
- Outputs: updated checklists + binding scheme (Finding IDs).
- Owners: execution-audit role, reconciliation/evidence role.

## Constraints and guardrails

- No product-breaking changes without a migration plan.
- Audit-first at every step.
- No new shadow gateways or auth layers.
- No agent access to critical routes outside the documented perimeter.
- IDV/KYC treated as high-risk internally by policy; counsel owns the Annex III stance.
- KYB + merchant acquiring assessed together as one perimeter.
- correlation_id not equated to full regulatory traceability.
- Legal classification and permissions remain [counsel]; [operator] and [counsel] stay separate.

## Sequence of actions

1. Complete external-gate discovery (docker-compose, infra), read-only.
2. Confirm the actual path of payments/ledger and KYB/merchant traffic (diagrams, logs).
3. Confirm or create High-Risk Map entries for IDV/KYC ("non-Annex-III, high-risk internally by policy"; counsel owns the classification).
4. Design the unified gateway/auth/rate-limiting perimeter for critical routes, including decision-trace logging fields (initiator, inputs, decision, override) for value-bearing routes.
5. Map current routes to the target perimeter, explicitly identifying KYB+merchant route groups in the coverage plan.
6. Design migration steps per route group, without executing them.
7. Design updated install-audit checks for the gateway/auth perimeter, including decision-trace coverage.
8. Propose per-lane execution sprints (identity, ledger, gateway) to implement the design later, each audit-first.

## Relationship to factory self-repair

- S-GATE-REPAIR is a major repair line within FACTORY-FULL-AUDIT: the gateway/auth perimeter is the highest-severity structural defect and anchors the repair backlog.
- The factory uses it to orchestrate self-repair sprints (orchestration, logging, guardrails) rather than ad-hoc patches; the project brain owns the design decisions.
- Install-audits will later prove the perimeter's behaviour, binding evidence back by Finding ID.

## What this plan does not do

- Does not touch code or infra directly.
- Does not assert that the current perimeter is safe, nor guarantee compliance or resilience.
- Does not merge [operator] and [counsel] responsibilities.
- Does not activate autonomous agents on critical routes beyond existing controls.
