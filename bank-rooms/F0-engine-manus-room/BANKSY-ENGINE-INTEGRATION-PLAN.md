# BANKSY ENGINE — Integration Plan — 2026-07-23

**BANK CORE / INTEGRATION PLAN (PLAN-ONLY, NOTHING LAUNCHED) / DOCS-ONLY / READ-ONLY RUNTIME**

## Status
**Concept + parts exist; a single unified stack is NOT assembled.** Canon, ADRs (045/049/060/154/160/171), CEO/dept orchestrator souls, runtime heart-stack, and the OSS template all exist separately. This plan describes assembling them into one **Banksy Engine** deployed **in its own zone** from the **same OSS technology as a TEMPLATE** — **NOT compiled over Legion/OpenManus**. Banksy and Legion are two separate engines/worlds; Legion is an external trusted data supplier. **No code is built or launched here beyond the sandbox scaffold** — the factory assembles production code later; runtime read-only.

## Template base (NOT a compile-over)
- **OpenManus** technology (Manus base, 711 orch-signals) is taken as a **template** (same tech/config), deployed **separately** in the Banksy zone; supplemented conceptually by `banxe-ai-infrastructure`, `vibe-coding`, `merged-repo`, `developer-core`.
- Governance overlay: LangGraph / A2A / MCP / LiteLLM + guardrails (per canon).
- **Legion-extra functions NOT permitted to Banksy are excluded** (TOR networking, headless browser, web-crawl/OSINT, direct use of Legion's private inference). Banksy uses its own inference and reaches Legion only via an external request/response data-gathering interface.

## Assembly steps (plan)
1. **Fix concept baseline:** freeze the canonical concept (legion + two-engines + Legion Q&A) and the ADR set (045/049/060/154/160/171) as the engine spec.
2. **Compile CEO-conductor (Role 1):** assemble the orchestrator layer — ceo-orchestration soul/passport + orchestration-tree + the dept orchestrator souls (AML/CFO/webhook/SEPA/SWIFT) over graph_sandbox + tier_workers. This is the chairman/CEO brain coordinating all department heads.
3. **Compile client-PM (Role 2):** wire the intent-layer + client-intent-record (ADR-171) + intent/support/notifications-hub/quant-advisory routers + quant_advisory service into the friendly client personal-manager surface.
4. **Enable substrate:** midaz MCP (gated `[counsel]`) + budget gate + lineage/recorders + guardrails config as the safety/observability floor.
5. **Fold in expansion-agents:** absorb reusable agents (swarm/*, ObservabilityAgent, NotificationAgent) as engine sub-modules for multiplicative growth — which ones is `[pending human ratification]` `[audit]`.
6. **Wire heart ↔ 17 departments ↔ client:** conductor coordinates all F1–F4 room heads (129 bank agents, BANK-MASTER); client-PM contacts the client directly. No bank-room row is moved into the engine.
7. **Gated verification:** each layer needs its own install-audit before "integrated" is claimed; nothing is installed by this plan.

## Connection points
- **heart ↔ departments:** CEO-conductor ↔ 17 room heads (see `../../docs/governance/AGENT-REGISTRY-BANK-MASTER-2026-07-22.md`).
- **heart ↔ client:** client-PM layer = direct client contact.
- **heart ↔ external partners:** FACTORY (build/QA) and REPAIR-BRIGADE (self-heal) sit **outside** the bank; they build/monitor, they are not part of the engine or the rooms.

## Guardrails
- No code assembled here (factory's job later); docs only.
- Only engine-relevant files ingested; P9 10547-file sweep not pulled in wholesale.
- Contested modules (fx_engine, design_pipeline ×4, expansion-agent selection) stay `[pending human ratification]`.
- Midaz/MCP→ledger and any regulated advisory surface → `[counsel]`.
- **HEART_STACK = 32 verified files** (count closed; the earlier "21" is superseded — no reconcile outstanding).

## References — MemoHarness Integration
- `docs/adr/ADR-182-memoharness-banksy-binding.md` — DRAFT concept-only integration ADR (dual-project adapter contract; retro-binding of merged MemoHarness A1/A2/A3 to Banksy engine as second consumer).
- Antecedents: ADR-135-A / 136-A / 166-A (all merged, factory scope). Banksy consumes MemoHarness as feature via GL-*/HITL-L4/I-27 gating (concept only, no operational integration yet).

---
**This does not replace legal advice.**
