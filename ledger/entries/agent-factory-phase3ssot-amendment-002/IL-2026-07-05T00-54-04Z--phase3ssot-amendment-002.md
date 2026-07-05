---
il_ts: 2026-07-05T00:54:04Z
session_id: agent-factory-phase3ssot-amendment-002
source: agent-factory
status: PROPOSED
---

# PHASE-3-SSOT-PLAN AMENDMENT-002 — emi-stack domain-path corrections

## What

Append AMENDMENT-002 (I-24 append-only; body preserved) correcting the two emi-stack §3 path discrepancies the
#1029 cross-repo audit found.

## Corrections

- **§3.14 ARL:** `services/arl/` → **`services/agent_routing/`**.
- **§3.17 KB:** `services/kb/` → **`services/compliance_kb/`**.
- Clarified §3.12 (audit/ vs audit_trail/) + §3 = 22 core of ~50+ services (non-exhaustive).
- Restated: operational flags (§8 crit-4) need owner-team runtime attestation, not tree-verifiable.

## Boundaries

Doc-only, prepare-only. Append-only (I-24) — no body edit. No emi-stack mutation (audit was read-only, Rule 6).
IL minted redis-serialized at ratification.

## Anchors

`governance/PHASE-3-SSOT-PLAN.md` (AMENDMENT-002) · `docs/audit/PHASE-3-SSOT-EMI-STACK-DOMAIN-AUDIT-2026-07-05.md` (#1029).
