# session_memory — deterministic session-memory substrate (MVP)

A small, auditable Python package that turns the repo's **existing** memory and
handoff artifacts into one normalized, machine-readable **session-start pack**.
It is not "AI memory magic" — it is a deterministic parser + extractor over
source-of-truth documents, with strict append-only discipline.

## What it reads (never mutates)
- `MEMORY.md`
- latest `docs/handoff/HANDOFF-*.md`
- latest `docs/handoff/session-transfer-package-*.md`

## What it emits (regenerable cache only)
- `docs/generated/session-memory/session-pack-<UTC>.json` (canonical artifact)
- optional `…-<UTC>.md` (human summary, `--md`)

Extracted fields: `repo_state`, `invariants`, `operator_gated`, `next_actions`,
`first_action`, `canon_pointers`, plus `sources` (path + line count + sha256)
and `warnings`.

## Files
| file | role |
|---|---|
| `schemas.py` | typed, JSON-able data structures (the stable contract) |
| `extract_handoff_facts.py` | pure markdown → facts extraction (no I/O, no clock) |
| `build_session_pack.py` | builder + CLI (`build` / `inspect` / `latest`) |
| `read_memory_pack.py` | read-only loader + markdown renderer |
| `tests/` | parser/extractor/builder behaviour |

## Commands (run from repo root)
```bash
# build the pack for a role (writes to docs/generated/session-memory/)
python -m session_memory.build_session_pack build --role factory --md

# inspect a specific pack (read-only)
python -m session_memory.build_session_pack inspect docs/generated/session-memory/session-pack-<UTC>.json

# show the newest generated pack (read-only)
python -m session_memory.build_session_pack latest

# tests
python -m pytest session_memory/tests -q
```

`--role` ∈ `central | factory | sub-a | sub-b` (default `central`) reorders
role-relevant `next_actions` / `canon_pointers` to the front — it **never**
adds, drops, or edits source truth.

## Guarantees (canon-aligned)
- **Append-only / read-only source:** source docs are opened read-only; output
  goes only to the regenerable `docs/generated/` cache.
- **No authority expansion:** read / prepare / propose only. No write-authority
  escalation, no daemon, no background service, no external DB.
- **Deterministic:** same inputs + same `--now` ⇒ byte-identical JSON. The clock
  is injectable (`--now`) so builds are reproducible and testable.
- **Fail-open on inputs, not on truth:** a missing/malformed doc produces a
  `warning` and a partial pack; it never fabricates facts.
- **Does not bypass CI/canon:** complements `.github/workflows/novelty-handoff.yml`
  (the append-only handoff validator); it does not replace or weaken it.

## How this extends into memoir / substrate later
This MVP is the deterministic floor a richer substrate can stand on:
1. **Indexing** — persist packs to the append-only ClickHouse audit sink
   (`decision_events`-style, I-24 / 5-yr TTL) keyed by `sha256` for recall.
2. **Semantic layer** — add embeddings over `sources`/`facts` for similarity
   recall, keeping this extractor as the deterministic ground truth.
3. **Diffing** — pack-to-pack deltas ("what changed since last session") feed a
   memoir timeline; the sha256 per source makes drift detection exact.
4. **Runtime hook** — a session-start step calls `build` and surfaces the pack
   in the HITL dashboard; still operator-gated, still no autonomous write.
5. **Cross-repo** — the same schema over `banxe-emi-stack` handoffs; one pack
   format, per-repo extractors.

None of these change the invariant: the substrate **proposes context**; the
human decides. Adoption of any runtime/DB step is a separate operator-gated ADR.
