# Compliance Perimeter — Migration Manifest (GL-13 room-mapping fix) — 2026-07-25

**PHASE2 / GL-13 ROOM-MAPPING FIX / COPY-ONLY / REVERSIBLE / STAGED / NO COMMIT**

Resolves the 3 batch-skipped domains whose matrix room (`compliance-support`, F3) has **no bank-room dir**.
Copy-only (cp, not mv). Basement retained. Staged `[pending audit-evidence]`.

## Room remap (decision)
Matrix assigned `compliance-support` (F3, **MLRO/SMF17**) — a room that does not exist. Real F3 rooms:
F3-aml-room, F3-regrep-room, F3-risk-room. `compliance*` = 2nd-line compliance under **MLRO/SMF17**,
the **same owner as F3-aml-room** → placed in **F3-aml-room / runtime/compliance-perimeter/**.
A non-existent "compliance-support" room was **NOT** created.

## Source → Target
- Source (basement, read-only): `banxe-emi-stack/services/{compliance,compliance_automation,compliance_sync}/*.py`
- Target: `bank-rooms/F3-aml-room/runtime/compliance-perimeter/<subdomain>/` (subdomains preserved)

| subdomain | files copied |
|---|---|
| compliance | 9 |
| compliance_automation | 11 |
| compliance_sync | 4 |
| **total** | **24** |

## Gated
Per-file active-import scan (midaz/ledger/regdata/mcp/httpx): **0 gated** across all 24 — none [counsel].

## Reversibility
cp-only; basement intact (9/11/4 `.py` still present). Rollback = delete `compliance-perimeter/`. No mv/rm.

## Gates
- Canon-Guardian: 0 forbidden — PASS. Factory-Watchdog: 0 secrets, :8200 up, basement intact — PASS.
- Audit-evidence: no compliance-lane install-audit → **staged `[pending audit-evidence]`**.

---
**This does not replace legal advice.**
