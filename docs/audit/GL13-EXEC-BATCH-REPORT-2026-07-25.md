# GL-13-EXEC BATCH — Per-Floor Report — 2026-07-25

**PHASE2 / GL-13-EXEC BATCH / STAGED / NO COMMIT**

## Status: **STAGED** — 94 high-confidence domains distributed, 666 files, 33 gated excluded. Engines :8200/:8000 untouched.

## Per-floor distribution

| floor | domains | files |
|---|---|---|
| F0 | 1 | 5 |
| F1 | 16 | 83 |
| F2 | 24 | 216 |
| F3 | 19 | 122 |
| F4 | 34 | 240 |
| **total** | **94** | **666** |

## Deferred (not distributed)

- **[pending human ratification] (7):** incident_response, insurance, lending, producers, runtime_gate, sandbox, savings
- **[counsel]-gated (6):** banking-engine, compliance_kb, crypto_custody, ledger, midaz_mcp, regulatory_reporting
- **skipped room-mapping gap (3):** compliance, compliance_automation, compliance_sync (no F3-compliance-support room) → `[pending room-mapping]`

## Gates

| gate | result |
|---|---|
| Canon-Guardian — 0 forbidden in copied; cross-cutting placed once in F4 (not per-room) | PASS |
| Factory-Watchdog — 0 secrets in copied files | PASS |
| Factory-Watchdog — :8200 green + :8000 up after batch | PASS |
| Per-file gated scan — 0 active midaz/ledger/regdata imports in copied | PASS |
| Reversibility — basement sources intact, cp-only | PASS |

## Cross-cutting (§4 rule applied)

auth/iam/secrets/config/shared/events/_legacy_common placed **once** in their F4/F2 single-owner room
(Protocol DI, not copied per business room) — no double-count.

## Gated cleanup (leak-pinpoint)

- **13 gated-import matches** in copied files analysed:
  - **11 = false-positive** — safe intra-domain refs (`reporting_analytics.*` self-ref;
    `ledger_port.LedgerInfrastructureError` = exception class, not a live ledger call).
  - **3 = `[counsel-ref]`** flagged in the manifest (FIN060/RegData submission):
    `reporting/fin060_generator_v2.py`, `reporting/reporting_agent.py`, `gabriel/regdata_gabriel_adapter.py`.
    Files retained + unedited; **live submission stays under `[counsel]`** (backend + sign-off required).
- **Verdict: batch clean, gated under control** — no live gated execution enabled by placement.

## Batch closure

**GL-13-EXEC BATCH = DONE** (94 domains, **666 files measured**, 3 `[counsel-ref]` flagged).
*Note (honest): operator context cited 737 files; on-disk measurement = 666 .py — the 737 figure was not reproduced.*
Remaining backlog: **7 [pending human ratification]** + **6 [counsel]-domains**.
*Room-mapping (3 compliance*) — **RESOLVED 2026-07-25** → F3-aml-room/compliance-perimeter (24 files, MLRO/SMF17). Backlog 3→0.*

## Result

17 rooms now hold staged code. Promotion staged→active = install-audit + HITL per lane.

---
**This does not replace legal advice.**