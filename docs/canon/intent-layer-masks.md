# Intent-Layer Masks — L1→L2 Transition Specification
## BANXE AI BANK | Sprint-A A5

**Date:** 2026-06-28  
**Status:** PROPOSED  
**IL Anchor:** (assigned at merge)  
**Related ADRs:** ADR-049 (intent layer & masks), ADR-145 (A2A contract), ADR-048 (business process repository)  
**Regulatory source:** EU AI Act Art.14 (human oversight), FCA CASS 15 (safeguarding)

---

## Overview

The **Intent-Layer Mask** is the governance boundary between L1 (conversational intent capture) and L2 (agent execution). It defines:

- **Which intents are client-facing** (conversational entrypoints to agent capabilities)
- **The autonomy level** at which each intent executes (L1 fully autonomous, L2 human-reviewed, L3 HITL-gated)
- **Confirmation and step-up policy** required before execution
- **Scope constraints** (which ports/operations the agent can invoke within this mask)
- **A2A routing** (how intents flow between agents in the swarm)

Per ADR-049, masks are the **regulated surface** of the Intent-First architecture. They are NOT implementation details; they are **governance artefacts** that determine regulatory compliance per class (CLASS_B / CLASS_C).

---

## L1→L2 Transition Spec

### Autonomy Levels

| Level | Name | Meaning | Review Required | Agent Auto-executes |
|-------|------|---------|-----------------|-------------------|
| **L1** | Autonomous | Read-only operations, balance queries, FX rate lookups | NO | YES |
| **L2** | Human-Reviewed | Mutating operations (payment, account change, KYC update) | YES | NO — waits for HITL |
| **L3** | Compliance-Gated | High-risk mutations (SAR filing, threshold change, sanctions reversal) | YES | After gate clearance only |

### Transition Rules

**L1 (autonomous):**
- Query operations: balance, transaction history, FX rates, account details
- No API key/token changes, no account closures, no customer data mutations
- Instant response to client; no HITL gate
- **Example:** Client asks "what's my current balance in EUR?" → Planner reads balance, no gate

**L1→L2 escalation trigger:**
- ANY mutating intent (payment submission, account update, KYC submission)
- ANY intent accessing PII beyond the current context (new beneficiary, linked account)
- Amount-based triggers (e.g., payment > £10k individual, > £50k corporate)
- **Client experience:** "I need to send £5000 to John" → mask escalates to L2; client sees confirmation card with amount, recipient, fees

**L2 (human-reviewed):**
- Agent PROPOSES the action (generates a structured decision record per ADR-046)
- Human (MLRO, Compliance Officer, or designated approver) sees a **masked summary** (not raw data):
  - "Payment: £5000 to IBAN *****GB82; risk score: 0.35; charges: £2.50"
  - "KYC update: residential address changed to…; new sanctions status: CLEARED"
- Agent waits for explicit HITL approval (per ADR-027, I-27)
- On approval: A2A DECISION message fires → agent executes the port call → AgentDecisionRecord logged
- **Client surfaces:** confirmation modal with "Pending approval" badge; retry logic if approval times out

**L3 (HITL-gated, compliance-specific):**
- Only MLRO / CTIO can approve (role-based gate per agent-authority.md)
- Examples: SAR filing, sanctions threshold reversal, AML score override, API key rotation
- Timeout: escalation path defined per agent-authority.md (e.g., SAR → MLRO → CEO, 24h timeout)

### Confirmation & Step-Up Policy

| Mask Type | Confirmation Required | Step-Up (Biometric) | Timeout | Escalate If Rejected |
|-----------|----------------------|-------------------|---------|---------------------|
| L1 read-only | NO | NO | — | N/A |
| L2 payment ≤ £1k | YES (visual) | NO | 5min | Audit log + retry |
| L2 payment £1k–£10k | YES + SMS OTP | YES (optional) | 10min | Audit log + MLRO alert |
| L2 payment > £10k | YES + SMS OTP + Biometric | YES (mandatory) | 15min | MLRO review required |
| L3 SAR / sanctions | MLRO + CTIO approval | N/A | 24h | CEO escalation |

---

## Passport Cross-Reference Index

### Intent-Facing Passports (70 agents)

The following passports are candidates for A2A bus revision (Sprint-B B2 intent-dispatcher-runtime-wiring):

| Passport | Role | Current State | Needs A2A Revision | Dispatcher Entry Point | Notes |
|----------|------|---------------|--------------------|-----------------------|-------|
| **canon-judge** | Policy enforcer | Internal | Optional | policy_validate | Reviews decisions; non-client-facing |
| **executor** | Code executor | Internal | NO | — | Aider CLI only; not in agent swarm |
| **planner** | Task decomposer | L1_ACTIVE | YES | task_decompose, sprint_assign | Dispatcher integration via A2A; ADR-145 contract |
| **reviewer** | Code reviewer | Internal | Optional | code_review_gate | Non-client-facing; optional A2A for audit |
| **mlro** | Compliance overseer | L2_REVIEW | YES | sar_file, threshold_change | High-trust; requires HITL gate |
| **ctio** | Tech/infrastructure owner | L1_ACTIVE | Optional | secret_rotate, infra_config | Internal; optional A2A if swarm includes infra agents |
| **operator** | Deployment/operations | Internal | NO | — | Manual operations; not agent-facing |
| **guardian-factory** | Factory security auditor | L1_ACTIVE | Optional | security_audit | Optional A2A for factory coordination |
| **guardian-project** | Project security auditor | L1_ACTIVE | Optional | security_audit | Optional A2A for project coordination |
| **schema** | Schema validator | L1_ACTIVE | Optional | schema_validate | Optional A2A if used by other agents |

### Service-Layer Agents (Sprint-3 pending via GAP-078)

The following are **NOT yet modelled in passports** (live in `vibe-coding` + `banxe-emi-stack` services); they will require new passport files + A2A dispatch:

| Service | Agent Type | Autonomy | HITL Gate | A2A Routing Required |
|---------|-----------|----------|-----------|---------------------|
| `services/aml/aml_orchestrator` | AML orchestrator | L3 | sanctions_score ≥ 0.80 | YES (REQUEST from TM agent) |
| `services/kyc/kyc_agent` | KYC processor | L2 | risk_score ≥ 0.60 | YES (REQUEST from onboarding flow) |
| `services/payment/payment_agent` | Payment executor | L2 | amount > £10k GBP | YES (REQUEST from L1 intent dispatcher) |
| `services/fraud/fraud_agent` | Fraud detector | L3 | fraud_score ≥ 0.75 | YES (EVENT from transaction monitor) |
| `services/ledger/ledger_agent` | Ledger keeper | L1 | — | YES (REQUEST from payment agent) |
| `services/recon/recon_agent` | Daily reconciliation | L1 | — | YES (scheduled EVENT) |
| `services/reporting/fin060_agent` | FCA reporting | L2 | — | NO (batch; HITL sign-off pre-submission) |

### Passport Revision Summary

**Total passports in docs/canon/passports/:** 10  
**Passports with A2A entry points (must update):** 4 (planner, mlro, ctio, reviewer)  
**Passports optional for A2A:** 3 (canon-judge, guardian-factory, guardian-project, schema)  
**Passports external (out of scope A5):** 3 (executor, operator)

**Service-layer agents requiring new passports (Sprint-3 GAP-078):** 7

---

## Implementation Notes (Sprint-B B2)

**B2 will implement the dispatcher runtime wiring:**

1. Build the intent-classifier (LLM-based): client intent string → canonical process_ref via ADR-048
2. Wire A2A routing: planner → executor | mlro → decision-gate | payment-agent → ledger-agent
3. Implement confirmation UI: L2 cards with visual + OTP + optional biometric
4. Test HITL timeout escalation: 24h SAR window → CEO notification
5. Validate ADR-145 A2A message envelope: correlation_id propagation, audit trail logging (ClickHouse)

**BLOCKERS for B2:**
- ADR-145 A2A contract must be ACCEPTED (currently PROPOSED; depends on A1)
- LLM orchestration layer (Terminal A responsibility) must be operational

---

## References

- **ADR-049:** Intent Layer & Client-Facing Agent Masks (L1 specification)
- **ADR-048:** Business Process Repository (intent→process contract)
- **ADR-145:** A2A Inter-Agent Message Contract (routing & correlation)
- **ADR-046:** Decision Lineage Schema (audit trail per action)
- **ADR-047:** AI Cost Governance Policy (cost caps + HITL thresholds)
- **agent-authority.md:** Autonomy levels L1–L4; HITL gates & timeouts
- **CLAUDE.md § Financial Invariants:** I-24 (append-only audit), I-27 (HITL supervised)
- **SPRINT-PLAN § A5:** Acceptance criteria & gate-in requirement (A2 ACCEPTED PR #860)
