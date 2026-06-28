# ENGINE-ROADMAP-INPUTS.md
# Agent-Engine-as-Bank-Core — Roadmap Inputs Anchor
# Source: CENTRAL-SYNTHESIS (session 2026-06-28, dossier audit PRs #842–#851)
# IL: assigned at merge by build_ledger.py | ADR-143-A | status: PREPARED

> **SCOPE:** Input-anchor only. This file contains VERIFIED synthesis from
> Central's dossier audit session. It is the source-of-truth for the roadmap
> builder (next factory task). It is NOT the roadmap itself — no timelines,
> no sprint assignments here. Append-only per ADR-056/I-24.

---

## 1. GAP Inventory [CENTRAL-SYNTHESIS verified]

Five engine gaps identified in target-audit (PR #842) and confirmed against
ADR corpus + runtime-snapshot + DEDUP-FINDINGS.

| ID | Gap | Evidence | Scope |
|----|-----|----------|-------|
| **GAP-E1** | Intent-dispatcher L1→L2 not deployed | `planner.yaml` exists (concept); dispatcher absent from passports + runtime (ADR-045 §concept_only, ADR-049 lines 291/390/490 [GAP]) | architecture (spec) + infra (runtime) |
| **GAP-E2** | Tool-registry / MCP binding partial | LangGraph ✅ DEPLOYED (COMPLIANCE-MATRIX S12-13); Lerian MCP ❌ absent (S12-16) | architecture |
| **GAP-E3** | Semantic-memory / Qdrant not deployed | `:6333 NOT LISTENING` (runtime-snapshot); ADR-136/137 deferred; episode-substrate required for ADR-141 self-healing | infra |
| **GAP-E4** | A2A inter-agent contract absent | No ADR exists; no passport formalises it; NOVELTY (no prior decision) | architecture (ADR first, then implementation) |
| **GAP-E5** | Execution-sandbox contract not formalised | Autonomy L1–L4 defined (agent-authority.md, ADR-077); gate-exec/gate-policy exist in fabric/legion; contract layer absent | architecture (contract) + fabric/legion (gate-exec present) |

### GAP Dependency chain

```
GAP-E4 (A2A ADR)
  └─► GAP-E1 (dispatcher spec, needs A2A contract)
        └─► GAP-E2 (tool-registry binding, needs dispatcher)

GAP-E3 (Qdrant deploy)
  └─► ADR-141 self-healing (episode-substrate dependency)

GAP-E5 (execution-sandbox)
  └─► GAP-E1 (dispatcher enforces sandbox policy per L1–L4 level)
```

---

## 2. Sprint Split [CENTRAL-SYNTHESIS verified]

Source: DEDUP-FINDINGS.md §OSS Status Correction + ADR-060 §6 (runtime boundary).

### Sprint-A — banxe-architecture repo
Scope: ADR authoring, passport updates, spec/contract docs.
- ADR for GAP-E4 (A2A contract)
- ADR amendment for GAP-E1 (dispatcher deployment trigger)
- GAP-E2: Lerian MCP binding spec (ADR or passport)
- GAP-E5: execution-sandbox contract formalisation
- Passport revisions (planner.yaml, intent-layer masks per ADR-049)

### Sprint-B — banxe-ai-infrastructure repo
Scope: runtime deployment, fabric wiring, evo1/evo2 services.
Per ADR-060 §6: Temporal saga, Redis-lease, Qdrant deploy = runtime concerns,
OUT OF SCOPE for banxe-architecture PRs.
- GAP-E3: Qdrant `:6333` deploy on evo1/evo2 (ADR-136/137 execution)
- Temporal saga runner (ADR-060 §6, ADR-133; NOT_STARTED per DEDUP-FINDINGS)
- Redis-lease (ADR-143-A; already used for IL allocation — extend to saga lease)
- Intent-dispatcher runtime wiring (after Sprint-A ADR approved)
- evo1/evo2 USB4 fabric wiring for new services (ADR-018 compute substrate)

---

## 3. Reuse Scaffold — DO NOT REBUILD [CENTRAL-SYNTHESIS verified]

The following artefacts are DEPLOYED or SPEC-COMPLETE. The roadmap must
reference them, not replace them.

| Artefact | Status | Location |
|----------|--------|----------|
| `planner.yaml` | SPEC-COMPLETE (concept_only: true) | `agents/passports/planner.yaml` |
| ADR-045 (intent-first banking) | ACCEPTED (concept) | `docs/decisions/ADR-045-*.md` |
| ADR-049 (client-facing agent masks) | ACCEPTED | `docs/decisions/ADR-049-*.md` |
| ADR-136/137 (Qdrant vector memory) | DEFERRED → Sprint B | `docs/decisions/ADR-136/137-*.md` |
| `fabric/legion/gate-exec/` | DEPLOYED | `fabric/legion/gate-exec/` |
| `fabric/legion/gate-policy/` | DEPLOYED | `fabric/legion/gate-policy/` |
| `fabric/common/bus-redis-streams.py` | DEPLOYED | `fabric/common/` |
| 70 passports (swarm) | VERIFIED (2026-06-28 snapshot) | `agents/passports/` |
| LangGraph | DEPLOYED (COMPLIANCE-MATRIX S7-06/S12-13 ✅) | banxe-emi-stack |
| CrewAI | DEPLOYED | banxe-emi-stack |
| AutoGen | DEPLOYED (S7-08/C-29 ✅) | banxe-emi-stack |

**Mandate:** No new OSS agent frameworks. Extend DEPLOYED ones only.

---

## 4. Maturity Model [CENTRAL-SYNTHESIS verified]

Three-level gate before production adoption.

```
L1 — DESIGN
    ADR accepted; passport spec complete; gap formalised.
    Gate: architecture review + orphan-check 0.

L2 — SANDBOX (minimum for adoption-gate)
    Code committed + tests pass; InMemory stub available.
    Gate: CI green + coverage ≥ 80% + security-scan clean.

L3 — PRODUCTION (operator-gated)
    Live keys set; HITL gate wired; audit trail active (I-24).
    Gate: CTIO/CEO sign-off + FCA-boundary review (CASS 15 if applicable).
```

**Adoption-gate (100% engine-complete):** All 5 GAPs at L2 minimum; L3 = operator-gated keys.

| GAP | Current Level | Min-for-adoption |
|-----|---------------|------------------|
| GAP-E1 (intent-dispatcher) | L1 partial (ADR-045/049 exist; no deploy) | L2 |
| GAP-E2 (tool-registry/MCP) | L1 partial (LangGraph deployed; Lerian absent) | L2 |
| GAP-E3 (semantic-memory) | L0 (Qdrant not deployed; ADRs deferred) | L2 |
| GAP-E4 (A2A contract) | L0 (no ADR, no spec) | L2 |
| GAP-E5 (execution-sandbox) | L1 partial (gate-exec exists; contract absent) | L2 |

---

## 5. Known Runtime Gaps [CENTRAL-SYNTHESIS verified]

From VERIFIED-RUNTIME-SNAPSHOT.md + PR #845 addendum A-003.

| ID | Gap | Severity | Source |
|----|-----|----------|--------|
| **G-CANON-BYPASS** | OpenClaw instances invoke Ollama directly, bypassing canon audit path; I-24/I-28 audit-gap | P1 | SNAPSHOT + A-003 |
| **G-GUARDIAN-WEBHOOK-MISSING** | Guardian App 15368 has no webhook configured; breach alerts silently dropped | P1 | SNAPSHOT + A-003 |

These gaps BLOCK L3 production readiness for any engine component that uses
OpenClaw or Guardian webhook. They must be resolved in Sprint B before L3 gate.

---

## 6. Input Completeness

| Section | Source | Confidence |
|---------|--------|------------|
| GAP-E1 | ADR-045/049 text (lines 291/390/490); PR #848 (SRC-03) | HIGH |
| GAP-E2 | COMPLIANCE-MATRIX S12-13/S12-16; DEDUP-FINDINGS §OSS | HIGH |
| GAP-E3 | runtime-snapshot `:6333 NOT LISTENING`; ADR-136/137 | HIGH |
| GAP-E4 | DEDUP-FINDINGS §NOVELTY; SRC-02/SRC-04 no A2A ADR found | HIGH |
| GAP-E5 | agent-authority.md; ADR-077; fabric/legion verified | HIGH |
| Sprint split | ADR-060 §6 + DEDUP-FINDINGS boundary | HIGH |
| Reuse scaffold | DEDUP-FINDINGS §OSS Status + COMPLIANCE-MATRIX | HIGH |
| Maturity model | ADR-077 + agent-authority.md L1–L4 + HITL gates | HIGH |
| Runtime gaps | VERIFIED-RUNTIME-SNAPSHOT.md v2 + A-003 addendum | HIGH |

**Next step:** factory roadmap task consumes this file as input-anchor and produces
`ENGINE-ROADMAP.md` (timeline, sprint assignments, milestones, acceptance criteria).

---

*Append-only. Do not edit existing sections. New verified findings → append §7+.*
