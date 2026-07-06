---
il_ts: 2026-07-06T21:18:00Z
session_id: agent-factory-canon-delivery-stdin-paste
source: agent-factory
status: PROPOSED
---

# Delivery canon — STDIN-paste (`cat > file`) as MANDATORY zero-loss delivery method (cross-terminal)

## What

Add `docs/canon/DELIVERY-CANON-STDIN-PASTE.md` — canon doc making STDIN-paste (`cat > file`)
the MANDATORY zero-loss delivery method for large documents (RU text, formulae, code),
superseding chat-attachment and inline base64 for this purpose. Applies to ALL terminals:
Factory (Left / A), Central, Right (Orchestrating). Specifies the method, the same-chain
ingestion test (bytes > 500; no leftover placeholder; domain-markers > 0; corruption-markers
→ 0; sha256 baseline), and zero-loss archival via `cp` + sha256 equality. Pointer-first
(ADR-102) — references FACTORY-CANON Execution Pattern rather than restating it.

## Boundaries

Doc-only; prepare-only; additive. No passport / SOUL / template / activation touched. No
IL minted at authoring (Rule 8 / ADR-119: build_ledger mints at merge). No merge in this
step. No TRADING-001 or `agent/specproj/*` contours touched (Rule 6). Written from a
session worktree, never the shared checkout (ADR-120). Interactive editors (nano / vim /
code) explicitly forbidden by the canon; shell scripts only.

## Anchors

`docs/canon/DELIVERY-CANON-STDIN-PASTE.md` · `docs/factory/FACTORY-CANON.md` (Execution
Pattern; worktree; prepare-only) · `docs/sources/` (ADR-161 Intake SSOT) · ADR-102 (dedup /
pointer-first) · ADR-120 (worktree) · I-24 (append-only audit).
