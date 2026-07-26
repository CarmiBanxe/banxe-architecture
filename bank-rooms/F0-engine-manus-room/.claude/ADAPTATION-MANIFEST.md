# Banksy F0 .claude Adaptation Manifest — 2026-07-24

**Banksy-private, F0-facing.** Adapts the 14 banxe-specific refs (source = arch-repo `.claude/`, left intact). Additive; no legacy deletion.

## Substitution rules
- `INSTRUCTION-LEDGER` / `IL-NNN` -> **GENERAL-LINE ROADMAP** / **GL-NN**
- `banxe-architecture` -> **F0 BANKSY-ENGINE docs** (bank-rooms/F0-engine-manus-room/*)
- `banxe-emi-stack` -> **read-only external reference** (not Banksy's stack)
- `banxe_mcp` -> external MCP via `.mcp.json` (gated [counsel])
- `financial-invariants`, `cass15`, `compliance-boundaries` -> **reference-only** (bank regulatory canon, NOT applied to Banksy art-layer)

## Per-file result (14)
| file | result |
|---|---|
| CLAUDE.md | adapt -> Banksy identity (F0) |
| agents/controller.md | adapted -> .claude/agents/controller.md |
| commands/docs-build.md | adapt (generic; banxe paths -> F0) |
| commands/new-adr.md | adapt (banxe-architecture -> F0 BANKSY-ENGINE docs) |
| commands/validate-mermaid.md | adapt (generic) |
| rules/agents.md | adapted -> .claude/rules/agents.md |
| rules/cass15.md | **reference-only** -> .claude/rules/cass15.reference-only.md |
| rules/infrastructure.md | adapted -> .claude/rules/infrastructure.md |
| rules/parallel-session-isolation.md | adapted -> .claude/rules/parallel-session-isolation.md |
| rules/testing.md | adapted -> .claude/rules/testing.md |
| settings.json | adapt (strip banxe-specific hooks) [pending] |
| skills/github-navigation | adapt (generic) |
| skills/spec-writing | adapt (generic) |
| skills/testing | adapt (generic) |
| financial-invariants (referenced) | **reference-only** |

**This does not replace legal advice.**
