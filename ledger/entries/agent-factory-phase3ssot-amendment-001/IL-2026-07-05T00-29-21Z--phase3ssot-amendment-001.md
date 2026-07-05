---
il_ts: 2026-07-05T00:29:21Z
session_id: agent-factory-phase3ssot-amendment-001
source: agent-factory
status: PROPOSED
---

# PHASE-3-SSOT-PLAN AMENDMENT-001 — conformance corrections

## What

Append AMENDMENT-001 to `governance/PHASE-3-SSOT-PLAN.md` (I-24 append-only; body preserved) correcting the
two discrepancies + stale statuses the #1026 conformance audit found.

## Corrections

- **Path:** §5/§3.21 STAFF-MATRIX-v3 `docs/` → **`governance/`** (docs/ path doesn't exist).
- **Count:** §5/§3.21 passport total 74 → **70** — STAFF-MATRIX-v3 §1 states 70 (filesystem scan 2026-07-02);
  proven internally consistent (12 heads + 58 PROPOSED = 70, not 74). [My #1026 finding confirmed after a
  self-check against the wrong inventory — 70 is authoritative.]
- **§8 criteria 1/2/6 + §7 #270:** ⏳ → ✅ DONE (all merged on main).
- Refreshed IL tip 864→887, ADR range →160. Clarified §3.20 (two GAP registers) + §3 emi-stack domains unverified.

## Boundaries

Doc-only, prepare-only. Append-only (I-24) — no body edit, no passport activation, no SSOT ownership change.
IL minted redis-serialized at ratification (REDIS_HOST=100.68.102.48).

## Anchors

`governance/PHASE-3-SSOT-PLAN.md` (AMENDMENT-001) · `docs/audit/PHASE-3-SSOT-CONFORMANCE-2026-07-05.md` (#1026) ·
`governance/STAFF-MATRIX-v3.md` (§1 total=70).
