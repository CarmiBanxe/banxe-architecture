# Agent-Liveness Gap — verified absence of agent-level 24/7 liveness contracts @ `origin/main` `69889e8` (2026-07-02)

> **Status:** read-only governance gap record (non-canonical). **Additive, pointer-first (ADR-102).**
> **This is NOT a runtime-incident report, NOT a design, NOT an activation.** It records a **measured
> capability gap**: the fleet has node-level liveness but **no agent-level liveness/24-7 contract**. It edits
> no passport, designs no mechanism, asserts no runtime, implies no activation, and invents nothing.

## §1. Scope & method
- **Pin:** measured against `origin/main` at commit **`69889e8`** (2026-07-02) — a **point-in-time snapshot**;
  re-run the sweep to refresh.
- **Method:** read-only `git grep` / `git show` for top-level liveness fields across the 70 passports
  (anchored per lesson **L-10** — top-level keys only), plus reads of `config/fleet/heartbeat-policy.yaml` and
  ADR-126. **No file was mutated, no agent invoked, no runtime inspected.**
- **What was NOT done:** no passport/soul/swarm/agent edit; no ADR or `config/fleet` change; no mechanism
  design; no activation; no runtime/deployment probing.

## §2. Verified facts
- **F1 — passports carry no liveness contract.** **0 / 70** passports declare any `liveness` / `heartbeat` /
  `idle` / `uptime` / `schedule` / `run_mode` / `always_on` field (measured on top-level YAML keys).
- **F2 — the existing fleet heartbeat is node-level only.** `config/fleet/heartbeat-policy.yaml` probes
  **hosts**: "each on/always-on **host** answers a liveness probe", host state transitions
  HEALTHY→SUSPECT→UNHEALTHY(+RECOVERED), keyed on `host.expected_state`. It watches the **Legion / evo1 / evo2
  nodes**, not agents.
- **F3 — Hermes / ADR-126 is a watchdog, not an agent-liveness layer.** ADR-126 defines Hermes as a Tier-1
  **CI/CD Watchdog**, **read-only / alerting-first**, **factory-only**, and names **"24/7 specialized agents"
  as a *FUTURE* factory work item** — explicitly not a current runtime capability.
- **F4 — conclusion:** therefore **no agent-level liveness mechanism currently exists** — neither a
  passport-level contract (F1) nor a runtime layer (F2 covers nodes; F3 defers agents).
- **F5 — classification:** this is a **measurable capability gap**, **not** a runtime-incident report. No agent
  is claimed to have been running and then failed; the capability is **absent by design** (F3 parks it).

## §3. Node-vs-agent distinction (why the existing heartbeat does not close this)
The fleet heartbeat answers *"is this **machine** alive?"* — its subject is `host.expected_state` over
Legion/evo1/evo2 (F2). Agent liveness would answer a **different** question — *"is this **agent** meeting its
run/idle/uptime contract?"* — which requires a **per-agent** contract (F1: none exists) and an
**agent-scoped** runtime layer (F3: deferred). A healthy node says nothing about whether an agent on it is
scheduled, idle, or up. The two are **orthogonal**; the present mechanism covers only the former.

## §4. Canon binding (pointer-first — restates none)
- **ADR-126** (`docs/adr/ADR-126-hermes-tier1-cicd-watchdog-role.md`) — Hermes Tier-1 watchdog; **"24/7
  specialized agents" = future work item**. Any agent-liveness capability would be defined *there or in a new
  ADR*, not here.
- **Node heartbeat** (`config/fleet/heartbeat-policy.yaml`, `docs/governance/SERVER-CONTROL-ORCHESTRATION.md`)
  — the node-level mechanism this record is explicitly distinguished from (§3).
- **Fleet audit** (`docs/governance/FLEET-CONFORMANCE-AUDIT.md`, #972/#973) — which fenced runtime/liveness as
  out-of-scope; this record is the dedicated home for that one fenced item.
- **Agent-harness locus** (`docs/governance/SELF-IMPROVEMENT-MANDATE.md` §4) — the pending
  `[BLOCKING: operator / ADR-136-gated]` project-fork locus; **if** agent-liveness is ever built project-side,
  it would live against that locus, not be fabricated here.

## §5. Gap statement
**No agent-level liveness / 24-7 / idle-uptime mechanism exists at `69889e8`** — 0/70 passport contracts, and
no agent-scoped runtime layer (node heartbeat is orthogonal; ADR-126 defers 24/7 agents). Whether and how to
close this gap — a passport `liveness` contract schema, an agent-scoped runtime watcher, or an extension of
Hermes' future item — is a **design and governance decision** marked **`[BLOCKING: operator / ADR-gated]`**.
**No such mechanism is designed, proposed, or implied here.**

## §6. Honesty boundary
- **No passport edited** — F1 is measured, not fixed.
- **No runtime asserted** — no agent is claimed running, idle, up, or down.
- **No activation implied** — recording an absence activates nothing.
- **No mechanism invented** — the design/implementation choice is *recorded as blocked* (§5), not made.

## §7. Out of scope (explicitly excluded)
- Designing an agent-liveness / 24-7 / heartbeat mechanism (schema, daemon, scheduler).
- Editing any passport to add a liveness field; activating or scheduling any agent.
- Editing ADR-126 or authoring a new agent-liveness ADR (the decision is *recorded as blocked*, not made).
- Extending `config/fleet/*` to agents; touching Hermes scope; creating the agent-harness locus.
- Any framework/runtime reinterpretation; any claim that an agent is or was running.

## Anchors
`docs/adr/ADR-126-hermes-tier1-cicd-watchdog-role.md` (24/7 agents = future work item; watchdog scope) ·
`config/fleet/heartbeat-policy.yaml` + `docs/governance/SERVER-CONTROL-ORCHESTRATION.md` (node-level heartbeat
— the distinction of §3) · `docs/governance/FLEET-CONFORMANCE-AUDIT.md` (#972/#973 — runtime/liveness fenced
out-of-scope there; recorded here) · `docs/governance/SELF-IMPROVEMENT-MANDATE.md` §4 (agent-harness locus,
`[BLOCKING: operator / ADR-136-gated]`) · `docs/governance/FACTORY-LESSON-CAPTURE.md` L-10 (top-level
measurement rule applied to F1) · ADR-102 (Duplication Audit — restates none of the above). Operator directive
2026-07-02 (record the agent-liveness capability gap conservatively; design deferred).
