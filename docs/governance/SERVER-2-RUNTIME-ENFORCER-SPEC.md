# Server-2 Runtime Enforcer — implementation specification (build-prompt)

> **Status:** governance specification / **build-prompt** for the project/infra side. **Date:** 2026-07-01.
> **Owner-terminal: A (factory).** **Pointer-first and additive (ADR-102).**
>
> This document specifies **what the server-2 runtime enforcer must do** so that the ratified borrow policy
> (`SERVER-2-BORROWABLE-COMPUTE-ORCHESTRATION.md`, #932; thresholds ratified in #933) is executed
> *physically*. **It is a specification-prompt, not the enforcer.** The actual enforcer is **built by the
> project/infra side under the operator gate** (the LiteLLM gateway and the machines are operator-owned;
> ADR-117 perimeter). This document **writes no enforcer/scheduler code, touches no LiteLLM gateway config,
> no hardware, no `banxe-ui`, no `config/compute/server-2-borrow-policy.yaml`, and no policy doc** — it
> restates none of them; it references them.

## 0. What this is / is not
- **IS:** the exact behavioural + interface contract the enforcer must satisfy, expressed as a task for an
  implementer. Testable acceptance criteria included (§6), all validatable by **simulation without hardware
  mutation**.
- **IS NOT:** an implementation, a scheduler, a gateway change, a machine change, or a threshold source.
  All thresholds live in the **ratified config** and are **read**, never hardcoded (§1, §7).
- **Build side:** project/infra terminal, operator-gated. The enforcer's deployment point, its concrete
  gateway-integration mechanism, and the `project_critical` SLO are **[НЕИЗВЕСТНО]** here (§8) — the
  implementer sources them; this spec invents none.

## 1. Purpose
The enforcer is an **admission-controller / scheduler** that **physically executes** `admit` / `drain` /
`deny` / `kill` for server-2 (evo2, the `qwen3:235b-a22b-banxe` slot) at the LiteLLM gateway (`:4000`),
according to the policy in `SERVER-2-BORROWABLE-COMPUTE-ORCHESTRATION.md` and the **thresholds** in
`config/compute/server-2-borrow-policy.yaml` (ratified #933). The enforcer **reads the config as its single
source of thresholds** (Config-over-Hardcoding, CLAUDE.md §10) — it MUST NOT hardcode any value, and MUST
re-read on change so a re-ratified threshold takes effect without a code edit.

## 2. Behaviour (executes the policy — normative)
The enforcer implements exactly the policy's admission/revocation semantics:

- **admit** — a `factory-*` (borrow) request is admitted **only when ALL** borrowing conditions hold:
  the primary (`project-*`) queue for server-2 has been empty for `governance.factory_borrow.idle_grace_s`;
  the pre-borrow health-check passes (§4); live factory-borrow concurrency `< concurrent_ceiling`; and
  neither `daily_budget_tokens` nor the rolling `max_duty_cycle` is exhausted.
- **deny** — if **any** condition fails ⇒ the borrow is refused, a `borrow_deny` event is logged (§3), and
  server-2 stays project-only for that request. Denials are the normal, expected outcome under project load.
- **drain** — on arrival of any `project_*` request, the enforcer **immediately stops admitting** new
  factory-borrow and puts in-flight borrow on a **graceful drain** up to
  `governance.factory_borrow.drain_deadline_s`: a borrow finishing within the deadline completes; one that
  overruns is **deferred/cancelled** so the project job is served (`preempt_defer` event).
- **kill** — a borrow exceeding `governance.factory_borrow.runaway_kill_after_s` is **hard-stopped**
  regardless of drain (`runaway_kill` event).
- **project-priority invariant** — any `project_*` class always outranks any `factory_*`/`experimental`
  class. This is a **hard invariant the enforcer MUST NOT violate** for any reason (utilization included);
  it sits above allocator/enforcer discretion, at ADR-102 stop-barrier tier.
- **fail-closed** — if telemetry is unavailable, the health-check fails, or the config is unreadable, the
  enforcer **disables borrowing** and server-2 becomes **project-only**; factory heavy work falls back to
  its own tier (`factory-*` on evo1). Fail-closed is always the safe default.

Priority order and per-class placement/preemptibility are read from the policy/config
(`priority_order`, `workload_classes`) — the enforcer does not re-define them.

## 3. Interfaces (contract, not implementation)
### 3.1 LiteLLM gateway (`:4000`)
- **Tenant/class identification** — the enforcer derives tenant + lane from the **alias prefix** of the
  request: `project-*` ⇒ primary lane (project tenant); `factory-*` ⇒ borrow lane (factory tenant). The
  precise workload class maps from the alias per the policy's `lanes` / `workload_classes`. (These aliases
  already exist on the live gateway — the enforcer consumes them, it does not create models/endpoints.)
- **Slot observation** — the enforcer must observe, for the single serialized 235b slot: whether it is
  busy, the depth/age of the primary-lane queue, and in-flight borrow identity + elapsed runtime. **The
  concrete mechanism (gateway hooks / a pre-request admission callback / a sidecar proxy / router
  pre-call) depends on the deployed LiteLLM version's capabilities and is a project/infra decision
  ([НЕИЗВЕСТНО], §8).** This spec fixes the **required integration point** — "admission decision evaluated
  before a `factory-*` request occupies the slot, with the ability to hold/deny/cancel it" — not the code.
- **admit/deny/drain/kill actuation** — the enforcer must be able to: hold or reject a `factory-*` request
  before it occupies the slot (admit/deny); stop admitting and let an in-flight borrow finish or cancel it
  at the drain deadline (drain/defer); and terminate a runaway borrow (kill). The actuation is via whatever
  the deployed gateway exposes (pre-call hook, request cancellation, upstream timeout, proxy interception)
  — **described as a required capability, not a specific call.**

### 3.2 Factory journal
The enforcer MUST emit, to the factory journal, one event per decision — with the exact event set and
fields from the policy:
- **events:** `borrow_grant`, `borrow_deny`, `revocation`, `preempt_defer`, `runaway_kill`,
  `budget_exhausted`, `health_fail`.
- **fields per event:** `correlation_id`, `tenant`, `class`, `alias`, `duration` (`duration_s`), `tokens`,
  `reason`.
This makes every allocation auditable and post-hoc contention explainable (Observability, policy §4).

### 3.3 Telemetry
**Reuse** the existing LiteLLM `success_callback`/`failure_callback: prometheus` pipe — the enforcer adds
only the **borrow-specific counters** (utilization, queue time, failed jobs, throughput, idle windows,
reclaim/revocation events, health status). It **does not** stand up a parallel telemetry stack (pointer to
the existing callback, not a reinvention).

## 4. Health-check-before-borrow (mandatory gate)
Before admitting **any** factory-borrow, the enforcer runs the policy's pre-borrow health-check:
gateway→server-2 reachability; strongest-model loaded/loadable; memory headroom; recent error-rate under
threshold. **Any failure ⇒ deny the borrow, log `health_fail`, stay project-only.** You may not borrow what
you cannot observe; a failing or unavailable health-check is a fail-closed condition (§2).

## 5. Configuration binding (read-only consumer of the ratified thresholds)
The enforcer treats `config/compute/server-2-borrow-policy.yaml` as **read-only input**. It binds:
`governance.factory_borrow.{concurrent_ceiling, idle_grace_s, drain_deadline_s, max_runtime_s,
daily_budget_tokens, runaway_kill_after_s, max_duty_cycle, health_required}`,
`governance.project_batch.max_duty_cycle`, `priority_order`, `workload_classes`, `lanes`, `revocation`,
`fallback`, and `observability`. It MUST NOT hardcode, override, or mutate any of these; a threshold change
is a **config edit + re-ratification** (governance), never a code change.

## 6. Acceptance / simulation criteria (testable, no hardware mutation)
The enforcer is "policy-conformant" when a **dry-run over a job trace** (a synthetic sequence of
project/factory requests — **no hardware, no gateway mutation**) demonstrates **all** of:
1. **Priority within deadline** — a `project_critical` request is served on the slot **ahead of** any
   pending factory-borrow within `drain_deadline_s` (observable as queue-time + a `revocation`/`preempt_defer`
   event).
2. **Correct denial** — a factory-borrow is **denied** whenever the project queue is non-empty **or** the
   health-check fails (`borrow_deny`/`health_fail` in the journal).
3. **Anti-monopoly** — factory rolling duty-cycle never exceeds `max_duty_cycle` over the window; and
   `budget_exhausted` fires when the token budget is spent.
4. **Fail-closed** — under degraded/absent telemetry or unreadable config, borrowing is disabled and the
   slot is project-only.
5. **Journal completeness** — every `grant`/`deny`/`revocation`/`preempt_defer`/`kill` appears with the
   required fields (§3.2).
6. **Config-sourced thresholds** — flipping a value in the ratified config changes enforcer behaviour with
   **no code edit** (proves no hardcoding).

A conformance harness that replays a job trace and asserts 1–6 is the acceptance artefact. It requires **no
live 235b load and no gateway change** — the trace + a policy model suffice; live wiring is validated later
by the implementer on operator-owned infra.

## 7. project_critical SLO — a config parameter, never invented
The `project_critical` SLO / `workload_classes.project_critical.runtime_cap_s` is **still `[RATIFY]`**
(project-owned, awaits the project SLO — #933). The enforcer MUST accept it as a **config parameter**: read
it when present, and when absent treat `project_critical` as **uncapped within its HITL envelope** (the
policy's placeholder default) — it MUST NOT fabricate an SLO value.

## 8. [НЕИЗВЕСТНО] — implementer/operator-sourced, not invented here
- **Gateway-integration mechanism** — the exact admission/actuation hook depends on the deployed LiteLLM
  version's capabilities (pre-call hook vs sidecar proxy vs router pre-call vs upstream cancellation); a
  **project/infra decision**, sourced at build time.
- **project_critical SLO** — project-owned (§7), pending the project SLO number.
- **Enforcer deployment point** — where the enforcer process runs relative to the gateway (in-process
  callback, adjacent service, proxy) is a project/infra decision — the gateway and machines are
  operator-owned (ADR-117 perimeter).
These are surfaced as build-time inputs; this spec invents none.

## 9. Boundaries held
Touches ONLY this specification document + its IL shard. **No enforcer/scheduler code.** **LiteLLM gateway
config not touched.** **Hardware/machines not touched.** **`banxe-ui` not touched.**
**`config/compute/server-2-borrow-policy.yaml` not touched** (read-only consumer described, not edited).
**The policy doc not touched.** This is a **build-prompt** the project/infra side executes under the
operator gate.

## Anchors
`docs/governance/SERVER-2-BORROWABLE-COMPUTE-ORCHESTRATION.md` (#932 — the policy this enforces) ·
`config/compute/server-2-borrow-policy.yaml` (ratified #933/IL-780 — the thresholds it reads) ·
`docs/adr/ADR-154-shared-space-orchestration.md` (factory-as-arbiter) ·
`docs/governance/TERMINAL-OWNERSHIP.md` (compute-ownership zones) ·
`docs/governance/CONFLICT-LEDGER.md` (contention deconfliction) · `.claude/rules/agents.md` (alias set) ·
existing LiteLLM `success_callback`/`failure_callback: prometheus` (reused, not reinvented) · gates ADR-102
(dedup, unchanged) / ADR-117 (regulated perimeter — build is operator-gated, project/infra-side) /
CLAUDE.md §10 (Config-over-Hardcoding) / §11 (prod-state HITL). Operator directive 2026-07-01 (scope the
runtime-enforcer).
