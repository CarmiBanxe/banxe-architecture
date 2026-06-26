---
il_ts: 2026-06-26T21:00:00Z
session_id: agent-factory-sub-b-paybis-plan-roadmap
source: CEO
status: DONE
---
### PAYBIS implementation plan / roadmap / sprints (NeuroNext→PAYBIS) — docs-plane

- **Objective:** Produce the implementation plan, roadmap (waves), and sprints for replacing NeuroNext with PAYBIS, grounded in the ingested dossier (SRC-01/04 FACT contractual; SRC-05/06/07 PARTIAL structural; code-verified FROZEN CryptoLedgerPort + MidazCryptoAdapter; CryptoCompliancePort does NOT exist → travel_rule_engine + ADR-114; ADR-108/114/126; 0 NeuroNext/0 Bitrix). Docs-plane only; no invented literal API facts; FROZEN port respected (new adapter, not port change).
- **Live audit:** banxe-architecture origin/main@9ef6c49; branch agent/factory/paybis/neuronext-retirement-adr (IL-545..550). Provisional IL = max+1 frozen-at-merge (Rule 8; MAIN regenerates).
- **Plan content:** 11 epics (E1 adapter scaffold READY … E11 MLRO/CASP GATED) with dependency graph + gate-status (READY/GATED-on-SRCxx); 3 waves (A READY-now mock/fenced ≥90%; B GATED-on-SRC-06 API spec; C GATED-on-SRC-07+ADR-114+SRC-08); Wave-A sprints detailed (A-S1..A-S5: adapter scaffold, NeuroNext CI guard, ADR-102 consolidation audit, settlement domain logic, env-switch+mock-DI) with ≥90% cov + dup-audit + hand-to-MAIN cadence; Wave-B/C gated outlines; explicit operator/Paybis dependency gate-list; return-to-base.
- **Guardrails recorded:** I-27 HITL (KYC/KYB/AML), I-01 Decimal-only, ADR-102 dup-audit, I-SEC secrets, FROZEN CryptoLedgerPort untouched, no live PAYBIS call until ADR-114 go-live gate; microservice-consolidation only via ADR-102 (preserve microservice arch).
- **НЕИЗВЕСТНО honored:** literal endpoints/auth/signature/schemas/webhook-payload/SLA/data-residency/fee% kept as external dependencies (SRC-06/07/08) — not invented.
- **Perimeter / canon:** docs-plane only; no runtime/code/secrets; no cross-repo write; isolated worktree off arch origin/main; signed; sub-B hands to MAIN per §71/§74; return-to-base = primary track (Phase-3.6 stub→L2, IL-538) after PAYBIS track.
- **Deliverable:** docs/paybis-dossier/PLAN-ROADMAP-SPRINTS-NEURONEXT-TO-PAYBIS.md + this IL shard.
- **Refs:** SRC-01/04/05-06 (IL-547/549/550), REGISTER (IL-548), DOSSIER (IL-546), ADR-126 (IL-545); ADR-108/114; services/ledger/crypto_ledger_port.py; travel_rule_engine; EMI-impl-state IL-538; ADR-102/119; I-01/I-27/I-SEC.
