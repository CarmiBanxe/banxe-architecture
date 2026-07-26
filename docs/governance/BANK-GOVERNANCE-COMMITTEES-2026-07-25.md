# BANK GOVERNANCE COMMITTEES — 2026-07-25

**GOVERNANCE / COMMITTEE CHARTERS / DOCS-ONLY / NO COMMIT**

Documents the 8 mandatory governance committees (classical bank + SM&CR pattern), closing the
"0 documented / 8 MISSING" gap from `FABLE5-IDEAL-BANK-TECHMAP-GAP-2026-07-25.md`. Committee
structures are descriptive canon over the verified 4-floor / 17-room model; they create governance
oversight, not new autonomy. Actual member appointments (esp. NED chairs) → `[pending human ratification]`;
regulatory sign-off → `[counsel]`.

## Committee register

| # | Committee | Chair (SMF) | Core members | Frequency | Oversees (rooms/floors) | Escalates to |
|---|---|---|---|---|---|---|
| C1 | **Board Risk Committee** | NED chair + CRO/SMF4 | CRO, CFO, CEO, MLRO | Monthly | F3-risk, F3-aml, F3-treasury (2nd line) | Board |
| C2 | **Board Audit Committee** | NED chair (independent) | Internal-Audit/SMF5, CEO, external auditor | Quarterly | F4-audit-cell (3rd line), all rooms (audit scope) | Board |
| C3 | **ALCO (Asset-Liability)** | CFO/SMF2 | CRO, Treasury head, CEO | Quarterly | F3-treasury, F2-ledger, F2-safeguarding | Board Risk (C1) |
| C4 | **Credit Committee** | CRO/SMF4 | Head of Credit, CFO | Monthly (on lending) | F2-payments (lending domain) `[pending lending ratification]` | Board Risk (C1) |
| C5 | **Product Governance Committee** | COO/SMF24 | Product heads, Compliance, Risk, Consumer-Duty lead | Quarterly | F1-marketing, F2-payments, F1-customer-ops (consumer_duty) | Board |
| C6 | **Consumer Duty Committee** | COO/SMF24 | Head of Customer Service, Compliance, Risk, Finance | Quarterly | F1-customer-ops (consumer_duty, complaints), F1-support | Board |
| C7 | **Operational Risk Committee** | CRO/SMF4 | COO, CTO, Internal-Audit, Security lead | Monthly | F4-security, F4-devops, F4-audit-cell (incident_response) | Board Risk (C1) |
| C8 | **SMCR Governance Committee** | Board/CEO chair | CEO, HR head, Internal-Audit/SMF5 | Annual + on-change | F1-hr-legal (SMCR registration) | Board Audit (C2) |

## Per-committee mandate

- **C1 Board Risk** — approves risk appetite & limits; reviews material breaches (safeguarding shortfall,
  AML threshold changes); oversees CRO function. HITL: threshold changes gate here (I-27 / HITL-L4).
- **C2 Board Audit** — approves audit plan; reviews findings & remediation; **assures 3rd-line independence**
  (F4-audit-cell reports HERE, not to CTO — see audit-independence fix); reviews SAR disclosure; receives DPO reporting once appointed.
- **C3 ALCO** — sets liquidity / funding / FX limits; approves funding plans; reviews interest-rate & FX risk.
- **C4 Credit** — approves lending decisions above threshold; reviews credit quality/provisioning. **Dormant until
  lending is ratified** (`[pending human ratification]`).
- **C5 Product Governance** — approves new products; fair-value & consumer-duty assessment; conflict-of-interest review.
- **C6 Consumer Duty** — PS22/9 fair value, vulnerable-customer outcomes, conduct-risk monitoring.
- **C7 Operational Risk** — incident & loss-event governance; escalation of P0/P1 incidents; control-failure review.
- **C8 SMCR Governance** — SMF fitness & propriety, certification, conflicts, training policy.

## Notes
- Chairs marked "NED" (non-executive director) require appointment → `[pending human ratification]`.
- Committee cadence & Board-reporting are the governance canon; operational HITL gates already exist in `HITL-MATRIX.yaml`.
- Regulatory adequacy of each charter → `[counsel]`.

---
**This does not replace legal advice.**
