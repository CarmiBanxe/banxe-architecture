# Banksy Engine — Launch Report (sandbox scaffold) — 2026-07-23

**BANK CORE / BANKSY ENGINE LAUNCH / SANDBOX SCAFFOLD / DOCS+CONFIG ONLY / NO COMMIT**

## Honest status up front

**What was done:** the Banksy Engine **zone was scaffolded** in its own path with a templated, sanitized config and a defined Legion interface. **What was NOT done:** a live, running multi-component engine was **not** brought up. This report states that plainly rather than claiming a running engine.

**Why not a full live bring-up:** the actual engine runtime code lives in `~/banxe-emi-stack` (read-only per the rules) and in OpenManus (read-only template); no production code was copied into the Banksy zone (that is the **factory's** assembly step). Models, dependencies, secrets, and ports are not wired. Starting real processes / binding ports for a bank engine is a heavy, stateful action requiring factory build + HITL. So this is a **truthful scaffold**, not a fabricated "engine online".

## What was deployed (Banksy own zone)

Zone: `bank-rooms/F0-engine-manus-room/runtime/`
- `banksy-engine.config.toml` — templated from OpenManus config (read-only), sanitized (no secrets; env placeholders), bank-limited profile, separate zone (`compiled_over_legion = false`).
- `banksy-legion-interface.md` — Banksy → Legion external request/response boundary (trusted supplier, data-gathering).

## Legion-extra functions EXCLUDED from Banksy (limited bank profile)

Explicitly disabled in the Banksy config (`[excluded_legion_functions]`):
- **TOR networking** (Legion-only) — excluded.
- **Headless browser** (Legion-only) — excluded.
- **Web-crawl / OSINT** (Legion-only) — excluded.
- **Direct use of Legion private inference** (`127.0.0.1:8080` llama-server) — excluded; Banksy uses its own inference.
- **Proxy / scrape** — excluded.

## Bank profile configured (scaffold; assembled later by factory)

- Role-1 CEO-conductor: `graph_sandbox`, `tier_workers` (PROPOSES only, I-27/HITL-L4).
- Role-2 client-PM: intent-layer + intent/support/notifications-hub/quant-advisory routers.
- Substrate: midaz MCP (gated `[counsel]`), budget gate, lineage/recorders, guardrails.
- MCP tools: bank profile only.

## Health-check (real, read-only)

| check | result |
|---|---|
| Zone files present | 2 (config + interface) |
| Config sections valid | 7 |
| Real secrets leaked into zone | **0** (all `${ENV}` placeholders) |
| Banksy engine processes running | **none** (scaffold only) |
| Banksy-own ports bound | **none** (4000 = existing LiteLLM, not Banksy; 8080/8081 = not bound here) |
| Legion runtime on this machine | **absent** (Legion is external, on its own laptop) — correct separation |

## Banksy ↔ Legion boundary (confirmed in scaffold)

- Two separate engines / two separate zones; **not** a shared runtime.
- Banksy → Legion = external request/response for client-info gathering + special databases.
- Legion outside the bank; trust boundary external; cross-party data flow → `[counsel]`.

## Next steps (factory)

1. Factory assembles the Banksy runtime code in the zone from the template (not by copying read-only banxe-emi-stack).
2. Wire Banksy-own inference + bank MCP tools; keep Legion-extras excluded.
3. Bring up components under install-audit + HITL; only then bind ports and report "online".
4. Establish the Legion external data-gathering channel with data-governance sign-off.

## Open / gated

- `[pending human ratification]`: AML passport dedup (`aml_orchestrator.yaml` vs canonical `banxe_aml_orchestrator.yaml`); expansion-agent selection; fx_engine / design_pipeline ownership.
- `[counsel]`: Midaz/MCP→ledger; Banksy↔Legion cross-party data flow; any regulated advisory surface.
- No runtime (banxe-emi-stack) or Legion repo was modified; nothing committed.

---
**This does not replace legal advice.**
