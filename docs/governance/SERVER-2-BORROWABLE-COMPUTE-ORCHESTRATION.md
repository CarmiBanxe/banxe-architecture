# Server-2 Borrowable Compute Orchestration — policy + factory integration

> **Status:** governance policy (factory operating-model addition). **Date:** 2026-07-01.
> **Owner-terminal: A (factory).** **Pointer-first and additive (ADR-102).** **schema_version: 1.0.0.**
>
> This document adds **server-2 shared-compute policy** to the factory operating model. It is **policy +
> canon integration only**. All numeric thresholds live as data in
> `config/compute/server-2-borrow-policy.yaml` (Config-over-Hardcoding, CLAUDE.md §10) — **none in this
> doc, none in code**. It writes **no runtime enforcer/scheduler** (that is a separate downstream
> implementation slice, project/infra-side), touches **no LiteLLM gateway config**, and mutates **no
> hardware, `banxe-ui`, or `uiux-pipeline.sh`**. Ground-truth is *surfaced* (pointer), never mutated.

## 0. Ground truth (surfaced, not owned here)
Server-2 = **evo2** (`192.168.0.15`, ollama backend). Strongest model = **`qwen3:235b-a22b-banxe`**
(142 GB). The live gateway `litellm-lan-gateway.service` (`:4000`) **already** routes `project-reason`,
`factory-heavy`, and `reasoning-235b` onto that one model. The design keystone follows from this: the
strongest model is **one serialized slot** addressed by several alias names, and the alias **prefix**
(`project-*` vs `factory-*`) already carries tenant identity — so this policy is an **admission
discipline** layered onto wiring that exists, not new infrastructure. No new model or endpoint is
introduced.

**Framing (non-negotiable):** literal "100% utilization" is **explicitly rejected** as a target. The
objective is *controlled, policy-driven, observable, conflict-free* borrowing. Server-2 stays **primarily
project-owned**; factory borrowing is **explicit, bounded, revocable** and can never displace project
priority.

## 1. Policy model
**Ownership / tenancy.** Primary tenant = **EMI BANXE AI BANK project** (a standing reservation on the
235b slot); secondary tenant = **factory burst/borrow** (only a *revocable lease* on capacity the primary
is demonstrably not using).

**Priority order (strict, single source of truth).**
`project_critical › project_batch › factory_heavy_analysis › factory_audit › experimental`
(config: `priority_order`). Any `project_*` class **always** outranks any `factory_*`/`experimental`
class — a **hard invariant** the factory allocator may **not** override. The 235b slot is treated as a
**single serialized resource** (142 GB ⇒ co-residency is not assumed); contention is resolved by
**admission ordering**, not fractional sharing.

**Borrowing conditions (all must hold to admit a factory-borrow).** The primary queue for server-2 has
been empty for `idle_grace_s`; the pre-borrow health-check passes (§4); factory concurrency is below
`concurrent_ceiling`; the daily token budget and rolling duty-cycle are not exhausted (§3).

**Revocation conditions.** The instant a `project_*` request arrives, the policy (a) **stops admitting**
new factory-borrow, and (b) puts in-flight borrow on a **drain deadline** (`drain_deadline_s`): a borrow
finishing within it completes gracefully; one exceeding it is **deferred/cancelled** so the project job is
served. A borrow exceeding `runaway_kill_after_s` is **hard-stopped** regardless.

**Fallback = FAIL-CLOSED.** If telemetry is unavailable, the health-check fails, or the policy config
cannot be read → **borrowing OFF, server-2 project-only**, and factory heavy work falls back to its own
tier (`factory-*` on evo1). Fail-closed is always safe because it degrades to the project-primary default.

## 2. Workload classification
Placement is expressed through the **existing** alias prefixes — `project_*` classes via `project-*`
(primary lane on the shared 235b slot), factory classes via `factory-*` (borrow lane on the same slot,
admission-gated). Full data in `config/compute/server-2-borrow-policy.yaml#workload_classes`.

| Class | Examples | Placement | Priority | Preemptible by |
|---|---|---|---|---|
| **project_critical** | KYC/AML/sanctions & payment-adjacent reasoning, MLRO escalation, prod-state (CLAUDE.md §11) | server-2 primary lane (`project-reason`/`reasoning-235b`) | **P0** | never |
| **project_batch** | recon, FIN060/report gen, non-realtime analysis | primary lane or evo1 | **P1** | project_critical only |
| **factory_heavy_analysis** | heavy refactor reasoning, large-context code analysis (`factory-heavy`/`factory-coder`) | borrow lane when idle, else evo1 | **P2 (borrow)** | any project_* |
| **factory_audit** | review/dedup/consolidation, doc synthesis, journal aggregation | prefer evo1 (`factory-mid`); borrow only idle+capped | **P3 (borrow)** | any project_* |
| **experimental** | evals, prompt playground, non-critical trials | evo1 by default; server-2 only in explicit idle windows | **P4 (borrow)** | all higher classes — first revoked |

## 3. Resource governance
**Enforcement = admission control at the gateway, not fractional GPU partitioning** (a 142 GB model does
not fraction cleanly). The project holds a **hard reserved floor**: on demand it always gets the 235b
slot (`governance.project_reserved_floor: true`). The factory holds a **soft borrow ceiling**:
`concurrent_ceiling` (default **1**), **auto-clamped to 0** whenever any `project_*` job is queued or
running on server-2.

**Idle rule.** Borrow is admitted only after the primary queue has been empty for `idle_grace_s`
(default **90 s**) — the grace window stops a borrow grabbing the slot microseconds before a periodic
project job returns.

**Preemption = graceful-drain-then-defer** (LLM inference is not cleanly mid-token preemptible): stop
admitting → drain up to `drain_deadline_s` (default **120 s**) → defer/cancel the overrun. Hard-kill is
reserved for runaway only.

**Caps.** `max_runtime_s` (default **900**), `daily_budget_tokens` (default **2,000,000**),
`runaway_kill_after_s` (default **1200**). `project_critical` is generous/uncapped within its HITL
envelope; `project_batch` carries a runtime cap so it cannot starve `project_critical`.

**Anti-monopoly.** Even "idle" time is bounded: factory-borrow may consume at most `max_duty_cycle`
(default **0.30**) of server-2 wall-clock over a rolling 24 h window, plus per-job and per-day caps — so
chronic project idleness cannot become a de-facto second ownership. Symmetrically, `project_batch` is
duty-capped (default **0.60**) so it cannot starve `project_critical`. **All numbers live in config, never
in this doc or in code.**

## 4. Observability / health
**Metrics (per lane).** utilization, queue time, failed jobs, throughput, idle-window duration/frequency,
reclaim/revocation events, health-check status.

**Mandatory pre-borrow health-check.** Before admitting any factory-borrow: gateway→server-2
reachability, strongest-model loaded/loadable, memory headroom, recent error-rate under threshold. Any
failure → **deny borrow, log, stay project-only**. You may not borrow what you cannot observe.

**Reuse, don't reinvent.** LiteLLM already has `success_callback`/`failure_callback: prometheus`
configured — metrics ride that existing pipe; the policy adds only the **borrow-specific counters**
(pointer to the existing callback, not a new telemetry stack).

**Factory-journal logging.** Every `borrow_grant`, `borrow_deny`, `revocation`, `preempt_defer`,
`runaway_kill`, `budget_exhausted`, and `health_fail` is written to the factory journal with
`correlation_id`, tenant, class, alias, `duration_s`, tokens, and reason — so allocation is auditable and
post-hoc contention is explainable.

## 5. Factory orchestration integration (additive to ADR-154)
This extends **ADR-154 (factory-as-arbiter)** from shared *space* to shared *compute*, additively:
- **Factory decides placement.** The factory (left terminal, orchestrator-executor) is the **single
  allocator**: it maps each submitted workload's class → lane/host/alias and admits or defers per this
  policy — the "one decision surface" (Best Single Artifact) applied to compute.
- **Central / right terminals stay autonomous.** They own their sub-products and **submit** workloads
  tagged with a class; they do **not** self-allocate server-2. The factory reconciles.
- **Compute-ownership zones** are recorded alongside write-zones in **TERMINAL-OWNERSHIP**; cross-tenant
  contention is deconflicted through the **CONFLICT-LEDGER**.
- **Project-priority invariant sits structurally above allocator discretion** (same tier as the ADR-102
  stop-barrier) — the allocator can never trade project priority for utilization.
- **Duplicate-check (ADR-102) and code-quality re-check (`quality-gate.sh`) are unchanged.** Borrowing
  changes only **where** a heavy analysis runs, never **what** it must pass; a borrowed job is subject to
  the identical merge/dedup/quality discipline. This policy touches none of it.

## 6. Acceptance criteria (testable)
"Server-2 integrated into orchestration" is met when:
1. This doc + `config/compute/server-2-borrow-policy.yaml` exist, with **all thresholds in config, none in
   code** (verifiable by inspection).
2. The class→placement/priority table is complete (**all five classes** mapped) and machine-readable.
3. A **policy-conformance simulation** (dry-run over a job trace — **no hardware mutation**) shows:
   `project_critical` served ahead of any pending factory-borrow within `drain_deadline_s`; borrow
   **denied** whenever the project queue is non-empty or the health-check fails; and factory rolling
   duty-cycle never exceeds `max_duty_cycle`.
4. Every grant/deny/revocation/kill appears in the factory journal with the required fields.
5. **Fail-closed demonstrated:** telemetry-down or health-fail ⇒ server-2 goes project-only.
6. **Regression-free:** ADR-102 dedup and `quality-gate.sh` behaviour **byte-unchanged**.

**Honest scope boundary.** This package makes the **policy + config + canon integration** authorable and
testable *now* (criteria 1–2, 6 are static; 3–5 validate by **simulation** against a job trace). The
**runtime enforcer** (the admission-controller/scheduler that actually executes drain/deny/kill) is a
**separate implementation slice** — project/infra-side, no code here. Acceptance for *this* artifact is
the policy being defined, config-shaped, and canon-aligned; live enforcement is its downstream ticket.

## 7. Risk notes
- **Starvation** — factory-borrow starving the project → project-priority invariant + immediate
  admission-stop + drain deadline; `project_batch` starving `project_critical` → intra-project priority +
  batch duty-cap.
- **Hidden contention** — a single 142 GB model means "idle GPU %" can mask an imminent project job, and
  project+borrow may not co-reside → the model is treated as a **serialized single slot**, guarded by
  `idle_grace_s` and short borrow caps so a returning project job waits at most the drain deadline.
- **Runaway factory jobs** — `max_runtime_s` + `runaway_kill_after_s` + daily token budget + duty-cycle
  cap.
- **Insufficient observability** — borrowing is *conditioned on* live telemetry + a passing health-check;
  degraded telemetry **fails closed** to project-only.
- **False "100% utilization" target** — explicitly disowned: the primary objectives are the **project
  SLO** and **zero project-preemption**; utilization is a secondary observed metric, never an optimization
  target. Chasing 100% would *guarantee* the contention this policy prevents.

## 8. Open questions / [НЕИЗВЕСТНО] — none blocking
The package is authorable and complete now; the remaining items are **operator-ratification** or
**downstream tickets**, not authoring blockers:
- **Threshold ratification** — every numeric in the config is a **proposed default** for operator
  sign-off (`config … #ratify`); the exact **`project_critical` SLO** is operator/project-owned and
  marked `[RATIFY]`.
- **evo2 headless-`claude` host question** — a **separate infra ticket**, not decided here.
- **Runtime-enforcer slice** — the scheduler/admission-controller is a **downstream implementation**,
  project/infra-side, containing no code in this package.

## Anchors
`docs/adr/ADR-154-shared-space-orchestration.md` (factory-as-arbiter — extended to compute, additively) ·
`docs/governance/TERMINAL-OWNERSHIP.md` (compute-ownership zones ∥ write-zones) ·
`docs/governance/CONFLICT-LEDGER.md` (cross-tenant contention deconfliction) · `.claude/rules/agents.md`
(Agent-to-LiteLLM alias set: `project-*` / `factory-*` / `reasoning-235b`) · existing LiteLLM
`success_callback`/`failure_callback: prometheus` (reused, not reinvented) · gates ADR-102 (dedup,
unchanged) / `quality-gate.sh` (unchanged) / CLAUDE.md §10 (Config-over-Hardcoding) / §11 (prod-state
HITL). **Config-as-data:** `config/compute/server-2-borrow-policy.yaml`. Operator directive 2026-07-01
(server-2 borrowable-compute package authorized).
