# S-FAC-61 (R0) — Health contract + legion `redis-cli` / keycloak YELLOW→GREEN

<!-- Source: docs/runbooks/S-FAC-61-health-contract-2026-07-18.md | Date: 2026-07-18 | Status: DRAFT (docs-only, PROPOSED) | Implements: docs/roadmap/FACTORY-ROADMAP-2026-06-23.md §2 S-FAC-61 (R0) DoD | IL: pending-shard (allocator down, see §6) -->

> **Status: DRAFT.** Governance/docs-only. No service, config, or ledger file was changed
> producing this document — `redis-cli` was checked, not installed; keycloak was queried
> read-only, not touched. Written from an isolated worktree
> (`agent/factory/govops/s-fac-60-evo1-remediation`, reused for this sibling R0 tail — no
> new worktree needed since S-FAC-60 is already local-only, unpushed there), **held locally,
> not pushed**, per I-71 while the evo1 Redis IL-allocator is unreachable.

## 0. S-FAC-61 DoD (verbatim)

> `docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` §2: **S-FAC-61 | R0 | Health contract + legion
> `redis-cli`** — *"`redis-cli` installed on legion; keycloak YELLOW→GREEN root-cause + fix;
> uniform healthcheck contract (endpoint, interval, RED/YELLOW/GREEN thresholds) documented
> per service."*

## 1. Major finding — two of the three DoD items already have a DONE ledger record, under a conflicting sprint label

`INSTRUCTION-LEDGER.md`, entry **IL-487** (`agent-factory-ops-s-fac-62-legion-keycloak-rediscli`,
2026-06-23T20:32:00Z, status **DONE**) records, verbatim:

> *"**keycloak "unhealthy" = FALSE NEGATIVE.** Service was actually healthy... Root cause:
> original healthcheck did a raw `/dev/tcp` `GET /realms/master` on 8180 **without
> `Connection: close`** → keep-alive hang → timeout → false "unhealthy". **Fix:**
> `docker-compose.override.yml` healthcheck → `9000/health/ready` with `Connection: close`.
> Result: healthy in 15s."* ... *"`redis-cli` ABSENT on legion. **Fix:** installed
> `redis-tools` 7.0.15 (apt)."* ... *"**DoD: MET**"*

**I independently re-verified both, live, today (2026-07-18), read-only, on this legion host:**

| Item | IL-487 claim (2026-06-23) | Live check now (2026-07-18) | Match? |
|---|---|---|---|
| `redis-cli` present | `redis-tools 7.0.15` | `which redis-cli` → `/usr/bin/redis-cli`; `redis-cli --version` → `redis-cli 7.0.15` | ✅ exact match |
| keycloak container health | healthy in 15s (docker healthcheck) | `docker ps --filter name=keycloak` → `keycloak-banxe-emi` **Up 30 hours (healthy)** | ✅ healthy |
| `:8180/realms/master` | 200 | `curl` → **HTTP 200** | ✅ match |
| `:9000/health/ready` | 200 (from inside container network) | `curl 127.0.0.1:9000/health/ready` from the host → **HTTP 400** | ⚠️ see note below |

**Note on the `:9000` result:** `docker ps` shows `9000/tcp` is **not published** to the host for
`keycloak-banxe-emi` (only `8180` is mapped `0.0.0.0:8180->8180/tcp`) — Docker's own healthcheck
runs `9000/health/ready` **inside** the container network namespace, which is why the container
reports `healthy` even though a curl from the host to `127.0.0.1:9000` does not reach the same
endpoint (it hit HTTP 400 from whatever, if anything, is actually listening on host port 9000 —
not verified further, out of scope for this DRAFT). **This is not evidence of a problem** — the
two endpoints that matter (Docker's internal healthcheck, and the externally-reachable
`8180/realms/master`) are both positive.

**Conclusion: keycloak is currently GREEN, and has been for ≥30 hours** (well past the S-FAC-60-style
"GREEN ≥30 min" bar). The `redis-cli`-on-legion requirement is also currently satisfied.

### Discrepancy flagged, not resolved: sprint-number mismatch

IL-487's own title and body label this exact work **"S-FAC-62"** (*"S-FAC-62 (R1) legion
stabilization... DoD MET"*) and refer to a **different** "S-FAC-61" as the **evo1**
midaz+ballerine stabilization work (*"(Unlike S-FAC-61 which is DoD PARTIAL pending 24h
observation...)"*, *"evo1 midaz+ballerine Up/healthy (S-FAC-61)"*). This does not match the
current `docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` §2 table, which labels the **evo1** triage
work **S-FAC-60** and the **legion redis-cli/keycloak/health-contract** work **S-FAC-61**. Both
documents are dated the same day (2026-06-23); this reads as a **sprint-numbering shift by one**
that happened sometime after IL-487 was written and before (or via) the roadmap table's current
form — **not confirmed**, no commit history was traced to establish which came first or whether
a renumbering PR exists. **This runbook does not resolve the mismatch** — it is flagged for
operator/CTIO reconciliation (§6, §7).

## 2. `redis-cli` on legion — status

- **Present.** `/usr/bin/redis-cli`, version **`redis-cli 7.0.15`** (checked via `which redis-cli`
  and `redis-cli --version`; no install performed by this task).
- Matches IL-487's proof exactly (`redis-tools 7.0.15` via apt) — consistent with the same
  installation still being in place a month later, not a coincidental reinstall.
- **DoD item satisfied**, evidence above. No action needed.

## 3. keycloak YELLOW→GREEN — root cause, fix, and current state

- **Root cause (per IL-487, not re-derived here):** the *original* healthcheck probed `8180`
  with a raw `/dev/tcp` `GET /realms/master` **without `Connection: close`**, causing an
  HTTP keep-alive hang that timed out and was misreported as "unhealthy" — a **false negative**,
  not an actual service fault.
- **Fix applied (per IL-487, host-side, not in this repo):** `docker-compose.override.yml` on the
  legion host changed the healthcheck to hit **`9000/health/ready`** with `Connection: close`.
  This file is **not tracked in `banxe-architecture`** — it is a runtime artifact on the legion
  host itself (confirmed: no `docker-compose.override.yml` referencing keycloak found in this
  repo's tree).
- **Current state (verified live, §1 table): GREEN.** Container `keycloak-banxe-emi` reports
  `healthy` via Docker, up 30 hours; `8180/realms/master` returns 200 externally.
- **This runbook does NOT attempt any further fix** — the fix already happened (per IL-487) and
  is independently confirmed still in effect. The only residual, still-open item is persistence
  (below).
- **Residual open item (IL-487's own flag, still unresolved as far as this DRAFT can tell):**
  *"the keycloak healthcheck fix lives in host `docker-compose.override.yml` (runtime,
  reboot-local) — persist declaratively... so legion stabilization survives host restart."*
  No evidence was found in this repo that this persistence step has been done — **[UNKNOWN]**,
  see §6.

## 4. Uniform healthcheck contract — derived from `config/traffic-light.env` + `scripts/traffic-light.sh` (the de-facto contract today)

**Global parameters (config-as-data, `config/traffic-light.env`):** probe timeout
`TL_PROBE_TIMEOUT_SEC=5`; schedule `TL_CRON_TIMES="08:00,20:00"` (`TL_CRON_TZ=Europe/Berlin`,
handled via `deploy/cron/traffic-light.crontab` — **twice daily**, plus an on-demand trigger via
the `TL_SESSION_STREAM` Redis stream on session start (`config/traffic-light.env`,
`docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` §4.2 "Triggers").

**Threshold logic (`scripts/traffic-light.sh` `probe()`, read verbatim):** every probe is a
**binary reachability check per run** — there is **no** graduated/numeric threshold (e.g. latency
bands) anywhere in the script or config. Verdict per probe: success → **GREEN**; failure on a
`critical` target → **RED**; failure on a `noncritical` target → **YELLOW**. Aggregate verdict:
any RED → overall 🔴; else any YELLOW → overall 🟡; else 🟢 (`traffic-light.sh` aggregation loop).

| Service | Endpoint / probe | Kind | Interval | Timeout | GREEN | YELLOW | RED | Critical? |
|---|---|---|---|---|---|---|---|---|
| `legion-redis` | `127.0.0.1:6379` | redis (`PING`) | 08:00 & 20:00 CEST + on-demand | 5s | `PONG` returned | — (fails closed to RED, see below) | any failure to PING | **critical** |
| `evo1-control-plane` | `http://evo1:9207/health` | http | 08:00 & 20:00 CEST + on-demand | 5s | HTTP 2xx/3xx | — | any failure (timeout, non-2xx, `curl` absent) | **critical** |
| `evo2-observability` | `http://evo2:9090/-/healthy` | http | 08:00 & 20:00 CEST + on-demand | 5s | HTTP 2xx/3xx | any failure | — | noncritical |
| `evo2-inference` | `http://evo2:9208/health` | http | 08:00 & 20:00 CEST + on-demand | 5s | HTTP 2xx/3xx | any failure | — | noncritical |
| `fabric-stream` | `redis-cli -h 127.0.0.1 XLEN fabric:heartbeat:evo1` (cmd) | cmd | 08:00 & 20:00 CEST + on-demand | 5s | exit 0 | any failure | — | noncritical |

**Not yet in `config/traffic-light.env` at all — gap, not a threshold omission:**

| Service | Why it should plausibly be added | [UNKNOWN] |
|---|---|---|
| `legion-keycloak` | S-FAC-61 names keycloak explicitly, but no `TL_TARGETS` row exists for it today | Proposed probe: `http` on `http://127.0.0.1:8180/realms/master`, criticality **[UNKNOWN — operator to decide; keycloak is IAM, arguably critical]** |
| `evo1-midaz-ledger` / `evo1-mongodb` / `evo1-workflow-service` | S-FAC-60's own subject (RESTARTING in the 2026-06-23 audit) has no dedicated `TL_TARGETS` probe either — only the umbrella `evo1-control-plane` is probed | Proposed probes: **[UNKNOWN — exact endpoints/ports not confirmed for a health probe per service]**; see the S-FAC-60 runbook (`docs/runbooks/S-FAC-60-evo1-remediation-2026-07-18.md`) §6 for the same open item |

**Not defined anywhere in the repo (flagged per this task's own instruction to mark undefined thresholds `[UNKNOWN]`):**

- **Sustained-GREEN duration.** The roadmap's own DoD language ("services GREEN **≥30 min** or
  quarantined", S-FAC-60 DoD) is **not implemented** by `traffic-light.sh` — the script evaluates
  a single point-in-time probe per run; there is no consecutive-run or duration tracking anywhere
  in `scripts/traffic-light.sh` or `config/traffic-light.env`. **[UNKNOWN]** whether this is
  intended to be satisfied manually (operator observes 2 consecutive green cron runs 12h apart)
  or needs new logic — not decided here.

## 5. `:9108` vs `:9207` — control-plane port, flagged as a contract decision (not resolved here)

Already raised in the S-FAC-60 runbook (`docs/runbooks/S-FAC-60-evo1-remediation-2026-07-18.md`
§3 Step F, §6): `docs/runbooks/evo1-control-plane-bringup-2026-06-17.md` states the evo1
control/status endpoint is **`:9108`**; `config/traffic-light.env`'s `evo1-control-plane` probe
targets **`:9207`**. The health contract in §4 above **uses `:9207` as written in
`config/traffic-light.env` today** (it is the live config-as-data value actually consulted by
`traffic-light.sh`), but this is **not** an endorsement that `:9207` is correct — it is simply
what the script currently probes. **This needs an explicit operator decision**: either
`config/traffic-light.env` is wrong and should be corrected to `:9108`, or the bring-up doc's
`:9108` claim is stale and the service was later moved to `:9207` (undocumented). Resolve via the
same `curl` check listed in the S-FAC-60 runbook §3 Step F, then update whichever document is
wrong in a small follow-up PR.

## 6. [UNKNOWN] — not determinable from the repository alone

- **Whether IL-487's "S-FAC-62" label or the roadmap table's "S-FAC-61" label is the intended
  sprint number for the legion keycloak/redis-cli work** (§1) — a real discrepancy between two
  dated-the-same-day sources; not resolved.
- **Whether the keycloak healthcheck fix's persistence follow-up (declarative, survives host
  rebuild) was ever done** — IL-487 flagged it as still-open at the time; no later entry found
  confirming it was closed.
- **Criticality classification for a prospective `legion-keycloak` probe** (critical vs
  noncritical) — not decided in any source read for this document.
- **Exact per-service health endpoints for `evo1-midaz-ledger`/`evo1-mongodb`/
  `evo1-workflow-service`** — same gap already flagged in the S-FAC-60 runbook; needed before
  these three can get their own `TL_TARGETS` rows.
- **Whether a sustained-GREEN-duration concept (the "≥30 min" DoD language) is meant to be
  automated or is a manual sign-off criterion** — no implementation or written decision found.
- **What is actually listening on host `127.0.0.1:9000`** that answered HTTP 400 during today's
  verification (§1) — not investigated further; out of scope for this DRAFT.

## 7. Post-recovery TODO (not executed now — allocator is down)

- **Mint the IL-shard for this runbook** once `redis-cli -h 100.68.102.48 -p 6379 -a "$REDIS_PASS"
  ping` returns `PONG` again (same allocator, same procedure as the sibling S-FAC-60 runbook's
  §7) — confirm `added=1 / mutated=0 / removed=0`, `build_ledger.py --check == OK`, then push and
  open the PR (operator-merge, §5).
- **Raise the IL-487 sprint-number discrepancy (§1) to the operator/CTIO explicitly** — do not
  let a future shard silently pick one label without a decision.
- **Propose (in a follow-up PR, not here) new `TL_TARGETS` rows** for `legion-keycloak` and the
  three evo1 services once their criticality/endpoints are confirmed (§4, §6).
- **Reconcile with the S-FAC-60 runbook's own open items** (evo1 SSH/Redis-refused incident,
  `:9108`/`:9207` port question — shared with §5 here) in the same follow-up wave, since both
  runbooks reference the same unresolved port discrepancy.

## Duplication Audit (ADR-102)

Reused, not duplicated: `config/traffic-light.env` + `scripts/traffic-light.sh` (the actual
contract, quoted/tabulated not reimplemented), `INSTRUCTION-LEDGER.md` IL-487 (root-cause + fix,
quoted verbatim, not re-derived), `docs/runbooks/S-FAC-60-evo1-remediation-2026-07-18.md` (shared
`:9108`/`:9207` and evo1-probe-endpoint open items, cross-referenced not restated),
`docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` §2/§4.2 (DoD + spec, quoted not restated). No
existing "health contract" document was found anywhere in `docs/**` — this is a new, non-duplicate
artifact.

**Refs:** `docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` (S-FAC-61 DoD, §4.2 spec),
`INSTRUCTION-LEDGER.md` IL-487, `config/traffic-light.env`, `scripts/traffic-light.sh`,
`deploy/cron/traffic-light.crontab`, `docs/runbooks/S-FAC-60-evo1-remediation-2026-07-18.md`
(sibling), `GAP-REGISTER.md` (G-OPS-05 — a **different**, evo1-side zombie-keycloak gap, not to
be confused with this legion-keycloak item), ADR-102.
