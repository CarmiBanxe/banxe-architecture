# Refactor SPEC #11 — AML high-risk patterns extraction (gambling)

Date: 2026-06-06
Status: SPEC (design baseline; CLASS_TRANSFORM EXTRACT-PATTERNS; NEW-driven C5)
Scope: 2 gambling-acquiring legacy projects -> AML high-risk patterns library (serves C5 KYC/AML)
Source: BANXE.RAR /home/banxe/banxe-rar-extracted/neuron/{neuron-gambling-acquiring,neuron-gambling-backend} on evo1
NEW capability: C5 (KYC/AML) per NEW-PROJECT-PRIORITY-MAP — gambling flows are a rich source of high-risk AML detection patterns
Related: ADR-028 KYC; SPEC #8 KYCProviderPort; RISK_REGISTER R-REG-02/03 (AML/Travel Rule)
Owner: Terminal B (smart refactor)

## Purpose

NEW-driven: C5 (KYC/AML) requires high-risk transaction-pattern detection. Legacy gambling-acquiring code (high AML-risk domain by nature) is mined for its risk-pattern heuristics (velocity, structuring, high-risk merchant categories) into a NEW banxe-aml-patterns library consumed by the compliance plane. The gambling business itself is NOT a NEW capability (BANXE is an EMI, not a gambling operator) — only the AML detection patterns are extracted; the gambling runtime is dropped.

## Legacy inventory + decision

- neuron/neuron-gambling-acquiring: EXTRACT-PATTERNS -> mine velocity/structuring/high-risk-category heuristics; drop acquiring runtime.
- neuron/neuron-gambling-backend: EXTRACT-PATTERNS -> mine transaction-scoring + merchant-risk model; drop gambling backend.

Note on other 18 EXTRACT-PATTERNS projects: 6 finance-UX-flows + 12 UI-patterns are BUILD-FRESH (NEW banxe-ui storybook + banxe-ux-flows + Playwright), referencing legacy as design inspiration only. They are NOT legacy-refactor with zero-mismatch and need no Transform SPEC; tracked as build-fresh-with-reference.

## Refactor strategy (Phases A-F)

- Phase A (done): inventory + decision (this SPEC).
- Phase B (Terminal B): scaffold banxe-aml-patterns library (Python or TS, consumed by compliance plane).
- Phase C (Terminal B): extract heuristics (velocity, structuring/smurfing, high-risk merchant categories, rapid in-out) into pure functions; wire into KYCProviderPort risk-scoring + Travel Rule gate.
- Phase D (Terminal B): backtest patterns against historical legacy gambling data; tune thresholds with MLRO.
- Phase E (Terminal B): integrate into compliance plane; alerts route via NotificationPort (critical severity to MLRO).
- Phase F (Terminal B): tag 2 gambling projects ARCHIVE; record decommission in IL.

## Risk register tie-in

- R-REG-02 (KYC/AML gap): AML patterns strengthen the C5 detection layer; feed KYCProviderPort risk scoring.
- R-REG-03 (Travel Rule): high-risk pattern hits gate crypto outflows.
- R-COMP-FCA-05 (AML model auditability): every pattern hit persisted to guardian_audit_events for MLRO review.

## Acceptance criteria

- banxe-aml-patterns library scaffolded; gambling runtime NOT in NEW dep tree.
- Heuristics extracted as pure testable functions; unit tests per pattern.
- Patterns wired into KYCProviderPort risk scoring + Travel Rule gate.
- MLRO sign-off on thresholds after backtest.
- 2 gambling projects ARCHIVE; decommission in IL.

## References

- ADR-028 KYC re-verification; SPEC #8 kyc-provider-port + CONTRACT
- NEW-PROJECT-PRIORITY-MAP-2026-06-06.md (C5)
- CLASS_TRANSFORM.tsv (2 gambling EXTRACT-PATTERNS rows)
- SPEC #7 crypto-ops-subgroup (Travel Rule consumer)
- RISK_REGISTER-2026-05-22.md (R-REG-02, R-REG-03)
- UNIVERSAL-CANON 1-12 + worktree-isolation

=== END OF AML patterns SPEC #11 (CLASS_TRANSFORM EXTRACT-PATTERNS; NEW-driven C5) ===
