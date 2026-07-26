# Phase-2 Next Code-Migration Sprint — Basement to Rooms (Spec Only)

**PHASE-2 EXECUTION / NEXT CODE-MIGRATION SPRINT SPEC / NO AUTO-MOVE / NO LEGAL STATUS**

## 1) Link to roadmap and previous sprint

- Follows `PHASE2-MASTER-CODE-MIGRATION-ROADMAP-AND-VERIFICATION-GATES-2026-07-20.md` (phases A–E and the five gates).
- Builds directly on `S-A6-FIRST-INSTALL-AUDIT-AND-MIGRATION-SPLIT-CASE1-2026-07-20.md` (audit/migration split; findings feed here).
- This sprint spec is Phase C/D/E for low/medium-risk families only, after S-A6 Case1 — high-risk ledger core stays out.
- It reuses the `S-PILOT-CODE-MIGRATION-SANDBOX-DEMO-REPORTING-VIEW-2026-07-20.md` pattern (plan → gates → rollback → post-audit).
- Spec/paper mode: it describes what will move and how; it performs no moves.

## 2) Migration scope — which code moves

Candidate families (REAL-CANDIDATE, HITL-pending). Only low/medium-risk; the high-risk ledger core (GL-CORE-001, MIDAZ-ADAPTER-002, MIDAZ-MCP-003) is explicitly excluded.

- **LEDGER-FAM-RECON-SAFEGUARD-005**
  - Components: recon_engine.py; safeguarding_account_port.py; midaz_reconciliation.py.
  - Basement location: banxe-emi-stack / services/recon.
  - Target room: reconciliation perimeter within the ledger lane (read-side / assurance).
  - Risk level: medium.
  - Why appropriate: reconciliation is read/assurance-oriented, not a primary posting path; no new write path introduced.

- **DEMO-FAM-REPORTING-VIEW (SANDBOX)**
  - Components: demo_report_builder.py.
  - Basement location: banksy-sandbox-repo / services/demo-reporting-view.
  - Target room: "other" lane reporting framework (sandbox).
  - Risk level: low.
  - Why appropriate: synthetic, read-only; already rehearsed by S-PILOT — safe warm-up for the real pattern.

- **DEMO-FAM-ANALYTICS-SIDECAR (SANDBOX)**
  - Components: demo_analytics_sidecar.py.
  - Basement location: banksy-sandbox-repo / services/demo-analytics-sidecar.
  - Target room: "other" lane analytics perimeter (sandbox).
  - Risk level: low.
  - Why appropriate: synthetic, read-only, no value-bearing path.

- **DEMO-FAM-REPORTING-VIEW-REAL-CANDIDATE (reporting/statement)**
  - Components: statement/report builders under the reporting perimeter (to be confirmed by shell-audit before inclusion).
  - Basement location: banxe-emi-stack / services/recon (statement_fetcher.py, bankstatement_parser.py) — read-side only.
  - Target room: "other"/reporting lane.
  - Risk level: medium.
  - Why appropriate: statement parsing is read-oriented; included only if S-A6 Case1 findings for it are Confirmed-with-caveats or better.

## 3) Gates that must pass before migration

- [ ] S-A6 findings for each candidate family are at least **Confirmed-with-caveats** (not Broken, not Not proven).
- [ ] Any identity/gateway/payments gate the family touches already has an install-audit (S-A5 identity done; gateway via S-A7/S-GATE-REPAIR where relevant).
- [ ] **Audit-evidence gate:** target lane install-audit exists and its checks cover the family.
- [ ] **Rollback readiness gate:** rollback and cutover plan exists and is dry-run tested (S-PILOT pattern).
- [ ] HITL approvals obtained from the lane owner(s) for each family.
- [ ] Confirmation that no LedgerPort/LedgerAgent or gateway/auth perimeter is bypassed by the move.

## 4) Step-by-step migration plan (spec-only)

Description only; no code changes.

1. Confirm S-A6 Case1 findings for each candidate family (HITL); drop any that are Broken/Not proven.
2. Define the target module/dir structure in the governed lane ("rooms") for each family.
3. Map current basement files to target paths (one-to-one where possible; refactor noted but not applied).
4. Specify required config changes (paths, imports) as a written plan, WITHOUT applying them.
5. Define the rollback plan per family (restore basement structure and prior config).
6. Define post-migration verification (parity checks on outputs, log presence, metric sanity).
7. List the read-only shell-audit commands operators will run before and after the move (names-only, per the shell-audit canon).
8. Define HITL sign-off points: before cutover and after verification.
9. Sequence families low-risk first (sandbox reporting/analytics) then medium-risk (recon/statement).
10. Mark out-of-scope items explicitly (high-risk ledger core; any unresolved Broken/Not proven findings).
11. Record assumptions and limitations (reversible only, gated, human-executed).

## 5) Constraints on migration execution

- Only low/medium-risk families included; the high-risk ledger core stays out.
- No direct DB writes added; all access uses existing ports/gates.
- No bypass of LedgerPort/LedgerAgent or the gateway/auth perimeter.
- Migration must be reversible (rollback tested before cutover).
- All changes are executed later by humans under HITL — never by Claude, never auto-applied.

## 6) Expected outputs of this sprint spec

Documents only.

- Per-family migration mapping (basement → room paths).
- Gate checklist (which gates are required and how each is proven).
- Rollback plan doc (per family group).
- Post-migration verification plan (tests, logs, metrics).
- Updated Phase-2 roadmap annotation ("next sprint candidates prepared").
