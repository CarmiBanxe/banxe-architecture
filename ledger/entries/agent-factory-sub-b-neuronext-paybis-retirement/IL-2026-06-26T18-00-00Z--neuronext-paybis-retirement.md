---
il_ts: 2026-06-26T18:00:00Z
session_id: agent-factory-sub-b-neuronext-paybis-retirement
source: CEO
status: DONE
---
### NeuroNext retired → PAYBIS sole external crypto provider — decision recorded (ADR-126, docs-plane)

- **Objective:** Record the operator's binding decision that PAYBIS fully replaces NeuroNext as the external crypto service provider across the EMI BANXE AI BANK stack; NeuroNext = fully retired provider. Docs-plane governance artifact (no runtime, no cross-repo write).
- **Live audit (source of truth, not memory):** banxe-emi-stack origin/main@b23593c — **0** neuronext refs + **0** bitrix refs in services/**/app/** (grep-confirmed); PAYBIS appears only in arch docs (ADR-108/114), not in code. banxe-architecture origin/main@9ef6c49, ADR max=124, IL max=544 → this provisional max+1=IL-545 (Rule 8 frozen-at-merge; MAIN regenerates). ADR-125 claimed by in-flight PR #790 (DRAFT) → used ADR-126 (MAIN re-numbers at merge if collision).
- **Decision (ADR-126):** PAYBIS = single external crypto processor for exchange/custody/processing/payouts/treasury-crypto flows via CryptoLedgerPort/CryptoCompliancePort seams; no new code path may introduce NeuroNext as active participant; no dual-provider logic; remaining NeuroNext config/adapters/flags = deprecation targets (Bitrix/NeuroNext sunset track — none present today, forward guard); cutover steps + rollback that never reintroduces NeuroNext.
- **Rationale:** NeuroNext Polish licensing no longer relied upon → EU/MiCA/national licensing+compliance risk if routed via NeuroNext. PAYBIS = regulated MiCA CASP (ADR-108) + Travel-Rule responsible (ADR-114), designated white-label crypto provider; BANXE = distribution agent.
- **Removal scope = EMPTY (audit-confirmed):** nothing to strip out — NeuroNext was never ported into the new codebase (residual-gap register IL-516: legacy neuron/crypto-processing classified DROP/RESCOPE). ADR-126 is a forward guard forbidding reintroduction, not a present cleanup.
- **Forward follow-up (separate, operator-authorized banxe-emi-stack runtime task — NOT done here):** implement the PAYBIS adapter behind CryptoLedgerPort (12 crypto stubs: get_balance/create_wallet_address/create_tx/get_fee_estimate/health) — injectable-mock + fenced live PAYBIS API, HITL where funds/PII move, ≥90% coverage via mock, live transport fenced. ADR-126 gates that build to PAYBIS-only.
- **ADR-102 self-dup:** no existing NeuroNext-retirement / PAYBIS-sole-provider ADR (ADR-108 = distribution model, ADR-114 = travel rule; this consolidates them into an explicit provider-replacement decision) → non-duplicative; builds on, does not modify, ADR-108/114/036.
- **Perimeter / canon:** docs/architecture plane only; no runtime/code change; no secrets; no cross-repo write; isolated worktree off arch origin/main@9ef6c49; signed; sub-B hands to MAIN per §71/§74 (does NOT push/PR/merge); governance decision is operator-made (human-in-the-loop satisfied), LLM persists the materials only.
- **Deliverable:** docs/adr/ADR-126-neuronext-retired-paybis-sole-crypto-provider.md (+ this IL shard).
- **Refs:** ADR-108/114/036/111; services/ledger/crypto_ledger_port.py; residual-gap register IL-516; GAP-REGISTER; ADR-119/I-28; MiCA / FATF R.16 / UK MLR 2017.
