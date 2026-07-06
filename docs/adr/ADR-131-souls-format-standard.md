---
id: ADR-131
title: Souls/SOUL.md format standard — canonical sections + voice/memory-policy/core-truths/pet-peeves extension
status: ACCEPTED
date: 2026-06-25
accepted: 2026-06-25
supersedes: []
relates:
  - "ADR-117 §Hermes + perimeter (souls are factory-side persona; perimeter enforcement stays in ADR-117)"
  - "ADR-122 (agents/souls=19, passports=57, swarms=3 — this ADR standardizes the souls layer it counted)"
  - "ADR-128 (HITL L1/L2/L3 — the HITL Gate section mirrors this ladder)"
  - "ADR-121 (destructive-action — Constraints/boundaries mirror fail-closed)"
  - "ADR-130 / PR #795 (IN-FLIGHT draft — generic factory persona template; see Duplication Audit for the boundary)"
  - "ADR-102 (no-duplication — Duplication Audit basis)"
il_anchor: IL-553
il_anchor_note: "Minted IL-553 by build_ledger as max+1 over origin/main (main max = 552 after #798/ADR-132 merged) at rebase-before-merge (ADR-119 Rule 8; prior provisional 551). Sequential HITL merge order #798→#796→#795 yields unique 552/553/554. The IL-202x labels in the ledger body are a separate legacy heading series, NOT the minted sequence."
scope: BANXE-factory-only
concept_only: true
---

# ADR-131 — Souls/SOUL.md format standard (canonical sections + 4-section extension)

## Context

The repo carries **19** persona files under `agents/souls/*.md` (counted by ADR-122). An audit of the
current main shows they already share a **stable 7-section format** — all **19/19** carry: `Identity`,
`Core Responsibilities`, `Tools Available`, `Data Sources`, `Constraints`, `Escalation`, `HITL Gate`.
But there is **no template and no written standard**, and the format has gaps vs. best practice:

- `Voice` **0/19**, `Memory Policy` **0/19**, `Core Truths` **0/19**, `Pet Peeves` **0/19**.
- `Data Sources` header has drifted into **3 variants** (`(read-only)` ×15, `(read-only unless
  explicitly stated)` ×1, `/ Targets` ×3).

This ADR **formalizes the existing format as a standard** and **adds the 4 missing sections**, additively.
It is concept-only: it introduces **no runtime code**, **no Hermes runner** (24/7 / auto-skills — a
separate ADR per the ADR-124 precedent), and **does not edit any of the 19 existing souls**.

## Decision

1. **Canonical `agents/souls/*.md` format = 11 sections**, in order: `Identity` · `Core Responsibilities`
   · `Tools Available` · **`Data Sources (read-only)`** · `Constraints` · `Escalation` · `HITL Gate` ·
   **`Voice`** · **`Memory Policy`** · **`Core Truths`** · **`Pet Peeves`**. The first 7 are the
   already-universal sections (kept verbatim, `Constraints` = boundaries); the last 4 are the additive
   extension.
2. **Template = `agents/souls/_TEMPLATE.md`** (30–80 lines, concrete prompts per section, not "be
   helpful"). `boundaries` (Constraints) + `Memory Policy` mirror canon — **fail-closed**, **HITL-gated**
   (ADR-128), **ledger append-only** (ADR-059), **perimeter** (ADR-117). `Voice` mirrors the working
   discipline (explicit read-only vs state-changing, one next action, audit-before-action).
3. **Data Sources header unified** to `## Data Sources (read-only)`. The unification is the **migration
   target**; the 3 drifted live files are **NOT edited in this PR** (append-only scope) — migration is a
   follow-up.
4. **Subordinate to canon, cannot expand authority.** A soul may narrow/describe authority, never
   broaden it. Enforcement stays in **CI gates + ADR-117/128/121** — never in a soul file. On conflict,
   the ADR/gate wins.
5. **Optional lint** `scripts/souls-format-check.sh` (read-only) checks the 7 mandatory sections (green
   today) and reports the 4 advisory sections without failing. **Not wired into CI** by this ADR;
   wiring it as a gate is a follow-up once the 19 souls are migrated.

## Duplication Audit (ADR-102)

1. **Repo-wide search** — `agents/souls/_TEMPLATE.md`: **absent** (no template). No prior ADR titled
   souls/persona *format/standard*. `agents/souls/*.md` (19) are persona **instances**, not a standard.
2. **Source-of-truth + consumers.** Source-of-truth for persona **instances** = `agents/souls/`
   (unchanged here). This ADR + template become the source-of-truth for the **format**; the 19 instances
   are consumers, migrated later, **not edited now**.
3. **In-flight overlap — ADR-130 / PR #795 (draft, NOT on main).** #795 introduces
   `agents/_template/SOUL.md` — a **generic factory-agent persona layer** (8 abstract sections) and the
   high-level "SOUL.md subordinate to ADRs" canon. **This ADR-131 is distinct, not a duplicate:**
   different **path** (`agents/souls/_TEMPLATE.md` vs `agents/_template/SOUL.md`), different **population**
   (the 19 concrete domain/banking souls vs any factory agent), different **purpose** (standardize the
   *existing* souls format + close section gaps + unify the Data Sources drift, grounded in the live
   19-file audit). **ADR number 131 chosen to avoid colliding with in-flight ADR-130.**
   **Operator recommendation (HITL):** at review, reconcile the two — either (a) merge both and
   cross-link (ADR-130 = generic layer/principle, ADR-131 = concrete souls format), or (b) supersede one.
   Both are drafts under operator HITL; this PR neither merges nor touches #795.
4. **No hidden dependencies.** No CI gate / code keys off a souls template today; the new lint is a
   standalone read-only script, unwired. The 19 souls are not edited.
5. **Decision per match:** `agents/souls/*` instances → **KEEP** (untouched); `agents/souls/_TEMPLATE.md`
   → **ADD**; `scripts/souls-format-check.sh` → **ADD** (unwired); ADR-131 → **ADD** (extends ADR-117/122,
   not a duplicate). No delete, no merge, no rewrite.

## Consequences

- The souls layer gains a written standard + template; new souls start 11-section-complete with
  canon-mirrored boundaries/memory.
- The 4 best-practice gaps (voice/memory/core-truths/pet-peeves) and the Data Sources drift have a
  documented target, migratable incrementally without a big-bang edit.
- **No runtime change**; no Hermes runner; the 19 existing souls are byte-for-byte unchanged.

## Anchors

- `agents/souls/_TEMPLATE.md` (NEW), `scripts/souls-format-check.sh` (NEW, read-only/unwired),
  `agents/souls/*.md` (19, unchanged).
- ADR-117 (perimeter), ADR-122 (souls/passports/swarms count), ADR-128 (HITL), ADR-121 (destructive),
  ADR-059 (append-only), ADR-119 (IL numbering), ADR-102 (dup), ADR-124 (runner = separate ADR),
  ADR-130/PR #795 (in-flight generic persona layer — reconcile at HITL). Enforcement = CI + ADRs.

## Amendment 2026-07-07 — `## Decision Method` added as a mandatory section (11 → 12)

> Append-only (I-24): the ADR body above is unchanged; this records the additive extension.

Per operator directive (train every factory agent on the **Best-Decision method**), the canonical
`agents/souls/*.md` format gains **one additional mandatory section — `## Decision Method`** — inserted after
`## HITL Gate`. The canonical count in **§Decision item 1 moves 11 → 12** (order otherwise unchanged; additive, no
existing section removed or reordered).

- **Content** (pointer-first, ADR-102 — not restated): enumerate the feasible action set → score (EU/MAUT over the
  passport's criteria) → **satisfice within the HITL gate** (Simon) → escalate on ambiguity / confidence-drop /
  invariant risk. Runtime L2+ (payment/compliance/KYC/AML) **fail-closed precedence is unchanged**.
- **Grounding:** `docs/sources/best-decision-concept-2026-07-06-v2.md` (theory) · `docs/adr/ADR-162-best-decision-principle.md`
  · `docs/canon/BEST-DECISION-BOUNDARY.md` · `docs/canon/BANXE-BEST-DECISION-AND-ENGINE-PRINCIPLES.md`.
- **Rollout:** `agents/souls/_TEMPLATE.md` carries the section as of this change; the **58 existing souls** are
  retrofitted per `docs/canon/BEST-DECISION-RETROFIT-PLAN.md` (one PR per batch, prepare-only) — existing souls are
  **not** edited in this amendment PR.
- **Effective:** 2026-07-07 (PR #1077). Enforcement = CI + ADRs; `docs/factory/FACTORY-CANON.md` §1.11 mirrors the requirement.
