# Factory Watchdog / NOC Runbook
> ADR-WDG-01 | I-75 | G-WDG-01..04
> Status: DRAFT — pending ADR-WDG-01 ACCEPTED

---

## 1. Cadence

| Interval | Check type | Scope | Timeout |
|----------|-----------|-------|---------|
| 15 min | Quick heartbeat | Connectivity, systemd/docker up, basic endpoint liveness | 30s |
| 30 min | Extended health-check | Resource thresholds, latency, model-route readiness | 60s |
| 60 min | Full audit snapshot | Comprehensive state, drift detection, agent smoke-tests | 120s |

---

## 2. Monitoring Layers

### Layer 1 — Hardware
| Check | Target | Warning | Critical |
|-------|--------|---------|----------|
| Host reachable | evo1 (192.168.0.72), evo2 (192.168.0.15), Legion | ping timeout > 5s | ping timeout > 15s or unreachable |
| CPU usage | all hosts | > 80% sustained 10m | > 95% sustained 5m |
| RAM usage | all hosts | > 85% | > 95% |
| Disk usage | all hosts | > 80% | > 90% |
| GPU/VRAM (evo2) | Radeon 8060S | VRAM > 90% | VRAM > 98% or GPU unresponsive |
| Uptime | all hosts | reboot detected | unreachable |
| systemd failed | all hosts | any failed unit | critical unit failed (see registry) |
| Docker health | evo1 | any unhealthy container | critical container down |

### Layer 2 — Routing / LLM
| Check | Target | Warning | Critical |
|-------|--------|---------|----------|
| Ollama health | evo1:11434, evo2:11434 | response > 5s | unreachable or 5xx |
| LiteLLM gateway | Legion:4000 | response > 3s | unreachable |
| factory-fast route | Legion:4000/v1 | latency p99 > 10s | route returns error |
| factory-mid route | Legion:4000/v1 | latency p99 > 15s | route returns error |
| factory-heavy route | Legion:4000/v1 | latency p99 > 30s | route returns error |
| project-reason route | Legion:4000/v1 | latency p99 > 60s | route returns error |
| qwen3-235b health | evo2:8082/health | response > 10s | HTTP != 200 |
| Model count | evo1/evo2 Ollama | < expected model count | 0 models loaded |

### Layer 3 — Agents / Services
| Check | Target | Warning | Critical |
|-------|--------|---------|----------|
| guardian-factory | evo1:8195 | response > 5s | unreachable |
| guardian-project | evo1:8196 | response > 5s | unreachable |
| compliance API | evo1:8093 | response > 5s | unreachable or 5xx |
| Midaz Ledger | evo1:8095 | response > 5s | unreachable or 5xx |
| PostgreSQL | evo1:5432 | connection > 3s | unreachable |
| ClickHouse | evo1:8123 | connection > 3s | unreachable |
| Redis | evo1:6379 | connection > 1s | unreachable |
| Keycloak | Legion:8180 | response > 10s | unreachable |
| n8n | evo1:5678 | response > 5s | unreachable |

---

## 3. No-Signal Policy (I-75)

```
IF heartbeat_count(entity, last_30m) == 0:
    classify → INCIDENT
    attempt → safe auto-remediation (§4)
    IF remediation_failed:
        escalate → operator (§5)
    log → ClickHouse banxe.watchdog_events
```

Missing 2 consecutive heartbeats (30 min silence) = automatic INCIDENT classification.

---

## 4. Remediation Matrix

### ALLOWED (auto, no operator needed)

| Condition | Remediation | Max retries | Cooldown |
|-----------|------------|-------------|----------|
| systemd unit failed | `systemctl restart <unit>` | 2 | 5 min |
| Docker container unhealthy | `docker restart <container>` | 2 | 5 min |
| Ollama unresponsive | `systemctl restart ollama` | 1 | 10 min |
| LiteLLM unresponsive | `systemctl restart litellm` | 1 | 10 min |
| LLM route error | Switch to fallback route (e.g., factory-heavy → factory-mid) | 1 | 15 min |
| Agent unresponsive (non-critical) | Disable + notify | 1 | — |
| High RAM (> 95%) | Restart largest non-critical consumer | 1 | 15 min |

### FORBIDDEN (operator required)

| Action | Reason | Escalation |
|--------|--------|-----------|
| Destructive cleanup (rm, docker system prune) | Data loss risk | Page operator |
| Compliance/policy threshold changes | FCA regulatory risk | Page operator + MLRO |
| Enable AGENT_ROUTING_ENABLED | ARL pipeline not validated | Page operator |
| Production payment/compliance routing | Regulatory boundary | Page operator + MLRO |
| Irreversible ledger/legal/compliance actions | Financial/legal risk | Page operator + MLRO + CEO |
| GPU driver/kernel changes | Hardware stability | Page operator |
| Credential rotation | Security procedure | Page operator |

---

## 5. Escalation Matrix

| Severity | Response time | Channel | Recipient |
|----------|--------------|---------|-----------|
| INFO | Next business day | ClickHouse log only | — |
| WARNING | 4 hours | Telegram notification | Operator |
| CRITICAL | 15 minutes | Telegram + n8n alert workflow | Operator + CEO |
| INCIDENT (no-signal) | Immediate | Telegram + n8n + all channels | Operator + CEO + MLRO (if compliance-adjacent) |

Escalation path: ADR-033 n8n + Telegram channel.

---

## 6. Degraded Mode

When critical services are down and auto-remediation fails:

| Component down | Degraded behavior |
|---------------|-------------------|
| evo2 (GPU inference) | Factory routes fallback to evo1 (CPU-only, slower) |
| Ollama (one node) | LiteLLM routes to surviving node |
| LiteLLM gateway | Direct Ollama calls (bypass routing, lose load-balancing) |
| ClickHouse | Buffer events in Redis; replay when CH recovers |
| Keycloak | Cached sessions continue; new auth blocked (CRITICAL) |
| PostgreSQL | Full stop — no degraded mode for primary DB (INCIDENT) |
| Redis | Degraded caching; compliance hot-path impacted (G-09) |

---

## 7. Registry Reference

Critical entity registry: `ops/watchdog/registry.yaml`
Heartbeat config: `ops/watchdog/config.yaml`
Systemd timer: `ops/watchdog/watchdog.timer` + `ops/watchdog/watchdog.service`
