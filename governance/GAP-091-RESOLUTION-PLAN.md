# GAP-091 Resolution Plan — ADR-049 Intent-First Deployment

**Date:** 2026-07-02  
**Status:** PROPOSED (pending CTIO/Product sign-off)  
**Owner:** Product / CTIO  
**Deadline:** Q3 2026  
**Blocks:** GAP-080 (C-37.3 consumer channel absent)  
**ADR Chain:** ADR-045 (ACCEPTED) → ADR-049 (ACCEPTED) → ADR-053/054/055 (PROPOSED)  

---

## Problem Statement

Three conflicting signals on GAP-091 (Intent-First deployment):

| Signal | Status |
|--------|--------|
| ADR-049 YAML frontmatter | ACCEPTED (2026-06-07) |
| ADR-049 body | PROPOSED-2026-06-07 |
| Runtime in banxe-emi-stack | NOT_DEPLOYED (INTENT_LAYER_ENABLED=false) |

Additionally:
- Floor 1 (banxe-ai-infrastructure/intent_dispatcher) EXISTS as separate deployment target
- Floor 3 (services/intent_layer/ in banxe-emi-stack) is code-complete but disabled
- Consumer frontend (CarmiBanxe/banxe-trading-frontend) covers trading channel only — no consumer channel

---

## Asset Inventory

### Floor 1 — banxe-ai-infrastructure/intent_dispatcher
Location: `~/banxe-ai-infrastructure/intent_dispatcher/`

Core modules:
- `__init__.py` — main dispatcher exports
- `dispatcher.py` — request routing and orchestration logic
- `ports.py` — Protocol-defined interfaces for external dependencies (LLM, event bus, registry)
- `models.py` — domain types (IntentRequest, IntentResult, routing state)
- `bus.py` — event/message bus adapter for inter-floor communication
- `registry.py` — intent-to-process mapping registry (consumes ADR-048 intent→process contract)

**Status:** Canonical Floor 1 AI infrastructure home for intent dispatch. No API contract defined yet between Floor 1 (dispatcher) and Floor 3 (EMI runtime).

### Floor 3 — banxe-emi-stack/services/intent_layer/

Location: `~/banxe-emi-stack/services/intent_layer/`

Core modules:
- `__init__.py` — L1 Intent Layer exports; INTENT_LAYER_ENABLED (DISTINCT from AGENT_ROUTING_ENABLED)
- `router.py` — L1→L2 routing gate; INTENT_LAYER_ENABLED=false returns NOT_ENABLED
- `classifier.py` — LLM-based intent classifier (gated by INTENT_LAYER_ENABLED)
- `catalog.py` — intent-to-mask mapping (ADR-049 D3 mask registry)
- `catalog_snapshot.py` — serializable mask catalog state
- `composition.py` — multi-intent composition logic
- `models.py` — L1 domain types: IntentDefinition, ProcessRef, ResolvedIntent
- `canary.py` — Phase 7 canary deployment controller
- `canary_metrics.py` — observability counters (requests, errors, latency)
- `observability.py` — structured logging (banxe.intent_layer.canary)
- `shadow.py` — Phase 8 shadow mode (parallel no-op)
- `ports.py` — Protocol DI: LLMClassifierPort, NullLLMClassifier
- `config.py` — INTENT_LAYER_ENABLED flag reader

**Status:** Code-complete, 13 modules, observability instrumented. Runtime: `INTENT_LAYER_ENABLED=false` (disabled in all environments).

### ADR-049 Key Spec Points

**Decision D1 — L1 Intent Layer Responsibilities (4-step):**
1. **Capture** — free-form NL client intent
2. **Clarify** — ask disambiguating questions
3. **Resolve** — turn into canonical `process_ref` (ADR-048)
4. **Hand off** — emit structured request with resolved `process_ref` and client-facing **mask**

**Decision D2 — Intent-Resolution Contract (ordered chain):**
```
client intent (NL)
  → capture + clarify
  → resolve to process_ref
  → select mask
  → confirmation_policy check (AUTO > 0.90 / REVIEW 0.70-0.90 / BLOCK < 0.70)
  → L2 agent executes within mask scope
  → L3 enforcement (ADR-046 lineage, ADR-047 cost-cap)
  → AgentDecisionRecord emitted
  → response to client
```

**Decision D3 — Client-Facing Agent MASK (6 mandatory fields):**
- `scope` — allowed ports and operations (allow-list)
- `autonomy_level` — HITL scale (AUTO/REVIEW/BLOCK)
- `confirmation_policy` — when HITL/biometric step-up required
- `cost_cap` — per-request hard caps
- `lineage_obligation` — MUST emit AgentDecisionRecord (I-24)
- `compliance_gate` — L3 overlay (AML/KYC/sanctions; Ruflo mandatory)

**Six initial masks:**
| Capability | Scope | Autonomy | Confirmation | Compliance |
|------------|-------|----------|--------------|-----------|
| Payments | WalletPort, PartnerPort | REVIEW-biased | Biometric step-up + HITL | AML + sanctions + Ruflo |
| FX/Exchange | ExchangePort, WalletPort | REVIEW-biased | Biometric/HITL threshold | AML + market-abuse + Ruflo |
| KYC Onboarding | KYCProviderPort | REVIEW | HITL identity decision | KYC + sanctions + MLRO |
| Notifications | NotificationProviderPort | AUTO-biased | AUTO info; REVIEW funds data | PII overlay (ADR-016) |
| Referral/CRM | CRMProviderPort | AUTO-biased | AUTO routine; REVIEW incentive | PII + anti-abuse |
| Wallet | WalletPort | Mixed | Reads AUTO; mutations REVIEW | AML movement; PII reads |

**Decision D4 — AUTO/REVIEW/BLOCK + Biometric Step-Up:**
- **AUTO (>0.90)** — masked agent executes; logged
- **REVIEW (0.70–0.90)** — paused; notify MLRO/CEO; escalate BLOCK on timeout
- **BLOCK (<0.70)** — halt; human confirmation mandatory
- **Step-up (independent)** — critical money movement requires biometric/step-up before commit (zero-trust, Revolut-style)

**Decision D5 — Chat-First UX:**
- Conversation is primary surface (not screen/form)
- Visual components are agent responses within conversation (not nav)
- Step-up surfaces in-conversation

**Decision D6 — Precondition: Terminal A owns LLM-orchestration layer**
ADR-049 specifies contract; does not stand up infrastructure. Infrastructure readiness = Terminal A owned.

**Decision D7 — Specification/Contract Only (No Implementation)**
Deferred to factory build sprint:
- intent classifier / resolver → ADR-048 `process_ref`
- L2 agents binding to ports
- chat-first UI + in-conversation components
- agent-routing layer (AGENT_ROUTING_ENABLED remains false)
- concrete mask values (config-as-data)
- ADR-046 lineage + ADR-047 cost-cap wiring

**Crucially:** ADR-049 specifies client surface; does NOT open ports to clients. Ports become reachable only when built, mask-bound, gated agent deployed with D2 governance.

### ADR-045 Architecture Layers

**Decision D1 — Intent-First / AI-Agent-First:**
Conversational intent layer is primary interface (not GUI + AI add-on). Banking capabilities surfaced through intent.

**Decision D2 — Four-Layer Model:**

| Layer | Name | Responsibility |
|-------|------|-----------------|
| **L1** | **Intent Layer** (client conversational) | Captures/clarifies NL intent; primary. Translates to structured, auditable requests. |
| **L2** | **Execution Layer** (agents) | Agents fulfil intent—planning, orchestration, ports, operations within autonomy. |
| **L3** | **Governance & Compliance Layer** | Guardrails, audit, Lineage, HITL, AML/KYC, cost-policy. Cross-cutting enforcement plane. Every L2 action of consequence passes through. |
| **L4** | **Data & Intelligence Layer** | Ledgers, datastores, analytics, model/inference, features feeding layers above. |

**L3 is cross-cutting enforcement, not call stack.** No L2 agent bypasses L3 for actions touching client funds, production state, or regulated data.

**Decision D3 — Factory REQUIRED Production Infrastructure**
All project code produced through factory. Not optional.

**Decision D4 — Central Produces Code ONLY Through Factory**
Central does not mutate project repos directly. Direct rights: read-only diagnostics + governance artefacts.

**Decision D6 — Terminal B Same Intent-First + Factory Model**
Terminal B not exception. Same concept, same factory, same governance.

---

## Root Cause Analysis

### RC-1: ADR-049 Status Contradiction

ADR-049 marked **ACCEPTED in frontmatter** (line 4) but **body remains PROPOSED** (line 23). Documentation debt—architectural decision accepted; deployment staged.

**Evidence:**
- Frontmatter: `status: ACCEPTED` + `accepted: 2026-06-07`
- Body §Status: `PROPOSED — 2026-06-07`
- Signals to readers: "Concept approved, deployment deferred"

**Resolution:** Update ADR-049; append addendum (I-24 append-only) clarifying acceptance scope vs. deployment status separately.

### RC-2: Floor 1 / Floor 3 Integration Contract Missing

`banxe-ai-infrastructure/intent_dispatcher` (Floor 1—canonical AI home) and `services/intent_layer/` (Floor 3—EMI seam) exist as **independent components with NO defined API contract**.

4-floor model (ADR-045 D2) requires **Floor 1 to serve Floor 3**, not duplicate:
- **Floor 1:** `intent_dispatcher` — orchestrates intent→process, mask selection, compliance, cost
- **Floor 3:** EMI `services/intent_layer/` — consumes Floor 1; exposes L1↔L2 boundary; calls L2 agents

**Gap:** No documented protocol (REST/HTTP, Kafka, gRPC, in-process) between Floor 1 dispatcher and Floor 3 layer.

**Questions:**
- Does Floor 3 call Floor 1 as remote service (HTTP)?
- Or embed Floor 1 logic (in-process)?
- How sync mask registries?
- How propagate lineage (ADR-046) and cost-caps (ADR-047) Floor 1 → Floor 3?

**Evidence:**
- `intent_dispatcher/ports.py` — Floor 1 protocol boundaries (LLM, event bus, registry)
- `services/intent_layer/ports.py` — Floor 3 protocol boundaries (LLMClassifierPort)
- No cross-imports. No shared contract.

**Resolution:** Formal spec defining integration protocol before factory wires.

### RC-3: Consumer Frontend Absent = C-37.3 Unfulfilled (Blocks GAP-080)

`banxe-trading-frontend` serves **trading channel only**. C-37.3 requires **separate consumer channel frontend** for consumer clients to access L1 Intent Layer.

This is **GAP-080** (separate in CONSOLIDATION-PLAN). **GAP-091 unblocks GAP-080**: once ADR-049 deployment clarified, Product/UX plan consumer frontend build.

**Evidence:**
- `banxe-trading-frontend` = trading-channel only (payments, FX)
- Consumer channel frontend (banking, KYC, wallet, CRM, notifications) = **absent**
- C-37.3 names consumer + trading channels
- GAP-080 names consumer frontend as missing piece

**Resolution:** Out of scope for GAP-091. Track in GAP-080. GAP-091 resolution clears path for GAP-080 planning.

### RC-4: ADR-053/054/055 Cannot Proceed Until ADR-049 Deployment Clarified

ADR-053/054/055 (Mask extensions: Catalogue Extensibility, Analytics C7, Statements) **PROPOSED** and depend on ADR-049:
- (a) **CONCEPT** (done—ACCEPTED)
- (b) **STAGED** (code-complete, deploy pending—needs clarification)
- (c) **DEPLOYED** (INTENT_LAYER_ENABLED=true)

ADR-053/054/055 move to **ACCEPTED** once (b) clarified. Cannot be ACCEPTED while ADR-049 deployment ambiguous.

---

## Resolution Paths

### Path A — Enable in EMI + Define Floor 1↔Floor 3 Contract (RECOMMENDED)

**Goal:** Activate Intent-First in EMI; clarify Floor 1 ↔ Floor 3 integration.

**Sequence:**
1. Fix ADR-049 status: append addendum clarifying ACCEPTED (arch) / STAGED (deploy)
2. Define Floor 1↔Floor 3 API contract (Protocol DI pattern preferred)
3. Wire IntentDispatcherPort in banxe-emi-stack/services/intent_layer/
4. Enable INTENT_LAYER_ENABLED=true in staging
5. Smoke-test intent → mask → agent dispatch in staging
6. Progress ADR-053 → ACCEPTED after IntentRouter + catalog verified
7. (Separate) Consumer channel frontend (GAP-080)

**Effort:** Medium (contract spec + flag enable + integration test)

**Owner:** CTIO (infra contract), Product (feature flag)

**Why recommended:**
- Aligns with 4-floor model (Floor 1 orchestrates; Floor 3 consumes)
- Keeps AI infra (Floor 1) separate from EMI runtime (Floor 3)
- Enables gradual rollout: staging → canary → prod
- Unblocks ADR-053/054/055 and GAP-080

**Risk:** Low-medium (integration contract primary risk; once defined, enablement straightforward)

---

### Path B — Consolidate: Fold intent_dispatcher Into services/intent_layer/

**Goal:** Eliminate separation; make intent_layer fully self-contained L1 service.

**Sequence:**
1. Migrate `banxe-ai-infrastructure/intent_dispatcher/` logic → `services/intent_layer/`
2. Remove/archive intent_dispatcher (or deprecate)
3. Update imports: `from services.intent_layer import ...`
4. Enable INTENT_LAYER_ENABLED=true after consolidation
5. Full test parity; verify no regressions

**Effort:** High (6 modules, ~500 lines; test parity; banxe-ai-infrastructure PR)

**Owner:** CTIO + Factory

**Why not recommended (by default):**
- Breaks 4-floor model separation (Floor 1 logic should stay in canonical AI infra, not move to EMI)
- Tight coupling: EMI service owns intent orchestration traditionally handled by AI plane
- Duplicate logic if other projects need intent dispatch (banxe-trading-core, etc.)
- Requires careful unwinding banxe-ai-infrastructure dependencies

**Why might choose:**
- Simpler ops model: one service, not two
- Faster if Floor 1 ↔ Floor 3 integration complex

**Risk:** Medium-high (architectural violation if not careful)

---

### Path C — Defer: INTENT_LAYER_ENABLED=false, Update ADR-049 Status Only

**Goal:** Acknowledge ACCEPTED (arch) but NOT_STAGED (deploy); explicitly defer.

**Sequence:**
1. Fix ADR-049 addendum: ACCEPTED (concept), NOT_STAGED (deferred TBD)
2. Mark GAP-091 DEFERRED (out of P0; link Q4 roadmap)
3. ADR-053/054/055 remain PROPOSED (blocked by ADR-049)
4. GAP-080 consumer frontend deferred (blocked by GAP-091)

**Effort:** Low (doc-only)

**Owner:** Product (deferral sign-off)

**Why not recommended (by default):**
- GAP-080 (C-37.3 consumer banking) stays OPEN
- C-37.3 consumer frontend undelivered beyond Q3
- Consumer clients still lack Intent-First (stays screen-first)

**Why might choose:**
- Budget/roadmap constraint
- LLM-orchestration layer (Terminal A) not ready (ADR-049 D6)
- Time to define Floor 1 ↔ Floor 3 contract exceeds Q3 availability

**Risk:** Low (reversible)

---

## Recommended Resolution Sequence (Path A)

| Step | Action | Owner | Deadline | Output | Notes |
|------|--------|-------|----------|--------|-------|
| A.1 | ADR-049 append addendum: ACCEPTED (arch) / STAGED (impl) | Factory | Q3-W27 (2026-07-07) | ADR-049 updated; IL-shard | Doc-only |
| A.2 | Define Floor 1↔Floor 3 API contract spec | CTIO | Q3-W28 (2026-07-14) | Protocol doc (REST/Kafka/gRPC); IntentDispatcherPort | Sync Terminal A on LLM-orch (D6) |
| A.3 | Wire IntentDispatcherPort in banxe-emi-stack | Factory | Q3-W29 (2026-07-21) | PR to banxe-emi-stack; DI setup | Integrate Floor 1 via injected port |
| A.4 | Smoke test: intent → mask → dispatch | CTIO + QA | Q3-W30 (2026-07-28) | Test report; 6 mask types | Canary (Phase 7) preferred; latency |
| A.5 | Enable INTENT_LAYER_ENABLED=true (staging) | CTIO | Q3-W30 (2026-07-28) | .env staging; monitoring live | Gradual: staging → canary-10% → prod |
| A.6 | Progress ADR-053 → ACCEPTED | Factory + Product | Q3-W31 (2026-08-04) | ADR-053 status; mask catalogue | Unblocks extensions |
| A.7 | (Separate) Consumer channel frontend design | Product + UX | Q3-W32+ (2026-08-11+) | Design spec; Figma; GAP-080 PR | Out of GAP-091; depends A.1–A.6 |

---

## Gate: CTIO/Product Sign-Off Required

Plan **cannot proceed** without explicit decision on:

1. **Path selection (A vs B vs C):**
   - A (Enable + Contract) = default
   - B (Consolidate) = if separation less critical
   - C (Defer) = if Q3 unachievable

2. **Floor 1↔Floor 3 protocol (Path A):**
   - HTTP REST (:9091 or :5900)?
   - Kafka topic?
   - gRPC?
   - In-process (anti-pattern)?

3. **INTENT_LAYER_ENABLED=true rollout (Path A):**
   - Staging-first gradual canary?
   - Canary-10% initially?
   - Full prod flip?

4. **Timeline (all paths):**
   - Path A: Q3-W31 (2026-08-04) for ADR-053 ACCEPTED
   - Path B: Q3-W35+ (2026-09-01+) for consolidation + test
   - Path C: explicit Q4 target (if deferred)

5. **GAP-080 consumer frontend (Path A):**
   - Q3-2026 or Q4-2026?
   - Design parallel A.1–A.3 or wait A.5?

**Decision deadline:** Q3-W27 (2026-07-07) for C-37.3 Q3 target.

---

## References

- **ADR-045:** Intent-First Banking Architecture (ACCEPTED) — `/docs/adr/ADR-045-intent-first-banking-architecture.md`
- **ADR-049:** Intent Layer & Masks (ACCEPTED—impl STAGED) — `/docs/adr/ADR-049-intent-layer-client-facing-agent-masks.md`
- **ADR-053/054/055:** Mask extensions (PROPOSED—blocked)
- **GAP-080:** C-37.3 consumer frontend absent (blocked by GAP-091)
- **GAP-091:** This document
- **MASTER-ORG-CODE-RUNTIME-DOSSIER.md** §4 (4-floor: Floor 1 = banxe-ai-infrastructure, Floor 3 = banxe-emi-stack)
- **GLOBAL-PROGRAM-PLAN.md** Phase 3 (SSOT—service boundaries)
- **banxe-ai-infrastructure/intent_dispatcher/:** Floor 1 canonical (6 modules)
- **banxe-emi-stack/services/intent_layer/:** Floor 3 EMI seam (13 modules)

