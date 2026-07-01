---
il_anchor: IL-122-INTENT-FIRST-CANON-2026-06-07
source_adr: ADR-045
extracted_from: "docs/adr/ADR-045-intent-first-banking-architecture.md §Deployment & Activation"
extraction_il: IL-777
---

# Runbook: Intent-Dispatcher Deployment & Activation

> **Source:** Extracted verbatim from ADR-045 §"Deployment & Activation" (IL-777).
> ADR-045 is CONCEPT ONLY; this runbook holds all operational activation details.
> Do NOT add operational specs back into ADR-045.

## Deployment Schedule

The Intent-First architecture is activated incrementally through Sprint-B. The
intent-dispatcher runtime (L1 conversational interface layer) is wired and deployed
in **Sprint-B item B2: Intent-Dispatcher Runtime Wiring**.

## Entry Point & Runtime Configuration

**Location:** `banxe-ai-infrastructure` repo, evo1 target host  
**Config file:** `planner.yaml` (intent routing schema and dispatcher endpoint configuration)

### Intent Routing Schema (`planner.yaml`)

```yaml
# banxe-ai-infrastructure/config/planner.yaml
intent_routing:
  passport_update:
    spec_ref: "banxe-architecture/docs/passport/intent-passport-identity-passport-update.md"
    dispatcher_endpoint: "/v1/intent/execute"
    executor_autonomy: L2
    compliance_gate: L3_GOVERNANCE
    result_type: "DECISION_LINEAGE_RECORD"
  payment_submit:
    spec_ref: "banxe-architecture/docs/passport/intent-passport-financial-payment-submit.md"
    dispatcher_endpoint: "/v1/intent/execute"
    executor_autonomy: L2
    compliance_gate: L3_GOVERNANCE
    result_type: "DECISION_LINEAGE_RECORD"
```

### Dispatcher Runtime Dependencies

| Dependency | Service | Port | Purpose |
|-----------|---------|------|---------|
| Redis Streams | `redis-a2a` | 6379 | A2A (Agent-to-Agent) bus (Sprint-B item B5) |
| Lerian MCP | `lerian-mcp` | 5555 | Intent-to-action translation (Sprint-B item B3) |
| PostgreSQL | `postgres` | 5432 | Decision Lineage Schema storage (future ADR) |
| ClickHouse | `clickhouse` | 9000 | Audit trail + compliance event log |

### Deployment Trigger

The intent-dispatcher enters **production beta** when **Sprint-B item B2** merges
to main in `banxe-ai-infrastructure`. This unblocks:

- Intent passports (identity, payment, compliance domains) → active routing
- L2 agent execution against intent intents (via Lerian MCP B3)
- L3 governance gates interception (HITL feedback loop)
- Decision Lineage recording (append-only ClickHouse, future ADR)

## Backward Compatibility

The Intent-First dispatcher launches **alongside** the existing GUI/REST API;
no existing REST/banking-screen clients are disrupted. The dispatcher is a new
L1 entry point that co-exists with the current banking app entry point until
migration to Intent-First is complete (Q3 2026 target).
