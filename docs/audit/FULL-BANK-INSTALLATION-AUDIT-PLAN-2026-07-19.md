# FULL BANK INSTALLATION AUDIT PLAN — 2026-07-19

**Status: DRAFT / NOT FOR MERGE** · sandbox-only · ветка `agent/factory/bank-operating-model/20260718`
Назначение: реестр «плиток» установленных подсистем банка со статусами READY/PARTIAL-READY/GAP; наполняется по одной плитке за change-set. Родственные аудиты: `docs/audit/FULL-PROJECT-INSTALLATION-AUDIT-2026-06-21.md`, `docs/audit/PHASE-3-SSOT-CONFORMANCE-2026-07-05.md`, `docs/audit/FEATURE-INSTALLATION-AUDIT-*-2026-06-2*.md` (не редактируются этим планом).

---

### Floor 1 – Intent-first demo (intent_slice)

- **Subsystem:** Intent Layer / Client-facing floor-1 demo.
- **Implementation:**
  - `tools/sandbox/intent_slice/` (contracts, gates, normalizer, card, hitl_stub, lineage_log, profile, demo, evidence_pack)
  - snapshot: `tools/sandbox/intent_slice/evidence/snapshot-20260718T222645Z/`
- **Documentation:**
  - `docs/runbooks/INTENT-SLICE-OPERATOR-QUICKSTART-2026-07-19.md`
  - `docs/runbooks/LINEAGE-EXPLORER-QUICKSTART-INTENT-SLICE-2026-07-19.md`
  - `docs/runbooks/BANK-FLOOR1-INTENT-DEMO-MAPPING-2026-07-19.md`
- **Canonical links:**
  - ADR-171/172/047/046/128/173
  - LINEAGE-EXPLORER-SPEC-v0.1
  - BANK-FOUR-FLOOR-MEMO (floor 1 = CLIENT / INTENT-FIRST)
  - BANK-MASTER-ROADMAP §9
  - BANK-SPRINT-PLAN (S-A4, S-A10)
- **Coverage:**
  - **Status: PARTIAL-READY** (demo + evidence + lineage mapping существуют; интеграция с Dispatcher/`INTENT_LAYER_ENABLED` и full Explorer UI остаётся OPEN POINT).
  - **READY:** demo intent, HITL path, lineage, evidence (15/15 тестов PASS, живой snapshot с verdict `executed`).
  - **GAP:** Dispatcher integration, budget-halt CLI flag, SCA/sanctions rails mocks, `immutable_storage_ref`/`input_tokens`/`output_tokens` fields, ADR ratification.
- **OPEN POINTS:**
  - полноценный Lineage Explorer (конфиг/UI);
  - интеграция с Intent Dispatcher + `INTENT_LAYER_ENABLED` (OD-R11, контракт роутингов);
  - CLI-флаг budget-halt;
  - mock SCA/санкции/рельсы до S-A5/S-A7 и ключей;
  - поля `immutable_storage_ref`/`input_tokens`/`output_tokens` не эмитятся slice;
  - ратификация ADR-171/172/173.

---

*Следующие плитки (будущие change-set'ы, здесь только резерв разделов): Floor 2 – Orchestration/engine (ENGINE-ROADMAP, SPRINT-PLAN); Floor 3 – Banking domain (EMI-IMPL-STATE); Floor 4 – Governance/HITL (HITL-MATRIX, conformance); Agent fleet (AGENT-FLEET-MASTER-PLAN, ai-agent-full-inventory).*
