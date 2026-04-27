# ADR-FOS-01: FOS Escalation — Complaint Handling and Financial Ombudsman Service Integration

## Status
Accepted

## Context
FCA DISP (Dispute Resolution: Complaints) rules require EMI firms to handle customer
complaints within defined SLAs and to provide a formal final-response letter before a
customer may escalate to the Financial Ombudsman Service (FOS). Any outbound response
that closes a complaint or refers the customer to FOS must pass a human-in-the-loop
review to ensure regulatory accuracy and avoid inadvertent admissions of liability.
An append-only audit trail is mandatory to satisfy FCA record-keeping obligations
and to defend decisions in FOS investigations.

## Decision
A dedicated `services/complaints/` microservice implements complaint lifecycle as an
explicit FSM with five states: `intake → triage → review → response → escalation`.
Transitions from `review` to `response` and from `response` to `escalation` are gated
by a HITL approval step implemented via `services/hitl/hitl_service.py`. All state
transitions are written as immutable events to the ClickHouse audit table
`safeguarding_events` (append-only). No outbound communication to a complainant or
to FOS is issued without a recorded human approval event.

## Consequences
Positive:
- Full auditable trail of every complaint state transition, defensible in FOS investigations.
- HITL gate prevents erroneous or legally harmful responses from being sent automatically.
- FSM makes SLA breach detection deterministic and automatable.
- Append-only log satisfies FCA DISP record-keeping requirements.

Negative:
- Final-response SLA (8 weeks, DISP 1.6.2) depends on human availability; officer
  unavailability creates bottleneck risk.
- FSM surface requires guard tests on every edge; test matrix grows with each new state.

## Invariants
I-24: All complaint state transitions are written to ClickHouse as append-only events;
no UPDATE or DELETE is permitted on audit records.
I-27: HITL gate is enforced before every outbound response; the service proposes,
a human decides — no autonomous outbound dispatch.

## References
- IL: instruction-ledger/sprint-41/IL-FOS-01-fos-escalation.md
- Code: banxe-emi-stack/services/complaints/
- Code: banxe-emi-stack/services/hitl/hitl_service.py
- Tests: banxe-emi-stack/tests/test_complaints/
