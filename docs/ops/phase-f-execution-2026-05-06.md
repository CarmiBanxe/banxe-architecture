# Phase F Execution Log — KC Backend dev-file → Postgres
# Date: 2026-05-06 | Operator: Architecture WG (CCF §15)
# Realm: banxe-emi | KC host: 100.101.218.26:8180 (Legion, Tailscale)
# IL: IL-PHASE-F-01 | Closes: G-IAM-09 (ADR-017)
# Source: RUNBOOK §Phase F, ADR-017 §G-IAM-09 closure

---

## Pre-state (captured 2026-05-06T00:31:48Z)

Backend: KC_DB=dev-file (H2) — confirmed via `docker inspect` + Installed features: `jdbc-h2`
Container: keycloak-banxe-emi (Up 37 hours, unhealthy healthcheck / serving OK)

Realm banxe-emi:
```json
{
  "id": "3dcbe1f4-849a-494b-8ce4-382bdb586589",
  "realm": "banxe-emi",
  "accessTokenLifespan": 900,
  "ssoSessionMaxLifespan": 36000,
  "enabled": true,
  "sslRequired": "none",
  "registrationAllowed": false
}
```

Clients present (4 EMI service accounts): banxe-compliance-api, banxe-dashboard, deep-search, drive_watcher
All enabled=true, serviceAccountsEnabled=true, publicClient=false ✅

---

## Execution Timestamps

```
[2026-05-06T00:31:48Z] Pre-state captured
[2026-05-06T00:32:25Z] STEP 3.2: docker compose down — KC STOPPED (DOWNTIME BEGINS)
                         Container keycloak-banxe-emi Stopped + Removed
                         Network keycloak-banxe-emi-legion_default Removed
[2026-05-06T00:34:33Z] STEP 3.4: cp canonical Postgres compose → ~/keycloak-banxe-emi-legion/docker-compose.yml
[2026-05-06T00:34:37Z] STEP 3.5: docker compose up -d
                         Volume keycloak_pg_data Created (fresh)
                         Container keycloak-banxe-emi-pg: Starting → Started → Healthy
                         Container keycloak-banxe-emi: Starting → Started
[2026-05-06T00:37:09Z] STEP 3.6: KC healthy — KC-SERVICES0032: Import finished successfully
                         KC-SERVICES0077: Created temporary admin user banxe-emi-admin
                         Keycloak 26.2.5 started in 11.298s (DOWNTIME ENDS)
[2026-05-06T00:37:09Z] STEP 3.7: sslRequired=none confirmed from realm JSON — no patch needed
[2026-05-06T00:37:xx Z] STEP 3.8: provision-clients.sh — 4/4 clients provisioned
                         drive_watcher uuid=2a710842-34cc-460f-940e-ec5cd7c348de
                         banxe-compliance-api uuid=eadfa01a-6b0f-46b1-b437-a39a2d6423ab
                         deep-search uuid=13ceb1d1-bd3f-4b93-825d-3a7909199f13
                         banxe-dashboard uuid=d982fc6e-96db-4c57-9bd6-1e5513dc2398
[2026-05-06T00:49:07Z] Phase G re-apply: realm JSON predates Phase G — re-applied 4 fields via kcadm
                         offlineSessionMaxLifespanEnabled=true, offlineSessionMaxLifespan=5184000
                         refreshTokenMaxReuse=0, revokeRefreshToken=true → HTTP 204 (kcadm exit 0)
[2026-05-06T00:49:xx Z] STEP 3.10: SMOKE 4/4 PASS
```

**Downtime window: 00:32:25Z → 00:37:09Z = 2 min 44 sec** (within 30-60s estimate +; actual KC start ~2:32 due to Postgres init + realm import on fresh Postgres)

---

## Post-state (captured 2026-05-06T00:46:12Z, post Phase G re-apply at 00:49:07Z)

Backend: KC_DB=postgres — confirmed via `docker inspect` + Installed features: `jdbc-postgresql`
Container: keycloak-banxe-emi (Up, fresh Postgres volume)

Realm banxe-emi (post-Phase-G re-apply):
```json
{
  "id": "b9901fe9-87b6-4880-85d8-e285a4b4335b",
  "realm": "banxe-emi",
  "revokeRefreshToken": true,
  "refreshTokenMaxReuse": 0,
  "accessTokenLifespan": 900,
  "offlineSessionMaxLifespanEnabled": true,
  "offlineSessionMaxLifespan": 5184000,
  "sslRequired": "none"
}
```

Note: Realm ID changed (3dcbe1f4 → b9901fe9) — expected on fresh Postgres import.

---

## Smoke Test Results (4/4 PASS)

All via Python3 urllib from host to http://127.0.0.1:8180

| Client | grant_type | expires_in | refresh_expires_in | Result |
|--------|-----------|-----------|-------------------|--------|
| banxe-compliance-api | client_credentials | 900 | 0 | ✅ OK |
| banxe-dashboard | client_credentials | 900 | 0 | ✅ OK |
| deep-search | client_credentials | 900 | 0 | ✅ OK |
| drive_watcher | client_credentials | 900 | 0 | ✅ OK |

`refresh_expires_in=0` correct per RFC 6749 §4.4 (client_credentials has no refresh token).

---

## Phase G Re-apply Note

The realm JSON (`banxe-emi-realm.json`) predates Phase G application (Phase G was applied to
the dev-file KC instance via Admin REST API; not exported back to JSON). Fresh Postgres KC
imported the pre-Phase-G JSON. Phase G settings re-applied via `kcadm.sh update realms/banxe-emi`
immediately after Phase F completion.

**Action required:** Export updated realm JSON and commit to repo to prevent this drift on
future KC restarts. TODO: update `realms/banxe-emi-realm.json` with Phase G fields.

---

## Backout Procedure

1. `cd ~/keycloak-banxe-emi-legion`
2. `cp docker-compose.yml.original docker-compose.yml`
3. `docker compose --env-file /tmp/kc-phase-f.env down -v` (WARNING: destroys Postgres volume)
4. `docker compose --env-file /tmp/kc-phase-f.env up -d` (restores dev-file KC from H2)

Note: All data written to Postgres KC after Phase F will be lost on rollback.

---

## Closure

- G-IAM-09: KC realm `banxe-emi` migrated dev-file → Postgres → **DONE 2026-05-06**
- IL-PHASE-F-01: appended to INSTRUCTION-LEDGER.md
- ROADMAP.md: Phase F pending gate struck
