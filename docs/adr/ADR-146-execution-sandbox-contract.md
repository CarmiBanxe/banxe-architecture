---
id: ADR-146
title: Execution-Sandbox Contract — L1-L4 isolation policy + gate-exec spec
status: PROPOSED
date: 2026-06-28
accepted: 
supersedes: []
relates:
  - "ADR-128 (Banking-agent HITL authority matrix L1/L2/L3)"
  - "ADR-150 (A2A Inter-Agent Message Contract — ESCALATION type)"
  - "ADR-077 (Autonomy levels — reference)"
  - "agent-authority.md (Agent Autonomy Matrix — BANXE EMI Stack)"
  - "ADR-120 (Session Worktree Isolation)"
  - "I-27 (HITL — AI PROPOSES, human DECIDES)"
  - "I-24 (Append-only audit trails)"
il_anchor: IL-691
il_anchor_note: "Assigned at merge per ADR-143-A."
scope: BANXE-factory-only
concept_only: false
---

# ADR-146 — Execution-Sandbox Contract: L1-L4 Isolation Policy + gate-exec Spec

## Context

**ADR-150** (A2A Inter-Agent Message Contract) defines a formal messaging envelope for
multi-agent orchestration, including the `ESCALATION` message type for L3+ actions requiring
HITL approval (I-27). **ADR-128** classifies all banking-domain AI into four autonomy levels
(L1/L2/L3/L4) with HITL gates at L2/L3/L4.

However, ADR-128 does not define the **execution isolation model**: how does gate-exec
enforce isolation at each autonomy level, and what sandbox (Python VENV / Docker / process)
does each level execute in?

**Gap evidence:**
- No ADR specifies which agent actions run in the same Python process (L1) vs isolated subprocess (L2) vs containerized (L3)
- No gate-exec integration spec exists to enforce HITL gates before L3+ execution
- No resource limits (CPU, memory, timeout) defined for agent sandboxes
- Multi-agent workflows (A2A messages) lack a pre-execution HITL check before sending an `ESCALATION` message to the HITL service

**This ADR fills the gap:** it defines the isolation model, maps L1-L4 → sandbox policy,
and specifies gate-exec integration points (I-27).

---

## Decision

Define a formal **execution-isolation model** for all agent code by autonomy level.
No new runtimes; leverage existing Python async, subprocess, and Docker infrastructure.

### Isolation Model by Autonomy Level

| Level | Autonomy | Isolation | Description | Timeout | Resource Limits |
|-------|----------|-----------|-------------|---------|-----------------|
| **L1** | Auto (read-only) | Python async (same process) | Fully trusted; stateless read operations; no state mutations. Examples: fetch account balance, log event, fetch FX rate. | No timeout | None (lightweight) |
| **L2** | Alert → Human | Python subprocess (VENV) | Isolated environment; can emit alerts but cannot mutate external state. Spawned in subprocess to contain side effects. Examples: anomaly detection, fraud scoring, KYC HIGH decision proposal. | 5 seconds | CPU: 50%, Mem: 256MB |
| **L3** | Auto + HITL gate | Docker container (ephemeral) | Full isolation; container is ephemeral and destroyed after execution. No persistent state. HITL gate enforced before execution. Examples: SAR filing proposal, sanctions threshold change, PEP approval. | 10 seconds | CPU: 1 core, Mem: 512MB |
| **L4** | Human Only | No AI execution | No agent execution whatsoever. Human terminal only. AI only proposes via A2A `ESCALATION` message type. Examples: production deploy, board sign-off, FCA regulatory filing. | N/A | N/A |

### Sandbox Execution Flow (gate-exec)

Before any L2+ agent action executes:

1. **Agent declares autonomy level** in its passport or class initializer.
2. **Pre-execution checks** (same for L2, L3; L1 skips):
   ```
   gate-exec.check_hitl_token()          # I-27: HITL token present?
   gate-exec.check_a2a_escalation_ack()  # A2A ESCALATION message sent & MLRO ACKed?
   gate-exec.check_audit_pre_exec()      # ClickHouse pre-execution log (I-24)
   gate-exec.spawn_sandbox()             # VENV (L2) or Docker (L3)
   ```
3. **Sandbox execution**:
   - **L2:** Subprocess in Python VENV; inherits env vars but no shared process state.
   - **L3:** Docker container with `docker run --rm --cpus=1 --memory=512m --timeout=10s ...`
4. **Post-execution logging** (I-24): result logged to ClickHouse a2a_events table.
5. **HITL gate (L3+ only)**: if agent proposes a state-changing action, block execution and send A2A `ESCALATION` message to HITL service. Wait for human approval before proceeding.

### gate-exec Integration Points

#### Entry Point: `gate_exec.execute_agent()`

```python
async def execute_agent(
    agent_id: str,
    autonomy_level: str,  # "L1" | "L2" | "L3" | "L4"
    action: AgentAction,
    hitl_token: str | None = None,
    correlation_id: str = "",
) -> AgentResult:
    """
    Execute agent action, enforcing isolation policy per autonomy_level.
    
    Args:
        agent_id: passport agent_id (e.g., "sanctions-check-agent")
        autonomy_level: L1, L2, L3, or L4
        action: agent action (encodes propose/execute decision)
        hitl_token: HITL approval token (required for L3+)
        correlation_id: A2A correlation_id for audit trail (I-24)
    
    Returns:
        AgentResult (status, proposal, audit_ref)
    
    Raises:
        HitlGateError: if L3+ and hitl_token not present or ACK not received
        SandboxTimeoutError: if sandbox exceeds timeout
        SandboxResourceError: if container exceeds resource limits
    """
    # L1: execute directly in calling process (async)
    if autonomy_level == "L1":
        return await agent.run_async(action, correlation_id=correlation_id)
    
    # L2/L3: check pre-execution gates (I-27)
    if autonomy_level in ("L2", "L3"):
        await gate_exec.check_hitl_token(hitl_token)  # token required
        await gate_exec.check_a2a_escalation_ack(correlation_id)  # ACK received
        await gate_exec.check_audit_pre_exec(agent_id, action, correlation_id)  # pre-log
    
    # L2: spawn VENV subprocess
    if autonomy_level == "L2":
        return await gate_exec.spawn_venv_subprocess(
            agent_id, action, correlation_id,
            timeout_sec=5, cpu_pct=50, mem_mb=256
        )
    
    # L3: spawn Docker container + HITL gate
    if autonomy_level == "L3":
        # Check MLRO ACK on A2A ESCALATION message before executing
        ack = await gate_exec.wait_hitl_approval(
            correlation_id, timeout_sec=2  # TM alerts require fast gate
        )
        if not ack.approved:
            return AgentResult(status="REJECTED_BY_HITL", proposal=action, audit_ref=ack.audit_ref)
        
        return await gate_exec.spawn_docker_container(
            agent_id, action, correlation_id,
            timeout_sec=10, cpu="1", mem_mb=512
        )
    
    # L4: no execution; human only
    if autonomy_level == "L4":
        raise HitlGateError(f"L4 agent {agent_id} cannot execute; human approval required")
    
    raise ValueError(f"Unknown autonomy_level: {autonomy_level}")
```

### A2A ESCALATION Message Flow (I-27)

An L3 agent that proposes a state-changing action must send an A2A `ESCALATION` message
**before** execution. The HITL service ACKs or REJECTs the message. gate-exec waits for
ACK before spawning the container.

```python
# 1. Agent proposes action
escalation_msg = A2AMessage(
    message_type="ESCALATION",
    source_agent_id="sanctions-check-agent",
    target_agent_id="hitl-gate",
    payload={"action": "BLOCK_IBAN_XYZ", "reason": "sanctioned entity"},
    correlation_id=correlation_id,
    hitl_gate="MLRO",
)
await a2a_bus.send(escalation_msg)  # send to HITL service

# 2. gate-exec waits for ACK (with timeout)
ack = await gate_exec.wait_hitl_approval(correlation_id, timeout_sec=2)

# 3. If MLRO approved, execute container; if rejected, return REJECTED status
if ack.approved:
    result = await gate_exec.spawn_docker_container(...)
else:
    return AgentResult(status="REJECTED_BY_HITL", ...)
```

### Resource Limits & Timeouts

**L2 (VENV subprocess):**
- Timeout: 5 seconds (anomaly detection, fraud scoring expected to complete quickly)
- CPU: 50% of one core (shared with main process)
- Memory: 256 MB cap (enforced via `cgroups` or `resource.setrlimit()`)
- Exit on timeout: SIGTERM → SIGKILL after 1 second grace

**L3 (Docker container):**
- Timeout: 10 seconds (SAR filing, sanctions decisions may require coordination)
- CPU: 1 full core (--cpus=1)
- Memory: 512 MB cap (--memory=512m)
- Exit on timeout: container killed via `docker stop --time=1`
- HITL gate timeout: 2 seconds (if MLRO doesn't ACK within 2s, TM alert is rejected)

### Audit Trail (I-24)

Every agent execution (L1-L3) produces a ClickHouse log entry **before** and **after** execution:

```
a2a_events (append-only):
  - pre-execution: agent_id, action, autonomy_level, correlation_id, timestamp
  - post-execution: result_status, elapsed_ms, sandbox_type, audit_ref
```

L4 actions (human terminal) log only the human's decision and GPG signature.

### Declare Autonomy Level: Passport vs Class Init

Agents must declare their autonomy level in **one** of two ways (not both):

1. **Passport entry** (preferred for multi-agent swarms):
   ```yaml
   # agents/compliance/passports/sanctions-check-agent.yaml
   agent_id: sanctions-check-agent
   autonomy_level: L3
   hitl_gate: MLRO
   ```

2. **Class initializer** (for single-agent or test use):
   ```python
   class SanctionsCheckAgent:
       def __init__(self, autonomy_level: str = "L3"):
           self.autonomy_level = autonomy_level
   ```

If both are present, **passport wins**; class initializer is override-only for testing.
Undeclared agents default to L2 (most restrictive).

---

## Consequences

1. **Isolation enforced at runtime**: gate-exec blocks any L2+ agent action that lacks a HITL token or A2A `ESCALATION` ACK (I-27). Fail-closed.

2. **All agent code must declare autonomy_level**: Passport or class init. Undeclared → defaults to L2 (conservative).

3. **Resource exhaustion prevented**: L2/L3 sandboxes cannot consume unbounded CPU/memory; timeouts enforce bounded execution.

4. **Audit trail complete (I-24)**: every agent action pre-logged and post-logged to ClickHouse, keyed by correlation_id and agent_id.

5. **Multi-agent workflows trace correctly**: A2A `ESCALATION` messages link agent → HITL → approval → execution. No hidden hand-offs.

6. **gate-exec is the only execution entry point for L2+**: direct agent.run() calls are forbidden for L2/L3 agents. All executions route through gate-exec.

---

## Alternatives Considered

### 1. Always-Docker (rejected)
- Spawn Docker container for all L1-L4 agents.
- **Rejected:** L1 read-only operations (fetch balance, log event) incur 100ms+ container startup overhead. Unacceptable for TM alerts (2s gate timeout).
- Consequence: TM agent forced to L2+ even though monitoring-only.

### 2. AWS Lambda / FaaS (rejected)
- Isolate L3 agents on AWS Lambda; L2 on local VENV; L1 in-process.
- **Rejected:** violates ADR-117 (no cloud dependencies in production). Not self-hosted.

### 3. gVisor / Kata Containers (not yet)
- Lightweight VM isolation for L2 (between VENV and Docker).
- **Deferred to Phase 5:** requires additional infrastructure and testing. VENV sufficient for Phase 4 (MVP).

### 4. No isolation, HITL gates only (rejected)
- All agents run in-process; rely only on HITL gates to block L3+ actions.
- **Rejected:** exposes main process to resource exhaustion, uncontrolled side effects, credential leaks. Fail-open.

---

## Implementation Checklist (Gate-exec integration)

- [ ] Define `autonomy_level` field in agent passport schema (YAML)
- [ ] Implement `gate_exec.execute_agent()` in `services/hitl/gate_exec.py`
- [ ] Implement `gate_exec.spawn_venv_subprocess()` (subprocess + resource limits)
- [ ] Implement `gate_exec.spawn_docker_container()` (docker CLI + timeouts)
- [ ] Add `hitl_token` validation to HITL service (`services/hitl/hitl_service.py`)
- [ ] Add pre-execution audit logging to ClickHouse (I-24)
- [ ] Update agent passport template to include `autonomy_level` and `hitl_gate` fields
- [ ] Add unit tests for gate_exec (L1 direct, L2 VENV, L3 Docker, timeout, resource limits)
- [ ] Add integration test: A2A `ESCALATION` → HITL ACK → Docker spawn → result logged
- [ ] Document in `docs/AGENT-DEPLOYMENT.md` and `.claude/rules/80-ai-agents.md`

---

## References

- **ADR-128** Banking-agent HITL authority matrix (autonomy levels L1/L2/L3)
- **ADR-150** A2A Inter-Agent Message Contract (ESCALATION message type)
- **ADR-077** Autonomy levels (reference, if exists)
- **agent-authority.md** BANXE EMI Stack Agent Autonomy Matrix
- **I-27** (HITL — AI PROPOSES, human DECIDES)
- **I-24** (Append-only audit trails)
- **services/hitl/hitl_service.py** (HITL service implementation)
- **services/hitl/gate_exec.py** (gate-exec implementation — to be created)
