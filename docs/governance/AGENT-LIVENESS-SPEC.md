# Agent-Liveness Spec — measuring agent 7/24 liveness (agent-scoped, analogous to fleet-control #959)

> **Status:** governance contract + build-prompt (Sprint C of the master-plan #978). **Additive, pointer-first
> (ADR-102).** It defines **how agent liveness is measured** and hands the *runtime* build to infra/project as a
> **build-prompt** — it **activates no agent, installs no engine, edits no passport / ADR / config / perimeter
> / project code, bypasses no auth (no 401 bypass), and excludes legal/ss1 (I-18/I-20).** Thresholds are
> **config-as-data**, marked **`[RATIFY]`**. The factory authors the contract; **infra/project builds the
> monitor**, beyond the ADR-117 perimeter.

## 1. Problem (from #974 / #982)
A **node-level** heartbeat exists (fleet-control #959 — `config/fleet/heartbeat-policy.yaml`), but there is
**no agent-level liveness**. The runtime addendum (#982 §7) confirmed evo1 runs the OpenClaw MoA orchestration
(`gateway-moa`/`-ctio`/`-guiyon` live) and its agents answer **on-demand** — but **on-demand ≠ provably 7/24**,
a passport `status: active` **≠ a running process**, and **without a liveness contract, `live` / `idle` / `dead`
are indistinguishable** (GAP-2 / F-LIVE). This spec closes the **measurability** gap: it defines the signal by
which "an agent is meeting its liveness expectation" can be *proven*, not assumed.

## 2. Agent-liveness contract (what is emitted / how it is checked)
Each agent (or its gateway, on its behalf) is measurable by a **liveness signal**:

| Field | Meaning |
|---|---|
| `agent_id` | the passport/registry id (read-only reference; **not written into the passport here**) |
| `last_seen` | timestamp of the most recent evidence of life |
| `status` | `live` \| `idle` \| `dead` \| `unknown` (never inferred `live` by inertia — see §2 freshness) |
| `host` | where observed (e.g. `evo1`, `Legion`) |
| `invocation_count` | successful invocations in the current window (for on-demand agents) |
| `via` | `daemon` \| `on-demand-gateway` — **the liveness definition differs by this** |

**Two liveness models — this is the core of the spec:**
- **On-demand agents (evo1 MoA today):** `live` ⟺ **(gateway responds) AND (the agent route is registered) AND
  (a recent successful invocation within `freshness_window`)**. Liveness is **NOT** a persistent daemon — an
  idle on-demand agent is **not dead**. This distinguishes **on-demand-live** from **dead**, which the raw
  `ps`-based probe (#982) could not.
- **Daemon agents (if/when any exist):** classical **heartbeat** — a periodic liveness probe answered within
  `heartbeat_interval`, host-style states `live → idle → dead`.

**Freshness = the honesty boundary.** A signal older than `freshness_window` ⇒ **`unknown`**, **never `live`
by inertia**. An agent is only `live` on *fresh, positive* evidence; absence of evidence is `unknown`, not
`live` and not (by default) `dead`. `dead` requires a *failed* check within window, not mere silence.

## 3. Thresholds — config-as-data (`[RATIFY]`)
Per Config-over-Hardcoding (CLAUDE.md §10) and the #959 pattern, thresholds live in a **config file the monitor
reads as data** (the monitor MUST NOT hardcode them; a change is a config edit + re-ratification). Proposed
(the monitor's config, built infra-side — **not created here**):

```yaml
# agent-liveness-policy.yaml (schema — to be created infra-side, ratified like config/fleet/heartbeat-policy.yaml)
heartbeat_interval_s:  [RATIFY]   # daemon agents: probe cadence
freshness_window_s:    [RATIFY]   # signal older than this => unknown (never live-by-inertia)
idle_alert_after_s:    [RATIFY]   # §5 utilization: idle longer than this => observability signal
invocation_min_window: [RATIFY]   # on-demand: min successful invocations in window to count as live
retry_grace_s:         [RATIFY]   # one-retry wait before dead
```
**All values `[RATIFY]` — operator-ratified, not fabricated here** (same discipline as #964 heartbeat
ratification).

## 4. Integration (read-only; auth NOT bypassed)
- **Extends fleet-control #959 from node-scope to agent-scope** — same policy shape, one level down (host →
  agent). The node heartbeat (#959) answers "is the machine alive"; this answers "is the agent meeting its
  liveness expectation."
- **Reads through existing gateways READ-ONLY** — the litellm gateway (:4000) and evo1 MoA (:8080) via
  **legitimate access / emitted metrics**, **never bypassing the 401** (no auth break; the monitor uses a
  provisioned credential or a metrics endpoint the operator supplies — **[BLOCKING: operator]** to provide it).
- **Events → factory journal + Prometheus (reuse)** — the existing Prometheus/Alertmanager (per #964 placement,
  evo2) and the factory journal; **no new telemetry stack invented.**

## 5. Alerting
An agent **expected `live` but observed `dead`/`stale`** ⇒ **`[AGENT-ALERT]`** — the agent-scoped analogue of
`[SERVER-ALERT]` (#959) — routed via **Telegram / Hermes (ADR-126, read-only alerting-first envelope)**. Severity
mirrors #959: unexpected-dead ⇒ CRITICAL; stale ⇒ WARN; recovered ⇒ INFO. (Hermes stays Tier-1 read-only — it
*surfaces* the alert, it does not act.)

## 6. 24/7-utilization (observability, not error)
The operator's "agents must not idle" principle is made **measurable, not enforced**: an agent `idle` longer
than `idle_alert_after_s` ⇒ an **observability signal** (`[AGENT-IDLE]`), **not an error** — it tells the
orchestrator "this agent is free; give it work." This spec **defines the measurement**; *acting* on it
(dispatching work) is orchestrator/operator behaviour, **not decided here**. Idle ≠ dead; idle = available.

## 7. Build-prompt half — what infra/project builds (task, NOT code)
> The **runtime monitor** is built **infra/project-side, beyond the ADR-117 perimeter** — the analogue of
> `FLEET-MONITOR-BUILD-PROMPT` (#963), one level down. **This section is a task specification, not an
> implementation.**

**Locus:** `banxe-monitoring` (operator-owned monitoring repo — the #964 placement locus; watcher external on
Legion/tailscale, alert via Prometheus + Telegram). **Build target (operator/infra):**
1. An **agent-liveness monitor** that, per the §2 contract, computes `status` for each agent from
   gateway-responds + route-registered + recent-invocation (on-demand) or heartbeat (daemon).
2. Reads thresholds from `agent-liveness-policy.yaml` (§3, config-as-data) — **not** hardcoded.
3. Emits `[AGENT-ALERT]` / `[AGENT-IDLE]` to Prometheus/Alertmanager + Telegram (ADR-126).
4. **Uses legitimate gateway access / emitted metrics — MUST NOT bypass auth (no 401 break).**
5. **[BLOCKING: operator]** — provide the monitor's read credential / metrics endpoint, and **ratify** the §3
   thresholds. No agent is activated; no passport is edited; liveness is **read**, not written into passports
   in this track.

## 8. Boundaries
- **Spec + build-prompt only here.** The **runtime monitor is built project/infra-side** (banxe-monitoring),
  under the operator gate, beyond the perimeter.
- **Passports are NOT touched** — liveness is **read** about an agent; **writing a liveness field into a
  passport is a separate, out-of-scope decision** (not done here).
- **No agent activated · no engine installed · no auth bypassed (no 401 break) · no ADR/config/perimeter/
  project-code edited · legal/ss1/GUYON excluded (I-18/I-20).**
- Thresholds are **`[RATIFY]`** (operator); the monitor **locus** and **credential** are **[BLOCKING:
  operator]**.

## Anchors
`docs/governance/SERVER-CONTROL-ORCHESTRATION.md` + `config/fleet/heartbeat-policy.yaml` (#959 fleet-control —
the node-level contract this extends to agent-scope; #964 ratified placement = banxe-monitoring / Legion-tailscale
/ Prometheus+Telegram) · `docs/governance/AGENT-LIVENESS-GAP.md` (#974 — the gap this closes) ·
`docs/governance/AGENT-FLEET-MASTER-PLAN.md` §7 (#982 — evo1 MoA confirmed-running, on-demand ≠ 7/24) ·
`FLEET-MONITOR-BUILD-PROMPT` (#963 — the node-level build-prompt this mirrors one level down) ·
`docs/adr/ADR-126-hermes-tier1-cicd-watchdog-role.md` (Telegram/alerting, read-only) · `docs/adr/ADR-117-*`
(perimeter — monitor built project-side) · `docs/governance/AGENT-FLEET-ROADMAP.md` (#975 — Sprint C) ·
CLAUDE.md §10 (Config-over-Hardcoding — thresholds as data) · ADR-102 (Duplication Audit — restates none).
Operator directive 2026-07-02 (Sprint C: agent-liveness contract + build-prompt; measure 7/24; activate/install
nothing; no auth bypass; passports untouched).
