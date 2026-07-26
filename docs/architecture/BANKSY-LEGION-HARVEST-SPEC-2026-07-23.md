# BANKSY ← LEGION/OpenManus — Harvest Spec (template only) — 2026-07-23

**BANK CORE / HARVEST-SPEC (DISPATCH TO FACTORY) / DOCS-ONLY / NO CODE COPIED HERE / NO COMMIT**

Dispatcher note: this document **only specifies** what Banksy harvests from Legion/OpenManus as **technology template**. The factory copies/adapts code later under audit — nothing is harvested or built by this spec.

**Concept:** Legion = external trusted supplier, **not** in Banksy's stack. Banksy takes only **technology patterns** (template), deploys them in **its own zone**, excludes the forbidden set, and is **not compiled over Legion**. Paths below spot-checked read-only in `/home/mmber/OpenManus`; two discrepancies flagged inline.

## §1 ADOPT — what Banksy takes (template, bank-limited)

| capability | Legion/OpenManus source path | why Banksy needs it | Banksy layer |
|---|---|---|---|
| Decision framework | `openmanus_rl/agents/{decision_agent,enhanced_decision_agent,smart_decision_agent,memory_enhanced_decision_agent}.py` + DecisionFramework/UtilityCalculator | CEO-conductor decides like a conductor | Role-1 (conductor) |
| Memory / context | `openmanus_rl/engines/memory_aware_streaming.py` + summarization pattern (`use_summary` / `max_history_length` / `summary_threshold`) | client-PM "remembers" the client | Role-2 (client-PM) |
| Tool-calling framework | `openmanus_rl/tool_calling/{registry,builtins,octotools_registry,octotools_bridge}.py` + `verl/verl/tools/{base_tool,schemas,mcp_base_tool}.py` + `verl/verl/tools/utils/mcp_clients/McpClientManager.py` | safe invocation of bank MCP tools | Substrate (Role-D) |
| Config pattern | OpenManus `config/config.toml` tiered model-map (tier→fallback→aliases, max_tokens/temperature) | Banksy config **structure** (own models, NOT Legion GGUF) | zone config |
| Reuse insight | `BANK_AI_ANALYSIS.md`, `COMPLIANCE_TOOLS_ANALYSIS.md` | reference analysis (Ballerine / open-kyc / FINOS OpenAML) — **not code** | reference only |

**Path corrections (flagged, not overridden):**
- `verl/verl/tools/tool_registry.py` cited in the audit is **NOT found** on disk → `[verify by factory]` (likely the registry role is covered by `tool_calling/registry.py` + `verl/.../base_tool.py`; do not cite a phantom path).
- `McpClientManager.py` real path is `verl/verl/tools/utils/mcp_clients/McpClientManager.py` (deeper than cited) — corrected above.

**Adaptation rule:** take as **TEMPLATE + rewrite for the bank-limited profile**; each module goes through the factory **Reviewer**.

## §2 FORBIDDEN — what Banksy does NOT take (Canon-Guardian blocks)

- **All TOR:** `tor_search_tool.py`, `tor_ip_check_tool.py`, `tor_tools_standalone.py`, `tor_integrated_tool.py`, `tor_monitor_agent*.py`, `tor_autostart.py`, `tor_complete_service.py`, all `SPRINT2/SPRINT8_TOR_*` docs, all `TOR_*` reports. (verified present in Legion; excluded from Banksy)
- **Web-scrape / crawl / OSINT:** Sprint2 "Advanced Web Scraping", Wikidata SPARQL crawl, any headless / browser / proxy / selenium / playwright.
- `openmanus_rl/tool_calling/executor.py` — **`[pending human ratification]` / `[verify by factory]`**: confirm whether direct execution is dangerous; if yes → EXCLUDE.
- **RL-training internals:** `verl/verl/workers/actor/*`, megatron, single_controller — not needed by Banksy (RL training, not banking). (verified present; excluded)
- **Direct Legion private-inference `:8080`** — EXCLUDED; Banksy reaches Legion only via external request/response for data-gathering.

## §3 Integration into the Banksy build

- These ADOPT components fold into `BANKSY-ENGINE-BUILD-SPEC-FOR-FACTORY-2026-07-23.md` (heart-stack 32) as reinforcement: **decision → Role-1**, **memory → Role-2**, **tool-framework → substrate**, **config → zone config**.
- Each ADOPT passes: **Reviewer** (self-critique + falsification) + **Canon-Guardian** (no forbidden set, no Legion-inference, bank-limited) + **Factory-Watchdog** (0 secrets).
- Harvest is **adaptation from template**, not compile-over-Legion; Banksy stays in its own zone.

## Gated / open

- `[pending human ratification]`: `executor.py` inclusion; AML passport dedup; expansion/ownership items (carried from build-spec).
- `[counsel]`: Banksy↔Legion cross-party data flow; Midaz/MCP→ledger; any regulated advisory surface.
- No Legion/OpenManus or `banxe-emi-stack` file is modified by this spec.

---
**This does not replace legal advice.**
