# Runbook — recover a lost shared checkout / `.git`

<!-- Source: docs/runbooks/recover-shared-checkout.md | Date: 2026-06-24 | Implements: ADR-121 (recovery contract) | Anchors: ADR-120, .claude/rules/parallel-session-isolation.md Rule 7 | Incident: shared-checkout deletion 2026-06-24 -->

**When:** the shared checkout `/home/mmber/banxe-architecture` or its `.git` is missing/corrupt, and
linked worktrees are cascade-orphaned (their `gitdir` pointed into the deleted `.git/worktrees/`).

**Principle (ADR-121):** **origin is the source of truth.** No local-only state is canonical — every
merged commit, ledger shard, and ADR is on `origin/main`. Only **unpushed** local work is at risk.
Recovery is a clean `git clone`; do **not** attempt to repair foreign worktrees in place.

> RULE 7 (parallel-session-isolation.md): do not `rm -rf` or delete foreign state to "clean up" first.
> If foreign worktrees/checkouts remain, they are operator-owned — report, do not destroy.

---

## Steps (exactly what was done on 2026-06-24)

```bash
# 0. Audit first (read-only) — confirm the loss; never assume.
ls -ld /home/mmber/banxe-architecture /home/mmber/banxe-architecture/.git 2>&1
git -C /home/mmber/banxe-architecture status 2>&1 || echo "checkout gone — proceed to re-clone"

# 1. Re-clone from origin (source of truth). Use SSH remote as configured.
git clone git@github.com:CarmiBanxe/banxe-architecture.git /home/mmber/banxe-architecture
cd /home/mmber/banxe-architecture
git log --oneline -1          # confirm main tip (e.g. 06fac53 on 2026-06-24)

# 2. Re-activate hooks (ADR-060 branch gate + ADR-120/121 pre-commit guard).
bash scripts/install-hooks.sh
git config --get core.hooksPath   # expect: .githooks

# 3. (Operator, recommended — ADR-121 Resilience) protect the shared .git out-of-band:
#    sudo chattr +i .git           # immutable, OR a periodic backup/snapshot of .git
#    — a commit-time hook cannot stop an out-of-process rm; this is the durable guard.

# 4. Re-establish session worktrees AS NEEDED, each off freshly-fetched origin/main.
#    Prefer the launcher (refuses to run from the shared checkout, ADR-120):
git fetch origin
bash scripts/bx-session.sh agent/<central|right|factory>/<id>/<slug>
#    OR a raw isolated worktree:
git worktree add -b agent/<actor>/<id>/<slug> /tmp/wt-<slug> origin/main
```

## Verify

```bash
git -C /home/mmber/banxe-architecture worktree list   # shared checkout + any re-created worktrees
git -C /home/mmber/banxe-architecture rev-parse --abbrev-ref HEAD   # expect: main (clean tracking)
```

## Notes

- **No local-only recovery is needed for merged work** — it is all on origin. If a session had
  **unpushed** commits in an orphaned worktree, that work is the only potential loss; if the
  worktree files survive on disk, copy the diff out manually (operator), do not `git`-repair the
  orphaned worktree.
- **Prevent recurrence:** ADR-121 RULE 7 (no destructive ops on shared/foreign state) +
  per-session **independent clone** (own `.git`) OR operator-protected shared `.git` (`chattr +i`).
