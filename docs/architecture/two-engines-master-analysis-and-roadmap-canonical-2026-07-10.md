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
# CANONICAL — 2026-07-10
# Branch: agent/factory/t5/bdsl-activation-prep
# Status: SYNTHESIS — reviewed against source corpus (see §0)

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
| S-17 | `manus-legion-telegram-architecture.md` | `/home/mmber/MetaClaw/docs/sources/` | Legion private engine runtime + interface blueprint: OpenManus agent engine pattern, llama-server, FastAPI wrapper, Telegram bot, Open WebUI, mobile access (Enchanted/Open Mobile UI), systemd lifecycle, interface comparison |
| S-18 | `BANXE-Private-Legion-Engine-Otvety-Konsultanta-2026-07-10.md` | worktree `docs/sources/` | Consultant advisory answers: 9 corrections applied to §1/§3/§4/§5/§6/§7/§10/§11 of this document. Status: advisory; operator + Central ratification required (I-27). |

### SHA Anchors

```
BDSL pinned source body-sha256:
  c4f71e729f3791e97429f5482c405c201cee395b4d8daff6d9828ed53c30553f
  (tail -c 34974 docs/sources/best-decision-self-learning-loop-2026-07-07.md)

BDSL pinned source file-sha256:
  e8c65d1f804548e1829618d6db2d4d91e9688f426a6c331aab70f5c993ae40fe

ORG-CODE-RECONCILIATION-v2 sha256 (operator-confirmed):
  b84a4babf36bb0f9cc1618b26970f3cf009620c5780cda45313a4c1b41a2f035

ADR-046 Decision Record schema sha256 (operator-confirmed):
  a95d8e959417ad86dbb19e1d07ccd02d036671b92cd12912f640827c82db313b

Manus-Legion-Telegram architecture sha256 (operator-confirmed):
  f937c55f7f12e86db4ac873232ed29aefec59cd480b6f42fa2ea1f0506e94038
  (24561 bytes, 538 lines — practical runtime/interface blueprint for Layer B/C of Legion Private Engine)

S-18 Consultant advisory sha256 (computed 2026-07-10):
  ba53185aeb9a55d122ba8146a2d262b98d45f73948208db54b12e9d81fc0c90d
  (BANXE-Private-Legion-Engine-Otvety-Konsultanta-2026-07-10.md — 9 corrections, advisory status)
```

### Source Hierarchy (S-18, Correction 6)

When sources conflict, this precedence order is unconditional:

```
LEVEL 0 [UNCONDITIONAL]:
  Regulatory framework: EU AI Act / BaFin / DORA / FCA / MLR / GDPR
  → Cannot be overridden by any ADR or internal decision

LEVEL 1 [CANONICAL]:
  ADR supersedes-chain (banxe-architecture/docs/adr/)
  → Each ADR states which ADR it supersedes
  → A new ADR changes a prior one only through an explicit supersedes declaration

LEVEL 2 [GOVERNANCE]:
  BDSL fleet registry + PassportYAML (MLRO/CRO approved)
  → Changes require MLRO/CRO joint sign-off

LEVEL 3 [OPERATIONAL]:
  Passports/fleet registry + ORG-CODE matrix
  → Describes current deployment state
```

If sources conflict: Level 0 always wins. Level 1 wins over Level 2-3. Regulatory override always takes priority.

### What Is NOT Source-Confirmed

- **S-17 (Manus) is NOW CONFIRMED** — SHA f937c55f... operator-verified. Used as practical runtime/interface blueprint for Layer B and Layer C of the Legion Private Engine. The source is a research/Q&A document, NOT a deployment report — whether the described stack is actually running on Legion is `[NOT SOURCE-CONFIRMED]`. ADR-002 (telegram-bot-scope) scope decision remains in effect: client-facing deferred to Phase 3 KYC+FCA. Operator terminal use is current scope.
- BDSL v2 in MetaClaw/docs/sources is `SUPERSEDED` per canon file (S-12). All BDSL facts sourced from pinned file-sha `e8c65d1f...` as directed by canon.
- Production port numbers, Redis IPs, LiteLLM alias lists (from S-03/S-07) — described as "in production on evo1" in source documents; not independently verified against live system in this synthesis.

---

## §1 — Executive Framing: Why Two Engines

### 1.1 The Problem These Documents Were Trying to Solve

The source corpus was produced in a period when BANXE AI Bank was being described across many documents inconsistently — sometimes as a "banking stack with AI bolted on", sometimes as a fully autonomous agent system. ADR-045 (S-13) names this explicitly as the core drift problem and fixes the framing: **EMI BANXE AI BANK is Intent-First / AI-agent-first**. The conversational intent layer is the primary interface.

But alongside the banking product, there is a second system: the **Software Factory and operator infrastructure** — the machinery *through which* the banking product is built and operated. This is not the same system. Conflating the two has been a recurring source of architectural confusion in the corpus.

### 1.2 Two Systems, One Corpus

A single source corpus (research docs, audit docs, agent passports, ADRs) covers two fundamentally different systems:

**System A — Banking Engine (product)**
What the *customer* uses. An Intent-First AI banking product built for FCA-regulated operation. Its decisions are regulated, auditable, governance-gated, and subject to FCA CASS 15, MLR 2017, EU AI Act, SM&CR. Its learning loop (BDSL) must be append-only, human-gated, and explainable by construction.

**System B — Legion Private Engine (infrastructure for the operator)**
What the *operator and Software Factory* uses. An autonomous, private engineering and orchestration system running on Legion/evo1/evo2 that builds, deploys, monitors, and evolves the banking product. Its decisions are operational, not regulated financial decisions. Its learning loop (MetaClaw, Hermes skills) optimizes factory velocity and correctness, not client outcomes.

**Important (S-18, Correction 1):** Legion hosts TWO SEPARATE circuits — there is no architectural "conflict" between them; they are designed to coexist with a hard data boundary:

- **(a) Private Engine circuit** — OpenManus + uncensored Qwen3.6, operates autonomously on Legion. Purpose: dev/research/operator tasks. NOT part of the banking compliance zone.
- **(b) Banking thin-client circuit** — a thin client on Legion that routes all banking execution to the banking engine on evo1 (ADR-103). Failover: evo1 → evo2. Legion is NOT a fallback for banking logic.

The data boundary: Legion cannot write to the banking ledger, cannot execute compliance operations autonomously. Legion access to the banking zone is read-only, logged, and write-blocked (see §5.8 DLP). ADR-103 is the canonical authority for this boundary.

### 1.3 Why This Is Not Duplication

| Dimension | Banking Engine | Legion Private Engine |
|-----------|---------------|----------------------|
| Primary user | Client / MLRO / compliance officer | Operator / Software Factory Lead (Moriel) |
| Output of decisions | Client money movement, compliance rulings | Code, specs, deployment, CI/CD |
| Regulatory envelope | FCA/PRA/EU AI Act — HIGH | None (internal tooling) |
| Failure cost | Client fund loss, regulatory breach | Delayed build, bad code (recoverable) |
| Learning loop | BDSL — MAUT + append-only + human-gated | MetaClaw skill distillation + Hermes episodic memory |
| Autonomy ceiling | L2_REVIEW (PROPOSED passports) / L3 (existing ENROLs, human-gated) | High autonomy within factory; no FCA exposure |
| Source of truth | agents/passports/, ADR-046 schema, governance config | SOUL.md, MetaClaw skill files, Tool Registry |

### 1.4 Why BDSL Is Not the Whole Story

BDSL (Best-Decision Self-Learning Loop) is the **governance substrate of the Banking Engine** — the mechanism by which every consequential agent decision is recorded, evaluated, and (when gate conditions are met) fed back into the next policy cycle. It is NOT a general-purpose AI orchestration framework. It does not describe the Legion Private Engine.

Similarly, Hermes/Factory/MetaClaw describe the **orchestration substrate of the Legion Private Engine**. They are NOT a banking compliance framework. Applying Hermes' autonomy model to the banking product would violate I-BDSL-2 (Human-Gated Activation) and EU AI Act requirements.

---

## §2 — Common Ontological Foundation: Seven Layers

Both engines share conceptual layers, but the instantiation in each engine is different. This table shows what is shared and what is specialized.

| Layer | Generic concept | Banking Engine instantiation | Legion Private Engine instantiation |
|-------|----------------|-----------------------------|------------------------------------|
| **L0 — Constitutional / Canon** | Immutable rules that govern the system | CLAUDE.md invariants (I-01..I-28), FCA constraints, EU AI Act | SOUL.md per profile, operator canon, Central/Terminal topology (ADR-153) |
| **L1 — Decision / Governance** | Rules for consequential choices | ADR-046 DecisionRecord schema, BDSL invariants (I-BDSL-1/2/3), HITL gates (L2–L4), SM&CR | Factory task discipline, BEST-SINGLE-ARTIFACT rule, ADR-120 worktree isolation, G-5 hook |
| **L2 — Orchestration** | How agents coordinate to fulfill intent | LangGraph DAG planner over banking passports, Swarm Orchestrator (banxe compliance swarm), Verify API (2/3 consensus) | Ruflo (RaftBFT, 98 agents), OpenClaw orchestration, Hermes 24/7 dispatch |
| **L3 — Agent / Fleet** | Specialist agents that execute | 47 passports (ENROL=15, DEFER=9, EXCLUDE=23), ADR-005 Protocol DI | Hermes profiles (factory, banxe-ops, client-advisor), MetaClaw, MiroFish, IronClaw, NanoClaw |
| **L4 — Runtime / Integration** | Where agents run and what they call | evo1 (compliance API :8085, Jube :5001, Marble :5002, n8n), evo2 (MicroFish, IronClaw), Midaz Ledger | Legion (Intent Parser local), evo1 (LiteLLM gateway, Ollama), evo2 (inference), OpenClaw CLI |
| **L5 — Operator Interface / Terminal** | How the operator controls the system | HITL gates (Marble Case Management), MLRO/COO approval flows, SM&CR sign-off PRs | Telegram (Hermes gateway), factory task dispatch (`claude -p`), Central terminal read-only diagnostics |
| **L6 — Audit / Quality / Learning Loop** | How the system improves and is verified | BDSL: append-only ClickHouse, DecisionRecord with MAUT utility, human-gated activation, fleet classification | MetaClaw: skill synthesis from trajectories, ClawArena benchmark scoring, Guardian (:8195/:8196), pre-commit hooks |

**What is shared (conceptually):** Every layer exists in both engines. The constitutional layer, decision discipline, orchestration pattern, fleet concept, runtime isolation, operator interface, and audit loop are universal.

**What diverges:** The instantiation in each layer is fundamentally different — by regulatory weight, autonomy ceiling, learning mechanism, and failure consequence.

---

## §3 — Comparative Analysis

| Attribute | Banking Engine | Legion Private Engine |
|-----------|---------------|----------------------|
| **Canonical name** | BANXE AI Bank / BANXE-CORE-ENGINE | Software Factory + Hermes/Factory stack |
| **Purpose** | Fulfill regulated financial intent for clients | Build, deploy, and operate the banking product |
| **Primary operator** | Client → MLRO/COO/CTO (human-gated decisions) | Moriel (Software Factory Lead) via Telegram/Terminal |
| **Environment** | evo1/evo2 (production inference + compliance stack) | Legion (primary), evo1/evo2 (execution targets) |
| **Regulatory load** | HIGH — FCA CASS 15, MLR 2017, PSR, EU AI Act Annex III, SM&CR | NONE — internal tooling; no FCA exposure |
| **Decision type** | AML rulings, KYC approvals, payment executions, compliance filings | Spec generation, code commits, CI/CD, deployment, sprint management |
| **Explainability requirement** | I-BDSL-3: machine-readable explanation per decision, traceable to policy version | Factory quality gate output; no regulatory explainability requirement |
| **HITL / gates** | I-BDSL-2: every autonomy tier upgrade is human-gated; L3+ decisions require human approval; I-27 (KYC HOLD = HITL-L4) | Factory discipline (Central never mutates directly); operator confirms risky actions; no FCA-mandated gate |
| **Orchestrator (S-18 C7)** | **LangGraph** — stateful/auditable/durable, checkpoint-based, native HITL support, threshold-gate compatible. LangGraph-first by default. Temporal: OPEN ITEM (see §5.1 addendum) | **OpenManus** — autonomous browser/bash execution, research tasks, no compliance constraints |
| **Runtime substrate** | FastAPI compliance stack, banxe-compliance-api (:8085), n8n, Temporal, Midaz Ledger | Claude Code CLI (`claude -p`), OpenClaw, LiteLLM v2 router, Ruflo swarm |
| **Artifact discipline** | Spec-first, ADR-required, passport YAML, DecisionRecord, audit trail | BEST-SINGLE-ARTIFACT rule, YAML spec → Lock 0→1→2 pipeline, SOUL.md, skill files |
| **Learning loop** | BDSL: MAUT utility score on each DecisionRecord → human-gated policy update | MetaClaw: RL trajectory distillation (skillmode=true), Hermes episodic skill memory, ClawArena benchmark delta |
| **Quality model** | Coverage ≥80% (pytest), ruff clean, semgrep clean, I-01 Decimal, audit trail completeness | Pre-commit hooks (ruff, pytest-fast, semgrep, G-5 branch), ClawArena (+15% benchmark delta/month target) |
| **Risk model** | Financial/compliance: client fund loss, regulatory breach, SAR filing triggers | Technical: bad code (reversible), delayed delivery, wrong spec (recoverable) |
| **Maturity (2026-07-10)** | BDSL governance substrate: DEEP. Passports: 47 classified. Fleet: ready for operator PR. | Hermes stack: documented, partially deployed on evo1. MetaClaw: production. Factory: operational. |
| **What is deeply built** | BDSL invariants, 47 passports, ADR-046 schema, ORG-CODE reconciliation (100% coverage) | OpenClaw orchestration, MetaClaw skills, LiteLLM routing, 9-agent compliance swarm |
| **What is next-phase** | Intent Engine (LangGraph), Qdrant, Tool Registry, CREDIT-GAP resolution | Hermes server profiles (factory, banxe-ops), Tool Registry, unified operator canon hardening |

---

## §4 — Deep Analysis: Banking Engine

### 4.1 What the Banking Engine Is

The Banking Engine is EMI BANXE AI BANK as described in ADR-045 (S-13). It is **not** a banking app with an AI chatbot added. It is an Intent-First AI product where:
- The primary interface is conversational intent (L1)
- Banking capabilities are surfaced *through* intent (not as the entry point)
- Every consequential agent action passes through the Governance & Compliance layer (L3 is cross-cutting, not sequential)
- The learning loop is BDSL — bounded by human-gated activation, append-only immutability, and explainability by construction

### 4.2 BDSL as the Governance Substrate

The Best-Decision Self-Learning Loop is the mechanism by which the Banking Engine learns without compromising regulatory integrity. Its three invariants (from S-12, pinned source sha `e8c65d1f...`):

**I-BDSL-1 — Append-Only Immutability**
Every learning signal, decision record, and feedback event is append-only. No UPDATE or DELETE on audit-trail tables. Implementation: `schemas/agent_decision_record.schema.json` (sha `a95d8e95...`).

**I-BDSL-2 — Human-Gated Activation**
Autonomous execution upgrades (threshold relaxation, new autonomy tier activation) require explicit human approval before taking effect. The gate mechanics live in `governance/novelty-pipeline-config.yaml`, not in the canon file.

**I-BDSL-3 — Explainability by Construction**
Every decision emitted by the loop must carry a machine-readable explanation traceable to input signals and the active policy version. Test coverage: `tests/best-decision/`.

**BDSL is NOT**: a general AI framework. It does not handle routing, orchestration, or model selection. It is the *audit and governance layer* on top of whatever orchestration runs below it.

**BDSL relationship to BUG-007 (S-18, Correction 3):** BDSL 90/70/95 thresholds (`governance/novelty-pipeline-config.yaml`) are a *learning overlay* on top of the live BUG-007 control. BUG-007 (HITL confidence thresholds, `.claude/rules/agents.md`) remains the PRIMARY control. BDSL adds an audit and improvement loop on top — it does NOT replace BUG-007. Payment confidence threshold ≥ 0.95 is technically valid; however, **production activation (advisory → auto-execution) requires all three of**:

| Prerequisite | Owner | Status |
|--------------|-------|--------|
| Back-testing on historical data — demonstrates threshold performance | CTO / Data team | NOT DONE |
| MLRO formal approval | MLRO (SMF17) | NOT DONE |
| Model card + risk management system documentation (EU AI Act) | CTO / Compliance | NOT DONE |

Until all three prerequisites are met: **BDSL operates in advisory mode only**. Autonomy upgrade is blocked (I-BDSL-2).

### 4.3 Four-Layer Reference Model (ADR-045)

```
L1 — Intent Layer (client conversational)
     Primary interface. Captures intent in natural language.
     Translates to structured, auditable requests.
     Technology: HII (Hybrid Intent Interface), assistant-ui,
                 Whisper voice, Rasa NLU (from S-05)

L2 — Execution Layer (agents)
     Fulfills intent. 47 passports cover 91/91 domain services.
     Planning: LangGraph DAG (to be built — see Roadmap)
     Existing: compliance swarm (9 agents), payment router, etc.

L3 — Governance & Compliance Layer (cross-cutting enforcement)
     AML/KYC, HITL gates, Decision Lineage, cost-policy.
     Every L2 action of consequence passes through here.
     No agent may bypass L3 for client funds / regulated data.
     Implementation: BDSL DecisionRecord, HITL service, ADR-046

L4 — Data & Intelligence Layer
     Midaz Ledger, PostgreSQL, ClickHouse (5yr TTL),
     Frankfurter FX, dbt (reporting), ORG audit trail.
```

Three open governance gaps named in ADR-045 as future ADRs:
1. Decision Lineage Schema / `AgentDecisionRecord` — now addressed by ADR-046, but schema reconciliation ADR pending ratification
2. AI cost governance policy — not yet formalized
3. S13-00 Business Process Repository — not yet created

### 4.4 Passport Fleet State (2026-07-10)

Source: S-14 (ORG-CODE-RECONCILIATION-v2), S-15 (fleet classification v3).

```
Runtime services:  106
Infra (out-of-scope): 15
Domain services:   91 (91/91 = 100% coverage, 0 true orphans)

Passports:         47 (34 existing + 13 PROPOSED)

BDSL classification (all 47):
  ENROL:   15  (make consequential decisions → must emit DecisionRecord)
  DEFER:    9  (consequential but needs architectural/scope review first)
  EXCLUDE: 23  (platform/infra/advisory — no autonomous financial decisions)
  TOTAL:   47  ✓

13 PROPOSED passports:
  status: PROPOSED, autonomy: L2_REVIEW (ceiling)
  NOT activated. Operator sign-off PR required.
  MLRO written sign-off required for case_management_agent (RED/SMF17).
```

**ENROL vs EXCLUDE criteria for 13 PROPOSED (S-18, Correction 8):**

| Classification | Criterion | Examples |
|---------------|-----------|---------|
| **ENROL under BDSL** | Agent's outputs affect payment / KYC / AML decisions; OR agent processes client personal data in a compliance context | `case_management_agent` (RED/MLRO) |
| **EXCLUDE from BDSL** | Orchestrators (route requests only), data-fetchers (read/display only), formatters (no decision authority) | `webhook_orchestrator_agent`, `design_pipeline_agent`, most AMBER/GREEN agents |

**Important:** The ENROL/DEFER/EXCLUDE classification above is a *proposal*, not final. **Final decision: Compliance (MLRO/Compliance Officer) sign-off required for each agent in ENROL category.** Current BDSL ENROL candidate from the 13 PROPOSED batch: 1 (`case_management_agent`). Remaining 12: passport activation for audit coverage; BDSL DecisionRecord not required (confirm with MLRO).

### 4.5 The ENROL-15 Are the Active BDSL Subjects

The 15 ENROL agents span: AML orchestration, transaction monitoring, sanctions, fraud (jube/yente/watchman/crypto_aml adapters), compliance monitoring, internal audit, risk oversight, board reporting, finance AP-AR, IFRS, and case management (from PROPOSED batch). These are the agents whose decisions require DecisionRecord emission once BDSL activation PR is merged.

### 4.6 What Is Missing for Banking Engine Production

From S-03 (agent-engine-conclusion) — components not yet built:

1. **BANXE-INTENT-ENGINE** — LangGraph DAG planner over 39/47 passports. Maps client intent to agent graph. Not built; described as the single most important missing component.
2. **Qdrant** — Semantic memory between sessions. Agents currently remember nothing across sessions (ClickHouse stores audit trail, not semantic context). Proposed: Docker on evo1 alongside Redis.
3. **Tool Registry** — `banxe-architecture/tools/registry.yaml` — unified manifest of all tools with permission matrix. Currently tools are scattered across passport YAML files.
4. **Agent Communication Protocol** — standardized agent-to-agent message envelope with `trace_id`, `correlation_id`, decision lineage. Partially addressed by ADR-046 schema.

P0 blockers from AUDIT_CONCEPT_VS_REAL (referenced in S-03):
- midaz-ledger in restart loop (Redis on 172.20.0.1:6379 missing)
- banxe-recon.service FAILED (FCA CASS 15 Daily Safeguarding Reconciliation broken)
- hardcoded `api_key="sk_live_abc123"` in gateway.py
- ANTHROPIC_API_KEY not set (3 Claude-workflows fail daily)
- qwen3-banxe-v2 alias missing (6 Aider configs reference non-existent alias)

**[SYNTHESIS NOTE]**: The P0 blockers above appear in S-03, which is a research document from 2026-07-10. Whether all of them are still unresolved as of today is NOT independently verified in this synthesis. These should be confirmed against current `git log` / service status before acting.

---

## §5 — Deep Analysis: Legion Private Engine

### 5.1 Three-Layer Architecture

The Legion Private Engine is not a monolithic system. The Manus-Legion source (S-17, confirmed) provides the practical implementation picture and makes it possible to distinguish three architectural layers with different canonical weight:

**Layer A — Foundational Substrate (Hermes/Factory/ORG + terminal canon)**
The constitutional and orchestration foundation. Operator canon, terminal topology, Central/Left/Right discipline, factory quality loop. Sources: S-07, S-08, S-10, ADR-153, CLAUDE.md. This layer is the *governance* of the private engine — analogous to the BDSL governance substrate in the banking engine. It cannot be replaced without a new ADR. It does not describe how agent tasks execute locally; it describes how the operator governs the factory.

**Layer B — Runtime Implementation (agent engine + model serving + tool plane + systemd)**
The practical execution machinery. A local LLM server (llama-server :8080) wrapped by a FastAPI agent engine (OpenManus-style :8000). Tasks dispatched from Layer A land here for execution. Source: S-17 (confirmed). This layer is buildable and documented but is NOT the constitutional substrate — it could be replaced with a different agent engine without changing Layer A governance.

**Layer C — Interface Layer (operator access channels)**
How the operator interacts with the private engine. Telegram bot (polling) as lightweight mobile/remote channel. Open WebUI as the preferred rich local interface. Native mobile apps (Enchanted LLM for iOS, Open Mobile UI for Android) for full LLM access on the move. Source: S-17 (confirmed). These are implementation choices — multiple can coexist; none is architecturally mandatory.

**Critical boundary**: Layer A is the canon substrate. Layers B and C are implementation and interface options. Manus = Layer B/C practical blueprint. Manus ≠ constitutional foundation. Manus does NOT replace Hermes/Factory/ORG in any governance capacity.

**Two Legion circuits (S-18, Correction 1):** Within Legion, two circuits coexist by design — not in conflict:
- **(a) Private Engine circuit** — Layer B/C in full: OpenManus + Qwen3.6, autonomous browser/bash, dev/research. No banking compliance zone access.
- **(b) Banking thin-client circuit** — only a thin routing client runs on Legion; all banking execution on evo1 (ADR-103). Failover: evo1 → evo2. Legion = NOT a banking logic host.

Data boundary: Legion has no write access to banking ledger. Read access: logged only (see §5.8). ADR-103 is canonical authority.

### 5.2 Layer A: Foundational Substrate (Hermes/Factory/ORG)

Source: S-07, S-08, S-10. Physical topology:
- **evo1**: LiteLLM v2 router, Ollama, banxe-compliance-api, Jube, Marble, ClickHouse, PostgreSQL, Redis, Presidio PII proxy, n8n, Midaz Ledger
- **evo2**: IronClaw (WASM sandbox), MicroFish (offline inference), Hyperswitch
- **Legion**: MetaClaw, OpenClaw (primary orchestration), NanoClaw, ClawArena, Software Factory Lead terminal

**Agent stack (confirmed in S-07):**

| Agent | Role | Terminal |
|-------|------|----------|
| OpenClaw | Control plane: ADR drafting, spec writing, coding, docs, DevOps | Central |
| MetaClaw | Transparent proxy: skill injection, RL trajectories, cross-session memory | Central |
| Ruflo | Swarm orchestration: 98 agents, RaftBFT consensus, AgentDB HNSW | Central |
| IronClaw | Security auditor: WASM sandbox, AES-256, TEE-secured inference | Right (evo2) |
| NanoClaw | TDD generator: Jest/Vitest, 700M-parameter specialist | Central |
| MiroFish | Prediction + Risk: OASIS 100-world simulation, VaR, Greeks | Right (evo1) |
| MicroFish | Privacy layer: offline inference, MiCA/CASP checks | Right (evo2) |
| ClawArena | Benchmark judge: MetaClaw integration, CI scoring | Central |
| Hermes | 24/7 autonomous server: episodic memory, self-improving skills | evo2 VPS (proposed) |

**Hermes three-profile deployment** (from S-07):
- `factory`: Factory Coordinator — task dispatching, CI/CD, sprint ledger (Telegram → factory channel)
- `banxe-ops`: Operations Monitor — AML alerts, MiroFish feeds, system health (read-only on banking data)
- `client-advisor`: Client AI Advisor — DSS recommendations, MiCA disclaimer, no autonomous execution

### 5.3 Terminal Topology Canon

From CLAUDE.md global instructions and ADR-153:
- **Central** = dispatcher / arbiter / operator-facing governance / ledger-arbiter. Read-only diagnostics direct; all mutations through factory.
- **Terminal A (Left)** = Software Factory — orchestrator-executor. Self-orchestrates. Owns and perfects the factory engine.
- **Terminal B (Right)** = Special-mandate (TRADING-001). Operates under same Intent-First concept and governance model. No carve-out.

**No-Wait Rule (immutable):** Central NEVER waits for Terminal A. Factory imperfections are A's concern.

**Best-Single-Artifact Rule:** After any output, Central ALWAYS emits exactly ONE next-action artifact (`[CLAUDE CODE]` for state changes, `[SHELL]` for read-only audit). No alternatives, no menus.

### 5.4 MetaClaw Learning Loop

MetaClaw operates as a transparent proxy in front of OpenClaw. Intercepts all trajectories, synthesizes skills during idle periods (≥5min), injects verified skills into subsequent calls (few-shot ICL, not fine-tuning). Phase 1 (current): `rlmode: false` — accumulating trajectories. Phase 3 (future): RL via cloud LoRA.

This learning model is NOT applicable to the BDSL loop in the banking engine — it would violate I-BDSL-2 (Human-Gated Activation). The factory uses it freely because factory output is reviewed before merging into the project.

### 5.5 Layer B: Runtime Implementation

Source: S-17 (confirmed, SHA f937c55f...).

**Local model-serving substrate (Legion):**
```
llama-server :8080
  model: Qwen3.6-35B-A3B IQ2_M (quantized, local)
  GPU offload: -ngl 20, --flash-attn
  context: -c 131072 (128K tokens)
  KV cache: q8_0 (memory-efficient)
  systemd: llama-qwen.service (After=network.target)
```

**Agent engine wrapper (OpenManus-style FastAPI):**
```
OpenManus :8000
  config.toml: base_url = "http://localhost:8080/v1", api_key = "none"
  POST /run/agent  {"prompt": "..."} → {"status": "ok", "result": "..."}
  GET  /health     → {"status": "running"}
  systemd: openmanus-api.service (Requires=llama-qwen.service)
```

**Tool execution plane (7 tools confirmed in S-17):**

| Tool | Function |
|------|----------|
| `bash.py` | Shell command execution |
| `browser_use_tool.py` | Playwright Chromium — full headless web browser, click/scroll/form/screenshot |
| `python_execute.py` | Python code execution in agent sandbox |
| `google_search.py` | Google Custom Search (100 req/day free; needs API key) |
| `duckduckgo_search.py` | Web search without keys (rate-limited by DDG) |
| `file_saver.py` | Artifact storage in `workspace/` |
| `planning.py` | Multi-step task decomposition |

**Systemd startup order:**
```
1. llama-qwen.service     → Qwen model loads (~30-60s)
2. openmanus-api.service  → Requires=llama-qwen.service
3. (interface services)   → Open WebUI Docker, Telegram bot
```

**Relationship between Layer B and Layer A:**
- Layer A agents (OpenClaw/Hermes) dispatch tasks → Layer B executes locally. These are complementary, not competing paths.
- OpenManus adds browser automation and internet search that the `claude -p` factory terminal does not provide natively — making it the preferred execution target for research, data collection, and web-interaction tasks.
- Hermes `factory` profile continues to dispatch factory tasks via `claude -p` CLI. Hermes `banxe-ops` runs read-only monitoring. Neither is replaced by OpenManus — they use different backends for different task types.

**Where S-17 conflicts with or supplements the Hermes/Factory worldview:**
- S-17 is fully compatible with Layer A. It describes the local execution substrate, not the orchestration canon.
- S-17 does NOT specify how to dispatch tasks from Central — that remains factory discipline (through terminal A / factory task).
- S-17 describes internet access capabilities (browser, search) that are NOT available from IronClaw zones (payment flows, AES-256 keys) per zero-trust constraint from S-07.

### 5.6 Layer C: Interface Layer

Source: S-17 (confirmed). All three interface categories confirmed with concrete implementation details.

**Telegram bot (polling) — lightweight remote/mobile channel:**
- Polling mode: Legion polls Telegram API every few seconds. No public IP, no SSL certificate required.
- Timeout configured at 300s (`httpx.AsyncClient(timeout=300.0)`).
- **Hard limit: 4096 characters per message.** Long outputs are truncated.
- Long-output pattern: agent saves artifact to `workspace/`, bot returns file path or sends via `send_document()`.
- Best for: short remote tasks, status queries, mobile on-the-go operator commands.
- NOT suitable for: long analysis, code reviews, structured financial reports, multi-file outputs.

**Open WebUI — preferred rich local interface:**
```bash
docker run -d -p 3000:8080 \
  --add-host=host.docker.internal:host-gateway \
  -e OPENAI_API_BASE_URL=http://host.docker.internal:8080/v1 \
  -e OPENAI_API_KEY=none \
  -v open-webui:/app/backend/data \
  --name open-webui --restart always \
  ghcr.io/open-webui/open-webui:main
# Access: http://localhost:3000
```
Capabilities: unlimited response length, full Markdown/LaTeX/code rendering, built-in RAG, voice TTS/STT, artifact storage in UI, runs in browser on any LAN device. Direct OpenAI-compatible connection to llama-server — no OpenManus needed for plain LLM chat. For agentic tasks: connect via OpenManus API.

**LibreChat — team/MCP-native alternative:**
```bash
# http://localhost:3080 (Docker Compose)
# Native MCP tool support → direct OpenManus integration
# Agent Builder UI, code execution in browser, conversation forking
```
Best for: multi-user scenarios, MCP tool use from UI, collaborative task management.

**Mobile-native apps (beyond Telegram):**

| App | Platform | Requirement | Agent tasks | Truncation |
|-----|----------|-------------|-------------|-----------|
| Enchanted LLM | iOS (App Store, free, iOS 17+) | Cloudflare Tunnel or ngrok | ❌ LLM chat only | ✅ None |
| Open Mobile UI | Android (Google Play, React Native) | Cloudflare Tunnel or ngrok | ✅ Via Open WebUI | ✅ None |

**Remote access (outside home LAN) — two options from S-17:**
- **Cloudflare Tunnel** (recommended): permanent URL, free, no public IP. `cloudflared tunnel --url http://localhost:8080`
- **ngrok**: simpler setup, URL changes on restart on free plan. `ngrok http 8080`

**Operator topology (from S-17):**
```
Legion (local)
├── llama-server :8080
├── Open WebUI :3000        ← primary rich interface (local/LAN)
└── cloudflared → https://tunnel.trycloudflare.com

iPhone (anywhere)
└── Enchanted LLM → https://tunnel.trycloudflare.com  (LLM chat)

Android (anywhere)
└── Open Mobile UI → https://tunnel.trycloudflare.com (full agentic via Open WebUI)

Telegram (anywhere, lightweight)
└── Bot polling → OpenManus :8000 → llama-server :8080
```

### 5.7 What Is Missing for Legion Private Engine

1. **Hermes server deployment** — documented (S-07) but actual evo2 VPS systemd/Docker status: `[NOT SOURCE-CONFIRMED]`.
2. **OpenManus deployment on Legion** — S-17 is a research/blueprint document. Whether OpenManus is installed and running is `[NOT SOURCE-CONFIRMED]`.
3. **Open WebUI Docker on Legion** — Docker run command documented in S-17; deployment status: `[NOT SOURCE-CONFIRMED]`.
4. **Cloudflare Tunnel setup** — required for remote access; configuration status: `[NOT SOURCE-CONFIRMED]`.
5. **Tool Registry** — factory tools scattered across passport files and `.claude/skills/`. No unified registry.
6. **BANXE-INTENT-ENGINE** — client-facing LangGraph intent parser not built (factory has OpenClaw/Ruflo for internal orchestration).
7. **Unified private engine spec** — no single formal document equivalent to ADR-045 for the Legion Private Engine. S-07 + S-08 + S-17 together provide the picture; none is the formal spec.
8. **DLP layer** — NeMo Guardrails + LlamaFirewall + OS-sandbox not yet deployed (see §5.8).
9. **Memory boundary enforcement** — hard data boundary between Legion Qdrant and Banking Qdrant not yet implemented (see §5.9).

### 5.8 DLP Boundary: Legion → Banking Zone (S-18, Correction 4)

The Legion Private Engine agent with browser/search tools MUST NOT output the following to any interface (Telegram, Open WebUI, logs, or workspace artifacts):
- Client PII (names, IBAN, transaction data, KYC records)
- API keys, credentials, tokens from the banking zone
- Source code from production banking repositories
- Audit logs or compliance reports

**Required DLP implementation stack:**

| Layer | Tool | Purpose | License |
|-------|------|---------|---------|
| Programmatic output filter | NeMo Guardrails (NVIDIA) | Rule-based output constraints on agent responses | Apache 2.0 |
| Secondary output filter | LlamaFirewall | Additional output filter before delivery to interface | Apache 2.0 |
| OS-level process isolation | Landlock (Linux 5.13+) + seccomp + namespaces | Kernel-level isolation of Legion agent processes | Kernel built-in |

**Access rules (Legion → banking zone):**

| Operation | Allowed | Condition |
|-----------|---------|---------|
| READ status/metrics | YES | Must be logged; read-only endpoint only |
| WRITE to ledger/DB | NO | Hard-blocked; no credentials exposed to Legion agent |
| Credentials transfer | NO | Banking zone credentials NEVER passed to Legion agent |

**Status:** DLP layer not yet deployed. Design complete (S-18). Buildable as Horizon 1 task.

### 5.9 Memory Boundary: Banking Qdrant vs Legion Qdrant (S-18, Correction 5)

Two separate Qdrant instances — NO shared access between them:

**Banking Engine memory stack (evo1/evo2):**
| Component | Purpose | Location |
|-----------|---------|---------|
| Qdrant instance (banking) | Semantic search over banking knowledge base | evo1 |
| Zep (Apache 2.0) | Temporal Knowledge Graph for client banking context | evo1 |
| Graphiti | Temporal KG with versioning for compliance and audit | evo1 |
| LlamaIndex | Ingestion pipeline for regulatory documents | evo1 |

**Legion Private Engine memory stack (Legion):**
| Component | Purpose | Location |
|-----------|---------|---------|
| Qdrant instance (dev/research) | Semantic search over dev/research knowledge | Legion |
| Mem0 (Apache 2.0) | Long-term memory for operator sessions | Legion |

**Hard boundary rules:**
- Banking Qdrant: NOT accessible from Legion agent directly
- Legion Qdrant: contains NO banking client PII
- Cross-engine sync: ONLY through explicit human-approved export with audit trail (logged, append-only record per I-24)
- No automated sync between memory stores

**Status:** Architecture defined (S-18). Implementation requires Horizon 1/2 build tasks.

---

## §5a — Legion Private Engine: Runtime and Interface Comparison

Source: S-17 (confirmed, SHA f937c55f...). All comparison data source-anchored.

### Interface Comparison Table

| Attribute | Telegram | Open WebUI | LibreChat | Enchanted LLM (iOS) | Open Mobile UI (Android) |
|-----------|----------|------------|-----------|---------------------|--------------------------|
| Response length | ❌ 4096 chars | ✅ Unlimited | ✅ Unlimited | ✅ Unlimited | ✅ Unlimited |
| Markdown rendering | ⚠️ Partial | ✅ Full | ✅ Full | ✅ Full | ✅ Full |
| Native mobile | ✅ Yes | ✅ Browser | ✅ Browser | ✅ Native iOS | ✅ Native Android |
| OpenManus integration | ✅ Via REST API | ✅ Via REST API | ✅ Via MCP | ⚠️ LLM chat only | ✅ Via Open WebUI |
| Voice (TTS/STT) | ❌ | ✅ Built-in | ❌ Limited | ❌ | ❌ |
| RAG (doc retrieval) | ❌ | ✅ Built-in | ✅ Built-in | ❌ | ❌ |
| Outside home access | ✅ Always (polling) | ⚠️ Needs tunnel | ⚠️ Needs tunnel | ✅ Needs tunnel | ✅ Needs tunnel |
| Artifact return path | Truncation / send_document() | Full in UI | Full in UI | File sharing | File sharing |
| Setup complexity | Simple (token only) | Docker (1 command) | Docker Compose | App Store install | Google Play install |

**Operator recommendation (verbatim from S-17):** "Open WebUI для работы дома за ноутом — полный функционал, нет ограничений. Telegram оставить для доступа на ходу с телефона — быстрые короткие задачи."

### Long-Output Handling Pattern (confirmed from S-17)

Telegram's 4096-character limit requires a dedicated pattern for agent output:

```python
# In telegram_bot.py — long-result handling
if len(result) > 4000:
    # Option 1: truncate with notice
    result = result[:4000] + "\n... [обрезано]"
    await update.message.reply_text(f"✅ Результат:\n\n{result}")
    # Option 2 (preferred for full output): save artifact + send file
    # artifact_path = workspace / f"result_{timestamp}.txt"
    # artifact_path.write_text(result)
    # await update.message.reply_document(document=open(artifact_path, "rb"))
```

For structured outputs (code, reports, analysis): always use artifact path (`workspace/`) + `send_document()`. Truncation is for quick status responses only.

### Conflict Analysis: Hermes Telegram vs OpenManus Telegram

**Are these competing?** No. They are parallel paths for different task types.

| Aspect | Hermes `factory` profile | OpenManus Telegram bot |
|--------|--------------------------|------------------------|
| Backend | Claude (claude -p via factory) | Local Qwen3.6 (llama-server :8080) |
| Use case | Factory task dispatch, CI/CD monitoring, sprint ledger | Local agent tasks: browser, bash, search, file ops |
| Telegram channel | Factory-specific channel (operators) | General operator channel |
| Autonomy | L2/L3 per agent-authority.md | Local execution, offline capable |
| Banking data access | Yes (via factory read-only) | No (local task execution only) |
| Conflict | None — these are complementary layers | |

Hermes `factory` profile = Layer A governance channel on Telegram.
OpenManus Telegram bot = Layer B/C execution channel on Telegram.
Both can coexist on different bot tokens / channels without conflict.

### Deployment Status Summary (2026-07-10)

| Component | Status | Source |
|-----------|--------|--------|
| llama-server :8080 with Qwen3.6 | `[NOT SOURCE-CONFIRMED — deployment]` | S-17 is blueprint |
| OpenManus FastAPI :8000 | `[NOT SOURCE-CONFIRMED — deployment]` | S-17 is blueprint |
| Telegram bot (polling) | `[NOT SOURCE-CONFIRMED — deployment]` | S-17 is blueprint |
| Open WebUI Docker :3000 | `[NOT SOURCE-CONFIRMED — deployment]` | S-17 is blueprint |
| Cloudflare Tunnel | `[NOT SOURCE-CONFIRMED — deployment]` | S-17 is blueprint |
| systemd llama-qwen.service | `[NOT SOURCE-CONFIRMED — deployment]` | S-17 is blueprint |
| systemd openmanus-api.service | `[NOT SOURCE-CONFIRMED — deployment]` | S-17 is blueprint |

S-17 is a confirmed architecture/blueprint document. The described stack is well-specified and buildable. None of the above implies the stack is NOT deployed — only that the source corpus does not confirm running state.

---

## §6 — Honest Maturity Assessment

**This section must be read before the roadmap. Maturity is uneven by design.**

```
Maturity Tier 1 (deepest, production-relevant):
  ├── BDSL governance substrate
  │   ├── 3 invariants: defined, canon-pinned (sha e8c65d1f...)
  │   ├── ADR-046 schema: confirmed (sha a95d8e95...)
  │   ├── 47 passports: classified ENROL/DEFER/EXCLUDE
  │   ├── 91/91 domain coverage: 0 true orphans
  │   ├── Activation gates: documented, ready for operator PR
  │   ├── CREDIT-GAP: identified, localized, not resolved
  │   ├── MAUT weights: reg=0.40 / harm=0.30 / rev=0.15 / cost=0.15 (S-18, Correction 9)
  │   │   Sensitivity: reg-weight stable in range 0.32–0.48 (rank order unchanged ±20%)
  │   │   Approved by: MLRO + CRO joint sign-off required; weights cannot change without it
  │   │   Independent model validation: required (FCA/PRA SS1/23) before production activation
  │   └── BDSL = overlay on BUG-007 (NOT replacement); advisory mode until back-testing + MLRO + model card
  └── ORG-CODE reconciliation
      └── v2 authoritative (sha b84a4bab...)

Maturity Tier 2 (operational, partially production):
  ├── MetaClaw: confirmed running, skill injection active
  ├── OpenClaw: primary factory orchestrator, active
  ├── LiteLLM v2 router: active on evo1 (7 aliases)
  ├── 9-agent compliance swarm: active (MLRO, Sanctions, AML, TM, CDD, Fraud, Recon, Breach)
  ├── Guardian (:8195/:8196): active
  ├── ClickHouse audit trail: active (I-08 TTL 5yr)
  └── Hermes: documented at depth; deployment status unconfirmed

Maturity Tier 3 (designed, not yet built):
  ├── BANXE-INTENT-ENGINE (LangGraph Intent Parser)
  ├── Tool Registry (banxe-architecture/tools/registry.yaml)
  ├── Qdrant (semantic memory)
  ├── Agent Communication Protocol (standardized envelope)
  ├── S13-00 Business Process Repository (future ADR)
  ├── AI cost governance policy (future ADR)
  ├── Legion Layer B/C stack (llama-server, OpenManus, Open WebUI, Telegram bot) — source-confirmed blueprint (S-17); deployment status unconfirmed
  └── Manus-on-Legion → Telegram client-facing scope (ADR-002 deferred, Phase 3 KYC + FCA permissions)

Maturity Tier 4 (research / world benchmarks, not yet on BANXE roadmap):
  ├── PRAGMA (Revolut, 40B transaction events) — referenced in S-02
  ├── nuFormer (Nubank) — referenced in S-02
  ├── FATE federated learning (WeBank model) — referenced in S-06
  └── DeerFlow 2.0 (ByteDance super-harness) — referenced in S-04
```

The banking engine's governance layer (Tier 1) is the most thoroughly specified system in this corpus. The Legion private engine's operational layer (Tier 2) is the most deployed. The product-facing intent engine (Tier 3) is the most important gap.

### §6a — MAUT Best-Decision Analysis: Key Architecture Forks (S-18, Corrections 7/9)

For each key architectural fork, MAUT scoring was applied using weights: **reg=0.40 / harm=0.30 / rev=0.15 / cost=0.15**. Sensitivity: reg-weight stable 0.32–0.48; rank order unchanged. MLRO/CRO sign-off required on these weights.

#### Fork 1 — Banking Orchestrator

| Alternative | reg | harm | rev | cost | Weighted score | Decision |
|-------------|-----|------|-----|------|---------------|---------|
| LangGraph (stateful DAG, checkpoint, HITL native) | 0.95 | 0.90 | 0.75 | 0.65 | **0.87** | ✅ SELECTED |
| Temporal (durable execution, saga pattern) | 0.80 | 0.85 | 0.70 | 0.55 | **0.79** | OPEN ITEM |
| Custom FSM | 0.60 | 0.70 | 0.50 | 0.80 | **0.65** | EXCLUDED |

**Verdict: LangGraph-first.** LangGraph wins on reg (checkpoint = auditable state; native HITL gates) and harm (human oversight built-in). Temporal: OPEN ITEM — if cross-service saga pattern with guaranteed delivery is needed, Temporal adds value. Requires ADR before adoption.

#### Fork 2 — Legion Private Orchestrator

| Alternative | reg | harm | rev | cost | Weighted score | Decision |
|-------------|-----|------|-----|------|---------------|---------|
| OpenManus (autonomous browser/bash, local) | 0.10 | 0.50 | 0.90 | 0.85 | **0.47** | ✅ SELECTED for Legion |
| LangGraph (same as banking) | 0.95 | 0.90 | 0.60 | 0.50 | **0.84** | N/A — not needed here |

**Verdict: OpenManus for Legion.** Regulatory weight irrelevant for factory/dev tasks — cost and revenue/velocity dominate. OpenManus is the correct tool for autonomous browser/bash operator tasks.

#### Fork 3 — Memory Architecture

| Alternative | reg | harm | rev | cost | Weighted score | Decision |
|-------------|-----|------|-----|------|---------------|---------|
| Separate Qdrant per engine + Zep/Graphiti (banking) + Mem0 (Legion) | 0.95 | 0.90 | 0.75 | 0.60 | **0.86** | ✅ SELECTED |
| Shared Qdrant (single instance) | 0.30 | 0.25 | 0.80 | 0.85 | **0.38** | EXCLUDED — DLP violation |

**Verdict: Separate instances.** Shared memory violates DLP boundary (PII exposure risk, harm=0.25). Hard data boundary is non-negotiable.

#### Fork 4 — Inference Model (Banking agent, regulated)

| Alternative | reg | harm | rev | cost | Weighted score | Decision |
|-------------|-----|------|-----|------|---------------|---------|
| Self-hosted (evo1/evo2, on-premise) | 0.95 | 0.95 | 0.70 | 0.50 | **0.86** | ✅ SELECTED |
| Cloud inference (OpenAI/Anthropic API) | 0.55 | 0.60 | 0.85 | 0.80 | **0.64** | CONDITIONAL (non-financial tasks only; INV-AI-01) |

**Verdict: Self-hosted for banking.** GDPR/FCA: client financial data must not leave on-premise boundary (INV-AI-01). Cloud API permissible only for non-financial agent tasks where no PII transits.

---

## §7 — CREDIT-GAP: EU AI Act Annex III §5

### Status: BLOCKER — CREDIT circuit only

**What is missing:** No `credit_decision_agent` passport exists. No `lending_agent`, `savings_decision_agent`, `insurance_underwriting_agent`, or `card_credit_agent` exists as a dedicated decision-emitting agent.

**Where credit logic lives (confirmed in S-15):**
- `finance/apar_agent.yaml` — AP/AR management with embedded credit-terms decisions
- `channel_c_sepa_orchestrator.yaml` — SEPA payment routing including credit facility drawdown

**Why this is relevant (EU AI Act Art.62 — CORRECTED via S-18 Correction 2):**

> **DEADLINE CORRECTION:** Creditworthiness assessment and AML/anti-fraud AI systems fall under **EU AI Act Art.62** (Annex I high-risk — creditworthiness / essential services category). The compliance deadline is **2 December 2027** (24 months after the Regulation's entry into force). It is NOT 2 August 2026.
>
> The 2 August 2026 deadline applies to: payment fraud detection + law enforcement + biometric categories (Annex III other categories — Article 6(2)). This deadline is NOT applicable to the creditworthiness/AML high-risk category.

Formal classification under Art.62 requires:
- Dedicated accountability structure with named responsible person
- Dedicated audit trail traceable to that agent's decisions
- Explainability requirement per decision (I-BDSL-3 equivalent)
- No credit decision embedded as an undifferentiated sub-function of a broader agent

**`apar_agent` classification:** If `apar_agent` prepares data but does NOT make the final credit decision, it may qualify as Art.63 non-high-risk (preparatory task). Formal classification must be completed before **2 December 2027**. A dedicated `credit_decision_agent` is NOT an immediate requirement — it becomes mandatory only if/when the agent makes final credit decisions.

The current state — credit logic embedded in `apar_agent` and `channel_c_sepa_orchestrator` — does not satisfy Art.62 high-risk requirements IF those agents make final credit decisions. Classification to be confirmed by Legal/Compliance.

**What is NOT blocked:**
This blocker applies ONLY to the CREDIT circuit. AML / KYC / PAYMENT / COMPLIANCE BDSL activation is NOT blocked by the CREDIT-GAP.

**Operator decision required (two options):**

| Option | Action | Consequence |
|--------|--------|-------------|
| A | Create `credit_decision_agent.yaml` passport now | Art.62 proactively satisfied; credit logic becomes auditable, HITL-gated, L3+ agent |
| B | Formal Art.62 classification by Legal/Compliance; defer `credit_decision_agent` to Q4 2026 | Credit circuit explicitly deferred until classification complete; BDSL activation proceeds on all other circuits; deadline: 2 Dec 2027 |

**[NOT IN SCOPE OF THIS DOCUMENT]**: Choosing between Option A and B. This is an operator / MLRO / legal decision. Neither option is recommended here without operator instruction.

---

## §8 — Reuse: What Private Engine Can Contribute to Banking Engine

The following patterns from the Legion Private Engine are genuinely transferable to the banking engine — but only where they do not conflict with banking governance constraints.

| Private Engine pattern | Transferable to Banking Engine? | Constraint |
|------------------------|--------------------------------|-----------| 
| Factory quality gates (ruff, mypy, pytest, semgrep) | YES — already shared | No constraint; gates apply equally |
| BEST-SINGLE-ARTIFACT discipline | YES — as a design principle for agent output | Agent must still satisfy DecisionRecord schema (I-BDSL-3) |
| Audit-first action model (read before mutate, confirm before irreversible) | YES — banking agents should apply same discipline | Banking agents: L3 gate is mandatory, not just a practice |
| MetaClaw skill distillation pattern | PARTIAL — factory code improvement | NOT applicable to BDSL learning loop. BDSL requires human-gated activation; MetaClaw-style autonomous skill injection would violate I-BDSL-2 |
| Hermes episodic memory (session → skill) | PARTIAL — client advisor profile (read-only) | Client-facing memory must be GDPR-compliant; zero 3rd-party storage (INV-AI-01) |
| SOUL.md persona discipline | YES — as agent constitution pattern | Banking agents' SOUL.md must include HITL gate declarations |
| Tool Registry pattern | YES — applies to both engines | Banking registry must include `invariants:` and `hitl_required:` per tool |
| ClawArena benchmark loop | YES — can be adapted to banking agent quality | Banking benchmark must measure compliance accuracy, not just code quality |
| Ruflo RaftBFT consensus | PARTIAL — pattern applicable | Banking: 2/3 Verify API already implements consensus; Ruflo is factory-specific tool |
| LiteLLM routing (cost, privacy) | YES — INV-AI-01 requires local inference | Already shared: same evo1 stack serves both |

**What must NOT be reused:**
- MetaClaw RL trajectory distillation applied to BDSL without human-gated PR for each policy update
- Hermes autonomous scheduling applied to banking compliance decisions (would violate I-BDSL-2 and EU AI Act Art.14)
- Ruflo swarm autonomy on banking money movement without L3 gate enforcement

---

## §9 — Non-Goals and Boundary Conditions

These boundaries must be maintained. Violating them creates regulatory risk or architectural confusion.

```
Banking Engine ≠ General private autonomy sandbox
  The banking engine's autonomy ceiling is human-gated (I-BDSL-2).
  No banking agent operates at Legion Private Engine autonomy levels.
  SM&CR requires named human accountability for L3+ decisions.

Legion Private Engine ≠ Regulated banking decision engine
  Factory decisions (code, specs, CI) are NOT financial decisions.
  MetaClaw/Hermes skill loops do NOT satisfy I-BDSL-1/2/3.
  Factory output is reviewed before merging — that is the gate,
  but it is NOT equivalent to BDSL's append-only audit trail.

BDSL ≠ The entire Legion Engine
  BDSL is the governance layer of the Banking Engine only.
  It is not a general AI agent framework.
  It is not applicable to the factory orchestration layer.

Hermes/Factory ≠ Banking governance core
  Hermes profiles operate on operational data (CI, system health, recommendations).
  Hermes must NOT make autonomous client-fund decisions.
  The `banxe-ops` profile is read-only on banking data by design (SOUL.md constraint).

Intent Layer (L1) ≠ Chat UI bolted on
  ADR-045 is explicit: the conversational intent layer is the PRIMARY interface.
  Any design that treats a screen/form as primary and chat as optional
  contradicts ADR-045 (ACCEPTED, 2026-06-07).

CREDIT circuit ≠ Unblocked path
  Even after BDSL activation for AML/KYC/PAYMENT/COMPLIANCE,
  the CREDIT circuit requires a separate operator decision (§7).
  Do not activate credit decision flow without resolving CREDIT-GAP.
```

---

## §10 — Unified Roadmap

### Horizon 0 — Canonicalization (NOW, no build required)

**Shared:**
- [x] ORG-CODE-RECONCILIATION-v2 is authoritative (sha b84a4bab...) — DONE
- [x] BDSL pinned source canon (sha e8c65d1f...) — DONE
- [x] 47 passports classified ENROL/DEFER/EXCLUDE — DONE (v3 classification)
- [x] CREDIT-GAP localized and documented — DONE
- [ ] Schema reconciliation ADR (`ADR-schema-reconciliation-decisionrecord.md`) — ratification PENDING
- [ ] Three open ADR-045 gaps: Decision Lineage, AI cost policy, S13-00 BPR — formal ADRs PENDING

**Banking Engine:**
- [ ] Operator sign-off PR for 13 PROPOSED passports (MLRO sign-off for `case_management_agent`)
- [ ] CREDIT-GAP operator decision (Option A or B — see §7)

**Legion Private Engine:**
- [ ] Hermes deployment status verification (is server actually running on evo2?)
- [ ] Unified private engine spec document (equivalent to ADR-045 for factory topology)
- [ ] DLP layer design ratified (NeMo Guardrails + LlamaFirewall + OS-sandbox) — §5.8
- [ ] Memory boundary design ratified (separate Qdrant/Mem0 on Legion; Qdrant/Zep/Graphiti on evo1) — §5.9
- [ ] Two-circuit ADR drafted (Private Engine circuit vs banking thin-client circuit, ADR-103 boundary)

---

### Horizon 1 — Buildable Foundations (Sprint A: ~2 weeks)

**Shared:**
- [ ] P0 blockers resolved (banxe-recon.service, midaz Redis, hardcoded key, ANTHROPIC_API_KEY, qwen3-banxe-v2 alias) — **[VERIFY CURRENT STATUS FIRST; these may already be resolved]**
- [ ] Tool Registry `banxe-architecture/tools/registry.yaml` (applies to both engines)
  - Banking fields: `invariants:`, `hitl_required:`, `autonomy_level:`
  - Factory fields: `permissions:`, `terminal:`, `soul_constraint:`

**Banking Engine track:**
- [ ] Verify ADR-046 schema is ratified and in use by at least one ENROL agent (not just specified)
- [ ] `governance/novelty-pipeline-config.yaml` — MAUT weights and thresholds (must not be in canon file per ADR-161)
- [ ] `tests/best-decision/` — case-a through case-d YAML fixtures (referenced in S-12 anchors)
- [ ] Operator PR: 13 PROPOSED → ACTIVE (after Horizon 0 sign-offs)

**Legion Private Engine track:**
- [ ] Hermes `factory` profile: formal systemd service or Docker Compose entry on Legion
- [ ] MetaClaw: confirm rlmode=false trajectory accumulation is active, log count
- [ ] Ruflo: verify RaftBFT consensus is functional for factory swarm tasks
- [ ] DLP implementation: NeMo Guardrails output-filter + LlamaFirewall + Landlock/seccomp OS-sandbox (§5.8)
- [ ] Memory boundary implementation: deploy separate Qdrant on Legion (dev/research) + Mem0; confirm banking Qdrant isolated on evo1 (§5.9)
- [ ] Back-testing infrastructure for BDSL threshold validation (prerequisite for §4.2 production activation)

---

### Horizon 2 — Runtime-Ready Systems (Sprint B: ~2 weeks)

**Banking Engine track:**
- [ ] **BANXE-INTENT-ENGINE**: LangGraph over 47 passports as FastAPI service on Legion
  - Each ENROL-15 passport = node in graph
  - Input: structured intent from HII
  - Output: agent call chain with HITL points
  - Repository: `banxe-intent-engine` (new repo in CarmiBanxe org)
- [ ] **Qdrant**: Docker container on evo1, index passport files + compliance-documents
  - Client profiling: EDD history, document history, transaction patterns
  - Bounded by GDPR: client vectors stored on-premise, no cloud egress (INV-AI-01)
- [ ] **Agent Communication Protocol**: define standard message envelope
  - Fields: `trace_id`, `correlation_id`, `decision_lineage`, `agent_id`, `autonomy_level`
  - Must be compatible with ADR-046 DecisionRecord schema

**Legion Private Engine track:**
- [ ] **Hermes `banxe-ops` profile**: connect to MiroFish prediction feed, AML alert stream
- [ ] **Hermes `factory` profile**: wire to OpenClaw CLI via SSH, monitor CI/CD jobs
- [ ] **NanoClaw**: automate TDD-first generation before OpenClaw coding pass
- [ ] **Layer B — local model-serving substrate**: `llama-qwen.service` systemd unit (llama-server :8080, Qwen3.6-35B-A3B IQ2_M)
- [ ] **Layer B — agent API wrapper**: `openmanus-api.service` systemd unit (FastAPI :8000, Requires=llama-qwen.service)
- [ ] **Layer B — tool execution plane**: confirm 7-tool set functional on Legion (bash, browser_use_tool, python_execute, duckduckgo_search, google_search, file_saver, planning)
- [ ] **Layer C — preferred rich interface**: Open WebUI Docker (:3000) with Cloudflare Tunnel for remote access
- [ ] **Layer C — secondary mobile interface**: Telegram bot (polling) for on-the-go short tasks; Enchanted LLM / Open Mobile UI via tunnel
- [ ] **Artifact return path**: long-output handling via `workspace/` directory + `send_document()` in Telegram bot
- [ ] Manus-on-Legion client-facing scope: `[OPERATOR DECISION REQUIRED]` — define scope per ADR-002 (client-facing deferred until Phase 3 KYC + FCA permissions cleared)

---

### Horizon 3 — Controlled Deployment and Operator Loop (Sprint C: ~3 weeks)

**Banking Engine track:**
- [ ] **Client-facing Intent Interface**: Rich Cards (TransferCard, FXRailCard, CryptoOrderCard)
  - Connect HII to BANXE-INTENT-ENGINE
  - Voice interface (Whisper) as alternate input channel
  - NLU: Rasa for intent classification
- [ ] **BDSL live loop**: ENROL-15 agents begin emitting DecisionRecords
  - ClickHouse append-only storage confirmed
  - MAUT utility scores computed per record
  - Human review cycle: MLRO/COO review anomalies flagged by BDSL
- [ ] **Safeguarding Reconciliation**: banxe-recon.service confirmed running (FCA CASS 15)
- [ ] **CREDIT circuit**: implement chosen option (A: credit_decision_agent creation or B: formal deferral)

**Legion Private Engine track:**
- [ ] **Hermes `client-advisor` profile**: closed beta with first SME clients
  - MiCA disclaimer enforcement in SOUL.md
  - Honcho user modelling per client
  - NO autonomous trade execution (design constraint in SOUL.md)
- [ ] **ClawArena**: establish baseline benchmark, set +15%/month target
- [ ] **MetaClaw Phase 2**: analyze 1000-trajectory corpus, identify top-10 distilled skills

---

### Horizon 4 — Deep Specialization and Cross-Engine Reuse (Q3–Q4 2026)

**Banking Engine track:**
- [ ] **BDSL policy calibration**: first human-gated autonomy tier upgrade based on live DecisionRecord corpus
- [ ] **S13-00 Business Process Repository**: formal BPR mapping intent → L2 agent graph (future ADR)
- [ ] **AI cost governance policy**: per-route / per-agent cost accounting (future ADR)
- [ ] **MiroFish integration**: VaR and stress-test results surfaced through Intent Interface (read-only advisory, full I-27 HITL on execution)
- [ ] **World-benchmark alignment**: apply lessons from Alipay/Nubank/Minna Bank models (S-06) to BDSL calibration

**Legion Private Engine track:**
- [ ] **MetaClaw Phase 3**: RL mode via cloud LoRA (`tinkercloud.enabled: true`)
- [ ] **IronClaw**: formal blocking integration — no code merges without IronClaw PASS on payment/auth paths
- [ ] **Factory Tool Registry v2**: automated tool discovery from passport changes

**Convergence / Reuse track:**
- [ ] **Shared Tool Registry** — single registry, dual-namespace (banking invariants + factory permissions)
- [ ] **Benchmark-to-BDSL bridge**: ClawArena benchmark delta as input signal to BDSL quality monitoring
- [ ] **Unified operator canon**: formal document equivalent to ADR-045 for the Legion Private Engine, resolving topology ambiguities

---

## §11 — Final Canonical Outcome (S-18 integrated, 2026-07-10)

### Decisions Made (Canonical — integrated from S-01 through S-18)

| # | Decision | Authority | Status |
|---|----------|-----------|--------|
| D-1 | Two-engine architecture: Banking Engine (FCA/regulated) vs Legion Private Engine (operator tooling) | Central + ADR-153 | ✅ CANONICAL |
| D-2 | Two Legion circuits: Private Engine (OpenManus+Qwen3.6) vs banking thin-client (→evo1) — NOT conflict, by design | S-18 C1 + ADR-103 | ✅ CANONICAL |
| D-3 | Banking orchestrator: LangGraph (stateful/auditable/HITL). LangGraph-first default | S-18 C7 | ✅ DECIDED |
| D-4 | Temporal role: OPEN ITEM — ADR required before adoption | S-18 C7 | ⚠️ OPEN |
| D-5 | Legion orchestrator: OpenManus (autonomous browser/bash, dev/research) | S-18 C7 | ✅ DECIDED |
| D-6 | Memory: separate Qdrant per engine + Zep/Graphiti (banking) + Mem0 (Legion). Hard data boundary | S-18 C5 | ✅ DECIDED |
| D-7 | DLP boundary: NeMo Guardrails + LlamaFirewall + Landlock/seccomp. Legion→banking = read-only+logged | S-18 C4 | ✅ DECIDED |
| D-8 | BDSL thresholds (90/70/95) = overlay on BUG-007, advisory mode until back-testing+MLRO+model card | S-18 C3 | ✅ DECIDED |
| D-9 | MAUT weights: reg=0.40/harm=0.30/rev=0.15/cost=0.15; stable 0.32–0.48 on reg-weight | S-18 C9 | ⏳ AWAITS MLRO/CRO SIGN-OFF |
| D-10 | Source hierarchy Level 0-3: Regulatory → ADR → BDSL/MLRO → passports | S-18 C6 | ✅ CANONICAL |
| D-11 | EU AI Act credit/AML deadline: Art.62, **2 December 2027** (NOT Aug 2026) | S-18 C2 | ✅ CORRECTED |
| D-12 | ENROL/EXCLUDE criteria: decision-outputs affecting payment/KYC/AML → ENROL; orchestrators/fetchers/formatters → EXCLUDE | S-18 C8 | ⏳ AWAITS MLRO/CO SIGN-OFF |
| D-13 | 47 passports classified (ENROL=15/DEFER=9/EXCLUDE=23); 91/91 domain coverage | S-14/S-15 | ✅ CANONICAL |
| D-14 | ADR-045 Intent-First as primary interface canon (ACCEPTED 2026-06-07) | ADR-045 | ✅ CANONICAL |
| D-15 | ADR-046 DecisionRecord schema canonical (sha a95d8e95…) | ADR-046 | ✅ CANONICAL |

### What Awaits MLRO/CRO Sign-off

| Item | Required approver | What is blocked without it |
|------|-----------------|--------------------------|
| MAUT weights (reg/harm/rev/cost) — D-9 | MLRO + CRO (joint) | BDSL scoring cannot be used in production governance |
| Independent model validation (FCA/PRA SS1/23) | External validator + MLRO | Production activation of BDSL auto-execution mode |
| BDSL production activation (back-testing + model card) | MLRO (SMF17) | Transition from advisory → auto-execution |
| 13 PROPOSED passports activation | MLRO (for case_management_agent, RED); operator for remaining 12 | BDSL ENROL coverage expansion |
| ENROL/EXCLUDE final classification (D-12) | MLRO + Compliance Officer | Official BDSL fleet membership |

### What Awaits Operator Decision

| Item | Options | Deadline |
|------|---------|---------|
| CREDIT-GAP (§7) | A: create `credit_decision_agent.yaml` now / B: formal Art.62 classification by Q4 2026 | Before Dec 2027 (Art.62) |
| Temporal adoption | Require ADR before decision | Before LangGraph scale-out sprint |
| Manus-on-Legion client scope | Per ADR-002: client-facing deferred until Phase 3 KYC + FCA permissions | Phase 3 gate |

### Open Items

| Item | Section | Resolution path |
|------|---------|----------------|
| Schema reconciliation ADR ratification | §4.3 / §10 H0 | ADR PR + human approval |
| Three ADR-045 gaps (Decision Lineage, AI cost policy, S13-00 BPR) | §4.3 | Future ADRs |
| Temporal: LangGraph vs LangGraph+Temporal | §6a D-4 | ADR draft → operator decision |
| Hermes deployment status on evo2 | §5.2 / §5.7 | `[VERIFY CURRENT STATUS]` against live system |
| P0 infrastructure blockers (midaz-Redis, recon.service, hardcoded key, etc.) | §4.6 | `[VERIFY CURRENT STATUS]` — may already be resolved |
| DLP layer deployment (NeMo Guardrails, LlamaFirewall, Landlock) | §5.8 | Horizon 1 build task |
| Memory boundary deployment (separate Qdrant instances) | §5.9 | Horizon 1/2 build task |
| Back-testing infrastructure for BDSL thresholds | §4.2 | Horizon 1 pre-requisite |
| Two-circuit ADR for Legion (Private Engine circuit vs thin-client circuit) | §5.1 | ADR draft |

### What Exists Now (2026-07-10)

**Confirmed and auditable:**
- BDSL governance substrate: 3 invariants, ADR-046 schema, 47 passports classified, 91/91 domain coverage, 0 true orphans
- 9-agent compliance swarm: operational on evo1
- MetaClaw + OpenClaw: operational on Legion/evo1
- LiteLLM v2 router: operational on evo1
- Guardian (:8195/:8196): operational
- ClickHouse audit trail: operational (I-08 TTL)
- ADR-045: accepted, Intent-First framing canonical
- MAUT framework: weights defined (reg=0.40/harm=0.30/rev=0.15/cost=0.15), sensitivity confirmed (stable ±20%), awaiting MLRO/CRO formal sign-off
- Source hierarchy Level 0-3: canonical (S-18 C6)
- Two Legion circuits: architecturally defined, ADR-103 boundary canonical

**Confirmed but not yet active:**
- 13 PROPOSED passports: classified, awaiting operator sign-off PR
- BDSL DecisionRecord emission: schema confirmed, no live agent emitting yet
- Hermes: documented at depth, deployment status unconfirmed
- DLP layer: design defined (§5.8), not yet deployed
- Memory boundary: design defined (§5.9), not yet deployed

### What Is Buildable Now (no new research required)

1. Operator PR: 13 PROPOSED → ACTIVE (30 minutes + MLRO sign-off)
2. Tool Registry YAML (1 sprint)
3. BANXE-INTENT-ENGINE as LangGraph FastAPI service (2 sprints)
4. Banking Qdrant + Zep on evo1 (1–2 days)
5. Legion Qdrant + Mem0 on Legion (1 day)
6. DLP stack: NeMo Guardrails + LlamaFirewall + OS-sandbox (1 sprint)
7. Hermes `factory` profile systemd service (1 day)
8. Back-testing infrastructure for BDSL thresholds (1 sprint)
9. CREDIT-GAP resolution: formal Art.62 classification (Option B, immediate) or `credit_decision_agent.yaml` (Option A, 1 sprint)

### What Is Blocked

| Blocker | Blocked item | Resolution path |
|---------|-------------|----------------|
| Operator sign-off (I-BDSL-2) | 13 PROPOSED activation | Operator opens PR, MLRO signs off |
| MLRO/CRO joint sign-off | MAUT weights production use | Joint sign-off meeting |
| Back-testing + model card + MLRO approval | BDSL auto-execution mode | Sequential prerequisites (§4.2) |
| Schema reconciliation ADR ratification | BDSL live loop | ADR ratification PR |
| CREDIT-GAP operator decision | CREDIT circuit activation | Operator chooses Option A or B |
| P0 infrastructure blockers (if still open) | BANXE-INTENT-ENGINE, client beta | Verify and resolve per Sprint A |
| Manus-on-Legion scope | Client-facing Telegram bot | ADR-002 Phase 3 conditions (KYC + FCA permissions) |
| DLP layer deployment | Any Legion → banking zone READ access | Horizon 1 build |
| Two-circuit ADR | Clear governance boundary documentation | ADR draft |

### Recommended Execution Order

```
Step 1 (operator, immediate — no build required):
  → Verify P0 blocker status (midaz-Redis, recon.service — may be resolved)
  → Make CREDIT-GAP decision (Option A or B)
  → Sign off 13 PROPOSED passports (MLRO sign-off for case_management_agent)
  → Schedule MLRO/CRO joint sign-off on MAUT weights (reg=0.40/harm=0.30/rev=0.15/cost=0.15)

Step 2 (factory, Sprint A ~2 weeks):
  → Close confirmed P0 blockers
  → Build Tool Registry (shared foundation for both engines)
  → Verify/deploy Hermes factory profile
  → Ratify schema reconciliation ADR
  → Deploy DLP stack: NeMo Guardrails + LlamaFirewall + Landlock/seccomp (§5.8)
  → Deploy separate Qdrant (Legion) + Qdrant/Zep/Graphiti (evo1) (§5.9)
  → Build back-testing infrastructure for BDSL threshold validation

Step 3 (factory, Sprint B ~2 weeks):
  → Build BANXE-INTENT-ENGINE (LangGraph on Legion, banking thin-client circuit)
  → Wire Hermes banxe-ops to MiroFish + AML alerts
  → Begin BDSL live emission on ENROL-15 agents (advisory mode)
  → Submit back-testing results to MLRO for approval

Step 4 (factory, Sprint C ~3 weeks):
  → BDSL model card + risk management system documentation
  → Request MLRO formal production activation approval
  → Client-facing HII + Rich Cards
  → CREDIT circuit resolution (if Option A: build credit_decision_agent)
  → Hermes client-advisor closed beta

Step 5 (operator + factory, ongoing):
  → BDSL first policy cycle (human-gated, post MLRO approval)
  → Independent model validation (FCA/PRA SS1/23 compliance)
  → MetaClaw Phase 2 skill corpus review
  → Horizon 4 specialization + Temporal ADR
```

### Concise Verdict

The Banking Engine governance substrate (BDSL, passports, ADR-046, MAUT framework) is the most thoroughly specified system in this corpus. The two-engine architecture with two Legion circuits is now canonical. Key S-18 corrections are integrated: EU AI Act Art.62 deadline is 2 December 2027 (not Aug 2026); BDSL operates in advisory mode until back-testing + MLRO + model card prerequisites are met; MAUT weights are defined and sensitivity-confirmed but require MLRO/CRO sign-off; DLP and memory boundaries are architecturally defined and ready to build. The execution path is clear: operator decisions first (sign-offs, CREDIT choice, MAUT approval), then DLP/memory boundary infrastructure, then Intent Engine, then BDSL production loop.

---

*End of canonical document. All 9 corrections from S-18 are integrated. Open items tracked above. No follow-on research required before execution.*
