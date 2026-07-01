# banxe-ui UI/UX Runners — transferable BUILD-PROMPTS (four project-side slices)

> **Status:** governance artefact — the **canonical, ready-to-hand build-prompts** for the four remaining
> `banxe-ui` UI/UX evidence runners. **Date:** 2026-07-01. **Owner-terminal: A (factory).** **Pointer-first
> and additive (ADR-102).**
>
> **These are TASKS, not code.** They are handed to the **project side** and **executed by the operator
> inside the `banxe-ui` repo, beyond the ADR-117 perimeter** (`banxe-ui` is project-owned). This document
> **implements no runner**, writes no `banxe-ui` code, and **touches no `banxe-ui` repo, no
> `schemas/uiux-audit-findings.schema.json`, no `uiux-pipeline.sh` ingest, and no policy/spec** — it
> references them. It is derived from the emission spec `UIUX-EVIDENCE-EMISSION-SPEC.md` (#928 §4), the gate
> policy (#918), and the ingest (#921), and restates none of them.
>
> **Relation to the emitter build-prompt (#942):** that prompt is about the **emitter** (how `banxe-ui`
> packages and transports one envelope). **This document is about the four runners that GENERATE the
> evidence** the emitter packages — a distinct concern. It does **not** re-specify the envelope, the
> transport, or the emitter; it specifies **what produces each `result`** the emitter emits.

---

## 0. Shared frame (applies to all four runners)
- **Baseline of fact:** `banxe-ui` `origin/main = b9645a2` (2026-06-27, verified two clones per
  `UIUX-RUNTIME-CONTRACT.md` §0). Build against that verified reality.
- **One shared envelope.** Each runner runs project-side in the `banxe-ui` CI and emits **its own `result`**
  into the **same** envelope `evidence/uiux-findings.json` — conforming to
  `schemas/uiux-audit-findings.schema.json` (P0, `contract_version 1.0.0`) — which the factory ingest (#921)
  consumes read-only. The **emitter (#942) packages/transports** that envelope; these runners **populate**
  their `results[]` entries.
- **All four are ADVISORY** per `UIUX-GATE-POLICY.md` §2/§3 (#918) — they **do NOT block** promotion and do
  **NOT** touch the factory `blocking`/exit path. **The one hard runtime gate remains axe-core / WCAG 2.1
  AA** (handled by the emitter's proof-of-loop, #942 §3); nothing here changes that.
- **Freshness / honesty boundary (P0).** No evidence ⇒ `status: unknown`, **never `pass`**; `commit_sha`
  MUST equal the audited `banxe-ui` frontend commit, else the factory treats it as stale ⇒ `unknown`
  (`UIUX-GATE-POLICY.md` §4). A `result` is `pass`/`fail` only from a real run with a fresh `artefact_ref`.
- **Result shape (all four).** Each `result` is a P0 `result` object (`additionalProperties: false`):
  required `requirement`, `status` (`pass|advisory|fail|unknown`), `severity: advisory`; optional
  `artefact_ref`, `confidence`, `file_paths`, `impacted_flows`, `remediation`. Severity is read from
  `UIUX-GATE-POLICY.md` §3, **not invented**.
- **Task-not-code.** Each runner is **built by the project side inside `banxe-ui`, under the operator gate**
  (ADR-117 perimeter). The exact tool choices and CI-integration details are the **implementer's
  `[НЕИЗВЕСТНО]`** — chosen at build time, not fixed here.
- **Do NOT duplicate what exists.** Storybook (13 stories on `b9645a2`), axe-core, and vitest already exist
  (`UIUX-RUNTIME-CONTRACT.md` §2) — build **on** them, do not rebuild them.

---

## 1. Runner — Playwright e2e journeys (`requirement: e2e_journeys`)
**What to build.** Stand up **Playwright** in `banxe-ui` CI (absent on `b9645a2`, `UIUX-RUNTIME-CONTRACT.md`
§3) and cover the **canonical user journeys** of `banxe-ui`.
**What to emit.** One `result` with `requirement: "e2e_journeys"`, `severity: "advisory"`, `status`
`pass|fail|unknown` from the actual Playwright run, `artefact_ref` → the Playwright report; optional
`impacted_flows` naming the journeys exercised.
**Acceptance.** Envelope stays schema-valid; the factory ingest (#921) moves `e2e_journeys` from `unknown`
to a real `pass`/`fail` sourced from the Playwright run; all other requirements remain `unknown` correctly;
`status` is `unknown` whenever the run is absent/stale.
**`[НЕИЗВЕСТНО]` (implementer-sourced).** The **canonical journey list** (which flows are "the" journeys) —
sourced from `banxe-ui` / the design system at build time, not invented here; the Playwright config,
fixtures, and which CI job runs it.

## 2. Runner — Visual-regression diffing (`requirement: visual_regression`)
**What to build.** Add **visual-regression diffing over the EXISTING 13 Storybook stories** (`b9645a2`).
Storybook already exists — **do NOT rebuild it**; add **only the diffing layer** (Chromatic / Loki / Percy /
`reg-cli` — implementer's choice, `UIUX-RUNTIME-CONTRACT.md` §3 lists these as absent).
**What to emit.** One `result` with `requirement: "visual_regression"`, `severity: "advisory"`, `status`
`pass|fail|unknown` from the diff run (`pass` = no unapproved visual diff), `artefact_ref` → the diff
report/baseline set.
**Acceptance.** Envelope stays schema-valid; ingest (#921) moves `visual_regression` from `unknown` to a
real `pass`/`fail`; others remain `unknown`; `unknown` whenever the diff run is absent/stale. No new
Storybook stories are required by this slice (diffing runs over the existing 13).
**`[НЕИЗВЕСТНО]`.** The **diffing tool** and its baseline-approval workflow; the CI job that runs it.

## 3. Runner — Viewport matrix (`requirement: viewport_matrix`)
**What to build.** An explicit **breakpoint matrix** (mobile / tablet / desktop) exercising the UI across
each breakpoint (no explicit viewport suite on `b9645a2`, `UIUX-RUNTIME-CONTRACT.md` §3).
**What to emit.** One `result` with `requirement: "viewport_matrix"`, `severity: "advisory"`, `status`
`pass|fail|unknown`; report per-breakpoint outcomes (e.g. via `confidence`/`remediation` or an
`artefact_ref` to the per-breakpoint report) — an overall `pass` only if every breakpoint passes.
**Acceptance.** Envelope stays schema-valid; ingest (#921) moves `viewport_matrix` from `unknown` to a real
`pass`/`fail`; others remain `unknown`; `unknown` when absent/stale.
**`[НЕИЗВЕСТНО]`.** The **exact breakpoint set** (the canonical mobile/tablet/desktop widths) — sourced from
the design system at build time, not invented here; how per-breakpoint runs are executed (may reuse
Playwright §1 or Storybook viewports).

## 4. Runner — State coverage (`requirement: state_coverage`)
**What to build.** Explicit coverage of **empty / loading / error** states **per component** (no explicit
state-coverage suite on `b9645a2`, `UIUX-RUNTIME-CONTRACT.md` §3).
**What to emit.** One `result` with `requirement: "state_coverage"`, `severity: "advisory"`, `status`
`pass|fail|unknown`; per-component state results conveyed via `file_paths`/`artefact_ref` — an overall
`pass` only if every in-scope component covers its empty/loading/error states.
**Acceptance.** Envelope stays schema-valid; ingest (#921) moves `state_coverage` from `unknown` to a real
`pass`/`fail`; others remain `unknown`; `unknown` when absent/stale. (Note: the factory static Layer-B check
already surfaces whether states are *declared* in the design-system docs — this runner provides the
*runtime* per-component coverage evidence, complementing it, not duplicating it.)
**`[НЕИЗВЕСТНО]`.** The **component inventory** (which components are in scope) — sourced from `banxe-ui` at
build time, not invented here; how each state is driven (Storybook stories, Playwright, or unit harness).

---

## 5. Scope / boundaries (all four)
- Build the runners **inside the `banxe-ui` repo, under the operator gate** (ADR-117 perimeter). Do **not**
  alter the P0 schema, the factory ingest, the emitter, or the gate policy — each runner's output is a
  schema-conformant `result` the emitter packages and the factory consumes read-only.
- Each runner **only adds** its own evidence; none is a hard gate (all **advisory**), so none changes the
  factory `blocking`/exit behaviour — **the WCAG/axe-core gate remains the sole hard runtime gate**.
- Emit only what is truly evidenced: a real `pass`/`fail` from an actual run with a fresh `commit_sha`;
  `unknown` otherwise. Never assert `pass` without fresh evidence.

## 6. What this document did NOT touch
No `banxe-ui` code. No `banxe-ui` repo. No `schemas/uiux-audit-findings.schema.json`. No `uiux-pipeline.sh`
ingest. No emitter build-prompt (#942). No Storybook rebuild. No policy/spec. This is a **build-prompt set
for project execution**, authored governance-side, prepare-only.

## Anchors
`docs/governance/UIUX-EVIDENCE-EMISSION-SPEC.md` (#928 §4 — the four remaining runners this set frames) ·
`docs/governance/BANXE-UI-EMITTER-BUILD-PROMPT.md` (#942, IL-791 — the **emitter** that packages the
envelope; this set is the **runners that generate** its `results[]`, complementary, not duplicative) ·
`docs/governance/UIUX-RUNTIME-CONTRACT.md` (#920 — verified baseline §0, existing-vs-missing §2/§3) ·
`schemas/uiux-audit-findings.schema.json` + `docs/governance/UIUX-GATE-POLICY.md` (P0, #918 — envelope
shape, **advisory** severity map §2/§3, evidence rule §4) · `scripts/uiux-pipeline.sh` evidence-ingest
(#921 — default path `evidence/uiux-findings.json`, `contract_version 1.0.0`) · ADR-117 (regulated
perimeter — build is operator-gated, project-side, `banxe-ui`-owned) · ADR-102 (Duplication Audit — this
restates none of the above and duplicates neither the emitter prompt nor Storybook). **Baseline of fact:**
`banxe-ui` `origin/main` `b9645a2` (2026-06-27, verified two clones). Operator directive 2026-07-01 (author
the four runner build-prompts as one consolidated governance document).
