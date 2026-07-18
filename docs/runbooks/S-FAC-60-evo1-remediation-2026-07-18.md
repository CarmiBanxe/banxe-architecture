# S-FAC-60 (R0) — evo1 RED-service triage & remediation runbook

<!-- Source: docs/runbooks/S-FAC-60-evo1-remediation-2026-07-18.md | Date: 2026-07-18 | Status: DRAFT (docs-only, PROPOSED) | Implements: docs/roadmap/FACTORY-ROADMAP-2026-06-23.md §2 S-FAC-60 (R0) DoD | IL: pending-shard (allocator down, see §7) -->

> **Status: DRAFT.** Governance/docs-only. No service was restarted, no config changed, no
> ledger shard minted by producing this document. All remediation steps below are written
> **for the operator/repair-crew to execute**, not self-executed. Written from an isolated
> worktree (`agent/factory/govops/s-fac-60-evo1-remediation`), **held locally, not pushed**,
> per I-71 single-writer discipline while the evo1 Redis IL-allocator is unreachable.

## 1. Incident summary (confirmed, cited — not re-guessed)

Per operator-confirmed read-only check from Legion, **2026-07-18 11:00 CEST**:

| Probe | Target | Result |
|---|---|---|
| ICMP | `100.68.102.48` (evo1, Tailscale) | **OK** — host responds to ping |
| TCP 22 (SSH) | `100.68.102.48:22` | **REFUSED** |
| TCP 6379 (Redis / IL-allocator) | `100.68.102.48:6379` | **REFUSED** |

Downstream effects (same source):

- Traffic-light probe `evo1-control-plane|http|http://evo1:9207/health|critical` (`config/traffic-light.env`) reads **CRITICAL** → the S-FAC-65 adoption gate is **RED** while evo1 is down.
- The central IL-shard allocator (`ledger/build_ledger.py`, evo1 Redis `100.68.102.48:6379`, per `fabric/legion/README.md` §"IL allocator shares this same evo1 Redis") is unreachable → `build_ledger` runs fail-loud per this session's operating discipline (no local `max+1` fallback used) → **no IL shard can be minted right now**.
- PR #1126 (Legion private-engine config, `banxe-architecture`) is blocked on the `guardian-ledger` check for exactly this reason — every ledger-touching factory PR is blocked while the allocator is down.

**Relation to the prior audit finding (2026-06-23):** `docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` §0 row **A6** already recorded, as of 2026-06-23: *"evo1 `midaz-ledger`/`mongodb`/`workflow-service` **RESTARTING (RED)**"* (host reachable, specific containers cycling). Today's finding (SSH **and** Redis TCP both refused) is evidence of a **broader, host-level** condition than the original A6 finding — the earlier issue was "some containers restarting on a reachable host with a working SSH daemon"; today neither SSH nor Redis accept a connection at all. **These may be the same root cause progressing, or two separate incidents** — this runbook does not assume either without console evidence (see §2, §6 [UNKNOWN]).

## 2. Root-cause hypotheses (ranked by evidence — NONE confirmed without console access)

Reasoning basis: ICMP succeeds (host + network path + kernel are up), but **both** TCP listeners checked (22, 6379) refuse — this pattern is more consistent with *"the specific service processes are not running / not bound"* than with *"a firewall or network outage,"* because a firewall or a fully-hung host would typically also affect ICMP or would selectively block rather than uniformly refuse at the TCP layer. Ranked accordingly:

1. **[HYPOTHESIS, highest confidence] Host was rebooted or the Docker daemon crashed, and one or more of `sshd`/`docker` did not auto-start.** evo1 runs `sshd` at the OS level and Redis/Midaz/MongoDB as Docker containers (`docker/**` per `.claude/rules/infrastructure.md`, `banxe-redis` container per `docs/runbooks/redis-evo1-setup.md`). A reboot without both services enabled (`systemctl enable`) would produce exactly this symptom: host up, both listeners down.
2. **[HYPOTHESIS] Disk-full or OOM condition killed `dockerd` and/or `sshd`.** Would explain simultaneous, uniform TCP refusal without a network-layer explanation. Cannot be confirmed or ruled out without console `df -h` / `dmesg`/`journalctl -k` output.
3. **[HYPOTHESIS, lower confidence] Firewall/iptables rule change dropped exactly ports 22 and 6379.** `.claude/rules/infrastructure.md` records a containment iptables rule from the **V-XMRIG incident (2026-05-07)**, but that containment was scoped to **evo2**, not evo1 — no equivalent evo1 containment rule is documented anywhere found in this repo. This hypothesis is kept only because it cannot be excluded without a console-side `iptables -L`/`ufw status` check, not because there is positive evidence for it.
4. **[HYPOTHESIS, lowest confidence] Full host hang / hardware fault with a still-live NIC.** Possible in principle (a hung userspace can still answer ICMP handled at the kernel/NIC level) but has no supporting evidence beyond the absence of a simpler explanation; console login attempt (§3 Step A) settles this immediately.

**Not claimed as fact:** which of the above is correct. Console access (§3) is required to distinguish them; do not act on assumption.

## 3. Step-by-step remediation — FOR THE OPERATOR/REPAIR-CREW, run ON evo1's local console

**SSH is down, so `ssh evo1 ...` (used throughout the existing runbooks below) will not work until Step B below succeeds.** Every command in this section is a **local-console** command (physical console, KVM, or any out-of-band management the repair crew has — **[UNKNOWN]** whether evo1 has IPMI/BMC out-of-band access; not documented anywhere found in this repo, so plan for physical keyboard/monitor access unless the repair crew already knows otherwise).

### Step A — Confirm the host is alive and log in locally
```bash
# At evo1's physical console / KVM, log in as the `banxe` user (per existing runbooks' convention).
# If login itself fails or hangs → hypothesis 4 (§2) gains weight; escalate to hardware check.
```

### Step B — Bring up SSH (restores remote access for every subsequent step and for the existing runbooks)
```bash
sudo systemctl status ssh
sudo systemctl enable --now ssh
sudo systemctl status ssh          # verify: "active (running)" AND "enabled"
```
**Verify (from Legion, once this step is done):** `ssh evo1 'echo ok'` should now succeed — from this point on, the remaining steps MAY be run either at the console or over the now-restored SSH, at the repair crew's discretion.

### Step C — Bring up the Docker daemon (Redis, Midaz, MongoDB, RabbitMQ, and other evo1 services all run as containers per `.claude/rules/infrastructure.md` and `docs/runbooks/redis-evo1-setup.md`)
```bash
sudo systemctl status docker
sudo systemctl enable --now docker
docker ps -a                        # inventory every container + its state (Up / Exited / Restarting)
```

### Step D — Bring up Redis (`banxe-redis` container — the IL-allocator + fabric bus backing store)
Full setup/rebuild procedure already documented — **do not duplicate, follow `docs/runbooks/redis-evo1-setup.md` §"Restart / Recovery"** verbatim:
```bash
docker start banxe-redis
docker logs banxe-redis --tail 20                        # check for a crash loop / AOF corruption
docker exec banxe-redis redis-cli -a "$REDIS_PASS" ping   # expect PONG, LOCAL to evo1
```
If the container itself is gone or the data volume is corrupted, use the full rebuild in `redis-evo1-setup.md` §2–§4 (password already stored at `~/banxe-dev/redis-evo1.env` on Legion per that doc — do not regenerate it unless it is confirmed lost).

### Step E — Bring up `midaz-ledger` / `mongodb` / `workflow-service` (the original A6 finding)
```bash
docker ps -a | grep -iE "midaz|mongo|workflow"
docker start <midaz-ledger-container>
docker start <mongodb-container>
docker start <workflow-service-container>   # [UNKNOWN — exact container/service name for
                                             #  "workflow-service" not confirmed in any file
                                             #  read for this runbook; identify it from the
                                             #  `docker ps -a` output above, do not guess]
docker logs <container> --tail 30           # per container — look specifically for a Mongo
                                             # rs0 replica-set election failure or a Midaz
                                             # DB-connection-refused loop (the two most common
                                             # causes of a restart loop for these two services)
```

### Step F — Reconcile the control-plane health-endpoint port discrepancy, then verify
Two source documents disagree on the evo1 control-plane port:
- `docs/runbooks/evo1-control-plane-bringup-2026-06-17.md` states the control/status endpoint is **`:9108`** (`evo1-control.service`, a `systemd --user` unit requiring `loginctl enable-linger banxe` to survive reboot — if linger was not (re)confirmed after a reboot, this specific service would not restart).
- `config/traffic-light.env` probes **`http://evo1:9207/health`** as the `evo1-control-plane|critical` target.

**This runbook does not resolve which port is authoritative** — that is itself an open item (flagged again in §6). Check both:
```bash
systemctl --user status evo1-control.service     # run as the `banxe` user, locally or via SSH
curl -s http://127.0.0.1:9108/health
curl -s http://127.0.0.1:9207/health
```
Report back which port actually answers so `config/traffic-light.env` (or the bring-up doc) can be corrected in a follow-up — do not silently pick one.

### Step G — Only if 22/6379 are still refused after C–D: check the firewall
```bash
sudo iptables -L -n -v | grep -E ":22\b|:6379\b"
sudo ufw status verbose   # if ufw is in use on evo1
```

## 4. Verification — FROM LEGION, once evo1 is reported back up

```bash
# 1. SSH restored
ssh evo1 'echo ok'

# 2. Redis / IL-allocator restored (fail-loud check used throughout this session — do not
#    fall back to local max+1 if this still fails)
source ~/banxe-dev/redis-evo1.env
redis-cli -h 100.68.102.48 -p 6379 -a "$REDIS_PASS" ping        # expect PONG

# 3. Control-plane health (use whichever port Step F confirmed)
curl -s http://evo1:9207/health     # (or :9108 — per Step F)

# 4. Re-run the traffic-light audit — expect GREEN for the evo1-control-plane and
#    fabric-stream probes (config/traffic-light.env, scripts/traffic-light.sh)
bash scripts/traffic-light.sh
```

Per the S-FAC-60 DoD (`FACTORY-ROADMAP-2026-06-23.md` §2): each service must be **GREEN for ≥30 minutes** before being considered recovered — a single green probe immediately after restart is not sufficient; re-check after the 30-minute window.

## 5. Quarantine fallback (if a service cannot be restored)

The roadmap's own exit criterion is: *"every audited service GREEN or explicitly quarantined with a reason"* (`FACTORY-ROADMAP-2026-06-23.md` §1 R0, §2 S-FAC-60 DoD). **No machine-readable quarantine mechanism exists yet** in `config/traffic-light.env` or `scripts/traffic-light.sh` (searched both — no `quarantine` field/flag found; the word appears only in prose elsewhere in the repo, e.g. `INSTRUCTION-LEDGER.md` referring to an unrelated future "R5 quarantine list"). Until S-FAC-61 (health-contract sprint) defines one:

1. Document, in this runbook (this section, updated in place), which service(s) could not be restored, the console evidence gathered (`docker logs`, `journalctl`, `dmesg` excerpts), and the reason quarantine was chosen over continued remediation.
2. Do **not** silently remove or weaken the corresponding `TL_TARGETS` entry in `config/traffic-light.env` to hide a RED/YELLOW result — if a probe must be excluded, say so explicitly in the same PR that touches the config, with this runbook cited as the reason.
3. Record the quarantine formally as an IL-shard once the allocator is back (§7) — the roadmap DoD requires the reason to live "in the ledger," not only in this doc.

_As of this DRAFT (2026-07-18), no service has been declared quarantined — remediation has not yet been attempted (evo1 SSH is down, so §3 has not been executed by the repair crew at the time of writing)._

## 6. [UNKNOWN] — not determinable from the repository alone

- **Why the services stopped in the first place.** No console/log access from this session; §2 lists hypotheses only, none confirmed.
- **Whether evo1 has any out-of-band (IPMI/BMC) management.** Not documented anywhere found in this repo; assume physical console access is required unless the repair crew knows otherwise.
- **Whether ports other than 22 and 6379 are also down** (e.g. `:8095` Midaz, `:5703` MongoDB, `:8123`/`:9000` ClickHouse, `:5678` n8n). Only 22 and 6379 were checked per the confirmed incident state given for this task; the true blast radius on evo1 is otherwise unknown until Step C's `docker ps -a` / a broader port check is run.
- **The exact container/service name behind "workflow-service"** in the A6 finding — not found by name in any file read for this runbook (`.claude/rules/infrastructure.md`, `redis-evo1-setup.md`, `SERVICE-MAP.md` pointer not re-read in full here). Identify via `docker ps -a` on evo1, do not guess.
- **Which port (`:9108` vs `:9207`) is the authoritative evo1 control-plane health endpoint.** Two source docs disagree (§3 Step F); not resolved here.
- **Whether the 2026-06-23 A6 RESTARTING finding and the 2026-07-18 SSH/Redis-refused finding share a root cause**, or are two separate incidents. Flagged, not decided (§1).

## 7. Post-recovery TODO (not executed now — allocator is down)

- **Mint the IL-shard for this runbook** once `redis-cli -h 100.68.102.48 -p 6379 -a "$REDIS_PASS" ping` returns `PONG` again: run `python3 ledger/build_ledger.py` (mints via the evo1 allocator per `fabric/legion/README.md`), confirm `added=1 / mutated=0 / removed=0`, `build_ledger --check == OK`, then push this branch and open the PR (still respecting single-writer/§5 operator-merge discipline).
- **Unblock PR #1126** (`agent/factory/privateengine/openmanus-config`, `banxe-architecture`) — its `guardian-ledger` check should flip to pass once its own required shard can be minted the same way; re-poll `gh pr view 1126` after the allocator returns.
- **Reconcile the `:9108`/`:9207` control-plane port discrepancy** (§3 Step F / §6) in a small follow-up PR once confirmed which port is live.
- **If `docker ps -a` reveals other evo1 ports/services affected** beyond 22/6379, extend this runbook (or file a follow-up) rather than treating today's fix as complete.

## Duplication Audit (ADR-102)

Reused, not duplicated: `docs/runbooks/redis-evo1-setup.md` (Redis install/restart/rebuild — pointed to, not restated), `docs/runbooks/evo1-control-plane-bringup-2026-06-17.md` (control-plane service detail + port claim), `config/traffic-light.env` (probe targets/thresholds), `docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` §0/§2 (A6 finding + S-FAC-60/61 DoD, quoted not restated in full), `.claude/rules/infrastructure.md` (evo1 service/port inventory). No existing evo1-triage runbook covers today's SSH+Redis-refused incident specifically (checked `docs/audit/*evo1*`, `docs/runbooks/*evo1*`, `docs/runbooks/legion-do-not-do.md` — none address this) — this is a new, non-duplicate artifact satisfying the S-FAC-60 DoD.

**Refs:** `docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` (S-FAC-60/61), `fabric/legion/README.md` (IL allocator on evo1 Redis), `docs/runbooks/redis-evo1-setup.md`, `docs/runbooks/evo1-control-plane-bringup-2026-06-17.md`, `config/traffic-light.env`, `.claude/rules/infrastructure.md`, ADR-102, ADR-104.
