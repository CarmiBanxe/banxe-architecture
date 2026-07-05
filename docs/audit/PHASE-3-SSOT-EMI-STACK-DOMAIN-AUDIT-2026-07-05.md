# Phase 3 SSOT — banxe-emi-stack Domain-Path Audit (2026-07-05)

**Auditor:** Factory (prepare-only, read-only cross-repo verification)
**Target:** `governance/PHASE-3-SSOT-PLAN.md` §3 domains **1–17, 22** (the `banxe-emi-stack` rows) that the
governance-side conformance audit (`PHASE-3-SSOT-CONFORMANCE-2026-07-05.md`, #1026) marked **unverified-here**.
**Method:** read-only `git ls-tree -r origin/main` on `banxe-emi-stack` (HEAD `8ca0ce4`) — **no** worktree of
that repo was touched (it hosts many concurrent live sessions; Rule 6). This verifies **paths**; runtime
operational flags (✅ LIVE / 🟡 CODE-READY / 🔴 BLOCKED / 🟠 STAGED) are **not** verifiable from the tree and
remain status-unverified.

## Verdict

**16 of 18** claimed emi-stack domain paths are **correct**; **2 are wrong** (fixable via AMENDMENT-002). This
closes the cross-repo half of §8 criterion 4 for path-correctness; operational-flag attestation still requires a
runtime check by the owning service teams.

## A. Confirmed paths ✅ (16/18)

| § | Domain | Path (plan = reality) |
|---|---|---|
| 1 | Identity/IAM | `services/auth/` |
| 2 | Payments | `services/payment/` |
| 3 | Ledger/CBS | `services/ledger/` |
| 4 | AML Orchestration | `agents/compliance/swarm.yaml` |
| 5 | KYC | `services/kyc/` |
| 6 | Safeguarding | `services/safeguarding-engine/` |
| 7 | FX Rates | `services/fx_rates/` |
| 8 | Reporting/FIN060 | `services/reporting/` |
| 9 | Reconciliation | `services/recon/` |
| 10 | Fraud | `services/fraud/` |
| 11 | Transaction Monitoring | `services/aml/tx_monitor.py` |
| 12 | Audit Trail | `services/audit/` *(see §C ambiguity)* |
| 13 | SAR Generation | `services/case_management/` |
| 15 | HITL Gates | `services/hitl/` |
| 16 | Intent Layer | `services/intent_layer/` |
| 22 | MCP Tools | `banxe_mcp/server.py` |

## B. Path discrepancies ⚠ (2 — need correction)

| § | Domain | Plan path (WRONG) | Actual path on `origin/main` |
|---|---|---|---|
| **14** | Agent Routing (ARL) | `services/arl/` | **`services/agent_routing/`** |
| **17** | Compliance KB | `services/kb/` | **`services/compliance_kb/`** |

Both plan paths do not exist; the real directories are present under the names above. → **AMENDMENT-002**.

## C. Clarifications 🟠 (not hard errors)

- **§3.12 Audit-Trail ambiguity:** the tree has **both** `services/audit/` **and** `services/audit_trail/`.
  The plan cites `services/audit/`; the SSOT should state explicitly which directory is canonical for the
  audit-trail domain (or that they are distinct concerns).
- **§3 table is a curated subset, not exhaustive.** `banxe-emi-stack` `origin/main` contains **~50+**
  `services/*` directories (e.g. `abs`, `adverse_media`, `agent_routing`, `api_gateway`, `ato_prevention`,
  `audit_dashboard`, `batch_payments`, `beneficiary_management`, `bi`, `card_issuing`, `client_statements`,
  `complaints`, `consent_management`, `consumer_duty`, `crm`, …). The §3 table lists **22 core** domains. Since
  §1 objective states "SSOT for **every** domain", the plan should either declare the table as "core domains
  only" or extend coverage — otherwise the many uncovered services have **no** declared SSOT owner.

## D. Not verified ⬜ (out of scope for a tree-read)

- **Operational flags** (LIVE / CODE-READY / BLOCKED / STAGED) are runtime states — a path existing does not
  attest that the service is deployed/healthy. §8 criterion 4 ("SSOT table approved") should require the owning
  teams' runtime attestation, not just path-existence.

## Recommendation

Land **AMENDMENT-002** on `PHASE-3-SSOT-PLAN.md` (I-24 append-only) fixing §3.14 (`services/arl/` →
`services/agent_routing/`) and §3.17 (`services/kb/` → `services/compliance_kb/`), plus the §3.12 audit
clarification and a "22 core domains, non-exhaustive" note. Operational-flag attestation remains an owner-team
action before Phase 3 is declared COMPLETE.

## Anchors

`governance/PHASE-3-SSOT-PLAN.md` §3 · `docs/audit/PHASE-3-SSOT-CONFORMANCE-2026-07-05.md` (#1026, the
governance-side audit this completes) · `banxe-emi-stack` `origin/main` `8ca0ce4` (read-only). Prepare-only,
cross-repo read-only; no emi-stack mutation.
