# Consolidated UI/UX Audit Block — Specification

> **Status:** factory-capability specification. **Date:** 2026-07-01. **Owner-terminal: A (factory).**
> **Pointer-first and additive (ADR-102).** This is the operating specification of the now-active
> `design_pipeline_agent`; it fuses the existing UI/UX audit, governance, validation, and design-system
> approaches into ONE block. It **defines**; it does not implement. Companion artefacts named in §B/§D are
> **future implementation steps — NOT created in this PR.** Append/amend discipline applies (§8).

## §1. Purpose and scope
The Consolidated UI/UX Audit Block is a **full-cycle factory capability** that audits the BANXE UI/UX surface for
conformance to intent, design-system adherence, accessibility baselines, interaction/state completeness,
duplication/drift, and documentation alignment — and hands the runtime/browser validation contract to `banxe-ui`.

**Covers (directly):** static code audit; design-system conformance; accessibility *baselines* (static + the
runtime gate contract); interaction/state completeness *as a contract*; duplication/drift detection;
documentation alignment; runtime-contract handoff to `banxe-ui`.

**Does NOT cover directly:** subjective UX truth without runtime evidence; product analytics; user research —
unless separately attached. **No "100% working" claim is made**: the block is operational, testable, auditable,
and incrementally enforceable, with explicit scope, runtime boundaries, health-checks, and acceptance criteria.

**Operating canon (binding):** the factory (left terminal, A) is the authority; the factory orchestrates and the
**operator executes**; **shell is audit-only**; main work happens through Claude Code; **sandbox mode**; every
audit output ends with **exactly one next step**; central and right terminals may work autonomously on
sub-products, but the **factory merges them into one EMI BANXE AI BANK solution and prevents conflicts**.

## §2. Architecture — five layers (non-overlapping)

### Layer A — Source of truth (pointer-only; nothing restated)
- `docs/BANXE-UI-UX-SYSTEM.md` — Taste Rubric (advisory bands), WCAG 2.1 AA Accessibility Rules, token system.
- `docs/governance/UI-UX-DESIGN-SYSTEM-CANON.md` — design-system governance (§5A taste, §5 WCAG floor, §7.2 owner, §8 OI-5 θ).
- `agents/passports/design_pipeline_agent.yaml` — the active owning agent (capabilities incl. `visual_regression_config`, `aesthetic_taste_review`).
- **ADR-149** (closed-loop completion criteria) · **ADR-153** (terminal topology) · **ADR-154** (shared-space arbitration).

### Layer B — Static repo audit (definition only; implementation deferred; NO runtime)
Each static check is **defined** here, classified as **EXTENDS `scripts/uiux-pipeline.sh`** (never fork) or
**NEW check** (future step). Implementation is a later named step — not built in this PR.

| Static check | Definition (what it asserts) | Extends `uiux-pipeline.sh` / NEW |
|---|---|---|
| **Tokens** | UI uses `--space-*`/`--text-*`/`--color-*` tokens, not hardcoded values | NEW (future) |
| **Components** | authored components reuse documented Component Patterns; no bespoke re-invention | NEW (future) |
| **States (static)** | each component *declares* empty/loading/error states (runtime proof = Layer C) | NEW (future) |
| **Duplication** | no duplicate component/rule/doc (ADR-102 repo-wide) | NEW (future) |
| **Drift** | authored UI vs design-system canon divergence | NEW (future) |
| **Semantic** | semantic HTML / ARIA-role correctness (static) | NEW (future) |
| **a11y-static** | static WCAG-checkable rules (alt text, label-for, contrast tokens) | NEW (future) |
| **Code quality** | lint / static-analysis / test-boundary | EXTENDS (semgrep already wired) |
| **Declaration presence** | A-rubric + B-governance + ADR-149 loop declared | already in `uiux-pipeline.sh` |

### Layer C — Runtime contract for `banxe-ui` (machine-checkable handoff)
The repo-side block can only **declare and require**; `banxe-ui` must **execute and prove**. For each requirement
the repo-side audit checks an **evidence artefact** for presence and pass — **without running it**. The runners
are built by `banxe-ui` **under operator gate** (ADR-117 perimeter; ADR-103 server-only); here we define only the
**contract and the evidence envelope**.

| Runtime requirement | Evidence artefact (presence + pass) | Gate? |
|---|---|---|
| **Viewport matrix** | pass/fail per declared breakpoint | advisory until runtime |
| **Keyboard / focus** | focus-order + visible-focus + skip-to-content report | advisory until runtime |
| **axe-core accessibility** | axe run vs **WCAG 2.1 AA** | **GATE** (hard floor — not advisory) |
| **Visual regression** | Storybook screenshots + diff | advisory until runtime |
| **Empty / loading / error states** | per-component state-coverage report | advisory until runtime |
| **Key user journeys** | Playwright e2e pass/fail | advisory until runtime |
| **Mobile/web parity** | parity assertion per shared screen | advisory until runtime |

> **Explicit rule:** absent its evidence artefact, a runtime requirement's conformance is **[НЕИЗВЕСТНО] — NEVER
> asserted as `passed`.** The block does not pretend runtime is validated when only static evidence exists.

### Layer D — Evidence / reporting
- **Findings format:** `finding = { id, severity, confidence, file_paths[], impacted_flows[], remediation }`,
  emitted as a **findings JSON** (schema = **future companion artefact `schemas/uiux-audit-findings.schema.json`,
  NAMED not created**).
- **Blocking-vs-advisory map** per §4.
- **One-next-step rule:** every audit output ends with **exactly one** next action (mirrors the Best Single
  Artifact canon) — never zero, never a menu.

### Layer E — Factory orchestration
Binds the existing governance (pointer, not restated): **CONFLICT-LEDGER** (deconfliction + merge discipline),
**TERMINAL-OWNERSHIP** (write-zones), **ADR-154** (factory = arbiter), **CTIO-CARRY-FORWARD** (operator-owned ops).
**Merge contract** for central/right/Legion outputs: **no duplicate logic · no circular dependencies · no
conflicting component ownership · no unsourced UI variants.** The **factory is final arbiter**. **Duplicate-check
is mandatory** (§5). **Generated/changed UI code is NOT trusted until factory re-check** (§7).

## §3. Inputs / outputs
- **Inputs:** source docs (Layer A), passports, validators, frontend code (`banxe-ui`), component inventory, ADR
  bindings, generated code, runtime evidence from `banxe-ui`.
- **Outputs:** audit report; findings JSON; blocking-vs-advisory results; duplication findings; remediation list;
  unresolved unknowns.

## §4. Blocking vs advisory
- **Hard gates (preserved):** WCAG 2.1 AA · guardian / quality governance gates · ADR-102 duplication. These block.
- **Advisory (never a gate):** the **taste rubric** stays advisory by canon; **θ=on-canon** feeds only the
  impeccable loop, never promotion.
- **Severity-typed by class:** duplication and unsourced-variant default **blocking**; stylistic drift **advisory**.
- **UI findings remain ADVISORY until the `banxe-ui` runtime exists** (operator decision, §8).

## §5. Duplicate-check (mandatory, first-class)
Required (ADR-102) **before**: adding a new UI component; introducing a new audit rule; merging a terminal
sub-product; expanding documentation. Every report MUST carry an **anti-dup proof** (matches found + keep/merge/
delete decision + risk), or it is incomplete and rejected.

## §6. Terminal orchestration
Central, right, and Legion outputs are produced independently but **reconciled by the factory** per the merge
contract (§2 Layer E). The factory is the final arbiter; conflicts are deconflicted by time or by files per
CONFLICT-LEDGER; ownership is resolved per TERMINAL-OWNERSHIP; arbitration authority is ADR-154.

## §7. Code-quality re-check
Any generated or changed UI code is **factory-re-checked before trust**: lint + static-analysis + test-boundary +
design-system conformance (Layer B) + a11y review (static + the Layer C gate contract). **Generated UI code is
not trusted until re-checked.**

## §8. Documentation governance (binding)
Docs are **extended, not destructively rewritten** — originals preserved; changes accumulate in additive
sections / changelog-style evolution. **HARD RULE: any rewrite exceeding 50% of a document requires operator
approval.** This applies to this spec itself and to every Layer A source it points to.

## §9. Block health / failure behaviour
- **Health-check before use:** any block/tool/model is health-checked before the audit relies on it; model/block
  readiness is verified first. Legion and both servers are referenced **only** as they affect block operability
  (pointer to infrastructure canon — `[НЕИЗВЕСТНО]` whether enumerated here or by pointer; proposed: pointer).
- **Failure handling:** **log → one retry → fallback or operator question.** No silent failure; no invented
  workaround.

## §10. `banxe-ui` runtime contract — see Layer C
The authoritative handoff (§2 Layer C). Repo-side **declares/requires**; `banxe-ui` **executes/proves** under
operator gate. Evidence envelope machine-checkable; absent evidence ⇒ `[НЕИЗВЕСТНО]`.

## §11. Acceptance criteria
The spec is done only if: one unified block is defined; responsibilities are non-overlapping across the five
layers; the static/runtime split is explicit and the runtime contract machine-checkable; duplicate-check is
first-class at every stage; factory orchestration duties are explicit with the factory as final arbiter; the
reporting format is defined; health-check and log→retry-once→fallback-or-ask behaviour is defined; taste remains
advisory; and it is implementable later without reopening fundamentals.

## §12. Anti-scope-creep
Reuse existing validators / passports / docs by reference (§ Anti-dup). **No parallel agent** — the owner is the
already-active `design_pipeline_agent`; this block is its operating spec. **No new governance** where an ADR/
pointer already covers it. **No pretending runtime is validated** on static evidence alone. **Companion artefacts
(`schemas/uiux-audit-findings.schema.json`, `uiux-pipeline.sh` check extensions) are NAMED future steps — not
built in this PR.**

## §13. [НЕИЗВЕСТНО] (targets for implementation-time; not invented)
- `banxe-ui` runtime maturity (separate repo; not audited from here) — the contract is a target, not a description.
- The exact breakpoint set, the canonical user-journey list, and the component inventory — sourced at
  implementation time from `banxe-ui` / the design system.
- Whether Legion/server health-checks are enumerated here or referenced by pointer (proposed: pointer).

## Anchors
**Anti-dup / reuse-by-reference (ADR-102):** `scripts/uiux-pipeline.sh` (EXTEND, never parallel) · taste A/B/C on
`main` (`BANXE-UI-UX-SYSTEM.md`, `UI-UX-DESIGN-SYSTEM-CANON.md`, `design_pipeline_agent`) · the seven governance
documents (CONFLICT-LEDGER · TERMINAL-OWNERSHIP · ADR-154 · CTIO-CARRY-FORWARD · MASTER-ROADMAP ·
REPORTING-STYLE-CANON) · gates ADR-102 / ADR-117 / ADR-135 / ADR-149. **No new parallel agent.** Operator
directive 2026-07-01.
