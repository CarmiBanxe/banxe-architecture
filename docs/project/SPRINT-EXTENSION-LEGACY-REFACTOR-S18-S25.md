# Sprint Extension — Legacy Refactor S18-S25 (R-tracks overlay)

Date: 2026-05-22
Status: REFERENCE (operator-facing; not binding by itself)
Source: IL-OPS-V2-DELTA-ANALYSIS-LEGACY-REFACTOR-2026-05-22 (line 8775)
Backbone IL: IL-OPS-ROADMAP-SPRINTS-S12-S25-APPROVED-2026-05-11 (line 7728)
Companion file: docs/project/SPRINT-EXTENSION-LEGACY-REFACTOR-S12-S17.md (S12-S17 already covered)
Purpose: close the durability gap surfaced by the 2026-05-22 12:00 CEST shell audit — S18-S25 were not mechanically re-indexed under v2 R-tracks at the time of PR #295.

## S18 — §0.2 Levels 3-5 (SMF Heads AI duplicates + CEO dashboard + AI MLRO Option B + openclo-moa + Factory overseer §0.4)

- Backbone scope: deliver §0.2 Levels 3-5 — SMF Heads AI duplicates, CEO dashboard, AI MLRO Option B, openclo-moa, Factory overseer §0.4 (per IL line 7743).
- R-tracks overlay: R8 (AI surface extension via AI duplicates, AI MLRO, openclo-moa); R3 (CEO dashboard + Factory overseer = observability); R7 (legal boundary cleanup window per DELTA-ANALYSIS §4 mapping).
- R8-specific: SMF Heads AI duplicates and openclo-moa extend the LiteLLM / OpenClaw surface; alignment with INV-37 routing contract required.
- R3-specific: CEO dashboard and Factory overseer §0.4 require Prometheus + Grafana foundation delivered in S14 / S22 to be available; if S22 stack lands after S18, dashboard ships against the minimum stack first.
- R7-specific: §0.2 levels work coincides with the GUIYON separation window per DELTA-ANALYSIS §4 (S18-S19 mapping).
- Dependencies: S12-S17 R-track work landed; R0-DISCOVERY not required.
- DONE criterion: Levels 3-5 demonstrably running with the CEO dashboard reachable to operator and AI MLRO Option B emitting verdicts to the audit trail.

## S19 — Sandbox 100% verification (Phase F6 — COMPLIANCE-MATRIX 80%+ + G-SEC-02 Vault + AMLR review)

- Backbone scope: Phase F6 sandbox verification — COMPLIANCE-MATRIX 80%+, G-SEC-02 Vault adoption, AMLR review (per IL line 7744).
- R-tracks overlay: R4 (Vault is persistent secret state — DR matters); R3 (COMPLIANCE-MATRIX needs metrics surface); R7 (legal boundary cleanup tail of S18-S19 window).
- R4-specific: G-SEC-02 Vault adoption introduces a new stateful service; backup matrix from S15 must be extended to include Vault, and the monthly restore drill must add a Vault path before sandbox can claim 100%.
- R3-specific: COMPLIANCE-MATRIX coverage must be observable; reuse the Prometheus + Grafana stack from S14 + S22.
- R7-specific: AMLR review and GUIYON corpus scrub close together; legal boundary IL entry expected by end of S19.
- Dependencies: S15 R4 backup matrix; S14 R3 minimum observability; R0-DISCOVERY not blocking.
- DONE criterion: COMPLIANCE-MATRIX ≥80%, Vault adopted with documented restore drill, AMLR review signed off.

## S20 — External blockers Track I (7 API keys real + MLRO real + Board + Internal Audit)

- Backbone scope: close external Track I blockers — 7 real vendor API keys, real MLRO appointment, Board sign-off, Internal Audit (per IL line 7745).
- R-tracks overlay: R0-DISCOVERY (per DELTA-ANALYSIS §4 mapping S20-S25); R4 indirectly (new vendor credentials enter Vault under R4 rotation).
- R0-specific: any legacy trading claim that resurfaces during vendor onboarding is routed to R0-DISCOVERY, not absorbed into S20.
- R4-specific: 7 real API keys land in Vault per S19; their rotation cadence is the first real test of the S17 / R4 secrets-rotation policy.
- External owners: vendors (Modulr, SumSub, Sardine, Marble, Telegram, Jube), MLRO candidate, Board, Internal Audit per IL line 8732 + transfer package §5.
- Dependencies: S19 G-SEC-02 Vault; S15.1 MLRO appointment unblocked.
- DONE criterion: all 7 vendor API keys live in Vault, MLRO appointed, Board and Internal Audit sign-offs recorded as IL entries.

## S21 — Crypto Block Phase 7 (ADR-036 Travel Rule + Neuronext + TomPay + Crypto AML)

- Backbone scope: Crypto Block Phase 7 — ADR-036 Travel Rule, Neuronext, TomPay, Crypto AML (per IL line 7746).
- R-tracks overlay: R0-DISCOVERY (legacy trading discovery may surface crypto-adjacent components — e.g. neuron-bitshares-ui); R3 (crypto txn observability); R4 (new crypto persistent state).
- R0-specific: any verdict from R0-DISCOVERY on neuron-bitshares-ui or Binance bindings (claims 3 + 4 in UNVERIFIED-CLAIMS-LEGACY-DISCOVERY.md) feeds S21 scope decisions; not the other way around.
- R3-specific: crypto Travel Rule events emit to the audit trail (ADR-027 5y) and to the observability stack delivered by S14 / S22.
- R4-specific: Neuronext and TomPay introduce new persistent state; backup matrix and restore drill extended accordingly.
- Dependencies: ADR-036 already ACCEPTED; R0-DISCOVERY for trading-legacy claims should be VERIFIED or REJECTED before any code work on neuron-bitshares-ui-derived flows.
- DONE criterion: Travel Rule provider live or signed MLRO manual procedure recorded, Neuronext + TomPay reachable in sandbox, Crypto AML rules observable.

## S22 — Multi-agent Comms Phase 8 (dashboard + Telegram bot + FCA Section 4 + MI report)

- Backbone scope: Phase 8 — dashboard, Telegram bot, FCA Section 4, MI report (per IL line 7747).
- R-tracks overlay: R3 (full observability stack — Loki / Tempo / Jaeger / Otel — explicitly deferred to S22 by SPRINT-EXTENSION-LEGACY-REFACTOR-S12-S17.md); R8 (multi-agent comms extends the AI/LLM platform surface); R0-DISCOVERY (per DELTA-ANALYSIS §4 S20-S25 mapping).
- R3-specific: this sprint lands the full Loki / Tempo / Jaeger / Otel stack on evo1, on top of the minimum Prometheus + Grafana from S14.
- R8-specific: multi-agent comms extends OpenClaw / LiteLLM topology; INV-37 routing contract must remain green after the change.
- R3-specific dashboards: the FCA Section 4 dashboard and the MI report run on the new R3 stack and replace any ad-hoc evidence pulls.
- Dependencies: S14 R3 minimum stack; S18 dashboard precedent; R0-DISCOVERY non-blocking.
- DONE criterion: dashboard live, Telegram bot routing approved verdicts, FCA Section 4 section assembled from observability data, MI report auto-generated.

## S23 — QA + Production Ready Phase 9 (E2E + regression + compliance playbooks + load testing)

- Backbone scope: Phase 9 — E2E, regression, compliance playbooks, load testing (per IL line 7748).
- R-tracks overlay: R3 (load tests need full observability stack from S22); R0-DISCOVERY (per S20-S25 mapping).
- R3-specific: load testing exercises the R3 stack itself; metrics from S22 must hold under load before S23 can sign off.
- R0-specific: any legacy claim still UNVERIFIED at the start of S23 is escalated to "must close before S25", not deferred indefinitely.
- Compliance playbooks: reuse the safeguarding + audit-trail patterns from S14.1 / S16.4 / ADR-027.
- Dependencies: S22 full observability stack live; backbone S15 security residual cleared.
- DONE criterion: E2E + regression green on a load-tested environment, compliance playbooks merged, load-test report archived in audit trail.

## S24 — FCA Submission Phase 10.1 (RegData + safeguarding evidence + MLRO report + business plan)

- Backbone scope: Phase 10.1 — RegData submission, safeguarding evidence, MLRO report, business plan (per IL line 7749).
- R-tracks overlay: R3 (safeguarding evidence is harvested from the audit trail + observability stack); R0-DISCOVERY (per S20-S25 mapping, must be CLOSED here at the latest).
- R3-specific: safeguarding evidence pulls from ADR-027 audit trail and the R3 stack; no manual evidence pulls accepted at this stage.
- R0-specific: all 7 R0-DISCOVERY claims must be VERIFIED or REJECTED before S24 sign-off; UNVERIFIED status blocks RegData.
- MLRO report: depends on S20 MLRO appointment.
- Dependencies: S20 MLRO; S23 QA sign-off; R0-DISCOVERY closed.
- DONE criterion: RegData submission accepted by FCA, safeguarding evidence package archived, MLRO report and business plan filed.

## S25 — Go-Live Phase 10.2 (customer data migration + live operations + post-launch monitoring)

- Backbone scope: Phase 10.2 — customer data migration, live operations, post-launch monitoring (per IL line 7750).
- R-tracks overlay: R4 (customer data migration is a persistent-state event); R3 (post-launch monitoring is the R3 stack in production); R0-DISCOVERY (final closure of legacy claims per S20-S25 mapping).
- R4-specific: customer data migration is the highest-risk persistent-state operation in the roadmap; backup matrix and restore drill from S15 / S19 must be exercised against the migrated dataset before go-live cuts over.
- R3-specific: post-launch monitoring runs on the R3 stack from S22; alerts must page operator within agreed SLO.
- R0-specific: any UNVERIFIED legacy claim still open at S25 is treated as REJECTED by default; explicit IL entry records the rejection.
- Dependencies: S24 FCA submission accepted; S23 load-test report archived; S19 + S15 backup/restore demonstrated.
- DONE criterion: customer data migrated with rollback rehearsed, live operations running on the R3 stack, post-launch monitoring SLOs met for the first published window.

## Coverage check

- All eight sprints S18-S25 listed: yes.
- R-track coverage across S18-S25:
  - R0 — referenced in S20, S21, S22, S23, S24, S25 (gated on legacy discovery).
  - R1 — covered earlier (S13).
  - R2 — covered earlier (S12).
  - R3 — referenced in S18, S19, S21, S22, S23, S24, S25 (foundation deepens with each sprint).
  - R4 — referenced in S19, S20, S21, S25 (and covered earlier in S15).
  - R5 — covered earlier (S13); not re-attached per the constraint.
  - R6 — ALREADY_COVERED (8/8 D3.3.X domains); not applicable here.
  - R7 — referenced in S18, S19 (GUIYON separation window per DELTA-ANALYSIS §4).
  - R8 — referenced in S18, S22 (AI surface extensions).
- Pairs with companion file docs/project/SPRINT-EXTENSION-LEGACY-REFACTOR-S12-S17.md to provide full S12-S25 mechanical re-index.

=== END OF SPRINT EXTENSION S18-S25 (snapshot 0ae543a) ===
