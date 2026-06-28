---
il_ts: 2026-06-28T14:30:00Z
session_id: agent-factory-agenteng05-behavior-canon
source: factory
status: prepared
---

## Summary

Append-only behavior/decision-canon section added to `docs/agent-engine-dossier/SRC-09-preaudit-synthesis.md`.
Content from A1 audit (canon root, origin/main):

- ADR-025 agent-interaction-canon (via AGENT-INTERACTION-CANON.md): decision-policy (no-ask, read-only-inventory-then-decide, 6-source priority)
- IL-CANON-04 best-decision-rule: formal BEST DECISION principle (layer 3 of 4-layer canon)
- UNIVERSAL-CANON-BEST-SOLUTION-SEQUENTIAL: best-solution + sequential one-artifact
- UNIVERSAL-CANON-TOPOLOGY: central/left-factory/right terminal topology
- Cross-ref: target-audit #842 GAP "execution sandbox contract не формализован" → ADR-025 as partial formalization
- Distinction: ADR-025 governs fleet-agent (factory); explicit-permission governs central-terminal — different layers, PARTIAL distinction (not conflict)

## Change

- File modified: `docs/agent-engine-dossier/SRC-09-preaudit-synthesis.md` (append-only)
- New section: "Agent behavior/decision canon (A1 audit)"
- Zero duplication of existing L0 fleet/structural content in SRC-09
- All content sourced from verified canon files in docs/canon/ and instruction-ledger/

## References

- AGENT-INTERACTION-CANON: docs/canon/AGENT-INTERACTION-CANON.md (ADR-025 acceptance via 2026-05-04)
- IL-CANON-04: instruction-ledger/IL-CANON-04-best-decision-rule.md
- UNIVERSAL-CANON-BEST-SOLUTION: docs/canon/UNIVERSAL-CANON-BEST-SOLUTION-AND-SEQUENTIAL-2026-05-25.md
- UNIVERSAL-CANON-TOPOLOGY: docs/canon/UNIVERSAL-CANON-TOPOLOGY-CLARIFICATION-2026-05-22.md
- Target-audit: #842 GAP "execution sandbox contract не формализован"
- ADR-143-A: IL allocator
- ADR-144: orphan-check 0
