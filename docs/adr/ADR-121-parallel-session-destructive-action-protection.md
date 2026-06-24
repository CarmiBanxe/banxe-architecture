---
id: ADR-121
title: Parallel-session destructive-action protection (no destructive ops on shared/foreign state)
status: ACCEPTED
date: 2026-06-24
accepted: 2026-06-24
supersedes: []
related:
  - "ADR-120-session-worktree-isolation.md (isolates commits; did NOT protect the shared .git)"
  - "ADR-060-branch-namespace.md (one session = one ADR-060 branch)"
  - ".claude/rules/parallel-session-isolation.md (Rule 1–7 operational mirror; Rule 7 added here)"
  - "docs/runbooks/recover-shared-checkout.md (recovery contract used on 2026-06-24)"
  - "scripts/bx-session.sh (session launcher; --cleanup removes only the session's OWN worktree)"
il_anchor: IL-506
scope: BANXE-only
concept_only: false
---

# ADR-121 — Parallel-session destructive-action protection

## Context

On **2026-06-24** the shared checkout `/home/mmber/banxe-architecture` (and its `.git`) was
**deleted mid-session** by an external/parallel-session event. Because all **12 linked worktrees**
had their `gitdir` pointing into `/home/mmber/banxe-architecture/.git/worktrees/`, deleting the
shared `.git` **cascade-orphaned every linked worktree** at once — a single destructive action took
down all concurrent sessions.

**No commits were lost** (origin was intact; recovery was a `git clone` re-establishing `main` at
`06fac53`). The incident exposed three gaps:

1. **Single shared `.git` = single point of failure.** ADR-120 placed each session in its own linked
   worktree, but all worktrees still depended on one shared `.git`. Destroying it killed all of them.
2. **No canon forbade destructive ops against shared/foreign state.** Nothing banned one session from
   running `rm -rf` on a checkout, deleting `.git`, or `git worktree remove`-ing worktrees it did not
   create. `parallel-session-isolation.md` Rule 6 covered *dirty-state* but not *destruction*.
3. **ADR-120 isolated commits, not the substrate.** Commit isolation ≠ filesystem-destruction safety.

`safety-rules.md` already requires a verify-step before destructive ops, but it did not name
shared/foreign **session state** (other checkouts, the shared `.git`, foreign worktrees, foreign
branches) as off-limits. This ADR adds that permanent prohibition (RULE 7) and the resilience +
recovery contract.

## Decision

### RULE 7 — No destructive ops against shared or foreign-session state (PERMANENT canon)

A session **MUST NEVER** run a destructive operation against shared state or another session's
state. Specifically forbidden against any path/object the session **did not itself create**:

- `rm -rf` (or any delete/`shred`/`truncate`) on **any repository checkout** or its contents;
- deleting, moving, or corrupting a **`.git` directory** (shared or linked) — including a linked
  worktree's `.git` file/admin under `.git/worktrees/`;
- `git worktree remove` / `git worktree prune` of a worktree the session **did not create**;
- force-removal or force-update of **foreign branches** (`git branch -D`, `git push --delete`,
  `git update-ref -d`) the session does not own;
- `chattr`, permission, or ownership changes on shared `.git` / shared checkouts.

**Cleanup is limited to the session's OWN isolated worktree** (the one it created off `origin/main`,
ADR-120) — e.g. `bx-session.sh --cleanup` removing **only** that worktree. Anything beyond the
session's own worktree is **operator-owned**: report, do not act (consistent with Rule 6).

> RULE 7 sits at invariant priority alongside the `safety-rules.md` stop-barriers: it is a
> **stop-barrier**, not advisory. Uncertainty about whether a target is foreign ⇒ **fail-closed**
> (treat as foreign; do not destroy) and escalate to the operator.

### Resilience — eliminate the single point of failure

1. **Preferred:** each session uses an **independent clone with its own `.git`** (full `git clone`
   per session), so no session shares a `.git` with another. A destructive action then cannot
   cascade beyond the acting session.
2. **If linked worktrees are used** (shared `.git`, the ADR-120 model): the shared `.git` is
   **operator-protected** — `chattr +i` on the shared `.git` (or a periodic backup/snapshot) — and
   the **single-point-of-failure risk is documented and accepted** (this section). Linked worktrees
   trade isolation-of-commits for a shared substrate; that substrate MUST be protected out-of-band
   because RULE 7 alone cannot stop an out-of-process `rm`.

### Recovery contract — origin is the source of truth

On loss of a shared checkout (or its `.git`), **recover via `git clone` from origin**. No local-only
state is canonical: every merged commit, ledger shard, and ADR lives on `origin/main`; unpushed
local work is the only thing at risk, which is exactly why RULE 7 + per-session push discipline
exist. The exact steps are in `docs/runbooks/recover-shared-checkout.md`.

## Enforcement

- **Pre-commit guard (`.githooks/pre-commit`, extended here):** (a) **blocks** any commit that stages
  a git-internal / worktree-admin path (`.git/…`, `*/worktrees/*`) — never a legitimate commit, so
  zero false-positives; (b) **warns** (non-blocking) when a staged **shell script** adds a RULE 7
  destructive pattern (`rm -rf` on a checkout, `.git` deletion, `git worktree remove/prune`,
  `git branch -D`, `chattr … .git`), surfacing the risk without false-blocking normal commits or
  documentation that merely *mentions* these patterns.
- **Operator (out-of-band, host):** `chattr +i` / backup the shared `.git` per the Resilience section
  — the durable protection a commit-time hook cannot provide.
- **Memory persistence:** RULE 7 + recovery pointer are mirrored into
  `.claude/rules/parallel-session-isolation.md` so every future factory/agent session loads it.

## Consequences

- **Positive:** a single destructive action can no longer cascade across sessions; the destruction
  class is named canon (stop-barrier); recovery is a known, deterministic `git clone`.
- **Cost:** independent-clone-per-session uses more disk than shared linked worktrees; if the linked
  model is kept, the operator must maintain the `chattr +i`/backup protection.
- **Limit (honest):** RULE 7 binds agents/sessions and the commit-time hook; it **cannot** stop an
  arbitrary out-of-process `rm` by a non-cooperating actor — hence the operator-side `.git`
  protection is required, not optional, under the linked-worktree model.

## Anchors

- Shared-checkout deletion incident, 2026-06-24 (12 worktrees cascade-orphaned; re-clone → `06fac53`).
- ADR-120 (worktree isolation — commits only); ADR-060 (branch namespace); I-28 (append-only).
- `.claude/rules/parallel-session-isolation.md` (Rule 7 mirror); `safety-rules.md` (verify-step / stop-barriers).
- `docs/runbooks/recover-shared-checkout.md`; `scripts/bx-session.sh`; `.githooks/pre-commit`.
