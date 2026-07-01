# Server-2 Runtime Enforcer — transferable BUILD-PROMPT (for the project/infra side)

> **Status:** governance artefact — the **canonical, ready-to-hand build-prompt** for constructing the
> server-2 runtime enforcer. **Date:** 2026-07-01. **Owner-terminal: A (factory).** **Pointer-first and
> additive (ADR-102).**
>
> **This is a TASK, not code.** It is handed to the **project/infra side** and **executed by the operator
> beyond the ADR-117 perimeter** (the LiteLLM gateway and the machines are operator-owned). This document
> **does not implement the enforcer**, writes no code, and **touches no LiteLLM gateway config, no gateway,
> no machines, no `banxe-ui`, no `config/compute/server-2-borrow-policy.yaml`, no policy doc, and not the
> enforcer spec itself** — it references them. It is derived from the enforcer specification
> `SERVER-2-RUNTIME-ENFORCER-SPEC.md` (#934, IL-782) and restates none of it.

---

## 0. How to use this prompt
Hand this document to the implementer (project/infra terminal). It is the **single canonical source** for
the enforcer build. Wherever it fixes behaviour, that behaviour is **normative** and traces to the ratified
policy; wherever it marks `[НЕИЗВЕСТНО]`, the implementer decides at build time. The **authoritative
behavioural + interface contract is the enforcer spec (#934)**; this prompt is its executable framing plus
the concrete ratified numbers to build against.

## 1. What to build
Build an **admission-controller / scheduler** ("the enforcer") that **physically executes**
`admit` / `deny` / `drain` / `kill` for server-2 (evo2, the `qwen3:235b-a22b-banxe` slot) at the **LiteLLM
gateway (`:4000`)**, enforcing the ratified policy in
`docs/governance/SERVER-2-BORROWABLE-COMPUTE-ORCHESTRATION.md` (#932). The enforcer **reads all thresholds
from** `config/compute/server-2-borrow-policy.yaml` — the **ratified** config (#933 defaults + #936 SLO) —
**as data**; it hardcodes nothing.

## 2. Ratified thresholds to build against (READ from config — do NOT hardcode)
These are the **ratified** values the enforcer must consume from `server-2-borrow-policy.yaml`. They are
listed here for the implementer's orientation **only** — the enforcer reads them from the YAML at runtime,
it does not embed them:

| Key | Ratified value |
|---|---|
| `governance.factory_borrow.concurrent_ceiling` | 1 (auto-clamped to 0 while any `project_*` active) |
| `governance.factory_borrow.idle_grace_s` | 90 |
| `governance.factory_borrow.drain_deadline_s` | 120 |
| `governance.factory_borrow.max_runtime_s` | 900 |
| `governance.factory_borrow.daily_budget_tokens` | 2,000,000 |
| `governance.factory_borrow.runaway_kill_after_s` | 1200 |
| `governance.factory_borrow.max_duty_cycle` | 0.30 |
| `governance.project_batch.max_duty_cycle` | 0.60 |
| `workload_classes.project_critical.runtime_cap_s` (**project_critical SLO**) | **120** (ratified #936) |

The enforcer MUST re-read the config on change so a re-ratified threshold takes effect **without a code
edit** (§6 proves this).

## 3. Invariants to implement (from spec #934 — normative)
- **project-priority hard invariant** — any `project_*` class always outranks any `factory_*`/`experimental`
  class; the enforcer MUST NOT violate it for any reason (utilization included).
- **fail-closed** — telemetry unavailable / health-check fail / config unreadable ⇒ borrowing OFF,
  server-2 project-only, factory heavy falls back to `factory-*` on evo1.
- **graceful-drain-then-defer** — on any `project_*` arrival: stop admitting new borrow, drain in-flight up
  to `drain_deadline_s` (120 s); finished within ⇒ complete, overrun ⇒ defer/cancel.
- **runaway hard-kill** — a borrow exceeding `runaway_kill_after_s` (1200 s) is hard-stopped regardless of
  drain.
- **health-check-before-borrow** (mandatory gate) — gateway→server-2 reachability, model loaded/loadable,
  memory headroom, error-rate under threshold; any failure ⇒ deny + log, stay project-only.
- **factory-journal events** — emit `borrow_grant`, `borrow_deny`, `revocation`, `preempt_defer`,
  `runaway_kill`, `budget_exhausted`, `health_fail`, each with `correlation_id`, `tenant`, `class`,
  `alias`, `duration`, `tokens`, `reason`.
- **telemetry** — **reuse the existing LiteLLM `success_callback`/`failure_callback: prometheus`**; add only
  borrow-specific counters (do not stand up a parallel telemetry stack).

## 4. Config-driven (hard requirement)
The enforcer is a **read-only consumer** of `server-2-borrow-policy.yaml`. It MUST NOT hardcode, override, or
mutate any threshold. **Changing a threshold is a config edit + re-ratification (governance), never a code
change.** Tenant/lane is derived from the request's **alias prefix** (`project-*` = primary lane,
`factory-*` = borrow lane) — the aliases already exist on the live gateway; the enforcer consumes them and
introduces no new model/endpoint.

## 5. Gateway integration mechanism — `[НЕИЗВЕСТНО]` (implementer's choice)
The **exact** integration point — a **pre-call hook**, a **sidecar proxy**, a **router pre-call**, upstream
request cancellation, or another mechanism — **depends on the deployed LiteLLM version's capabilities and is
chosen by the implementer**. This prompt fixes only the **required capability**: *"an admission decision is
evaluated before a `factory-*` request occupies the 235b slot, with the ability to hold, deny, drain, or
cancel it, and to observe slot-busy / primary-queue-depth / in-flight-borrow-runtime."* The concrete
mechanism, the enforcer's **deployment point** relative to the gateway, and any gateway wiring are
**operator/infra decisions** — not fixed here, not invented.

## 6. Acceptance criteria (testable by simulation — NO hardware mutation)
The enforcer is accepted when a **dry-run over a job trace** (a synthetic project/factory request sequence —
**no live 235b load, no gateway mutation**) demonstrates **all** of:
1. **Priority within deadline** — `project_critical` is served on the slot ahead of any pending
   factory-borrow within `drain_deadline_s` (120 s).
2. **Correct denial** — factory-borrow denied whenever the project queue is non-empty **or** the
   health-check fails (`borrow_deny`/`health_fail` journalled).
3. **Anti-monopoly** — factory rolling duty-cycle never exceeds `max_duty_cycle` (0.30); `budget_exhausted`
   fires when the token budget is spent.
4. **Fail-closed** — degraded/absent telemetry or unreadable config ⇒ borrowing off, slot project-only.
5. **Journal completeness** — every grant/deny/revocation/preempt_defer/kill carries the required fields.
6. **No hardcoding** — **flipping a value in the ratified config changes enforcer behaviour with no code
   edit** (e.g. set `drain_deadline_s` and observe the drain window change). This is the decisive proof of
   config-driven design.

A conformance harness that replays a trace and asserts 1–6 is the acceptance artefact. It requires **no live
235b load and no gateway change**; live wiring is validated by the implementer on operator-owned infra
afterwards.

## 7. Scope / boundaries for the implementer
- Build the enforcer + its conformance harness **only**; do **not** alter the ratified policy or config
  (threshold changes go back through governance re-ratification).
- The build runs on **operator-owned infra under the operator gate** (ADR-117 perimeter); the gateway and
  machines are operator-owned.
- Emit evidence (journal + conformance-harness results) so the factory can consume it read-only — mirroring
  the evidence-ingest discipline used elsewhere in this programme.

## 8. What this document did NOT touch
No enforcer/scheduler code. No LiteLLM gateway config. No gateway. No machines. No `banxe-ui`. No
`config/compute/server-2-borrow-policy.yaml`. No policy doc. Not the enforcer spec. This is a **build-prompt
for infra execution**, authored governance-side, prepare-only.

## Anchors
`docs/governance/SERVER-2-RUNTIME-ENFORCER-SPEC.md` (#934, IL-782 — the authoritative behavioural + interface
contract this prompt frames for execution) ·
`docs/governance/SERVER-2-BORROWABLE-COMPUTE-ORCHESTRATION.md` (#932, IL-778 — the policy enforced) ·
`config/compute/server-2-borrow-policy.yaml` (ratified: #933/IL-780 defaults + #936/IL-784 project_critical
SLO=120 — the thresholds read) · `docs/adr/ADR-154-shared-space-orchestration.md` (factory-as-arbiter) ·
ADR-117 (regulated perimeter — build is operator-gated, project/infra-side) · existing LiteLLM
`success_callback`/`failure_callback: prometheus` (reused, not reinvented) · ADR-102 (Duplication Audit —
this restates none of the above) · CLAUDE.md §10 (Config-over-Hardcoding) / §11 (prod-state HITL). Operator
directive 2026-07-01 (fix the transferable enforcer build-prompt as a governance document).
