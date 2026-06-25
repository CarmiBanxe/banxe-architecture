---
il_ts: 2026-06-25T19:00:00Z
session_id: agent-factory-factory-skills-bind-group2
source: CEO
status: DONE
---
### Skills-binding GROUP 2 — bind passport skills to 12 unbound agents (S-FAC-64 style, PROPOSED/I-27, binding metadata only); 1 justified false-positive drop
- **Decision:** Applied passport-bound-skills blocks (`allowed_skills` + `preferred_skill_sequences` + `mandatory_skill_triggers`, S-FAC-64 style) to the 12 GROUP-2 agents from `make skills-audit-json` proposals. Bound ONLY proposed skills (⊆ SKILLS-MATRIX), each re-verified against the agent's real capabilities/ports; NO activation — each passport's existing `status` (PROPOSED) unchanged (binding metadata, I-27). Minimal-diff append; existing fields/order preserved.
- **Per-agent skills assigned (all genuinely match — 11 agents have declared `ports:`):**
  - **agreement_agent** (ports: AgreementPort/CustomerPort/CompliancePort/AuditPort) → cms, cae, ehs, acg, stg (5).
  - **alerting_agent** (ports: AlertRoutingPort/N8nTelegramAlertPort/AuditPort) → cms, cae, ehs, acg, stg (5).
  - **bi_dashboard_governor** (ports: BiGovernancePort) → cms, rsb, cae, ehs, acg, stg (6).
  - **case_management_agent** (ports: CaseManagementPort/MarbleCasePort/AuditPort) → 6 + prohibited auto_refactor_pro (MLRO/compliance case contour, I-20).
  - **crm_dsar_governor** (ports: CrmGovernancePort/CrmServicePort/AuditPort) → 6 + prohibited ARP (compliance/DSAR contour, I-20).
  - **channel_c_sepa_orchestrator** (ports: PaymentIntentPort/PaymentRailPort/AuditPort) → 7 (+performance_scanner) + prohibited ARP (payment contour, I-20).
  - **channel_c_swift_orchestrator** (ports: SwiftIntentPort/CorrespondentRailPort/AuditPort) → 7 (+performance_scanner) + prohibited ARP (payment/correspondent contour, I-20).
  - **clickhouse_writer** (ports: AuditPort; append-only Level-3 adapter) → 6 + prohibited ARP (ARP must not touch audit write path, I-24).
  - **crypto_aml** (ports: PolicyPort/AuditPort; AML scoring) → 7 (+performance_scanner) + prohibited ARP (AML contour, I-20).
  - **design_pipeline_agent** (ports: DesignSpecPort/CodeGeneratorPort/AuditPort) → 6 (cms, cae, ehs, acg, stg, dependency_optimizer).
  - **adverse_media_governor** (non-standard `id:` schema, NO ports) → cms, rsb (2) + prohibited ARP (compliance/EDD contour, I-20). Proposal had no code skills, so nothing to drop.
- **Justified DROP (false-positive guard, same as GROUP 1):** **data_lake_elt_agent** — proposed cms, cae, ehs, acg, stg, dependency_optimizer; **DROPPED `api_contract_guardian`**: this passport (apiVersion/kind/metadata/spec schema) declares **NO ports / routers / webhook schemas** (delegates the write path to clickhouse_writer), so the port-contract skill does not genuinely apply. Kept cms, cae, ehs, stg, dependency_optimizer (5) — these apply to its dbt/Airbyte/Debezium/OpenMetadata pipeline code. allowed_skills placed at **top level** (not under `spec:`) so `train.sh` / `skills-bind-audit.sh` detect the binding; agent remains FULLY bound (5 skills), so global unbound still drops by 12.
- **Basis:** `make skills-audit-json` proposals 2026-06-25 (all ⊆ SKILLS-MATRIX); SKILLS-MATRIX.md (10 skills, per-plane MANDATORY/CONTROLLED + Trigger column → `mandatory_skill_triggers`); GROUP 1 precedent (IL-518) incl. the no-ports false-positive guard; I-20 (ARP prohibited on payment/aml/compliance contours), I-24 (audit-trail).
- **Proof — deltas:** `make skills-audit` bound **19 → 31** (+12), unbound **38 → 26** (−12); all 12 GROUP-2 agents confirmed unbound→bound (json check `all 12 bound = True`), incl. data_lake_elt (top-level allowed_skills detected). `make train-verify` = **no regression**: still exits 2 solely on the pre-existing `cicd_quick_setup` gap (only unbound mandatory skill; not a GROUP-2 proposal, correctly not force-fit). All 12 passports parse (`yaml.safe_load` OK); skill counts 2/5/5/6/6/6/7/7/6/7/5/6, prohibited on 7. semgrep pre-commit green.
- **Append-only (ADR-059-A):** ONE new tail shard at il_ts `2026-06-25T19:00:00Z` (strictly > fresh tree max `2026-06-25T18:30:00Z`); INSTRUCTION-LEDGER.md + IL-SEQUENCE.json regenerated via `python3 ledger/build_ledger.py`, `--check` exit 0. Isolated worktree off `origin/main 03f987f` (ADR-120); RULE 7 self-honored. Diff = exactly 12 passports + shard + INSTRUCTION-LEDGER.md + IL-SEQUENCE.json.
- **Status:** DONE — GROUP 2 (12 agents) bound; passports remain PROPOSED/non-activated (I-27). DO NOT MERGE pending operator review.
- **Recommended next (operator):** merge; then GROUP 3 binding sprint (remaining 26 unbound agents via `make skills-audit`); separately bind `cicd_quick_setup` to a CI/infra-owning passport to close `train-verify` (S-FAC-66).
- **Refs:** 12 passports under `agents/passports/`; `docs/SKILLS-MATRIX.md` (source of truth); `scripts/skills-bind-audit.sh` (proposals); `scripts/train.sh` (train-verify); S-FAC-64 / IL-518 GROUP 1 (precedent); ADR-059-A, ADR-120, ADR-121, I-20/I-24/I-27/I-28.
