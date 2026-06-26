---
il_ts: 2026-06-27T04:00:00Z
session_id: agent-factory-sub-b-paybis-governance-facts
source: CEO
status: DONE
---
### PAYBIS governance-facts cross-check + honest CryptoCompliancePort correction (docs-plane)

- **Objective:** Record governance facts (ADR-108/114/GAP-REGISTER) into a cross-referenced fact table + one honest correction (CryptoCompliancePort code-vs-governance); update PLAN go-live-gate + settlement route. Docs-plane; no runtime.
- **Live audit (evidence, not memory):** CryptoCompliancePort = 0 occurrences in EMI services/api (verified grep) BUT named in governance docs/adr/ADR-114-travel-rule-paybis-casp.md + README + SESSION-2026-05-10 → both truths confirmed. ADR-108 (docs/adr/ADR-108-payment-distribution-model.md) + ADR-114 exist; services/crypto_custody/travel_rule_engine.py present (Wave C anchor). banxe-architecture origin/main IL max=559; this shard on branch agent/factory/paybis/neuronext-retirement-adr; provisional IL = max+1 frozen-at-merge (Rule 8).
- **Facts recorded (PAYBIS-GOVERNANCE-FACTS.md, 13 rows, each ADR/GAP-line-cited):** G1 CryptoCompliancePort = TR seam receive-not-originate, design-frozen (ADR-114:8/13); G2 not-in-runtime (grep=0); G3 TomPay GBP IBAN + G4 Papaya SEPA EUR (ADR-108:14); G5 GAP-071 + G6 GAP-072 = 🟡 IN PROGRESS (GAP-REGISTER:61-62); G7 go-live gate = TR contract + MLRO both (ADR-114:14/22, ADR-108:18); G8 TR contract in SP-PR3; G9 CASP T&C 2026-07-01; G10 Neuronext VASP retired; G11 BANXE distribution-agent NOT CASP; G12 non-custodial; G13 Paybis = MiCA CASP (Latvia).
- **Honest correction (corrections log):** prior sub-B «CryptoCompliancePort does not exist» true ONLY for runtime code (G2); in governance it IS canonical design-frozen seam (G1) — record BOTH: canonical-in-ADR-114 / not-yet-coded. Fixed stale «НЕ существует» in PLAN (source-of-truth line + conformance-map rows) and DOSSIER references.
- **PLAN updates:** GO-LIVE GATE section (concrete: TR contract + MLRO + CASP T&C 2026-07-01; GAP-071/072 IN PROGRESS); SETTLEMENT route (TomPay GBP IBAN / Papaya SEPA EUR, ADR-108:14); conformance-map TR row now cites CryptoCompliancePort (Wave C) alongside travel_rule_engine.
- **Wave C note:** must implement CryptoCompliancePort (canonical seam) + travel_rule_engine integration, gated on ADR-114 go-live + SRC-07.
- **Perimeter / canon:** docs-plane only; every fact cites ADR/GAP source; no invented literals; FROZEN ports untouched; isolated worktree off arch origin/main; sub-B hands to MAIN per §71/§74.
- **Deliverable:** PAYBIS-GOVERNANCE-FACTS.md + PLAN go-live-gate/settlement/source-of-truth updates, this IL shard.
- **Refs:** ADR-108:5/8/13/14/15/18, ADR-114:8/13/14/22, GAP-REGISTER:61-62, SESSION-2026-05-10; PLAN, PAYBIS-SANDBOX-STATE, DOSSIER; travel_rule_engine.py; ADR-119/I-28.
