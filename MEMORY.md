# banxe-architecture — Sprint Memory

> Auto-maintained by Claude Code sessions. Append-only: add new entries at the bottom.
> Last updated: 2026-04-05

---

## Sprint 4 — Trust Zone Governance + Zero Standing Privileges

### G-11 — Trust Zone Governance (DONE 2026-04-05)

**Deliverables:**
- `banxe-architecture/CONTRIBUTING.md` — full governance guide, 3-zone table, approval rules, branch protection
- `banxe-architecture/governance/trust-zones.yaml` — machine-readable zone spec (RED/AMBER/GREEN), path patterns, shared rules SR-01..SR-04, escalation rules
- `src/compliance/validators/validate_trust_zones.py` — CLI validator: `--file`, `--zone`, `--validate`, `--check-drift`
- `src/compliance/test_trust_zones.py` — 28 tests covering zone assignment, AI policy, approval requirements, CONTRIBUTING content

**Key design decisions:**
- `trust-zones.yaml` is itself in Zone RED (self-protecting, CLASS_B)
- `validate_trust_zones.py` is also RED — once deployed, requires `GOVERNANCE_BYPASS=1` to modify
- Zone matching uses `fnmatch` glob patterns, first-match wins
- Zone RED: AI-FORBIDDEN, requires MLRO/CEO/CTIO approval, signed commits
- Zone AMBER: CLAUDE_CODE_ONLY, architect review required, hooks: invariant_check.py + bounded_context_check.py
- Zone GREEN: PERMITTED (free vibe-coding), CI must pass

**Test result:** 28/28 passed

---

### G-10 — Zero Standing Privileges / JIT Credentials (DONE 2026-04-05)

**Deliverables:**
- `src/compliance/security/jit_credentials.py` — full JIT in-memory implementation
- `src/compliance/security/__init__.py` — package exports
- `src/compliance/test_jit_credentials.py` — 31 tests T-01..T-28

**Key design decisions:**
- `CredentialScope` enum: READ_POLICY, EMIT_DECISION, APPEND_AUDIT, CHECK_EMERGENCY, ORCHESTRATE
  — `POLICY_WRITE` intentionally absent (invariant I-22 / trust boundary B-06)
- `TemporaryCredential` is a frozen dataclass (immutable after issuance)
- `InMemoryCredentialStore` uses `threading.Lock()` for thread-safety
- ZSP-01: Level-3 agents cannot hold EMIT_DECISION, APPEND_AUDIT, CHECK_EMERGENCY, ORCHESTRATE
- ZSP-01: Level-2 agents cannot hold ORCHESTRATE (Level-1 orchestrators only)
- ZSP-02: credentials expire after TTL (default 300s = 5 minutes)
- ZSP-03: all issuances/revocations logged via StructuredLogger (event payload pattern)
- Sprint 5 migration path: replace `InMemoryCredentialStore` with `VaultCredentialStore` (same interface, injected via constructor)
- `get_credential_manager()` — thread-safe singleton (double-checked locking)

**Bugs fixed during implementation:**
- `StructuredLogger.log()` does not exist → fixed to use `.event(event_type=..., payload=...)`
- `pyproject.toml` missing `pythonpath = ["src"]` → added so `compliance.*` imports resolve in pytest

**Test result:** 31/31 passed

---

## Full Test Suite Status (2026-04-05)

| Scope | Tests | Status |
|-------|-------|--------|
| `src/compliance/` (excl. integration + test_suite) | 579 | ✅ ALL PASSED |
| G-10 test_jit_credentials.py | 31 | ✅ |
| G-11 test_trust_zones.py | 28 | ✅ |

---

## GAP Status Summary (Sprint 4 complete)

All 22 gaps from GAP-REGISTER have been addressed. User updating GAP-REGISTER.md directly via GitHub.

Key completed gaps (Sprint 4):
- G-11 Trust Zone Governance — DONE
- G-10 Zero Standing Privileges — DONE
- G-18 DDD Bounded Contexts — DONE
- G-01 Decision Event Log (PostgreSQL) — DONE
- G-12 Agent Passports — DONE
- G-20 Release Pipeline — DONE

---

## Sprint 5 — P3 Maturity (Compliance Snapshot + OPA Sidecar + Review Agent)

### G-13 — Compliance Snapshot Bundle (DONE 2026-04-05)

**Deliverables:**
- `src/compliance/utils/compliance_snapshot.py` — collector + ZIP exporter
- `src/compliance/test_compliance_snapshot.py` — 28 tests T-01..T-28

**Key design decisions:**
- `ComplianceSnapshot` dataclass: timestamp, version, git_sha, policy_checksums (SHA-256 for 5 files), invariants_count, test_results, agent_passports_count, rego_rules_count, gap_register_summary, thresholds, errors
- `collect_snapshot(run_tests=True)` — live snapshot; `run_tests=False` for fast collection
- `export_snapshot_zip(path)` — ZIP with snapshot.json + snapshot.md + 5 artefact files: compliance_config.yaml, INVARIANTS.md, GAP-REGISTER.md, change-classes.yaml, trust-zones.yaml
- `to_markdown()` — human-readable report for MLRO
- Missing files reported as non-fatal errors (never raises)
- CLI: `python -m compliance.utils.compliance_snapshot --output /tmp/audit-YYYY-MM-DD.zip`

**Test result:** 28/28 passed

---

### G-14 — OPA Sidecar Pilot (DONE 2026-04-05)

**Deliverables:**
- `src/compliance/security/opa_sidecar.py` — runtime pre-decision enforcement layer
- `src/compliance/test_opa_sidecar.py` — 28 tests T-01..T-28

**Key design decisions:**
- `OPASidecar` wraps `rego_evaluator.evaluate()` as runtime enforcement before agent decisions
- `PolicyDecision` frozen dataclass: allowed, outcome (ALLOW/DENY/ESCALATE), rule_id, reason, escalation_target, violations
- 3 critical rules enforced:
  - RULE-01 (I-22): Level-2/3 agents cannot write to policy layer → DENY
  - RULE-02 (I-23): Emergency stop must be checked before any decision → DENY
  - RULE-03 (I-25): ExplanationBundle required for decisions > £10K → ESCALATE(MLRO)
- Fail-closed: any internal exception → DENY with rule_id=SIDECAR_ERROR (never silent allow)
- All evaluations logged via StructuredLogger.event() for I-24 audit trail
- `get_sidecar()` module-level singleton
- Integration: call `sidecar.evaluate_pre_decision(agent_id, action, context)` before `_layer2_assess()`

**Test result:** 28/28 passed

---

### G-15 — Multi-Agent Review Pattern (DONE 2026-04-05)

**Deliverables:**
- `src/compliance/review/review_agent.py` — independent rule-based reviewer
- `src/compliance/review/__init__.py` — package exports
- `src/compliance/test_review_agent.py` — 28 tests T-01..T-28

**Key design decisions:**
- `ReviewAgent` is independent of the builder — never generated the proposed change
- `ReviewRequest`: proposed_change (diff), change_class (auto-detected if None), author_agent_id, target_file, rationale, author_level, context
- `ReviewResult`: approved, reviewer_agent_id, concerns, risk_score (0-100), recommendation, resolved_class
- Class-based hard gates: CLASS_B→REJECT(100), CLASS_C→ESCALATE_TO_HUMAN(75), CLASS_D→REJECT(100)
- CLASS_A rule-based scoring: I-21(+90), I-22(+85), trust-zone RED(+70), BC-boundary(+20/+25), no-rationale(+10)
- Threshold: risk>80→REJECT, risk>50→ESCALATE_TO_HUMAN, else→APPROVE
- Auto-detects change class from target_file (SOUL.md/AGENTS.md→B, *.rego/compliance_config.yaml→C, ADR-→D)
- All review decisions logged via StructuredLogger.event() (I-24 append-only)
- Integration: `feedback_loop.py` calls `ReviewAgent.review(request)` before applying a patch

**Test result:** 28/28 passed

---

## Full Test Suite Status (2026-04-05, Sprint 5 complete)

| Scope | Tests | Status |
|-------|-------|--------|
| `src/compliance/` (excl. integration + test_suite) | 663 | ✅ ALL PASSED |
| G-13 test_compliance_snapshot.py | 28 | ✅ |
| G-14 test_opa_sidecar.py | 28 | ✅ |
| G-15 test_review_agent.py | 28 | ✅ |

---

## Sprint 6 — Production Infrastructure

### G-09 — Redis Pre-Tx Gate (DONE 2026-04-05)

**Deliverables:**
- `src/compliance/gates/pre_tx_gate.py` — fast-path gate, <80ms SLA, 4-check pipeline
- `src/compliance/gates/__init__.py`
- `src/compliance/test_pre_tx_gate.py` — 30 tests T-01..T-30

**Key design decisions:**
- 4-check order: EMERGENCY_STOP → JURISDICTION → SANCTIONS_CACHE → VELOCITY
- Fail-open: Redis unavailable → ESCALATE (not BLOCK), business continuity over safety
- Velocity member format: `"{amount}:{timestamp}"` (backward compat: plain float also supported)
- `InMemoryRedisStub` for testing; real Redis for production
- `get_pre_tx_gate()` singleton

**Test result:** 30/30 passed

---

### VaultCredentialStore (DONE 2026-04-05)

**Deliverables:**
- `src/compliance/security/vault_credential_store.py` — Vault KV v2 adapter with InMemory fallback
- `src/compliance/test_vault_credential_store.py` — 28 tests T-01..T-28

**Key design decisions:**
- Same interface as `InMemoryCredentialStore` (drop-in replacement)
- `VaultConfig.from_env()` reads VAULT_ADDR, VAULT_TOKEN from environment
- `_probe_vault()` at startup: if unreachable → fallback to InMemory + WARNING log
- `get_credential_manager(prefer_vault=True)` factory: uses Vault if VAULT_TOKEN present + reachable

**Test result:** 28/28 passed

---

### Commercial Adapter Stubs (DONE 2026-04-05)

**Deliverables:**
- `src/compliance/adapters/dowjones_adapter.py` — sanctions + PEP screening
- `src/compliance/adapters/sumsub_adapter.py` — KYC/KYB document verification
- `src/compliance/adapters/chainalysis_adapter.py` — crypto wallet/transaction AML
- `src/compliance/test_commercial_adapters.py` — 30 tests T-01..T-30

**Key design decisions:**
- STUB mode (no API key) → `NotConfiguredError` with onboarding message (never silent fail)
- LIVE mode → real API call with HMAC signing (Sumsub), bearer auth (Dow Jones, Chainalysis)
- All results map to `RiskSignal` via `.to_risk_signal()` (unified interface)
- Risk thresholds: Chainalysis score 0-10 → SEVERE(≥7)/HIGH(≥5)/MEDIUM(≥3)/LOW

**Test result:** 30/30 passed

---

### Production Scripts (DONE 2026-04-05)

- `scripts/deploy-sprint6.sh` — 8-step deploy: pull → rsync → Redis → PG check → emergency → FastAPI → tests → snapshot
- `scripts/verify-production.sh` — 14-check verification script across 5 categories

---

## Full Test Suite Status (2026-04-05, Sprint 6 complete)

| Scope | Tests | Status |
|-------|-------|--------|
| `src/compliance/` full suite | 747 | ✅ ALL PASSED |
| G-09 test_pre_tx_gate.py | 30 | ✅ |
| VaultCredentialStore | 28 | ✅ |
| Commercial Adapters | 30 | ✅ |

---

## Sprint 7 — CANON System (DONE 2026-04-05)

**Deliverables:** `~/developer/canon/` — модульная система правил

| Файл | Назначение |
|------|------------|
| `CANON.md` | Маршрутизатор профилей |
| `modules/CORE.md` | Ядро (P-01..P-05, абсолютные запреты) |
| `modules/DOC.md` | Работа с файлами и документами |
| `modules/DEV.md` | BANXE-специфика (I-21..I-25, B-01..B-06, CLASS_A/B/C/D) |
| `modules/DECISION.md` | Framework принятия решений, ADR-шаблон |
| `modules/LEGAL.md` | Юридический профиль (guiyon, ss1) |
| `modules/FR_MODULE.md` | Французское право (надстройка над LEGAL) |
| `rules/DIALOGUE.md` | КАНОН 2+7: QRAA + консультационный протокол |
| `rules/COLLABORATION.md` | КАНОН 1+9: роли агентов + изоляция проектов |
| `rules/AUTOMATION.md` | КАНОН 3+4+10: MEMORY.md, скрипты, auto-git |
| `rules/REPORTING.md` | КАНОН 5+6: объяснения + прогресс |
| `rules/VERIFICATION.md` | КАНОН 8: 5-шаговый протокол (FIXATION→FINALIZATION) |
| `scripts/check-canon.sh` | Проверка установки CANON |
| `scripts/activate-profile.sh` | Активация профиля banxe/legal/mixed |

**Профили:**
- `BANXE/DEV` — разработка (DEV primary, LEGAL=off)
- `LEGAL` — юридические проекты (guiyon, ss1; DEV=off)
- `MIXED` — LEGAL overlay поверх DEV (переключение внутри сессии)

**Коммит:** `8bd5525` в `CarmiBanxe/developer-core`

---

## banxe-emi-stack P0 Features (IL-SK-01..IL-SAF-01, DONE 2026-04-12)

Ретроспективные записи из IL-RETRO-02 — фичи были реализованы но не зафиксированы в MEMORY.

### IL-SK-01 — Starter Kit (IL-073)

**Deliverables:**
- `.claude/rules/` — 16 правил для Claude Code агентов
- `.semgrep/banxe-rules.yml` — 10 SAST правил (float-money, audit-delete, clickhouse-ttl-reduce, …)
- `.pre-commit-config.yaml` — ruff + semgrep + pytest hooks
- `.github/workflows/` — quality-gate.yml + PR/Issue templates
- `.claude/specs/` — 5 шаблонов (bug, feature, incident, migration, risk)

**Key decision:** Starter Kit устанавливает фундаментальные правила. Все последующие ILs следуют этим правилам. Commit: `d39d709`.

---

### IL-MCP-01 — MCP Server (IL-074)

**Deliverables:**
- `banxe_mcp/server.py` — начальные 11 инструментов (финансы, recon, FX, payments)
- `.mcp.json` — Claude Code server config
- Расширен до 34 инструментов в IL-075..IL-071

**Architecture:** MCP → FastAPI → Protocol DI → PostgreSQL/ClickHouse. Commits: `b858855`, `91e2ed9`, `fbdb803`, `8688e74`.

---

### IL-075..077 — ARL + D2C + ADDS

| IL | Тикет | Краткое описание | Тесты | Commit |
|----|-------|-----------------|-------|--------|
| IL-075 | IL-ARL-01 | 3-tier LLM routing (Haiku/Sonnet/Opus) + 4 MCP tools | 184 | 5f132dd |
| IL-076 | IL-D2C-01 | Penpot MCP + Design-to-Code pipeline + 4 MCP tools | 207 | 9b8fb48 |
| IL-077 | IL-ADDS-01 | React component library + DESIGN.md + 3 AI modules | ~160 | 3e592d0 |

---

### IL-078 — Safeguarding Engine CASS 15 (IL-SAF-01)

**Deliverables:** ~40 коммитов. Полноценный FastAPI микросервис.

| Компонент | Детали |
|-----------|--------|
| SQLAlchemy models | 5 таблиц: accounts, positions, position_details, reconciliation_records, breaches |
| Сервисы | SafeguardingService, ReconciliationService, BreachService, PositionCalculator, AuditLogger |
| API | 8 endpoints (safeguarding, reconciliation, breach, accounts, health) |
| MCP tools | 4: safeguarding_position, reconciliation_status, breach_report, safeguarding_health |
| Integrations | MidazClient, BankApiClient, ComplianceClient, NotificationClient |
| Alembic | PostgreSQL migrations |

**Why CRITICAL:** IL-SAF-01 — самый крупный gap в INSTRUCTION-LEDGER (~40 commits без записи). P0 deadline 7 May 2026. Commit range: `28c35cd..8d44179`.

---

## IL-BIOME-01 — Quality Gates Expansion (DONE 2026-04-12)

**Scope:** `banxe-emi-stack` — расширение Ruff ruleset + Biome frontend linter + 5-parallel-job CI

### Ruff: расширение с 5 до 12 rule groups

| До | После |
|----|-------|
| E, F, I, W, UP | E, F, I, W, UP, **B, SIM, ANN, S, DTZ, ERA** |

- Progressive adoption: новые группы добавлены с `ignore` записями, тегированными `→ IL-ANN-01 / IL-DTZ-01 / IL-B-01`
- `ANN101/ANN102` — удалены из Ruff, **не** добавлять в ignore (вызывают предупреждение)
- `per-file-ignores`: tests→no S/ANN; services/iam→S310; banxe_mcp/server.py→S608; services/design_pipeline→S602/S105
- `src = ["services","api","agents","tests"]` добавлен для корректного isort first-party

### Biome 2.3.0 — frontend linter (заменяет ESLint)

- Config: `frontend/biome.json` (lineWidth: 120, double quotes, trailing commas, semicolons)
- Scope: `src/**` + `*.json` + `*.config.ts/js`
- **Исключения:** `src/generated/**` (Mitosis output) + `**/*.lite.tsx` (Mitosis source)
- Pre-commit: local bash hook `cd frontend && npx biome check --apply .`, files: `^frontend/`
- Scripts: `lint → biome check .`, `ci → biome ci --reporter=github .`

### GitHub Actions — 5 parallel jobs

| Job | Trigger |
|-----|---------|
| `ruff` | `**.py`, `pyproject.toml` |
| `biome` | `frontend/src/**`, `frontend/*.json` |
| `test` | needs: ruff |
| `semgrep` | any push |
| `vitest` | needs: biome |

Отдельные workflows: `lint-python.yml` (ruff + semgrep с SARIF), `lint-frontend.yml` (biome + vitest с coverage artifact)

### Makefile — Mitosis → React pipeline

```makefile
make generate-component COMPONENT=Button
# → npx mitosis compile --from=mitosis --to=react Button.lite.tsx → src/generated/Button.tsx
# → npx biome check --apply src/generated/Button.tsx
```

### Коммиты

| Репо | Коммит | IL |
|------|--------|----|
| banxe-emi-stack | (on refactor/claude-ai-scaffold) | IL-072 |
| banxe-architecture | `395f33f` | IL-072 recorded |

### Тесты (banxe-emi-stack)

| Milestone | Count |
|-----------|-------|
| После IL-BIOME-01 | 1 931 ✅ |
- [2026-04-12] ee683db — feat(IL-091): add post-task.sh hook + commit-log.jsonl

---

## Sprint 12 — SMF Appointments + Safeguarding + D-recon (2026-04-13)

### Personnel appointments (sandbox)

| SMF | Role | Appointed |
|-----|------|-----------|
| SMF17 | MLRO | Sarah Mitchell |
| SMF2 | CFO | David Goldstein |
| SMF4 | CRO | Elena Vasilenko |
| SMF24 | COO | James Hargreaves |
| SMF5 | Internal Audit | Grant Thornton UK |

Functional heads: Rachel Cohen (Financial Controller), Nikolai Petrov (Head FP&A),
Marcus Webb (Head Treasury), Priya Sharma (Head Reg Reporting),
Aisha Okonkwo (Compliance Officer), Tom Nakamura (Head Customer Support),
Laura Bennett (Legal Counsel), Grant Thornton UK (External Auditor).

Updated: `docs/ORG-STRUCTURE.md §4`, `docs/DEPARTMENT-MAP.md §3`.
GAP-001, 002, 009, 026–033 → ✅ DONE. Commit: `33e8eaa`.

### gap-tracker.py — GAP register status

| Date | Open | Done | In Progress |
|------|------|------|-------------|
| Session start | 43 | 0 | 2 |
| End of session | 29 | 14 | 2 |

GAP-003 (safeguarding engine), GAP-004 (audit trail), GAP-010 (D-recon tri-party) → DONE.
Run: `python3 scripts/gap-tracker.py --status` (mandatory session start/end).

### banxe-emi-stack deliverables (commit `cabfb2f`)

**src/safeguarding/** — CASS 15 / PS23/3 (deadline 7 May 2026):
- `daily_reconciliation.py` — MATCHED/BREAK/PENDING, £0.01 tolerance
- `breach_detector.py` — >3 day streak → CRITICAL FCA alert
- `fin060_generator.py` — FIN060 return, to_dict/to_json/to_csv_row
- `audit_trail.py` — ClickHouse MergeTree 6yr TTL, fail-open

**src/settlement/reconciler_engine.py** — GAP-010 D-recon (was OVERDUE Sprint 9):
- Tri-party: RAILS_VS_LEDGER + LEDGER_VS_BANK + RAILS_VS_BANK
- Protocol ports (fully injectable, no infra deps)
- ClickHouseDiscrepancyReporter → banxe.settlement_recon_events (5yr TTL)
- ReconcilerCron: exit 0/1/2/3

NOTE: Do NOT confuse with existing `services/recon/` (2-way Midaz↔bank, still used) or
`services/safeguarding-engine/` (FastAPI microservice, stubs Phase 3.6 — not yet wired).

### Sprint 12 remaining open (9 gaps)
GAP-005 (real Barclays/HSBC account — external blocker),
GAP-008/011/015 (API keys blocked),
GAP-012 (IDV), GAP-014 (EMI products), GAP-018 (FCA reporting),
GAP-019 (Fee Engine), GAP-023 (API Gateway).
- [2026-04-17] 9c140ef — feat(payments): wire PaymentService+LedgerPort in DI, align router type hints — Phase 2 P0
- [2026-04-19] 7816c87 — refactor(auth): add application service seam for thin router migration
- [2026-05-03] 3adf76b — feat(infra): Keycloak realm banxe-emi — compose stack + realm export + runbook (pre-GATE-A; G-IAM-01..05,07 prep)
- [2026-05-04] 76dd1e3 — feat(guardian-shim): claude-code pre-bash enforcer v0.1 + Strategy-S1 native hook (audit default)

### Sprint 45 — IL-FPA-01 CFO Office Agents (FP&A + BI)
- **FPAAgent** (ORG §2.5.2, L1 Auto) — budget vs actuals; injects `LedgerPort` (read-only GL). Soul: budget-agent.
- **BIAgent** (ORG §2.5.5, L1 Auto) — dashboard + KPI alerts; injects `AnalyticsPort` (read-only ClickHouse). Soul: finance-bi-agent.
- Both: ADR-049 §D2 gate-chain + ADR-046 lineage, AUTO-only read-only, ports+recorder injected, R-SEC opaque-handles-only. 63/63 tests, 100% cov.
- Merged via banxe-emi-stack PR #166 (squash, SHA ecede803) — `--admin` under documented R3 non-reporting-guardian exception (guardian-factory/guardian-project unreported, enforce_admins=false, 13 real checks green).
- **DEFERRED → sprint-46/ADR-078:** TreasuryAgent (NOSTRO recon + FX exposure) + ForecastAgent (liquidity) — no port CONTRACT yet; remain (PROPOSED) in ORG §2.5.

### Sprint 46 — IL-172 / ADR-078 CFO Treasury & Forecast (the 2 deferred from sprint-45)
- **ADR-078 ports** (`services/treasury/`, read-only): `FXExposurePort` (no trade execution), `NOSTROReconPort` (read+compare, no transfers), `LiquidityForecastPort` (inputs only, no ML). abc.ABC + InMemory + PortError, Decimal.
- **TreasuryAgent** (ORG §2.5.3, L2 Review) — FX exposure + NOSTRO recon; §D2 step-up = **>£100k → CFO HITL**. **ForecastAgent** (§2.5.2, L2 Review) — rolling liquidity; below-AUTO → Head-of-FP&A HITL.
- Both: ADR-049 §D2 + ADR-046 lineage, ports+recorder injected, R-SEC opaque-handles-only. 77 tests, 100% cov. banxe-emi-stack PR #167.
- Name coexistence: `services/agents/treasury_agent.py:TreasuryAgent` (mask) vs pre-existing `services/treasury/treasury_agent.py` (domain) — distinct packages, full suite green.
- **CFO office §2.5 now fully implemented** (FPA/BI sprint-45 + Treasury/Forecast sprint-46).

### Sprint 47 — IL-173 / ADR-079 CRO RiskOversightAgent (L1 read-only dashboard)
- **ADR-079** resolves the ORG §2.2 L1-vs-L3 contradiction: dashboard agent = **L1 read-only**; CRO model/threshold approval stays **L3/human** (EU AI Act Art.14).
- **RiskMetricsPort** (`services/risk/`, read-only): aggregate exposure, fraud/AML counters, Consumer Duty PS22/9 signals, dashboard. abc.ABC + InMemory + PortError; no mutate/approve/threshold method. Decimal.
- **RiskOversightAgent** (ORG §2.2, L1 Auto) — read-only dashboard via RiskMetricsPort; ADR-049 §D2 + ADR-046 lineage; **invariant (tested): never emits approve/threshold/decision** — any such op out-of-scope/refused. R-SEC opaque-handles-only. 39 tests, 100% cov.
- banxe-emi-stack PR (sprint-47). CRO §2.2 dashboard agent now implemented.

### Sprint 48 — IL-174 / ADR-080 CTO DataQualityAgent (L1 read-only drift detection)
- **DataQualityPort** (`services/data_quality/`, read-only): drift score, quality report (null-rate/schema-conformance/freshness/drift), datasets, freshness. abc.ABC + InMemory + PortError; Decimal. No mutate/trigger/retrain method (I-27/I-10).
- **DataQualityAgent** (ORG §2.7.1, L1 Auto) — detect + report drift via the port; ADR-049 §D2 + ADR-046 lineage; **invariant (tested): never triggers retrain/pipeline/write** — any such op out-of-scope/refused. R-SEC opaque-handles-only. 54 tests, 100% cov.
- ONLY DataQualityAgent this sprint; MLPipelineAgent + DeployAgent stay (PROPOSED). banxe-emi-stack PR #169.

### Audit (2026-06-11) — ORG ↔ code reconciliation (IL-176)
- ORG `(PROPOSED)` list drifted from code: ~60 domain `services/*/*_agent.py` exist but only 12 §D2 masks (`services/agents/`). `(PROPOSED)` = "no §D2 mask yet", not "no domain code".
- Remaining work: MASK_ONLY (Chargeback→dispute_resolution, CreditScoring→lending, Contract→agreement, NPS→support/feedback_analytics) → BUILD (Churn, Lead, Campaign, Incident, HR) → DEFER/GATED (DeployAgent in-flight, MLPipeline I-27).
- ORG-STRUCTURE now carries a scope-note: tables = client-facing §D2 masks only. See docs/audit/ORG-CODE-RECONCILIATION-2026-06-11.md.

### Sprint 49 — IL-177 / ADR-081 CTO DeployAgent (L2 staging / L3 prod, token-gated)
- **DeployPort** (`services/deploy/`): prepare/request (read/propose) + execute_deployment(plan, approval_token) which RAISES without a valid CTO token (prod mandatory). No autonomous-execute path. abc.ABC + InMemory + PortError.
- **DeployAgent** (ORG §2.7.2): staging L2 (CTO review token), production L3 (force CTO step-up; execute only with valid token; without → HALT, port.execute never called). ADR-049 §D2 + ADR-046 lineage; port+recorder injected.
- **⭐ Safety invariant (tested):** no autonomous prod deploy — prod@confidence=1.0 w/o token HALTs, port.execute never called (spy). R-SEC: token never in lineage. 54 tests, 100% cov.
- First state-changing mask. ONLY DeployAgent built; MonitoringAgent + MLPipelineAgent stay (PROPOSED). banxe-emi-stack PR (sprint-49).

### Sprint 50 — IL-178 ChargebackAgent (MASK_ONLY over dispute_resolution)
- First MASK_ONLY sprint (audit Tier-2): thin §D2 mask `services/agents/chargeback_agent.py` delegating to existing `services/dispute_resolution/` domain (ChargebackBridge) via injected handle Protocol — NO domain rewrite, NO new port.
- ORG §2.6.1 COO, L2 Review, gate COO. initiate_chargeback/submit_representment → COO review step-up (no reviewer → HOLD, domain not called); get_chargeback_status → AUTO read. ADR-049 §D2 + ADR-046 lineage; ValueError = provider-error (emit+reraise). R-SEC opaque-handles-only. 100% cov on mask.
- No new ADR (existing §D2). banxe-emi-stack PR (sprint-50). Pattern for remaining MASK_ONLY: CreditScoring→lending, Contract→agreement, NPS→support/feedback_analytics.

### Sprint 51 — IL-180 CreditScoringAgent (MASK_ONLY over lending; HITL-on-reject)
- Second MASK_ONLY: thin §D2 mask `services/agents/credit_scoring_agent.py` delegating to existing `services/lending/` (CreditScorer + LoanOriginator) via injected handle Protocol — NO domain rewrite/port.
- Actions: score_customer/get_latest_score (AUTO reads) + decide. **⭐ Regulatory invariant (tested): credit REJECTION never finalized autonomously** — proposed DECLINED → force step-up to human regardless of confidence; no reviewer → HOLD, domain.decide never called, escalate→CREDIT_OFFICER (EU AI Act Art.14 / FCA CONC / I-27). ValueError = provider-error. R-SEC: no income/score/PII in lineage. 100% cov on mask.
- No new ADR (existing §D2). banxe-emi-stack PR (sprint-51). Remaining MASK_ONLY: Contract→agreement, NPS→support/feedback_analytics.

### Sprint 52 — IL-182 ContractAgent (MASK_ONLY over agreement)
- Third MASK_ONLY: thin §D2 mask `services/agents/contract_agent.py` delegating to existing `services/agreement/` via injected `AgreementPort` (already a Protocol — reused directly, no new port). NO domain rewrite.
- ORG §2.9 Legal, L2 Review, gate Legal Counsel. create_agreement/record_signature → Legal Counsel review step-up (no reviewer → HOLD, domain not called); get_agreement → AUTO read. ADR-049 §D2 + ADR-046 lineage; AgreementError = provider-error (emit+reraise). R-SEC: no terms/PII in lineage. 100% cov on mask.
- No new ADR (existing §D2). banxe-emi-stack PR (sprint-52). Remaining MASK_ONLY: NPS→support/feedback_analytics (last of Tier-2).

### Sprint 53 — IL-187 NPSAgent (MASK_ONLY over support feedback) — Tier-2 COMPLETE
- Fourth/LAST MASK_ONLY: thin §D2 mask `services/agents/nps_agent.py` (ORG §2.8 Front Office, L1 Auto) delegating to existing `services/support/feedback_analytics_agent.py` (get_metrics: NPS+CSAT aggregate) via injected handle Protocol — NO domain rewrite/port. Distinct from the existing FeedbackAnalyticsAgent domain agent.
- Action: get_feedback_metrics (AUTO read). L1 read-only invariant: write submit_csat out-of-scope/refused (tested). ADR-049 §D2 + ADR-046 lineage; ValueError = provider-error; compliance→CRO. R-SEC: no feedback text/PII in lineage (RED zone). 100% cov on mask.
- No new ADR (existing §D2). banxe-emi-stack PR (sprint-53). **Audit Tier-2 (MASK_ONLY) all 4 complete** (Chargeback/CreditScoring/Contract/NPS). Next: Tier-3 BUILD (Churn/Lead/Campaign/Incident/HR), Tier-4 MLPipeline (I-27).

### Sprint 54 — IL-189 ChurnPredictionAgent (Tier-3 BUILD; ChurnSignalPort + L1 read-only mask)
- **First Tier-3 BUILD** of the audit IL-176 remainder (sibling of sprint-47 RiskOversight IL-173 / sprint-48 DataQuality IL-174): a new read-only port + a thin §D2 mask, NOT a MASK_ONLY over an existing agent.
- **ChurnSignalPort** (`services/churn/churn_signal_port.py`, read-only): `get_at_risk_customers(threshold: Decimal)` (highest-risk first) + `get_churn_signals(customer_id)`. abc.ABC + InMemoryChurnSignalPort + ChurnSignalPortError (+ CustomerNotFound). Signals DERIVED read-only from existing `services/customer_lifecycle/` (DORMANT/SUSPENDED → ChurnSignalCode); NOT a new ML model, NO writes. customer_lifecycle untouched. Decimal everywhere. No mutate/trigger/retention method (I-10/I-27).
- **ChurnPredictionAgent** (ORG §2.6.3 Customer Operations, L1 Auto) — detect + report at-risk customers via the port; ADR-049 §D2 + ADR-046 lineage; **invariant (tested): never modifies customer state or triggers retention** — any such write/retention op out-of-scope/refused. compliance non-PASS → BLOCK + escalate→DPO. R-SEC opaque-handles-only (customer_id/cohort; never risk scores/weights/PII). 43 tests, 100% cov on BOTH new modules.
- ONLY ChurnPredictionAgent this sprint; Lead/Campaign/Incident/HR stay (PROPOSED), Tier-4 MLPipeline (I-27) deferred. banxe-emi-stack PR #175. NO new ADR (existing L1 read-only §D2).

### Sprint 55 — IL-191 LeadScoringAgent (Tier-3 BUILD; LeadSignalPort + L1 read-only mask)
- **Second Tier-3 BUILD** of the audit IL-176 remainder (sibling of IL-189 ChurnPredictionAgent / sprint-47 RiskOversight IL-173 / sprint-48 DataQuality IL-174): a new read-only port + a thin §D2 mask, full BUILD (NO existing lead/sales/marketing domain — `referral/` + `crm/` exist but are NOT lead scoring).
- **LeadSignalPort** (`services/lead_scoring/lead_signal_port.py`, read-only): `get_active_leads(threshold: Decimal)` (highest-score first) + `get_lead_score(lead_id)`. abc.ABC + InMemoryLeadSignalPort + LeadSignalPortError (+ LeadNotFound). Read-only CONTRACT abstraction of behavioral scoring (signup → active); ClickHouse + scikit-learn production adapter DEFERRED (I-10, like analytics/churn). NO mutate/contact/outreach/nurture/write method (I-10/I-27). Decimal everywhere. LeadScoreBand/LeadStage/LeadSignalCode enums.
- **LeadScoringAgent** (ORG §2.8 Front Office / Sales, L1 Auto) — score + report behavioral lead propensity via the port; ADR-049 §D2 + ADR-046 lineage; **invariant (tested): never contacts a lead or mutates state** — any such contact/outreach/write op out-of-scope/refused. compliance non-PASS → BLOCK + escalate→DPO. R-SEC opaque-handles-only (lead_id/cohort; never scores/weights/PII). 43 tests, 100% cov on BOTH new modules.
- ONLY LeadScoringAgent this sprint; Campaign/Incident/HR stay (PROPOSED), Tier-4 MLPipeline (I-27) deferred. banxe-emi-stack PR #176 (mergeStateStatus BLOCKED = R3 review; operator merges, not self---admin). NO new ADR (existing L1 read-only §D2).

### Sprint 56 — IL-193 CampaignAgent (Tier-3 BUILD; CampaignPort + L2 mask, MANDATORY MLRO publish gate)
- **Third Tier-3 BUILD** of the audit IL-176 remainder (after IL-189 Churn + IL-191 Lead): a new port + a §D2 mask. UNLIKE the L1 read-only Churn/Lead BUILDs, this is the FIRST Tier-3 BUILD with a **write/publish** surface — sibling of the L2 client-facing masks `kyc_onboarding_agent` / `crm_agent`, not the read-only RiskOversight/DataQuality pattern.
- **Regulatory invariant (COBS 4 — enforced in code AND test):** ORG §2.8.2 — "AI may draft but NEVER auto-publish." A campaign action that PUBLISHES financial-promotion content can **NEVER** be autonomous — mandatory step-up to MLRO **regardless of confidence**: publish proceeds only with a valid, campaign-bound `MlroReviewToken`; no/invalid token → HALT (`HALT_MLRO_REVIEW_REQUIRED`), domain publish **never called**, escalate→MLRO. Drafting (`prepare_campaign`) free. Dedicated test: publish @ conf=1.0, no token → HALT + publish never called + escalate→MLRO; plus COBS-4-hard test (financial promo needs token even when mask flag waives it).
- **CampaignPort** (`services/campaign/campaign_port.py`): `prepare_campaign` (free draft) / `publish_campaign(draft, mlro_token)` (raises `MlroReviewRequired` without a valid bound token — defence in depth) / `list_campaigns` (read). abc.ABC + InMemoryCampaignPort + `CampaignPortError`/`CampaignNotFound`/`MlroReviewRequired`/`ProviderUnavailable`. Frozen `CampaignDraft`/`MlroReviewToken`/`PublishedCampaign`; `CampaignChannel`/`CampaignStatus` enums. Decimal for budget. No real Listmonk (I-10).
- **CampaignAgent** (ORG §2.8.2, L2 Review) — full ADR-049 §D2 chain (process_ref → scope → band → cost_cap → compliance → **MLRO publish step-up** → port); 1 ADR-046 record/action; port + DecisionRecorder injected. Drafting REVIEW-biased; reads AUTO-only; compliance non-PASS → BLOCK + escalate→MLRO; port error → emit+reraise. R-SEC opaque-handles-only (campaign_id/segment/channel; never subject/body content or recipient PII). 37 tests, 100% cov on BOTH new modules.
- **Distinction:** `services/referral/campaign_manager.py` EXISTS (referral-reward lifecycle, different bounded context) — **untouched**; the marketing email/push path is the new port. ONLY CampaignAgent this sprint; Incident/HR stay (PROPOSED), Tier-4 MLPipeline (I-27) deferred. banxe-emi-stack PR #177 (mergeStateStatus BLOCKED = R3 review; operator merges, not self---admin). NO new ADR (existing L2 §D2 mask — KYC/CRM).

### Sprint 57 — IL-196 IncidentResponseAgent (Tier-3 BUILD; IncidentSignalPort + L2 mask, CRITICAL→CTO+CEO step-up)
- **Fourth Tier-3 BUILD** of the audit IL-176 remainder (after IL-189 Churn + IL-191 Lead + IL-193 Campaign): a new read-only signal port + a §D2 mask — sibling of the L2 mandatory-escalation masks `campaign_agent` (COBS 4 MLRO publish gate) / `kyc_onboarding_agent` (mandatory-HITL). Second Tier-3 BUILD with a hard mandatory-step-up regulatory invariant.
- **Regulatory invariant (FCA SYSC 8.1 — enforced in code AND test):** ORG §2.7.4 — "Security incident CRITICAL: CEO notified within 2h" | `CRITICAL | CTO+CEO | 2h | NO`. A **CRITICAL** incident can **NEVER** be auto-resolved/suppressed/closed — mandatory step-up to **CTO+CEO regardless of confidence** with a **≤2h SLA**: no reviewer → HALT (`HALT_CRITICAL_ESCALATION_REQUIRED`), disposition **never committed**, escalate→CTO+CEO. AI may triage/classify + propose; CRITICAL closure requires human. Dedicated test: critical @ conf=1.0, no reviewer → HALT + escalate→CTO+CEO + `sla_hours=2` + incident left OPEN; plus config-floor test (permissive mask cannot waive) + critical-with-reviewer proceeds.
- **IncidentSignalPort** (`services/incident_response/incident_signal_port.py`): `get_incidents(severity)` / `get_incident(incident_id)` (reads) / `classify_severity(score)` (pure helper). **READ + classify only — NO close/resolve/suppress seam exists**, so auto-closure is impossible by construction. abc.ABC + InMemoryIncidentSignalPort + `IncidentSignalPortError`/`IncidentNotFound`/`SignalSourceUnavailable`. Frozen `IncidentSignal`; enums `IncidentSeverity` (LOW/MEDIUM/HIGH/**CRITICAL**, score-banded) / `IncidentStatus` / `IncidentSource`. Signals DERIVED read-only from existing `observability/*`, `device_fingerprint/anomaly_detector`, `ato_prevention/*` (those domains **untouched**); no real SIEM/pager (I-10).
- **IncidentResponseAgent** (ORG §2.7.4, L2) — full ADR-049 §D2 chain (process_ref → scope → band → cost_cap → compliance → **CRITICAL CTO+CEO step-up** → port); 1 ADR-046 record/action; port + DecisionRecorder injected. Reads AUTO-only; non-critical triage REVIEW-biased; compliance non-PASS → BLOCK + escalate→CTO+CEO; port error → emit+reraise. R-SEC opaque-handles-only (incident_id/severity; never raw security data/PII). 39 tests, 100% cov on BOTH new modules.
- **Shared (additive):** `_lineage.AgentOutcome` gains `sla_hours: int | None = None` (SYSC 8.1 2h SLA); defaults None, other masks unaffected (full agents suite green). ONLY IncidentResponseAgent this sprint; **HR stays (PROPOSED)**, Tier-4 MLPipeline (I-27) deferred. banxe-emi-stack PR #178 (mergeStateStatus BLOCKED = R3 review; operator merges, not self---admin). NO new ADR (existing L2 §D2 mandatory-escalation mask — Campaign/KYC).

### Sprint 58 — IL-198 HRAgent (Tier-3 BUILD; HRPort + L1 mask, mandatory CEO gate on SMF hires) — LAST Tier-3
- **Fifth and LAST Tier-3 BUILD** of the audit IL-176 remainder (after IL-189 Churn + IL-191 Lead + IL-193 Campaign + IL-196 Incident) — **completes the Tier-3 BUILD set**: a new HR-operations port + a §D2 mask. Third mandatory-step-up Tier-3 (after Campaign COBS 4 MLRO + Incident SYSC 8.1 CRITICAL), and the FIRST fusing an L1-AUTO routine surface with a mandatory step-up gate — `churn_prediction_agent`'s L1-routine pattern + `credit_scoring_agent`'s mandatory-gate invariant.
- **Regulatory invariant (FCA SM&CR — enforced in code AND test):** ORG §2.9 line 361 — `HR | HRAgent | L1 Auto | CEO (hiring SMF holders)`. Routine people-ops (training tracking, conduct-rule attestations, headcount reporting) are **L1 AUTO**. BUT hiring/appointing/changing an **SMF** (Senior Management Function) holder can **NEVER** be autonomous — mandatory step-up to **CEO regardless of confidence** (even 1.0): the appointment commits only with a valid CEO token; no token → HALT (`HALT_SMF_CEO_STEP_UP_REQUIRED`), `apply_smf_appointment` **never called**, escalate→CEO. Dedicated test: appoint-SMF @ conf=1.0, no token → HALT + escalate→CEO + apply never called; plus appoint-with-token-proceeds + config-floor test (permissive mask cannot waive).
- **HRPort** (`services/hr/hr_port.py`): `get_training_status` / `record_conduct_attestation` (routine L1) / `propose_smf_appointment` (prepare only, no token) / `apply_smf_appointment(proposal, ceo_token)` (commit — raises `CEOAuthorizationRequired` without a token, defence-in-depth). abc.ABC + InMemoryHRPort + InMemorySMCRReadHandle + `HRPortError`/`EmployeeNotFound`/`HRSourceUnavailable`/`CEOAuthorizationRequired`. Frozen `TrainingStatus`/`ConductAttestation`/`SMFAppointmentProposal`/`SMFAppointment`; enum `ConductRuleTier`. SMF/role data read via a **read-only** `SMCRReadHandle` Protocol (structurally compatible with `InMemorySMCRRegistry`) — `compliance_automation` **untouched**; no real HRIS (I-10).
- **HRAgent** (ORG §2.9, L1 Auto) — full ADR-049 §D2 chain (process_ref → scope → band → cost_cap → compliance → **CEO SMF step-up** → port); 1 ADR-046 record/action; port + read-only SM&CR handle + DecisionRecorder injected. Routine ops AUTO-only (below-AUTO → `HALT_REVIEW_DEFERRED`); compliance non-PASS → BLOCK + escalate→CEO; port error → emit+reraise. R-SEC opaque-handles-only (employee_id/role/candidate; never PII, salary, or the CEO token). 100% cov on BOTH new modules; full agents suite green (710 passed).
- **`_lineage.py` NOT modified** — existing `requires_step_up`/`escalated_to` carry the SMF gate; 15 existing agents intact. **Completes audit IL-176 Tier-3 BUILD** (Churn+Lead+Campaign+Incident+HR ALL done); remaining: Tier-4 MLPipeline (I-27). banxe-emi-stack PR #179 (mergeStateStatus BLOCKED = R3 review; operator merges, not self---admin). NO new ADR (existing §D2 mandatory-step-up mask — Campaign/Incident). Main raced: expected IL-197 taken by ADR-083 (#426) → renumbered to IL-198.

### Sprint 59 — IL-200 MLPipelineAgent (Tier-4 BUILD; MLSignalPort + L3 mask, mandatory DUAL CRO+CTO sign-off) — FINAL agent of the org chart
- **The LAST agent in the org chart** — its implementation **COMPLETES the entire ORG-STRUCTURE agent catalogue** (every tier, Tier-1…Tier-4, now PROPOSED → IMPLEMENTED). The FINAL Tier-4 build and the **first dual-human-sign-off (CRO+CTO) gate** — strictest mandatory step-up in the catalogue, strengthening the prior single-token gates (Cards biometric, Incident CTO+CEO, HR CEO) to a two-of-two requirement on model updates. Fuses the AUTO-biased read/propose posture of the statements/analytics masks with `cards_agent`/`credit_scoring_agent`'s mandatory-gate invariant.
- **Regulatory invariant (I-27 — enforced in code AND test):** ORG §2.7.1 line 272 — `MLPipelineAgent | Model retraining proposals | L3 | CRO + CTO`; line 276 I-27 "No autonomous model updates" STRENGTHENED to the dual CRO+CTO gate. The agent may **ONLY PROPOSE**; it can **NEVER** apply a model update autonomously. `apply_model_update` commits **only** with **BOTH** a valid CRO token AND a valid CTO token (even at conf=1.0); either missing → HALT (`HALT_DUAL_SIGN_OFF_REQUIRED`), `MLSignalPort.apply_model_update` **never called**, escalate→CRO+CTO. Four invariant tests (no tokens / CRO-only / CTO-only / both) + config-floor test (permissive mask `auto_threshold=0` cannot waive) + port-level `DualSignOffRequired` defence-in-depth test.
- **MLSignalPort** (`services/ml_pipeline/ml_signal_port.py`): `get_drift_signals(model_id)` (read-only) / `propose_retraining(model_id)` (prepare only, no token, applies NOTHING) / `apply_model_update(proposal, cro_token, cto_token)` (only commit seam — raises `DualSignOffRequired` without BOTH tokens, defence-in-depth). abc.ABC + InMemoryMLSignalPort (transient-fail switch) + `MLSignalPortError`/`ModelNotFound`/`DualSignOffRequired`/`MLSignalSourceUnavailable`. Frozen `DriftSignal`/`RetrainingProposal`/`ModelUpdateResult`; enums `DriftSeverity`/`RetrainingUrgency`. Signals DERIVED read-only from existing `ci_governance/*` (drift_detector, drift_metrics_exporter) + `experiment_copilot/*` + `reasoning_bank/*` (those domains **untouched**); no real ML training framework (I-10).
- **MLPipelineAgent** (ORG §2.7.1, L3) — full ADR-049 §D2 chain (process_ref → scope → band → cost_cap → compliance → **dual CRO+CTO sign-off step-up** → port); 1 ADR-046 record/action; port + DecisionRecorder injected. Read/propose AUTO-only (below-AUTO → `HALT_REVIEW_DEFERRED`); a successful proposal carries `requires_step_up` to signal the downstream dual sign-off; off-scope apply → `REJECT_OUT_OF_SCOPE`; compliance non-PASS → BLOCK + escalate→CRO; port error → emit+reraise. R-SEC opaque-handles-only (model_id/proposal_id; never training data, weights, hyper-parameters, datasets, PII, or the CRO/CTO tokens — a completed dual sign-off recorded as the opaque roles "CRO+CTO"). 43 tests, 100% cov on BOTH new modules; full agents suite green (744 passed).
- **`_lineage.py` NOT modified** — existing `requires_step_up`/`escalated_to` carry the dual-sign-off gate; the 16 existing agents intact. **COMPLETES the ORG agent catalogue** — every tier built. banxe-emi-stack PR #180 (mergeStateStatus BLOCKED = R3 review; operator merges, not self---admin). NO new ADR (existing §D2 mandatory-step-up mask, extended to a dual sign-off). Main raced: expected IL-199 taken by ADR-083 dYdX v4 MarketDataPort (Sprint 6.2, #—) → renumbered to next free IL-200, append-only (I-28).
- [2026-06-27] 9e9a1c6 — feat(safeguarding): GAP-087 Step 2 — wire N8nFcaBreachNotifier (immutable FCA shortfall path) [IL-CBS-DRECON-GAP087STEP2-2026-06-27]
- [2026-06-27] 5b93de3 — feat(safeguarding): GAP-087 Step 2 — wire N8nFcaBreachNotifier (immutable FCA shortfall path) [IL-CBS-DRECON-GAP087STEP2-2026-06-27]
- [2026-06-27] af1abfc — feat(reporting): S-PROD-2 Variant B — LiveRegDataClient fail-closed, GAP-088 canonized [IL-CBS-FINRPT-GAP088-2026-06-27]
