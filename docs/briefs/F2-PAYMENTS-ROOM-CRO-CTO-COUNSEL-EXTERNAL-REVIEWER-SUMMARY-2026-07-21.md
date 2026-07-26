# F2 Payments-Room — CRO/CTO + Counsel + External Reviewer Summary — 2026-07-21

**FLOOR-2 / PAYMENTS CLUSTER / CONSOLIDATED GOVERNANCE SUMMARY / DOCS-ONLY / NO RUNTIME CHANGE**
Analogue of the identity/ledger CRO-CTO summaries. Factual and governance-safe. Internal control stance, legal classification, and external-review questions are marked and kept separate. **This does not replace legal advice.**

## 1. Canon position and room perimeter

- **Canon position (factual):** `bank-rooms/F2-payments-room` is now treated as a canonical Floor-2 room — a documentation / governance / navigation layer **above** runtime, hardened on the same pattern as identity (S-A5) and ledger (S-A6).
- **Basement split:** runtime payment rails, adapters, and webhooks live in `~/banxe-emi-stack`; the room / governance layer lives in the architecture repo (`~/wt/architecture-bank-operating-model-20260718`). This summary does **not** assert any runtime change.
- **Room perimeter anchored by:** `M-GATEWAY-BUILD-SPEC.md`, `M-SANDBOX-BUILD-SPEC.md`, `B-PRICING-BUILD-SPEC.md`, `D-FEE-BUILD-SPEC.md`, `D-FIN-BUILD-SPEC.md`, plus the linked roadmap/audit docs (`S2-FLOOR2-SPRINT-PLAN-UPDATE-PLAN`, `R2-FLOOR2-MASTER-ROADMAP-UPDATE-PLAN`, `FLOOR2-BUILD-SPECS-INSTALLATION-AUDIT-PLAN`, `FLOOR2-MIG-STATUS-MATRIX`, `FLOOR2-A-CHAIN-CONTEXT-FOR-CONSULTANTS`).
- **Runtime entrypoints identified by shell audit R1 (not modified):** `services/payment/payment_service.py`, `services/ledger/production/{PAYBIS-WAVE-A.md, paybis_provider.py, paybis_webhook.py}`, `services/ledger/crypto_ledger_port.py`, `api/routers/payments.py`. Some open-banking router paths were **MISSING** in the R1 snapshot — recorded as an observation, not a conclusion.
- **Roadmap state (factual):** M-GATEWAY MIG side is treated as clean; M-GATEWAY remains **PARTIAL/GAP** for external / non-MIG reasons (keys / OD-R07 / web gating). WS8 "Payments/Rails" is the relevant lane.
- **In-perimeter as topics, not all resolved:** cards, crypto on/off-ramp, webhook contracts, and merchant-acquiring sit **inside** the control perimeter as topics; presence in the perimeter is not a statement that they are resolved or live-approved.

## 2. Internal control stance vs legal / regulatory classification

**Internal control stance (governance posture, not legal):**
- The payments-room is governed as a **controlled room** with HITL / SMF / review layers, consistent with the identity/ledger hardening pattern (I-27: AI proposes, human decides).
- Where room hardening introduced HITL framing, the three layers must remain **distinct**: technical workflow routing ≠ financial decision authority ≠ regulatory / audit escalation.
- M-GATEWAY residual gates are **externally controlled / gated** per roadmap (keys / OD-R07 / web gating); the room reflects them as open gates, not as passed controls.

**Legal / regulatory classification (NOT decided here):**
- Live card processing, crypto on/off-ramp, webhook go-live, and merchant-acquiring implications are **not legally closed** in this summary.
- Annex III relevance, licence / merchant-acquiring perimeter, Travel Rule, and similar characterisations are **not determined here** and remain `[counsel]`.
- **This does not replace legal advice.**

## 3. Open questions for counsel / external reviewer

- **`[counsel]` Merchant-acquiring licence / perimeter relevance for the payments-room.** *Known:* merchant-acquiring is inside the room perimeter as a topic and is linked to payments rails. *Undecided:* whether, and how, licensing / acquiring-perimeter obligations attach to the room's flows. *Why open:* it is a licensing/legal determination, not derivable from the build specs or the R1 audit.
- **`[counsel]` Legal / regulatory relevance of the cards / crypto / webhook go-live gates.** *Known:* card, crypto on/off-ramp, and webhook paths exist as gated topics, and runtime entrypoints were identified without modification. *Undecided:* their regulatory characterisation and go-live conditions. *Why open:* the materials preserve them as gated/open issues and do not state a closed legal position.
- **`[external reviewer]` Adequacy of the webhook / adapter / gated-control model for auditability and operational traceability.** *Known:* webhook and provider adapters are present and treated as controlled coupling points within the payments perimeter. *Undecided:* whether the current gated-control and traceability model is sufficient for external audit assurance. *Why open:* sufficiency for assurance is an external-review judgement, not something established by the R1 audit alone.
- **`[external reviewer]` Sufficiency of the canonical separation between room-governance and runtime rails.** *Known:* the room is documented as a governance layer above runtime, while runtime rails remain in the basement repo and are not changed by this summary. *Undecided:* whether that separation is sufficient for external architecture assurance of the payments perimeter. *Why open:* this is an architecture-assurance question that must be independently reviewed rather than self-certified inside the canon.
