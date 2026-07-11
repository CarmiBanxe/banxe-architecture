# RUNBOOK: BANXE Private Legion Engine — OpenManus Bring-Up
# Artifact status: OPERATOR HITL — all commands below are OPERATOR-executed only.
# Branch: agent/factory/private-engine/openmanus-config
# Created: 2026-07-11
# Single-writer canon (I-71): factory prepares; operator executes.

---

## Context

- **Private Engine:** OpenManus powerful autonomous agent (browser/bash/search/code) on Legion machine.
  This is a MULTI-LAYER engine — NOT a light single-model assistant.
- **Active tier (default):** `qwen3-30b` (Tier 2 — qwen3:30b-a3b on evo2, 30B MoE via LiteLLM :4000).
- **Available tiers via LiteLLM :4000:**
  - Tier 1 (local, Legion GPU): `qwen2.5-coder:7b-instruct-q4_K_M` via `127.0.0.1:11434` — 4.7GB VRAM, fits 8GB RTX 4070.
  - Tier 2 (default, remote): `qwen3-30b` / `project-mid` → evo2 (18GB VRAM model).
  - Tier 3 (heavy, remote): `reasoning` / `reasoning-235b` → evo1/evo2 (up to 235B MoE).
  - Tier 4 (coding, remote): `coding` / `factory-coder` → evo2.
- **VRAM constraint:** Legion RTX 4070 Laptop = 8GB VRAM. Only ≤7B fits locally. 30B–235B MUST be remote.
- **Backend:** LiteLLM :4000 → evo2 primary + evo1 (100.68.102.48) ONLINE as failover. IPv4 only (`127.0.0.1:4000`). No separate llama-server :8080.
- **Isolation:** Legion Private Engine is NOT connected to banking ledger. DLP boundary enforced per ADR-103 / Correction 4.
- **API endpoint after launch:** `POST http://localhost:8000/run/agent`, `GET http://localhost:8000/health`
- **`banxe-general` is BANNED here** — reserved for Banking Engine only.
- **NOTE:** The source blueprint `manus-legion-private-engine.md` references uncensored/abliterated models on llama-server :8080. Those are NOT used. This engine uses LiteLLM :4000 with standard models only.

---

## Phase 0 — Pre-flight (operator verifies, no changes yet)

```bash
# 1. LiteLLM up?
systemctl is-active litellm-lan-gateway

# 2. evo2 reachable + qwen3-30b present?
curl -s http://192.168.0.15:11434/api/tags | jq '[.models[].name]' | grep qwen3

# 3. LiteLLM primary alias "qwen3-30b" present?
curl -s -H "Authorization: Bearer sk-banxe-llm-gateway-2026" \
  http://127.0.0.1:4000/v1/models | jq '[.data[].id]' | grep qwen3-30b

# 3a. evo1 failover reachable?
curl -s http://100.68.102.48:11434/api/tags | jq '[.models[].name]' | head -5

# 3b. Heavy tier alias present (optional pre-flight)?
curl -s -H "Authorization: Bearer sk-banxe-llm-gateway-2026" \
  http://127.0.0.1:4000/v1/models | jq '[.data[].id]' | grep -E "reasoning|qwen3-30b|coding"

# 4. Port :8000 free?
ss -tlnp | grep :8000
# Expected: no output (port free)

# 5. No existing OpenManus install?
ls ~/OpenManus 2>&1
# Expected: ls: cannot access '~/OpenManus': No such file or directory
```

---

## Phase 1 — Install OpenManus (operator-executed)

```bash
# Clone OpenManus — single-writer action
git clone https://github.com/FoundationAgents/OpenManus.git ~/OpenManus

# Create isolated venv
python3 -m venv ~/OpenManus/.venv

# Install dependencies
~/OpenManus/.venv/bin/pip install -r ~/OpenManus/requirements.txt

# Confirm api_server.py exists (OpenManus exposes FastAPI on :8000)
ls ~/OpenManus/api_server.py
```

---

## Phase 2 — Config deployment (operator-executed)

```bash
# Create config directory
mkdir -p ~/OpenManus/config

# Copy the artifact config.toml prepared in this branch:
# File: docs/ops/legion-private-engine/config.toml (this repo)
# Destination: ~/OpenManus/config/config.toml
cp <path-to-this-repo>/docs/ops/legion-private-engine/config.toml \
   ~/OpenManus/config/config.toml

# DLP VERIFICATION — operator must confirm no banking credentials present:
grep -E "postgres|IBAN|password|banking|prod_key" ~/OpenManus/config/config.toml
# Expected: no output
```

---

## Phase 3 — Systemd unit deployment (operator-executed)

```bash
# Copy draft unit (prepared in this branch):
# File: docs/ops/legion-private-engine/banxe-private-engine.service
sudo cp <path-to-this-repo>/docs/ops/legion-private-engine/banxe-private-engine.service \
        /etc/systemd/system/banxe-private-engine.service

sudo systemctl daemon-reload

# Enable and start — HITL STOP: confirm all Phase 0-2 checks are GREEN first
sudo systemctl enable banxe-private-engine
sudo systemctl start banxe-private-engine

# Check status
sudo systemctl status banxe-private-engine
```

---

## Phase 4 — Verification (post-launch)

```bash
# 1. Service up?
systemctl is-active banxe-private-engine
# Expected: active

# 2. Health endpoint responds?
curl -s http://localhost:8000/health
# Expected: {"status": "ok"} or similar

# 3. LiteLLM round-trip (via OpenManus)?
curl -s -X POST http://localhost:8000/run/agent \
  -H "Content-Type: application/json" \
  -d '{"task": "echo test — reply with OK only"}' | jq .
# Expected: {"result": "OK"} or similar — confirms evo2 path works end-to-end

# 4. Confirm :8000 bound to localhost only (not 0.0.0.0):
ss -tlnp | grep :8000
# If bound 0.0.0.0: add ufw rule or review OpenManus bind config before proceeding.

# 5. No banking data in agent logs:
sudo journalctl -u banxe-private-engine --since "1 minute ago" | \
  grep -E "IBAN|postgres|customer_id|kycId" | wc -l
# Expected: 0
```

---

## DLP Boundary Reminders (operator canonical reference)

Per ADR-103 + Consultant Correction 4:

| Allowed in Private Engine config | BLOCKED |
|----------------------------------|---------|
| LiteLLM :4000 master key | Banking Postgres password |
| Model aliases (qwen3-30b / reasoning / coding) | Customer PII (IBAN, names, KYC IDs) |
| Research/dev tasks | Any compliance write operation |
| Read-only banking status (logged) | Banking ledger write |

---

## Rollback

```bash
sudo systemctl stop banxe-private-engine
sudo systemctl disable banxe-private-engine
sudo rm /etc/systemd/system/banxe-private-engine.service
sudo systemctl daemon-reload
# OpenManus directory remains for inspection; remove manually if needed:
# rm -rf ~/OpenManus
```

---

## Advanced — Tier-switching and Per-task Model Selection

OpenManus config.toml supports only `[llm]` + `[llm.vision]` — no named per-agent profiles.
To switch the active tier, the operator edits `config.toml` and restarts the service.

**Quick tier-switch commands (operator-only):**

```bash
# Activate Tier 3 heavy (reasoning) for deep planning session:
sed -i 's/^model\s*=\s*"qwen3-30b"/model       = "reasoning"/' ~/OpenManus/config/config.toml
sudo systemctl restart banxe-private-engine

# Restore Tier 2 default:
sed -i 's/^model\s*=\s*"reasoning"/model       = "qwen3-30b"/' ~/OpenManus/config/config.toml
sudo systemctl restart banxe-private-engine

# Activate Tier 4 coding:
sed -i 's/^model\s*=\s*"qwen3-30b"/model       = "coding"/' ~/OpenManus/config/config.toml
sudo systemctl restart banxe-private-engine
```

**For programmatic per-task routing (future enhancement):**
Wrap `api_server.py` to accept an optional `model_tier` field in the request body,
then override `llm.model` before calling `Manus.create()`. This avoids config file
edits but requires patching the agent runner. Document in a follow-up factory task.

---

## References

- Config artifact: `docs/ops/legion-private-engine/config.toml` (this repo)
- Systemd artifact: `docs/ops/legion-private-engine/banxe-private-engine.service` (this repo)
- DLP boundary: ADR-103 (banxe-architecture/docs/adr/)
- Consultant Correction 4: `docs/sources/BANXE-Private-Legion-Engine-Otvety-Konsultanta-2026-07-10.md`
- LiteLLM config: `/home/mmber/MetaClaw/litellm/litellm-config.v2.yaml`
- Blueprint (superseded on llama-server :8080): `MetaClaw/docs/sources/manus-legion-private-engine.md`
