---
il_ts: 2026-07-07T00:29:48Z
session_id: agent-factory-knowledge-consultant-escalation-protocol
source: CEO
status: PROPOSED
---
### Consultant Escalation & Best-Decision Consultation Protocol — reference source (factory-authored, NOT canon)

- **Objective:** Preserve, as a citable **reference source** (ADR-161 Intake SSOT), the Consultant Escalation &
  Best-Decision Consultation Protocol — the spec of *when* a decision escalates to the expert-consultant and *how*
  the consultant applies the Best-Decision method. **Prepare-only**; no canon, no thresholds adopted, no
  runtime/schema/config/passport/soul change, no activation.
- **Provenance (honest):** authored **in-session by the factory's expert-consultant role** — NOT an external
  operator-supplied paper. Written directly into the file (no paste vector), so lossless by construction; the four
  prior intake attempts had failed only because a wrong document (a 24/7-orchestration synthesis, sha 274dbd3d)
  kept landing in the operator's paste buffer — that document is a #1070 near-duplicate and was correctly rejected.
- **Archived file:** `docs/sources/consultant-escalation-protocol-2026-07-07.md` (SSOT header + protocol body).
- **Classification:** reference source, **not canon**. All thresholds/weights marked "proposal, not adopted"
  (Config-over-Hardcoding §10 — adoption via human-gated config PR). Advisory-only; vердикт never self-applies;
  fail-closed on payment/compliance/KYC/AML; I-27 preserved.
- **Distinctness (ADR-102):** related but NOT a duplicate — #1080 = per-agent advisory *method*; #1070 = engine /
  24-7 / Factory-Central-Right *principles*; this = the *escalation-and-consultation protocol*.
- **Perimeter / canon:** banxe-architecture only; isolated worktree off origin/main (ADR-120); no TRADING-001 /
  agent/specproj/* (Rule 6); no secrets; no code/runtime change; signed; `--force-with-lease`.
- **Deliverable:** 1 `docs/sources/*.md` + this IL shard. ONE Draft PR, prepare-only. IL frozen-at-merge (Rule 8).
- **Refs:** ADR-161; CLAUDE.md §10; I-27; I-24; BUG-007; ADR-162; ADR-164 / `docs/design/BEST-DECISION-AGENT.md` (PR #1080);
  `docs/canon/BEST-DECISION-BOUNDARY.md`; `docs/sources/best-decision-concept-2026-07-06-v2.md`;
  `docs/sources/best-decision-self-learning-loop-2026-07-07.md` (PR #1083); ADR-102; Rule 6; ADR-120.
