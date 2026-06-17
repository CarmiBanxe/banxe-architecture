# gate.exec stream-consumer — Legion live node (F1.5 stage-3.1, ADR-104 §3)

<!-- Source: docs/runbooks/gate-exec-stage3.1-consumer-2026-06-17.md | Date: 2026-06-17 | Implements: ADR-104 §3 (gate chain) + §5 (failover) | extends: gate-exec-stage3, bus-redis-streams | IL: pending-shard -->

## Status

**gate.exec is now a live NODE, not a one-shot.** Stage-3 activated `gate_exec.py` but the
unit was `Type=oneshot` (processed one stdin verdict, then exited). Stage-3.1 adds the
long-running **stream-consumer** (`gate_exec_consumer.py`): it `XREADGROUP`s verdicts from
the evo1 `fabric:gate:policy` stream and runs the **unchanged** decision logic per verdict.
**Scope is unchanged:** real execution only for the low-risk idempotent allow-list; risky →
HITL/REFUSE; deny-by-default; fail-closed. The consumer was tested server-side (isolated
streams); the **real Legion service start = OPERATOR ACTION**.

## 1. Consumer entrypoint (`fabric/legion/gate_exec_consumer.py`)

- Connects to evo1 redis (`REDIS_HOST` default `100.68.102.48` tailscale for Legion; password
  from the vault, **no-argv, never logged**) via the shared stdlib RESP client
  `fabric/common/fabric_redis.py`.
- `XGROUP CREATE` (idempotent, `BUSYGROUP→EXISTS`) + `XREADGROUP GROUP gate-exec` on
  `fabric:gate:policy`; for each verdict it reconstructs `action = {type, correlation_id}`
  and calls **`gate_exec.decide(action, verdict, audit_sink)` — the stage-3 rules verbatim**
  (fail-closed; low-risk idempotent allow-list with `idempotent === true` enforced; risky →
  HITL/REFUSE). Each decision is audited to `fabric:exec` with the `correlation_id`; the
  message is `XACK`ed.
- **fail-closed / graceful (§5):** on `RedisUnavailable` it logs `DEGRADED (fail-closed §5)`
  and retries with backoff — **never silent**. No disabled redis command used.

### RESP client extended (reuse, not duplicate)
`fabric_redis.py` (F1.5 s2) gains `xgroup_create` / `xreadgroup` / `xack` on the **same**
client — no second redis implementation. Promoted to `fabric/common/fabric_redis.py` as the
canonical shared client (evo1 runtime copy kept byte-identical).

## 2. Server-side test (isolated streams, no prod execution touched)

Created group `gate-exec` on an **isolated** `fabric:gate:policy-test`, published 3 authentic
gate.policy verdicts, ran the consumer (`GATE_EXEC_ENABLED=true`, isolated `fabric:exec-test`):

| verdict | consumer decision | audit (`fabric:exec-test`) |
|---|---|---|
| `read.health` (allow, no HITL) | **EXECUTED** (executed=true, idempotent read) | `decision=EXECUTED` |
| `payment` (allow, requires_hitl) | **REFUSED** — fail-closed: no HITL token | `decision=REFUSED` |
| `foo.bar` (deny-by-default) | **REFUSED** — policy denied | `decision=REFUSED` |
| (2nd poll, no new msgs) | **idle** — nothing | — |

`correlation_id` carried verdict→exec→audit. Test streams deleted afterward (`DEL`; not a
disabled command). **Only one idempotent read executed; nothing risky/money/order ran.**

## 3. systemd unit — `Type=simple` long-running (no sudo)

`fabric/legion/gate-exec.service` updated to `Type=simple`, `Restart=always`, `RestartSec=5`,
with redis env (`REDIS_HOST=100.68.102.48`, `REDIS_PASS_FILE`=vault, `POLICY_STREAM`/
`EXEC_STREAM`/`EXEC_GROUP`) and `GATE_EXEC_ENABLED=true`. **Vault PATH only — never the password.**

## 4. OPERATOR ACTION — activate on Legion (exact commands; factory did NOT run these)

```bash
mkdir -p ~/.config/systemd/user ~/banxe-fabric/{common,legion,hitl}
cp fabric/common/fabric_redis.py ~/banxe-fabric/common/
cp fabric/legion/{gate_exec.py,gate_exec_consumer.py,low-risk-allowlist.json} ~/banxe-fabric/legion/
cp fabric/legion/gate-exec.service ~/.config/systemd/user/     # edit <USER>/paths
loginctl enable-linger "$USER"
systemctl --user daemon-reload
systemctl --user enable --now gate-exec.service                # activates the consumer (low-risk only)
```

Needs a **Legion-side** redis vault (`~/banxe-fabric/.vault/redis.pass`, mode 600,
operator-provisioned). The factory never transfers the secret. Closes **GAP-G3** (Legion =
sole execution gate) for the low-risk allow-list.

## 5. OPERATOR ACTIONS / future (HITL / sudo / secret — NOT done by the factory)

1. **Risky execution (later stage)** — adding any risky class to real execution = separate
   operator authorization + HITL per action (AUTO>90 / REVIEW 70–90 / BLOCK<70). Not here.
2. **Auth-harden** :9108/:9110 before fabric exposure; consider per-consumer ACL on redis.
3. **Stream trimming** — `XADD MAXLEN`/`XTRIM` retention policy for `fabric:*` streams
   (config-as-data) — operator-tuned.

## Duplication Audit (ADR-102)

**Coverage:** `fabric/legion/gate_exec.py` (stage-3), `fabric_redis.py` (F1.5 s2),
`gate_policy.py`, the stage-3 + bus-redis runbooks, and the repo for any consumer/stream-reader.

| Match | Decision | Rationale |
|---|---|---|
| `gate_exec.py` `decide()` (stage-3) | **reuse, unchanged** | The consumer calls it verbatim — same rules, no fork. |
| `fabric_redis.py` (F1.5 s2 RESP client) | **extend + promote** | Adds `xgroup_create`/`xreadgroup`/`xack` on the same client; promoted to `fabric/common/` as the single canonical copy (evo1 runtime copy byte-identical). No second redis impl. |
| `gate_policy.py` / `fabric:gate:policy` stream | **reuse** | Consumer reads its verdicts; policy unchanged. |
| repo `git ls-files` for a stream consumer | **none** | First consumer entrypoint — new artifact. |

**Verdict:** **no duplicate** — the consumer wraps the unchanged stage-3 `decide()` and reuses
the extended F1.5 RESP client + gate.policy stream. **Keep all, no merge/delete.** The
`fabric_common` cross-node note (§4): the Legion node ships its own copy of `fabric_redis`
because nodes share no filesystem — a deployed artifact, not duplicated logic.

## Confirmations

**scope unchanged** (real exec only low-risk idempotent allow-list; risky → HITL/REFUSE;
deny-by-default; fail-closed) · consumer calls stage-3 `decide()` verbatim · test executed
only ONE idempotent read; nothing risky/money/order ran · password only from vault (no-argv);
**no secret leaked**; no disabled redis command; **legacy secrets not touched** · **real Legion
consumer service NOT started by the factory** (commands provided) · server-side test on
isolated streams (deleted after) · evo1/evo2/redis services not broken; M0–M1.x /
`/srv/banxe-legacy` / prod / emi-stack untouched.

**Refs:** ADR-104 (§3 gates, §5 failover), ADR-103 (server-only), ADR-102, ADR-059-A;
`docs/runbooks/gate-exec-stage3-2026-06-17.md`, `bus-redis-streams-2026-06-17.md`,
`three-node-execution-fabric-contract.md`, `fabric/legion/gate_exec_consumer.py`,
`fabric/common/fabric_redis.py`, `fabric/legion/gate-exec.service`, `.claude/rules/agents.md`.
