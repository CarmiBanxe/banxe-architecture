# Secret Rotation Cron Template — Reminder-only (Sprint S17 PREP)

Document ID: RB-SEC-ROTATION-CRON-2026-05-14 | Sprint S17 | Date 2026-05-14 | Layer 2 | Last reviewed 2026-05-14
Status: SKELETON; HITL-gated (reminder-only; NO auto-execution of rotation)
HITL gate: ENFORCED — cron emits reminders only; rotation operator-led under HITL gate per D1 policy §D and S15.5 runbook §HITL gate.
Owner: Central (authoring) per IL-CANON-DOCUMENTATION-OWNED-BY-CENTRAL-2026-05-12; operator deploys cron and executes rotations.

## Anchors

- D1 policy: docs/project/security/secret-rotation-policy-2026-05-14.md (cadence + matrix + escalation)
- S15.5 runbook: docs/project/runbooks/secret-rotation-runbook-2026-05-13.md (per-secret-type 8-step procedure + smoke tests)
- ADR-032 (rotation framework Accepted); ADR-038 (Vault placeholder DEFERRED); ADR-027 (5y CASS 15 audit trail)
- G-SEC-02 (Vault adoption deferred — Track F); Sprint S17 (this); S20.5 (Telegram bot deploy — reminder delivery channel)
- IL-OPS-S15-5-HISTORICAL-LEAKS-PREP-2026-05-13 (line 8569); IL-OPS-S12-3-S2S-TOKENS-PREP-2026-05-13 (line 8508)
- FCA SYSC 15A (operational resilience)

## A. Cron schedule design (reminder-only)

Three cadence triggers, NONE of which execute rotation:

| Trigger | Schedule (UTC) | Action |
|---|---|---|
| Daily reminder | `0 9 * * *` (09:00 UTC) | Query operator vault metadata; emit secrets approaching 80% of cadence window (day 72 of 90d; day 24 of 30d; day 292 of 365d). |
| Weekly summary | `0 9 * * 1` (Monday 09:00 UTC) | Aggregated summary to operator + MLRO (vendor secrets only — D1 matrix rows 3–7); past-week executed, past-due, upcoming-7-day. |
| On-demand | manual invocation by `secret-id` | operator triggers single-secret lookup (incident response or out-of-cycle rotation). |

Rationale for 80% threshold (day 72 of 90d cycle): provides 18-day operator response window before the cadence ceiling, mirroring D1 policy §C grace window. Beyond the grace window the secret enters compromise-event treatment per D1 §A row 3.

## B. Cron entry template

Operator-side crontab (NOT installed by this PREP package — operator deploys under HITL gate):

```
# Banxe secret rotation reminder — Sprint S17 / D1 policy
# HITL-gated: reminder-only; rotation operator-led per D1 §D + S15.5 runbook §HITL gate.

# Daily reminder — 09:00 UTC
0 9 * * * /usr/local/bin/secret-rotation-reminder.sh daily 2>&1 | logger -t secret-rotation

# Weekly summary — Monday 09:00 UTC
0 9 * * 1 /usr/local/bin/secret-rotation-reminder.sh weekly 2>&1 | logger -t secret-rotation
```

`logger -t secret-rotation` routes output to `journalctl -t secret-rotation` and rsyslog. No `MAILTO=` — reminder delivery is via the script (Telegram post-S20.5 + Central log + ClickHouse Guardian per §G). On-demand invocation (`secret-rotation-reminder.sh on-demand <secret-id>`) is manual; not in crontab.

## C. Reminder script template (`secret-rotation-reminder.sh`)

Operator-side script — TODO implementation (this PREP package is template only; deploy queued under Sprint S17 follow-up). Pseudocode contract:

```
USAGE: secret-rotation-reminder.sh <mode> [secret-id]
  mode = daily | weekly | on-demand

ALGORITHM:
1. Read operator vault metadata (interim file-based; ADR-038 Vault when promoted).
   Schema per D1 §G: secret_id, owner, cadence_days, last_rotated_at,
                     rotation_due_date, runbook_ref, class.
2. For each secret:
   - days_until_due = rotation_due_date - today
   - threshold_days = cadence_days * 0.20  (18d for 90d / 6d for 30d / 73d for 365d)
3. Filter by mode:
   - daily:     days_until_due <= threshold_days AND >= -18  (grace window per D1 §C)
   - weekly:    days_until_due <= 7  (vendor-secrets only — D1 matrix rows 3–7)
   - on-demand: match secret_id exactly
4. Emit per filtered secret: secret-id, days_until_due, owner, runbook_ref, class.
5. Sinks: logger -t secret-rotation; Telegram operator channel (post-S20.5; no-op until);
         Central log; ClickHouse Guardian via ADR-027 BufferedAuditPort
         (kind=secret_rotation, action=reminder_fired, fields per D1 §F).

EXIT: 0 success | 1 metadata read error | 2 sink emit error

CONSTRAINT: script reads METADATA ONLY — no secret values read or written.
```

## D. Operator workflow (post-reminder)

1. **Receive** reminder via Telegram channel (post-S20.5) OR `journalctl -t secret-rotation` (interim).
2. **Review** against D1 §A (cadence class) + D1 §B matrix (runbook ref) + S15.5 runbook §Rotation procedure (8 steps).
3. **Engage Central HITL** per D1 §D via Claude Code session (primary per IL-CANON-CLAUDE-CODE-PRIMARY-SHELL-FALLBACK-2026-05-12); shell fallback if unavailable. Vendor-compliance keys (D1 matrix rows 3–7) → MLRO advisory.
4. **Execute rotation** per D1 §B matrix col 6 runbook reference (S15.5 runbook 8-step procedure: generate → update → restart → smoke test → revoke → verify → IL log → audit emit).
5. **Update vault metadata**: `last_rotated_at = now()`, `rotation_due_date = last_rotated_at + cadence_days`.
6. **Log IL** entry `IL-SEC-ROTATE-<secret-type>-<YYYY-MM-DD>`; emit ClickHouse Guardian record per D1 §F.

If Central unavailable same business day: operator MAY defer up to the D1 §C 18-day grace window; beyond that = compromise-event treatment.

## E. NO auto-execution (canonical constraint)

The cron template is reminder-only. The following are EXPLICITLY forbidden in this design:

- cron MUST NOT invoke `kcadm.sh update` or any KC admin write;
- cron MUST NOT issue vendor API key revocation (Modulr, SumSub, Sardine, Marble, Telegram, Jube);
- cron MUST NOT execute `ALTER USER ... WITH PASSWORD` against any database;
- cron MUST NOT modify `~/.ssh/` or `~/.gnupg/`;
- cron MUST NOT write any secret value anywhere;
- cron MUST NOT install or rotate GitHub PATs via API.

Auto-rotation is deferred to G-SEC-02 Vault adoption (ADR-038 when promoted). Adding any auto-execution to the script = governance incident per CLAUDE.md §11 (production-state mutation gate without human approval).

## F. Rollback (cron mis-fire — no destructive action)

Cron emits reminders only; mis-fire ≠ harmful. Recovery:

1. Identify mis-fire root cause (vault metadata corruption, clock skew, false-positive on `rotation_due_date`).
2. Mark secret as false-positive: append `false_positive_marks` entry `{timestamp, reason}`; emit ClickHouse Guardian record `action=false_positive_mark`.
3. Suppress future reminders for that secret-id until mark cleared (default 24h; configurable).
4. Document recurring pattern (>2 mis-fires per secret-id per quarter) in INSTRUCTION-LEDGER.md; revisit threshold under Sprint S25.4 quarterly review per D1 §H.

No service interruption from cron mis-fire (cron does not act). No `git reset` / production state restoration required.

## G. Audit trail

Cron-run events MUST emit to ClickHouse Guardian per ADR-027 BufferedAuditPort:

| Event | `action` | fields per D1 §F |
|---|---|---|
| Reminder fired (per secret) | `reminder_fired` | timestamp, secret_id, days_until_due, mode, runbook_ref |
| Cron run start | `cron_run_started` | timestamp, mode |
| Cron run complete | `cron_run_completed` | timestamp, mode, secrets_matched_count, exit_code |
| False-positive mark | `false_positive_mark` | timestamp, secret_id, operator_id, reason |
| Sink failure | `sink_failure` | timestamp, sink, error |

If ClickHouse Guardian write fails at reminder-emit time, fall back to logger-only and queue retry; do NOT silently drop. Audit gap = compliance incident per ADR-027 §Context.

## H. Open dependencies

- **Operator vault metadata schema** (interim file-based; awaits ADR-038 Vault). Fields per §C algorithm + D1 §G. Schema design queued under Sprint S17 follow-up.
- **Telegram bot deployment** (Sprint S20.5) — reminder delivery channel; until then `telegram_emit` is no-op with debug log.
- **`secret-rotation-reminder.sh` implementation** — template here; actual implementation queued as Sprint S17 follow-up.
- **ClickHouse Guardian bash client** — operator-side wrapper for BufferedAuditPort HTTP API per ADR-027; TODO. Until then, audit-emit writes to `~/audit-drop/secret-rotation/<YYYY-MM-DD>.jsonl` for forwarding.
- **Vault adoption** (G-SEC-02, ADR-038) DEFERRED. When promoted, template is superseded by Vault native scheduler.

## I. EDGE CASES

1. **Telegram bot circular dependency** — Telegram bot token (D1 matrix row 7) reminder fires; rotation requires Telegram for completion alert. Order-of-operations: rotate audit channel first OR use out-of-band channel (SMS / email) before rotating the reminder-delivery token. Per S15.5 runbook §TODO #2.
2. **Clock skew / file lock** — cron uses system UTC; metadata uses UTC ISO-8601 (skew tolerance ±2h, else `cron_run_started.error`). Concurrent on-demand + daily cron MUST use `flock` (shared for reminder; exclusive for false-positive-mark update).
3. **GPG 365d cadence edge** — 80% threshold = day 292; filter logic handles 90d and 365d uniformly via `cadence_days * 0.20`.
4. **Vault promotion mid-cycle** — when ADR-038 Vault promoted, cron decommissioned; in-flight reminders for migrated secrets de-duplicated (Vault native scheduler takes precedence). Migration plan = Sprint S17 follow-up.

## Anchors footer

D1 policy `docs/project/security/secret-rotation-policy-2026-05-14.md`; S15.5 runbook `docs/project/runbooks/secret-rotation-runbook-2026-05-13.md`; ADR-027 / ADR-032 / ADR-038; G-SEC-02 (Vault adoption deferred — Track F); Sprint S17 / S20.5 / S25.4; IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12; IL-CANON-DOCUMENTATION-OWNED-BY-CENTRAL-2026-05-12; IL-CANON-CLAUDE-CODE-PRIMARY-SHELL-FALLBACK-2026-05-12; IL-CANON-PERSISTENCE-SHELL-FIXATION-2026-05-12; IL-CANON-F01-REINFORCE-ALWAYS-ONE-ACTIONABLE-2026-05-12; IL-CANON-ALL-CLAUDE-CODE-PROMPTS-VIA-FILE-2026-05-12.

## TODOs (operator + future-sprint)

- `secret-rotation-reminder.sh` implementation (Sprint S17 follow-up).
- Operator vault metadata schema (interim file-based; awaits ADR-038).
- Telegram bot deployment (Sprint S20.5) for reminder delivery.
- ClickHouse Guardian bash client (per ADR-027 BufferedAuditPort).
- Cron deployment on operator host (HITL-gated; NOT executed here).
- Migration plan cron-reminder → Vault native scheduler when ADR-038 promoted.
