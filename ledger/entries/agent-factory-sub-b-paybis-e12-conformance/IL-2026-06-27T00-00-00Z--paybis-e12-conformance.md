---
il_ts: 2026-06-27T00:00:00Z
session_id: agent-factory-sub-b-paybis-e12-conformance
source: CEO
status: DONE
---
### E12 architecture-conformance map — legacy/PAYBIS processes → existing target ports (adapt, not transplant)

- **Objective:** Record E12 conformance-map in PLAN §1A + tick §5A acceptance point 2 (architecture conformance checked); flip E12 READY→DONE. Docs-plane; no new ports/contracts; FROZEN ports unchanged; no invented facts.
- **Live audit (read-only shell, not memory):** banxe-emi-stack origin/main — verified 49 *_port.py; all anchor ports present: crypto_ledger_port (CryptoLedgerPort+CryptoRpcPort FROZEN), ledger_port (LedgerPort), payment_port/payment_gateway_port, kyc_provider_port/kyc_port, crypto_custody/travel_rule_engine (methods requires_travel_rule/screen_jurisdiction/attach_originator_data/get_travel_rule_data/validate_travel_rule_complete) + crypto_custody/models (TravelRuleData), observability/compliance_monitor (ComplianceCheckPort), webhooks/reliability_port, treasury/{fx_exposure,liquidity_forecast,nostro_recon}_port, recon/recon_port. CryptoCompliancePort confirmed NON-existent → compliance via travel_rule_engine + ComplianceCheckPort. banxe-architecture IL max=546; this shard on branch agent/factory/paybis/neuronext-retirement-adr; provisional IL = max+1 frozen-at-merge (Rule 8).
- **Conformance map recorded (8 process→port mappings):** crypto ops→CryptoLedgerPort (FROZEN; non-custodial balance/wallet OUT_OF_PAYBIS_SCOPE); crypto RPC→CryptoRpcPort (FROZEN, legacy parked); Order/Refund+events→CryptoLedgerPort create_tx/status + webhooks/reliability_port; Travel-Rule→TravelRuleEngine+TravelRuleData (E5, NOT new CryptoCompliancePort); compliance verdicts→ComplianceCheckPort; KYC/KYB→KYCProviderPort/KYCWorkflowPort (I-27 HITL; data-sharing НЕИЗВЕСТНО SRC-07); settlement→LedgerPort+treasury/* (SRC-04 FACT, fiat Tompay IBAN ADR-108); webhook idempotency→webhooks/reliability_port.
- **Conformance verdict:** every PAYBIS/legacy process lands on an EXISTING port → 0 new contracts, FROZEN CryptoLedgerPort/CryptoRpcPort unchanged (adapt-not-transplant). Literal API/TR mapping НЕИЗВЕСТНО until SRC-06/07 — not invented.
- **§5A acceptance:** point 2 (architecture conformance checked) ticked ✅; E12 READY→DONE in §1A track-epics + §2 table.
- **Perimeter / canon:** docs-plane only; no runtime/code/secrets; no new ports/contracts; FROZEN ports intact; every mapping traceable to shell-evidence (no invented ports); isolated worktree off arch origin/main; signed; sub-B hands to MAIN per §71/§74.
- **Deliverable:** PLAN §1A E12-result + §5A point-2 tick, this IL shard.
- **Refs:** ADR-108/114/126; PLAN §1A/§5A (IL-553/554/555); Wave-A (IL-552); services/ledger/crypto_ledger_port.py, services/crypto_custody/travel_rule_engine.py, services/observability/compliance_monitor.py, services/kyc/*, services/webhooks/reliability_port.py, services/treasury/*; ADR-102/119/I-28; I-27.
