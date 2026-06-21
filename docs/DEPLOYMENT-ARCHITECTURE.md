# Deployment Architecture — Banxe Cluster Infrastructure (evo1/evo2)

**Version:** 1.1
**Date:** 2026-06-21
**Status:** LIVING DOCUMENT — updated each sprint
**Scope:** Project cluster evo1/evo2 (per ADR-117 ACCEPTED 2026-06-21); Factory = Legion

> **Reconciled to ADR-117 (ACCEPTED 2026-06-21); Mandate: ADR-116.** See `docs/governance/CANON-RECONCILIATION-ADR117.md`.
> Per ADR-117: **Factory** = Legion (64 GB, model `qwen2.5-coder:14b-banxe-factory`, software-delivery only); **Project** = cluster evo1/evo2 (128 GB each), which lends compute to the factory during code-design.
> **RESOLVED (operator decision, 2026-06-21):** GMKtec == evo1. evo1 = banxe-NucBox-EVO-X1 (LAN 192.168.0.72, Tailscale 100.68.102.48); evo2 = banxe-NucBox-EVO-X2-2 (LAN 192.168.0.15, Tailscale 100.99.208.21). Service placement = node-per-service (mode B); see §1.1 and §2.

---

## 1. Hardware

### 1.1 Project Cluster — evo1 / evo2 (per ADR-117 ACCEPTED)

| Node | Hostname | LAN IP | Tailscale | SSH | RAM | CPU/NPU | Role |
|------|----------|--------|-----------|-----|-----|---------|------|
| evo1 (== former GMKtec) | banxe-NucBox-EVO-X1 | 192.168.0.72 | 100.68.102.48 | :2222 (alias `evo1`) | 128 GB unified (operator-confirmed) | AMD Ryzen AI MAX+ 395 (Strix Halo, NPU) | app / compliance / payments / AI-gateway; banxe-supervisor model `qwen3-banxe-v2` |
| evo2 | banxe-NucBox-EVO-X2-2 | 192.168.0.15 | 100.99.208.21 | :2222 (ProxyJump evo1) | 128 GB unified (operator-confirmed) | AMD Ryzen AI MAX+ 395 family (NucBox EVO-X) | observability + heavy-inference; `qwen3:235b-a22b(-banxe)` |

- OS: Ubuntu 24.04 LTS; Storage 1.9 TB NVMe per node (evo2 GPU/storage per EVO-X family).
- Shared models on both nodes: `llama3.3:70b`, `qwen3:30b-a3b`, `qwen3-coder-next`, `glm-4.7-flash`, `gpt-oss:20b`.
- Factory model `qwen2.5-coder:14b-banxe-factory` runs on **Legion** (factory node, not the cluster).

### 1.2 Legion Pro 5 — Factory Node (per ADR-117)

| Spec | Value |
|------|-------|
| CPU | Intel i7-14700HX |
| RAM | 64 GB |
| OS | Windows 11 + WSL2 Ubuntu 24.04 |
| Role | Factory node (ADR-117) — software-delivery orchestration: Claude Code, git, factory model `qwen2.5-coder:14b-banxe-factory` |
| Constraint | Software-delivery only; no project/domain workloads or live banking services |

**Important:** Factory = Legion (software-delivery orchestration only, ADR-117); no project/customer data on Legion. Project services, AI models, and data reside on the **Project cluster (evo1/evo2)** per the node-per-service map (§2). FCA DORA data-residency is satisfied by the Project cluster (regulated compute perimeter) — no customer data leaves it.

---

## 2. Service Inventory

### 2.1 Complete Port Map

Node placement = mode B (node-per-service, operator audit 2026-06-21). Target-Node column added.

| Service | Internal Port | External Port | Protocol | License | Status | Target-Node |
|---------|--------------|--------------|----------|---------|--------|-------------|
| Ollama | 11434 | — (internal) | HTTP | MIT | Active | evo1 + evo2 |
| OpenClaw moa-bot | 18789 | 18789 | Telegram/HTTP | Commercial | Active | evo1 |
| OpenClaw ctio-bot | 18791 | 18791 | Telegram/HTTP | Commercial | Active | evo1 |
| OpenClaw @mycarmibot | 18793 | 18793 | Telegram/HTTP | Commercial | Active | evo1 |
| FastAPI compliance | 8093 | — (nginx) | HTTP | Proprietary | Active | evo1 |
| Moov Watchman | 8084 | — (internal) | HTTP | Apache 2.0 | Active | evo1 |
| Banxe Screener | 8085 | — (internal) | HTTP | Proprietary | Active | evo1 |
| Jube TM | 5001 | — (internal) | HTTP | AGPLv3 | Active | evo1 |
| Marble API | 5002 | — (internal) | HTTP | ELv2 | Active | evo1 |
| Marble UI | 5003 | — (nginx) | HTTP | ELv2 | Active | evo1 |
| ClickHouse (TCP) | 9000 | — (internal) | TCP | Apache 2.0 | Active | evo1 |
| ClickHouse (HTTP) | 8123 | — (internal) | HTTP | Apache 2.0 | Active | evo1 |
| PostgreSQL (compliance) | 5432 | — (internal) | TCP | PostgreSQL | Active | evo1 |
| PostgreSQL (Jube) | 15432 | — (internal) | TCP | PostgreSQL | Active | evo1 |
| PostgreSQL (Marble) | 15433 | — (internal) | TCP | PostgreSQL | Active | evo1 |
| Redis | 6379 | — (internal) | TCP | BSD | Active | evo1 |
| Redis (Jube) | 16379 | — (internal) | TCP | BSD | Active | evo1 |
| PII Proxy (Presidio) | 8089 | — (internal) | HTTP | MIT | Active | evo1 |
| Deep Search | 8088 | — (internal) | HTTP | Proprietary | Active | evo1 |
| Auto-Verify API | 8094 | — (internal) | HTTP | Proprietary | Active | evo1 |
| n8n | 5678 | — (nginx) | HTTP | Fair-code | Active | evo1 |
| nginx | 443/80 | 443/80 | HTTPS/HTTP | MIT | Active | evo1 |
| Firebase Emulator (auth) | 9099 | — (internal) | HTTP | Apache 2.0 | Active | evo1 |
| Firebase Emulator (UI) | 4000 | — (internal) | HTTP | Apache 2.0 | Active | evo1 |
| Midaz (LerianStudio) | 8095 | — (internal) | HTTP | Apache 2.0 | Deploying | evo1 |
| Yente (OpenSanctions) | 8086 | — (internal) | HTTP | MIT | Planned Phase 3 | evo1 |
| LiteLLM gateway | 4000 | — (LAN) | HTTP | MIT | Active | evo1 (port per operator; verify vs Firebase UI :4000) |
| banxe-mock-aspsp | 8888 | — (internal) | HTTP | Proprietary | Active | evo1 |
| Prometheus | 9090 | — (internal) | HTTP | Apache 2.0 | Active | evo2 |
| Grafana | 3000 | — (internal) | HTTP | AGPLv3 | Active | evo2 |
| Blackbox exporter | 9115 | — (internal) | HTTP | Apache 2.0 | Active | evo2 |

**GUIYON (:18794) — operator decision 2026-06-21:** compute co-located on **evo1** (node-per-service, see §2.3). I-18 "absolute isolation" is hereby interpreted as **logical / network / data isolation** (not node-exclusivity); GUIYON remains a separate project with its own isolation boundary. **FLAG:** `INVARIANTS.md` I-18 requires a separate formal reconciliation to match this co-location — not edited in this changeset.

### 2.3 Node placement (mode B) — operator audit 2026-06-21 (services without published port above)

- **evo1** (app/compliance/payments/AI-gateway): keycloak, hitl-dashboard, guardian-factory, guardian-project, guiyon-dispatcher, openclaw guiyon (:18794), midaz (ledger / rabbitmq / mongodb), mirofish. Ports not re-asserted where absent from operator audit — to be added when confirmed.
- **evo2** (observability + heavy-inference): see Prometheus/Grafana/Blackbox above; Ollama heavy-inference (`qwen3:235b-a22b(-banxe)`).
- GUIYON: co-located on evo1 per operator (2026-06-21); I-18 = logical/network/data isolation (INVARIANTS.md reconciliation flagged separately).

### 2.2 Ollama Models

| Model | Size | Role | Agent |
|-------|------|------|-------|
| qwen2.5-coder:14b-banxe-factory | 14b | factory code-delivery (Legion) | Factory (ADR-117) |
| qwen3-banxe-v2 | ~30b-a3b | supervisor, kyc, compliance, risk, crypto | MLRO bot (primary) |
| glm-4.7-flash-abliterated | — | client-service, operations, it-devops | CTIO bot |
| gpt-oss-derestricted:20b | — | analytics, finance | Analytics agent |

> **ADR-117 per-node roles (operator-confirmed 2026-06-21):**
> - **evo2** = heavy-reasoning (`qwen3:235b-a22b`, `qwen3:235b-a22b-banxe`) + observability host.
> - **evo1** = banxe-supervisor (`qwen3-banxe-v2`) + app/compliance services.
> - **shared (both)**: `llama3.3:70b`, `qwen3:30b-a3b`, `qwen3-coder-next`, `glm-4.7-flash`, `gpt-oss:20b`.
> - **Legion (factory)**: `qwen2.5-coder:14b-banxe-factory` — docs-resolved; **runtime unverified (Legion UNREACHABLE via ssh @2026-06-21)**.

---

## 3. Storage Layout

All persistent app/compliance data resides under `/data/` on **evo1** NVMe (192.168.0.72); per-service node placement per §2.3 (mode B). Observability data (Prometheus/Grafana) resides on evo2:

```
/data/
├── banxe/                    # Main compliance data
│   ├── .env                  # All secrets (API keys, tokens — NOT in git)
│   ├── compliance/           # AML/KYC screening data
│   └── backups/              # ClickHouse + OpenClaw backups
│
├── vibe-coding/              # Git repo (synced from GitHub CarmiBanxe/vibe-coding)
│   ├── src/compliance/       # Core compliance Python stack
│   ├── scripts/              # All operational scripts
│   └── docs/                 # Project documentation
│
├── banxe-stack/              # OSS components (Docker Compose stacks)
│   ├── marble/               # Marble case management
│   ├── ballerine/            # KYC orchestration (Phase 3)
│   ├── watchman/             # Sanctions screening
│   └── midaz/                # CBS general ledger (deploying)
│
├── clickhouse/               # ClickHouse data directory
│   └── banxe/                # Database: compliance_screenings, decision_events (+4 tables)
│
├── metaclaw/                 # MetaClaw skills (AI training artifacts)
│   └── skills/               # Learned compliance skills (JSONL)
│
├── n8n/                      # n8n workflow storage
│   └── workflows/            # FIN-RPT, Gabriel, FSCS workflows
│
└── ollama-models/            # Ollama model weights storage
    └── manifests/            # Model metadata
```

### 3.1 OpenClaw Workspace Layout

```
/root/.openclaw-moa/          # moa-bot configuration root
  └── .openclaw/
      └── openclaw.json       # Gateway config (immutable via chattr+i)

/home/mmber/.openclaw/
  └── workspace-moa/          # moa-bot workspace (md files)
      ├── SOUL.md             # Agent identity (chattr+i protected)
      ├── MEMORY.md           # Long-term memory (synced from GitHub)
      ├── AGENTS.md           # Agent routing rules
      ├── BOOTSTRAP.md        # Agent bootstrap instructions
      ├── IDENTITY.md         # Identity file (CLASS_B)
      ├── TOOLS.md            # Available tools
      ├── USER.md             # User profile
      └── HEARTBEAT.md        # Health signal

/root/.openclaw-ctio/         # CTIO bot configuration root
/root/.openclaw-default/      # @mycarmibot (separate project — do not modify)
```

---

## 4. Network Architecture

### 4.1 External Access

```
Internet
  │
  ▼
nginx :443 (HTTPS, self-signed SSL)
  │
  ├─► Marble UI :5003      (MLRO dashboard)
  ├─► n8n :5678            (workflow automation)
  └─► FastAPI :8093        (compliance API — internal only, no external exposure)

nginx :80 (HTTP → redirect to :443)

Telegram Webhook
  │
  ├─► OpenClaw moa-bot :18789
  ├─► OpenClaw ctio-bot :18791
  └─► OpenClaw @mycarmibot :18793
```

### 4.2 Internal Service Communication

All internal services communicate on Docker bridge networks, isolated per stack:

```
banxe-compliance-net:
  FastAPI :8093 → Watchman :8084
  FastAPI :8093 → Screener :8085
  FastAPI :8093 → Jube :5001
  FastAPI :8093 → PII Proxy :8089
  FastAPI :8093 → ClickHouse :9000
  FastAPI :8093 → PostgreSQL :5432
  FastAPI :8093 → Redis :6379
  FastAPI :8093 → Auto-Verify :8094

banxe-marble-net:
  Marble API :5002 → PostgreSQL (Marble) :15433
  Marble API :5002 → Firebase :9099
  Marble UI :5003 → Marble API :5002

banxe-ai-net:
  OpenClaw :18789 → Ollama :11434
  OpenClaw :18791 → Ollama :11434
  OpenClaw :18789 → Auto-Verify :8094
  OpenClaw :18789 → FastAPI :8093

banxe-cbs-net (deploying):
  LedgerPort → Midaz :8095
  Midaz :8095 → PostgreSQL (CBS) :25432 (planned)
  Midaz :8095 → ClickHouse :9000
```

### 4.3 SSH Access

| Source | Target | Port | Method |
|--------|--------|------|--------|
| Legion (WSL2) | evo1 (192.168.0.72) | 2222 | SSH key, alias `ssh evo1` (was `gmktec`; alias renamed) |
| Legion (WSL2) | evo2 (192.168.0.15) | 2222 | SSH key, alias `ssh evo2` (ProxyJump evo1) |
| Claude Code | evo1 / evo2 | 2222 | Via Legion terminal |

---

## 5. Process Management

### 5.1 Systemd Services (evo1 — app/compliance; observability units on evo2)

| Service | Unit File | User | Managed By |
|---------|-----------|------|-----------|
| Ollama | ollama.service | banxe | systemd |
| OpenClaw moa-bot | openclaw-moa.service | root | systemd |
| OpenClaw ctio-bot | openclaw-ctio.service | root | systemd |
| FastAPI compliance | banxe-compliance.service | banxe | systemd |
| PII Proxy | pii-proxy.service | banxe | systemd |

### 5.2 Docker Compose Stacks (evo1 — app/compliance; observability stack on evo2)

| Stack | Directory | Key Services |
|-------|-----------|-------------|
| banxe-compliance | /data/banxe-stack/compliance/ | Watchman, Screener, Jube, Presidio |
| banxe-marble | /data/banxe-stack/marble/ | Marble API, Marble UI, Firebase, PostgreSQL (Marble) |
| banxe-clickhouse | /data/banxe-stack/clickhouse/ | ClickHouse |
| banxe-n8n | /data/banxe-stack/n8n/ | n8n |
| banxe-midaz | /data/banxe-stack/midaz/ | Midaz (deploying) |

### 5.3 Cron Jobs (evo1)

| Schedule | Script | Purpose |
|----------|--------|---------|
| `*/5 * * * *` | memory-autosync-watcher.sh | MEMORY.md GitHub sync + SOUL GUARD hash check |
| `*/5 * * * *` | ctio-watcher.sh v2 | SYSTEM-STATE.md → GitHub push |
| `*/15 * * * *` | watchdog-watcher.sh | Verify all watchers alive |
| `0 */6 * * *` | backup-clickhouse.sh | ClickHouse database backup |
| `0 3 * * *` | backup-openclaw.sh | OpenClaw config backup |
| `0 2 * * 0` | run-adversarial-sim.sh | Weekly adversarial scenario simulation |
| `0 4 * * 0` | run-promptfoo-eval.sh | Weekly promptfoo compliance quality eval |

---

## 6. Security Architecture

### 6.1 File Immutability

Critical configuration files are protected with `chattr +i` (immutable flag):

| File | Protection | Update Method |
|------|-----------|---------------|
| SOUL.md (workspace) | chattr +i | `bash scripts/protect-soul.sh update` |
| openclaw.json | chattr +i | Manual root, then re-apply chattr |
| memory-autosync-watcher.sh | chattr +i | Manual root only |
| ctio-watcher.sh | chattr +i | Manual root only |

### 6.2 OpenClaw Gateway Hardening

Per security hardening (31 March 2026):

- `dangerouslyDisableDeviceAuth: false` — always
- `gateway.auth.token` — configured
- `discovery.mdns.mode: "off"` — mDNS disabled
- `tools.deny: [gateway]` — gateway tools denied
- `configWrites: false` — no runtime config modification
- systemd: `MemoryMax=8G`, `CPUQuota=200%`

### 6.3 PII Handling

All compliance data passes through PII Proxy (Presidio :8089) before ClickHouse storage. Ensures GDPR Article 25 (data minimisation) and FCA data handling requirements.

### 6.4 Secrets Management

- All secrets (API keys, tokens, passwords) stored exclusively in `/data/banxe/.env` on evo1 (192.168.0.72)
- No secrets committed to any git repository (enforced by pre-commit hook via SR-01)
- Claude Code never reads or commits `.env` files

---

## 7. Backup and Recovery

| Component | Backup Schedule | Method | Retention |
|-----------|----------------|--------|-----------|
| ClickHouse | Every 6 hours | backup-clickhouse.sh | 30 days local |
| OpenClaw configs | Daily 03:00 | backup-openclaw.sh | 7 days local |
| GitHub repositories | On every push | git push | Unlimited |
| MEMORY.md | Every 5 min | memory-autosync-watcher.sh | GitHub history |
| SYSTEM-STATE.md | Every 5 min | ctio-watcher.sh | GitHub history |

---

## 8. Related Documents

- `SERVICE-MAP.md` — authoritative service port registry
- `docs/SYSTEM-ARCHITECTURE.md` — C4 architecture diagrams
- `docs/ROADMAP-MATRIX.md` — delivery schedule
- `docs/SOUL-PROTECTION.md` — SOUL.md protection runbook
- `governance/trust-zones.yaml` — trust zone definitions
- `INVARIANTS.md` — architecture invariants (I-08, I-24 most relevant here)
