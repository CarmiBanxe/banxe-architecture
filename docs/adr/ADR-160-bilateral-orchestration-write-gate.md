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

**Governance reconciliation — RESOLVED via scope-separation (operator ruling 2026-07-05; no amendment to ADR-154):**
- The earlier §G fusion "GUARDIAN OF CANON | Terminal A (Central)" is corrected: **Central** (a *separate*
  actor per **ADR-153**, NOT Terminal A) is the **canon / write-gate authority**; the **Factory** (= Terminal A
  / LEFT) is the **executor** *and* — per **ADR-154**, at a **different scope** — the shared-space **concurrency**
  arbiter (IL / branch / ledger / worktree). The two arbiter roles coexist without conflict, so **ADR-154 is
  referenced, not amended**. §F's "A↔Factory" self-reference is rewritten to actor-named axes
  **Central↔Factory[A]** / **Central↔TRADING-001[B]** (Central = hub) per ADR-153's alias note. See §F header,
  the §G "Scope Separation" note, and §H.

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
merges, pushes, and rebases are invisible to Central mid-session, causing
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
- Central reads ACTION-LEDGER before each session step

### D-4: SINGLE-WRITER LOCK

Only one terminal writes to a given branch/repo at a time. The writing terminal
records its intent in ACTION-LEDGER before first push and OUTCOME on completion.
Central (or a peer terminal) seeing a FACTORY lock must pause and coordinate via ACTION-LEDGER
(ACTOR = TERMINAL-A, ACTION = PAUSE).

### D-5: FACTORY SELF-APPLICATION PROHIBITION

The factory MUST NOT:
- Apply the `settings.json` diff from Appendix A (operator-only)
- Push using `+` refspecs
- Execute `gh pr merge *`
- Modify `settings.json`, `.claude/` config, or hook scripts without explicit
  per-step operator instruction

### F) SYNC-PROTOCOL (mandatory in every Central↔Factory exchange)

> **Actor naming (ADR-153 alias note):** the sync axis is **Central ↔ Factory**, not "A↔Factory".
> Per ADR-153, **Terminal A *is* the Software Factory (LEFT)** — so "A↔Factory" was a self-reference;
> **Central** is the *separate* governance/arbiter actor. The parallel axis is **Central ↔ TRADING-001
> (Terminal B, RIGHT)**, with Central the mandatory hub of both (see §H).

Every exchange between Central and the Factory MUST carry structured sync blocks.
An exchange without a sync block is **invalid** — the action is not credited.

**Central→Factory (task assignment) MUST include a CONTEXT block:**
```
CONTEXT:
  phase:             <current phase of the master program>
  node/task:         <current node or task identifier>
  central_state:     <what Central is orchestrating>
  expected_from_factory: <what the factory is asked to produce>
  action_ledger_ref: <timestamp/row of PENDING entry already written>
```
A task without this CONTEXT block is invalid and factory MUST NOT execute it.

**Factory→Central (response) MUST include a BEST-SOLUTION REPORT:**
```
BEST-SOLUTION REPORT:
  what_done:         <list of changes made>
  files:             <explicit file list>
  deviations:        <any deviation from the assignment, or "none">
  what_not_done:     <force push / +HEAD: / gh pr merge / settings.json change — always listed>
  awaiting_operator: <list of operator actions required>
  action_ledger_ref: <timestamp/row of OUTCOME row written>
```
A response without this BEST-SOLUTION REPORT is invalid and Central MUST reject it.

**Bidirectional and mandatory:** both sides carry their sync block; a missing block
from either side invalidates the exchange regardless of technical correctness.

### G) ROLES & ACCOUNTABILITY

| Role | Actor | Responsibilities |
|------|-------|-----------------|
| **GUARDIAN OF CANON** | **Central** (governance arbiter — a *separate* actor per ADR-153, **NOT** Terminal A) | Owner of canon and orchestration rules for the write-gate. Validates every exchange against Sync-Protocol and write-gate. Rejects violations (force-push, main-checkout work, self-push/merge, absent sync block). Maintains ACTION-LEDGER as write-gate arbiter. Decides by BEST-DECISION principle after audit. |
| **Executor + concurrency arbiter** | **Factory** (= Terminal A / LEFT, Claude Code) | Produces code and verifies quality under Central's canon arbitration. NEVER pushes / merges / modifies `settings.json`. Synchronises via Sync-Protocol. Returns BEST-SOLUTION REPORT. **Separately** — per **ADR-154** — the Factory is the single arbiter of shared-space *concurrency* boundaries (IL / branch / ledger / worktree); that is a **different scope** from Central's canon/write-gate authority and does not conflict (see Scope Separation note). |
| **Sole remote-write window** | Operator | Only party that executes push/merge/merge-sequence to remote. Applies prepared artefacts (settings.json diff, hook install commands) as supplied by factory. |
| **Spec projects** | Terminal B (TRADING-001, RIGHT) | Operates under the same Sync-Protocol and write-gate as the Factory; same prohibitions apply. |

Accountability chain: Factory (Terminal A) → **Central** (canon guardian) → Operator (remote write).
No actor may skip a link. An exchange that bypasses **Central** arbitration is void.

> **Scope Separation (ADR-153 / ADR-154 reconciliation — no amendment to either).** Two *distinct*
> arbiter roles coexist without conflict: **(1)** the Factory (Terminal A / LEFT) is the **shared-space
> concurrency arbiter** — IL numbering, branch namespace, ledger, worktree isolation — per **ADR-154**
> (unchanged); **(2)** **Central** is the **canon / write-gate authority** over the Factory per this ADR.
> ADR-154's "factory = single arbiter" is scoped to *concurrency boundaries*, not to canon/write-gate
> governance; this ADR adds the latter and assigns it to Central. Because the scopes differ, ADR-154 is
> **referenced, not amended**. Naming follows ADR-153 (A = Factory = LEFT; Central = separate arbiter;
> B = TRADING-001 = RIGHT) — the retained "Right Terminal" behavioural alias of the Orchestrating
> Terminal is NOT topological Terminal B.

### H) TRI-PARTY SYNC — TERMINAL B

*Added: 2026-07-05 | Source: ADR-160 addendum (agent/factory/adr158b)*

The bilateral Central↔Factory protocol of §F/§G is extended to a **trilateral** loop:
**Central ↔ Factory (Terminal A) ↔ Terminal B**, with **Central the mandatory hub** of both axes
(Central↔Factory and Central↔TRADING-001). Terminal B (spec-project lane — novelty scouting,
`agent/specproj/*`) enters the same Sync-Protocol and Write-Gate with no exceptions.

#### H-1: Terminal B — Sync-Protocol (mandatory CONTEXT block)

B MUST send a CONTEXT block to **Central** in two mandatory events:

**Event 1 — specproj start** (new branch opened):
```
CONTEXT (B→Central):
  direction:         B→Central
  event:             specproj_start
  specproj_id:       <e.g. sp04>
  branch:            agent/specproj/<id>/<slug>
  target_files:      <files / repos B will write to>
  novelty_area:      <brief summary of what B is hunting>
  action_ledger_ref: <timestamp of PENDING row already written to ACTION-LEDGER>
```

**Event 2 — novelty finding handoff** (B→Central/Factory):
```
CONTEXT (B→Central):
  direction:         B→Central
  event:             novelty_found
  specproj_id:       <e.g. sp04>
  novelty_id:        <NOVELTY-COLLECTION-REGISTER.md id>
  artifact:          <PR number or branch>
  action_ledger_ref: <timestamp of PENDING row>
```

An exchange from B **without** a CONTEXT block is invalid — Central MUST reject it.
A/Factory response MUST include a BEST-SOLUTION REPORT (§F).

#### H-2: Terminal B — Write-Gate (same constraints as Factory)

| Constraint | Rule |
|-----------|------|
| Branch namespace | `agent/specproj/<id>/<slug>` (ADR-060) — G-5 enforced by pre-push |
| IL shard | Every PR requires a shard (see `ledger/SHARD-WORKFLOW.md`) |
| Pre-push guards | G-1..G-5+ mandatory in B's circuit (same `.githooks/pre-push`) |
| Rebase discipline | `git rebase origin/main` BEFORE every push |
| Force policy | ONLY `--force-with-lease`; `+HEAD:` refspec is **FORBIDDEN** |
| Merge | Operator only — B MUST NOT self-merge via `gh pr merge` |
| Settings | B MUST NOT touch `~/.claude/settings.json` |

#### H-3: Novelty Visibility — ACTION-LEDGER integration (B→Central direction)

Every novelty finding MUST produce two artefacts:

1. **NOVELTY-COLLECTION-REGISTER.md entry** — permanent discovery record
2. **ACTION-LEDGER row** (direction=B→Central) — real-time signal to Central

This eliminates the asymmetric blind spot: Central sees B's activity in
ACTION-LEDGER without waiting for a PR. Symmetric with Factory's push/merge duty.

B→Central row format (two rows per event — action + sync-context):
```
| <TIMESTAMP> | TERMINAL-B | NOVELTY  | <novelty-id>: <description> | banxe-architecture | PENDING  |
| <TIMESTAMP> | TERMINAL-B | SYNC-CTX | direction=B→Central | event=novelty_found | specproj=<id> | novelty=<id> | artifact=PR-NNN | ledger_ref=<PENDING ts> |
```

#### H-4: Single-Writer Lock — shared-file coordination

Before writing any shared file (governance/*.md, INSTRUCTION-LEDGER.md, any ADR,
NOVELTY-COLLECTION-REGISTER.md), the writing terminal MUST post a LOCK entry:

```
| <TIMESTAMP> | <ACTOR> | LOCK | file=<repo-relative path> | holder=<ACTOR> | status=HELD     |
```

On completion (success or abort), append a RELEASE row (never edit HELD row — I-24):
```
| <TIMESTAMP> | <ACTOR> | LOCK | file=<repo-relative path> | holder=<ACTOR> | status=RELEASED |
```

Rules:
- Any terminal seeing `status=HELD` for a needed file → write `WAIT` row; do NOT modify the file
- **Arbiter**: Factory resolves disputes; decision appended to ACTION-LEDGER
- Scope: shared governance files only; own-branch private files do not need a lock
- This prevents the parallel-edit collision that produced the rebase conflict in
  `.githooks/pre-push` (2026-07-04) — the incident from which ADR-160 was born

#### H-5: Guardian of Canon extends to Terminal B

Central (§G — Guardian of Canon) validates ALL exchanges involving B:
- B's CONTEXT blocks checked against §H-1 format
- B's PRs checked for: IL shard ✓, rebase on main ✓, no `+HEAD:` ✓, ACTION-LEDGER PENDING row ✓
- B's ACTION-LEDGER rows checked for direction=B→Central correctness

An exchange that bypasses Central arbitration — from B or Factory — is void.

#### H-6: First registered B-entry — PR #1017 (retroactive registration)

PR #1017 (`agent/specproj/sp04/adr-ba-novelty-pipeline`, ADR-159 novelty-pipeline)
is retroactively registered as the first Terminal B entry in ACTION-LEDGER.
**Status at addendum date (2026-07-05):** needs `git rebase origin/main` —
INSTRUCTION-LEDGER.md and IL-SEQUENCE.json conflict with ADR-158 merge
(squash-merged 2026-07-04T22:28:08Z, PR #1018). Terminal B rebase procedure
supplied in Appendix D of this addendum.

See ACTION-LEDGER row: `2026-07-05T00:00:00Z | TERMINAL-B | NOVELTY | sp04:ADR-159`.

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

---

## Appendix D — Terminal B post-merge rebase procedure (PR #1017)

After ADR-158 (PR #1018, squash-merged 2026-07-04T22:28:08Z), PR #1017
(`agent/specproj/sp04/adr-ba-novelty-pipeline`) has a merge conflict in
`INSTRUCTION-LEDGER.md` and `ledger/IL-SEQUENCE.json`. Terminal B MUST execute
the following from a worktree (ADR-120):

```bash
# 1. Open a worktree for B's branch (ADR-120 mandate)
git -C ~/banxe-architecture fetch origin
git -C ~/banxe-architecture worktree add ~/wt/sp04-adr159     agent/specproj/sp04/adr-ba-novelty-pipeline

cd ~/wt/sp04-adr159

# 2. Rebase onto current origin/main
git rebase origin/main

# 3. When conflict appears on INSTRUCTION-LEDGER.md / IL-SEQUENCE.json:
#    Take origin/main's version (generated artifact — never hand-edit)
git checkout origin/main -- INSTRUCTION-LEDGER.md ledger/IL-SEQUENCE.json

# 4. Rebuild generated artifacts to include B's own shard
python3 ledger/build_ledger.py
python3 ledger/build_ledger.py --check  # must exit 0

# 5. Stage and continue rebase
git add INSTRUCTION-LEDGER.md ledger/IL-SEQUENCE.json
git rebase --continue

# 6. Push (force-with-lease only — never +HEAD:)
ALLOW_STASH=1 git push origin agent/specproj/sp04/adr-ba-novelty-pipeline     --force-with-lease

# 7. Record OUTCOME in ACTION-LEDGER (append-only — I-24)
echo "| $(date -u +%FT%TZ) | TERMINAL-B | OUTCOME | sp04:ADR-159 rebase on post-#1018 main | banxe-architecture | DONE |"     >> ~/banxe-architecture/governance/ACTION-LEDGER.md
```

Post-rebase CI checks that MUST pass before merge:
- `guardian-ledger-shards` — verifies shard + generated ledger sync
- `ledger-build` — verifies `build_ledger.py --check` exits 0
- pre-push guards G-1..G-5+ (ADR-158/ADR-160, `.TERMINAL-ROLE=TERMINAL-B` required)
