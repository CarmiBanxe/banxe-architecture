# AI Cost Policy — BANXE AI BANK
# Governance Artifact | ADR-045 §D7.2 | Status: ACCEPTED
# Minted: 2026-07-01 | Supersedes: none | Superseded by: —

## Purpose

This document defines the per-model, per-agent token-spend budgets, alerting tiers,
hard-stop thresholds, monthly caps, and cost-attribution schema governing all LLM API
calls across the BANXE estate.

**Scope:** every agent, MCP tool, and automated prompt that calls an LLM API
(Anthropic Claude, or any future provider added via ADR-040).

**Regulatory driver:** EU AI Act Art. 13 (transparency) and Art. 9 (risk-management)
require that AI systems used in credit, payment, and compliance workflows have
auditable resource controls. Unbounded LLM spend is a governance and operational risk.

---

## 1. Model Tier Registry

| Tier | Models | Unit cost (input) | Unit cost (output) | Use case |
|------|--------|------------------|--------------------|----------|
| T1 — Fast | claude-haiku-4-5 | low | low | Routing, classification, simple extraction |
| T2 — Standard | claude-sonnet-4-6 | medium | medium | Analysis, recon, reporting, KB query |
| T3 — Deep | claude-opus-4-8 | high | high | Complex compliance decisions, SAR drafting |
| T4 — Future | reserved | — | — | Reserved for ADR-047 cost-governance ADR |

Actual per-token prices are maintained out-of-band in `.env`
(`ANTHROPIC_HAIKU_INPUT_CPM`, `ANTHROPIC_SONNET_INPUT_CPM`, `ANTHROPIC_OPUS_INPUT_CPM`)
and read at runtime by `services/arl/cost_tracker.py`. No prices are hardcoded here.

---

## 2. Per-Agent Budget Table

| Agent | Tier | Max tokens / call | Max calls / day | Daily budget cap (USD) |
|-------|------|-------------------|-----------------|------------------------|
| Sanctions Check Agent | T1 | 2 000 | 50 000 | 5.00 |
| AML Check Agent | T2 | 4 000 | 10 000 | 20.00 |
| TM Agent | T1 | 1 500 | 100 000 | 7.50 |
| CDD Review Agent | T2 | 8 000 | 2 000 | 20.00 |
| Fraud Detection Agent | T1 | 2 000 | 50 000 | 5.00 |
| MLRO Coordinator | T3 | 16 000 | 200 | 15.00 |
| Reconciliation Agent | T2 | 6 000 | 500 | 5.00 |
| Reporting Agent (FIN060) | T2 | 12 000 | 50 | 5.00 |
| KB Query (kb_query MCP) | T2 | 4 000 | 5 000 | 20.00 |
| Intent Dispatcher | T1 | 1 000 | 200 000 | 5.00 |
| Experiment Copilot | T2 | 8 000 | 200 | 2.00 |
| Design Pipeline | T1 | 2 000 | 1 000 | 1.00 |
| **Estate daily total** | | | | **110.50** |

Budget table is a governance baseline; adjustments require a new IL entry and
CTIO sign-off. The table is read-only here — live limits are enforced in
`services/arl/cost_tracker.py` (see ADR-040 §5).

---

## 3. Monthly Hard Cap

| Level | Threshold (USD/month) | Action |
|-------|-----------------------|--------|
| INFO | 500 | Log to ClickHouse `ai_cost_events`; no action |
| WARN | 1 500 | Alert CTIO + Slack `#ai-ops`; 24 h review |
| ALERT | 2 500 | Freeze T3 (Opus) calls estate-wide; page on-call |
| HARD STOP | 3 300 | Suspend ALL LLM calls except MLRO SAR path; CEO notified |

**Hard-stop exemption:** the MLRO SAR-drafting path (L4 gate, POCA 2002 s.330)
is exempt from HARD STOP and may continue at T2 (Sonnet) only, rate-limited
to 10 calls/hour.

Monthly cap resets on the 1st of each calendar month UTC. The CFO may request
a one-time override (IL entry required, CTIO co-sign) for extraordinary periods
(e.g., regulatory submission month).

---

## 4. Alerting Tiers

### 4.1 Daily Burn Rate

```
daily_burn = sum(input_tokens * input_cpm + output_tokens * output_cpm)
             for all calls in current UTC day
```

| Burn vs daily budget | Action |
|----------------------|--------|
| < 80 % | No action |
| 80 – 100 % | WARN log to ClickHouse; Slack `#ai-ops` |
| > 100 % (overshoot) | Block further calls for that agent until next UTC day |

### 4.2 Per-Call Anomaly

A single call is anomalous if:

- Input tokens > 2× agent's `Max tokens / call` in the table above, OR
- Latency > 30 s (timeout threshold), OR
- Cost > $1.00 per single call (any tier)

Anomalous calls are logged to `ai_cost_events` with `severity = ANOMALY` and
trigger a Slack alert. The agent continues; the anomaly does not block execution.

### 4.3 Escalation Path

```
WARN  → Slack #ai-ops  (immediate)
ALERT → PagerDuty on-call (P2, 1-hour SLA)
HARD STOP → PagerDuty CEO + CTIO (P1, 15-min SLA)
```

---

## 5. Cost-Attribution Schema

Every LLM call **MUST** emit a `CostAttributionRecord` before the call completes.
Partial records (call failed) are still emitted with `outcome = FAILED`.

```
CostAttributionRecord {
  record_id          UUID         REQUIRED  -- unique per call
  agent_id           String       REQUIRED  -- matches agent-authority.md registry
  model_id           String       REQUIRED  -- e.g. "claude-sonnet-4-6"
  tier               Enum(T1..T4) REQUIRED
  called_at          DateTime(UTC) REQUIRED
  input_tokens       Int          REQUIRED
  output_tokens      Int          REQUIRED
  cost_usd           Decimal(10,6) REQUIRED  -- never float (I-01)
  correlation_id     UUID         REQUIRED  -- links to AgentDecisionRecord (IL-785)
  intent_id          UUID         NULLABLE  -- links to IntentDispatcher intent
  hitl_required      Boolean      REQUIRED
  outcome            Enum(SUCCESS, FAILED, TIMEOUT, BLOCKED) REQUIRED
  monthly_budget_pct Decimal(5,2) REQUIRED  -- % of monthly cap consumed at call time
  schema_version     String       REQUIRED  -- "cost-attribution-v1"
}
```

**I-01 invariant**: `cost_usd` is `Decimal(10,6)`, never `float`. Enforced by
Semgrep rule `banxe-float-money` and Pydantic validator in
`services/arl/cost_tracker.py`.

### 5.1 ClickHouse Storage (Primary)

```sql
CREATE TABLE ai_cost_events
(
    record_id          UUID,
    agent_id           String,
    model_id           LowCardinality(String),
    tier               LowCardinality(String),
    called_at          DateTime('UTC'),
    input_tokens       UInt32,
    output_tokens      UInt32,
    cost_usd           Decimal(10, 6),
    correlation_id     UUID,
    intent_id          Nullable(UUID),
    hitl_required      Bool,
    outcome            LowCardinality(String),
    monthly_budget_pct Decimal(5, 2),
    schema_version     LowCardinality(String)
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(called_at)
ORDER BY (called_at, agent_id, record_id)
TTL called_at + INTERVAL 5 YEAR;  -- I-08: minimum 5-year FCA retention
```

### 5.2 PostgreSQL Shadow (Aggregates Only)

```sql
CREATE TABLE ai_cost_monthly_summary (
    month          DATE          NOT NULL,  -- first day of month
    agent_id       TEXT          NOT NULL,
    model_id       TEXT          NOT NULL,
    total_calls    INTEGER       NOT NULL DEFAULT 0,
    total_input_tk BIGINT        NOT NULL DEFAULT 0,
    total_output_tk BIGINT       NOT NULL DEFAULT 0,
    total_cost_usd NUMERIC(12,6) NOT NULL DEFAULT 0,  -- never float (I-01)
    hard_stop_hit  BOOLEAN       NOT NULL DEFAULT FALSE,
    updated_at     TIMESTAMPTZ   NOT NULL DEFAULT now(),
    PRIMARY KEY (month, agent_id, model_id)
);
```

Aggregates are updated hourly by `services/arl/cost_aggregator.py`. Individual
call records live in ClickHouse only (append-only, I-24).

---

## 6. Hard-Stop Implementation Contract

When `monthly_budget_pct >= 100.0` (HARD STOP threshold reached):

1. `services/arl/cost_tracker.py` raises `HardStopError` before any LLM call.
2. All agents catch `HardStopError` and return `HITLProposal` (I-27: propose, never auto-apply).
3. The MLRO SAR path checks `agent_id == "mlro-coordinator"` and bypasses HARD STOP,
   using T2 (Sonnet) at 10 calls/hour.
4. `HardStopError` is logged to ClickHouse `ai_cost_events` with `outcome = BLOCKED`.
5. CEO and CTIO are notified via PagerDuty within 15 minutes (SLA P1).

Hard-stop state is stored in Redis (`banxe:ai:hard_stop = 1`) and checked
before every LLM call. Reset requires manual CTIO action (IL entry required).

---

## 7. Governance Controls

| Control | Owner | Frequency |
|---------|-------|-----------|
| Monthly cost review | CTIO | 1st business day of month |
| Budget table update | CTIO + Factory IL | On change |
| Hard-stop override | CEO + CTIO co-sign | As needed (IL required) |
| ClickHouse TTL audit | Platform | Quarterly |
| Cost anomaly report | ARL | Weekly to Slack `#ai-ops` |

---

## 8. Reserved Future ADRs

| ADR | Title | Status | Trigger |
|-----|-------|--------|---------|
| ADR-050 | AI Cost Governance — Implementation (DDL + ingestion + instrumentation) | PENDING | Factory sprint after this artifact |
| ADR-051 | AI Cost Governance — Multi-provider extension (non-Anthropic LLMs) | PENDING | When second LLM provider is onboarded |
| ADR-052 | AI Cost Governance — Real-time spend dashboard (Metabase/Superset) | PENDING | P1 milestone (Q2–Q3 2026) |

These ADRs are reserved in `docs/adr/INDEX.md`. Numbering is provisional;
`build_ledger.py` assigns the canonical IL when each ADR is promoted.

---

## 9. Invariant References

| Invariant | Rule | Enforcement |
|-----------|------|-------------|
| I-01 | `Decimal` for all cost values — never `float` | Semgrep `banxe-float-money` |
| I-08 | ClickHouse TTL ≥ 5 years | Semgrep `banxe-clickhouse-ttl-reduce` |
| I-24 | `ai_cost_events` is append-only — no UPDATE/DELETE | Semgrep `banxe-audit-delete` |
| I-27 | Hard-stop returns `HITLProposal` — never autonomous block without human notification | `services/hitl/hitl_service.py` |
| I-28 | Every LLM call emits a `CostAttributionRecord` before returning | `services/arl/cost_tracker.py` |

---

## 10. References

- Parent ADR: `docs/adr/ADR-045` (Intent-First Banking, §D7.2 this document closes)
- ARL routing: `docs/adr/ADR-040` (LLM orchestration substrate)
- Decision lineage: `governance/decision-lineage/README.md` (IL-785, `correlation_id` join)
- Agent authority: `.claude/rules/agent-authority.md`
- HITL service: BANXE EMI Stack `services/hitl/hitl_service.py`
- Cost tracker: BANXE EMI Stack `services/arl/cost_tracker.py` (implementation, PENDING ADR-050)
- ClickHouse DDL migration: BANXE EMI Stack `infra/clickhouse/migrations/` (PENDING ADR-050)
- FCA reference: PS22/9 Consumer Duty §4.3 (operational resilience), EU AI Act Art. 9/13
