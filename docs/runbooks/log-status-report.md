# log-status-report — task-log markdown summary (ops utility)

> Read-only ops report generator for `/tmp/sp*-*.log` style task logs.
> Analogous to a CI summary: takes N log files, emits ONE markdown table
> classifying each file's state (FINISHED / IN_PROGRESS / INCOMPLETE / EMPTY)
> and pulls a short summary line per file.

Pattern reference (ADR-102 reference-not-restate, **not** a copy): shape of
this unit + script mirrors `scripts/novelty-watcher.sh` +
`systemd/novelty-watcher.{service,timer}` — the same config-over-hardcode
env plumbing, the same `Type=oneshot` service anchored to `%h`, the same
"template in-repo, install by operator" discipline. Behaviour is unrelated.

## Purpose

The Legion / evo1 terminals dispatch background jobs whose stdout goes to
`/tmp/sp<N>-<slug>.<epoch>.log`. Each job typically ends with a canonical
one-line marker in the form `[KEY=value] [KEY=value] ...`. This utility
walks the current glob, picks up state from either the marker or the
mtime, and writes a single markdown file operators can `cat` to see at a
glance what's still running and what's finished.

## Read-only contract

The script **only opens log files for reading** (`stat`, `wc`, `grep`,
`tail`). It **never** truncates, rotates, moves, deletes, or otherwise
modifies any input log. It does not signal or inspect processes beyond
counting matches to `pgrep -c -f "$JOB_MATCH"`. `safety-rules.md`
destructive-op verify-step does not apply because there is no destructive
op — the invariant is stated here for review.

## Configuration (config-over-hardcode, CLAUDE.md §10)

All tunables live in an EnvironmentFile, not the script or unit files.
Sample: `config/log-status-report.env.sample`.

| Env var       | Default                                    | Meaning |
|---------------|--------------------------------------------|---------|
| `LOG_GLOB`    | `/tmp/sp*-*.log`                           | Shell glob for input logs. |
| `STATUS_PATH` | `$HOME/banxe-dev/DISPATCH-STATUS.md`       | Absolute path to the markdown output. Atomic write via `mktemp`+`mv`. |
| `STALE_SECS`  | `1800`                                     | mtime threshold for `IN_PROGRESS` vs `INCOMPLETE`. |
| `JOB_MATCH`   | `claude -p`                                | `pgrep -c -f` pattern for the active-jobs header line. |

If `STATUS_PATH`'s directory is missing / not writable, the script exits
non-zero with a diagnostic instead of guessing.

## State classification

| State         | Condition                                                       |
|---------------|-----------------------------------------------------------------|
| `EMPTY`       | `size == 0`.                                                    |
| `FINISHED`    | any line matches the marker regex `^\[[A-Z].*=.*\]`.            |
| `IN_PROGRESS` | no marker AND `mtime` newer than `STALE_SECS`.                  |
| `INCOMPLETE`  | no marker AND `mtime` older than `STALE_SECS`.                  |

Summary column: for FINISHED = the last matching marker line; for
IN_PROGRESS / INCOMPLETE = the last line of the file; for EMPTY = blank.
Pipes are transliterated to fullwidth (`｜`) so they never break the
markdown row.

## Install (operator, HITL — CLAUDE.md §11 / ADR-156)

The `.service` and `.timer` in `systemd/` are **templates**. Nothing in
this repo enables them. On the target host:

```bash
# 1) Populate the env file OUTSIDE the repo (mode 0600, never committed).
install -m 0600 -D /dev/null ~/.config/banxe/log-status-report.env
cp config/log-status-report.env.sample ~/.config/banxe/log-status-report.env
$EDITOR ~/.config/banxe/log-status-report.env

# 2) Drop the unit + timer under systemd --user.
mkdir -p ~/.config/systemd/user
cp systemd/log-status-report.service ~/.config/systemd/user/
cp systemd/log-status-report.timer   ~/.config/systemd/user/

# 3) Enable — operator step. Neither the script nor the factory arms this.
systemctl --user daemon-reload
systemctl --user enable  log-status-report.timer
systemctl --user start   log-status-report.timer

# 4) One-shot verification run.
systemctl --user start   log-status-report.service
cat "${STATUS_PATH:-$HOME/banxe-dev/DISPATCH-STATUS.md}"
```

Disable is the reverse: `systemctl --user disable --now log-status-report.timer`.

## Self-test output (first ~15 lines, captured 2026-07-06)

```
# DISPATCH-STATUS

_generated: 2026-07-06T22:43:42Z (UTC) on banxe-NucBox-EVO-X1 by scripts/log-status-report.sh_

- **config:** `LOG_GLOB=/tmp/sp*-*.log` / `STATUS_PATH=/home/banxe/banxe-dev/DISPATCH-STATUS.md` / `STALE_SECS=1800s` / `JOB_MATCH=claude -p`
- **active jobs (pgrep -c -f "claude -p"):** 2

| job | log | state | summary | mtime |
|---|---|---|---|---|
| sp33b-log-status | `sp33b-log-status.1783377624.log` | EMPTY |  | 2026-07-06T22:40:24Z |
| sp33-dispatch-notifier | `sp33-dispatch-notifier.1783377147.log` | IN_PROGRESS | API Error: ... | 2026-07-06T22:37:23Z |
| sp32-bestdec-agent | `sp32-bestdec-agent.1783376501.log` | FINISHED | [BESTDEC_AGENT=designed] [...] | 2026-07-06T22:30:15Z |
| sp31-mint-1075 | `sp31-mint-1075.1783374154.log` | FINISHED | [PR#=1075] [REBASED=onto f1cdb71] [CHECK=pass] [...] | 2026-07-06T22:06:16Z |
| sp30-amend-1075 | `sp30-amend-1075.1783373707.log` | FINISHED | [AMENDMENT=§4-header-body-blessed] [...] | 2026-07-06T21:38:43Z |
| sp29-delivery-canon | `sp29-delivery-canon.1783372607.log` | FINISHED | [DELIVERY_CANON=written] [...] | 2026-07-06T21:22:29Z |
| sp27-arm-1072 | `sp27-arm-1072.1783371560.log` | FINISHED | [PR#=1072] [REBASED=onto a5c77d9] [CHECK=pass] [...] | 2026-07-06T21:00:52Z |
```

All four states (`FINISHED`, `IN_PROGRESS`, `INCOMPLETE`, `EMPTY`) are
present in the full self-test run against 50 files in `/tmp/sp*-*.log`.

## Anchors

- `scripts/novelty-watcher.sh` + `systemd/novelty-watcher.{service,timer}`
  — pattern reference, ADR-102 (reference-not-restate, **not** copied).
- CLAUDE.md §10 — Configuration-over-Hardcoding (all knobs env-driven).
- CLAUDE.md §11 — no autonomous prod-state mutation (HITL install).
- `.claude/rules/safety-rules.md` — this script performs NO destructive op;
  the verify-step canon is preserved by the read-only contract above.
- ADR-120 — per-session worktree isolation used to build this shard.
