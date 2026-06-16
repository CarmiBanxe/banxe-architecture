# ADR-WDG-01 — Factory Watchdog / NOC / Auto-Remediation

| Field | Value |
|-------|-------|
| **Status** | PROPOSED — требует явного утверждения оператора/CEO перед переводом в ACCEPTED |
| **Date** | 2026-06-16 |
| **Author** | Factory (Central) |
| **Track** | Track J — Factory Watchdog / NOC / Auto-Remediation |
| **Refs** | G-WDG-01..04, I-75, ADR-033, I-37, G-SECURITY-EVO1-XMRIG-CRYPTOMINER |

---

## Context

No unified heartbeat/health-check system exists for the 3-layer infrastructure (hardware, routing/LLM, agents). Incidents are currently discovered manually. The post-incident V-XMRIG event (G-SECURITY-EVO1-XMRIG-CRYPTOMINER) demonstrated the need for automated detection: the cryptominer ran undetected for an unknown period before manual discovery.

Current state:
- Fragmented cron jobs (watchdog-watcher.sh */15, SYSTEM-STATE.md */5) with no unified control loop.
- No formal "no-signal = incident" policy.
- No auto-remediation framework distinguishing safe vs. forbidden actions.
- No critical entity registry with owners, heartbeat endpoints, and escalation paths.
- MTTR driven by manual triage; no automated incident classification.

---

## Decision

Implement a 3-tier heartbeat + watchdog + auto-remediation loop covering all 3 infrastructure layers.

### Cadence

| Tier | Interval | Scope | Timeout |
|------|----------|-------|---------|
| Quick heartbeat | 15 min | Connectivity, systemd/docker up, basic endpoint liveness | 30s |
| Extended health-check | 30 min | Resource thresholds (CPU/RAM/disk/VRAM), latency, model-route readiness | 60s |
| Full audit snapshot | 60 min | Comprehensive state dump, drift detection, agent smoke-tests | 120s |

**No-signal policy (I-75):** missing 2 consecutive heartbeats (2 × 15m = 30 min) from any critical entity → automatic INCIDENT classification and escalation.

### Monitoring Layers

#### Layer 1 — Hardware
- Host reachability: evo1 (192.168.0.72), evo2 (192.168.0.15), Legion
- systemd failed units (all hosts)
- Docker container health (evo1)
- CPU, RAM, disk usage (all hosts)
- GPU/VRAM on evo2 (Radeon 8060S)
- Uptime / reboot detection

#### Layer 2 — Routing / LLM
- Ollama endpoints: evo1:11434, evo2:11434
- LiteLLM gateway: Legion:4000
- LLM route aliases: factory-fast, factory-mid, factory-heavy, factory-coder, project-mid, project-heavy, project-reason
- Response latency p99 per route
- Model count (0 models loaded = critical)
- qwen3-235b-master: evo2:8082

#### Layer 3 — Agents / Services
- guardian-factory: evo1:8195
- guardian-project: evo1:8196
- compliance API: evo1:8093
- Midaz Ledger: evo1:8095
- PostgreSQL: evo1:5432
- ClickHouse: evo1:8123
- Redis: evo1:6379
- Keycloak: Legion:8180
- n8n: evo1:5678

### Safe Auto-Remediation (ALLOWED without operator)

| Condition | Remediation | Max retries | Cooldown |
|-----------|------------|-------------|----------|
| systemd unit failed (non-critical) | `systemctl restart <unit>` | 2 | 5 min |
| Docker container unhealthy | `docker restart <container>` | 2 | 5 min |
| Ollama unresponsive | `systemctl restart ollama` | 1 | 10 min |
| LiteLLM unresponsive | `systemctl restart litellm` | 1 | 10 min |
| LLM route error | Switch to fallback route | 1 | 15 min |
| Agent unresponsive (non-critical) | Disable + notify | 1 | — |
| High RAM (> 95%) | Restart largest non-critical consumer | 1 | 15 min |
| Transition to degraded mode | Route to surviving node | automatic | — |

### FORBIDDEN without operator approval

| Action | Reason |
|--------|--------|
| Destructive cleanup (rm, docker system prune) | Data loss risk |
| Compliance/policy threshold changes | FCA regulatory risk |
| Enabling AGENT_ROUTING_ENABLED | ARL pipeline not validated |
| Production routing for payment/compliance | Regulatory boundary |
| Irreversible money/ledger/legal/compliance actions | Financial/legal risk |
| GPU driver/kernel changes | Hardware stability |
| Credential rotation | Security procedure |

### Critical Entity Registry

Every critical entity MUST have in `ops/watchdog/registry.yaml`:
- `owner` — responsible party
- `heartbeat` — check type (ping / tcp_connect / http_get)
- `smoke_test` — lightweight functional test command
- `remediation` — auto_restart / operator_only / manual
- `escalation` — info / warning / critical / incident

---

## Implementation Scaffold

```
ops/watchdog/
├── README.md              # Overview and quick-start
├── config.yaml            # Heartbeat/health-check configuration
├── registry.yaml          # Critical entity registry
├── watchdog.timer         # systemd timer (15m cadence)
├── watchdog.service       # systemd service unit
└── healthcheck.py         # Health-check script (scaffold, not production-ready)
```

Full operational runbook: `docs/runbooks/watchdog-noc-runbook.md`

---

## Consequences

### Positive
- Reduced MTTR: automated detection replaces manual discovery.
- Defense-in-depth after V-XMRIG incident (G-SECURITY-EVO1-XMRIG-CRYPTOMINER).
- Unified visibility across all 3 infrastructure layers.
- Safe auto-remediation reduces on-call burden for transient failures.
- No-signal = incident policy (I-75) eliminates silent failures.
- Formal separation of safe vs. forbidden remediation actions.

### Negative / Risks
- Additional systemd service/timer on Legion (maintenance overhead).
- False positives during maintenance windows (mitigated via maintenance mode config).
- Auto-restart of Ollama/LiteLLM can cause in-flight request drops.

### Neutral
- All artifacts remain PROPOSED/SCAFFOLD until operator ratification.
- No production changes until ADR-WDG-01 transitions to ACCEPTED.
- No AGENT_ROUTING_ENABLED change. No compliance threshold changes.

---

## References

- G-WDG-01: Unified heartbeat gap
- G-WDG-02: No-signal policy gap
- G-WDG-03: Auto-remediation policy gap
- G-WDG-04: Critical entity registry gap
- I-75: No-Signal-Equals-Incident invariant (PROPOSED)
- ADR-033: Alert routing (n8n + Telegram)
- I-37: Factory/project layer binding
- Track E: Observability
- Track H Phase 8: Monitoring/alerting full coverage
- G-SECURITY-EVO1-XMRIG-CRYPTOMINER: Post-incident motivation

---

*OPERATOR DECISION REQUIRED: ADR-WDG-01 ratification (PROPOSED → ACCEPTED) before any Track J implementation begins.*
