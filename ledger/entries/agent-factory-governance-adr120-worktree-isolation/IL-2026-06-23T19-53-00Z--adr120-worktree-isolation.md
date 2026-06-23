---
il_ts: 2026-06-23T19:53:00Z
session_id: agent-factory-governance-adr120-worktree-isolation
source: CEO
status: PROPOSED
---
### ADR-120 — per-session git-worktree isolation (shared checkout audit-only); bx-session launcher + pre-commit guard
- **Date:** 2026-06-23 · **Type:** governance ADR + tooling; docs/scripts/hook + ledger only; no protection/ledger-history mutation.
- **Decision:** Establish PERMANENT canon: one session = one `git worktree` off origin/main = one ADR-060 branch; the shared checkout `/home/mmber/banxe-architecture` is RESERVED audit-only (no edit/commit/session-branch); ledger regen + commits ONLY inside the session worktree (protects I-28 append-only); detached-HEAD shared checkouts forbidden as work trees.
- **Instrukciya:** Close the structural root cause behind recurring cross-session pollution by requiring physical worktree isolation and enforcing it (launcher + pre-commit guard), complementing the operational `.claude/rules/parallel-session-isolation.md` (Rule 1–6).
- **Basis (audit):** worktree audit @ mark-legion 2026-06-23 ~19:40 UTC. `git worktree list` = 12 worktrees; shared checkout in DETACHED HEAD @4c9904f holding UNCOMMITTED DELETIONS of files committed on origin/main (S-PROD-1 brief + shard b8f3d1; refactor-index PHASE-B doc + shards c4a9f7, b8e2f1) + dirty INSTRUCTION-LEDGER.md/IL-SEQUENCE.json from regen on the depleted tree; a 2nd checkout also detached. Root cause: no canon REQUIRING worktree isolation (grep found none).
- **Change (minimal, no duplication):** +`docs/adr/ADR-120-session-worktree-isolation.md`; +`scripts/bx-session.sh` (worktree launcher, `--cleanup`, refuses shared checkout, ADR-060 validated); +ADR-120 guard in `.githooks/pre-commit` (portable `*/worktrees/*` detection, no hardcoded path, no duplicated guardian logic); +ADR-120/bx-session mention in `scripts/install-hooks.sh`; +1 ledger shard. Extends existing helpers, does not duplicate.
- **Proof:** authored in an ISOLATED worktree `/home/mmber/wt/adr120-worktree-isolation` off origin/main@4c9904f (NOT the shared checkout); shared-checkout pollution left UNTOUCHED (operator-owned, Rule 6); `build_ledger.py --check` exit 0; guardian-ledger / ledger-append-only / guardian-ledger-shards / guardian-branch-naming green (local); squash PR to main (merge-queue); operator merges.
- **Canon compliance:** live-audit source of truth; best-solution; minimal-diff; append-only ledger (ADR-119 frozen IL via IL-SEQUENCE.json, max+1); branch ADR-060-compliant (`agent/factory/governance/adr120-worktree-isolation`); no S320 (S314, Ruff ≥0.12.0); hooks enabled (no `--no-verify`/`--admin`/bypass); STOP before merge.
- **Coupling/append-only:** branch off origin/main@4c9904f; single new shard; no prior entry modified.
- **Refs:** ADR-060 (branch namespace); ADR-120 (this); ADR-119 (frozen IL); I-28 (append-only); `.claude/rules/parallel-session-isolation.md`; `scripts/install-hooks.sh`; `scripts/bx-session.sh`; `.githooks/pre-commit`.
