---
il_ts: 2026-06-26T18:30:00Z
session_id: agent-factory-sub-b-paybis-dossier
source: CEO
status: DONE
---
### PAYBIS crypto-provider DOSSIER — inputs for plan/roadmap/sprints (docs-plane, no runtime)

- **Objective:** Produce a grounded dossier document-set for later plan/roadmap/sprints of the NeuroNext→PAYBIS replacement, docs-plane only, grounded ONLY in ADR-108, ADR-114, ADR-126, the BANXE↔PAYBIS agreement, and the live-audit fact. FACT/INFERENCE/НЕИЗВЕСТНО tagged; no invented runtime facts.
- **Live audit (source of truth, not memory):** banxe-emi-stack origin/main@b23593c — 0 neuronext / 0 bitrix in services/app. banxe-architecture origin/main@9ef6c49; companion to ADR-126/IL-545 on the same branch (agent/factory/paybis/neuronext-retirement-adr). Provisional IL = max+1 frozen-at-merge (Rule 8; MAIN regenerates).
- **Key constraint honestly recorded:** the BANXE↔PAYBIS agreement (SP-PR3 Distribution/Outsourcing) / Paybis distribution guide is **NOT present in the repository** (ADR-108/114 reference it as operator-provided). Therefore all agreement-specific contractual fields (approved entity detail, domains/URLs/ICT systems, prior-approval, security/incident/audit clauses, sublicensing/white-label scope) are marked **НЕИЗВЕСТНО** — not fabricated. Operator/legal must provide the document before runtime work.
- **Grounded facts captured:** PAYBIS=MiCA CASP (Latvia/Latvijas Banka, EU-passport); BANXE=distribution agent, non-CASP, non-custodial; Paybis=data processor / BANXE=controller (GDPR Art.28); Travel-Rule on Paybis (FATF R.16, GBP1,000), MLRO fallback; seams CryptoLedgerPort + CryptoCompliancePort; settlement via Tompay IBAN; go-live gated on TR-contract + MLRO procedure + CASP T&C (2026-07-01).
- **Dossier sections:** (1) executive framing; (2) source-of-truth FACT/INFERENCE/UNKNOWN; (3) contractual constraints (agreement absent → НЕИЗВЕСТНО); (4) architecture target (PAYBIS sole, seams, no dual-provider, rollback no-reintroduce, consolidation principle); (5) implementation dossier map; (6) roadmap inputs (epics/deps/unknowns/data-needed); (7) return-to-base rule.
- **Perimeter / canon:** docs/architecture plane only; no runtime/code/secrets; no cross-repo write; ADR-102 non-duplicative (no prior PAYBIS dossier); isolated worktree off arch origin/main; signed; sub-B hands to MAIN per §71/§74 (does NOT push/PR/merge).
- **Deliverable:** docs/architecture/DOSSIER-PAYBIS-CRYPTO-PROVIDER-2026-06-26.md (+ this IL shard). Companion to ADR-126 (IL-545) on the same branch.
- **Refs:** ADR-108/114/126/036/111; services/ledger/crypto_ledger_port.py; residual-gap register IL-516; ADR-119/I-28; SP-PR3 (НЕИЗВЕСТНО — not in repo).
