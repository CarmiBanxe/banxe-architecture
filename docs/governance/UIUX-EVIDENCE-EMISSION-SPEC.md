# UI/UX Evidence Emission Spec — banxe-ui → factory handoff contract

> **Status:** governance handoff spec (project-side emission contract for the UI/UX audit block).
> **Date:** 2026-07-01. **Owner-terminal: A (factory).** **Pointer-first and additive (ADR-102).**
> **contract_version: 1.0.0.**
>
> This document is the **transferable emission specification** — it states precisely **what `banxe-ui`
> must emit** so that the evidence-ingest check in `scripts/uiux-pipeline.sh` (P2, #921) accepts it and the
> UI/UX audit block turns runtime `unknown` into real `pass`/`fail`. It is authored **in
> `banxe-architecture`** as a governance artefact and handed to the **project terminal**; it **restates none
> of** the schema, gate policy, runtime contract, or spec it binds — it references them. **It touches no
> `banxe-ui` code, writes no runner, and emits no envelope** (ADR-117 perimeter). It describes the target
> for the project terminal to build; it does not build it.

## 0. Verified baseline (source of fact)
All `banxe-ui` statements below are anchored to **`banxe-ui` `origin/main` = `b9645a2` (2026-06-27)**, the
baseline confirmed identically from two independent local clones in `UIUX-RUNTIME-CONTRACT.md` §0. This spec is
written to that verified reality — not to assumption — and invents no `banxe-ui` state.

## 1. Transport — DEFAULT, now selected (closes the P1 [НЕИЗВЕСТНО])
The cross-repo transport left open at P1 (`UIUX-RUNTIME-CONTRACT.md` §5, `UIUX-GATE-POLICY.md` §5) is hereby
fixed to the **proposed default**, promoted from "proposed" to **selected**:

- **`banxe-ui` commits the evidence envelope as a plain file at the repo-relative path
  `evidence/uiux-findings.json`.** This path is chosen deliberately to **match the ingest default** in
  `uiux-pipeline.sh` (#921): the check reads `UX_EVIDENCE_ENVELOPE` and falls back to
  `evidence/uiux-findings.json`. Committing to that exact path means the factory ingests it with **zero
  configuration** and **read-only** (no cross-repo write, no secret use, no network fetch).
- **Selection is now binding for the first loop.** The transport is no longer `[НЕИЗВЕСТНО]` — it is a
  committed file at the default path, read read-only by the factory.
- **Possible strengthening later (not required now):** a **signed evidence manifest** (or a CI artefact, or a
  shared evidence store) may replace the plain committed file as a hardening step. That is an additive future
  decision; it does **not** block the first loop and is **not** specified here beyond noting it as the
  intended strengthening direction.

## 2. Envelope format — strictly per the P0 schema (no restatement, no drift)
The committed file MUST validate against **`schemas/uiux-audit-findings.schema.json`** (P0, #918) with
`contract_version` referencing **this contract's version, `"1.0.0"`** (per `UIUX-RUNTIME-CONTRACT.md`). The
top-level object is exactly:

```json
{
  "contract_version": "1.0.0",
  "commit_sha": "<banxe-ui frontend commit the evidence was generated against>",
  "generated_at": "<ISO-8601 UTC timestamp>",
  "results": [ /* one entry per audited requirement */ ]
}
```

Each entry in `results[]` is a **`result`** object per the P0 schema (`additionalProperties: false`):

| Field | Requirement | Notes (authoritative source = P0 schema + `UIUX-GATE-POLICY.md`) |
|---|---|---|
| `requirement` | **required** | audited requirement id, e.g. `axe_core_wcag_aa`, `viewport_matrix`, `visual_regression`, `state_coverage`, `key_journeys` |
| `status` | **required** | one of `pass` \| `advisory` \| `fail` \| `unknown`; **default & mandatory fallback = `unknown`** |
| `severity` | **required** | `blocking` \| `advisory`; severity map is authoritative in `UIUX-GATE-POLICY.md` §3 — the emitter does not invent it |
| `artefact_ref` | optional | reference to the supporting evidence artefact; **absent ⇒ `status` MUST be `unknown`** |
| `confidence` | optional | 0..1 |
| `file_paths` | optional | impacted source files |
| `impacted_flows` | optional | user flows / journeys impacted |
| `remediation` | optional | operator-usable remediation hint |

The emitter MUST NOT add keys outside the schema (`additionalProperties: false` on both the envelope and each
`result`), and MUST NOT invent severities — the `blocking`/`advisory` assignment is read from
`UIUX-GATE-POLICY.md` §3, not decided at emission time.

## 3. First slice (proof-of-loop) — axe-core / WCAG 2.1 AA from the EXISTING CI
The first envelope emission is a **single real result** sourced from a check that **already runs and passes**
on `banxe-ui` main — no new runner is required to light the loop:

- `banxe-ui` already runs **`axe-core` + `jest-axe`** (4 refs in `package.json`; `tests/a11y/` two suites)
  inside its **`quality-gate` CI workflow** (verified, `UIUX-RUNTIME-CONTRACT.md` §2).
- The emitter writes **one `result`** with `requirement: "axe_core_wcag_aa"`, `severity: "blocking"` (the one
  hard runtime gate, `UIUX-GATE-POLICY.md` §1), and `status` taken from the **actual CI run**: `pass` when
  the axe-core suite passes, `fail` when it does not, with `artefact_ref` pointing at the axe report.
- This single result is what **turns the hard WCAG gate end-to-end**: the factory ingest (#921) stops
  reporting `unknown` for accessibility and reflects the real `pass`/`fail` from the frontend CI.

## 4. Freshness — the P0 honesty boundary
`commit_sha` MUST equal the **`banxe-ui` frontend commit the evidence was generated against**. The factory
verifies presence, schema-validity, and **freshness**: if `commit_sha` does not match the audited frontend
revision (stale envelope), the factory treats the requirement as **`unknown` (`[НЕИЗВЕСТНО]`), never `pass`**
(`UIUX-GATE-POLICY.md` §4, `UIUX-RUNTIME-CONTRACT.md` §4). A `pass` is only honoured with a **fresh**
`artefact_ref`/`commit_sha`. No runtime conformance is asserted without fresh evidence.

## 5. The remaining requirements — emitted as `unknown` until their runners exist
The four gaps genuinely absent on `banxe-ui` main `b9645a2` (`UIUX-RUNTIME-CONTRACT.md` §3) — **Playwright e2e
journeys, visual-regression diffing, viewport matrix, empty/loading/error state coverage** — MUST be emitted
(if present in `results[]` at all) with **`status: "unknown"`** and their policy severity (advisory until the
`banxe-ui` runtime exists, `UIUX-GATE-POLICY.md` §2). The emitter **MUST NOT assert these as `passed`** — each
is a **separate project-side slice** built later. Emitting them as `unknown` is correct and honest; omitting
them entirely is also acceptable (ingest treats an absent requirement as `unknown` by the same boundary).

## 6. Acceptance criteria (for the project terminal)
The emission is accepted when **all** hold:

1. The committed `evidence/uiux-findings.json` is **schema-valid** against `schemas/uiux-audit-findings.schema.json` (P0).
2. `contract_version == "1.0.0"` and `commit_sha` is **fresh** (matches the audited `banxe-ui` frontend commit).
3. The **ingest check (#921) in `uiux-pipeline.sh` moves from `unknown` to a real `pass`/`fail`** for
   `axe_core_wcag_aa`, sourced from the existing quality-gate CI run.
4. All other (unbuilt) requirements remain **`unknown`** correctly — none asserted `passed`.

The factory verifies 1–4 **read-only**; it does not write into `banxe-ui` and does not run the frontend checks
itself.

## 7. [НЕИЗВЕСТНО] — project-side details, not invented here
- The **exact location of the envelope inside the `banxe-ui` tree** — the `evidence/uiux-findings.json` path is
  specified **relative to the point the factory reads** (the ingest default); whether `banxe-ui` produces it at
  that path directly or maps it there is a **project-side placement decision**.
- The **specific CI step / workflow job that generates and commits the envelope** (name, trigger, on which
  workflow it hangs) is a **project-side implementation detail** — this spec does not name it and does not
  invent it.
- Whether/when to strengthen the committed-file transport to a **signed manifest** (§1) — a later project/operator decision.

## 8. Boundaries held
Touches ONLY this handoff document + its IL shard. **`banxe-ui` not touched** (no code, no runner, no emitter,
no PR/files there — ADR-117 perimeter). **`scripts/uiux-pipeline.sh` not touched.** **The P0 schema not
touched.** **The P0/P1 documents not touched.** No runtime asserted passed without fresh evidence. This is a
**description of what must be emitted**, handed to the project terminal — not an implementation.

## Anchors
`docs/governance/UIUX-RUNTIME-CONTRACT.md` (P1, #920 — transport §5, freshness §4, baseline §0) ·
`schemas/uiux-audit-findings.schema.json` + `docs/governance/UIUX-GATE-POLICY.md` (P0, #918 — envelope shape,
severity map §3, evidence rule §4) · `scripts/uiux-pipeline.sh` evidence-ingest (#921 — default path
`evidence/uiux-findings.json`, `UX_EVIDENCE_ENVELOPE`, contract_version 1.0.0) ·
`docs/governance/UIUX-AUDIT-BLOCK-SPEC.md` (#916, Layer C/D) · Layer D/E consolidated report + decision surface
(#927) · gates ADR-102 / ADR-117. **Baseline of fact:** `banxe-ui` `origin/main` `b9645a2` (2026-06-27,
verified two clones). Operator directive 2026-07-01 (transport = default; emission handoff spec).
