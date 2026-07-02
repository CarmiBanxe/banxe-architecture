# Agent-Fleet Roadmap — consolidated findings-register + sprints @ `origin/main` `acb43b0` (2026-07-02)

> **Status:** governance roadmap (consolidation, non-canonical planning record). **Additive, pointer-first
> (ADR-102).** It consolidates the **already-recorded** agent-audit findings (#972/#973/#974 + framework
> sweep) into one findings-register and a sprint plan. **It activates no agent, installs no framework, edits
> no passport / ADR / config / perimeter / project code, and invents no framework-status or repo.** It
> **does not duplicate** the adoption ADRs (ADR-148/126/127) — it **references** them as the existing adopt
> track. Sprint sequencing is a **proposal**; the final order is the operator's.

## 1. Scope & method
- **Pin:** measured facts are as recorded at `origin/main` **`acb43b0`** (2026-07-02); a point-in-time
  consolidation of prior audits — re-run their sweeps to refresh.
- **Sources consolidated (facts, not re-derived):** `FLEET-CONFORMANCE-AUDIT.md` (#972/IL-816),
  its erratum (#973/IL-817), `AGENT-LIVENESS-GAP.md` (#974/IL-818), and the framework sweep (read-only).
- **What this is NOT:** not an activation, not an install, not a design/ADR, not a dedup. Each
  state-changing item is marked with its **owner** and, where beyond the factory perimeter (ADR-117) or
  requiring a human gate, **AWAITS-OPERATOR**.

## 2. Findings-register (verified facts)
| ID | Finding (measured) | Source | Owner of remedy |
|---|---|---|---|
| **INV** | Inventory: **4** factory agents (`.claude/agents/`) + **70** project passports + **3** swarms (`accounting-swarm`, `banxe-aml-swarm`, `monthly-fca-return`) + framework mentions (**canon/prose only**). | #972/#973 | — |
| **STAT** | Status (strict top-level `^status:`): **39 PROPOSED / 10 active / 3 ACTIVE / 18 without top-level** (2 indented `PROPOSED` + 16 none); **activated 13/70**. | #973 | — |
| **GAP-1** | **57 agents not activated** (70 − 13) — the fleet is largely declared, not running. | #972 | operator (gate) + factory (normalise) |
| **GAP-2** | **No agent-level 24/7-liveness mechanism.** A node heartbeat exists (#966, node-level), but **agent liveness does not** — node-vs-agent are orthogonal: the machine can be alive while an agent idles undetected. | #974 | factory (governance/build-prompt) + project (runtime) |
| **GAP-3** | Frameworks (OpenClaw / Hermes / MetaClaw / MiroFish / Ruflo / IronClaw) are **not installed in this repo**; `services/` does not exist here (runtime is project-side, ADR-117). The **adopt question is OWNED by ADR-148** (PROPOSED, prepare-only, no-install) + **ADR-126** Hermes (ACCEPTED as a *bounded role-shape*, not installed) + **ADR-127** (PROPOSED). **Not duplicated here — referenced.** | framework sweep | operator (ADR-135 gate) + infra |
| **GAP-4** | **Duplicate `agent_id: banxe_aml_orchestrator`** (2 files: `aml/banxe_aml_orchestrator.yaml`, root `banxe_aml_orchestrator.yaml`). `aml_orchestrator.yaml` = distinct id (naming-proximity only). | #972 | **[BLOCKING: operator]** dedup (ADR-102) |
| **GAP-5** | **No agent-harness project-fork locus** — project-side self-improvement pending it (`SELF-IMPROVEMENT-MANDATE` §4, #971). | #971 | **[BLOCKING: operator / ADR-136-gated]** |
| **GAP-6** | Status/casing inconsistent (`active`/`ACTIVE`); **2 indented-status** (`data_lake_elt`, `treasury_alm`); **16 without any status**. | #973 | factory (normalise) |
| **GAP-7** | Orchestration canon exists (a2a **ADR-150**, `agents/swarms/*`, shared-space **ADR-154**) — **recorded as the basis for Sprint C**, not a gap to invent. | sweep | factory (extend) |

## 3. Sprints
Each sprint states **owner** (factory / project / operator), **dependencies**, **gate**, and what is
**factory-authorable** vs **beyond the perimeter (ADR-117)** / **AWAITS-OPERATOR**.

### Sprint A — Activate & Normalize (GAP-1, GAP-6)
- **Goal:** bring declared agents live and normalise status hygiene.
- **Factory-authorable:** status/casing normalisation proposal (`active`/`ACTIVE` → one form); fix schema for
  the 2 indented-status + 16 no-status passports **as a build-prompt/spec** (passport *edits* are project-side).
- **AWAITS-OPERATOR:** each **PROPOSED→ACTIVE** promotion is one-at-a-time through the **ADR-135 gate**
  (operator); no bulk activation.
- **Dependency:** none. **Gate:** ADR-135 per-agent; quality-gate on any factory artefact.
- **Beyond perimeter:** the passport file edits + actual activation (project/operator).

### Sprint C — Orchestration & 24/7-Liveness (GAP-2 → #974, GAP-7)
> Sequenced before B per the operator's "agents must not idle" principle (see §4).
- **Goal:** an **agent-level liveness contract** (closes GAP-2; the agent-scoped analogue of fleet-control
  #959, not a node heartbeat) + extend the existing a2a/swarm orchestration canon (GAP-7).
- **Factory-authorable:** the liveness-contract **governance spec + build-prompt** (schema for a per-agent
  run/idle/uptime contract), referencing ADR-126's "future 24/7 agents" item; orchestration extension design.
- **AWAITS-OPERATOR / project:** the **runtime** liveness watcher is built project-side / infra (beyond
  perimeter); any ADR for the contract is operator-gated.
- **Dependency:** benefits from Sprint A (agents live to be watched). **Gate:** ADR-135 for any promotion; the
  design decision itself is **[BLOCKING: operator / ADR-gated]** per #974.

### Sprint B — Framework Adoption (GAP-3)
- **Goal:** resolve the existing adopt track — **do NOT author a new adopt doc.**
- **Factory-authorable:** advance-or-defer **ADR-148** through the **ADR-135 held-out gate** (Ruflo-reviewed);
  progress **ADR-126/127** Hermes as their status dictates; on an adopt decision, a build-prompt.
- **AWAITS-OPERATOR / infra:** actual **binary install** = operator/infra, **beyond the perimeter**
  (dual-use posture, as the #949 Hyperbrowser eval established). No install here.
- **Dependency:** none blocking; informed by Sprint C's orchestration needs. **Gate:** ADR-135; ADR-148 owns
  the analysis.

### Sprint D — Cleanup & Fork (GAP-4, GAP-5)
- **Goal:** resolve the duplicate and stand up the project-fork locus.
- **Factory-authorable:** the ADR-102 Duplication-Audit **write-up** for `banxe_aml_orchestrator` (enumerate
  consumers) — as a finding for the operator's decision.
- **AWAITS-OPERATOR:** the **source-of-truth choice + keep/merge/delete** (GAP-4, ADR-102); the
  **agent-harness project-fork locus** (GAP-5, ADR-136-gated); projection of agents to the project fork
  (projection-model #967).
- **Dependency:** GAP-5 unblocks the project side of Sprint C. **Gate:** ADR-102 (dedup), ADR-136 (locus).

## 4. Proposed sequence (final order = operator)
**A (activate what exists) → C (24/7 so agents don't idle — the operator's principle) → B (frameworks) →
D (cleanup & fork).** Rationale: activate the declared fleet first, then give it a liveness contract so nothing
idles undetected (operator principle), then resolve adoption, then dedup + fork. **This ordering is a
proposal; the operator sets the final order.**

## 5. AWAITS-OPERATOR (the gated decisions this roadmap surfaces, none taken here)
- **dedup source-of-truth** for `banxe_aml_orchestrator` (GAP-4, ADR-102);
- **ADR-148 advance-or-defer** decision (GAP-3, ADR-135 gate) — *no new adopt doc*;
- **agent-harness project-fork locus** (GAP-5, ADR-136-gated);
- **per-agent activation** gate (GAP-1, ADR-135);
- **framework install** (GAP-3, operator/infra, beyond perimeter).

## 6. Honesty boundary
- **No agent activated · no framework installed · no passport/ADR/config/perimeter/project-code touched · no
  framework-status or repo invented.**
- **ADR-148/126/127 are NOT duplicated** — referenced as the existing adopt track (ADR-102).
- Facts are consolidated from #972/#973/#974 + the sweep; **remediation is deferred** to the owners/gates named
  per sprint. This roadmap **plans**, it does not execute.

## Anchors
`docs/governance/FLEET-CONFORMANCE-AUDIT.md` (#972/IL-816) · its erratum (#973/IL-817) ·
`docs/governance/AGENT-LIVENESS-GAP.md` (#974/IL-818) · #966 (node heartbeat ratify) ·
`docs/governance/SERVER-CONTROL-ORCHESTRATION.md` + `config/fleet/*` (#959 fleet-control — the node-level
precedent Sprint C is distinguished from) · `docs/adr/ADR-148-handson-ai-adoption-pack-v1.md` (PROPOSED —
the adopt track; **referenced, not duplicated**) · `docs/adr/ADR-126-hermes-tier1-cicd-watchdog-role.md`
(ACCEPTED role-shape) · `docs/adr/ADR-127-hermes-factory-delegation-contract.md` (PROPOSED) ·
`docs/governance/SELF-IMPROVEMENT-MANDATE.md` §4 (#971 — agent-harness locus) ·
`docs/governance/FACTORY-PROJECT-PROJECTION-MODEL.md` (#967 — projection) · `docs/adr/ADR-135-*` (adoption
gate) · `docs/adr/ADR-136-*` (agentmemory/locus gate) · `docs/adr/ADR-117-*` (perimeter) · `docs/adr/ADR-150-*`
(a2a inter-agent contract) · `docs/adr/ADR-154-*` (shared-space orchestration) · ADR-102 (Duplication Audit —
restates none of the above). Operator directive 2026-07-02 (consolidate agent-audit findings into roadmap +
sprints; activate/install nothing; do not duplicate ADR-148).
