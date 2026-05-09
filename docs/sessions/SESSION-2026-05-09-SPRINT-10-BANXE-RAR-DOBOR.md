# Session Canon: 2026-05-09 — Sprint 10 BANXE.RAR Dobor

**Status:** ACTIVE
**Date:** 2026-05-09
**Operator:** Moriel Carmi
**Repo:** CarmiBanxe/banxe-architecture
**Source listing:** docs/inventories/BANXE-RAR-LISTING-2026-05-06.txt (100488 files)
**Category map:** docs/inventories/BANXE-RAR-CATEGORY-MAP-2026-05-06.md

---

## Scope (Sprint 10)

Goal: classify **deferred** BANXE.RAR fragments (≈58439 files) into PASS / REWRITE / REJECT relative to EMI BANXE AI BANK.

Priority candidates (per Phase 3 notes and EMI roadmap):

- `banxe/banxe-shared-libs` — DTOs, error maps, utilities
- `internal_dev/support-services` — internal tools
- `internal_dev/trigger-system-services` — event triggers / cron
- `internal_dev/fintech-services` — fintech utilities
- `banxe-digital/v-accounting` — accounting / AML hooks
- `banxe-digital/crypto-exchange-api` — exchange API
- `banxe/banxe-uikit` — UI components
- `consul-configs/*` — config-only
- `neuron/*` — separate ecosystem, EMI relevance TBC

---

## Classification legend

- **PASS:** Domain logic / models / mappings worth porting into EMI stack behind existing ports/adapters.
- **REWRITE:** Legacy implementation discarded; only domain idea / flow kept, re-implemented natively in EMI.
- **REJECT:** Out of EMI scope, obsolete, or UI-only / infra-only.

Each fragment entry MUST include:
- BANXE.RAR path prefix
- Files count (from listing)
- Proposed classification (PASS / REWRITE / REJECT)
- If PASS/REWRITE: intended EMI boundary (module + port)

---

## Candidates — initial classification (Draft)

_TODO_

---

## Next action

Derive exact path counts for the first priority candidate from `BANXE-RAR-LISTING-2026-05-06.txt` and append the first classification block here.
