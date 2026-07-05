---
il_ts: 2026-07-05T01:54:25Z
session_id: agent-factory-fleetstubs-schema-upgrade
source: agent-factory
status: PROPOSED
---

# Fleet stubs — schema-conformance upgrade of 3 governor passports (per #1034)

## What

Bring the 3 schema-nonconformant governor stubs (#1034 finding) up to agent_passport.schema.json shape by
ADDING the missing required fields + department/human_double. **No activation** — all stay status: PROPOSED (I-27).

## Placement (evidence-grounded, from #1034 + analogous passports)

- **adverse_media_governor** → Compliance/Adverse-Media(EDD); MLRO; CTX-01; AMBER; L2.
- **regulatory_returns_governor** → Reporting/FCA-Regulatory; CFO+MLRO; CTX-10-REPORTING; RED; L2 (mirrors reporting_agent).
- **safeguarding_recon_governor** → Finance/Safeguarding; CFO+MLRO; CTX-01; RED; L2 (HITL-011 shortfall gate).

Added per passport: agent_id (from id), name, version, level, trust_zone, capabilities, ports (inbound/outbound),
bounded_context, invariants, governance{change_class:CLASS-B, owner}. Legacy stub fields (gap/domain/skills/etc.)
preserved. trust_zone/level are proposed values for operator ratification.

## Verify

All 3: valid YAML, all 10 schema-required fields present, status PROPOSED (none activated).

## Boundaries

Prepare-only. CLASS-B passports — WRITTEN not ACTIVATED (I-27; operator ratifies merge). No SOUL/rego/runtime
change. No agent added to AGENT_REGISTRY/swarm.yaml. IL minted redis-serialized at ratification.

## Anchors

`agents/passports/{adverse_media,regulatory_returns,safeguarding_recon}_governor.yaml` ·
`schemas/agent_passport.schema.json` · `docs/audit/FLEET-PASSPORT-BINDING-CONFORMANCE-2026-07-05.md` (#1034).
