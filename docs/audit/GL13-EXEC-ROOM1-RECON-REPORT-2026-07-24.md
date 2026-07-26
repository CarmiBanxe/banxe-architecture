# GL-13-EXEC room-1 — Recon Read-Side Migration Report — 2026-07-24

**PHASE2 / GL-13-EXEC ROOM-1 / COPY-ONLY / REVERSIBLE / STAGED / NO COMMIT**

## Status: **STAGED — first family (recon read-side) copied into F2-ledger-room `[pending audit-evidence]`**

First safe family per PHASE2 spec = `services/recon` (read-side/assurance). Copied into the
F2-ledger-room reconciliation perimeter. High-risk ledger core stays OUT; active Midaz adapters gated.
Engine :8200 / backend untouched. Reversible (basement retained). Nothing committed.

## Numbers
- **Transferred (read-side): 18** `.py` → `bank-rooms/F2-ledger-room/runtime/reconciliation-perimeter/`
- **Gated / NOT transferred [counsel]: 3** (`midaz_reconciliation.py`, `cron_daily_recon.py`, `safeguarding_adapters.py`) — active Midaz-adapter / run-side coupling
- **Ledger core: OUT** (high-risk, per spec — not this wave)
- **Skipped: demo-reporting/analytics** — `banksy-sandbox-repo` absent `[pending sandbox repo]`

## Basement untouched
Source `banxe-emi-stack/services/recon/` still has all **21** `.py` (cp, not mv). Rollback = remove target dir.

## Gated (midaz/mcp/crypto) → [counsel]
3 active-Midaz files excluded (see manifest). No copied read-side file imports them (clean separation, verified).
`services/ledger/*` core not touched.

## Audit-evidence gate
No recon-lane install-audit exists (only `FLOOR2-LEDGER-ROOM-HARDENING-REPORT-20260721.md`) → transfer is
**staged `[pending audit-evidence]`**; promotion to active needs install-audit + HITL (spec §).

## Gate results
| gate | result |
|---|---|
| Canon-Guardian — no forbidden (TOR/onion/scrapy/selenium/:8080) | PASS |
| Factory-Watchdog — 0 secrets in copied files | PASS |
| Factory-Watchdog — engine :8200 green, untouched | PASS |
| Reversibility — basement 21 `.py` intact, copy-only | PASS |

## Result
F2-ledger-room now **has code** (18 read-side recon modules, staged). Reversible, gated-safe, no cutover.

---
**This does not replace legal advice.**
