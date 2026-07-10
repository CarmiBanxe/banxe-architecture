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
```

### What Is NOT Source-Confirmed

- **Manus-агент на Legion → Telegram-бот_Архитектура системы** — referenced by operator as important future input; ADR-002-telegram-bot-scope.md found (scope decision: operator terminal only, client-facing deferred to Phase 3 KYC/FCA), but no dedicated "Manus → Legion → Telegram bot architecture" document was found in current corpus. Marked `[NOT SOURCE-CONFIRMED]` where referenced below.
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

### 5.1 What the Legion Private Engine Is

The Legion Private Engine is the Software Factory + orchestration infrastructure through which the banking product is built and operated. It runs on Legion (primary terminal) with evo1/evo2 as execution targets. It is the system Moriel (Software Factory Lead) interacts with to produce all project code, manage sprints, run CI/CD, and monitor the banking stack.

Per the Central Terminal canon (`CLAUDE.md` global instructions): Central performs NOTHING directly on project repos. EVERYTHING — specs, code, tests, CI fixes, migrations, merges — goes through the factory as a task (`claude -p`). The factory executes and reports. This is the operational discipline of the Legion Private Engine.

### 5.2 Hermes/Factory as Engine Substrate

From S-07 (Hermes Agent BANXE Factory):

**Physical topology:**
- evo1: LiteLLM v2 router, Ollama, banxe-compliance-api, Jube, Marble, ClickHouse, PostgreSQL, Redis, Presidio PII proxy, n8n, Midaz Ledger
- evo2: IronClaw (WASM sandbox), MicroFish (offline inference), Hyperswitch
- Legion: MetaClaw, OpenClaw (primary orchestration), NanoClaw, ClawArena, Software Factory Lead terminal

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

**No-Wait Rule (immutable):** Central NEVER waits for Terminal A. Factory imperfections are A's concern. Central delegates project work to factory continuously regardless of infra-perfection.

**Best-Single-Artifact Rule:** After any output, Central ALWAYS emits exactly ONE next-action artifact (`[CLAUDE CODE]` for state changes, `[SHELL]` for read-only audit). No alternatives, no variations, no menus.

### 5.4 MetaClaw Learning Loop

MetaClaw operates as a transparent proxy in front of OpenClaw:
- Intercepts all trajectories (prompt → response → outcome)
- Synthesizes skills during idle periods (≥5min threshold → skill distillation)
- Injects verified skills into subsequent OpenClaw calls (few-shot without fine-tuning)
- Phase 1 (current): `rlmode: false` — collecting trajectories
- Phase 3 (future): RL mode via cloud LoRA (`tinkercloud.enabled: true`)

This is In-Context Learning (ICL) + episodic memory, not model fine-tuning. The distinction matters: the banking product cannot use this learning model (violates I-BDSL-2 without explicit human-gating), but the factory can use it freely because factory output is reviewed before merging.

### 5.5 What Is Missing for Legion Private Engine

1. **Hermes server deployment** — documented but not confirmed as running on evo2 VPS. Three profiles defined; actual systemd service / Docker deployment status: `[NOT SOURCE-CONFIRMED]`.
2. **Tool Registry** — same gap as banking engine but from the factory side. Factory tools are scattered across passport files and `.claude/skills/`.
3. **BANXE-INTENT-ENGINE** — specifically for client-facing; the factory already has OpenClaw/Ruflo for internal orchestration. But the client-facing intent parser (LangGraph on Legion) is not built.
4. **Manus-on-Legion → Telegram bot architecture** — `[REFERENCED BY OPERATOR AS IMPORTANT FUTURE INPUT, NOT SOURCE-CONFIRMED IN CURRENT CORPUS]`. ADR-002 (telegram-bot-scope) establishes that current bot = operator terminal only; client-facing deferred to Phase 3 KYC+FCA permissions.
5. **Unified private orchestration runtime spec** — the Legion Private Engine's overall runtime topology is described across multiple documents (S-07, S-08) but has no single formal spec document equivalent to ADR-045 for the banking engine.

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
  │   └── CREDIT-GAP: identified, localized, not resolved
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
  └── Manus-on-Legion → Telegram client-facing (future, NOT SOURCE-CONFIRMED)

Maturity Tier 4 (research / world benchmarks, not yet on BANXE roadmap):
  ├── PRAGMA (Revolut, 40B transaction events) — referenced in S-02
  ├── nuFormer (Nubank) — referenced in S-02
  ├── FATE federated learning (WeBank model) — referenced in S-06
  └── DeerFlow 2.0 (ByteDance super-harness) — referenced in S-04
```

The banking engine's governance layer (Tier 1) is the most thoroughly specified system in this corpus. The Legion private engine's operational layer (Tier 2) is the most deployed. The product-facing intent engine (Tier 3) is the most important gap.

---

## §7 — CREDIT-GAP: EU AI Act Annex III §5

### Status: BLOCKER — CREDIT circuit only

**What is missing:** No `credit_decision_agent` passport exists. No `lending_agent`, `savings_decision_agent`, `insurance_underwriting_agent`, or `card_credit_agent` exists as a dedicated decision-emitting agent.

**Where credit logic lives (confirmed in S-15):**
- `finance/apar_agent.yaml` — AP/AR management with embedded credit-terms decisions
- `channel_c_sepa_orchestrator.yaml` — SEPA payment routing including credit facility drawdown

**Why this is a blocker (EU AI Act Annex III §5):**
Credit scoring and creditworthiness assessment for individuals/businesses is classified HIGH-RISK under EU AI Act Annex III §5. This requires:
- Dedicated accountability structure with named responsible person
- Dedicated audit trail traceable to that agent's decisions
- Explainability requirement per decision (I-BDSL-3 equivalent)
- No credit decision can be embedded as an undifferentiated sub-function of a broader agent

The current state — credit logic embedded in `apar_agent` and `channel_c_sepa_orchestrator` — does not satisfy this requirement.

**What is NOT blocked:**
This blocker applies ONLY to the CREDIT circuit. AML / KYC / PAYMENT / COMPLIANCE BDSL activation is NOT blocked by the CREDIT-GAP.

**Operator decision required (two options):**

| Option | Action | Consequence |
|--------|--------|-------------|
| A | Create `credit_decision_agent.yaml` passport | EU AI Act §5 satisfied; credit logic becomes auditable, HITL-gated, L3+ agent |
| B | Formal out-of-scope declaration + deferred roadmap | Credit circuit explicitly deferred; BDSL activation proceeds on all other circuits |

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
- [ ] Manus-on-Legion → Telegram client advisory interface: `[OPERATOR DECISION REQUIRED]` — define scope per ADR-002 (client-facing deferred until Phase 3 KYC + FCA permissions cleared) `[NOT SOURCE-CONFIRMED AS CURRENTLY SCOPED]`

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

## §11 — Final Canonical Outcome

### What Exists Now (2026-07-10)

**Confirmed and auditable:**
- BDSL governance substrate: 3 invariants, ADR-046 schema, 47 passports classified, 91/91 domain coverage, 0 true orphans
- 9-agent compliance swarm: operational on evo1
- MetaClaw + OpenClaw: operational on Legion/evo1
- LiteLLM v2 router: operational on evo1
- Guardian (:8195/:8196): operational
- ClickHouse audit trail: operational (I-08 TTL)
- ADR-045: accepted, Intent-First framing canonical

**Confirmed but not yet active:**
- 13 PROPOSED passports: classified, awaiting operator sign-off PR
- BDSL DecisionRecord emission: schema confirmed, no live agent emitting yet
- Hermes: documented at depth, deployment status unconfirmed

### What Is Buildable Now (no new research required)

1. Operator PR: 13 PROPOSED → ACTIVE (30 minutes + MLRO sign-off)
2. Tool Registry YAML (1 sprint)
3. BANXE-INTENT-ENGINE as LangGraph FastAPI service (2 sprints)
4. Qdrant on evo1 (1 day — single Docker run)
5. Hermes `factory` profile systemd service (1 day)
6. CREDIT-GAP resolution via `credit_decision_agent.yaml` creation (1 sprint, if Option A chosen)

### What Is Blocked

| Blocker | Blocked item | Resolution path |
|---------|-------------|----------------|
| Operator sign-off (I-BDSL-2) | 13 PROPOSED activation | Operator opens PR, MLRO signs off |
| Schema reconciliation ADR ratification | BDSL live loop | ADR ratification PR |
| CREDIT-GAP operator decision | CREDIT circuit activation | Operator chooses Option A or B |
| P0 infrastructure blockers (if still open) | BANXE-INTENT-ENGINE, client beta | Verify and resolve per Sprint A |
| Manus-on-Legion scope | Client-facing Telegram bot | ADR-002 Phase 3 conditions (KYC + FCA permissions) |

### What Is Next

**Recommended execution order:**

```
Step 1 (operator, immediate):
  → Verify P0 blocker status (are they still open or already resolved?)
  → Make CREDIT-GAP decision (Option A or B)
  → Sign off 13 PROPOSED passports (MLRO sign-off for case_management_agent)

Step 2 (factory, Sprint A ~2 weeks):
  → Close confirmed P0 blockers
  → Build Tool Registry (shared foundation for both engines)
  → Verify/deploy Hermes factory profile
  → Ratify schema reconciliation ADR

Step 3 (factory, Sprint B ~2 weeks):
  → Build BANXE-INTENT-ENGINE (LangGraph on Legion)
  → Deploy Qdrant on evo1
  → Wire Hermes banxe-ops to MiroFish + AML alerts
  → Begin BDSL live emission on ENROL-15 agents

Step 4 (factory, Sprint C ~3 weeks):
  → Client-facing HII + Rich Cards
  → CREDIT circuit resolution (if Option A: build credit_decision_agent)
  → Hermes client-advisor closed beta

Step 5 (operator + factory, ongoing):
  → BDSL first policy cycle (human-gated)
  → MetaClaw Phase 2 skill corpus review
  → Horizon 4 specialization
```

### Concise Verdict

The Banking Engine governance substrate (BDSL, passports, ADR-046) is the most thoroughly specified system in this corpus and is ready for operator activation. The Legion Private Engine operational layer (MetaClaw, OpenClaw, compliance swarm) is already running. The gap between them is the product-facing intent layer — BANXE-INTENT-ENGINE, Tool Registry, Qdrant — which is buildable in 2–3 sprints with no further research. The CREDIT circuit is an isolated blocker that does not hold up the rest. Execution order: operator decisions first (sign-offs, CREDIT choice), then Tool Registry, then Intent Engine, then live BDSL loop.

---

*End of canonical document. No follow-on documents are required before execution. All open items are tracked above as actionable steps.*
