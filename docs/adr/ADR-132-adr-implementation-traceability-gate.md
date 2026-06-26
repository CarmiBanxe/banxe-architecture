---
id: ADR-132
title: ADR↔implementation & souls↔SKILLS-MATRIX traceability gate
status: ACCEPTED
date: 2026-06-25
accepted: 2026-06-25
supersedes: []
refs:
  - "scripts/adr-traceability-check.sh (enforcement script — the implementation of this ADR)"
  - ".github/workflows/guardian.yml job guardian-traceability (informational CI gate)"
relates:
  - "ADR-130 / PR #795 (IN-FLIGHT draft — agents/_template/SOUL.md generic persona; COMPLEMENTARY: persona vs traceability)"
  - "ADR-131 / PR #796 (IN-FLIGHT draft — agents/souls/_TEMPLATE.md souls format standard; COMPLEMENTARY: format vs traceability)"
  - "ADR-117 (perimeter — gate runs factory-side, informational)"
  - "ADR-056 (ledger/IL coupling — traceability of governance↔ledger)"
  - "ADR-128 (HITL — gate is informational, never auto-blocks a human decision)"
  - "ADR-102 (no-duplication — Duplication Audit basis; ADR-052/080 adjacent, not duplicate)"
il_anchor: IL-552
il_anchor_note: "Provisional per ADR-119 Rule 8 — frozen to max+1 over origin/main at rebase-before-merge. Real IL-SEQUENCE max on main = 550 (owned by #797 handoff); in-flight #795/#796 also claim IL-550 (draft, not on main) — this PR takes IL-552 to avoid worsening that collision."
scope: BANXE-factory-only
concept_only: true
complementary:
  - "ADR-130 (#795): persona LAYER — what an agent IS"
  - "ADR-131 (#796): souls FORMAT — how a soul is STRUCTURED"
  - "ADR-132 (this): TRACEABILITY — that an ADR/soul is LINKED to its implementation"
---

# ADR-132 — ADR↔implementation & souls↔SKILLS-MATRIX traceability gate

## Context

There is **no machine-checked link** between governance and implementation. Two concrete gaps measured
on the current main:

- **souls ↔ SKILLS-MATRIX:** `agents/souls/*.md` = **19**, references in `docs/SKILLS-MATRIX.md` = **0**.
  A soul can exist with no skill/matrix entry — no signal.
- **ADR ↔ code:** an ACCEPTED ADR that carries an implementation can ship with an **empty `refs:`** —
  nothing ties the decision to the code/skill that realizes it.

This ADR adds a **traceability gate** closing both, as an informational CI job until stabilized. It is
**complementary, not a duplicate** of the in-flight persona/format work (ADR-130/#795, ADR-131/#796):
those define *what an agent is* and *how a soul is structured*; this defines *that a decision/soul is
linked to its implementation*. ADR-102 dup-check is clean (adjacent ADR-052/080 are not duplicates).

Concept-only: **no runtime code, no Hermes runner** (24/7 / auto-skills = separate ADR, ADR-124
precedent); no mass edit of existing ADRs/souls/SKILLS-MATRIX (the 19 souls↔matrix sync is a separate
follow-up IL).

## Decision

1. **Traceability rule (canon):** every **ACCEPTED ADR that carries an implementation** (i.e. not
   `concept_only`) MUST have a **non-empty `refs:`** pointing at its code/skill; every
   `agents/souls/*.md` MUST be **referenced in `docs/SKILLS-MATRIX.md`**.
2. **Enforcement = a new CI gate**, `scripts/adr-traceability-check.sh` (read-only), surfaced as the
   `guardian-traceability` workflow job. It is **subordinate to ADR-117 (perimeter) / ADR-056 (ledger
   coupling) / ADR-128 (HITL)** — informational, it never auto-blocks a human decision.
3. **Scope = new/changed tracked paths.** The gate HARD-fails (exit 1) only on souls/ADRs **added or
   changed** in a PR. The **historical debt** (19 souls not yet in SKILLS-MATRIX; older ADRs with empty
   refs) is reported as **WARN, never hard-failing** — its remediation is a separate follow-up IL.
4. **Informational / non-required until stabilized.** The `guardian-traceability` job runs
   `continue-on-error: true` and is not a required check; promotion to required is a later operator
   decision once the historical debt is cleared.

## Duplication Audit (ADR-102)

1. **Repo-wide search** — no prior traceability/SKILLS-MATRIX-gate ADR; `scripts/adr-traceability-check.sh`
   and a `guardian-traceability` job do **not** exist. Adjacent ADR-052/080 (ledger/coupling-area) are
   **not** duplicates — they don't define an ADR↔impl or souls↔matrix machine gate.
2. **In-flight complementary set (NOT duplicates):** ADR-130/#795 (persona layer, `agents/_template/SOUL.md`)
   and ADR-131/#796 (souls format, `agents/souls/_TEMPLATE.md`) are about *format/persona*; this ADR-132 is
   about *linkage/traceability*. Different files, different purpose — explicitly cross-linked in `refs:`/
   `relates:` with a `complementary:` note.
3. **No hidden dependencies / no mass edit.** The gate is additive (new script + new informational job);
   no existing ADR, soul, or SKILLS-MATRIX row is edited. #795/#796 and their files are untouched.
4. **Decision per match:** new script + workflow job + ADR-132 → **ADD**; existing files → **KEEP**.
   No delete/merge/rewrite.

## Consequences

- Future PRs that add a soul or an implementing ADR get an immediate traceability signal; the gate is
  green today (historical debt is WARN-only) and tightens as debt is paid down.
- The persona/format/traceability triad (ADR-130/131/132) is explicitly cross-linked, so a reviewer
  sees the boundary instead of suspecting duplication.
- **No runtime change**; no Hermes runner; #795/#796 and the 19 souls are byte-for-byte untouched.

## Operator note (HITL — in-flight triple)

Three overlapping draft PRs now exist: **#795 (ADR-130)**, **#796 (ADR-131)**, **this (ADR-132)**.
**IL-550 is already double-claimed by #795 and #796** (both draft) — at sequential merge the second will
fail ledger append-only/coupling. This PR takes **IL-552** and `il_ts` > `T21:00:00Z` to avoid worsening
it. **Recommendation:** at HITL, first reconcile #795 ↔ #796 (cross-link or supersede + re-mint one's IL),
then merge one at a time; ADR/IL numbers freeze at merge (ADR-119).

## Anchors

- `scripts/adr-traceability-check.sh` (NEW), `.github/workflows/guardian.yml` job `guardian-traceability`
  (NEW, informational), modelled on `scripts/adr117-gate-check.sh`.
- ADR-130/#795, ADR-131/#796 (complementary), ADR-117, ADR-056, ADR-128, ADR-102, ADR-119, ADR-124.
  Enforcement = CI gate + this ADR; gate is informational/non-required until stabilized.
