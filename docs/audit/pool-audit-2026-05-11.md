# Pool Audit — Banxe AI Inference Pool
# ADR-035 ROADMAP Part 1 / Step 2
# Date: 2026-05-11 | Auditor: Sub-terminal A (Claude Code)
# Status: READ-ONLY collection — no changes made to any node

## Scope

Three-node inference pool: evo1 (on-prem AI master), evo2 (production inference), Legion WSL2 (dev router).
Collection method: SSH read-only commands + local inspection. No writes, no restarts, no config changes.

---

## evo1 — banxe-NucBox-EVO-X2 (On-Prem AI Master)

### System
| Metric          | Value                                       |
|-----------------|---------------------------------------------|
| Hostname        | banxe-NucBox-EVO-X2                         |
| Kernel          | 6.17.0-23-generic                           |
| Uptime          | 4 days 8:25                                 |
| Load (1/5/15m)  | 0.95 / 1.05 / 1.29                          |

### Memory
| Metric      | Value    |
|-------------|----------|
| Total RAM   | 123 GiB  |
| Used        | 11 GiB   |
| Free        | 74 GiB   |
| Buff/Cache  | 39 GiB   |
| Available   | 112 GiB  |
| Swap total  | 8 GiB    |
| Swap used   | 3.4 GiB  |

### Storage
| Device          | Size  | Used  | Avail | Use% | Mount |
|-----------------|-------|-------|-------|------|-------|
| /dev/nvme0n1p4  | 913G  | 304G  | 563G  | 36%  | /     |

### GPU (ROCm)
| Metric           | Value        |
|------------------|--------------|
| GPU count        | 1 (GPU[0])   |
| VRAM Total       | 2.0 GiB      |
| VRAM Used        | ~313 MiB     |
| Driver           | ROCm present |

### Ollama Service
| Metric        | Value                                    |
|---------------|------------------------------------------|
| Status        | active (running)                         |
| Since         | 2026-05-07                               |
| PID           | 3280                                     |
| Memory        | 27.5 GiB (peak 63.2 GiB)                |
| Model storage | /data/ollama-models/blobs/               |

### Ollama Models (evo1) — 9 models
| Model                                   | Size   | Notes              |
|-----------------------------------------|--------|--------------------|
| qwen3-coder-next:q4_K_M                 | 51 GB  | primary coder      |
| llama3.3:70b                            | 42 GB  | general purpose    |
| qwen3.5:35b                             | 23 GB  | reasoning          |
| huihui_ai/glm-4.7-flash-abliterated    | 18 GB  | uncensored flash   |
| qwen3:30b-a3b                           | 18 GB  | MoE 30B            |
| gurubot/gpt-oss-derestricted:20b        | 15 GB  | uncensored 20B     |
| qwen3.5:latest                          | 6.6 GB | fast inference     |
| qwen2.5-coder:7b-instruct-q4_K_M       | 4.7 GB | compact coder      |
| qwen3:4b                                | 2.5 GB | fastest/smallest   |
| **TOTAL**                               | **~182 GB** |               |

### Top Processes by RSS (evo1)
| PID     | User       | RSS     | Command           |
|---------|------------|---------|-------------------|
| 3729    | clickhouse | 1.2 GB  | clickhouse-serv   |
| 3639    | ctio       | 798 MB  | openclaw-gateway  |
| 3849    | guiyon     | 619 MB  | openclaw-gateway  |
| 3175021 | root       | 270 MB  | banxe-watchman    |
| 3831    | root       | 236 MB  | openclaw-gateway  |
| 6508    | banxe      | 234 MB  | java              |
| 2109    | root       | 195 MB  | node              |
| 3280    | ollama     | 145 MB  | ollama (daemon)   |
| 6864    | banxe      | 80 MB   | uvicorn           |

### Services (evo1)
| Service  | Status     |
|----------|------------|
| Ollama   | running    |
| Redis    | not installed |
| ROCm     | present (2GB GPU) |
| ClickHouse | running  |
| uvicorn  | running    |

---

## evo2 — banxe-NucBox-EVO-X2-2 (Production Inference)

### System
| Metric          | Value                                       |
|-----------------|---------------------------------------------|
| Hostname        | banxe-NucBox-EVO-X2-2                       |
| Uptime          | 2 days 8:54                                 |
| Load (1/5/15m)  | 0.00 / 0.00 / 0.00                          |

### Memory
| Metric      | Value    |
|-------------|----------|
| Total RAM   | 123 GiB  |
| Used        | 43 GiB   |
| Free        | 1.1 GiB  |
| Buff/Cache  | 80 GiB   |
| Available   | 80 GiB   |
| Swap total  | 8 GiB    |
| Swap used   | 463 MiB  |

**Note:** 43 GiB used — llama-server process holds ~55.8 GiB RSS (model loaded in RAM).
Buff/cache + swap mask this; available 80 GiB includes reclaimable page cache.

### Storage
| Device          | Size  | Used  | Avail | Use% | Mount |
|-----------------|-------|-------|-------|------|-------|
| /dev/nvme0n1p2  | 1.9T  | 429G  | 1.4T  | 25%  | /     |

### GPU
| Metric   | Value         |
|----------|---------------|
| ROCm     | not present   |
| GPU      | not detected  |

### Ollama Service
| Metric        | Value                                    |
|---------------|------------------------------------------|
| Status        | active (running)                         |
| Since         | 2026-05-09                               |
| PID           | 2121                                     |
| Memory        | 28.4 MiB (daemon only — model via llama-server) |
| Model storage | /data/ollama-models/ = 301 GB (35 blobs) |

### Ollama Models (evo2) — 10 models
| Model                                   | Size    | Notes                     |
|-----------------------------------------|---------|---------------------------|
| qwen3:235b-a22b-banxe                   | 142 GB  | fine-tuned Banxe variant  |
| qwen3:235b-a22b                         | 142 GB  | base 235B (duplicate)     |
| qwen3-coder-next:q4_K_M                 | 51 GB   | primary coder             |
| llama3.3:70b                            | 42 GB   | general purpose           |
| qwen3.5:35b                             | 23 GB   | reasoning                 |
| huihui_ai/glm-4.7-flash-abliterated    | 18 GB   | uncensored flash          |
| qwen3:30b-a3b                           | 18 GB   | MoE 30B                   |
| gurubot/gpt-oss-derestricted:20b        | 15 GB   | uncensored 20B            |
| qwen3.5:latest                          | 6.6 GB  | fast inference            |
| qwen3:4b                                | 2.5 GB  | fastest/smallest          |
| **TOTAL**                               | **~461 GB** | qwen3:235b dominates  |

### Top Processes by RSS (evo2)
| PID  | User    | RSS      | Command        |
|------|---------|----------|----------------|
| 2122 | moriel+ | 55.8 GB  | llama-server   |
| 3163 | moriel+ | 223 MB   | gnome-shell    |
| 2708 | 472     | 188 MB   | grafana        |
| 1849 | root    | 37 MB    | tailscaled     |

**Critical finding:** `llama-server` at 55.8 GB RSS — a large model (likely qwen3:235b-a22b-banxe
or llama3.3:70b) is actively loaded and consuming ~45% of physical RAM.

### Services (evo2)
| Service     | Status        |
|-------------|---------------|
| Ollama      | running       |
| llama-server | running (55.8 GB loaded) |
| Redis       | not installed |
| Grafana     | running       |
| Tailscale   | running       |

---

## Legion — WSL2 Dev Router (mark-legion)

### System
| Metric    | Value                             |
|-----------|-----------------------------------|
| Platform  | WSL2 on Windows                   |
| Role      | LiteLLM proxy + dev workstation   |

### Memory
| Metric     | Value   |
|------------|---------|
| Total RAM  | 54 GiB  |
| Used       | 6.9 GiB |
| Free       | 35 GiB  |
| Buff/Cache | 13 GiB  |
| Available  | 48 GiB  |
| Swap       | 8 GiB (0 used) |

### Storage
| Device   | Size   | Used | Avail | Use% | Mount |
|----------|--------|------|-------|------|-------|
| /dev/sdd | 1007G  | 98G  | 858G  | 11%  | /     |

### LiteLLM Proxy
| Metric        | Value                                       |
|---------------|---------------------------------------------|
| Status        | active (running)                            |
| Since         | 2026-05-07                                  |
| Port          | 8080 (127.0.0.1 only)                       |
| PID           | 339                                         |
| Memory        | 297.8 MB                                    |
| Auth          | LITELLM_MASTER_KEY required                 |
| Config        | ~/litellm-config.yaml                       |

### LiteLLM Model Routes (active config)
| Route alias            | Backend                     | Provider   |
|------------------------|-----------------------------|------------|
| anthropic/claude-sonnet-4-6 | claude-sonnet-4-6       | Anthropic  |
| gemini/gemini-2.0-flash    | gemini-2.0-flash         | Google     |
| llama-3.3-70b          | ollama/llama3.3:70b @ evo1  | evo1 local |
| groq/llama-3.3-70b     | groq/llama-3.3-70b-versatile | Groq      |
| groq/llama-4-scout     | groq/llama-4-scout-17b      | Groq       |
| banxe/supervisor       | claude-sonnet-4-6           | Anthropic  |
| banxe/operations       | qwen3:30b-a3b @ evo1        | evo1 local |
| banxe/compliance       | claude-sonnet-4-6           | Anthropic  |
| banxe/kyc              | groq/llama-4-scout          | Groq       |
| banxe/fx               | gemini-2.0-flash            | Google     |
| ollama/glm-flash       | qwen3:30b-a3b @ evo1        | evo1 local |
| ollama/llama3.3-70b    | llama3.3:70b @ evo1         | evo1 local |
| ollama/qwen3.5-35b     | qwen3.5:latest @ evo1       | evo1 local |

**evo1 Tailscale address in config:** 100.68.102.48:11434

### Compliance Notes (Legion LiteLLM)
- **C1 FIX applied:** Kimi K2 (Moonshot AI, China) disabled — UK GDPR Art.44 cross-border transfer risk
- Compliance comment in config references the exact regulatory rationale
- `banxe/compliance` route correctly uses Claude Sonnet 4.6 (Anthropic, UK/EU DPA available)
- `general_settings.master_key` sourced from env — no hardcoded secret

### Stale Config Note
- `~/litellm_config.yaml` (note: no hyphen) exists with an older 4-model config pointing to evo2
  at 192.168.0.72:11434. This file is NOT the active config. The service uses `~/litellm-config.yaml`.
  Risk: confusion if future operators edit the wrong file.

---

## Pool Summary

| Node   | RAM    | Models  | Model Storage | GPU      | Ollama | Redis |
|--------|--------|---------|---------------|----------|--------|-------|
| evo1   | 123 GB | 9 models | ~182 GB      | ROCm 2GB | Active | None  |
| evo2   | 123 GB | 10 models | ~301 GB     | None     | Active | None  |
| Legion | 54 GB  | 0 local  | 0             | None     | None   | None  |
| **Total** | **300 GB** | **19 unique** | **~483 GB** | | | |

### Cross-Pool Observations

1. **qwen3:235b-a22b present on evo2** — 142 GB model, actively loaded (llama-server 55.8 GB RSS
   suggests a slice or different model; 235B quantised at 4-bit would require ~120 GB RAM to load fully).
2. **No model deduplication** — both nodes carry llama3.3:70b, qwen3.5:35b, qwen3:30b-a3b,
   qwen3.5:latest, qwen3-coder-next, glm-4.7-flash, gpt-oss-derestricted:20b. ~130 GB duplicated.
3. **No Redis anywhere** — no shared key-value store for routing state, session, or rate limiting.
4. **Legion routes to evo1 only** (via Tailscale 100.68.102.48). evo2 is not in the active
   LiteLLM route table — it operates independently.
5. **evo2 grafana running** — monitoring infrastructure present; evo1 has no grafana observed.
6. **evo1 is heavier** (clickhouse + openclaw-gateway + banxe-watchman + uvicorn) —
   inference node also carries production services, creating resource contention risk.

---

## Risk Register (Audit Findings)

| ID  | Severity | Finding                                              | Node  |
|-----|----------|------------------------------------------------------|-------|
| A-1 | HIGH     | evo1 carries production services + inference — RAM contention if model peaks at 63GB | evo1 |
| A-2 | MEDIUM   | Two litellm config files on Legion — stale file risk | Legion |
| A-3 | MEDIUM   | evo2 not in LiteLLM routing — orphaned inference capacity | evo2 |
| A-4 | MEDIUM   | 130+ GB of duplicate models across evo1/evo2         | Both  |
| A-5 | LOW      | No Redis on any node — no session/rate-limit layer   | All   |
| A-6 | LOW      | evo2 has qwen3:235b × 2 (base + fine-tuned) — 284 GB; storage at 301GB/1.9T (16%) | evo2 |
| A-7 | INFO     | ROCm GPU (2GB) on evo1 — insufficient for model offload; used for system display only | evo1 |

