# Delta Analysis: v2 Rebuild Roadmap (R1–R8) vs Current Baseline (S12–S25)

Date: 2026-05-22
Status: BINDING (delta overlay on existing roadmap; does NOT replace S12–S25 backbone)
Executor: Central per IL-CANON-DOCUMENTATION-OWNED-BY-CENTRAL-2026-05-12
Source: v2 audit baseline (20–21 May 2026) + existing S12–S25 binding roadmap (IL line 7728)

## 1. Summary

v2 adds 8 remediation tracks (R1–R8) to the existing S12–S25 delivery backbone. Analysis shows: 4 tracks partially covered by existing work, 3 tracks genuinely new, 1 track contains unverified claims requiring discovery sprint. No conflicts with existing S12–S25 backbone — all R-tracks are additive.

Existing S12–S25 status (per IL lines 7728–8759): S12 5/6 PREP, S13 2/8, S14 2/5, S15 4/5, S17 PREP, Sprint 0 infra fixes DONE.

## 2. Per-track delta status

| R-Track | Title | Status vs current | Evidence |
|---------|-------|-------------------|----------|
| R1 | Infrastructure Recovery (Redis/Midaz/Hyperswitch/Recon) | PARTIAL | Sprint 0 D5 identified workflow-service crash-loop; S16.4 safeguarding+recon PREP DONE Sub-B PR #135; Redis not yet addressed |
| R2 | IAM Stabilization (KC health/JGroups/DB readiness) | PARTIAL | S12.1 DONE (KC backend Postgres); S12.2/S12.3/S12.5/S12.6 PREP; KC unhealthy state seen in audit 20 May but S13.8 verified containerised design is canonical per ADR-017 |
| R3 | Observability Foundation (Prometheus/Grafana/Loki/Otel) | NEW | Audit confirms MISS on Legion; evo1 has banxe-prometheus exited; no formal observability sprint in S12-S25 beyond S14.1 CH audit retention verify |
| R4 | Backup and DR (pgdump/clickhouse-backup/restic/S3/repo mirrors) | PARTIAL | S12.6 G-IAM-09 KC backup PREP DONE Sub-B; ADR-029 Postgres backup strategy ACCEPTED; Sprint 0 CH password reset; DR pushes only 6 repos per audit |
| R5 | Repo Governance (branch protection/CODEOWNERS/CI cleanup) | PARTIAL | S13.7 .gitignore DONE; evaluate.sh wired; but branch protection gaps in banxe-payment-core, banxe-ui per audit |
| R6 | Documentation Completion | ALREADY_COVERED | D3.3.X 8/8 domain CONTENT (3333 lines); ADR INDEX 100%; 43 ADRs indexed; D3.2d reconciliation complete |
| R7 | Legal and Data Boundary Cleanup (GUIYON separation) | NEW | Legal separation plan documented in audit but no Sprint in S12-S25; GUIYON content in banxe repos confirmed by audit |
| R8 | AI/LLM Platform Stabilization (OpenClaw/LiteLLM/Ruflo topology) | PARTIAL | Software Factory Canon v1.0 RATIFIED; INV-01 amended; Sprint 0 D4 ruflo_checkpoints DDL; but OpenClaw version split and evo2 SPOF not addressed |

## 3. Unverified claims (require DISCOVERY sprint before roadmap inclusion)

| Claim | Source | Status | Required action |
|-------|--------|--------|-----------------|
| "8.6 GB BANXE.RAR unpacked" | operator brief | UNVERIFIED | Inventory sprint: verify archive contents, SHA256 per subtree |
| "12 projects in archive" | operator brief | UNVERIFIED | Same inventory sprint |
| "7 Binance-related files" | operator brief | UNVERIFIED | Same inventory sprint |
| "neuron-bitshares-ui = trading frontend" | operator brief | UNVERIFIED | Discovery: confirm identity + relevance |
| "HollaEx/CCXT recommended target" | operator brief | UNVERIFIED | ADR required after discovery confirms trading legacy |
| Paymentology 11 remote API endpoints complete | operator brief | UNVERIFIED | Contract audit against actual API spec |
| <500ms payment path SLA | operator brief | UNVERIFIED | Not in existing invariants; needs new performance invariant |

All UNVERIFIED items assigned to **R0-DISCOVERY** sprint (see section 4).

## 4. Sprint mapping: R-tracks overlaid on S12–S25

Existing S12–S25 backbone preserved. R-tracks inserted as parallel workstreams.

| Sprint window | Core S12–S25 focus | R-track overlay |
|---------------|-------------------|-----------------|
| S12 (current) | KC IAM hardening (5/6 PREP) | R2: KC health probe repair, JGroups review (extends S12.2/S12.5 scope) |
| S13 | Factory infra cleanup (2/8 done) | R1: Redis/Midaz/Hyperswitch crash-loop fix (extends S13 scope); R5: branch protection + CODEOWNERS closure |
| S14 | Guardian + governance (2/5) | R3: observability foundation (NEW track alongside S14.1 CH audit verify DONE) |
| S15 | Security residual (4/5) | R4: backup matrix + restore drill (extends S15.5 leak audit + S12.6 KC backup) |
| S16 | Operational infra | R1 continued: Redis pre-tx gate (S16.3); R6: ALREADY_COVERED (docs 8/8 CONTENT) |
| S17 | Secrets rotation (PREP DONE) | R8: AI/LLM platform stabilization (OpenClaw version alignment, SPOF reduction) |
| S18–S19 | §0.2 levels + sandbox verify | R7: legal boundary cleanup (GUIYON separation, training-data corpus scrub) |
| S20–S25 | External blockers → go-live | R0-DISCOVERY: legacy inventory, trading discovery, migration dashboard |

## 5. Additional items from delta (not in original S12–S25)

| Item | Sprint assignment | Priority | Notes |
|------|-------------------|----------|-------|
| Legacy baseline & full inventory (R0.1–R0.4) | R0-DISCOVERY (pre-S16) | P1 | Must precede any legacy migration claims |
| Strangler Fig ADR + context map | S13B (new sub-sprint) | P2 | Auth ports pattern (ADR-015) exists; generalize to all domains |
| Migration dashboard + shadow metrics | S14B (new sub-sprint) | P2 | No existing dashboard for legacy→new coverage |
| Adapter factory beyond auth | S14C (new sub-sprint) | P2 | Extends existing ADR-015 auth ports pattern |
| Compatibility matrix old→new API | S15B (new sub-sprint) | P2 | Not in current artefacts |
| Outbox + two-phase data migration | S16B (new sub-sprint) | P2 | Postgres/Alembic exists but no outbox pattern |
| Event sourcing + CQRS + Saga | S17B (new sub-sprint) | P3 | Append-only audit (ADR-027) exists; full ES/CQRS/Saga = major architecture decision requiring ADR |
| AI migration factory (formalized) | S17C (new sub-sprint) | P2 | qwen3-coder on evo1/evo2 exists; needs formal sprint deliverables |
| Trading/exchange legacy discovery | R0-DISCOVERY | P3 | All claims UNVERIFIED; discovery-only until evidence |

## 6. Recommendations

1. **Do NOT replace S12–S25.** R-tracks are additive overlays, not replacements.
2. **R0-DISCOVERY first.** Before any legacy migration claims enter binding roadmap, verify archive contents + trading findings.
3. **R6 = ALREADY_COVERED.** Documentation completion (8/8 domains CONTENT) does not need rebuild; only incremental sub-file expansion per D3.4+ sprints.
4. **R3 = highest-priority NEW track.** Observability stack (Prometheus/Grafana/Loki/Otel) is a genuine gap; no existing S12–S25 sprint covers it beyond S14.1 CH retention verify.
5. **R7 = genuine NEW track** but lower priority than R3 (legal separation is non-blocking for production; GUIYON can wait until S18–S19 window).
6. **R1 crash-loops = P0 but narrow scope.** Only workflow-service actively restarting; midaz-ledger/midaz-mongodb/hyperswitch are Exited (stopped 2+ weeks ago). Redis chain fix = S16.3 pre-tx gate.
7. **Event sourcing/CQRS/Saga (R8 extension) = P3.** Major architecture decision requiring its own ADR; do not rush into existing sprint.

## Anchors

IL-OPS-ROADMAP-SPRINTS-S12-S25-APPROVED-2026-05-11 (line 7728); IL-CANON-SOFTWARE-FACTORY-V1-INTEGRATION-ACKNOWLEDGE-2026-05-14 (line 8735); IL-OPS-SPRINT-0-CH-PASSWORD-RESET-RUFLO-DDL-2026-05-22 (line 8759); ADR-015 (auth ports); ADR-017 (KC IAM cutover); ADR-027 (audit-trail 5y); ADR-029 (Postgres backup); ADR-036 (Travel Rule); Software Factory Canon v1.0 (docs/canon/software-factory-canon-v1.md); v2 audit baseline (BANXE_AUDIT_part_00..06, 20-21 May 2026).
