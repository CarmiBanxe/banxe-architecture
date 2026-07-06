# docs/sources/ — Intake SSOT (System-of-Record for input documents)

> **Purpose:** canonical, verbatim store of every input document that feeds the
> Terminal-B intake pipeline (concept papers, external analyses, operator briefings,
> academic notes). Findings, pointer-docs, and register rows **REFERENCE** files in
> this directory — they never duplicate the body.

## Rule (canon — see ADR-161 and ADR-159 §"Terminal-B Operating Algorithm")

**Mandatory step 0 of any B-intake:** before extracting findings, the full source
MUST be persisted here **verbatim** as `docs/sources/<slug>-<yyyy-mm-dd>.md` (or
`.pdf`, `.txt` — original encoding preserved). The extraction (findings row in
`governance/NOVELTY-COLLECTION-REGISTER.md`, pointer-doc, ADR, coverage-log entry)
happens **after** persistence and links back to the SSOT path.

Rationale: prior to this rule, B-intake stored only short findings; the source body
was lost between operator paste and register append. Academic and regulatory inputs
were reduced to bullet-points, destroying the fidelity that later re-reads and audit
depend on. See ADR-161 for the full class-defect analysis.

## What belongs here

- Operator-supplied concept notes and briefings (verbatim).
- External research papers pasted into intake (verbatim body; add citation header).
- Regulatory circulars, whitepapers, and vendor docs used as inputs to a
  finding / ADR / spec.
- Any input the intake pipeline "reads" — the original text, not a summary.

## What does NOT belong here

- Findings, pointer-docs, or extracted summaries — those live in
  `governance/NOVELTY-COLLECTION-REGISTER.md`, `docs/adr/`, and per-sprint runbooks.
- Code, config, or infrastructure — those live in their canonical repos / trees.
- Machine-generated indexes — those are rebuilt on `main` by CI.

## Naming

```
docs/sources/<kebab-slug>-<yyyy-mm-dd>.md
```

- `<kebab-slug>` — short concept slug (`best-decision-concept`, `paybis-fee-report`,
  `fca-cass-15-circular`).
- `<yyyy-mm-dd>` — the operator-intake date (UTC), not the source publication date.
- Multiple intakes of the same slug on the same day: append `-<n>` (`…-2026-07-06-2.md`).

## Header format (in-file)

Every SSOT file starts with a minimal metadata header so downstream references stay
unambiguous:

```markdown
---
slug: <kebab-slug>
intake-date: <yyyy-mm-dd>
source-type: concept | paper | circular | briefing | other
provenance: <operator-supplied | url | doi | vendor>
sha256: <sha256 of body — computed after write>
---

# <Original title>

<verbatim body, unmodified>
```

The `sha256` is computed against the body after the front-matter and pinned so future
edits are detectable. Body edits are **forbidden** — a corrected source is a new file
with `-v2` or a new date suffix; the older file is preserved (append-only, I-24).

## Cross-references

- **ADR-161** — intake SSOT-persistence policy (this rule, formalised).
- **ADR-159 §"Terminal-B Operating Algorithm"** — where step 0 sits in the pipeline.
- **ADR-102** — no smart refactor / delete without duplication verification; applies
  to SSOT files (references first, then decision).
- **`.claude/rules/parallel-session-isolation.md`** Rule 6 — dirty-state reporting;
  SSOT files are append-only, foreign-session edits are reported, not auto-resolved.
- **`governance/NOVELTY-COLLECTION-REGISTER.md`** — findings register that
  references SSOT paths in the `rationale` column.
