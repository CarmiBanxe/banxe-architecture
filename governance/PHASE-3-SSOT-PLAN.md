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

---

## AMENDMENT-001 (2026-07-05) — conformance corrections

Source: conformance audit `docs/audit/PHASE-3-SSOT-CONFORMANCE-2026-07-05.md` (PR #1026, merged). Append-only
(I-24): the body above is preserved; the values below **supersede** the noted body cells.

### Corrections (discrepancies — the body values are wrong)

| Ref | Body value | Corrected value | Basis |
|---|---|---|---|
| §5 "Canonical location" + §3.21 path | `docs/STAFF-MATRIX-v3.md` | **`governance/STAFF-MATRIX-v3.md`** | the `docs/` path does not exist; the file lives under `governance/` |
| §5 "Total passports" + §3.21 count | **74** | **70** | STAFF-MATRIX-v3 §1 states its own total = **70** (filesystem scan 2026-07-02 of `agents/passports/`); internally consistent (§5: 12 L1–L2 heads + 58 PROPOSED = **70**, not 74) |

### Stale statuses now satisfied (flip to ✅ DONE)

| Ref | Body status | Actual |
|---|---|---|
| §8 criterion 1 (this plan merged) | ⏳ This PR | ✅ DONE — on `main` |
| §8 criterion 2 (ADR-157 merged) | ⏳ This PR | ✅ DONE — on `main` |
| §8 criterion 6 + §7 (#270 DEPLOYMENT-MANIFEST) | ⏳ Awaiting merge | ✅ DONE — #270 **MERGED** |

### Refreshed snapshot values (informational — were point-in-time at Phase-3 open)

- §3.18 IL tip: `IL-864` → current max **IL-887**.
- §3.19 ADR range: `ADR-001..157` → highest on main **ADR-160**.

### Not amended — clarified only

- **§3.20 GAP register:** two files exist on main — `GAP-REGISTER.md` (root) **and** `docs/GAP-REGISTER.md` (an
  intentional split, root = architecture-canon gaps, `docs/` = operational). The "92 gaps / 18 OPEN" figure is
  not reproducible by simple count; it should cite the specific register + its own authoritative tally. Highest
  GAP on main is `GAP-091` (so ~92 total is plausible; the **18 OPEN** sub-count remains unverified).
- **§3 domains 1–17, 22** name `banxe-emi-stack` paths + operational flags that were **not** verified in the
  `banxe-architecture`-scoped audit. A companion emi-stack-side audit is required before §8 criterion 4 (SSOT
  table approval) is honestly satisfiable.

*AMENDMENT-001 is append-only (I-24). It corrects references; it does not activate/deactivate any passport or
change any SSOT ownership.*

---

## AMENDMENT-002 (2026-07-05) — emi-stack domain-path corrections

Source: cross-repo domain-path audit `docs/audit/PHASE-3-SSOT-EMI-STACK-DOMAIN-AUDIT-2026-07-05.md` (PR #1029,
merged), which verified the §3 `banxe-emi-stack` rows (domains 1–17, 22) that AMENDMENT-001 left cross-repo-
unverified. 16 of 18 paths were correct; the two below are corrected. Append-only (I-24): the body §3 cells are
preserved; the values below **supersede** them.

### Corrections (§3 paths — body values are wrong)

| Ref | Body path | Corrected path | Basis (banxe-emi-stack `origin/main` `8ca0ce4`) |
|---|---|---|---|
| §3.14 Agent Routing (ARL) | `services/arl/` | **`services/agent_routing/`** | `services/arl/` does not exist; `services/agent_routing/` present |
| §3.17 Compliance KB | `services/kb/` | **`services/compliance_kb/`** | `services/kb/` does not exist; `services/compliance_kb/` present |

### Clarifications (not path errors)

- **§3.12 Audit Trail** — both `services/audit/` and `services/audit_trail/` exist on emi-stack `origin/main`.
  The §3.12 canonical path `services/audit/` is retained, but the SSOT should state explicitly whether
  `services/audit_trail/` is a distinct concern or a duplicate to consolidate.
- **§3 table is a curated CORE set, not exhaustive.** `banxe-emi-stack` `origin/main` has **~50+**
  `services/*` directories; §3 lists 22 core domains. §1's "SSOT for **every** domain" is satisfied only for
  the core set — the uncovered services (`abs`, `adverse_media`, `api_gateway`, `card_issuing`,
  `client_statements`, `consumer_duty`, `crm`, …) have **no declared SSOT owner** in this table. The plan
  should either declare §3 "core domains only" or extend coverage in a later amendment.

### Still owed (not resolvable by the factory — path audit ≠ runtime attestation)

- The §3 **operational flags** (✅ LIVE / 🟡 CODE-READY / 🔴 BLOCKED / 🟠 STAGED) attest *runtime* state, which a
  read-only tree audit cannot verify. **§8 criterion 4 (SSOT-table approval)** therefore requires the owning
  service teams' runtime attestation, not merely path-existence — this remains an owner-team action before
  Phase 3 can be honestly declared COMPLETE.

*AMENDMENT-002 is append-only (I-24). It corrects references; it does not activate/deactivate any passport,
change any SSOT ownership, or mutate `banxe-emi-stack` (the audit was read-only, Rule 6).*

---

## AMENDMENT-003 (2026-07-05) — GAP-count clarification + passport-count confirmation

Closes the two "needs clarification" items the conformance audits (#1026 / #1029) flagged but could not resolve
to a number. Append-only (I-24); no body cell changed.

### §3.20 GAP Register — the "92 gaps / 18 OPEN" figure is a stale, non-reproducible snapshot

Verified on `origin/main` (`7758b1d`):
- **Total ~92 is plausible** — the highest GAP id on main is **`GAP-091`**.
- **The "18 OPEN" sub-count is NOT reproducible**, because the register's statuses are **self-declared stale**.
  The plan's cited register `docs/GAP-REGISTER.md` yields **8–17** OPEN by different counting methods; its own
  **GAP-076 note (2026-06-21)** states *"all 13 OPEN GAPs have code (stale statuses)"*; and a **second** register,
  root `GAP-REGISTER.md` (the intentional two-register split — architecture-canon vs operational), yields **~40**.
- **Conclusion:** no single authoritative "OPEN" count exists today. §3.20 should (a) name **one** register as the
  SSOT for this figure, and (b) treat the count as a **dated snapshot** (or live-computed), not a pinned constant —
  an authoritative OPEN tally first requires a **GAP-register status-reconciliation pass** (separate from this SSOT
  plan, since the registers' statuses are known-stale per GAP-076).

### §5 / §3.21 passport count — AMENDMENT-001's "70" is confirmed stable (not drifting)

A later survey produced 75/82 via a broad `passport.*\.yaml` glob; those are **counting artifacts** (they match
subdir/other files beyond the passport registry). The authoritative count — `agents/passports/**/*.yaml` — is
**70**, matching STAFF-MATRIX-v3 §1's own 2026-07-02 filesystem scan. **AMENDMENT-001's 70 stands; no change.**

### Net Phase-3 status after AMENDMENTs 001–003

Every SSOT claim is now either **verified-and-correct**, **corrected** (STAFF-MATRIX path, passport 74→70, ARL &
KB emi-stack paths, stale §8 criteria), or **honestly flagged as owner-team/reconciliation work** (operational
runtime flags for §8 criterion 4; the GAP OPEN tally). The governance-side registry is conformant; the residual
items are explicitly *not* factory-resolvable.

*AMENDMENT-003 is append-only (I-24). It clarifies figures and confirms a prior correction; it changes no SSOT
ownership and activates no passport.*
