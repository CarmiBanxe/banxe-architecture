---
il_ts: 2026-06-28T19:00:00Z
session_id: agent-factory-rar-trading-reclassification
source: CEO
status: DONE
---
### Residual-register correction — BANXE.RAR trading sources = ADR-083-retired Binance-dealer legacy (docs-plane)

- **Objective:** Resolve the Trading-core SERVER-AUDIT-REQUIRED item using the read-only evo1 server-audit; reclassify BANXE.RAR crypto-trading sources. Docs+ledger only; NO RAR content / no secrets into repo; no code.
- **Server-audit evidence (read-only, evo1 /home/banxe/banxe-rar-extracted 8.6G; file names + match counts only):**
  (a) Legacy trading = Binance-dealer/custodial lineage (crypto-api/crypto-api-exchange, crypto-api-keys-lib/binance, crypto-api-rate, neuron/neuron-transaction-service Binance, neuron/fast-exchange, neuron/client-virtual-abs) → ADR-083 RETIRES this model → RESCOPE/DROP (rebuild-not-port), NOT a port candidate.
  (b) "13-section trading program" (Intent-First AgentFi / Метод Ремизова / DSE / casino-effect / phased roadmap) NOT in RAR (0 hits) → separate design doc, no RAR migration item.
  (c) DeFi stack (dYdX/LI.FI/ExchangePort/MarketDataPort/QuotePort/self-custodial/trading-frontend/backend) 0 hits in RAR → greenfield; gated ADR-083 §7 + dYdX AGPL-3.0.
  (d) 124 .env files → de-secret/refactor server-side on evo1 only; only de-secreted sandbox code reaches a repo.
- **Edits:** Trading-core row → SERVER-AUDIT RESOLVED + new "Server-audit resolution (2026-06-28)" note in docs/migration/MIG-RESIDUAL-GENUINE-GAP-REGISTER-2026-06-25.md; 4→3 SERVER-AUDIT-REQUIRED update; pointer in docs/sessions/SESSION-HANDOFF-STATE-AND-TASKS-2026-06-27.md (§A.4 + line 35). ADR-102: recorded once (residual-register canonical), handoff = pointer; neuron already finalized in MIG-SAR-MODULES-FINALIZATION (not duplicated).
- **Provenance:** banxe-architecture origin/main @ 9da43ac IL max=683; provisional IL = max+1 frozen-at-merge (Rule 8; MAIN regenerates).
- **Perimeter / canon:** docs+ledger only; NO code/runtime; NO RAR content or secret values in repo (names + counts only); BANXE.RAR de-secret stays server-side (evo1) under factory; FROZEN contracts untouched; append-only build_ledger; sub-B/factory → MAIN per §71/§74 (NO merge — operator decides).
- **Refs:** evo1 audit 2026-06-28; ADR-083 (DeFi stack); ADR-103 (server-only); ADR-021 (ExchangePort); ADR-102/119; MIG-SAR-MODULES-FINALIZATION-2026-06-25 (neuron rebuild-not-port); MIG-RESIDUAL-GENUINE-GAP-REGISTER-2026-06-25.
