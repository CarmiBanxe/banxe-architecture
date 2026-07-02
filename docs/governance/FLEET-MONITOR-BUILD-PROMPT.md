# Fleet Heartbeat Monitor + Alert-Sink — transferable BUILD-PROMPT

> **Status:** governance artefact — the **canonical, ready-to-hand build-prompt** for constructing the
> fleet heartbeat monitor + alert-sink. **Date:** 2026-07-02. **Owner-terminal: A (factory).**
> **Pointer-first and additive (ADR-102).**
>
> **This is a TASK, not code.** It is handed to the infra implementer and **executed by the operator on
> operator-owned infra under the operator gate** (ADR-117 perimeter). This document **implements no
> monitor / daemon / enforcer / alert-sink**, writes no `fabric/legion/*` runtime, and **touches no
> machines, gateway, perimeter, or `config/fleet/*`**. It is derived from
> `SERVER-CONTROL-ORCHESTRATION.md` (#959, IL-807) + `config/fleet/*.yaml`, and restates none of them —
> it references them. The monitor here is **read-only**; the mutating enforcer is a **separate** downstream
> task (§1).

---

## 0. How to use this prompt
Hand this document to the infra implementer. It is the **single canonical source** for the fleet monitor
build. Wherever it fixes behaviour, that behaviour is **normative** and traces to the ratified policy
(#959) and thresholds (`config/fleet/heartbeat-policy.yaml`); wherever it marks `[BLOCKING]`/`[НЕИЗВЕСТНО]`,
the operator/implementer decides. The **authoritative behaviour is the policy (#959)**; this prompt is its
executable framing plus the placement resolved by the 2026-07-02 audit.

## 1. Placement (audit-resolved, canon-grounded)
- **Monitor + alert-sink → `fabric/legion/`** (the **existing** Legion-side ops subtree — already home to
  `gate-exec.service` + consumer + `fabric_redis`). It is the **always-on locus** the policy §4 requires
  (Legion), it reads the LiteLLM gateway (`:4000`) + host telemetry **READ-ONLY**, and it **does not act
  against machines**. Only a monitor/alerter is built here — no mutation of the fleet.
- **Alert-channel → Telegram via the Hermes role (ADR-126)** — the Tier-1, **read-only, alerting-first,
  HITL-safe** DevOps companion, explicitly **out of scope for merge / deploy / payment-core / AML** — and/or
  the **n8n** route already in the stack (GAP-066, port note 5680). The alert path performs **no
  payment/AML/merge action**; it emits an operator signal only.
- **#939 enforcer (mutating admit / drain / kill against the gateway) → a project/infra repo, beyond the
  ADR-117 perimeter.** The **concrete repo is `[BLOCKING: operator confirms]`** — `banxe-emi-stack` vs a
  dedicated infra repo — **NOT invented here.** This yields a **clean split: the read-only monitor is
  Legion-side (`fabric/legion/`); the mutating enforcer is project-side.**

## 2. What the monitor must do (from the #959 policy)
The monitor **reads thresholds from `config/fleet/heartbeat-policy.yaml`** (Config-over-Hardcoding) and
**MUST NOT hardcode them**:
- **Heartbeat probe** every `heartbeat_interval_s` against each `on`/`always-on` host in
  `config/fleet/server-inventory.yaml` (reuse the existing LiteLLM `prometheus` callback where a host serves
  the gateway; direct ollama `/api/tags` + ping for backends — no new telemetry stack).
- **Staleness/SUSPECT:** a heartbeat older than `freshness_window_s`, or `missed_beats` consecutive misses,
  ⇒ host = **SUSPECT**.
- **Health-check-before-use:** before any placement/borrow the monitor must be able to report host health;
  a host must be HEALTHY to be used (the allocator consumes this — §"orchestration integration", #959 §5).
- **One-retry:** on a failed health-check, retry **once** after `retry_grace_s`; a second failure ⇒
  **UNHEALTHY** ⇒ **fail-closed** (host leaves the placement set) + **alert** (§3).
- **Planned vs unexpected:** `operator-shutdown-window` + SUSPECT ⇒ **INFO**; `on`/`always-on` + SUSPECT with
  **no** window ⇒ **UNEXPECTED_OUTAGE** ⇒ **CRITICAL** (the evo1 case).
- **Monitor-survivability:** runs on Legion (always-on) and/or cross-checks so a monitored node's death (e.g.
  evo1, which is both control-node and monitored) cannot silence its own alarm.
- **Read-only:** the monitor observes and alerts; it does **not** admit/drain/kill or power-cycle anything —
  those mutations are the separate enforcer (§1, `[BLOCKING]` repo).

## 3. Alert format → Telegram (Hermes/ADR-126)
Emit one concise operator signal per event, routed to Telegram via the Hermes role (ADR-126) / n8n:
```
[SERVER-ALERT] severity=<CRITICAL|WARN|INFO>
host=<name> (<addr>)
event=<UNEXPECTED_OUTAGE | HEALTH_FAIL | RECOVERED | RECLAIM | BORROW_DENIED>
affected_workloads=<aliases/lanes>
probable_cause_class=<power/host-down | network/unreachable | model-not-loaded | resource-exhaustion | unknown>
last_seen=<ISO-8601Z>
next_action=<one line>
```
Severity from `config/fleet/heartbeat-policy.yaml#severity_map` (on-host UNEXPECTED_OUTAGE = CRITICAL,
HEALTH_FAIL = WARN, planned/RECOVERED = INFO). Channel/escalation come from each host's inventory record.
The alert path stays within the Hermes read-only/alerting-first envelope — no merge/deploy/payment/AML.

## 4. Acceptance — simulation-first
The monitor is accepted when the **validation drill (#959 §8.7)** passes **by simulation** (no live
power-cycle): declare an evo1 **shutdown-window ⇒ INFO** (no alarm); then **simulate an unexpected outage in
a job trace ⇒ CRITICAL** `[SERVER-ALERT]` **+ placement gated** (UNHEALTHY host leaves the set) **+ journal
entries**. Also: thresholds are **config-sourced** — flipping a value in `heartbeat-policy.yaml` changes
behaviour **with no code edit** (proves no hardcoding). No hardware mutation is required to accept; live
wiring is validated by the implementer on operator-owned infra afterwards.

## 5. Journal
Emit events to the **existing factory journal** (reuse journal + prometheus, per #959 §6): `outages`,
`recoveries` (+ downtime), `failed health-checks`, `operator-approved shutdown windows` (open/close), and
(host-tagged) `borrow/reclaim` — each with `correlation_id · host · event · cause_class · timestamp ·
affected_workloads · actor`.

## 6. Boundaries held
No monitor/daemon/enforcer/alert-sink code. `fabric/legion/*` runtime **not touched**. Machines, gateway,
perimeter, and `config/fleet/*` **not touched**. `#959` policy **not touched**. The **enforcer repo is
`[BLOCKING: operator]`, not invented.** This is a **build-prompt for infra execution**, authored
governance-side, prepare-only.

## Anchors
`docs/governance/SERVER-CONTROL-ORCHESTRATION.md` (#959, IL-807 — the policy this monitor executes) +
`config/fleet/server-inventory.yaml` + `config/fleet/heartbeat-policy.yaml` (the inventory + thresholds it
reads) · `fabric/legion/` (existing Legion-side ops subtree — the monitor's home; `gate-exec.service` et al.
present) · `docs/adr/ADR-126-hermes-tier1-cicd-watchdog-role.md` (Hermes Tier-1 read-only alerting-first
Telegram role — the alert channel) · GAP-066 (n8n in stack, port 5680) · ADR-117 (regulated perimeter —
build is operator-gated; enforcer is project/infra-side) · `docs/adr/ADR-154-shared-space-orchestration.md`
(factory-as-arbiter) · `SERVER-2-BORROWABLE-COMPUTE-ORCHESTRATION.md` (#932) + `SERVER-2-ENFORCER-BUILD-PROMPT.md`
(#939 — the mutating enforcer, separate `[BLOCKING]` repo) · existing LiteLLM prometheus callback + factory
journal (reused, not reinvented) · ADR-102 (Duplication Audit — restates none of the above). Operator
directive 2026-07-02 (fleet-monitor build-prompt; placement audit-resolved; enforcer repo `[BLOCKING]`).
