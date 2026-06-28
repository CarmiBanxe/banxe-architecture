---
il_ts: 2026-06-28T00:00:00Z
session_id: agent-factory-agenteng02-src01-descriptors
source: factory
status: prepared
---

## Summary

Append-only OSS descriptor section added to `docs/agent-engine-dossier/SRC-01-engine-landscape.md`.
Descriptor layer sourced from corpus Part 1: 10 OSS + Manus reference.
Existing OSS name list and BANXE-STATUS mapping NOT duplicated — only cross-referenced.

## Change

- File modified: `docs/agent-engine-dossier/SRC-01-engine-landscape.md` (append-only)
- New section: "OSS Descriptors (Corpus Part 1)"
- 11 rows: OpenManus, OWL, AutoGPT, CrewAI, LangGraph, AutoGen, AgentScope, MetaGPT, Haystack, TaskWeaver, Manus
- Zero mutations to existing content

## References

- Corpus: Part 1 (operator-provided)
- Source file: `docs/agent-engine-dossier/SRC-01-engine-landscape.md`
- ADR-144: orphan-check 0

## Amendment A1 (2026-06-28)

Added rationale section "Rationale — why BANXE needs a Manus-class engine (Corpus §1.1)":
- 5 Manus-class defining properties: autonomous decomposition, tool selection, parallel/sequential execution, cross-session context, error adaptation
- 3 Manus-class key properties table: async execution, multiagent parallel execution, virtual file system
- Banking coordination diagram (international transfer, ①–⑬ steps): parallel fanout (compliance checks) → sequential (ledger + routing)
- BANXE-status mapping: async=PRESENT (CASS 15 daily recon), parallel=PRESENT (swarm.yaml), virtual-FS=PARTIAL (ClickHouse+Redis+Qdrant), full-orchestration=NOT_DEPLOYED (GAP #842)
- Marker: [ФАКТ из корпуса §1.1]
- No duplication of existing descriptor/name-list/BANXE-STATUS content
- File: docs/agent-engine-dossier/SRC-01-engine-landscape.md (93 lines → 164 lines)

## References

- Source: Corpus §1.1 (operator-provided)
- ADR-060 (multi-actor orchestration)
- ADR-049 (Intent Dispatcher) — NOT DEPLOYED
- GAP #842 (banking-coordination orchestration)
- Compliance swarm: agents/compliance/swarm.yaml
- CASS 15: services/recon/

## ADR-144

Orphan check status: 0 orphans (will verify after build_ledger)
