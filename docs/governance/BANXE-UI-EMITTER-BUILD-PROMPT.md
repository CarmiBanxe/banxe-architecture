# banxe-ui Evidence Emitter — transferable BUILD-PROMPT (for the project side)

> **Status:** governance artefact — the **canonical, ready-to-hand build-prompt** for constructing the
> `banxe-ui` evidence-envelope emitter. **Date:** 2026-07-01. **Owner-terminal: A (factory).**
> **Pointer-first and additive (ADR-102).**
>
> **This is a TASK, not code.** It is handed to the **project side** and **executed by the operator inside
> the `banxe-ui` repo, beyond the ADR-117 perimeter** (`banxe-ui` is project-owned). This document
> **implements no emitter**, writes no `banxe-ui` code, and **touches no `banxe-ui` repo, no
> `schemas/uiux-audit-findings.schema.json`, no `uiux-pipeline.sh` ingest, and no policy/spec** — it
> references them. It is derived from the emission spec `UIUX-EVIDENCE-EMISSION-SPEC.md` (#928) and restates
> none of it.

---

## 0. How to use this prompt
Hand this document to the implementer (project terminal, working in the `banxe-ui` repo). It is the
**single canonical source** for the emitter build. Wherever it fixes behaviour, that behaviour is
**normative** and traces to the emission contract; wherever it marks `[НЕИЗВЕСТНО]`, the implementer decides
at build time. The **authoritative contract is the emission spec (#928)** and the **P0 schema (#918)**; this
prompt is their executable framing.

**Verified baseline (source of fact):** `banxe-ui` `origin/main = b9645a2` (2026-06-27), confirmed from two
independent clones (per `UIUX-RUNTIME-CONTRACT.md` §0). Build against that verified reality.

## 1. What to build
Build an **evidence-envelope emitter** that `banxe-ui` runs in **its CI (the existing `quality-gate`
workflow)** and that **writes one envelope file** conforming to `schemas/uiux-audit-findings.schema.json`
(P0, #918, `contract_version 1.0.0`) to the repo-relative path **`evidence/uiux-findings.json`**. That path
is the **selected default transport** (#928 §1) and **matches the factory ingest default** (`uiux-pipeline.sh`
evidence-ingest, #921: `UX_EVIDENCE_ENVELOPE` fallback = `evidence/uiux-findings.json`), so the factory
consumes it **read-only** with zero configuration.

## 2. Envelope format (strictly per the P0 schema — do NOT redefine)
The emitted file MUST validate against `schemas/uiux-audit-findings.schema.json` (P0, #918):

```json
{
  "contract_version": "1.0.0",
  "commit_sha": "<banxe-ui frontend commit the evidence was generated against>",
  "generated_at": "<ISO-8601 UTC timestamp>",
  "results": [ /* one entry per audited requirement */ ]
}
```

Each `results[]` entry is a P0 `result` object (`additionalProperties: false`): required `requirement`,
`status` (`pass|advisory|fail|unknown`, default/fallback `unknown`), `severity` (`blocking|advisory`);
optional `artefact_ref`, `confidence`, `file_paths`, `impacted_flows`, `remediation`. The emitter **MUST NOT
add keys outside the schema** and **MUST NOT invent severities** — severity is read from
`UIUX-GATE-POLICY.md` §3 (#918), not decided at emission time.

## 3. Proof-of-loop (first slice) — axe_core_wcag_aa from the EXISTING CI
The first envelope emission is a **single real result** sourced from a check that **already runs and passes**
on `banxe-ui` main `b9645a2` — no new runner is required to light the loop:
- `banxe-ui` already runs **`axe-core` + `jest-axe`** (4 refs in `package.json`; `tests/a11y/` two suites)
  inside its **`quality-gate` CI workflow** (verified, `UIUX-RUNTIME-CONTRACT.md` §2).
- The emitter writes **one `result`** with `requirement: "axe_core_wcag_aa"`, `severity: "blocking"` (the one
  hard runtime gate, `UIUX-GATE-POLICY.md` §1), and `status` taken from the **actual CI run**: `pass` when
  the axe-core suite passes, `fail` when it does not, with `artefact_ref` pointing at the axe report.
- This single result **lights the hard WCAG gate end-to-end**: the factory ingest (#921) moves
  `axe_core_wcag_aa` from `unknown` to a **real `pass`/`fail`** sourced from the frontend CI.

## 4. The remaining requirements — emit as `status: unknown` until their runners exist
The four gaps genuinely absent on `banxe-ui` main `b9645a2` (`UIUX-RUNTIME-CONTRACT.md` §3) — **Playwright
e2e journeys, visual-regression diffing, viewport matrix, empty/loading/error state coverage** — MUST be
emitted (if present in `results[]`) with **`status: "unknown"`** and their policy severity (advisory until
the runtime exists). The emitter **MUST NOT assert these as `passed`** — each is a **separate project-side
slice** built later. Emitting them as `unknown` is correct and honest; omitting them entirely is also
acceptable (the factory treats an absent requirement as `unknown` by the same boundary).

## 5. Freshness — the P0 honesty boundary
`commit_sha` MUST equal the **`banxe-ui` frontend commit the evidence was generated against**. The factory
verifies presence, schema-validity, and **freshness**: if `commit_sha` does not match the audited frontend
revision (stale envelope), the factory treats the requirement as **`unknown` (`[НЕИЗВЕСТНО]`), never
`pass`** (`UIUX-GATE-POLICY.md` §4). A `pass` is honoured only with a **fresh** `commit_sha`/`artefact_ref`.
No runtime is asserted passed without fresh evidence.

## 6. Acceptance criteria (for the project terminal)
The emitter is accepted when **all** hold:
1. The committed `evidence/uiux-findings.json` is **schema-valid** against
   `schemas/uiux-audit-findings.schema.json` (P0).
2. `contract_version == "1.0.0"` and `commit_sha` is **fresh** (matches the audited `banxe-ui` frontend
   commit).
3. The **factory ingest (#921) in `uiux-pipeline.sh` moves from `unknown` to a real `pass`/`fail`** for
   `axe_core_wcag_aa`, sourced from the existing `quality-gate` CI run.
4. All other (unbuilt) requirements remain **`unknown`** correctly — none asserted `passed`.

The factory verifies 1–4 **read-only**; it does not write into `banxe-ui` and does not run the frontend
checks itself.

## 7. `[НЕИЗВЕСТНО]` — project-side decisions, not invented here
- **The exact location of the envelope inside the `banxe-ui` tree** — `evidence/uiux-findings.json` is fixed
  **relative to the point the factory reads** (the ingest default); whether `banxe-ui` produces it there
  directly or maps it there is a **project-side placement decision**.
- **The specific CI step / job that generates and commits the envelope** (name, trigger, which workflow it
  hangs on) is a **project-side implementation detail** — not named here, not invented.
- Whether/when to strengthen the committed-file transport to a **signed manifest** (#928 §1) — a later
  project/operator decision.

## 8. Scope / boundaries for the implementer
- Build the emitter **inside the `banxe-ui` repo, under the operator gate** (ADR-117 perimeter; `banxe-ui`
  is project-owned). Do **not** alter the P0 schema or the factory ingest — the envelope conforms to the
  schema as-is; the factory consumes it read-only.
- Commit the envelope at `evidence/uiux-findings.json` so the factory ingests it with zero configuration.
- Emit only what is truly evidenced: real `pass`/`fail` for `axe_core_wcag_aa` from the existing CI;
  `unknown` for everything unbuilt.

## 9. What this document did NOT touch
No `banxe-ui` code. No `banxe-ui` repo. No `schemas/uiux-audit-findings.schema.json`. No `uiux-pipeline.sh`
ingest. No policy/spec. This is a **build-prompt for project execution**, authored governance-side,
prepare-only.

## Anchors
`docs/governance/UIUX-EVIDENCE-EMISSION-SPEC.md` (#928 — the emission contract this prompt frames for
execution) · `docs/governance/UIUX-RUNTIME-CONTRACT.md` (#920 — verified baseline §0, existing-vs-missing
§2/§3, freshness §4, transport §5) · `schemas/uiux-audit-findings.schema.json` +
`docs/governance/UIUX-GATE-POLICY.md` (P0, #918 — envelope shape, severity map §3, evidence rule §4) ·
`scripts/uiux-pipeline.sh` evidence-ingest (#921 — default path `evidence/uiux-findings.json`,
`UX_EVIDENCE_ENVELOPE`, `contract_version 1.0.0`) · ADR-117 (regulated perimeter — build is operator-gated,
project-side, `banxe-ui`-owned) · ADR-102 (Duplication Audit — this restates none of the above). **Baseline
of fact:** `banxe-ui` `origin/main` `b9645a2` (2026-06-27, verified two clones). Operator directive
2026-07-01 (fix the transferable banxe-ui emitter build-prompt as a governance document).
