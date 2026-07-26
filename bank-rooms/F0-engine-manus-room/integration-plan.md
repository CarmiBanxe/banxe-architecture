# ENGINE-MANUS integration plan — 2026-07-23

**BANK CORE / INTEGRATION PLAN (PLAN-ONLY, NOTHING LAUNCHED) / DOCS-ONLY / READ-ONLY RUNTIME**

## Status
**Created, NOT integrated/installed.** Today the heart is a "label-heap" (Layer-A 12 helper files) plus scattered orchestrator/client/substrate files. This plan describes assembling the 4 layers into one multi-layer ENGINE-MANUS. **No step is executed here** — this is design only; runtime is read-only.

## Assembly steps (plan)
1. **Absorb the shell (Layer A):** pull the 12 helper sub-modules **inward** into the heart as sub-modules of ENGINE-MANUS. Do **not** distribute them to other rooms.
2. **Stand up the orchestrator (Layer B):** wire graph_sandbox + tier_workers + the three orchestrators (swarm/design/SCA) + midaz MCP + budget gate into the single coordination brain (chief-conductor role). Midaz/MCP→ledger remains gated `[counsel]`.
3. **Connect the client-PM (Layer C):** bind intent/support/notifications-hub/quant-advisory routers + service as the direct, friendly client contact (personal-manager role).
4. **Enable the substrate (Layer D):** turn on intent-layer canary/composition/observability/shadow + lineage/recorders + guardrails config as the safety/observability floor beneath A–C.
5. **Wire heart ↔ 17 departments:** conductor coordinates all F1–F4 room heads (129 bank agents) — reference BANK-MASTER; no bank-room row is moved into the heart.
6. **Verify (later, gated):** each step needs its own install-audit before it is treated as integrated; nothing is "installed" by this plan.

## Guardrails
- Heart-related files are collected inward only; nothing torn out to other rooms (operator directive).
- No files invented beyond the audited/verified set (**HEART_STACK = 32 verified files** across A–D; the earlier "21" figure is superseded — count closed at 32).
- Contested Layer-A modules (fx_engine, design_pipeline ×4) stay `[pending human ratification]` until `[audit]`.
- External companies (FACTORY, REPAIR-BRIGADE) are not part of the heart or the bank rooms.
- No deploy/launch; all legal → `[counsel]`.

## Open items
- `[audit]` reconcile the 21-vs-32 file count; ratify the contested Layer-A modules.
- `[audit]`/`[factory]` sequence install-audits for B→C→D before any "integrated" claim.
- `[counsel]` Midaz/MCP→ledger and any regulated client-PM advisory surface.

---
**This does not replace legal advice.**
