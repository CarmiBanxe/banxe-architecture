# Feature-Installation Audit — Roadmap (2026-06-20)

Ordered, read-only audit tasks (AU-1..AU-7), one per feature-cluster. Each AU produces an L1/L2/L3 verdict per the methodology (FEATURE-INSTALLATION-AUDIT-METHODOLOGY-2026-06-20.md). **No code changes — verification only.**

| AU | Cluster | Features | Code-repos to grep | Deliverable |
|----|---------|----------|--------------------|-------------|
| **AU-1** | Crypto / blockchain | GAP-065, GAP-068 | crypto-ops-monitor (connectors, services), emi-stack | L1/L2/L3 verdict + STUB/scaffold/key-gated check; RPC live vs safe-stub |
| **AU-2** | Acquiring / payments / travel-rule | GAP-071, GAP-072, GAP-074 | banxe-payment-core (adapters, settlement), emi-stack (rails) | verdict + blocked-on-keys inventory (Modulr BT-001, Paymentology) |
| **AU-3** | Compliance / EDD / supply-chain | GAP-064, GAP-067 | emi-stack (adverse_media, compliance_*), tooling (SBOM/SCA) | verdict + adverse-media wiring + license-tier register |
| **AU-4** | Platform / merchant onboarding | GAP-066 | braslina (standalone), emi-stack (KYB GAP-013) | verdict + braslina repo presence + KYB completeness |
| **AU-5** | Advisory / voice | GAP-069, GAP-070 | DSE / quant repos, voice stack | verdict; advisory-seam (no live exec) confirmed |
| **AU-6** | Execution channel | GAP-073 | banxe-architecture + Ruflo factory | verdict (expected LIVE) |
| **AU-7** | Roll-up | all | — | aggregate installation % per feature + cross-repo gap-delta matrix |

## Execution rules
- Each AU is **read-only** (grep/test-run/inspect). No feature code edits.
- For each feature in an AU: record L1 ref, L2 evidence (repo path + test result), L3 status (live / STUB / blocked), gap-delta.
- STUB/scaffold detection: grep for `stub`, `scaffold`, `NotImplemented`, `pass  # TODO`, `mock` in the live path; safe-stub-on-missing-key is L2-done / L3-gated, not L3-live.
- Blocked-on-key (Modulr BT-001, Paymentology, RPC URLs) → L2 done, L3 gated; list the exact key dependency.
- AU-7 aggregates into a single installation-% table and a cross-repo gap-delta matrix.

## Ordering rationale
AU-1/AU-2 first (highest-value, code already exists per first-pass — crypto-ops + payment-core). AU-3/AU-4 next (partial). AU-5 (mostly L1-governance). AU-6 quick (expected LIVE). AU-7 roll-up last.
