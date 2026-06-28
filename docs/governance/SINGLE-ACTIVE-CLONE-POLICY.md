---
id: SINGLE-ACTIVE-CLONE-POLICY
title: Single active write-capable clone per machine per origin (extends ADR-120 worktree isolation)
status: PROPOSED
date: 2026-06-28
concept_only: false
relates:
  - "ADR-120 (per-session worktree isolation — this extends it from worktrees to CLONES)"
  - "parallel-session-isolation.md Rules 1–8 (cross-session leak / shared-checkout incidents)"
  - "ADR-143/143-A (single-writer central allocator — un-serialized write-path is the collision root)"
  - "ADR-117 (factory/project perimeter)"
il_anchor: IL-667
il_anchor_note: "Provisional per ADR-119 Rule 8 — minted by the central Redis allocator (ADR-143/143-A) over current origin/main. Frozen at rebase-before-merge."
scope: BANXE-factory-operational-policy
---

# Single active write-capable clone per machine per origin

> **DRAFT governance policy. PREPARE-ONLY.** No clone/branch/worktree deleted; no merge; no install.
> Operator (Moriel) decides remediation after reviewing the rescue + classification evidence.

## 1. Problem (evidence-backed)

Two clones of the **same origin** (`CarmiBanxe/banxe-architecture`) coexist on this machine:
- **clone1** `~/banxe-architecture` (SSH) — the **ACTIVE factory contour** (on `main`, 18 worktrees).
- **clone2** `~/banxe/banxe-architecture` (HTTPS) — a **stale, write-capable** secondary (on a legacy
  branch).

A second **un-synced, write-capable contour on the same origin** is the **same root cause** as the
shared-worktree dirty-state and concurrent-session incidents: it is an **un-serialized write path** that
produces base-drift, DIRTY PRs, and IL/merge collisions (the class fixed by ADR-143/143-A single-writer
allocator + `main-merge-serialize` + ADR-120 worktree isolation). Worktree isolation (ADR-120) solved
intra-clone races; it does **not** cover a **second clone**. This policy closes that gap.

**Audited scale (read-only, this session):** clone2 holds **24 LOCAL-ONLY ahead branches** (not on
origin) — potential unsaved work, the same risk class as a dirty worktree but at **~24×**. All were
rescued reversibly (bundle + per-branch patches) and classified before any decision.

## 2. Policy

1. **One ACTIVE write-capable clone per machine per origin.** Exactly one clone is the writer (clone1).
   Any additional clone of the same origin is **read-only or archived** — no commits, no branch creation,
   no push.
2. **Secondary clones are read-only.** Use them only for read-only inspection. A secondary that must do
   work is first **reconciled into the active clone** (rescue → classify → re-apply via the normal
   factory flow), then demoted to read-only or removed by the **operator** (never by the factory).
3. **No second write path to the same origin.** This generalises ADR-120 (per-session worktree isolation)
   from *worktrees inside one clone* to *clones on one machine*: the writer is single, everything else
   reads.
4. **Rescue-before-remediation (mandatory, reversible).** Before any cleanup of a secondary clone, ALL
   its local branches are backed up reversibly — a full `git bundle --branches` + per-branch
   `format-patch` — and every LOCAL-ONLY ahead branch is **classified** (PR-merged / files-identical →
   SAFE; otherwise UNIQUE/REVIEW, **fail-closed**). **No branch is deleted until the operator reviews the
   classification.**
5. **Factory never deletes.** Branch/clone/worktree deletion is an **operator** action. The factory only
   rescues, classifies, and proposes.

## 3. Evidence (this session — operator-local, NOT committed)

- **Rescue bundle + patches:** `~/banxe-architecture/.rescue/clone2-20260628T044333/`
  (`clone2-all-local-branches.bundle` [verified] + 24 per-branch `.patch` + `MANIFEST.txt`). Local backup
  only — **not** added to git.
- **Classification:** `…/CLASSIFICATION.md` — **14 SAFE-TO-DELETE** (PR-MERGED or files-identical-in-main)
  / **10 UNIQUE-REVIEW** (no merged PR, content differs → potential unsaved work, operator must review
  before any deletion). Restore any branch via `git bundle unbundle` or `git am < <branch>.patch`.

## 4. Remediation path (operator-decided; NOT executed here)

1. Operator reviews `CLASSIFICATION.md`.
2. For **UNIQUE-REVIEW** branches: reconcile genuine work into the active clone through the normal factory
   flow (hard-reset recipe on a fresh worktree off `origin/main`, re-mint IL, draft PR) **before** any
   deletion.
3. For **SAFE-TO-DELETE** branches: operator may prune in the **secondary** clone (writer untouched).
4. Demote clone2 to **read-only** (or archive) per §2.

## 5. Open [UNKNOWN] for operator

- Whether clone2 should be **archived** (kept read-only) or **removed** after reconciliation — operator call.
- Whether any UNIQUE-REVIEW branch (e.g. `neuronext-landing`, `implstate-landing`, `m28e-append`, the
  `pr82x` locals) contains intended-but-unpushed work — requires operator content review (not inferable
  read-only with certainty across squash-merges).

## Anchors
- ADR-120 (worktree isolation — extended here to clones), `parallel-session-isolation.md` (Rules 1–8),
  ADR-143/143-A (single-writer allocator), ADR-117 (perimeter). Rescue/classification evidence under
  `~/banxe-architecture/.rescue/clone2-20260628T044333/` (operator-local; not committed). PREPARE-ONLY;
  no deletion; operator HITL.
