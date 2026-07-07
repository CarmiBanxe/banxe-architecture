---
il_ts: 2026-07-07T09:35:25Z
session_id: agent-factory-canon-best-decision-learning-loop
source: CEO
status: PROPOSED
---
### Author BEST-DECISION-LEARNING-LOOP.md — bank-runtime decision-quality feedback loop (net-new, pointer-first)

- **Objective:** Author `docs/canon/BEST-DECISION-LEARNING-LOOP.md` — the canon for the **bank runtime
  decision-quality feedback loop** (decide → record → score → evaluate → propose → human/MLRO gate). Prepare-only;
  pointer-first (ADR-102); no runtime/config/schema/passport/SOUL change; no activation.
- **ADR-102 dedup verdict (grounded on main):** net-new. The bank-runtime loop is ABSENT from all candidates —
  **ADR-141** is `scope: BANXE-factory-only` with RED payment/KYC/AML/sanctions EXCLUDED (PRECOND-06); the sp38
  `BEST-DECISION-RATIFICATION-SYNTHESIS` has **0** runtime-loop mentions; the Perplexity
  `consultant-response-best-decision-2026-07-07.md` defines the *decider* (deterministic admissibility gate → scoring),
  not the loop. This doc is the complement ADR-141 does not cover; it POINTS to ADR-141 (factory loop, distinct) and
  ADR-164 (method), and does not rival either.
- **Distinctness declared in the doc:** ADR-164 = method (decider unit); ADR-141 = factory self-healing loop (RED-excluded);
  sp38 + consultant-response = ratification of the decider; this = the RED/runtime bank decision-quality LOOP.
- **Loop stages bound to EXISTING infra (nothing invented):** DECIDE (ADR-164 method + deterministic admissibility gate
  per sp38/consultant Q1) → RECORD (agent_decision_record.schema.json + clickhouse_writer decision_events, append-only
  I-24) → SCORE/OUTCOME (metrics per self-learning-loop source #1083) → EVALUATE (tests/best-decision + BUG-007 tiers,
  pointer, no new threshold) → PROPOSE (ImprovementProposal, PROPOSED only) → HUMAN/MLRO GATE (novelty-pipeline-config.yaml
  via human-gated PR, §10 / I-27).
- **HARD RULE (stop-barrier):** runtime L2+ on payment/compliance/KYC/AML NEVER self-modify gates/weights; every config
  change human-ratified; fail-closed on ambiguity. "Предлагает система — утверждает человек."
- **SYNC-CANON (ADR-163) compliance:** authored sync-before-write off current origin/main; no runtime/config/schema change.
- **Correction:** source pointer uses the correct date `best-decision-self-learning-loop-2026-07-07.md` (the spec's `-06` would dangle).
- **Perimeter:** banxe-architecture; worktree off origin/main (ADR-120); no TRADING-001 / agent/specproj/* (Rule 6);
  signed; --force-with-lease. IL frozen-at-merge (Rule 8). Thresholds are PROPOSALS in config, never canon-hardcoded.
- **Deliverable:** 1 `docs/canon/BEST-DECISION-LEARNING-LOOP.md` + this shard. ONE Draft PR, prepare-only.
- **Refs:** ADR-102; ADR-141; ADR-162; ADR-163; ADR-164; ADR-161; CLAUDE.md §10/§11; I-17; I-24; I-27; BUG-007;
  docs/design/BEST-DECISION-AGENT.md (#1080); docs/design/BEST-DECISION-RATIFICATION-SYNTHESIS.md (sp38);
  docs/sources/consultant-response-best-decision-2026-07-07.md; docs/sources/consultant-escalation-protocol-2026-07-07.md (#1084);
  docs/sources/best-decision-self-learning-loop-2026-07-07.md (#1083); docs/sources/best-decision-concept-2026-07-06-v2.md;
  docs/canon/BEST-DECISION-BOUNDARY.md; schemas/agent_decision_record.schema.json; tests/best-decision/; governance/novelty-pipeline-config.yaml.
