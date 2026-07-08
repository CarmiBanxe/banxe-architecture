---
il_ts: 2026-07-08T20:36:10Z
session_id: agent-factory-session-memory-mvp
source: CEO
status: PROPOSED
---
### session_memory MVP — deterministic session-memory substrate over existing repo artifacts

Implements a working MVP (`session_memory/`) that normalizes the EXISTING memory/handoff artifacts
(MEMORY.md + latest docs/handoff/HANDOFF-*.md + latest session-transfer-package-*.md) into one
machine-readable session-start pack (JSON + optional markdown). Deterministic, read-only against source
truth, append-only output to the regenerable `docs/generated/session-memory/` cache. Files: schemas.py
(typed contract), extract_handoff_facts.py (pure markdown→facts, no I/O/clock), build_session_pack.py
(builder + CLI build/inspect/latest), read_memory_pack.py (read-only loader/renderer), README.md, tests/
(14 tests: missing doc → warning-not-crash, malformed markdown, duplicate headers, role reorder-not-drop,
determinism, source-never-mutated). Role-aware (--role central/factory/sub-a/sub-b) reorders relevant
sections only. ruff clean; pytest 14/14. NO authority expansion, NO daemon, NO external DB, NO CI/canon
bypass — complements .github/workflows/novelty-handoff.yml (append-only handoff validator). Extension path
to memoir/substrate (ClickHouse index, embeddings, pack-diff timeline) documented; each step is a separate
operator-gated ADR. Refs: I-24 append-only; I-28 IL record; HITL/operator merge gate; ADR-102/119/120.
