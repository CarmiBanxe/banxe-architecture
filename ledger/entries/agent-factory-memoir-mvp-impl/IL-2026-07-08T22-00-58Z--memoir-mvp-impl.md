---
il_ts: 2026-07-08T22:00:58Z
session_id: agent-factory-memoir-mvp-impl
source: CEO
status: PROPOSED
---
### memoir factory-pilot MVP CODE — per ADR-165 (HOW) + MEMOIR-PILOT-PRECOND-01..08 (WHAT)

First code work item for the memoir pilot (authorised now ADR-165 is on main). Delivers factory/memoir/:
git-plumbing store over an ISOLATED bare memory-repo (redact→then commit; native branch/commit/blame/checkout;
rollback = new commit, no history rewrite), fail-closed redaction (RegexEntropyRedactor mirroring the emi-stack
PresidioRedactor pattern — NO project import — EMAIL/IBAN(mod-97)/CARD(Luhn)/SORT_CODE/PHONE + secrets/keys/.env/
JWT/high-entropy; RED-zone DROP; uncertainty ⇒ refuse), bounded retention (config/memoir/retention.yaml,
memoir-retention/v1, fail-closed on absent/unbounded; on-write eviction + purge sweep), XOR (engine config key +
scripts/check-memory-xor.sh + runtime single-registry), perimeter (factory-fork only; project fork disabled;
assert_isolated), no-authority (content-only; AST check bans ledger/build_ledger/network imports). CLI: store/
recall/branch/rollback/blame/checkout/purge — NO daemon/FastAPI/MCP. Tests: ADR-137 8-precondition matrix
T01..T15 (22 tests) ALL PASS; ruff clean. **ACCEPTANCE = ADR-137 8-precond matrix (NOT ADR-135).** PROPOSED/gated:
code + tests only — does NOT activate production capture. NO emi-stack/project touched, NO memoir import, NO
agentmemory instance. Refs: ADR-165, ADR-137, ADR-136, MEMOIR-PILOT-PRECOND-01..08, ADR-130/127/117/120/059,
I-24/I-28, ADR-102.
