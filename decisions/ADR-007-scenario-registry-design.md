# ADR-007: Scenario Registry Design — AMLTRIX Mapping Policy

**Status:** Accepted
**Date:** 2026-04-05
**Deciders:** BANXE Compliance Architecture
**Jurisdiction scope:** UK FCA (sole jurisdiction at time of decision)

---

## Context

BANXE requires a machine-readable catalogue of AML/fraud detection scenarios
(`scenario_registry.yaml`) that:

1. Links detection rules to recognised financial-crime typologies for audit traceability.
2. Supports internal, exploratory scenarios that may not yet have a confirmed
   AMLTRIX mapping without blocking development velocity.
3. Remains automatically verifiable in CI to prevent schema drift.

AMLTRIX (`framework.amltrix.com`) is the chosen external knowledge framework:
an open-source graph of 250+ AML techniques, 1 950+ defensive mappings, and
2 500+ risk indicators, endorsed by BIS and the Central Bank of Ireland.
AMLTRIX is versioned quarterly (`YYYY-QN`) and recommends pinning the version
used for any mapping to ensure stable references.

See ADR-010 for the decision to adopt AMLTRIX as reference taxonomy.

---

## Decision

Adopt a **hybrid mapping policy** governed by the `source` field:

| `source` value | AMLTRIX fields | `amltrix_pending_review` |
|---|---|---|
| `amltrix` | **Required** (non-null) | Not applicable |
| `hybrid` | **Required** (non-null) | Not applicable |
| `internal` | Optional (may be `null`) | **Required** (boolean) |

### Core invariant (enforced in CI)

> For all scenarios with `source: amltrix` or `source: hybrid`, the fields
> `amltrix.tactic_id`, `amltrix.technique_id`, and `amltrix.amltrix_version`
> are **mandatory** and validated by JSON Schema.
> For `source: internal`, these fields may be `null`, but
> `amltrix_pending_review` is **mandatory** and must be resolved at the
> next scheduled review cycle.

### Rationale

- **Strict-only** would block registration of EMI-specific or UK FCA-specific
  scenarios that have no AMLTRIX equivalent yet (e.g., FPS redirect / APP fraud,
  open-banking abuse). Forcing a poor mapping is worse than no mapping.
- **Optional-only** causes silent accumulation of unmapped scenarios with no
  visibility or ownership. Retroactive mapping becomes a separate, unplanned
  project.
- The hybrid approach gives speed for internal scenarios while creating an
  explicit, visible backlog via `amltrix_pending_review: true`.

---

## Schema

The authoritative JSON Schema is located at:

```
banxe-architecture/schemas/scenario_registry.schema.json
```

A copy is kept alongside the registry in `developer-core` for local validation:

```
developer-core/compliance/training/scenarios/scenario_registry.schema.json
```

CI validation (Python jsonschema):

```bash
python -m jsonschema \
  -i compliance/training/scenarios/scenario_registry.yaml \
  compliance/training/scenarios/scenario_registry.schema.json
```

Validation **must pass** as a required CI gate before merge to `main`.

---

## AMLTRIX Version Pinning

- The registry-level field `amltrix_catalog_version` records the AMLTRIX
  quarterly release against which the registry was last reviewed.
- Each individual AMLTRIX mapping carries its own `amltrix.amltrix_version`
  pin, which may differ from the registry-level pin for older, stable mappings.
- On AMLTRIX catalog upgrade: diff the new release, identify deprecated or
  renamed technique IDs, update affected scenarios, bump `amltrix_catalog_version`.

---

## Invariants

These invariants are enforced by `registry_loader.py` and the CI schema gate.
Violation of any invariant causes a `ValueError` at load time or CI failure.

**I-1 — Source validity**
Every scenario must have a `source` field with a value from the closed set
`{internal, amltrix, hybrid}`. Any other value or absence of the field is a
load-time error.

**I-2 — Mandatory AMLTRIX mapping for external scenarios**
If `source ∈ {amltrix, hybrid}`, then `amltrix.tactic_id`,
`amltrix.technique_id`, and `amltrix.amltrix_version` are required and
non-null. Violation causes immediate `ValueError` on `load_registry()`.

**I-3 — Managed debt for internal scenarios**
If `source = internal`, `amltrix_pending_review` is required and must be
boolean. `amltrix` may be a valid mapping object or explicit `null`. Absence
of `amltrix_pending_review` or a non-boolean value is a load-time error.

**I-4 — Fail-fast loading**
`registry_loader.py` must raise `ValueError` on any schema violation
(including duplicate `id` values, unknown `source`, AMLTRIX mapping rule
violations). It must not return a partially loaded registry.

**I-5 — Filter consistency**
`pending_review()`, `by_category()`, `by_engine()` operate only on a
fully-validated registry. Any scenario passing through a filter is guaranteed
to satisfy I-1 through I-3.

**I-6 — Identifier stability**
A scenario `id` (format `SCN-NNN`) is a stable key and must not be reused for
a different scenario. Renaming or merging scenarios requires an ADR, not a
silent edit to `scenario_registry.yaml`.

**I-7 — AMLTRIX version pin immutability**
`amltrix.amltrix_version` records the AMLTRIX catalog version used for the
mapping. Changing `amltrix_version` is only allowed when explicitly re-mapping
the scenario against a new catalog release; this is a significant change
requiring review and changelog entry (ADR preferred for material changes).

---

## Review Cadence

- **Quarterly**: sweep all scenarios with `amltrix_pending_review: true`.
  For each: attempt mapping, or create an ADR note explaining why the scenario
  is permanently `internal` and set `amltrix_pending_review: false`.
- **On AMLTRIX catalog release**: check for technique ID changes.
- **On new jurisdiction onboarding**: add `jurisdiction` enum value and
  document in ADR-008 (DEFERRED until second jurisdiction).

---

## Consequences

**Positive:**
- Internal scenarios are never blocked; development velocity is preserved.
- All unmapped scenarios are visible as a managed backlog, not silent debt.
- CI gate enforces the invariant automatically; no manual audit required.
- AMLTRIX version pins ensure reproducible, auditable mappings.

**Negative / Accepted trade-offs:**
- `amltrix_pending_review` adds a required field to all `internal` scenarios —
  minor authoring overhead.
- Pending-review backlog must be resolved quarterly; if neglected it becomes
  technical debt. Mitigated by review gate.

**Out of scope for this ADR:**
- Multi-jurisdiction routing (see ADR-008, DEFERRED).
- Marble/Jube integration for case management (see ADR-005).
- AMLTRIX sub-technique granularity below `technique_id`
  (`sub_technique_id` is supported as optional field, not required).

---

## References

- `developer-core/compliance/training/scenarios/scenario_registry.yaml`
- `developer-core/compliance/training/scenarios/scenario_registry.schema.json`
- `banxe-architecture/schemas/scenario_registry.schema.json` (canonical)
- ADR-010 — AMLTRIX taxonomy adoption
- ADR-008 — jurisdiction label (DEFERRED: multi-jurisdiction routing)
