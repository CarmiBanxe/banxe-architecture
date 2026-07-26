# Banksy Engine — Build Manifest (factory build input) — 2026-07-23

**BANK CORE / BUILD MANIFEST / DOCS-ONLY / NO CODE ASSEMBLED HERE**
Concrete assembly input for the factory's GL-20 build. The dispatcher does **not** author the runnable modules; this manifest tells the factory exactly what to assemble, in what order, with which exclusions and gates. Reference source is read-only.

## Target zone
`bank-rooms/F0-engine-manus-room/runtime/` · bind port **8200** · `compiled_over_legion = false`.

## Assemble — heart-32 (adapt from banxe-emi-stack, read-only reference)

**Layer A (12) — shell sub-modules:** swarm/agents {base,behavior,geo_risk,product_limits,profile_history,sanctions}, design_pipeline/agents {compliance_ui,onboarding,report_ui,transaction_ui}, fx_engine/fx_agent, webhook_orchestrator/webhook_agent.
**Layer B (8) — orchestrator:** banking-engine/graph_sandbox, agent_routing/tier_workers, swarm/orchestrator, design_pipeline/orchestrator, open_banking/sca_orchestrator, midaz_mcp/{midaz_agent,midaz_client}, runtime_gate/budget.
**Layer C (5) — client-PM:** api/routers/{intent,support,notifications_hub,quant_advisory}, quant_advisory/service.
**Layer D (7) — substrate:** intent_layer/{canary,composition,observability,shadow}, agents/{_lineage,recorders}, banking-engine/compliance/guardrails_config.yaml.

**HEART_STACK = 32 verified files** (single canonical count).

## Harvest — Legion/OpenManus TEMPLATE (adapt, NOT compile-over)
- decision-framework: `openmanus_rl/agents/decision_agent.py` (+ enhanced/smart/memory variants) → Role-1.
- memory: `openmanus_rl/engines/memory_aware_streaming.py` + summarization → Role-2.
- tool-framework: `tool_calling/{registry,builtins}` + `verl/verl/tools/{base_tool,schemas,mcp_base_tool}` + `.../mcp_clients/McpClientManager.py` → substrate.
- config: tiered model-map structure (own models, not Legion GGUF).

## EXCLUDE (Canon-Guardian must verify absent)
TOR (`*tor*`), web-scrape/crawl/OSINT, proxy/selenium/playwright, RL-training (`verl/workers/actor/*`, megatron, single_controller), `executor.py` `[pending human ratification]`, direct-Legion-inference `:8080`.

## Wire
- Banksy-own inference (`${BANKSY_INFERENCE_URL}` / `${BANKSY_MODEL}`) — NOT Legion `:8080`.
- Bank MCP tools; Midaz/MCP→ledger stays gated `[counsel]`.
- Banksy↔Legion = external request/response only.
- Secrets via env; 0 in repo.

## Gate order (before ONLINE)
Reviewer (per module) → Canon-Guardian (no forbidden, compiled_over_legion=false, no-silent-rewrite) → Factory-Watchdog (0 secrets, process live, port 8200 listening) → install-audit → HITL-L4 (I-27).

## Status of this manifest
Build input only. **No module assembled yet** (zone has 0 python modules). Assembling runnable adapted code is the factory's engineering step.

---
**This does not replace legal advice.**
