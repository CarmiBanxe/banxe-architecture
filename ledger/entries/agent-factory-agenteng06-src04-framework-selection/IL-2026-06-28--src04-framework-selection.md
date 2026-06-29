---
il_ts: 2026-06-28T14:00:00Z
session_id: agent-factory-agenteng06-src04-framework-selection
source: factory
status: PREPARED
---
### SRC-04 — Framework Selection (Corpus Part 4)

**Instrukciya:** Create `docs/agent-engine-dossier/SRC-04-framework-selection.md` (new file, decision layer).
Update `docs/agent-engine-dossier/SRC-INTAKE-REGISTER.md` (append-only, SRC-04 = INGESTED).
Branch `agent/factory/agenteng06/src04-framework-selection` (ADR-060 factory alphanumeric).
Append-only tail shard (ADR-056/059/144), ADR-119/ADR-133 rule 8 = build_ledger mints IL at merge.

**Preflight (read-only):** `SRC-04-framework-selection.md` NOT PRESENT on origin/main (anti-dup OK).
Fresh main max il_ts @ origin/main ad99f63 = 2026-06-28 (PR #838 intake). SRC-04 il_ts = 2026-06-28T14:00:00Z > max.
Source artifacts present: Corpus Part 4 (operator-provided), SRC-01 cross-ref.

**Doc (`docs/agent-engine-dossier/SRC-04-framework-selection.md`, NEW):** 
§0 Star-count note (Part 4 vs Part 1 = different corpus slices, not conflict);
§1 Recommendation table (10 frameworks, stars June 2026, fintech-readiness, BANXE role);
§4.1 LangGraph+Temporal combo (repo-split: LangGraph=architecture/emi-stack; Temporal=banxe-ai-infrastructure/ADR-060§6/Sprint B);
§4.2 Cross-references (SRC-01 BANXE-STATUS primary source, #842 GAP, ADR-SAF-01/J-ENGINE-BUILD-SPEC);
§4.3 Open gaps (Intent Dispatcher / Temporal code / Haystack RAG / TaskWeaver).

**Repo-asserted facts:** LangGraph = planning/routing cand. (#842 Intent Dispatcher); Temporal = crash-resume/at-least-once (CASS 15 MUST complete). Cross-ref SRC-01 §BANXE-STATUS = primary deployment source (SRC-04 additive decision layer, no duplication).

**Proof:** New doc + intake register updated (append-only) + this shard; INSTRUCTION-LEDGER.md regenerated via `python3 ledger/build_ledger.py`; `--check` exit 0. ADR-144: 0 orphans. Branch name matches ADR-060 pattern. Staged set = SRC-04 doc + SRC-INTAKE-REGISTER update + new shard + regenerated ledger.

**Status:** SRC-04 = decision layer (additive, no duplication of SRC-01 BANXE-STATUS primary). PREPARED for merge.

**Refs:** docs/agent-engine-dossier/SRC-04-framework-selection.md (NEW); docs/agent-engine-dossier/SRC-INTAKE-REGISTER.md (updated); docs/agent-engine-dossier/SRC-01-engine-landscape.md (BANXE-STATUS cross-ref); ADR-060§6/ADR-049/ADR-SAF-01/J-ENGINE-BUILD-SPEC; target-audit #842; IL-SAF-01; ADR-143-A/ADR-144/ADR-119/ADR-133.

Created `docs/agent-engine-dossier/SRC-04-framework-selection.md` (new file, decision layer).
Updated `docs/agent-engine-dossier/SRC-INTAKE-REGISTER.md` (append-only, SRC-04 = INGESTED).

Content from Corpus Part 4 (operator-provided, 2026-06-28):

**Recommendation table:** 10 frameworks with stars (June 2026), fintech-readiness, BANXE-stack fit, recommended role.
**LangGraph+Temporal combo §4.1:**
- LangGraph = planning/routing (graph deps, conditional HITL, parallel checks) → candidate for #842 GAP "Intent Dispatcher"
- Temporal = reliable execution (crash-resume, at-least-once, CASS 15 resume) → banxe-ai-infrastructure (ADR-060§6)
- Repo-split: LangGraph = architecture/emi-stack; Temporal = banxe-ai-infrastructure (Sprint B)
**Star-count note:** Corpus Part 1 (AutoGPT 170k) vs Part 4 (different snapshot June 2026) = different corpus slices, not conflict.

Cross-refs: SRC-01 §BANXE-STATUS (not duplicated), ADR-060§6 (Temporal repo boundary),
target-audit #842 GAP "Intent Dispatcher", ADR-SAF-01/J-ENGINE-BUILD-SPEC/IL-SAF-01 (CASS15-resume).

## References

- Corpus Part 4 (operator-provided, 2026-06-28)
- SRC-01: docs/agent-engine-dossier/SRC-01-engine-landscape.md (BANXE-STATUS cross-ref)
- ADR-060§6: Temporal repo boundary (banxe-ai-infrastructure)
- Target-audit: #842 GAP "Intent Dispatcher not deployed"
- ADR-SAF-01 / J-ENGINE-BUILD-SPEC / IL-SAF-01: CASS 15 resume
- ADR-143-A: IL allocator; ADR-144: 0 orphans
