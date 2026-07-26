# F1 Functional Agent Shortlist (filtered from raw grep) — 2026-07-21

**FLOOR-1 / FUNCTIONAL SHORTLIST (ACTION-3, step 1) / DOCS-ONLY / READ-ONLY RUNTIME**
Filters non-`*_agent.py` grep candidates in F1 zones (support/marketing/customer-ops/hr-legal) per `../governance/AGENT-CLASSIFICATION-CRITERION-2026-07-21.md`. F1 flags are conduct/data (not licensing carve-out): `[cobs4]` (financial promotion), `[gdpr-consent]` (data/consent), SM&CR CEO-gate on SMF-hires. Read-only over `~/banxe-emi-stack`.

## Filter applied
- **Kept:** L2/L3, OR `HITLProposal`, OR affects a regulated/customer outcome (complaints/FOS, financial promotion, savings/insurance product, consent/data).
- **Dropped:** tests, `__init__`, pure utilities/models, duplicates.

## Shortlist (non-`*_agent.py` functional entities)

| path | signal | decision\|tooling | proposed-room |
|---|---|---|---|
| `services/complaints/complaints_engine.py` | complaints handling engine | decision | F1-support |
| `services/complaints/fos_escalation.py` | FOS escalation path | decision | F1-support |
| `services/complaints/complaint_service.py` | complaint service (CRUD/orchestration) | tooling | F1-support |
| `services/customer/customer_service.py` | customer servicing orchestration | decision | F1-customer-ops |
| `services/document_management/retention_engine.py` | doc retention (GDPR) | decision `[gdpr-consent]` | F1-customer-ops |
| `services/document_management/document_store.py` | document storage | tooling `[gdpr-consent]` | F1-customer-ops |
| `services/document_management/version_manager.py` | doc versioning | tooling | F1-customer-ops |
| `services/notifications/notification_service.py` | notification dispatch | tooling `[gdpr-consent]` | F1-customer-ops |
| `services/savings/accrual_engine.py` | interest accrual (financial) | decision | F1-customer-ops |
| `services/savings/maturity_handler.py` | savings maturity handling | decision | F1-customer-ops |
| `services/savings/rate_manager.py` | savings rate management | decision | F1-customer-ops |
| `services/insurance/policy_manager.py` | insurance policy management | decision | F1-customer-ops |
| `services/insurance/claims_processor.py` | insurance claims processing | decision | F1-customer-ops |
| `services/insurance/premium_calculator.py` | insurance premium pricing | decision `[pending human ratification]` — if life/health, Annex III relevance `[counsel]` | F1-customer-ops |

**Count into F1:** 14 non-`*_agent.py` functional entities passed the filter. Note: `insurance/premium_calculator.py` flagged pending because life/health insurance pricing may carry Annex III relevance (per CONFIRMED-1) — `[counsel]`, not decided here.

---
**This does not replace legal advice.**
