---
il_ts: 2026-07-08T21:07:05Z
session_id: agent-factory-governance-memoir-impl-design
source: CEO
status: PROPOSED
---
### ADR-165 memoir Implementation Design (HOW-layer) — factory pilot, PROPOSED, document-only

Authors ADR-165 (docs/adr/ADR-165-memoir-implementation-design.md) — the ratifiable HOW for the ADR-137
factory-only memoir pilot. **Text-3 authoritative** (grounded on real ADR-136/137 + the 8 MEMOIR-PILOT-PRECOND
docs + live reasoning_bank + PresidioRedactor). **Text-2 REJECTED** on three perimeter/surface violations: C1
factory-fork-only breach (reasoning_bank is project-side), C2 cross-perimeter storage (shared store), C3
premature FastAPI/MCP surface. Reconciled HOW: factory/memoir/ path (factory-side only, PRECOND-05); git-plumbing
bare memory-repo (redact→then commit, raw never stored); Python lib+CLI surface (no daemon/FastAPI/MCP);
redaction mirroring PresidioRedactor + extended secrets/keys/.env/JWT/high-entropy + RED-zone DROP, fail-closed;
git-native branch/blame/rollback (rollback = new commit, no history rewrite); config/memoir/retention.yaml
(max_age/max_entries/hard_cap_bytes/scope, fail-closed if invalid); XOR via config-key + CI guard + runtime
single-registry; no-authority (VCS content-only, never code/ledger/prod/dispatch). **Acceptance gate = ADR-137
8-precondition test matrix T01..T15 (NOT ADR-135; ADR-135 governs only expansion beyond pilot, PRECOND-08:
separate ADR + operator + IronClaw).** session_memory clarified as read-only pack builder, not a substrate,
outside the XOR constraint. **NO code, NO memoir runtime, NO import of zhangfengcdt/memoir.** Additive; document-only.
Refs: ADR-137/136/135/130/127/117/120/059; MEMOIR-PILOT-PRECOND-01..08; ADR-102/119/120.
