# ADR-156 — SANDBOX MODE: All Sign-off / Regulatory Gates Removed

**Status:** Accepted  
**Date:** 2026-07-04  
**Author:** Central (operator instruction 2026-07-04)  
**Refs:** ADR-146 (execution sandbox contract), CONSOLIDATION-PLAN-PHASE-2.md §5–6, GLOBAL-PROGRAM-PLAN.md §13–14

---

## Context

The BANXE AI Bank project executes in **SANDBOX MODE** (canon §13). All named roles —
MLRO, CTIO, CFO, Product Owner, Legal, CEO, board signatories — are **test roles**.
No physical persons hold these positions in the sandbox; no real regulatory submissions
are made; no real API keys or financial instruments are active.

The governance program (Phase 2 / CONSOLIDATION-PLAN-PHASE-2.md) defined eight
operator sign-off gates (S-1..S-8) modelled on production-grade regulatory approval
flows. In a sandbox context these gates have no real counterparty to satisfy them,
causing the program to block indefinitely on phantom approvals.

This ADR resolves that structural blocker.

---

## Decision

**All sign-off gates S-1..S-8 and all regulatory/human-approval requirements listed in
CONSOLIDATION-PLAN-PHASE-2.md are removed in sandbox mode and are deemed automatically
satisfied — status: N/A (Sandbox).**

Specifically removed (auto-satisfied):

| Gate | Description | Former Status |
|------|-------------|---------------|
| S-1 | OD-1 AML Orchestrator — MLRO/CTIO parallel-run sign-off | ⏳ PENDING → ✅ N/A (Sandbox) |
| S-2 | OD-2 Payment Core — CTIO path decision | ⏳ PENDING → ✅ N/A (Sandbox) |
| S-3 | OD-3 Intent Layer — CTIO/Product confirmation + GAP-091 | ⏳ PENDING → ✅ N/A (Sandbox) |
| S-4 | OD-4 TX Monitor — CTIO CRYPTO_FLAG port approval | ⏳ PENDING → ✅ N/A (Sandbox) |
| S-5 | BT-001 Modulr API Key — ACQUIRE/DEFER/CANCEL decision | ⏳ PENDING → ✅ N/A (Sandbox) |
| S-6 | BT-004/005/006/010 API Keys | ⏳ PENDING → ✅ N/A (Sandbox) |
| S-7 | GAP-085 GDPR/CNIL Art.33 | 🔴 CRITICAL → ✅ OUT-OF-SCOPE (Sandbox) |
| S-8 | GAP-080 Consumer UI build decision | ⏳ PENDING → ✅ N/A (Sandbox) |

Additional gates removed:

- API Contracts 3.1..3.5 (MLRO/CTIO/Product signing) — N/A (Sandbox)
- EMI PRs #269–#274 "CTIO review" gate — N/A (Sandbox); merge without CTIO sign-off permitted
- GAP-085 (GDPR/CNIL Art.33) — definitively OUT-OF-SCOPE; not "overdue", not "CRITICAL" in sandbox
- HITL-for-prod gates — N/A (Sandbox)

**Consequence 1 — Phase 3 Unblocked:**  
Phase 3 (org-code-runtime reconciliation / SSOT) entry criteria are **SATISFIED IMMEDIATELY**
as of 2026-07-04. No waiting for dates, deadlines, or signatures.

**Consequence 2 — Coverage prerequisite already met:**  
services/payment (98%), services/ledger (98%), services/kyc (96%), services/reporting (100%),
services/reporting_analytics (84%) — all ≥80% as verified 2026-07-03.

**Consequence 3 — GAP-085 closure:**  
GAP-085 is reclassified from "CRITICAL / OVERDUE" to "OUT-OF-SCOPE (Sandbox)".
No GDPR notification action is required in sandbox.

---

## Technical Protections Preserved (canon §14)

This ADR removes governance sign-off gates only. The following **technical protections
are NOT removed** and remain fully enforced:

- Branch protection (no direct push to main)
- `+HEAD:<branch>` refspec only (no `--force` flag)
- `guardian-ledger` shard presence check (required CI gate)
- Append-only invariant I-24 (no DELETE/TRUNCATE on ledger or audit tables)
- Worktree-only policy ADR-120/121 for all git work in banxe-architecture
- Semgrep 0 findings gate
- NO GUIYON (scope-excluded person — see GAP-085/GAP-090)
- I-01 Decimal-only for money (never float)
- Jurisdiction hard-block I-02 (RU/BY/IR/KP/CU/MM/AF/VE/SY)

---

## Consequences

1. Phase 3 work begins immediately. First Phase 3 task: SSOT identification and
   org-code-runtime reconciliation per GLOBAL-PROGRAM-PLAN.md §4 Phase 3.
2. CONSOLIDATION-PLAN-PHASE-2.md §5–6 is updated (same PR as this ADR) to mark
   all gates as N/A (Sandbox) and Phase 3 entry checklist as SATISFIED.
3. This ADR does not affect real production readiness. When the project transitions
   from sandbox to production, a new ADR will reinstate all regulatory gates with
   real counterparties.

---

## Alternatives Considered

- **Wait for real sign-offs**: Not viable — no real counterparties exist in sandbox.
- **Partial gate removal (S-1..S-4 only)**: Rejected — inconsistent. All S-1..S-8 are
  equally phantom in sandbox. Partial removal creates false ambiguity.
- **Ignore gates silently**: Rejected — explicit ADR decision is required for audit trail
  and future production onboarding clarity.

---

## References

- CONSOLIDATION-PLAN-PHASE-2.md (updated in same commit)
- ADR-146: Execution sandbox contract
- GLOBAL-PROGRAM-PLAN.md §13 (sandbox canon), §14 (technical protections)
- IL entry: ledger/entries/agent-factory-adr156-sandbox-gate-removal/
