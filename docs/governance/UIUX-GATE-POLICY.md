# UI/UX Gate Policy — advisory-vs-blocking map

> **Status:** governance policy (Phase P0 of the UI/UX block remediation). **Date:** 2026-07-01.
> **Owner-terminal: A (factory).** **Pointer-first and additive (ADR-102).** This map defines which UI/UX audit
> findings **block** promotion and which are **advisory**. It is consumed alongside the findings/evidence
> schema (`schemas/uiux-audit-findings.schema.json`) by the audit block defined in
> `docs/governance/UIUX-AUDIT-BLOCK-SPEC.md` (#916). It restates none of that spec — it concretises its §4.

## 1. Hard gates (BLOCK promotion)
| Gate | Basis | Notes |
|---|---|---|
| **axe-core vs WCAG 2.1 AA** | design-system canon §5 (hard floor) | the **one runtime requirement that is a gate**; a failing axe-core result blocks |
| **guardian / quality governance gates** | existing CI (guardian-*, quality-gate) | unchanged |
| **ADR-102 duplication** | Duplication Audit | duplicate component / rule / doc blocks |
| **unsourced-variant** | merge contract (UIUX-AUDIT-BLOCK-SPEC §2 Layer E) | a UI variant with no design-system source blocks |

## 2. Advisory (NEVER block)
| Advisory | Basis |
|---|---|
| **Taste rubric** | advisory by canon (UI-UX-DESIGN-SYSTEM-CANON §5A); **θ=on-canon feeds only the impeccable loop, never promotion** |
| **Stylistic drift** | non-breaking divergence from the design system |
| **All runtime requirements except axe-core/WCAG** | viewport matrix, keyboard/focus, visual regression, empty/loading/error states, key journeys, mobile/web parity — **remain advisory until the banxe-ui runtime exists** |

## 3. Severity by finding class
| Finding class | Default severity |
|---|---|
| duplication | **blocking** |
| unsourced-variant | **blocking** |
| accessibility (axe-core / WCAG 2.1 AA) | **blocking** |
| stylistic drift | advisory |
| all other runtime requirements (pre-banxe-ui-runtime) | advisory |

These defaults map directly to the `severity` field (`blocking|advisory`) of each `result` in the findings
schema.

## 4. Evidence rule (binding)
**Absence or staleness of evidence ⇒ the requirement's status is `unknown` (`[НЕИЗВЕСТНО]`), NEVER `pass`.** A
requirement is reported `pass` only with a fresh `artefact_ref` whose `commit_sha` matches the audited frontend
revision. This is the honesty boundary: the block never asserts runtime conformance it has not received evidence
for.

## 5. [НЕИЗВЕСТНО] — implementation-time, not invented here (P2+)
- the cross-repo **evidence-transport mechanism** (committed manifest vs CI artefact vs evidence store);
- **banxe-ui CI maturity** to run the runners;
- the exact **breakpoint set / canonical journey list / component inventory**.
These are sourced at P2 from `banxe-ui` / the design system; this policy invents none of them.

## Anchors
`docs/governance/UIUX-AUDIT-BLOCK-SPEC.md` (#916, §4) · `schemas/uiux-audit-findings.schema.json` (P0 sibling) ·
`docs/governance/UI-UX-DESIGN-SYSTEM-CANON.md` (§5 WCAG floor, §5A taste advisory) · taste A/B/C · the seven
governance documents (CONFLICT-LEDGER · TERMINAL-OWNERSHIP · ADR-154 · CTIO-CARRY-FORWARD · MASTER-ROADMAP ·
REPORTING-STYLE-CANON) · gates ADR-102 / ADR-117 / ADR-135 / ADR-149. **Cross-repo contract / ADR is P1 (NOT
created here); `uiux-pipeline.sh` extension is P2 (NOT touched here).** Operator directive 2026-07-01 (Phase P0).
