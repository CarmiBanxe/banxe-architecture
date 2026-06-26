---
il_ts: 2026-06-26T19:30:00Z
session_id: agent-factory-sub-b-paybis-intake-register
source: CEO
status: DONE
---
### PAYBIS dossier source-intake register — drives roadmap dependency gating (docs-plane)

- **Objective:** One source-intake register tracking every dossier source (status/blocker/ingestion path) so roadmap epics gate on source readiness. Docs-plane only; no invented contractual/API facts.
- **Live audit (source of truth, not memory):** banxe-architecture origin/main@9ef6c49; companion to ADR-126/IL-545 + DOSSIER/IL-546 + SRC-01/IL-547 on branch agent/factory/paybis/neuronext-retirement-adr. Provisional IL = max+1 frozen-at-merge (Rule 8; MAIN regenerates).
- **Confirmed-present sources:** ADR-108, ADR-114, ADR-126, AUDIT-01 (0 NeuroNext/0 Bitrix in emi b23593c), SRC-01 (placeholder; contractual fields НЕИЗВЕСТНО).
- **Missing/BLOCKED sources (per operator):** SRC-04 SP-PR3 agreement full text (owner operator/legal); SRC-05 Paybis distribution/integration guide — approved domains/ICT/use-cases/prior-approval (operator/Paybis); SRC-06 PAYBIS API spec — unblocks CryptoLedgerPort adapter (Paybis); SRC-07 TR data contract/TR-status schema — unblocks CryptoCompliancePort (Paybis/MLRO); SRC-08 MLRO oversight owner + CASP T&C status (operator/compliance). SRC-02/03 unassigned/reserved (НЕИЗВЕСТНО).
- **Audit provenance for BLOCKED:** off-repo mark-legion filesystem audit (operator-reported) found NO physical SP-PR3 file; content grep for approved-domains/prior-written-approval/distribution-agreement/outsourcing-agreement = EMPTY; independently re-confirmed by sub-B exhaustive search (repos/FS/paste-cache=task-prompts/scratchpad/tmp). BLOCKED = audit-based, not memory.
- **Roadmap gating rule recorded:** contractual/approved-env/API/compliance epics GATED until their SRC-xx ingested (SRC-04/05 contractual+env; SRC-06 adapter; SRC-07/08 compliance + ADR-114 go-live gate). NON-blocked: architecture-seam analysis, ADR-102 consolidation-analysis, injectable-mock test-strategy cavas. No live PAYBIS call until ADR-114 go-live gate closed.
- **Perimeter / canon:** docs-plane only; no runtime/code/secrets; no cross-repo write; ADR-102 non-duplicative; no fabricated contractual/API facts; isolated worktree off arch origin/main; signed; sub-B hands to MAIN per §71/§74 (does NOT push/PR/merge).
- **Deliverable:** docs/paybis-dossier/SRC-INTAKE-REGISTER.md + this IL shard.
- **Refs:** ADR-108/114/126; SRC-01 (IL-547); DOSSIER (IL-546); services/ledger/crypto_ledger_port.py; AUDIT-01 (b23593c); ADR-119/I-28; SP-PR3 (НЕ найден — required from operator).
