---
il_ts: 2026-06-26T20:30:00Z
session_id: agent-factory-sub-b-paybis-src0506-ingest
source: CEO
status: DONE
---
### PAYBIS SRC-05/06 integration map ingested (structural, from operator preview) — docs-plane

- **Objective:** Ingest SRC-05 (IT — ProWallet×Paybis) + SRC-06/07 (GE — Интеграция с Paybis) operator previews as a STRUCTURAL integration map; flip SRC-05/06/07 BLOCKED→PARTIAL in the intake register. Latin identifiers reliable; Cyrillic prose encoding-mangled → no invented literal spec.
- **Live audit:** banxe-architecture origin/main@9ef6c49; branch agent/factory/paybis/neuronext-retirement-adr (IL-545..549). Provisional IL = max+1 frozen-at-merge (Rule 8; MAIN regenerates). Binaries NOT on disk (mark-legion: no PDF) → only structural identifiers ingested.
- **[FACT-from-preview] ingested:** flows BuyCrypto/SellCrypto; ids requestId/partnerOrderId/transactionId; entities Order/Refund/WidgetSettings + signed request; order states pending/completed/cancelled/rejected/expired; events paymentInitiated/paymentCompleted/GetPaymentCreated/Completed/Refunded/cancelled; mechanics signed-request(signature)/widget/webhook-callback; environments sandbox; compliance Travel-Rule + KYB on Paybis side + Privacy Policy banxe.com; contact Alex Guts (Paybis).
- **[INFERENCE] flagged:** PaybisCryptoAdapter implements FROZEN CryptoLedgerPort alongside MidazCryptoAdapter; BuyCrypto/SellCrypto+Order/Refund ↦ create_tx + status/webhook; widget+signedRequest → HMAC-style signing (algo НЕИЗВЕСТНО); TR on Paybis (ADR-114), KYB/compliance Paybis-side (ADR-108 processor split); webhook → verified callback endpoint + idempotency on partnerOrderId/transactionId; sandbox/prod → config-as-data env switch + fenced live transport.
- **НЕИЗВЕСТНО (require clean PDF/Paybis spec — not invented):** exact endpoints/methods, auth scheme, signature algorithm + signed fields, per-flow request/response schemas, webhook event names/payload/signature-verification, retry/timeout/rate-limit/SLA, data residency, exact integration fee %, sandbox/prod base-URLs/credentials. Owners: Paybis / operator.
- **Files:** docs/paybis-dossier/SRC-05-06-paybis-integration-map.md (new); SRC-INTAKE-REGISTER.md (SRC-05/06/07 BLOCKED→PARTIAL).
- **Perimeter / canon:** docs-plane only; no runtime/code/secrets; no cross-repo write; no invented literal spec; isolated worktree off arch origin/main; signed; sub-B hands to MAIN per §71/§74.
- **Refs:** SRC-05/06/07 operator previews; ADR-108/114/126; SRC-01/SRC-04 (IL-547/549); services/ledger/crypto_ledger_port.py; ADR-119/I-28.
