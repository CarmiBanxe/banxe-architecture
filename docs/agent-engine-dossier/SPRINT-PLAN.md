# SPRINT-PLAN.md
# Agent-Engine-as-Bank-Core — Sprint-A/B Execution Plan
# Derived from: ENGINE-ROADMAP.md (IL-666, PR #857)
# IL: IL-669 | ADR-143-A | status: PREPARED
# Sprint-B repo confirmed: banxe-ai-infrastructure (created 2026-06-05 ✅)

> **SCOPE:** Per-deliverable execution plan for Sprint-A (banxe-architecture) and
> Sprint-B (banxe-ai-infrastructure). Each item has: status, IL pointer, gate-in
> (what must be true before starting), gate-out (acceptance criteria), and dependency.
> Derived from ENGINE-ROADMAP.md §2; does not duplicate its content — extends it with
> execution tracking. Append-only per ADR-056/I-24.

---

## 0. Status Dashboard

| Attribute | Value |
|-----------|-------|
| Roadmap source | ENGINE-ROADMAP.md (IL-666, PR #857) |
| Input anchor | ENGINE-ROADMAP-INPUTS.md (IL-665, PR #856) |
| A2A ADR (A1) | ADR-150 — PR #858, IL-667, **ACCEPTED** ✅ |
| Sprint-A A2 | ADR-045 amendment — PR #860, IL-693, **ACCEPTED** ✅ |
| Sprint-A A3 | ADR-147 Lerian MCP spec — PR #863, IL-694, **ACCEPTED** ✅ |
| Sprint-A A4 | ADR-146 sandbox contract — PR #862, IL-692, **ACCEPTED** ✅ |
| Sprint-A A5 | Passport revisions — PR #865, IL-695, **PROPOSED** (CTIO review) |
| Sprint-E E1 | Planner passport L1→L2 routing tests — PR #914, IL-762, **MERGED** ✅ |
| Sprint-B B1 | Qdrant deploy — infra#3 OPEN (operator merge + evo1 execute pending) |
| Sprint-B B2 | Dispatcher runtime — BLOCKED (gate-in: A5 ACCEPTED) |
| Sprint-B B3 | Lerian MCP runtime — infra#7 OPEN (CI running, 34 tests / 98%) |
| Sprint-B B4 | gate-exec enforcement — infra#6 OPEN (CI running, 15 tests / 100%) |
| Sprint-B B5 | A2A bus RedisStreams — BLOCKED (gate-in: B2) |
| Sprint-B B6 | G-CANON-BYPASS fix — infra#5 OPEN (operator merge + CTIO execute pending) |
| Sprint-B B7 | G-GUARDIAN-WEBHOOK-MISSING — infra#4 OPEN (title fix by operator pending) |
| Sprint-B B8 | Temporal saga runner — BLOCKED (ADR-133 approval) |
| Sprint-B B9 | Redis-lease saga — BLOCKED (B8 required) |
| Adoption gate | 0 / 5 GAPs at L2 (sprint B in progress) |

---

## 1. Gating Rules

### Global sprint gates

| Gate | Condition |
|------|-----------|
| **A-GATE** | Sprint-A ADR accepted by CTIO before dependent Sprint-B item starts |
| **L2-GATE** | CI green + coverage ≥ 80% + Semgrep 0 findings (banxe rules) |
| **L3-GATE** | CTIO + CEO sign-off; G-CANON-BYPASS + G-GUARDIAN-WEBHOOK-MISSING resolved |
| **ORPHAN-GATE** | ADR-144 orphan-check: 0 before every PR merge |
| **REVIEW-GATE** | ADR PROPOSED → ACCEPTED requires named CTIO review in PR comment |

### Item gate notation

`[gate-in: X]` = item is BLOCKED until X is satisfied.
`[gate-out: Y]` = item is DONE when Y is true.

---

## 2. Sprint-A Execution Plan (banxe-architecture)

Dependency order: **A1 → A2 → {A3, A4, A5} (parallel after A2)**

---

### A1 — ADR-150: A2A Inter-Agent Message Contract

| Field | Value |
|-------|-------|
| Epic | GAP-E4 (root dependency) |
| Status | **DONE** (ACCEPTED ✅) |
| PR | #858 (`agent/factory/sprintA01/a2a-contract`) |
| IL | IL-667 |
| Gate-in | None (root item) |
| Gate-out | ADR-150 status = ACCEPTED; REVIEW-GATE satisfied |
| Blocks | A2, A3, A4, A5, B2, B5 |

**Acceptance criteria:**
- [ ] ADR-150: `A2AMessage` dataclass spec; 4 message types; transport spec; `a2a_events` schema
- [ ] ADR-150 status changed from PROPOSED → ACCEPTED (PR comment by CTIO)
- [ ] ORPHAN-GATE: 0

---

### A2 — ADR-045 Amendment: Intent-Dispatcher Deployment

| Field | Value |
|-------|-------|
| Epic | GAP-E1 |
| Status | **DONE** (ACCEPTED ✅) |
| PR | #860 |
| IL | IL-693 |
| Gate-in | **[A-GATE: A1 ACCEPTED]** ✅ |
| Gate-out | ADR-045 amendment ACCEPTED; `concept_only: true` removed |
| Blocks | A5 (passport revisions), B2 (dispatcher runtime wiring) |

**Acceptance criteria:**
- [ ] ADR-045 amended: `concept_only: true` removed; deployment section added
- [ ] Deployment trigger defined: which Sprint-B item activates dispatcher
- [ ] `planner.yaml` entry points documented (passport update spec)
- [ ] ORPHAN-GATE: 0

---

### A3 — Lerian MCP Binding Spec (ADR or DESIGN-NOTE)

| Field | Value |
|-------|-------|
| Epic | GAP-E2 |
| Status | **DONE** (ACCEPTED ✅) |
| PR | #863 |
| IL | IL-694 |
| Gate-in | **[A-GATE: A1 ACCEPTED]** ✅ |
| Gate-out | Lerian MCP binding spec accepted; central tool registry schema defined |
| Blocks | B3 (Lerian MCP runtime binding) |

**Acceptance criteria:**
- [ ] ADR or DESIGN-NOTE: central tool registry schema (agent_id → tool_id → skill)
- [ ] Lerian MCP binding protocol defined (endpoint, auth, discovery)
- [ ] COMPLIANCE-MATRIX S12-16 update path documented
- [ ] ORPHAN-GATE: 0

---

### A4 — Execution-Sandbox Contract ADR

| Field | Value |
|-------|-------|
| Epic | GAP-E5 |
| Status | **DONE** (ACCEPTED ✅) |
| PR | #862 |
| IL | IL-692 |
| Gate-in | **[A-GATE: A1 ACCEPTED]** ✅ |
| Gate-out | Sandbox contract ADR ACCEPTED; L1–L4 → isolation-policy mapping defined |
| Blocks | B4 (gate-exec extension) |

**Acceptance criteria:**
- [ ] ADR: capability isolation model (Python VENV / Docker / FaaS per autonomy level)
- [ ] L1–L4 → sandbox-policy mapping table (extends ADR-077 + agent-authority.md)
- [ ] gate-exec integration points documented
- [ ] HITL gate spec for L3+ sandbox decisions (I-27)
- [ ] ORPHAN-GATE: 0

---

### A5 — Passport Revisions: planner.yaml + Intent-Layer Masks

| Field | Value |
|-------|-------|
| Epic | GAP-E1 |
| Status | **PROPOSED** (CTIO review) |
| PR | #865 |
| IL | IL-695 |
| Gate-in | **[A-GATE: A2 ACCEPTED]** ✅ |
| Gate-out | `planner.yaml` updated; intent-layer masks spec complete |
| Blocks | B2 (dispatcher runtime needs updated passport) |

**Acceptance criteria:**
- [ ] `planner.yaml`: `state` field updated; dispatcher entry points added
- [ ] Intent-layer masks per ADR-049: L1→L2 transition spec documented
- [ ] 70 passport cross-ref list: which passports need revision for A2A bus
- [ ] ORPHAN-GATE: 0

---

## 3. Sprint-B Execution Plan (banxe-ai-infrastructure)

**Repo:** `banxe-ai-infrastructure` (EXISTS, created 2026-06-05 — no B0 needed).
All Sprint-B items are BLOCKED until indicated Sprint-A gate-in is satisfied.
Per ADR-060 §6: Temporal, Redis-lease, Qdrant = runtime concerns — OUT OF SCOPE
for banxe-architecture PRs. Sprint-B PRs land in banxe-ai-infrastructure only.

Dependency order: **B1 (independent) | B2→B5 (chain) | B6/B7 (P1, any time) | B8→B9**

---

### B1 — Qdrant `:6333` Deploy on evo1/evo2

| Field | Value |
|-------|-------|
| Epic | GAP-E3 |
| Status | **OPEN** (infra#3 — operator merge + evo1 execute pending) |
| Gate-in | ADR-136/137 undeferred (operator decision) |
| Gate-out | `:6333 LISTENING` on evo1; episode-substrate smoke-test passes |
| Blocks | ADR-141 self-healing (episode-substrate dependency) |

**Acceptance criteria:**
- [ ] Qdrant Docker compose in banxe-ai-infrastructure
- [ ] `:6333 LISTENING` confirmed in next VERIFIED-RUNTIME-SNAPSHOT addendum
- [ ] Write + read vector round-trip test green
- [ ] ADR-136/137 status: DEFERRED → DEPLOYED

---

### B2 — Intent-Dispatcher Runtime Wiring

| Field | Value |
|-------|-------|
| Epic | GAP-E1 |
| Status | **BLOCKED** (gate-in: A5 ACCEPTED pending) |
| Gate-in | **[A-GATE: A1 ACCEPTED ✅ + A2 ACCEPTED ✅ + A5 ACCEPTED pending]** |
| Gate-out | Dispatcher running on evo1; integration tests green |
| Blocks | B5 (A2A bus needs dispatcher) |

**Acceptance criteria:**
- [ ] Dispatcher code in banxe-ai-infrastructure; CI green; coverage ≥ 80%
- [ ] InMemory stub available for unit tests
- [ ] Integration with CrewAI/LangGraph (DO NOT replace)
- [ ] L2-GATE: CI + coverage + Semgrep 0

---

### B3 — Lerian MCP Runtime Binding

| Field | Value |
|-------|-------|
| Epic | GAP-E2 |
| Status | **OPEN** (infra#7 — CI running, 34 tests / 98%) |
| Gate-in | **[A-GATE: A3 ACCEPTED]** ✅ |
| Gate-out | Lerian MCP bound; COMPLIANCE-MATRIX S12-16 DEPLOYED |
| Blocks | None (leaf node) |

**Acceptance criteria:**
- [ ] Lerian MCP client in banxe-ai-infrastructure; CI green
- [ ] Tool discovery: agent can query tool registry by agent_id
- [ ] COMPLIANCE-MATRIX S12-16 update (architecture PR, separate from runtime)
- [ ] L2-GATE satisfied

---

### B4 — gate-exec Extension (Sandbox Contract Enforcement)

| Field | Value |
|-------|-------|
| Epic | GAP-E5 |
| Status | **OPEN** (infra#6 — CI running, 15 tests / 100%) |
| Gate-in | **[A-GATE: A4 ACCEPTED]** ✅ |
| Gate-out | gate-exec enforces contract; L3 call audit-logged (I-24) |
| Blocks | None (leaf node) |

**Acceptance criteria:**
- [ ] `fabric/legion/gate-exec/` extended with contract enforcement point
- [ ] L3 agent call logged to ClickHouse before execution (I-24)
- [ ] HITL gate wired for L3+ (I-27); ESCALATION message type used
- [ ] L2-GATE satisfied

---

### B5 — InMemory A2A Bus → RedisStreams A2A Bus (Production)

| Field | Value |
|-------|-------|
| Epic | GAP-E4 |
| Status | **BLOCKED** (gate-in: B2) |
| Gate-in | **[A-GATE: A1 ACCEPTED] ✅ + [B2 complete]** |
| Gate-out | `RedisStreamsA2ABus` wrapping `bus-redis-streams.py`; MLRO chain migrated |
| Blocks | None (leaf node — completes GAP-E4 at L2) |

**Acceptance criteria:**
- [ ] `RedisStreamsA2ABus` in banxe-ai-infrastructure; wraps `bus-redis-streams.py`
- [ ] MLRO→AML→Sanctions chain migrated to A2A bus (3 chain migrations)
- [ ] Semgrep rule `banxe-a2a-direct-import` added (no hardcoded cross-agent imports)
- [ ] `a2a_events` ClickHouse table created; TTL 5yr (I-08); payload hash only
- [ ] L2-GATE satisfied

---

### B6 — G-CANON-BYPASS Fix *(P1 — start any time)*

| Field | Value |
|-------|-------|
| Type | P1 blocker (not an epic deliverable; blocks L3 gate) |
| Status | **OPEN** (infra#5 — operator merge + CTIO execute pending) |
| Gate-in | None (P1 — highest priority, start immediately) |
| Gate-out | OpenClaw instances route through canon audit path; I-24/I-28 satisfied |

**Acceptance criteria:**
- [ ] OpenClaw instances no longer invoke Ollama directly
- [ ] All LLM calls through canon audit path (I-24 audit log active)
- [ ] I-28 execution trace logged per call
- [ ] VERIFIED-RUNTIME-SNAPSHOT addendum confirms G-CANON-BYPASS = RESOLVED

---

### B7 — G-GUARDIAN-WEBHOOK-MISSING Fix *(P1 — start any time)*

| Field | Value |
|-------|-------|
| Type | P1 blocker (blocks L3 gate) |
| Status | **OPEN** (infra#4 — title fix by operator pending) |
| Gate-in | None (P1 — start immediately) |
| Gate-out | Guardian App 15368 webhook configured; breach alerts active |

**Acceptance criteria:**
- [ ] Guardian App 15368 webhook URL set and confirmed active
- [ ] Test breach alert delivered end-to-end
- [ ] VERIFIED-RUNTIME-SNAPSHOT addendum confirms G-GUARDIAN-WEBHOOK-MISSING = RESOLVED

---

### B8 — Temporal Saga Runner

| Field | Value |
|-------|-------|
| Epic | Infra enabler (ADR-060 §6, ADR-133) |
| Status | **BLOCKED** (ADR-133 approval pending) |
| Gate-in | ADR-133 execution approval |
| Gate-out | Temporal worker running on evo1/evo2 |
| Blocks | B9 |

---

### B9 — Redis-Lease Extend for Saga Lease

| Field | Value |
|-------|-------|
| Epic | Infra enabler (ADR-143-A extension) |
| Status | **BLOCKED** (B8 required) |
| Gate-in | **[B8 complete]** |
| Gate-out | Redis-lease used for Temporal saga lease (extends ADR-143-A) |

---

## 4. Critical Path

```
A1 (ADR-150 ACCEPTED)
  └─► A2 ──► A5 ──► B2 ──► B5
  └─► A3 ──────────► B3
  └─► A4 ──────────► B4

B1 (independent — start parallel with A1)
B6, B7 (P1 — start immediately, parallel with all)
B8 ──► B9 (independent of A/B chain)
```

**Fastest path to adoption-gate (all 5 GAPs at L2):**
1. Accept ADR-150 (A1) — unblocks all Sprint-A work
2. Execute A2+A3+A4 in parallel (after A1)
3. A5 after A2; then B2 can start
4. B1, B6, B7 parallel from now
5. L2-SANDBOX gate: B2+B3+B4+B5 complete + B1 deployed

---

## 5. IL Tracking

| Item | PR | IL | Status |
|------|----|----|--------|
| ENGINE-ROADMAP-INPUTS.md | #856 | IL-665 | PREPARED |
| ENGINE-ROADMAP.md | #857 | IL-666 | PREPARED |
| ADR-150 (A1 — A2A contract) | #858 | IL-667 | PROPOSED |
| SPRINT-PLAN.md (this file) | #859 | IL-669 | PREPARED |
| A2 (ADR-045 amendment) | TBD | TBD | NOT_STARTED |
| A3 (Lerian MCP spec) | TBD | TBD | NOT_STARTED |
| A4 (sandbox contract ADR) | TBD | TBD | NOT_STARTED |
| A5 (passport revisions) | TBD | TBD | NOT_STARTED |
| B1–B9 (banxe-ai-infrastructure) | TBD | TBD | BLOCKED |
| E1 (planner.yaml routing tests) | #914 | IL-762 | MERGED ✅ |

---

*Append-only. Update status in §5 IL Tracking as items complete. New sprint items → append §6+.*
