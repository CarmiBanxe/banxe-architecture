# R-Tracks v2 — Operator One-Pager

Date: 2026-05-22
Status: REFERENCE (operator-facing summary; not binding by itself)
Source: IL-OPS-V2-DELTA-ANALYSIS-LEGACY-REFACTOR-2026-05-22 (INSTRUCTION-LEDGER.md line 8775)

## Idea in one paragraph

S12–S25 is the delivery **backbone** — the binding roadmap approved on 2026-05-11
(IL-OPS-ROADMAP-SPRINTS-S12-S25-APPROVED-2026-05-11, line 7728). The v2 audit
(20–21 May 2026) surfaced 8 remediation tracks, R1–R8, plus a discovery bucket
R0 for unverified legacy claims. R-tracks are **overlays**: they extend or
parallel existing S12–S25 sprints, never replace them. Of the 8 overlays, R6
(documentation) is already covered by the D3.3.X domain work; R3 and R7 are
genuinely new; R1/R2/R4/R5/R8 are partial extensions of existing PREP/DONE
deliverables. R0 is gated behind discovery — no unverified claim enters the
binding roadmap until evidence is on file.

---

## R0 — Legacy discovery (BANXE.RAR + trading legacy)

- **Scope:** Inventory BANXE.RAR archive, identify projects inside it,
  verify or reject 7 operator-brief claims (archive size, project count,
  Binance files, neuron-bitshares-ui, HollaEx/CCXT target, Paymentology
  endpoints, <500ms payment SLA).
- **Why it exists:** Operator brief contains numeric and product claims that
  are not yet backed by evidence; binding roadmap must not absorb them blind.
- **Docs / IL:** docs/project/UNVERIFIED-CLAIMS-LEGACY-DISCOVERY.md;
  DELTA-ANALYSIS §3; SPRINT-EXTENSION §R0-DISCOVERY.
- **DONE looks like:** Each of the 7 claims marked VERIFIED or REJECTED with
  evidence path; Strangler Fig ADR draft + MIGRATION_DASHBOARD.md draft on disk.

## R1 — Redis dependency chain fix

- **Scope:** Diagnose and fix the Redis chain that keeps midaz-ledger in
  crash-loop and hyperswitch in startup panic; unblock S16.3 Redis pre-tx gate.
- **Why it exists:** Sprint 0 D5 identified workflow-service crash-loop; audit
  confirms midaz-ledger/midaz-mongodb/hyperswitch Exited; Redis itself is not
  yet addressed by any S12–S25 PREP.
- **Docs / IL:** SPRINT-EXTENSION §S13 extensions (R1-specific);
  DELTA-ANALYSIS §2 row R1; existing S16.3 entry in S12-S25 roadmap.
- **DONE looks like:** Redis up and reachable from midaz-ledger; midaz-ledger
  exits crash-loop state; hyperswitch either starts or is documented as
  accepted limitation with a dated note.

## R2 — Legacy EMI / IAM stabilisation

- **Scope:** Bring Keycloak from unhealthy to healthy in containerised
  deployment (ADR-017), validate Postgres auth path, document JGroups
  singleton fallback as accepted design.
- **Why it exists:** Audit 20 May showed KC unhealthy; S12.1 DONE moved KC to
  Postgres but S12.2/S12.3/S12.5/S12.6 are still PREP; health-probe behaviour
  must match the canonical containerised design.
- **Docs / IL:** SPRINT-EXTENSION §S12 extensions; ADR-017 (KC IAM cutover);
  S12.2/S12.5 PREP DONE entries; G-IAM-08, G-IAM-09 sub-tasks.
- **DONE looks like:** KC health endpoint returns healthy after deploy; runbook
  for unhealthy → healthy transition merged; JGroups behaviour captured in IL
  as accepted per ADR-017.

## R3 — Observability foundation (Prometheus + Grafana on evo1)

- **Scope:** Restart or redeploy banxe-prometheus on evo1; wire Grafana
  dashboards (reuse evo2 banxe-grafana already running); minimum scrape
  targets = KC, compliance-api, Guardian, ClickHouse, node-exporter.
  Loki / Tempo / Jaeger / Otel full stack deferred to S22.
- **Why it exists:** Genuine NEW gap. No S12–S25 sprint covers observability
  beyond S14.1 ClickHouse retention verify; Legion has no observability
  stack; evo1 banxe-prometheus container is in Exited state.
- **Docs / IL:** SPRINT-EXTENSION §S14 extensions (R3-specific NEW);
  DELTA-ANALYSIS §2 row R3 + §6 recommendation #4 (highest-priority NEW).
- **DONE looks like:** Prometheus on evo1 scraping the 5 targets above;
  Grafana shows a service-health dashboard reachable to operator; Loki /
  Tempo / Jaeger / Otel explicitly deferred in IL to S22.

## R4 — Backup and DR

- **Scope:** Formalise backup matrix (which stateful services have pg_dump /
  clickhouse-backup / volume backup, which do not); schedule monthly restore
  drill (first drill operator-HITL); extend repo DR mirrors from 6 to all
  critical repos.
- **Why it exists:** S12.6 G-IAM-09 KC backup PREP DONE and ADR-029 Postgres
  backup ACCEPTED cover only part of the surface; audit shows only 6 of 18
  repos have DR pushes.
- **Docs / IL:** SPRINT-EXTENSION §S15 extensions (R4-specific);
  ADR-029 (Postgres backup); S12.6 G-IAM-09; S15.5 leak audit.
- **DONE looks like:** Backup matrix table merged into docs/project/;
  first monthly restore drill executed with operator approval and logged in
  IL; DR mirror push list extended to all critical repos.

## R5 — Repo governance (branch protection, hooks, gitleaks, key hygiene)

- **Scope:** Close branch-protection gaps in banxe-payment-core, banxe-ui,
  MiroFish; create per-repo CODEOWNERS; resolve evaluate.sh false-positives
  on markdown-only commits (either scope evaluate.sh to changed file types
  or formal policy on --no-verify for IL/docs commits).
- **Why it exists:** S13.7 .gitignore is DONE and evaluate.sh is wired, but
  audit flagged branch-protection gaps; CI noise on docs-only commits is a
  recurring operator friction point.
- **Docs / IL:** SPRINT-EXTENSION §S13 extensions (R5-specific);
  DELTA-ANALYSIS §2 row R5; S13.7 / S13.8 entries.
- **DONE looks like:** Branch protection enabled on the 3 flagged repos;
  CODEOWNERS present in each; evaluate.sh either passes cleanly on
  markdown-only commits or its scope rule is captured in IL.

## R6 — Documentation / Layer 2 (already covered)

- **Scope:** Layer-2 documentation completion across 8 D3.3.X domains; ADR
  index; D3.2d reconciliation.
- **Why it exists:** Identified as a track in the v2 audit, but the work was
  already delivered before the audit closed.
- **Docs / IL:** DELTA-ANALYSIS §2 row R6 (status ALREADY_COVERED);
  §6 recommendation #3; D3.3.X domain files (8/8, 3333 lines);
  ADR INDEX (43 ADRs indexed); D3.2d reconciliation entries.
- **DONE looks like:** No new sprint needed; incremental D3.4+ sub-file
  expansion continues under the existing documentation cadence.

## R7 — Legal boundary cleanup (GUIYON separation)

- **Scope:** Separate GUIYON content from BANXE repos; scrub training-data
  corpora; document the legal/data boundary so that future commits cannot
  re-mix the two.
- **Why it exists:** Genuine NEW. Audit confirms GUIYON content present in
  BANXE repos; no S12–S25 sprint addresses it; legal separation is
  non-blocking for production but must precede go-live.
- **Docs / IL:** SPRINT-EXTENSION §S18–S19 window (R7 assignment);
  DELTA-ANALYSIS §2 row R7 + §6 recommendation #5 (lower priority than R3).
- **DONE looks like:** GUIYON content removed from BANXE repo histories
  where legally required, isolated where retention is required; IL entry
  records the boundary rule so future PRs can be checked against it.

## R8 — AI / LLM platform extension

- **Scope:** Align OpenClaw version between Legion (2026.3.24) and evo1
  (2026.3.28); reduce evo2 SPOF (evo2 is the sole GPU inference host today);
  validate LiteLLM routing contract (canonical :4000 vs sandbox :8080 per
  INV-37).
- **Why it exists:** Software Factory Canon v1.0 is RATIFIED and Sprint 0 D4
  delivered ruflo_checkpoints DDL, but the version split and the evo2
  single-point-of-failure are not yet addressed by any S12–S25 sprint.
- **Docs / IL:** SPRINT-EXTENSION §S16–S17 extensions (R8-specific);
  Software Factory Canon v1.0 (docs/canon/software-factory-canon-v1.md);
  INV-37 (LiteLLM routing); IL-OPS-SPRINT-0-CH-PASSWORD-RESET-RUFLO-DDL-2026-05-22.
- **DONE looks like:** OpenClaw version identical on Legion and evo1;
  fallback inference host configured so evo2 outage does not kill the AI
  plane; LiteLLM port contract verified end-to-end against INV-37.

---

## How to use this page

1. Read it as the operator-side index into the v2 overlay.
2. For any R-track, the deeper text lives in DELTA-ANALYSIS-LEGACY-REFACTOR-vs-CURRENT-ROADMAP.md
   (per-track status + evidence) and SPRINT-EXTENSION-LEGACY-REFACTOR-S12-S17.md
   (per-sprint extension detail).
3. R0 stays out of the binding roadmap until UNVERIFIED-CLAIMS-LEGACY-DISCOVERY.md
   moves each of the 7 claims to VERIFIED or REJECTED.
4. R6 needs no further sprint — only incremental D3.4+ expansion.

## Anchors

IL-OPS-V2-DELTA-ANALYSIS-LEGACY-REFACTOR-2026-05-22 (line 8775);
IL-OPS-ROADMAP-SPRINTS-S12-S25-APPROVED-2026-05-11 (line 7728);
IL-CANON-SOFTWARE-FACTORY-V1-INTEGRATION-ACKNOWLEDGE-2026-05-14 (line 8735);
IL-OPS-SPRINT-0-CH-PASSWORD-RESET-RUFLO-DDL-2026-05-22 (line 8759);
ADR-015, ADR-017, ADR-027, ADR-029, ADR-036;
Software Factory Canon v1.0; v2 audit baseline (BANXE_AUDIT_part_00..06, 20–21 May 2026).
