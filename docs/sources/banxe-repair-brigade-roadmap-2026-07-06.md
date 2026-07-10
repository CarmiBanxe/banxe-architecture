# BANXE Repair Brigade — Roadmap and Sprints

## Mission

First build an always-on AI repair brigade for BANXE infrastructure.  
Its job is to keep every live machine and every live AI model in working condition for task execution through automatic detection, diagnosis, repair, verification, and escalation.

This comes before broader bank-agent ambitions because resilience is the base layer for all later work.

## Operating Principle

The repair brigade follows the **Best Solution** runtime:

1. Detect incident.
2. Classify failure type.
3. Enumerate allowed repair actions.
4. Score actions by:
   - time to recovery
   - reversibility
   - blast radius
   - confidence
   - dependency risk
5. Execute the best safe action automatically.
6. Verify health after action.
7. Escalate to operator for irreversible or high-risk cases.

## Target Failure Classes

- Service down
- Model unloaded / cold
- GPU memory insufficient
- Timeout on generation
- Route drift to unhealthy node
- Node unreachable
- Repeated crash-loop
- Scheduler / sleep regression
- Partial recovery with degraded performance

## Architecture Layers

### Layer 1 — Node self-recovery
- systemd Restart=always / RestartSec for ollama, llama-server, litellm
- keep_alive for critical models
- sleep/gdm masked on serving nodes
- boot-safe startup for core inference services

### Layer 2 — Watchdog monitor
- minute-level health checks across all registered aliases/endpoints
- auto-heal for safe routine failures
- ledger logging
- alerting
- post-repair verification

### Layer 3 — HITL / escalation
- no autonomous irreversible infra mutations
- config changes, model replacement, route-policy rewrites, destructive cleanup only via operator approval

## Sprint Plan

### Sprint 0 — Infra readiness audit
**Goal:** establish the real current state

**Deliverables**
- inventory of machines, aliases, services, models, ports
- restart-policy matrix
- keep_alive matrix
- model residency / VRAM matrix
- known route map for project-reason and similar critical paths
- failure taxonomy

**Exit criteria**
- every production-relevant node is classified
- every critical model has a known owner node and health method

---

### Sprint 1 — Base auto-recovery on nodes
**Goal:** eliminate trivial human-only recovery work

**Deliverables**
- systemd hardening for ollama / llama-server / litellm
- standardized keep_alive for critical models
- anti-sleep / anti-idle safeguards
- restart verification checklist per node

**Exit criteria**
- process crash no longer requires manual restart
- model cold-start regressions are reduced
- reboot does not silently disable serving

---

### Sprint 2 — Watchdog MVP
**Goal:** create the first automatic repair worker

**Deliverables**
- lightweight watchdog service
- health probes for every node and critical model
- safe repair actions:
  - restart service
  - warm model
  - re-check route health
  - emit alert
- append-only repair log / ACTION-LEDGER integration

**Exit criteria**
- at least one real failure class is auto-detected and auto-repaired
- operator receives alert + repair trace

---

### Sprint 3 — Best-Solution decision core
**Goal:** turn watchdog into a repair agent, not just a timer

**Deliverables**
- decision policy for allowed repair actions
- action scoring model
- confidence thresholding
- hard boundary between auto-fix and escalate
- standard post-action verification loop

**Exit criteria**
- repair decisions are explainable
- high-risk actions are escalated instead of guessed
- repeated incidents produce consistent choices

---

### Sprint 4 — Central / Factory / Scout synchronization
**Goal:** make repair operations part of the unified engine

**Deliverables**
- shared task/event schema
- ownership model:
  - Central = arbitration/policy
  - Factory = implementation/change delivery
  - Scout = diagnostics/discovery
- sync states:
  - issued
  - accepted
  - in_progress
  - blocked
  - awaiting_operator
  - completed
  - rejected
- shared decision/repair ledger

**Exit criteria**
- no conflicting repair actions from parallel terminals
- no invisible changes to infra state

---

### Sprint 5 — 24/7 production resilience layer
**Goal:** run the repair brigade continuously

**Deliverables**
- durable remediation workflows
- observability dashboards
- alert routing
- MTTR / incident recurrence metrics
- degraded-mode behavior
- temporary failover policy for unhealthy nodes/models

**Exit criteria**
- repair brigade runs continuously
- cold/unloaded models and dead services are routinely absorbed by automation
- operator intervenes only for high-risk branches

## First Practical Milestone

The first real milestone is:

**Cold Model / Unloaded Model Auto-Recovery for project-reason**

Reason:
- this is a live repeated failure mode now
- it has clear signals
- it has bounded safe actions
- it directly affects task throughput

### Incident logic
If model endpoint is unhealthy:
1. check service health
2. check model presence
3. check residency / warm state
4. attempt safe warmup
5. retry probe
6. if still failing, mark node degraded
7. trigger temporary failover
8. escalate if failure persists

## Immediate Next Sprint Backlog

1. audit all serving nodes for restart policy and keep_alive
2. identify critical models that must stay warm
3. define health endpoints and thresholds
4. define safe repair actions per failure class
5. create first watchdog spec for project-reason path
6. define failover rule for evo1 failure
7. define operator escalation template

## Non-Negotiable Boundaries

- no autonomous destructive edits
- no autonomous permanent routing changes without policy
- no config rewrite without escalation
- no hidden background actions outside the ledgered repair flow

## Definition of Success

Success is not “the agent exists”.
Success is:
- the infrastructure stays usable 24/7,
- common failures self-heal,
- risky changes escalate,
- and all repair behavior is observable, explainable, and synchronized.
