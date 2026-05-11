# Runbook: Redis 7 on evo1 (Docker, Hardened)
# ADR-035 ROADMAP Part 2 / Step 4
# Date: 2026-05-11 | Author: Sub-terminal A

## Overview

Redis 7 deployed as a Docker container on evo1 with:
- `--network host` (access to all evo1 interfaces)
- Bind: `127.0.0.1 192.168.0.72 100.68.102.48` (localhost + LAN + Tailscale only)
- `requirepass` set via 48-char random hex secret
- Persistence: AOF appendonly
- Dangerous commands disabled: CONFIG, FLUSHALL, FLUSHDB, DEBUG
- maxmemory: 2 GB with allkeys-lru eviction

## Prerequisites

- evo1 running Docker
- `redis:7` image available (pre-pulled)
- Password stored at `~/banxe-dev/redis-evo1.env` on Legion (chmod 600)

## Installation Steps (performed 2026-05-11)

### 1. Generate password (Legion)
```bash
REDIS_PASS=$(openssl rand -hex 24)
echo "REDIS_PASS=$REDIS_PASS" > ~/banxe-dev/redis-evo1.env
chmod 600 ~/banxe-dev/redis-evo1.env
```

### 2. Push redis.conf to evo1
```bash
REDIS_PASS=$(grep REDIS_PASS ~/banxe-dev/redis-evo1.env | cut -d= -f2)
cat << EOF | ssh evo1 'cat > /home/banxe/redis.conf'
bind 127.0.0.1 192.168.0.72 100.68.102.48
protected-mode yes
port 6379
requirepass ${REDIS_PASS}
appendonly yes
appendfsync everysec
dir /data
maxmemory 2gb
maxmemory-policy allkeys-lru
rename-command CONFIG ""
rename-command FLUSHALL ""
rename-command FLUSHDB ""
rename-command DEBUG ""
EOF
ssh evo1 'mkdir -p /home/banxe/redis-data'
```

### 3. Start container
```bash
ssh evo1 '
docker run -d \
  --name banxe-redis \
  --network host \
  --restart unless-stopped \
  -v /home/banxe/redis.conf:/etc/redis/redis.conf:ro \
  -v /home/banxe/redis-data:/data \
  redis:7 redis-server /etc/redis/redis.conf
'
```

### 4. Verify
```bash
# From evo1 localhost
ssh evo1 "docker exec banxe-redis redis-cli -a '$REDIS_PASS' ping"  # PONG

# From Legion via Tailscale
python3 -c "
import socket
s = socket.socket(); s.settimeout(3)
s.connect(('100.68.102.48', 6379))
s.send(b'*2\r\n\$4\r\nAUTH\r\n\$48\r\n<REDIS_PASS>\r\n')
print(s.recv(64))
s.close()
"
```

## Current State (as of 2026-05-11)

| Metric            | Value                     |
|-------------------|---------------------------|
| Container         | banxe-redis               |
| Status            | Up, restart=unless-stopped |
| Network           | host                      |
| Bind              | 127.0.0.1 192.168.0.72 100.68.102.48 |
| Port              | 6379                      |
| Auth              | requirepass (48-char hex) |
| Persistence       | AOF appendonly            |
| Data dir          | /home/banxe/redis-data    |
| maxmemory         | 2 GB                      |

## evo1 Network Interfaces (reference)

| Interface | IP             | Type      |
|-----------|----------------|-----------|
| eno1      | 192.168.0.72   | LAN wired |
| wlp195s0  | 192.168.0.117  | LAN WiFi  |
| tailscale0 | 100.68.102.48 | Tailscale |

**Only eno1 (192.168.0.72) and tailscale0 (100.68.102.48) are bound.**
WiFi interface (192.168.0.117) is deliberately excluded.

## Restart / Recovery

```bash
# If container stopped:
ssh evo1 'docker start banxe-redis'

# Full rebuild (password already in env):
REDIS_PASS=$(grep REDIS_PASS ~/banxe-dev/redis-evo1.env | cut -d= -f2)
# Re-run steps 2–4 above

# Check logs:
ssh evo1 'docker logs banxe-redis --tail 20'

# Check AOF persistence:
ssh evo1 'ls -lh /home/banxe/redis-data/'
```

## Security Notes

- Password stored ONLY on Legion at `~/banxe-dev/redis-evo1.env` (chmod 600) and in
  `~/.config/litellm/.env` as `REDIS_PASS=...`
- Never commit either file to git
- `rename-command` disables CONFIG/FLUSHALL/FLUSHDB/DEBUG to prevent remote manipulation
- Protected-mode prevents unauthenticated access from non-bound interfaces
- No /data/kyc, /data/transactions, /data/aml paths are mounted or accessible from this container

## Invariants

| Invariant | Check |
|-----------|-------|
| I-02 | No sanctioned-jurisdiction access — evo1 is on-prem UK |
| I-24 | Redis stores LiteLLM cache only — not audit trail data |
| I-27 | No autonomous agent can flush the cache (FLUSHALL disabled) |

