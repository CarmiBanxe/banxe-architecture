# Fabric gate services bring-up — gate.policy (evo1) + gate.exec (Legion) DRY-RUN (F1.3, ADR-104 §3)

<!-- Source: docs/runbooks/gate-services-dry-run-2026-06-17.md | Date: 2026-06-17 | Implements: ADR-104 §3 + three-node-execution-fabric-contract.md §3 | IL: pending-shard -->

## Status

**GATE SERVICES UP — DRY-RUN / DECISION-ONLY.** The canonical fabric action path
`reasoning(evo2) → policy(evo1) → execution(Legion)` (ADR-104 §3) is stood up as services,
but **executes nothing**: `gate.exec` defaults to **`execute_enabled=false`** and only logs
`WOULD EXECUTE: …`. Real activation is **F1.5** (HITL). Done server-side over ssh, **no
sudo for code, no secrets, no prod action**.

## 1. gate.policy — evo1 (decision-only, deny-by-default)

- `~/banxe-fabric/evo1/gate_policy.py` + `policy-config.json` (Config-as-Data), reuses
  `fabric_common` (correlation_id + bus). stdlib-only. Endpoint **:9110**.
- `POST /policy/evaluate` `{correlation_id, action}` → verdict
  `{allowed, compliant, requires_hitl, reason, policy_version}`. `GET /health`.
- **Policy** (`policy-config.json`):
  - **deny-by-default** — any `action.type` not in `allow_list` → `allowed=false`.
  - **allow-list** low-risk idempotent reads (`read.health`, `read.status`, `noop.echo`).
  - **risky classes** (`payment, schema, secret, deploy, merge, delete, shell, git`) →
    `allowed=true` **only with `requires_hitl=true`**.
  - **fail-closed** on missing/invalid `correlation_id`.
- It **DECIDES only — acts on nothing**.

### Verdict demo (live, :9110)

| Action | allowed | compliant | requires_hitl | verdict reason |
|---|---|---|---|---|
| `read.health` | ✅ | ✅ | false | allow-list (risk=low) |
| `payment` | ✅ | ✅ | **true** | risky class — allowed ONLY with HITL |
| `foo.bar` (unknown) | ❌ | ❌ | false | **deny-by-default** |

## 2. gate.exec — Legion (the only execution node, DRY-RUN)

- `fabric/legion/gate_exec.py` (in repo — Legion-destined; see `fabric/legion/README.md`).
  Self-contained stdlib; `correlation_id` format validated, not imported (cross-node, §4).
- **`execute_enabled=false` by default** → logs `WOULD EXECUTE: …` + `correlation_id`,
  **runs nothing**. `decide(action, verdict, hitl_confirmation=None)` →
  `{decision: WOULD_EXECUTE | REFUSED, executed:false, reason, correlation_id}`.
- **fail-closed REFUSE** when: no valid verdict / correlation_id, cid mismatch, not
  allowed/compliant, or `requires_hitl` without confirmation.
- Even `execute_enabled=true` **refuses** real execution — real executor = **F1.5** (defense
  in depth). **Real run on Legion = OPERATOR ACTION.**

## 3. End-to-end chain (dry-run) — one correlation_id across 3 nodes

`fabric_chain_demo.py` on evo1 runs `reasoning(evo2 :9208) → policy(evo1 :9110) →
exec(Legion gate_exec dry-run)`. Verified (all `correlation_id`-consistent across the 3 steps,
nothing executed):

| Case | policy verdict | exec(dry-run) decision |
|---|---|---|
| A `read.health` | allow, no HITL | `WOULD_EXECUTE` (executed=false) |
| B `payment`, no HITL | allow + requires_hitl | **`REFUSED`** — fail-closed: requires_hitl, no confirmation |
| C `payment`, **with HITL** | allow + requires_hitl | `WOULD_EXECUTE` (executed=false; F1.5 to activate) |
| D `foo.bar` | **deny-by-default** | **`REFUSED`** — policy denied |
| E exec with **no verdict** | — | **`REFUSED`** — fail-closed: no valid verdict |

## 4. Failover / safety (ADR-104 §5)

- gate.policy reads fabric status from evo1 control `:9108`. **evo2 down ⇒ fabric degraded**
  ⇒ **risky actions blocked** (`allowed=false`, reason "failover §5: Legion blocks risky");
  low-risk idempotent reads still proceed. **Verified** with a degraded `FABRIC_STATUS_URL`
  (throwaway eval) — risky `payment` → blocked, `read.health` → allowed. Real evo2 **not
  touched**.
- gate.exec is **fail-closed**: no valid policy verdict ⇒ `REFUSED`. No split-brain — an
  action runs only with a live evo1 `allow` for the same correlation_id (and, in F1.5, a live
  Legion executor with `execute_enabled=true`).

## 5. Persistence — systemd user-unit (no sudo)

- `~/.config/systemd/user/evo1-gate-policy.service` (`Restart=always`, `After=evo1-control.service`).
- `systemctl --user enable --now` → **active / enabled**; `Linger=yes` (survives reboot, no
  sudo). Parity with `evo1-control.service` / `evo2-health.service`.

## 6. OPERATOR ACTIONS (HITL / sudo / secret — NOT executed by the factory)

1. **Deploy gate.exec to Legion** and run it as the `gate.exec` receiver (real run = operator).
2. **Bus → Redis streams** for `gate.*`/`exec.*` topics — needs `REDIS_PASS` (vault). In-process
   + file bus until then (F1.2 posture).
3. **F1.5 activation** — flip `execute_enabled=true` + implement the real executor, behind HITL
   approval (AUTO>90 / REVIEW 70–90 / BLOCK<70 per `.claude/rules/agents.md`). **Out of scope here.**
4. **Auth-harden :9110** before fabric exposure (token + Tailscale/LAN ACL) — parity with :9108/:9208.

## Duplication Audit (ADR-102)

**Coverage:** searched the repo (`git ls-files`) and the evo1 fabric workspace for existing
gate / policy / exec **implementations** and for correlation_id / bus primitives.

| Match | Decision | Rationale |
|---|---|---|
| `three-node-execution-fabric-contract.md` §3 | **keep — source-of-truth (interface)** | F1.3 **implements** the gate chain; no contract text duplicated. |
| `fabric_common.py` (evo1, F1.2) | **reuse** | gate.policy imports it (correlation_id + bus); not re-implemented. gate.exec validates the same id format without importing (cross-node, §4). |
| `evo1_control.py` `:9108` (F1.2) | **reuse** | gate.policy reads fabric status from it for failover §5; not duplicated. |
| ADR-040 (AI execution policy), ADR-056 (merge gate), `docs/policies/hitl-l3-agent-gate-2026-05-11.md`, `agents.md` HITL thresholds | **keep — governance source** | These are **decision/policy docs**, not runtime gate services. gate.policy's `requires_hitl` is consistent with the agents.md HITL model; no new threshold scheme invented (Config-as-Data in `policy-config.json`). |
| repo `git ls-files` for `gate_exec`/`gate_policy` code | **none found** | No prior runtime gate-service code — this is the first implementation. |

**Verdict:** **no duplicate** — first runtime gate-service implementation; reuses F1.2
`fabric_common` + control-plane and honours the contract + agents.md HITL model. **Keep all,
no merge/delete.** Source-of-truth boundaries preserved (ADR-104 §3 = decision/interface,
this = implementation).

## Confirmations

**NOTHING executed for real** · `execute_enabled=false` (default) · gate.exec refuses real
execution even if enabled (F1.5) · no sudo for code (`enable-linger` is per-user, non-sudo) ·
no secrets (Redis `REDIS_PASS` deferred to operator) · deny-by-default + fail-closed ·
reasoning(evo2)/policy(evo1) **act on nothing** prod · no cross-node state drift (policy only
**reads** evo2/control health) · evo1/evo2 services **not stopped** · M0–M1.2 /
`/srv/banxe-legacy` / prod / emi-stack untouched.

**Refs:** ADR-104 (§3 gates, §5 failover), ADR-040 (execution policy), ADR-103 (server-only),
ADR-102 (Duplication Audit); `docs/runbooks/three-node-execution-fabric-contract.md`,
`three-node-fabric-bootstrap.md`, `evo1-control-plane-bringup-2026-06-17.md`,
`fabric/legion/gate_exec.py`, `.claude/rules/agents.md`.
