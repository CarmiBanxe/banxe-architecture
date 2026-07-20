# S-GATE-REPAIR Execution Plan — Unified Gateway/Auth Perimeter for Ledger and Payments

**FLOOR-2 / REPAIR-PLANNING / GATEWAY-AUTH / NO LEGAL STATUS**

## Purpose

S-GATE-REPAIR exists to close a structural gap surfaced by the I-API install-audit: payment and ledger routes are not consistently protected by a single gateway / auth / rate-limiting perimeter. It translates the I-API install-audit and FACTORY-FULL-AUDIT findings into a repair roadmap for a unified protection perimeter.

This is design, not direct code change. No code moves and no infra changes in this plan; it defines what a correct perimeter must do, in what order it should be built, and what evidence must later prove it — all under audit-first discipline.

## Inputs

This plan must align with, and consumes, the following:

- `I-API-INSTALL-AUDIT-2026-07-20.md` — gateway/auth findings (orphan gateway, partial auth coverage, login-only rate limiting, unprotected payments/ledger paths).
- S-A8 reconciliation artefact — M-GATEWAY (productisation wrapper) vs I-API (runtime gateway) perimeter discussion; "no second gateway".
- FACTORY-FULL-AUDIT top-5 repair candidates — where the gateway/auth perimeter appears as a structural defect.
- `docs/roadmap/S-A5-EXECUTION-PLAN-A-IDV-KYC-KYB-2026-07-19.md` · `S-A6-EXECUTION-PLAN-D-GL-B-EMI-2026-07-19.md` · `S-A7-EXECUTION-PLAN-M-GATEWAY-BIF-WEB-2026-07-19.md` — identity, ledger/EMI, gateway/web lanes.
- `docs/roadmap/SPRINT-3-PHASE1-NEW-PRODUCTS-OVERVIEW-2026-07-20.md` · `SPRINT-4-PHASE1-MIDAZ-WEBHOOKS-DORA-ICT-RISK-OVERVIEW-2026-07-20.md` · `SPRINT-5-PHASE1-PAYMENTS-RESILIENCE-OVERVIEW-2026-07-20.md` — product / ICT / payments-resilience perimeter.

## Problem statement (as-is)

Stated as structural facts from the audit, no blame:

- Multiple gateway/auth mechanisms that do not form a single protection perimeter.
- Orphan gateway code (`src/api/gateway.py`) with tests but no wiring into the live app.
- Key-management self-service (`services/api_gateway/`) that is not a full request-fronting gateway.
- Partial auth coverage — `api/deps.py::require_auth` / Keycloak attached to only a subset of routers.
- Rate limiting (Redis-based) applied only to login, not to critical payment/ledger routes.
- Payment and ledger routes show no visible dependency on the auth layer inside this repo — no explicit "who are you and may you touch money/balances" check along their path.
- Presence and behaviour of an external reverse-proxy / ingress gate are currently unknown and must be confirmed before severity is finalised.

## Target perimeter (to-be)

Behaviour and responsibilities only; no code.

One clearly defined gateway / auth / rate-limiting perimeter that:

- Fronts all payment-related and ledger-related routes.
- Ensures identity, permissions, and limits are checked before any value-bearing action.
- Applies rate limiting and logging consistently across critical routes, not only login.
- Integrates with the existing identity lane (S-A5) and ledger lane (S-A6) rather than re-implementing them.
- Respects MCP/Midaz and AI-agent control surfaces, so agents pass through the same perimeter as any other caller.

## Design principles

- Every step of a money/ledger path must be guarded, not just login.
- Identity and permissions checks must be consistent for all critical routes.
- Gateway/auth logic should be centralised, not re-implemented per router.
- An external reverse-proxy may be part of the perimeter, but its behaviour must be explicit and audited, never assumed.
- Rate limiting is part of resilience and protection, not only login hardening.
- AI agents may not bypass the perimeter.

## Repair workstreams

**WS1 — Wiring discovery**
- Goal: confirm how traffic actually reaches payments/ledger, internally and via any external gate.
- Inputs: I-API install-audit, infra/docker-compose, route inventory.
- Outputs: traffic-path map (internal ports + external gate presence/behaviour verdict).
- Owners: execution-audit role, project-coordination role.

**WS2 — Unified gateway design**
- Goal: design how `gateway.py`, the `api_gateway` service, `require_auth`, and the rate limiter become one coherent perimeter (no second gateway).
- Inputs: WS1 map, S-A7 topology, S-A8 reconciliation.
- Outputs: perimeter design note (responsibilities, single front door, integration seams to S-A5/S-A6).
- Owners: central project brain (design authority), gateway/web role.

**WS3 — Coverage expansion**
- Goal: plan bringing all payments/ledger routes under the unified perimeter.
- Inputs: route inventory, WS2 design.
- Outputs: route→perimeter coverage plan (per route group, current vs target).
- Owners: execution-audit role, product/perimeter role.

**WS4 — External gate coordination**
- Goal: plan how a reverse-proxy/ingress (if present) participates in protection without becoming an unaudited shadow gate.
- Inputs: WS1 external-gate verdict, infra config.
- Outputs: external-gate coordination note (what it guards, what remains for the app perimeter).
- Owners: gateway/web role, project-coordination role.

**WS5 — Evidence and audit binding**
- Goal: plan how future install-audits will prove the perimeter actually guards every critical route.
- Inputs: WS2–WS4 outputs, M-GATEWAY-WEB and LEDGER-EMI install-audit shells.
- Outputs: updated install-audit check set + evidence-binding scheme (Finding ID references).
- Owners: execution-audit role, reconciliation/evidence role.

## Constraints and guardrails

- No breaking existing products without a migration plan.
- Audit-first: perimeter design and wiring must be auditable at every step.
- No silent introduction of new shadow gateways or auth layers.
- No agent may gain direct access to payments/ledger routes outside the documented perimeter.
- Legal classification remains [counsel]; technical repair must not pretend to solve regulatory compliance on its own.

## Sequence of actions

1. Complete external-gate discovery (docker-compose, infra), read-only.
2. Confirm the actual path of payments/ledger traffic (diagrams, logs).
3. Design the unified gateway/auth/rate-limiting perimeter for critical routes.
4. Map current routes to the target perimeter (coverage plan).
5. Design migration steps per route group, without executing them.
6. Design updated install-audit checks for the gateway/auth perimeter.
7. Propose per-lane execution sprints (identity, ledger, gateway) to implement the design later, each audit-first.

## Relationship to factory self-repair

- This plan is a major repair line within FACTORY-FULL-AUDIT: the gateway/auth perimeter is the highest-severity structural defect and anchors the repair backlog.
- The factory will use it to self-improve orchestration, logging, and guardrails — routing perimeter work through controlled repair sprints rather than ad-hoc patches.
- The central project brain owns the design decisions (target perimeter, principles, sequencing); the factory applies them in controlled repair sprints, each producing auditable evidence.

## What this plan does not do

- Does not touch code or infra directly.
- Does not assert that the current perimeter is safe.
- Does not guarantee compliance or resilience.
- Does not merge [operator] and [counsel] responsibilities.
- Does not activate autonomous agents on critical routes beyond existing controls.
