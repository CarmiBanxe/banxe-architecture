# F4 DevOps / Audit-Cell — Functional Census-Gap Analysis — 2026-07-21

**FLOOR-4 / FUNCTIONAL AGENT CENSUS (ACTION-2) / DOCS-ONLY / READ-ONLY RUNTIME**
Follows ACTION-2 of `../briefs/CONSULTANT-RESPONSE-ORGCHART-CENSUS-2026-07-21.md`. Prepares ACTION-3 (registry). Read-only over `~/banxe-emi-stack`; no runtime change.

## §A Method (functional, not filename-based)

- Census by **purpose**, not by the `*_agent.py` naming convention (consultant: a single `*_agent.py` in F4 likely = census miss).
- Candidate zones scanned (present): `services/observability`, `services/audit_trail`, `services/audit`, `services/audit_dashboard`, `services/watchdog`, `services/deploy`, `services/transaction_monitor`, `infra`, `deploy`, `scripts`, `.github/workflows`.
- Agentic signals: orchestration / scheduling / `HITLProposal` / decision-propose-monitor-deploy-scan-alert behaviour / guarded state-changing actions / best-solution selection — i.e. behaviour like a `*_agent.py` but without the suffix.
- Grep was name/signature-level only (`class`/`def`), no runtime execution, no file modification.

## §B Candidates found

Functional agent-like entities **outside** `*_agent.py` (representative, evidence-backed):

| path | type | signal | proposed-room |
|---|---|---|---|
| `services/watchdog/repair_engine.py` | class | `RepairEngine.evaluate_and_act` — autonomous repair decision + verify | F4-devops |
| `services/watchdog/decision_policy.py` | class | `DefaultActionScorer` / `ActionScorer` — action scoring/decision | F4-devops |
| `services/watchdog/best_solution.py` | class | `BestSolutionScorer.select` — best-decision selection (mirrors agent decisioning) | F4-devops |
| `services/watchdog/guarded_actions.py` | class | `GuardedActionExecutor` — guarded state-changing ops (restart/config_sync/recreate) | F4-devops |
| `services/watchdog/root_cause_classifier.py` | class | `RootCauseClassifier` (+LLM enrich) — classification/decision | F4-devops |
| `services/watchdog/watchdog.py` | class/orchestrator | node-state monitor loop, config-driven | F4-devops |
| `services/deploy/deploy_port.py` | class | `DeployPort.prepare_deployment` / `request_approval` — deploy + approval (HITL-like) | F4-devops |
| `services/observability/compliance_monitor.py` | class | `ComplianceCheckPort` — invariant/compliance monitor | F4-devops (audit-cell cross-link) |
| `scripts/ci-protection-drift-check.py` | script | CI protection drift scan/monitor | F4-devops |
| `scripts/alert-routing-check.py` | script | alert routing check | F4-devops |
| `scripts/deploy-psd2-gateway.sh` · `deploy-recon-stack.sh` · `deploy-safeguarding-gmktec.sh` · `deploy-sprint9.sh` | script | deploy orchestration | F4-devops |
| `.github/workflows/factory-guard.yml` · `guardian.yml` | workflow | CI guard automation | F4-devops |
| `.github/workflows/claude-daily-report.yml` · `claude-issue-triage.yml` · `claude-release-readiness.yml` | workflow | claude-driven agentic automation | F4-devops (ai-platform cross-link) |
| `services/audit_trail/retention_enforcer.py` | class | `HITLProposal` + `RetentionEnforcer.schedule_purge` — retention decision | F4-audit-cell |
| `services/audit/audit_query.py` | class | `HITLProposal` + `AuditQueryService.export_audit_report` | F4-audit-cell |
| `services/audit_dashboard/governance_reporter.py` | class | governance reporting | F4-audit-cell |
| `services/audit_dashboard/risk_scorer.py` | class | risk scoring (decision-like) | F4-audit-cell |
| `services/audit_dashboard/audit_aggregator.py` | class | audit aggregation/monitor | F4-audit-cell |
| `scripts/audit-buffer-drain.py` | script | scheduled audit buffer drain | F4-audit-cell |

## §C Verdict

**Census gap CONFIRMED: YES.** At least **19** agent-like entities were found **outside** the `*_agent.py` naming convention across F4-devops and F4-audit-cell — the largest being the `services/watchdog/*` decision/repair package (multiple decision + guarded-action classes) and the `HITLProposal`-bearing audit modules (`retention_enforcer.py`, `audit_query.py`). A filename-only census would have missed these. This validates the consultant's warning and motivates ACTION-3 (formal registry) and ACTION-1 (decision-vs-tooling criterion).

## §D Open items

- **[factory]** Confirm the counting canon: which of these functional entities count toward the agent census, and how the registry reconciles against files(86)/classes(77).
- **[audit]** Confirm which candidates qualify as an "agent" for the org-chart (decision-affecting, HITL-relevant) versus pure tooling (CI scripts, embedded service functions) — pending the ACTION-1 decision-vs-tooling criterion.
- **[factory]** Decide cross-link handling where a module plausibly serves two rooms (e.g. `compliance_monitor.py` devops↔audit-cell; claude-* workflows devops↔ai-platform).

---
**This does not replace legal advice.**
