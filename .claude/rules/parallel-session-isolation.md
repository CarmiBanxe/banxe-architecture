# Parallel session isolation (canon)

> Added 2026-05-06 per session 2026-05-05/06 incident pattern: 4 cross-session commit leaks documented in IL-052, IL-FA-01-CLOSE, IL-FA-02-EXEC.

## Problem statement

Multiple concurrent Claude Code / Aider / Cursor sessions on the same Legion host operate on the same git working tree of the same repository. This causes:

1. **Branch switching mid-operation** — Spec-First Auditor pre-commit hook switched checkout to a different branch between command issuance and execution.
2. **Stash leaks** — `git stash pop` on later session retrieves entries from a different earlier session.
3. **Commit leaks** — a commit intended for our branch lands on a parallel session's branch because checkout was hijacked.
4. **Worktree drift** — `?? docs/ops/`, `?? decisions/ADR-035-...` appear unexpectedly during our `git status` from a parallel session writing.

## Parallel session isolation canon

### Rule 1 — Always verify branch before stage

Before `git add` / `git commit`, MUST run `git -C <repo> branch --show-current` and assert it matches the intended branch. If mismatch — STOP, do not proceed with commit.

### Rule 2 — Always verify staged set before commit

Before `git commit`, MUST run `git -C <repo> diff --cached --stat` and assert exact file list matches expectation. If extra files appear (cross-session leakage) — STOP, run `git restore --staged <other-file>` for each unexpected entry.

### Rule 3 — Stash explicit-paths only

When stashing carry-over from parallel sessions, MUST use `git stash push -m "<descriptive-message>" -- <explicit-path-1> <explicit-path-2>`, never bare `git stash` (captures everything).

### Rule 4 — Push uses --force-with-lease, never --force

Bare `git push --force` discards remote work without check. Always `--force-with-lease` so a parallel session's intermediate push triggers safety abort.

### Rule 5 — Cross-session ADR/IL conflicts in INSTRUCTION-LEDGER.md

Append-only at end of file. When conflict appears (`<<<<<<<` markers), strategy = "both append-blocks remain" (keep upstream THEN keep ours, drop markers). Never resolve by taking only one side — both contain canonical work.

### Rule 6 — Worktree dirty state must be reported, not auto-resolved

If `git status --short` shows uncommitted modifications NOT initiated by current session, STOP and report to operator. Do NOT auto-stash, auto-restore, or auto-discard. Operator decides scope of resolution.

### Rule 7 — Never run destructive ops against shared or foreign-session state (ADR-121, STOP-barrier)

> Added 2026-06-24 per the shared-checkout-deletion incident: deleting the shared `.git` cascade-orphaned all 12 linked worktrees at once (no commits lost — origin intact; recovered via `git clone`). This is a **stop-barrier**, not advisory — same priority as the `safety-rules.md` destructive-op verify-step.

A session **MUST NEVER** run a destructive operation against shared state or another session's state. Against any path/object the session **did not itself create**, forbidden:

- `rm -rf` (or any delete / `shred` / `truncate`) on **any repository checkout** or its contents;
- deleting / moving / corrupting a **`.git`** directory — shared OR a linked worktree's admin under `.git/worktrees/`;
- `git worktree remove` / `git worktree prune` of a worktree the session **did not create**;
- force-removing/updating **foreign branches** (`git branch -D`, `git push --delete`, `git update-ref -d`) it does not own;
- `chattr` / permission / ownership changes on shared `.git` or shared checkouts.

**Cleanup is limited to the session's OWN isolated worktree** (created off `origin/main` per ADR-120; `bx-session.sh --cleanup` removes only that one). Anything beyond it is **operator-owned**: report, do not act (extends Rule 6). **Uncertain whether a target is foreign ⇒ fail-closed** (treat as foreign; do not destroy) and escalate.

**Resilience:** prefer an **independent clone per session** (own `.git`, no shared substrate) so destruction cannot cascade; if linked worktrees are used, the shared `.git` MUST be operator-protected (`chattr +i` / backup) — the single-point-of-failure is documented and accepted in ADR-121.

**Recovery contract:** on shared-checkout / `.git` loss, recover via **`git clone` from origin** (origin = source of truth; no local-only state is canonical). Exact steps: `docs/runbooks/recover-shared-checkout.md`.

### Application

These rules apply to:
- Perplexity supervisor in shell commands issued to operator.
- Claude Code session in pre-commit / pre-push automation.
- Any agent with `claude.bash` Guardian-shim scope.

### Anchors

- IL-052 (PR #42) — original "slipped factory branch" incident
- IL-FA-01-CLOSE (PR #80) — OLLAMA_HOST + multiple session-switch incidents
- IL-FA-02-EXEC (PR #88) — 2 systemd LiteLLM units conflict (consequence of double-session lifecycle)
- safety-rules.md (sibling canon)
- approval-rules.md (sibling canon)
- ADR-027 — Claude Code permissions reclassification
- docs/canon/operator-canon-2026-05.md — Operator canon
- ADR-120 — per-session worktree isolation (commits); ADR-121 — destructive-action protection (Rule 7)
- Shared-checkout-deletion incident 2026-06-24 (12 worktrees cascade-orphaned; re-clone → `06fac53`); `docs/runbooks/recover-shared-checkout.md`
