---
il_ts: 2026-07-08T21:17:12Z
session_id: agent-factory-session-memory-mvp-reclassify
source: CEO
status: PROPOSED
---
### Reclassify session_memory — read-only session-pack builder, NOT a memory substrate (text-only correction)

Corrects the terminology on the open session_memory MVP (PR #1104): session_memory is a **read-only
session-pack builder** over MEMORY.md + docs/handoff/HANDOFF-*.md + the transfer package — it is **NOT a memory
substrate** and **does NOT participate in ADR-137 PRECOND-04 (agentmemory XOR memoir)**. Read-only over source
handoff docs; append-only to a regenerable cache; complements memoir/agentmemory, never competes. Removes the
false PRECOND-04 XOR implication carried by the earlier "substrate" wording. **Text/metadata only — no .py, no
schema, no behavior change** (README.md + PR title). The prior shard IL-... (agent-factory-session-memory-mvp) is
NOT edited (append-only, I-24); this is an additive correcting record. Refs: memoir reconciliation; ADR-137
(memoir pilot) / ADR-165 (memoir HOW); PRECOND-04; I-24; ADR-102/119/120.
