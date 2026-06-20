# Canon Reconciliation — ADR-117 (perimeter/hardware/org)

**Date:** 2026-06-21 · **Driver:** ADR-117 (Factory/Project Perimeter & Full-Cycle Org) · **Mandate:** ADR-116
**Principle:** Operator = canon, supreme over docs. Every contradiction is PUBLISHED; disputed items await operator decision (no invention beyond ADR-117).

ADR-117 source of truth:
- Factory = Legion (64 GB), model `qwen2.5-coder:14b-banxe-factory`, software-delivery only.
- Project = cluster evo1/evo2 (128 GB each); models `qwen3-banxe-v2`, `qwen3:235b-a22b`, `llama3.3:70b`, `qwen3-coder-next`, `glm-4.7-flash`, `gpt-oss-derestricted`, `qwen3.5/30b/4b`; lends compute to the factory during code-design.

## Contradiction registry

| File | Line | Old statement (≤15 words) | ADR-117 norm | Type | Operator decision |
|------|------|---------------------------|--------------|------|-------------------|
| docs/DEPLOYMENT-ARCHITECTURE.md | 31 | Legion RAM "16 GB" | Legion = 64 GB | hardware | RECONCILED (ADR-117) |
| docs/DEPLOYMENT-ARCHITECTURE.md | 26,33-34 | Legion = "developer terminal only / thin terminal" | Legion = Factory node, software-delivery only | perimeter/role | RECONCILED (ADR-117) |
| docs/DEPLOYMENT-ARCHITECTURE.md | 6 | Scope = "GMKtec EVO-X2 primary compute node" | Factory=Legion; Project=evo1/evo2 | perimeter | RECONCILED note added (ADR-117) |
| docs/DEPLOYMENT-ARCHITECTURE.md | 12-24 | Single "GMKtec EVO-X2 — AI Brain" 128 GB, "all services" | Project cluster = evo1/evo2 (128 GB each) | nodes | AWAITS OPERATOR — GMKtec↔evo1/evo2 mapping & service migration NOT asserted by ADR-117 |
| docs/DEPLOYMENT-ARCHITECTURE.md | 77-82 | Factory model absent; project models = 3 (qwen3-banxe-v2/glm/gpt-oss) | Factory model `qwen2.5-coder:14b-banxe-factory`; project list broader | models | RECONCILED (names per ADR-117; sizes AWAIT OPERATOR) |
| AGENT-ORG-STRUCTURE.md | 14 | Aider CLI = "единственный разработчик" (single dev) | Doubled dev headcount (≥2× capacity) | org | RECONCILED note (ADR-117); exact dev composition AWAITS OPERATOR |
| AGENT-ORG-STRUCTURE.md | 57-60 | Model list = 4 (qwen3-banxe-v2/glm/gpt-oss/235b-master) | Factory + project model sets per ADR-117 | models | RECONCILED (names per ADR-117) |

## Notes

- RECONCILED rows are corrected in-place in the named files (ADR-117-backed only).
- AWAITS OPERATOR rows: original text retained, annotated with a pointer here; not rewritten (no facts invented beyond ADR-117). Examples: whether GMKtec (192.168.0.72) is renamed/replaced by evo1/evo2 or decommissioned; migration of the GMKtec service inventory; exact model sizes/roles on evo1/evo2; exact doubled-dev composition.
- KPIs (ADR-117): coverage ≥85%, tech-debt <5%, 0 blocker/critical on merge, security-hotspot ≥95%, MTTD <24h — recorded for reference; enforcement is a follow-up factory work item.
