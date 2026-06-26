---
id: ADR-130
title: SOUL.md persona layer as governance canon — human-readable, subordinate to ADRs (cannot expand authority)
status: ACCEPTED
date: 2026-06-25
accepted: 2026-06-25
supersedes: []
relates:
  - "ADR-117 §Hermes + perimeter (SOUL.md is factory-node only; enforcement of perimeter stays in ADR-117)"
  - "ADR-121 (destructive-action protection — SOUL boundaries mirror, never replace it)"
  - "ADR-126 (Hermes Tier-1 role — SOUL.md formalizes the persona layer that a Tier-1 agent would carry)"
  - "ADR-127 (Tier-1 read-only/no-dispatch — SOUL voice/boundaries mirror it)"
  - "ADR-128 (HITL L1/L2/L3 — SOUL memory/boundary sections mirror the ladder)"
  - "ADR-059 (ledger append-only — SOUL memory policy mirrors it)"
  - "ADR-102 (no-duplication — Duplication Audit basis)"
  - "ADR-124 (plugin eval precedent — any executable runner is a SEPARATE ADR, not this one)"
il_anchor: IL-554
il_anchor_note: "Minted IL-554 by build_ledger as max+1 over origin/main (main max = 553 after #798/#796 merged) at rebase-before-merge (ADR-119 Rule 8; prior provisional 551). Sequential HITL merge order #798→#796→#795 yields unique 552/553/554."
scope: BANXE-factory-only
concept_only: true
---

# ADR-130 — SOUL.md persona layer as governance canon (subordinate to ADRs)

## Context

The repo already carries 19 per-agent persona files under `agents/souls/*.md` (Identity /
Responsibilities / Constraints / read-only Data Sources), but there is **no canonical template** and
**no ADR** defining what a persona file is, what it may say, and — critically — what authority it may
**not** grant. Without that, a persona file could drift into asserting capabilities (merge, deploy,
payment, AML) that canon forbids. This ADR fixes the persona layer as governance, **subordinate to
and unable to weaken** the existing ADRs.

It introduces a template (`agents/_template/SOUL.md`) and the canon rule. It adds **no runtime code**
and **no executable Hermes harness** (no 24/7 runner, no skill auto-activation) — any such runner is a
**separate, separately-gated ADR** (the ADR-124 plugin-eval precedent).

## Decision

1. **SOUL.md is a human-readable persona layer OVER `CLAUDE.md` + the ADRs.** It expresses identity,
   worldview, voice, expertise, boundaries, memory policy, and pet peeves for an agent in concrete
   terms — not generic "be helpful".
2. **It is subordinate to canon and CANNOT expand authority.** The source of truth for enforcement
   remains **CI gates** and the ADRs — **ADR-117** (perimeter), **ADR-121** (destructive-action),
   **ADR-127** (Tier-1 read-only / no dispatch), **ADR-128** (HITL L1/L2/L3). A SOUL.md may **narrow
   or describe** an agent's authority; it may **never broaden** it. Where SOUL.md and an ADR/CI gate
   conflict, the ADR/gate wins and the SOUL.md is the stale side.
3. **Mandatory mirroring.** Every SOUL.md `boundaries` and `memory policy` section MUST mirror the
   canon defaults: **fail-closed**, **HITL-gated** (BUG-007), **ledger append-only** (ADR-059),
   **perimeter** (ADR-117). The `voice` section reflects the working discipline: explicit
   **[SHELL]/[CLAUDE CODE]** labelling, exactly **one artifact** at a time, **audit-before-action**.
4. **Template = `agents/_template/SOUL.md`**, 30–80 lines, 8 sections: identity · core truths ·
   worldview · voice · expertise · boundaries · memory policy · pet peeves.
5. **No executable wrapper here.** SOUL.md is structure/persona only. A persistent runner, scheduler,
   or skill auto-activation for any agent (e.g. a future Hermes) is **out of scope** and requires its
   own ADR (per ADR-124).

## Duplication Audit (ADR-102)

1. **Repo-wide search** — `docs/adr/` has **no** prior SOUL/persona ADR (`grep -i soul|persona` over
   origin/main `docs/adr/` = none). `agents/souls/*.md` (19) are persona **instances**;
   `agents/_template/SOUL.md` does **not** exist.
2. **Source-of-truth + consumers.** Source-of-truth for persona **instances** = `agents/souls/`
   (unchanged here). This ADR + the new template formalize the **structure** those instances already
   informally follow; they do not redefine or duplicate any instance.
3. **No hidden dependencies.** No CI gate or code keys off a persona template today; adding one is
   additive (no consumer to break). The 19 existing souls are **not edited**.
4. **Decision per match:** existing `agents/souls/*` → **KEEP** (untouched); new
   `agents/_template/SOUL.md` → **ADD** (template, no duplicate); ADR-130 → **ADD** (governance canon,
   no prior ADR). No delete, no merge, no rewrite.
5. **No doubt / fail-closed:** no ambiguity; nothing to escalate.

## Consequences

- The persona layer is now canon-bounded: a SOUL.md can humanize an agent but can never grant it
  authority canon withholds — closing the "persona drifts into capability" risk.
- Future agents (incl. a future Hermes Tier-1) get a ready 8-section template whose boundaries/memory
  sections are pre-wired to fail-closed / HITL / append-only / perimeter.
- **No runtime change.** Executable runners remain a separate ADR; this PR is docs/governance-only.

## Anchors

- `agents/_template/SOUL.md` (NEW template); `agents/souls/*.md` (19 existing instances, unchanged).
- ADR-117 (perimeter), ADR-121 (destructive), ADR-126/127 (Hermes Tier-1 / read-only), ADR-128 (HITL),
  ADR-059 (ledger append-only), ADR-119 (IL numbering), ADR-102 (Duplication Audit), ADR-124 (runner
  = separate ADR precedent). Enforcement = CI gates + these ADRs, never SOUL.md.
