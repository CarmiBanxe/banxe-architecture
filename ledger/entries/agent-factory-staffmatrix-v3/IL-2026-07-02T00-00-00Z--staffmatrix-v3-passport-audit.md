---
il_ts: 2026-07-02T00:00:00Z
session_id: agent-factory-staffmatrix-v3
source: factory
status: DONE
parent_il: IL-799
---

### IL — STAFF-MATRIX-v3: Sprint-4 passport audit baseline (70 passports)

- **Type:** Governance document — sprint-4 normative audit snapshot.
- **File:** `governance/STAFF-MATRIX-v3.md` (NEW).
- **Supersedes:** `governance/STAFF-MATRIX-v2.md` (Sprint-3, 44 passports). v2 remains frozen.
- **Scope:** Records 2026-07-02 filesystem scan results: 70 YAML passport files in `agents/passports/`.
  Does NOT activate or deactivate any passport (I-24 append-only).

#### Passport inventory (70 total)

| Section | Count | Notes |
|---------|-------|-------|
| §2a L1–L2 dept heads | 12 | From STAFF-MATRIX-v2, all active |
| §2b AML sub-agents | 7 | Compliance swarm — L3, Trust Zone RED |
| §2c Core platform | 13 | Active infra agents |
| §2d Finance / audit (PROPOSED) | 6 | Pending operator activation |
| §2e New PROPOSED | 32 | Added during Sprints 4–5 without prior SM update |

#### Governance additions

- **§3 Duplicate flag:** `banxe_aml_orchestrator.yaml` exists in both `agents/passports/` (root, autonomy unset)
  and `agents/passports/aml/` (L3, complete). Trust Zone RED — MLRO/CTIO sign-off required before
  root copy is deprecated (OD-1).
- **§4 evo2 infrastructure profile:** AMD Radeon 8060S GFX1151, 40 GPU layers, Q3_K_S, :8082/:50052/:11434.
  ADR-018 EXISTS at `decisions/ADR-018-hybrid-5-layer-ai-compute.md` (ACCEPTED 2026-05-03).
  P4.3-Q235 as-built CLOSED by IL-801 (PR #956).
- **§5 Open Operator Decisions:** 5 open decisions (OD-1..OD-5); OD-4 CLOSED (ADR-018 authored).
- **§6 P1 GAP status:** GAP-082/085/090/091/092 — summary of highest-priority open items.
- **§7 Lineage:** v1 (34) -> v2 (44) -> v3 (70).

#### Also modified (append-only)

- `governance/SPRINT-4-MLRO-LINE.md` — passport count updated: "70 passports (STAFF-MATRIX-v3, 2026-07-02)".
- `governance/SPRINT-5-INTERNAL-AUDIT-LINE.md` — same passport count update.

- **Refs:** STAFF-MATRIX-v2 (IL-697); GAP-REGISTER.md (IL-799); ADR-018 (IL-801, PR #956).
- **REMOVED:** 0 (append-only; I-24 enforced).
