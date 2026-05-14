# Runbook: Emergency Canon Amendment
## Trigger
Production incident requires immediate canon change that cannot wait for full factory loop.
## Steps
1. Operator declares emergency (verbal or chat).
2. Sub-A or Central Claude Code drafts amendment directly.
3. Skip evaluation orchestrator (emergency exemption).
4. Guardian override label applied: `guardian-override-approved-factory`.
5. Commit with message prefix `emergency:` and IL ref.
6. Within 24h: retrospective full evaluation + Ruflo checkpoint for audit.
## Constraints
- Emergency amendments are append-only (INV-10).
- Cannot weaken existing invariants (precedence order: FCA > invariants > ADRs).
- Must be logged in GAP-REGISTER.md with `EMERGENCY` tag.
