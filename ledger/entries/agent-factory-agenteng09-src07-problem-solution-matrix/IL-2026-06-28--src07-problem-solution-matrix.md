---
il_id: TBD
il_ts: 2026-06-28T03:30:00Z
session_id: agent-factory-agenteng09-src07-problem-solution-matrix
slug: agent-factory-agenteng09-src07-problem-solution-matrix
title: "dossier: SRC-07 enrich — community problem→solution matrix (4 rows) + bus-factor engine note (corpus Part 7)"
type: docs
scope: banxe-architecture
branch: agent/factory/agenteng09/src07-problem-solution-matrix
pr: TBD
status: prepared
source: factory
---

## Summary

Append-only enrichment of `docs/agent-engine-dossier/SRC-07-constraints-guardrails.md`.
Resolves 7 UNKNOWN/без-детального-текста placeholders via community problem→solution matrix (corpus Part 7 §7.2).

Content from Corpus Part 7 §7.2 (4 community problems + BANXE solutions):

1. Non-determinism: LLM errors unacceptable without guardrails →
   BANXE solution: deterministic rules (Semgrep×3/Guardian/tx_monitor 9 rules) BEFORE execution.
   Existing components ALREADY DEPLOYED: Verify :8094 (ADR-012/I-09), Guardian (ADR-019), Semgrep (10 rules).

2. Latency: agent chains add seconds/op →
   BANXE solution: parallel compliance checks (LangGraph DAG) + Redis velocity cache.
   Cross-ref: SRC-04 §4.1 LangGraph (PR#847, pending-merge) + SRC-02 §HTN-DAG parallelism.

3. Hallucination in compliance: non-existent regulatory refs →
   BANXE solution: Verify API :8094 (2/3 consensus) + RAG over FCA corpus (banxe-rag 17 docs → 200+).
   Cross-ref: SRC-01 §Haystack (Compliance RAG). banxe-rag expansion = out-of-scope architecture.

4. Bus-factor (engine-specific): all 18 repos one reviewer; AGENT AUTONOMY AGGRAVATES bus-factor
   (autonomous changes harder to track) →
   BANXE solution: Guardian + CODEOWNERS expansion (P2) + append-only audit trail per agent action.
   Cross-ref: GAP-084, ADR-140 (not duplicated here).

banxe-rag note: 17 docs → 200+ FCA anti-hallucination corpus expansion. Source: banxe-rag/emi-stack.
Out-of-scope for banxe-architecture (marked, not designed here).

Cross-refs: SRC-04 (LangGraph, PR#847 pending-merge), SRC-01 (Haystack), SRC-02 (HTN-DAG),
GAP-084 (bus-factor / CODEOWNERS), ADR-140, ADR-012, ADR-019.
Guardrail component details: NOT duplicated (primary = SRC-07 §existing-guardrails above the append).

## References

- Corpus Part 7 §7.2 (community critique — 4 problems + solutions), 2026-06-28
- SRC-07 original file (append-only, no overwrites)
- SRC-01: Haystack Compliance RAG (cross-ref)
- SRC-02: HTN/SWIFT-DAG parallelism (cross-ref)
- SRC-04: LangGraph §4.1 (PR#847 pending-merge; cross-ref)
- GAP-084: bus-factor / CODEOWNERS (cross-ref; not duplicated)
- ADR-012: Verify API :8094 (I-09); ADR-019: MetaClaw Guardian; ADR-140: review policy
- ADR-143-A: IL allocator; ADR-144: 0 orphans

## Amendment Z1 (2026-06-28 04:30Z): Fix 3 remaining unmarked [НЕИЗВЕСТНО]

Independent verify found 3 UNMARKED lines missed by prior pass:
- L39: `предположительно документов` → RESOLVED, см. §R ниже
- L158: `[НЕИЗВЕСТНО в banxe-architecture]` → RESOLVED, см. §R ниже  
- L292: table cell `| banxe-rag note | absent / НЕИЗВЕСТНО |` → RESOLVED, см. §R ниже

All 3 reference §R (banxe-rag Knowledge Base Note, defined @ L254).
Append-only; no deletions or overwrites.
ADR-144 verify: §R target exists (0 orphans for our marks).
Remaining unmarked: 0 CONFIRMED.
