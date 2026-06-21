# ORG-CODE Reconciliation v2 — Passport Coverage (2026-06-21)

> Read-only governance reconciliation (SP-PASSPORT-COV). Supersedes the coverage view in
> `ORG-CODE-RECONCILIATION-2026-06-11.md`. NO feature code changed.
> Source of truth: banxe-emi-stack `services/` (106) ↔ banxe-architecture `agents/passports/` (34 → 47).

## Summary

| Metric | Value |
|--------|-------|
| Runtime services (banxe-emi-stack) | 106 |
| Infrastructure / non-agent (OUT-OF-SCOPE by design) | 15 |
| **Domain services** | **91** |
| Directly mapped (existing agent / CTX) — incl. 3 now-explicit | 78 |
| Orphan → new PROPOSED passport (this PR) | 13 |
| Passports total (34 + 13) | 47 |
| **Domain coverage (owner assigned)** | **91/91 = 100%** |
| **Total accounting (owned + out-of-scope)** | **91 owned + 15 out-of-scope = 106/106 = 100%** |

All 13 new passports are **status: PROPOSED, autonomy: L2_REVIEW** — NOT activated (I-27).

## Matrix C — remaining gaps

True-orphan domain services with NO owner: **0**. Every domain service has an agent/alias;
every infra service is explicitly OUT-OF-SCOPE (Matrix D). No service is unaccounted.
Residual: 13 PROPOSED passports await operator activation; `experiment_copilot` capabilities marked TODO (sparse code).

## Matrix B — new passports → bounded_context → SM&CR owner

| Service | Passport | trust_zone | bounded_context | SM&CR owner |
|---------|----------|-----------|-----------------|-------------|
| case_management | case_management_agent | RED | CTX-01 | MLRO (SMF17) |
| document_management | document_management_agent | AMBER | CTX-06 | COO (SMF24) |
| user_preferences | user_preferences_agent | GREEN | CTX-06 | COO (SMF24) |
| alerting | alerting_agent | AMBER | CTX-06 | COO (SMF24) |
| hr | hr_agent | GREEN | CTX-08 | HR/Legal |
| midaz_mcp | midaz_mcp_agent | AMBER | CTX-03 | CTO (SMF26) |
| webhook_orchestrator | webhook_orchestrator_agent | AMBER | CTX-03 | CTO (SMF26) |
| webhooks | webhooks_agent | AMBER | CTX-03 | CTO (SMF26) |
| ml_pipeline | ml_pipeline_agent | AMBER | CTX-03 | CTO (SMF26) |
| experiment_copilot | experiment_copilot_agent | AMBER | CTX-03 | CTO (SMF26) |
| reasoning_bank | reasoning_bank_agent | AMBER | CTX-03 | CTO (SMF26) |
| design_pipeline | design_pipeline_agent | AMBER | CTX-09 | CTO (SMF26) |
| multi_tenancy | multi_tenancy_agent | AMBER | CTX-09 | CTO (SMF26) |

### Explicitly mapped (previously indirect — now named)

| Service | Owning agent | bounded_context |
|---------|--------------|-----------------|
| payment | payment_router_agent | CTX-04 |
| reporting | reporting_agent | CTX-10 |
| fx_exchange | treasury_alm_agent / fx-exposure | CTX-10 |

## Matrix D — Infrastructure / non-agent services (OUT-OF-SCOPE by design)

| Service | Status | Reason | Owner |
|---------|--------|--------|-------|
| __pycache__ | OUT-OF-SCOPE | Python bytecode cache | CTO platform (infra custody, no agent) |
| _legacy_common | OUT-OF-SCOPE | deprecated shared module (legacy) | CTO platform (infra custody, no agent) |
| config | OUT-OF-SCOPE | configuration module (no business logic) | CTO platform (infra custody, no agent) |
| secrets | OUT-OF-SCOPE | secret loading (no agent logic) | CTO platform (infra custody, no agent) |
| shared | OUT-OF-SCOPE | shared utilities | CTO platform (infra custody, no agent) |
| deploy | OUT-OF-SCOPE | deployment scaffolding | CTO platform (infra custody, no agent) |
| producers | OUT-OF-SCOPE | event-producer scaffolding | CTO platform (infra custody, no agent) |
| providers | OUT-OF-SCOPE | DI provider scaffolding | CTO platform (infra custody, no agent) |
| events | OUT-OF-SCOPE | event definitions / transport | CTO platform (infra custody, no agent) |
| swarm | OUT-OF-SCOPE | swarm orchestration scaffolding | CTO platform (infra custody, no agent) |
| agents | OUT-OF-SCOPE | agent registry scaffolding | CTO platform (infra custody, no agent) |
| backup | OUT-OF-SCOPE | backup scripts | CTO platform (infra custody, no agent) |
| data_quality | OUT-OF-SCOPE | data-quality checks (infra) | CTO platform (infra custody, no agent) |
| repo_watch | OUT-OF-SCOPE | repo watcher (infra) | CTO platform (infra custody, no agent) |
| ci_governance | OUT-OF-SCOPE | CI governance scaffolding | CTO platform (infra custody, no agent) |

## Matrix A — service → status (106 rows)

| Service | Status | Owner / note |
|---------|--------|--------------|
| __pycache__ | OUT-OF-SCOPE | infra — Python bytecode cache; owner CTO platform (no agent) |
| _legacy_common | OUT-OF-SCOPE | infra — deprecated shared module (legacy); owner CTO platform (no agent) |
| adverse_media | MAPPED | existing agent / bounded-context |
| agent_routing | MAPPED | existing agent / bounded-context |
| agents | OUT-OF-SCOPE | infra — agent registry scaffolding; owner CTO platform (no agent) |
| agreement | MAPPED | existing agent / bounded-context |
| alerting | orphan→PROPOSED | COO (SMF24) — new passport alerting_agent.yaml |
| aml | MAPPED | existing agent / bounded-context |
| api_gateway | MAPPED | existing agent / bounded-context |
| api_versioning | MAPPED | existing agent / bounded-context |
| ato_prevention | MAPPED | existing agent / bounded-context |
| audit | MAPPED | existing agent / bounded-context |
| audit_dashboard | MAPPED | existing agent / bounded-context |
| audit_trail | MAPPED | existing agent / bounded-context |
| auth | MAPPED | existing agent / bounded-context |
| backup | OUT-OF-SCOPE | infra — backup scripts; owner CTO platform (no agent) |
| batch_payments | MAPPED | existing agent / bounded-context |
| beneficiary_management | MAPPED | existing agent / bounded-context |
| campaign | MAPPED | existing agent / bounded-context |
| card_issuing | MAPPED | existing agent / bounded-context |
| case_management | orphan→PROPOSED | MLRO (SMF17) — new passport case_management_agent.yaml |
| churn | MAPPED | existing agent / bounded-context |
| ci_governance | OUT-OF-SCOPE | infra — CI governance scaffolding; owner CTO platform (no agent) |
| client_statements | MAPPED | existing agent / bounded-context |
| complaints | MAPPED | existing agent / bounded-context |
| compliance | MAPPED | existing agent / bounded-context |
| compliance_automation | MAPPED | existing agent / bounded-context |
| compliance_calendar | MAPPED | existing agent / bounded-context |
| compliance_kb | MAPPED | existing agent / bounded-context |
| compliance_sync | MAPPED | existing agent / bounded-context |
| config | OUT-OF-SCOPE | infra — configuration module (no business logic); owner CTO platform (no agent) |
| consent_management | MAPPED | existing agent / bounded-context |
| consumer_duty | MAPPED | existing agent / bounded-context |
| crm | MAPPED | existing agent / bounded-context |
| crypto_aml_graph | MAPPED | existing agent / bounded-context |
| crypto_custody | MAPPED | existing agent / bounded-context |
| customer | MAPPED | existing agent / bounded-context |
| customer_lifecycle | MAPPED | existing agent / bounded-context |
| data_quality | OUT-OF-SCOPE | infra — data-quality checks (infra); owner CTO platform (no agent) |
| deploy | OUT-OF-SCOPE | infra — deployment scaffolding; owner CTO platform (no agent) |
| design_pipeline | orphan→PROPOSED | CTO (SMF26) — new passport design_pipeline_agent.yaml |
| device_fingerprint | MAPPED | existing agent / bounded-context |
| dispute_resolution | MAPPED | existing agent / bounded-context |
| document_management | orphan→PROPOSED | COO (SMF24) — new passport document_management_agent.yaml |
| events | OUT-OF-SCOPE | infra — event definitions / transport; owner CTO platform (no agent) |
| experiment_copilot | orphan→PROPOSED | CTO (SMF26) — new passport experiment_copilot_agent.yaml |
| fatca_crs | MAPPED | existing agent / bounded-context |
| fee_management | MAPPED | existing agent / bounded-context |
| fraud | MAPPED | existing agent / bounded-context |
| fraud_tracer | MAPPED | existing agent / bounded-context |
| fx_engine | MAPPED | existing agent / bounded-context |
| fx_exchange | MAPPED | treasury_alm_agent / fx-exposure (CTX-10) |
| fx_rates | MAPPED | existing agent / bounded-context |
| hitl | MAPPED | existing agent / bounded-context |
| hr | orphan→PROPOSED | HR/Legal — new passport hr_agent.yaml |
| iam | MAPPED | existing agent / bounded-context |
| incident_response | MAPPED | existing agent / bounded-context |
| insurance | MAPPED | existing agent / bounded-context |
| intent_layer | MAPPED | existing agent / bounded-context |
| kyb_onboarding | MAPPED | existing agent / bounded-context |
| kyc | MAPPED | existing agent / bounded-context |
| lead_scoring | MAPPED | existing agent / bounded-context |
| ledger | MAPPED | existing agent / bounded-context |
| lending | MAPPED | existing agent / bounded-context |
| loyalty | MAPPED | existing agent / bounded-context |
| merchant_acquiring | MAPPED | existing agent / bounded-context |
| midaz_mcp | orphan→PROPOSED | CTO (SMF26) — new passport midaz_mcp_agent.yaml |
| ml_pipeline | orphan→PROPOSED | CTO (SMF26) — new passport ml_pipeline_agent.yaml |
| multi_currency | MAPPED | existing agent / bounded-context |
| multi_tenancy | orphan→PROPOSED | CTO (SMF26) — new passport multi_tenancy_agent.yaml |
| notification_hub | MAPPED | existing agent / bounded-context |
| notifications | MAPPED | existing agent / bounded-context |
| observability | MAPPED | existing agent / bounded-context |
| open_banking | MAPPED | existing agent / bounded-context |
| payment | MAPPED | payment_router_agent (CTX-04) |
| producers | OUT-OF-SCOPE | infra — event-producer scaffolding; owner CTO platform (no agent) |
| providers | OUT-OF-SCOPE | infra — DI provider scaffolding; owner CTO platform (no agent) |
| psd2_gateway | MAPPED | existing agent / bounded-context |
| quant_advisory | MAPPED | existing agent / bounded-context |
| reasoning_bank | orphan→PROPOSED | CTO (SMF26) — new passport reasoning_bank_agent.yaml |
| recon | MAPPED | existing agent / bounded-context |
| referral | MAPPED | existing agent / bounded-context |
| regulatory_reporting | MAPPED | existing agent / bounded-context |
| repo_watch | OUT-OF-SCOPE | infra — repo watcher (infra); owner CTO platform (no agent) |
| reporting | MAPPED | reporting_agent (CTX-10) |
| reporting_analytics | MAPPED | existing agent / bounded-context |
| resolution | MAPPED | existing agent / bounded-context |
| risk | MAPPED | existing agent / bounded-context |
| risk_management | MAPPED | existing agent / bounded-context |
| safeguarding | MAPPED | existing agent / bounded-context |
| safeguarding-engine | MAPPED | existing agent / bounded-context |
| sanctions_screening | MAPPED | existing agent / bounded-context |
| savings | MAPPED | existing agent / bounded-context |
| scheduled_payments | MAPPED | existing agent / bounded-context |
| secrets | OUT-OF-SCOPE | infra — secret loading (no agent logic); owner CTO platform (no agent) |
| shared | OUT-OF-SCOPE | infra — shared utilities; owner CTO platform (no agent) |
| statements | MAPPED | existing agent / bounded-context |
| support | MAPPED | existing agent / bounded-context |
| swarm | OUT-OF-SCOPE | infra — swarm orchestration scaffolding; owner CTO platform (no agent) |
| swift_correspondent | MAPPED | existing agent / bounded-context |
| transaction_monitor | MAPPED | existing agent / bounded-context |
| treasury | MAPPED | existing agent / bounded-context |
| user_preferences | orphan→PROPOSED | COO (SMF24) — new passport user_preferences_agent.yaml |
| voice_support | MAPPED | existing agent / bounded-context |
| webhook_orchestrator | orphan→PROPOSED | CTO (SMF26) — new passport webhook_orchestrator_agent.yaml |
| webhooks | orphan→PROPOSED | CTO (SMF26) — new passport webhooks_agent.yaml |
