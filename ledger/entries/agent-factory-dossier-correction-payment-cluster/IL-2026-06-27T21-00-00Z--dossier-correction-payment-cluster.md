---
il_ts: 2026-06-27T21:00:00Z
session_id: agent-factory-dossier-correction-payment-cluster
source: CEO
status: DONE
---
### Dossier correction — payment-cluster factual errors in pass-1 rationalization (docs-plane)

- **Objective:** Correct 3 mis-read payment-cluster facts in EMI-LEGACY-RATIONALIZATION-PASS-1, additively (originals struck/kept for audit trail). NO code changed.
- **Shell-audit evidence (EMI origin/main fe27f4d, not memory):**
  - FACT-1: to_minor_units defined TWICE — bifrost_adapter.py:51 AND open_banking/m24_int_bridge.py:31 (duplicate). open_banking/intl_scheduled.py:25 imports from its OWN m24_int_bridge, not bifrost → DUPLICATE, not dependency.
  - FACT-2: bifrost_adapter docstring = MIG-M2.5-BIF / Wave-D / ADR-025 §15-16 / advisory-sandbox scaffold + characterization tests → class PARKED, not LIVE_MIGRATE_NEXT/orphan.
  - FACT-3: bifrost_adapter.py:19 imports AbsPaymentStatus from legacy_abs_payment → direction is bifrost→abs_payment (abs_payment is bifrost's dependency, NOT transitively-live via bifrost).
  - Consequence: to_minor_units action = DE-DUPLICATE both copies into services/shared (ADR-102), NOT extract-and-repoint; bifrost stays (Wave-D scaffold).
- **Edits:** Correction-note section + inline annotations on result-blockquote, bifrost row, abs_payment row, to_minor_units stream row, dedupe-map line, coupled-chains line, recommended-next item 2. Originals preserved (strikethrough).
- **Provenance:** banxe-architecture origin/main @ 76fa404 IL max=617; provisional IL = max+1 frozen-at-merge (Rule 8; MAIN regenerates).
- **Perimeter / canon:** docs-plane only; NO code / no prior IL or merged ADR modified; additive append-only; sub-B/factory → MAIN per §71/§74.
- **Refs:** dossier IL-610/IL-614; ADR-102 (dedup); ADR-025 §15-16 (Wave-D bifrost); ADR-119/I-28.
