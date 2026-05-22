# R2 — IAM Stabilization (PREP)

Date: 2026-05-22
Status: PREP (design + acceptance criteria; binding implementation scoped to S12 per SPRINT-EXTENSION-LEGACY-REFACTOR-S12-S17.md)
Source: IL-OPS-V2-DELTA-ANALYSIS-LEGACY-REFACTOR-2026-05-22 (line 8775, R2 PARTIAL item); audit 2026-05-20 (KC unhealthy state observed)
Related: ADR-017 (containerised Keycloak — canonical design); S12.1 DONE (KC backend Postgres); S12.2/S12.3/S12.5/S12.6 PREP; ROADMAP_8Q Q1 exit gates

## Purpose

R2 (IAM Stabilization) closes the gap between the canonical containerised Keycloak design (per ADR-017) and the observed operational state, where KC instances were reported unhealthy in the 2026-05-20 audit despite a healthy Postgres backend (S12.1 DONE). R2 establishes (a) the unhealthy-to-healthy transition runbook, (b) JGroups singleton fallback documentation, (c) session timeout hardening, and (d) DB readiness validation contract. Binding implementation is scoped to S12 within the existing roadmap; this PREP captures the design baseline only.

## Scope (PREP)

In scope:

- Inventory of all Keycloak instances across evo1 + Legion with realm coverage.
- Define KC unhealthy-to-healthy transition runbook (root-cause flow + recovery steps).
- Document JGroups singleton fallback behaviour as accepted design per ADR-017 (containerised KC is single-replica by design).
- Define session-timeout hardening baseline (S12.2 PREP carries the runbook).
- Define DB readiness validation contract (Postgres reachability + schema version + replica lag tolerance).
- Identify R2 acceptance gates that align with ROADMAP_8Q Q1 exit.

Out of scope (deferred):

- Multi-region KC HA topology — not in S12-S25; revisit post-FCA go-live.
- KC-to-Vault credential migration — owned by R4 (Backup and DR) + S19 G-SEC-02 Vault adoption.
- KC-to-Hyperswitch identity federation — owned by separate payment-routing track.
- Keycloak version upgrade beyond current line — out of scope until Q3 stability is observed.

## IAM instance matrix (instance × realm × tier × status)

| Instance | Host | Port | Backend | Realm(s) | Tier | Health source |
|---|---|---|---|---|---|---|
| KC banxe-emi (production) | evo1 | (per audit) | Postgres :15433 (S12.1 DONE) | banxe-emi | Tier 1 (production identity) | KC /health endpoint + jdbc reachability |
| KC factory (developer) | Legion | container | container Postgres | factory | Tier 2 (developer identity) | container healthcheck + KC /health |

Notes:
- Both instances are single-replica by design per ADR-017 (containerised KC); see JGroups section below.
- Tier 1 outage on KC banxe-emi blocks any new user authentication and any session refresh; runbook below.
- Tier 2 outage on KC factory blocks factory CI workflows that require IAM but not production traffic.

## KC unhealthy-to-healthy transition runbook

Pre-conditions:
- Postgres backend reachable (S12.1 baseline). If not, escalate to R4 (Backup and DR) before continuing.
- KC container running but /health returns 503 or refuses connection.

Steps (in order, do not skip):

1. Capture state — docker logs, KC /health response, Postgres reachability check from KC container, last 200 lines of KC stdout.
2. Verify schema version — KC requires its DB schema to match the running KC version; mismatch is the most common cause of post-restart unhealthy.
3. Verify JGroups state — even on single-replica deploys, KC initialises JGroups; check for singleton-mode warnings (expected) vs partition-mode errors (not expected).
4. Verify session cache — Infinispan cache layer; if stale lock observed, restart in maintenance window with cache eviction.
5. Re-issue /health and confirm 200 + ready=true; record latency.
6. Tail KC stdout for 5 minutes; absence of WARN/ERROR after recovery = stable.
7. Document the incident in INSTRUCTION-LEDGER.md with the symptom, root cause, and resolution.

## JGroups singleton fallback (accepted design per ADR-017)

KC containerised single-replica deploys initialise JGroups in singleton-mode. This is canonical and not an error condition:
- The cluster has size 1; no peer discovery is expected.
- Infinispan caches operate in local-only mode.
- Session replication is unnecessary because there is no peer.
- Logs may contain "no other members" or "singleton view" messages — these are informational, not failure indicators.

This is the accepted design. Multi-replica KC HA is out of scope until post-FCA go-live decision; if a future sprint introduces HA, this section will be superseded.

## Session-timeout hardening (S12.2 PREP)

Baseline values (target per S12.2 runbook):
- SSO Session Idle: 30 minutes (operator sessions); 15 minutes (customer-facing where applicable).
- SSO Session Max: 10 hours.
- Offline Session Idle: 30 days (refresh-token rotation tracked separately).
- Access Token Lifespan: 5 minutes (short-lived JWT).
- Client Session Idle: matches SSO Session Idle by default.
- Refresh-token rotation: enabled where supported by the client; documented per ADR.

S12.2 PREP runbook captures the per-realm apply procedure with rollback steps. R2 PREP only sets the baseline values; the apply procedure is owned by S12.2.

## DB readiness validation contract

Every KC startup must validate before accepting traffic:
- Postgres TCP reachability on configured host:port; abort startup on connection refusal.
- Schema version matches expected for the running KC version; abort startup on mismatch.
- Replica lag tolerance (if a replica is configured): max 5 seconds; warn but do not abort if exceeded.
- KC /health/ready must transition to 200 within 60 seconds of startup; else container exits with non-zero to trigger restart policy.

This contract is the entry condition for Q1 exit gate "KC unhealthy-to-healthy runbook merged".

## Four objectives (binding for S12 implementation)

### Objective (a) — KC unhealthy-to-healthy transition runbook

- Root-cause flow: KC healthcheck failing → distinguish (i) Postgres backend unreachable, (ii) JGroups discovery timeout, (iii) realm export/import corruption, (iv) JVM out-of-memory.
- Recovery steps per cause: (i) verify Postgres :15433 reachable, restart KC; (ii) confirm single-replica (per ADR-017), no JGroups required, restart KC; (iii) restore realm from last good export under /etc/keycloak/realms/; (iv) bump JVM heap and restart.
- Runbook lives at docs/runbooks/S12-2-KC-SESSION-TIMEOUTS.md (S12.2 PREP DONE) and is extended for full unhealthy diagnostic flow during S12 implementation.

### Objective (b) — JGroups singleton fallback documentation

- ADR-017 binds containerised Keycloak as single-replica. JGroups clustering is NOT used in current topology.
- Document explicitly that JGroups discovery timeouts in logs are expected when KC starts alone and do not indicate failure.
- Add note to S12.5 G-IAM-08 PR description; cross-link from observability dashboards (R3) once webhook lands.

### Objective (c) — Session timeout hardening

- Already PREP DONE in S12.2 (docs/runbooks/S12-2-KC-SESSION-TIMEOUTS.md).
- R2 confirms this is sufficient as design baseline; implementation lands as part of S12 sprint execution.

### Objective (d) — DB readiness validation contract

- Contract: KC must validate (i) Postgres :15433 TCP reachable, (ii) schema version matches expected migration head, (iii) replica lag ≤ 5 seconds (if replica configured; not configured today per ADR-017 single-replica).
- Validation runs at KC startup (init container or entrypoint script).
- Failure mode: KC refuses to start with explicit error in logs, not silent unhealthy.

## Acceptance criteria (DONE definition for R2 implementation in S12)

- Unhealthy-to-healthy runbook published and tested with simulated failure for each of the 4 root causes.
- JGroups singleton fallback documented in ADR-017 and referenced from S12.5 PR.
- S12.2 session timeout runbook merged (PREP DONE per existing line in IL).
- DB readiness validation contract implemented in KC startup logic (init container or entrypoint).
- ROADMAP_8Q Q1 exit gate "KC unhealthy-to-healthy runbook merged" is satisfied.

## Open questions (route to operator / Architecture WG during S12 implementation)

- Init container vs entrypoint script: which pattern does ops prefer for DB readiness validation?
- Replica configuration: should we plan for Postgres read-replica even though ADR-017 currently mandates single-replica KC?
- Realm export cadence: how often should the canonical realm export be refreshed (daily? per-change?), and where stored under R4 backup matrix?

## References

- ADR-017 (containerised Keycloak — canonical design)
- IL-OPS-V2-DELTA-ANALYSIS-LEGACY-REFACTOR-2026-05-22 (line 8775, R2 PARTIAL)
- docs/runbooks/S12-2-KC-SESSION-TIMEOUTS.md (S12.2 PREP DONE)
- docs/runbooks/R4-BACKUP-AND-DR-PREP-2026-05-22.md (R4 backup matrix; Keycloak Postgres = Tier 1)
- docs/project/right-track/ROADMAP_8Q-2026-05-22.md (Q1 exit gates)
- docs/canon/UNIVERSAL-CANON-TOPOLOGY-CLARIFICATION-2026-05-22.md (House rule 10)
- Audit 2026-05-20 (KC unhealthy state observation)

=== END OF R2 IAM STABILIZATION PREP (snapshot ef4b7db) ===
