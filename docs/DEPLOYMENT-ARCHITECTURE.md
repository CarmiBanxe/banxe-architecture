# Deployment Architecture — Banxe GMKtec Infrastructure

**Version:** 1.0
**Date:** 2026-04-06
**Status:** LIVING DOCUMENT — updated each sprint
**Scope:** GMKtec EVO-X2 primary compute node (192.168.0.72)

---

## 1. Hardware

### 1.1 GMKtec EVO-X2 — AI Brain (Primary Compute)

| Spec | Value |
|------|-------|
| Hostname | gmktec (SSH alias) |
| IP Address | 192.168.0.72 |
| SSH Port | 2222 |
| CPU | AMD Ryzen AI MAX+ 395 (Strix Halo, NPU integrated) |
| RAM | 128 GB unified memory |
| Storage | 1.9 TB NVMe |
| GPU/NPU | AMD Radeon 890M iGPU + Ryzen AI NPU (ROCm capable) |
| OS | Ubuntu 24.04 LTS |
| Role | All services, AI inference, compliance stack, data storage |

### 1.2 Legion Pro 5 — Developer Terminal

| Spec | Value |
|------|-------|
| CPU | Intel i7-14700HX |
| RAM | 16 GB |
| OS | Windows 11 + WSL2 Ubuntu 24.04 |
| Role | Developer terminal only — Claude Code, git, SSH to GMKtec |
| Constraint | No production services run here |

**Important:** All production services, AI models, and data reside exclusively on GMKtec. The Legion is a thin terminal. This satisfies FCA DORA data residency obligations — no customer data leaves the regulated compute perimeter.

---

## 2. Service Inventory

### 2.1 Complete Port Map

| Service | Internal Port | External Port | Protocol | License | Status |
|---------|--------------|--------------|----------|---------|--------|
| Ollama | 11434 | — (internal) | HTTP | MIT | Active |
| OpenClaw moa-bot | 18789 | 18789 | Telegram/HTTP | Commercial | Active |
| OpenClaw ctio-bot | 18791 | 18791 | Telegram/HTTP | Commercial | Active |
| OpenClaw @mycarmibot | 18793 | 18793 | Telegram/HTTP | Commercial | Active |
| FastAPI compliance | 8093 | — (nginx) | HTTP | Proprietary | Active |
| Moov Watchman | 8084 | — (internal) | HTTP | Apache 2.0 | Active |
| Banxe Screener | 8085 | — (internal) | HTTP | Proprietary | Active |
| Jube TM | 5001 | — (internal) | HTTP | AGPLv3 | Active |
| Marble API | 5002 | — (internal) | HTTP | ELv2 | Active |
| Marble UI | 5003 | — (nginx) | HTTP | ELv2 | Active |
| ClickHouse (TCP) | 9000 | — (internal) | TCP | Apache 2.0 | Active |
| ClickHouse (HTTP) | 8123 | — (internal) | HTTP | Apache 2.0 | Active |
| PostgreSQL (compliance) | 5432 | — (internal) | TCP | PostgreSQL | Active |
| PostgreSQL (Jube) | 15432 | — (internal) | TCP | PostgreSQL | Active |
| PostgreSQL (Marble) | 15433 | — (internal) | TCP | PostgreSQL | Active |
| Redis | 6379 | — (internal) | TCP | BSD | Active |
| Redis (Jube) | 16379 | — (internal) | TCP | BSD | Active |
| PII Proxy (Presidio) | 8089 | — (internal) | HTTP | MIT | Active |
| Deep Search | 8088 | — (internal) | HTTP | Proprietary | Active |
| Auto-Verify API | 8094 | — (internal) | HTTP | Proprietary | Active |
| n8n | 5678 | — (nginx) | HTTP | Fair-code | Active |
| nginx | 443/80 | 443/80 | HTTPS/HTTP | MIT | Active |
| Firebase Emulator (auth) | 9099 | — (internal) | HTTP | Apache 2.0 | Active |
| Firebase Emulator (UI) | 4000 | — (internal) | HTTP | Apache 2.0 | Active |
| Midaz (LerianStudio) | 8095 | — (internal) | HTTP | Apache 2.0 | Deploying |
| Yente (OpenSanctions) | 8086 | — (internal) | HTTP | MIT | Planned Phase 3 |

**Excluded:** GUIYON (:18794) — separate project, absolute isolation (I-18).

### 2.2 Ollama Models

| Model | Size | Role | Agent |
|-------|------|------|-------|
| qwen3-banxe-v2 | ~30b-a3b | supervisor, kyc, compliance, risk, crypto | MLRO bot (primary) |
| glm-4.7-flash-abliterated | — | client-service, operations, it-devops | CTIO bot |
| gpt-oss-derestricted:20b | — | analytics, finance | Analytics agent |

---

## 3. Storage Layout

All persistent data resides under `/data/` on GMKtec NVMe:

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
| Legion (WSL2) | GMKtec | 2222 | SSH key, alias `ssh gmktec` |
| Claude Code | GMKtec | 2222 | Via Legion terminal |

---

## 5. Process Management

### 5.1 Systemd Services

| Service | Unit File | User | Managed By |
|---------|-----------|------|-----------|
| Ollama | ollama.service | banxe | systemd |
| OpenClaw moa-bot | openclaw-moa.service | root | systemd |
| OpenClaw ctio-bot | openclaw-ctio.service | root | systemd |
| FastAPI compliance | banxe-compliance.service | banxe | systemd |
| PII Proxy | pii-proxy.service | banxe | systemd |

### 5.2 Docker Compose Stacks

| Stack | Directory | Key Services |
|-------|-----------|-------------|
| banxe-compliance | /data/banxe-stack/compliance/ | Watchman, Screener, Jube, Presidio |
| banxe-marble | /data/banxe-stack/marble/ | Marble API, Marble UI, Firebase, PostgreSQL (Marble) |
| banxe-clickhouse | /data/banxe-stack/clickhouse/ | ClickHouse |
| banxe-n8n | /data/banxe-stack/n8n/ | n8n |
| banxe-midaz | /data/banxe-stack/midaz/ | Midaz (deploying) |

### 5.3 Cron Jobs (GMKtec)

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

- All secrets (API keys, tokens, passwords) stored exclusively in `/data/banxe/.env` on GMKtec
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
