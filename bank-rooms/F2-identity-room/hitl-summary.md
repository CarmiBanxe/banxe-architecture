# F2 / identity-room — HITL Summary

**Reflects `../../HITL-MATRIX.yaml` (v1.0, IL-065). This file MIRRORS the matrix; it does not modify it.**
Invariant **I-27** (`../../INVARIANTS.md`): AI PROPOSES, human DECIDES. Gate IDs below are the authoritative matrix IDs (the brief's H-006/H-007/H-012 shorthand maps to these).

## Identity-cluster HITL gates (from HITL-MATRIX.yaml)

| Gate | Name | Trigger | Roles | Auto? | Relevance to this room |
|---|---|---|---|---|---|
| **HITL-002** | EDD Sign-off | `EDD_REQUIRED` | any_of: MLRO, COMPLIANCE_OFFICER (MLRO if PEP) | no | KYB corporate ≥£50k / KYC individual ≥£10k enhanced due diligence |
| **HITL-006** | KYC Rejection (HIGH/PROHIBITED) | `KYC_HIGH_RISK_REJECTION` | any_of: MLRO, COMPLIANCE_OFFICER | no | KYC rejections for HIGH/PROHIBITED risk require human review; LOW/MED auto-approve permitted |
| **HITL-007** | PEP Onboarding | `PEP_ONBOARDING` | MLRO AND CEO | no | PEP enhanced measures (MLR 2017 Reg.35) — applies to KYC and KYB (beneficial owners) |
| **HITL-014** | AI Model Update (High-risk system) | AI_MODEL_UPDATE | CRO AND CTO | no | Updates to high-risk KYC AI models require dual CRO+CTO sign-off |

Adjacent (not identity-owned, referenced for chain awareness): HITL-005 Customer BLOCK (AML), HITL-003/004 Sanctions — these sit in the AML/sanctions carve-out (I-27), **not** in this room.

## Consent / DPO — governance gap (NOT a matrix gate)

- Consent and lawful-basis decisions are **human-only**; there is **no HITL-matrix gate** for consent — it is governed through **register #5 (Consent/DPO)**.
- **DPO VACANT** — interim owner per the Interim Consent-Owner Decision (temporary only). Art.37 applicability and sufficiency of the interim arrangement remain `[counsel]`.
- Withdrawal/change of lawful basis and material profiling changes must wait for a formal DPO decision.

## Carve-out (I-27) boundary

KYC/KYB/AML screening internals remain under the I-27 carve-out. This room mirrors the identity boundary only; SAR filing, sanctions reversal, and AML customer blocks are owned by the AML/MLRO domain, not here.

## Decision-trace requirement (technical note)

For any agent-assisted identity decision surfaced through this cluster, `correlation_id` alone is insufficient for regulatory decision traceability; decision-layer fields (initiator, input data, decision outcome, override trail) must accompany it. Sufficiency assessment: `[counsel] / [external reviewer]`.

## Sources

`../../HITL-MATRIX.yaml` · `../../docs/ORG-STRUCTURE.md` · `../../docs/briefs/HIGH-RISK-AI-REGISTER-OPERATOR-MEMO.md` · `../../INVARIANTS.md` (I-27)
