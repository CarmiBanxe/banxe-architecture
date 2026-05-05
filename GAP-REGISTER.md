# GAP-REGISTER.md — Реестр архитектурных | 12-Factor Factor III | DONE |пробелов BANXE

**Версия аудита:** v7 (2026-04-05) — ALL SPRINTS COMPLETE, 22/22 addressed (G-09 DEFERRED), 663 tests
**Следующий пересмотр:** 2026-07-01 (до EU AI Act дедлайна 2026-08-02)

Каждый gap отслеживается: приоритет, принцип, описание, статус, sprint.

## P1 — Критические (регуляторный и security риск)

| ID | Пробел | Принцип | Дедлайн | Статус |
|----|--------|---------|---------|--------|
| G-01 | Нет immutable audit trail / Decision Event Log | CQRS+ES, DORA 14(2) | — | DONE |
| G-02 | Нет XAI / ExplanationBundle в BanxeAMLResult | XAI, FCA SS1/23 | — | DONE |
| G-03 | HITL не формализован по EU AI Act Art.14 | EU AI Act Art.14 | 2026-08-02 | DONE |
| G-04 | Нет trust boundaries между агентами (Orchestration Tree) | Multi-agent security | — | DONE |
| G-05 | feedback_loop.py может менять SOUL.md без governance gate | Self-rewriting risk | — | DONE |
| G-16 | Нет формализованных Ports & Adapters для агентов | Hexagonal Architecture | — | DONE |
| G-17 | Нет Event Sourcing для решений агентов | Event Sourcing / CQRS | — | DONE |

**G-01 примечание:** DONE (2026-04-05). PostgreSQL 17 Docker (port 5432) на GMKtec. Schema: banxe_compliance.decision_events (15 полей). Indexes: case_id, customer_id, occurred_at, tx_id, decision. I-24: banxe_app_role имеет INSERT+SELECT, UPDATE+DELETE REVOKED. asyncpg установлен. PostgresEventLogAdapter smoke test: append→query→idempotency PASSED. Миграция запускается через `docker exec postgres psql -U postgres -d banxe_compliance -f decision_events.sql`.

**G-05 примечание:** DONE (5130232, 2026-04-05). change_classes.yaml: CLASS_A (auto, AGENTS.md/docs), CLASS_B (DEVELOPER|CTIO|CEO required, SOUL.md/openclaw.json), CLASS_C (MLRO|CEO required, compliance_config.yaml/.rego). GovernanceGate.evaluate() raises GovernanceError for B/C without approver. Append-only governance_log.jsonl. CLI wrapper для protect-soul.sh. feedback_loop.py патчен: --approver/--role/--reason/--strict; без approver soul_patches пропускаются (non-breaking). 44 tests T-01..T-44, suite 247/247.

**G-04 примечание:** DONE (3b84592, 2026-04-05). OrchestrationTree с 6 правилами (B-01..B-06): Level-2→Level-1 BLOCKED (B-01), Level-3→Level-1 BLOCKED (B-02), Level-3→Level-2 BLOCKED (B-03, must use Ports), RED→GREEN BLOCKED (B-04), AMBER→GREEN WARN (B-05), policy_write для Level-2/3 BLOCKED (B-06/I-22). AgentDescriptor frozen dataclass + TrustBoundaryError. Default tree: 1 Level-1, 4 Level-2, 4 Level-3. Интегрирован в banxe_aml_orchestrator Step-1 перед _layer2_assess. 34 tests T-01..T-34, suite 203/203.

**G-03 примечание:** DONE (3b5ad06). emergency_stop.py (dual-store Redis+file) + api.py endpoints + 17 integration tests (T-01..T-17, I-23 verified) + emergency_panel.html (MLRO admin panel, /compliance/admin/emergency) + marble_emergency_workflow.json (n8n webhook→API) + deploy-emergency-stop.sh. Production deploy: bash scripts/deploy-emergency-stop.sh.

**G-16 примечание:** DONE (7b74ebd, 2026-04-05). 4 Port ABCs: PolicyPort (read-only, I-22 enforcement), DecisionPort (async emit_decision), AuditPort (append-only, existing), EmergencyPort (is_stopped/activate/clear). 5 Adapters: ComplianceConfigPolicyAdapter (production, backed by compliance_config.yaml G-07), InMemoryPolicyAdapter (test/dev), BanxeAMLDecisionAdapter (→AuditPort via constructor injection), MockDecisionAdapter (test captures), InMemoryEmergencyAdapter (full lifecycle). 30 tests T-01..T-30, full suite 169/169. Инвариант I-22 реализован как архитектурное ограничение (PolicyPort не имеет write-методов).

**G-17 примечание:** DONE (a8b47cb, 2026-04-05). EventStore (write side): StreamId factory (customer/case/channel/all), AppendResult, append()→AuditPort, load_stream(), replay_into(Projector). CQRS read models: RiskSummaryView (per-customer: counts/avg-score/risk_trend ESCALATING|DE-ESCALATING|STABLE), DailyStatsView (per-date: reject_rate, channels, policy_versions), CustomerRiskView (full MLRO history, high_risk_events). Projector: apply()/apply_batch() with idempotency guard, escalating_customers(), customers_with_sar(), customers_requiring_mlro(), snapshot(). 47 tests T-01..T-47, suite 294/294.

## P2 — Существенные (compliance провал при масштабировании)

| ID | Пробел | Принцип | Статус |
|----|--------|---------|--------|
| G-06 | Нет Bounded Context Map в коде | DDD | DONE |
| G-07 | Compliance thresholds захардкожены в Python | 12-Factor Factor III | DONE |
| G-08 | Нет drift detection для policy-файлов | GitOps | DONE |
| G-09 | Pre-tx gate без Redis hot-path (<80ms p99) | Latency / DIP | DEFERRED |
| G-10 | Нет Zero Standing Privileges для агентов | ZSP / JIT secrets | DONE |
| G-11 | Партнёрский доступ не разграничен (Zone RED/AMBER) | Trust zones | DONE |
| G-12 | Нет формального agent passport | KPMG AIGF | DONE |
| G-18 | Нет bounded contexts — плоская структура модулей | DDD Bounded Contexts | DONE |
| G-19 | Нет controls-as-code (OPA/Rego) — только bash-скрипт | FINOS AIGF v2.0 | DONE |
| G-20 | 12-Factor: отсутствует release pipeline и structured logging | 12-Factor App | DONE |
| G-21 | Нет зонирования для AI-генерированного кода в Claude Code hooks | Vibe-coding governance | DONE |

**G-06 примечание:** DONE (2026-04-05). domain/context-map.yaml: 5 bounded contexts (CTX-01 Compliance/Decision Engine AMBER, CTX-02 Policy RED, CTX-03 Audit RED, CTX-04 Operations GREEN, CTX-05 Agent Trust AMBER). Для каждого: owner, trust_zone, modules[], ports[], adapters[], allowed/forbidden dependencies, invariants. 4 relationship types (conformist, ACL, published_language, partnership). 2 shared kernels (DecisionEvent, BanxeAMLResult). GREEN/AMBER/RED trust boundary summary.

**G-08 примечание:** DONE (2026-04-05). validators/policy_drift_check.py: SHA-256 для 5 файлов (SOUL.md, AGENTS.md, compliance_config.yaml, banxe_compliance.rego, INVARIANTS.md). Baseline: policy_checksums.json. --verify: exit 0 OK / exit 1 drift / exit 2 no baseline. --update: обновляет baseline. Интегрирован в check-compliance.sh (шаг 6/7). 15 тестов T-01..T-15.

**G-12 примечание:** DONE (2026-04-05). schemas/agent_passport.schema.json (JSON Schema draft-07): 14 поля (agent_id, name, version, level 1/2/3, trust_zone GREEN/AMBER/RED, capabilities[], ports, bounded_context CTX-01..05, invariants[], governance, fca_references, aigf_risks). 9 паспортов в agents/passports/ (banxe_aml_orchestrator L1, aml_orchestrator/tx_monitor/sanctions_check/crypto_aml L2, watchman_adapter/jube_adapter/yente_adapter/clickhouse_writer L3). validate_agent_passport.py: business rules B-04/B-06/I-22 + schema validation. 20 тестов T-01..T-20, 124/124 pass.
**G-07 примечание:** DONE (d7a1310, 2026-04-05). compliance_config.yaml: externalized thresholds. config_loader.py: load/validate/access. 18 тестов, 114/114 pass.  **G-19 примечание:** DONE (1cbe34d, 2026-04-05). banxe_compliance.rego + rego_evaluator.py. 25 тестов, 139/139 pass. OPA sidecar → Sprint 4 G-14.  **G-09 примечание:** DEFERRED — EMI-масштаб BANXE пока не требует. Пересмотреть при transaction volume > 10K/day.

**G-18 примечание:** DONE (2026-04-05). contexts/registry.py: 5 BoundedContext dataclass (CTX-01..05) с modules[], allowed_dependencies[], forbidden_dependencies[], trust_zone, ports. context_for_module() + allowed_imports() API. validate_contexts.py: AST-сканирование 56 файлов, 0 BC нарушений. Физическое перемещение файлов DEFERRED (продакшн бот активен) — границы теперь machine-verifiable через валидатор. 40 тестов T-01..T-40.

**G-19 примечание:** `check-compliance.sh` — зародыш controls-as-code. Нужно масштабировать до OPA/Rego engine. FINOS AIGF v2.0 рекомендует executable controls.

**G-20 примечание:** DONE (2026-04-05). Structured logging: compliance/utils/structured_logger.py (ebc54c9). Release pipeline: .github/workflows/compliance-ci.yml (5 steps: syntax check → pytest → policy drift G-08 → passport validation G-12 → invariant check I-21/I-22); triggers push/PR to main. scripts/release.sh: semver versioning, CHANGELOG.md auto-update, 5 pre-release gates (clean tree / pytest / drift / passports / secret scan), git tag + push.

**G-21 примечание:** DONE (819f315, 2026-04-05). 4 хука: policy_guard.py (PreToolUse — BLOCKS CLASS_B/C: SOUL.md/openclaw.json/rego), invariant_check.py (PostToolUse — warns I-22/I-24/I-25), bounded_context_check.py (PostToolUse — warns BC-01..BC-05 import boundaries), load_architecture.py (UserPromptSubmit — arch context on relevant queries). settings.json с абсолютными путями, GOVERNANCE_BYPASS=1 для protect-soul.sh. 30 tests T-01..T-30, suite 324/324.

**G-10 примечание:** DONE (2026-04-05). security/jit_credentials.py: CredentialScope enum (READ_POLICY, EMIT_DECISION, APPEND_AUDIT, CHECK_EMERGENCY, ORCHESTRATE — POLICY_WRITE intentionally absent per I-22/B-06). TemporaryCredential frozen dataclass. InMemoryCredentialStore thread-safe (threading.Lock). ZSP-01: Level-3 blocked from EMIT_DECISION/APPEND_AUDIT/CHECK_EMERGENCY/ORCHESTRATE; Level-2 blocked from ORCHESTRATE. ZSP-02: TTL auto-expiry (default 300s). ZSP-03: all issuance/revocation logged via StructuredLogger.event(). get_credential_manager() singleton. Sprint 5: replace InMemoryCredentialStore with VaultCredentialStore. 31 tests, suite 579/579.

**G-11 примечание:** DONE (2026-04-05). CONTRIBUTING.md: full governance guide with 3-zone table. governance/trust-zones.yaml: machine-readable spec (RED/AMBER/GREEN), path patterns, shared rules SR-01..SR-04, escalation rules. validators/validate_trust_zones.py: CLI --file/--zone/--validate/--check-drift. Zone RED: AI-FORBIDDEN, CLASS_B approval (MLRO+CEO+CTIO), signed commits. Zone AMBER: CLAUDE_CODE_ONLY, architect review, hooks (invariant_check + bounded_context_check). Zone GREEN: PERMITTED (free vibe-coding), CI must pass. trust-zones.yaml self-protecting (Zone RED). 28 tests, suite 579/579.

## P3 — Улучшения зрелости

| ID | Пробел | Принцип | Статус |
|----|--------|---------|--------|
| G-13 | Нет compliance bundle для аудиторов | Compliance-as-Code | DONE |
| G-14 | Нет OPA/Rego runtime enforcement | FINOS AIGF | DONE |
| G-15 | Нет multi-agent review pattern в feedback pipeline | Plan>Build>Review | DONE |
| G-22 | AIGF v2.0 risk catalogue не замаплен на GAP-REGISTER | FINOS alignment | DONE |

**G-22 примечание:** DONE (2026-04-05). governance/aigf-risk-mapping.yaml: 29 рисков по 7 доменам (agent_autonomy, audit_explainability, policy_controls, trust_security, regulatory, data_risks, operational_risks). Статусы: 10 CONTROLLED, 8 PARTIAL, 1 PLANNED, 10 TODO. Привязаны к GAP IDs и инвариантам I-xx. Sprint-3 TODO: AIGF-TODO-01..10 → G-10, G-11, G-13, G-14, G-15 backlog.

**G-13 примечание:** DONE (2026-04-05). utils/compliance_snapshot.py: ComplianceSnapshot dataclass, collect_snapshot() (policy checksums SHA-256, agent passport count, rego rules, GAP summary, git SHA), export_snapshot_zip() (snapshot.json + snapshot.md + 5 policy artefacts), to_markdown() (MLRO-readable report). CLI: python -m compliance.utils.compliance_snapshot --output /tmp/audit.zip. 28 tests, suite 663/663.

**G-14 примечание:** DONE (2026-04-05). security/opa_sidecar.py: OPASidecar class, evaluate_pre_decision(agent_id, action, context) → PolicyDecision (frozen: ALLOW/DENY/ESCALATE). 3 runtime rules: R-01 policy_write blocked for L2/L3 (I-22), R-02 emergency check required (I-23), R-03 ExplanationBundle required >£10K (I-25). Fail-closed: exception → DENY. All evaluations logged via StructuredLogger. 28 tests, suite 663/663.

**G-15 примечание:** DONE (2026-04-05). review/review_agent.py: ReviewAgent independent rule-based reviewer. ReviewRequest/ReviewResult frozen dataclasses. CLASS_B/D → auto REJECT (risk=100), CLASS_C → ESCALATE_TO_HUMAN, CLASS_A → rule scoring (trust zone + invariant I-21/I-22 + BC boundary checks). risk_score > 50 → ESCALATE. All reviews logged append-only (I-24). 28 tests, suite 663/663.

## Спринт-план

### Sprint 0 (архитектурный, 0-1 неделя) — НОВЫЙ

- [x] G-16: Формализовать Port-интерфейсы: PolicyPort, DecisionPort, AuditPort, EmergencyPort — DONE 7b74ebd
- [x] G-18: Реструктурировать в 5 bounded contexts (Compliance, Decision Engine, Policy, Audit, Operations)
- [x] G-21: Настроить Claude Code hooks (policy-guard, invariant-check, bounded-context-check, load-architecture) — DONE 819f315
- [x] G-22: Замапить AIGF v2.0 risk catalogue на GAP-REGISTER — DONE aigf-risk-mapping.yaml

См. подробности: `SPRINT-0-PLAN.md`

### Sprint 1 (немедленно, 1-2 недели)

- [x] G-05: `governance/change-classes.yaml` — запрет auto-apply для Class B (SOUL.md/AGENTS.md) — DONE 5130232
- [x] G-04: Orchestration Tree в AGENTS.md + новые инварианты I-21..I-25 в INVARIANTS.md
- [x] G-03: Завершить G-03 (тесты + Marble UI + deploy) — `emergency_stop.py` уже есть
- [x] G-17: Базовый event store (append-only) для решений агентов — DONE a8b47cb

### Sprint 2 (2-4 недели)

- [x] G-02: `ExplanationBundle` dataclass в `risk_contract.py`
- [x] G-01: Decision Event Log — PARTIAL (код b6541ab: AuditPort ABC, PostgresEventLogAdapter, InMemoryAuditAdapter, decision_events.sql; 15 тестов 89/89 pass; DONE — deployed on GMKtec: Docker PG17, I-24 enforced (INSERT+SELECT only), smoke test passed)
- [x] G-07: `compliance_config.yaml` — DONE (d7a1310: config_loader.py, 18 тестов, 114/114 pass; compliance_validator/explanation_builder/sanctions_check/tx_monitor переведены на config)
- [x] G-19: OPA/Rego для критических инвариантов — DONE (1cbe34d: banxe_compliance.rego + rego_evaluator.py, 25 тестов, 139/139 pass; OPA sidecar → Sprint 3 G-14)
- [x] G-20: Structured logging — DONE (structured_logger.py, ebc54c9). Release pipeline: DONE (ad5e9cf + 17658ce). .github/workflows/compliance-ci.yml (5-step gate). scripts/release.sh (semver + CHANGELOG + 5 pre-release gates).

### Sprint 3 (4-8 недель) — 480 тестов  - [x] G-22: AIGF v2.0 risk mapping — DONE 2dc9794 - [x] G-06: Bounded Context Map — DONE 59bdf2c - [x] G-12: Agent passport — DONE 086667f + 706d97d - [x] G-20: Release pipeline — DONE ad5e9cf + 17658ce

- [x] G-11: Zone RED/AMBER/GREEN в CONTRIBUTING.md + branch protection
- [x] G-08: Policy checksum verification в CI
- [x] G-15: Review agent step в feedback_loop.py

### Sprint 4 (8-16 недель)

- [ ] G-09: Redis hot-path pre-tx gate
- [x] G-10: Vault-based JIT agent credential scoping
- [x] G-14: OPA sidecar pilot (3 критических правила)
- [x] G-13: `compliance_snapshot.py`

### Sprint 5 (2026-04-05) — 663 тестов, ALL P3 DONE

- [x] G-13: Compliance Snapshot Bundle — DONE (28 tests)
- [x] G-14: OPA Sidecar Pilot — DONE (28 tests)
- [x] G-15: Multi-Agent Review Pattern — DONE (28 tests)

### Sprint 8 (2026-04-06) — Midaz CBS Integration + IL System

- [x] ADR-012: Compliance API port :8090→:8093 — DONE (commit 20831f8, DEF-001 resolved)
- [x] ADR-013: Midaz v3.5.3 PRIMARY CBS — DONE (commit 22201fe, midaz-ledger healthy :8095)
- [x] ADR-014: Composable Financial Stack — DONE
- [x] DEF-002: midaz-ledger healthcheck — DONE (distroless/static: `disable:true` + external cron `/usr/local/bin/midaz-healthcheck.sh`, API → "healthy")
- [x] G-16 extension: LedgerPort ABC + MidazLedgerAdapter — DONE (ports/ledger_port.py, adapters/midaz_adapter.py, 14/14 tests passing)
- [x] I-28: Instruction Ledger System — DONE (INSTRUCTION-LEDGER.md, il-check.sh, il_gate.py hook, KA-11 CANON, .claude/CLAUDE.md)
- [ ] Block J: Safeguarding accounts — IN_PROGRESS (org + ledger + GBP asset + 2 accounts created; reconciliation engine pending Sprint 9, deadline 7 May 2026)
- [ ] D-recon: Reconciliation engine — NOT_STARTED (Sprint 9)

### ADR-016 rollout — Phase 3 EMI sync, 2026-05-03

- [x] G-AI-01: No unified AI entrypoint for EMI services — DONE (ADR-016 + I-32; LiteLLM v2 router http://legion:4000/v1 как единая точка входа)
- [x] G-AI-02: Backing-model coupling in service code — DONE (ADR-016 alias contract: ai, ai-heavy, glm-air, reasoning, banxe-general, fast, coding)
- [x] G-PII-01: Risk of PII leak to cloud LLM — DONE (I-33 + banxe-infra/ai-routing/policy.yaml deny-paths)
- [x] G-PII-02: No enforcement on PII deny-paths — DONE (pre-commit hook + review checklist + LiteLLM runtime guard)
- [x] G-MIG-01: Legion → evo1 migration without rollback contract — DONE (ADR-016 §5: dual-stack until verified PASS; Legion --user units сохраняются)

### ADR-017 rollout — P3.4 Keycloak IAM cutover, 2026-05-03 → 2026-05-07

- [ ] G-IAM-01: Keycloak realm `banxe-emi` deployed on evo1 (:8180) — WAITING_FOR_GATE-A
  Strategy-A re-engaged 2026-05-04; artefacts ready in banxe-emi-stack PR #54.
  Awaiting operator `go GATE-A` to execute `docker compose build + up` on evo1.
- [ ] G-IAM-02: OIDC discovery URL `http://evo1:8180/realms/banxe-emi/.well-known/openid-configuration` reachable from EMI services — WAITING_FOR_GATE-A
- [ ] G-IAM-03: Service-to-service tokens provisioned for banxe-compliance-api, banxe-dashboard, deep-search, drive_watcher — NOT_STARTED (ADR-017 §2)
- [ ] G-IAM-04: Realm mappers (service_id, environment, compliance_scope) + audit log retention ≥ 12 months — NOT_STARTED (ADR-017 §4; FCA CASS 15)
- [ ] G-IAM-05: Rotation policy for client_secrets (90 days / on-incident) — NOT_STARTED (ADR-017 §5)
- [x] G-IAM-06: pre-commit hook + Semgrep rule blocking direct credentials in EMI repos — **DONE 2026-05-03** (I-34 enforcement; banxe-emi-stack PR #41 `feat/iam-creds-guard` → squash `3ce0a01`; artefacts: `.semgrep/banxe-rules/iam-no-direct-creds.yml` + pre-commit hook `iam-no-direct-creds` + `docs/CONTRIBUTING.md §IAM Credentials Guard`)
- [ ] G-IAM-07: Backout procedure verified — documented in RUNBOOK.md §GATE-D + §Backout — WAITING_FOR_GATE-A
- [x] G-IAM-08: Keycloak realm cutover via STRATEGY-B host migration to Legion — **DONE 2026-05-04** (banxe-emi-stack PR #50, tag `cass15-iam-cutover-2026-05-07`). Production KC `banxe-emi` UP on Legion `100.101.218.26:8180`. EMI mirror GAP-REGISTER row 54 already reflects this. Reconciles V-05 in HANDOFF-2026-05-04.
- [ ] G-IAM-09: Migrate keycloak-pg sidecar to shared managed Postgres — TECH_DEBT (ADR-017 impl note; schedule TBD)

## Guardian Bash Shim — Gaps (ADR-024)

- [x] G-GUARD-01: Guardian rule coverage for scope `claude.bash` ≥ 4 base rules (CB1..CB4) — **DONE 2026-05-05**
  Closed via ADR-026 (Guardian third family) + MetaClaw `d122a61 feat(guardian): add scope claude.bash with ADR-025 canon ruleset [V-01]`. Deployed to evo1 `/data/banxe/guardian/` (PR #32 → main `c321b40`). Verified positive (`git status -sb` → pass) + negative (`rm -rf / --no-preserve-root` → fail CB4). See INSTRUCTION-LEDGER §IL-CANON-02. Follow-up: G-GUARD-01-EXT (rule coverage to 90% over time, separate work item).
- [x] G-GUARD-02: Switch banxe-emi-stack + vibe-coding to ENFORCE mode (`GUARDIAN_MODE=enforce`) — **DONE 2026-05-05**
  banxe-emi-stack PR #57 (`feat/guardian-enforce-2026-05-05`) flipped `claude-bash-shim.env` defaults audit→enforce, open→closed. Operator `~/.bashrc` updated symmetrically. Live smoke 4/4 expected outcomes (1 pass, 3 BLOCK on CB1/CB2/CB4). New interactive sessions inherit enforce automatically.
- [ ] G-GUARD-03: Guardian ClickHouse retention configured for 12 months (FCA-grade) — NOT_STARTED
  Target: 2026-05-31. Audit trail canonical destination per G-GUARD-03 (I-08, FCA CASS 15).
  Action: evo1 team to verify ClickHouse TTL for Guardian audit table.
- [ ] G-GUARD-04: ENFORCE everywhere (all Claude Code sessions, all repos) — NOT_STARTED
  Target: 2026-05-18. Depends on G-GUARD-01 + G-GUARD-02 verified clean.
  Action: onboarding script to install shim + set enforce mode on all dev machines.


- [x] G-DEPLOY-01: Pipeline-deploy MetaClaw `guardian/` → evo1 `/data/banxe/guardian/` — **DONE 2026-05-05**
  Implemented as evo1 cron pull-deploy (operator-side):
    - Sparse-clone of MetaClaw on evo1: `/home/banxe/MetaClaw-deploy` (filter=blob:none, sparse-checkout=guardian).
    - Cron `*/15 * * * *` runs: `git pull --ff-only origin main && rsync -a --delete guardian/ /data/banxe/guardian/ && sudo systemctl restart banxe-guardian-factory`.
    - Replaces manual scp/rsync from MetaClaw checkout. CI-grade gate is still TBD (GH Actions push-trigger) — tracked as G-DEPLOY-02 (CI-driven deploy, optional follow-up).

## CASS / Safeguarding audit-trail — Gaps (V-06 from HANDOFF-2026-05-04)

- [ ] G-CASS-01: AuditTrail fail-open path leaves CASS reconciliation events un-recorded — NEW 2026-05-05
  Source: V-06 HIGH in HANDOFF-2026-05-04. Components: `src/safeguarding/audit_trail.py` (banxe-emi-stack), `services/recon/reconciliation_engine{,_v2}.py`, `services/safeguarding-engine/app/services/reconciliation_service.py`. Risk: under ClickHouse outage, recon events succeed silently without persisting to immutable log. FCA CASS 15 expects unbroken audit chain.
  Plan (3 steps):
    1. **Audit** (read-only): query ClickHouse `audit_trail` for the last 30 days, compare event counts vs reconciliation_engine state-machine transitions. Identify gap windows. Output: `docs/ops/cass-audit-2026-05-05.md`.
    2. **Propose**: ADR-027 — Audit-trail durability strategy. Options: (a) blocking append (fail-closed), (b) async queue with disk-backed buffer, (c) dual-write to ClickHouse + local SQLite ring-buffer.
    3. **Fix**: implement chosen option, add tests covering ClickHouse-down scenarios, regenerate audit-trail for any identified gap window.
  Owner: Architecture WG. Linked: I-08 (audit-trail invariant TBD), .claude/rules/cass15.md.

- [ ] G-CASS-02: Audit-trail end-to-end coverage tests (no gaps detectable) — NEW 2026-05-05
  Add CI check: pytest fixture that runs a full reconciliation cycle with ClickHouse connection killed mid-flight, asserts every recon event eventually persists OR returns 5xx (no silent success). Owner: Architecture WG.

## KYC / Customer Lifecycle — Gaps (V-03 from HANDOFF-2026-05-04)

- [ ] G-KYC-01: No KYC re-verification trigger on customer / organisation role change — NEW 2026-05-05
  Source: V-03 HIGH in HANDOFF-2026-05-04. Components: `services/customer_lifecycle/lifecycle_engine.py`, `services/customer_lifecycle/lifecycle_observer.py`, `services/hitl/org_roles.py`, `services/kyc/kyc_port.py`. Risk: when an existing customer or organisation member is granted elevated privileges (e.g. authorised signatory, beneficial owner ≥ 25%), KYC tier is not re-assessed → AML/MLR 2017 Reg 27/28 exposure.
  Plan (3 steps):
    1. **Audit** (read-only): trace `org_roles.py` mutations and `lifecycle_engine` transitions; confirm no `on_role_change` / `RoleChanged` event hook exists. Output: `docs/canon/v-03-audit-2026-05-05.md` (one-pager).
    2. **Propose**: ADR-028 — KYC re-verification triggers. Define triggers (role grant, beneficial-ownership change, sanctions list match, recurring 24-month review, jurisdiction change), target FSM transitions in ADR-LCY-01, event payload schema, audit-trail integration.
    3. **Fix**: implement `RoleChanged` event publisher in `org_roles.py`, subscriber in `lifecycle_observer.py` that triggers `KYC_RE_VERIFICATION_REQUIRED` state transition; add tests covering each trigger; canonise via update to ADR-LCY-01.
  Owner: Architecture WG / Compliance lead. Linked: ADR-LCY-01 (canonical lifecycle FSM), .claude/rules/cass15.md, FCA MLR 2017 Reg 27/28.

- [ ] G-KYC-02: KYC trigger coverage tests — NEW 2026-05-05
  Add CI fixture that simulates each canonical trigger (role grant, BO ≥ 25%, sanctions match, 24-month review, jurisdiction change), asserts FSM transitions to KYC_RE_VERIFICATION_REQUIRED, and audit-trail records the event. Owner: Architecture WG.

## Operations / Backups — Gaps (V-07 from HANDOFF-2026-05-04)

- [ ] G-OPS-01: Postgres backup rotation policy not defined for keycloak-pg (post Phase F migration) — NEW 2026-05-05
  Source: V-07 MEDIUM in HANDOFF-2026-05-04. Affected service: `keycloak-banxe-emi-pg` (staging on Legion :8181, will become production after Phase F live switch). Risk: without rotation, FCA CASS 15 audit-trail evidence may be lost (no point-in-time recovery, no documented retention).
  Plan (3 steps):
    1. **Audit** (read-only): inventory existing volume (`keycloak_pg_data`), check disk usage and freshness; document the absence of any rotation cron / WAL archiving.
    2. **Propose**: ADR-029 — Postgres backup strategy. Options: (a) `pg_dump` daily + 14-day rotation to `/data/banxe/backups/`, (b) `wal-g` continuous WAL + 30-day retention to S3-compatible store, (c) `pgBackRest`. Decide based on RPO/RTO + FCA evidence requirements (12-month retention).
    3. **Fix**: implement chosen option, add cron / systemd timer, validate restore on staging, document in `infra/keycloak-banxe-emi/RUNBOOK.md` §Backup. Add G-OPS-01 closure proof (test restore log).
  Owner: Architecture WG / Infra lead. Linked: ADR-017 (Keycloak IAM cutover), G-IAM-09 (Postgres backend).

- [ ] G-OPS-02: Backup-restore CI smoke test (no silent rotation failure) — NEW 2026-05-05
  Add CI fixture (or scheduled job): take a pg_dump from `keycloak-pg`, restore into ephemeral Postgres, verify `banxe-emi` realm + 4 client_credentials grants survive. Run weekly. Owner: Architecture WG.

## API Gateway / Ingress — Gaps (V-12 from HANDOFF-2026-05-04)

- [ ] G-API-01: No rate limiting on `/auth/*` endpoints — NEW 2026-05-05
  Source: V-12 LOW in HANDOFF-2026-05-04 (severity LOW per handoff but security-critical: brute-force / credential-stuffing / SCA-bypass risk on banxe-compliance-api auth surface). Affected: any HTTP entrypoint that proxies to Keycloak realm `banxe-emi` token endpoint, including `/auth/login`, `/auth/refresh`, `/auth/sca/*`, `/auth/token` and analogous routes in `api/routers/auth.py`.
  Plan (3 steps):
    1. **Audit** (read-only): grep all `/auth/*` route handlers in `banxe-emi-stack/api/routers/`, identify which lack rate-limit decorators / middleware. Confirm there is no upstream limiter (nginx / Traefik / Cloudflare). Output: `docs/canon/v-12-audit-2026-05-05.md`.
    2. **Propose**: ADR-030 — Auth-surface rate-limit policy. Recommended baselines: `/auth/login` 5/min/IP, 20/hour/account; `/auth/refresh` 30/min/refresh-token-id; `/auth/sca/verify` 10/min/customer; `/auth/token` (Keycloak) 60/min/client_id. Choose enforcement layer (FastAPI `slowapi`, Traefik middleware, or Keycloak built-in `BruteForceProtector` already enabled in `banxe-emi-realm.json`).
    3. **Fix**: implement chosen layer; emit `429 Too Many Requests` with `Retry-After`; log every limit hit to ClickHouse `audit_trail` (links with G-CASS-01); add tests covering each limit boundary; canonise via update to ADR-024/030.
  Owner: Architecture WG / Security lead. Linked: `banxe-emi-realm.json` (bruteForceProtected=true at realm level — partial coverage), I-32..I-36, ADR-017.

- [ ] G-API-02: Rate-limit coverage tests — NEW 2026-05-05
  Add CI fixture that fires N+1 requests against each `/auth/*` endpoint above its declared limit, asserts exactly the (limit+1)th request returns 429 with `Retry-After` header, and verifies an audit_trail event is recorded. Owner: Architecture WG.

## Infrastructure / Cluster Visibility — Gaps (IL-052 successor)

- [ ] G-INFRA-01: evo2 node missing from `.claude/rules/infrastructure.md` + `SERVICE-MAP.md` — NEW 2026-05-05
  Source: IL-052 post-mortem (phase4 org-cleanup branch recovery). Root cause: evo2 (EVO-X2 #2, 192.168.0.15) was added to the cluster in v2.1 and upgraded in P4.3-EVO2 (BIOS UMA rebalance), but neither the canonical infrastructure rule file nor the service map was updated to reflect it as a named cluster node.
  Risk: agents and operators navigating architecture docs see only evo1 (192.168.0.72). Confusion about which node runs which service (Ollama, llama.cpp RPC worker :50052, Prometheus/Grafana stack) leads to mis-directed operational commands — repeat of IL-052 subjective-loss pattern.
  Plan (3 steps):
    1. **Audit** (read-only): confirm evo2 current state — `ssh banxe@192.168.0.15 "hostname && ip a | grep '192.168' && sudo systemctl is-active ollama"`. Cross-reference with `MetaClaw/docs/roadmap/HW-MODEL-UPGRADE-matrix.md` (authoritative HW spec) and `docs/inventory/banxe-cluster-inventory.md`.
    2. **Update** `.claude/rules/infrastructure.md`: rename current header from "GMKtec EVO-X2" to "evo1 — GMKtec EVO-X2 (192.168.0.72)"; add sibling section "evo2 — GMKtec EVO-X2 #2 (192.168.0.15)" with hostname `banxe-NucBox-EVO-X2-2` (Tailscale: `banxe-nucbox-evo-x2-2`), specs (Ryzen AI MAX+ 395 / 128 GiB LPDDR5X / Radeon 8060S 40 CU gfx1151), services (Ollama :11434 key `sk-banxe-evo2-local-2026`, llama.cpp RPC :50052, Prometheus :9090, Grafana :3000, Blackbox :9115, node_exporter :9100). Mirror equivalent rows in `SERVICE-MAP.md` header + service table.
    3. **Verify**: `grep -n "evo2\|192.168.0.15" .claude/rules/infrastructure.md SERVICE-MAP.md` returns non-empty from both files. Commit `docs(infra): G-INFRA-01 — add evo2 node to infrastructure.md + SERVICE-MAP [G-INFRA-01]`.
  Owner: Architecture WG. Linked: ADR-018 (5-layer hybrid AI compute), IL-052, INS-2026-05-04-P4.3-EVO2, `MetaClaw/docs/roadmap/HW-MODEL-UPGRADE-matrix.md`.

## CI / Deploy Pipeline — Gaps (V-08 from HANDOFF-2026-05-04)

- [ ] G-CI-01: No end-to-end smoke gate before merge / auto-deploy — NEW 2026-05-05
  Source: V-08 MEDIUM in HANDOFF-2026-05-04. Existing CI gates in `banxe-emi-stack/.github/workflows/`: `quality-gate.yml`, `lint-python.yml`, `lint-frontend.yml`, `alembic-check.yml`, `claude-*.yml` — all unit/lint level. Missing: a smoke job that exercises a real boot-and-call path (KC token grant via realm `banxe-emi`, ClickHouse audit append, reconciler tick, safeguarding endpoint, Guardian /audit) before a PR can merge into main. Risk: regressions only caught post-merge; production-state change without smoke evidence violates IL-CANON-04 §best-decision (cannot pick "best" without smoke signal).
  Plan (3 steps):
    1. **Audit** (read-only): inventory existing workflows + their job-level dependencies; identify minimal smoke surface (5-7 endpoints) that proves "system boots and answers". Output: `docs/canon/v-08-audit-2026-05-05.md`.
    2. **Propose**: ADR-031 — CI smoke-gate policy. Define: which workflow file (`smoke-gate.yml`), trigger (PR opened + push to main), env (ephemeral docker compose with KC + Postgres + ClickHouse + Guardian-mock), required-status check on `main` branch protection, time budget (≤ 7 min), rollback signal.
    3. **Fix**: implement `smoke-gate.yml`, add to branch-protection required checks, document in `docs/ops/`. Subsumes G-OPS-02 (backup-restore smoke) and aligns with G-DEPLOY-02 (CI-driven deploy).
  Owner: Architecture WG / DevOps lead. Linked: `quality-gate.yml`, G-DEPLOY-02, G-OPS-02, IL-CANON-04.

- [ ] G-CI-02: Required-check enforcement — NEW 2026-05-05
  After G-CI-01 implementation: switch GitHub branch-protection on `main` so that `smoke-gate` is a required status check (not just advisory). Audit existing required checks; document in `INSTRUCTION-LEDGER` IL-CI-01. Owner: Architecture WG.


## Observability — Gaps (V-10 from HANDOFF-2026-05-04, reframed)

> V-10 reads "Keycloak realm alerts not wired to PagerDuty". PagerDuty NOT deployed (not in stack).
> Reframed as product-neutral: Keycloak audit events exist but reach no alert channel.

- [ ] G-OBS-01: Keycloak audit events not wired to any alert channel — NEW 2026-05-05
  **Source:** V-10 (HANDOFF-2026-05-04, MEDIUM).
  **Components:** `infra/keycloak-banxe-emi/realms/banxe-emi-realm.json` (`eventsListeners = []`), n8n :5678, Telegram Bot.
  **Risk:** `LOGIN_ERROR`, `CLIENT_LOGIN_ERROR`, `TOKEN_EXCHANGE_ERROR` events are captured by Keycloak internally but silently dropped — no ops team notification on auth anomalies.
  **Current state:** `eventsEnabled=True`, 18 event types enabled, `adminEventsEnabled=True` — but `eventsListeners` is not set, so events are stored in KC DB only (default 0-day expiry).
  **Plan:**
    1. Audit — confirm `eventsListeners` empty in live realm: `GET /admin/realms/banxe-emi` → inspect `eventsListeners`.
    2. ADR-033 — choose routing channel: (a) n8n webhook trigger → Telegram bot (lowest friction — n8n+Telegram already in stack for safeguarding alerts); (b) Keycloak SPI Event Listener → direct Slack webhook; (c) Prometheus Alertmanager + external on-call tool (heaviest, requires Prometheus deploy).
    3. Fix — implement chosen option; set `eventsListeners` in realm-export; add KC event retention (≥90 days for audit trail).
  **Owner:** Platform WG.
  **Linked:** ADR-017 §GATE-D (realm provisioning), ADR-033 (to be opened), G-IAM-01, I-24.

- [ ] G-OBS-02: Alert-coverage CI smoke test for Keycloak auth events — NEW 2026-05-05
  **Source:** G-OBS-01 follow-on.
  **Components:** `tests/integration/` or dedicated smoke fixture, Keycloak Admin API, alert channel endpoint.
  **Risk:** Without a smoke test, alert routing regressions are invisible until a real auth incident goes unnoticed.
  **Plan:**
    1. CI fixture: POST synthetic `LOGIN_ERROR` event via Keycloak Admin API (`POST /admin/realms/banxe-emi/events`).
    2. Assert event reaches alert channel within 60 s (poll endpoint / check Telegram bot / inspect n8n execution log).
    3. Run in `quality-gate.yml` smoke job after KC health check.
  **Owner:** Platform WG.
  **Linked:** G-OBS-01, ADR-033, G-CI-01.


## KYC Webhook Reliability — Gaps (V-11 from HANDOFF-2026-05-04)

> V-11: "SumSub webhook retry policy undefined" — MEDIUM.
> Audit: inbound SumSub webhook handling exists (signature via x-payload-digest, audit-log I-24),
> but no idempotency key tracking and no DLQ path for inbound SumSub events.
> Existing webhook_orchestrator/dead_letter_queue.py covers outbound delivery only.

- [ ] G-KYC-03: SumSub webhook retry / dead-letter handling not defined — NEW 2026-05-05
  **Source:** V-11 (HANDOFF-2026-05-04, MEDIUM).
  **Components:**
    - `services/webhooks/webhook_router.py` — inbound SumSub handler (HMAC-SHA1 sig, audit-log); no idempotency key.
    - `services/webhook_orchestrator/dead_letter_queue.py` — DLQ exists but wired to outbound delivery only.
    - `services/webhook_orchestrator/delivery_engine.py` — exponential backoff retry for outbound; not wired to inbound SumSub path.
    - `api/routers/kyc.py` — no retry or DLQ routing for SumSub events.
    - `.env.example` — SUMSUB_WEBHOOK_SECRET not yet registered as env template entry.
  **Risk:**
    If our endpoint returns 5xx, SumSub retries on its schedule (vendor-side). We have no idempotent
    guard: repeated delivery of the same applicant event may cause duplicate KYC FSM transitions or
    be silently dropped, causing silent state-machine drift. FCA MLR 2017 Reg.28 requires complete
    and auditable CDD records — a missed or duplicated KYC decision event is a compliance gap.
  **Plan:**
    1. Audit: trace full inbound path — `webhook_router.py` → KYC FSM trigger → state write.
       Confirm: (a) which field carries idempotency (applicantId + type + createDate?),
       (b) whether duplicate delivery causes double FSM transition,
       (c) what HTTP status is returned on handler error.
    2. Propose ADR-034 — Webhook reliability strategy (KYC inbound). Options:
         (a) Idempotency key store (Redis/Postgres) + always 200 OK + background processing
             (most robust — decouples SumSub retry from our processing latency).
         (b) Inline retry via tenacity on downstream calls only + idempotency check at entry
             (simpler, in-process, suits low-volume).
         (c) Route failed SumSub events to existing webhook_orchestrator DLQ + reprocessor worker
             (reuses existing infra, adds inbound routing to DLQ).
    3. Fix: implement chosen option; add SUMSUB_WEBHOOK_SECRET to .env.example;
       cover 5xx delivery / replay / out-of-order event scenarios in tests (G-KYC-04).
  **Owner:** Platform WG.
  **Linked:** ADR-034 (to be opened), ADR-LCY-01, G-KYC-01 (FSM PENDING trigger),
              G-KYC-02 (re-verification triggers), FCA MLR 2017 Reg.28.

- [ ] G-KYC-04: Webhook signature verification + idempotency-key coverage tests — NEW 2026-05-05
  **Source:** G-KYC-03 follow-on.
  **Components:** `tests/test_webhook_router.py`, `tests/test_webhook_audit.py`, `services/webhooks/webhook_router.py`.
  **Risk:** Existing tests cover happy-path signature check; no tests for:
    replay attack (same event delivered twice), out-of-order delivery (REJECTED before COMPLETED),
    5xx response triggering SumSub retry, and missing/wrong x-payload-digest header.
  **Plan:**
    1. Add parametrised test: duplicate event → assert idempotent (single FSM transition).
    2. Add test: out-of-order delivery (REJECTED after already COMPLETED) → assert no state regression.
    3. Add test: invalid signature → assert 401 + audit-log entry (no FSM transition).
    4. Add test: handler error path → assert correct HTTP status returned to SumSub.
  **Owner:** Platform WG.
  **Linked:** G-KYC-03, ADR-034, .claude/rules/cass15.md, FCA MLR 2017 Reg.28.

## Что реализовано лучше стандарта

| Преимущество | Почему это важно |
|-------------|------------------|
| feedback_loop.py + REFUTED corpus | Monzo строил 4+ года. BANXE имеет с фундамента. |
| SOUL.md + AGENTS.md в Git (версионированы) | KPMG называет это «agent passport». Редкость у нео-банков. |
| ADR-007..011 + CI schema gate | FCA supervisory reviews требуют именно такую документацию. |
| Policy provenance chain до ClickHouse | policy_scope в audit_trail — прямое доказательство FCA MLR 2017 |
| scenario_registry.yaml I-1..I-10 | Machine-verifiable invariants — редкость на этом этапе. |
| governance/change-classes.yaml (CLASS_B) | Защита от auto-rewriting SOUL.md — опережает FINOS AIGF рекомендации. |
