# Refactor SPEC #21 — CLASS_TAIL remainder (EDD + settlements + support + AML scoring) closes 270/270

Date: 2026-06-06
Status: SPEC (design baseline; CLASS_TAIL final; NEW-driven; surfaces C28 EDD + C29 settlements + C30 support; CLOSES all 270 legacy projects)
Scope: ~20 remaining TAIL projects -> 4 capability groups + anti-map verdict
Source: BANXE.RAR; CLASS_TAIL.tsv
NEW capability: C28 (EDD) + C29 (settlements) + C30 (support ops) + C5 (AML scoring)
Related: SPEC #8 KYC; SPEC #11 AML; SPEC #4 trading; ADR-027 CASS 15
Owner: Terminal B (smart refactor)

## Purpose

Final SPEC. Closes CLASS_TAIL and completes NEW-driven analysis of all 270 legacy projects. Maps remaining TAIL projects to new capabilities and confirms anti-map for the rest.

## Remaining TAIL groups + decisions

### C28 EDD — 2 EDD-forms projects -> banxe-edd-platform
- FCA Enhanced Due Diligence forms/workflow; integrates with KYCProviderPort (SPEC #8) for high-risk customers.

### C29 settlements — 1 settlements project -> banxe-settlements
- CASS 15 settlement reconciliation; feeds midaz-ledger + banxe-recon; ADR-027 5y audit.

### C30 support ops — 2 support-tools projects -> banxe-support-ops
- Customer support tooling; reads customer-lifecycle (C23) + audit (C15).

### C5 AML scoring — 1 AML-scoring project -> banxe-aml-scoring (Crystal + SumSub)
- Transaction risk scoring; complements SPEC #11 AML patterns; Crystal blockchain analytics + SumSub.

### Already covered / anti-map (~14)
- 2 Neuron auth -> C19 (SPEC #12); 2 partner API -> C3 (SPEC #13); DEX backend -> C6 (SPEC #4); CEX proxy -> ExchangePort (SPEC #4).
- C++ BitShares fork + DEX client + Electron wallet -> archive read-only (anti-map; replaced by NEW trading-ui Tauri 2 per SPEC #4).
- VABS v1 (1) -> SPEC #10; common lib (1) -> crypto-utils (SPEC #2); admin UI (2) -> build-fresh banxe-admin; DROP-LEGACY-WEB (3) -> anti-map.

## Full 270-project NEW-driven closure summary

- KEEP 24 -> SPECs #1-#8.
- TRANSFORM 99 -> SPECs #9-#11 (26 covered, 73 build-fresh/infra/anti-map).
- PORT 22 -> SPECs #12-#14 (surfaced C19/C20/C21).
- MERGE 15 -> SPECs #15-#17 (surfaced C22/C23/C24/C25).
- REVIEW 69 -> SPECs #18-#19 (surfaced C26; ~40 anti-map).
- TAIL 39 -> SPECs #20-#21 (surfaced C27/C28/C29/C30; rest covered/anti-map).

All 270 legacy projects swept NEW-first. 26 -> 18 design SPECs covering capability-serving legacy; ~150 anti-mapped/build-fresh/infra (NOT refactored because no NEW need). 30 NEW capabilities (C1-C30) — 18 original + 12 surfaced by sweeps.

## Acceptance

- C28/C29/C30 added to PRIORITY-MAP; banxe-edd-platform + banxe-settlements + banxe-support-ops + banxe-aml-scoring scaffolded in Phase B.
- All 270 legacy projects have a NEW-driven verdict; CLASS_TAIL 39/39 closed.

## References

- SPEC #8 KYC; SPEC #11 AML; SPEC #4 trading; ADR-027 CASS 15
- NEW-PROJECT-PRIORITY-MAP (to amend C28/C29/C30); CLASS_TAIL.tsv (39 rows)
- UNIVERSAL-CANON 1-12 + worktree-isolation

=== END OF CLASS_TAIL remainder SPEC #21 (270/270 legacy projects NEW-driven swept; C1-C30 capabilities) ===
