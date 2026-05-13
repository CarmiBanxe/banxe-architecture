# Secret Rotation Runbook (Sprint S15.5)

**Status:** SKELETON
**Sprint:** S15.5
**Date:** 2026-05-13
**Layer:** 2 (Project / Runbooks)
**HITL gate:** REQUIRED (Central + operator + MLRO advisory)
**Owner:** Operator (executor); Central (procedure custodian)

## Anchors

- ADR-027 — audit trail durability (5y CASS 15 — rotation events logged)
- ADR-029 — Postgres backup strategy (rollback path)
- ADR-032 — Secret rotation policy (interim; 90-day cadence; n8n + manual)
- ADR-038 — Vault adoption placeholder (DEFERRED, G-SEC-02 / Sprint S17+)
- Sprint S15.5 (this prep), S15.4 (FCA SUP 15 + GDPR Art.33 notification),
  S17 (90-day rotation cadence enforcement),
  S12.5 (G-IAM-08 DB password prep), S12.6 (G-IAM-09 prep)
- G-SECURITY-HISTORICAL-LEAKS (mitigation target)
- banxe-emi-stack PR #133, #134 — G-IAM-08 / G-IAM-09 prep precedent
- FCA SYSC 15A (operational resilience)

## Scope

Per-secret-type rotation procedure template. **No production rotation is executed in this
PR.** Operator invokes the runbook under HITL gate after S15.5 audit (D1) confirms a
P0 / P1 active-prod credential leak.

### Secret types covered

| # | Secret type | Vendor / scope | Cadence (ADR-032) | Rotation owner |
|---|---|---|---|---|
| 1 | Modulr live API key | Modulr (payments) | 90 days | Operator (vendor console) |
| 2 | SumSub API key | SumSub (KYC) | 90 days | Operator (vendor console) |
| 3 | Sardine.ai API key | Sardine (fraud) | 90 days | Operator (vendor console) |
| 4 | Marble API key + INBOX_ID | Marble (AML) | 90 days | Operator (TODO — Sprint S20.6 onboarding) |
| 5 | Telegram bot token | Telegram (alerts) | 180 days | Operator (BotFather) |
| 6 | Jube admin password | Jube (AML / fraud) | 90 days | Operator (Jube admin UI) |
| 7 | Keycloak client secrets | KC realm `banxe-emi` | 90 days (ADR-017 §5) | Operator (KC admin) |
| 8 | Internal service S2S secrets | banxe-emi-stack | 180 days | Operator + Central |
| 9 | Database passwords | Postgres / ClickHouse / Frankfurter PG | 180 days | Operator (G-IAM-08/09 prep) |

## Pre-flight (operator only — NOT executed in this PR)

1. Identify leak from S15.5 audit (D1) — confirm `severity = P0` or `P1`, vendor name,
   and last-seen commit SHA.
2. Verify vendor console access — operator has admin credentials for the vendor whose
   secret is being rotated.
3. Verify backup / rollback path per ADR-029 — Postgres dump + WAL exists if rotating
   DB password; service config snapshot exists if rotating env var.
4. Notify Central + MLRO advisory — Telegram out-of-band (NOT in PR body).
5. Confirm dual-key grace window (per ADR-032 §Decision Drivers #5) — vendor supports
   coexistent old + new keys for at least 10 minutes. If not — schedule maintenance window.

## Rotation procedure (HITL-gated template)

Per secret type, the canonical 8-step procedure:

1. **Generate** new secret in vendor console (or `openssl rand -hex 32` for internal S2S /
   DB passwords). Capture secret-id (NOT value) for audit.
2. **Update** service config — env var, Keycloak client secret field, vault entry
   (post-S17 ADR-038), or DB `ALTER USER ... WITH PASSWORD` statement.
3. **Restart / reload** service — systemd `systemctl restart <unit>`, or
   `docker compose up -d <service>` with new env. Confirm new process picked up new value.
4. **Smoke test** new secret — vendor-specific endpoint per secret-type matrix below.
5. **Revoke** old secret in vendor console — explicit revocation (not just deletion of
   local copy). For DB: `DROP ROLE` only after confirming no active sessions on old role.
6. **Verify** old secret revoked — negative smoke test: call vendor endpoint with old
   key; expected 401 / 403.
7. **Log** rotation event to IL with timestamp + operator co-sign + secret-id (NEVER value).
   Format: `IL-SEC-ROTATE-<vendor>-<YYYY-MM-DD>`.
8. **Audit** event to ClickHouse Guardian per ADR-027 (BufferedAuditPort,
   `kind=secret_rotation`, retention 5y CASS 15).

### Vendor-specific smoke test endpoints

| Secret type | Smoke test |
|---|---|
| Modulr | `GET /accounts` with new key → 200 |
| SumSub | `GET /resources/applicants` with new key → 200 |
| Sardine.ai | `POST /v1/customers/feedback` (canary payload) → 200 |
| Marble | TODO — Sprint S20.6 onboarding (vendor docs pending) |
| Telegram bot | `GET /bot<token>/getMe` → 200 |
| Jube admin | UI login with new password → success |
| Keycloak client | OIDC client_credentials grant with new secret → access_token issued |
| Internal S2S | `GET /health` to dependent service with new bearer → 200 |
| DB passwords | `psql -h <host> -U <user>` with new password → connected; `SELECT 1` → 1 |

## HITL gate

Rotation is a security-boundary change and MUST be gated by:

- **Central** — Claude Code (this runbook is the canonical procedure)
- **Operator** — executor (vendor console access, prod env access)
- **MLRO advisory** — informed for P0; sign-off only for P0 with customer-data exposure

**EMERGENCY override** — for a P0 active-leak with confirmed external exposure (e.g.,
gitleaks finding cross-referenced to a public clone), operator MAY proceed with rotation
without MLRO synchronous sign-off, **provided** retrospective Central + MLRO sign-off
is captured in the rotation IL entry within 24h. This mirrors FCA SUP 15 same-business-day
notification expectations.

## Rollback

If new secret fails smoke test (step 4) or breaks dependent service:

1. **Re-activate** old secret in vendor console (within grace window from pre-flight #5).
2. **Revert** service config to old value; restart service.
3. **Confirm** dependent service restored — repeat smoke test of dependent endpoint.
4. **Document** rollback event in rotation IL entry (do NOT close — keep OPEN with
   `status: ROLLED_BACK`, root-cause TBD).
5. **Retry** rotation after root-cause analysis; do not bypass smoke test.

## Audit trail

Every rotation event (success, rollback, or revoke failure) MUST produce:

1. An IL entry — `IL-SEC-ROTATE-<vendor>-<YYYY-MM-DD>` — with secret-id, operator,
   timestamp, smoke-test result, rollback flag.
2. A ClickHouse audit record via ADR-027 BufferedAuditPort
   (`kind=secret_rotation`, `payload={vendor, secret_id, outcome, operator}`),
   retained 5y per CASS 15.
3. Optional: post-rotation Telegram message to operator channel for cadence visibility
   (TG bot token rotation handled separately to avoid circular dependency).

## Anchors footer

- ADR-027 (audit trail), ADR-029 (backup), ADR-032 (rotation policy),
  ADR-038 (Vault placeholder DEFERRED)
- Sprint S15.5 (this), S15.4 (FCA SUP 15 / GDPR Art.33 escalation),
  S17 (90-day cadence enforcement), S12.5 / S12.6 (G-IAM-08/09 DB password prep)
- banxe-emi-stack PR #133 / #134 — G-IAM-08 / G-IAM-09 prep precedent
- G-SECURITY-HISTORICAL-LEAKS (closes when all P0 + P1 leaks rotated and logged)
- FCA SYSC 15A (operational resilience)
- IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12 (this runbook = Layer 2)

## TODOs

- Marble vendor-specific rotation steps — Sprint S20.6 onboarding (vendor docs pending).
- Telegram bot token rotation order-of-operations — avoid circular dependency with
  audit-channel alerts (rotate audit channel first or use secondary out-of-band channel).
- ADR-038 Vault entries replace env-var injection step (2) when Sprint S17 lands;
  this runbook supersedes when ADR-038 promoted from placeholder.
- Integrate rotation invocation into n8n workflow per ADR-032 §Implementation Plan
  (90-day cron — pending Sprint S17 enforcement).
- Per ADR-032 §Decision Drivers #3 — wire rotation event emitter to ADR-027
  BufferedAuditPort with structured payload schema (TBD Sprint S17).
- Negative smoke test (step 6) operationalisation per vendor — capture expected error
  body / status code in vendor-specific matrix above.
- DB password rotation interaction with PgBouncer / connection-pooler reload — verify
  drain-then-reload sequence to avoid mid-transaction failure (S12.5 G-IAM-08 prep).
