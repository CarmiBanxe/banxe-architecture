# Runbook — Allocator Redis AUTH (vault channel)

**Created:** 2026-08-04 | **Status:** ACTIVE | **Owner plane:** fabric / operator
**Refs:** ADR-143, ADR-143-A, ADR-143-B, `docs/runbooks/EVO1-ALLOCATOR-STABILITY-2026-08-02.md`,
advisory "allocator-redis-auth fork A/B/C" (verdict B, 2026-08-04), IL-827 precedent.

## What this covers

The shared IL allocator (`banxe:il:counter`, evo1 `100.68.102.48:6379`) requires a
password (`requirepass`). This runbook fixes how that secret is stored, verified,
and rotated, and which preflight checks guard minting.

**What changed (D1/D2/D3 closure):**

- `scripts/preflight.sh` (NEW) — authenticated PING via the vault channel; a bare
  TCP-open check is no longer considered a passing preflight.
- `scripts/add-il-shard.sh` — after the TCP gate, an AUTH probe runs before any
  mint work; NOAUTH/WRONGPASS → exit 4, missing vault → exit 5, with clear messages.
- This runbook (NEW) — single documented procedure for provisioning and rotation.

**Why:** on 2026-08-02..04 a TCP-only preflight passed while AUTH failed, so mints
died later with opaque errors (D1/D2). No procedure existed for placing or rotating
the password (D3).

## Source of truth (SoT)

| Item | Location |
|------|----------|
| Password SoT | `requirepass` in `/home/banxe/redis.conf` on **evo1** (mounted read-only into the container at `/etc/redis/redis.conf`) |
| Per-node secret copy | vault file `~/banxe-fabric/.vault/redis.pass`, `chmod 600`, owner = the terminal user |
| Connection config | `ledger/build_ledger.py::_redis_config()` — env `REDIS_HOST` / `REDIS_PORT` / `REDIS_PASS_FILE`, defaults evo1 `100.68.102.48:6379` and the vault path above |
| Auth client | `fabric/common/fabric_redis.py` (`RedisStreams`) — reads the vault file only; never argv, never env, never logged; fail-closed (`RedisUnavailable`) |
| Preflight probe | `fabric/common/redis_auth_probe.py` (used by `scripts/preflight.sh` and `scripts/add-il-shard.sh`) |

## The vault channel is the ONLY secret channel

**Forbidden:** passing the allocator password via environment variables
(`BANXE_REDIS_PASSWORD`, `REDISCLI_AUTH`, `REDIS_PASSWORD`, …), on argv, in shell
history, in logs, or in any committed file. Env values leak via `/proc/<pid>/environ`,
are inherited by every child process, and surface in `ps`/journalctl dumps.
`REDIS_PASS_FILE` is allowed — it carries a *path*, never the secret itself.

**Known legacy deviation (flagged, out of scope here):**
`tools/factory/factory-preflight.sh` still sources `~/banxe-dev/redis-evo1.env`
(`REDISCLI_AUTH` + `redis-cli`). That is the env path this runbook forbids; migrating
it to the vault probe is a separate operator-gated task — do not copy that pattern.

## Procedure: provision a new node

1. Create the directory and file (as the terminal user, never root-owned):
   `install -d -m 700 ~/banxe-fabric/.vault`
2. Place the password into `~/banxe-fabric/.vault/redis.pass` **without** echoing it
   in shell history (e.g. paste into the editor, or copy the file over an encrypted
   channel from an existing node). Trailing newline is tolerated (client strips it).
3. `chmod 600 ~/banxe-fabric/.vault/redis.pass`
4. Verify without exposing the value: `bash scripts/preflight.sh`
   → expect `redis-auth-probe: OK — AUTH+PING … banxe:il:counter=<n>`.

## Procedure: rotate the password

Rotation is operator-driven (secret rotation during an incident requires
co-ordination per `.claude/rules/95-incidents.md`).

1. Generate the new value; update `requirepass` in `/home/banxe/redis.conf` on evo1.
2. Restart/reload `banxe-redis` on evo1 (config is mounted read-only — a container
   restart is required for it to take effect).
3. Update the vault file on **every** fabric node (mark-legion, evo2, …) per the
   provisioning steps above. Until a node is updated, its probes fail with exit 4 —
   loud and explicit, no silent degradation.
4. Verify from each node: `bash scripts/preflight.sh` → exit 0.
5. Record the rotation as an IL shard (no secret values in the shard body).

## Verification / diagnostics

| Command | Meaning of result |
|---------|-------------------|
| `bash scripts/preflight.sh` | 0 = AUTH+PING OK; 3 = unreachable (network/load — retryable); 4 = AUTH rejected (fix vault sync, do NOT retry); 5 = vault file missing/unreadable/empty |
| `sha256sum ~/banxe-fabric/.vault/redis.pass` | Compare digests across nodes without revealing the value |
| `bash scripts/add-il-shard.sh …` | Runs TCP gate + the same AUTH probe before minting; exits 3/4/5 as above |

## Risks if this doc is wrong or stale

Wrong SoT pointer → operators "rotate" the wrong file and lock every terminal out of
minting (exit 4 fleet-wide). Stale prohibition list → the env path quietly returns
and the secret leaks into process listings. Keep this runbook in the same PR as any
change to the auth plane (`.claude/rules/40-docs.md`).

## Rollback

The preflight layer is additive: reverting the PR that introduced
`scripts/preflight.sh`, the `add-il-shard.sh` probe block, and this runbook restores
the previous TCP-only behaviour with no data or schema impact. The vault files and
`requirepass` themselves are untouched by that revert.
