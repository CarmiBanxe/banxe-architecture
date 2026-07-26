# GL-post-21 — MCP Re-Cutover LIVE Report — 2026-07-24

**BANK CORE / GL-post-21 RE-CUTOVER / HITL-AUTHORIZED (2026-07-24) / ADDITIVE / NO COMMIT**

## Status: **LIVE** — 6 MCP tools live, real read round-trip green, :8200 + :8000 both up

The previously-blocked MCP cutover is now **LIVE**. Backend :8000 up removed the blocker; a real,
non-mutating read round-trip through `banxe_mcp` returned HTTP 200 with real data; `endpoint_set` flipped
to `true`; the Banksy engine was controlled-restarted and now surfaces the **6 tools** in `/status`,
green, with `:8000` wired. Write-tools remain declared-only `[counsel]`.

## ШАГ 0 — snapshot
- Backup: `banksy-engine.config.toml.pre-recutover.bak`; pre `/status` saved (`tools=[]`, `endpoint_set=false`).

## ШАГ 1-2 — MCP + REAL read round-trip (measured, read-only)
- `banxe_mcp.server` started with `BANXE_API_BASE=http://127.0.0.1:8000`, `PYTHONPATH` (env-only).
- `get_account_balance("test-account-001")` → **HTTP 404** (no seeded account — real backend response, transport alive; not "unavailable").
- **Green round-trip:** `fx_get_rates()` → `:8000/v1/fx/rates` → **HTTP 200**, real body
  `{"GBP/EUR":"1.17","GBP/USD":"1.27","GBP/CHF":"1.13","GBP/PLN":"5.05","GBP/CZK":"29.5","EUR/USD":"1.08"}`.
  Read-only, non-mutating → **PASS** (backend reachable, real data, not Error/unavailable).
- Contrast with pre-cutover: previously `Error: BANXE API unavailable` — blocker now cleared.

## ШАГ 3 — enable + controlled reload
- `[tools_staged]`: `endpoint_set=true`, `endpoint="http://127.0.0.1:8000"` (localhost, no creds).
- `banksy/main.py` (additive): when `endpoint_set=true`, register the 6 declared tools → `STATE["tools"]`.
- `py_compile` OK; dry STATE build → 6 tools. **Controlled restart of ONLY the Banksy process**
  (`python3 banksy/main.py`), immediate re-verify.

## ШАГ 4 — LIVE verify (measured NOW)
- Engine pid 354066 owns `:8200` (`ss` confirmed). `/health` = `{"status":"green","engine":"banksy","modules":32,"port":8200}`.
- `/status`: `status=online`, `tools_endpoint_set=true`, `tools_endpoint=http://127.0.0.1:8000`,
  **`tools=["get_balance","get_fx_quote","initiate_payment","kyc_status","notify_client","wallet_validate_address"]` (6, non-empty)**.

## ШАГ 5 — gates
| gate | result |
|---|---|
| Canon-Guardian — `forbidden_hits=[]`, `compiled_over_legion=false`, Legion `external-request-response` | PASS |
| Factory-Watchdog — 0 secrets in edited files (endpoint = localhost, env-only creds) | PASS |
| Factory-Watchdog — :8200 green + :8000 up + banxe_mcp read round-trip green | PASS |
| Live proof — `/status tools[]` non-empty (6) + `endpoint_set=true` | PASS |

## Ports (measured)
`:8200` Banksy green (pid 354066) · `:8000` backend `{"status":"ok",...}` · both UP simultaneously.

## Rollback (available, not used)
Round-trip green + engine green → no rollback. If needed: restore `*.pre-recutover.bak`, revert `main.py`,
`endpoint_set=false`, stop `banxe_mcp`, restart engine.

## Gated (unchanged)
- **WRITE-tools stay `[counsel]`**: `initiate_payment` / Midaz-MCP→ledger declared but **not authorized for live write**;
  round-trip used read-only `fx_get_rates` only — no write-tool invoked.
- Frankfurter :8181 down (affects `get_exchange_rate` only, not the cutover path).
- Legion (:8080) untouched, external-only.

---
**This does not replace legal advice.**
