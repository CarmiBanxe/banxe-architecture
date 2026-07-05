---
il_ts: 2026-07-05T01:27:58Z
session_id: agent-factory-phase3ssot-amendment-003
source: agent-factory
status: PROPOSED
---

# PHASE-3-SSOT-PLAN AMENDMENT-003 — GAP-count clarification + passport confirmation

## What

Closes the two "needs clarification" items #1026/#1029 flagged but couldn't resolve to a number. Append-only (I-24).

- **§3.20 GAP "18 OPEN":** not reproducible — docs/GAP-REGISTER yields 8-17, its GAP-076 note says "13 OPEN
  (stale statuses)", root register ~40. Highest GAP=091 (so ~92 total ok). No authoritative OPEN count exists;
  needs a register status-reconciliation pass (separate). Recommend snapshot-dating, not a pinned constant.
- **§5/§3.21 passport 70:** CONFIRMED stable — the survey's 75/82 were broad-glob artifacts; agents/passports/**
  = 70 (matches STAFF-MATRIX §1). AMENDMENT-001 holds.

## Boundaries

Doc-only, prepare-only, append-only (I-24). No number pinned that can't be reproduced; honest limitation
documented. IL minted redis-serialized at ratification.

## Anchors

`governance/PHASE-3-SSOT-PLAN.md` (AMENDMENT-003) · `docs/GAP-REGISTER.md` + `GAP-REGISTER.md` (two registers) ·
`governance/STAFF-MATRIX-v3.md` §1 (=70) · #1026/#1029 audits.
