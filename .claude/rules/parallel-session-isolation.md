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

### Rule 8 — IL number is FROZEN at merge time, never asserted at creation (ADR-119)

> Added 2026-06-24 per the duplicate-IL incident: concurrent terminals double-claimed
> IL-493/494/497/500/501 because each hardcoded `[IL-NNN]` against a stale base. PRs #744,
> #749, #751 each carried a number already merged on `main`, forcing Claude Code to stop and
> ask (an I-28 duplicate). Root cause = no atomic IL allocation across concurrent terminals.

The IL number is a **pure function of `ledger/IL-SEQUENCE.json` + the shard set on the
up-to-date base** (ADR-119). It MUST NOT be treated as known at shard-creation time.

1. **Never hardcode `[IL-NNN]` at creation.** A shard's IL number is assigned by
   `python ledger/build_ledger.py` (run **FROM ROOT**) as `max+1` over the **current
   `origin/main`** — not over the base the branch was cut from. Until the branch is rebased
   onto current `main` immediately before merge, any `[IL-NNN]` in the PR title, commit
   subject, shard body, or companion doc is **provisional and unverified**.
2. **Rebase-before-merge is mandatory.** Branch protection on `main` is `strict` (must be
   up-to-date) precisely so a behind-branch cannot merge a stale number. Before merge:
   `git fetch origin && git switch -C <work> origin/main && git checkout <pr> -- <own files>
   && python ledger/build_ledger.py` (FROM ROOT) → read the assigned number from
   `IL-SEQUENCE.json` → correct every human-facing `[IL-NNN]` to match → `--check` exit 0.
3. **Serialize concurrent ledger PRs.** Merge one at a time; after each merge, the next PR
   re-rebases onto the new `main` and regenerates, so it deterministically receives the next
   `max+1`. `strict` protection enforces this at the platform level.
4. **Append-only on the number sequence, never a renumber.** Regeneration assigns the new
   shard `max+1` and MUST NOT mutate any existing key→value in `IL-SEQUENCE.json` (verify:
   added = exactly the new key; mutated = ∅; removed = ∅). Never renumber a prior entry
   (ADR-119, I-28). The same discipline applies to **named ordinals** (Rule N, ADR-NNN): a
   collision with an already-merged ordinal is resolved by taking `max+1`, never by renumber
   (this Rule itself was re-id'd 7 → 8 after ADR-121 landed Rule 7 concurrently).
5. **A duplicate is a rebase signal, not a question.** If `build_ledger.py` on the current
   base assigns a number different from the one asserted in the PR, that is the canonical
   instruction to **rebase + regenerate + re-id**, performed autonomously — it is NOT a
   stop-barrier and MUST NOT escalate to the operator (best-decision canon; only data-loss /
   irreversibility / invariant breach is a stop-barrier).

Enforced in CI by `guardian-ledger` (see
`docs/guardian/guardian-ledger-il-collision-gate.md`) and by `strict` branch protection.

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
- ADR-119 — stable/frozen IL numbering (Rule 8 merge-time freeze; "Amendment 2026-06-24")
- docs/guardian/guardian-ledger-il-collision-gate.md — pre-merge IL-collision gate spec (Rule 8)
- PRs #744/#749/#751 (2026-06-24) — duplicate-IL re-id incident (IL-503/504/505); this guard = IL-507

## Operator-runtime-config is LOCAL — not a cross-terminal git race (canon, ADR-134)

> Added 2026-06-26 per a false-attribution review: a permission-mode change was misread as a
> cross-terminal/PR race. It is not.

`~/.claude/settings.json` (operator runtime config) is **LOCAL and NOT git-tracked** — it is read
**at session startup** as local enforcement (see **ADR-039**, Claude Code permissions
reclassification). Therefore:

1. **A change to it is a LOCAL session event** (session restart / a different home file / an operator
   edit), **never a repository merge race.** A `bypassPermissions → acceptEdits` (or any permission-mode)
   shift is local startup state, not a git conflict between terminals.
2. **`.claude/` is protected in-repo** by `.github/CODEOWNERS` (`/.claude/ @mmber`) and
   `.gitignore` (`.claude/settings.local.json`). A PR cannot silently rewrite operator settings; any
   `.claude/` change requires the `@mmber` code-owner review.
3. **A permission-mode discrepancy between terminals ⇒ a local restart, not a repo conflict.** Do NOT
   diagnose it as a cross-session leak (Rules 1–7), do NOT "fix" it via git, and do NOT touch
   `~/.claude/settings.json` (operator-owned). Report the local nature and stop.
4. **Attribution rule (ADR-134):** before flagging "another/foreign governance terminal", verify PR
   actor tags — `agent/<actor>/…` (ADR-060). Factory-authored PRs (`agent/factory/…`) are *our own*
   work, not a foreign terminal; misreading them is false attribution.

Cross-ref: **ADR-039** (settings = LOCAL startup enforcement), **ADR-134** (cross-terminal
attribution + operator-gated stub classification), ADR-060 (branch actor namespace).
