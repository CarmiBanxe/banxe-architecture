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
- `offlineSessionMaxLifespan`: 5184000 ✓ (60 days, no change needed)
- `refreshTokenMaxReuse`: 0 ✓ (no change needed)

Fields requiring change:
- `offlineSessionMaxLifespanEnabled`: false → **true**
- `revokeRefreshToken`: false → **true**

---

## Apply Commands (Admin REST API — kcadm.sh OOM on Legion, using curl+JWT)

All commands authenticated via `POST /realms/master/protocol/openid-connect/token`
(`admin-cli` client, credentials from `/home/mmber/.banxe/keycloak.env`).
All responses: HTTP 204 No Content.

```
[2026-05-05T23:38:20Z] PUT /admin/realms/banxe-emi
  {"offlineSessionMaxLifespanEnabled": true}
  → HTTP 204

[2026-05-05T23:38:20Z] PUT /admin/realms/banxe-emi
  {"offlineSessionMaxLifespan": 5184000}
  → HTTP 204

[2026-05-05T23:38:20Z] PUT /admin/realms/banxe-emi
  {"refreshTokenMaxReuse": 0}
  → HTTP 204

[2026-05-05T23:38:20Z] PUT /admin/realms/banxe-emi
  {"revokeRefreshToken": true}
  → HTTP 204
```

**Note:** `kcadm.sh` was killed (OOM, exit 137) on Legion. Used Admin REST API directly with
Bearer token obtained from `admin-cli` client. Behaviour is identical; Admin REST API is the
canonical interface (kcadm.sh is a thin wrapper). Credentials sourced from
`/home/mmber/.banxe/keycloak.env` (not committed, operator-controlled).

---

## Post-state (captured 2026-05-05T23:38:21Z after apply)

```json
{
  "offlineSessionMaxLifespanEnabled": true,
  "offlineSessionMaxLifespan": 5184000,
  "refreshTokenMaxReuse": 0,
  "revokeRefreshToken": true
}
```

### Diff verification

| Field | Pre | Post | Target | Status |
|-------|-----|------|--------|--------|
| `offlineSessionMaxLifespanEnabled` | false | **true** | true | ✅ |
| `offlineSessionMaxLifespan` | 5184000 | 5184000 | 5184000 | ✅ |
| `refreshTokenMaxReuse` | 0 | 0 | 0 | ✅ |
| `revokeRefreshToken` | false | **true** | true | ✅ |

---

## Smoke Test (2026-05-05T23:38:22Z)

```bash
curl -X POST http://100.101.218.26:8180/realms/banxe-emi/protocol/openid-connect/token \
  -d "grant_type=client_credentials" \
  -d "client_id=banxe-compliance-api" \
  -d "client_secret=***MASKED***"
```

Result:
```
expires_in=900
refresh_expires_in=0
token_type=Bearer
```

`refresh_expires_in=0` is correct: `client_credentials` grant does not issue refresh tokens
per OAuth 2.0 spec (RFC 6749 §4.4). `revokeRefreshToken=true` applies to `authorization_code`
and `password` grant refresh token rotation — it does not affect `client_credentials` flows.

**Smoke: PASS ✅**

---

## Backout Instructions

Refer to `infra/keycloak-banxe-emi/RUNBOOK.md §Phase G Backout`.

If reverting, restore pre-state via Admin REST API:

```bash
# Get admin token (credentials from /home/mmber/.banxe/keycloak.env)
TOKEN=$(curl -fsS -X POST http://100.101.218.26:8180/realms/master/protocol/openid-connect/token \
  --data-urlencode "client_id=admin-cli" \
  --data-urlencode "username=${KC_BOOT_ADMIN}" \
  --data-urlencode "password=${KC_BOOT_ADMIN_PASSWORD}" \
  --data-urlencode "grant_type=password" | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")

# Restore pre-state
curl -X PUT http://100.101.218.26:8180/admin/realms/banxe-emi \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"offlineSessionMaxLifespanEnabled": false, "revokeRefreshToken": false}'
```

Note: `offlineSessionMaxLifespan` (5184000) and `refreshTokenMaxReuse` (0) were already at
target before apply — no need to restore these values during backout.

---

## References

- ADR-017 §5: session TTL policy (90-day offline session commitment)
- ADR-030: KC realm hardening — all Phase G settings defined here
- RUNBOOK.md: `infra/keycloak-banxe-emi/RUNBOOK.md §Phase G`
- PR #59: canon already in main (Phase G settings documented prior to apply)
- GAP-REGISTER V-02: closed by this execution (see IL-PHASE-G-01)
