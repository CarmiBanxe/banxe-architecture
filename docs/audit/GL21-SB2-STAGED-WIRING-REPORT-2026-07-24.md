# GL-21 (S-B2) — Staged Wiring + Adaptation Report — 2026-07-24

**BANK CORE / GL-21 STAGED WIRING / ADDITIVE / NO CUTOVER / NO COMMIT**

## Status: **STAGED — configuration + adaptation done, LIVE CUTOVER NOT performed**

Additive configuration/adaptation pass only. The Banksy engine on **:8200 was NOT stopped or restarted** and remained ONLINE throughout. Enable/cutover to live MCP = a separate step `[pending operator + HITL]` (AMBER for live).

## Step results

**Step 1 — MCP registration (config only):**
- Created `bank-rooms/F0-engine-manus-room/.mcp.json` registering `banxe` via `command: python`, `args: ["-m","banxe_mcp.server"]`, env `BANXE_API_BASE` + `PYTHONPATH` (env placeholders, **0 secrets**).
- Server **not started**, engine **not switched** — registration only. `banxe_mcp/server.py` is read-only in `banxe-emi-stack`.

**Step 2 — adaptation of 14 banxe-specific refs:**
- Classified in `BANKSY-CLAUDE-ADAPTATION-MAP.md`: **12 adapt / 2 reference-only** (cass15 + agents.md bank-specific clauses; financial-invariants/compliance carried reference-only per GL-18).
- **Edits NOT applied (0 files changed).** The 14 refs are the **arch-repo's own `.claude` canon**, not a Banksy handoff copy — mutating them is out of scope for a staged Banksy pass. Actual per-file adaptation → **`[pending human ratification]`**, targeting a Banksy-private `.claude` copy, not the shared canon.

**Step 3 — staged tools[] declaration:**
- Appended `[tools_staged]` to `banksy-engine.config.toml`: 6 bank MCP tools declared (`get_balance`, `initiate_payment`, `get_fx_quote`, `wallet_validate_address`, `kyc_status`, `notify_client`, per ADR-049 client-masks) with **`endpoint_set=false`** — declarative, **no live prod MCP connection**.

**Step 4 — dry-wiring verify (engine not restarted):**
- `.mcp.json` valid JSON ✓; 0 secrets ✓.
- `banxe_mcp/server.py` **dry-parsed OK** (AST parse; **not executed, not started as a service**) ✓.
- `python -m banxe_mcp.server` pattern registered ✓.
- `tools_staged` present (endpoint_set=false, 6 declared) ✓.
- **Engine :8200 still ONLINE** — `/health` green, `/status` status=online ✓.
- Live `/status` `tools[]` = **[]** (staged, not live) ✓ — confirms no cutover.

## Gate results

| gate | result |
|---|---|
| Canon-Guardian — no forbidden, env-secrets | **PASS** |
| Factory-Watchdog — 0 secrets + :8200 still up after wiring | **PASS** |

## Engine status (measured, unchanged)
`:8200` ONLINE · `/health` green · `status=online` · 32 modules · live `tools[]` empty (staged not live). The wiring was **additive** — the running engine was not touched.

## Explicit
- **STAGED — configuration+adaptation done; LIVE CUTOVER NOT performed.**
- **Enable/cutover = next separate step `[pending operator + HITL]`.**
- 14-ref adaptation = **mapped, not applied** (0 arch-repo canon files edited).

## Gated / open
- `[counsel]`: Midaz/MCP→ledger (tools declared but not live); Banksy↔Legion data-flow.
- `[pending human ratification]`: apply the 12 adapt classifications to a Banksy-private `.claude`; client-mask placement; AML-passport dedup; `executor.py`.
- `[pending prod-inference]` (GL-post-20): live LLM/MCP/ledger wiring.
- Legion (`:8080`) and `banxe-emi-stack` not modified; nothing committed.

---
**This does not replace legal advice.**
