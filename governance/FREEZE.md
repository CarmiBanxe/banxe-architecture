# Frozen sessions (per Fable-5 advisory 2026-08-04)

Live parallel sessions with uncommitted work that must not be
touched by other agents. Each entry MUST have owner, review-date,
and reconcile-obligation.

## bank-operating-model/20260718 (2026-08-04)

- **worktree:** /home/mmber/wt/architecture-bank-operating-model-20260718
- **branch:** agent/factory/bank-operating-model/20260718
- **status:** LIVE parallel session (uncommitted work)
- **detected artifacts:**
  - ADR-182 draft (banksy creative contour)
  - governance docs 2026-08-04
  - docs/audit/ledger-mint-failure-2026-08-03.md
  - CLAUDE.md §2.6 (own Codex-second-opinion formulation,
    potentially conflicts with ADR-181 merged canon)
- **conflict:** §2.6 vs ADR-181 (single source of truth, ADR-102)
- **owner-session:** bank-operating-model/20260718 owner
- **review-date:** 2026-08-11 (7 days — active work needs
  reconciliation window)
- **reconcile-obligation:** owner-session MUST bring §2.6 to
  ADR-181 canon BEFORE any commit; ADR-182 draft goes as
  separate PR after §2.6 reconciliation
- **isolation rule:** NO other agent/session touches any file inside
  this worktree until review-date (ADR-120/121 session isolation);
  freeze is recorded here on main only — the D1 worktree itself is
  not modified by this record.
  *(строка реконструирована фабрикой: операторский input оборвался на
  «NO O…» — сверить при ревью)*
