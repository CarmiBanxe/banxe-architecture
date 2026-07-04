# Phase 3 SSOT Plan — Banxe AI Bank
**Date:** 2026-07-04  
**Status:** ACTIVE — Phase 3 OPEN (ADR-156 sandbox gate removal, 2026-07-04)  
**Author:** Factory (Central dispatch)  
**Append-only (I-24). Updates via AMENDMENT-NNN sections only.**  
**ADR:** docs/adr/ADR-157-phase3-ssot-methodology.md  
**Program context:** governance/GLOBAL-PROGRAM-PLAN.md §3  

---

## 1. Phase 3 Objective

Phase 3 establishes a **Single Source of Truth (SSOT)** for every domain in the Banxe AI Bank system.

Specifically:
1. Produce a canonical per-domain SSOT table (Section 3) — authoritative repo, path, adapter class, operational status.
2. Confirm resolution of all Phase 2 Duplicate Traps (Section 4).
3. Define the agent passport canonical location (Section 5).
4. Produce the 3-repo → 2-repo migration plan (Section 6).
5. Define the service registry canonical location (Section 7).

Phase 3 entry gate was satisfied on 2026-07-03 (all five banxe-emi-stack services ≥80% coverage; see CONSOLIDATION-PLAN-PHASE-2.md AMENDMENT-001). Phase 3 was opened on 2026-07-04 by ADR-156.

---

## 2. Repository Census (Stable State Input)

| Repo | Role | Floor | Status |
|------|------|-------|--------|
| `banxe-architecture` | Governance — IL, ADR, GAP, STAFF-MATRIX, program plans | Floor 4 | LIVE |
| `banxe-emi-stack` | P0 production code — all microservices, adapters, MCP tools | Floor 3 | LIVE |
| `vibe-coding` | Research / prototype — compliance engine experiments | Floor 3 | RESEARCH-ONLY |
| `ss1-archived` | Archived snapshot (2026-04-18) | N/A | ARCHIVE (read-only) |

**3-repo stable state target:** `vibe-coding` transitions to archived/read-only research reference after OD-4 Step 3 completes (tx_monitor retirement). No code deletion — GitHub Archive status only.

---

## 3. Per-Domain SSOT Table

The following table is the canonical SSOT registry for all Banxe AI Bank domains as of Phase 3 open.

| # | Domain | Canonical Adapter / Service | Canonical Repo | Canonical Path | Op Status | Notes |
|---|--------|-----------------------------|----------------|----------------|-----------|-------|
| 1 | **Identity / IAM** | Keycloak 26.2 | banxe-emi-stack | `services/auth/` | ✅ LIVE | IAM_ADAPTER=keycloak; :8180 |
| 2 | **Payments** | ModulrAdapter (SEPA) + MockPaymentAdapter | banxe-emi-stack | `services/payment/` | 🟡 CODE-READY | BT-001 (Modulr API key) pending |
| 3 | **Ledger / CBS** | Midaz :8095 | banxe-emi-stack | `services/ledger/` | ✅ LIVE | GL posting; create_tx; get_balance |
| 4 | **AML Orchestration** | swarm.yaml (HITL L1-L4 gates) | banxe-emi-stack | `agents/compliance/swarm.yaml` | ✅ LIVE | vibe-coding/aml_orchestrator.py = research-only (T2.1 OD-1) |
| 5 | **KYC** | SumsubAdapter + CompaniesHouseAdapter | banxe-emi-stack | `services/kyc/` | 🔴 BLOCKED | BT-004 (Sumsub), BT-005 (Companies House) |
| 6 | **Safeguarding** | PostgreSQL safeguarding_accounts table | banxe-emi-stack | `services/safeguarding-engine/` | ✅ LIVE | CASS 15 daily recon; GAP-087 LIVE |
| 7 | **FX Rates** | Frankfurter ECB (self-hosted :8087) | banxe-emi-stack | `services/fx_rates/` | ✅ LIVE | 160+ currencies; 24h fallback cache |
| 8 | **Reporting / FIN060** | dbt + WeasyPrint | banxe-emi-stack | `services/reporting/` + `dbt/` | 🟡 CODE-READY | BT-010 (FCA RegData key) pending |
| 9 | **Reconciliation** | Blnk + adorsys PSD2 | banxe-emi-stack | `services/recon/` | ✅ LIVE | CAMT.053/MT940 daily execution |
| 10 | **Fraud** | Jube :5001 + Marble :5002 | banxe-emi-stack | `services/fraud/` | ✅ LIVE | 9 behaviour signals; case routing |
| 11 | **Transaction Monitoring** | tx_monitor (EMI production) | banxe-emi-stack | `services/aml/tx_monitor.py` | ✅ LIVE | CRYPTO_FLAG ported (PR #269); vibe-coding version RETIRED (OD-4 Step 3) |
| 12 | **Audit Trail** | ClickHouse :9000 + pgAudit | banxe-emi-stack | `services/audit/` (ClickHouse) + PostgreSQL (pgAudit) | ✅ LIVE | Append-only I-24; TTL ≥5yr I-08 |
| 13 | **SAR Generation** | HITLGate + SARService (production state machine) | banxe-emi-stack | `services/case_management/` | ✅ LIVE | vibe-coding/sar_generator.py = research-only (OD-5 verified) |
| 14 | **Agent Routing (ARL)** | RouteAgentTask tier-1/2/3 | banxe-emi-stack | `services/arl/` | ✅ LIVE | Haiku/Sonnet/Opus tiering; logged to ClickHouse |
| 15 | **HITL Gates** | HITLService L1-L4 | banxe-emi-stack | `services/hitl/` | ✅ LIVE | Marble UI :5003; I-27 enforced |
| 16 | **Intent Layer** | SkillRouter (STAGED) | banxe-emi-stack | `services/intent_layer/` | 🟠 STAGED | INTENT_LAYER_ENABLED=false; GAP-080 SkillRouter incomplete |
| 17 | **Compliance KB** | ChromaDB + KBQueryPort | banxe-emi-stack | `services/kb/` | ✅ LIVE | Regulatory citations; FCA/PRA/MLR |
| 18 | **Instruction Ledger** | IL (append-only, Guardian-enforced) | banxe-architecture | `INSTRUCTION-LEDGER.md` + `ledger/` | ✅ LIVE | ADR-019/020 Guardian; IL-864 tip |
| 19 | **ADR Registry** | Markdown ADRs | banxe-architecture | `docs/adr/` | ✅ LIVE | ADR-001..157; ADR-157 = this phase |
| 20 | **GAP Register** | GAP-REGISTER.md | banxe-architecture | `docs/GAP-REGISTER.md` | ✅ LIVE | 92 gaps; 18 OPEN |
| 21 | **Staff / Agent Passports** | STAFF-MATRIX-v3 | banxe-architecture | `docs/STAFF-MATRIX-v3.md` | ✅ LIVE | 74 passports (Section 5) |
| 22 | **MCP Tools** | FastMCP server | banxe-emi-stack | `banxe_mcp/server.py` | ✅ LIVE | 34 tools; ADR-004 |

**Legend:** ✅ LIVE | 🟡 CODE-READY (awaiting API key) | 🔴 BLOCKED (external dependency) | 🟠 STAGED (feature-flagged)

---

## 4. Duplicate Trap Resolution Status

All seven duplicate traps from the Phase 1 census are resolved or classified as intentional separations. No consolidation action required at code level for any trap.

| Trap | Severity | OD Ref | Resolution | Evidence |
|------|----------|--------|------------|----------|
| **AML Orchestrator** — vibe-coding vs banxe-emi-stack | HIGH | OD-1 | Intentional separation: vibe=research scoring function, banxe-emi=production HITL topology. Different layers, zero coupling. | T2.1 analysis (PR #998, merged 2026-07-03) |
| **TX Monitor** — vibe-coding vs banxe-emi-stack | MEDIUM | OD-4 | vibe version RETIRED to deprecated/. CRYPTO_FLAG ported to EMI (PR #269). I-01 fix applied (vibe-coding PR #3). | T2.5 Step 3 (PR #999, merged 2026-07-03) |
| **SAR Generator** — vibe-coding vs banxe-emi-stack | MEDIUM | OD-5 | Intentional separation: vibe=research narrative generator (no MLRO gate), banxe-emi=production state machine (MLRO L4 gate). | OD-5 verification package (PR #995, merged 2026-07-03) |
| **Reconciliation** — vibe-coding vs banxe-emi-stack | LOW | OD-6/7 | Intentional separation: vibe=research prototype, banxe-emi=production CAMT.053 engine. Zero coupling verified. | OD-6/7 evidence (PR #997, merged 2026-07-03) |
| **Audit Trail** — vibe-coding vs banxe-emi-stack | LOW | OD-6/7 | Intentional separation: vibe=prototype logger, banxe-emi=production ClickHouse append-only trail (I-24). | OD-6/7 evidence (PR #997, merged 2026-07-03) |
| **AML/KYC/Fraud overlap** | MEDIUM | OD-1 | Compliant by design: AML (scoring), KYC (identity), Fraud (behaviour) are regulatory distinct domains per MLR 2017. | compliance-boundaries.md §1-6 |
| **Intent-First** — SkillRouter incomplete | HIGH | GAP-080 | DEFERRED to Phase 4. INTENT_LAYER_ENABLED=false. No SSOT conflict — banxe-emi-stack owns this domain exclusively. | GAP-080 OPEN; MASTER-BASEMENT-AUDIT §1.2 |

**Verdict:** All seven traps resolved. Phase 3 has no outstanding duplicate conflicts.

---

## 5. Agent Passport SSOT

**Canonical location:** `banxe-architecture/docs/STAFF-MATRIX-v3.md`

| Metric | Value | Source |
|--------|-------|--------|
| Total passports | 74 | STAFF-MATRIX-v3 (rebased IL-800/801, PR #957) |
| L1-L2 Dept Heads | 12 | Activated |
| PROPOSED agents | 58 | Passports written; I-27 L4 HITL sign-off required to activate |
| Passport schema | `.soul.md` format | `agents/compliance/soul/` |
| Orchestrator registry | `AGENT_REGISTRY` | `agents/compliance/orchestrator.py` |

**Rule:** No new agent can be added to `AGENT_REGISTRY` or `swarm.yaml` without a corresponding passport in STAFF-MATRIX-v3. Passports in STAFF-MATRIX-v3 are append-only (I-24).

**Activation gate:** PROPOSED → ACTIVE requires L4 HITL sign-off (MLRO + CTIO per agent-authority.md). In Sandbox mode (ADR-156), sign-off gates are N/A — factory may activate agents for testing, but PROPOSED→ACTIVE production promotion still requires MLRO attestation before FCA submission.

---

## 6. Migration Plan: 3-Repo → 2-Repo Stable State

### 6.1 Target State

| Repo | Target Role | Action |
|------|-------------|--------|
| `banxe-architecture` | Governance SSOT — ADR, IL, GAP, STAFF-MATRIX, program plans | NO CHANGE (stays active) |
| `banxe-emi-stack` | Production code SSOT — all microservices, adapters, MCP, agents | NO CHANGE (stays active) |
| `vibe-coding` | Archived research reference | GitHub Archive (operator action, OD-9) |
| `ss1-archived` | Already archived | NO CHANGE |

### 6.2 Prerequisites for vibe-coding Archive

| # | Prerequisite | Status |
|---|--------------|--------|
| 1 | OD-4 Step 1: I-01 fix applied | ✅ DONE (vibe PR #3, 0bdccfc) |
| 2 | OD-4 Step 2: CRYPTO_FLAG ported to EMI | ✅ DONE (banxe-emi PR #269) |
| 3 | OD-4 Step 3: tx_monitor retired to deprecated/ | ✅ DONE (architecture PR #999) |
| 4 | OD-5: SAR generator classified as research-only | ✅ DONE (architecture PR #995) |
| 5 | OD-1: AML orchestrator classified as research-only | ✅ DONE (architecture PR #998) |
| 6 | Verify zero cross-repo imports from banxe-emi-stack → vibe-coding | ✅ DONE (grep 0 matches, T2.1 §2) |
| 7 | Operator archives vibe-coding on GitHub | ⏳ PENDING (OD-9 — operator action) |

**All code prerequisites satisfied.** Only operator action remaining: GitHub Archive vibe-coding.

### 6.3 Post-Archive Canonical Routing

After vibe-coding is archived, any regulatory reference to "compliance research" artifacts points to:
- **Algorithmic scoring reference:** `banxe-architecture/docs/MASTER-ORG-CODE-RUNTIME-DOSSIER.md §3` (pinned snapshot)
- **Production implementations:** `banxe-emi-stack/services/{aml,kyc,fraud,recon}/`

---

## 7. Service Registry SSOT

**Canonical location:** `banxe-emi-stack/infra/DEPLOYMENT-MANIFEST.md`

| Field | Value |
|-------|-------|
| File | `infra/DEPLOYMENT-MANIFEST.md` |
| Created | PR #270 (feat/sprint5-deployment-manifest) |
| Services listed | 27 |
| Node assignments | evo1 / evo2 (per service) |
| Health check strategy | Defined per service |
| Status | ⏳ Awaiting merge (CTIO gate N/A per ADR-156) |

Once PR #270 merges, `DEPLOYMENT-MANIFEST.md` is the canonical service registry. Updates to it follow the same append-only discipline as INSTRUCTION-LEDGER.md for operational stability records.

---

## 8. Phase 3 Completion Criteria

Phase 3 is **COMPLETE** when all of the following are satisfied:

| # | Criterion | Status |
|---|-----------|--------|
| 1 | This PHASE-3-SSOT-PLAN.md merged to banxe-architecture main | ⏳ This PR |
| 2 | ADR-157 (SSOT methodology) merged | ⏳ This PR |
| 3 | All Duplicate Traps confirmed resolved (Section 4) | ✅ DONE |
| 4 | Per-domain SSOT table (Section 3) approved by operator | ⏳ Awaiting merge |
| 5 | vibe-coding archived on GitHub (OD-9) | ⏳ Operator action |
| 6 | DEPLOYMENT-MANIFEST.md merged (#270) | ⏳ Awaiting merge |

Phase 3 → Phase 4 gate: all 6 criteria satisfied + operator confirmation.

---

*Append-only (I-24). Amendments via AMENDMENT-NNN sections below.*
