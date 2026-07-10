---
il_ts: 2026-07-06T23:19:04Z
session_id: agent-factory-knowledge-bestdecision-selflearning-loop-source
source: CEO
status: PROPOSED
---
### Verbatim SSOT archival — Best-Decision Self-Learning Loop consultant spec (reference source, NOT canon)

- **Objective:** Preserve, byte-for-byte, the operator-supplied consultant specification on a Best-Decision
  Self-Learning Loop for the EMI BANXE agent fleet, as a citable **reference source** under the ADR-161 Intake
  SSOT convention. Prepare-only; no canon, no thresholds, no runtime/schema/config/passport/soul change.
- **Archived file:** `docs/sources/best-decision-self-learning-loop-2026-07-07.md` (SSOT header + verbatim body).
- **Zero-loss integrity (proven):** body-bytes=**34974**, body-sha256=**c4f71e729f3791e97429f5482c405c201cee395b4d8daff6d9828ed53c30553f**.
  Proof: `tail -c 34974 <file> | sha256sum` == body-sha256 (PASS). Total file 37366 bytes (header 2392 + body 34974).
- **Classification:** reference source, **not canon**. Thresholds/weights in the paper are the CONSULTANT's proposal,
  **NOT adopted config** — any adoption lands in governance config via a human-gated PR (Config-over-Hardcoding §10).
  Nothing here sets a live threshold, weight, or gate; nothing is activated.
- **Alignment (informational, not adoption):** the paper's confidence tiers (AUTO≥0.90 / REVIEW 0.70–0.90 / BLOCK<0.70)
  correspond to existing **BUG-007**; its DecisionRecord/OutcomeRecord map onto `schemas/agent_decision_record.schema.json`
  + `clickhouse_writer`; its propose-only, human-gated boundary corresponds to I-27 / `BEST-DECISION-BOUNDARY`.
- **Forward use:** this source is the citable anchor for the deferred, pointer-first `docs/canon/BEST-DECISION-LEARNING-LOOP.md`
  (to be authored only after ADR-164 / PR #1080 lands, and after the teachers-first cohort).
- **Perimeter / canon:** banxe-architecture only; isolated worktree off origin/main (ADR-120), not shared checkout;
  no TRADING-001 / agent/specproj/* (Rule 6); no secrets; no code/runtime change; signed; `--force-with-lease`.
- **Deliverable:** 1 `docs/sources/*.md` (verbatim archival) + this IL shard. ONE Draft PR, prepare-only. IL frozen-at-merge (Rule 8).
- **Refs:** ADR-161 (Intake SSOT); Config-over-Hardcoding CLAUDE.md §10; I-27; BUG-007; ADR-162; ADR-164 / `docs/design/BEST-DECISION-AGENT.md` (PR #1080, pending);
  `docs/canon/BEST-DECISION-BOUNDARY.md`; `schemas/agent_decision_record.schema.json`; `tests/best-decision/`;
  `governance/novelty-pipeline-config.yaml`; `docs/sources/best-decision-concept-2026-07-06-v2.md`; `docs/sources/emi-banxe-engine-2026-07-06.md`.
