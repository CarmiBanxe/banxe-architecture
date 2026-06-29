# ENGINE-ROADMAP.md
# Agent-Engine-as-Bank-Core — Execution Roadmap
# Input: ENGINE-ROADMAP-INPUTS.md (IL-665, PR #856) | ADR-056 append-only
# IL: assigned at merge by build_ledger.py | ADR-143-A | status: PREPARED

> **SCOPE:** Execution roadmap derived from ENGINE-ROADMAP-INPUTS.md anchor.
> 5 epics (GAP-E1..E5), Sprint-A/B split per ADR-060 §6, L1→L2→L3 adoption gate.
> References: target-audit PR #842, DEDUP-FINDINGS.md, SRC-04 (PR #847), SRC-09 (PRs #846/#851).
> Does NOT duplicate ENGINE-ROADMAP-INPUTS.md — extends it with sprint assignments,
> milestones, and acceptance criteria. Append-only per ADR-056/I-24.

---

## 0. Status Dashboard

| Attribute | Value |
|-----------|-------|
| Input anchor | ENGINE-ROADMAP-INPUTS.md (IL-665, PR #856 — CLEAN) |
| Roadmap status | PREPARED (operator review pending) |
| Adoption gate | **0 / 5 GAPs at L2 — BLOCKED** |
| Sprint-A repo | banxe-architecture |
| Sprint-B repo | banxe-ai-infrastructure |
| P1 runtime blockers | G-CANON-BYPASS, G-GUARDIAN-WEBHOOK-MISSING |
| Dossier PRs state | PRs #842–#851 OPEN/DIRTY — rebase required (main at IL-663) |

---

## 1. Epic Register (GAP-E1 → E5)

Dependency order (must be read before sprint assignment):

```
GAP-E4 (A2A ADR — root)
  └─► GAP-E1 (dispatcher spec needs A2A contract)
        ├─► GAP-E2 (tool-registry binding needs dispatcher)
        └─► GAP-E5 (sandbox policy enforced by dispatcher)

GAP-E3 (Qdrant — independent; episode-substrate for ADR-141)
```

### EPIC-E4 — A2A Inter-Agent Contract *(first; root dependency)*

| Field | Value |
|-------|-------|
| GAP | GAP-E4 |
| Current level | **L0** (no ADR, no spec — NOVELTY per DEDUP-FINDINGS §NOVELTY) |
| Target | **L2-SANDBOX** |
| Sprint | Sprint-A (ADR) → Sprint-B (reference implementation) |
| Repo | banxe-architecture (ADR); banxe-ai-infrastructure (impl) |
| Depends on | None — root dependency |
| Reuse | `fabric/common/bus-redis-streams.py` (A2A transport candidate) |
| Evidence | target-audit §4.4; SRC-02/SRC-04: no A2A ADR located |

**Sprint-A deliverable:** New ADR defining A2A message envelope (agent_id, message_type,
payload, correlation_id, audit_trail_ref). Must be accepted before E1/E2 specs proceed.

**Sprint-B deliverable:** InMemory A2A bus stub; MLRO→AML→Sanctions chain ported to A2A
bus in sandbox; no hardcoded service imports between agents (lint rule).

**L2 acceptance criteria:**
- [ ] ADR accepted: A2A message schema (envelope + payload + correlation)
- [ ] InMemory A2A bus stub — CI green, coverage ≥ 80%
- [ ] Existing agents use A2A bus in sandbox (no hardcoded cross-agent imports)
- [ ] ADR-144 orphan-check: 0

---

### EPIC-E1 — Intent-Dispatcher L1→L2 Deployment

| Field | Value |
|-------|-------|
| GAP | GAP-E1 |
| Current level | **L1 partial** (ADR-045/049 ACCEPTED; dispatcher not deployed) |
| Target | **L2-SANDBOX** |
| Sprint | Sprint-A (ADR amendment) → Sprint-B (runtime wiring) |
| Repo | banxe-architecture (spec); banxe-ai-infrastructure (deploy) |
| Depends on | EPIC-E4 (A2A ADR must be accepted first) |
| Reuse | `planner.yaml`, ADR-045, ADR-049 intent-layer masks |
| Evidence | ADR-045 `concept_only: true`; ADR-049 lines 291/390/490 [GAP] |

**Sprint-A deliverable:** ADR-045 amendment removing `concept_only: true`; deployment
section added; `planner.yaml` updated with dispatcher entry points; intent-mask spec
for L1→L2 transition per ADR-049.

**Sprint-B deliverable:** Dispatcher runtime wiring on evo1; service tests; integration
with existing CrewAI/LangGraph orchestration (DO NOT replace with new framework).

**L2 acceptance criteria:**
- [ ] ADR-045 amendment: `concept_only` removed, deployment section present
- [ ] `planner.yaml` state updated (after Sprint-B)
- [ ] Dispatcher code: CI green, coverage ≥ 80%
- [ ] InMemory stub available for unit tests
- [ ] ADR-144 orphan-check: 0

---

### EPIC-E2 — Tool-Registry / MCP Binding

| Field | Value |
|-------|-------|
| GAP | GAP-E2 |
| Current level | **L1 partial** (LangGraph DEPLOYED; Lerian MCP absent) |
| Target | **L2-SANDBOX** (Lerian MCP binding spec + stub registry) |
| Sprint | Sprint-A (spec/ADR) → Sprint-B (runtime binding) |
| Repo | banxe-architecture (ADR/passport); banxe-ai-infrastructure (bind) |
| Depends on | EPIC-E1 (dispatcher routes tool calls) |
| Reuse | 34 MCP tools in `banxe-emi-stack/banxe_mcp/server.py` (DO NOT REBUILD) |
| Evidence | COMPLIANCE-MATRIX S12-13 ✅ LangGraph; S12-16 ❌ Lerian MCP |

**Sprint-A deliverable:** ADR or DESIGN-NOTE for central tool registry schema
(agent_id → tool_id → skill invocation); Lerian MCP binding spec.

**Sprint-B deliverable:** Lerian MCP runtime binding; COMPLIANCE-MATRIX S12-16 updated.

**L2 acceptance criteria:**
- [ ] Central tool registry schema defined (ADR or DESIGN-NOTE accepted)
- [ ] Lerian MCP binding spec reviewed and accepted
- [ ] Stub registry: agent ↔ tool ↔ skill lookup, CI green
- [ ] ADR-144 orphan-check: 0

---

### EPIC-E3 — Semantic-Memory / Qdrant Deployment

| Field | Value |
|-------|-------|
| GAP | GAP-E3 |
| Current level | **L0** (`:6333 NOT LISTENING`; ADR-136/137 deferred) |
| Target | **L2-SANDBOX** (Qdrant on evo1; episode-substrate for ADR-141) |
| Sprint | **Sprint-B only** (runtime concern per ADR-060 §6) |
| Repo | banxe-ai-infrastructure |
| Depends on | ADR-136/137 undeferred (by Sprint-B start) |
| Reuse | ADR-136 factory-memory pilot; ADR-137 Memoir pilot (both ACCEPTED) |
| Evidence | runtime-snapshot `:6333 NOT LISTENING`; ADR-141 episode-substrate dep |

**Sprint-B deliverable:** Qdrant Docker deploy on evo1 (:6333); episode-substrate wiring
for ADR-141 self-healing; agentmemory Tier-1 → Tier-2 promotion; write+read vector test.

*Note: G-CANON-BYPASS must be resolved before L3 gate (not L2 blocker).*

**L2 acceptance criteria:**
- [ ] Qdrant `:6333 LISTENING` on evo1 (next runtime-snapshot confirms)
- [ ] ADR-136/137 status: DEFERRED → IN_PROGRESS → DEPLOYED
- [ ] Episode-substrate smoke-test: write + read vector round-trip
- [ ] ADR-144 orphan-check: 0 (Sprint-B repo; verify in banxe-ai-infrastructure)

---

### EPIC-E5 — Execution-Sandbox Contract

| Field | Value |
|-------|-------|
| GAP | GAP-E5 |
| Current level | **L1 partial** (gate-exec/gate-policy present; contract absent) |
| Target | **L2-SANDBOX** (sandbox contract ADR + gate-exec integration) |
| Sprint | Sprint-A (contract ADR) → Sprint-B (fabric wiring) |
| Repo | banxe-architecture (ADR); fabric/legion in banxe-ai-infrastructure |
| Depends on | EPIC-E1 (dispatcher enforces sandbox policy per L1–L4) |
| Reuse | `fabric/legion/gate-exec/` DEPLOYED; `fabric/legion/gate-policy/` DEPLOYED |
| Evidence | agent-authority.md L1–L4; ADR-077; gate-exec/gate-policy verified |

**Sprint-A deliverable:** Execution-sandbox contract ADR: capability isolation model
(Python VENV / Docker / FaaS); L1–L4 → sandbox-policy mapping; gate-exec integration
points; HITL gate spec for L3+ decisions (I-27).

**Sprint-B deliverable:** gate-exec extended with contract enforcement; L3 agent call
audit-logged (I-24).

**L2 acceptance criteria:**
- [ ] ADR: execution-sandbox contract (isolation model + L1–L4 policy mapping)
- [ ] gate-exec extended with contract enforcement point
- [ ] L3 sandbox decision audit-logged per I-24
- [ ] HITL gate wired for L3+ (I-27)
- [ ] ADR-144 orphan-check: 0

---

## 2. Sprint Plan

### Sprint-A — banxe-architecture (ADRs + specs)

Priority order is dependency-driven (E4 first):

| # | Deliverable | Epic | Input |
|---|-------------|------|-------|
| A1 | **ADR: A2A inter-agent message contract** | E4 | DEDUP-FINDINGS §NOVELTY; target-audit §4.4 |
| A2 | **ADR-045 amendment: remove concept_only; add deployment spec** | E1 | ADR-045 current; planner.yaml |
| A3 | **Lerian MCP binding spec (ADR or DESIGN-NOTE)** | E2 | COMPLIANCE-MATRIX S12-16; 34 MCP tools |
| A4 | **Execution-sandbox contract ADR** | E5 | ADR-077; gate-exec; agent-authority.md |
| A5 | **Passport revisions: planner.yaml + intent-layer masks** | E1 | ADR-049; 70 passports corpus |

### Sprint-B — banxe-ai-infrastructure (runtime)

Per ADR-060 §6: Temporal, Redis-lease, Qdrant = runtime → OUT OF SCOPE for
banxe-architecture PRs. All Sprint-B items must land in banxe-ai-infrastructure.

| # | Deliverable | Epic | Depends on |
|---|-------------|------|------------|
| B1 | Qdrant `:6333` deploy on evo1/evo2 | E3 | ADR-136/137 undeferred |
| B2 | Intent-dispatcher runtime wiring | E1 | A1 (A2A ADR) + A2 |
| B3 | Lerian MCP runtime binding | E2 | A3 |
| B4 | gate-exec extension (sandbox contract enforcement) | E5 | A4 |
| B5 | InMemory A2A bus → Redis-streams A2A bus (production) | E4 | A1 + B2 |
| B6 | **G-CANON-BYPASS fix** (OpenClaw → canon audit path; I-24/I-28) | — | P1; before L3 |
| B7 | **G-GUARDIAN-WEBHOOK-MISSING** (App 15368 webhook config) | — | P1; before L3 |
| B8 | Temporal saga runner (ADR-060 §6, ADR-133) | — | ADR-133 |
| B9 | Redis-lease extend for saga lease (ADR-143-A) | — | B8 |

---

## 3. L1 → L2 → L3 Adoption Gate

### Gate table

| GAP | L1 (Design) | L2 (Sandbox — min for adoption) | L3 (Production) |
|-----|-------------|----------------------------------|-----------------|
| E4 (A2A contract) | ❌ NOT_STARTED | — | — |
| E1 (dispatcher) | ✅ PARTIAL (ADR-045/049 exist) | ❌ NOT_STARTED | — |
| E2 (MCP binding) | ✅ PARTIAL (LangGraph deployed) | ❌ NOT_STARTED | — |
| E3 (Qdrant) | ✅ ADRs exist (deferred) | ❌ NOT_STARTED | — |
| E5 (sandbox) | ✅ PARTIAL (gate-exec present) | ❌ NOT_STARTED | — |

**Current: 0 / 5 at L2. Adoption gate = BLOCKED.**

### L2 gate conditions (per epic)
Each epic's L2 acceptance criteria are listed in §1. Shared gate:
- CI green + coverage ≥ 80% (per banxe-architecture testing rules)
- Security scan (Semgrep) 0 findings
- ADR-144 orphan-check: 0

### L3 gate (operator-gated — additional)
- CTIO + CEO sign-off
- FCA-boundary review (CASS 15 applicable if engine touches safeguarding flows)
- G-CANON-BYPASS resolved (I-24/I-28 audit gap closed)
- G-GUARDIAN-WEBHOOK-MISSING resolved (breach alerts active)
- HITL gates wired per ADR-077 + agent-authority.md (I-27)

### 100%-adoption-gate
**Triggers when:** all 5 GAPs at L2 AND G-CANON-BYPASS + G-GUARDIAN-WEBHOOK-MISSING resolved.
L3 remains operator-gated after 100%-adoption-gate is reached.

---

## 4. Reuse Mandate Map

Source: ENGINE-ROADMAP-INPUTS.md §3. Cross-reference only — do not duplicate content.

| Artefact | Must-reuse in epic | Action |
|----------|-------------------|--------|
| `planner.yaml` | E1 | Update `state`; do not replace |
| ADR-045 | E1 | Amend (Sprint-A A2); do not supersede |
| ADR-049 | E1 | Use intent-layer masks as-is |
| ADR-136/137 | E3 | Execute deferred Sprint-B plan |
| `fabric/legion/gate-exec/` | E5 | Extend (Sprint-B B4) |
| `fabric/legion/gate-policy/` | E5 | Extend |
| `fabric/common/bus-redis-streams.py` | E4 | A2A transport candidate (Sprint-B B5) |
| 70 passports | E1/E2 | Revise per new ADRs; do not replace |
| LangGraph, CrewAI, AutoGen | E1/E2 | Extend — no new OSS frameworks |

**Hard mandate:** GigaAgent = I-02/RU BLOCKED (permanent, Sberbank origin).

---

## 5. P1 Blocker Register

Must resolve before L3 gate (not blocking L2):

| ID | Description | Sprint item | Owner |
|----|-------------|-------------|-------|
| G-CANON-BYPASS | OpenClaw invokes Ollama directly; bypasses I-24/I-28 audit path | Sprint-B B6 | CTIO |
| G-GUARDIAN-WEBHOOK-MISSING | Guardian App 15368 has no webhook; breach alerts silently dropped | Sprint-B B7 | CTIO |

Source: VERIFIED-RUNTIME-SNAPSHOT.md v2 + PR #845 addendum A-003.

---

## 6. Dossier Dependency (merge order)

Roadmap evidence PRs. Must be merged (rebased first) before roadmap is dossier-complete.

| PR | Content | Status (2026-06-28) | Action |
|----|---------|---------------------|--------|
| #856 | ENGINE-ROADMAP-INPUTS.md anchor | OPEN/CLEAN ✅ | Merge first |
| #857 | This file (ENGINE-ROADMAP.md) | PREPARED | Merge after #856 |
| #842 | Target-audit (5 GAPs; §4/§7) | OPEN/DIRTY | Rebase → merge |
| #843 | SRC-01 quantitative descriptors | OPEN/DIRTY | Rebase → merge |
| #844 | SRC-02 formal notation layer | OPEN/DIRTY | Rebase → merge |
| #845 | VERIFIED-RUNTIME-SNAPSHOT addendum A-003 | OPEN/DIRTY | Rebase → merge |
| #846 | SRC-09 behavior-canon | OPEN/DIRTY | Merge before #851 |
| #847 | SRC-04 framework-selection | OPEN/DIRTY | Rebase → merge |
| #848 | SRC-03 implementation-state | OPEN/DIRTY | Rebase → merge |
| #849 | SRC-06 enrich (UNKNOWN resolved) | OPEN/DIRTY | Rebase → merge |
| #850 | SRC-07 enrich (problem→solution) | OPEN/DIRTY | Rebase → merge |
| #851 | SRC-09 resolve 5 UNKNOWN | OPEN/DIRTY | Merge after #846 |

**Operator action required:** rebase all DIRTY PRs onto main (HEAD IL-663) before merge.

---

*Append-only. Do not edit existing sections. New sprint decisions → append §7+.*

---

## 7. Sprint-B Completion Report (2026-06-30)

### Adoption Gate — Updated Assessment

Sprint-B B1–B6 are complete. PRs #25 (B5 Redis-streams A2A bus) and #26 (B3 Lerian MCP + B4 gate-exec) are open in banxe-ai-infrastructure pending CodeRabbit review/merge.

| GAP | L2 Status | Evidence |
|-----|-----------|----------|
| E4 (A2A contract) | ✅ **L2 READY** | ADR-150 ACCEPTED; Redis-streams A2A bus (PR #25); InMemoryA2ABus CI green |
| E1 (dispatcher) | ✅ **L2 READY** | ADR-045 amended (concept_only removed); A5 passport revisions MERGED (PR #865); intent-dispatcher v0.3.0 (PR #25+#26) |
| E2 (MCP binding) | ✅ **L2 READY** | ADR-147 ACCEPTED; InMemoryToolRegistry + LerianMCPClient (PR #26 B3); COMPLIANCE-MATRIX S12-16 → ✅ DEPLOYED (PR #894) |
| E3 (Qdrant) | ✅ **L2 READY** | :6333 LISTENING on evo1 (VERIFIED-RUNTIME-SNAPSHOT 2026-06-29) |
| E5 (sandbox) | ✅ **L2 READY** | ADR-146 ACCEPTED; GateExec wired in /dispatch for L1 (PR #26 B4); I-24 audit logged; I-27 HITL enforced |

**Adoption gate: 5/5 at L2** (pending PR #25+#26 merge into main in banxe-ai-infrastructure).

### P1 Blocker Status (L3 gate)

| ID | Status | Notes |
|----|--------|-------|
| G-CANON-BYPASS | ✅ RESOLVED | VERIFIED-RUNTIME-SNAPSHOT 2026-06-29; OpenClaw→Ollama direct bypass NOT DETECTED |
| G-GUARDIAN-WEBHOOK-MISSING | ❌ CTIO-BLOCKED | Spec merged; GitHub App 15368 webhook registration requires CTIO owner access |

**L3 gate: BLOCKED on G-GUARDIAN-WEBHOOK-MISSING** (CTIO action: register App 15368 webhook → n8n :5678).

### Sprint-B Item Summary

| Item | Status | PR / Evidence |
|------|--------|---------------|
| B1 Qdrant :6333 deploy | ✅ DONE | VERIFIED-RUNTIME-SNAPSHOT |
| B2 Intent-dispatcher runtime | ✅ DONE | PR #12/#13 (MERGED); HITL L2 verified |
| B3 Lerian MCP runtime binding | ✅ DONE | PR #26 (OPEN — pending merge) |
| B4 gate-exec sandbox extension | ✅ DONE | PR #26 (OPEN — pending merge) |
| B5 Redis-streams A2A bus | ✅ DONE | PR #25 (OPEN — pending merge) |
| B6 G-CANON-BYPASS fix | ✅ DONE | VERIFIED-RUNTIME-SNAPSHOT; B6 PR merged |
| B7 G-GUARDIAN-WEBHOOK-MISSING | ❌ CTIO-BLOCKED | GitHub App 15368 webhook (owner access) |
| B8 Temporal saga runner | ❌ CTIO-BLOCKED | Depends on ADR-133 |
| B9 Redis-lease extend | ❌ CTIO-BLOCKED | Depends on B8 |

### Operator Actions Required (to close L2 gate)

1. **Merge PR #25** in banxe-ai-infrastructure (Sprint-B B5 Redis-streams A2A bus).
2. **Merge PR #26** in banxe-ai-infrastructure after #25 (Sprint-B B3 Lerian MCP + B4 gate-exec).
3. **Merge PR #894** in banxe-architecture (COMPLIANCE-MATRIX S12-16 → ✅ DEPLOYED).

### Operator Actions Required (to open L3 gate)

4. **G-GUARDIAN-WEBHOOK-MISSING**: CTIO registers GitHub App 15368 webhook → `http://100.68.102.48:5678/webhook/guardian-breach-alert`.
5. **CTIO sign-off** on L3 gate (per §3 L3 gate conditions).

*Appended 2026-06-30 per ADR-056 (append-only). Author: factory agent/factory/b3cm/cm-s12-16.*
