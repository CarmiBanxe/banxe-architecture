# Sprint Extension: Legacy Refactor R-tracks overlaid on S12–S17

Date: 2026-05-22
Status: PROPOSED (requires operator approval before becoming BINDING)
Source: docs/project/DELTA-ANALYSIS-LEGACY-REFACTOR-vs-CURRENT-ROADMAP.md

## S12 extensions (KC IAM + R2 IAM Stabilization)

- S12.2 PREP DONE (session timeouts); deploy extends to include R2 health probe repair
- S12.5 PREP DONE Sub-B (G-IAM-08); deploy extends to include R2 Postgres auth validation
- R2-specific: JGroups discovery review (singleton fallback behavior confirmed in audit; document as accepted design per ADR-017 containerized KC)
- R2-specific: KC unhealthy → healthy transition runbook (extends S12.2 session-timeout runbook with health endpoint verification post-deploy)

## S13 extensions (Factory infra + R1 Infrastructure Recovery + R5 Repo Governance)

- S13.7 DONE (.gitignore); S13.8 DONE (G-FACTORY-05 reclassified)
- R1-specific: Redis dependency chain fix (midaz-ledger depends on Redis; Redis not started or misconfigured → Midaz crash-loop). Diagnosis + fix required before S16.3 Redis pre-tx gate.
- R1-specific: Hyperswitch startup panic (banxe-hyperswitch-app panic visible in audit). Investigate + fix or document as accepted limitation.
- R5-specific: branch protection audit for banxe-payment-core + banxe-ui + MiroFish (audit flagged gaps). CODEOWNERS file creation per repo.
- R5-specific: CI failure cleanup (evaluate.sh false-positive on markdown-only commits needs policy: --no-verify for IL/docs OR evaluate.sh scoped to changed file types).

## S14 extensions (Guardian + R3 Observability Foundation)

- S14.1 DONE (CH 5y TTL verified); S14.3 PREP DONE (webhook)
- R3-specific NEW: deploy Prometheus + Grafana on evo1 (evo1 already has banxe-prometheus exited container; restart or redeploy). Minimum viable: scrape KC + compliance-api + Guardian + ClickHouse + node-exporter.
- R3-specific NEW: Grafana dashboards for service health (reuse evo2 banxe-grafana container already running per audit).
- R3-specific DEFERRED: Loki/Tempo/Jaeger/Otel full stack → S22 (multi-agent comms + dashboards sprint in original S12-S25 roadmap).

## S15 extensions (Security + R4 Backup and DR)

- S15.2/3/4/5 PREP DONE; S15.1 MLRO blocked
- R4-specific: backup matrix formalization (which stateful services have pg_dump/clickhouse-backup/volume backup + which do not). Extend S12.6 G-IAM-09 scope.
- R4-specific: restore drill scheduling (monthly cadence per S12.6 runbook; first drill = operator HITL gated).
- R4-specific: repo DR mirror audit (only 6 of 18 repos have DR pushes per audit; extend to all critical repos).

## S16–S17 extensions (Ops infra + R8 AI/LLM Platform)

- S16.3 Redis pre-tx gate (original roadmap) — blocked on R1 Redis chain fix
- S17 PREP DONE (secrets rotation policy)
- R8-specific: OpenClaw version alignment (Legion 2026.3.24 vs evo1 2026.3.28 per audit)
- R8-specific: evo2 SPOF reduction (evo2 = sole GPU inference host; if evo2 down, AI plane dead)
- R8-specific: LiteLLM routing contract validation (canonical :4000 vs sandbox :8080 per INV-37)

## R0-DISCOVERY (pre-S16, standalone)

- Full legacy inventory of BANXE.RAR (if archive accessible)
- Trading/exchange legacy discovery (neuron-bitshares-ui, Binance bindings)
- Migration dashboard draft
- Strangler Fig ADR draft
- All UNVERIFIED claims from delta-analysis section 3
- Owner: operator-led with Central documentation support
- Deliverable: docs/project/UNVERIFIED-CLAIMS-LEGACY-DISCOVERY.md updated with evidence

## Anchors

Same as DELTA-ANALYSIS anchors + per-sprint IL references from existing S12-S25 PREP entries.
