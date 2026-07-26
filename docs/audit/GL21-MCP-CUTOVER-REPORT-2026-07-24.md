# GL-21 — MCP Cutover Report — 2026-07-24

**BANK CORE / GL-21 MCP CUTOVER / HITL AUTHORIZED / NO COMMIT**

## Status: **FAILED-BLOCKED — NOT LIVE** (cutover halted at round-trip; engine safe, unchanged)

The live MCP cutover **did not complete**. It was **halted at the real read round-trip** (per the STOP rule) because the banxe FastAPI backend that `banxe_mcp.server` proxies to is **not running**. The Banksy engine on **:8200 was not touched** (still ONLINE), and the config was **not flipped** (`endpoint_set` remains `false`). No rollback was needed — the system never left its safe pre-cutover state.

## Step results

**Step 0 — snapshot (done):**
- Backup: `bank-rooms/F0-engine-manus-room/runtime/banksy-engine.config.toml.pre-cutover.bak`.
- Pre-cutover `/status`: `status=online, tools=[]` (saved).

**Step 1 — start banxe_mcp.server (BLOCKED at backend):**
- Deps: `httpx` OK, `mcp` OK, `fastmcp` MISSING (import still succeeds).
- `banxe_mcp.server` **imports OK** (dry, PYTHONPATH=banxe-emi-stack).
- Its tools call a **banxe FastAPI backend** via `_api_get`/`_api_post` (`BANXE_API_BASE`, uvicorn `:8000`). **No banxe backend is listening** (`:8000/:8090` unbound).

**Round-trip (real, read-only, non-mutating):**
- Invoked `banxe_mcp.get_account_balance("test-account-001")`.
- **Measured result:** `Error: BANXE API unavailable. Ensure uvicorn is running on :8000` → **round-trip FAILED**.

**Step 2 — enable tools:** **NOT performed.** Because the round-trip cannot succeed without the backend, `endpoint_set` was left `false`; the engine was **not restarted**. Enabling "live" tools with no reachable backend would be a false LIVE.

**Step 3 — LIVE verify:** N/A — LIVE not declared. `/status` `tools[]` remains `[]` (correct: not live).

## Gate results

| gate | result |
|---|---|
| Canon-Guardian — no forbidden, `compiled_over_legion=false`, Legion external-only | **PASS** |
| Factory-Watchdog — 0 secrets; engine :8200 up | **PASS** |
| Factory-Watchdog — banxe_mcp live + backend reachable | **FAIL** — backend (uvicorn :8000) not running |
| Reviewer — cutover-diff | **N/A** — no cutover applied (endpoint_set unchanged) |

## Engine status (measured, unchanged)
`:8200` ONLINE · `/health` green · `status=online` · live `tools[]` = **[]** · `endpoint_set=false`. Engine untouched.

## Rollback
- **Not required** — no change was applied (endpoint_set never flipped, engine never restarted).
- Backup retained for safety: `banksy-engine.config.toml.pre-cutover.bak` (identical to current).

## Blocker + next step
- **Blocker:** the banxe FastAPI backend (`uvicorn` on `:8000`, `BANXE_API_BASE`) is not running; `banxe_mcp.server` cannot serve live tool calls without it. Starting the full `banxe-emi-stack` backend is a **separate authorized step** (out of scope here — banxe-emi-stack is read-only reference).
- **Re-run cutover** after the banxe backend is up: start `banxe_mcp.server`, confirm a green read round-trip, then flip `endpoint_set=true` and hot-reload — only then LIVE.

## Gated / open
- `[counsel]`: Midaz/MCP→ledger write-tools (`initiate_payment`) — never called; live use gated.
- `[pending]`: banxe backend bring-up; then MCP cutover re-run.
- Legion (`:8080`) and `banxe-emi-stack` not modified; nothing committed.

---
**This does not replace legal advice.**
