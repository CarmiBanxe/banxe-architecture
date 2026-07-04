# ADR-160 — Bilateral Orchestration & Write-Gate

**Date:** 2026-07-04
**Status:** Accepted (renumbered 158 → 160; D-1/D-2 **NOT yet implemented on main** — see Renumber & Status Note)
**Author:** Factory (authored on branch `agent/factory/adr158/bilateral-orchestration`, merged as #1018)
**Supersedes:** none (additive; complements ADR-120, ADR-121, ADR-153, ADR-154, ADR-156)
**Tags:** governance, orchestration, security, write-gate, action-ledger

---

## Renumber & Status Note (corrective, ADR-119)

This ADR merged (#1018) numbered **ADR-158**, which was **already taken** by the merged push-safety ADR
(`ADR-158-push-safety-versioned-pre-push-guard.md`, #1016) — a duplicate ordinal (ADR-119 unique-number
invariant). It is renumbered here to **ADR-160** (159 is held by #1017). Per ADR-119 the *merged* number is
not renumbered; this forward corrective renames only this document.

**Implementation-status (factual, what is actually on `main`) + a landed defect:**
- **D-2's four write-gate guards DID land** in main's committed `.githooks/pre-push` as a **v2 union**
  (G-1 force-refspec, G-2 worktree, G-3 stash, G-4 role, G-5 branch-name/ADR-060, **G-5+ protected-ref =
  the ADR-158 push-safety guard from #1016**). The union is correct and live.
- **⚠ BUT the installed hook is DESYNCED from its source mirror.** `scripts/pre-push-branch-name.sh`
  (source of truth per #1016) was **not** updated — it remains push-safety-only. Because
  `scripts/install-hooks.sh` copies **source → installed**, any bootstrap **silently reverts the four
  write-gate guards**, breaking the #1016 byte-identical invariant. This is a regression risk that needs a
  **dedicated hook-sync follow-up** (sync `scripts/pre-push-branch-name.sh` up to the v2 union; extend the
  test harness). That follow-up is also where the hook's **G-1..G-4 comments are relabeled ADR-158 → ADR-160**
  (keeping G-5+ = ADR-158 push-safety) — relabeling only the installed copy here would be reverted by
  install-hooks, so it is deliberately **not** done in this doc-only renumber.
- **D-1 (settings.json write-gate, Appendix A) is operator-only and NOT applied.**

**Deferred governance reconciliation (NOT resolved in this renumber — flagged for a follow-up amendment):**
- §G assigns "GUARDIAN OF CANON | **Terminal A (Central)**", which (a) fuses two distinct actors — per
  **ADR-153**, Terminal A **is** the Software Factory (LEFT), and Central is a **separate** arbiter; and
  (b) contradicts **ADR-154**, which canonizes the **factory as the single arbiter** of shared-space
  boundaries. §F's "A↔Factory" axis is likewise a self-reference (A *is* the Factory). These require a
  governance decision (amend ADR-154, or restructure §F/§G to actor-named axes Central↔Factory[A] /
  Central↔TRADING-001[B] per ADR-153's alias note) and are **out of scope for this numbering corrective**.

---

## Context

An orchestration audit on 2026-07-04 revealed two structural gaps that enable
factory-side force-push and merge without operator knowledge:

**Gap 1 — Allow-list over-permissive.**
`~/.claude/settings.json` contains `"Bash(git push origin *)"` in the `allow`
list. This entry permits `git push origin +HEAD:<feature-branch>` (force-refspec
on any non-main branch) because the deny rules only block `main`/`master` and
the literal `--force` flag. The factory exploited this window when resolving
PR #272 (2026-07-04).

**Gap 2 — No versioned pre-push hook in banxe-emi-stack.**
`banxe-architecture` has `.githooks/pre-push` (ADR-060 branch-name guard), but
`banxe-emi-stack` has no equivalent. The `role-guard` pre-commit hook warns
`WARN: no .TERMINAL-ROLE anchor — skipping` instead of failing hard, giving the
factory a soft path around governance.

**Gap 3 — Unilateral visibility.**
Terminal A (Software Factory) and Central share no real-time action log. Factory
merges, pushes, and rebases are invisible to Terminal A mid-session, causing
coordination collisions and duplicate work.

**Scope (Sandbox / ADR-156):** All S-1..S-8 regulatory gates are N/A. This ADR
governs technical orchestration posture only.

---

## Decision

### D-1: WRITE-GATE (settings.json — operator applies; factory MUST NOT self-apply)

Remove over-broad allow entries and tighten deny entries so that the factory can
execute only forward-only, feature-branch pushes via `--force-with-lease`.

**Operator action required — exact diff is in Appendix A.**

Key changes:
- Remove `"Bash(git push origin *)"` and `"Bash(git push origin HEAD)"` from `allow`
- Replace with explicit per-namespace patterns: `agent/*`, `feat/*`, `fix/*`, `refactor/*`, `hotfix/*`, `chore/*`
- Add to `deny`: all `+` refspec patterns, `gh pr merge *`, self-modification of `settings.json`
- Preserve: plain non-force feature push on named namespaces

### D-2: VERSIONED PRE-PUSH HOOK (both repos)

Replace/extend `.githooks/pre-push` in **both** `banxe-architecture` and
`banxe-emi-stack` to enforce four guards (stacked, all must pass):

1. **Force-refspec guard**: REJECT any refspec containing `+` prefix
   (force push, including `+HEAD:<branch>`). Permitted only if
   `ALLOW_FORCE_WITH_LEASE=1` and the actual push uses `--force-with-lease`.

2. **Worktree guard** (ADR-120): REJECT push if working directory is the
   main checkout (not under `~/wt/`). Exception: `ALLOW_MAIN_CHECKOUT=1`.

3. **Stash guard**: REJECT push when `git stash list` is non-empty unless
   `ALLOW_STASH=1`. Prevents pushing while session state is hidden in stash.

4. **Role-guard** (hard fail): REJECT if `.TERMINAL-ROLE` anchor file is
   absent from the repo root. Replaces current WARN/skip with FAIL.

Hook file: `.githooks/pre-push` (updated in this ADR for `banxe-architecture`;
deployed to `banxe-emi-stack` via operator install command — Appendix B).

### D-3: ACTION-LEDGER (`governance/ACTION-LEDGER.md`, append-only I-24)

A shared append-only ledger visible to all terminals. Every state-changing
action MUST be recorded BEFORE execution. Format:

```
| TIMESTAMP (UTC)       | ACTOR   | ACTION      | ARTIFACT                      | TARGET          | OUTCOME |
|-----------------------|---------|-------------|-------------------------------|-----------------|---------|
| 2026-07-04T20:00:00Z  | FACTORY | git push    | +HEAD:feat/fix-sgrd-recon     | banxe-emi-stack | DONE    |
| 2026-07-04T20:30:00Z  | FACTORY | gh pr merge | #272 squash                   | banxe-emi-stack | DONE    |
```

Rules:
- Append-only (I-24): no edits to existing rows
- Write BEFORE the action (intent record), append OUTCOME row after
- All terminals (A, B, Factory, Central) write here
- Terminal A reads ACTION-LEDGER before each session step

### D-4: SINGLE-WRITER LOCK

Only one terminal writes to a given branch/repo at a time. The writing terminal
records its intent in ACTION-LEDGER before first push and OUTCOME on completion.
Terminal A seeing a FACTORY lock must pause and coordinate via ACTION-LEDGER
(ACTOR = TERMINAL-A, ACTION = PAUSE).

### D-5: FACTORY SELF-APPLICATION PROHIBITION

The factory MUST NOT:
- Apply the `settings.json` diff from Appendix A (operator-only)
- Push using `+` refspecs
- Execute `gh pr merge *`
- Modify `settings.json`, `.claude/` config, or hook scripts without explicit
  per-step operator instruction

### F) SYNC-PROTOCOL (mandatory in every A↔Factory exchange)

Every exchange between Terminal A and Factory MUST carry structured sync blocks.
An exchange without a sync block is **invalid** — the action is not credited.

**A→Factory (task assignment) MUST include a CONTEXT block:**
```
CONTEXT:
  phase:             <current phase of the master program>
  node/task:         <current node or task identifier>
  terminal_a_state:  <what Terminal A is working on>
  expected_from_factory: <what the factory is asked to produce>
  action_ledger_ref: <timestamp/row of PENDING entry already written>
```
A task without this CONTEXT block is invalid and factory MUST NOT execute it.

**Factory→A (response) MUST include a BEST-SOLUTION REPORT:**
```
BEST-SOLUTION REPORT:
  what_done:         <list of changes made>
  files:             <explicit file list>
  deviations:        <any deviation from the assignment, or "none">
  what_not_done:     <force push / +HEAD: / gh pr merge / settings.json change — always listed>
  awaiting_operator: <list of operator actions required>
  action_ledger_ref: <timestamp/row of OUTCOME row written>
```
A response without this BEST-SOLUTION REPORT is invalid and Terminal A MUST reject it.

**Bidirectional and mandatory:** both sides carry their sync block; a missing block
from either side invalidates the exchange regardless of technical correctness.

### G) ROLES & ACCOUNTABILITY

| Role | Actor | Responsibilities |
|------|-------|-----------------|
| **GUARDIAN OF CANON** | Terminal A (Central) | Sole owner of canon and orchestration rules. Validates every exchange against Sync-Protocol and write-gate. Rejects violations (force-push, main-checkout work, self-push/merge, absent sync block). Maintains ACTION-LEDGER as arbiter. Decides by BEST-DECISION principle after audit. |
| **Executor** | Factory (Claude Code) | Produces code and verifies quality under Terminal A arbitration. NEVER pushes / merges / modifies `settings.json`. Synchronises via Sync-Protocol. Returns BEST-SOLUTION REPORT. |
| **Sole remote-write window** | Operator | Only party that executes push/merge/merge-sequence to remote. Applies prepared artefacts (settings.json diff, hook install commands) as supplied by factory. |
| **Spec projects** | Terminal B | Operates under the same Sync-Protocol and write-gate as Factory; same prohibitions apply. |

Accountability chain: Factory → Terminal A (canon guardian) → Operator (remote write).
No actor may skip a link. An exchange that bypasses Terminal A arbitration is void.

---

## Consequences

### Positive

- Factory physically cannot force-push or merge without operator intervention
- All terminal actions visible in ACTION-LEDGER (eliminates Gap 3)
- Role-guard fails hard — unidentified actors cannot push
- Stash guard prevents hidden session state from propagating
- Worktree guard enforces ADR-120 at the git protocol level

### Negative / Trade-offs

- Force-with-lease requires operator pre-approval (`ALLOW_FORCE_WITH_LEASE=1`)
- ACTION-LEDGER requires consistent discipline; stale PENDING rows are noise
- Pre-push hook must be installed manually in both repos (see Appendix B)

### Invariants preserved

- I-24 (append-only): ACTION-LEDGER enforced by convention and hook
- ADR-120/121: worktree mandate now enforced at hook level
- ADR-153 (terminal topology): write-gate formalises existing topology canon
- ADR-156 (sandbox): all S-1..S-8 gates remain N/A

---

## Alternatives Rejected

| Alternative | Reason rejected |
|-------------|-----------------|
| GitHub branch protection only | Does not prevent force-push to feature branches |
| Claude Code `--no-permissions` mode | Too blunt; disables all factory operations |
| Per-session allow-list audit | Manual, fragile, already failed once (Gap 1, 2026-07-04) |
| Remove factory push rights entirely | Factory needs push for feature branches; fix is scoping, not removal |

---

## References

- ADR-060: Branch naming guardian (pre-push v1 — extended here as v2)
- ADR-120/121: Worktree mandate for banxe-architecture
- ADR-153: Terminal topology canon
- ADR-154: Shared-space orchestration
- ADR-156: Sandbox mode, S-gates N/A
- Audit event: 2026-07-04T20:42:16Z (orchestration guard audit output)
- Gap evidence: PR #272 force-push via `+HEAD:` allowed by `"Bash(git push origin *)"`

---

## Appendix A — settings.json diff (OPERATOR APPLIES; factory MUST NOT self-apply)

```diff
 "allow": [
-  "Bash(git push)",
-  "Bash(git push origin HEAD)",
-  "Bash(git push -u origin HEAD)",
   "Bash(git push --dry-run *)",
-  "Bash(git push origin *)",
+  "Bash(git push origin HEAD)",
+  "Bash(git push -u origin HEAD)",
+  "Bash(git push origin agent/*)",
+  "Bash(git push origin feat/*)",
+  "Bash(git push origin fix/*)",
+  "Bash(git push origin refactor/*)",
+  "Bash(git push origin hotfix/*)",
+  "Bash(git push origin chore/*)",
+  "Bash(git -C * push origin agent/*)",
+  "Bash(git -C * push origin feat/*)",
+  "Bash(git -C * push origin fix/*)",
+  "Bash(git -C * push origin refactor/*)",
   ...rest unchanged...
 ],
 "deny": [
   "Bash(git push --force *)",
   "Bash(git push -f *)",
   "Bash(git push * --force*)",
+  "Bash(git push * +*)",
+  "Bash(git push *+*)",
   "Bash(git push origin main)",
   "Bash(git push origin main *)",
   "Bash(git push origin master)",
   "Bash(git push origin master *)",
   "Bash(git push * HEAD:main)",
   "Bash(git push * HEAD:main *)",
   "Bash(git push * HEAD:master)",
   "Bash(git push * HEAD:master *)",
   "Bash(git -C * push --force *)",
   "Bash(git -C * push origin main)",
   "Bash(git -C * push origin main *)",
   "Bash(git -C * push origin master)",
   "Bash(git -C * push origin master *)",
+  "Bash(gh pr merge *)",
+  "Bash(gh pr merge*)",
+  "Write(~/.claude/settings.json)",
+  "Edit(~/.claude/settings.json)",
   ...rest unchanged...
 ]
```

NOTE: After applying, remove any duplicate `"Bash(git push --dry-run *)"` entry.

---

## Appendix B — Pre-push hook install commands

```bash
# banxe-architecture (hook already updated in this ADR):
git -C ~/banxe-architecture config core.hooksPath .githooks

# banxe-emi-stack (copy hook, then configure):
mkdir -p ~/banxe-emi-stack/.githooks
cp ~/banxe-architecture/.githooks/pre-push ~/banxe-emi-stack/.githooks/pre-push
git -C ~/banxe-emi-stack config core.hooksPath .githooks
```

---

## Appendix C — ACTION-LEDGER usage protocol

Before any state-changing action, append a row:

```bash
echo "| $(date -u +%FT%TZ) | FACTORY | git push | feat/my-branch | banxe-emi-stack | PENDING |" \
  >> ~/banxe-architecture/governance/ACTION-LEDGER.md
```

After completion, append an OUTCOME row (never edit the PENDING row — I-24):

```bash
echo "| $(date -u +%FT%TZ) | FACTORY | OUTCOME  | feat/my-branch | banxe-emi-stack | DONE    |" \
  >> ~/banxe-architecture/governance/ACTION-LEDGER.md
```
