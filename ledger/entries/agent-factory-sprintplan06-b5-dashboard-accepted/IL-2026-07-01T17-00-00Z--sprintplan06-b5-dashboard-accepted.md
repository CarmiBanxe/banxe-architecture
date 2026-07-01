---
il_ts: 2026-07-01T17:00:00Z
session_id: agent-factory-sprintplan06-b5-dashboard-accepted
source: factory
status: PREPARED
---
### IL-773 — Correct Sprint-B B5 dashboard row to ACCEPTED (ADR-150)

- **Task:** Fix §0 dashboard: PR #923 (IL-771) merged with B5 → OPEN (incorrect).
- **Root cause:** `a2a_bus/redis_streams.py` (`RedisStreamsA2ABus`) was already merged to
  banxe-ai-infrastructure main via infra#25 *before* B2. The IL-771 commit was amended
  to ACCEPTED but force-pushed after PR #923 was already merged and branch auto-deleted.
  GitHub re-created the branch without a PR; the incorrect OPEN content reached main.
- **Change:** `docs/agent-engine-dossier/SPRINT-PLAN.md` §0 dashboard row B5:
  `OPEN (gate-in: B2 ✅ cleared — ready to start)` →
  `infra#25, **ACCEPTED** ✅ (RedisStreamsA2ABus on main; BUS_MODE=redis wired in app.py)`
- **Evidence:** `a2a_bus/redis_streams.py` present on main; `tests/test_a2a_bus/test_redis_streams.py`
  green; semgrep 0 findings on a2a_bus/ — confirmed by operator gate-check (2026-07-01).
- **Gate-out:** Dashboard reflects verified accepted state; append-only (I-24).
- **Status:** PREPARED — operator HITL before merge.
