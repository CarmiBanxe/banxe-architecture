# ADR-145: A2A Inter-Agent Message Contract

**Date:** 2026-06-28
**Status:** PROPOSED
**IL:** assigned at merge by build_ledger.py | ADR-143-A
**Sprint:** Sprint-A, item A1 (ENGINE-ROADMAP §2; GAP-E4 root dependency)
**Supersedes:** N/A (first A2A contract ADR — NOVELTY per DEDUP-FINDINGS §NOVELTY)

---

## Context

The BANXE swarm defines 70+ agent passports (Sprint-2 GAP-077 complete; Sprint-3
service code pending via GAP-078). Multi-agent orchestration chains currently rely on
hardcoded service imports — for example, the MLRO→AML→Sanctions chain calls agents
via direct Python module references rather than a formal messaging contract.

**Gap evidence (from target-audit PR #842 §4.4 + DEDUP-FINDINGS §NOVELTY):**
- No ADR found for A2A message schema; no passport formalises inter-agent communication
- Agents do not have a common envelope for correlation, traceability, or HITL escalation
- Multi-agent scenarios cannot emit a unified audit trail per I-24 without a shared
  correlation_id propagated across agent hops
- GAP severity: HIGH — no documented protocol for agents calling agents

**ENGINE-ROADMAP position:**
GAP-E4 (this ADR) is the root dependency for the full engine chain:
```
GAP-E4 (A2A ADR — this) → GAP-E1 (dispatcher) → GAP-E2 (MCP binding)
                                                  → GAP-E5 (sandbox contract)
```

---

## Decision

Define a formal A2A message envelope for all inter-agent communication in the BANXE
swarm. Transport candidate: `fabric/common/bus-redis-streams.py` (already deployed).
No new frameworks; no new infrastructure.

### Message Envelope Schema

```python
@dataclass(frozen=True)
class A2AMessage:
    msg_id: str                   # UUID v4 — unique per message
    source_agent_id: str          # passport agent_id of sender
    target_agent_id: str          # passport agent_id of receiver
    message_type: str             # REQUEST | RESPONSE | EVENT | ESCALATION
    correlation_id: str           # propagated from originating user/flow request
    audit_trail_ref: str          # ClickHouse event_id for I-24 linkage
    payload: dict                 # message body (schema per message_type)
    timestamp_utc: str            # ISO-8601 UTC; never local tz
    ttl_seconds: int = 300        # message TTL; 0 = no expiry
    hitl_gate: str | None = None  # non-None if HITL approval required (I-27)
```

### Message Types

| Type | Meaning | HITL gate |
|------|---------|-----------|
| `REQUEST` | Agent requests action from another agent | No (unless L3+) |
| `RESPONSE` | Response to a prior REQUEST (same correlation_id) | No |
| `EVENT` | Fire-and-forget notification (no reply expected) | No |
| `ESCALATION` | Agent proposes action above its autonomy level | Yes (I-27) |

### Transport

- **Development / L2-SANDBOX:** `InMemoryA2ABus` — synchronous dict-based bus;
  no Redis required; deterministic for unit tests.
- **Production / L3:** `RedisStreamsA2ABus` wrapping `bus-redis-streams.py`;
  each stream key = `banxe:a2a:<target_agent_id>`.

**No new broker.** RabbitMQ, Kafka, gRPC excluded — not in current stack. Temporal
saga is Sprint-B runtime (ADR-060 §6, ADR-133); A2A bus is NOT Temporal.

### Audit Requirement (I-24)

Every A2A message MUST be logged to ClickHouse `a2a_events` table before delivery:

```
a2a_events (
    msg_id UUID,
    source_agent_id String,
    target_agent_id String,
    message_type String,
    correlation_id String,
    audit_trail_ref String,
    timestamp_utc DateTime,
    hitl_gate Nullable(String),
    payload_hash String        -- SHA-256 of payload; never raw payload in audit table
)
TTL timestamp_utc + INTERVAL 5 YEAR   -- I-08: 5yr minimum
```

Payload hash only — never raw payload in ClickHouse (PII risk). Raw payload stays in
Redis stream TTL'd per `ttl_seconds`.

### HITL Invariant (I-27)

`ESCALATION` messages are proposals only. The receiving HITL gate (per agent-authority.md)
must approve before any action is taken. Agents NEVER auto-apply ESCALATION responses.

### Hardcoded Import Ban

After ADR-145 is ACCEPTED, new agent code MUST NOT import other agents directly:

```python
# BANNED after ADR-145
from services.aml.aml_agent import AMLAgent
aml = AMLAgent()
result = await aml.screen(payload)

# REQUIRED after ADR-145
from services.a2a.bus import a2a_bus
await a2a_bus.send(A2AMessage(
    source_agent_id="mlro_agent",
    target_agent_id="aml_orchestrator",
    message_type="REQUEST",
    correlation_id=ctx.correlation_id,
    ...
))
```

Semgrep rule `banxe-a2a-direct-import` to be added in Sprint-B (enforcement).

---

## Alternatives Considered

| Option | Reason rejected |
|--------|----------------|
| RabbitMQ | Not in BANXE production stack; new infra = Sprint-B scope |
| gRPC | Not available; requires significant infra; not Python-async native |
| n8n workflows | Step orchestration, not A2A messaging; different abstraction level |
| Direct HTTP service calls | Current state; breaks I-24 (no correlation_id envelope); rejected |
| Hardcoded imports | Current state; couples agent implementations; rejected |

---

## Consequences

**Positive:**
- Decouples agent implementations — agents only know each other by `agent_id`
- Enables unified I-24 audit trail across multi-agent hops via `correlation_id`
- `InMemoryA2ABus` enables L2-SANDBOX testing of multi-agent flows without Redis
- ESCALATION type formalises I-27 HITL gate in messaging layer

**Negative:**
- Existing agent chains (MLRO→AML→Sanctions) require migration to A2A bus
- Sprint-B migration effort: 3 agent chains estimated (scoped in ENGINE-ROADMAP §2)

**Invariants:**
- I-24: audit log BEFORE delivery (not after)
- I-27: ESCALATION = propose only; no auto-apply
- I-08: ClickHouse TTL ≥ 5 years on `a2a_events`

---

## Implementation Path (Sprint-A → Sprint-B)

**Sprint-A (banxe-architecture — this ADR):**
- [ ] ADR-145 accepted (CTIO sign-off)
- [ ] `A2AMessage` dataclass spec finalised
- [ ] `InMemoryA2ABus` Protocol + stub spec documented
- [ ] `a2a_events` ClickHouse schema spec added

**Sprint-B (banxe-ai-infrastructure):**
- [ ] `InMemoryA2ABus` implementation + unit tests (≥80% coverage)
- [ ] `RedisStreamsA2ABus` wrapping `bus-redis-streams.py`
- [ ] ClickHouse `a2a_events` table migration
- [ ] MLRO→AML→Sanctions chain migrated to A2A bus
- [ ] Semgrep rule `banxe-a2a-direct-import` added
- [ ] ADR-144 orphan-check: 0

---

## References

- GAP-E4 evidence: target-audit PR #842 §4.4; DEDUP-FINDINGS.md §NOVELTY
- ENGINE-ROADMAP §1 EPIC-E4 (PR #857)
- ENGINE-ROADMAP-INPUTS §1 GAP-E4 (PR #856, IL-665)
- Transport reuse: `fabric/common/bus-redis-streams.py` (DEPLOYED)
- HITL: agent-authority.md; ADR-077; `services/hitl/hitl_service.py`
- Audit: I-24 (append-only); I-08 (5yr TTL); I-27 (HITL)
- Depends-on: none (root ADR)
- Enables: ADR-045 amendment (GAP-E1), Lerian MCP spec (GAP-E2), sandbox ADR (GAP-E5)
