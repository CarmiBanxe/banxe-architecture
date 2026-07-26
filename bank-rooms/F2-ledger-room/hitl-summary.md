> ⚠ TRAINING DATA — SANDBOX — NOT FOR PRODUCTION

# F2 / ledger-room — HITL Summary

**Reflects `../../HITL-MATRIX.yaml` (v1.0, IL-065). This file MIRRORS the matrix; it does not modify it.**
Invariant **I-27** (`../../INVARIANTS.md`): AI PROPOSES, human DECIDES. The three authority layers below are kept separate: technical workflow routing ≠ financial decision authority ≠ regulatory/audit escalation.

## Ledger-relevant HITL gates (from HITL-MATRIX.yaml)

| Gate | Name | Trigger | Roles | Auto? | Ledger relevance |
|---|---|---|---|---|---|
| **HITL-010** | FCA RegData Submission | `FCA_REGDATA_SUBMISSION` | CFO | no | FIN060 / RegData: AI generates, **CFO personally submits** (CASS 15.12.4R; PS7/24). No automated submission. |
| **HITL-011** | Safeguarding Shortfall Alert | `SAFEGUARDING_SHORTFALL` | CFO **and** MLRO | no | Safeguarding shortfall touching the e-money liability — dual CFO+MLRO; FCA notified if shortfall confirmed. |
| **HITL-016** | Large Transaction (>£50k) | large-tx | any_of: COO, CFO | no | Large value movement posted to the ledger requires COO or CFO in addition to standard AML checks. |
| **HITL-017** | New Product Launch | new-product | CEO | no | New EMI products (B-EMI) require CEO sign-off + FCA product governance review. |

Room-level financial control (not a matrix gate but room canon): **adjustment > £10k → CFO** sign-off; period-close is human-gated.

## Three authority layers (kept distinct)

- **Technical workflow routing:** posting/derivation flows through `LedgerPort` → `midaz_adapter` (Midaz PRIMARY; Fineract failover swap). This is routing, not decision authority; failover is operator-authorized, not autonomous.
- **Financial decision authority:** CFO (SMF2) owns adjustments >£10k, period-close, and RegData submission; COO (SMF24) co-owns safeguarding; large-tx >£50k needs COO/CFO. AI proposes, the accountable SMF decides (I-27).
- **Regulatory / audit escalation:** safeguarding shortfall → CFO+MLRO (+FCA notification); AML customer blocks and SAR remain in the MLRO carve-out (not ledger-room owned); Internal Audit (SMF5) has read-only assurance over ledger evidence.

## Append-only / adjustment posture

Ledger is append-only (ADR-056/057, ADR-059-A/119, I-24); posted entries are not mutated in place — corrections are new, signed-off entries. Money is Decimal-only (I-01). Adjustments and closes carry the financial-materiality sign-off above.

## Midaz / MCP escalation note (gated)

`midaz_agent` / MCP writes must route via `LedgerPort`. Whether any direct MCP→ledger write path exists is **not asserted here**; it is a gated architecture-control question for **`[external reviewer]`** (register #6 midaz MCP→ledger, AMBER), to be closed only with documented evidence, never assumed.

## Sources
`../../HITL-MATRIX.yaml` · `../../docs/ORG-STRUCTURE.md` · `../../INVARIANTS.md` (I-01, I-24, I-27) · `../../docs/briefs/FLOOR2-A-CHAIN-CONTEXT-FOR-CONSULTANTS.md`
