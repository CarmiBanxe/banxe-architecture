# ADR-LCY-01: Customer Lifecycle FSM — State Machine for Customer Onboarding and Offboarding

## Status
Accepted

## Context
FCA MLR 2017 and PS22/9 (Consumer Duty) require EMI firms to maintain a clear and
auditable record of each customer's lifecycle status and to ensure that critical
transitions — particularly onboarding (KYC completion, risk classification) and
offboarding (account closure, fund return) — involve human review before taking
effect. Without an explicit FSM, transition logic is scattered across services,
making compliance evidence collection difficult and creating risk of illegal state
combinations (e.g., active account with incomplete KYC).

## Decision
A dedicated `services/customer_lifecycle/` service models the customer lifecycle
as an explicit FSM with five states: `prospect → onboarded → active → dormant →
offboarded`. Transitions are defined as an exhaustive edge list; invalid transitions
are rejected with a named exception. HITL gates are enforced on the
`prospect → onboarded` (KYC sign-off) and `active → offboarded` (closure approval)
transitions via `services/hitl/hitl_service.py`. Every state transition is written
as an immutable event to the ClickHouse audit table (append-only). The FSM state
is the source of truth for downstream services (payments, statements, AML screening).

## Consequences
Positive:
- Strict state governance prevents illegal lifecycle combinations; compliance evidence
  is derivable directly from the event log.
- HITL gates on onboarding and offboarding satisfy MLR 2017 CDD requirements and
  Consumer Duty exit-process obligations.
- FSM as single source of truth eliminates inconsistency between services.
- Append-only event log supports FCA supervisory data requests.

Negative:
- Every FSM edge requires a guard test; test matrix scales with number of transitions.
- HITL gates on onboarding introduce latency; officer SLA must be defined and monitored.

## Invariants
I-24: All lifecycle state transitions are written to ClickHouse as append-only events;
no UPDATE or DELETE is permitted on lifecycle audit records.
I-27: HITL gates on `prospect → onboarded` and `active → offboarded` transitions are
enforced; the FSM proposes the transition, a human approves — no autonomous execution
of gated transitions.

## References
- IL: instruction-ledger/sprint-41/IL-LCY-01-customer-lifecycle-fsm.md
- Code: banxe-emi-stack/services/customer_lifecycle/
- Code: banxe-emi-stack/services/hitl/hitl_service.py
- Tests: banxe-emi-stack/tests/test_customer_lifecycle/
