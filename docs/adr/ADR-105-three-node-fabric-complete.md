---
id: ADR-105
title: Three-node execution fabric — completion & GAP G1–G7 closure record
status: ACCEPTED
date: 2026-06-17
accepted: 2026-06-17
supersedes: []
related:
  - "ADR-104-three-node-execution-fabric.md (the decision + runtime contract this records the completion of)"
  - "ADR-103-server-only-refactoring-policy.md (server-only build; fabric built server-side)"
  - "ADR-102-no-smart-refactor-without-duplication-verification.md (Duplication Audit)"
  - "ADR-040-ai-execution-policy.md (planes/trust inherited)"
il_anchor: IL-267
scope: BANXE-only
concept_only: false
---

# ADR-105: Three-node execution fabric — completion & GAP closure record

**Status:** ACCEPTED — 2026-06-17
**IL:** IL-267
**Applies to:** the factory and all agent/refactor/migration work — records that the ADR-104
fabric is **built and active** (with two explicitly operator/HITL-gated exceptions).

## Context

ADR-104 **decided** the three-node execution fabric (evo1 control / evo2 reasoning / Legion
execution) and `docs/runbooks/three-node-execution-fabric-contract.md` specified the runtime
contract; `docs/runbooks/three-node-fabric-bootstrap.md` listed the pre-fabric debt as
**GAP G1–G7**. The fabric has since been **built and verified** server-side across F1.1–F1.5
stage-3.1 (all merged). This ADR is the **completion/closure record**: it asserts no new
design — it states what is now real, maps each GAP to its closing IL/runbook, and is
**honest** about what remains operator/HITL-gated. It does **not** re-specify the fabric
(that is ADR-104 + the contract runbook).

## Decision

Record the ADR-104 fabric as **IMPLEMENTED AND ACTIVE**. The canonical action path
`reasoning(evo2) → policy(evo1) → execution(Legion)` is live, with: `correlation_id`
end-to-end; a Redis-streams bus + heartbeat/health; an evo1 `gate.policy` (deny-by-default);
a Legion `gate.exec` whose **real execution is restricted to a low-risk idempotent
allow-list** (`read.health`, `status.read`, `fabric.ping`); **risky actions require human
HITL and otherwise REFUSE**; `fail-closed` everywhere; and the ADR-104 §5 failover.

### GAP G1–G7 closure matrix

| GAP | Requirement (bootstrap §3) | Status | Closed by |
|---|---|---|---|
| **G1** | Three-node fabric as one process (not single-evo1) | **CLOSED** | F1.1 evo2 + F1.2 evo1 + F1.3/3.1 Legion gate — three live nodes (IL-257, IL-259, IL-260, IL-265, IL-266) |
| **G2** | evo2 = live reasoning node (GPU) | **CLOSED** | F1.1 — Vulkan-accelerated ollama + LiteLLM :4000 + health/heartbeat :9208 (IL-257) |
| **G3** | Legion = sole execution gate | **CLOSED for low-risk; HITL-gated for risky** | F1.3 dry-run + stage-3 activation (low-risk allow-list) + stage-3.1 consumer (IL-260, IL-265, IL-266). Risky execution remains operator/HITL-gated (see Residual). |
| **G4** | evo1 policy gate before action | **CLOSED** | F1.3 `gate.policy` :9110 — deny-by-default, risky→requires_hitl, fail-closed, §5 (IL-260) |
| **G5** | correlation_id on every task/log/artifact | **CLOSED** | F1.1/F1.2 — `fab-<utc-iso>-<6hex>`, minted evo1, echoed evo2, end-to-end through gates (IL-257, IL-259) |
| **G6** | queue + heartbeat/health service | **CLOSED** | F1.2 control-plane + F1.5 stage-2 Redis-streams bus + heartbeat (IL-259, IL-264) |
| **G7** | controlled sync layer (no state drift) | **CLOSED** | F1.5 stage-2 — Redis-streams as the controlled bus; evo1 only **reads** evo2 health (no cross-node FS/state write); tagged-degraded audit (IL-264) |

### Residual — explicitly NOT auto-closed (operator/HITL-gated)

1. **Persistent Legion `gate.exec` consumer.** The stream-consumer (stage-3.1) is built,
   unit-templated (`Type=simple`), and tested server-side, but the **real prod service start
   on Legion is an OPERATOR ACTION** (`systemctl --user enable --now gate-exec.service` +
   Legion-side vault). Until started, G3 is closed *in capability*, not *running in prod*.
2. **Risky execution.** Real execution of risky classes (payment/withdraw/trade/transfer/
   custody/key-ops) is **NOT enabled**: it requires a **separate operator authorization +
   HITL per action** (AUTO>90 / REVIEW 70–90 / BLOCK<70, `.claude/rules/agents.md`). Stage-3
   deliberately restricts real execution to the low-risk idempotent allow-list.

These two are **not** claimed closed. They are tracked in the bootstrap runbook's
"Residual operator-gated" TODO and gated per ADR-104 §3 + CLAUDE.md §11.

## Consequences

- **Positive:** one auditable task lifecycle is real; no node acts on prod without the
  policy + execution gates; graceful degradation works; the GAP debt is closed or honestly
  scoped.
- **Cost / honesty:** "active" means the low-risk path runs end-to-end and the risky path is
  gate-enforced to REFUSE — it does **not** mean risky prod actions execute. Over-claiming
  closure would be a canon violation; the Residual section keeps the record truthful.
- **Enforcement:** any claim that the fabric does more than this record states (e.g. risky
  auto-execution, or a running Legion prod consumer the operator did not start) is incorrect.

## Duplication Audit (ADR-102)

**Coverage:** `docs/adr/` (esp. ADR-104), `docs/runbooks/three-node-execution-fabric-contract.md`
and `three-node-fabric-bootstrap.md`, and the F1.x IL shards/runbooks.

| Match | Decision | Rationale |
|---|---|---|
| **ADR-104** (decision + roles + 6 invariants) | **keep — source-of-truth (decision)** | ADR-105 records **completion**, it does not re-decide; no decision text duplicated. |
| **fabric-contract runbook** (runtime interface) | **keep — source-of-truth (interface)** | Not re-specified; referenced. |
| **bootstrap runbook** (deployment plan + GAP G1–G7) | **keep + update** | ADR-105 records GAP closure; the bootstrap GAP table is updated to point here (one closure record, not a fork). |
| F1.x IL shards / runbooks | **keep — evidence** | Cited as the closing artifacts per GAP; not duplicated. |

**Verdict:** **no duplicate** — ADR-104 = decision/contract; ADR-105 = completion/closure
record with the GAP matrix + honest residuals. Distinct roles, single source each. **Keep
all, no merge/delete.**

## References

- ADR-104, ADR-103, ADR-102, ADR-040; `docs/runbooks/three-node-execution-fabric-contract.md`,
  `three-node-fabric-bootstrap.md`, `evo2-reasoning-node-bringup-2026-06-17.md`,
  `evo1-control-plane-bringup-2026-06-17.md`, `gate-services-dry-run-2026-06-17.md`,
  `bus-redis-streams-2026-06-17.md`, `gate-exec-stage3-2026-06-17.md`,
  `gate-exec-stage3.1-consumer-2026-06-17.md`; IL-257, IL-259, IL-260, IL-264, IL-265, IL-266.
