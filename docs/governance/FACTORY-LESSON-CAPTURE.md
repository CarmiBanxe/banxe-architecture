# Factory Lesson-Capture — safe, factory-native self-correction

> **Status:** governance mechanism + lesson register (non-canonical record). **Date:** 2026-07-02.
> **Owner-terminal: A (factory).** **Pointer-first and additive (ADR-102).**
>
> This is the **factory-native, safe-by-design** alternative to an external self-correcting harness, selected
> per the Hyperbrowser/harness evaluation (#949, IL-797). It reproduces the *value* of self-correction — the
> agent records its own failures (wrong paths, missing scripts, false assumptions) so it does not repeat them —
> **without the external-adoption risks** that evaluation named. **It installs nothing, downloads no external
> code, touches no perimeter or tool, and NEVER auto-mutates the canonical `CLAUDE.md`.** This document is a
> **non-canonical record**: capturing a lesson here changes no canon; promoting a lesson *into* canon
> (`CLAUDE.md` / an ADR / a rule) is a **separate operator-ratify (HITL) step**.

---

## 1. Purpose
Reproduce the value of a self-correcting harness (automated lesson-capture) **without** the risks the #949
evaluation assessed for the external `/harness` plugin: no dual-use browser automation, no untrusted external
code in the trust boundary, **no auto-`CLAUDE.md` mutation**, no new supply-chain surface. The mechanism is
entirely inside the repo, authored, and gated exactly like any other governance change.

## 2. Mechanism — propose → operator-ratify
- **Lessons are recorded in THIS non-canonical file** (the register in §3), **never written into `CLAUDE.md`
  directly.** `CLAUDE.md` remains **authored governance** (Config-over-Hardcoding, CLAUDE.md §10) — never a
  machine-generated artifact.
- **Each lesson is a structured entry:** **Symptom** (what went wrong) · **Root cause** · **Corrective** (how
  not to repeat it) · **Ref** (the IL/PR where it surfaced).
- **Promotion of a lesson into canon** (a `CLAUDE.md` rule, an ADR, a `.claude/rules/*` entry) is a **separate,
  explicit operator-ratify step** — human-in-the-loop, prepare-only Draft PR, never automatic. Capture
  *proposes*; the operator *ratifies*. This mirrors the prepare-only / HITL discipline used throughout the
  factory.
- **Adding an entry to the register** is itself a normal prepare-only Draft PR (doc + paired shard), passing
  `quality-gate.sh` and invariants like any change — no auto-commit, no bypass.

## 3. Lesson register (seeded from this session — facts, already observed)
Each entry is a real failure/correction from the current session; these are the register's first records.

| # | Symptom | Root cause | Corrective | Ref |
|---|---|---|---|---|
| L-01 | "Re-mint" produced doc-only PRs (no shard, no ledger regen) → `guardian-ledger` fail | Operator `rebase_one` / `make il-mint` dropped the shard (`grep -v ledger`) and never ran `build_ledger` | Factory drives re-mint via **real `python ledger/build_ledger.py`**; never `grep -v ledger`; shard is always paired | #845, #847 |
| L-02 | Audit run in the wrong repo (MetaClaw / banxe-architecture confusion) | No repo-root check before repo-scoped commands | Run **`git rev-parse --show-toplevel`** (or `git -C <repo>`) before any repo operation | MetaClaw wrong-dir incident |
| L-03 | `gh pr merge --auto` refused: "still a draft" | Draft PR was never marked ready before merge | Sequence **`gh pr ready && gh pr merge`** (ready precedes merge) | #887 |
| L-04 | `--auto` merge stalled at CLEAN (auto-merge not armed after a serialize error) | `main-merge-serialize` GraphQL error aborted the whole `--auto` call | At **behind-0 + CLEAN, a direct `gh pr merge --squash` lands immediately**; `--auto` is for riding out a not-yet-green window | #934, #936, #942 |
| L-05 | `reset --hard` wiped the new shard mid-rebase | The shard was already `git add`ed; `reset --hard` clears **staged-new** files (untracked survive) | **Recreate the shard AFTER `reset --hard`**, then rebuild the ledger | #933 |
| L-06 | Same content re-minted repeatedly on wave-drift | Treating a duplicate IL as a stop-barrier / question | **A duplicate IL is a rebase signal, not a question** — rebase onto `origin/main` + regenerate autonomously (ADR-119) | ADR-119 Rule 8 |
| L-07 | Merged branches mis-labelled "unmerged, holds unique work" | `merge-base --is-ancestor` is wrong under **squash-merge** (squashed content lands under a new SHA) | Classify squash-aware: **matched a merged-PR head OR `git cherry origin/main <br>` == 0 unlanded** ⇒ landed | branch-cleanup sweep |
| L-08 | "Auto will land at CLEAN" assumed, but PR sat un-merged | Read a stale counter, not the live merge state; `--auto` had silently not armed | On a pending merge, **check `autoMergeRequest` + `mergeStateStatus`**, not just behind/ahead | #934, #942 |
| L-09 | Pasted multi-line Cyrillic/paren task mangled into `command not found` in bash | Governance task text pasted into a shell instead of the agent | **Route by artifact type** — `[SHELL]` for read-only shell, `[CLAUDE CODE]` for state-changing prompts; task text is not a shell command | heredoc-in-bash incidents |

**Registering a new lesson:** append a row with Symptom / Root cause / Corrective / Ref via a prepare-only
Draft PR (this file + a paired shard). Do **not** edit `CLAUDE.md`.

## 4. Boundaries
- **No auto-commit, no auto-mutation of canon.** This file is non-canonical; `CLAUDE.md` is never written by
  this mechanism.
- **No external code executed or downloaded.** No plugin, no third-party `SKILL.md`, no binary. No perimeter
  or tool touched (ADR-117).
- **No gate bypass.** Every register update and every canon-promotion passes `quality-gate.sh` + invariants
  I-01..I-28 + the ADR-135 gate where a skill/rule is involved.
- **Promotion to canon = operator HITL, always.** Capture proposes; the operator ratifies. Nothing here
  auto-promotes a lesson into `CLAUDE.md`, an ADR, or a rule.

## 5. What this document did NOT do
Auto-mutated no `CLAUDE.md`. Installed/downloaded no external code. Created no `.claude/skills` entry. Touched
no perimeter or tool. Promoted nothing into canon (each promotion is a separate operator-ratified step). This
is a **non-canonical governance record + mechanism**, prepare-only, authored governance-side.

## Anchors
`docs/governance/ADR-EVAL-HYPERBROWSER-HARNESS.md` (#949, IL-797 — the evaluation whose "factory-native
alternative" this realises, and whose risks it avoids) · the corrective runbook (#900 — the manual
lesson-capture precedent this systematises) · CLAUDE.md §9 (external adoption + HITL — avoided here by staying
internal) + §10 (Config-over-Hardcoding — why `CLAUDE.md` is not auto-generated) · `docs/adr/ADR-135-agent-skill-evolution-gate.md`
(canon-promotion gate) · `docs/governance/HARNESS-INTEGRATION-ASSESSMENT.md` (#948, IL-796 — the harness fact
record) · `.github/CODEOWNERS` (governance / `.claude/` code-owner protection) · ADR-102 (Duplication Audit —
restates none of the above). **Basis:** operator directive 2026-07-02 (choose by canon → factory-native
lesson-capture, the safe alternative to `/harness`). Register entries L-01..L-09 are facts observed in the
current session.
