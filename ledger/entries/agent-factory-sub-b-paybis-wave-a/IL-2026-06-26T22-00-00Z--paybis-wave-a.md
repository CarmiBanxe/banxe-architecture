---
il_ts: 2026-06-26T22:00:00Z
session_id: agent-factory-sub-b-paybis-wave-a
source: CEO
status: DONE
---
### PAYBIS Wave A runtime — PaybisCryptoAdapter behind FROZEN CryptoLedgerPort (mock-first, fenced)

- **Objective:** Implement the smallest safe PAYBIS-first runtime slice enabling on/off-ramp through PAYBIS under existing constraints, invariants preserved, money/PII fenced. Per PLAN Wave A (E1 + structural E3/E6/E8 elements).
- **Live audit:** banxe-emi-stack origin/main@17647be; Wave-A code on isolated branch agent/factory/paybis/wave-a-adapter (worktree .wt-paybis-wavea), commit 2edf49d, SSH-signed. banxe-architecture origin/main; this IL shard on the PAYBIS dossier branch agent/factory/paybis/neuronext-retirement-adr. Provisional IL = max+1 frozen-at-merge (Rule 8; MAIN regenerates).
- **Runtime added (4 additive files; ADR-102 clean — no pre-existing paybis file, no existing file edited; FROZEN CryptoLedgerPort UNCHANGED):**
  - services/ledger/production/paybis_crypto_adapter.py — PaybisCryptoAdapter(CryptoLedgerPort) PAYBIS-only (no dual-provider); injectable PaybisTransportPort; default FencedLivePaybisTransport (raises PaybisLiveFencedError — no live HTTP/secrets/funds); PaybisConfig/PaybisEnv (config-as-data, no secret values); map_order_status (pending→PENDING/completed→CONFIRMED/cancelled|rejected|expired|refunded→FAILED). Capabilities: health, get_fee_estimate, create_tx (initiate order→PENDING). get_balance/create_wallet_address raise OUT_OF_PAYBIS_SCOPE (non-custodial, ADR-108).
  - services/ledger/production/paybis_webhook.py — PaybisWebhookEvent + parse_event (structural latin fields → CryptoTransactionStatus) + idempotency key (partnerOrderId⊳transactionId); verify_signature FENCED (algorithm НЕИЗВЕСТНО).
  - tests/test_paybis_crypto_adapter.py — 8 mock-first tests; PAYBIS-WAVE-A.md doc note (does/does-NOT).
- **Quality:** 8 tests pass, **100% module coverage** (adapter+webhook); ruff+format clean; semgrep banxe-rules+p/default exit 0; gitleaks-style scan — **no secrets**.
- **Invariants/constraints honored:** I-01 Decimal-only (float→I01_DECIMAL); I-24 FROZEN immutable results; I-27 — no funds/PII movement (live fenced); I-28 — this IL append-only; no main-worktree write; sub-B does NOT push/PR/merge; coverage canonical; FROZEN port not changed (new adapter).
- **НЕИЗВЕСТНО (not invented):** literal endpoints/auth/signature/schemas/webhook-payload/rate-limit/SLA/data-residency/fee% — fenced; Wave B unblocks on SRC-06 (API spec) + ADR-114 go-live gate (Wave C: travel_rule_engine + MLRO + SRC-07/08).
- **OPERATOR-GATE:** live PAYBIS transport + Travel-Rule go-live remain GATED (SRC-06/07/08 + ADR-114). No operator question raised — best-decision within fence.
- **Perimeter / canon:** PAYBIS-only; no NeuroNext; isolated worktrees; signed; hand to MAIN per §71/§74 (MAIN pushes/PRs both emi code branch + this arch IL).
- **Deliverable:** banxe-emi-stack branch agent/factory/paybis/wave-a-adapter (2edf49d) + this IL shard.
- **Refs:** ADR-108/114/126; PLAN (IL-551); SRC-01/04/05-06 (IL-547/549/550); services/ledger/crypto_ledger_port.py (FROZEN); travel_rule_engine; ADR-102/119; I-01/I-24/I-27/I-28/I-SEC.
