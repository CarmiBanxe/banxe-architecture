# Phase G Execution Log — Session-Timeout Hardening
# Date: 2026-05-06 | Operator: Architecture WG (CCF §15)
# Realm: banxe-emi | KC host: 100.101.218.26:8180 (Legion, Tailscale)
# IL: IL-PHASE-G-01 | Closes: V-02 (HANDOFF-2026-05-04)
# Source: ADR-017 §5, ADR-030, RUNBOOK §Phase G

---

## Pre-state (captured 2026-05-06T01:38:19Z before apply)

```json
{
  "offlineSessionMaxLifespanEnabled": false,
  "offlineSessionMaxLifespan": 5184000,
  "refreshTokenMaxReuse": 0,
  "revokeRefreshToken": false
}
```

Fields already at target before apply:
- `offlineSessionMaxLifespan`: 5184000 ✓
- `refreshTokenMaxReuse`: 0 ✓

Fields requiring change:
- `offlineSessionMaxLifespanEnabled`: false → true
- `revokeRefreshToken`: false → true

---

## Apply Commands (Admin REST API — kcadm.sh OOM on Legion, using curl+JWT)

kcadm.sh was OOM-killed (exit 137) on Legion. Equivalent Admin REST API calls used
via curl+JWT — identical behaviour, canonical KC interface, same authorisation scope.

```
[2026-05-05T23:38:20Z] PUT /admin/realms/banxe-emi {"offlineSessionMaxLifespanEnabled": true} → HTTP 204
[2026-05-05T23:38:20Z] PUT /admin/realms/banxe-emi {"offlineSessionMaxLifespan": 5184000}     → HTTP 204
[2026-05-05T23:38:20Z] PUT /admin/realms/banxe-emi {"refreshTokenMaxReuse": 0}                → HTTP 204
[2026-05-05T23:38:20Z] PUT /admin/realms/banxe-emi {"revokeRefreshToken": true}               → HTTP 204
```

All 4 calls returned HTTP 204 No Content (KC Admin REST API success response for realm PATCH).

---

## Post-state (verified after apply)

```json
{
  "offlineSessionMaxLifespanEnabled": true,
  "offlineSessionMaxLifespan": 5184000,
  "refreshTokenMaxReuse": 0,
  "revokeRefreshToken": true
}
```

All 4 fields at ADR-030 target values. ✅

---

## Smoke Test

```
POST /realms/banxe-emi/protocol/openid-connect/token
grant_type=client_credentials

Response:
  expires_in=900          ✅  (15-min access token, per ADR-017 §5 target)
  refresh_expires_in=0    ✅  (correct per RFC 6749 §4.4 — client_credentials has no refresh token)
```

Smoke PASS.

---

## Backout Procedure

If rollback required, restore pre-state:

```bash
curl -s -X PUT "$KC_BASE/admin/realms/banxe-emi" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"offlineSessionMaxLifespanEnabled": false, "revokeRefreshToken": false}'
```

Fields `offlineSessionMaxLifespan` and `refreshTokenMaxReuse` were already at target — no change required on rollback.

---

## Closure

- V-02 (HANDOFF-2026-05-04): KC realm session-timeout hardening → **DONE 2026-05-06**
- GAP-REGISTER: G-IAM-10 added and marked DONE
- ROADMAP: Phase 4.7 V-02 row updated, Phase G pending gate struck
- IL: IL-PHASE-G-01 appended
