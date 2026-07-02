# Server Control Orchestration — availability-integrity policy

> **Status:** governance policy (factory operating-model addition). **Date:** 2026-07-02.
> **Owner-terminal: A (factory).** **Pointer-first and additive (ADR-102).**
>
> Turns the server fleet into an **explicitly governed orchestration substrate**. **Policy + config-as-data
> only** — all thresholds live in `config/fleet/heartbeat-policy.yaml`; the fleet in
> `config/fleet/server-inventory.yaml`. It writes **no monitor / daemon / enforcer / alert-sink** (that is
> infra-side, ADR-117 perimeter), touches **no machines, gateway, perimeter, `CLAUDE.md`, the server-2
> policy, or the enforcer spec**. Occasioned by the **evo1 incident** — a USB4 host (`10.0.0.1`,
> operator-confirmed) powered off with **no operator signal**.

## 0. Purpose
Servers must not "live their own life." **Availability is a precondition of all orchestration:** the server-2
borrowable-compute policy (#932) assumes the 235b host is alive; the runtime enforcer (#934/#939) needs a
*healthy* host to admit/drain/kill against; project and factory workloads depend on the strongest-model host
and the gateway backends. A host that disappears silently makes every placement decision on a stale
assumption. This policy establishes known inventory, expected state, heartbeat/health, offline detection,
operator alerting, and availability-gated placement — additive to ADR-154 (factory-as-arbiter) and the
server-2 policy.

## 1. Heartbeat / health model
Thresholds are **read from `config/fleet/heartbeat-policy.yaml`** (Config-over-Hardcoding); the monitor never
hardcodes them.
- **Heartbeat expectation:** each `on`/`always-on` host answers a liveness probe every `heartbeat_interval_s`.
  Reuse the existing LiteLLM `prometheus` callback where a host serves the gateway, plus a direct host probe
  (ollama `/api/tags` + ping) for backends — **no new telemetry stack**.
- **Staleness / SUSPECT:** a heartbeat older than `freshness_window_s` is **stale**; `missed_beats`
  consecutive misses **OR** stale-beyond-window ⇒ host = **SUSPECT**.
- **Health-check-before-use:** before **any** job placement or borrow on a host, run its
  `health_check_method`; a host must be **HEALTHY** to receive work. This **extends server-2 §4**
  (pre-borrow health-check) to *all* placement on *all* hosts.
- **One-retry rule:** on a failed health-check, retry **once** after `retry_grace_s`; a second failure ⇒
  **UNHEALTHY**.
- **Fallback/escalation:** **UNHEALTHY** ⇒ stop placing/borrowing on that host, **fail-closed** to healthy
  hosts (or project-only for its primary lane), and raise an alert (§3).

## 2. Critical distinction — planned vs unexpected
- A host in an **`operator-shutdown-window`** (declared in inventory / journal) that goes SUSPECT is a
  **planned** event ⇒ **INFO**, no alarm.
- A host in **`on`/`always-on`** that goes SUSPECT with **no** open window is an **UNEXPECTED_OUTAGE** ⇒
  **CRITICAL**. *This is exactly the evo1 case* — no declared window, so it should have alerted.

The distinction is **config-driven and auditable** (`heartbeat-policy.yaml#outage_classification`; shutdown
windows journalled §6), so a planned outage is provably distinguishable from an unexpected one.

## 3. Alerting model
One concise, actionable operator signal per event:
```
[SERVER-ALERT] severity=<CRITICAL|WARN|INFO>
host=<name> (<addr>)
event=<UNEXPECTED_OUTAGE | HEALTH_FAIL | RECOVERED | RECLAIM | BORROW_DENIED>
affected_workloads=<aliases/lanes>
probable_cause_class=<power/host-down | network/unreachable | model-not-loaded | resource-exhaustion | unknown>
last_seen=<ISO-8601Z>
next_action=<one line>
```
Severity (from `heartbeat-policy.yaml#severity_map`): `on`-host **UNEXPECTED_OUTAGE = CRITICAL**;
**HEALTH_FAIL = WARN**; planned-shutdown / **RECOVERED = INFO**. Channel + escalation come from the host's
inventory record.

## 4. Design constraint — monitor survivability
The monitor **MUST NOT be single-pointed on a host that can itself go offline.** evo1 is *both* a
control/orchestration node *and* a monitored backend — if the monitor lived only on evo1, evo1's death would
also silence the monitor (the exact failure that hid this incident). The monitor runs on an **always-on
locus** (Legion) and/or **cross-checks** so a monitored node's death cannot silence its own alarm. The exact
survivable locus is `[НЕИЗВЕСТНО]` (infra-build decision, §7).

## 5. Orchestration integration (additive to ADR-154 + server-2 #932)
- **Availability gates placement:** the factory allocator treats **host HEALTHY + expected-state = on** as a
  *precondition* for placing any workload; a SUSPECT/UNHEALTHY host is removed from the placement set until
  RECOVERED.
- **Borrow only if healthy AND idle/borrowable:** factory may borrow project compute (server-2 borrow lane)
  **only** when the host passes the pre-borrow health-check *and* is idle per the ratified duty/ceiling caps —
  availability is an added AND-condition on the existing borrow gate.
- **Closed-world:** a host not in `server-inventory.yaml` is **not orchestrated** (no hidden off-grid state);
  a host in inventory but SUSPECT is *visibly* SUSPECT, never silently used or silently absent.
- **Reclaim-on-project-demand** (unchanged from #932) composes with availability: a host must be healthy to be
  reclaimed *to*.
- **Conflict-free across tenants:** central/right/project/factory read the **same** availability state (single
  source of truth); deconfliction via TERMINAL-OWNERSHIP (compute-zones) + CONFLICT-LEDGER — no two tenants
  place onto a host the fleet knows is down.

## 6. Journal / governance
Log to the existing factory journal (reuse journal + prometheus, per server-2 §4), one event with
`correlation_id · host · event · cause_class · timestamp · affected_workloads · actor`:
- **outages** (SUSPECT / UNEXPECTED_OUTAGE), **recoveries** (RECOVERED + downtime duration),
- **borrow/reclaim** events (host-tagged; already in the server-2 journal set),
- **failed health checks** (HEALTH_FAIL + retry outcome),
- **operator-approved shutdown windows** (open + close — so §2's planned-vs-unexpected distinction is
  auditable).

## 7. Enforcement placement
- **Governance + spec + inventory + thresholds = THIS repo (`banxe-architecture`)** — this doc +
  `config/fleet/*.yaml`, alongside the ratified server-2 policy. **KNOWN.**
- **Runtime locus (monitor + alert-sink + orchestrator hook + the #939 enforcer) = operator-owned infra,
  ADR-117 perimeter.** The **repo name is `[BLOCKING]` — NOT invented; operator decision.** Required target
  characteristics: operator-owned inside the ADR-117 project/infra perimeter (not this governance repo, not
  `banxe-ui`); owns deploy/systemd/ops for Legion/evo1/evo2; reads the LiteLLM gateway + host telemetry
  **read-only**; writes the factory journal (§6); reads the ratified `banxe-architecture` config as its
  threshold source (never hardcoding). *(Observed loci to confirm — not chosen, not invented: a `fabric/`
  layer exists in `banxe-architecture`; `banxe-emi-stack` carries `services/`/deploy.)*
- **Alert channel/transport = `[BLOCKING]`** — candidate n8n+Telegram is already in the stack for safeguarding
  alerts (per GAP-REGISTER) but is **NOT confirmed** for fleet alerts; operator chooses.

## 8. Acceptance — simulation-first
"Server control integrated into factory orchestration" is met when:
1. Inventory + heartbeat policy exist as config-as-data; every fleet host (Legion/evo1/evo2) has a complete
   record; **no host is orchestrated off-inventory** (closed-world).
2. **Health-check-before-use** precedes every placement/borrow; UNHEALTHY hosts leave the placement set.
3. A **validation drill** (no live power-cycle) demonstrates the §2 distinction: **declare an evo1
   shutdown-window ⇒ INFO** (no alarm); then **simulate an unexpected outage in a job trace ⇒ CRITICAL alert**
   (§3 format) **+ placement gated + journal entries**. This mirrors the server-2 #934 simulation-first
   acceptance — **no hardware mutation required to accept the policy**; live enforcement is the downstream
   infra ticket.
4. Borrow granted **only** when healthy AND idle/borrowable; reclaim-on-project-demand still holds.
5. Outage/recovery/borrow/reclaim/health-fail/shutdown-window events are journalled.
6. Thresholds are config-sourced, not hardcoded (flip a value ⇒ behaviour changes with no code edit).

## 9. Open questions
- **`[BLOCKING]` enforcement-locus repo** (§7) — operator-owned infra repo for the monitor/alert-sink/enforcer.
- **`[BLOCKING]` alert channel/transport** (§3, §7) — the concrete operator signal sink.
- **`[RATIFY]` thresholds** — `heartbeat_interval_s=30`, `freshness_window_s=90`, `missed_beats=3`,
  `retry_grace_s=10`, and per-host `expected_state`/`allowed_workloads`/`borrowable`: proposed defaults,
  operator-ratifiable.
- **`[НЕИЗВЕСТНО]` (non-blocking)** — Legion LAN address; the survivable monitor locus (§4) — resolved at
  infra build.

## Anchors
`config/fleet/server-inventory.yaml` + `config/fleet/heartbeat-policy.yaml` (config-as-data this policy
governs) · `docs/governance/SERVER-2-BORROWABLE-COMPUTE-ORCHESTRATION.md` (#932/IL-778) +
`config/compute/server-2-borrow-policy.yaml` (#933/#936) + `SERVER-2-RUNTIME-ENFORCER-SPEC.md` (#934/IL-782) +
`SERVER-2-ENFORCER-BUILD-PROMPT.md` (#939 — availability precedes the enforcer) ·
`docs/adr/ADR-154-shared-space-orchestration.md` (factory-as-arbiter) · `docs/governance/TERMINAL-OWNERSHIP.md`
· `docs/governance/CONFLICT-LEDGER.md` · ADR-117 (regulated perimeter — runtime is operator/infra-gated) ·
existing LiteLLM `success_callback`/`failure_callback: prometheus` + factory journal (reused, not reinvented)
· `AGENTS.md` (evo1 = control/orchestration; Legion = execution/ops) · `GAP-REGISTER.md` (n8n+Telegram
safeguarding-alert candidate, NOT confirmed for fleet) · ADR-102 (Duplication Audit — restates none). **Basis
of fact:** evo1 = LAN `192.168.0.72` / USB4 `10.0.0.1` (operator-confirmed), evo2 = `192.168.0.15` (235b host),
Legion = factory host; ADR-117 host set. Operator directive 2026-07-02 (server-control policy + inventory,
evo1 incident).
