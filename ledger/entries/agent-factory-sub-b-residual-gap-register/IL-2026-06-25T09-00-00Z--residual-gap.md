---
il_ts: 2026-06-25T09:00:00Z
session_id: agent-factory-sub-b-residual-gap-register
source: CEO
status: DONE
---
### Residual genuine-gap register — DECISION stage, BANXE.RAR → EMI (docs-only, no port)

- **Objective:** Produce the definitive residual genuine-gap register: after ADR-102 dup-audit against the CURRENT EMI codebase, which legacy microservices/domains are NOT ported AND NOT covered/blocker/rescope. DECISION stage of the migration state machine — not a port; no scaffold, no secrets.
- **Live audit (source of truth, not memory):** banxe-architecture audited@a5e2ddc, rebased-to-merge@9d557b8 (IL max=515; #761 IL-514 f-fatca + #762 IL-515 skills-audit merged after audit) — the prompt's base f605573/next-513 and sub-B provisional IL-514 were both STALE; corrected by live-verify + merge-time freeze, so this shard = **max+1 = IL-516** (Rule 8: frozen at merge-time; main rebases+regenerates before merge). banxe-emi-stack origin/main@35033ac, services/* = 110+ service dirs (read-only git ls-tree).
- **Method:** each legacy top-level module (inventory M0) + each cross-cutting domain (domain-map M0) dup-audited vs banxe-emi-stack:services/* + banxe-architecture; service-name/domain-entity match + content-depth (ls-tree file/.py counts) to separate real target from empty placeholder. Verdicts COVERED / BLOCKER / RESCOPE / GENUINE-GAP / SERVER-AUDIT-REQUIRED.
- **Result (DECISION):** residual LEGACY-DERIVED genuine-gap = **0 confirmed**. Every legacy module/domain → COVERED (existing content-verified EMI service), RESCOPE/DROP (out of EMI-license scope or rebuild-not-port), or SERVER-AUDIT-REQUIRED. Confirms prior docs/migration genuine-gap=0 against the current richer codebase.
  - COVERED: crypto-api→crypto_custody; banxe-digital/dcard→card_issuing; Payments→payment/batch_payments/banxe-payment-core (IL-378/380); Wallets→ledger/midaz_mcp (IL-374); KYC/AML→kyc/kyb_onboarding/aml/sanctions_screening (IL-391, I-27 gated); Risk/DSE→risk/quant_advisory (DSE SBOX-1..6); money→Decimal/I-01.
  - ROADMAP 0% legacy-derived rows all COVERED at service level: C-swift→swift_correspondent(8py), E-treasury→treasury(11py), F-fatca→fatca_crs(6py)+PR#761, H-crm→crm+customer+case_management, H-support→support(7py), M-gateway→api_gateway(8py). Depth-build, not new ports.
  - NET-NEW genuine-gaps (NOT BANXE.RAR-derived → ROADMAP forward-plan, not migration): M-sdk (no legacy SDK), M-sandbox, L-bi presentation.
  - RESCOPE/DROP: crypto-processing (WordPress shop) DROP; banxe_site (PHP front) rewrite→M2.8 roster-gated; consul-configs/binarity-team infra-replace; Trading-core (no EMI crypto order-matching engine) out-of-scope.
  - SERVER-AUDIT-REQUIRED (ADR-103 server-side, never into repo): neuron (6654, domain unclear), internal_dev (2087, tooling), ilink (37 SQL), Trading-core scope confirmation.
- **Next step (best-solution):** remaining migration value = depth/quality of covered services + two operator gates (M2.8 frontend roster; KYC/KYB I-27 HITL-L4), NOT new ports. Recommend an ADR-103 server-side audit of the 4 SERVER-AUDIT-REQUIRED modules to finalise each as DROP/RESCOPE. No port unblocked by this register.
- **ADR-102 self-dup:** no prior residual register on main (verified absent) → non-duplicative; aggregator referencing MIG-INDEX (IL-436) + M0 docs, overwrites nothing.
- **Perimeter / canon:** docs/migration plane only; no secrets in repo (no .RAR unpack; legacy depth left on factory server /home/mmber/banxe-legacy-unpack, ADR-103); no port/scaffold/code; isolated worktree off origin/main@a5e2ddc; signed commit; sub-B does NOT push/PR/merge — hands to main per §71/§74; --force-with-lease only if needed.
- **Deliverable:** docs/migration/MIG-RESIDUAL-GENUINE-GAP-REGISTER-2026-06-25.md.
- **Refs:** banxe_legacy_inventory.md; banxe_legacy_domain_map.md; banxe_to_emi_mapping.md; MIG-INDEX-final-state-register.md (IL-436); ROADMAP-MATRIX.md; banxe-emi-stack:services/* (35033ac); ADR-102/103/119; I-01/I-27/I-28.
