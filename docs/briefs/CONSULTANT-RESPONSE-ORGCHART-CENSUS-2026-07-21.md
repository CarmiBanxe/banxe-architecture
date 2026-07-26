# Consultant Response — Org-Chart / Agent Census + Floor-2 Identity — 2026-07-21

**FLOOR-2 / GOVERNANCE / CONSULTANT-RESPONSE CAPTURE / DOCS-ONLY / NO RUNTIME CHANGE**
Source: external consultant response to 10 questions (agent census vs org-chart + Floor-2 identity), captured 2026-07-21. Internal-policy stance and legal classification are kept separate. Nothing here is a self-authored legal conclusion.

## 1. CONFIRMED (internal decisions — recorded)

- **CONFIRMED-1 — IDV/KYC classification.** "Non-Annex-III, high-risk by policy" is consistent with the Annex III text (Annex III high-risk = credit scoring of natural persons + life/health insurance pricing). This remains an **internal control posture, not a legal determination**.
- **CONFIRMED-2 — Article 12 traceability.** `correlation_id` is **insufficient**. Mandatory decision-layer fields: **initiator, input data, decision outcome, override trail**; **retention ≥ 6 months**. Status moves from "open" to **"required"** for high-risk lanes.
- **CONFIRMED-3 — Consumer Duty.** A `consumer_duty_agent` in F3-risk is permissible, but it does **not** substitute for a board-level SMF **Consumer Duty champion** (PS22/9) — that is a separate appointment.
- **CONFIRMED-4 — SM&CR headcount.** The regulator sets no FTE count; the minimum is **1 approved Senior Manager + a Statement of Responsibilities per function**. FTE sizing is an internal, risk-based decision.
- **CONFIRMED-5 — Agent source-of-truth.** Canonical source = a formal **REGISTRY** (agent → room → human-double → SMF). File count (86) / class count (77) are **reconciliation metrics, not the source of truth**.

## 2. GATED (remains with counsel / needs function clarification)

- **KYB ↔ merchant-acquiring.** No settled legal boundary; working position — treat KYB as an embedded element of acquiring-onboarding until counsel concludes. `[counsel]`
- **crypto_agent.** If custody is involved → CASP/MiCA perimeter; ownership depends on who holds the CASP status (bank / Paybis / custodian). `[counsel]` `[gated]`
- **open_banking_agent.** Determine role: **AISP** (read-only) vs **PISP** (payment initiation) → licence follows from that. `[counsel]` `[needs-function-clarification]`
- **Room-governance vs runtime.** Sufficient as navigation; an external reviewer will likely require **evidence of auto-synchronisation** of rooms with runtime (anti-drift), which does not currently exist. `[external reviewer]`

## 3. ACTION ITEMS (new, from consultant response)

- **ACTION-1** — Introduce a formal **decision-agent vs tooling-agent** criterion. Only decision-agents (affect a regulated outcome, HITL-gated) are mandatory in the org-chart with a human-double. Tooling-agents are out of the personal listing.
- **ACTION-2** — Functional audit of **F4-audit-cell / F4-devops by purpose, not by `*_agent.py` filename** (CI scripts, embedded functions) — a single agent likely means a census miss.
- **ACTION-3** — Stand up a formal agent **REGISTRY** as source of truth; reconcile files/classes against the registry.
- **ACTION-4** — Design **decision-layer logging fields** (initiator / input / decision / override, retention ≥ 6 months) as a requirement for high-risk lanes.
- **ACTION-5** — Appoint a **board-level SMF Consumer Duty champion** (separate from room placement).

## Register status

- **Decision register:** no `docs/governance/DECISION-REGISTER.md` (or equivalent) exists in the architecture repo at capture time. CONFIRMED-1..5 are therefore recorded **here** pending a decision register; no new register schema was created.
- **Open-questions register:** `docs/governance/OPEN-REGULATORY-QUESTIONS-REGISTER-2026-07-20.md` exists. A dated **append-only addendum** (2026-07-21, consultant response) records the status deltas below without editing any existing entry or traffic-light (freeze rule respected):
  - Annex III IDV/KYC → "policy-confirmed, legal open"
  - correlation_id → "insufficient, decision-layer required"
  - KYB/acquiring, crypto CASP, OB AISP/PISP → "gated-counsel"

---
*Internal-policy stances are labelled as such; all legal/regulatory classifications remain `[counsel]` and are not decided here. Annex III / MiCA / PSD2 classifications are not changed beyond what the consultant stated.*
**This does not replace legal advice.**
