---
il_ts: 2026-07-01T12:00:00Z
session_id: agent-factory-governance-a5-ctio-accepted
source: factory
status: ACCEPTED
---
### IL-765 — Sprint-A A5 ACCEPTED by CTIO (PR #865)
- **Decision:** Sprint-A A5 (planner.yaml passport revisions + intent-layer masks) ACCEPTED by CTIO. PR #865 merged into main.
- **Scope:** A5 gate-in satisfied. Unblocks Sprint-B B2 (Intent-Dispatcher Runtime Wiring).
- **Proof:** PR #865 merged; A5 planner.yaml and intent-layer masks finalized. ADR-045 amendment applies; ADR-049 intent masks L1/L2 boundary documented.
- **Status:** ACCEPTED — governance decision recorded. IL provisional, NOT hardcoded (ADR-119 Rule 8) — `build_ledger` mints max+1 over current origin/main. Isolated worktree off origin/main (ADR-120); namespace ADR-060; no git ops outside this branch.
- **Refs:** PR #865 (planner.yaml passport revisions); ADR-045 (A5 amendment, IL-693); ADR-049 (intent masks L1/L2 boundary); SPRINT-PLAN.md §2 A5 gate-out.
