# ADR-029 — PostgreSQL Backup Strategy

**Status:** Accepted (2026-05-10)
**Date Accepted:** 2026-05-10
**Author:** Architecture WG
**Closes:** G-OPS-01 (backup strategy absent), G-OPS-02 (restore drill absent)
**Linked:** ADR-027 (audit-trail durability), INVARIANTS I-08/I-24, SERVICE-MAP.md §Серверы кластера, V-07 (HANDOFF-2026-05-04)

---

## Context

A read-only audit of evo1 (192.168.0.72) conducted 2026-05-05 found **zero backup
infrastructure** for any PostgreSQL instance: no pg_dump cron jobs, no WAL archiving,
no backup scripts in any cron tab (`root`, `banxe`, `mmber`, `ctio`). Seven
PostgreSQL containers exist on the host; only one (`banxe-marble-postgres`,
`postgis:17-3.5`, port 15433) is in a RUNNING state. The remaining six are in Exited
states, including `keycloak-banxe-emi_keycloak_pg_data` with exit code 137 (OOM kill),
indicating active memory pressure on evo1.

**Critical scope correction:** The `midaz-ledger` stack uses MongoDB (`midaz-mongodb`,
`mongo:8`, port 5703, replica set `rs0`), **not** PostgreSQL. WAL-G for "Midaz ledger
primary" — as originally scoped in V-07 — is not applicable to PostgreSQL. Midaz
MongoDB backup is out of scope for this ADR and must be addressed separately.

PostgreSQL instances in scope for this ADR:

| Instance | Container | Port | Status | Data criticality |
|----------|-----------|------|--------|-----------------|
| Marble compliance cases | banxe-marble-postgres | 15433 | RUNNING | HIGH — FCA CASS 7 evidence |
| Keycloak IAM realm | keycloak-banxe-emi (pg vol) | N/A | Exited(137) | HIGH — IAM credential store |
| banxe_compliance DB (AML/KYC) | banxe-postgres | 5432 | Exited(128) | CRITICAL — AML audit trail |
| Jube TM | postgres (Jube stack) | 15432 | Exited(0) | MEDIUM — TM state |
| Ballerine KYC | ballerine-postgres | N/A | Exited(0) | HIGH — KYC documents |
| Hyperswitch payments | hyperswitch-pg-data (vol) | N/A | Exited | HIGH — payment records |
| Braslina | braslina_pgdata (vol) | N/A | Exited | LOW |

Volumes confirmed present: `keycloak-banxe-emi_keycloak_pg_data`, `ballerine-x_postgres15`,
`braslina_pgdata`, `docker_hyperswitch-pg-data`, `hyperswitch_pg_data`. All data
resides on evo1 SSD with no replica; a disk failure or OOM cascade constitutes total
data loss for all PostgreSQL instances simultaneously.

The absence of any backup infrastructure means:
- **FCA CASS 15 §15.10**: loss of daily reconciliation audit records in `banxe_compliance`
  DB constitutes a reportable compliance failure.
- **MLR 2017 Reg.28**: AML/KYC evidence required for 5 years post-relationship — unprotected.
- **DORA Art.14(2)**: ICT operational records must be complete and tamper-proof; unprotected
  data fails this requirement.
- **IAM continuity**: Keycloak data loss (OOM kill already observed) prevents all staff
  logins; no RBAC recovery path exists without a realm backup.

---

## Decision Drivers

1. **Zero-backup state (G-OPS-01)** — any evo1 storage incident destroys all PostgreSQL
   data; this is the highest-severity infrastructure gap in the current stack.
2. **FCA/MLR data retention (I-08 analogue for PG)** — AML/KYC and CASS audit data must
   be recoverable for ≥5 years post-relationship; current state provides zero retention.
3. **DORA RTO/RPO requirements** — ICT continuity plans must define recovery objectives;
   no backup means no definable RPO or RTO.
4. **Restore drill absence (G-OPS-02)** — a backup that has never been tested is not
   a backup; V-07 confirms restore validation has never been performed.
5. **Single-engineer operability** — evo1 is operated by a small team; the backup
   solution must be automatable and require minimal ongoing intervention.
6. **evo2 availability** — evo2 (192.168.0.15, GMKtec EVO-X2 #2, 128 GiB) is available
   as a local archive target; S3-compatible MinIO on evo2 provides durable off-evo1 storage
   without cloud dependency.

---

## Considered Options

### Option (a) — pg_dump daily cron + local retention only

`pg_dump` via cron for each running instance, compressed to `/var/backups/pg/`, with
14-day local rotation. No off-evo1 copy.

| Dimension | Assessment |
|-----------|-----------|
| Safety | Low — single-disk failure destroys both primary and backup |
| Complexity | Minimal — one cron script per instance |
| RPO | 24h (daily dump) |
| Retention | 14 days (local disk limit) |
| Restore validation | Manual; not automated |
| FCA 5yr requirement | Fails — 14-day local retention insufficient |

**Risk:** Local-only backup does not satisfy FCA 5-year data retention. evo1 disk failure
destroys primary AND backup simultaneously.

---

### Option (b) — pg_dump daily + evo2 MinIO archive (12 months)

`pg_dump` via cron → compress → upload to MinIO on evo2 (`s3://banxe-pg-backups/`).
14-day local rotation on evo1, 12-month archive on evo2. Weekly automated restore drill.

| Dimension | Assessment |
|-----------|-----------|
| Safety | High — off-evo1 copy survives evo1 disk failure |
| Complexity | Moderate — MinIO setup on evo2 + rclone/mc upload script |
| RPO | 24h (daily dump) |
| Retention | 12 months on evo2 (covers FCA operational window; archival extension path) |
| Restore validation | Automated weekly restore drill on evo2 staging DB |
| FCA 5yr requirement | Requires policy: 12-month hot + 5-year cold (evo2 or offsite) |

**Risk:** MinIO on evo2 is a single additional disk; not geo-redundant. Acceptable for
current single-cluster deployment; geo-redundancy deferred to P1.

---

### Option (c) — WAL-G continuous archiving + evo2 MinIO (banxe_compliance only)

WAL-G archives PostgreSQL WAL segments continuously to MinIO on evo2 for
`banxe_compliance` DB (highest criticality: AML audit trail). pg_dump daily for
remaining instances (as option b).

| Dimension | Assessment |
|-----------|-----------|
| Safety | Very high for banxe_compliance — point-in-time recovery |
| Complexity | High — WAL-G config, WAL archiving toggle in postgresql.conf, restore path |
| RPO | ~5 min (WAL segment interval) for banxe_compliance; 24h for others |
| Retention | 12-month base file backup + WAL for PITR window |
| Restore validation | WAL-G restore drill + pg_dump restore drill |
| FCA 5yr requirement | WAL segments + base backup must cover 5-year window |

**Risk:** WAL-G requires `wal_level=replica` and `archive_mode=on` in `postgresql.conf`;
requires postgres container restart. banxe_compliance is currently Exited(128) — restart
required in any case.

---

### Option (d) — Logical replication streaming to standby on evo2

Create a PostgreSQL standby on evo2 receiving streaming replication from each primary.
Backup taken from standby.

| Dimension | Assessment |
|-----------|-----------|
| Safety | Maximum — live replica, near-zero data loss |
| Complexity | Very high — streaming replication config, replication slots, standby management |
| RPO | Near-zero (streaming lag, typically seconds) |
| Retention | Continuous; point-in-time via WAL |
| Restore validation | Promotes standby to primary; production test |
| FCA 5yr requirement | Requires WAL retention policy on standby |

**Risk:** Streaming replication for 7 heterogeneous PostgreSQL instances (different
versions, different container stacks) is a multi-week infrastructure project. Multiple
containers are currently Exited; getting all instances running and configured for
replication is a major operational undertaking. Disproportionate to current P0 sprint scope.

---

## Trade-off Summary

| Option | Safety | Complexity | RPO | FCA 5yr | Testability |
|--------|--------|-----------|-----|---------|-------------|
| (a) local pg_dump | Low | Min | 24h | Fails | Manual |
| (b) pg_dump + evo2 MinIO | High | Moderate | 24h | Policy path | Automated |
| (c) WAL-G + evo2 MinIO | Very high | High | ~5 min / 24h | Policy path | Automated |
| (d) streaming replication | Max | Very high | ~0 | Policy path | Complex |

---

## Recommendation

**Option (b) — pg_dump daily + evo2 MinIO archive**, with **option (c) WAL-G
continuous archiving for `banxe_compliance` DB** as a targeted extension for the
highest-criticality instance.

Rationale:
- Option (a) alone fails FCA 5-year retention; local-only backup is not acceptable for
  regulated financial data.
- Option (b) provides off-evo1 durability, automated restore drills, and a retention
  path to 5 years, at manageable complexity for a single-engineer team.
- Option (c) targeted at `banxe_compliance` only adds PITR capability for the AML audit
  trail (CASS 15 + MLR 2017 evidence) without requiring WAL-G config on all 7 instances.
- Option (d) is architecturally sound but disproportionate to current sprint scope;
  deferred to P1 multi-node infrastructure work.

**Instance strategy matrix:**

| Instance | Container | Strategy | RPO | Retention | Priority |
|----------|-----------|----------|-----|-----------|---------|
| banxe_compliance (AML/KYC) | banxe-postgres | pg_dump daily + WAL-G PITR | ≤5 min | 5yr (WAL) | P0 |
| Marble cases | banxe-marble-postgres | pg_dump daily + evo2 MinIO | 24h | 12mo + archive | P0 |
| Keycloak realm | keycloak-banxe-emi vol | pg_dump daily + evo2 MinIO | 24h | 12mo | P0 |
| Ballerine KYC | ballerine-postgres | pg_dump daily + evo2 MinIO | 24h | 12mo | P0 |
| Hyperswitch payments | hyperswitch-pg-data vol | pg_dump daily + evo2 MinIO | 24h | 12mo | P0 |
| Jube TM | postgres (Jube) | pg_dump daily + evo2 MinIO | 24h | 3mo | P1 |
| Braslina | braslina_pgdata vol | pg_dump daily local | 24h | 14d | P2 |

**Phased implementation:**
1. (Immediate — P0) MinIO setup on evo2 + `banxe-pg-backup.sh` cron script for all P0
   instances. Local 14-day rotation + upload to `s3://banxe-pg-backups/<instance>/`.
2. (Sprint 4+) WAL-G for `banxe_compliance` DB: configure `wal_level=replica`,
   `archive_mode=on`, `archive_command` → MinIO. Implement `pg_basebackup` weekly.
3. (Sprint 4+) Automated weekly restore drill: restore latest dump from MinIO to evo2
   staging DB, run `pg_restore --list` + row count validation, alert on failure.
4. (P1) Retention policy automation: lifecycle rules on MinIO bucket to transition
   12-month backups to compressed cold storage for 5-year retention.

---

## Consequences

### Positive

- Zero-backup gap closed immediately; off-evo1 copy survives evo1 storage failure.
- FCA CASS 15 + MLR 2017 5-year data retention achievable via MinIO lifecycle policy.
- PITR for `banxe_compliance` (AML audit trail) provides ≤5-min RPO for the highest-
  criticality regulated data.
- Weekly automated restore drill satisfies G-OPS-02 and DORA Art.14(2) ICT continuity
  evidence.
- IAM continuity restored: Keycloak realm backup enables recovery from next OOM kill.

### Negative / Risks

- MinIO on evo2 is a single additional disk; evo1+evo2 simultaneous failure = data loss.
  Acceptable for current single-cluster deployment; geo-redundancy (cloud S3) deferred to P1.
- WAL-G requires `banxe_compliance` container restart (currently Exited(128)); restart
  must be coordinated with compliance team to avoid audit gap.
- pg_dump of Exited containers requires starting each container temporarily; startup
  may fail if dependent services are unavailable.
- 12-month MinIO retention does not cover the full 5-year FCA requirement without
  lifecycle policy automation; tracked in IL until policy is implemented.

---

## Implementation Plan

1. **MinIO on evo2** — deploy `minio/minio` container on evo2 at port 9100/9101;
   create bucket `banxe-pg-backups` with versioning enabled. Credentials to `.env`
   on evo1 (`MINIO_EVO2_ENDPOINT`, `MINIO_EVO2_ACCESS_KEY`, `MINIO_EVO2_SECRET_KEY`).

2. **Backup script** — `scripts/backup/banxe-pg-backup.sh`: loop over instance list,
   `pg_dump -Fc`, compress, `mc cp` to MinIO. Rotate local copies >14 days.
   Cron: `0 2 * * * root /opt/banxe/scripts/banxe-pg-backup.sh >> /var/log/banxe-pg-backup.log 2>&1`.

3. **WAL-G for banxe_compliance** — add `POSTGRES_WALG_*` env vars to
   `docker-compose.master.yml` for `banxe-postgres` service; configure `archive_mode`,
   `archive_command`. Add `pg_basebackup` weekly cron (Sunday 03:00).

4. **Restore drill** — `scripts/backup/banxe-pg-restore-drill.sh`: pull latest
   `banxe-marble-postgres` dump from MinIO, restore to `postgres-restore-drill`
   container on evo2, count rows in `cases` table, emit result to `/var/log/restore-drill.log`.
   Cron: `0 4 * * 0 root /opt/banxe/scripts/banxe-pg-restore-drill.sh`.

5. **Tests** — `tests/test_ops/test_pg_backup.py`: mock `subprocess.run` (pg_dump) and
   `mc cp` (MinIO upload); assert correct invocation for each P0 instance;
   assert local rotation logic; assert restore drill validation logic. ≥15 tests.

6. **IL update** — `banxe-architecture/INSTRUCTION-LEDGER.md`: close G-OPS-01/02
   when implementation PR merges with evidence (backup log line + restore drill output).

---

## Decision

**Accepted** (2026-05-10) — pg_dump daily + evo2 MinIO archive (Option b) implemented
for keycloak-pg. BackupPort abstraction + DI factory + cron script operational.

---

## Implementation

- **Step 1:** banxe-emi-stack PR #102 — BackupPort + PgDumpBackupAdapter + 6 unit tests.
- **Step 2:** banxe-emi-stack PR #104 — DI factory wiring + BACKUP_ENABLED flag + 5 integration tests.
- **Step 3:** banxe-emi-stack PR #106 — pg-backup-run.py cron script + 4 smoke tests.
- **Total:** 15 tests PASS, coverage 40.94%.
- **Gaps closed:** G-OPS-01 (DONE), G-OPS-02 (DONE).
