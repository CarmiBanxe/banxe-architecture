# R4 — Backup and Disaster Recovery (PREP)

Date: 2026-05-22
Status: PREP (design + acceptance criteria; implementation scoped to S19 Phase F6 sandbox verification per SPRINT-EXTENSION-S18-S25)
Source: IL-OPS-V2-DELTA-ANALYSIS-LEGACY-REFACTOR-2026-05-22 (line 8775, R4 PARTIAL item)
Related: ADR-027 (audit-trail TTL 5y); S15 (Security residual baseline); S19 (G-SEC-02 Vault adoption); S25 (customer data migration go-live)

## Purpose

R4 (Backup and DR) ensures every BANXE persistent-state service has a documented backup matrix, defined restore RPO/RTO, monthly restore drill, and DR mirror evidence before any production stateful component goes live. The current state covers ClickHouse audit-trail (5y TTL per ADR-027) and Keycloak Postgres (jdbc:postgresql://127.0.0.1:15433/keycloak) ad-hoc, but lacks unified matrix, drill cadence, and DR mirror plan. R4 closes that gap as design baseline; binding implementation is scoped to S19 sandbox verification window.

## Scope (PREP)

In scope:

- Enumerate every persistent-state service across evo1 + Legion + evo2 with backup classification.
- Define RPO (Recovery Point Objective) and RTO (Recovery Time Objective) per service tier.
- Define monthly restore drill procedure (which service, which week, who verifies).
- Define DR mirror plan (cold standby vs warm vs hot) for production go-live.
- Define backup-secret rotation cadence alignment with S17 secrets rotation policy.

Out of scope (deferred to S19 / S25):

- Actual backup script implementation (S19 G-SEC-02 Vault, S25 data migration).
- Cross-region DR (no second region until post-FCA-go-live decision).
- Backup encryption-at-rest key custody (depends on Vault adoption per S19).

## Backup matrix (services × tier × RPO/RTO)

| Service | Host | State store | Tier | RPO | RTO | Notes |
|---|---|---|---|---|---|---|
| ClickHouse guardian_audit_events | evo1 | local disk + 5y TTL | Tier 1 (audit) | 24h | 4h | ADR-027 binding; loss = FCA SS21/3 violation |
| ClickHouse pretx_gate_events | evo1 | local disk + 5y TTL | Tier 1 (audit) | 24h | 4h | S16.3 binding; loss = compliance evidence gap |
| Keycloak Postgres (banxe-emi realm) | evo1 :15433 | local disk | Tier 1 (identity) | 1h | 1h | ADR-017 binding; loss = identity outage |
| Keycloak Postgres (factory realm) | Legion :8181 | container volume | Tier 2 (dev) | 24h | 8h | non-prod; rebuild from IaC acceptable |
| midaz-ledger Postgres | evo1 (per midaz docker) | container volume | Tier 1 (ledger) | 1h | 2h | ledger immutability; PITR required |
| midaz-mongodb | evo1 (per midaz docker) | container volume | Tier 1 (ledger) | 1h | 2h | currently Exited per R1 context |
| RabbitMQ midaz queues | evo1 | container volume | Tier 2 (transient) | none | 2h | queues rebuild on restart |
| Redis (pretx gate) | evo1 (planned) | container volume | Tier 2 (cache) | none | 1h | cache only; rebuild from CH on restart |
| Vault (G-SEC-02) | evo1 (planned, S19) | local disk | Tier 0 (root) | 1h | 1h | catastrophic if lost; HSM-backed seal recommended |
| ruflo_checkpoints | evo1 ClickHouse | local disk + 5y TTL | Tier 1 (audit) | 24h | 4h | factory checkpoint table per IL-OPS-SPRINT-0 |
| Guardian source / config | evo1 /data/banxe/guardian/ | local disk + git | Tier 2 (code) | 1h | 2h | now under git (initial commit 3565ee6 on evo1) |
| INSTRUCTION-LEDGER.md + ADR/docs | banxe-architecture repo | GitHub | Tier 0 (canon) | minutes | minutes | GitHub mirror = primary backup |

## Restore drill cadence

- **First week of each month** — Tier 1 audit (ClickHouse guardian_audit_events) restore drill into isolated namespace; verify last 7 days of events match production.
- **Second week** — Tier 1 identity (Keycloak Postgres) restore drill; verify realm export round-trips.
- **Third week** — Tier 1 ledger (midaz Postgres + mongodb) restore drill; verify last day of transactions match.
- **Fourth week** — Tier 0 root (Vault, once S19 lands) restore drill; verify seal unwrap.
- **Drill log** — append to docs/audit/R4-RESTORE-DRILLS-YYYY.md with date, who verified, RPO/RTO observed, deltas vs target, remediation actions.

## DR mirror plan (for go-live S25)

- **Phase 1 (S19 to S23)** — local backups only; no DR mirror. Acceptable for sandbox.
- **Phase 2 (S24 RegData submission)** — warm standby on second host (proposed evo2 if GPU SPOF resolved per R8) or cloud-cold object storage for Tier 1.
- **Phase 3 (S25 go-live)** — DR mirror required for Tier 0 + Tier 1 with documented failover runbook; failover RTO ≤ 4h for Tier 1, ≤ 1h for Tier 0.
- **Out of scope until post-go-live** — multi-region active-active.

## Secret rotation alignment

- Backup encryption keys rotate per S17 (90 days).
- Vault root token (S19 G-SEC-02) — emergency rotation procedure must be documented before S19 closure; PREP defers exact procedure to that sprint.
- Restore-test credentials (read-only) — separate principal from backup-write credentials; both rotated per S17.

## Acceptance criteria (DONE definition for R4 implementation in S19)

- Backup matrix above is verified live: every Tier 0/1 service has working backup with documented retention.
- Monthly drill schedule is in production: at least one drill per tier per month, drill log appended.
- Tier 0 services (canon repo, Vault) have evidence of at least one successful restore-from-backup before any Tier 1 production data exists.
- RPO/RTO targets are met in drill (deltas ≤ 10% of target).
- DR mirror Phase 1 evidence: documented local-backup retention works across host reboot.
- Secret rotation evidence: at least one backup encryption key rotated per S17 procedure.

## Open questions (route to operator / Architecture WG during S19)

- evo2 SPOF resolution status (currently sole GPU inference host per R8): is evo2 viable as warm standby for Tier 1 or is it dedicated to AI plane only?
- Vault adoption timing (S19 G-SEC-02): if Vault delays past S19, what is the fallback for backup encryption key storage?
- Cloud cold storage: is operator approved to introduce a third-party (e.g. S3-compatible) for Tier 1 cold backup, or must everything stay on-premise?
- Drill verifier rotation: who verifies the drill log? MLRO? Architecture WG? Operator?

=== END OF R4 BACKUP-DR PREP (snapshot 09b7491) ===
