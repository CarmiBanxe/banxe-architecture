# ADR-032 — Secret Rotation Policy (Interim)

**Status:** Proposed (2026-05-06)
**Author:** Architecture WG
**Closes:** G-SEC-01 (canonical), G-IAM-05 (canonical), V-09 (HANDOFF)
**Linked:** ADR-017 §5 (90-day cadence), I-34 (no direct credentials), ADR-027 (audit trail buffer),
IL-SEC-01 (Frankfurter password exposure 2026-05-05), MASTER-PLAN Track F, FCA SYSC 15A

---

## Context

Banxe's secret surface comprises four categories of operator-supplied credentials:
(1) **Keycloak IAM secrets** — `KC_BOOT_ADMIN_PASSWORD`, `KC_DB_PASSWORD`, and four
`KC_CLIENT_SECRET_*` values stored in `infra/keycloak-banxe-emi/.env.example` (injected at
runtime into the Keycloak container on evo1);
(2) **External service API keys** — `MARBLE_API_KEY`, `JUBE_PASSWORD`, `SUMSUB_APP_TOKEN`,
`SUMSUB_WEBHOOK_SECRET`;
(3) **Infrastructure credentials** — `POSTGRES_PASSWORD`, `CLICKHOUSE_PASSWORD`,
`PSD2_POSTGRES_PASSWORD`, `AUTH_SECRET_KEY` (JWT signing key);
(4) **Automation tokens** — `TELEGRAM_BOT_TOKEN` (n8n shortfall-alert + safeguarding workflows),
GitHub Actions PATs (deploy + registry push).

ADR-017 §5 committed a 90-day rotation cadence for KC client secrets and declared it NOT_STARTED
(G-IAM-05). No cron, calendar reminder, n8n workflow, or runbook chapter covers multi-secret
rotation. IL-SEC-01 (2026-05-05) addressed a point incident — a Frankfurter Postgres password
printed to a terminal session — but did not produce a general policy. Rotation events are not
logged to ClickHouse, meaning an auditor cannot distinguish "never rotated" from "rotated but
unlogged". FCA SYSC 15A requires an operational resilience programme including credential
management procedures; an absence of any rotation schedule is a measurable control gap.

n8n is live on evo1 (:5678) with five operational workflows (shortfall-alert, daily-recon-report,
complaint-sla-monitor, mcp-health-monitor, safeguarding-shortfall-alert). No rotation-related
workflow exists. Vault/Infisical adoption is deferred to G-SEC-02 (long-term roadmap); this ADR
covers the interim policy using only tools already in the stack.

---

## Decision Drivers

1. **ADR-017 §5 cadence commitment** — 90-day rotation for KC client secrets was committed in the
   Keycloak IAM cutover ADR; G-IAM-05 is NOT_STARTED. Closing this gap is a prerequisite for
   GATE-D sign-off.
2. **FCA SYSC 15A operational resilience** — credential management procedures must be documented,
   tested, and evidenced. An unlogged rotation history prevents supervisory evidence reconstruction.
3. **Audit trail completeness (I-24 + ADR-027)** — rotation is an operational action; every rotation
   event must produce an append-only audit record in ClickHouse via the ADR-027 `BufferedAuditPort`.
4. **Operability constraint** — single-engineer team; automation must reduce cognitive overhead, not
   add it. New dedicated services (Vault, Infisical) are out of scope until G-SEC-02.
5. **Reversibility / grace windows** — every rotation must support a dual-key grace period
   (old + new credential simultaneously valid) to prevent service downtime during rollout.

---

## Considered Options

### Option (a) — Static cadence + manual runbook (current state hardened)

Extend IL-SEC-01 into a comprehensive runbook chapter covering all secret types. Add a calendar
reminder (Google Calendar / cron email) to trigger manual rotation per type-specific cadence.

| Dimension | Assessment |
|-----------|-----------|
| Effort | Minimal — documentation only |
| Reliability | Low — human-error prone; calendar reminders are silently missed |
| Audit trail | None — rotation events not logged unless operator manually adds log step |
| ClickHouse coupling | None |
| Operability | High cognitive load — operator must remember cadence + runbook steps |

**Risk:** Rotation silently falls behind cadence when operator is on leave or in sprint crunch.
No observable signal until audit. FCA SYSC evidence gap persists.

---

### Option (b) — n8n scheduled workflows + IL-SEC-01 runbook as manual fallback (RECOMMENDED)

Each secret type gets an n8n workflow with a cron trigger. The workflow sends a Telegram alert to
the CTIO/CEO, logs a `ROTATION_DUE` event to ClickHouse via the ADR-027 `BufferedAuditPort` HTTP
endpoint, and gates on a human-approve step before executing the rotation script. n8n already runs
on evo1 (:5678); `TELEGRAM_BOT_TOKEN` and `TELEGRAM_MLRO_CHAT_ID` are already in the n8n env.

| Dimension | Assessment |
|-----------|-----------|
| Effort | Moderate — 5-6 n8n workflow templates + HTTP action node per secret type |
| Reliability | High — cron is deterministic; missed triggers are visible in n8n execution log |
| Audit trail | Full — ROTATION_DUE + ROTATION_COMPLETED events logged to ClickHouse |
| ClickHouse coupling | Low — via ADR-027 BufferedAuditPort (survives CH outage) |
| Operability | Low cognitive load — operator receives Telegram prompt, clicks approve |

**Risk:** n8n outage (OOM, restart) delays reminder delivery. Mitigated by n8n
`restart: unless-stopped` policy and IL-SEC-01 runbook as manual fallback.

---

### Option (c) — OPA + secret-rotator service (light Vault alternative)

Deploy a minimal `secret-rotator` service (FastAPI, ~200 lines) with an OPA policy file defining
per-secret cadence and rotation procedures. The service exposes a `/rotate/{secret_type}` endpoint
that re-generates credentials, updates target services via their admin APIs, and logs to ClickHouse.

| Dimension | Assessment |
|-----------|-----------|
| Effort | High — new service, OPA policy bundle, per-secret admin API integration |
| Reliability | High — deterministic, fully automated |
| Audit trail | Full — service logs every rotation step |
| ClickHouse coupling | Low — via ADR-027 buffer |
| Operability | Medium — new service to monitor, OPA policies to maintain |

**Risk:** KC admin API for client_secret rotation, Jube password rotation endpoint, and Marble
API key rotation each require distinct integration patterns. Building all before G-SEC-02 adds
scope without proportional benefit over option (b) for a single-engineer team.

---

### Option (d) — Vault / Infisical deployment (G-SEC-02 long-term)

Deploy HashiCorp Vault or Infisical on evo1/evo2. Enable dynamic secrets for PostgreSQL, static
secret versioning for external API keys, and lease-based rotation for KC service accounts.

| Dimension | Assessment |
|-----------|-----------|
| Effort | Very high — new infrastructure, agent sidecars, policy authoring, secret migration |
| Reliability | Highest — industry-standard secret lifecycle management |
| Audit trail | Full — Vault audit device logs every secret access + rotation |
| ClickHouse coupling | None — Vault is the source of truth |
| Operability | Requires Vault operator expertise; adds critical-path dependency |

**Risk:** Vault HA requires a 3-node Raft cluster; single-node Vault is a SPOF. Infisical
self-hosted adds MongoDB coupling (Midaz already uses it, but architectural dependency grows).
Both require migration of all existing secrets with a planned rollout window. Deferred to G-SEC-02.

---

## Trade-off Summary

| Option | Effort | Reliability | Audit trail | Operability |
|--------|--------|------------|-------------|-------------|
| (a) manual runbook | Min | Low | None | Low (high cognitive) |
| (b) n8n workflows | Moderate | High | Full (via ADR-027) | High |
| (c) secret-rotator service | High | High | Full | Medium |
| (d) Vault/Infisical | Very high | Highest | Full | Low (expertise req.) |

---

## Recommendation

**Option (b) — n8n scheduled workflows with IL-SEC-01 runbook as manual fallback.**

Rationale:
- n8n is already running and has `TELEGRAM_BOT_TOKEN` wired — no new infrastructure required.
- Option (a) alone is insufficient: unobservable cadence drift is an FCA SYSC evidence gap.
- Option (c) adds a new service and per-adapter integrations that exceed sprint scope without
  material reliability gain over (b) for the current secret inventory size.
- Option (d) is correctly deferred to G-SEC-02; this ADR creates the explicit placeholder.

**Cadence and ownership matrix:**

| Secret type | Storage location | Cadence | n8n trigger | Approval | Grace window |
|-------------|-----------------|---------|-------------|----------|-------------|
| `KC_CLIENT_SECRET_*` (×4) | evo1 keycloak.env | 90 days | cron `@every90d` | CTIO | 24h dual-secret |
| `KC_BOOT_ADMIN_PASSWORD` | evo1 keycloak.env | 180 days | cron `@every180d` | CEO | 1h dual-pwd |
| `KC_DB_PASSWORD` | evo1 compose env | 365 days | manual + n8n alert | CTIO | brief KC restart |
| `AUTH_SECRET_KEY` (JWT) | evo1 `.env` | 90 days | cron `@every90d` | CTIO | 15 min (JWT TTL) |
| `POSTGRES_PASSWORD` / `CLICKHOUSE_PASSWORD` | evo1 `.env` / systemd | 365 days | n8n + runbook | CTIO | service restart |
| GitHub Actions PATs | GitHub Secrets | 30 days | cron `@every30d` | CEO | immediate |
| `MARBLE_API_KEY` / `JUBE_PASSWORD` | evo1 `.env` | 180 days | n8n alert + manual | CTIO | 24h dual-key |
| `SUMSUB_APP_TOKEN` / `SUMSUB_WEBHOOK_SECRET` | evo1 `.env` | 180 days | n8n alert + manual | CTIO | 24h |
| `TELEGRAM_BOT_TOKEN` | n8n env + `.env` | on-incident | n8n alert (compromise) | CEO | immediate |
| `FCA_REGDATA_PASSWORD` | evo1 `.env` | 90 days | cron `@every90d` | CEO | immediate |

**n8n and Vault boundary:**
This ADR covers the interim period until G-SEC-02. When Vault/Infisical is adopted, the n8n
rotation workflows become Vault leases and this ADR is deprecated.

---

## Consequences

### Positive

- G-IAM-05 (90-day KC client_secret rotation) gains an observable, auditable mechanism.
- Every rotation event produces a `ROTATION_DUE` + `ROTATION_COMPLETED` pair in ClickHouse via
  ADR-027 `BufferedAuditPort` — FCA SYSC 15A evidence chain is complete.
- IL-SEC-01 Frankfurter incident is resolved as a specific action item within the broader policy.
- n8n human-approve gate satisfies HITL requirement (I-27): cron proposes, operator confirms.

### Negative / Risks

- n8n is a single point of failure for rotation reminders; n8n OOM/restart = missed trigger.
  Mitigated by `restart: unless-stopped` policy and IL-SEC-01 runbook fallback.
- KC client_secret dual-key grace window requires `previousClientSecret` support (KC >= 20.x
  supports this natively). Must be verified before first rotation drill.
- GITHUB_PAT 30-day cadence creates operational overhead; consider fine-grained PAT with minimal
  scope to reduce blast radius between rotations.

---

## Implementation Plan

1. **n8n workflow templates** (Sprint 4+) — create `n8n/workflows/secret-rotation-kc-client.json`
   (KC x4 client secrets, 90-day cron), `n8n/workflows/secret-rotation-github-pat.json` (30-day),
   `n8n/workflows/secret-rotation-reminder.json` (generic 180-day alert). Each workflow structure:
   cron trigger -> HTTP POST to BufferedAuditPort `/audit` (`ROTATION_DUE`) -> Telegram alert ->
   human-approve gate -> rotation script execution -> HTTP POST (`ROTATION_COMPLETED`).

2. **ADR-027 BufferedAuditPort schema extension** — add two event types `ROTATION_DUE` and
   `ROTATION_COMPLETED` to `safeguarding_audit` ClickHouse table. Fields: `secret_type`, `owner`,
   `previous_rotation_date`, `next_due_date`, `approved_by`.

3. **Dry-run rotation drill** — execute one KC client_secret rotation
   (`KC_CLIENT_SECRET_BANXE_COMPLIANCE_API`) manually per IL-SEC-01 runbook pattern, verify
   dual-secret grace window, confirm `ROTATION_COMPLETED` event in ClickHouse.

4. **Gitleaks enforcement** — verify `gitleaks detect` pre-commit hook covers all secret types in
   the cadence matrix; add missing patterns to `.gitleaks.toml` if any gaps found.

5. **G-SEC-02 placeholder ADR** — open `decisions/ADR-033-vault-adoption.md` as Status: Placeholder.
   Trigger for activation: secret volume > 30 or dynamic secrets required for PostgreSQL.

---

## Decision

**Pending** — operator acceptance required.
Implementation begins only after operator confirms Option (b) and phasing.
