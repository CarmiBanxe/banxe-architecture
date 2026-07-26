# banxe FastAPI Backend :8000 — Bring-Up Report — 2026-07-24

**BACKEND BRING-UP / OPERATOR-AUTHORIZED (variant A) / LAUNCH-ONLY / NO CODE MOD / NO COMMIT**

## Status: **UP** — backend :8000 online, health-verified, :8200 Banksy preserved

The banxe FastAPI backend was started (launch only — no code modified). `/health` returns HTTP 200
with a real body; startup completed with no crash. The Banksy engine on :8200 was **not touched**.

## ШАГ 1 — redis blocker resolved (minimal path = **Variant 1a**, no redis)
- `api/deps.py`: webhook adapter selected by env `WEBHOOK_RELIABILITY_ADAPTER`, **default `"in_memory"`**;
  redis is used **only** when set to `"redis"` (lazy `redis.Redis.from_url` inside that branch).
- `api/main.py` `lifespan` connects to **no** redis at startup (log-only).
- Redis usage elsewhere (`sanctions_rescreen.py`) is lazy (inside handler), not startup.
- **Decision:** started with `WEBHOOK_RELIABILITY_ADAPTER=in_memory` (+ `GABRIEL_ADAPTER=stub`) →
  **redis NOT required**; redis:6379 left DOWN. No EMI stack brought up; no redis container started.

## ШАГ 2 — start (measured)
- Launched from `banxe-emi-stack/.venv`: `uvicorn api.main:app --host 127.0.0.1 --port 8000`, detached.
- Process **alive**: pid 325864 (`.venv/bin/python3 uvicorn api.main:app`). Secrets via env only (0 printed/committed).

## ШАГ 3 — health verify (measured, real responses)
| endpoint | HTTP |
|---|---|
| `/health` | **200** — body `{"status":"ok","version":"1.0.0","plane":"Product"}` |
| `/docs` | 200 |
| `/openapi.json` | 200 |
| `/` | 404 (no root route — expected) |
- `:8000` **LISTENING**. Log: `Application startup complete` / `Uvicorn running on http://127.0.0.1:8000` — no crash, no 500.

## ШАГ 4 — gates
| gate | result |
|---|---|
| Canon-Guardian — no forbidden; secrets env-only (0 in repo/log) | PASS |
| Factory-Watchdog — backend process alive + :8000 listening | PASS |
| Factory-Watchdog — Banksy :8200 STILL up (green, 32 modules) — not broken | PASS |
| banxe-emi-stack code — not modified (launch only) | PASS |

## Engine preservation (measured)
- `:8200` `/health` = `{"status":"green","engine":"banksy","modules":32,"port":8200}` — unchanged.
- Both ports up simultaneously: 8000 UP, 8200 UP.

## Rollback
- Backend is a detached process; rollback = stop pid 325864 (`kill`). No state mutated; reversible.

## Unblocked (now that backend :8000 is live)
- **GL-post-21 (MCP cutover):** `banxe_mcp.server` can now reach the backend → re-run cutover
  (start `banxe_mcp.server` → green read round-trip → flip `endpoint_set=true` → authorized reload → LIVE).
- **GL-post-20 (prod-inference):** backend available for live wiring.

## Gated (unchanged)
- **Midaz write-path stays `[counsel]`** — backend up ≠ authorization for write ops (`initiate_payment`/ledger).
- Redis-backed webhook reliability (`WEBHOOK_RELIABILITY_ADAPTER=redis`, ADR-034) not enabled (in-memory path).

---
**This does not replace legal advice.**
