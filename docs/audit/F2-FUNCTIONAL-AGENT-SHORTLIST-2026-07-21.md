# F2 Functional Agent Shortlist (filtered from raw grep) — 2026-07-21

**FLOOR-2 / FUNCTIONAL SHORTLIST (ACTION-3, step 1) / DOCS-ONLY / READ-ONLY RUNTIME**
Filters non-`*_agent.py` grep candidates in F2 zones (identity/ledger/payments/safeguarding) per `../governance/AGENT-CLASSIFICATION-CRITERION-2026-07-21.md`. Carve-out surfaces flagged **gated** per the OPEN-REGULATORY-QUESTIONS addendum + CONSULTANT-RESPONSE brief — not closed here. Read-only over `~/banxe-emi-stack`.

## Filter applied
- **Kept:** L2/L3 lineage, OR `HITLProposal`, OR affects a regulated outcome (payment/ledger/safeguarding/identity).
- **Dropped:** tests, `__init__`, pure data models, duplicates, and provider adapters with no independent decision (noted as tooling, not row-listed individually).
- **Carve-out (gated-counsel):** crypto/CASP (MiCA), open-banking AISP/PISP, KYB↔merchant-acquiring, Midaz/MCP→ledger — flagged, not auto-classified as ordinary decision.

## Shortlist (non-`*_agent.py` functional entities)

| path | signal | decision\|tooling\|gated | proposed-room |
|---|---|---|---|
| `services/ledger/gl_service.py` | `HITLProposal` + `post_journal_entry` (GL posting) | decision | F2-ledger |
| `services/ledger/payment_posting_service.py` | `HITLProposal` + payment→posting | decision | F2-ledger |
| `services/ledger/posting_rules.py` | posting rule engine | decision | F2-ledger |
| `services/ledger/approval_models.py` | approval/HITL data models | tooling | F2-ledger |
| `services/ledger/midaz_adapter.py` | Midaz write path (MASK) | decision `[gated-counsel]` — Midaz/MCP→ledger | F2-ledger |
| `services/midaz_mcp/midaz_client.py` | MCP client to ledger | decision `[gated-counsel]` — Midaz/MCP→ledger | F2-ledger |
| `services/ledger/crypto_application_service.py` | crypto ledger service | decision `[gated-counsel]` — crypto/CASP | F2-ledger |
| `services/ledger/crypto_ledger_port.py` | crypto ledger port | tooling `[gated-counsel]` — crypto/CASP | F2-ledger |
| `services/payment/payment_service.py` | core payment processing (regulated outcome) | decision | F2-payments |
| `services/payment/payment_processing_service.py` | `HITLProposal` + processing | decision | F2-payments |
| `services/payment/payment_auth_guard.py` | `HITLProposal` + payment auth gating | decision | F2-payments |
| `services/merchant_acquiring/settlement_engine.py` | acquiring settlement | decision `[gated-counsel]` — KYB↔acquiring | F2-payments |
| `services/merchant_acquiring/payment_gateway.py` | acquiring gateway | decision `[gated-counsel]` — KYB↔acquiring | F2-payments |
| `services/merchant_acquiring/chargeback_handler.py` | chargeback handling | decision `[gated-counsel]` — KYB↔acquiring | F2-payments |
| `services/merchant_acquiring/merchant_onboarding.py` | merchant onboarding (KYB coupling) | decision `[gated-counsel]` — KYB↔acquiring | F2-payments |
| `services/crypto_custody/transfer_engine.py` | `HITLProposal` + crypto transfer | decision `[gated-counsel]` — crypto/CASP | F2-payments |
| `services/crypto_custody/travel_rule_engine.py` | Travel Rule engine | decision `[gated-counsel]` — crypto/Travel Rule | F2-payments |
| `services/crypto_custody/wallet_manager.py` | crypto wallet management | decision `[gated-counsel]` — crypto/custody | F2-payments |
| `services/crypto_custody/custody_reconciler.py` | crypto custody recon | tooling `[gated-counsel]` — crypto/custody | F2-payments |
| `services/recon/recon_engine.py` | reconciliation engine | decision | F2-safeguarding |
| `services/recon/reconciliation_engine.py` | reconciliation engine (v2) | decision | F2-safeguarding |
| `services/recon/breach_notify_port.py` | safeguarding breach notification | decision | F2-safeguarding |

**Count into F2:** 22 non-`*_agent.py` functional entities passed the filter; provider adapters (modulr/paybis/legacy) counted as tooling and not row-listed. 12 of the 22 carry a `[gated-counsel]` carve-out flag.

---
**This does not replace legal advice.**
