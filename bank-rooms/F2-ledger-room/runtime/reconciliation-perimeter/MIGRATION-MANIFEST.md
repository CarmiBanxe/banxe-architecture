> ⚠ TRAINING DATA — SANDBOX — NOT FOR PRODUCTION

# Reconciliation Perimeter — Migration Manifest (GL-13-EXEC room-1) — 2026-07-24

**PHASE2 code-migration wave-1, FIRST family = `services/recon` read-side/assurance.**
Copy-only (cp, not mv). Basement originals retained — fully reversible. Staged pending audit-evidence.

## Source → Target
- Source (basement, read-only): `banxe-emi-stack/services/recon/*.py`
- Target (room): `bank-rooms/F2-ledger-room/runtime/reconciliation-perimeter/`

## Transferred — read-side (18)
`__init__.py`, `bankstatement_parser.py`, `breach_detector.py`, `breach_notify_port.py`,
`camt053_parser.py`, `clickhouse_client.py`, `fca_regdata_client.py`, `mock_aspsp.py`,
`recon_agent.py`, `recon_engine.py`, `recon_models.py`, `recon_port.py`, `recon_report.py`,
`reconciliation_engine.py`, `reconciliation_engine_v2.py`, `safeguarding_account_port.py`,
`statement_fetcher.py`, `statement_poller.py`

Read-side classification: these reach the ledger only via `LedgerPort` (Protocol) / stdlib / parsers;
Midaz appears only in comments/docstrings, never as an active adapter import.

## EXCLUDED — GATED [counsel] (NOT transferred)
Active Midaz-adapter / run-side — carry live ledger coupling, out of read-side scope:
| file | reason |
|---|---|
| `midaz_reconciliation.py` | `from services.ledger.midaz_adapter import MidazLedgerAdapter` — active Midaz CBS pull |
| `cron_daily_recon.py` | systemd-facing run-side wrapper; instantiates `MidazClientFundsPort`, runs daily pipeline |
| `safeguarding_adapters.py` | defines `MidazClientFundsPort` adapter (client-fund total from Midaz CBS) |

Ledger core (`services/ledger/*`) = **high-risk, stays OUT** this wave (per spec).
No copied read-side file imports any of the 3 gated modules (clean separation, verified).

## Skipped
- `demo-reporting` / `analytics` low-risk sandbox — `banksy-sandbox-repo` **absent** → `[pending sandbox repo]`.

## Reversibility
Copy-only; basement source intact (21 `.py` still present). Rollback = delete the target dir.
No `mv`/`rm`; no basement mutation; nothing committed.

## Gates
- Audit-evidence: no recon-lane install-audit found (only room-hardening report) → **staged `[pending audit-evidence]`**.
- Canon-Guardian: no forbidden paths — PASS. Factory-Watchdog: 0 secrets, engine :8200 untouched — PASS.

---
**This does not replace legal advice.**
