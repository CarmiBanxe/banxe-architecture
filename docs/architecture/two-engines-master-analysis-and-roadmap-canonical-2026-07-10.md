<!-- ============================================================= -->
<!-- AUDIT OVERRIDE — 2026-07-10 (live shell audit, Legion)        -->
<!-- CANON: "verify, don't trust labels". Метки [ФАКТ]/[ВЫВОД]/     -->
<!-- [НЕИЗВЕСТНО] из S-18 НЕ истина — истина = аудит. Приоритет.    -->
<!-- ============================================================= -->

## §AUDIT-2026-07-10 — Verified Topology & Deployment (OVERRIDES S-18 labels)

**CANON:** любая метка требует прямого аудита. Ниже — live-факты (audit 2026-07-10).

### Nodes (было [НЕИЗВЕСТНО] → установлено)
| Node | LAN IP | Tailscale | Services (audited) | Status |
|------|--------|-----------|--------------------|--------|
| evo1 | 192.168.0.72 | 100.68.102.48 | Ollama :11434, LiteLLM :4000, llama.cpp RPC | via Tailscale; short-name evo1 NOT resolving from Legion |
| evo2 | 192.168.0.15 | 100.99.208.21 | Ollama :11434, RPC :50052, Prometheus :9090, Grafana :3000 | REGISTERED 2026-05-11; via Tailscale |
| Legion (mark-legion) | LAN | — | LiteLLM :4000 (active), Grafana/WebUI :3000, ollama.service active | operator/factory node |

### Deployment reality (OVERRIDES blueprint)
- **Qdrant:** NOT FOUND anywhere → S-18 "[ФАКТ] Qdrant" = **UNVERIFIED / PLANNED**, not deployed.
- **Private Engine on Legion:** llama-server :8080 + OpenManus :8000 **NOT LISTENING** → **BLUEPRINT / NOT-DEPLOYED**. Live only: Ollama :11434 + LiteLLM :4000.
- **evo1/evo2 "unavailable":** actually name-resolution from Legion; nodes reachable via Tailscale 100.x. Verify server-side.

### Open items (audit-driven)
1. Deploy Qdrant (banking evo1/evo2 + private Legion) — absent now.
2. Deploy Private Engine runtime (llama-server :8080 + OpenManus :8000) — blueprint now.
3. Fix evo1/evo2 short-name resolution from Legion (hosts/DNS/Tailscale MagicDNS).

<!-- ===================== END AUDIT OVERRIDE ===================== -->

# Two-Engine Architecture: Master Analysis and Unified Roadmap
# CANONICAL — 2026-07-10 (v2 — 14-section restructure, S-19 integration, EMI scope framing)
# Branch: agent/factory/t5/bdsl-activation-prep
# Status: SYNTHESIS — reviewed against full source corpus S-01..S-19

---

## §0 — Source Corpus and Integrity

### Confirmed Source Documents

| ID | File | Location | Used for |
|----|------|----------|---------|
| S-01 | `emi-banxe-intent-first-banking-2026-07-10.md` | `/home/mmber/MetaClaw/docs/sources/` | Banking engine framing, Intent-First architecture |
| S-02 | `emi-banxe-ideal-engine-math-2026-07-10.md` | `/home/mmber/MetaClaw/docs/sources/` | OSS framework landscape, math foundations (MAUT, DAG, MCTS) |
| S-03 | `banxe-agent-engine-conclusion-2026-07-10.md` | `/home/mmber/MetaClaw/docs/sources/` | BANXE-CORE-ENGINE 6-layer model, P0 blockers, missing components |
| S-04 | `banxe-oss-free-agent-solutions-2026-07-10.md` | `/home/mmber/MetaClaw/docs/sources/` | OSS agent catalog (120+ frameworks) |
| S-05 | `banxe-uxui-architecture-2026-07-10.md` | `/home/mmber/MetaClaw/docs/sources/` | HII, Rich Cards, chat-first paradigm, voice, NLU |
| S-06 | `emi-banxe-world-experience-2026-07-09.md` | `/home/mmber/MetaClaw/docs/sources/` | Global benchmarks (Alipay, Nubank, Minna Bank, DBS, Revolut AIR) |
| S-07 | `Hermes-Agent----BANXE------Factory--EMI-AI-Bank.md` | `/home/mmber/MetaClaw/docs/sources/` | Full agent stack map, Hermes topology, 3 profiles |
| S-08 | `Hermes-Agent------EMI-BANXE-AI-Bank--Software-Factory.md` | `/home/mmber/MetaClaw/docs/sources/` | Software Factory substrate, Hermes integration |
| S-09 | `emi_banxe_ai_bank_full_structure_report_v1.md` | `/home/mmber/MetaClaw/docs/sources/` | ORG audit: staffing gaps, sprint history, service projections |
| S-10 | `ORG-STRUCTURE.md` | `/home/mmber/MetaClaw/docs/sources/` | Organizational hierarchy, vertical management |
| S-11 | `bdsl-self-learning-loop-v2-2026-07-10.md` | `/home/mmber/MetaClaw/docs/sources/` | BDSL v2 spec, MAUT decision record, fleet enrolment |
| S-12 | `docs/canon/BEST-DECISION-SELF-LEARNING-LOOP.md` | worktree `docs/canon/` | BDSL canon pointer, 3 invariants, activation readiness |
| S-13 | `docs/adr/ADR-045-intent-first-banking-architecture.md` | worktree `docs/adr/` | Intent-First ADR (ACCEPTED 2026-06-07), 4-layer model |
| S-14 | `docs/audit/ORG-CODE-RECONCILIATION-v2.md` | worktree `docs/audit/` | 106/91/47 passport coverage, Matrix A–D |
| S-15 | `docs/audit/bdsl-fleet-classification-2026-07-10.md` | worktree `docs/audit/` | All 47 passports, ENROL/DEFER/EXCLUDE, CREDIT-GAP |
| S-16 | `docs/audit/bdsl-fleet-coverage-2026-07-10.md` | worktree `docs/audit/` | Coverage gates, activation blockers |
| S-17 | `manus-legion-telegram-architecture.md` | `/home/mmber/MetaClaw/docs/sources/` | Legion private engine runtime + interface blueprint: OpenManus, llama-server, FastAPI, Telegram, Open WebUI, mobile apps, systemd |
| S-18 | `BANXE-Private-Legion-Engine-Otvety-Konsultanta-2026-07-10.md` | worktree `docs/sources/` | Consultant advisory: 9 corrections applied to §§1–14 (sha ba53185a, 162 lines). Status: advisory; operator + Central ratification required (I-27). Referenced as `(S-18 C1)..(S-18 C9)` throughout. |
| S-19 | `BANXE-Private-Legion-Engine-Otvety-na-otkrytye-voprosy-arkhitektury-2026-07-10.md` | worktree `docs/sources/` | Open architecture Q&A: framework comparison table, memory layer roles, implementation inventory matrix, EU AI Act article precision, DLP detail, source hierarchy, evo1 risk (sha 719494c4, 298 lines, 36628 bytes). Integrated into §7–§9, §12. Referenced as `(S-19 B1..B6)`, `(S-19 Q1..Q5)` throughout. **PROVENANCE NOTE:** commit `14ad199` subject incorrectly labelled this file "S-18 consultant answers" — informal naming. Formal designation in this document is S-19 (distinct from S-18 above: different SHA ba53185a≠719494c4, different content). S-18 and S-19 are two separate consultation artefacts from the same session. |

### SHA Anchors

```
BDSL pinned source body-sha256:
  c4f71e729f3791e97429f5482c405c201cee395b4d8daff6d9828ed53c30553f

BDSL pinned source file-sha256:
  e8c65d1f804548e1829618d6db2d4d91e9688f426a6c331aab70f5c993ae40fe

ORG-CODE-RECONCILIATION-v2 sha256 (operator-confirmed):
  b84a4babf36bb0f9cc1618b26970f3cf009620c5780cda45313a4c1b41a2f035

ADR-046 Decision Record schema sha256 (operator-confirmed):
  a95d8e959417ad86dbb19e1d07ccd02d036671b92cd12912f640827c82db313b

Manus-Legion-Telegram architecture sha256 (S-17, operator-confirmed):
  f937c55f7f12e86db4ac873232ed29aefec59cd480b6f42fa2ea1f0506e94038
  (24561 bytes, 538 lines)

S-18 Consultant advisory sha256 (computed 2026-07-10):
  ba53185aeb9a55d122ba8146a2d262b98d45f73948208db54b12e9d81fc0c90d
  (9 corrections, advisory status)

S-19 Open architecture Q&A sha256 (computed 2026-07-10):
  719494c471bd1a5f2c21337ae37b22c0c48bc68c52699025236dbb946c049b19
  (298 lines, 36628 bytes)
```

### Source Hierarchy (S-18 C6 + S-19 B6 — complementary, not duplicate)

```
LEVEL 0 [UNCONDITIONAL]:
  Regulatory: EU AI Act / BaFin / DORA / FCA / MLR / GDPR
  → Cannot be overridden by any ADR or internal decision

LEVEL 1 [CANONICAL]:
  ADR supersedes-chain (banxe-architecture/docs/adr/)
  → Each ADR states which ADR it supersedes; explicit supersedes only

LEVEL 2 [GOVERNANCE]:
  BDSL fleet registry + PassportYAML (MLRO/CRO approved)
  → Changes require MLRO/CRO joint sign-off

LEVEL 3 [OPERATIONAL]:
  Passports / fleet registry / ORG-CODE matrix
  → Describes current deployment state

LEVEL 4 [WORKING DRAFTS]:
  Consultant analysis, source documents S-01..S-19, research memos
  → Inform ADRs and governance documents; NOT source of truth themselves
```

---

## §1 — Purpose and Synthesis Frame

### The Primary Lens: EMI Scope vs Bank-License Scope

Every element of this document must be read through the following frame:

**BANXE currently operates as an EMI (Electronic Money Institution) under FCA authorization.**

This means:
- **ACTIVE under current EMI scope:** AML/KYC screening, payment routing, safeguarding (CASS 15), sanctions, fraud detection, FX exchange, compliance monitoring, reporting (FIN060), open banking (PSD2/CAMT.053).
- **INTENTIONALLY DORMANT under current EMI scope:** Credit decisioning, credit scoring, lending, loan origination, insurance underwriting, market-facing banking functions, card-credit facilities.

The dormant category is NOT a defect. It is a license boundary. When (if) BANXE obtains a banking license, dormant capabilities are activated — they must remain in the architecture as hidden branches, not deleted. This distinction governs how credit-related components are classified throughout this document.

The phrase "CREDIT-GAP blocker" used in prior versions is superseded. The correct framing is: **dormant bank-grade capabilities under current EMI scope, activation-on-license-expansion.**

### Why This Document Exists

The source corpus (S-01 through S-19) was produced during a period when BANXE AI Bank was described inconsistently: sometimes as "a banking stack with AI bolted on," sometimes as a fully autonomous agent system. ADR-045 (S-13) names this as the core drift problem and resolves it: **BANXE is Intent-First / AI-agent-first**. The conversational intent layer is the primary interface.

Alongside the banking product, there is a second system: the **Software Factory and operator infrastructure** — the machinery through which the banking product is built and operated. These are not the same system. This document separates them clearly and synthesizes the full picture from 19 confirmed sources.

---

## §2 — Two-Engine Model: Banking + Private

### The Two Systems

**System A — Banking Engine (product)**
What the *customer* uses. An Intent-First AI banking product built for FCA-regulated operation. Decisions are regulated, auditable, governance-gated, subject to FCA CASS 15, MLR 2017, EU AI Act, SM&CR. Learning loop (BDSL) is append-only, human-gated, explainable by construction. Operates on evo1/evo2.

**System B — Legion Private Engine (infrastructure for the operator)**
What the *operator and Software Factory* uses. An autonomous private engineering system running on Legion that builds, deploys, monitors, and evolves the banking product. Its decisions are operational, not regulated financial decisions. Learning loop (MetaClaw/Hermes) optimizes factory velocity and correctness. Operates on Legion (with evo1/evo2 as execution targets via Tailscale 100.x).

### Two Legion Circuits (S-18 C1, S-19 Q1 — NOT a contradiction, by design)

**(a) Private Engine circuit** — OpenManus + uncensored Qwen3.6. Operates autonomously on Legion. Purpose: dev/research/operator tasks. NOT part of banking compliance zone. Currently: blueprint/not-deployed (§AUDIT-2026-07-10: llama-server :8080 + OpenManus :8000 NOT LISTENING).

**(b) Banking thin-client circuit** — only a thin routing client on Legion; all banking execution on evo1 (ADR-103). Failover: evo1 → evo2. Both reachable via Tailscale 100.x. Legion is NOT a fallback for banking logic.

Data boundary: Legion cannot write to the banking ledger, cannot execute compliance operations autonomously. Legion access to the banking zone: read-only, logged, no write. ADR-103 is the canonical authority.

### Side-by-Side Comparison

| Attribute | Banking Engine | Legion Private Engine |
|-----------|---------------|----------------------|
| Primary user | Client / MLRO / Compliance Officer | Operator / Software Factory Lead |
| Output | Client money movement, compliance rulings | Code, specs, deployments, CI/CD |
| Regulatory envelope | FCA/PRA/EU AI Act — HIGH | None (internal tooling) |
| Failure cost | Client fund loss, regulatory breach | Delayed build (recoverable) |
| Orchestrator (S-18 C7, S-19 B3) | **LangGraph** — stateful, auditable, HITL-native | **OpenManus** — autonomous browser/bash, research |
| Learning loop | BDSL: MAUT + append-only + human-gated | MetaClaw: RL trajectory distillation + Hermes episodic memory |
| Autonomy ceiling | L2_REVIEW (PROPOSED) / L3 (ENROL, human-gated) | High autonomy; no FCA exposure |
| Inference | Self-hosted evo1/evo2 (Ollama :11434, LiteLLM :4000 active on evo1) | Local Qwen3.6 on Legion (NOT YET DEPLOYED — §AUDIT) |
| Memory stack | Qdrant + Zep/Graphiti (evo1) — NOT YET DEPLOYED | Qdrant + Mem0 (Legion) — NOT YET DEPLOYED |
| EMI scope | AML/KYC/PAYMENT/COMPLIANCE — ACTIVE | Not applicable (operator tooling) |
| Credit scope | **DORMANT** — bank-license expansion required | Not applicable |

### MAUT Analysis: Key Architecture Forks

Weights: **reg=0.40 / harm=0.30 / rev=0.15 / cost=0.15** (proposed; MLRO/CRO sign-off required).
Sensitivity: reg-weight stable in range 0.32–0.48 (rank order unchanged ±20%) — S-18 C9.

| Fork | Winner | Weighted score | Runner-up | Reason |
|------|--------|---------------|-----------|--------|
| Banking orchestrator | **LangGraph** | 0.87 | Temporal (0.79, OPEN ITEM) | reg: checkpoint = auditable state; harm: native HITL gates |
| Legion orchestrator | **OpenManus** | preferred | LangGraph (N/A) | reg irrelevant for factory; cost/velocity dominate |
| Memory architecture | **Separate instances** | 0.86 | Shared (0.38, EXCLUDED) | Shared = DLP violation; harm=0.25 |
| Banking inference | **Self-hosted** | 0.86 | Cloud API (0.64, conditional) | GDPR/FCA: no PII cloud egress (INV-AI-01) |

Temporal: OPEN ITEM — if cross-service saga pattern with guaranteed delivery is required, Temporal adds value over LangGraph alone. Requires ADR before adoption.

---

## §3 — Shared Foundation Across Both Engines

### Seven Layers (Both Engines)

| Layer | Generic concept | Banking Engine | Legion Private Engine |
|-------|----------------|----------------|----------------------|
| **L0 — Constitutional** | Immutable rules | CLAUDE.md invariants I-01..I-28, FCA constraints, EU AI Act | SOUL.md per profile, operator canon, Central/Terminal topology (ADR-153) |
| **L1 — Decision/Governance** | Rules for consequential choices | ADR-046 DecisionRecord schema, BDSL invariants, HITL gates, SM&CR | BEST-SINGLE-ARTIFACT rule, ADR-120 worktree isolation, G-5 hook |
| **L2 — Orchestration** | Agent coordination | LangGraph DAG planner over passports, Compliance Swarm, Verify API (2/3 consensus) | Ruflo (RaftBFT, 98 agents), OpenClaw, Hermes 24/7 dispatch |
| **L3 — Agent / Fleet** | Specialist agents | 47 passports (ENROL=15, DEFER=9, EXCLUDE=23) | Hermes (factory/banxe-ops/client-advisor), MetaClaw, MiroFish, IronClaw, NanoClaw |
| **L4 — Runtime / Integration** | Execution environment | evo1 (Ollama :11434, LiteLLM :4000, compliance API :8085, Jube :5001, Marble :5002, n8n), evo2 | Legion (LiteLLM :4000 active, ollama.service active), evo1/evo2 via Tailscale |
| **L5 — Operator Interface** | Operator control | HITL gates, Marble Case Management, MLRO/COO approvals | Telegram, factory task dispatch (`claude -p`), Central read-only diagnostics |
| **L6 — Audit/Learning** | Improvement and verification | BDSL: append-only ClickHouse, DecisionRecord with MAUT, human-gated activation | MetaClaw: skill synthesis, ClawArena benchmark scoring, Guardian (:8195/:8196) |

### What Is Shared Operationally

| Pattern | Shared? | Note |
|---------|---------|------|
| Factory quality gates (ruff, mypy, pytest, semgrep) | ✅ YES | Apply equally to both engines |
| Source hierarchy Level 0-4 | ✅ YES | Regulatory always wins |
| Tool Registry pattern | ✅ YES | Banking fields: `invariants:`, `hitl_required:`; factory fields: `permissions:`, `terminal:` |
| SOUL.md persona discipline | ✅ YES | Banking agents include HITL gate declarations |
| Audit-first action model | ✅ YES | Banking agents: L3 gate is mandatory; Legion: practice only |
| BEST-SINGLE-ARTIFACT rule | ✅ YES (design principle) | Banking agents: must still satisfy DecisionRecord schema (I-BDSL-3) |
| MetaClaw RL distillation | ❌ NO for banking BDSL | Would violate I-BDSL-2 (Human-Gated Activation) |
| Hermes autonomous scheduling | ❌ NO for banking | Would violate I-BDSL-2 and EU AI Act Art.14 |
| Ruflo swarm autonomy | ❌ NO on money movement | L3 gate mandatory for banking money movement |

---

## §4 — Banking Engine: Active EMI Scope

### What the Banking Engine Is

The Banking Engine is EMI BANXE AI BANK as defined in ADR-045 (S-13). Intent-First AI product:
- Primary interface: conversational intent (L1)
- Banking capabilities surfaced *through* intent, not as the entry point
- Every consequential agent action passes through the Governance & Compliance layer (L3)
- Learning loop: BDSL — bounded by human-gated activation, append-only immutability, explainability

### Active EMI Operational Scope

The following domains are ACTIVE under the current EMI license. BDSL enrollment applies to these circuits:

| Domain | Status | Key agents |
|--------|--------|------------|
| AML / fraud screening | ✅ ACTIVE | `aml_orchestrator`, `fraud_tracer`, `crypto_aml_graph`, `ato_prevention` |
| KYC/KYB onboarding | ✅ ACTIVE | `jube_adapter`, `yente_adapter`, `kyb_onboarding` |
| Payment routing | ✅ ACTIVE | `payment_router_agent`, `batch_payments`, `multi_currency` |
| Compliance monitoring | ✅ ACTIVE | `compliance_monitoring_agent`, `sanctions_check` |
| Safeguarding / reconciliation | ✅ ACTIVE | `safeguarding_recon_governor` |
| Reporting (FIN060) | ✅ ACTIVE | `reporting_agent`, `treasury_alm_agent` |
| PSD2 / open banking | ✅ ACTIVE | existing agents / CTX-04 |
| FX exchange | ✅ ACTIVE | `reporting_agent` + Frankfurter ECB |

### BDSL as the Governance Substrate

Three invariants (pinned sha `e8c65d1f...`, S-12):

**I-BDSL-1 — Append-Only Immutability:** Every learning signal, decision record, and feedback event is append-only. No UPDATE or DELETE on audit tables. Schema: `schemas/agent_decision_record.schema.json` (sha `a95d8e95...`).

**I-BDSL-2 — Human-Gated Activation:** Autonomous execution upgrades require explicit human approval before effect. Gate mechanics: `governance/novelty-pipeline-config.yaml`.

**I-BDSL-3 — Explainability by Construction:** Every decision must carry machine-readable explanation traceable to input signals and active policy version.

**BDSL relationship to BUG-007 (S-18 C3):** BDSL thresholds (90/70/95) are a learning overlay on top of live BUG-007. BUG-007 (`.claude/rules/agents.md`) remains the PRIMARY control. BDSL adds audit and improvement loop — does NOT replace BUG-007.

**Production activation prerequisites:**

| Prerequisite | Owner | Status |
|--------------|-------|--------|
| Back-testing on historical data | CTO / Data team | NOT DONE |
| MLRO formal approval | MLRO (SMF17) | NOT DONE |
| Model card + risk management system (EU AI Act) | CTO / Compliance | NOT DONE |

Until all three met: **BDSL = advisory mode only**. Auto-execution upgrade blocked (I-BDSL-2).

### ADR-045 Four-Layer Reference Model

```
L1 — Intent Layer (client conversational)
     Technology: HII (Hybrid Intent Interface), assistant-ui, Whisper, Rasa NLU

L2 — Execution Layer (agents)
     47 passports cover 91/91 domain services
     Orchestrator: LangGraph DAG (to be built — Horizon 2)

L3 — Governance & Compliance Layer (cross-cutting)
     AML/KYC, HITL gates, Decision Lineage, cost-policy
     Implementation: BDSL DecisionRecord, HITL service, ADR-046

L4 — Data & Intelligence Layer
     Midaz Ledger, PostgreSQL, ClickHouse (5yr TTL),
     Frankfurter FX, dbt, ORG audit trail
```

### Passport Fleet State (2026-07-10)

```
Runtime services:    106
Infra (out-of-scope): 15
Domain services:      91  (100% coverage, 0 true orphans)
Passports:            47  (34 existing + 13 PROPOSED)

BDSL classification:
  ENROL:   15  (consequential decisions → must emit DecisionRecord)
  DEFER:    9  (consequential but needs scope review)
  EXCLUDE: 23  (platform / infra / advisory — no autonomous financial decisions)

13 PROPOSED passports:
  status: PROPOSED, autonomy: L2_REVIEW (ceiling)
  NOT activated. Operator sign-off PR required.
  MLRO written sign-off required for case_management_agent (RED/SMF17).
```

**ENROL vs EXCLUDE criteria (S-18 C8):**

| Classification | Criterion |
|---------------|-----------|
| ENROL | Output affects payment / KYC / AML decisions; OR processes client personal data in compliance context |
| EXCLUDE | Orchestrators (route only), data-fetchers (read/display), formatters (no decision authority) |

Final decision: MLRO/Compliance Officer. ENROL candidates from 13 PROPOSED: `case_management_agent` (1 confirmed). Remaining 12: passport coverage only.

### What Is Missing for Banking Engine Production

1. **BANXE-INTENT-ENGINE** — LangGraph DAG planner over passports. Single most important missing component.
2. **Banking Qdrant** — Semantic memory between sessions on evo1. Status: NOT DEPLOYED (§AUDIT-2026-07-10).
3. **Tool Registry** — `banxe-architecture/tools/registry.yaml` — unified manifest.
4. **Agent Communication Protocol** — standardized message envelope with `trace_id`, `correlation_id`, decision lineage.
5. **Schema reconciliation ADR** — `ADR-schema-reconciliation-decisionrecord.md` pending ratification.

P0 blockers from S-03: midaz-Redis missing (172.20.0.1:6379), banxe-recon.service FAILED, hardcoded `api_key="sk_live_abc123"` in gateway.py, ANTHROPIC_API_KEY not set, qwen3-banxe-v2 alias missing. **[VERIFY CURRENT STATUS — may be resolved]**.

---

## §5 — Banking Engine: Latent Bank-License Scope

### Canonical Rule: EMI Scope vs Dormant Bank-Grade Capabilities

```
CANONICAL — 2026-07-10

Current EMI mode: BANXE does NOT lend, does NOT issue credit,
does NOT operate a credit/financial-markets contour.

Credit decisioning, credit ratings, lending, loan origination,
insurance underwriting, market-facing banking functions,
card-credit facilities = INTENTIONALLY DORMANT.

This is NOT a defect. This is a license boundary.
Dormant capabilities must remain in the architecture as hidden
branches — not deleted — for activation-on-license-expansion.

Language: "dormant bank-grade capabilities",
          "activation-on-license-expansion",
          "intentionally inactive under current EMI license scope"
```

### EMI Scope vs Bank-License Scope Table

| Capability | EMI scope | Bank-license scope | Current state |
|------------|-----------|-------------------|---------------|
| Payment routing (SEPA, SWIFT, FPS) | ✅ Active | ✅ Active | ACTIVE |
| AML/KYC/CDD screening | ✅ Active | ✅ Active | ACTIVE |
| Safeguarding / reconciliation (CASS 15) | ✅ Active | ✅ Active | ACTIVE |
| FX exchange (Frankfurter ECB) | ✅ Active | ✅ Active | ACTIVE |
| Open banking (PSD2/CAMT.053) | ✅ Active | ✅ Active | ACTIVE |
| Reporting (FIN060, RegData) | ✅ Active | ✅ Active | ACTIVE |
| Sanctions / FATF screening | ✅ Active | ✅ Active | ACTIVE |
| Credit decisioning / credit scoring | ❌ Out of EMI scope | ✅ Active | **DORMANT** |
| Lending / loan origination | ❌ Out of EMI scope | ✅ Active | **DORMANT** |
| Insurance underwriting | ❌ Out of EMI scope | ✅ Active | **DORMANT** |
| Savings products / interest-bearing | ❌ Out of EMI scope | ✅ Active | **DORMANT** |
| Card credit facilities | ❌ Out of EMI scope | ✅ Active | **DORMANT** |
| Market-facing banking (proprietary trading) | ❌ Out of EMI scope | ✅ Active (if licensed) | **DORMANT** |

### Architecture: Hidden Branch Pattern

Dormant bank-grade capabilities are preserved as disabled code paths — not wired to any active agent flow:

```
services/
  credit/        → exists; not wired to any ACTIVE agent flow
  lending/       → exists; no passport / no BDSL enrollment
  savings/       → exists; no active agent
  insurance/     → exists; no active agent

agents/passports/
  credit_decision_agent.yaml   → DOES NOT EXIST YET
                                 (correct under current EMI scope)

ACTIVATION PATH:
  1. Banking license obtained
  2. credit_decision_agent.yaml created (Art.62 compliant)
  3. EU AI Act formal classification completed (≤ Dec 2027)
  4. MLRO + Legal sign-off
  5. Dormant branch activated
```

### apar_agent Classification Under Current EMI Scope

`finance/apar_agent.yaml` contains credit-terms logic (AP/AR management with embedded credit-term decisions). Under current EMI scope, classified as:

**→ Preparatory task under EU AI Act Art.6(3)(b) — NOT high-risk (see §7 for Art.6(3) detail)**

Rationale (S-19 Q5, S-18 C2): If `apar_agent` prepares data for human decision-making without making autonomous credit decisions, it qualifies for the Art.6(3) filter. It is performing a "preparatory task" — does not directly determine access to credit services. This excludes it from Art.62 high-risk classification under current EMI scope.

Condition: `apar_agent` must NOT autonomously approve/reject credit facilities. Human-in-the-loop mandatory on all credit-adjacent outputs.

Formal classification exercise: required before **2 December 2027**.

### Activation Conditions for Dormant Bank-Grade Capabilities

| Condition | Owner | Dependency |
|-----------|-------|-----------|
| Banking license obtained | CEO / Board | Regulatory process |
| `credit_decision_agent.yaml` created | CTO + Compliance | Post-license |
| EU AI Act Art.62 conformity assessment | Compliance + External auditor | ≤ Dec 2027 after activation |
| MLRO sign-off on credit BDSL enrollment | MLRO (SMF17) | Post-license |
| Technical documentation per Art.13 | CTO | Post-license, pre-launch |
| Registration in EU AI Database | Compliance | Before credit system goes live |

**Until banking license: CREDIT circuit = DORMANT BY DESIGN. Not a blocker for current AML/KYC/PAYMENT/COMPLIANCE BDSL activation.**

---

## §6 — Private Legion Engine Foundation

### Three-Layer Architecture

**Layer A — Foundational Substrate (Hermes/Factory/ORG)**
Constitutional and orchestration foundation. Operator canon, terminal topology, Central/Left/Right discipline, factory quality loop. Sources: S-07, S-08, S-10, ADR-153, CLAUDE.md. This is the *governance* of the private engine — analogous to BDSL in the banking engine. Cannot be replaced without a new ADR.

**Layer B — Runtime Implementation**
Practical execution machinery: local LLM server (llama-server :8080), FastAPI agent engine (OpenManus-style :8000). Source: S-17 (confirmed, SHA f937c55f...). **Status per §AUDIT-2026-07-10: NOT DEPLOYED. Blueprint only. Live on Legion: Ollama :11434 + LiteLLM :4000.**

**Layer C — Interface Layer**
Operator access channels: Telegram bot (polling), Open WebUI (rich local), LibreChat (MCP-native), mobile apps (Enchanted LLM iOS, Open Mobile UI Android). Source: S-17 (confirmed). Multiple can coexist; none architecturally mandatory.

### Layer A: Agent Stack (confirmed S-07)

| Agent | Role | Terminal |
|-------|------|----------|
| OpenClaw | Control plane: ADR drafting, spec writing, coding, docs, DevOps | Central |
| MetaClaw | Transparent proxy: skill injection, RL trajectories, cross-session memory | Central |
| Ruflo | Swarm: 98 agents, RaftBFT consensus, AgentDB HNSW | Central |
| IronClaw | Security auditor: WASM sandbox, AES-256, TEE-secured inference | Right (evo2) |
| NanoClaw | TDD generator: Jest/Vitest, 700M-parameter specialist | Central |
| MiroFish | Prediction + Risk: OASIS 100-world simulation, VaR, Greeks | Right (evo1) |
| MicroFish | Privacy layer: offline inference, MiCA/CASP checks | Right (evo2) |
| ClawArena | Benchmark judge: MetaClaw integration, CI scoring | Central |
| Hermes | 24/7 autonomous server: episodic memory, self-improving skills | evo2 VPS (proposed) |

**Hermes three-profile deployment (S-07):**
- `factory`: task dispatching, CI/CD, sprint ledger (Telegram → factory channel)
- `banxe-ops`: operations monitor — AML alerts, MiroFish feeds, system health (read-only on banking data)
- `client-advisor`: DSS recommendations, MiCA disclaimer, no autonomous execution

**Hermes Art.6(3) status (S-19 B4):** Hermes client-advisor profile qualifies as advisory-only under Art.6(3)(b) — output is information, not a decision. Human-in-the-loop mandatory before any action → not a high-risk AI system under current scope. Formal classification memo required (→ WP-S19-03).

### Terminal Topology Canon (ADR-153)

- **Central** = dispatcher / arbiter / operator governance. Read-only diagnostics direct; all mutations through factory.
- **Terminal A (Left)** = Software Factory — orchestrator-executor. Self-orchestrates.
- **Terminal B (Right)** = Special-mandate (TRADING-001).
- **No-Wait Rule (immutable):** Central NEVER waits for Terminal A.
- **Best-Single-Artifact Rule:** After any output, Central emits exactly ONE next-action artifact.

### MetaClaw Learning Loop

Transparent proxy in front of OpenClaw. Intercepts all trajectories, synthesizes skills during idle periods (≥5min), injects verified skills into subsequent calls (few-shot ICL, not fine-tuning). Phase 1: `rlmode: false` — accumulating trajectories. Phase 3: RL via cloud LoRA. NOT applicable to BDSL (would violate I-BDSL-2).

### DLP Boundary: Legion → Banking Zone (S-18 C4, S-19 B5)

Legion agent with browser/search tools MUST NOT output to any interface:
- Client PII (names, IBAN, transaction data, KYC records)
- API keys, credentials, tokens from banking zone
- Source code from production banking repositories
- Audit logs or compliance reports

**DLP implementation stack:**

| Layer | Tool | License |
|-------|------|---------|
| Programmatic output filter | NeMo Guardrails (NVIDIA) | Apache 2.0 |
| Secondary filter | LlamaFirewall | Apache 2.0 |
| OS-level isolation | Landlock (Linux 5.13+) + seccomp + namespaces | Kernel built-in |

Access rules: READ status/metrics = YES (logged, read-only endpoint only); WRITE to ledger/DB = NO (hard-blocked); Credentials transfer = NO.

Status: design complete (S-18); NOT YET DEPLOYED. Horizon 1 task.

### Memory Boundary: Banking vs Legion (S-18 C5)

Two separate Qdrant instances — NO shared access. **Both NOT DEPLOYED per §AUDIT-2026-07-10.**

**Banking Engine (evo1):** Qdrant (semantic search, banking knowledge) + Zep Apache 2.0 (Temporal KG, client context) + Graphiti (temporal KG with versioning) + LlamaIndex (regulatory document ingestion pipeline)

**Legion Private Engine (Legion):** Qdrant (dev/research semantic search) + Mem0 Apache 2.0 (long-term operator session memory)

Hard boundary rules:
- Banking Qdrant: NOT directly accessible from Legion agent
- Legion Qdrant: contains NO banking client PII
- Cross-engine sync: only through explicit human-approved export with audit trail

---

## §7 — New Architecture Document: Extracted Contributions (S-19)

*Source: S-19 (sha 719494c4..., 298 lines, 36628 bytes). This section extracts architectural content not present in prior sources and applies it across three integration tracks.*

### Integration Type A — Shared Engine Principles

**Framework evaluation table (S-19 B3):**

| Framework | Banking Engine | Private Legion | Reason |
|-----------|---------------|----------------|--------|
| **LangGraph** | ✅ Canon | ❌ Overkill | Stateful, auditable, durable, native HITL, threshold-gate compatible |
| **OpenManus** | ❌ No compliance | ✅ Canon | Autonomous browser/bash, research tasks, no compliance constraints |
| **DeerFlow** (ByteDance) | ❌ | ⚠️ Alternative | Docker-sandbox isolation, deep research; not local-first |
| **CrewAI** | ❌ Rejected | ⚠️ Prototype | No auditable state machine, no HITL of required depth |
| **AutoGen** (Microsoft) | ❌ Rejected | ⚠️ R&D only | Probabilistic, no audit trail; .NET support |

**Memory layer roles (S-19 B3):**

| Tool | Type | Banking use | Legion use | Compliance |
|------|------|-------------|------------|------------|
| **Qdrant** | Vector store (semantic) | RAG over policies, KYC docs | Dev/research semantic search | ✅ DataSunrise audit trail (banking instance) |
| **Mem0** | Long-term personal memory | ❌ SaaS option = not for banking PII | Operator session context | ⚠️ Self-hosted only |
| **Zep / Graphiti** | Temporal knowledge graph | Client context history + versioning | ❌ Not needed | ✅ Open-source, self-hosted |
| **LlamaIndex** | Document ingestion pipeline | Regulatory document ingestion | ❌ | ✅ Self-hosted |

**Source hierarchy (S-19 B6):** See §0. Key addition: LEVEL 4 explicitly separates working drafts and consultant analysis from the operational hierarchy. S-01..S-19 are Level 4 material informing Level 1 ADRs.

**Implementation inventory audit matrix (S-19 B6):** Fill from live system state before finalizing roadmap:

| Component | Required state | Audited 2026-07-10 status |
|-----------|---------------|--------------------------|
| llama-server on Legion :8080 | RUNNING | ❌ NOT LISTENING |
| OpenManus :8000 | RUNNING | ❌ NOT LISTENING |
| Banking Qdrant on evo1 | RUNNING | ❌ NOT FOUND anywhere |
| Legion Qdrant | RUNNING | ❌ NOT FOUND anywhere |
| LangGraph banking agents | PRESENT | ❌ Not built |
| BDSL threshold layer (novelty-pipeline-config.yaml) | PRESENT | Code present, not emitting |
| NeMo Guardrails | CONFIGURED | ❌ Not deployed |
| EU AI Act risk management docs | PRESENT | ❌ Not created |
| evo1 short-name resolution from Legion | WORKING | ❌ BROKEN (Tailscale 100.x works) |
| Ollama on evo1 :11434 | RUNNING | ✅ ACTIVE |
| LiteLLM on evo1 :4000 | RUNNING | ✅ ACTIVE |
| Legion LiteLLM :4000 | RUNNING | ✅ ACTIVE |
| Legion Ollama service | RUNNING | ✅ ACTIVE |
| evo2 Prometheus :9090 | RUNNING | ✅ REGISTERED 2026-05-11 |

### Integration Type B — Private Engine Track

**DeerFlow as OpenManus alternative (S-19 B3):**
ByteDance DeerFlow offers Docker-sandbox isolation for deep research multi-step tasks. Advantages: stricter sandbox, better Docker integration. Disadvantage: less mature local-first deployment. **Current decision: OpenManus remains canon for Legion. DeerFlow = evaluation candidate in Horizon 3-4.**

**AutoGen and CrewAI (S-19 B3):**
- CrewAI: prototype-only for Legion (role-based multi-agent, fast setup, no production-grade state management)
- AutoGen: R&D-only for Legion (.NET-friendly, good for evaluating multi-agent patterns offline)

**BDSL does NOT apply to Legion (S-19 B1):** BDSL is a governance layer for banking decision systems. OpenManus on Legion is a dev/research operator tool. Different scope.

**Mem0 for Private Engine:** Self-hosted deployment required (no SaaS option for any data touching production context). Mem0 is Apache 2.0 — deployable locally on Legion. Status: NOT DEPLOYED (§AUDIT).

### Integration Type C — Banking Engine Track (Universal Parts)

**LangGraph canonical status — specific technical reasons (S-19 B3, B1):**
- Stateful via checkpoint-based persistence (every state transition logged)
- Durable execution: persists workflow state across restarts
- Native HITL support: graph nodes can suspend awaiting human input
- Threshold-gate compatible: BDSL thresholds as conditional edges

**Temporal role (S-19 B3):** If LangGraph implements durable workflows through checkpoint + async, Temporal may be redundant for baseline CASS 15 workflows. If cross-service saga pattern with guaranteed delivery needed → Temporal adds value. **Status: OPEN ITEM — requires ADR. LangGraph-first default.**

**Qdrant for banking with DataSunrise (S-19 B3):** Banking Qdrant instance (evo1) must be monitored via DataSunrise for audit trail compliance — provides logging and monitoring wrapper over Qdrant operations. Mechanism to satisfy I-24 for vector store operations. Status: NOT DEPLOYED.

**Art.6(3) preparatory task filter (S-19 B4):** An agent is excluded from EU AI Act high-risk classification if its output "improves the result of a previously completed human activity" or performs a "preparatory task" without directly determining access to services. Mechanism for advisory-only agents (Hermes client-advisor, apar_agent under EMI scope) to avoid high-risk enrollment. Final determination: MLRO/Compliance with documented justification.

---

## §8 — Search, Retrieval, and External-Resource Architecture

### Banking Engine: Retrieval Stack

**Qdrant (semantic vector search):**
- Deployment: Docker on evo1 (designed; NOT DEPLOYED per §AUDIT)
- Indexes: passport files, FCA regulatory documents, AML policy corpus, CASS 15 guidance, MLR 2017
- Bounded by GDPR: client vectors stored on-premise, no cloud egress (INV-AI-01)
- Audit trail: DataSunrise monitoring wrapper over Qdrant instance (→ WP-S19-06)
- Use in banking: RAG context for LangGraph nodes (policy lookup, EDD precedent, FIN060 data)

**Zep / Graphiti (temporal knowledge graph):**
- Deployment: self-hosted evo1 (designed; NOT DEPLOYED)
- Zep: client banking context history with temporal versioning
- Graphiti: version-controlled KG entries, suitable for compliance decision lineage

**LlamaIndex (document ingestion pipeline):**
- Not a memory store — an ingestion orchestrator
- Pipeline: PDF/HTML regulatory docs → chunking → embedding → Qdrant insert
- Sources: FCA PS documents, MLR 2017, DORA, EU AI Act text, CASS 15 guidance
- Runs as periodic job on evo1

### Legion Private Engine: Retrieval Stack

**Qdrant (dev/research):** Separate instance on Legion (NOT DEPLOYED per §AUDIT). Dev/research indexes only. No banking PII.

**Mem0 (operator long-term memory):** Self-hosted on Legion. Tracks cross-session context for operator. NOT DEPLOYED.

### External Resource Acquisition

**Web search tools (Layer B, S-17, S-19):**

| Tool | Rate limit | API key | Use case |
|------|-----------|---------|---------|
| `google_search.py` | 100 req/day (free tier) | Required (Google Custom Search) | High-quality specific queries |
| `duckduckgo_search.py` | DDG rate limits apply | Not required | Quick search, no quota concerns |
| `browser_use_tool.py` (Playwright) | No hard limit | Not required | Full web interaction: click/scroll/form/screenshot |

**External resource governance:**

| Resource type | Governance rule |
|--------------|----------------|
| Regulatory documents (FCA PS, EU AI Act text) | Download once, store in banking Qdrant; re-download on material update. Never fetch live from banking agent context. |
| LLM model weights (Qwen3.6-35B-A3B) | Pin to specific quantized GGUF hash. Never auto-update in production. |
| Docker images (Open WebUI, Qdrant, Mem0) | Pin to specific version tag. Update requires test in non-prod first. |
| Python packages (LangGraph, OpenManus) | Pin in `requirements.txt` or `pyproject.toml`. |
| Google Custom Search API | 100 req/day free tier; key in `.env` (never in code — `banxe-hardcoded-secret` Semgrep rule). |

**What must be mirrored / pinned / localized:**
- Qwen3.6-35B-A3B model GGUF → mirrored on Legion disk; no cloud dependency at runtime
- Banking Qdrant data → on-premise evo1; GDPR requires no cloud egress (INV-AI-01)
- LiteLLM v2 router → self-hosted evo1 (already active); routes only to on-premise models for banking
- Frankfurter ECB FX rates → self-hosted Frankfurter instance (per CLAUDE.md P0 stack)
- Regulatory document corpus → ingested into banking Qdrant; source URLs logged but data pinned

---

## §9 — Runtime, Installation, and Integration Posture

### Infrastructure State (§AUDIT-2026-07-10 — ground truth)

| Node | LAN IP | Tailscale | Confirmed running |
|------|--------|-----------|-------------------|
| evo1 | 192.168.0.72 | 100.68.102.48 | Ollama :11434, LiteLLM :4000, llama.cpp RPC |
| evo2 | 192.168.0.15 | 100.99.208.21 | Ollama :11434, RPC :50052, Prometheus :9090, Grafana :3000 |
| Legion | LAN | — | LiteLLM :4000, Grafana/WebUI :3000, ollama.service |

**evo1 name resolution issue:** short-name `evo1` NOT resolving from Legion. Must use Tailscale `100.68.102.48` until DNS/hosts/MagicDNS fixed.

### Required Dependencies: Legion Private Engine

| Component | Install method | Status (§AUDIT) |
|-----------|---------------|-----------------|
| llama.cpp / llama-server | Build from source or binary | ❌ NOT DEPLOYED |
| Qwen3.6-35B-A3B IQ2_M GGUF | Download from HuggingFace (pin commit) | ❌ NOT DEPLOYED |
| OpenManus | `git clone` + `pip install -e .` | ❌ NOT DEPLOYED |
| Playwright Chromium | `playwright install chromium` | ❌ NOT DEPLOYED |
| Open WebUI | `docker pull ghcr.io/open-webui/open-webui:main` | ❌ NOT DEPLOYED |
| Mem0 | `pip install mem0ai` (self-hosted) | ❌ NOT DEPLOYED |
| DuckDuckGo search | `pip install duckduckgo-search` | ❌ NOT DEPLOYED |
| Ollama :11434 | Running | ✅ ACTIVE |
| LiteLLM :4000 | Running | ✅ ACTIVE |

### Required Dependencies: Banking Engine Additions

| Component | Install method | Status |
|-----------|---------------|--------|
| Qdrant | `docker pull qdrant/qdrant` | ❌ NOT DEPLOYED |
| Zep | `docker pull ghcr.io/getzep/zep` | ❌ NOT DEPLOYED |
| Graphiti | `pip install graphiti-core` | ❌ NOT DEPLOYED |
| LlamaIndex | `pip install llama-index` | ❌ NOT DEPLOYED |
| NeMo Guardrails | `pip install nemoguardrails` | ❌ NOT DEPLOYED |
| LlamaFirewall | `pip install llamafirewall` | ❌ NOT DEPLOYED |
| DataSunrise | Docker or native | ❌ NOT DEPLOYED |
| Ollama :11434 (evo1) | Running | ✅ ACTIVE |
| LiteLLM :4000 (evo1) | Running | ✅ ACTIVE |

### Layer B Runtime Configuration (S-17, confirmed blueprint)

**llama-server (target: systemd `llama-qwen.service`):**
```
model: Qwen3.6-35B-A3B IQ2_M (quantized GGUF)
listen: :8080
GPU offload: -ngl 20, --flash-attn
context: -c 131072 (128K tokens)
KV cache: q8_0
After=network.target
```

**OpenManus FastAPI wrapper (target: systemd `openmanus-api.service`):**
```
listen: :8000
config.toml: base_url = "http://localhost:8080/v1", api_key = "none"
POST /run/agent  {"prompt": "..."} → {"status": "ok", "result": "..."}
GET  /health     → {"status": "running"}
Requires=llama-qwen.service
```

**Systemd startup order (target state):**
```
1. llama-qwen.service          → Qwen model loads (~30-60s)
2. openmanus-api.service       → Requires=llama-qwen.service
3. open-webui Docker container → After systemd services ready
4. Telegram bot process        → After openmanus-api healthy
```

### evo1 Infrastructure Status (S-19 Q2 — CRITICAL RISK)

evo1 is confirmed reachable via Tailscale (100.68.102.48). However:
- Short-name resolution from Legion: BROKEN (→ WP-S19-03 fix: update /etc/hosts or configure MagicDNS)
- evo1 availability: operational (Ollama :11434, LiteLLM :4000 active)
- evo1 as banking engine host: confirmed primary. Failover: evo2 (registered, Tailscale 100.99.208.21)

**Fallback to Legion without compliance controls is NOT a valid option (S-19 Q2, ADR-103).**

### MAUT Weight Elicitation (S-19 B2 — new requirement)

Current weights (reg=0.40/harm=0.30/rev=0.15/cost=0.15) are an expert proposal. For regulated production use, they must be **formally elicited** through:

1. **Swing-weighting** or **direct rating** with MLRO, CRO, and CTO as stakeholders
2. **Documented justification** per weight
3. **Independent validation** — external model validator (FCA/PRA SS1/23)
4. **Back-testing** — verify sensitivity analysis on actual decision data

This is a mandatory prerequisite before MAUT scores can be used as production governance signals.

---

## §10 — Mobile / Application / Operator Interface Implications

### Interface Comparison Table (S-17, confirmed)

| Attribute | Telegram | Open WebUI | LibreChat | Enchanted LLM (iOS) | Open Mobile UI (Android) |
|-----------|----------|------------|-----------|---------------------|--------------------------|
| Response length | ❌ 4096 chars | ✅ Unlimited | ✅ Unlimited | ✅ Unlimited | ✅ Unlimited |
| Markdown rendering | ⚠️ Partial | ✅ Full | ✅ Full | ✅ Full | ✅ Full |
| Native mobile | ✅ Yes | ✅ Browser | ✅ Browser | ✅ iOS native | ✅ Android native |
| OpenManus integration | ✅ Via REST | ✅ Via REST | ✅ Via MCP | ⚠️ LLM chat only | ✅ Via Open WebUI |
| Voice (TTS/STT) | ❌ | ✅ Built-in | ❌ Limited | ❌ | ❌ |
| RAG | ❌ | ✅ Built-in | ✅ Built-in | ❌ | ❌ |
| Outside LAN access | ✅ Always | ⚠️ Tunnel | ⚠️ Tunnel | ✅ Tunnel | ✅ Tunnel |
| Setup complexity | Simple (token) | Docker (1 cmd) | Docker Compose | App Store install | Google Play install |

All Layer C interfaces: **NOT DEPLOYED** (§AUDIT-2026-07-10). Blueprint from S-17.

### Telegram Bot Long-Output Pattern

4096 character limit — hard constraint:

```python
if len(result) > 4000:
    # Preferred: save artifact + send file
    artifact_path = workspace / f"result_{timestamp}.txt"
    artifact_path.write_text(result)
    await update.message.reply_document(document=open(artifact_path, "rb"))
```

### Remote Access Options

| Option | Stability | Cost | URL stability |
|--------|-----------|------|--------------|
| **Cloudflare Tunnel** (recommended) | Permanent URL | Free | Stable across restarts |
| ngrok | URL changes on restart (free plan) | Free/paid | Unstable on free |

### Hermes Telegram vs OpenManus Telegram — NOT competing

| Aspect | Hermes `factory` profile | OpenManus Telegram bot |
|--------|--------------------------|----------------------|
| Backend | Claude (`claude -p` factory) | Local Qwen3.6 (llama-server :8080) |
| Use case | Factory task dispatch, CI/CD, sprint ledger | Local research: browser, bash, search, file ops |
| Banking access | Factory read-only | None (local tasks only) |

Complementary Layer A and Layer B channels. Both can coexist on different bot tokens/channels.

---

## §11 — Unified Roadmap

### Horizon 0 — Canonicalization (NOW, no build required)

**Shared:**
- [x] ORG-CODE-RECONCILIATION-v2 authoritative (sha b84a4bab...) — DONE
- [x] BDSL pinned source canon (sha e8c65d1f...) — DONE
- [x] 47 passports classified ENROL/DEFER/EXCLUDE — DONE (v3)
- [x] Credit circuit reframed as DORMANT BY EMI SCOPE (§5) — DONE in this document
- [ ] Schema reconciliation ADR (`ADR-schema-reconciliation-decisionrecord.md`) — PENDING ratification
- [ ] Three ADR-045 gaps: Decision Lineage, AI cost policy, S13-00 BPR — PENDING

**Banking Engine:**
- [ ] Operator sign-off PR for 13 PROPOSED passports (MLRO for case_management_agent)
- [ ] Art.62 formal classification exercise initiation (preparatory task vs high-risk for apar_agent)
- [ ] evo1 short-name resolution from Legion (fix /etc/hosts or Tailscale MagicDNS) — §AUDIT

**Legion Private Engine:**
- [ ] Verify evo1 reachability via Tailscale from Legion (100.68.102.48) — §AUDIT confirms yes
- [ ] DLP layer design ratified (NeMo Guardrails + LlamaFirewall + OS-sandbox)
- [ ] Memory boundary design ratified (separate Qdrant/Mem0 on Legion; Qdrant/Zep/Graphiti on evo1)
- [ ] Two-circuit ADR drafted (Private Engine circuit vs banking thin-client circuit, ADR-103 boundary)

---

### Horizon 1 — Buildable Foundations (~2 weeks)

**Shared:**
- [ ] P0 blockers verified and resolved: banxe-recon.service, midaz-Redis, hardcoded key, ANTHROPIC_API_KEY, qwen3-banxe-v2 alias — **VERIFY CURRENT STATUS FIRST**
- [ ] Tool Registry `banxe-architecture/tools/registry.yaml`
- [ ] Implementation inventory audit (§7 matrix) — update status column from §AUDIT-2026-07-10

**Banking Engine:**
- [ ] Verify ADR-046 schema in use by at least one ENROL agent
- [ ] `governance/novelty-pipeline-config.yaml` — MAUT weights and thresholds
- [ ] `tests/best-decision/` — case-a through case-d YAML fixtures
- [ ] Operator PR: 13 PROPOSED → ACTIVE (after Horizon 0 sign-offs)
- [ ] Banking Qdrant deploy: Docker on evo1; DataSunrise monitoring wrapper (→ WP-S19-06)
- [ ] Zep + Graphiti deploy on evo1
- [ ] MAUT weight formal elicitation process (→ WP-S19-01)

**Legion Private Engine:**
- [ ] DLP implementation: NeMo Guardrails + LlamaFirewall + Landlock/seccomp
- [ ] Separate Qdrant on Legion (dev/research) + Mem0
- [ ] Fix evo1/evo2 short-name resolution from Legion
- [ ] Back-testing infrastructure for BDSL threshold validation (→ WP-S19-02)
- [ ] Google Custom Search API key setup (→ WP-S19-07)

---

### Horizon 2 — Runtime-Ready Systems (~2 weeks)

**Banking Engine:**
- [ ] **BANXE-INTENT-ENGINE**: LangGraph over 47 passports as FastAPI service
- [ ] **Agent Communication Protocol**: `trace_id`, `correlation_id`, `decision_lineage`, `agent_id`, `autonomy_level`
- [ ] LlamaIndex ingestion pipeline: regulatory documents → banking Qdrant

**Legion Private Engine:**
- [ ] **llama-qwen.service**: systemd unit for Qwen3.6-35B-A3B IQ2_M on Legion
- [ ] **openmanus-api.service**: FastAPI :8000 (Requires=llama-qwen.service)
- [ ] Confirm 7-tool set functional (bash, browser_use_tool, python_execute, duckduckgo_search, google_search, file_saver, planning)
- [ ] **Open WebUI** Docker (:3000) with Cloudflare Tunnel for remote access
- [ ] **Telegram bot** (polling) for on-the-go short tasks
- [ ] Hermes `factory` profile: formal systemd service on Legion/evo2

---

### Horizon 3 — Controlled Deployment (~3 weeks)

**Banking Engine:**
- [ ] **Client-facing Intent Interface**: Rich Cards (TransferCard, FXRailCard, CryptoOrderCard)
- [ ] **BDSL live loop**: ENROL-15 agents begin emitting DecisionRecords in advisory mode
- [ ] **Safeguarding Reconciliation**: banxe-recon.service confirmed running (FCA CASS 15)
- [ ] Submit back-testing results to MLRO for production activation approval

**Legion Private Engine:**
- [ ] **Hermes `banxe-ops` profile**: connect to MiroFish prediction feed, AML alert stream
- [ ] **ClawArena**: establish baseline benchmark, set +15%/month target
- [ ] **Mobile**: Enchanted LLM (iOS) + Open Mobile UI (Android) via Cloudflare Tunnel
- [ ] DeerFlow evaluation vs OpenManus (→ WP-S19-05)

---

### Horizon 4 — Deep Specialization (Q3–Q4 2026)

**Banking Engine:**
- [ ] **BDSL policy calibration**: first human-gated autonomy tier upgrade
- [ ] **S13-00 BPR**: formal Business Process Repository mapping intent → L2 agent graph
- [ ] **AI cost governance policy** (future ADR)
- [ ] **MiroFish integration**: VaR and stress-test through Intent Interface (read-only + I-27 HITL on execution)
- [ ] **Independent model validation**: external validator (FCA/PRA SS1/23 compliance)

**Legion Private Engine:**
- [ ] **MetaClaw Phase 3**: RL mode via cloud LoRA (`tinkercloud.enabled: true`)
- [ ] **IronClaw**: blocking integration — no code merges without IronClaw PASS on payment/auth paths
- [ ] **Factory Tool Registry v2**: automated tool discovery from passport changes

**Convergence:**
- [ ] **Benchmark-to-BDSL bridge**: ClawArena delta as quality signal input to BDSL monitoring
- [ ] **Temporal ADR**: decide LangGraph-only vs LangGraph+Temporal for cross-service sagas

---

## §12 — Roadmap Expansion After S-19 Integration

*New work packages from S-19 content not represented in prior roadmap.*

### WP-S19-01: Formal MAUT Weight Elicitation

**What:** Formal stakeholder elicitation for MAUT weights via swing-weighting or direct rating with MLRO, CRO, CTO.
**Why:** S-19 B2 confirms current weights are "consultant expert estimate, not validated." Regulatory use requires documented elicitation.
**Output:** Signed annex to ADR-MAUT-weights. Sensitivity analysis on actual decision data.
**Owner:** CTO + MLRO. **Horizon:** 1 (prerequisite for BDSL production).

### WP-S19-02: BaFin Back-Testing Documentation Package

**What:** Formal back-testing for BDSL thresholds (90/70/95) on historical transactions.
**Why:** S-19 B2: "threshold from the air without back-testing is not accepted by BaFin."
**Output:** Model card + calibration report (FP/FN rates at each threshold) + MLRO sign-off letter.
**Owner:** CTO / Data team. **Horizon:** 1-2.

### WP-S19-03: Art.6(3) Preparatory Task Formal Assessment

**What:** Written classification document for each BDSL-adjacent agent under EU AI Act Art.6(3).
**Why:** S-19 B4 identifies the preparatory task filter as the mechanism for advisory-only agents to avoid high-risk classification. Needs formal documentation.
**Scope:** `apar_agent`, `channel_c_sepa_orchestrator`, Hermes `client-advisor` profile, 9 EXCLUDE-eligible PROPOSED passports.
**Output:** Classification memo per agent, signed by MLRO/Compliance Officer.
**Owner:** Compliance. **Horizon:** 0-1.

### WP-S19-04: evo1 Name-Resolution Fix (from §AUDIT)

**What:** Fix evo1/evo2 short-name resolution from Legion.
**Why:** §AUDIT-2026-07-10: short-name NOT resolving; Tailscale 100.x works. Impacts all Legion → evo1 calls.
**Options:** (a) Update `/etc/hosts` on Legion with `100.68.102.48 evo1`; (b) Enable Tailscale MagicDNS; (c) Update all configs to use Tailscale IPs directly.
**Owner:** Operator / Infrastructure. **Horizon:** 0 (immediate, 15 minutes).

### WP-S19-05: DeerFlow Evaluation vs OpenManus

**What:** Technical comparison of DeerFlow (ByteDance) vs OpenManus for Legion Private Engine.
**Why:** S-19 B3 identifies DeerFlow as a viable alternative with better Docker-sandbox isolation.
**Output:** Evaluation report → ADR decision (keep OpenManus vs switch to DeerFlow).
**Owner:** Terminal A (Software Factory). **Horizon:** 3-4.

### WP-S19-06: DataSunrise Qdrant Audit Trail Deployment

**What:** Deploy DataSunrise monitoring wrapper over banking Qdrant instance on evo1.
**Why:** S-19 B3 identifies DataSunrise as the mechanism for Qdrant audit trail compliance (I-24). Without it, vector store operations are not in the append-only audit trail.
**Scope:** Banking Qdrant only (evo1). Legion Qdrant does not require DataSunrise.
**Owner:** CTO / Platform. **Horizon:** 2 (with Qdrant deployment).

### WP-S19-07: Google Custom Search API Key Setup

**What:** Provision Google Custom Search API key for Legion agent tool plane.
**Why:** S-17/S-19 confirm `google_search.py` requires API key (100 req/day free tier). Without key, Legion agent falls back to DuckDuckGo only.
**Action:** Create Google Custom Search engine + API key. Store in Legion `.env` (never in code). Document quota management.
**Owner:** Operator. **Horizon:** 1-2.

---

## §13 — Risks, Blockers, Dormant Branches, Activation Conditions

### Non-Goals (Boundary Conditions)

```
Banking Engine ≠ Autonomous sandbox
  Autonomy ceiling is human-gated (I-BDSL-2).
  SM&CR requires named human accountability for L3+ decisions.

Legion Private Engine ≠ Banking compliance engine
  Factory decisions are NOT financial decisions.
  MetaClaw/Hermes skill loops do NOT satisfy I-BDSL-1/2/3.

BDSL ≠ Entire Legion Engine
  BDSL is banking governance only. Not applicable to factory.

Hermes/Factory ≠ Banking governance core
  Hermes `banxe-ops`: read-only on banking data (SOUL.md constraint).
  Must NOT make autonomous client-fund decisions.

Intent Layer (L1) ≠ Chat UI bolted on
  ADR-045 explicit: conversational intent is the PRIMARY interface.
  Screen/form as primary, chat as optional = contradicts ADR-045.

Credit circuit ≠ Active EMI scope
  Credit is DORMANT under current EMI license.
  Do not wire credit agents to active payment/KYC/AML flows.
  Activation requires banking license (§5).
```

### Dormant Branch: Credit Circuit

| Item | Current state | Activation condition |
|------|--------------|---------------------|
| Credit decisioning | DORMANT — no agent passport | Banking license obtained |
| `credit_decision_agent.yaml` | Does not exist | Create after license; Art.62 compliant |
| apar_agent credit-terms logic | ACTIVE under EMI but classified as preparatory task (Art.6(3)) | Formal classification memo required (WP-S19-03) |
| EU AI Act Art.62 compliance | NOT REQUIRED until credit circuit activates | Required ≤ Dec 2027 after credit system goes live |
| Lending / savings / insurance | DORMANT — no passport, no active agent | Banking license + regulatory approval per product |

**Language to use:** "dormant bank-grade capabilities," "activation-on-license-expansion," "intentionally inactive under current EMI scope."

### Critical Infrastructure Risks

| Risk | Severity | Status |
|------|----------|--------|
| evo1 short-name resolution from Legion BROKEN | 🟡 HIGH | Fix: update /etc/hosts or MagicDNS (→ WP-S19-04) |
| Layer B (llama-server + OpenManus) NOT DEPLOYED | 🟡 HIGH | Horizon 1-2 build required |
| Qdrant NOT DEPLOYED anywhere (banking + Legion) | 🟡 HIGH | Horizon 1-2 build required |
| BDSL auto-execution without back-testing | 🔴 BLOCKED | Prerequisites §4 not met (→ WP-S19-02) |
| MAUT weights in production without formal elicitation | 🔴 BLOCKED | WP-S19-01 required |
| DLP layer not deployed (Legion → banking) | 🟡 HIGH | Horizon 1 build required |
| Schema reconciliation ADR not ratified | 🟡 HIGH | BDSL live loop blocked |
| EU AI Act Aug 2, 2026 deadline (payment fraud, AML) | 🟡 HIGH | Documentation required NOW |
| Banking engine fallback to Legion without compliance controls | 🔴 NOT PERMITTED | ADR-103 boundary (hard rule) |

### BDSL Activation Gates (Current Status)

| Gate | Status |
|------|--------|
| Passport coverage 91/91 | ✅ CLEARED |
| True orphans = 0 | ✅ CLEARED |
| ADR-046 schema confirmed | ✅ CLEARED |
| 13 PROPOSED passports operator sign-off | ⏳ PENDING operator PR |
| Schema reconciliation ADR ratified | ⏳ PENDING |
| BDSL fleet classification (ENROL=15/DEFER=9/EXCLUDE=23) | ✅ CLEARED |
| Back-testing completed | ❌ NOT STARTED |
| MLRO formal approval | ❌ NOT STARTED |
| Model card + risk management docs | ❌ NOT STARTED |
| MAUT weights MLRO/CRO sign-off | ❌ NOT STARTED |

**AML/KYC/PAYMENT/COMPLIANCE circuits:** proceed after operator signs off on 13 PROPOSED passports.
**CREDIT circuit:** DORMANT by EMI scope (§5). Not a BDSL activation gate.
**BDSL auto-execution mode:** requires all three back-testing + MLRO + model card prerequisites.

### EU AI Act Timeline (S-18 C2, S-19 B5)

| Deadline | Scope | Impact on BANXE |
|----------|-------|----------------|
| **2 Aug 2026** | Payment fraud detection, law enforcement AI, biometrics (Annex III other) | `fraud_tracer`, payment fraud agents — documentation NOW |
| **2 Aug 2026** | NEW high-risk systems entering production after this date | Any new high-risk system → full compliance immediately |
| **2 Aug 2027** | Existing high-risk systems in production before Aug 2026 | Transition period per Art.111 |
| **2 Dec 2027** | Credit scoring / AML AI high-risk (Art.62) | `credit_decision_agent` (when created), apar_agent if high-risk classification confirmed |

**Sanctions (S-19 B5):** up to €35M or 7% global turnover (prohibited practices); up to €15M or 3% for other violations.

---

## §14 — Recommended Execution Order

```
STEP 0 (operator, THIS WEEK — no build required):
  → Fix evo1 name resolution from Legion (/etc/hosts 100.68.102.48 evo1) [WP-S19-04]
  → Verify P0 blocker status (midaz-Redis, recon.service, hardcoded key, API keys)
  → Confirm CREDIT circuit is DORMANT by EMI scope (update team on §5 framing)
  → Schedule MLRO/CRO joint sign-off on MAUT weights (reg=0.40/harm=0.30/rev=0.15/cost=0.15)
  → Clarify: are Layer B components (llama-server, OpenManus) planned for Legion or evo1?

STEP 1 (operator + compliance, 2 weeks):
  → Sign off 13 PROPOSED passports (MLRO written sign-off for case_management_agent)
  → Art.6(3) classification memo for apar_agent + Hermes client-advisor [WP-S19-03]
  → Ratify schema reconciliation ADR
  → Start MAUT weight formal elicitation (swing-weighting workshop) [WP-S19-01]
  → Setup Google Custom Search API key for Legion tool plane [WP-S19-07]

STEP 2 (factory, Sprint A ~2 weeks):
  → Run implementation inventory audit (§7 matrix — update with live status)
  → Close confirmed P0 blockers
  → Tool Registry YAML (shared foundation)
  → Deploy DLP stack: NeMo Guardrails + LlamaFirewall + Landlock/seccomp (§6)
  → Deploy banking Qdrant + DataSunrise + Zep/Graphiti on evo1 [WP-S19-06]
  → Deploy Legion Qdrant + Mem0 on Legion (separate from banking)
  → Build back-testing infrastructure for BDSL threshold validation [WP-S19-02]
  → Hermes factory profile systemd service on Legion

STEP 3 (factory, Sprint B ~2 weeks):
  → Build BANXE-INTENT-ENGINE (LangGraph on evo1/evo2, banking thin-client from Legion)
  → LlamaIndex ingestion pipeline: FCA docs → banking Qdrant
  → Deploy llama-qwen.service + openmanus-api.service on Legion
  → Deploy Open WebUI + Cloudflare Tunnel on Legion
  → Wire Hermes banxe-ops to MiroFish + AML alerts
  → Begin BDSL live emission on ENROL-15 agents (advisory mode)

STEP 4 (factory, Sprint C ~3 weeks):
  → Submit back-testing results + model card to MLRO [WP-S19-02 deliverable]
  → Request MLRO formal BDSL production activation approval
  → Client-facing HII + Rich Cards
  → Mobile deployment: Enchanted LLM (iOS) + Open Mobile UI (Android)
  → Hermes client-advisor closed beta
  → BaFin-ready calibration documentation package

STEP 5 (operator + factory, ongoing Q3-Q4 2026):
  → BDSL first policy cycle (post MLRO production activation approval)
  → Independent model validation (FCA/PRA SS1/23 compliance)
  → DeerFlow evaluation vs OpenManus [WP-S19-05]
  → Temporal ADR decision (LangGraph-only vs LangGraph+Temporal)
  → MetaClaw Phase 2 skill corpus review
  → Credit circuit: initiate banking license process (if in business plan)
```

### Summary: What Exists vs What Is Next

**Confirmed operational:**
- BDSL governance substrate (3 invariants, ADR-046, 47 passports, 91/91 coverage)
- 9-agent compliance swarm on evo1
- MetaClaw + OpenClaw on Legion/evo1
- LiteLLM v2 router on evo1 :4000 + Legion :4000
- Ollama on evo1 :11434 + evo2 :11434 + Legion
- Guardian (:8195/:8196)
- ClickHouse audit trail (I-08 TTL 5yr)
- ADR-045 Intent-First framing canonical
- evo1 reachable via Tailscale (100.68.102.48)
- evo2 reachable via Tailscale (100.99.208.21, Prometheus/Grafana running)

**Blueprint / not yet deployed:**
- Layer B (llama-server :8080, OpenManus :8000) — NOT LISTENING
- All Qdrant instances — NOT FOUND
- DLP layer (NeMo Guardrails + LlamaFirewall) — NOT DEPLOYED
- Open WebUI, Telegram bot, mobile interfaces — NOT DEPLOYED
- BDSL DecisionRecord emission (schema confirmed; no live agent emitting)
- 13 PROPOSED passports (awaiting operator PR)
- Banking Zep/Graphiti, LlamaIndex — NOT DEPLOYED
- Hermes: documented, deployment status unconfirmed

**Credit circuit:** DORMANT BY EMI SCOPE — not a deployment gap, not a defect. Activation-on-license-expansion.

**Next single most important actions:**
1. Fix evo1 name resolution from Legion (15 min, Step 0) — unblocks all Legion → evo1 routing
2. Deploy Qdrant on evo1 + DataSunrise (Step 2) — unblocks semantic memory for banking engine
3. Deploy llama-server + OpenManus on Legion (Step 3) — unblocks Layer B private engine

---

*Canonical document v2. Sources S-01 through S-19 integrated. 14-section restructure complete. §AUDIT-2026-07-10 live data incorporated into §9 and §14. EMI scope vs dormant bank-license scope distinction applied throughout. CREDIT-GAP reframed as dormant bank-grade capabilities. S-19 extracted contributions in §7, §8, §9. Roadmap expansion in §12 (7 new work packages WP-S19-01..07). All open items tracked in §13.*
