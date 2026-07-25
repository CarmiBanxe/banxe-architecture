# FLOOR2 Ledger-Room Hardening Report — 2026-07-21

**FLOOR-2 / LEDGER-EMI CLUSTER (S-A6) / ROOM-KIT HARDENING / DOCS-ONLY / NO RUNTIME CHANGE**

Scope: `bank-rooms/F2-ledger-room` in the architecture repo only, plus this report. No file in `~/banxe-emi-stack` was modified; `services/ledger/*`, `api/routers/ledger.py`, `api/models/ledger.py` untouched. No HITL-MATRIX, register, passport, or legal/regulatory classification was changed. Nothing committed.

## Artefacts created / updated

| Artefact | Action | Notes |
|---|---|---|
| `bank-rooms/F2-ledger-room/README.md` | **updated** (expanded) | Preserved existing invariants/register/Sprint-5 content; added basement split, D-GL+B-EMI perimeter, ledger narrative, Midaz/MCP gated topic, anchors |
| `bank-rooms/F2-ledger-room/agents-ledger-room.yaml` | **created** | Owner roles + SMF map, stack/capability roster (no invented `*_agent.py`), autonomy posture, control notes, consultant topics |
| `bank-rooms/F2-ledger-room/hitl-summary.md` | **created** | Real gate IDs HITL-010/011/016/017 + adj>£10k→CFO; three authority layers kept distinct |
| `bank-rooms/F2-ledger-room/diagrams/ledger-room-overview.svg` | **created** | Basement→cabinet, D-GL/B-EMI, LedgerPort/Midaz/MCP coupling, HITL layer |
| `docs/audit/FLOOR2-LEDGER-ROOM-HARDENING-REPORT-20260721.md` | **created** | This report |

## Shell-audit facts and roadmap anchors relied on

- **R1 audit (FABRIKA-FLOOR2-LEDGER-CABINET-AND-RUNTIME-AUDIT-R1):** runtime ledger entrypoints identified (`services/ledger/`, `ledger_port.py`, `midaz_adapter.py`, `midaz_agent.py`, `api/routers/ledger.py`, `api/models/ledger.py`, `services/midaz_mcp/`) — reflected in README basement split; **not modified**.
- **D-GL-BUILD-SPEC:** Midaz PRIMARY / Fineract FALLBACK via one `LedgerPort`; no second ledger / no dual-write; consolidates `services/ledger/` (IL-FIN-01); append-only (ADR-059-A/119); Decimal I-01.
- **B-EMI-BUILD-SPEC:** EMI product catalogue; product accounts map to GL; no posting logic (ADR-102).
- **HITL-MATRIX.yaml:** gate IDs HITL-010 (RegData/CFO), HITL-011 (Safeguarding shortfall/CFO+MLRO), HITL-016 (Large tx/COO-CFO), HITL-017 (New product/CEO) — mirrored, matrix unchanged.
- **ORG-STRUCTURE.md:** SMF mapping (CFO SMF2, COO SMF24, MLRO SMF17, Internal Audit SMF5, CEO SMF1).
- **Roadmap/audit anchors:** S-A6 execution plan, S2/R2 update plans, FLOOR2 build-specs install-audit plan, FLOOR2 MIG-status matrix, FLOOR2-A-CHAIN context.
- **ADR/invariants:** ADR-102 (reuse-not-rebuild), ADR-173 (source governance), I-01/I-24/I-27.

## Open questions intentionally left open

- **`[external reviewer]` Midaz / MCP / ledger-port coupling proof.** Whether any direct MCP→ledger write path exists is **not asserted** as fact. Room canon requires all writes via `LedgerPort`; a direct-mutation suspicion remains a gated architecture-control question (register **#6 midaz MCP→ledger, AMBER**), to be closed only with documented evidence.
- **`[counsel]` Tax-agent autonomy + RegData submission authority (register #1 Tax, AMBER).** ADR ratification and counsel answer pending; RegData submission stays CFO-only (HITL-010), no automated submission.
- **No new legal/regulatory classification introduced.** Existing register statuses (#1, #6 AMBER) and freeze rules are reflected, not changed.

## Deviations / notes for operator
- Roster written in stack/capability form (canonical) where architecture docs assert no concrete `*_agent.py` mapping — nothing invented.
- Diagram delivered as SVG (diff-able); no PNG.
- All changes additive/documentation; runtime repo and gated topics untouched; not committed (operator review).
