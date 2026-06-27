# BANXE Agent Engine — Архитектурный аудит
# Статус: READ-ONLY AUDIT | Дата: 2026-06-28
# Репо: banxe-architecture | Ветка: main

---

## 1. Executive Facts

1. **Guardian System (ADR-139) ACCEPTED 2026-06-26** — Self-hosted PR-audit service with dual ports: Factory :8195 (qwen3.5:35b, F1-F8 rules) + Project :8196 (llama3.3:70b, P1-P8 rules). Both agents deterministic, low-risk, auto gate authority. **Evidence:** `docs/adr/ADR-139-guardian-system.md` (status: ACCEPTED); `docs/canon/passports/guardian-factory.yaml` (port 8195); `docs/canon/passports/guardian-project.yaml` (port 8196).

2. **Multi-Actor Orchestration (ADR-060) ACCEPTED 2026-06-09** — Orchestration spine: namespaced branches (`agent/<actor>/<id>/<slug>`), append-only per-session ledger shards, merge queue serialization, guardian gates. Enforces ADR-056 (ledger coupling), ADR-057 (append-only), ADR-059 (per-session shards). **Evidence:** `docs/adr/ADR-060-multi-actor-orchestration.md` (status: Accepted).

3. **Intent-First Architecture (ADR-045) ACCEPTED 2026-06-07** — Four-layer model: L1 Intent Layer (governed business intents), L2 Client-Facing Agent Masks (L1→L2 masking), L3 Execution (backend services), L4 Audit (ClickHouse 5Y TTL, I-24). Pairs with ADR-049 (Intent Layer client masks specification). **Evidence:** `docs/adr/ADR-045-intent-first-banking-architecture.md` (status: ACCEPTED); `docs/adr/ADR-049-intent-layer-client-facing-agent-masks.md` (status: PROPOSED).

4. **Shared Memory Substrate (ADR-136) PROPOSED 2026-06-27** — Factory-only decision: `agentmemory` vs project fork gating under ADR-135 held-out gate. Tier-1 read-only (no authority expansion per ADR-127). Companion Memoir versioned-memory pilot (ADR-137) ACCEPTED 2026-06-27, stays separate future work. **Evidence:** `docs/adr/ADR-136-agentmemory-shared-memory-substrate.md` (status: PROPOSED); `docs/adr/ADR-137-memoir-versioned-memory-pilot.md` (status: ACCEPTED with deferral note).

5. **Central IL Allocator (ADR-143) PROPOSED 2026-06-27** — Redis INCR on `banxe:il:counter` replaces unsafe local max+1; amends ADR-119 (provisional IL numbering). Mints IL-613 (this ADR). Serialization fix for cross-worktree IL collision (IL-172 class). **Evidence:** `docs/adr/ADR-143-redis-central-il-allocator.md` (status: PROPOSED, il_anchor: IL-613).

6. **ClickHouse audit trail (I-24) ACTIVE** — Append-only immutable TTL ≥5Y for all compliance events. Required by MLR 2017, CASS 15, EU AI Act Art.14. Enforced by Semgrep rule + Guardian append-only job. **Evidence:** `docs/COMPLIANCE-MATRIX.md` (rows S5-07, S11-10); `docs/SYSTEM-ARCHITECTURE.md` (:9000/8123); `docs/adr/ADR-057-ledger-append-only-immutability.md`.

7. **n8n workflow automation (:5678) ACTIVE** — Fair-code self-hosted on evo1. Regulatory reporting pipelines + MLRO alerts (CASS 7.15 discrepancy webhook). **Evidence:** `docs/DEPLOYMENT-ARCHITECTURE.md` (:5678); `docs/D-RECON-DESIGN.md` (MLRO alert via n8n webhook).

8. **LiteLLM v2 gateway (:4000, Meta-Plane routing)** — All AI inferences route via `legion:4000` (Ollama + llama.cpp + RPC worker). PII deny-paths local-only (I-33). **Evidence:** `docs/adr/ADR-040-ai-execution-policy.md` (Inference-plane section); `docs/DEPLOYMENT-ARCHITECTURE.md` (:4000 LiteLLM).

9. **Port map CONFIRMED** — Screener :8085 (proprietary Watchman wrapper), Auto-Verify API :8094 (compliance/AML validator), Guardian factory :8195, Guardian project :8196, n8n :5678, LiteLLM :4000, ClickHouse :9000. All documented in DEPLOYMENT-ARCHITECTURE and referenced in ADRs. **Evidence:** `docs/DEPLOYMENT-ARCHITECTURE.md` (§Services table); `docs/adr/ADR-139-guardian-system.md` (ports 8195/8196).

10. **Marble (case management, fraud rules) INTEGRATED** — Apache 2.0 self-hosted in `services/case_management/marble_adapter.py`. No AGPL risk (unlike Jube). OSS replacement for proprietary fraud/rules engines. **Evidence:** `docs/sessions/SNAPSHOT-2026-05-06-oss-sumsub-replacement-block.md` (Marble Apache 2.0); `docs/canon/g-sec-01-audit-2026-05-06.md` (services/case_management/marble_adapter.py).

11. **Compliance agents PASSPORTS EXIST** — 70+ agent passports defined in `agents/passports/`. Department-head PROPOSED stubs created in Sprint 2 (GAP-077). Service implementation → GAP-078 (Sprint 3). Pattern: agent_id → passport YAML → allowed_skills + gate_authority → HITL mapping. **Evidence:** `agents/passports/` (70 files); `docs/GAP-REGISTER.md` (GAP-077, GAP-078).

12. **No orchestration spine / A2A contract / Temporal / Qdrant IN PROJECT SCOPE** — ADR-045 cites these as conceptual L1 governance (not deployed). No MCP tool registry binding. ADR-136/137 memory pilots deferred. Execution sandbox contract и semantic memory index not confirmed in code. **Evidence:** `docs/adr/ADR-045-intent-first-banking-architecture.md` (concept_only: true); no PRs landing `Temporal`, `Qdrant`, `A2A contract`.

---

## 2. Evidence Matrix

| Артефакт | Путь | Статус | Ключевые строки/содержание |
|----------|------|--------|-----|
| **ADR-045** | docs/adr/ADR-045-intent-first-banking-architecture.md | **ACCEPTED** 2026-06-07 | Four-layer model (L1 Intent, L2 Masks, L3 Exec, L4 Audit). concept_only: true. binding_artifact: INTENT-FIRST-CANON-2026-06-07.md |
| **ADR-049** | docs/adr/ADR-049-intent-layer-client-facing-agent-masks.md | **PROPOSED** 2026-06-07 | L1→L2 client masking contract; intent resolves to process_ref; cost-cap per mask (AUTO/REVIEW/BLOCK). concept_only: true. No service code. |
| **ADR-060** | docs/adr/ADR-060-multi-actor-orchestration.md | **ACCEPTED** 2026-06-09 | Namespaced branches `agent/<actor>/<id>/<slug>`; merge queue serialization; per-session shards; append-only projection. Related: ADR-056/057/059. |
| **ADR-136** | docs/adr/ADR-136-agentmemory-shared-memory-substrate.md | **PROPOSED** 2026-06-27 | Factory-only fork vs project fork boundary. Tier-1 read-only (per ADR-127). external_ref: rohitg00/agentmemory (NOT imported). scope: BANXE-factory-only. |
| **ADR-137** | docs/adr/ADR-137-memoir-versioned-memory-pilot.md | **ACCEPTED** 2026-06-27 | Factory-only pilot UNDER ADR-136. Memoir (branch/commit/merge/rollback). Pilot entry deferred; preconditions must pass. external_ref: zhangfengcdt/memoir (NOT imported). |
| **ADR-139** | docs/adr/ADR-139-guardian-system.md | **ACCEPTED** 2026-06-26 | Factory :8195 (qwen3.5:35b, F1-F8) + Project :8196 (llama3.3:70b, P1-P8). Deterministic rules. Auto gate authority. Enforces IL coupling, ledger append-only, branch naming. |
| **ADR-143** | docs/adr/ADR-143-redis-central-il-allocator.md | **PROPOSED** 2026-06-27 | Redis INCR `banxe:il:counter` replaces max+1. Fixes IL-172 collision. Amends ADR-119. Serialization across worktrees. |
| **Guardian Factory Passport** | docs/canon/passports/guardian-factory.yaml | **ACTIVE** | actor: guardian-factory-service; port :8195; tools: factory_rules.py, github-status-check, clickhouse-append; backbone qwen3.5:35b. |
| **Guardian Project Passport** | docs/canon/passports/guardian-project.yaml | **ACTIVE** | actor: guardian-project-service; port :8196; tools: project_rules.py, github-status-check, clickhouse-append; backbone llama3.3:70b. |
| **Screener :8085** | docs/DEPLOYMENT-ARCHITECTURE.md (line 55) | **ACTIVE** | Proprietary Watchman wrapper; HTTP internal; active on evo1. |
| **Auto-Verify API :8094** | docs/DEPLOYMENT-ARCHITECTURE.md (line 68–69) | **ACTIVE** | Proprietary FastAPI compliance validator; HTTP internal; active on evo1. |
| **n8n :5678** | docs/DEPLOYMENT-ARCHITECTURE.md (line 69); docs/D-RECON-DESIGN.md | **ACTIVE** | Fair-code self-hosted; MLRO alert webhook (CASS 7.15); regulatory reporting pipelines. |
| **LiteLLM :4000** | docs/DEPLOYMENT-ARCHITECTURE.md (line 75); docs/adr/ADR-040 | **ACTIVE** | OpenAI-compatible router; Ollama + llama.cpp + RPC; evo1 LAN; Meta-Plane routing. |
| **ClickHouse :9000/8123** | docs/DEPLOYMENT-ARCHITECTURE.md (line 64); docs/SYSTEM-ARCHITECTURE.md | **ACTIVE** | Audit trail 5Y TTL (I-24); append-only immutable; FCA CASS 15 retention. |
| **Marble (case_management)** | docs/sessions/SNAPSHOT-2026-05-06-oss-sumsub-replacement-block.md; docs/canon/g-sec-01-audit-2026-05-06.md | **INTEGRATED** | Apache 2.0 OSS; fraud rules + case management; self-hosted; no AGPL risk. Path: services/case_management/marble_adapter.py |
| **Compliance Agent Passports** | agents/passports/ (70 files) | **70+ EXIST** | Agent IDs for AML, KYC, fraud, safeguarding, reporting, treasury, payments. Pattern: role_id → responsibility → HITL gates → invariants. |
| **Department-Head Agent Stubs** | docs/GAP-REGISTER.md (GAP-077, GAP-078); governance/STAFF-MATRIX-v1.md | **PROPOSED STUBS** | 10 PROPOSED passports: ceo_orchestration, board_reporting, internal_audit, risk_oversight, cfo_orchestration, coo_operations, cto_platform, front_office, legal_corporate, compliance_monitoring. Sprint-2 DONE; Sprint-3 service code pending. |
| **Ledger Append-Only (ADR-057)** | docs/adr/ADR-057-ledger-append-only-immutability.md | **ACCEPTED** | IL-XXX assignments immutable after commit. `.github/workflows/guardian.yml` `ledger-append-only` job enforces. |
| **Per-Session Shards (ADR-059)** | docs/adr/ADR-059-il-append-serialization-per-session-shards.md | **ACCEPTED** | INSTRUCTION-LEDGER.md is generated read-only projection; new entries append to `ledger/entries/SHARD-<session>.jsonl`. Removes merge races. |
| **Merge Queue Serialization** | docs/adr/ADR-060, LEDGER-MERGE-QUEUE.md | **BLOCKED** | Native GitHub merge queue unavailable (user repo, org-only). ADR-143 Redis allocator provides alternative serialization. Operator must enable merge queue if GitHub org status changes. |
| **Keycloak IAM :8180** | docs/DEPLOYMENT-ARCHITECTURE.md; docs/SYSTEM-ARCHITECTURE.md | **ACTIVE** | Version 26.2; auth for BANXE API; HITL RBAC (MLRO/CEO/CTIO roles). |
| **Jube adapter (I-15)** | docs/sessions/SNAPSHOT-2026-05-06-oss-sumsub-replacement-block.md | **AGPL-LICENSED** | AGPL-3.0; deployed isolated microservice; no direct linkage with proprietary code. I-15 (Jube internal only). Legal review completed. |
| **I-24 (Append-only audit)** | docs/COMPLIANCE-MATRIX.md; docs/adr/ADR-057 | **ENFORCED** | Semgrep `banxe-audit-delete` blocks DELETE on audit tables. ClickHouse TTL ≥5Y. Guardian append-only job. |
| **Compliance-MATRIX.md** | docs/COMPLIANCE-MATRIX.md | **GOVERNANCE** | Master compliance tracking; S1-S15 blocks; 35% coverage of TZ (Compliance-brain strong; payment/CBS blocks critical). |
| **GAP-REGISTER.md** | docs/GAP-REGISTER.md | **OPERATIONAL** | 78 GAPs tracked; P0/P1/P2 priority; Sprint assignment; owner; deadline; status. P0 deadline: 7 May 2026 (safeguarding). |
| **Passports schema** | docs/canon/passports/schema.yaml | **DEFINED** | role_id, actor, responsibility, tools[], allowed_skills[], gate_authority, risk_ceiling, invariants_enforced[], litellm_routes[], notes. |
| **Temporal NOT FOUND** | N/A | **❌ NOT DEPLOYED** | Mentioned in `financial-analytics-research.md` as Phase 1 (ETA unknown). No ADR, no service code, no passport. |
| **Qdrant NOT FOUND** | N/A | **❌ NOT DEPLOYED** | Semantic memory indexing not confirmed. ADR-136 agentmemory stays Tier-1 read-only (no vector DB). |
| **A2A Contract NOT FOUND** | N/A | **❌ NOT DEFINED** | Agent-to-agent message schema not located. Agents exist but inter-agent communication protocol not documented. |
| **Execution Sandbox Contract NOT FOUND** | N/A | **❌ NOT DEFINED** | No formal sandbox execution contract. L1 intent isolation from L3 execution is governance-only. |
| **Semantic Memory Index NOT FOUND** | N/A | **❌ NOT DEPLOYED** | Memory substrate (ADR-136/137) deferred; no production semantic index. agentmemory Tier-1 read-only. |
| **Tool Registry / MCP Binding NOT FOUND** | N/A | **❌ NOT FORMALIZED** | MCP tools exist (banxe-emi-stack banxe_mcp/server.py, 34 tools); no central registry linking agents ↔ tools ↔ skills. |

---

## 3. Confirmed Reusable Components

### 3.1 Orchestration (Existing)

- **Guardian Dual-Agent System (ADR-139)** — Factory :8195 + Project :8196; deterministic rule-based audit gates (F1-F8 and P1-P8). Status: **DEPLOYED**.
  - Path: `docs/adr/ADR-139-guardian-system.md`
  - Ports: :8195 (factory, qwen3.5:35b), :8196 (project, llama3.3:70b)
  - Gate authority: AUTO
  - Enforces: IL coupling, ledger append-only, branch naming

- **Multi-Actor Branch Namespace (ADR-060)** — `agent/<actor>/<id>/<slug>` enforces uniqueness + serialization. Status: **ACCEPTED, POLICY-LEVEL** (gate enforced by Guardian).
  - Path: `docs/adr/ADR-060-multi-actor-orchestration.md`
  - Enforces: Central terminal + right terminal + factory isolation

- **Per-Session Ledger Shards (ADR-059)** — Append-only per-session `ledger/entries/SHARD-<session>.jsonl`. Status: **ACCEPTED, IMPLEMENTED**.
  - Path: `docs/adr/ADR-059-il-append-serialization-per-session-shards.md`
  - Eliminates merge races; INSTRUCTION-LEDGER.md is generated projection

### 3.2 Tool / Capability Layer (Existing)

- **MCP Tool Registry** — 34 tools in `banxe-emi-stack/banxe_mcp/server.py` (financial, ARL, design, KB, monitoring, experiments). Status: **DEPLOYED**.
  - Path: `banxe-emi-stack/banxe_mcp/server.py`
  - Examples: `get_account_balance`, `monitor_score_transaction`, `kb_query`, `route_agent_task` (ARL Tier 1/2/3)
  - No central registry mapping agents ↔ tools (registration is hardcoded)

- **n8n Workflow Automation (:5678)** — Fair-code self-hosted; regulatory reporting + MLRO alerts. Status: **ACTIVE**.
  - Path: `docs/DEPLOYMENT-ARCHITECTURE.md` (line 69)
  - Ports: :5678
  - Used for: CASS 7.15 discrepancy alerts, FIN060 generation

- **Compliance Validator (Auto-Verify :8094)** — FastAPI compliance/AML agent response validator. Status: **ACTIVE**.
  - Path: `docs/SYSTEM-ARCHITECTURE.md` (line 114)
  - Port: :8094
  - Validates: L2 mask → L3 execution contract

### 3.3 Memory / State (Existing)

- **ClickHouse Audit Trail (I-24)** — Append-only 5Y TTL immutable log. Status: **ACTIVE, ENFORCED**.
  - Path: `docs/COMPLIANCE-MATRIX.md`, `docs/adr/ADR-057`
  - Port: :9000 (native), :8123 (HTTP)
  - TTL: ≥5Y (FCA CASS 15 retention)
  - Enforced by: Semgrep `banxe-audit-delete`, Guardian append-only job

- **Per-Session Worktree Isolation (ADR-120)** — Each session owns isolated worktree; branch namespace maps to session ID. Status: **GOVERNANCE-LEVEL**.
  - Path: `docs/adr/ADR-120-session-worktree-isolation.md` (referenced, exact path not verified)
  - Session memory: IL entries in `ledger/entries/SHARD-<session>.jsonl`

### 3.4 Guardrails / Compliance (Existing)

- **Intent-First Four-Layer Model (ADR-045)** — L1 Intent → L2 Agent Masks → L3 Backend Services → L4 Audit. Status: **ACCEPTED, GOVERNANCE-ONLY** (no L1→L2 code deployed yet).
  - Path: `docs/adr/ADR-045-intent-first-banking-architecture.md`
  - Binding artifact: `docs/canon/INTENT-FIRST-CANON-2026-06-07.md`
  - Scope: BANXE-only, concept_only: true

- **Agent Autonomy Levels (L1-L4)** — L1 Auto, L2 Alert→Human, L3 Auto+HITL, L4 Human-Only. Status: **GOVERNANCE-DEFINED**.
  - Path: `docs/canon/passports/schema.yaml` (gate_authority field)
  - HITL gates: SAR filing (L4/MLRO), AML threshold change (L4/MLRO), sanctions reversal (L4), PEP onboarding (L3→L4)

- **Marble (OSS Case Management)** — Apache 2.0 fraud rules + case management; no AGPL risk. Status: **INTEGRATED**.
  - Path: `services/case_management/marble_adapter.py` (banxe-emi-stack)
  - License: Apache 2.0
  - Scope: Internal compliance domain

### 3.5 Communication (Existing)

- **Guardian GitHub Webhook Integration** — GitHub App id 15368 → Guardian factory/project (:8195/:8196) → check_runs posted back. Status: **GOVERNANCE-DEFINED, PARTIALLY DEPLOYED** (webhook delivery Tailscale-gated, configuration documented).
  - Path: `docs/project/runbooks/github-webhook-guardian-deploy-2026-05-13.md`
  - Webhook secrets: environment variables (GUARDIAN_WEBHOOK_SECRET_*)
  - Events: pull requests, pushes, check_runs, workflow_runs

- **LiteLLM Meta-Plane Router (:4000)** — Centralized AI routing; Ollama + llama.cpp + RPC. Status: **ACTIVE**.
  - Path: `docs/adr/ADR-040-ai-execution-policy.md` (Inference-Plane section)
  - Port: :4000 (LAN-only, evo1)
  - Routes: factory-fast (Haiku), factory-mid (Sonnet), factory-heavy (Opus), project-reason (local aliases)

---

## 4. Confirmed Gaps

### 4.1 Orchestration Spine

**What is missing:** Centralized orchestration engine that:
- Dispatches intents (L1) → agent masks (L2) with cost governance
- Routes masks → services (L3) with idempotency + correlation tracking
- Escalates to HITL gates (L4) with human double assignment
- Logs all decisions to ClickHouse audit trail

**What exists (partial):**
- Guardian gates (ADR-139) — rule-based, deterministic, NO intent dispatch
- Per-session ledger shards (ADR-059) — records IL entries, not agent decisions
- Intent-First contract (ADR-045) — governance model, not deployed code
- Compliance agent passports (agents/passports/) — 70+ agents defined, NO orchestrator binding

**Gap severity:** **HIGH** — L1→L2→L3 dispatch is governance-only; no orchestrator implements it.

**Evidence path:** `docs/adr/ADR-045-intent-first-banking-architecture.md` (concept_only: true); `docs/adr/ADR-049-intent-layer-client-facing-agent-masks.md` (specification only, no code).

### 4.2 Tool Registry

**What is missing:** Centralized registry linking:
- Agent passport ID → available tools list
- Tool ID → MCP method + signature
- Skill ID → tool invocation rules + ordering

**What exists (partial):**
- MCP tools in `banxe_mcp/server.py` — 34 tools hardcoded, no metadata registry
- Agent passport `allowed_skills[]` — list of skill IDs, no tool binding
- SKILLS-ORCHESTRATION.md — manual policy document, not enforced registry

**Gap severity:** **MEDIUM** — Tools exist, agents exist, but no runtime binding mechanism.

**Evidence path:** `banxe-emi-stack/banxe_mcp/server.py`; `agents/passports/` (no tool registry field); `docs/SKILLS-ORCHESTRATION.md`.

### 4.3 Semantic Memory Index

**What is missing:**
- Qdrant or equivalent vector DB for embedding-based context retrieval
- agentmemory bridge for session context → semantic layer
- Memoir version control layer (deferred pilot)

**What exists (partial):**
- ADR-136 (agentmemory substrate) — PROPOSED, factory-only, not deployed
- ADR-137 (Memoir pilot) — ACCEPTED with deferral (preconditions not met)
- Per-session shards (ADR-059) — append-only ledger, not semantic index

**Gap severity:** **MEDIUM-HIGH** — Deferred to later phases (Phase 2+). ADR-136 explicitly marks as out-of-scope for project (factory-only).

**Evidence path:** `docs/adr/ADR-136-agentmemory-shared-memory-substrate.md` (scope: BANXE-factory-only); `docs/adr/ADR-137-memoir-versioned-memory-pilot.md` (acceptance_note: "pilot stays separate future work").

### 4.4 Agent Communication Contract (A2A)

**What is missing:**
- Formal schema for agent-to-agent message routing
- Message format (request/response/async event)
- Protocol for inter-agent skill requests (e.g., MLRO Agent → AML Agent)
- Replay/replay-detection (exactly-once semantics)

**What exists (partial):**
- Agent passports (agents/passports/) — define agent roles, tools, autonomy
- Guardian gates (ADR-139) — audit agent actions, do NOT define A2A messages
- n8n workflows (:5678) — orchestrate steps, not A2A messaging

**Gap severity:** **HIGH** — No documented protocol for agents calling other agents. Multi-agent scenarios (MLRO → AML → Sanctions) rely on hardcoded service calls, not A2A messaging.

**Evidence path:** No ADR found for A2A contract; agents passports do not reference communication protocol.

### 4.5 Execution Sandbox Contract

**What is missing:**
- Formal sandbox execution model (what agent code can/cannot do)
- Capability isolation (agent A cannot escalate to agent B's HITL authority)
- Execution environment specification (Python VENV? Docker container? Function-as-a-service?)
- Fault isolation (agent A failure → agent B unaffected)

**What exists (partial):**
- Autonomy levels (L1-L4) — governance policy
- HITL gates (services/hitl/hitl_service.py, banxe-emi-stack) — human approval gates
- Passport risk_ceiling field — risk classification (LOW/MEDIUM/HIGH)

**Gap severity:** **MEDIUM** — Autonomy policy is defined, but execution sandbox contract (how to enforce it) is not formalized.

**Evidence path:** `docs/canon/passports/schema.yaml` (gate_authority, risk_ceiling); `banxe-emi-stack/services/hitl/hitl_service.py` (gate implementation).

### 4.6 Temporal Workflow Engine (Out of Scope, Phase 2+)

**What is missing:** Saga pattern support for long-running multi-step workflows (e.g., payment settlement → reconciliation → reporting).

**What exists:** Referenced as Phase 1 ETA unknown in `financial-analytics-research.md`. No ADR, no code.

**Gap severity:** **MEDIUM-LOW** — Acknowledged as future; not P0 blocker.

**Evidence path:** `docs/financial-analytics-research.md` (line 230: "Workflow | Temporal | Phase 1").

---

## 5. Minimal Target Architecture — Evidence Only

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    BANXE Agent Engine — Target Model                    │
│              (Evidence-Based; [GAP] = Unconfirmed / Deferred)            │
└─────────────────────────────────────────────────────────────────────────┘

═══ INPUT LAYER ═══
  GitHub PR / Webhook
         │
         ▼
  GitHub App id 15368
  (webhook delivery via Tailscale)
         │
         ▼
┌──────────────────────────────────────────┐
│   Guardian Dual-Agent (ADR-139)          │
│  ┌────────────────────────────────────┐  │
│  │ Factory :8195 (qwen3.5:35b)        │  │ F1-F8 Rules
│  │ - factory_rules.py (deterministic) │  │ - Tool binding compliance
│  │ - github-status-check              │  │ - Factory CI/CD gates
│  │ - clickhouse-append (I-24)         │  │
│  └────────────────────────────────────┘  │
│  ┌────────────────────────────────────┐  │
│  │ Project :8196 (llama3.3:70b)       │  │ P1-P8 Rules
│  │ - project_rules.py (deterministic) │  │ - ADR compliance
│  │ - github-status-check              │  │ - Domain invariants
│  │ - clickhouse-append (I-24)         │  │
│  └────────────────────────────────────┘  │
│  Gate Authority: AUTO                    │
│  Enforces: IL coupling + append-only     │
│           branch naming + ADR refs       │
└──────────────────────────────────────────┘
         │ (check_runs + audit log)
         ▼
  ClickHouse audit table
  (guardian_audit_factory / guardian_audit_project, 5Y TTL)

═══ ORCHESTRATION LAYER ═══
         │ (PR approved by Guardian)
         ▼
  [GAP] Intent Dispatcher (L1→L2)
  ┌─────────────────────────────────────────────────────────┐
  │ NOT DEPLOYED — Governance only (ADR-045/049)          │
  │ Expected: Intent(L1) → Agent Mask(L2) cost dispatch     │
  │ + correlation_id + request_id propagation              │
  └─────────────────────────────────────────────────────────┘
         │
         ▼
  Agent Passports (70+ exist in agents/passports/)
  ┌─────────────────────────────────────────────────────────┐
  │ Defined: role_id, actor, tools[], allowed_skills[]     │
  │ Autonomy: gate_authority (L1-L4)                        │
  │ Deployment: Guardian validates; PROPOSED stubs exist    │
  │            (service code implementation → Sprint 3)     │
  └─────────────────────────────────────────────────────────┘
         │
         ▼
  [GAP] Agent Communication Contract (A2A)
  ┌─────────────────────────────────────────────────────────┐
  │ NOT DEFINED — no message schema for agent→agent calls  │
  │ Current: hardcoded service imports (banxe-emi-stack)   │
  │ Needed: formal protocol (schema, exactly-once, replay) │
  └─────────────────────────────────────────────────────────┘
         │
         ▼
  [GAP] Tool Registry / MCP Binding
  ┌─────────────────────────────────────────────────────────┐
  │ PARTIAL — 34 MCP tools in banxe_mcp/server.py          │
  │ Missing: central registry linking agents ↔ tools        │
  │ Current: hardcoded @mcp_server.tool() definitions      │
  └─────────────────────────────────────────────────────────┘
         │
         ▼
═══ EXECUTION LAYER ═══
  L3 Backend Services (banxe-emi-stack)
  ┌─────────────────────────────────────────────────────────┐
  │ services/aml/, services/ledger/, services/reporting     │
  │ services/safeguarding/, services/kyc/, services/fraud  │
  │ ...                                                     │
  │ [GAP] Execution Sandbox Contract — not formalized       │
  │       Capability isolation = governance policy only     │
  └─────────────────────────────────────────────────────────┘
         │
         ▼
  [GAP] Semantic Memory Index
  ┌─────────────────────────────────────────────────────────┐
  │ NOT DEPLOYED — ADR-136/137 deferred (factory-only)     │
  │ Current: per-session ledger shards (append-only)        │
  │         per-session worktree isolation (ADR-120)        │
  │ Missing: Qdrant + agentmemory bridge                    │
  └─────────────────────────────────────────────────────────┘
         │
         ▼
═══ AUDIT & STATE LAYER ═══
  ClickHouse (I-24)
  ┌─────────────────────────────────────────────────────────┐
  │ :9000 (native) / :8123 (HTTP)                           │
  │ Tables: guardian_audit_*, safeguarding_events,          │
  │         hitl_decisions, training_runs                   │
  │ TTL: ≥5Y (FCA CASS 15 retention)                        │
  │ Constraint: Append-only (Semgrep `banxe-audit-delete`) │
  │ Enforced by: Guardian append-only job ✅               │
  └─────────────────────────────────────────────────────────┘
         │
         ▼
  Per-Session Ledger Shards (ADR-059)
  ┌─────────────────────────────────────────────────────────┐
  │ ledger/entries/SHARD-<session>.jsonl                    │
  │ IL entries immutable after commit (ADR-057)             │
  │ INSTRUCTION-LEDGER.md = generated read-only projection  │
  │ Serialization: Redis INCR (ADR-143) + merge queue       │
  └─────────────────────────────────────────────────────────┘

═══ SUPPORTING INFRASTRUCTURE ═══
  n8n Workflow Automation (:5678)
  ├─ MLRO alert webhook (CASS 7.15 discrepancy)
  ├─ FIN060 generation + submission
  └─ Regulatory reporting pipelines

  LiteLLM v2 Meta-Plane Router (:4000)
  ├─ Ollama (evo1:11434)
  ├─ llama.cpp glm-master (evo1:8081)
  ├─ RPC worker (evo2:50052)
  └─ Routes: factory-fast, factory-mid, factory-heavy, project-reason

  Keycloak IAM (:8180)
  ├─ Auth for API + BANXE services
  ├─ HITL role-based access (MLRO/CEO/CTIO)
  └─ MFA support

  Marble (Case Management)
  ├─ Apache 2.0 OSS (no AGPL risk)
  ├─ Fraud rules + case management
  └─ services/case_management/marble_adapter.py

═══ NOT YET DEPLOYED (Out of Scope, Phase 2+) ═══
  [ ] Temporal workflow engine (saga patterns)
  [ ] Qdrant semantic memory (agentmemory bridge)
  [ ] Memoir versioned-memory pilot (adjourned preconditions)
  [ ] [GAP] Intent dispatcher code (L1→L2 masks)
  [ ] [GAP] A2A message contract (agent communication)
  [ ] [GAP] Tool registry / MCP binding (agent ↔ tools)
  [ ] [GAP] Execution sandbox (capability isolation)

```

---

## 6. Open Questions for Next Audit

1. **Intent Dispatcher Implementation Timeline** — ADR-045 acceptance cites concept_only: true. When will L1→L2 mask dispatcher code land? Is this Sprint 3 (GAP-078) or later?
   - Files checked: `docs/adr/ADR-045-*`, `docs/adr/ADR-049-*`; no implementation date found.

2. **Agent-to-Agent Message Schema** — No ADR found defining A2A protocol. Are agents expected to call each other via hardcoded service imports, or is a formal messaging layer planned?
   - Files checked: `agents/passports/`; no A2A schema located.

3. **Tool Registry Formalization** — MCP tools exist (34 in `banxe_mcp/server.py`). Is a central tool registry (mapping agent ↔ tool ↔ skill invocation) planned, or is hardcoding acceptable?
   - Files checked: `banxe-emi-stack/banxe_mcp/server.py`, `docs/SKILLS-ORCHESTRATION.md`; no registry found.

4. **Qdrant / Semantic Memory ETA** — ADR-136 marks agentmemory as factory-only; ADR-137 Memoir pilot is accepted but deferred. When will production semantic indexing for agent context retrieval land?
   - Files checked: `docs/adr/ADR-136-*`, `docs/adr/ADR-137-*`; pilot preconditions documented but not scheduled.

5. **Execution Sandbox Formalization** — Autonomy levels (L1-L4) are governance policy. Is a formal execution environment contract (Python VENV / Docker / FaaS + capability isolation) planned?
   - Files checked: `docs/canon/passports/schema.yaml`, `banxe-emi-stack/services/hitl/hitl_service.py`; only policy found, no execution contract.

6. **GitHub Webhook Delivery Status** — ADR-139 + runbook document Guardian webhook integration. Is webhook delivery to evo1:8195/:8196 currently working, or is it still Tailscale-gated (GAP-083)?
   - Files checked: `docs/GAP-REGISTER.md` (GAP-083, 🔴 OPEN); Tailscale ACL unconfigured; getent evo1/evo2 fails.

7. **Merge Queue Serialization** — ADR-060 cites GitHub native merge queue for serialization. ADR-143 substitutes Redis INCR. Is GitHub merge queue now enabled (org-level feature), or does Redis allocator remain the sole serialization mechanism?
   - Files checked: `docs/adr/ADR-060-*`, `docs/adr/ADR-143-*`, `LEDGER-MERGE-QUEUE.md`; merge queue listed as unavailable (user-owned repo).

8. **Passport Activation Timeline** — GAP-077 (Sprint 2) created 10 PROPOSED department-head passport stubs. GAP-078 (Sprint 3) implements service code. Is Sprint 3 currently active, and what is the expected completion date?
   - Files checked: `docs/GAP-REGISTER.md` (GAP-077 ✅ DONE, GAP-078 PLANNED); no Sprint 3 completion date in visible roadmap.

9. **Marble Integration Scope** — Marble (Apache 2.0) is listed as integrated in case_management. What triggers its activation (e.g., Jube ML model ready, or independent of fraud scoring)?
   - Files checked: `services/case_management/marble_adapter.py` (not verified in detail); `docs/sessions/SNAPSHOT-*` references it as part of OSS AML stack.

10. **Redis Allocator Availability** — ADR-143 Redis INCR on `banxe:il:counter` requires Redis availability. Is a central Redis deployed on evo1, and what is the fallback if Redis is unavailable (local max+1)?
    - Files checked: `docs/adr/ADR-143-*` (fallback documented as local max+1); no deployment status for Redis evo1 found.

---

## Audit Metadata

| Field | Value |
|-------|-------|
| **Auditor** | BANXE Factory Agent (Claude Haiku 4.5) |
| **Date** | 2026-06-28 |
| **Scope** | banxe-architecture main branch (commit: 76fa404) |
| **Method** | grep/find/Read — read-only; no execution, no mutation |
| **Files examined** | ~25 ADRs, 70+ agent passports, COMPLIANCE-MATRIX, GAP-REGISTER, DEPLOYMENT-ARCHITECTURE, SYSTEM-ARCHITECTURE, D-RECON-DESIGN, SKILLS-ORCHESTRATION, runbooks, sessions, decisions/ (historical), agents/ |
| **Mutations** | ZERO (read-only; single report file created) |
| **Report location** | `/home/mmber/banxe-architecture/docs/audit/banxe-agent-engine-target-audit.md` |

---

## Disclaimer

This audit is **read-only** and captures architectural facts as of 2026-06-28 from publicly visible documentation in the main branch. It does NOT verify:
- Actual deployment status (e.g., Guardian :8195/:8196 responsiveness)
- Code correctness or test coverage
- Compliance adequacy (only governance structures)
- Implementation timeline accuracy (GAP-REGISTER timelines may drift)

For operational verification, run:
```bash
# Check Guardian health
curl -s https://evo1.<tailnet>:8195/health
curl -s https://evo1.<tailnet>:8196/health

# Check merge queue status
gh api repos/CarmiBanxe/banxe-architecture/merge_queues

# Check ClickHouse audit trail
clickhouse-client --query "SELECT COUNT(*) FROM banxe_audit.guardian_audit_factory"

# Check Redis allocator
redis-cli -h <evo1-ip> PING
redis-cli -h <evo1-ip> GET banxe:il:counter
```

---

## 7. Cross-Reference to Intake Dossier (#838, merged — ad99f63)

> Append-only cross-reference. PR #838 merged to main 2026-06-28.
> Source: `docs/agent-engine-dossier/` (ad99f63).
> DO NOT copy dossier content here — only path references.

### 7.1 GAP: Semantic Memory Index → Dossier Status

- **Dossier path:** `docs/agent-engine-dossier/VERIFIED-RUNTIME-SNAPSHOT.md` §Models
- **Dossier status:** Qdrant=PLANNED; port :6333 confirmed NOT LISTENING at snapshot time (2026-06-28)
- **ADR reference:** ADR-136 (Shared Memory Substrate, PROPOSED), ADR-137 (Memoir Pilot, ACCEPTED/deferred)
- **Cross-ref verdict:** CONSISTENT — gap confirmed by both audit and dossier snapshot

### 7.2 GAP: Orchestration Spine / Intent Dispatcher L1→L2 → Dossier Status

- **Dossier path:** `docs/agent-engine-dossier/SRC-09-preaudit-synthesis.md` §L0 Fleet
- **Dossier status:** `docs/canon/passports/planner.yaml` EXISTS (verified); intent dispatcher between L1→L2 NOT deployed (governance layer only)
- **ADR reference:** ADR-045 (Intent-First Architecture, ACCEPTED); ADR-060 §6 (runtime → banxe-ai-infrastructure scope)
- **Cross-ref verdict:** CONSISTENT — planner passport present but spine not wired

### 7.3 GAP: A2A Contract (Agent-to-Agent Communication) → Dossier Status

- **Dossier path:** не подтверждено (Q3 grep пуст по всем SRC-* файлам)
- **Dossier status:** НЕ ПОКРЫТ — A2A message schema absent from all ingested dossier SRC files
- **Cross-ref verdict:** ⚠ NOVELTY — this gap is NOT addressed in the merged dossier. Requires separate specification in a future SRC or ADR.
- **Recommendation:** Flag as input for next dossier corpus acceptance session (SRC-03/04/05/08 PENDING-INTAKE)

### 7.4 GAP: Tool Registry / MCP Binding → Dossier Status

- **Dossier path:** `docs/agent-engine-dossier/SRC-01-engine-landscape.md` §BANXE-STATUS column
- **Dossier status:** MCP=PARTIAL (S12-16): LangGraph MCP ✅ DEPLOYED / Lerian MCP ❌ NOT DEPLOYED
- **ADR reference:** ADR-004 (MCP tooling boundary)
- **Cross-ref verdict:** CONSISTENT — partial MCP binding confirmed by both audit and dossier; central tool registry absent in both

### 7.5 GAP: Execution Sandbox Contract → Dossier Status

- **Dossier path:** `docs/agent-engine-dossier/SRC-07-constraints-guardrails.md` §Autonomy levels
- **Dossier status:** Autonomy L1–L4 defined via ADR-128 + HITL-MATRIX.yaml; sandbox execution contract (isolation spec, resource limits, escape-hatch rules) NOT formalized in any SRC
- **ADR reference:** ADR-128 (HITL gates), agent-authority.md
- **Cross-ref verdict:** CONSISTENT — levels defined, contract absent; gap stands in both documents

---

## 8. Audit Metadata Update (Cross-Reference Addition)

| Field | Value |
|-------|-------|
| Cross-ref added | 2026-06-28 (rebase + §7 append) |
| Dossier source | PR #838 merged (ad99f63) |
| Cross-ref coverage | 5/5 GAPs linked to dossier sections |
| NOVELTY gaps | 1 (A2A Contract — §7.3) |
| Orphan check | ADR-144: 0 (verified post-rebase) |
| Mutations to existing content | ZERO (§1–§6 unchanged) |
| New section size | ~40 lines (append-only §7–§8) |

---

**END OF AUDIT REPORT**
