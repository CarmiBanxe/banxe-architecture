---
il_ts: 2026-06-26T11:00:00Z
session_id: agent-factory-sub-b-emi-impl-state
source: CEO
status: DONE
---
### EMI-stack implementation-state — authoritative decision doc (docs-plane, no runtime)

- **Objective:** Capture the implementation-state truth of banxe-emi-stack + the strategic consequence: the right-terminal quality/L2 track is now a per-service Phase-3.6 RUNTIME feature-build, not tests-only remediation; P0 regulatory surfaces are governance/I-27-gated and need operator prioritization. No runtime implemented here.
- **Live audit (source of truth, not memory):** banxe-emi-stack origin/main@ebfeac6 (audited 2026-06-26); banxe-architecture origin/main@02d3cc3 IL max=535 → this provisional max+1=IL-536 (Rule 8 frozen-at-merge; MAIN regenerates). Method: per-service `git grep NotImplementedError` + def/test_ counts, read-only.
- **Stub-density (verified):** 19 services carry NotImplementedError — safeguarding-engine 40, fx_engine 15, ledger 12, complaints 8, compliance 7, payment 4, kyb_onboarding 4, fraud_tracer 4, backup 4, fatca_crs 3, consumer_duty 3, client_statements 3 (+10 testfuncs), auth 3, reporting 2, observability 2, fraud 2, transaction_monitor 1, psd2_gateway 1, agreement 1.
- **F-aml = REAL+TESTED (STOP-CONDITION honoured, not overstated as stub):** core AML services 0 stubs with real logic — aml (44 defs), sanctions_screening (60), compliance_automation (83), adverse_media (8), crypto_aml_graph (17); **203 AML/compliance test functions** at repo-level tests/. Corroborates ROADMAP "F-aml ~80% DONE". reporting_analytics also REAL+TESTED (0 stubs, 11 tests).
- **Verdict classes:** SPEC-LOCKED-STUB (runtime stubbed: safeguarding-engine [P0 CASS15], fx_engine, ledger, complaints, payment, kyb_onboarding, fraud_tracer, backup, fatca_crs, consumer_duty, reporting, observability, fraud); PARTIAL (auth, compliance, transaction_monitor, client_statements, psd2_gateway, agreement); REAL+TESTED (F-aml surface, reporting_analytics).
- **Consequence (strategic):** (1) migration done (IL-516/522). (2) Right-terminal L2 track = per-service Phase-3.6 RUNTIME build, not tests-only — safeguarding STOP (IL-535) is the canonical proof (test-authoring fixes only hit a NotImplementedError wall). (3) P0 regulatory surfaces (safeguarding-engine CASS15, fatca_crs, consumer_duty, ledger/payment core) = operator-gated runtime features (I-27, CLAUDE.md §11 client-funds/production gate); F-aml = hardening not greenfield. (4) Recommend operator-prioritised, I-27-gated scoped runtime builds with per-build IL, then align authored tests to implemented API.
- **STOP-CONDITION check:** F-aml confirmed genuinely real+tested → recorded REAL, not stub; no counts fabricated; stub-density reported only where NotImplementedError actually present.
- **ADR-102 self-dup:** no prior EMI-IMPLEMENTATION-STATE / impl-state doc on main (verified absent) → non-duplicative; aggregator referencing IL-516/522/535 + ROADMAP, overwrites nothing.
- **Perimeter / canon:** docs-plane only; no runtime built, no service prioritised without operator sign-off; no secrets; isolated worktree off banxe-architecture origin/main@02d3cc3; signed; sub-B hands to MAIN per §71/§74; --force-with-lease only.
- **Deliverable:** docs/migration/EMI-IMPLEMENTATION-STATE-2026-06-25.md.
- **Refs:** IL-516, IL-522, IL-535; banxe-emi-stack services/* (ebfeac6); ADR-102/119; I-27; CLAUDE.md §11.
