---
il_ts: 2026-07-18T22-56-44Z
session_id: agent-factory-govops-traffic-light-config-fix
source: CEO
status: DONE
---
### Traffic-light config-drift fix — legion-redis + evo1-control-plane false-RED (config-only, PROPOSED)
- **Date:** 2026-07-18 · **Type:** config-as-data fix to `config/traffic-light.env`
  (S-FAC-65 R1 artifact), zero changes to `scripts/traffic-light.sh` or any other target.
- **Decision:** Repoint the two CRITICAL probe targets that were causing a false-RED
  adoption-gate verdict, using only confirmed live evidence (not guessed):
  1. `legion-redis` → renamed `evo1-redis-allocator`, probed `127.0.0.1:6379` (no local
     Redis exists there) → repointed to the real shared IL allocator per ADR-143-A,
     `100.68.102.48:6379`. **Probe kind changed `redis` → `tcp`**: the allocator requires
     auth (`requirepass`, confirmed live via `NOAUTH Authentication required.` on an
     unauthenticated PING), and `scripts/traffic-light.sh`'s `redis` probe kind sends an
     unauthenticated PING only (no `-a`/`REDISCLI_AUTH` support anywhere in the script) —
     repointing with `kind=redis` unchanged would have traded one false-RED
     (connection-refused) for another (NOAUTH-refused). `kind=tcp` is a credential-free
     reachability check already supported by the script, confirmed live
     (`exec 3<>/dev/tcp/100.68.102.48/6379` succeeds).
  2. `evo1-control-plane` — probed `http://evo1:9207/health`. Two independent faults
     found, both fixed: (a) hostname `evo1` does not resolve from Legion (`getent hosts
     evo1` → not found; `curl` to it times out on DNS) — repointed to the same stable
     Tailscale IP used for the allocator; (b) port `:9207` is undocumented anywhere in the
     repo (`grep -rn 9207` matches only the drifted config line itself) — the only
     documented control-plane port is `:9108`
     (`docs/runbooks/evo1-control-plane-bringup-2026-06-17.md`, cited 4×). Repointed to
     `http://100.68.102.48:9108/health`, confirmed live `HTTP 200`.
  3. `TL_REDIS_HOST` updated `127.0.0.1` → `100.68.102.48` for evidence-accuracy (the
     downstream `XADD` publish step has no auth support either, so it will continue to
     WARN — not flip the verdict RED — against the auth'd host exactly as it already does
     today against a refused localhost; no regression, not a full fix).
- **Explicitly NOT changed (out of scope per task):** `evo2-observability`,
  `evo2-inference` (noncritical, unconfirmed as wrong), `fabric-stream` (noncritical,
  shares the same `127.0.0.1` assumption as the old `legion-redis` line and would hit the
  identical NOAUTH constraint if repointed — flagged as a related follow-up, not fixed
  here to keep this change minimal and evidence-scoped), thresholds, cron schedule.
- **Follow-up (not implemented here, needs a script change, not a config change):**
  `scripts/traffic-light.sh` has no mechanism to supply Redis auth to either the
  `redis`-kind probe or the `XADD` publish step. A real fix needs `REDIS_PASS`/
  `REDISCLI_AUTH` sourced from a secure out-of-band location (e.g. the existing vault
  file already used elsewhere in this session) — **not** a literal secret added to this
  tracked `.env` file, which would violate the no-hardcoded-secrets rule. Until that
  lands, `evo1-redis-allocator` stays a `tcp`-kind reachability check (weaker signal than
  an authenticated `PING`, but honest and false-RED-free) and `fabric-stream` stays
  pointed at localhost (noncritical, already-known-broken, unchanged).
- **Basis (evidence, not memory):** live `NOAUTH` test against `100.68.102.48:6379`; live
  `getent hosts evo1` (not found) and `curl --max-time 5 http://evo1:9108/health` (DNS
  timeout) vs. `curl http://100.68.102.48:9108/health` (`HTTP 200`) and
  `http://100.68.102.48:9207/health` (connection refused); `grep -rn 9207`/`9108` across
  the repo; `docs/runbooks/evo1-control-plane-bringup-2026-06-17.md` lines 11/26/52/72
  (all citing `:9108`). Dry-run of `scripts/traffic-light.sh --no-publish --no-shard`
  against the **unfixed** origin/main config reproduced `🔴 red` live
  (`legion-redis=red; evo1-control-plane=red`); the **same run against the fixed config**
  produced `🟡 yellow` (`evo1-redis-allocator=green; evo1-control-plane=green`; remaining
  yellow entries are the untouched noncritical targets) — direct before/after proof the
  false-RED adoption-gate is resolved without introducing a new one.
- **DoD:** config-only fix satisfying the confirmed-drift remediation task; no service
  mutation (read-only audit tool, I-27 unchanged); no script code changed in this shard.
- **Canon compliance:** authored in an ISOLATED worktree off `origin/main@684a9ff`
  (post-#1126-merge tip, ADR-120); branch ADR-060-compliant
  (`agent/factory/govops/traffic-light-config-fix`); no S320; hooks enabled (no
  `--no-verify`/`--admin`/bypass); STOP before merge for operator.
- **Coupling/append-only:** branch off `origin/main@684a9ff`; single new shard; no prior
  entry modified.
- **Proof (ledger):** `build_ledger.py --check` to be confirmed after mint; IL number
  assigned live via the evo1 Redis allocator (`banxe:il:counter`), not hand-picked.
- **Refs:** `config/traffic-light.env`, `scripts/traffic-light.sh`,
  `docs/runbooks/evo1-control-plane-bringup-2026-06-17.md`,
  `docs/runbooks/S-FAC-60-evo1-remediation-2026-07-18.md`,
  `docs/runbooks/S-FAC-61-health-contract-2026-07-18.md` (original `:9108`/`:9207`
  discrepancy flag), ADR-143-A, ADR-102, ADR-120, ADR-060.
