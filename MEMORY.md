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
