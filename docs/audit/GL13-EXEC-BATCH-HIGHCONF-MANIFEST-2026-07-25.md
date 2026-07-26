# GL-13-EXEC BATCH — High-Confidence Distribution Manifest — 2026-07-25

**PHASE2 / GL-13-EXEC BATCH / COPY-ONLY / REVERSIBLE / STAGED / NO COMMIT**

Source: `banxe-emi-stack/services/` (canonical). Target: `bank-rooms/<room>/runtime/<domain>/`.
cp-only, basement retained. Per-file gated scan (active midaz/ledger/regdata/mcp/httpx/crypto import → excluded).
Staged `[pending audit-evidence]` — promotion to active = install-audit + HITL.

**Totals:** 94 domains placed · 666 files copied · 33 gated files excluded (per-file).

| domain | files_copied | target_room | gated_excluded | status |
|---|---|---|---|---|
| hitl | 5 | F0-engine-manus-room | 0 | staged |
| case_management | 4 | F1-customer-ops-room | 1 | staged |
| complaints | 7 | F1-customer-ops-room | 1 | staged |
| consumer_duty | 10 | F1-customer-ops-room | 0 | staged |
| customer_lifecycle | 6 | F1-customer-ops-room | 0 | staged |
| dispute_resolution | 8 | F1-customer-ops-room | 0 | staged |
| resolution | 4 | F1-customer-ops-room | 0 | staged |
| agreement | 3 | F1-hr-legal-room | 0 | staged |
| document_management | 8 | F1-hr-legal-room | 0 | staged |
| hr | 2 | F1-hr-legal-room | 0 | staged |
| campaign | 2 | F1-marketing-room | 0 | staged |
| churn | 2 | F1-marketing-room | 0 | staged |
| crm | 1 | F1-marketing-room | 0 | staged |
| lead_scoring | 2 | F1-marketing-room | 0 | staged |
| loyalty | 8 | F1-marketing-room | 0 | staged |
| referral | 8 | F1-marketing-room | 0 | staged |
| voice_support | 8 | F1-support-room | 0 | staged |
| auth | 26 | F2-identity-room | 2 | staged |
| consent_management | 7 | F2-identity-room | 0 | staged |
| iam | 3 | F2-identity-room | 0 | staged |
| kyc | 5 | F2-identity-room | 1 | staged |
| api_versioning | 7 | F2-payments-room | 0 | staged |
| batch_payments | 8 | F2-payments-room | 0 | staged |
| beneficiary_management | 8 | F2-payments-room | 0 | staged |
| card_issuing | 9 | F2-payments-room | 0 | staged |
| client_statements | 8 | F2-payments-room | 0 | staged |
| customer | 3 | F2-payments-room | 0 | staged |
| fee_management | 8 | F2-payments-room | 0 | staged |
| fx_engine | 9 | F2-payments-room | 0 | staged |
| fx_exchange | 8 | F2-payments-room | 0 | staged |
| fx_rates | 3 | F2-payments-room | 1 | staged |
| merchant_acquiring | 8 | F2-payments-room | 0 | staged |
| multi_currency | 8 | F2-payments-room | 0 | staged |
| open_banking | 12 | F2-payments-room | 0 | staged |
| payment | 16 | F2-payments-room | 4 | staged |
| psd2_gateway | 5 | F2-payments-room | 0 | staged |
| scheduled_payments | 8 | F2-payments-room | 0 | staged |
| swift_correspondent | 8 | F2-payments-room | 0 | staged |
| safeguarding | 2 | F2-safeguarding-room | 0 | staged |
| safeguarding-engine | 35 | F2-safeguarding-room | 3 | staged |
| statements | 2 | F2-safeguarding-room | 0 | staged |
| adverse_media | 4 | F3-aml-room | 1 | staged |
| alerting | 4 | F3-aml-room | 1 | staged |
| aml | 4 | F3-aml-room | 1 | staged |
| crypto_aml_graph | 6 | F3-aml-room | 2 | staged |
| fraud | 5 | F3-aml-room | 1 | staged |
| fraud_tracer | 5 | F3-aml-room | 0 | staged |
| kyb_onboarding | 7 | F3-aml-room | 1 | staged |
| sanctions_screening | 8 | F3-aml-room | 0 | staged |
| transaction_monitor | 17 | F3-aml-room | 3 | staged |
| bi | 3 | F3-finbi-room | 0 | staged |
| data_quality | 2 | F3-finbi-room | 0 | staged |
| quant_advisory | 5 | F3-finbi-room | 0 | staged |
| reporting_analytics | 10 | F3-finbi-room | 0 | staged |
| compliance_calendar | 8 | F3-regrep-room | 0 | staged |
| fatca_crs | 6 | F3-regrep-room | 0 | staged |
| reporting | 7 | F3-regrep-room | 0 | staged |
| risk | 2 | F3-risk-room | 0 | staged |
| risk_management | 8 | F3-risk-room | 0 | staged |
| treasury | 11 | F3-treasury-room | 0 | staged |
| agent_routing | 8 | F4-ai-platform-room | 0 | staged |
| agents | 25 | F4-ai-platform-room | 1 | staged |
| design_pipeline | 12 | F4-ai-platform-room | 2 | staged |
| experiment_copilot | 12 | F4-ai-platform-room | 2 | staged |
| intent_layer | 13 | F4-ai-platform-room | 0 | staged |
| ml_pipeline | 2 | F4-ai-platform-room | 0 | staged |
| reasoning_bank | 4 | F4-ai-platform-room | 0 | staged |
| repo_watch | 6 | F4-ai-platform-room | 2 | staged |
| swarm | 9 | F4-ai-platform-room | 0 | staged |
| audit | 3 | F4-audit-cell-room | 0 | staged |
| audit_dashboard | 6 | F4-audit-cell-room | 0 | staged |
| audit_trail | 8 | F4-audit-cell-room | 0 | staged |
| gabriel | 5 | F4-audit-cell-room | 0 | staged |
| watchdog | 12 | F4-audit-cell-room | 2 | staged |
| _legacy_common | 3 | F4-devops-room | 0 | staged |
| abs | 2 | F4-devops-room | 0 | staged |
| api_gateway | 8 | F4-devops-room | 0 | staged |
| backup | 8 | F4-devops-room | 0 | staged |
| ci_governance | 11 | F4-devops-room | 0 | staged |
| config | 3 | F4-devops-room | 0 | staged |
| deploy | 2 | F4-devops-room | 0 | staged |
| events | 2 | F4-devops-room | 0 | staged |
| multi_tenancy | 8 | F4-devops-room | 0 | staged |
| notification_hub | 7 | F4-devops-room | 0 | staged |
| notifications | 6 | F4-devops-room | 0 | staged |
| observability | 5 | F4-devops-room | 0 | staged |
| providers | 2 | F4-devops-room | 0 | staged |
| shared | 4 | F4-devops-room | 0 | staged |
| user_preferences | 8 | F4-devops-room | 0 | staged |
| webhook_orchestrator | 8 | F4-devops-room | 0 | staged |
| webhooks | 9 | F4-devops-room | 1 | staged |
| ato_prevention | 7 | F4-security-room | 0 | staged |
| device_fingerprint | 7 | F4-security-room | 0 | staged |
| secrets | 5 | F4-security-room | 0 | staged |

## Excluded (not in this batch)

**[pending human ratification] (7):** incident_response, insurance, lending, producers, runtime_gate, sandbox, savings

**[counsel]-gated (6):** banking-engine, compliance_kb, crypto_custody, ledger, midaz_mcp, regulatory_reporting — write/ledger/regdata/MCP; placement needs counsel.

**already placed:** recon (GL-13 room-1), support (GL-13 family-2)

**skipped (room-mapping gap) (3):** compliance — room 'compliance-support' has no bank-room dir; compliance_automation — room 'compliance-support' has no bank-room dir; compliance_sync — room 'compliance-support' has no bank-room dir → `[pending room-mapping]`

## [counsel-ref] files (flagged, NOT removed, NOT edited)

Leak-pinpoint of the 13 gated-import matches in copied files: **11 = false-positive** (safe intra-domain
refs — e.g. `reporting_analytics.*` referencing itself; `ledger_port.LedgerInfrastructureError` = an
exception class, not a live ledger call). **3 files** carry a live RegData/FIN060 submission function →
flagged `[counsel-ref]`: they remain in the room as copied read-side artefacts, but **live submission
stays under `[counsel]`** (needs the banxe backend + counsel sign-off; not authorized by placement).
The `.py` files are **not modified** — placement never authorizes live submission regardless.

| file (copied) | gated concern | ruling |
|---|---|---|
| `bank-rooms/F3-regrep-room/runtime/reporting/fin060_generator_v2.py` | FIN060 generation → RegData | `[counsel-ref]` — live submit under [counsel] |
| `bank-rooms/F3-regrep-room/runtime/reporting/reporting_agent.py` | FIN060/RegData reporting agent | `[counsel-ref]` — live submit under [counsel] |
| `bank-rooms/F4-audit-cell-room/runtime/gabriel/regdata_gabriel_adapter.py` | RegData submit adapter | `[counsel-ref]` — live submit under [counsel] |

**Batch verdict:** clean — 11 matches false-positive (safe), 3 flagged `[counsel-ref]`; no live gated
execution enabled by this batch.

## Reversibility
cp-only; basement source intact. Rollback = delete target `runtime/<domain>/` dirs. No mv/rm.

---
**This does not replace legal advice.**