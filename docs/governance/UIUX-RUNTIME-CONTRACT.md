# UI/UX Cross-Repo Runtime Contract

> **Status:** governance contract (Phase P1 of the UI/UX block remediation). **Date:** 2026-07-01.
> **Owner-terminal: A (factory).** **Pointer-first and additive (ADR-102).** **contract_version: 1.0.0.**
> This is the machine-checkable contract between **`banxe-architecture`** (governance — *requires and consumes*
> evidence) and **`banxe-ui`** (project — *executes checks and emits evidence*). It restates none of the spec,
> schema, or gate-policy it binds. *(May be promoted to an ADR — next free is ADR-156 — if the operator prefers
> the ADR form; authored here as a governance doc to keep the UI/UX block artefacts coherent.)*

## 0. Verified baseline (source of fact)
All `banxe-ui` statements below are verified against **`banxe-ui` `origin/main` = `b9645a2` (2026-06-27)**,
confirmed **identically from two independent local clones** (`/home/mmber/banxe-ui`,
`/home/mmber/banxe/banxe-ui`). **Not** a feature branch. This contract is written to that verified reality, not
to assumption.

## 1. Purpose
A machine-checkable cross-repo contract. `banxe-architecture` declares the UI/UX requirements and consumes
evidence read-only; `banxe-ui` executes the checks and emits an **evidence envelope** conforming to
`schemas/uiux-audit-findings.schema.json` (P0, #918). The envelope's `contract_version` field references **this
contract's version (1.0.0)**.

## 2. What ALREADY exists on `banxe-ui` main `b9645a2` (the contract SURFACES this — does not rebuild it)
Verified present; the contract requires `banxe-ui` to **emit the evidence envelope from these already-running
checks**, not to build them anew.

| Requirement | Verified on `banxe-ui` main `b9645a2` | Contract treatment |
|---|---|---|
| **axe-core accessibility (WCAG 2.1 AA)** | `axe-core` + `jest-axe` (4 refs in `package.json`); `tests/a11y/` (2 suites); runs in the `quality-gate` CI workflow | **the one HARD runtime gate** (UIUX-GATE-POLICY §1) — maps directly onto this existing, passing CI run; envelope `axe_core_wcag_aa` result is sourced from it |
| **Storybook** | 13 stories on main (`@banxe/storybook`) | foundation present; envelope surfaces the Storybook build (visual-regression *diffing* is a gap, §3) |
| **vitest + coverage** | 2 vitest configs; thresholds **80% lines / 70% branches** | foundation present; surfaced as the unit/coverage evidence |

## 3. What is genuinely MISSING on `banxe-ui` main (scoped remaining build — project-side, operator-gated; NOT built here)
| Gap | Verified absent on `banxe-ui` main `b9645a2` | Status until built |
|---|---|---|
| **Playwright e2e journeys** | 0 refs; no `playwright.config` | advisory |
| **Visual-regression diffing** | 0 (no Chromatic / Loki / Percy / reg-cli) over the existing 13 stories | advisory |
| **Viewport matrix** | no explicit mobile/tablet/desktop breakpoint suite | advisory |
| **Empty / loading / error state coverage** | no explicit state-coverage suite | advisory |
| **The evidence envelope emission itself** | does not exist (this contract defines it) | required for P2 wiring |

These five remain **advisory until built** — **axe-core / WCAG 2.1 AA stays the single hard runtime gate**
(UIUX-GATE-POLICY §1). Building them is `banxe-ui` work under the **ADR-117 perimeter** and operator gate; this
contract does **not** build them and does **not** touch `banxe-ui`.

## 4. Evidence envelope (the handoff)
`banxe-ui` emits one file conforming to `schemas/uiux-audit-findings.schema.json` (P0):
`{ contract_version, commit_sha, generated_at, results[] }`. The factory consumes it **read-only** and verifies:
1. **present**, 2. **schema-valid** (P0 schema), 3. **fresh** — `commit_sha` matches the audited `banxe-ui`
frontend revision. For each result it reads `status` and `severity` per `UIUX-GATE-POLICY.md`. **Absence or
staleness of the envelope (or any requirement) ⇒ that requirement's status is `unknown` (`[НЕИЗВЕСТНО]`), NEVER
`pass`** — the P0 honesty boundary. No runtime is asserted as passed without fresh evidence.

## 5. Transport mechanism — [НЕИЗВЕСТНО] (P2 implementation decision)
*How* the envelope crosses from `banxe-ui` to the factory is an implementation decision deferred to **P2**, not
fixed here. **Proposed default (not final):** `banxe-ui` commits a signed evidence manifest that the factory
reads **read-only** (no cross-repo write, no secret use). Alternatives — a CI artefact, or a shared evidence
store — are equally admissible; the choice is the **operator's / project terminal's**, sourced at P2. This
contract invents no transport.

## 6. Boundaries held
Touches ONLY this contract document + its IL shard. **`uiux-pipeline.sh` not touched** (the ingest check is P2).
**`banxe-ui` not touched** (project-side, ADR-117 perimeter). **No runners written.** No runtime asserted passed.

## Anchors
`docs/governance/UIUX-AUDIT-BLOCK-SPEC.md` (#916, §2 Layer C) · `schemas/uiux-audit-findings.schema.json` +
`docs/governance/UIUX-GATE-POLICY.md` (P0, #918) · `docs/governance/UI-UX-DESIGN-SYSTEM-CANON.md` (§5 WCAG floor,
§5A taste advisory) · taste A/B/C · the seven governance documents (CONFLICT-LEDGER · TERMINAL-OWNERSHIP ·
ADR-154 · CTIO-CARRY-FORWARD · MASTER-ROADMAP · REPORTING-STYLE-CANON) · gates ADR-102 / ADR-117 / ADR-135 /
ADR-149. **Baseline of fact:** `banxe-ui` `origin/main` `b9645a2` (2026-06-27, verified two clones). **P2 = ingest
in `uiux-pipeline.sh` + first runners; not started here.** Operator directive 2026-07-01 (Phase P1).
