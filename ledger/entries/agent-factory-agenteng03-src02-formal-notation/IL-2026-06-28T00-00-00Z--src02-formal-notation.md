---
il_ts: 2026-06-28T00:00:00Z
session_id: agent-factory-agenteng03-src02-formal-notation
source: Factory
status: prepared
---

## dossier: SRC-02 formal notation layer from corpus Part 2

**Summary**

Append-only formal notation section added to `docs/agent-engine-dossier/SRC-02-theory-principles.md`.
Formal notation sourced from corpus Part 2: ReAct s_t/π, CoT C(d), MARL J_i(θ_i), vector e/top-k.
Conceptual bridge: banking passport = π_domain (payments/KYC/FX/crypto).
Math-status (PRESENT/THEORY) NOT duplicated — cross-ref to SRC-09 §Math-Methods.

**Change**

- File modified: `docs/agent-engine-dossier/SRC-02-theory-principles.md` (append-only)
- New section: "Formal Notation (Corpus Part 2)"
- 4 formulae + 1 passport-π bridge
- Zero mutations to existing content

**Rationale**

SRC-02 listed 5 principles (CoT, MARL, HTN, etc.) with architectural bindings (Verify:8094, MetaClaw, passports).
Corpus Part 2 provides formal notation for these principles. Appending formulae + BANXE-binding examples
makes the principles explicit and machine-readable for future agent-synthesis tasks.

**Evidence**

- SRC-02 last line before: 140 (final matrix)
- SRC-02 new section: "Formal Notation (Corpus Part 2)" — 4 subsections (ReAct/CoT/MARL/Vector)
- Cross-ref to SRC-09 §Math-Methods: ensures no status duplication
- Passport-π bridge: banking passport = π_domain (10 canon-passports in docs/canon/passports/)
- AdorRefNotes: `top-k cos(e_query, e_j)` = vector retrieval, Qdrant :6333 PLANNED (SRC-09 VERIFIED-RUNTIME-SNAPSHOT.md)

**References**

- Corpus: Part 2 (operator-provided, 2026-06-28)
- Source file: `docs/agent-engine-dossier/SRC-02-theory-principles.md`
- Cross-ref: `docs/agent-engine-dossier/SRC-09-preaudit-synthesis.md` §Math-Methods
- ADR-144: orphan-check 0

---

## Amendment A1 — SWIFT-DAG explicit mapping (Corpus §2.4)

**Timestamp:** 2026-06-28 (same session)

**Addition:** "SWIFT-DAG explicit mapping (Corpus §2.4)" section appended to SRC-02-theory-principles.md (lines 244–308).

**Content:**
- DAG structure: `parallel { SUBTASK-1,2,3 } → SUBTASK-4 → sequential {5→6*→7→8}`
- 8 subtask → agent/passport mapping table with repo + status columns
- SUBTASK-2 KYC cross-ref: no passport in architecture yet (A-KYC-BUILD-SPEC + IL-KYC-01)
- SUBTASK-4 FX cross-ref: in banxe-emi-stack (services/providers/fx/), NOT in architecture
- HITL gate at SUBTASK-6 (I-27): conditional, if risk > threshold
- Status summary: 5/8 present, 2/8 partial (FX+HITL in emi-stack), 1/8 spec-only (KYC)

**Evidence:**
- SRC-02 line count: 240 → 309
- New subsections: DAG structure, subtask→agent mapping, parallel/sequential formal pseudocode, status coverage summary
- Cross-refs: A-KYC-BUILD-SPEC, ADR-049 (NOT DEPLOYED), ADR-128 (HITL), swarm.yaml, emi-stack services/hitl/
- No SRC-09 duplication; no conflict markers

**Rationale:**
Corpus §2.4 provides concrete HTN-task decomposition of SWIFT payment flow. Mapping subtasks to BANXE agents + passports
reveals gaps (L1→L2 ADR-049 NOT DEPLOYED, KYC passport absent in architecture) and cross-repo dependencies (FX + HITL in emi-stack).
This explicit mapping enables future sprint planning for architecture alignment.
