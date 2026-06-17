# gate.exec activation — Legion execution gate, LOW-RISK only (F1.5 stage-3, ADR-104 §3)

<!-- Source: docs/runbooks/gate-exec-stage3-2026-06-17.md | Date: 2026-06-17 | Implements: ADR-104 §3 (gate chain) + §5 (failover) | extends: gate-services-dry-run, bus-redis-streams | IL: pending-shard -->

## Status

**FIRST REAL EXECUTION — narrowly scoped.** Stage-3 activates `gate.exec` (the Legion
execution node) to **really execute, but ONLY a low-risk idempotent allow-list**
(`read.health`, `status.read`, `fabric.ping`). **Nothing risky/money/orders executes:**
risky classes (payment/withdraw/trade/transfer/custody/key-ops) require a human **HITL
token** and are still **REFUSED** in stage-3 (not in the allow-list). `deny-by-default` +
`fail-closed` preserved. Operator authorized "go stage-3". The controlled smoke ran
co-located on evo1 (vault present); the **role-correct Legion deploy = OPERATOR ACTION**.

## 1. gate_exec.py — final (`fabric/legion/gate_exec.py`)

Self-contained stdlib; acts **only** on an evo1 `gate.policy` verdict. Decision order
(fail-closed at each step):

1. no valid verdict / `correlation_id` missing/invalid → **REFUSE**
2. `correlation_id` mismatch (action vs verdict) → **REFUSE**
3. verdict not `allowed`+`compliant` (incl. fabric-degraded §5) → **REFUSE**
4. `requires_hitl` and no human HITL token → **REFUSE**
5. `action.type` ∉ `low-risk-allowlist.json` → **REFUSE** (risky real exec = later stage)
6. `GATE_EXEC_ENABLED=false` → **DRY-RUN** `WOULD_EXECUTE` (runs nothing)
7. else → **EXECUTE** the idempotent read handler; audit to `fabric:exec`.

- `GATE_EXEC_ENABLED` **defaults to `false`** in code; activation is via the systemd unit
  (operator). `LOW_RISK_ALLOWLIST` is Config-as-Data (`low-risk-allowlist.json`).
- **HITL confirm channel:** a human writes `<HITL_TOKEN_DIR>/<correlation_id>.confirm`. **The
  factory never creates tokens.**
- **Audit:** every decision → `fabric:exec` stream (`correlation_id` carried) via an injected
  sink (smoke uses `fabric_redis`; Legion prod wires a vault-backed sink — OPERATOR ACTION).

## 2. Controlled smoke — ONE low-risk action executed for real (e2e)

`reasoning(evo2) → policy(evo1) → exec(gate_exec REAL)`, one `correlation_id`:

| Step | Result |
|---|---|
| reasoning (evo2 :9208) | `up` |
| policy (evo1 :9110) | `allowed=true, requires_hitl=false` (allow-list `read.health`) |
| **exec (Legion)** | **`EXECUTED` (executed=true)** — idempotent read, `observed_status=up` |
| correlation_id | consistent across all 3 steps |
| audit | `fabric:exec` entry `decision=EXECUTED` |

**Only this idempotent read ran. No risky/money/order action executed.**

## 3. Negative controls — all REFUSED (real)

| Case | policy | exec |
|---|---|---|
| `payment` risky, **no HITL** | allowed + requires_hitl | **REFUSED** — fail-closed: no HITL token |
| `foo.bar` unknown | **deny-by-default** | **REFUSED** — policy denied |
| **no verdict** | — | **REFUSED** — fail-closed |
| `payment` under **degraded fabric** (§5) | **allowed=false** (risky blocked) | **REFUSED** — policy denied |
| **defense-in-depth:** synthetic `allowed+no-hitl` risky verdict | (bypassed) | **REFUSED** — `payment` ∉ low-risk allow-list |

The defense-in-depth case proves the executor's allow-list is a **hard final gate**
independent of policy — risky never executes in stage-3 even if a verdict slipped through.

## 4. Failover (ADR-104 §5)

evo2 down ⇒ fabric `degraded` ⇒ gate.policy returns `allowed=false` for risky ⇒ gate.exec
**REFUSES** (low-risk idempotent reads still proceed). Verified (degraded `FABRIC_STATUS_URL`,
real evo2 untouched).

## 5. OPERATOR ACTION — activate on Legion (exact commands; factory did NOT run these)

The factory does **not** start a prod service on Legion. Using `fabric/legion/gate-exec.service`
(template — adjust `<USER>`/paths):

```bash
mkdir -p ~/.config/systemd/user ~/banxe-fabric/legion ~/banxe-fabric/hitl
cp gate_exec.py low-risk-allowlist.json ~/banxe-fabric/legion/
cp gate-exec.service ~/.config/systemd/user/         # edit <USER>/paths first
loginctl enable-linger "$USER"
systemctl --user daemon-reload
systemctl --user enable --now gate-exec.service      # activates GATE_EXEC_ENABLED=true (low-risk only)
```

This closes **GAP-G3** (Legion = sole execution gate) for the low-risk allow-list. `fabric:exec`
audit on Legion needs a Legion-side redis vault (mode 600, operator-provisioned) or audit
routed via evo1 — the factory never transfers the secret.

## 6. OPERATOR ACTIONS / future stages (HITL / sudo / secret — NOT done by the factory)

1. **Legion vault** for `fabric:exec` audit (or evo1-routed audit).
2. **Stream-consumer entrypoint** — long-running `gate.exec` consuming `fabric:gate`/verdicts
   from redis (`Type=simple`), instead of the `oneshot` stdin form (stage-3.1).
3. **Risky execution (later stage)** — adding any risky class to real execution requires a
   separate operator authorization + HITL per action (AUTO>90 / REVIEW 70–90 / BLOCK<70,
   `.claude/rules/agents.md`). Not in stage-3.
4. **Auth-harden** :9108/:9110 before fabric exposure.

## Duplication Audit (ADR-102)

**Coverage:** `fabric/legion/gate_exec.py` (F1.3 dry-run), `gate-services-dry-run` +
`bus-redis-streams` runbooks, `fabric_redis`/`fabric_common`/`gate_policy`, and the repo for
any executor/allow-list implementation.

| Match | Decision | Rationale |
|---|---|---|
| `gate_exec.py` (F1.3 dry-run) | **extend, not duplicate** | Same file finalized: adds the low-risk allow-list, HITL token gate, real idempotent execution + audit. Same fail-closed contract. |
| `gate_policy.py` (F1.3) | **reuse** | gate.exec consumes its verdict; policy unchanged. |
| `fabric_redis` / `fabric_common` (F1.5 s2) | **reuse** | `fabric:exec` audit via the existing redis-streams client + bus; not re-implemented. |
| `.claude/rules/agents.md` HITL thresholds | **keep — governance source** | HITL token gate is consistent with the AUTO/REVIEW/BLOCK model; no new scheme. |
| repo `git ls-files` for executor/allow-list | **none new** | Only the F1.3 `gate_exec.py`; this is its stage-3 finalization. |

**Verdict:** **no duplicate** — finalizes the F1.3 executor and reuses the F1.5 stage-2
bus/redis + gate.policy. **Keep all, no merge/delete.**

## Confirmations

**only ONE low-risk idempotent read executed for real** (`read.health`) · **no
risky/money/order/custody action executed** (all REFUSED, incl. defense-in-depth) · risky →
HITL-required, fail-closed without token · `deny-by-default` + fail-closed preserved ·
gate.exec acts only on a gate.policy verdict · `GATE_EXEC_ENABLED` default `false` in code
(operator/unit activates) · real Legion service start = OPERATOR ACTION (commands given, not
run by factory) · password only from evo1 vault (no-argv); **no secret leaked**; no disabled
redis command; **legacy secrets not touched** · M0–M1.x / `/srv/banxe-legacy` / prod trading /
emi-stack untouched · evo1/evo2 services not stopped.

**Refs:** ADR-104 (§3 gates, §5 failover), ADR-103 (server-only), ADR-102, ADR-059-A;
`docs/runbooks/gate-services-dry-run-2026-06-17.md`, `bus-redis-streams-2026-06-17.md`,
`three-node-execution-fabric-contract.md`, `fabric/legion/gate_exec.py`,
`fabric/legion/low-risk-allowlist.json`, `fabric/legion/gate-exec.service`,
`.claude/rules/agents.md`.
