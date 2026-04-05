# GAP-REGISTER.md — Реестр архитектурных пробелов BANXE

**Версия аудита:** v3 (2026-04-05)
**Следующий пересмотр:** 2026-07-01 (до EU AI Act дедлайна 2026-08-02)

Каждый gap отслеживается: приоритет, принцип, описание, статус, sprint.

## P1 — Критические (регуляторный и security риск)

| ID | Пробел | Принцип | Дедлайн | Статус |
|----|--------|---------|---------|--------|
| G-01 | Нет immutable audit trail / Decision Event Log | CQRS+ES, DORA 14(2) | — | PARTIAL |
| G-02 | Нет XAI / ExplanationBundle в BanxeAMLResult | XAI, FCA SS1/23 | — | DONE |
| G-03 | HITL не формализован по EU AI Act Art.14 | EU AI Act Art.14 | 2026-08-02 | DONE |
| G-04 | Нет trust boundaries между агентами (Orchestration Tree) | Multi-agent security | — | DONE |
| G-05 | feedback_loop.py может менять SOUL.md без governance gate | Self-rewriting risk | — | DONE |
| G-16 | Нет формализованных Ports & Adapters для агентов | Hexagonal Architecture | — | DONE |
| G-17 | Нет Event Sourcing для решений агентов | Event Sourcing / CQRS | — | DONE |

**G-05 примечание:** DONE (5130232, 2026-04-05). change_classes.yaml: CLASS_A (auto, AGENTS.md/docs), CLASS_B (DEVELOPER|CTIO|CEO required, SOUL.md/openclaw.json), CLASS_C (MLRO|CEO required, compliance_config.yaml/.rego). GovernanceGate.evaluate() raises GovernanceError for B/C without approver. Append-only governance_log.jsonl. CLI wrapper для protect-soul.sh. feedback_loop.py патчен: --approver/--role/--reason/--strict; без approver soul_patches пропускаются (non-breaking). 44 tests T-01..T-44, suite 247/247.

**G-04 примечание:** DONE (3b84592, 2026-04-05). OrchestrationTree с 6 правилами (B-01..B-06): Level-2→Level-1 BLOCKED (B-01), Level-3→Level-1 BLOCKED (B-02), Level-3→Level-2 BLOCKED (B-03, must use Ports), RED→GREEN BLOCKED (B-04), AMBER→GREEN WARN (B-05), policy_write для Level-2/3 BLOCKED (B-06/I-22). AgentDescriptor frozen dataclass + TrustBoundaryError. Default tree: 1 Level-1, 4 Level-2, 4 Level-3. Интегрирован в banxe_aml_orchestrator Step-1 перед _layer2_assess. 34 tests T-01..T-34, suite 203/203.

**G-03 примечание:** DONE (3b5ad06). emergency_stop.py (dual-store Redis+file) + api.py endpoints + 17 integration tests (T-01..T-17, I-23 verified) + emergency_panel.html (MLRO admin panel, /compliance/admin/emergency) + marble_emergency_workflow.json (n8n webhook→API) + deploy-emergency-stop.sh. Production deploy: bash scripts/deploy-emergency-stop.sh.

**G-16 примечание:** DONE (7b74ebd, 2026-04-05). 4 Port ABCs: PolicyPort (read-only, I-22 enforcement), DecisionPort (async emit_decision), AuditPort (append-only, existing), EmergencyPort (is_stopped/activate/clear). 5 Adapters: ComplianceConfigPolicyAdapter (production, backed by compliance_config.yaml G-07), InMemoryPolicyAdapter (test/dev), BanxeAMLDecisionAdapter (→AuditPort via constructor injection), MockDecisionAdapter (test captures), InMemoryEmergencyAdapter (full lifecycle). 30 tests T-01..T-30, full suite 169/169. Инвариант I-22 реализован как архитектурное ограничение (PolicyPort не имеет write-методов).

**G-17 примечание:** DONE (a8b47cb, 2026-04-05). EventStore (write side): StreamId factory (customer/case/channel/all), AppendResult, append()→AuditPort, load_stream(), replay_into(Projector). CQRS read models: RiskSummaryView (per-customer: counts/avg-score/risk_trend ESCALATING|DE-ESCALATING|STABLE), DailyStatsView (per-date: reject_rate, channels, policy_versions), CustomerRiskView (full MLRO history, high_risk_events). Projector: apply()/apply_batch() with idempotency guard, escalating_customers(), customers_with_sar(), customers_requiring_mlro(), snapshot(). 47 tests T-01..T-47, suite 294/294.

## P2 — Существенные (compliance провал при масштабировании)

| ID | Пробел | Принцип | Статус |
|----|--------|---------|--------|
| G-06 | Нет Bounded Context Map в коде | DDD | OPEN |
| G-07 | Compliance thresholds захардкожены в Python | 12-Factor Factor III | OPEN |
| G-08 | Нет drift detection для policy-файлов | GitOps | OPEN |
| G-09 | Pre-tx gate без Redis hot-path (<80ms p99) | Latency / DIP | DEFERRED |
| G-10 | Нет Zero Standing Privileges для агентов | ZSP / JIT secrets | OPEN |
| G-11 | Партнёрский доступ не разграничен (Zone RED/AMBER) | Trust zones | OPEN |
| G-12 | Нет формального agent passport | KPMG AIGF | PARTIAL |
| G-18 | Нет bounded contexts — плоская структура модулей | DDD Bounded Contexts | OPEN |
| G-19 | Нет controls-as-code (OPA/Rego) — только bash-скрипт | FINOS AIGF v2.0 | OPEN |
| G-20 | 12-Factor: отсутствует release pipeline и structured logging | 12-Factor App | PARTIAL |
| G-21 | Нет зонирования для AI-генерированного кода в Claude Code hooks | Vibe-coding governance | DONE |

**G-12 примечание:** SOUL.md + ADR частично закрывают. Не хватает `agent_id`, `version`, `capabilities[]` как structured metadata.
**G-09 примечание:** DEFERRED — EMI-масштаб BANXE пока не требует. Пересмотреть при transaction volume > 10K/day.

**G-18 примечание:** 5 bounded contexts: Compliance, Decision Engine, Policy, Audit, Operations. Модули (sanctions_check, registry_loader) живут в плоской структуре без явных границ.

**G-19 примечание:** `check-compliance.sh` — зародыш controls-as-code. Нужно масштабировать до OPA/Rego engine. FINOS AIGF v2.0 рекомендует executable controls.

**G-20 примечание:** Structured logging реализован — `compliance/utils/structured_logger.py` (vibe-coding ebc54c9). JSON одна строка на событие, correlation IDs (tx_id + case_id + scenario_id), интегрирован в sanctions_check + banxe_aml_orchestrator. Остаток: immutable release pipeline.

**G-21 примечание:** DONE (819f315, 2026-04-05). 4 хука: policy_guard.py (PreToolUse — BLOCKS CLASS_B/C: SOUL.md/openclaw.json/rego), invariant_check.py (PostToolUse — warns I-22/I-24/I-25), bounded_context_check.py (PostToolUse — warns BC-01..BC-05 import boundaries), load_architecture.py (UserPromptSubmit — arch context on relevant queries). settings.json с абсолютными путями, GOVERNANCE_BYPASS=1 для protect-soul.sh. 30 tests T-01..T-30, suite 324/324.

## P3 — Улучшения зрелости

| ID | Пробел | Принцип | Статус |
|----|--------|---------|--------|
| G-13 | Нет compliance bundle для аудиторов | Compliance-as-Code | OPEN |
| G-14 | Нет OPA/Rego runtime enforcement | FINOS AIGF | OPEN |
| G-15 | Нет multi-agent review pattern в feedback pipeline | Plan>Build>Review | OPEN |
| G-22 | AIGF v2.0 risk catalogue не замаплен на GAP-REGISTER | FINOS alignment | OPEN |

**G-22 примечание:** FINOS AI Governance Framework v2.0 вводит каталог рисков для agentic AI в финансах (46+ рисков). Необходимо замапить на наши gaps и добавить недостающие контроли.

## Спринт-план

### Sprint 0 (архитектурный, 0-1 неделя) — НОВЫЙ

- [x] G-16: Формализовать Port-интерфейсы: PolicyPort, DecisionPort, AuditPort, EmergencyPort — DONE 7b74ebd
- [ ] G-18: Реструктурировать в 5 bounded contexts (Compliance, Decision Engine, Policy, Audit, Operations)
- [x] G-21: Настроить Claude Code hooks (policy-guard, invariant-check, bounded-context-check, load-architecture) — DONE 819f315
- [ ] G-22: Замапить AIGF v2.0 risk catalogue на GAP-REGISTER

См. подробности: `SPRINT-0-PLAN.md`

### Sprint 1 (немедленно, 1-2 недели)

- [x] G-05: `governance/change-classes.yaml` — запрет auto-apply для Class B (SOUL.md/AGENTS.md) — DONE 5130232
- [ ] G-04: Orchestration Tree в AGENTS.md + новые инварианты I-21..I-25 в INVARIANTS.md
- [ ] G-03: Завершить G-03 (тесты + Marble UI + deploy) — `emergency_stop.py` уже есть
- [x] G-17: Базовый event store (append-only) для решений агентов — DONE a8b47cb

### Sprint 2 (2-4 недели)

- [ ] G-02: `ExplanationBundle` dataclass в `risk_contract.py`
- [x] G-01: Decision Event Log — PARTIAL (код b6541ab: AuditPort ABC, PostgresEventLogAdapter, InMemoryAuditAdapter, decision_events.sql; 15 тестов 89/89 pass; миграция на GMKtec pending)
- [x] G-07: `compliance_config.yaml` — DONE (d7a1310: config_loader.py, 18 тестов, 114/114 pass; compliance_validator/explanation_builder/sanctions_check/tx_monitor переведены на config)
- [x] G-19: OPA/Rego для критических инвариантов — DONE (1cbe34d: banxe_compliance.rego + rego_evaluator.py, 25 тестов, 139/139 pass; OPA sidecar → Sprint 3 G-14)
- [x] G-20: Structured logging — DONE (structured_logger.py, ebc54c9). Release pipeline — остаток Sprint 3.

### Sprint 3 (4-8 недель)

- [ ] G-11: Zone RED/AMBER/GREEN в CONTRIBUTING.md + branch protection
- [ ] G-08: Policy checksum verification в CI
- [ ] G-15: Review agent step в feedback_loop.py

### Sprint 4 (8-16 недель)

- [ ] G-09: Redis hot-path pre-tx gate
- [ ] G-10: Vault-based JIT agent credential scoping
- [ ] G-14: OPA sidecar pilot (3 критических правила)
- [ ] G-13: `compliance_snapshot.py`

## Что реализовано лучше стандарта

| Преимущество | Почему это важно |
|-------------|------------------|
| feedback_loop.py + REFUTED corpus | Monzo строил 4+ года. BANXE имеет с фундамента. |
| SOUL.md + AGENTS.md в Git (версионированы) | KPMG называет это «agent passport». Редкость у нео-банков. |
| ADR-007..011 + CI schema gate | FCA supervisory reviews требуют именно такую документацию. |
| Policy provenance chain до ClickHouse | policy_scope в audit_trail — прямое доказательство FCA MLR 2017 |
| scenario_registry.yaml I-1..I-10 | Machine-verifiable invariants — редкость на этом этапе. |
| governance/change-classes.yaml (CLASS_B) | Защита от auto-rewriting SOUL.md — опережает FINOS AIGF рекомендации. |
