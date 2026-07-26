# THREE LINES OF DEFENCE — Overlay Map — 2026-07-25

**GOVERNANCE / 3LoD / DOCS-ONLY / NO COMMIT**

Maps our 17 rooms / 4 floors onto the classical Three Lines of Defence, closing the "3LoD separation
unclear / F4 conflation" gap from `FABLE5-IDEAL-BANK-TECHMAP-GAP-2026-07-25.md`. Descriptive canon.

## Line assignment

| line | role | our rooms | owner/SMF |
|---|---|---|---|
| **1st line** | own & manage risk (business ops) | F1-support, F1-customer-ops, F1-marketing, F2-identity, F2-payments, F2-ledger, F2-safeguarding, F3-treasury (front), F2-payments (lending `[pending]`) | COO/SMF24, CFO/SMF2 |
| **2nd line** | oversee & challenge (risk/compliance) | F3-risk, F3-aml, F3-regrep (compliance-perimeter), F1-customer-ops (consumer_duty), F3-finbi (control reporting) | CRO/SMF4, MLRO/SMF17, CCO/SMF16 `[counsel]` |
| **3rd line** | independent assurance (audit) | **F4-audit-cell** | Internal-Audit/SMF5 → **Board Audit Committee** |
| support (not a line) | technology enablement | F4-ai-platform, F4-devops, F4-security | CTO/SMF26 |

## Control relationships

```
        Board  ── Board Risk (C1) / Board Audit (C2) ──┐
          ▲                                            │
   ┌──────┴───────┐                                    │
3rd LINE  F4-audit-cell  ──independent assurance──▶ audits ALL lines
(Internal-Audit/SMF5, reports to Board Audit Committee — NOT CTO)
          ▲ audits
2nd LINE  F3-risk / F3-aml / compliance-perimeter / consumer_duty
(CRO/SMF4, MLRO/SMF17)  ──oversees & challenges──▶
          ▲ oversees
1st LINE  F1 (customer) + F2 (banking ops) + treasury-front
(business owns its risk)
```

## Independence rule (audit-cell)

- **F4-audit-cell physically sits on F4** but its **governance reporting line is the Board Audit Committee**,
  NOT CTO/SMF26. This restores 3rd-line independence (IIA Standards): technology management cannot direct
  audit scope or findings.
- F4-ai-platform / devops / security are **1st-line technology enablement** (they build/run), not an
  independent line — they are subject to 2nd-line control and 3rd-line audit like any business function.

## Overlay verdict
- 1st / 2nd / 3rd lines are now explicitly separated. Prior F4 conflation (audit sharing CTO management
  with devops/security) is resolved by re-pointing audit-cell's reporting line to Board Audit Committee.
- 2nd-line oversight of 1st-line and 3rd-line audit of all are documented control relationships above.

---
**This does not replace legal advice.**
