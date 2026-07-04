# SP03 — LiteLLM :4000 Single-Listener Guard (proposed systemd drop-in)

**Status:** DRAFT (contour-B, append-only artefact — NOT applied to live systemd)
**Owner:** Terminal B (Spec-Projects)
**Consumer:** Terminal A (Factory) — reads only, never edits
**Handoff:** closes OPEN-GAP "systemd single-listener guard" from `governance/NOVELTY-COLLECTION-REGISTER.md`
**Apply model:** `apply=operator-Legion` (same discipline as routing-apply — this document is a template, live systemd mutation is an explicit operator step)
**Related novelty rows:**
- `litellm_4000_orphan_reuseport` (root cause, OPEN)
- `litellm_4000_noauth_redis_cache_stall` (RESOLVED — separate)
- `project_reason_glm_air_live_applied` (RESOLVED — downstream benefit blocked while routing "flickers")

---

## 1. Problem

Multiple LiteLLM gateway processes can co-bind TCP `:4000` on Legion when the socket is opened with `SO_REUSEPORT`. The Linux kernel then load-balances incoming connections across ALL bound sockets in round-robin (one accept per listener). Observed effect during sp02:

- one connection reaches the intended (upgraded) LiteLLM instance;
- the next reaches an orphan/legacy instance still holding a stale routing table;
- callers therefore see routing "flicker" — e.g. `project-reason` was hitting `:8081` on one call and `:8082` on the next, with no client-side change.

Root cause: no serialisation guarantee that the previous LiteLLM listener is dead before the new one starts. `systemctl restart` (or manual bounce) can leave orphan children holding the port because `SO_REUSEPORT` explicitly permits it.

## 2. Proposed solution (systemd drop-in — TEXT, NOT APPLIED)

A drop-in override for the LiteLLM unit that:

1. Kills any non-systemd process still bound to `:4000` immediately BEFORE starting the new instance (`ExecStartPre`).
2. Restarts the unit on failure so a transient orphan does not degrade routing silently.

Proposed content (operator applies verbatim; this repo does NOT deploy it):

```ini
# /etc/systemd/system/litellm.service.d/10-single-listener-guard.conf
# apply=operator-Legion (contour-B artefact; do not `systemctl daemon-reload` in CI)
[Service]
# 1) Detect any listener on :4000 that is NOT owned by this unit's ExecStart PID
#    and terminate it. The `-k` flag on fuser sends SIGKILL to all matched PIDs;
#    the leading `-` on the ExecStartPre line makes systemd tolerate an empty
#    result (i.e. no orphan present — the normal steady state).
ExecStartPre=-/usr/bin/fuser -k -TERM 4000/tcp
ExecStartPre=-/bin/sh -c 'sleep 1; /usr/bin/fuser -k -KILL 4000/tcp || true'

# 2) Fail-loud on unit crash so an orphan taking the port is not masked by
#    an idle unit sitting in `inactive (dead)`.
Restart=on-failure
RestartSec=2s
```

Notes on the proposal:

- `fuser -k 4000/tcp` is preferred over `ss ... | awk | xargs kill` because it is one binary, one syscall path, and does not depend on `ss` column layout that varies by iproute2 version.
- The two `ExecStartPre` lines implement TERM-then-KILL with a 1s grace period. Both are prefixed with `-` so the unit does NOT fail when there is no orphan (steady state).
- `Restart=on-failure` is deliberately narrower than `Restart=always` — we do not want restart storms when the unit is intentionally stopped by the operator.
- No secrets, no `EnvironmentFile=` change, no config-value edit. This drop-in ONLY governs process lifecycle around `:4000`.

## 3. Apply procedure (operator, on Legion — NOT executed by this repo)

The operator applies this in one atomic step, mirroring the existing routing-apply discipline:

```bash
# operator@Legion — apply=operator-Legion, DO NOT run in CI or from an agent shell
sudo install -Dm0644 \
  <path-to-this-repo>/governance/specproj/SP03-LITELLM-SINGLE-LISTENER-GUARD.md \
  /dev/null   # NB: this doc is documentation, not a config file — operator copies
              # the ini-block above into 10-single-listener-guard.conf by hand.
sudo systemctl daemon-reload
sudo systemctl restart litellm
```

The two-step separation (repo = template, operator = apply) preserves the invariant that no agent can mutate live systemd on Legion (safety-rules.md; ADR-103 server-only).

## 4. Verification (one stale-detection probe)

Run BEFORE apply, and again AFTER apply, from the operator shell on Legion:

```bash
# Count distinct PIDs holding a LISTEN socket on :4000.
# Expected AFTER apply: exactly 1 (the systemd-owned MainPID).
ss -H -tlnp 'sport = :4000' \
  | awk 'match($0, /pid=([0-9]+)/, m) {print m[1]}' \
  | sort -u \
  | wc -l
```

Pass criterion: value = `1`. Any value `≥ 2` means the guard did not converge — do NOT declare sp03 closed; capture PIDs and escalate as a follow-up novelty row.

Optional smoke: two back-to-back completions against LiteLLM `:4000` MUST land on the same upstream (as reported in the response `x-litellm-*` headers or `MODEL` echo). Any flicker = guard not effective.

## 5. Handoff for Terminal A (Factory)

- Registration expectation: this artefact CLOSES the OPEN-GAP tagged `systemd single-listener guard` on the novelty row `litellm_4000_orphan_reuseport`. The row itself stays `OPEN` per append-only discipline; the closure is recorded via the sp03 novelty row appended in this same PR.
- Terminal A action: NONE required in-repo. Live application is `apply=operator-Legion`; Factory only needs to acknowledge that once the operator has applied the drop-in, subsequent routing measurements (e.g. `project-reason` on `:4000`) are single-listener and the "flicker" observation from sp02 will not recur.
- Cross-reference: novelty rows above; `.claude/rules/safety-rules.md` (no live-systemd mutation from agent); `.claude/rules/agents.md` §"Factory-Only Execution" (state-change ⇒ factory PR, this PR IS the state change — repo-only).

## 6. Non-goals

- Does NOT touch LiteLLM config values (routing table, cache, auth). Those are separate rows (`litellm_4000_noauth_redis_cache_stall` etc.).
- Does NOT introduce a health-check endpoint change; existing `/v1/models` liveness signal remains as-is (per lesson `lesson_v1models_not_generation_proof`).
- Does NOT mutate any live systemd unit on Legion from this PR.
