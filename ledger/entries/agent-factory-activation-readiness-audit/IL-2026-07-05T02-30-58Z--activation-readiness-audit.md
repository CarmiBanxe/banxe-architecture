---
il_ts: 2026-07-05T02:30:58Z
session_id: agent-factory-activation-readiness-audit
source: agent-factory
status: PROPOSED
---

# PROPOSED-agent activation-readiness audit (prepare-only, read-only)

## What

Rigorous readiness check of the 39 PROPOSED passports vs factory-checkable activation preconditions (schema /
SOUL / HITL). Report: `docs/audit/ACTIVATION-READINESS-AUDIT-2026-07-05.md`. Activates nothing.

## Findings

- Corrects survey's "SOUL=0 for all" — 6 finance agents HAVE souls (underscore↔hyphen false-negative).
- **0/39 fully ready**, bimodal blocker: ~33 schema-conformant but NO SOUL; 6 finance have SOUL+HITL but schema-incomplete (7-8/10).
- Fleet activation blocked on SOUL authoring (33) + schema completion (6), BEFORE the I-27 HITL-L4 gate.
- HITL column read-with-care (governors route to services, no direct gate ≠ defect). Service-code cross-repo unverified.

## Boundaries

Doc-only, prepare-only, read-only. No activation, no status change. Activation stays I-27 HITL-L4/operator (§11).
IL minted redis-serialized at ratification.

## Anchors

`docs/audit/ACTIVATION-READINESS-AUDIT-2026-07-05.md` · `agents/passports/**` · `agents/souls/**` ·
`docs/runbooks/AGENT-ACTIVATION-PROCEDURE.md` (#1039) · #1034/#1035.
