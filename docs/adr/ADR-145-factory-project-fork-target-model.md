---
id: ADR-145
title: Factory ⊕ Project fork target architecture — non-delegable authority + delegable execution (platform advantage model)
status: PROPOSED
date: 2026-06-28
concept_only: false
relates:
  - "ADR-117 (factory↔project perimeter — the contour boundary this model formalises)"
  - "ADR-135 (held-out adoption gate — the promotion mechanism between forks; stays factory-only)"
  - "ADR-136 (agentmemory substrate — Factory fork vs Project fork; PRECOND-05 factory-fork-only by default)"
  - "ADR-137 + MEMOIR-PILOT-PRECOND-06/07 (RED ZONE fail-closed; no-authority-expansion)"
  - "ADR-143 / ADR-143-A (single-writer central Redis IL allocator — the authority spine)"
  - "ADR-144 (orphan-safe ledger / orphan-detecting --check)"
il_anchor: IL-668
il_anchor_note: "Provisional per ADR-119 Rule 8 — minted by the central Redis allocator (ADR-143/143-A) over current origin/main. Frozen at rebase-before-merge."
scope: BANXE-architecture-governance
external_ref: "Temporal / LangGraph / AutoGen / Hermes-MCP referenced as infra, NOT imported by this ADR"
---

# ADR-145 — Factory ⊕ Project fork target architecture

> **DRAFT governance artifact. PREPARE-ONLY.** Concept/governance decision, **no runtime change, no
> install, no deploy, no enable.** Promotion to ACCEPTED is operator (Moriel) action through the
> **ADR-135 held-out adoption gate**. No RED-zone content; no authority delegated to the project fork.

## 1. Context

BANXE runs a **factory fork** (the AI agents that BUILD software — compute / agent / governance sub-forks)
and must now also treat the **project fork** (the EMI BANXE AI BANK execution contour) as a **separate
execution contour**. The goal is **platform advantage**, not mere automation: the same governance +
ledger + durability spine that runs the factory becomes the **trust boundary a product inherits**.

**Core invariant (the whole model rests on it):** **authority is NON-DELEGABLE.** IL mint, governance
decisions, merge-authority, and the ADR-135 adoption-gate stay in the **factory fork**. The **project
fork is an execution consumer — never an authority** (PRECOND-07 no-authority-expansion; ADR-117/136).
The project fork is **non-prod and RED-ZONE-excluded by default** (ADR-137: payment / KYC / AML /
sanctions / ledger-write / secrets / PII — fail-closed).

## 2. DECISION — ACCEPTED single target architecture (operator decision)

> **One target, no dilution.** Operator-ACCEPTED; integrated here by amendment (this ADR is **not**
> duplicated into a new number — anti-duplication, same class as the IL-collision fix ADR-143/144).
> Status stays **PROPOSED** until promoted through the **ADR-135 adoption-gate**.

**Target:** **Factory-authoritative, single-writer, durable-orchestrated contour.**
Authority (mint / governance / merge / adoption-gate) is **FACTORY-ONLY, non-delegable**; the write-path
is a **single-writer central atomic allocator**; runtime orchestration is **Temporal as a durable
control-plane with LangGraph as reasoning inside Temporal activities**; the project fork is an
**execution-consumer only**.

| Decision axis | ACCEPTED choice |
|---|---|
| **Authority layer** | **Factory-only, non-delegable** (mint / governance / merge / ADR-135 gate). Project fork never receives authority (PRECOND-07; ADR-117/136/137). |
| **Write-path (ledger / merge / mint)** | **Single-writer central atomic allocator** (ADR-143/143-A) + **orphan-gate** (ADR-144). |
| **Runtime orchestration** | **Temporal durable control-plane** (exactly-once, compensations, resume-after-crash) **WITH LangGraph as reasoning inside Temporal activities** (LangGraph + AutoGen already deployed → reuse, do not discard). |
| **Project fork** | **Execution-consumer only** — durable execution on **synthetic / non-prod** data + **read-only ledger-evidence projection**; never authority. |

### Rejected alternatives (why NOT)
- **Write-path:** ❌ *decentralized max+1* = the original IL-collision class; ❌ *distributed lock* =
  crash-of-lock-holder → stuck + complexity; ❌ *content-addressed-for-IL* = loses human-readable
  governance ordering **and** does not serialize merges. → **single-writer** chosen.
- **Orchestration:** ❌ *merge-queue + scripts as END-state* = native GitHub merge queue is unavailable
  on a user-owned repo, and scripts do not survive a terminal crash; ❌ *LangGraph as the durability
  layer* = in-process, not durable; ❌ *Temporal-only* = discards already-deployed LangGraph.
  → **Temporal (durable) + LangGraph (reasoning)** chosen; `main-merge-serialize` kept only as the
  **Phase-1 bridge**, not the end-state.
- **Authority:** ❌ *project-authority* or *split factory+project* = governance / RED-zone breach and
  re-creates authority races. → **factory-only** chosen.

## 3. Decision — per-layer placement

| Layer | Factory value | Project value | Governance risk | Reusable platform IP | Placement |
|---|---|---|---|---|---|
| **GitHub rulesets / merge-serialization / protected branches** | High (serialize merges, anti base-drift) | High but **stricter** (gate = compliance boundary) | Factory low (CI-only); **Project high** (gate must not weaken) | merge-serialization-as-code (works without org/Enterprise) — portable, commodity | **Both, different role** |
| **Single-writer ledger + ID allocator** (ADR-143/143-A/144) | Very high (IL spine: atomic, append-only, frozen, orphan-safe) | High as **audit/evidence** ledger (FCA CASS trail) | Factory low; **Project high** (financial/regulatory events = RED-adjacent) | **Tamper-evident single-writer frozen-ID orphan-safe decision-ledger engine** = genuine IP | **Both, different role**: factory = authority **mint**; project = **read-only evidence** projection |
| **Temporal durable workflows** — **PLANNED, NOT DEPLOYED** | Med-high (durable build/migration, no lost state) | **Very high** (durable saga / exactly-once / compensations for CASS recon, safeguarding, payment-orchestration) | Factory low; Project medium (orchestrates RED-zone, but durability = **compliance asset**: replay/audit) | Durable workflow-definitions for **regulated fin-ops** — reusable across EMI products. High moat | **Both, different role** (factory = build; project = fin-ops) |
| **LangGraph orchestration** — **ALREADY DEPLOYED (existing infra, not a new candidate)** | High (structured multi-agent state/memory/HITL-interrupt) | Medium (autonomy near RED-zone is bounded) | Factory medium (overlaps ADR-136/137/141 — avoid duplication); **Project high** (autonomous near RED = PRECOND-07) | Graph-orchestration + HITL-interrupt pattern; overlaps our stack | **Mostly factory**; project only under strict HITL |
| **Hermes plugins / MCP adapters** | Medium (extensibility, read-only integrations) | Low-med (RED-zone limits; read-only only) | Factory medium (arbitrary Python; sandbox/egress **[UNKNOWN]**); **Project high** | MCP as standardized integration layer — portable, commodity | **Factory-only** read-only pilot; project later, read-only only |
| **Lazyweb** — **factory-internal tooling** (`FACTORY-SCRIPTS-TOOLS-BACKLOG`), NOT an architectural layer | Tooling-level | n/a | Low (factory tool) | n/a (internal tool) | **Factory-internal only** |
| **Hallmark** — **[UNKNOWN]** | [UNKNOWN] | [UNKNOWN] | [UNKNOWN] | [UNKNOWN] | **[UNKNOWN — operator definition required]** (no repo definition; NOT invented) |

**Verified-fact anchors (read-only audit of origin/main, do not re-assume):**
- **Temporal** — decision RECORDED (durable saga, exactly-once, compensations) but **NOT DEPLOYED**
  (`:7233` not listening); deploy is **out of scope for the arch-repo**, tracked in
  `banxe-ai-infrastructure` **Sprint B**.
- **LangGraph + AutoGen** — **ALREADY DEPLOYED**; treat as **existing infrastructure**, not new candidates.
- **Hallmark** — **no definition exists in repo** → `[UNKNOWN]`, operator-input-needed; **not invented here**.
- **Lazyweb** — appears only in `FACTORY-SCRIPTS-TOOLS-BACKLOG` → scoped as **factory-internal tool**.
- Fork-perimeter ADRs on main: **ADR-117 / 135 / 136 / 137 / 143 / 143-A / 144**.

## 4. Authority boundary (the moat line)

**Stays FACTORY-ONLY (non-delegable authority layer):**
- **IL mint / ID allocator** (ADR-143/143-A) — the project fork **never mints an IL**.
- **Governance decisions** (governance sub-fork) and **ADR-135 held-out adoption-gate**.
- **Merge-authority** into canonical `main` (merge-serialization / protected branches as the gate).
- **Memoir / agentmemory factory fork** (ADR-136 PRECOND-05 factory-fork-only).

**Safely DELEGABLE to the project fork (execution only, never authority):**
- **Durable execution** of Temporal workflows on **synthetic / non-prod** data (replay/audit value).
- **Read-only evidence projection** of the ledger — the project may **emit** audit events; the factory
  remains **source-of-truth**; project never writes the canonical IL sequence.
- **Read-only MCP / Hermes integrations** — egress-bounded, no secrets, no RED-zone, disabled-by-default.

> The boundary is the product: the project fork **inherits** factory governance as a service; it does not
> copy authority. Any text or runtime that lets the project mint/merge/govern = ADR-137/PRECOND-07 breach.

## 5. Phased target — ACCEPTED (sequenced; each step is a separate gated work item — NOT executed by this ADR)

- **Phase 1 — NOW, no new infra (already near-golden).** Canonize the **factory-authority single-writer
  spine**: central allocator (ADR-143/143-A) + orphan-gate (ADR-144) + **make `main-merge-serialize` a
  REQUIRED status check** + **mandatory per-session isolated worktrees** (ADR-120). This is the current
  race / manual-toil elimination — already proven this contour (0 IL collisions, ledger 1:1). **No
  Temporal, no new tool.**
- **Phase 2 — after Temporal deploy (Sprint B, `banxe-ai-infrastructure`; OUT OF SCOPE here).** Wrap the
  factory **build / migration / merge pipeline in Temporal durable workflows**; the **allocator-mint and
  merge-serialize become Temporal activities** (exactly-once, resume-after-crash); **LangGraph agents =
  reasoning-activities** inside those workflows. A terminal crash → the workflow **resumes**, zero manual
  rebuild. **Authority unchanged** (factory-only).
- **Phase 3 — platform moat, under the ADR-135 gate.** Delegate to the **project fork** durable execution
  on **synthetic / non-prod** data + **read-only ledger-evidence projection**; **authority stays factory.**
  Moat = provable-governance + audit-ledger + durable regulated execution + RED-zone fail-closed.

> Each phase promotes only via the ADR-135 adoption-gate (operator HITL). Phase 1 needs no new
> infrastructure; Phases 2–3 are gated on the Temporal deploy and the open [UNKNOWN] in §7.

## 6. Platform-advantage thesis + moat

**Top-3 "what enriches us":**
1. **Authority-spine as platform IP** — a tamper-evident, single-writer, append-only, frozen-ID,
   orphan-safe decision-ledger + allocator with a **two-way projection** (factory = mint/authority;
   project = read-only evidence). The internal IL engine becomes a generic *provable-governance ledger*
   for a regulated domain.
2. **Durable regulated execution (Temporal)** — replay / exactly-once / compensations for CASS recon /
   safeguarding / payments as a **compliance moat** (auditable, recoverable financial ops) — not just
   orchestration.
3. **Promotion-gate as a product** — ADR-135 held-out gate + merge-serialization as the mechanism by
   which the project **safely inherits** factory output. This turns "we build faster" into "we build
   regulated software with **provable, non-delegable authority** the product inherits".

**Moat statement:** the advantage is **not** the AI agents (commodity) nor any single framework
(Temporal / LangGraph / Hermes are open to everyone). The moat is the **combination inside a regulated
contour**: an AI-factory producing EMI/FCA software on top of (a) an append-only, provable-governance
spine with **non-delegable authority**, and (b) **durable, replayable** financial execution, where the
project fork **inherits but never appropriates** authority, all **RED-zone fail-closed**. Hard to copy
because what must be reproduced is the *binding* (governance-authority + audit-ledger + durable execution
+ RED-zone fail-closed), already wired into the perimeter (ADR-117/135/137/143).

## 7. Open [UNKNOWN] — operator input required (does NOT block Phase 1)

> Phase 1 needs **none** of these (no new infra). They gate **Phase 2–3** only.

1. **Hallmark** — no repo definition; provide the meaning (code-signing/attestation? provenance? external
   service?) before its layer can be assessed. **Not invented.**
2. **Temporal deploy** — timeline / capacity + **persistence-backend & HA** topology, and **cluster ops
   cost**. Status today: decision recorded, **NOT deployed** (`:7233` not listening; Sprint B,
   `banxe-ai-infrastructure`, out of scope here). Gates Phase 2.
3. **LangGraph integration** — whether the already-deployed LangGraph (+ AutoGen) **integrates with our
   OpenClaw / MoA / ARL** stack or is standalone — affects how it wires as a Temporal **reasoning-activity**
   in Phase 2.
4. **Hermes plugin sandbox / egress** — execution isolation and `security.allow_lazy_installs=false`
   unverified; required before any factory pilot.
5. **Project-fork posture** — confirm project fork stays **non-prod + RED-excluded** for the pilot window
   (ADR-136 PRECOND-05 / ADR-137 PRECOND-06).

## Anchors
- ADR-117 (perimeter), ADR-135 (adoption gate), ADR-136 (substrate / factory-fork-only),
  ADR-137 + PRECOND-06/07 (RED zone / no-authority), ADR-143/143-A (allocator), ADR-144 (orphan-safe).
  Temporal (planned, Sprint B `banxe-ai-infrastructure`), LangGraph+AutoGen (deployed infra), Hermes-MCP
  (read-only factory pilot), Lazyweb (factory tool), Hallmark ([UNKNOWN]). PREPARE-ONLY; no runtime/secret;
  operator HITL via ADR-135.
