---
id: ADR-134
title: Cross-terminal status-report attribution — actor-tagging + operator-gated stub classification (kill false attribution)
status: ACCEPTED
date: 2026-06-26
accepted: 2026-06-26
supersedes: []
refs:
  - "scripts/stub-classifier.sh (read-only — separates non-gated vs operator-gated stubs)"
  - ".claude/rules/parallel-session-isolation.md §'Operator-runtime-config is LOCAL' (canon note)"
  - "docs/governance/CANON-FAST-LANE-SIMPLIFICATION.md:22 (operator-gated additive surfaces — gating source)"
  - "docs/adr/ADR-087-dse-provider-foundation.md (MOCK/STUB/LIVE tier matrix, mock-default — provider-stub gating)"
  - "docs/adr/ADR-039-claude-code-permissions-reclassification.md (~/.claude/settings.json = LOCAL startup enforcement)"
relates:
  - "ADR-060 (branch actor namespace agent/<actor>/<id>/<slug> — the actor tag this ADR leans on)"
  - "PR #801 / ADR-133 (IL global-uniqueness — already closed the collision-counter root)"
il_anchor: IL-557
il_anchor_note: "Minted IL-557 by build_ledger as max+1 over origin/main (main max = 556 after #798/#796/#795/#799/#801 merged) at rebase-before-merge (ADR-119 Rule 8; prior provisional 552). Validated by the live global-uniqueness gate (ADR-133, 540 allowlisted)."
scope: BANXE-factory-only
concept_only: true
---

# ADR-134 — Cross-terminal status-report attribution (actor-tagging + operator-gated stub classification)

## Context

A central-terminal status review raised three concerns; an audit reduced them to **one real** issue:

1. **"A foreign governance terminal is open" — FALSE.** All open PRs are actor-tagged `agent/factory/…`
   (ADR-060): #795/#796/#798/#799/#801 are **our own factory work**, not a foreign terminal. Reading
   them as someone else's is a false attribution.
2. **"A PR overwrote ~/.claude/settings.json" — FALSE.** None of #795/#796/#798/#799 touch `.claude/`;
   `.github/CODEOWNERS` (`/.claude/ @mmber`) + `.gitignore` (`.claude/settings.local.json`) already
   protect it; per **ADR-039** the file is **LOCAL startup enforcement** — a `bypassPermissions →
   acceptEdits` shift is a local session event (restart / home file), **not** a git race.
3. **REAL — the "non-gated stubs" counter conflates classes.** It counts **operator-gated** stubs
   (REWRITE-7 / provider-stubs per FAST-LANE:22 + ADR-087; PROPOSED department-head passports gated on
   operator approval, I-27) together with genuinely **non-gated** stubs → a false, inflated indicator.
   (The collision-counter root was separately closed by ADR-133/#801.)

## Decision

1. **Operator-gated stub classification (closes the real issue).** `scripts/stub-classifier.sh`
   (read-only) splits stub-bearing files into **non-gated (TRUE)** vs **operator-gated (EXCLUDED)**. A
   stub is operator-gated when it carries a canon gating marker — `gated on operator approval`,
   `PROPOSED stub`, `I-27`, `operator-gated` (FAST-LANE:22), or `ADR-087` / `MOCK/STUB/LIVE` /
   `provider-mode`/`provider-stub` / `mock-default` / `REWRITE-7` / `legacy-crypto`. Such a surface
   cannot change client/production state until the operator approves, so it MUST NOT count as
   "non-gated". The status report uses the **TRUE non-gated** figure, with the operator-gated count
   shown separately. (Live repo audit: 13 stub files → **3 non-gated / 10 operator-gated**.)
2. **Actor-tagging kills false attribution (1).** Before labelling any PR/terminal "foreign", verify
   the branch actor tag `agent/<actor>/…` (ADR-060). `agent/factory/…` = our own factory; it is never
   a foreign governance terminal. This is recorded as canon so the misread does not recur.
3. **Operator-runtime-config is LOCAL (2).** Codified in
   `.claude/rules/parallel-session-isolation.md` (new section, cross-ref ADR-039): `~/.claude/settings.json`
   is local, not git-tracked, read at startup; a permission-mode change is a local restart, not a
   cross-terminal/repo race; `.claude/` is CODEOWNERS/`.gitignore`-protected; do not touch it.

This ADR is subordinate to **ADR-060** (actor namespace) and changes **no runtime** — it adds a
read-only classifier + two canon notes. No `~/.claude/settings.json` edit; no Hermes runner.

## Duplication Audit (ADR-102)

1. **Repo-wide search** — no prior cross-terminal-attribution / stub-classification ADR;
   `scripts/stub-classifier.sh` and the settings-LOCAL canon note do not exist. ADR-133/#801 closed the
   IL-collision counter (different root — value uniqueness), not the stub/gating classification.
2. **Source-of-truth + consumers.** Gating definitions stay in FAST-LANE:22 + ADR-087 (unchanged); this
   ADR adds a *consumer* (the classifier) + an attribution canon. No existing counter is rewritten —
   `factory-report.sh` and `gap-tracker.py` are untouched; the prior "non-gated" figure was ad-hoc.
3. **No hidden dependencies / no mass edit.** Classifier is standalone read-only; the canon note is an
   append; `.claude/settings.json` is NOT modified; PRs #795/#796/#798/#799/#801 untouched.
4. **Decision per match:** classifier + canon note + ADR-134 → **ADD**; gating canon, existing
   counters, in-flight PRs → **KEEP / untouched**.

## Consequences

- The status report stops over-reporting non-gated stubs; operator-gated (REWRITE-7/provider/I-27)
  surfaces are excluded, with a transparent separate count.
- False "foreign terminal" / "settings overwritten by a PR" attributions are pre-empted by canon
  (actor-tag check + settings-LOCAL note), so the review noise does not recur.
- **No runtime change**; `~/.claude/settings.json` untouched; concept/CI-read-only only.

## Anchors

- `scripts/stub-classifier.sh` (NEW, read-only), `.claude/rules/parallel-session-isolation.md`
  (canon note, NEW section).
- FAST-LANE:22, ADR-087 (gating sources), ADR-039 (settings LOCAL), ADR-060 (actor namespace),
  ADR-133/#801 (collision counter), ADR-102. Enforcement of gating stays in canon; this only
  classifies + attributes correctly.
