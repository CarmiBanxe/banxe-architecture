# Business Process Repository — S13-00
# ADR-045 §D7.3 | Version: 1.0.0 | Status: ACCEPTED
# Governance artifact — schema and policy only. No runtime code in this cycle.

## 1. Purpose

This document is the binding specification for the **Business Process Repository (BPR)**,
closing ADR-045 §D7 gap-3 (S13-00). It defines the catalog schema, process ID scheme,
versioning policy, dependency model, SLA framework, and compliance-tagging rules that
govern all business processes in the estate.

The BPR is the authoritative, machine-readable registry of every consequential operational
and compliance process: who owns it, what triggers it, what it consumes and produces, which
systems execute it, what its SLA obligation is, and which regulatory controls it satisfies.

**Scope:** all processes that touch financial data, customer lifecycle, compliance obligations,
or audit trails. Processes that are purely infrastructure (CI/CD, deployment pipelines)
are out of scope unless they carry a compliance obligation.

**Related governance artifacts:**
- IL-785 — Decision Lineage schema (`AgentDecisionRecord`) — processes link decisions here.
- IL-789 — AI Cost Policy — agent-executed processes emit `CostAttributionRecord`.
- ADR-045 — parent decision record for the three §D7 governance gaps.

---

## 2. Process ID Scheme

Every process is assigned a permanent, opaque **Process ID** on first registration.

```
BPR-{DOMAIN}-{NNNN}
```

| Segment | Values | Example |
|---------|--------|---------|
| `BPR` | literal prefix | `BPR` |
| `DOMAIN` | three-letter domain code (see §3) | `SAF`, `AML`, `PAY`, `KYC`, `RPT`, `OPS`, `IAM` |
| `NNNN` | zero-padded 4-digit integer, sequential within domain | `0001` |

Full example: `BPR-SAF-0001` = first registered safeguarding process.

**IDs are immutable.** A process may be deprecated but its ID is never reused.
Replacement processes receive a new ID; the deprecated entry carries `superseded_by`.

### Domain Codes

| Code | Domain |
|------|--------|
| `SAF` | Safeguarding (CASS 15) |
| `AML` | Anti-Money Laundering / CTF |
| `KYC` | Know-Your-Customer / CDD |
| `PAY` | Payment processing and settlement |
| `RPT` | Regulatory reporting (FIN060, RegData) |
| `OPS` | Operational / back-office |
| `IAM` | Identity and access management |
| `FRD` | Fraud detection and case management |
| `CST` | Consumer Duty and complaints |
| `REC` | Reconciliation |

---

## 3. Process Catalog Schema

Each entry in the catalog is a structured record with the following fields.

### 3.1 Identity

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `process_id` | String (`BPR-{DOMAIN}-{NNNN}`) | YES | Permanent, immutable identifier |
| `name` | String (≤ 80 chars) | YES | Human-readable process name |
| `domain` | Enum (§2 domain codes) | YES | Business domain |
| `version` | SemVer string | YES | Schema version of this record (not the process) |
| `status` | Enum | YES | `ACTIVE` / `DEPRECATED` / `DRAFT` |
| `superseded_by` | String (process_id) | if DEPRECATED | ID of the replacement process |

### 3.2 Ownership

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `owner_role` | String | YES | Job title or role (e.g., `MLRO`, `CFO`, `Compliance Officer`) |
| `owner_team` | String | YES | Organisational unit (e.g., `Compliance`, `Payments`, `Finance`) |
| `escalation_path` | String[] | YES | Ordered list of roles to escalate to on SLA breach |
| `review_frequency` | Enum | YES | `MONTHLY` / `QUARTERLY` / `ANNUALLY` / `AD_HOC` |
| `next_review_due` | Date (ISO 8601) | YES | Wall-clock deadline for next scheduled review |

### 3.3 Trigger

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `trigger_type` | Enum | YES | `SCHEDULED` / `EVENT` / `MANUAL` / `THRESHOLD` |
| `trigger_spec` | String | YES | Human-readable trigger description (e.g., `"daily at 23:00 UTC"`, `"on PAYMENT_SUBMITTED event"`) |
| `trigger_source` | String | if EVENT | System or topic that emits the trigger event |
| `idempotency_key` | Boolean | YES | Whether the process enforces idempotency on re-trigger |

### 3.4 Inputs and Outputs

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `inputs` | Input[] | YES | List of input artifacts consumed by the process |
| `outputs` | Output[] | YES | List of output artifacts produced by the process |

**Input schema:**

| Sub-field | Type | Description |
|-----------|------|-------------|
| `name` | String | Short label (e.g., `"ledger_snapshot"`) |
| `source_system` | String | System that produces this input |
| `format` | String | Data format (e.g., `"CAMT.053"`, `"JSON"`, `"Parquet"`) |
| `required` | Boolean | Whether the process can proceed without this input |

**Output schema:**

| Sub-field | Type | Description |
|-----------|------|-------------|
| `name` | String | Short label (e.g., `"reconciliation_report"`) |
| `destination_system` | String | System that consumes this output |
| `format` | String | Data format |
| `retention_years` | Integer | Minimum retention period (must be ≥ 5 for audit outputs — I-08) |

### 3.5 Systems Involved

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `systems` | String[] | YES | Canonical system names from the system registry |
| `primary_db` | String | YES | Database that holds the process's primary state |
| `audit_sink` | String | YES | Where audit events are written (`"clickhouse"` / `"pgaudit"` / `"both"`) |

### 3.6 SLA

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `sla_target_seconds` | Integer | YES | Maximum allowable execution duration (seconds) |
| `sla_breach_action` | String | YES | Action triggered on breach (e.g., `"alert:MLRO"`, `"halt:downstream"`) |
| `sla_measurement_start` | String | YES | When the SLA clock starts (e.g., `"trigger_received"`) |
| `sla_measurement_end` | String | YES | When the SLA clock stops (e.g., `"output_committed"`) |

### 3.7 Dependencies

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `upstream_processes` | String[] | YES | Process IDs that must complete before this process starts |
| `downstream_processes` | String[] | YES | Process IDs that depend on this process's output |
| `blocking` | Boolean | YES | Whether upstream failure halts this process |

### 3.8 Risk and Compliance Tags

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `regulatory_refs` | String[] | YES | FCA/PRA/statutory references (e.g., `"FCA CASS 15.4"`, `"MLR 2017 s.19"`) |
| `risk_level` | Enum | YES | `LOW` / `MEDIUM` / `HIGH` / `CRITICAL` |
| `hitl_required` | Boolean | YES | Whether a human must approve process output (I-27) |
| `hitl_role` | String | if hitl_required | Role authorised to approve (e.g., `"MLRO"`, `"CFO"`) |
| `audit_trail` | Boolean | YES | Whether the process emits an append-only audit record (I-24) |
| `pii_in_scope` | Boolean | YES | Whether personally identifiable information is processed |
| `sanctions_check` | Boolean | YES | Whether the process performs a sanctions screening step |
| `ai_agent_executed` | Boolean | YES | Whether an AI agent executes any step |
| `ai_autonomy_level` | Enum | if ai_agent_executed | `L1` / `L2` / `L3` / `L4` (see agent-authority.md) |

### 3.9 Versioning

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `record_version` | SemVer | YES | Version of this catalog record (not the process code) |
| `effective_date` | Date | YES | Date from which this record version is binding |
| `changelog` | Changelog[] | YES | Ordered list of record changes |

**Changelog entry schema:**

| Sub-field | Type | Description |
|-----------|------|-------------|
| `version` | SemVer | Record version this entry describes |
| `date` | Date | Date of change |
| `author_role` | String | Role of person who made the change |
| `summary` | String | ≤ 200-char description of what changed and why |

---

## 4. Process Catalog — Governance Controls

The BPR is itself a governed artifact. The following controls apply to the catalog.

### 4.1 Registration

A process MUST be registered in the BPR before it is deployed to production. Registration
requires all `REQUIRED` fields populated. Draft processes may omit `effective_date`.

### 4.2 Change Control

Any change to a registered process record requires:
1. A new `record_version` (SemVer increment).
2. A `changelog` entry authored by the owning role.
3. HITL approval if `risk_level` is `HIGH` or `CRITICAL`, or if `hitl_required` is `true`.
4. An IL entry (ledger shard) recording the change and its rationale.

Changes to `process_id`, `domain`, or `owner_role` are **major** changes (major SemVer bump).
All other changes are **minor** or **patch**.

### 4.3 Deprecation

Deprecating a process requires:
- Setting `status: DEPRECATED`.
- Populating `superseded_by` with the replacement process ID (or `"NONE"` if no replacement).
- HITL approval from `owner_role`.
- Notification to all downstream process owners listed in `downstream_processes`.

### 4.4 Retention

Process catalog records are append-only (I-24). Deprecated records are retained indefinitely.
The physical store (see §5) must enforce TTL ≥ 5 years on all change-event rows (I-08).

---

## 5. Storage Schema

### 5.1 PostgreSQL — Process Registry (source of truth)

```sql
CREATE TABLE process_catalog (
    process_id          TEXT            NOT NULL,
    name                TEXT            NOT NULL,
    domain              TEXT            NOT NULL,
    status              TEXT            NOT NULL DEFAULT 'DRAFT',
    superseded_by       TEXT,
    owner_role          TEXT            NOT NULL,
    owner_team          TEXT            NOT NULL,
    escalation_path     TEXT[]          NOT NULL DEFAULT '{}',
    review_frequency    TEXT            NOT NULL,
    next_review_due     DATE            NOT NULL,
    trigger_type        TEXT            NOT NULL,
    trigger_spec        TEXT            NOT NULL,
    trigger_source      TEXT,
    idempotency_key     BOOLEAN         NOT NULL DEFAULT TRUE,
    systems             TEXT[]          NOT NULL DEFAULT '{}',
    primary_db          TEXT            NOT NULL,
    audit_sink          TEXT            NOT NULL,
    sla_target_seconds  INTEGER         NOT NULL,
    sla_breach_action   TEXT            NOT NULL,
    regulatory_refs     TEXT[]          NOT NULL DEFAULT '{}',
    risk_level          TEXT            NOT NULL,
    hitl_required       BOOLEAN         NOT NULL DEFAULT FALSE,
    hitl_role           TEXT,
    audit_trail         BOOLEAN         NOT NULL DEFAULT TRUE,
    pii_in_scope        BOOLEAN         NOT NULL DEFAULT FALSE,
    sanctions_check     BOOLEAN         NOT NULL DEFAULT FALSE,
    ai_agent_executed   BOOLEAN         NOT NULL DEFAULT FALSE,
    ai_autonomy_level   TEXT,
    record_version      TEXT            NOT NULL,
    effective_date      DATE,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT now(),
    PRIMARY KEY (process_id, record_version)
);

-- Append-only constraint: never DELETE or UPDATE rows (I-24).
-- Physical deletion requires MLRO + CEO sign-off and IL entry.

CREATE TABLE process_changelog (
    id              BIGSERIAL       PRIMARY KEY,
    process_id      TEXT            NOT NULL,
    record_version  TEXT            NOT NULL,
    change_date     DATE            NOT NULL,
    author_role     TEXT            NOT NULL,
    summary         TEXT            NOT NULL,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT now(),
    FOREIGN KEY (process_id, record_version)
        REFERENCES process_catalog (process_id, record_version)
);

CREATE TABLE process_io (
    id              BIGSERIAL       PRIMARY KEY,
    process_id      TEXT            NOT NULL,
    record_version  TEXT            NOT NULL,
    direction       TEXT            NOT NULL CHECK (direction IN ('INPUT','OUTPUT')),
    name            TEXT            NOT NULL,
    counterpart     TEXT            NOT NULL,  -- source_system or destination_system
    format          TEXT            NOT NULL,
    required        BOOLEAN,                   -- null for outputs
    retention_years INTEGER,                   -- null for inputs
    FOREIGN KEY (process_id, record_version)
        REFERENCES process_catalog (process_id, record_version)
);
```

### 5.2 ClickHouse — Process Change Events (audit trail)

```sql
CREATE TABLE process_change_events (
    event_id        UUID,
    process_id      TEXT,
    from_version    LowCardinality(String),
    to_version      LowCardinality(String),
    changed_at      DateTime('UTC'),
    author_role     LowCardinality(String),
    change_type     LowCardinality(String),   -- REGISTER / UPDATE / DEPRECATE
    summary         String,
    approved_by     LowCardinality(String),
    correlation_id  UUID                       -- joins to AgentDecisionRecord (IL-785)
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(changed_at)
ORDER BY (changed_at, process_id, event_id)
TTL changed_at + INTERVAL 5 YEAR;            -- I-08
```

---

## 6. Dependency Graph

The BPR dependency model is a **directed acyclic graph (DAG)** where nodes are processes
and edges are `upstream → downstream` dependencies.

Rules:
1. A process may not list itself as upstream or downstream (no self-loops).
2. Circular dependencies are forbidden and must be detected at registration time.
3. `blocking: true` edges mean the downstream process halts if the upstream process
   fails or breaches SLA.
4. The dependency graph must be re-validated whenever `upstream_processes` or
   `downstream_processes` is modified.

Tools for validation are reserved for ADR-053 (see §9).

---

## 7. SLA Framework

### 7.1 SLA Classes

| Class | `sla_target_seconds` | Typical use |
|-------|---------------------|-------------|
| REALTIME | ≤ 2 | Fraud scoring, sanctions check |
| NEAR_REALTIME | ≤ 30 | Payment authorisation |
| OPERATIONAL | ≤ 300 | Reconciliation matching |
| BATCH | ≤ 86400 | Daily safeguarding recon, FIN060 generation |
| PERIODIC | > 86400 | Monthly regulatory submissions |

### 7.2 Breach Actions

On SLA breach, `sla_breach_action` determines the automated response:

| Action string | Effect |
|---------------|--------|
| `alert:{role}` | Send alert to named role via notification channel |
| `halt:downstream` | Suspend all blocking downstream processes |
| `hitl:{role}` | Open a HITL gate for the named role to decide |
| `escalate:{role}` | Escalate to named role after primary owner unresponsive |

Breach events are written to `process_change_events` with `change_type = BREACH` and
to the operational runbook at `docs/runbooks/process-sla-breach.md`.

---

## 8. AI Agent Integration

Processes where `ai_agent_executed: true` are subject to additional constraints:

1. **Autonomy ceiling**: `ai_autonomy_level` must match or be lower than the agent's
   registered autonomy level in `agent-authority.md`.
2. **Cost attribution**: every AI-executed step emits a `CostAttributionRecord` (IL-789).
3. **Decision lineage**: every consequential L2+ decision in an AI-executed step emits
   an `AgentDecisionRecord` (IL-785), with `correlation_id` linking the two.
4. **HITL gate**: if `hitl_required: true`, the agent returns an `HITLProposal` — it never
   auto-applies the output (I-27).
5. **Audit**: the process's `audit_sink` must receive the AI agent's execution trace.

---

## 9. Reserved Future ADRs

The following ADRs are reserved for implementation work that depends on this specification:

| ADR | Title | Scope |
|-----|-------|-------|
| ADR-053 | BPR Runtime — Registration API and DAG Validator | FastAPI service exposing `/v1/process-catalog`, cycle-detection on dependency graph, migration DDL, migration spec |
| ADR-054 | BPR Integration — Process-to-Decision and Process-to-Cost Links | Runtime wiring of `correlation_id` between `process_change_events`, `agent_decision_records` (IL-785), and `ai_cost_events` (IL-789) |
| ADR-055 | BPR Compliance Dashboard — Process Health and SLA Monitoring | Metabase / Superset views over the process catalog; SLA breach alerting pipeline; regulatory-tag coverage reports |

These ADRs are **not implemented in this cycle**. This document is schema and policy only.

---

## 10. Invariants Upheld

| Invariant | How this artifact upholds it |
|-----------|------------------------------|
| I-01 | No monetary amounts in process schema — not applicable; I-01 deferred to ADR-053 for cost fields in process records |
| I-08 | `process_change_events` ClickHouse TTL 5 YEAR minimum |
| I-24 | `process_catalog` and `process_changelog` are append-only; no DELETE/UPDATE |
| I-27 | AI-executed processes return `HITLProposal`, never auto-apply (§8) |
| I-28 | Every AI-executed process step emits an execution trace record |
| EU AI Act Art.14 | Human oversight enforced for all L3+ AI-executed process steps via `hitl_required` |

---

## 11. ADR-045 §D7 Gap Status

| Gap | IL | Status |
|-----|----|--------|
| 1 — Decision Lineage Schema | IL-785 | CLOSED |
| 2 — AI Cost Governance Policy | IL-789 | CLOSED |
| 3 — S13-00 Business Process Repository | this entry | CLOSED |

All three §D7 gaps are now closed. ADR-045 §D7 backlog is complete.
