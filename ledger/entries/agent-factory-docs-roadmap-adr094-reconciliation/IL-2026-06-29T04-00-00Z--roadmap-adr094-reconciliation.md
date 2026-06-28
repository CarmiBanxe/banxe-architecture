---
il_ts: 2026-06-29T04:00:00Z
session_id: agent-factory-docs-roadmap-adr094-reconciliation
source: CEO
status: DONE
---
### Reconcile TRADING-BLOCK road map with ADR-094 — S6.6/S6.7 DROPPED (Path B) [docs-only correction]
- **Decision:** Surgically corrected `docs/roadmap/TRADING-BLOCK-ROADMAP-AND-SPRINTS-2026-06-28.md` (IL-714) to align with **ADR-094** (ACCEPTED, IL-237), which canonically **DROPS S6.6 and S6.7 as out-of-scope-2026**. The road map originally listed both as Phase-1 *executable* and **omitted any ADR-094 reference** — the omission now fixed. Per canon priority **ADRs > IL**, ADR-094 governs.
- **Path B (keep dropped):** no revival ADR authored, no new sprint label, no change to spec PR #875 contents — that is the separate Path-C choice, NOT taken here. #875 is recorded as **HELD** pending an operator revival decision.
- **Edits (surgical — only S6.6/S6.7 lines; valid rows untouched):**
  1. Added an **ADR-094 reconciliation banner** near the top (states the correction + #875 held).
  2. **L42 Yield/Earn row** → `ADR-083 + ADR-094 · DROPPED (out-of-scope 2026)` (earn/ advisory seam still exists, ADR-102 reuse, but YieldPort not a 2026 build obligation).
  3. **Phase-1 header note** → S6.6/S6.7 removed from immediately-executable; only S6.8 + S6.2-EN remain.
  4. **S6.6 / S6.7 rows** → gate changed `executable` → `⛔ DROPPED per ADR-094` (may return only via a dedicated ADR + IL).
  5. **S6.6-EN row** → `⛔ contingent on a future S6.6-revival ADR`.
  6. **ODR-1 / ODR-2 "Blocks"** → S6.6-EN annotated `(contingent — S6.6 DROPPED per ADR-094)`.
- **Untouched (valid, verbatim):** S6.2/6.4/6.5 built + S6.2-EN enable, S6.8, advisory seams, the three ADR-gated elements (autonomous MM/RL ①, MetaClaw RL ②, AgentFi ③), SEC-1. Diff = +10/−6, single file.
- **Dup-check (ADR-102):** re-verified clean — no existing road-map ADR-094 reconciliation; ADR-095/dse-baas-component/runbook only *reference* ADR-094 (context, not a duplicate). This correction is net-new.
- **Proof:** docs-only (one road-map file); **no code / runtime / port / FROZEN-contract / new repo / keys / secrets / RAR content / revival-ADR / new-label**; 0 files deleted (append-only I-24). IL **provisional, NOT hardcoded** (ADR-119 Rule 8) — `build_ledger.py` mints over current `origin/main` (base frozen max 718) via the ADR-143 central allocator; on concurrent advance → rebase+regenerate (Rule 2/5), `--force-with-lease` only. Append-only (ADR-059-A): ONE tail shard, il_ts `2026-06-29T04:00:00Z` strictly > origin/main max `2026-06-29T02:30:00Z`. Branch `agent/factory/docs/roadmap-adr094-reconciliation` off origin/main `c88340c` (ADR-120; namespace ADR-060).
- **Status:** DONE — correction applied. **DRAFT PR; DO NOT MERGE — operator-gated (§71).**
- **Refs:** `docs/roadmap/TRADING-BLOCK-ROADMAP-AND-SPRINTS-2026-06-28.md` (IL-714); `docs/adr/ADR-094-scope-closure-s6.6-s6.7-t7.9-t8.0.md` (IL-237); ADR-083/102/119/143/059-A/120/060; PR #875 (held). Operator HITL.
