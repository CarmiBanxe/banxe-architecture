---
il_ts: 2026-06-27T05:00:00Z
session_id: agent-factory-sub-b-paybis-legacy-flow-map
source: CEO
status: DONE
---
### Legacy crypto-flow → PAYBIS mapping + governance-drift flag (docs-plane)

- **Objective:** Record legacy crypto-flow → PAYBIS mapping + invariant impact (I-30/32/33/36) + surface a governance drift (CRYPTO-BLOCK.md not reconciled with ADR-108). Docs-plane; sub-B does NOT edit CRYPTO-BLOCK.md (central doc) — only flags.
- **Live audit (evidence, not memory):** docs/CRYPTO-BLOCK.md verified — 0 refs to ADR-108/paybis/retired/superseded, 46 neuronext refs → drift CONFIRMED (still active-NeuroNext model). Invariants I-30(:372)/I-32(:374)/I-33(:375)/I-36(:378) present with cited descriptions. Legacy flows at :157-161. banxe-architecture origin/main IL max=561; this shard on branch agent/factory/paybis/neuronext-retirement-adr; provisional IL = max+1 frozen-at-merge (Rule 8).
- **Mapping recorded (PAYBIS-LEGACY-FLOW-MAP.md §1):** Buy→PAYBIS on-ramp (fiat→TomPay GBP IBAN/Papaya SEPA EUR, non-custodial); Sell→off-ramp same route; Card top-up→off-ramp→TomPay card GBP; Crypto-to-crypto→PAYBIS-side OR OUT-OF-SCOPE НЕИЗВЕСТНО (SRC-06/agreement); Fiat transfer→UNCHANGED (TomPay FCA, not PAYBIS).
- **Invariant impact (§2):** I-30 UK-resident restriction → re-evaluate under PAYBIS T&C (НЕИЗВЕСТНО, CASP T&C 2026-07-01); I-32 dual-AML → PL-GIIF leg gone, crypto-AML PAYBIS-side (Latvia/MiCA), BANXE keeps MLRO (ADR-114), reporting topology changes; I-33 firewall → TomPay↔PAYBIS (processor/controller, GDPR Art.28, ADR-108); I-36 NeuroNext-as-TomPay-client → NO LONGER APPLIES (settlement Paybis→TomPay GBP IBAN). All require governance re-base (central/legal, not sub-B).
- **Governance drift (§3):** CRYPTO-BLOCK.md = superseded-by-ADR-108 recommendation + re-base I-30/32/33/36 → central/governance action (NOT sub-B). sub-B surfaces, does not edit.
- **Primary-track note (§4):** corrects earlier "stub array closed" — safeguarding-engine (P0 CASS 15) = SPEC-LOCKED-STUB, 40 NotImplementedError, IL-535 STOP (EMI-IMPLEMENTATION-STATE-2026-06-25.md:19/29/64); F-aml REAL+TESTED ~80%.
- **Perimeter / canon:** docs-plane only; CRYPTO-BLOCK.md NOT edited (verified untouched); every fact cites CRYPTO-BLOCK/ADR line; unsettled → НЕИЗВЕСТНО; isolated worktree off arch origin/main; sub-B hands to MAIN per §71/§74.
- **Deliverable:** PAYBIS-LEGACY-FLOW-MAP.md, this IL shard.
- **Refs:** CRYPTO-BLOCK.md:157-161/372-378; ADR-108/114/126; PAYBIS-GOVERNANCE-FACTS.md; EMI-IMPLEMENTATION-STATE-2026-06-25.md:19/29/64; ADR-119/I-28.
