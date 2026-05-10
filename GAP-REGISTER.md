# GAP-REGISTER.md — Реестр архитектурных | 12-Factor Factor III | DONE |пробелов BANXE
> **Scope:** Architecture-level canon GAPs (G-FACTORY-*, G-PROJECT-*, G-SECURITY-*, G-COMPLIANCE-*, G-INFRA-*, G-CI-*, etc).
> **Counterpart:** `docs/GAP-REGISTER.md` tracks **operational EMI sprint** GAPs (GAP-001..NNN, FCA Authorisation Blockers, Sprint Assignment).
> **Per Sprint S5 F4 reconciliation 2026-05-09:** Two GAP-REGISTER.md files coexist with distinct purposes. Не duplicate. See IL-OPS-SPRINT-S5-F4-DOCUMENTATION-RECONCILIATION-2026-05-09.

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
- [x] G-IAM-09: Migrate keycloak-pg sidecar to shared managed Postgres — **DONE 2026-05-06** (IL-PHASE-F-01)
  Production KC realm `banxe-emi` switched from dev-file (H2) to Postgres backend (postgres:16-alpine sidecar). Compose replaced via Phase F procedure from RUNBOOK §Phase F. Downtime: 2 min 44 sec. Postgres volume: `keycloak_pg_data` (named, Legion). 4/4 client_credentials smoke PASS. Phase G settings re-applied post-import (realm JSON predated Phase G). Execution log: `docs/ops/phase-f-execution-2026-05-06.md`. Source: ADR-017 §G-IAM-09 closure.
- [x] G-IAM-10: KC realm `banxe-emi` session-timeout hardening (Phase G) — **DONE 2026-05-06** (V-02 closed, IL-PHASE-G-01)
  Applied via Admin REST API (curl+JWT; kcadm.sh OOM on Legion). Pre-state captured, 4 fields updated: `offlineSessionMaxLifespanEnabled=true`, `offlineSessionMaxLifespan=5184000`, `refreshTokenMaxReuse=0`, `revokeRefreshToken=true`. Post-state verified, smoke PASS (`expires_in=900`, `refresh_expires_in=0` correct per RFC 6749 §4.4). Execution log: `docs/ops/phase-g-execution-2026-05-06.md`. Source: ADR-017 §5, ADR-030.

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

- [x] G-CASS-01: AuditTrail fail-open path leaves CASS reconciliation events un-recorded — DONE 2026-05-06
  Source: V-06 HIGH in HANDOFF-2026-05-04. Components: `src/safeguarding/audit_trail.py` (banxe-emi-stack), `services/recon/reconciliation_engine{,_v2}.py`, `services/safeguarding-engine/app/services/reconciliation_service.py`. Risk: under ClickHouse outage, recon events succeed silently without persisting to immutable log. FCA CASS 15 expects unbroken audit chain.
  Resolution (ADR-027 Accepted 2026-05-06): implemented SQLite ring-buffer (Option b).
    - banxe-emi-stack PR #66: `BufferedAuditPort` — SQLite WAL ring-buffer, 8 unit tests.
    - banxe-emi-stack PR #67: DI wiring (`get_recon_engine`), `AUDIT_FAIL_CLOSED` flag, 4 integration tests.
    - banxe-emi-stack PR #68: `scripts/audit-buffer-drain.py` cron drain, 3 smoke tests. Total: 15 tests, 0 new deps.
  Owner: Architecture WG. Linked: ADR-027 (Accepted), I-08, .claude/rules/cass15.md.

- [ ] G-CASS-02: Audit-trail end-to-end coverage tests (no gaps detectable) — NEW 2026-05-05
  Add CI check: pytest fixture that runs a full reconciliation cycle with ClickHouse connection killed mid-flight, asserts every recon event eventually persists OR returns 5xx (no silent success). Owner: Architecture WG.

## KYC / Customer Lifecycle — Gaps (V-03 from HANDOFF-2026-05-04)

- [x] G-KYC-01: No KYC re-verification trigger on customer / organisation role change — DONE 2026-05-09 (ADR-028 Accepted)
  Source: V-03 HIGH in HANDOFF-2026-05-04. Components: `services/customer_lifecycle/lifecycle_engine.py`, `services/customer_lifecycle/lifecycle_observer.py`, `services/hitl/org_roles.py`, `services/kyc/kyc_port.py`.
  Resolution: `ROLE_CHANGED` + `BENEFICIAL_OWNER_CHANGED` events wired through FSM lifecycle engine (`notify_attribute_change()`). Implementation: banxe-emi-stack PRs #69/#70/#99.
  Owner: Architecture WG / Compliance lead. Linked: ADR-028 (Accepted), ADR-LCY-01, FCA MLR 2017 Reg 27/28.

- [x] G-KYC-02: KYC trigger coverage tests — DONE 2026-05-09 (ADR-028 Accepted)
  Resolution: `JURISDICTION_CHANGED` event (CRITICAL) + 12 tests (8 unit + 4 smoke) + operational check script (`scripts/kyc-retrigger-check.py`). Implementation: banxe-emi-stack PRs #69/#70/#99. Owner: Architecture WG.

## Operations / Backups — Gaps (V-07 from HANDOFF-2026-05-04)

- [x] G-OPS-01: Postgres backup rotation policy not defined for keycloak-pg — DONE 2026-05-10 (ADR-029 Accepted)
  Source: V-07 MEDIUM in HANDOFF-2026-05-04. Affected service: `keycloak-banxe-emi-pg`.
  Resolution: BackupPort + PgDumpBackupAdapter + factory DI + BACKUP_ENABLED flag + rotation policy (keep_last=7 default). Implementation: banxe-emi-stack PRs #102/#104/#106.
  Owner: Architecture WG / Infra lead. Linked: ADR-029 (Accepted), ADR-017, G-IAM-09.

- [x] G-OPS-02: Backup-restore CI smoke test (no silent rotation failure) — DONE 2026-05-10 (ADR-029 Accepted)
  Resolution: 15 tests (6 unit + 5 integration + 4 smoke) + pg-backup-run.py cron script with exit-code verification. Implementation: banxe-emi-stack PRs #102/#104/#106. Owner: Architecture WG.

## API Gateway / Ingress — Gaps (V-12 from HANDOFF-2026-05-04)

- [x] G-API-01: No rate limiting on `/auth/*` endpoints — DONE 2026-05-10 (ADR-030 Accepted)
  Resolution: RateLimiterPort + RedisRateLimiterAdapter + sliding window + lockout on `/auth/login` (per-IP) and `/auth/token/refresh` (per-token-prefix). Implementation: banxe-emi-stack PRs #107/#108/#109.
  Owner: Architecture WG / Security lead. Linked: ADR-030 (Accepted), ADR-017, I-32..I-36.

- [x] G-API-02: Rate-limit coverage tests — DONE 2026-05-10 (ADR-030 Accepted)
  Resolution: 17 tests (6 unit + 6 integration + 5 smoke) covering threshold, lockout, window reset, per-endpoint isolation, router wiring. Implementation: banxe-emi-stack PRs #107/#108/#109. Owner: Architecture WG.

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
- [x] G-INFRA-02: evo2 GPU userspace stack — **DONE 2026-05-05** (Vulkan/RADV gfx1151 verified; ROCm not required for Ollama Vulkan backend; rocminfo/clinfo deferred to G-ROCM-01 if HIP path needed)
  Root cause: user moriel-carmi not in render/video groups (mesa-vulkan-drivers 25.2.8 already installed correctly). Fix: `usermod -aG render,video moriel-carmi`. Verify: `vulkaninfo --summary` shows Radeon 8060S Graphics (RADV GFX1151), Vulkan 1.4.318.
  Anchors: docs/roadmap/audit-2026-05/A3-gap-analysis.md, ADR-018, INS-2026-05-04-P4.2-ROCM-BLOCKED.
  Priority: P1.

- [x] G-INFRA-03: RAM imbalance evo1↔evo2 — **EVALUATED 2026-05-05, NOT PURSUED** (Option D: ROI 74 MiB only; Frankfurter+MiroFish effectively-stateful via cross-host Postgres/LiteLLM dependencies; swap pressure root-caused separately in G-INFRA-04)
  Investigation: docker stats shows frankfurter=41 MiB + mirofish=33 MiB (total 74 MiB / 30 GiB = 0.23%). Swap 3.6 GiB from OTHER services. Migration cost: cross-host Postgres reconfig + LiteLLM exposure + uploads sync. ROI negative.
  Anchors: docs/roadmap/audit-2026-05/A3-gap-analysis.md, A2 baseline, IL-PA-05-CLOSE.
  Priority: P1 (closed as evaluated-not-pursued).

- [ ] G-INFRA-04: evo1 swap pressure root cause (3.6 GiB swap used) — OPEN
  Discovered during PA-5 investigation 2026-05-05. evo1 30 GiB RAM, 3.6 GiB swap. Frankfurter+MiroFish only 74 MiB combined — not the cause. Likely culprit: Midaz/Marble/Ballerine/Jube heavy containers or midaz-ledger restart-loop OOM (see G-OPS-03).
  Action: identify top RSS consumers on evo1; correlate with swap usage; consider container memory limits or service consolidation.
  Anchors: G-INFRA-03 (closed), G-OPS-03 (midaz-ledger restart), IL-PA-05-CLOSE.
  Priority: P2.

- [x] G-OPS-04: banxe-frankfurter zombie restart-loop on evo1 — CLOSED 2026-05-06 → IL-OPS-G-OPS-04-2026-05-06
  Discovered in PA-5a-extended (IL-PROJECT-AUDIT-01). Container `banxe-frankfurter` (image `hakanensari/frankfurter:latest`) на evo1 имеет RestartCount=6051; Memory=25 MiB; CPU=0% idle между крашами; DATABASE_URL направлен на `172.17.0.1:5432` (host gateway), но host Postgres НЕ слушает на :5432 (verified via ss -tlnp). 0 TCP connections на :8181; 0 proxy/ingress/code refs. Zombie state нарушает Operator canon Principle 1 ("evo1 не должен задыхаться") через restart-loop CPU churn.
  Action: decommission via runbook `docs/runbooks/pa-05-frankfurter-decommission.md` (steps gated on operator go).
  Rollback: documented in runbook §"Rollback plan" — requires new Postgres frankfurter DB with rotated password per IL-SEC-01.
  Anchors: docs/runbooks/pa-05-frankfurter-decommission.md, IL-SEC-01, IL-PA-05-CLOSE (где G-INFRA-03 closed как NOT PURSUED), docs/canon/operator-canon-2026-05.md.
  Priority: P2.

- [x] IL-SEC-01: Frankfurter Postgres password exposed in PA-5a logs (2026-05-05) — CLOSED (canon applied, no live secrets)
  During PA-5a (2026-05-05) `docker inspect banxe-frankfurter` on evo1 revealed DATABASE_URL with Postgres password in operator logs → password considered permanently compromised. Mitigated by canon IL-SEC-01-2026-05-06: old password banned from reuse; any future Frankfurter DB provisioning MUST generate new random credentials. Current state: no Frankfurter DB exists → no live secrets to rotate.
  Anchors: docs/runbooks/pa-05-frankfurter-decommission.md, G-OPS-04, PA-5a logs (2026-05-05), IL-SEC-01-2026-05-06 in INSTRUCTION-LEDGER.md.
  Priority: P1 (security canon applied; effectively closed pending future DB provisioning).

- [ ] G-OPS-05: evo1 keycloak.service restart-loop (zombie) — OPEN 2026-05-06
  Discovered FA-4a (IL-FACTORY-AUDIT-01). evo1 has `keycloak.service` in `activating auto-restart` state. Two docker containers `keycloak` and `test-iam` exited (137) 5 days ago. NO :8180 listener on evo1. ADR-017 + G-IAM-08 (DONE 2026-05-04) made Legion the canonical authority — evo1 keycloak deployment is now legacy.
  Action: decommission analogous to G-OPS-04 frankfurter pattern — `docker compose down` on `/data/banxe/banxe-emi-stack/infra/keycloak-banxe-emi/docker-compose.yml`, disable systemd `keycloak.service`, remove containers. Runbook deferred (separate operator-gated execution).
  Anchors: ADR-017, G-IAM-08, FA-4a discovery, docs/canon/operator-canon-2026-05.md (Principle 1 — evo1 not choke).
  Priority: P3 (zombie tolerable; restart-loop CPU cost minimal compared to frankfurter).
  Update 2026-05-06: keycloak.service observed HEALTHY on evo1 — active (running), port :8180 listening (java pid=705370), db-url=jdbc:postgresql://127.0.0.1:15433/keycloak, uptime ~3h. No restart-loop at observation time. Gap reclassified to MONITOR; decommission deferred. See IL-OPS-G-OPS-05-OBSERVED-2026-05-06.
- [x] G-OPS-03: midaz-ledger restart loop resolved — **DONE 2026-05-05** (existing redis-stack container stopped SIGTERM 4 days ago; midaz-ledger expected Redis on 172.22.0.1:6379 (host gateway midaz-network) per Variant 2 lightweight topology in docker-compose.midaz.yml)
  Fix: `docker start redis` (recovery existing container redis/redis-stack:latest). Verify: midaz-ledger "Connected to Redis/Valkey in STANDALONE mode ✅".
  Follow-up: G-OPS-05 — set restart policy=unless-stopped on redis container to prevent recurrence.
  Anchors: docs/roadmap/audit-2026-05/A3-gap-analysis.md, ADR-013, IL-001 Midaz healthcheck fix, IL-PA-01-CLOSE.
  Update 2026-05-05 (PA-1e): Root cause identified = three-fold config drift (1) postgres@16-main listens on 5433 not 5432, (2) listen_addresses=localhost only (no 172.22.0.1 docker bridge), (3) midaz DBs/role not provisioned. NOT an OOM or container defect. PA-1 runbook ready: docs/runbooks/pa-01-midaz-ledger-postgres-provisioning.md. Phase A-F gated on operator go (superseded by redis fix — retained as DR reference).
  Priority: P0 (closed).

- [x] G-FACTORY-01: Legion has no local model serving — DONE 2026-05-06 (FA-1 executed successfully — qwen2.5-coder:7b live on Legion RTX 4070 via LiteLLM factory-fast route; HTTP 200, 5533 MiB VRAM, 100% GPU, content="OK" verified) — OPEN
  - 2026-05-06: runbook fa-01-legion-ollama-coder-install.md drafted; awaiting operator execution go
  Discovered 2026-05-05 in IL-AUDIT-01 A1. Legion has llama.cpp built but no weights, no ollama. RTX 4070 Laptop (CUDA-capable, 8 GB VRAM) idle for inference. All routine coding-agent calls go either to cloud API or to evo1/evo2 via LiteLLM:4000.
  Action: FA-1 (install ollama + qwen3:4b 2.5 GB on Legion; wire as `factory-fast` route in LiteLLM).
  Anchors: docs/roadmap/audit-2026-05/A4-agents-orchestration-proposal.md.
  Priority: P2.

- [x] G-FACTORY-02: Keycloak realm split-brain (resolved) — DONE 2026-05-06 (FA-4a discovery: no actual split-brain. ADR-017 + G-IAM-08 cutover 2026-05-04 made Legion canonical authority `100.101.218.26:8180` for `banxe-emi` realm. evo1 :8180 NOT listening; evo1 keycloak.service in restart-loop but NO consumer references. A3 risk assessment was based on pre-cutover state. Successor zombie issues split out: G-OPS-05 (evo1 keycloak restart-loop) + G-FACTORY-04 (Legion 2x keycloak Java orphan).)
  Discovered 2026-05-05 in IL-AUDIT-01 A1. Legion listens on :8180 (Keycloak banxe-emi realm host-installed dev-file backend). evo1 also has :8180 reserved per ADR-016/017 with Postgres backend (IL-IAM-09 staging validated). Two Keycloak instances on same realm name = classic IAM split-brain risk.
  Action: FA-4 (confirm canonical Keycloak per ADR-017; decommission Legion-side OR convert to read-only mirror; document in .claude/rules/infrastructure.md).
  Anchors: docs/roadmap/audit-2026-05/A3-gap-analysis.md, ADR-017, G-IAM-01..09.
  Priority: P1.

- [x] G-FACTORY-LITELLM-DUPLICATE: two systemd units on :4000 (user-level litellm-v2.service vs system-level litellm-lan-gateway.service) — CLOSED 2026-05-06
  Discovered FA-2 execute (IL-FA-02-EXEC). Both units enabled+active, both ExecStart pointing to same config /home/mmber/MetaClaw/litellm/litellm-config.v2.yaml --port 4000 --host 0.0.0.0. user-level wins SO_REUSEPORT race (started earlier May06 01:17:50); system-level fails bind, uvicorn falls back to random port (e.g., :12734, :17861). Functionally LiteLLM works because user-level is canonical owner of :4000, but every restart of system-level wastes ~5s + spawns orphan listener.
  Action options:
    (a) Disable system-level litellm-lan-gateway.service permanently (`sudo systemctl disable --now litellm-lan-gateway`); user-level remains canonical. Update .bashrc comment block at line 137-138 to mention litellm-v2.service instead of generic litellm.service.
    (b) Disable user-level litellm-v2.service; rely on system-level. Risk: user-level was the working one for last 1+ hour, more proven.
    (c) Keep both, change one to a different port (e.g., :4001 for system as fallback). Useful for HA but adds complexity.
  Recommendation: (a) — minimal change, user-level already proven working with FA-2 aliases.
  Anchors: FA-2 execute (IL-FA-02-EXEC), .bashrc lines 137-138, /etc/systemd/system/litellm-lan-gateway.service, ~/.config/systemd/user/litellm-v2.service.
  Priority: P2 (operational hygiene; not blocking; wastes ~5s per system-level restart attempt).
  Update 2026-05-06: Option (a) applied — `sudo systemctl disable --now litellm-lan-gateway.service`;
  symlink in multi-user.target.wants removed. `ss -tlnp | grep :4000` shows only python
  pid=4052653 (user-level litellm-v2.service). Canonical gateway confirmed: user-level
  litellm-v2.service binding 0.0.0.0:4000. See IL-OPS-G-FACTORY-LITELLM-DUPLICATE-2026-05-06.
- [x] G-FACTORY-03: Ruflo identity reclassified — DONE 2026-05-06 (FA-3 discovery: Ruflo is internal Banxe Review Agent / Claude Code subagent for regulatory boundary enforcement, not a PATH binary; documented in .claude/rules/agents.md + agent passports + IL-008 review reports; not "missing", just misclassified in A1 baseline which checked only PATH) — OPEN
  Update 2026-05-06 (FA-3): IL-008 review report at docs/reviews/IL-008-review.md confirms operational use; pipeline mandate per .claude/rules/agents.md (request → ARL → Ruflo → target agent → response for payment/compliance/kyc). Lesson: A1 inventory missed canonical agent fleet by checking only `command -v`, not `.claude/agents/` + `.claude/rules/agents.md`.
- [ ] G-FACTORY-04: Legion :8180 keycloak Java processes — MONITOR/VERIFY 2026-05-06
  Initial FA-4a observation suggested 2 keycloak Java processes on :8180 (pid 3221994 + pid 3354617). As of 2026-05-06 verification on Legion: `ps aux | grep keycloak` → 0 Java processes; `ss -tlnp | grep :8180` → LISTEN without users field; `sudo lsof -i :8180` → docker-proxy (PID 3979260/3979267, root). Gap reclassified to MONITOR/VERIFY: watch for future orphan Java processes and validate container Keycloak configuration.
  Action: identify which pid is the live one (linked to docker container), gracefully stop the other. Read-only verification first (`ps`, `docker inspect`, `lsof :8180`).
  Anchors: FA-4a discovery, G-IAM-08 (cutover artefact), Legion-side keycloak install dirs `/home/mmber/keycloak-banxe-emi-legion`, `/home/mmber/keycloak-banxe-emi-pg-test`.
  Priority: P3 (Quarkus consumes ~750 MB RAM each → ~1.5 GB total used; second process is wasted RAM but not breaking anything).
  Update 2026-05-06: No Java Keycloak processes found on Legion :8180; only docker-proxy. Original "2 orphan Java procs" not confirmed. See IL-OPS-G-FACTORY-04-OBSERVED-2026-05-06.
- [x] G-FACTORY-CHAIN: agents.md chain matrix not formalised — DONE 2026-05-06 (FA-5: agent-chain × GSD-phase matrix added to .claude/rules/agents.md with 6 canonical chains A-F; Ruflo placement formalised per FA-3 reclassification; agent-to-LiteLLM-route mapping included per FA-2)
  Anchors: PR #57 (sprint), PR #80 (FA-1), PR #81 (FA-2 runbook), PR #83 (FA-3 reclass), .claude/rules/agents.md, A4 proposal.
  Priority: P3 (closed).
  Discovered 2026-05-05 in IL-AUDIT-01 A1. Briefed CLI fleet includes Ruflo; A1 PATH probe found no `ruflo` binary. Unclear whether tool is missing (gap) or renamed/integrated.
  Action: FA-3 (search alternative names: ruff/ruflo-cli/ruflo-agent; install or reclassify).
  Anchors: docs/roadmap/audit-2026-05/A1 inventory.
  Priority: P3.

- [x] G-CLUSTER-01: qwen3:235b-fp16 fate decided — **DONE 2026-05-05** (Option C: deleted fp16 470GB; canonical max остаётся Q3_K_S 142GB per IL-CANON-OPERATOR-2026-05 principle #3; future quality upgrade tracked via G-MODEL-UPGRADE)
  Root cause: fp16 470 GB won't fit 93 GiB RAM evo2; Q3_K_S (5.1 tok/s, 142 GB) sanctioned as canonical max. `ollama rm qwen3:235b-a22b-fp16` freed ~470 GB (disk 49%→25%).
  Anchors: docs/roadmap/audit-2026-05/A3-gap-analysis.md, INS-2026-05-04-P4.3-Q235-BLOCKED, docs/canon/HW-MODEL-UPGRADE-matrix.md.
  Priority: P2 (closed).

- [x] G-CLUSTER-02: model placement matrix documented — **DONE 2026-05-05** (canonical primary-serves per model decided; dedup execution tracked via G-CLUSTER-03)
  Matrix: evo2 primary for heavy inference (70b, 35b, 30b-a3b, coder-next, glm-4.7, 235b); evo1 keeps small models (4b, 9.7b, 20b) + duplicates retained until G-CLUSTER-03 operator-confirmed cleanup.
  Anchors: docs/canon/HW-MODEL-UPGRADE-matrix.md §"Model placement", A2 baseline.
  Priority: P3 (closed — documentation complete).

- [ ] G-CLUSTER-03: model dedup execution (evo1 cleanup ~134 GB) — OPEN
  Per G-CLUSTER-02 matrix: evo1 retains qwen3:4b, qwen3.5:latest, gpt-oss:20b as primary; remainder (~134 GB: llama3.3:70b, qwen3.5:35b, qwen3-coder-next, qwen3:30b-a3b, glm-4.7-flash) should be removed from evo1 after operator per-model confirmation.
  Action: per-model `ollama rm` on evo1 with operator go per §3.2.
  Anchors: docs/canon/HW-MODEL-UPGRADE-matrix.md, G-CLUSTER-02 (closed).
  Priority: P3.

## G-FACTORY-WSL2-RAM-CAP
<!-- Added: docs/runbook-g-factory-wsl2-ram-cap-2026-05-06-v2 | IL-CANON-HW-BASELINE-2026-05-06 -->

- [x] G-FACTORY-WSL2-RAM-CAP: Legion WSL2 exposes ~23 GiB instead of physical 64 GB RAM — CLOSED-PENDING-OPERATOR 2026-05-07
  Legion physical HW: 64 GB RAM, 4+ TB SSD, NVIDIA RTX 4070 Laptop (8 GB VRAM). WSL2 .wslconfig not
  configured; default cap leaves ~23 GiB visible to Linux, severely constraining coding model selection
  and Ollama blob cache capacity.
  Action: set `memory=56GB` in C:\Users\<user>\.wslconfig; restart WSL2; verify `free -h` shows 50+ GiB;
  re-evaluate coding model beyond 7B-class (e.g. Qwen2.5-Coder-32B or similar).
  Use 4+ TB SSD as Ollama blob cache (OLLAMA_MODELS env to SSD path).
  Anchors: docs/canon/factory-project-stack-2026-05.md §"HW Baseline", IL-CANON-HW-BASELINE-2026-05-06.
  Priority: P2 (blocks optimal factory-layer model; not blocking operations today).
  Runbook: docs/runbooks/fa-wsl2-ram-cap-and-ollama-cache.md
  Update 2026-05-06: Phase A executed; WSL2 cap confirmed (~23.5 GiB of physical 64 GB);
  /mnt/d 3.7 TB SSD available (307 GB used); no local Ollama models on Legion;
  OLLAMA_HOST→evo1 (192.168.0.72:11434); RTX 4070 8 GB VRAM idle.
  See IL-OPS-G-FACTORY-LEGION-PHASE-A-2026-05-06.

## G-FACTORY-OLLAMA-OFFLOAD
<!-- Added: docs/il-ops-phase-a-legion-evo2-2026-05-06 | IL-OPS-G-FACTORY-LEGION-PHASE-A-2026-05-06 -->

- [x] G-FACTORY-OLLAMA-OFFLOAD: Legion has no local Ollama model; RTX 4070 8 GB VRAM idle; all inference routed to evo1 over LAN — CLOSED-PENDING-OPERATOR 2026-05-07
  Legion physical HW: RTX 4070 Laptop 8 GB VRAM, 4+ TB SSD. Currently OLLAMA_HOST=http://192.168.0.72:11434
  (evo1). No coding model runs locally on Legion. RTX 4070 8 GB VRAM is sufficient for a 7B–13B coding
  model (e.g. Qwen2.5-Coder-7B Q8 or 13B Q4). Local GPU inference would reduce LAN latency and remove
  evo1 dependency for Legion-side coding tasks.
  Action: after G-FACTORY-WSL2-RAM-CAP resolved (memory=56GB), install a coding model on Legion via Ollama
  (OLLAMA_MODELS pointing to /mnt/d); configure CUDA for RTX 4070; verify GPU offload in Ollama logs;
  add model routing in LiteLLM config to prefer local GPU for coding tasks.
  Anchors: docs/canon/factory-project-stack-2026-05.md §"HW Baseline", IL-CANON-HW-BASELINE-2026-05-06,
  IL-OPS-G-FACTORY-LEGION-PHASE-A-2026-05-06, G-FACTORY-WSL2-RAM-CAP.
  Priority: P2 (not blocking operations; evo1 handles inference adequately; activates after WSL2 fix).
## HW Baseline Gaps — 2026-05-06
<!-- Added: docs/canon-hw-baseline-2026-05-06-v2 | IL-CANON-HW-BASELINE-2026-05-06 -->

- [~] G-INFRA-EVO1-RAM-VISIBILITY: evo1 OS sees ~30 GiB instead of physical 128 GB — CLOSED-PENDING-OPERATOR 2026-05-07
  evo1 physical HW: 128 GB RAM, large SSD. `free -h` reports ~30 GiB — a BIOS/UMA/firmware
  mismatch, not a real physical limit. This gap blocks honest capacity planning for evo1
  (services, small models, Keycloak, Postgres). All decisions about "evo1 is under pressure,
  migrate to evo2" MUST be suspended or marked pre-audit until this gap is resolved.
  Action: run `sudo dmidecode -t memory`, check BIOS/UEFI for UMA Frame Buffer Size and
  Memory Remap settings; enable Memory Remap if supported; verify `free -h` approaches
  ~128 GiB after BIOS change + reboot.
  Related: G-INFRA-04 (evo1 swap pressure — may be partially explained by this mismatch).
  Anchors: docs/canon/factory-project-stack-2026-05.md §"HW Baseline", IL-CANON-HW-BASELINE-2026-05-06,
  G-INFRA-04.
  Priority: P1 (distorts all evo1 capacity decisions; pre-audit block on migration decisions).
  Runbook: docs/runbooks/fa-evo1-bios-uma-audit.md
  Update 2026-05-06: Phase A executed; physical 128 GB confirmed (8 × 16 GB, DDR5 8000 MT/s);
  OS sees ~31.9 GiB → BIOS/UMA mismatch; Phase C (BIOS audit) required.
  See IL-OPS-G-INFRA-EVO1-PHASE-A-2026-05-06.
  Update 2026-05-07: Phase C executed; UMA Frame Buffer 32G→2G; free -h now 123Gi; lsmem 126G online. PASS.
  Closing IL: IL-OPS-G-INFRA-EVO1-PHASE-C-EXECUTED-2026-05-07.
  Closed-on: 2026-05-07 00:13 CEST (pending operator-confirmation from Mark).

- [ ] G-INFRA-EVO2-GPU-STACK: evo2 GPU stack (ROCm/Vulkan) inactive — qwen3:235b runs CPU-only — OPEN 2026-05-06
  evo2 physical HW: 128 GB RAM, 1.9 TB SSD, AMD GPU. `vulkaninfo` shows llvmpipe software
  renderer only; `rocminfo` not verified functional. qwen3:235b Q3_K_S (142 GB) currently
  runs CPU-only at ~5 tok/s. GPU-offload would significantly improve throughput and unlock
  larger quant or longer context.
  Action: identify AMD GPU model; install correct ROCm version for GPU arch; verify
  `rocminfo` lists the GPU; verify `vulkaninfo` shows hardware Vulkan adapter;
  reconfigure Ollama with ROCm backend (HSA_OVERRIDE_GFX_VERSION if needed);
  re-select maximum feasible model under full 128 GB + GPU-offload.
  Related: G-CLUSTER-01 (fp16 deleted because GPU stack was broken; may reopen after fix).
  Anchors: docs/canon/factory-project-stack-2026-05.md §"HW Baseline", IL-CANON-HW-BASELINE-2026-05-06,
  G-CLUSTER-01, G-CLUSTER-03, docs/canon/HW-MODEL-UPGRADE-matrix.md.
  Priority: P1 (project reasoning layer running suboptimally; blocks re-evaluation of heavy model).
  Runbook: docs/runbooks/fa-evo2-gpu-stack.md
  Update 2026-05-06: Phase A executed; AMD GPU [1002:1586] detected in PCIe bus;
  Vulkan 1.3.275 instance OK but zero hardware devices (software/CPU fallback only);
  rocminfo missing; qwen3:235b confirmed CPU-only. Phase B (ROCm+Mesa install) required.
  See IL-OPS-G-INFRA-EVO2-PHASE-A-2026-05-06.

- [x] G-INFRA-EVO2-RAM-VISIBILITY: evo2 OS sees ~93.9 GiB instead of physical 128 GB — CLOSED-PENDING-OPERATOR 2026-05-07
  evo2 physical HW: 128 GB RAM (8 × 16 GB DDR5, confirmed by dmidecode + lshw). `/proc/meminfo` reports
  ~93.9 GiB; `lsmem` shows 96G online. ~34 GB appears BIOS-reserved (likely UMA Frame Buffer or Memory Remap,
  similar pattern to evo1 G-INFRA-EVO1-RAM-VISIBILITY but smaller magnitude — ~73% vs ~25% visible on evo1).
  Can be addressed in the same BIOS session as GPU stack fix (G-INFRA-EVO2-GPU-STACK Phase C/D).
  Action: after GPU stack Phase C/D, inspect BIOS for UMA Frame Buffer Size and Memory Remap settings;
  follow fa-evo1-bios-uma-audit.md Phase C pattern for evo2. Verify `free -h` ≥ 110 GiB.
  Related: G-INFRA-EVO1-RAM-VISIBILITY (same BIOS/UMA pattern; evo1 is P1 due to larger visibility gap).
  Anchors: docs/canon/factory-project-stack-2026-05.md §"HW Baseline", IL-CANON-HW-BASELINE-2026-05-06,
  IL-OPS-G-INFRA-EVO2-PHASE-A-2026-05-06, G-INFRA-EVO1-RAM-VISIBILITY, docs/runbooks/fa-evo1-bios-uma-audit.md.
  Priority: P2 (OS sees ~94 GiB; sufficient for current workloads; lower urgency than P1 GPU stack fix).
  Update 2026-05-07: BIOS verified physically — UMA Frame buffer Size already [2G]; free -h now 123Gi; lsmem 126G online. PASS (verify-only, no BIOS change applied).
  Closing IL: IL-OPS-G-INFRA-EVO2-RAM-VISIBILITY-VERIFIED-2026-05-07.
  Verified-on: 2026-05-07 00:45 CEST (pending operator-confirmation from Mark).
- [x] G-CANON-HW-BASELINE: canonical HW baseline was implicit / missing from canon docs — CLOSED 2026-05-06
  Prior to this entry, factory/project stack canon (docs/canon/factory-project-stack-2026-05.md)
  did not record physical HW specs. Decisions about model selection, service placement, and
  capacity were implicitly based on OS-visible metrics (WSL2 ~23 GiB, free -h ~30 GiB evo1,
  ~93 GiB evo2) rather than physical hardware.
  Mitigated by: adding "## HW Baseline" section to docs/canon/factory-project-stack-2026-05.md
  and recording IL-CANON-HW-BASELINE-2026-05-06 (BINDING, P1).
  Anchors: docs/canon/factory-project-stack-2026-05.md §"HW Baseline", IL-CANON-HW-BASELINE-2026-05-06.
  Priority: P2 (closed — canon applied).


- [ ] G-CANON-AGENT-PLACEMENT-MIGRATION (P1, OPEN, 2026-05-07)
    Текущая агентская топология не соответствует §1.bis (factory↔project
    layers). Требуется audit OpenClaw/Guardian configs на Legion, evo1,
    evo2 и миграция cross-layer агентов в правильные layer'ы.
    Closing IL: TBD.
    Anchors: IL-CANON-FACTORY-PROJECT-LAYERS-2026-05-07,
    docs/canon/factory-project-stack-2026-05.md §1.bis.

- [x] G-FACTORY-LITELLM-DUPLICATE-REGRESSION (P1, CLOSED-FALSE-POSITIVE, 2026-05-07)
    На evo1 обнаружен второй LiteLLM listener на 127.0.0.1:4000
    (live audit 2026-05-07 02:00 CEST). Нарушает «один канонический
    gateway» (canon §2). PR #104 (G-FACTORY-LITELLM-DUPLICATE CLOSED) был
    merged 2026-05-06; регрессия. **CLOSED-FALSE-POSITIVE 2026-05-07:** на evo1:4000 был Google IDX preview, не LiteLLM; реально один canonical LiteLLM на Legion.
    Closing IL: IL-OPS-R1-R2-FACTORY-PROJECT-EXECUTION-2026-05-07.
    Anchors: PR #104, IL-CANON-FACTORY-PROJECT-LAYERS-2026-05-07.


- [ ] G-GUARDIAN-WEBHOOK-MISSING (P1, OPEN, 2026-05-07)
    Branch protection на main требует guardian-factory + guardian-project status checks от GitHub App id 15368. Guardian services здоровы на evo1:8195/8196, но GitHub webhook delivery не настроена — нет webhook'ов в репо, check_runs total_count=0. Требуется: GitHub App credentials, публичный HTTPS endpoint (через cloudflared / nginx), webhook handler в Guardian с check_run posting back. До исправления: branch protection bypass window per IL-CANON-PROCESS-INCIDENT-2026-05-07-PROTECTION-WINDOW.
    Closing IL: TBD.
    Anchors: IL-CANON-PROCESS-INCIDENT-2026-05-07-PROTECTION-WINDOW, PR #121/#122/#123/#124.

- [x] G-FACTORY-OLLAMA-HOST-WRONG (P1, CLOSED-PENDING-OPERATOR 2026-05-07)
    Legion .bashrc had export OLLAMA_HOST=http://192.168.0.72:11434 (LAN unreachable from WSL2 historical). Cleaned via sed; ollama drop-in now sets OLLAMA_HOST=127.0.0.1:11434 systemwide.
    Closing IL: IL-OPS-R1-R2-FACTORY-PROJECT-EXECUTION-2026-05-07.

- [x] G-FACTORY-OLLAMA-CACHE-MISSING (P2, CLOSED-PENDING-OPERATOR 2026-05-07)
    OLLAMA_MODELS unset; /mnt/d unused. Now: ollama drop-in sets OLLAMA_MODELS=/mnt/d/ollama-models, /etc/wsl.conf has metadata mount option, blobs migrated.
    Closing IL: IL-OPS-R1-R2-FACTORY-PROJECT-EXECUTION-2026-05-07.

- [ ] G-CANON-PROJECT-AGENTS-BYPASS-GATEWAY (P1, OPEN, 2026-05-07)
    Project-агенты на evo1 (OpenClaw ctio/guiyon/moa, banxe-api с OLLAMA_URL=http://127.0.0.1:11434) ходят напрямую в local Ollama, минуя Legion LiteLLM gateway. Нарушение §1.bis п.3 «единственный шов — LiteLLM gateway». Требуется миграция endpoint'ов на http://100.101.218.26:4000 с правильным master_key.
    Closing IL: TBD.
    Anchors: IL-CANON-FACTORY-PROJECT-LAYERS-2026-05-07,
    IL-OBSERVE-R3-AGENT-AUDIT-2026-05-07,
    docs/sessions/HANDOFF-2026-05-07-fixes-roadmap.md.

- [ ] G-INFRA-EVO1-PORT-4000-COLLISION (P3, OPEN, 2026-05-07)
    На evo1 порт 4000 (TCP, 127.0.0.1) занят Google IDX preview / Firebase emulator (HTML «Copyright 2020 Google LLC»). Не блокер сейчас, но мешает развернуть real LiteLLM на evo1 если потребуется.
    Anchors: IL-OPS-R1-R2-FACTORY-PROJECT-EXECUTION-2026-05-07.

- [ ] G-INFRA-EVO1-LOAD-AVG-35 (P2, OPEN, 2026-05-07 — ROOT-CAUSE-IDENTIFIED: XMRig cryptominer)
    Постоянный load avg ~35 на evo1 (3 пользователя). Источник heavy CPU не идентифицирован в текущих аудитах. Нужно отдельное расследование (top -c, htop, iotop).
    **2026-05-07 escalation:** root cause identified as unknown daemon /etc/systemd/system/systemd.service (PID 2127, ≈2911% CPU, 38 threads). Effective priority escalated to P1 until daemon classified. See G-SECURITY-EVO1-UNKNOWN-SYSTEMD-SERVICE.
    **2026-05-07 ROOT-CAUSE-IDENTIFIED:** daemon classified as XMRig-compatible RandomX/Monero CPU miner. See G-SECURITY-EVO1-XMRIG-CRYPTOMINER (P0). Awaiting remediation.
    Anchors: IL-OPS-R1-R2-FACTORY-PROJECT-EXECUTION-2026-05-07, IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-UNKNOWN-DAEMON, IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-XMRIG-IDENTIFIED.

- [ ] G-CI-WORKFLOWS-FAILING (P2, OPEN, 2026-05-07)
    .github/workflows/ci.yml fails 0s + docs.yml fails 17s on every push to main / PR.
    Likely: gitleaks-action triggers on 8 historical leaks in repo; mkdocs build --strict
    on broken docs. Не блокирует merge (branch protection требует только guardian-*),
    но шумит и скрывает реальные fail'ы.
    Closing IL: TBD.
    Anchors: IL-OBSERVE-R3-AGENT-AUDIT-2026-05-07,
    docs/sessions/HANDOFF-2026-05-07-fixes-roadmap.md §6.

- [ ] G-SECURITY-HISTORICAL-LEAKS (P1, OPEN, 2026-05-07)
    gitleaks v8.30.1 detect reports 8 leaks in 469-commit git history.
    Open credentials (tokens/keys/passwords) in repo history.
    Requires: rotation каждого leaked credential + filter-repo cleanup
    + force-push (security-focused session).
    Closing IL: TBD.
    Anchors: docs/sessions/HANDOFF-2026-05-07-fixes-roadmap.md §6.

- [ ] G-FACTORY-GITIGNORE-INCOMPLETE (P3, OPEN, 2026-05-07)
    .gitignore не исключает .claude/settings.local.json, CLAUDE.local.md.
    Risk: accidental commit of personal overrides per §1.bis.
    Action: add lines к .gitignore.
    Closing IL: TBD.
    Anchors: docs/sessions/HANDOFF-2026-05-07-fixes-roadmap.md §6.

- [ ] G-SECURITY-EVO1-UNKNOWN-SYSTEMD-SERVICE (P1, ESCALATED → P0 via G-SECURITY-EVO1-XMRIG-CRYPTOMINER, 2026-05-07)
    **ESCALATED:** daemon classified as XMRig-compatible cryptominer. See G-SECURITY-EVO1-XMRIG-CRYPTOMINER (P0) for full evidence and remediation plan.
    Original discovery: unknown root daemon masquerading as systemd on evo1.
    Anchors: IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-UNKNOWN-DAEMON,
    IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-XMRIG-IDENTIFIED,
    G-SECURITY-EVO1-XMRIG-CRYPTOMINER.

- [ ] G-SECURITY-EVO1-XMRIG-CRYPTOMINER (P0, OPEN — IDENTIFIED, 2026-05-07)
    **Active malware on project-layer node evo1.** XMRig-compatible RandomX/Monero CPU miner
    masquerading as systemd. GDPR/FCA-relevant compromise of project layer node hosting
    BANXE customer-data services.
    **Hard evidence:**
    - Binary: /usr/local/bin/systemd
      SHA256: baca0922a6ce82f250d15c7b71a209f0ba60274ff7e9654338900020a36de6c4
      Size: 3149464 bytes, Owner: root:root, Mode: 755, Mtime: Apr 23 07:05
      Type: ELF 64-bit LSB executable, x86-64, statically linked, no section header
      BuildID[sha1]: c746d5445679e29ea09a8ae5bdc7fbbbf3720c44
      Packed: UPX (lsof shows /memfd:upx). Not owned by any dpkg package.
    - Unit file: /etc/systemd/system/systemd.service
      SHA256: a7e0975fbd52853cd757ce4e09a42de1402ec967ad187794d6d6bd88aa026b24
      Size: 259 bytes, Mtime: Apr 23 07:05
      UnitFileState=enabled, ExecStart=systemd -c .config.json, User=root,
      Restart=always, RestartSec=30, LimitNOFILE=8192, LimitNPROC=8192
    - Config: /usr/local/bin/.config.json (XMRig schema)
      Mtime: Apr 23 07:05. Sections: randomx, cpu (32 threads), pools (single, tls=true),
      donate-level=1. Algorithms: cn, cn-heavy, cn-lite, cn-pico, cn/upx2, ghostrider,
      rx, rx/wow, argon2. Log file: .bench.log (6.9 MB).
    - C2/pool: ESTABLISHED tcp 192.168.0.72:44496 → 136.243.75.233:8029
      PTR: static.233.75.243.136.clients.your-server.de
      ASN: AS24940 Hetzner Online GmbH (DE). TLS encryption per config.
    - Process: PID 2127, root, 38 threads, ~2911% CPU, started 2026-05-07 01:03:48 CEST.
      Binary install date: Apr 23 07:05 (mtime).
    **IoC list (for sweep on evo2 + Legion):**
    - sha256_binary: baca0922a6ce82f250d15c7b71a209f0ba60274ff7e9654338900020a36de6c4
    - sha256_unit:   a7e0975fbd52853cd757ce4e09a42de1402ec967ad187794d6d6bd88aa026b24
    - path_binary:   /usr/local/bin/systemd
    - path_unit:     /etc/systemd/system/systemd.service
    - path_config:   /usr/local/bin/.config.json
    - path_log:      /usr/local/bin/.bench.log
    - pool_ip:       136.243.75.233
    - pool_port:     8029
    - pool_ptr:      static.233.75.243.136.clients.your-server.de
    - buildid:       c746d5445679e29ea09a8ae5bdc7fbbbf3720c44
    - masquerade:    process "systemd", unit "systemd.service", description "System Proxy Service"
    - sha256_observed_unit:  53d664a4eecf377193161193e8d0ec9f3852c55d48a124e4f1097cd87d8d51e0
    - sha256_freeproc_sh:    5cae515b56e50ee8fd4fa86b46eedf1e1713badc9fafb287f826876b2cc475d4
    - path_observed_unit:    /etc/systemd/system/observed.service
    - path_freeproc_sh:      /usr/local/bin/free_proc.sh
    - watchdog_pattern:      "ps | awk '$2>200 && !/systemd/' | xargs kill -9"
    - install_event_unified: /usr/local/bin/{systemd, .config.json, free_proc.sh} +
                             /etc/systemd/system/{systemd, observed}.service all
                             mtime 2026-04-23 07:05 (single deployment script)
    **Compliance flags:**
    - GDPR: potential personal data exposure (project layer hosts BANXE customer-data services)
    - FCA: potential incident-reporting obligation (EMI license)
    - Internal: unauthorized root binary, full host compromise must be assumed
    **Decision rule:** read-only IoC sweep evo2+Legion BEFORE any destructive action on evo1.
    Full compromise audit evo1 BEFORE stop/disable/cleanup. Forensic artifact preservation mandatory.
    **Containment status (2026-05-07, A16-a executed):**
    Network containment APPLIED via host iptables on evo1.
    Rule: iptables -I OUTPUT 1 -d 136.243.75.233 -j DROP
          -m comment --comment "BANXE-IL-CANON-INCIDENT-2026-05-07-EVO1-XMRIG-CONTAINMENT"
    State: rule active, counter at install pkts=0/bytes=0; conntrack entry for
    pool IP cleared by kernel. XMRig PID 2127 and watchdog PID 2111 still running
    (not touched). Mining shares cannot reach pool. Persistence: RUNTIME-ONLY,
    will be removed on reboot — must transition to A16-d cleanup before any reboot.
    Rollback: single iptables -D command (documented in IL-OPS-EVO1-CONTAINMENT).
    Forensic impact: ZERO.
    **Cleanup ordering (binding, awaiting operator-confirmation):**
    1. systemctl stop observed.service
    2. systemctl stop systemd.service
    3. systemctl disable observed.service systemd.service
    4. systemctl mask observed.service systemd.service
    5. forensic artifact bundle creation (sha256 manifest)
    6. file removal /usr/local/bin/{systemd,.config.json,free_proc.sh,.bench.log}
       and /etc/systemd/system/{systemd,observed}.service
    Network containment (iptables OUTPUT DROP 136.243.75.233 OR Tailscale isolation)
    is preferred first mitigation, safe vs watchdog.
    **Supersedes:** G-SECURITY-EVO1-UNKNOWN-SYSTEMD-SERVICE (P1).
    **2026-05-08 status: CONTAINED** — exfiltration blocked via host-level
    iptables-persistent on evo1 (136.243.75.233/32 + Hetzner ranges /16+/15).
    XMRig PID 2127 in SYN-SENT loop; forensic chain preserved (no kill/rm).
    Hit counters: /32 ≈ 8921 pkts / 660 KB. Forensic bundle on Legion (off-host),
    sha256 dfd6c9b5..., chain-of-custody verified. IoC sweep evo2+Legion: CLEAN
    (all 7 IoC criteria no-match, compromise scope localised to evo1 at sweep time).
    Gap remains OPEN until Phase 1 forensic preservation + Phase 5 compromise audit
    + Phase 6 credentials rotation + Phase 8 remediation complete.
    See IL-INCIDENT-2026-05-07-CONTAINMENT-APPLIED-HOST-LEVEL,
    IL-INCIDENT-2026-05-07-IOC-SWEEP-EVO2-LEGION-CLEAN.
    **2026-05-08 IoC expansion:** Phase 1 Step 3 analysis identified 2 additional
    persistence artefacts in same mtime-transaction (2026-04-23 07:05):
    - /etc/systemd/system/observed.service (SHA256 53d664a4eecf..., 226 bytes,
      watchdog/respawn unit)
    - /usr/local/bin/free_proc.sh (SHA256 5cae515b56e5..., 130 bytes, executable,
      competing-miner killer script)
    These were already in cleanup ordering but not in original IoC sweep checklist.
    Supplemental re-sweep evo2+Legion required: G-SECURITY-EVO2-IOC-RESWEEP-OBSERVED-FREE-PROC,
    G-SECURITY-LEGION-IOC-RESWEEP-OBSERVED-FREE-PROC.
    **2026-05-08 containment verification:** XMRig .bench.log confirms 0.00/0.00/0.00 H/s
    continuously since iptables-persistent DROP. Pre-containment max: 16004.8 H/s.
    Containment effective.
    **2026-05-08 forensic chain:** Phase 1 Steps 1e+2+3 complete (off-host on Legion).
    SHA256 chain: Step 1e 7adfbe1e..., Step 2 196524233bea..., Step 3 74d71a45...,
    Step 3 analysis 5ccca1fd.... Steps 4–7 pending operator.
    See IL-INCIDENT-2026-05-07-IOC-EXPANSION-OBSERVED-FREE-PROC,
    IL-INCIDENT-2026-05-08-PHASE1-FORENSIC-CHAIN-PRESERVED,
    IL-INCIDENT-2026-05-08-CONTAINMENT-EFFECTIVENESS-VERIFIED.
    **2026-05-08 status: CONTAINED-MALWARE-REMOVED** — malware fully removed
    by external action between Step 3 (09:27 CEST) and Step 4 (~11:59 CEST).
    PID 2127 GONE, systemd.service + observed.service = Unit could not be found,
    CPU load ≈1.2 (normalised). Exact actor: external (parallel session / operator /
    automation) — to be confirmed by operator.
    Forensic chain intact: Bundle B on evo1 (/tmp/banxe_forensic_254683/) confirmed
    present + Bundle B .tar.gz on Legion off-host (SHA256 dfd6c9b5...).
    Phase 1 Step 4 fs-audit: no additional malicious artefacts; LD_PRELOAD clean;
    SUID-window clean; dpkg -V no system-binary tampering.
    Step 4 forensic: SHA256 a8718dbe... (494 lines), analysis dd418f05... (34K),
    Step 4b: SHA256 3ae092c0... (136 lines).
    mmber1234 dpkg -V false-alarm: /etc/default/ufw standard config, NOT a credential.
    INTRUSION VECTOR NOT DETERMINED — auth.log/syslog Apr 22-23 rotated out of
    retention window. Root-cause analysis incomplete.
    Gap remains OPEN until: Phase 5 post-cleanup audit, Phase 6 credentials rotation,
    Phase 7 AML/KYC integrity verification, Phase 8 hardening, Phase 9 review.
    GDPR Art. 33 / FCA SUP 15 assessment still required (malware removal does not
    eliminate obligation to assess 14-day compromise window).
    See IL-INCIDENT-2026-05-08-PHASE1-STEP4-FS-AUDIT-COMPLETE,
    IL-INCIDENT-2026-05-08-MALWARE-REMOVED-EXTERNAL-ACTION,
    IL-INCIDENT-2026-05-08-BUNDLE-B-CHAIN-INTACT.
    **2026-05-08 status: RESOLVED-PENDING-MLRO-ACK** — containment + remediation +
    post-cleanup verification complete. Awaiting MLRO/DPO compliance assessment
    finalisation for GDPR Art. 33 / FCA SUP 15 / AMLR. Vector NOT determined
    (worst-case assumption applies). Cleanup-actor PENDING operator confirmation.
    See IL-INCIDENT-2026-05-08-PHASE5-POST-CLEANUP-VERIFIED-COMPLETE,
    IL-INCIDENT-2026-05-08-CLEANUP-ACTOR-NOT-IDENTIFIED,
    IL-INCIDENT-2026-05-08-VECTOR-NOT-DETERMINED-LOGS-ROTATED.
    Closing IL: TBD (requires MLRO/DPO compliance assessment + operator confirmation).
    Anchors: IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-UNKNOWN-DAEMON,
    IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-XMRIG-IDENTIFIED,
    IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-OBSERVED-CLASSIFIED,
    G-INFRA-EVO1-LOAD-AVG-35, G-SECURITY-EVO1-UNKNOWN-SYSTEMD-SERVICE.
    **2026-05-08 status: AML/KYC INTEGRITY VERIFIED CLEAN** — Phase 7 confirmed
    AML/KYC pipeline integrity preserved: 0 banxe-* unit tampering, 0 config
    tampering, ClickHouse/Watchman/Marble operational, sanctions screening intact.
    READY-FOR-MONITOR-DECISION by incident commander after Phase 6 init + 24-48h
    observation. See IL-INCIDENT-2026-05-08-PHASE7-AML-KYC-INTEGRITY-VERIFIED-CLEAN
    + IL-INCIDENT-2026-05-08-INCIDENT-READY-FOR-MONITOR-RECOMMENDATION.
    **2026-05-08 22:05 CEST status: STATE TRANSITION P0 → P1 MONITOR** (operator
    decision Option A) — incident commander signed off after complete technical
    phases (0/1/2/3/4/5/7) + AML/KYC integrity verified + containment stable 30+h.
    Observation window 24-48h starts now. Roadmap unfreeze under I-59 active.
    MLRO/DPO/Legal external sign-off pending (parallel-safe).
    See IL-INCIDENT-2026-05-08-STATE-TRANSITION-P0-TO-MONITOR.

- [ ] G-SECURITY-EVO2-IOC-SWEEP-PENDING (P1, OPEN → RESOLVED-PENDING-OBSERVATION, 2026-05-07)
    Read-only IoC sweep evo2 required for XMRig IoC signatures (sha256, paths, pool IP,
    BuildID, masquerade patterns). Same threat actor may have compromised evo2 via same
    vector. No destructive actions until sweep complete.
    **2026-05-08 status: RESOLVED-PENDING-OBSERVATION** — IoC sweep evo2 clean
    (all 7 IoC criteria no-match: no binary, no unit, no config, no active connection
    to pool, no BuildID match, no masquerade unit). Compromise scope localised to evo1
    at sweep time. Gap remains OPEN until Phase 5 compromise audit evo1 confirms
    intrusion vector + reasonable observation window passes.
    See IL-INCIDENT-2026-05-07-IOC-SWEEP-EVO2-LEGION-CLEAN.
    Closing IL: TBD.
    Anchors: G-SECURITY-EVO1-XMRIG-CRYPTOMINER, IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-XMRIG-IDENTIFIED.

- [ ] G-SECURITY-LEGION-IOC-SWEEP-PENDING (P1, OPEN → RESOLVED-PENDING-OBSERVATION, 2026-05-07)
    Read-only IoC sweep Legion (factory layer) required for XMRig IoC signatures.
    Lower probability (WSL2, different access vector) but factory-layer compromise
    would affect all downstream trust. No destructive actions until sweep complete.
    **2026-05-08 status: RESOLVED-PENDING-OBSERVATION** — IoC sweep Legion clean
    (all 7 IoC criteria no-match). Factory-layer compromise not confirmed.
    Gap remains OPEN until Phase 5 compromise audit evo1 confirms intrusion vector
    + reasonable observation window passes.
    See IL-INCIDENT-2026-05-07-IOC-SWEEP-EVO2-LEGION-CLEAN.
    Closing IL: TBD.
    Anchors: G-SECURITY-EVO1-XMRIG-CRYPTOMINER, IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-XMRIG-IDENTIFIED.

- [ ] G-SECURITY-EVO1-COMPROMISE-AUDIT-PENDING (P0, OPEN, 2026-05-07)
    Full compromise audit evo1 required BEFORE any cleanup/remediation:
    authorized_keys, /etc/{passwd,shadow}, sudoers, cron/timer enumeration,
    last/lastlog, .bash_history, profile.d/, other masqueraded systemd units,
    SSH logs since 2026-04-22 (binary mtime minus 1 day).
    Forensic artifact preservation mandatory before any destructive action.
    **2026-05-07 results:** read-only audit complete via ssh -tt evo1 sudo bash. Findings:
    - 1 confirmed XMRig (G-SECURITY-EVO1-XMRIG-CRYPTOMINER, P0)
    - 1 sudoers backdoor (G-SECURITY-EVO1-CTIO-SUDOERS-BACKDOOR, P0)
    - 1 unknown systemd unit at same mtime (G-SECURITY-EVO1-OBSERVED-SERVICE-UNKNOWN, P0)
    - 3 unauthorized/non-canon users (G-SECURITY-EVO1-UNAUTHORIZED-USERS, P0)
    - sshd public root login still open (G-SECURITY-EVO1-SSHD-ROOT-LOGIN-OPEN, P0)
    - root authorized_keys with non-canon identity (G-SECURITY-EVO1-ROOT-AUTHORIZED-KEYS-AUDIT, P0)
    - cross-layer key contamination (G-SECURITY-LEGION-ALEX-KEY-CROSSCONTAMINATION, P1)
    - unsigned cron auto-pull supply-chain risk (G-SECURITY-EVO1-CRON-PULL-UNSIGNED, P2)
    Status: GAP remains OPEN as parent tracker; closes when all 7 derived GAPs are CLOSED.
    No destructive action taken — fully read-only. Forensic evidence preserved in IL.
    **2026-05-08 status: COMPLETE — POST-CLEANUP VERIFIED** — Phase 5 post-cleanup
    audit confirmed cleanup completeness (6/6 XMRig artefacts removed, 0 rogue
    users/keys/units/cron/sudoers, sshd hardened, Bundle B intact). Vector NOT
    determined (logs rotated). See IL-INCIDENT-2026-05-08-PHASE5-POST-CLEANUP-VERIFIED-COMPLETE.
    Closing IL: TBD.
    Anchors: G-SECURITY-EVO1-XMRIG-CRYPTOMINER, IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-XMRIG-IDENTIFIED,
    IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-COMPROMISE-AUDIT.

- [ ] G-COMPLIANCE-FCA-EMI-INCIDENT-NOTIFICATION (P0, OPEN, 2026-05-07)
    Assessment required: FCA incident reporting obligation for EMI license
    (SUP 15 material incident notification) and GDPR Art. 33 (72h notification
    window for personal data breach). Timer potentially started at discovery
    2026-05-07 11:21 CEST. Operator-decision required: whether discovery of
    cryptominer on project-layer node constitutes a reportable breach
    (personal data exfiltration not confirmed but full host compromise assumed).
    **2026-05-07 escalation:** compromise audit evo1 confirms public root SSH was
    open during Apr 22 (auth.log.2.gz evidence: external bruteforce from
    146.190.83.66 + 138.124.181.144), with successful root login Apr 28 23:34
    from 192.168.0.75. GDPR Art. 33 72h notification timer effective discovery
    moves from 2026-05-07 11:21 (XMRig classification) to 2026-04-22
    (root-login-open-to-internet evidence in logs). Operator-decision required
    on regulatory window calculation and notification scope.
    Linked: G-SECURITY-EVO1-SSHD-ROOT-LOGIN-OPEN, G-SECURITY-EVO1-XMRIG-CRYPTOMINER,
    G-SECURITY-EVO1-COMPROMISE-AUDIT-PENDING, G-SECURITY-EVO1-CTIO-SUDOERS-BACKDOOR.
    Closing IL: TBD.
    Anchors: G-SECURITY-EVO1-XMRIG-CRYPTOMINER, IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-XMRIG-IDENTIFIED,
    IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-COMPROMISE-AUDIT.
    **2026-05-08 status: OPERATOR-ACK-EVIDENCE-CHAIN-COMPLETE** —
    MLRO/DPO/LEGAL-FORMAL-ACK-PENDING. Incident commander acknowledged
    compliance-assessment framework + full evidence chain (PR #132-#137,
    #139, #140; 11 forensic SHA256). T+12h MLRO/DPO ack SLA overdue ~21h,
    T+24h compliance review SLA overdue ~7.5h. GDPR Art. 33 deadline ~40h
    remaining. Final notification decision (Art. 33/34/SUP 15/AMLR) PENDING
    formal MLRO/DPO/CCO/Legal sign-off.
    See IL-INCIDENT-2026-05-07-COMPLIANCE-ASSESSMENT-ACK.
    **2026-05-08 22:05 CEST status: INCIDENT-IN-MONITOR** — evidence chain ready
    for external sign-off; incident transitioned to MONITOR (Option A); MLRO/DPO/
    CCO/Legal may sign-off at any time within GDPR Art. 33 window (~37h remaining).
    See IL-INCIDENT-2026-05-08-STATE-TRANSITION-P0-TO-MONITOR.


- [ ] G-SECURITY-EVO1-CTIO-SUDOERS-BACKDOOR (P0, OPEN, 2026-05-07)
    Backdoor sudoers entry on evo1: /etc/sudoers.d/ctio = "ctio ALL=(ALL) NOPASSWD: ALL".
    User ctio (UID 1002) has unrestricted root without password. mtime: Mar 28 20:04 (older
    than XMRig install Apr 23). Classic privilege escalation persistence.
    Decision rule: NO destructive action until operator-confirmation; preserve as forensic evidence.
    Linked: G-SECURITY-EVO1-XMRIG-CRYPTOMINER (likely escalation vector for XMRig install).
    Closing IL: TBD.
    Anchors: IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-COMPROMISE-AUDIT.

- [ ] G-SECURITY-EVO1-OBSERVED-SERVICE-UNKNOWN (P0, OPEN, 2026-05-07)
    Suspicious systemd unit /etc/systemd/system/observed.service created Apr 23 07:05 — exact
    same mtime as XMRig systemd.service. Size 226 bytes. Likely second persistence unit by same
    threat actor (potential XMRig watchdog or restart guardian).
    Decision rule: read-only classification (cat unit, sha256, classify ExecStart binary)
    REQUIRED before any destructive action on XMRig systemd.service.
    Linked: G-SECURITY-EVO1-XMRIG-CRYPTOMINER, G-SECURITY-EVO1-COMPROMISE-AUDIT-PENDING.
    **2026-05-07 IDENTIFIED:** classification complete. Unit is XMRig watchdog +
    anti-competitor + masquerade enforcer. Implementation: shell loop killing any
    process with %CPU > 200 EXCEPT args matching "systemd" (which is XMRig's own
    masquerade name). SHA256 unit: 53d664a4eecf377193161193e8d0ec9f3852c55d48a124e4f1097cd87d8d51e0.
    SHA256 script: 5cae515b56e50ee8fd4fa86b46eedf1e1713badc9fafb287f826876b2cc475d4.
    Sibling cluster: /usr/local/bin/{systemd, .config.json, free_proc.sh} all mtime
    2026-04-23 07:05 (single install event by same threat actor).
    Operational implication: cleanup ordering MUST be observed.service first, then
    systemd.service, otherwise watchdog kills legitimate heavy workloads after
    XMRig stops.
    Status: stays OPEN until operator-confirmed remediation.
    Closing IL: TBD.
    Anchors: IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-COMPROMISE-AUDIT,
    IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-OBSERVED-CLASSIFIED.

- [ ] G-SECURITY-EVO1-UNAUTHORIZED-USERS (P0, OPEN, 2026-05-07)
    Non-canon users with /bin/bash login shell on evo1 (per /etc/passwd live audit):
    - alex:x:1004:1004:,,,:/home/alex:/bin/bash — NOT in canon BANXE EMI roster.
      Cross-host SSH key correlation: matching public key
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDmlUN8...  alex@MacBook-Pro-Alex.local"
      also present in /home/banxe/.ssh/authorized_keys on evo1 AND in
      /home/mmber/.ssh/authorized_keys on Legion (factory layer).
      This makes alex a potential pivot identity between factory and project layers.
    - ctio:x:1002:1002::/home/ctio:/bin/bash — has NOPASSWD ALL sudo backdoor
      (see G-SECURITY-EVO1-CTIO-SUDOERS-BACKDOOR). /home/ctio/.bash_history
      mtime Apr 1 02:18, size 0 (history cleared).
    - user:x:1001:1001::/home/user — generic name, no canon-justification.
    - Additional unknown identity in /root/.ssh/authorized_keys:
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCfZ9LYz8Ly... egor.kopylov@egit-MacBook-Air.local"
      (mtime Mar 28 12:49). Direct root SSH from outside identity.
    Decision rule: NO destructive action (userdel, lock, key removal) until operator-confirmation.
    Forensic preservation of /home/{alex,ctio,user}, /root/.ssh/authorized_keys mandatory
    before any change. Operator must classify each identity (legitimate teammate vs unauthorized).
    Linked GAPs:
      - G-SECURITY-EVO1-CTIO-SUDOERS-BACKDOOR (P0)
      - G-SECURITY-LEGION-ALEX-KEY-CROSSCONTAMINATION (P1)
      - G-SECURITY-EVO1-ROOT-AUTHORIZED-KEYS-AUDIT (P0)
    Closing IL: TBD.
    Anchors: IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-COMPROMISE-AUDIT.

- [ ] G-SECURITY-EVO1-SSHD-ROOT-LOGIN-OPEN (P0, OPEN, 2026-05-07)
    /etc/ssh/sshd_config.d/10-legion.conf currently active with:
      PermitRootLogin yes
      PasswordAuthentication yes
    Live evidence in /var/log/auth.log.2.gz (Apr 22): public bruteforce attempts
    succeeded Failed-password loops from 146.190.83.66 (DigitalOcean) and
    138.124.181.144. lastlog confirms successful root SSH login from 192.168.0.75
    on Apr 28 23:34:28. Root login mechanism is the most likely vector for
    XMRig install (Apr 23 07:05).
    Currently sshd_config.d/10-legion.conf still permits this; узел остаётся
    уязвим к bruteforce пока конфиг не закрыт.
    Decision rule: NO destructive action until operator-confirmation. Recommended
    remediation (NOT executed): set PermitRootLogin no + PasswordAuthentication no
    in sshd_config.d/10-legion.conf, then systemctl reload sshd. Do not delete
    /root/.ssh/authorized_keys yet — it is forensic evidence.
    Linked GAPs:
      - G-SECURITY-EVO1-XMRIG-CRYPTOMINER (P0)
      - G-SECURITY-EVO1-ROOT-AUTHORIZED-KEYS-AUDIT (P0)
    Closing IL: TBD.
    Anchors: IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-COMPROMISE-AUDIT.

- [ ] G-SECURITY-EVO1-ROOT-AUTHORIZED-KEYS-AUDIT (P0, OPEN, 2026-05-07)
    /root/.ssh/authorized_keys on evo1 (mtime Mar 28 12:49, 690 bytes) contains
    multiple SSH public keys for direct root login:
      - ssh-rsa egor.kopylov@egit-MacBook-Air.local — non-canon identity
      - ssh-ed25519 mmber@mark-legion — operator key (legitimate)
      - one truncated/empty entry (line 1)
    Combined with G-SECURITY-EVO1-SSHD-ROOT-LOGIN-OPEN, these keys grant direct
    root access from external endpoints.
    Decision rule: NO destructive removal until operator confirms which keys are
    canon. Forensic preservation (sha256 manifest) mandatory.
    Linked GAPs:
      - G-SECURITY-EVO1-SSHD-ROOT-LOGIN-OPEN (P0)
      - G-SECURITY-EVO1-UNAUTHORIZED-USERS (P0)
    Closing IL: TBD.
    Anchors: IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-COMPROMISE-AUDIT.

- [ ] G-SECURITY-LEGION-ALEX-KEY-CROSSCONTAMINATION (P1, OPEN, 2026-05-07)
    Same RSA public key alex@MacBook-Pro-Alex.local present in:
      - /home/mmber/.ssh/authorized_keys on Legion (factory layer)
      - /home/banxe/.ssh/authorized_keys on evo1 (project layer)
      - User alex (UID 1004) on evo1 with /bin/bash login shell
    Cross-layer presence violates canon §1.bis principle of factory↔project layer
    isolation. Either alex is a known teammate with legitimate access (pending
    operator-classification) or this is a pivot identity used by attacker between
    layers.
    Decision rule: operator must classify alex identity. NO destructive removal
    until classification + operator-confirmation. If unauthorized — coordinate
    revocation simultaneously across both layers.
    Linked GAPs:
      - G-SECURITY-EVO1-UNAUTHORIZED-USERS (P0)
      - G-SECURITY-EVO1-XMRIG-CRYPTOMINER (P0)
    Closing IL: TBD.
    Anchors: IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-COMPROMISE-AUDIT.

- [ ] G-SECURITY-EVO1-CRON-PULL-UNSIGNED (P2, OPEN, 2026-05-07)
    Cron entries on evo1 auto-execute pulled code without signature verification:
      - banxe crontab: */15 git pull --ff-only origin main + rsync guardian + sudo systemctl restart banxe-guardian-factory
      - root crontab: bash /data/vibe-coding/memory-autosync-watcher.sh
      - root crontab: bash /data/vibe-coding/ctio-watcher.sh
      - root crontab: bash /usr/local/bin/watchdog-watcher.sh
    Supply-chain risk: malicious commit to origin/main → automatic execution.
    Also explains how external git reset to origin/main observed in operator
    session 2026-05-07 12:56 propagated rapidly (separate from XMRig but related
    to G-PROCESS-MEMORY-MD-LEAKAGE / parallel-session-leakage chain).
    Decision rule: NO destructive change until operator decides on signed-commit
    enforcement and/or replacing auto-pull with explicit deploy gate.
    Linked GAPs:
      - G-PROCESS-MEMORY-MD-LEAKAGE (P2)
      - G-SECURITY-EVO1-XMRIG-CRYPTOMINER (P0)
    Closing IL: TBD.
    Anchors: IL-CANON-PROCESS-INCIDENT-2026-05-07-EVO1-COMPROMISE-AUDIT.

- [ ] G-SECURITY-LIVEBOX-NO-OUTBOUND-FILTER (P2, OPEN, 2026-05-08)
    Orange Livebox UI does not support outbound destination filtering.
    Standard firmware exposes only 4 preset firewall levels
    (Faible/Moyen/Élevé/Personnalisé) + incoming NAT/PAT/IPv6 forwarding
    + incoming whitelist. No custom outbound rules, no static-route blackhole,
    no destination-IP blocking via UI.
    Impact: perimeter-level network containment impossible on default ISP CPE;
    host-level iptables is the only available containment mechanism.
    Accepted deviation: host-level iptables on managed node as principal
    containment (see IL-CANON-PROCESS-INCIDENT-2026-05-08-LIVEBOX-LIMITATION).
    Roadmap: deploy secondary downstream router (pfSense/OPNsense/Mikrotik)
    for perimeter-level outbound enforcement.
    Pending invariant: I-67 — host-level iptables accepted principal containment
    with documented deviation + secondary-router roadmap when perimeter router
    lacks outbound destination filtering.
    Linked GAPs:
      - G-SECURITY-EVO1-XMRIG-CRYPTOMINER (P0)
    Closing IL: TBD (secondary router deployment).
    Anchors: IL-CANON-PROCESS-INCIDENT-2026-05-08-LIVEBOX-LIMITATION,
    IL-INCIDENT-2026-05-07-CONTAINMENT-APPLIED-HOST-LEVEL.

- [ ] G-SECURITY-EVO2-IOC-RESWEEP-OBSERVED-FREE-PROC (P1, OPEN → RESOLVED-PENDING-OBSERVATION, 2026-05-08)
    Supplemental IoC re-sweep evo2 required for 2 newly identified artefacts
    from Phase 1 Step 3 analysis (not in original sweep checklist):
    - /etc/systemd/system/observed.service
      SHA256: 53d664a4eecf377193161193e8d0ec9f3852c55d48a124e4f1097cd87d8d51e0
    - /usr/local/bin/free_proc.sh
      SHA256: 5cae515b56e50ee8fd4fa86b46eedf1e1713badc9fafb287f826876b2cc475d4
    Original sweep (IL-INCIDENT-2026-05-07-IOC-SWEEP-EVO2-LEGION-CLEAN) was
    CLEAN but against incomplete IoC list. Read-only. No destructive actions.
    **2026-05-08 status: RESOLVED-PENDING-OBSERVATION** — extended IoC re-sweep
    evo2 CLEAN (Path PASS / Unit PASS / Network PASS). Forensic artefact:
    evo2-resweep.txt SHA256 ad434350c6f5badc5d1f77ef6d72bb815076bf6d7b54897c080bc2042aebddd5.
    Compromise scope formally localised to evo1. Gap remains OPEN until Phase 5
    compromise audit evo1 confirms vector + reasonable observation window passes
    (24-48h re-sweep cadence recommended).
    See IL-INCIDENT-2026-05-08-PHASE2-RESWEEP-COMPLETE.
    Closing IL: TBD.
    Anchors: G-SECURITY-EVO1-XMRIG-CRYPTOMINER,
    IL-INCIDENT-2026-05-07-IOC-EXPANSION-OBSERVED-FREE-PROC,
    IL-INCIDENT-2026-05-08-IOC-RESWEEP-REQUIRED.

- [ ] G-SECURITY-LEGION-IOC-RESWEEP-OBSERVED-FREE-PROC (P1, OPEN → RESOLVED-PENDING-OBSERVATION, 2026-05-08)
    Supplemental IoC re-sweep Legion required for 2 newly identified artefacts
    (same as G-SECURITY-EVO2-IOC-RESWEEP-OBSERVED-FREE-PROC).
    Read-only. No destructive actions.
    **2026-05-08 status: RESOLVED-PENDING-OBSERVATION** — extended IoC re-sweep
    Legion CLEAN (Path PASS / Unit PASS / Network PASS). Forensic artefact:
    legion-resweep.txt SHA256 eb0d4a68ca87ad1d0ff62e6d302d64bc048328018e2699a69993600ee3dcf647.
    Compromise scope formally localised to evo1. Gap remains OPEN until Phase 5
    compromise audit evo1 confirms vector + reasonable observation window passes.
    See IL-INCIDENT-2026-05-08-PHASE2-RESWEEP-COMPLETE.
    Closing IL: TBD.
    Anchors: G-SECURITY-EVO1-XMRIG-CRYPTOMINER,
    IL-INCIDENT-2026-05-07-IOC-EXPANSION-OBSERVED-FREE-PROC,
    IL-INCIDENT-2026-05-08-IOC-RESWEEP-REQUIRED.

- [ ] G-FACTORY-RUFLO-NOT-DEPLOYED (P0, OPEN, 2026-05-09)
    Ruflo regulated-routes proxy NOT deployed on Legion factory infrastructure.
    Required by canon §1.bis for project-layer regulated routes
    (request → ARL → Ruflo → target agent → response). Without Ruflo,
    project-mid / project-heavy / project-reason cannot service regulated
    AML/KYC/MLRO requests in compliance with §0.5 distribution discipline.
    Regulatory blocker for Phase F1 + sandbox 100% completion.
    Closing IL: TBD (Phase F1 — Ruflo deployment + LiteLLM proxy chain wiring + end-to-end regulated request verify).
    Anchors: IL-OPS-FACTORY-LAYER-AUDIT-BASELINE-2026-05-09, bootstrap canon §0.5 + §1.bis + §10 Phase F1.

- [x] G-PROJECT-SECTION-0-COMPLIANCE-AUDIT-PENDING (P0, CLOSED, 2026-05-09)
    Existing project (banxe-emi-stack 27 services + banxe-architecture canon docs)
    requires §0.2 hierarchy compliance audit. Mapping required:
    each existing AI agent / service / role → §0.2 Level 1..5 placement,
    deviations identified, reconciliation plan per deviation.
    Sandbox→Production transition (§0.3) blocked until audit + reconciliation complete.
    Existing JOB-DESCRIPTIONS.md / ORG-STRUCTURE.md / DEPARTMENT-MAP.md /
    RELATIONSHIP-TREE.md provide >70% framework foundation per audit
    IL-OPS-FACTORY-LAYER-AUDIT-BASELINE-2026-05-09, residual gaps to be
    enumerated in Sprint S2.
    Closing IL: TBD (Sprint S2 — project §0 audit completes with per-deviation GAPs).
    Anchors: IL-OPS-FACTORY-LAYER-AUDIT-BASELINE-2026-05-09, bootstrap canon §0.2 + §0.3 + §11 Sprint S2.
    Closing IL: IL-OPS-PROJECT-SECTION-0-COMPLIANCE-AUDIT-2026-05-09 (Sprint S2 audit completed; 5 per-deviation GAPs opened: G-PROJECT-SECTION-0-LEVEL-5-AI-MLRO-AUTONOMOUS-MISSING (P0), G-PROJECT-SECTION-0-LEVEL-3-SMF-HEADS-AI-DUPLICATE-MISSING (P1), G-PROJECT-SECTION-0-LEVEL-2-NO-DUPLICATE-VIOLATION (P1), G-PROJECT-SECTION-0-LEVEL-1-NO-DUPLICATE-VIOLATION (P1), G-PROJECT-SERVICES-COUNT-DRIFT-VS-ROADMAP (P3)).
    Closure verified: 2026-05-09 (CEST).

- [ ] G-FACTORY-EVO2-SSH-ACCESS-LOST (P1, CLOSED-POST-UPDATE, 2026-05-09)
    Original state: evo2 SSH access lost (carryover from V-XMRIG track §22 Phase F2.1).
    2026-05-09 status: CLOSED — operator-applied evo2 power-on + kernel update
    (kernel 6.17.0-23-generic, fresh boot uptime 10 min, boot_id
    23320028-9093-4406-8b4f-7b09d15a35c4) restored SSH access.
    Verification: ssh banxe@evo2 'uname -a; free -h; uptime' returned successfully
    at 2026-05-09 00:47 CEST during IL-OPS-FACTORY-LAYER-AUDIT-BASELINE-2026-05-09.
    Closing IL: IL-OPS-FACTORY-LAYER-AUDIT-BASELINE-2026-05-09.
    Anchors: bootstrap canon §22 Phase F2.1, §9 V-XMRIG carryover.

- [/] G-FACTORY-CLAUDE-SUBAGENTS-MISSING (P1, PARTIAL, 2026-05-09)
    4 canonical Claude subagents (controller, inspector-agent, openclo-moa,
    safeguarding-agent) NOT deployed in ~/.claude/agents/ on Legion.
    Factory audit 2026-05-08 confirmed empty; current audit confirms unchanged.
    Root cause for parallel-session-leakage episodes 6 + 7 per
    IL-CANON-PROCESS-INCIDENT-2026-05-08-PARALLEL-REPO-LEAKAGE +
    IL-CANON-PROCESS-INCIDENT-2026-05-08-CONCURRENT-CC-BRANCH-SWITCH —
    absent controller/inspector subagents leave session isolation
    enforcement to manual operator discipline only.
    Closing IL: TBD (Phase F2.3 — deploy 4 subagents + verify session isolation behavior).
    Anchors: IL-OPS-FACTORY-LAYER-AUDIT-BASELINE-2026-05-09, bootstrap canon §5 + §10 Phase F2.3.
    Status update 2026-05-09 21:21 CEST: 3 of 4 canonical subagents deployed (controller, inspector-agent, safeguarding-agent). openclo-moa.md authoring pending — sub-GAP G-FACTORY-CLAUDE-SUBAGENT-OPENCLO-MOA-MISSING (P2) opened.
    See IL-OPS-SPRINT-S3-F2-3-CLAUDE-SUBAGENTS-PARTIAL-DEPLOYMENT-2026-05-09 for deployment evidence (sha256 verified).

- [ ] G-FACTORY-OVERSEER-AGENT-NOT-DEPLOYED (P1, OPEN, 2026-05-09)
    Factory overseer AI agent (per §0.4) NOT deployed.
    Required functions: continuous monitoring §0.1+§0.2+§0.3 compliance,
    alert on canon deviations, block features that deviate from §0 hierarchy,
    track 100% completion progress (KPI: % of §0.2 roles implemented).
    Without overseer, §0 compliance enforcement is manual only — high drift risk
    during S2-S12 implementation phases.
    Closing IL: TBD (Phase F2.4 — overseer agent deployment + KPI dashboard wiring).
    Anchors: IL-OPS-FACTORY-LAYER-AUDIT-BASELINE-2026-05-09, bootstrap canon §0.4 + §10 Phase F2.4.

- [ ] G-FACTORY-LITELLM-NO-SYSTEMD-SERVICE-UNIT (P2, OPEN, 2026-05-09)
    LiteLLM v2 gateway runs as bare pipx-managed Python process
    (PID 71814, uptime 1d18h at audit) without /etc/systemd/system/litellm-v2.service
    unit. No automatic restart on failure, no boot-time start, no resource limits.
    Risk: factory layer LLM gateway availability tied to single user-session lifetime.
    Closing IL: TBD (Phase F3.1 — create litellm-v2.service systemd unit, User/WorkingDirectory/ExecStart per current invocation, enable + verify restart).
    Anchors: IL-OPS-FACTORY-LAYER-AUDIT-BASELINE-2026-05-09, bootstrap canon §10 Phase F3.1.

- [/] G-FACTORY-LITELLM-ROUTES-VS-CANON-DRIFT (P2, CLASSIFIED-PENDING-OPERATOR, 2026-05-09)
    LiteLLM v2 gateway exposes 20 routes vs 7 canonical (§1.bis).
    14 extra routes per audit 2026-05-09: banxe-general, qwen3-30b, qwen3-banxe,
    fast, glm-4-flash, coding, gpt-oss-20b, large, glm-4.5-air-distributed,
    glm-air, ai, ai-heavy, reasoning, reasoning-235b.
    Decision required per route: legitimate legacy alias / undocumented addition / remove.
    Either canon §1.bis updates to include reconciled aliases, or routes are removed
    from gateway config (/home/mmber/MetaClaw/litellm/litellm-config.v2.yaml).
    Closing IL: TBD (Phase F3.2 — per-route reconciliation decision + canon-or-config update).
    Anchors: IL-OPS-FACTORY-LAYER-AUDIT-BASELINE-2026-05-09, bootstrap canon §5 + §10 Phase F3.2.
    Status update 2026-05-09 22:00 CEST (Sprint S4 F3.2 diagnostic): all 14 extra routes classified — 9 DUPLICATE-ALIASES (recommend REMOVE), 1 UNIQUE-PROMOTE (large → project-heavy candidate), 2 UNIQUE-DECISION (fast / gpt-oss-20b — operator), 2 CROSS-LAYER-VIOLATION (ai-heavy / reasoning — recommend REMOVE per §1.bis strict).
    Cross-layer concern surfaced: factory-mid/heavy/coder configured against evo1+evo2 ollama (project layer nodes) — §1.bis canon update OR Legion model expansion required.
    See IL-OPS-SPRINT-S4-F3-2-LITELLM-ROUTES-RECONCILIATION-DIAGNOSTIC-2026-05-09 for full classification table.

- [/] G-FACTORY-LITELLM-PROJECT-HEAVY-ROUTE-MISSING (P2, RESOLUTION-CANDIDATE-IDENTIFIED, 2026-05-09)
    Canonical project-heavy LiteLLM route (per §1.bis) NOT registered in current
    LiteLLM v2 config. Audit 2026-05-09 confirmed only 6 of 7 canonical routes
    present (project-heavy MISSING). §1.bis says "preserve if registered" —
    factually not registered. Decision required: register project-heavy backed by
    appropriate evo1/evo2 model (candidate: llama3.3:70b on evo2 ollama or
    qwen3.5:35b) OR formally remove project-heavy from §1.bis canonical list.
    Closing IL: TBD (Phase F3.2 — project-heavy register-or-remove decision).
    Anchors: IL-OPS-FACTORY-LAYER-AUDIT-BASELINE-2026-05-09, bootstrap canon §1.bis.
    Status update 2026-05-09 22:00 CEST (Sprint S4 F3.2 diagnostic): existing route `large` (openai/glm-4.5-air @ evo1:8081 distributed inference via glm-master + llama-rpc-worker USB4 Vulkan) matches project-heavy intent. Promotion path: rename `large` → `project-heavy` OR add canonical `project-heavy` aliasing same backend. Operator decision pending.
    See IL-OPS-SPRINT-S4-F3-2-LITELLM-ROUTES-RECONCILIATION-DIAGNOSTIC-2026-05-09 for backend details.

- [ ] G-FACTORY-LITELLM-LEGACY-V1-RUNNING-PARALLEL (P2, OPEN, 2026-05-09)
    Legion runs second LiteLLM instance PID 339 on 127.0.0.1:8080
    (config /home/mmber/litellm-config.yaml, uptime 1d18h) parallel to
    canonical v2 gateway PID 71814 on 0.0.0.0:4000.
    Two additional config files exist on disk: /home/mmber/litellm-config.yaml,
    /home/mmber/litellm_config.yaml, /home/mmber/banxe/MetaClaw/litellm/litellm-config.v2.yaml,
    /home/mmber/MetaClaw/litellm/litellm-config.v2.yaml — 4 configs total.
    Risk: undocumented routing path, divergent route behavior, security surface.
    Closing IL: TBD (Phase F3.2 — verify legacy :8080 instance purpose; either deprecate or document as canonical secondary; consolidate to single config source-of-truth).
    Anchors: IL-OPS-FACTORY-LAYER-AUDIT-BASELINE-2026-05-09.

- [x] G-FACTORY-DISTRIBUTED-INFERENCE-NOT-IN-CANON (P2, CLOSED, 2026-05-09)
    GLM-4.5-Air 105B distributed inference architecture (glm-master.service on evo1
    + llama-rpc-worker.service on evo2 USB4 link 10.0.0.2:50052 Vulkan backend)
    is operational but NOT documented in canon §1.bis routes nor in
    PROMPT-CANON-PROJECT.md two-contour description.
    Concept-level conflict potential: distributed inference spans factory↔project
    layer boundary if glm-master serves cross-layer requests — needs verification
    against §0.5 distribution discipline.
    Closing IL: TBD (Phase F4.1 — canon documentation of distributed inference topology + layer-binding verification).
    Anchors: IL-OPS-FACTORY-LAYER-AUDIT-BASELINE-2026-05-09, bootstrap canon §0.5 + §1.bis.
    Closing 2026-05-09 22:30 CEST (Sprint S5 F4 autonomous): distributed inference topology now documented в docs/LOCAL-CLOUD-ROUTING.md (glm-master.service evo1:8081 + llama-rpc-worker.service evo2:50052 via USB4 + Vulkan; route `large` → project-heavy candidate; layer-assignment concerns per §1.bis).
    See IL-OPS-SPRINT-S5-F4-DOCUMENTATION-RECONCILIATION-2026-05-09.

- [ ] G-FACTORY-SPEC-FIRST-AUDITOR-NOT-DEPLOYED-AT-CANON-PATH (P2, OPEN, 2026-05-09)
    Spec-First Auditor v2 working in pre-commit hook but source NOT deployed at
    canon-prescribed path ~/developer/spec-first/audit/spec_first_auditor.py.
    Audit 2026-05-08 confirmed canon path empty.
    Closing IL: TBD (Phase F3.3 — relocate auditor source to canon path or update §5 canon to factual path).
    Anchors: IL-OPS-FACTORY-LAYER-AUDIT-BASELINE-2026-05-09, bootstrap canon §5 + §10 Phase F3.3.

- [x] G-FACTORY-DOCUMENTATION-PATH-DRIFT (P3, CLOSED, 2026-05-09)
    ROADMAP.md Phase 3 references org/role canon files without `docs/` prefix
    (IL-080 JOB-DESCRIPTIONS.md, IL-082 RELATIONSHIP-TREE.md, etc).
    Files factually located under `docs/`. Minor consistency issue — links
    function via filesystem search but canonical path declarations diverge.
    Closing IL: TBD (Phase F4.1 — ROADMAP.md path normalization sweep).
    Anchors: IL-OPS-FACTORY-LAYER-AUDIT-BASELINE-2026-05-09.
    Closing 2026-05-09 22:30 CEST (Sprint S5 F4 autonomous): 8 path references fixed in ROADMAP.md (docs/ prefix added to ORG-STRUCTURE.md / DEPARTMENT-MAP.md / JOB-DESCRIPTIONS.md / RELATIONSHIP-TREE.md in Phase 2/3 inventory + Document Inventory table). See IL-OPS-SPRINT-S5-F4-DOCUMENTATION-RECONCILIATION-2026-05-09.

- [x] G-FACTORY-CANON-FILES-DUPLICATION (P3, CLOSED-RECLASSIFIED, 2026-05-09)
    Two GAP-REGISTER.md files exist: /home/mmber/banxe-architecture/GAP-REGISTER.md
    (repo root) + /home/mmber/banxe-architecture/docs/GAP-REGISTER.md.
    Source-of-truth ambiguity. This IL declares root /GAP-REGISTER.md canonical.
    docs/GAP-REGISTER.md to be reviewed for divergent entries and either deprecated
    or content migrated.
    Closing IL: TBD (Phase F4.1 — duplicate canon-file reconciliation sweep + add to canon §3 process notes).
    Anchors: IL-OPS-FACTORY-LAYER-AUDIT-BASELINE-2026-05-09.
    Closing 2026-05-09 22:30 CEST (Sprint S5 F4 autonomous): files coexist with distinct purposes — root GAP-REGISTER.md = architecture canon GAPs (G-FACTORY-*, G-PROJECT-*, etc); docs/GAP-REGISTER.md = operational EMI sprint GAPs (GAP-001..NNN format).
    Namespace clarification headers added to BOTH files. Reclassified from "duplicate" to "two distinct artifacts". See IL-OPS-SPRINT-S5-F4-DOCUMENTATION-RECONCILIATION-2026-05-09.

    **2026-05-08 cleanup-actor: CONFIRMED PARALLEL CLAUDE CODE SESSION** —
    best-decision (§4 BDP) based on Bundle B preservation (mtime 2026-05-07 21:54),
    PR #138 parallel activity, journalctl absence, sshd hardening pre-Step-5.
    Authorised internal, forensic-first. Recurring pattern (3rd in 7d). Pending I-68.
    See IL-INCIDENT-2026-05-08-CLEANUP-ACTOR-CONFIRMED-PARALLEL-SESSION.

- [ ] G-PROJECT-SECTION-0-LEVEL-5-AI-MLRO-AUTONOMOUS-MISSING (P0, OPEN, 2026-05-09)
    Bootstrap canon v3 §0.2 Level 5 requires autonomous AI MLRO agent
    NOT subordinate to CEO, with sign-authority for SAR / sanctions / AML decisions;
    human MLRO co-sign / override only on legal-regulatory edge cases.
    Existing pattern: human MLRO Sarah Mitchell SMF17 + AI subagents
    (AML-Analyst-v1, KYC-Specialist-v2, SanctionsScreeningAgent,
    ComplianceOfficerAgent, ChainAnalysisAgent, CryptoAMLAgent,
    CryptoSanctionsAgent, TravelRuleAgent) feeding decisions to human MLRO.
    HITL Decision Gates §6 require "MLRO + CEO" co-sign for
    SAR retraction / Sanctions reversal / PEP onboarding — violates §0.2
    "AI MLRO NOT subordinate to CEO" if interpreted strictly.
    Independence verified: MLRO function declared independent from CFO + reports to Board (ORG-STRUCTURE §7.1).
    Closing IL: TBD (Phase F5.5 — autonomous AI MLRO agent deployment with sign-authority + Ruflo MANDATORY routing + HITL Gates §6 update for AML decisions).
    Anchors: IL-OPS-PROJECT-SECTION-0-COMPLIANCE-AUDIT-2026-05-09, bootstrap canon v3 §0.2 Level 5 + §10 Phase F5.5 + §11 Sprint S10.

- [ ] G-PROJECT-SECTION-0-LEVEL-3-SMF-HEADS-AI-DUPLICATE-MISSING (P1, OPEN, 2026-05-09)
    Bootstrap canon v3 §0.2 Level 3 requires each Head of Department = AI agent + human duplicate; AI makes operational decisions, human override authority.
    Existing pattern (SMF C-suite Heads): CRO / CFO David Goldstein / COO TBC / CTO Oleg @p314pm — all human only, no documented AI duplicate.
    Existing pattern (sub-Heads): Head of Treasury Marcus Webb (with PaymentRouterAgent partner), Head of FP&A (with Budget+Forecast+Variance+Scenario agents), Head of Reg Reporting (with FCA Data + Reg Data Quality + FCA Return Generator + Resolution Pack agents), Head of Customer Support Tom Nakamura (with CustomerLifecycleAgent + TicketRoutingAgent + CustomerSupportAgent + EscalationAgent partners) — close to §0.2 pattern but not formalised.
    Closing IL: TBD (Phase F5.3 — deploy AI duplicates for SMF C-suite Heads + formalise sub-Heads AI partner pattern as §0.2 Level 3 + audit log of overrides).
    Anchors: IL-OPS-PROJECT-SECTION-0-COMPLIANCE-AUDIT-2026-05-09, bootstrap canon v3 §0.2 Level 3 + §10 Phase F5.3 + §11 Sprint S8.

- [ ] G-PROJECT-SECTION-0-LEVEL-2-NO-DUPLICATE-VIOLATION (P1, OPEN, 2026-05-09)
    Bootstrap canon v3 §0.2 Level 2 requires тимлиды / supervisors / department leads = 100% AI без human duplicate.
    Existing pattern: ALL Level-2-candidate AI agents (ComplianceOfficerAgent, EscalationAgent, ComplaintTriageAgent, CampaignAgent, ContentAgent, AML-Analyst-v1, KYC-Specialist-v2, LedgerAgent, ReconciliationAgent) HAVE human doubles per JOB-DESCRIPTIONS Agent Summary Registry.
    Fundamental governance choice required (operator-only):
      Option A: reformulate §0.2 Level 2 to allow human doubles (preserves existing FCA-aligned framework, weakens §0.2 immutability claim);
      Option B: reform existing framework to remove human doubles for Level 2 agents (preserves §0.2 immutability, requires JOB-DESCRIPTIONS + DEPARTMENT-MAP rewrite + FCA review);
      Hybrid: Level 2 flexible (duplicate optional).
    Closing IL: TBD (Phase F5.2 — operator decides Option A/B/Hybrid; canon §0.2 amended OR existing framework rewritten accordingly).
    Anchors: IL-OPS-PROJECT-SECTION-0-COMPLIANCE-AUDIT-2026-05-09, bootstrap canon v3 §0.2 Level 2 + §10 Phase F5.2 + §11 Sprint S7.

- [ ] G-PROJECT-SECTION-0-LEVEL-1-NO-DUPLICATE-VIOLATION (P1, OPEN, 2026-05-09)
    Bootstrap canon v3 §0.2 Level 1 requires front-line operations = 100% AI без human duplicate.
    Existing pattern: ALL Level-1-candidate AI agents HAVE human doubles per JOB-DESCRIPTIONS Agent Summary Registry. Level-1 candidates: NotificationAgent, OnboardingNurtureAgent, AnalyticsAgent, FeedbackAnalyticsAgent, LeadScoringAgent + 22 Finance agents (GL Close, AP/AR, Expense Anomaly, IFRS, Consolidation, Tax Compliance, Beancount Export, Budget, Forecast, Variance Analysis, Scenario, Cash Position, Liquidity Forecast, FX Exposure, Covenant Monitor, FCA Data Extraction, Reg Data Quality, FCA Return Generator, Resolution Pack, Finance BI, Data Pipeline, Data Quality Gate) — all with Financial Controller / Head of FP&A / Head of Reg Reporting / Head of Treasury / Head of Finance Systems doubles.
    Same governance choice as Level 2 (Option A reformulate §0.2, Option B reform framework, Hybrid).
    Closing IL: TBD (Phase F5.1 — operator decides; canon §0.2 amended OR existing framework rewritten).
    Anchors: IL-OPS-PROJECT-SECTION-0-COMPLIANCE-AUDIT-2026-05-09, bootstrap canon v3 §0.2 Level 1 + §10 Phase F5.1 + §11 Sprint S6.

- [ ] G-PROJECT-SERVICES-COUNT-DRIFT-VS-ROADMAP (P3, OPEN, 2026-05-09)
    ROADMAP.md Phase 4 lists 27 implemented services in banxe-emi-stack;
    factual ls -1d /home/mmber/banxe-emi-stack/services/*/ shows 84 service directories.
    Drift: +57 undocumented service directories.
    Audit Sprint S2 2026-05-09 confirmed factual count.
    Required action: per-service classification (legitimate-but-undocumented / scaffold / experimental / orphaned) + ROADMAP.md sync to factual state OR cleanup of orphaned directories.
    Closing IL: TBD (Phase F4.1 — ROADMAP.md service inventory sync sweep).
    Anchors: IL-OPS-PROJECT-SECTION-0-COMPLIANCE-AUDIT-2026-05-09, bootstrap canon v3 §10 Phase F4.1.

- [x] G-SECURITY-EVO1-XMRIG-CRYPTOMINER (P0→P1→P2, **RESOLVED**, 2026-05-09)
    2026-05-09 21:30 CEST status: RESOLVED — observation 24h PASS (all 6 checks clean, containment static 43+h, zero reinfection). Incident formally closed. Containment iptables rules recommended KEEP 30 days as defence-in-depth. See IL-INCIDENT-2026-05-09-STATE-TRANSITION-MONITOR-TO-RESOLVED.

- [ ] G-FACTORY-CLAUDE-SUBAGENT-OPENCLO-MOA-MISSING (P2, OPEN, 2026-05-09)
    Sub-GAP of G-FACTORY-CLAUDE-SUBAGENTS-MISSING (P1, PARTIAL after this IL).
    openclo-moa.md (mixture-of-agents subagent for project layer, per bootstrap canon v3 §5)
    NOT FOUND filesystem-wide on Legion (find -name "openclo-moa*" returned 0 results).
    3 of 4 canonical subagents (controller, inspector-agent, safeguarding-agent) deployed
    to ~/.claude/agents/ in Sprint S3 F2.3 partial; openclo-moa requires authoring per
    operator/design spec.
    Bootstrap canon §5 spec available: "mixture-of-agents для project layer" — high-level only,
    requires operator-supplied design (interaction model, project-layer routing rules,
    Ruflo MANDATORY chain integration, ARL handshake, response aggregation).
    Project-layer mixture-of-agents fallback: direct LiteLLM project-mid/heavy/reason
    routing per §1.bis until openclo-moa authored.
    Closing IL: TBD (openclo-moa authored + deployed in ~/.claude/agents/ + verified).
    Anchors: IL-OPS-SPRINT-S3-F2-3-CLAUDE-SUBAGENTS-PARTIAL-DEPLOYMENT-2026-05-09,
    bootstrap canon v3 §5 + §10 Phase F2.3, parent G-FACTORY-CLAUDE-SUBAGENTS-MISSING.
