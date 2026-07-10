# I-27 Clarification: KYC HOLD vs BDSL Gate
# Status: CANONICAL CLARIFICATION
# Date: 2026-07-10
# Branch: feat/bdsl-activation-prep
# Purpose: Correct earlier conflation of I-27 with BDSL gate mechanics.

---

## The Confusion — What Went Wrong

Previous BDSL documentation (feat/bdsl-foundation) incorrectly treated **I-27** as a
"BDSL activation gate" anchored in `schemas/agent/decisionrecord.schema.json`.

This was wrong in two ways:
1. I-27 is an operator-level **KYC HOLD**, not a BDSL schema constraint.
2. `schemas/agent/decisionrecord.schema.json` was created as a duplicate of ADR-046;
   it is now marked superseded. See `schemas/agent/decisionrecord.schema.json` `$comment`.

---

## What I-27 Actually Is

| Field | Value |
|-------|-------|
| **Invariant ID** | I-27 |
| **Canonical name** | KYC HOLD |
| **Type** | Operator stop — HITL-L4 |
| **Scope** | KYC / KYB / AML agent activation |
| **Mechanism** | Any agent touching KYC, KYB, or AML decisions requires MLRO/CEO human sign-off before autonomy upgrade |
| **Who can lift** | MLRO (SMF17) + CEO co-sign (L4 gate per `agent-authority.md`) |
| **Where defined** | `.claude/rules/agent-authority.md` § HITL Gate Timeouts; `agents/compliance/swarm.yaml` |

I-27 is a **pre-activation gate** — it applies when an agent moves from PROPOSED to ACTIVE
in the KYC/KYB/AML domain. It does NOT apply to platform or tooling agents.

---

## What I-27 Is NOT

| Incorrect use | Correct statement |
|---------------|------------------|
| "BDSL gate encoded in JSON schema" | BDSL schema contains NO gate logic; gates live in `governance/novelty-pipeline-config.yaml` |
| "Applies to all 13 PROPOSED passports" | Applies only to agents in KYC/KYB/AML domains |
| "Equivalent to I-BDSL-2 Human-Gated Activation" | I-BDSL-2 is broader (all activation upgrades); I-27 is domain-specific (KYC/AML only) |
| "Triggered by confidence score < threshold" | I-27 is a lifecycle gate, not a per-decision runtime gate |

---

## Relationship to BDSL Invariants

```
I-BDSL-2 (Human-Gated Activation)
  └── covers ALL autonomy upgrades for BDSL-enrolled agents
      └── I-27 (KYC HOLD, HITL-L4) is a SPECIFIC INSTANCE of I-BDSL-2
          applied to KYC/KYB/AML domain agents only
          with stricter gate: MLRO + CEO co-sign required
```

Both invariants are satisfied by the same mechanism (human-gated PR) but I-27 adds
MLRO + CEO co-sign as additional signatories for KYC/KYB/AML agents.

---

## Impact on 13 PROPOSED Passports

| Agent | I-27 applies? | Reason |
|-------|--------------|--------|
| `case_management_agent` | **YES** (MLRO sign-off, CTX-01 AML/Compliance) | RED / MLRO ownership |
| `document_management_agent` | No | COO / operations, not KYC/AML |
| `user_preferences_agent` | No | COO / operations |
| `alerting_agent` | No | COO / infrastructure |
| `hr_agent` | No | HR/Legal domain |
| `midaz_mcp_agent` | No | CTO / platform |
| `webhook_orchestrator_agent` | No | CTO / platform |
| `webhooks_agent` | No | CTO / platform |
| `ml_pipeline_agent` | No | CTO / platform |
| `experiment_copilot_agent` | No | CTO / platform |
| `reasoning_bank_agent` | No | CTO / advisory |
| `design_pipeline_agent` | No | CTO / platform |
| `multi_tenancy_agent` | No | CTO / platform |

Only `case_management_agent` falls under I-27 because its bounded_context (CTX-01) includes
AML/compliance case disposition decisions.

---

## What BUG-007 Is (and is not I-27)

**BUG-007** (`.claude/rules/agents.md` § "HITL Confidence Thresholds — MANDATORY for every L2+ agent")
is a **runtime per-decision gate** — AUTO / REVIEW / BLOCK tier assignment based on confidence score.
It applies at every decision execution, not only at activation.

BUG-007 ≠ I-27:
- BUG-007: runtime, per-decision, confidence-driven
- I-27: lifecycle, per-agent-activation, domain-driven (KYC/AML only)
- Both apply to `case_management_agent` at different points in time

---

## References

- Agent authority matrix: `.claude/rules/agent-authority.md` § HITL Gate Timeouts
- Swarm config: `agents/compliance/swarm.yaml`
- BUG-007: `.claude/rules/agents.md#BUG-007`
- I-BDSL-2: `docs/canon/BEST-DECISION-SELF-LEARNING-LOOP.md` § Principles
- 13 PROPOSED activation checklist: `docs/audit/bdsl-fleet-classification-2026-07-10.md`
- ADR-046 canonical schema: `schemas/agent_decision_record.schema.json` (sha a95d8e95…)
