---
il_ts: 2026-07-05T02:09:52Z
session_id: agent-factory-fleetsync-placement-backref
source: agent-factory
status: PROPOSED
---

# Fleet doc-sync — placement back-reference in clickhouse_writer + spec_first_auditor (per #1034 note)

## What

Close the matrix↔passport placement-sync gap #1034 flagged: the #1012 placements existed in
AGENT-ORG-ASSIGNMENT-MATRIX (the SSOT) but weren't visible from the passports. Add a `placement:` **reference**
block (matrix stays authoritative; not a hard-asserted duplicate) reflecting the PROPOSED-pending-ratification
status.

## Boundaries

Doc-only, prepare-only. Reference-only (no department hard-asserted — placements are PROPOSED/pending per matrix).
No status change / no activation. spec_first_auditor already had plane:DEVELOPER; ref added for consistency.
IL minted redis-serialized at ratification.

## Anchors

`agents/passports/clickhouse_writer.yaml` · `agents/passports/spec_first_auditor.yaml` ·
`docs/governance/AGENT-ORG-ASSIGNMENT-MATRIX.md` §UNMAPPED · `docs/governance/UNMAPPED-AGENTS-PLACEMENT.md` (#1012) ·
`docs/audit/FLEET-PASSPORT-BINDING-CONFORMANCE-2026-07-05.md` (#1034 systemic note).
