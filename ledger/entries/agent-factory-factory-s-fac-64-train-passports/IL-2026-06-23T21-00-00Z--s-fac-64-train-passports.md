---
il_ts: 2026-06-23T21:00:00Z
session_id: agent-factory-factory-s-fac-64-train-passports
source: CEO
status: PROPOSED
---
### S-FAC-64 (R2 Training T1-T2) — bind SKILLS-MATRIX skills to 3 passports (internal_audit, resilience, ml_pipeline)
- **Date:** 2026-06-23 · **Type:** passport skill-binding metadata; passports + ledger; NO activation (status unchanged, I-27).
- **Decision:** Add `allowed_skills` / `prohibited_skills` / `preferred_skill_sequences` / `mandatory_skill_triggers` (repo canon snake_case, as the 6 S-FAC-63 passports use) to 3 passports, assigning ONLY genuinely-applicable SKILLS-MATRIX skills per each agent's role + plane + actual capabilities/ports. No skills invented outside SKILLS-MATRIX; no capabilities invented outside each passport.
- **Per-agent assignment + justification:**
  - **internal_audit_agent** (3rd-line assurance, SMF5, RED, L1, STUB — no service code/ports yet): `context_memory_sync` (IL/audit-trail continuity), `rapid_spec_builder` (dept-head PROPOSES IL/ADR for findings), `clean_architecture_enforcer` (3rd-line independence / I-20). PROHIBITED `auto_refactor_pro` (assurance must not auto-refactor reviewed code). **Deliberately NOT bound:** error_handling_standardizer / performance_scanner / api_contract_guardian / smart_test_generator — no service code or ports exist yet (stub, GAP-078 → Sprint-3); not force-fit.
  - **resilience_agent** (DORA, AMBER, L2, ports ResilienceRequestPort/NotificationPort/AuditPort): CMS, RSB, `error_handling_standardizer` (typed incident paths; AuditPort I-08), `performance_scanner` (RTO/RPO + incident SLA), `api_contract_guardian` (owns ports), `clean_architecture_enforcer`, `smart_test_generator` (CONTROLLED — DR/BCP scenario tests). PROHIBITED `auto_refactor_pro`.
  - **ml_pipeline_agent** (ML owner, AMBER, L2, MLSignalPort, AuditPort I-08): CMS, RSB, `error_handling_standardizer`, `performance_scanner` (inference/drift hot path), `api_contract_guardian` (MLSignalPort), `clean_architecture_enforcer`, `smart_test_generator` (CONTROLLED — drift tests, no real customer data). PROHIBITED `auto_refactor_pro` (drift/scoring governance-sensitive, EU AI Act Art.15).
- **Basis (audit):** S-FAC-64 roadmap + live passport+matrix audit 2026-06-23. SKILLS-MATRIX = 10 skills; 3 target passports previously had NO skill bindings.
- **Proof (train-verify):** `make train-verify` → still exactly **1 mandatory skill unbound: `cicd_quick_setup`** (Dev-plane infra skill, owned by no runtime agent) — **NO REGRESSION**; the 6 mandatory skills these agents bind (CMS, RSB, EHS, PS, ACG, CAE) are all ✓. `cicd_quick_setup` is out-of-scope for these 3 agents (not force-bound) per task. YAML of all 3 passports parses clean (yaml.safe_load OK).
- **DoD:** **MET for T1-T2** — 3 passports now carry canon-compliant skill bindings; no regression; passports remain PROPOSED/active (no activation).
- **Change (minimal, no duplication):** +skill-binding block appended at end of each of 3 passports (all existing fields/order preserved, status untouched); +1 ledger shard. No skills/capabilities invented.
- **Canon compliance:** live-audit source of truth; best-solution; minimal-diff; append-only ledger (ADR-119 frozen IL, max+1); authored in ISOLATED worktree off origin/main (ADR-120, NOT shared checkout); branch ADR-060-compliant (`agent/factory/factory/s-fac-64-train-passports`); passports stay PROPOSED/active (I-27, no activation); no S320 (not Python); hooks enabled (no `--no-verify`/`--admin`/bypass); STOP before merge.
- **Coupling/append-only:** branch off origin/main@2fcf992; single new shard; no prior entry modified.
- **Proof (ledger):** `build_ledger.py --check` exit 0; guardian-ledger / ledger-append-only / guardian-ledger-shards / guardian-branch-naming / guardian-schemas green (local); squash PR to main (merge-queue); operator merges.
- **Refs:** `docs/SKILLS-MATRIX.md`; `docs/roadmap/FACTORY-ROADMAP-2026-06-23.md` §S-FAC-64; `agents/passports/internal_audit_agent.yaml`, `resilience_agent.yaml`, `ml_pipeline_agent.yaml`; `scripts/train.sh` (S-FAC-63); `.claude/rules/agents.md` (allowed_skills = permission to use); ADR-120; ADR-119; ADR-060.
