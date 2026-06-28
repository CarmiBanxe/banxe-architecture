# UI Taste-Skills — Authoring Transfer Package (taste-skill + impeccable)

**Status:** TRANSFER PACKAGE · **PREPARE-ONLY** · awaits operator HITL (ADR-135) · **Date:** 2026-06-28
**Plane:** Architecture (Governance) · **Authority:** factory · **Execution:** `banxe-ui` (project)

> Single consolidated authoring package merging the **A → B → C** spec set (substance / pointer-governance /
> declaration) into one operator-HITL hand-off for the future build task. Authoring only — **no code, no
> activation, no θ value, no merge.** Promotion of any artifact is operator action via the **ADR-135**
> adoption gate.

---

## 0. Invariants (bind every artifact below)
- **taste-skill** = factory-authored taste **rubric** + project-side **advisory review**.
- **impeccable** = bounded project-side **polish loop** (ADR-149 closed-loop).
- **taste = ADVISORY, never a governance/merge gate** (binding peer-review correction; self-grading ≠ gate).
- **WCAG 2.1 AA (canon §5) = objective HARD floor** — taste sits *above* it, never overrides/weakens it.
- **Duplicate-check (ADR-102)** + **factory re-check (ADR-117 KPIs + §4.1 no-verbatim)** = mandatory gates.
- **Egress only via the LiteLLM seam** (local Ollama); no external API on internal data.
- **No RED-zone generation** (synthetic/mock only) · **no runaway loop** · **no agent auto-activation (I-27)**
  · **no code import** (Hands-On-AI = MIT *pattern* reference only).
- **Authority = factory (non-delegable); execution = `banxe-ui`** (ADR-145).

## 1. Authoring order — A → B → C (the only valid sequence)
1. **A** `docs/BANXE-UI-UX-SYSTEM.md` — taste-rubric **substance** (source-of-truth).
2. **B** `docs/governance/UI-UX-DESIGN-SYSTEM-CANON.md` — **pointer** governance (governs A; no substance copied).
3. **C** `agents/passports/design_pipeline_agent.yaml` + `scripts/uiux-pipeline.sh` — scoring/validation **declaration** (PROPOSED).

**Why:** B is pointer-only (canon §0.3/§2) → can only point to a rubric that already exists in A. C declares
scoring **against** the rubric+θ that B governs. Forbidden-if-earlier-missing: B must not point to a rubric
absent from A; C must not declare scoring of a rubric/θ not governed by B.

## 2. Anti-dup proof (ADR-102) — fresh from `origin/main`
| Check | Result |
|---|---|
| A taste-rubric | **ABSENT** on main → the substance delta is genuinely **new** (extend design-philosophy, don't recreate) |
| B references ADR-135 / 145 / 149 | all **real merged ADRs** (`ADR-135-…`, `ADR-145-factory-project-fork-target-model.md`, `ADR-149-…`) — introduce by reference |
| C scoring capability | **absent** — `design_pipeline_agent` has `design_to_code`/`component_catalog`/`design_token_management`/`visual_regression_config` only (visual-regression = pixel-diff ≠ taste) → scoring delta is **new**, added to the existing PROPOSED passport (no parallel agent) |
| C loop | `uiux-pipeline.sh` = read-only validator, **no review/fix loop** → the impeccable loop is **new** project-side (no parallel loop; the validator is only *extended* to check declaration) |
| ADR-145 disambiguation | `ADR-145` = **factory⊕project model** (canonical, #852). The A2A contract is **ADR-150** (renumber complete, #876 + #879). B/C reference the factory model, never the A2A one. |

**Reuse-not-recreate:** rubric substance only in A; B reuses §2-pointer + §5-accessibility governance shape + ADR-102/117 hooks; C extends the existing passport + validator. No parallel agent, no parallel loop.

## 3. Artifact A — substance (taste-rubric, advisory)
Add a **"Taste Rubric (advisory)"** subsection to `docs/BANXE-UI-UX-SYSTEM.md`, structuring the existing
Design-Philosophy + anti-patterns + scattered quality rules into **6 dimensions**, each consuming what A
already defines: **visual hierarchy · spacing rhythm (`--space-*`) · brand-token adherence · motion ·
responsive feel · data-viz clarity**. Each → an **advisory band** (e.g. on-canon / drifting / off-canon),
**no θ value**, **no pass/fail**. Sits **above** WCAG AA; presupposes reuse-not-regenerate; output = advisory
input only. Substance only — no governance/pipeline wording.

## 4. Artifact B — pointer governance
Add to `docs/governance/UI-UX-DESIGN-SYSTEM-CANON.md`, **pointer-only**: (1) a §2 Canonical-Pointer row → A's
taste-rubric; (2) a "Taste & Polish Governance" section paralleling §5 — taste **advisory-not-gate**, binding
**ADR-135** (HITL promotion) / **ADR-145** (factory authority, project advisory execution) / **ADR-149**
(closed-loop the impeccable loop instantiates), reusing **ADR-102** dup-check + **ADR-117** re-check, WCAG §5
hard floor; (3) a §7 RACI row (Design System Lead / Head of Design = **AWAITS OPERATOR**); (4) a §8 open-item
for **θ** (config-as-data location + value = **AWAITS OPERATOR**). Copies **no** substance from A.

## 5. Artifact C — declaration (PROPOSED, not activated)
(1) `agents/passports/design_pipeline_agent.yaml` — declare an `aesthetic_taste_review` capability + a
`TasteScorePort` (advisory score + deltas), distinct from the generation role; **status stays PROPOSED,
not-activated (I-27)**, taste-never-a-gate, no-auto-activate in `non_goals`; θ = AWAITS-OPERATOR placeholder
(non-value). (2) `scripts/uiux-pipeline.sh` — declare a **read-only, non-blocking advisory** check that A's
rubric + B's governance + the loop completion-criteria are *declared* (WCAG §5 stays the hard gate). The
**impeccable bounded loop** (ADR-149) is declared with a stop-condition `axe=AA-pass AND biome=0 AND
vitest≥70 AND dup-check=clean AND taste-score≥θ` **OR** `iteration==MAX_ITER` (hard cap, config-as-data),
**STOP-at-any-mutation = HITL (ADR-135)**, synthetic-data only, LiteLLM-egress only — **executed project-side
in `banxe-ui`**, not run by the validator.

## 6. AWAITS-OPERATOR blockers (nothing decided here)
- **θ value** (config-as-data threshold) — AWAITS OPERATOR.
- **Ownership** — Design System Lead / Head of Design (canon §7.2 / §8 OI-1) — AWAITS OPERATOR; owns θ + taste sign-off.
- **Agent activation** — `design_pipeline_agent` PROPOSED → active is **I-27**-gated (operator).

Draftable now with placeholders (all PROPOSED/advisory, ADR-135 HITL): A rubric structure; B scaffolding with
θ = `AWAITS OPERATOR`; C declaration not-activated.

## 7. Forbidden boundaries
taste-as-gate · external API on internal data · RED-zone generation · runaway loop · agent auto-activation ·
parallel agent · parallel loop · code import · verbatim promotion of generated UI (§4.1). WCAG §5 remains the
hard floor.

## 8. [НЕИЗВЕСТНО] / open
- Licenses of any external pattern source (Hands-On-AI = MIT; pattern-only, no import) — confirm per item.
- `banxe-ui` gate's ability to host an advisory non-blocking dimension — [НЕИЗВЕСТНО] (separate repo, not audited here).
- Whether `UI-UX-DESIGN-SYSTEM-CANON.md` / `design_pipeline_agent` already partially score — verified **absent** (§2), but re-confirm at authoring time.

## Anchors
A `docs/BANXE-UI-UX-SYSTEM.md` · B `docs/governance/UI-UX-DESIGN-SYSTEM-CANON.md` (§2/§4.1/§4.2/§5/§7/§8) ·
C `agents/passports/design_pipeline_agent.yaml` + `scripts/uiux-pipeline.sh` · ADR-102 / ADR-117 / ADR-135 /
ADR-145 / ADR-149 · WCAG 2.1 AA · LiteLLM seam · `banxe-ui`. Hands-On-AI-Engineering (MIT, pattern-only, NOT
imported). PREPARE-ONLY; operator HITL via ADR-135.
