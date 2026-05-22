# R8 — AI / LLM Platform Extension (PREP)

Date: 2026-05-22 18:30 CEST
Status: PREP (design baseline; binding implementation scoped to S17/S18/S22 per SPRINT-EXTENSION mapping)
Source: IL-OPS-V2-DELTA-ANALYSIS-LEGACY-REFACTOR-2026-05-22 (line 8775, R8 PARTIAL item)
Related: docs/project/SPRINT-EXTENSION-LEGACY-REFACTOR-S12-S17.md (S16-S17 extensions); INV-37 (LiteLLM canonical :4000 vs sandbox :8080); House rule 10 (Central does not write code in evo1 AI plane)

## Purpose

R8 (AI/LLM platform extension) consolidates the three concrete AI-plane risks identified in this session and the v2 delta-analysis: (1) OpenClaw version drift between Legion (2026.3.24) and evo1 (2026.3.28), (2) evo2 SPOF as sole GPU inference host (whole AI plane dies if evo2 down), (3) LiteLLM routing contract validation (canonical port :4000 vs sandbox :8080 per INV-37). R8 PREP captures these as design baseline; binding implementation requires code work in evo1/evo2/Legion AI plane which is NOT Central scope (House rule 10) — implementation owners are Terminal A (factory integration) and/or Terminal B (legacy refactor) reading this document asynchronously from main.

## Three risks (design baseline)

### Risk 1 — OpenClaw version drift

- Legion runs OpenClaw 2026.3.24.
- evo1 runs OpenClaw 2026.3.28.
- Both serve canonical Claude Code shim and Guardian audit pipeline.
- Drift impact: API responses may differ on edge cases; rule evaluation in Guardian may diverge silently between hosts.
- Detection: hash both binaries weekly, alert on mismatch via R3 observability stack (once S14.3 lands).
- Reconciliation policy: prefer newer (.28) as canonical; Legion upgrade scheduled for next maintenance window outside this session.
- Out of scope here: actual upgrade execution.

### Risk 2 — evo2 SPOF for AI inference

- evo2 is the sole GPU inference host for the whole BANXE AI plane.
- evo2 down = no LLM-driven verdicts, no Guardian rule extensions, no Compliance MCP responses, no R3 alerting on AI events.
- Two mitigation paths:
  - Path A: cold standby on Legion CPU (degraded latency, acceptable for sandbox not for prod).
  - Path B: warm GPU standby on second physical host (capital cost; revisit post-FCA go-live).
- PREP recommendation: Path A for S18-S23 (sandbox), Path B decision deferred to S24 RegData prep.
- Out of scope here: hardware procurement.

### Risk 3 — LiteLLM routing contract drift (INV-37)

- INV-37 binds LiteLLM canonical on :4000; sandbox lives on :8080.
- Any new AI surface (S18 SMF Heads AI duplicates, S22 multi-agent comms) must validate against INV-37 before merge.
- Drift symptoms: requests go to :8080 in prod (returns sandbox-tier models or fake answers), or to :4000 in sandbox (consumes paid tokens unnecessarily).
- Detection: AI-surface integration tests assert effective LiteLLM base_url matches INV-37 expectation per environment.
- Out of scope here: writing those tests (deferred to S18/S22 implementation).

## Acceptance criteria (PREP DONE means)

- All three risks documented with detection mechanism and out-of-scope boundary.
- INV-37 explicitly referenced as routing contract source of truth.
- Implementation deferred to named sprints (S17 for #1 reconciliation policy, S18-S23 for #2 Path A, S24 for #2 Path B decision, S18/S22 for #3 contract tests).
- House rule 10 respected — Central does not write AI plane code on evo1/evo2/Legion; document is input for Terminal A/B reading from main.

## Open questions (route to operator / Architecture WG)

- evo2 SPOF: do we accept Path A (CPU cold standby on Legion) for sandbox phases S18-S23 explicitly, or wait for hardware decision?
- OpenClaw version drift: who owns the Legion upgrade (Terminal A factory integration scope, or operator-managed maintenance window)?
- LiteLLM routing contract tests: who writes them — Terminal B legacy refactor when touching S18 AI surfaces, or Central as a follow-up PREP doc with explicit test plan?
- AI plane secret rotation alignment with S17: are LiteLLM API keys treated as Tier 0 (root) or Tier 1 (service) under R4 backup matrix?

## References

- docs/project/SPRINT-EXTENSION-LEGACY-REFACTOR-S12-S17.md (S16-S17 extensions including R8 items)
- docs/runbooks/R4-BACKUP-AND-DR-PREP-2026-05-22.md (S17 secret rotation alignment)
- INV-37 (LiteLLM canonical :4000 vs sandbox :8080)
- House rule 10 (docs/canon/UNIVERSAL-CANON-TOPOLOGY-CLARIFICATION-2026-05-22.md)
- IL-OPS-V2-DELTA-ANALYSIS-LEGACY-REFACTOR-2026-05-22 line 8775

=== END OF R8 AI-LLM PLATFORM PREP (snapshot 8a23e37) ===
