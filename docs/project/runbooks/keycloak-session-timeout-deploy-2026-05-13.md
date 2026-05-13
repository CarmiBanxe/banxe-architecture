# Keycloak Session Timeout Hardening — Deploy Runbook (Sprint S12.2)

Document ID: RB-KC-SESSION-TIMEOUT-2026-05-13
Status: SKELETON
Sprint: S12.2 (Phase G session timeout hardening)
Layer: 2 (Product Plane runbook per IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12)
HITL gate: REQUIRED — Central + operator + read-only diagnostic pre-deploy on evo1; MLRO advisory.
Owner: Central (authoring) per IL-CANON-DOCUMENTATION-OWNED-BY-CENTRAL-2026-05-12; operator executes under HITL gate.
Last reviewed: 2026-05-13

## Anchors

- ADR-017 — Keycloak IAM cutover for EMI realm `banxe-emi`.
- ADR-027 — Audit-trail durability strategy (deploy + rollback events sink to ClickHouse Guardian, 5y CASS 15 retention).
- ADR-030 — Auth surface rate-limit policy (auth surface change touches FCA SCA per PSD2 RTS Art.4).
- IL-OPS-ROADMAP-SPRINTS-S12-S25-APPROVED-2026-05-11 — defines Sprint S12.2 scope (Phase G session timeout hardening).
- IL-OPS-S12-1-DONE-EVIDENCE-AND-NEW-GAPS-2026-05-12 — KC 26.2.5 prod evidence (Postgres backend `jdbc:postgresql://127.0.0.1:15433/keycloak`).
- banxe-emi-stack PR #134 (G-IAM-09 prep, 29/29 PASS) — pg_dump backup pattern reference.
- Style sibling: docs/project/runbooks/README.md §A.1 (KC runbook MISSING; this artefact populates the KC slot in the project-side catalogue). The Safeguarding + reconciliation project-side runbook is queued (D3.3.4 / S16); not yet on main — cross-link to be added once landed.

## Scope

KC realm `banxe-emi` on evo1 (Legion 100.101.218.26:8180 canonical authority per ADR-017 §1). The deploy mutates three realm-level session timeout fields on the existing realm — it is a policy/config edit, NOT a destructive realm-create. S12.4 realm provisioning HOLD (G-IAM-08 / G-IAM-09 / G-FACTORY-05) does NOT block S12.2.

Target settings (per Sprint S12.2 roadmap row):

| Field (KC 26.2.5)            | Target value | Brief shorthand          | Notes                                                                 |
|------------------------------|--------------|--------------------------|-----------------------------------------------------------------------|
| `accessTokenLifespan`        | 900 (15 min) | access TTL 15 min        | Current prod value TODO — read via kcadm.sh pre-deploy. KC default 5 min on 26.x. |
| `ssoSessionIdleTimeout`      | 28800 (8 h)  | SSO session idle 8 h     | Current prod value TODO — read via kcadm.sh pre-deploy.               |
| `ssoSessionMaxLifespan`      | 86400 (24 h) | SSO max 24 h (defensive ceiling) | TODO operator confirmation — defensive ceiling, not in original brief row. |
| `accessTokenLifespanForImplicitFlow` | 900 (15 min) | implicit flow parity     | Parity with access TTL; KC docs recommend matching.                   |
| `offlineSessionIdleTimeout`  | 2592000 (30 d) | offline session idle (refresh) | KC field for long-lived refresh tokens; brief "Refresh TTL 30 min" reads as session idle 30 d in KC nomenclature — TODO operator decision per EDGE CASES §3 below. |

Edge case (brief vs KC nomenclature): the roadmap row "refresh token TTL 30 min" does not map 1:1 to a single KC field on 26.x. KC exposes refresh-token lifetime via `ssoSessionIdleTimeout` for online sessions (token refresh fails after idle > N) and `offlineSessionIdleTimeout` for offline tokens. The 30-min reading conflicts with KC default 30-day offline idle; documented as TODO operator decision rather than auto-applied.

## Pre-flight (NOT executed in this PR — operator-only under HITL gate)

1. SSH evo1; verify KC service active:
   ```
   ssh evo1 systemctl status keycloak
   ```
   Expected: `active (running)` with no recent restart loop. Abort if degraded.

2. Read current realm config via kcadm.sh (read-only):
   ```
   kcadm.sh get realms/banxe-emi --fields accessTokenLifespan,ssoSessionIdleTimeout,ssoSessionMaxLifespan,accessTokenLifespanForImplicitFlow,offlineSessionIdleTimeout
   ```
   Capture stdout to evidence log; this seeds the `_previousValues` block of `banxe-emi-session-config.json` (D2 artefact).

3. Snapshot current values to a timestamped evidence file under operator's audit drop (NOT inside this repo). Fields captured:
   - `accessTokenLifespan` → fill `{{CURRENT_AT_LIFESPAN}}` in template.
   - `ssoSessionIdleTimeout` → fill `{{CURRENT_SSO_IDLE}}` in template.
   - `ssoSessionMaxLifespan` → fill `{{CURRENT_SSO_MAX}}` in template.
   - Timestamp UTC → `{{TIMESTAMP_UTC}}`.
   - Operator handle → `{{OPERATOR_HANDLE}}`.
   Sign the evidence row (operator co-sign required per HITL gate).

4. Verify pg_dump backup is available per G-IAM-09 prep package (banxe-emi-stack PR #134, 29/29 PASS pattern). Restore-path must exist before any mutation. Abort if no recent backup (≤24 h old).

5. Confirm no in-flight authentication-sensitive operation (Phase G smoke test window or active SCA challenges). Coordinate with operator + MLRO advisory.

## Deploy steps (NOT executed in this PR — operator-led under HITL gate)

1. Re-read current config (idempotent read, last-chance snapshot):
   ```
   kcadm.sh get realms/banxe-emi --fields accessTokenLifespan,ssoSessionIdleTimeout,ssoSessionMaxLifespan
   ```
   Log to deploy event evidence.

2. Apply target values:
   ```
   kcadm.sh update realms/banxe-emi \
     -s accessTokenLifespan=900 \
     -s ssoSessionIdleTimeout=28800 \
     -s ssoSessionMaxLifespan=86400
   ```
   `accessTokenLifespanForImplicitFlow` and `offlineSessionIdleTimeout` applied separately only after explicit operator decision per EDGE CASES (this runbook intentionally does not auto-bundle to avoid silent default override).

3. Verify new values via read-back:
   ```
   kcadm.sh get realms/banxe-emi --fields accessTokenLifespan,ssoSessionIdleTimeout,ssoSessionMaxLifespan
   ```
   Assertion: read-back equals target. Abort + rollback if mismatch.

4. Smoke test via test client (non-prod credentials):
   - Login → assert issued access token `exp - iat == 900` (±2s clock skew tolerance).
   - Refresh token returned; verify refresh succeeds within idle window.
   - Hold session idle > 8 h (or shorter validation window via KC dev mode) → assert re-auth required.

5. Log deploy event to INSTRUCTION-LEDGER.md (timestamp + operator co-sign + pre/post values).

## HITL gate

Required parties before any kcadm.sh `update` runs:
- Central (this runbook + IL pairing — authoring authority).
- Operator (execution authority on evo1; only operator runs kcadm.sh writes).
- MLRO advisory (auth surface change touches FCA SCA scope per ADR-030 §Decision drivers; advisory, not blocking, on TTL tightening).

No EMERGENCY override permitted. Auth surface mutation without operator co-sign = P0 governance incident (CLAUDE.md §11 production-state mutation gate).

## Rollback (NOT executed in this PR)

1. Restore prior values captured in §Pre-flight step 3:
   ```
   kcadm.sh update realms/banxe-emi \
     -s accessTokenLifespan={{CURRENT_AT_LIFESPAN}} \
     -s ssoSessionIdleTimeout={{CURRENT_SSO_IDLE}} \
     -s ssoSessionMaxLifespan={{CURRENT_SSO_MAX}}
   ```

2. Verify reverted via:
   ```
   kcadm.sh get realms/banxe-emi --fields accessTokenLifespan,ssoSessionIdleTimeout,ssoSessionMaxLifespan
   ```

3. Smoke test rollback (test client login + access token TTL matches prior value).

4. Log rollback event to INSTRUCTION-LEDGER.md (timestamp + operator co-sign + reason).

If rollback also fails: fall back to pg_dump restore per G-IAM-09 prep (banxe-emi-stack PR #134). Escalate to Central + MLRO immediately.

## Audit trail

Deploy + rollback events MUST be logged to ClickHouse Guardian per ADR-027 §Decision drivers — durable evidence chain, 5 y FCA CASS 15 retention. Sink is the standard Guardian audit table (per ADR-027 §Implementation); event payload includes pre-values, post-values, operator handle, MLRO advisory artefact ID, and IL anchor.

If ClickHouse Guardian write fails at deploy time, abort deploy (do NOT proceed silently). Audit gap = compliance incident per ADR-027 §Context.

## Validation script (follow-up)

TODO follow-up artefact: `docs/project/runbooks/keycloak-session-timeout-validate.sh` — automated read-back + smoke test wrapper. Out of scope for this PREP package (Sprint S12.2 PREP is repo-only documentation + template). Owner queued under D3.x follow-up sprint.

## TODO list (open for operator action under HITL gate)

- TODO read current prod values for `accessTokenLifespan`, `ssoSessionIdleTimeout`, `ssoSessionMaxLifespan` and fill placeholders in `banxe-emi-session-config.json`.
- TODO operator confirmation of 24 h `ssoSessionMaxLifespan` defensive ceiling (not in original brief row).
- TODO operator decision on `offlineSessionIdleTimeout` mapping for "refresh TTL 30 min" per EDGE CASES §3.
- TODO landing of `docs/project/runbooks/keycloak-session-timeout-validate.sh` (D3.x follow-up).
- TODO cross-link the Safeguarding + reconciliation project-side runbook once it lands (D3.3.4 / S16).

## Anchors footer

- ADR-017 (decisions/ADR-017-keycloak-iam-cutover.md)
- ADR-027 (decisions/ADR-027-audit-trail-durability.md)
- ADR-030 (decisions/ADR-030-auth-rate-limit-policy.md)
- IL-OPS-ROADMAP-SPRINTS-S12-S25-APPROVED-2026-05-11
- IL-OPS-S12-1-DONE-EVIDENCE-AND-NEW-GAPS-2026-05-12
- Sprint S12.2 (Phase G session timeout hardening)
- banxe-emi-stack PR #134 (G-IAM-09 prep, pg_dump backup pattern reference)
- IL-CANON-DOCUMENTATION-OWNED-BY-CENTRAL-2026-05-12
- IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12
