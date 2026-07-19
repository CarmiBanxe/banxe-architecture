<!--
DRAFT ONLY — NOT A REAL LEDGER SHARD. NOT MINTED. NOT COMMITTED.
Deliberately named without the "IL-*.md" pattern so ledger/build_ledger.py (which scans
ledger/entries/**/IL-*.md) cannot pick this up and silently assign it a real IL number.
No il_ts/session_id below is a real allocator-assigned value — this is a proposal for the
operator to review; if ratified, a real shard must be minted via ledger/build_ledger.py in
an isolated worktree, per the standing factory ledger protocol.
-->

# Quarantine/repair record (DRAFT) — evo1/legion R0 services

**Status:** PROPOSED, awaiting operator ratification. Companion to
`docs/adr/ADR-QUARANTINE-MIDAZ-EVO1.md` (not yet accepted — pointer, not restated).
**Source-of-truth (pointer-first, not restated):**
`docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` §0/§1/§2 (A6, R0, S-FAC-60/61) ·
`docs/runbooks/S-FAC-60-evo1-remediation-2026-07-18.md` ·
`docs/runbooks/S-FAC-61-health-contract-2026-07-18.md` ·
`INSTRUCTION-LEDGER.md` IL-487.

## Per-service record

### midaz-ledger
- **Status:** RED (RESTARTING) — last confirmed 2026-06-23; current live state **UNKNOWN**
  (an unconfirmed, differently-sprint-labeled note hints "Up/healthy"; not independently
  verified — see ADR §2).
- **Decision:** QUARANTINE (provisional).
- **Reason:** S-FAC-60 DoD permits quarantine "w/ reason in ledger" as an alternative to
  GREEN≥30min; root-cause is documented only as ranked hypotheses, not confirmed
  (S-FAC-60 runbook §2/§6); no dedicated `TL_TARGETS` probe exists to detect true state.
- **Evidence date:** roadmap 2026-06-23; runbook 2026-07-18.

### mongodb
- **Status:** RED (RESTARTING) — same finding/evidence as `midaz-ledger` (grouped in A6).
- **Decision:** QUARANTINE (provisional).
- **Reason:** identical to `midaz-ledger` above — same S-FAC-60 finding, same runbook, no
  service-specific evidence beyond the grouped A6 line.
- **Evidence date:** roadmap 2026-06-23; runbook 2026-07-18.

### workflow-service
- **Status:** RED (RESTARTING) — same A6 finding; **exact container/service name itself
  unconfirmed** (S-FAC-60 runbook §6).
- **Decision:** QUARANTINE (provisional).
- **Reason:** same as above, plus an unresolved identity gap (which container this even
  refers to) that should be closed before this quarantine record can be considered
  complete.
- **Evidence date:** roadmap 2026-06-23; runbook 2026-07-18.

### keycloak
- **Status:** was YELLOW (unhealthy) per 2026-06-23 roadmap — **now confirmed GREEN**,
  independently re-verified live 2026-07-18 (`keycloak-banxe-emi` Up 30h healthy,
  `:8180/realms/master` HTTP 200; root cause + fix per IL-487: healthcheck lacked
  `Connection: close`, causing a false-negative "unhealthy").
- **Decision:** **NO QUARANTINE — already REPAIRED.** Recorded here to correct the stale
  YELLOW, not to flag an open risk.
- **Reason:** S-FAC-61 DoD item ("keycloak YELLOW→GREEN root-cause + fix") is met per
  independent live re-verification; quarantining an already-resolved item would misstate
  the record.
- **Evidence date:** roadmap 2026-06-23 (stale); runbook + live check 2026-07-18.

## Append-only / pointer-first compliance

This draft restates no roadmap or runbook content beyond short verbatim quotes needed for
the decision line; full text lives in the referenced files. If ratified, this record must
be minted as a real, immutable shard (never edited in place afterward) via the standard
`ledger/build_ledger.py` flow — this draft file itself must **not** be renamed to match the
`IL-*.md` pattern before that mint happens, to avoid an accidental, un-reviewed mint.
