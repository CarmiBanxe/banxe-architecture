# CONTACT-CHAIN MATRIX — 2026-07-25

**GOVERNANCE / DESCRIPTIVE CANON / DOCS-ONLY / NO COMMIT**

Formal multi-level contact chain for BANK: who contacts whom, in what direction, over which channel,
under which gate. **Descriptive only** — it records existing, verified relationships; it does **not**
grant new rights, autonomy, or write-authority. Facts sourced from verified shell-audits (engine :8200,
backend :8000, Legion :8080, agent registries). Disputed / non-verified links are marked
`[pending human ratification]`; legal/write links are `[counsel]`.

Referenced registries (not modified): `AGENT-REGISTRY-BANK-MASTER-2026-07-22.md`,
`AGENT-REGISTRY-{F1,F2,F3,F4}-2026-07-21.md`, `COMPANY-REGISTRY-*`, `HITL-MATRIX.yaml`,
`GL-POST21-MCP-CUTOVER-LIVE-REPORT-2026-07-24.md`, `BACKEND-8000-BRINGUP-REPORT-2026-07-24.md`.

---

## §1 Purpose

A single contact-chain reference across four contact levels — **vertical** (management hierarchy),
**horizontal** (inter-department working links), **client** (engine as personal manager), and
**technical** (engine↔backend↔Legion). Each contact names its direction, channel, and governing gate.
Descriptive canon: it mirrors the registries and verified runtime state; it creates no new authority.

---

## §2 VERTICAL chain (management hierarchy)

Direction of authority is top-down for *proposals*; **all engine decisions are PROPOSES-only (I-27 / HITL-L4)** —
the ceo-conductor coordinates but never decides autonomously.

| level | actor | contacts-upward | contacts-downward | SMF |
|---|---|---|---|---|
| L0 | Board | — | CEO | BOARD |
| L1 | CEO | Board | ceo-conductor (engine role_1); C-suite | CEO / SMF1 |
| L1 | CFO | Board/CEO | FinBI, RegRep, Treasury (F3) | CFO / SMF2 |
| L1 | CRO | Board/CEO | Risk, AML (F3) | CRO / SMF4 |
| L1 | Internal Audit | **Board Audit Committee (C2)** — independent, NOT CTO/SMF26 (3LoD independence, 2026-07-25) | Audit-cell (F4) | Int-Audit / SMF5 |
| L1 | MLRO | Board/CEO | AML, safeguarding escalations | MLRO / SMF17 |
| L1 | COO | Board/CEO | Support, Customer-ops (F1); Payments (F2) | COO / SMF24 |
| L1 | CTO | Board/CEO | AI-platform, DevOps, Security (F4) | CTO / SMF26 |
| L2 | ceo-conductor (:8200 role_1) | CEO | 17 room-heads (department governors) — **PROPOSES only (I-27)** | — (agent, no SMF) |
| L3 | room-head (×17) | ceo-conductor + owning SMF | room agents (human-double + SMF gate) | per-room SMF |
| L4 | room agent (×132) | room-head | task execution (autonomy L1–L4 per agent-authority) | via room-head |

**Explicit:** ceo-conductor (engine role_1) is a *coordinator that proposes*; it holds no autonomous
decision right. Every decision-grade downward contact carries the I-27 HITL gate; L4-grade actions
(SAR, FIN060 sign-off, threshold change) are human-only.

---

## §3 HORIZONTAL chain (inter-department working links)

Only domain-justified links (grounded in service boundaries / existing ports). Non-obvious couplings →
`[pending human ratification]`.

| from-room | to-room | reason | channel | gate |
|---|---|---|---|---|
| F2-identity | F2-payments | KYB/KYC gates merchant + payer before payment | API contract | AML/KYC (HITL-002/006) |
| F2-payments | F2-ledger | payment posting → ledger entry | LedgerPort (Protocol) | write → [counsel] |
| F2-ledger | F2-safeguarding | client-fund balances feed safeguarding recon | LedgerPort / recon read-side | I-24 audit |
| F2-safeguarding | F3-regrep | safeguarding shortfall → FCA reporting | event / report | HITL-011 |
| F3-aml | F3-risk | AML alerts feed risk scoring | event queue | L3 + HITL |
| F3-treasury | F2-ledger | treasury positions reconcile to ledger | read-side | I-24 audit |
| F3-finbi | F3-regrep | analytics → FIN060 / RegData generation | dbt / report | HITL-010 (CFO) |
| F2-payments | F3-aml | transaction monitoring on payment flow | event (TM agent) | L3, alert SLA |
| F1-customer-ops | F2-identity | onboarding routes to KYC/KYB | API contract | HITL-006 |
| F1-support | F1-complaints/customer-ops | ticket → complaint → escalation | internal queue | L2 alert |
| F4-security | all rooms (F1–F3) | security incident oversight | control-plane | HITL-015 |
| F4-audit-cell | all rooms (F1–F4) | append-only audit capture + **3rd-line independent assurance** | pgAudit / ClickHouse | I-24; reports to **Board Audit Committee (C2)**, not CTO — see THREE-LINES-OF-DEFENCE-MAP |
| F1-marketing | F1-customer-ops | referral/CRM → onboarding | internal | `[pending human ratification]` |
| F1-hr-legal | all rooms | SMCR / legal oversight | governance | [counsel] |

Links beyond the above are **not asserted** here — add only when domain-verified.

---

## §4 CLIENT chain (engine as personal manager)

```
Client ──▶ Banksy client-pm-friend (:8200 role_2)
              │  captures intent (ADR-171 ClientIntentRecord; intent-first ADR-045)
              ▼
        ceo-conductor (role_1) PROPOSES (I-27) ──▶ MCP tools ──▶ backend :8000
              ▼
        response back to client (friendly PM layer)
```

| step | actor | direction | channel | gate |
|---|---|---|---|---|
| 1 | Client → client-pm-friend (:8200) | inbound intent | engine HTTP | — |
| 2 | client-pm-friend → ceo-conductor | intent → proposal | in-engine | I-27 (proposes only) |
| 3 | engine → backend :8000 (read tools) | query | MCP: get_balance, get_fx_quote, kyc_status, notify_client, wallet_validate_address | **LIVE (read)** |
| 3w | engine → backend (write) | initiate_payment / ledger | MCP write-tool | **[counsel]** — declared, NOT auto-executed |
| 4 | engine → client | answer | client-pm layer | — |

**Read-path is LIVE** (verified: `tools_endpoint_set=true`, `fx_get_rates → :8000/v1/fx/rates` HTTP 200).
**Write-path (`initiate_payment`, ledger) = `[counsel]`** — never auto-executed; requires human decision.

---

## §5 ENGINE ↔ BACKEND ↔ LEGION chain (technical, verified)

| link | from → to | mode | verified state | gate |
|---|---|---|---|---|
| MCP tools | Banksy :8200 → backend :8000 | request/response | `tools_endpoint_set=true`, 6 tools live, read round-trip HTTP 200 | read LIVE; write [counsel] |
| external supply | Banksy :8200 → Legion :8080 | request/response, data-gathering only | `direct_inference=false`, external-request-response, `compiled_over_legion=false` | Legion-extras (TOR/scrape/OSINT/RL) **excluded** |
| persistence | backend :8000 → DB | query | postgres:5432, clickhouse:8123, midaz:8095 up; redis bypassed (in-memory webhook) | Midaz write [counsel] |

**Explicit boundaries (verified):** Legion is an **external trusted supplier**, NOT in the bank stack;
Banksy is **not compiled over Legion**; direct Legion inference (:8080) is forbidden to Banksy;
forbidden functions (TOR / scrape / OSINT / proxy / RL / executor) are excluded (`forbidden_hits=[]`).

---

## §6 GATES on each contact

| gate | applies to | rule |
|---|---|---|
| **I-27 (HITL)** | all engine decision-contacts (§2 downward, §4 step 2) | AI PROPOSES, human DECIDES — no autonomous decision |
| **HITL-L4** | SAR filing, FIN060 sign-off, threshold change, deploy, AI-model update | human-only (see HITL-MATRIX) |
| **[counsel]** | write/ledger/Midaz (`initiate_payment`, §3 payments→ledger, §4 step 3w, §5 persistence write) | not authorized for live write; legal sign-off |
| **I-24 (append-only)** | audit-cell, ledger, safeguarding audit contacts | no UPDATE/DELETE on audit trails |
| **Legion-exclusion** | Banksy → Legion (§5) | extra Legion functions (TOR/scrape/OSINT/proxy/RL/executor/direct-inference) forbidden to Banksy |

---

## §7 Roadmap note

- This matrix is **canon-alignment**, descriptive — it does **not** block or pause any sprint.
  GL-13-EXEC (code migration) and GL-post-20 (prod-inference) continue in parallel.
- GENERAL-LINE addition: **"contact-chain matrix canonized (DONE)"** as a governance-canon phase
  (non-blocking, parallel to sprints).
- Disputed links (§3 marketing→customer-ops) and any authority question → `[pending human ratification]`.

---
**This does not replace legal advice.**
