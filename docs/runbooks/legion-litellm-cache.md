# Runbook: LiteLLM Semantic Cache via Redis (Legion)
# ADR-035 ROADMAP Part 2 / Step 4
# Date: 2026-05-11 | Author: Sub-terminal A

## Overview

Legion's LiteLLM proxy (`:8080`) is wired to Redis on evo1 (`100.68.102.48:6379`)
as a semantic response cache. Identical prompts are served from Redis in < 1 ms
instead of hitting upstream providers.

## Config Changes Made (2026-05-11)

### ~/litellm-config.yaml — additions

**Environment variables block:**
```yaml
environment_variables:
  # existing ...
  REDIS_PASS: os.environ/REDIS_PASS   # ← added
```

**litellm_settings block:**
```yaml
litellm_settings:
  drop_params: true                   # existing
  cache: true                         # ← added
  cache_params:
    type: redis
    host: 100.68.102.48               # evo1 Tailscale IP
    port: 6379
    password: os.environ/REDIS_PASS
    ttl: 3600                         # 1 hour
    supported_call_types: ["completion", "acompletion", "embedding"]
```

### ~/.config/litellm/.env — additions
```
REDIS_PASS=<48-char hex>              # ← added (sourced from ~/banxe-dev/redis-evo1.env)
```

### Stale config archived
```
~/litellm_config.yaml  →  ~/litellm_config.yaml.bak-2026-05-11
```
(Previous .bak.20260501 file was already present.)
The **canonical active config** is `~/litellm-config.yaml` (hyphenated).

## Verification

### Cache miss → cache hit pattern
```bash
MASTER_KEY=$(grep LITELLM_MASTER_KEY ~/.config/litellm/.env | cut -d= -f2)
PAYLOAD='{"model":"groq/llama-3.3-70b","messages":[{"role":"user","content":"say BANXE"}],"max_tokens":5}'

# Call 1 — miss, goes to Groq (takes ~300–800ms)
curl -s -D - http://127.0.0.1:8080/v1/chat/completions \
  -H "Authorization: Bearer $MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" | grep -iE "x-litellm-response-duration|x-litellm-cache"

# Call 2+ — hit, served from Redis (<1ms)
curl -s -D - http://127.0.0.1:8080/v1/chat/completions \
  -H "Authorization: Bearer $MASTER_KEY" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" | grep -iE "x-litellm-response-duration|x-litellm-cache"
```

**Expected output on call 2+:**
```
x-litellm-cache-key: dc21a1ffa3...
x-litellm-response-duration-ms: 0.65    ← sub-1ms = cache hit
```

### Redis key count
```bash
python3 -c "
import socket
REDIS_PASS = open('/dev/stdin').read().strip()
import subprocess, os
REDIS_PASS = subprocess.check_output(
    ['bash','-c','grep REDIS_PASS ~/banxe-dev/redis-evo1.env | cut -d= -f2'],
    text=True).strip()
s = socket.socket(); s.settimeout(3)
s.connect(('100.68.102.48', 6379))
s.send(f'*2\r\n\$4\r\nAUTH\r\n\${len(REDIS_PASS)}\r\n{REDIS_PASS}\r\n'.encode())
s.recv(64)
s.send(b'*1\r\n\$6\r\nDBSIZE\r\n')
print('Keys in Redis:', s.recv(64).decode().strip())
s.close()
"
```

## Known Issues / Flags

### FLAG: Second LiteLLM instance at :4000
During audit, a second litellm process was found (PID 71814):
```
/home/mmber/.local/bin/litellm --config MetaClaw/litellm/litellm-config.v2.yaml
  --port 4000 --host 0.0.0.0
```
- This instance binds to `0.0.0.0` — potential external exposure
- It is NOT managed by the `litellm.service` systemd unit
- It is NOT wired to Redis cache
- **Action required:** investigate MetaClaw service ownership and consider
  restricting to `--host 127.0.0.1` or adding to systemd with proper management

### FLAG: litellm-config.v2.yaml not audited
`~/MetaClaw/litellm/litellm-config.v2.yaml` content was not read (outside scope).
Ensure it does not route compliance/KYC/AML content to non-compliant backends.

## LiteLLM Service Reference

| Setting      | Value                              |
|--------------|------------------------------------|
| Config       | ~/litellm-config.yaml              |
| Port         | 8080 (127.0.0.1 only)              |
| Auth         | LITELLM_MASTER_KEY (env)           |
| Env file     | ~/.config/litellm/.env             |
| Systemd unit | ~/.config/systemd/user/litellm.service |

```bash
# Restart
systemctl --user restart litellm

# Status
systemctl --user status litellm

# Logs
journalctl --user -u litellm -n 50 --no-pager
```

## TTL and Eviction

- Cache TTL: 3600 seconds (1 hour) — LiteLLM-level
- Redis maxmemory: 2 GB with allkeys-lru
- Dangerous flush commands disabled on Redis (FLUSHALL, FLUSHDB renamed to "")

