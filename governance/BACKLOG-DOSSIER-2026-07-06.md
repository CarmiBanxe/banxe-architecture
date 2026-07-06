# BACKLOG DOSSIER — 2026-07-06 (Terminal-B sp27)

**Source:** operator-directed, Terminal-B session sp27 (agent/specproj/sp27/ratify-bestdec-scope-and-backlog).
**Purpose:** canonicalise every unclosed negative-tail item as a BACKLOG entry via the mandatory
dossier → roadmap → script → execution chain. Additive to — never supersedes — ADR-159 (B→A
pipeline), ADR-161 (intake SSOT-persistence), ADR-102 (reference-not-restate), the SYNC-CANON
(ADR-163), and the I-01..I-28 invariants.

> **Status contract.** Every item lands here as `OPEN` (BACKLOG). Transitions to `PLANNED` are
> owned by Central (per §"Owner" column) and land in `docs/ROADMAP-MATRIX.md` via ACCEPT verdict
> of the best-decision adoption-audit gate (§3 of `docs/canon/BEST-DECISION-BOUNDARY.md`). No item
> is auto-adopted from BACKLOG to ROADMAP without a positive gate run.

## Canon-path (mandatory for every BACKLOG item)

```
DOSSIER (this file) → ROADMAP-anchor (docs/ROADMAP-MATRIX.md) → SCRIPT (future sprint task/agent) → EXECUTION (PR + gate)
```

Each item below declares its canon-path explicitly. Missing any step ⇒ item is not eligible for
sprint pickup.

## Items

### B1 — SSOT-retro: restore missing intake source-bodies

- **Description.** The full text of the OSS reviews (EMI-stack review, 120-solutions review) and
  BANXE concept versions v7–v9 was **not persisted** into `docs/sources/*` at intake time (pre
  ADR-161 enforcement). Only metadata / references / partial extracts survive. This violates
  ADR-161 §D-2 retroactively and blocks any future re-run of the adoption-audit gate on those
  items, because the gate reads from persisted SSOT (never from transient paste).
- **Owner.** Terminal-B (source retrieval + persist).
- **Canon-path.**
  1. Dossier: this entry.
  2. Roadmap-anchor: `docs/ROADMAP-MATRIX.md` §"BACKLOG appendix (sp27, 2026-07-06)" → B1.
  3. Script: future sprint task (Terminal-B) — retrieve source bodies from the operator's local
     archive / previous session transcripts, land as `docs/sources/oss-emi-stack-review-*.md`,
     `docs/sources/oss-120-solutions-review-*.md`, `docs/sources/banxe-concept-v{7,8,9}-*.md`.
  4. Execution: draft PR (single, sp<N>) with the persisted source files + SHA-256 provenance
     block, HITL-merged.
- **Status.** OPEN.
- **Next-action.** Terminal-B files sp<N> shard `sp<N>-ssot-retro-oss-reviews-and-concept-v7-v9`
  with the persisted files + provenance block; audit-gate re-runs against the restored SSOT.

### B2 — CI gate: "no SSOT-persist ⇒ PR fail" (ADR-161 hard enforcement)

- **Description.** ADR-161 mandates SSOT-persistence for every intake, but the current enforcement
  is documentary. B1 demonstrates the failure mode empirically (bodies missing). Required: a CI
  gate that inspects any PR touching intake / adoption / roadmap paths and **fails the PR** if the
  persisted SSOT file(s) named in the shard are missing, empty, or lack the provenance block.
- **Owner.** Terminal-B (spec) + Software Factory (implementation).
- **Canon-path.**
  1. Dossier: this entry.
  2. Roadmap-anchor: `docs/ROADMAP-MATRIX.md` §"BACKLOG appendix (sp27, 2026-07-06)" → B2.
  3. Script: future sprint task (Central-planned, Software-Factory-authored) — new Guardian check
     `guardian-ssot-persist`; workflow `.github/workflows/guardian-ssot-persist.yml`; spec doc
     `docs/guardian/guardian-ssot-persist-gate.md`.
  4. Execution: draft PR through the factory chain; ADR-102 Duplication Audit attached; HITL merge.
- **Status.** OPEN.
- **Next-action.** Central runs adoption-audit; on ACCEPT queue a factory sprint that authors the
  Guardian check + workflow + spec doc; wire it into required PR checks on `main`.

### B3 — Watcher hand-off: 41 findings from #1059 not yet propagated

- **Description.** PR #1059 landed the watcher / auto-hand-off mechanism (ADR-159 §D-3), but the
  41 pending findings identified in that PR have **not yet been emitted** as ROADMAP hand-off
  entries. The watcher daemon has not run the batch, and no manual PR has drained the queue.
- **Owner.** Terminal-B (monitor watcher daemon + emit hand-off PR if daemon idle).
- **Canon-path.**
  1. Dossier: this entry.
  2. Roadmap-anchor: `docs/ROADMAP-MATRIX.md` §"BACKLOG appendix (sp27, 2026-07-06)" → B3.
  3. Script: existing watcher daemon (`novelty-handoff` v2.2) — if running, no new script needed;
     if idle, Terminal-B files a fallback sprint shard that emits the 41 hand-off blocks manually.
  4. Execution: single hand-off PR (draft) appending `<!-- novelty-handoff v2.2: … -->` blocks per
     the pattern already visible in the tail of `docs/ROADMAP-MATRIX.md`; HITL merge.
- **Status.** OPEN.
- **Next-action.** Terminal-B checks watcher daemon status; if the batch has not drained within
  the operator-defined SLA (config-as-data), file the fallback sprint shard.

### B4 — Factory best-decision engine PR #1070 — resolution (close/rework)

- **Description.** Factory-authored PR #1070 (`docs(canon): BANXE-BEST-DECISION-AND-ENGINE-
  PRINCIPLES.md — best-decision math → engine + 24/7 ops [prepare-only]`) is open and in review /
  resolution. It must either be closed (superseded by BEST-DECISION-BOUNDARY.md + ADR-162 + this
  sp27 ratification) or reworked to fit strictly under the ratified variant-2 scope — no ADR-102
  restatement of the SSOT.
- **Owner.** Software Factory (rework or close) + Central (decision).
- **Canon-path.**
  1. Dossier: this entry.
  2. Roadmap-anchor: `docs/ROADMAP-MATRIX.md` §"BACKLOG appendix (sp27, 2026-07-06)" → B4.
  3. Script: existing factory sprint pipeline; comment on #1070 with resolution outcome.
  4. Execution: close #1070 as superseded, or push a rework commit and re-request review; HITL
     merge if rework path chosen.
- **Status.** OPEN.
- **Next-action.** Central files the resolution decision on #1070 (close vs rework) referencing
  this sp27 ratification + ADR-102.

### B5 — 17 SOUL-less passports: author SOULs

- **Description.** 17 agent passports currently lack a governor SOUL.md file. Passport-SOUL
  coupling is required for compliance boundary enforcement (BUG-001 MetaClo vs runtime, agents.md
  §"HITL Confidence Thresholds"). Prior cohort landings (cohorts 10, 11 — commits 8d2a462,
  6bdd7b5) resolved earlier tranches; the remaining 17 are the outstanding balance.
- **Owner.** Software Factory (SOUL authoring) + Central (approval).
- **Canon-path.**
  1. Dossier: this entry.
  2. Roadmap-anchor: `docs/ROADMAP-MATRIX.md` §"BACKLOG appendix (sp27, 2026-07-06)" → B5.
  3. Script: future factory sprint — enumerate the 17 SOUL-less passports (Central-supplied list),
     author `souls/<passport-id>/SOUL.md` per governor-SOUL schema, all as effectively PROPOSED
     (not activated) until each passport's HITL sign-off.
  4. Execution: cohort-batched draft PRs (2–4 SOULs per PR to preserve reviewability); HITL merge
     each cohort.
- **Status.** OPEN.
- **Next-action.** Central publishes the list of 17 SOUL-less passports; factory files the first
  cohort sprint shard.

### B6 — ENGINE SRC MISSING: `~/banxe-dev/emi-banxe-engine.md` absent

- **Description.** The engine source document referenced by Line B (`~/banxe-dev/emi-banxe-engine.md`)
  is **not present** on the operator's local filesystem. Line B (engine-side scoping and
  productisation work) is **blocked** without the original. This is not a persist-fix (no
  previously-visible content to restore); it requires the operator to provide the original.
- **Owner.** **Operator** (source of truth) + Central (intake + gate once received).
- **Canon-path.**
  1. Dossier: this entry.
  2. Roadmap-anchor: `docs/ROADMAP-MATRIX.md` §"BACKLOG appendix (sp27, 2026-07-06)" → B6.
  3. Script: operator supplies the file via any authorised channel; Terminal-B intake sprint
     persists as `docs/sources/emi-banxe-engine-<date>.md` per ADR-161.
  4. Execution: draft PR (sp<N>) with persisted engine SSOT + provenance block; HITL merge; Line B
     is unblocked; adoption-audit gate can then run against the engine content.
- **Status.** OPEN — **BLOCKED on operator input.**
- **Next-action.** Central raises the block explicitly in `governance/COORDINATION-NOTES.md`; when
  the operator supplies the file, Terminal-B files the intake sprint shard.

### B7 — Adoption-audit for 88 findings via best-decision-gate

- **Description.** 88 outstanding findings (queued through prior intake sessions, semantic-scored,
  currently pre-gate) require Central to run the best-decision adoption-audit (§3 of
  `docs/canon/BEST-DECISION-BOUNDARY.md`) with a terminal outcome per §4 (ACCEPT / REJECT-AS-NOT-
  WORTH / DEFER). Each outcome MUST be logged with the multi-criteria rationale.
- **Owner.** Central (gate runner) + Terminal-B (queue custody).
- **Canon-path.**
  1. Dossier: this entry.
  2. Roadmap-anchor: `docs/ROADMAP-MATRIX.md` §"BACKLOG appendix (sp27, 2026-07-06)" → B7.
  3. Script: existing gate implementation (`tests/best-decision/validator.py` for evidence, plus
     Central's manual multi-criteria audit note per finding); Central produces one
     adoption-audit-notes file per batch under `governance/adoption-audit/<date>-batch<N>.md`.
  4. Execution: batch-sized draft PRs (Central-batched, HITL merge); ROADMAP-MATRIX updated per
     ACCEPT verdict, QUEUE ack `not-worth`/`defer` on REJECT/DEFER.
- **Status.** OPEN.
- **Next-action.** Central files the first adoption-audit batch shard (Terminal-B publishes the
  queue snapshot; Central runs the multi-criteria audit).

### B8 — Ratify remaining directives (credit-gate, quiet-window)

- **Description.** Two operator-directive ratifications remain OPEN:
  - `B-EMI-CREDIT-GATE-001` — hard-block on any adoption that drifts into credit / lending scope
    (out-of-scope for BANXE EMI); currently referenced in `docs/canon/BEST-DECISION-BOUNDARY.md`
    §8 CASE-C but no formal ratification landed.
  - `B-QUIET-WINDOW-001` — merge quiet-window governance (part of SYNC-CANON ADR-163 lineage);
    referenced in prior sprints but not formally ratified.
- **Owner.** Central (formal ratification) + operator (final ack).
- **Canon-path.**
  1. Dossier: this entry.
  2. Roadmap-anchor: `docs/ROADMAP-MATRIX.md` §"BACKLOG appendix (sp27, 2026-07-06)" → B8.
  3. Script: future sprint per directive — Central drafts the ratification amendment to the
     relevant canon file (BEST-DECISION-BOUNDARY.md for credit-gate; SYNC-CANON.md for
     quiet-window); mirrors the sp27 pattern of this shard for structure.
  4. Execution: two sequential draft PRs (one per directive), HITL merge; also authors the
     follow-up ADR for §7 variant-2 per-role HITL envelope + config schema (as flagged in §7
     Anchors).
- **Status.** OPEN.
- **Next-action.** Central schedules the two ratification sprints; sp27 ratification (this shard)
  is the pattern template.

## Summary table

| Item | Title | Owner | Status | Blocked-by |
|------|-------|-------|--------|-----------|
| B1 | SSOT-retro OSS reviews + concept v7-v9 | Terminal-B | OPEN | — |
| B2 | CI gate: no SSOT-persist ⇒ PR fail | Terminal-B + Factory | OPEN | — |
| B3 | Watcher hand-off 41 findings | Terminal-B | OPEN | watcher daemon SLA |
| B4 | Factory best-decision engine PR #1070 resolution | Factory + Central | OPEN | — |
| B5 | 17 SOUL-less passports | Factory + Central | OPEN | Central passport list |
| B6 | ENGINE SRC MISSING (Line B blocked) | **Operator** + Central | OPEN — BLOCKED | operator supplies file |
| B7 | Adoption-audit 88 findings via best-decision-gate | Central | OPEN | — |
| B8 | Ratify remaining directives (credit-gate, quiet-window) | Central + operator | OPEN | — |

## Anchors (pointer only — ADR-102)

- `docs/canon/BEST-DECISION-BOUNDARY.md` — the ratified best-decision gate (§7 variant-2).
- `docs/adr/ADR-159-ba-novelty-auto-handoff-pipeline.md` — B→A pipeline that produces the queue.
- `docs/adr/ADR-161-intake-ssot-persistence.md` — SSOT-persistence precondition (drives B1 + B2).
- `docs/adr/ADR-162-best-decision-principle.md` — the formal principle statement referenced by the
  meaning correction (2026-07-06).
- `docs/adr/ADR-163-sync-canon.md` + `docs/canon/SYNC-CANON.md` — sync discipline (drives B8
  quiet-window).
- `docs/adr/ADR-102-no-smart-refactor-without-duplication-verification.md` — reference-not-restate
  rule applied throughout this dossier.
- `governance/COORDINATION-NOTES.md` — where B6 operator-block MUST surface.
- `governance/NOVELTY-HANDOFF-QUEUE.md` — queue custody for B3 + B7.
- `.claude/rules/agents.md` §"HITL Confidence Thresholds" (BUG-007) — runtime posture for B5 SOULs.
