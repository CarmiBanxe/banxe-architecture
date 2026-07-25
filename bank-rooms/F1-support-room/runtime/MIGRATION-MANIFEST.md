# Support (read-side) — Migration Manifest (GL-13-EXEC family-2) — 2026-07-24

**PHASE2 code-migration wave, SECOND family = `services/support` (customer support read-side).**
First transfer onto Floor-1. Copy-only (cp, not mv). Basement retained — reversible. Staged pending audit-evidence.

## Source → Target
- Source (basement, read-only): `banxe-emi-stack/services/support/*.py`
- Target (room): `bank-rooms/F1-support-room/runtime/`

## Transferred — read-side (7)
`__init__.py`, `complaint_triage_agent.py`, `customer_support_agent.py`, `escalation_agent.py`,
`feedback_analytics_agent.py`, `support_models.py`, `ticket_routing_agent.py`

Classification: tickets / complaints / escalations / feedback — pure read-side.
**Active-import gated scan (lesson from room-1): 0 gated active imports** across all 7 files
(no `from services.ledger/midaz/regdata`, no `httpx`/`mcp`/`crypto`). Self-contained within `services.support`
(no cross-service coupling).

## EXCLUDED — gated / other waves
- `demo-*` — `banksy-sandbox-repo` absent → `[pending sandbox]`
- `reporting` / `regdata` (RegData live-client stub) → `[gated/counsel]`, separate wave
- `services/ledger/*` core → high-risk, OUT
(None of these live in `services/support`; listed for scope clarity. No copied file imports any gated module — verified.)

## Reversibility
Copy-only; basement source intact (7 `.py` present). Rollback = delete target dir. No `mv`/`rm`; nothing committed.

## Gates
- Audit-evidence: no support-lane install-audit (only `F1-FUNCTIONAL-AGENT-SHORTLIST-2026-07-21.md`) →
  **staged `[pending audit-evidence]`**.
- Canon-Guardian: 0 forbidden — PASS. Factory-Watchdog: 0 secrets, engine :8200 untouched — PASS.

---
**This does not replace legal advice.**
