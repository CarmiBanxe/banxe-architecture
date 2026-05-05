# Runbook — PA-5 Frankfurter zombie decommission

| Field | Value |
|---|---|
| Sprint | IL-PROJECT-AUDIT-01 (PR #58) |
| Scope | Decommission banxe-frankfurter container on evo1 |
| Target node | evo1 (banxe-NucBox-EVO-X2, 192.168.0.12 / 100.68.102.48) |
| Risk | LOW (zombie container, no consumers, no DB target reachable) |
| Reversibility | HIGH (image hakanensari/frankfurter:latest publicly available; redeploy possible from scratch) |
| Approval required | YES — production-state mutation per CLAUDE.md §11; explicit operator `go` before each step |

## Context

Per PA-5a-extended discovery (2026-05-05 21:17 UTC):

- `banxe-frankfurter` container has RestartCount=6051, Memory=25 MiB, CPU=0% (idle between crashes).
- Logs return empty; State.Started repeatedly within seconds of previous start → restart loop.
- DATABASE_URL points to `172.17.0.1:5432` (host gateway), but host Postgres does NOT listen on :5432 (verified via `ss -tlnp`).
- Zero TCP connections on :8181 (Frankfurter) — no live consumers.
- No proxy/ingress references in nginx/caddy/traefik/haproxy/ballerine configs on evo1.
- No code references in /data/banxe / /data/banxe-stack / /data/banxe-emi-stack / systemd unit files.

Conclusion: `banxe-frankfurter` is a **zombie container** — running, restarting, but unreachable, unused, and pointing at a non-existent DB. It contributes only to evo1 CPU/IO churn from the restart loop, directly violating Operator canon Principle 1 ("evo1 не должен задыхаться").

## Decommission steps

Each step requires explicit operator `go` before execution.

### Step 1 — Read-only verify (no go required, idempotent)

```bash
ssh evo1 'docker inspect banxe-frankfurter --format "{{.State.Status}} restarts={{.RestartCount}} started={{.State.StartedAt}}"'
ssh evo1 'docker ps --filter name=banxe-frankfurter --format "{{.Names}} {{.Status}}"'
ssh evo1 'ss -tn state established "( sport = :8181 or dport = :8181 )"'
```

Acceptance: 0 established connections; container in restart loop; no consumers.

### Step 2 — Stop the container (operator go required)

```bash
ssh evo1 'docker stop banxe-frankfurter'
```

Acceptance: `docker ps --filter name=banxe-frankfurter` returns no row; CPU usage on evo1 drops by the restart-loop overhead (measurable in `top`).

### Step 3 — Remove the container (operator go required)

```bash
ssh evo1 'docker rm banxe-frankfurter'
```

Acceptance: `docker ps -a --filter name=banxe-frankfurter` returns no row; container fully removed.

### Step 4 — Optional: prune unused image (operator go required, optional)

```bash
ssh evo1 'docker image rm hakanensari/frankfurter:latest 2>/dev/null || true'
```

Acceptance: image removed if no other container uses it. SAFE to skip — image is ~50 MB, no harm in keeping for future redeploy.

### Step 5 — Verify evo1 RAM/CPU recovered

```bash
ssh evo1 'free -h'
ssh evo1 'top -b -n1 | head -15'
```

Expected: RAM unchanged significantly (~25 MiB freed, marginal); CPU idle higher (no more restart spam).

## Rollback plan

If decommission was a mistake (consumer surfaces later):

```bash
ssh evo1 'docker run -d --name banxe-frankfurter \
  --restart unless-stopped \
  -p 8181:8080 \
  -e DATABASE_URL="postgres://USER:NEW_ROTATED_PWD@HOST:5432/frankfurter" \
  hakanensari/frankfurter:latest'
```

Note: rollback requires (a) provisioning a real Postgres frankfurter DB and (b) using a NEW rotated password (see IL-SEC-01).

## MiroFish — DEFERRED

Per operator canon best-decision (2026-05-05): MiroFish remains on evo1 unchanged. Reasoning:

- Stateful (bind-mount /root/developer/mirofish/backend/uploads → /app/backend/uploads).
- Migration with state requires separate ADR + design.
- Resource footprint negligible (33 MiB RAM, 0 CPU at snapshot).
- Removal would touch real upload data — stop-barrier per safety-rules.md.

Future MiroFish decision: out of scope of PA-5; can be addressed in follow-up sprint if operator surfaces the need.

## Anchors

- IL-PROJECT-AUDIT-01 (PR #58) — sprint kickoff
- PA-5a + PA-5a-extended discovery (this session, 2026-05-05 21:13-21:17 UTC)
- docs/canon/operator-canon-2026-05.md — Principle 1 (Hardware-first)
- IL-SEC-01 (Frankfurter Postgres password rotation) — sibling
- safety-rules.md — destructive operation gate
- CLAUDE.md §11 — production-state mutation gate

## Status

| Date | Status | Note |
|---|---|---|
| 2026-05-05 | DRAFT | Runbook drafted post PA-5a-extended discovery; awaiting operator go on Step 2/3 |
