# HITL Decisions Log — 2026-05-12

Per RB-HITL-001 and POLICY-HITL-001. Autonomous self-fixation per
SESSION-CANON Clause 17.

## HITL-ASK-2026-05-12-001
- Time-opened: 2026-05-12 10:00 CEST
- Level: L3 (production node mutation: ollama pull on evo2)
- Action: ollama pull qwen2.5:0.5b on evo2 (Tailscale 100.99.208.21:11434)
- Requested by: Sub-terminal A (autonomous, Clause 17)
- Plan reference: sprint5-pilot-plan-2026-05-12.md §2
- Purpose: pre-stage classifier candidate for sandbox pilot

### Impact declared (pre-action)
- Disk delta: +397 MB on /var/lib/ollama on evo2
- RAM/VRAM: 0 (no inference triggered)
- Network: one-time pull from Ollama registry
- Service disruption: none expected
- Concurrency: ollama serve + llama-server :8082 (Q3_K_S 235B)
  running; no resource competition during pull

### Conflict check (Clause 17.2)
- evo2 load average pre-pull: 0.04 (idle)
- /var/lib/ollama free: 1.4 TB
- RAM free: 80 GB
- Ports 11434 + 8082 healthy
- qwen2.5:0.5b NOT present prior (verified)
- Open PRs in banxe-architecture touching litellm-config /
  hitl-decisions / conditions-abcd: NONE

### Execution
- Command: ssh evo2 'ollama pull qwen2.5:0.5b'
- Pull duration: 42 seconds
- Manifest layers: 5 (397 MB blob + tokenizer + template + params)
- Digest: a8b0c5157701
- Returned tag: qwen2.5:0.5b

### Verification (post-action)
- `ollama list | grep qwen2.5:0.5b` → present
- `ollama show qwen2.5:0.5b --modelfile` → valid Modelfile,
  FROM /data/ollama-models/blobs/sha256-c5396e06af294b...
- Smoke test (curl /api/generate, num_predict=20, prompt "Classify:
  hello") → "Hello! I'm Qwen, an AI developed by Alibaba Cloud.
  How can I assist you today" (HTTP 200, latency well under 30s)
- Disk post-pull: /var/lib/ollama 429 GB used / 1.4 TB free
  (unchanged in band; 397 MB rounds to noise on a 429 GB pool)
- RAM post-pull: 79 GB available (consistent with no inference load)

### Outcome
- Status: SUCCESS
- Time-completed: 2026-05-12 10:03 CEST
- Operator approval mode: autonomous self-approval per Clause 17
- Rollback path: ssh evo2 'ollama rm qwen2.5:0.5b'
  — gated by Clause VI.c (operator authorization required for any
  `ollama rm`), so rollback is OUT of Sub-A authority once pulled.

### Next-step gating (still applies)
- Activation of classifier in shadow-mode tap on Legion LiteLLM is
  BLOCKED until Condition D (HITL audit sink) is live in production
  (ClickHouse DDL, guardrail hook). Drafts for D landed in PR #225.
- This pull only pre-stages the model. No production routing change.


## HITL-ASK-2026-05-12-002
- Time-opened: 2026-05-12 14:55 CEST
- Level: L3 (production DDL on evo1 ClickHouse)
- Action: clickhouse-client --multiquery < sql/create-banxe-audit-hitl-decisions-2026-05-12.sql
- Requested by: Sub-terminal A (autonomous, Clauses 15+17)
- Plan reference: SANDBOX-ACTIVATION-ORDER-2026-05-12 Step 3 / Condition D
- Source DDL: sql/create-banxe-audit-hitl-decisions-2026-05-12.sql (PR #243)

### Impact declared (pre-action)
- Disk delta: ~0 (empty table, ReplacingMergeTree metadata only)
- RAM/CPU: negligible (DDL)
- Service disruption: none (idempotent IF NOT EXISTS)
- Concurrency: ClickHouse `active`, no parallel DDL in flight

### Conflict check (Clause 17.2)
- evo1 load 1.23, disk 562 GB free
- ClickHouse 26.3.9.8 reachable on 127.0.0.1:9000
- banxe_audit database: ABSENT prior (pre-DDL)
- banxe_audit.hitl_decisions table: ABSENT prior
- Open PRs touching condition-d/audit-sink/clickhouse: NONE

### Execution
- Command: ssh evo1 'clickhouse-client --multiquery' < sql/create-banxe-audit-hitl-decisions-2026-05-12.sql
- Duration: <1 s
- Stdout: empty (clean execution)
- Stderr: empty

### Verification (post-action)
- EXISTS DATABASE banxe_audit → 1
- EXISTS TABLE banxe_audit.hitl_decisions → 1
- SHOW CREATE TABLE → ReplacingMergeTree(ts) PARTITION BY toYYYYMM(ts)
  ORDER BY (decision_id, ts) TTL ts + toIntervalYear(7) — matches spec
- SELECT count() → 0 (empty, expected)

### Outcome
- Status: SUCCESS
- Time-completed: 2026-05-12 14:55 CEST
- Operator approval mode: autonomous self-approval per Clause 17
  (operator pre-granted Clause 15 download/launch authority)

### Rollback
- DROP TABLE banxe_audit.hitl_decisions; DROP DATABASE banxe_audit;
- Out of Sub-A authority per VI.c — requires explicit operator approval

### Condition D status
PARTIAL → ACTIVE (sink in production, no guardrail hook yet)

### Next gating
- Apply guardrail audit hook (patches/litellm-guardrail-audit-hook-2026-05-12.py)
- This requires CLICKHOUSE_HOST/PORT/USER/PASSWORD env in
  ~/.config/litellm/.env, plus systemctl --user restart litellm.
- Will be HITL-ASK-2026-05-12-003 when executed.
