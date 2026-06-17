# fabric/legion — Legion execution-node code (ADR-104 §3)

Code that runs on the **Legion** node — the fabric's **only execution gate** per ADR-104.
Authored server-side via the factory (ADR-103) and promoted here so it can be **deployed to
Legion** (the evo1/evo2 node code lives on its own host under `~/banxe-fabric/`).

## `gate_exec.py` — the execution gate (F1.5 stage-3: real low-risk execution)

- Acts **only** on an evo1 `gate.policy` verdict (+ `correlation_id`); it never self-initiates.
- **`GATE_EXEC_ENABLED` defaults to `false`** (DRY-RUN: `WOULD_EXECUTE`, runs nothing). When
  the operator sets it `true` (via the systemd unit), **real execution is restricted to the
  idempotent low-risk allow-list** (`low-risk-allowlist.json`: `read.health`, `status.read`,
  `fabric.ping`).
- **Risky actions** (payment/withdraw/trade/transfer/custody/key-ops) carry `requires_hitl`
  from gate.policy and are **never auto-executed**: without a human **HITL token** → REFUSE;
  even **with** a token → REFUSE (not in the low-risk allow-list — risky real execution is a
  later stage). Defense in depth: the executor allow-list is a hard gate independent of policy.
- **fail-closed REFUSE** when: no valid verdict, `correlation_id` missing/invalid or
  mismatched, verdict not `allowed`/`compliant`, fabric degraded (policy returns
  `allowed=false`), or a handler error.
- Every decision is audited to the `fabric:exec` stream (via an injected sink;
  `correlation_id` carried).
- Self-contained stdlib (zero deps); `correlation_id` format validated, not imported
  (cross-node, no shared FS — §4).

### HITL confirm channel

A human approval = a token file `<HITL_TOKEN_DIR>/<correlation_id>.confirm` created **by a
human** on Legion. **The factory never creates tokens.** Example (operator, after reviewing):

```bash
echo '{"approver":"MLRO","ts":"<utc>"}' > ~/banxe-fabric/hitl/<correlation_id>.confirm
```

(In stage-3 a risky action still REFUSEs even with a token — the allow-list blocks it. The
token mechanism is wired now; risky real execution is a later, separately-authorized stage.)

## `gate_exec_consumer.py` — stream-consumer (F1.5 stage-3.1, the live node)

The long-running entrypoint that makes gate.exec a **node** (not a one-shot). It
`XREADGROUP`s verdicts from the evo1 `fabric:gate:policy` stream (consumer group
`gate-exec`), runs the **unchanged** `gate_exec.decide()` per verdict, and audits each
decision to `fabric:exec`. Reuses `fabric/common/fabric_redis.py` (the shared stdlib RESP
client; vault password, no-argv). **Graceful/fail-closed:** if redis is unavailable it logs
`DEGRADED (fail-closed §5)` and retries with backoff — never silent. Rules are unchanged:
real exec only for the low-risk idempotent allow-list; risky → HITL/REFUSE; deny-by-default.

## OPERATOR ACTION — activate the consumer on Legion (NOT done by the factory)

The factory does **not** start a prod service on Legion. Deploy layout (keep `fabric/common`
beside `fabric/legion`) and activate with the `Type=simple` template `gate-exec.service`
(adjust `<USER>`/paths):

```bash
mkdir -p ~/.config/systemd/user ~/banxe-fabric/{common,legion,hitl}
cp fabric/common/fabric_redis.py ~/banxe-fabric/common/
cp fabric/legion/{gate_exec.py,gate_exec_consumer.py,low-risk-allowlist.json} ~/banxe-fabric/legion/
cp fabric/legion/gate-exec.service ~/.config/systemd/user/     # edit <USER>/paths first
loginctl enable-linger "$USER"
systemctl --user daemon-reload
systemctl --user enable --now gate-exec.service                # <-- activates the consumer
```

The consumer reaches evo1 redis over tailscale (`100.68.102.48:6379`); the password is read
from a **Legion-side** vault (`~/banxe-fabric/.vault/redis.pass`, mode 600, operator-provisioned
the same server-side way) — the factory never transfers the secret.

This closes **GAP-G3** (Legion = sole execution gate) for the low-risk allow-list — see
`docs/runbooks/gate-exec-stage3.1-consumer-2026-06-17.md` (and `gate-exec-stage3-2026-06-17.md`).
