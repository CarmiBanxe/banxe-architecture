# S14.1 — ClickHouse Guardian Audit Retention Verify

Document ID: AUDIT-S14-1-CH-RETENTION-2026-05-13
Status: VERIFIED (5y TTL active; naming mismatch with ADR-019 — amendment scheduled)
Sprint: S14.1 (Guardian audit retention verify)
Date: 2026-05-13 17:30 CEST
Executor: Central read-only shell diagnostic on evo1.

## Background

Sprint S14.1 per IL-OPS-ROADMAP-SPRINTS-S12-S25-APPROVED-2026-05-11: verify ClickHouse Guardian audit retention 5y active (already configured per ADR-019, verify production tables).

ADR-019 (AI Guardian two-family architecture, ACCEPTED locked 2026-05-03) prescribes:
- Line 31: factory side ClickHouse table `guardian_audit_factory` (TTL 5y)
- Line 47: project side ClickHouse table `guardian_audit_project` (TTL 5y)
- Line 53-54: 5y retention BLOCK on reduction
- Line 74: append-only TTL 5y per CASS audit retention

ADR-027 (audit-trail-durability, ACCEPTED 2026-05-06) addresses ClickHouse durability gaps (fail-open httpx, single-instance, no WAL above OS FS).

FCA CASS 15 §15.10: every reconciliation result, shortfall alert, FIN060 submission event durably recorded. 5y retention required.

## Diagnostic (read-only, 2026-05-13 17:25-17:30 CEST)

evo1 ClickHouse 26.3.9 active on 127.0.0.1:8123/9000/9009. Databases present: INFORMATION_SCHEMA, banxe, banxe_audit, default, information_schema, system.

### Guardian audit table found (prod-canonical)

`default.guardian_audit_events`:
- ENGINE: MergeTree
- TTL: `event_date + toIntervalYear(5)` — 5y retention ACTIVE (matches ADR-019 + FCA CASS 15 §15.10)
- PARTITION BY: toYYYYMM(event_date)
- ORDER BY: (event_date, scope, subject_type, subject_id, request_id)
- Columns: 15 (event_date, event_time_utc, request_id, subject_type, subject_id, scope, actor, prompt, verdict_result, verdict_summary, reasons_json, sources_json, loaded_domains_json, dry_run, storage_backend)
- Row count: 2801 events (live audit pipeline)
- Two-family dispatch: via `scope` column (factory vs project), not via separate tables

### ADR-019 prescribed names — NOT present

Checked all 8 candidate locations: guardian_audit / default / banxe / banxe_audit × guardian_audit_factory / guardian_audit_project — ALL MISSING.

### Other audit-related tables found (out of scope for S14.1)

- `banxe.audit_trail` — simple MergeTree, no TTL, distinct from Guardian (id/timestamp/agent/action/target/details/result)
- `banxe.safeguarding_breaches` + `banxe.safeguarding_events` — safeguarding-side (S16.4 territory)
- `banxe_audit.hitl_decisions` — HITL decisions log

## Verdict

5y TTL retention is **ACTIVE on `default.guardian_audit_events`**, functionally compliant with:
- FCA CASS 15 §15.10 (5y reconciliation evidence)
- DORA Art.14(2) (integrity of operational records)
- ADR-019 line 53-54 (5y retention BLOCK on reduction)

ADR-019 prescribed table NAMING is mismatched (single unified table vs two prescribed tables). Functional equivalence achieved via `scope` column dispatch.

## Decision

S14.1 deliverable (verify 5y retention) = **DONE**, retention active and compliant.

ADR-019 naming amendment = **SCHEDULED** as separate sprint deliverable (D3.x or new sprint), low-priority because:
1. Prod is functionally compliant (5y TTL active, append-only MergeTree, two-family dispatch via scope).
2. No data migration risk (cosmetic naming change in ADR body, not in prod).
3. Class of issue identical to D3.2c findings (anchor/naming mismatch resolved by amendment, not migration).

## Open follow-ups

- ADR-019 amendment: update lines 31, 47, 74 to reflect actual prod naming `default.guardian_audit_events` + scope dispatch. Owner sprint: D4.x or operator decision.
- ADR-027 ClickHouse durability implementation (fail-open httpx, WAL gap) remains separate open work per ADR-027 itself; NOT closed by S14.1.
- `banxe.audit_trail` no-TTL: separate audit chain (non-Guardian); review whether it needs TTL per ADR-027 follow-up.
- `banxe_audit.hitl_decisions`: review TTL + retention policy alignment per ADR-027 (S25.4 HITL review).

## Anchors

- ADR-019 (AI Guardian two-family, ACCEPTED locked 2026-05-03)
- ADR-027 (audit-trail-durability, ACCEPTED 2026-05-06)
- FCA CASS 15 §15.10, DORA Art.14(2), MLR 2017 Reg.28
- IL-OPS-ROADMAP-SPRINTS-S12-S25-APPROVED-2026-05-11 (Sprint S14.1)
- IL-CANON-DOC-MANDATORY-TWO-LAYER-2026-05-12, IL-CANON-DOCUMENTATION-OWNED-BY-CENTRAL-2026-05-12, IL-CANON-PERSISTENCE-SHELL-FIXATION-2026-05-12, IL-CANON-F01-REINFORCE-ALWAYS-ONE-ACTIONABLE-2026-05-12.
