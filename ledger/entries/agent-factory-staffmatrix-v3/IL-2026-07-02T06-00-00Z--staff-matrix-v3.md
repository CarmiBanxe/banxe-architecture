---
il_ts: 2026-07-02T06:00:00Z
session_id: agent-factory-staffmatrix-v3
source: factory
status: DONE
parent_il: IL-122-INTENT-FIRST-CANON-2026-06-07
---

### IL — STAFF-MATRIX v3: 70 passports, evo2 infra profile, ADR-018 gap, P1 GAPs (2026-07-02)

- **What:** `governance/STAFF-MATRIX-v3.md` (new) — post-audit snapshot superseding v2 (44 passports).
- **Changes:**
  - Passport count: 44 (v2) → 70 (filesystem scan 2026-07-02). +26 new passport files across
    finance/ subdir (6), additional governors, orchestrators, and L4 workers.
  - Duplicate flag: `banxe_aml_orchestrator.yaml` in two paths — agents/passports/root/ AND
    agents/passports/aml/. ACTION REQUIRED by operator (MLRO/CTIO sign-off, trust-zone RED).
  - evo2 Infrastructure Profile: banxe-NucBox-EVO-X2-2, 32c/123GiB/AMD Radeon 8060S GFX1151,
    qwen3-235b-master/:8082 (Q3_K_S, 40 GPU layers), llama-rpc-worker/:50052 (USB4 RPC),
    ollama/:11434. ADR-018 PENDING AUTHORING (P1 gap, dangling systemd reference).
    USB4 peer 10.0.0.1: OFFLINE, identity UNCONFIRMED.
  - Open Operator Decisions table (OD-1…OD-5) including ADR-018 authoring.
  - P1 GAP status snapshot: GAP-082/085/090/091/092.
  - `governance/SPRINT-4-MLRO-LINE.md`: "44/44 passports" → "70 passports (STAFF-MATRIX-v3, 2026-07-02)"
  - `governance/SPRINT-5-INTERNAL-AUDIT-LINE.md`: same update.
- **Invariants:** I-24 append-only (no passport rows deleted, v2 preserved); no GUIYON references;
  no sanctioned-jurisdiction tech; ADR-018 gap flagged but not authored (separate factory task).
- **Refs:** STAFF-MATRIX-v2 (parent); GAP-REGISTER.md IL-799 (P1 GAPs source); evo2 audit 2026-07-02;
  ADR-018 (pending); SPRINT-4-MLRO-LINE.md; SPRINT-5-INTERNAL-AUDIT-LINE.md.
