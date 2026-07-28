# SYNC-CANON — mandatory synchronization discipline (operational)

> **Status:** PROPOSED (per ADR-163). Advisory-first enforcement. See ADR-163 for the decision record and the three battle-run lessons that motivate this canon.
> **Scope:** every side (factory / Left / A, Central, Terminal-B / Right / B) and every actor (Claude Code session, factory-dispatch, watcher, ledger-rebuild, per-session daemon) operating in `banxe-architecture` (evo1). Same discipline extends to `banxe-emi-stack` where sides interact.
> **Not a second source-of-truth.** SYNC-CANON references, does not restate: `.claude/rules/parallel-session-isolation.md` (Rules 1–8), ADR-060, ADR-119 Rule 8, ADR-120, `.github/workflows/main-serialize.yml`, `guardian-branch-naming`. Per ADR-102, one rule lives in one place.

---

## Five principles

### P-1 — SYNC-BEFORE-ACT

Every actor synchronizes to a fresh `origin/main` **before** reading state, taking action, or writing. Canonical state (register, queue, ledger index, SSOT tree) is read via `git fetch` + `git show origin/main:<path>` — not from a possibly-stale local working copy.

- **Class defect this closes:** stale-checkout read.
- **Instance evidence:** PR #1058 — watcher v2.1 sync-before-scan. Watcher tick executed from a stale local `HEAD`, missed 30 freshly-merged NEW findings, logged "nothing to do" while `main` had moved.
- **Applies to:** watchers, ledger-rebase helpers, factory-dispatch, Central adoption-audit, Terminal-B intake, per-session Claude Code before any `git add`.
- **Instance rules to obey:** `.claude/rules/parallel-session-isolation.md` Rule 1 (verify branch before stage), Rule 6 (worktree dirty state must be reported).

### P-2 — LEDGER-SERIALIZE

Ledger-writes (any change to `INSTRUCTION-LEDGER.md`, `ledger/IL-SEQUENCE.json`, `ledger/entries/`) are serialised. Rebase-before-merge is mandatory. Parallel ledger-PRs are announced through the Central coordination hub so peers HOLD rather than pile on.

- **Class defect this closes:** ledger churn / rebase-treadmill; IL-number collision.
- **Instance evidence:** `.github/workflows/main-serialize.yml` (IL-617, PR #833) — concurrency-group + base-drift guard; `governance/COORDINATION-NOTES.md` DIRECTIVE B-QUIET-WINDOW-001 (sp16, `19cf12c`) — Terminal-B requested factory HOLD ledger-writing PRs while treadmill was in flight; ADR-119 Rule 8 duplicate-IL incident (PRs #744/#749/#751) — root cause was un-serialised concurrent IL allocation.
- **Escalation floor:** **two consecutive rebase-churn cycles ⇒ STOP + escalate to operator** (quiet-window). Infinite rebase-loop is forbidden. This is a stop-barrier for the treadmill, not an autonomy grant.
- **Instance rules to obey:** ADR-119 Rule 8 (IL number merge-time freeze), `.claude/rules/parallel-session-isolation.md` Rule 4 (push uses `--force-with-lease`, never `--force`), Rule 5 (cross-session INSTRUCTION-LEDGER.md conflicts resolve as append-both).

### P-3 — BRANCH-NAME-VALID by construction

Any automated actor that mints a branch name — watcher, factory-dispatch, `scripts/bx-session.sh`, ledger-rebase helpers — MUST produce a name matching the ADR-060 pattern by construction of the mint code, not by post-hoc validation.

- **Pattern (ADR-060, mirrored in `bx-session.sh`):**
  `^agent/(central|right|factory|specproj)/[A-Za-z0-9]+/[a-z0-9._-]+$`
  Note: the `<id>` fragment is `[A-Za-z0-9]+` — **no dash**.
- **Class defect this closes:** automation mints a non-compliant name, PR/push fails at the gate, run is silently dropped.
- **Instance evidence:** PR #1061 — watcher v2.2 ADR-060-compliant branch name.
- **Fail-closed at mint-time.** If the automation cannot guarantee the pattern by construction, it MUST refuse to mint and escalate.
- **Instance rules to obey:** `guardian-branch-naming`; `scripts/install-hooks.sh` pre-push gate (Step 0 of every session per CLAUDE.md session-bootstrap).

### P-4 — TRI-PARTY SYNC-POINT

At the start of a technical work item (sprint task, intake, adoption-audit, canon-write), **factory (Left / A), Central, and Terminal-B (Right / B) agree on a baseline `origin/main` sha**. Central is the mandatory hub of the B↔Central↔A axis.

- **Recording:** implicit via the PR base ref for routine work; explicit `git rev-parse origin/main` in the work log for non-trivial coordination (parallel ledger-writes, canon changes touching multiple sides, adoption-audits spanning multiple findings).
- **Divergent baseline between sides = STOP** until re-sync. Not a "small drift to reconcile later".
- **Class defect this closes:** silent baseline drift between sides — factory writes against sha-N, Central reviews against sha-N+K, B's coordination note assumes sha-N+M.
- **Scope discipline:** P-4 applies to technical work items that touch shared canonical state (ledger, canon docs, ADRs, register, queue, SSOT tree). Independent read-only work is unaffected — do not use P-4 to justify a coordination-heavy pause on obviously-independent work.

### P-5 — SSOT-FIRST (pointer to ADR-161)

Intake persists the source body verbatim BEFORE any extraction / evaluation / write of derivative artefacts. SSOT-FIRST is the intake face of the general sync-first shape (persistence-before-derivation).

- **Defined by:** ADR-161 (intake SSOT-persistence). SYNC-CANON references, does not restate — per ADR-102.
- **Class defect this closes:** intake loses body → downstream artefacts reference a source that has no persistent representation.
- **Instance rules to obey:** `docs/sources/README.md`; ADR-161 §D-2 (mandatory Step 0: SSOT-persist BEFORE extraction).

---

### P-6 — DIALOGUE-SYNC (pointer to ADR-175)

- Extends P-1/P-4 from git/ledger state to the **two-terminal dialogue-loop** (conversational/session
  context), which P-1..P-5 do not cover. Amendment ratified 2026-07-28 (ADR-175, ACCEPTED).
- Marker (two layers): durable SSOT `docs/canon/sync/TWO-TERMINAL-SYNC-MARKER.md` (append-only, read via
  `git show origin/main:<path>`) + live anchor `~/.banxe/two-terminal-sync.json` (not merge-gated).
- Reconcile each turn; `self-stale` (any ⇒ STOP-and-reconcile): (a) git-stale, (b) dialogue-stale,
  (c) liveness-stale, (d) role-stale (TERMINAL-ROLE-IDENTITY-CANON). Full spec: ADR-175 + marker doc.

## Actor checklists (short form)

**Every Claude Code session (Step 0 of any technical work item):**

1. `bash scripts/install-hooks.sh` (branch-name pre-push gate — P-3).
2. `git fetch origin main` (P-1).
3. `git rev-parse origin/main` — record the baseline sha in the work log if the item is non-trivial (P-4).
4. If the item is intake — persist source to `docs/sources/` FIRST (P-5, ADR-161 §D-2).
5. If the item is a ledger-write — verify no active churn on `main` (P-2); if 2+ consecutive rebase-cycles happen → STOP + escalate.

**Every automated actor (watcher, factory-dispatch, ledger-rebuild, bx-session helpers):**

1. On tick / on invocation: `git fetch` + read canonical state via `git show origin/main:<path>` (P-1).
2. On branch mint: construct name matching ADR-060 pattern by code (P-3). Fail-closed if not guaranteed.
3. On ledger-write: pass through `main-serialize.yml` gate (P-2); if base-drift guard fires twice consecutively → STOP + escalate (no infinite loop).

**Central (bilateral hub):**

1. Sync baseline sha at the start of any coordination touch-point (P-4).
2. Broker HOLD directives via `governance/COORDINATION-NOTES.md` when P-2 escalation floor is hit.
3. Ratify SYNC-CANON updates (this canon is a proposal from Terminal-B; Central owns the axis).

**Terminal-B (Right / Orchestrating Terminal, spec-projects lane):**

1. All five principles apply.
2. On intake: P-5 (SSOT-persist) before extraction (ADR-161).
3. On adoption-audit: P-4 baseline agreement with Central before write (ADR-162).
4. Best-decision canon continues to apply (CLAUDE.md §12) — SYNC-CANON is coordination discipline, does not change the ambiguity rule.

---

## What SYNC-CANON is not

- **Not a new mechanism.** It is a naming + framing layer over existing gates.
- **Not a runtime autonomy grant.** I-27 fail-closed is unchanged. Every merge and every state-change remains operator-gated per `safety-rules.md`.
- **Not a replacement for `.claude/rules/parallel-session-isolation.md`.** Rules 1–8 remain the operational rulebook for cross-session git hygiene. SYNC-CANON references them.
- **Not a stop-barrier by itself.** The stop-barriers are: `safety-rules.md`, CLAUDE.md §1 / §11, ADR-121 (destructive-action protection), ADR-119 Rule 8 (IL merge-time freeze), and the P-2 escalation floor (two consecutive rebase-churn cycles).

---

## Anchors

- `docs/adr/ADR-163-sync-canon.md` — the decision record.
- `.claude/rules/parallel-session-isolation.md` — Rules 1–8.
- `.github/workflows/main-serialize.yml` — IL-617 base-drift guard + concurrency-group.
- `scripts/bx-session.sh` — ADR-120 per-session worktree launcher (mirrors ADR-060 pattern).
- `scripts/install-hooks.sh` — pre-push branch-name gate (P-3 machinery).
- `governance/COORDINATION-NOTES.md` — Central coordination hub (P-4 recording surface; P-2 quiet-window directives).
- `docs/canon/BEST-DECISION-BOUNDARY.md` + ADR-162 — sibling discipline (adoption-audit).
- `docs/sources/README.md` + ADR-161 — sibling discipline (intake SSOT-persist; P-5 face).
- PRs #1058 (watcher v2.1), #1061 (watcher v2.2), sp16 quiet-window (`19cf12c`) — evidence base.
