# ADR-147: Lerian MCP Central Tool Registry & Binding Protocol

**Date:** 2026-06-28  
**Status:** PROPOSED  
**IL:** assigned at merge by build_ledger.py | ADR-143-A  
**Sprint:** Sprint-A, item A3 (Engine-Road-Map §2; depends on A1/A2)  
**Supersedes:** N/A (new protocol for agent-to-tool discovery and binding)

---

## Context

ADR-145 (A1) defined the A2A message contract for agent-to-agent communication. ADR-045 (amended in A2) 
established intent-first dispatcher architecture with deployment trigger in Sprint-B B2.

**Gap evidence (from SPRINT-PLAN.md §2 A3 + target-audit findings):**

- Agents currently hardcode tool calls (e.g., `from banxe_mcp.server import check_sanctions_tool`)
- No dynamic discovery mechanism for tools; no registry mapping `(agent_id, tool_id) → skill_endpoint`
- MCP binding is implicit, making it impossible to:
  - Audit which agent called which tool (I-24, I-28)
  - Validate autonomy level before tool execution (I-27)
  - Rotate tool endpoints without code redeploy
  - Multi-tenant or sandbox isolation of tool calls
- Lerian MCP (self-hosted MCP server in banxe-ai-infrastructure) needs a formal binding protocol
- COMPLIANCE-MATRIX S12-16 (Agent Tool Binding) is PENDING → DEPLOYED transition

**ROOT DEPENDENCY (ENGINE-ROADMAP):**

```
GAP-E4 (A2A contract, A1) ✅
  ↓
ADR-045 (Intent Dispatcher, A2) ✅ + ADR-147 (this: MCP Binding, A3)
  ↓
B2: Intent-Dispatcher Runtime Wiring
B3: Lerian MCP intent translator
B5: Redis Streams A2A bus
```

---

## Decision

Establish a **Central Tool Registry** schema and **Lerian MCP Binding Protocol**:

1. **Central Tool Registry:** a static mapping `(agent_id, tool_id) → ToolRegistryEntry`  
   stored in PostgreSQL or Redis; queried at agent startup.

2. **Lerian MCP binding protocol:** agents do not call tools directly; instead they route 
   requests through a central MCP client that looks up tool metadata, validates autonomy,  
   logs the call to ClickHouse (I-24), and returns the result.

3. **Discovery endpoint:** `GET /tools?agent_id=X` returns all tools that agent X is 
   authorized to call, with metadata (endpoint, autonomy_level, requires_hitl).

### Tool Registry Schema

```python
@dataclass(frozen=True)
class ToolRegistryEntry:
    """Central registry entry for agent-to-tool binding."""
    agent_id: str              # e.g., "mlro-agent", "recon-agent", "tx-monitor-agent"
    tool_id: str               # e.g., "check_sanctions", "get_balance", "query_kb"
    skill: str                 # MCP skill name from banxe_mcp/server.py
    endpoint: str              # Lerian MCP endpoint URL; e.g., "http://localhost:8765/mcp"
    autonomy_level: str        # L1 | L2 | L3 | L4 (from agent-authority.md)
    requires_hitl: bool        # if True, HITL gate must approve before tool call
    audit_enabled: bool = True # log to ClickHouse a2a_mcp_calls table (I-24)
    created_at: str            # ISO-8601 UTC
    created_by: str            # "system" | agent_id of provisioner
    version: int = 1           # registry entry version for auditability
```

**Examples:**

| agent_id | tool_id | skill | endpoint | autonomy_level | requires_hitl |
|----------|---------|-------|----------|---|---|
| mlro-agent | check_sanctions | get_sanctions_score | http://localhost:8765/mcp | L3 | True |
| mlro-agent | get_account_balance | get_balance | http://localhost:8765/mcp | L2 | False |
| recon-agent | query_reconciliation | run_recon | http://localhost:8765/mcp | L1 | False |
| fraud-agent | monitor_score | monitor_score_transaction | http://localhost:8765/mcp | L3 | True |

### Lerian MCP Binding Protocol

#### 1. **Agent Startup (Registry Hydration)**

When agent initializes, it calls the registry discovery endpoint once:

```http
GET /tools?agent_id=mlro-agent HTTP/1.1
Authorization: Bearer LITELLM_MASTER_KEY
```

Response:

```json
{
  "agent_id": "mlro-agent",
  "tools": [
    {
      "tool_id": "check_sanctions",
      "skill": "get_sanctions_score",
      "endpoint": "http://localhost:8765/mcp",
      "autonomy_level": "L3",
      "requires_hitl": true
    },
    {
      "tool_id": "get_account_balance",
      "skill": "get_balance",
      "endpoint": "http://localhost:8765/mcp",
      "autonomy_level": "L2",
      "requires_hitl": false
    }
  ]
}
```

Agent caches this locally (in-memory store or Redis, TTL 5 minutes).

#### 2. **Tool Call Flow**

When agent wants to call a tool:

```python
# OLD (hardcoded, rejected):
from banxe_mcp.server import check_sanctions_tool
result = await check_sanctions_tool(iban="GB...")

# NEW (via MCP binding protocol):
tool_call = MCPToolCall(
    agent_id="mlro-agent",
    tool_id="check_sanctions",
    params={"iban": "GB..."},
    correlation_id=context.correlation_id,
    audit_trail_ref=context.audit_event_id,
)

result = await mcp_client.call(tool_call)
# → MCP client looks up tool_id in registry
# → validates agent autonomy_level vs tool autonomy_level
# → checks requires_hitl flag; if True, gates on I-27 HITL service
# → logs call to ClickHouse a2a_mcp_calls table (I-24)
# → executes call via Lerian MCP endpoint
# → returns result
```

#### 3. **Audit Trail (I-24)**

Every tool call logged to ClickHouse table `a2a_mcp_calls`:

```sql
CREATE TABLE a2a_mcp_calls (
    event_id UUID DEFAULT generateUUIDv4(),
    timestamp DateTime DEFAULT now(),
    agent_id String,
    tool_id String,
    correlation_id String,
    audit_trail_ref UUID,
    autonomy_level Enum8('L1' = 1, 'L2' = 2, 'L3' = 3, 'L4' = 4),
    hitl_required UInt8,
    hitl_approved UInt8,
    hitl_approver_id String,
    call_status Enum8('PENDING' = 1, 'APPROVED' = 2, 'REJECTED' = 3, 'EXECUTED' = 4, 'FAILED' = 5),
    result_summary String,
    execution_time_ms Float32,
    error_message String
) ENGINE = MergeTree()
ORDER BY (timestamp, agent_id, tool_id)
TTL timestamp + INTERVAL 5 YEAR;
```

### Authentication & Authorization

- **Auth:** Lerian MCP endpoint protected by `LITELLM_MASTER_KEY` environment variable (same secret used in banxe-ai-infrastructure).
- **Virtual agent tokens:** for sandbox/test agents, use virtual keys in format `AGENT_<agent_id>_<sandbox_id>` (generated by CI/CD for automated tests).
- **No direct CLI access:** production Lerian MCP endpoints not exposed; only agents with valid `agent_id` can call tools.

### Discovery Endpoint (Banxe-side Service)

New internal API endpoint in banxe-architecture (or banxe-emi-stack):

```http
GET /api/v1/tools?agent_id=<agent_id>
Authorization: Bearer <JWT or service token>

Response: ToolRegistryEntry[] (JSON)
```

Backed by:
- **Dev/Test:** in-memory map (for unit tests)
- **Production:** PostgreSQL table `central_tool_registry` with read-only replica in Redis

### Deployment Target

- **Lerian MCP server:** `banxe-ai-infrastructure/services/lerian-mcp/`
- **Registry service:** `banxe-architecture/services/registry/` (new micro-service) or 
  embedded in existing banxe-emi-stack API
- **Database:** PostgreSQL 17 table + Redis Streams cache layer

---

## Consequences

### Positive

1. **Auditability (I-24):** Every agent-to-tool call is logged with correlation_id, audit_trail_ref, 
   and HITL gate status.
2. **Autonomy enforcement (I-27):** Tool calls validate autonomy_level before execution; 
   L3+ calls blocked pending HITL approval.
3. **No hardcoded imports:** Semgrep rule `banxe-a2a-direct-import` can now enforce 
   `NEVER import from banxe_mcp.server; MUST use mcp_client.call()`.
4. **Runtime flexibility:** tool endpoints (especially Lerian MCP URL) can change without code redeploy.
5. **Multi-tenant support:** sandbox agents can be isolated by agent_id; same Lerian MCP server 
   can serve multiple tenants.
6. **COMPLIANCE-MATRIX S12-16:** Agent Tool Binding status transitions from PENDING → DEPLOYED 
   after B3 (Lerian MCP intent translator) lands.

### Negative

1. **Latency overhead:** registry lookups + HITL gate checks add ~50–100ms per tool call 
   (acceptable for compliance workloads; not for sub-second trading).
2. **New dependency:** Lerian MCP server must be operational; failure → all agents unable to call tools 
   (mitigation: fallback to cached registry; circuit-breaker pattern).
3. **Schema evolution:** adding new tool metadata fields requires migration of all `ToolRegistryEntry` 
   instances (managed by build/deployment pipeline).

### Risks Mitigated

- **Rogue agent calls:** agent cannot call unauthorized tools (registry validates).
- **Unaudited tool calls:** every call in ClickHouse (I-24 append-only).
- **Autonomous HITL violations:** L3+ calls blocked at MCP client layer (I-27 enforced in code).
- **Hardcoded tool binding:** static analysis finds direct imports via Semgrep rule.

---

## Alternatives Considered

### 1. Hardcoded Tool Map (Rejected)

```python
TOOL_MAP = {
    "mlro-agent": ["check_sanctions", "get_account_balance"],
    "recon-agent": ["run_recon", "query_reconciliation"],
}
```

**Why rejected:**
- Not scalable (70+ agents × 150+ tools = 10,000+ entries in code).
- No runtime flexibility (endpoint changes require code redeploy).
- No audit trail linkage (I-24, I-28).
- Breaks multi-tenant isolation.

### 2. OpenAI Function-Calling Spec (Rejected)

Use OpenAI's native function-calling schema for MCP endpoints.

**Why rejected:**
- Not self-hosted compliant (our constraint: NEVER SaaS without self-hosted alt).
- Adds OpenAI SDK dependency; breaks polyglot agent support.
- No HITL gate integration (I-27).
- No explicit autonomy_level validation.

### 3. Kubernetes Service Discovery (Rejected)

Use k8s DNS + service mesh (Istio) for dynamic tool discovery.

**Why rejected:**
- Lerian MCP is single-endpoint; no need for mesh.
- Not all deployment targets use k8s (evo1 may be Docker Compose).
- Adds operational complexity (Istio, mTLS, ingress rules).

### 4. Temporal Activity Registry (Deferred to B1)

Temporal's activity discovery mechanism.

**Why deferred:**
- Temporal is Sprint-B runtime (ADR-060 §6).
- A2A bus must work **before** Temporal activation.
- MCP binding protocol is Temporal-agnostic; can co-exist.

---

## COMPLIANCE-MATRIX Update Path

**Current status (pre-A3):** S12-16 (Agent Tool Binding) = PENDING

| Category | Item | Current | After B3 | Evidence |
|----------|------|---------|----------|----------|
| S12 | Agent Autonomy Enforcement | PENDING | DEPLOYED | HITL gate + autonomy_level validation in MCP client |
| S13 | Audit Trail Completeness | PENDING | DEPLOYED | ClickHouse a2a_mcp_calls table (I-24, TTL 5yr) |
| S14 | Tool Endpoint Isolation | PENDING | DEPLOYED | Lerian MCP auth + virtual agent tokens |
| S15 | Registry Versioning | PENDING | DEPLOYED | version field in ToolRegistryEntry |
| S16 | Semgrep Enforcement | PENDING | DEPLOYED | `banxe-a2a-direct-import` rule deployed |

**Transition:** After B3 (Lerian MCP intent translator) lands and integrates with A2A bus (Redis Streams), 
S12-16 status updates to DEPLOYED.

---

## Implementation Checklist (Sprint-A A3)

- [ ] Write this ADR (ADR-147)
- [ ] Define `ToolRegistryEntry` dataclass (banxe-architecture/services/registry/models.py)
- [ ] Implement `GET /tools?agent_id=X` endpoint (new micro-service or embed in banxe-emi-stack)
- [ ] Create PostgreSQL table `central_tool_registry` (Alembic migration)
- [ ] Write seed SQL: populate registry with current 34 MCP tools × agent bindings
- [ ] Update `.semgrep/banxe-rules.yml`: add `banxe-a2a-direct-import` rule
- [ ] Create ClickHouse migration: `a2a_mcp_calls` table (TTL 5 years)
- [ ] Update COMPLIANCE-MATRIX.md: S12-16 status, Sprint-B B3 trigger

**Note:** Lerian MCP implementation deferred to B3; A3 prepares spec + database schema + Semgrep rule.

---

## References

- **ADR-045:** Intent-first banking architecture (amended in A2)
- **ADR-145:** A2A inter-agent message contract (A1)
- **ADR-060:** Temporal saga runtime (Sprint-B roadmap)
- **SPRINT-PLAN.md:** §2 Sprint-A items A1–A5
- **agent-authority.md:** Autonomy levels L1–L4
- **COMPLIANCE-MATRIX.md:** S12-16 Agent Tool Binding
- **security-policy.md:** banxe-hardcoded-secret, banxe-a2a-direct-import rules
- **I-24:** Append-only audit trails (INSTRUCTION-LEDGER.md)
- **I-27:** HITL feedback supervised (agent-authority.md)
- **Lerian MCP deployment:** banxe-ai-infrastructure (Sprint-B B3)
