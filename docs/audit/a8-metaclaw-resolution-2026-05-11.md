# A-8 MetaClaw LiteLLM — Investigation & Resolution
**Date:** 2026-05-11
**Author:** ADR-035 Comet Sub-terminal A, Part 4
**Status:** RESOLVED — non-canonical process stopped, finding closed

---

## 1. Discovery

Finding A-8 was logged during Part 2 pool audit (2026-05-11):
```
ss -tlnp | grep :4000
LISTEN  0  2048  0.0.0.0:4000  0.0.0.0:*  users:(("python",pid=71814,fd=14))
```
A second `litellm` process was listening on all interfaces, not systemd-managed.

---

## 2. Process Identification

| Field | Value |
|---|---|
| PID | 71814 |
| Owner | mmber |
| Started | 2026-05-07 (May07 in `ps` output) |
| Uptime at investigation | ~4 days |
| Command | `/home/mmber/.local/bin/litellm --config /home/mmber/MetaClaw/litellm/litellm-config.v2.yaml --port 4000 --host 0.0.0.0` |
| Binary | `/home/mmber/.local/share/pipx/venvs/litellm/bin/python` (same venv as canonical) |
| Config source | `/home/mmber/MetaClaw/litellm/litellm-config.v2.yaml` |

---

## 3. Config Audit (read-only)

MetaClaw's `litellm-config.v2.yaml` contained **30+ model aliases** for:
- evo1 Ollama (192.168.0.72:11434): `banxe-general`, `qwen3-30b`, `fast`, `glm-4-flash`, `coding`, `gpt-oss-20b`, `ai-heavy`, `factory-*`, `project-*`
- evo2 Ollama (192.168.0.15:11434): duplicate entries for `banxe-general`, `qwen3-30b`, `ai`, `ai-heavy`, `reasoning`, `factory-*`
- evo1 llama-server RPC (192.168.0.72:8081): `large`, `glm-4.5-air-distributed`, `glm-air`
- evo2 qwen3 RPC (192.168.0.15:8082): `reasoning-235b`, `project-reason`
- Legion local Ollama (127.0.0.1:11434): `factory-fast`

**Purpose:** Comprehensive local-model routing gateway for the MetaClaw development session
(started 2026-05-05..07 based on oldest bak files). Config was actively iterated
(12 backup files covering 2026-05-05 through 2026-05-07).

---

## 4. Security Findings

| Finding | Severity | Detail |
|---|---|---|
| Binds to `0.0.0.0:4000` | HIGH | Accessible from all Legion network interfaces (WiFi, LAN, potential external) |
| `master_key: sk-banxe-llm-gateway-2026` hardcoded in config | MEDIUM | Not an env var; visible to anyone who reads the config file |
| Redis cache without `password` | MEDIUM | `cache_params.host: 192.168.0.72` with no `password` field — bypasses the `requirepass` set in Part 2 Redis hardening; cache likely non-functional after Part 2 |
| No guardrails | MEDIUM | Anthropic not configured (no external keys), but no keyword blocking either; if keys were ever added this would be unguarded |
| Not systemd-managed | LOW | Started manually, no restart policy, no journal logging |

---

## 5. Decision: Stop MetaClaw, Keep Canonical Systemd Instance

**Canonical:** systemd `litellm.service` — `~/litellm-config.yaml` — `:8080` — `127.0.0.1` only

Rationale:
1. Canonical binds to `127.0.0.1` only — no external exposure.
2. Canonical uses env vars for all secrets (`os.environ/ANTHROPIC_API_KEY`, `os.environ/REDIS_PASS`).
3. Canonical has Redis cache with `requirepass` (`os.environ/REDIS_PASS`) from Part 2.
4. Canonical is systemd-managed with restart policy and full journal logging.
5. MetaClaw's model routes (evo1, evo2 LAN IPs) are valuable but can be incrementally merged into canonical config — NOT done in Part 4 to keep scope minimal.

---

## 6. Actions Taken

```bash
# 6.1 Archive MetaClaw config (files NOT deleted)
cp /home/mmber/MetaClaw/litellm/litellm-config.v2.yaml \
   /home/mmber/MetaClaw/litellm/litellm-config.v2.yaml.bak-2026-05-11

# 6.2 Stop MetaClaw process gracefully
kill -15 71814

# 6.3 Verified :4000 cleared (only :8080 remains)
ss -tlnp | grep -E ':4000|:8080'
# LISTEN  127.0.0.1:8080  ← canonical only
```

---

## 7. Post-Resolution State

| Port | Process | Status |
|---|---|---|
| :4000 | MetaClaw | STOPPED — port cleared |
| :8080 | Canonical systemd litellm | RUNNING — single canonical endpoint |

**MetaClaw files preserved** at `/home/mmber/MetaClaw/litellm/` — not deleted.
If MetaClaw routes are needed again, they should be merged into canonical config
via a separate Part (see Part 5+ roadmap).

---

## 8. Residual Items

| Item | Action |
|---|---|
| MetaClaw evo2 LAN routes (`192.168.0.15:*`) | Do NOT add to canonical until Part 5 evo2 onboarding |
| MetaClaw RPC routes (`:8081`, `:8082`) | Assess in Step 3 (model deduplication) |
| MetaClaw glm-4.5-air route | Requires llama-server on evo1 to be running — separate item |
| MetaClaw `factory-fast` (Legion local Ollama) | Can be added to canonical if Legion Ollama is deployed |

**A-8 closed.** Canonical endpoint is now the sole LiteLLM gateway on Legion.
