# ODR-3: Regulatory posture — BANXE as Paybis distributor (MiCA-CASP on Paybis principal)

**Status:** PROPOSED — distributor regulatory posture (resolves the prior "ODR-3 = MiCA stance" S6.4 gate). **Requires MLRO/CTIO §1/§9 confirmation** (operator merge = that confirmation).
**Date:** 2026-06-30
**Type:** Operator Decision Record (ODR) — resolves ADR-083 §"OPERATOR DECISION REQUIRED" item 3 (Legal/MiCA stance)
**Anchors:** Corporate On/Off-Ramp Agreement (BANXE LTD ↔ SIA Paybis Europe) §1.1 / §D *(basis only — not reproduced)* · ADR-138 (Paybis sole external crypto provider — ACCEPTED) · ADR-108 (distribution model) · ADR-114 (Travel-Rule / Paybis CASP) · ADR-151 (Consumer Duty disclosure) · ODR-1 (#908, PROVISIONING-CONFIRMED)
**Gates:** S6.4-EN (dYdX live order placement) — pairs with ODR-1
**Plane:** banxe-architecture = decision record only. No runtime code; **no secret values**. Additive (ADR-119 append-only).

> **RECORD-NOT-RULE (scope of this ODR).** The factory **records** the distributor posture as stated in the BANXE↔Paybis Agreement and as **already canon** in ADR-138/ADR-108; it **does not issue a legal or regulatory opinion** (§9 — LLM prepares materials). The **regulatory determination is the MLRO/CTIO's** — their §1/§9 confirmation (this PR's merge) is what resolves the gate. Until merged, this is a prepared record, not a regulatory clearance.

## Context

S6.4-EN (live dYdX order placement) was gated on **ODR-3 = "MiCA/CASP stance"** (ADR-083 §7). The relevant posture is **already canon**: **ADR-138** states *"PAYBIS = regulated CASP… BANXE acts as **distribution agent** (ADR-108), keeping the **crypto regulatory surface on PAYBIS**."* This ODR consolidates that scattered posture into the single ODR-3 record (ADR-102 — consolidation, not new legal discovery).

**Agreement basis (operator-supplied; cited, not reproduced — copyright):**
- **§1.1** — Paybis acts as **principal on its own behalf**, *not* as agent/broker of the Partner; transactions are executed **directly Paybis ↔ Customer**.
- **§D** — the user is a **direct customer of Paybis**.

⇒ The **MiCA-CASP obligations sit with Paybis** (the CASP principal, Latvia). **BANXE = distributor / Partner Platform** (surfaces the Paybis widget; routes), and does **not** take its own MiCA-CASP position for live crypto execution.

## Decision (recorded — pending MLRO/CTIO confirmation)

1. **BANXE LTD acts as a Paybis distributor (Partner Platform).** Paybis (regulated CASP) is the **principal** that holds the customer relationship and the **MiCA-CASP obligations** for live crypto execution, per Agreement §1.1/§D + ADR-138/ADR-108.
2. **BANXE does NOT take its own MiCA-CASP stance** for live crypto order execution — that surface is **covered by Paybis's principal/CASP status**. (This is the posture ADR-138 already canonizes; ODR-3 records it as the S6.4 regulatory basis.)
3. **What REMAINS BANXE's (distributor obligations — NOT MiCA-CASP):** Partner-Fee invoicing (per the Agreement); **Blacklisted-Industries (Annex 2) enforcement**; **Consumer Duty disclosure** of the embedded fee (already **ADR-151**); **Travel-Rule coordination** (ADR-114) in the distributor role.

## S6.4 gate effect (on confirmation)

On MLRO/CTIO §1/§9 confirmation, **"ODR-3 = MiCA stance" is resolved** (distributor model). **S6.4-EN then remains gated only on:**
- **ODR-1** ✅ (PROVISIONING-CONFIRMED, #908) **+ operator GO +** sandbox/RED-zone controls at build (**Ruflo mandatory** on the execution surface, **kill-switch** `dydx_submit_enabled`, **fail-closed**, **HITL on order**, sandbox/testnet first).
- **Live execution = Paybis principal**; BANXE **constructs the unsigned intent and routes** — the **client wallet signs**, the backend holds no keys (self-custodial, ADR-083). BANXE does not execute as principal.

This ODR does **not** itself authorize the S6.4-EN build — that needs operator GO + the build-time controls above.

## RED-zone / out of scope (fail-closed)

No secret values; the Agreement is **cited as basis, not reproduced** (copyright). No own-CASP licensing claim is asserted by the factory — the regulatory determination is the MLRO/CTIO's. No runtime code; no cross-repo write; no change to ADR-138/108/114/151 substance; no live execution authorized here.

## Related

Corporate On/Off-Ramp Agreement §1.1/§D (basis); ADR-138 (Paybis sole provider, distribution agent — the canon this consolidates); ADR-108 (distribution model); ADR-114 (Travel-Rule/CASP); ADR-151 (Consumer Duty); ADR-016 (AML/PII); **ODR-1** (#908, integrator provisioning — pairs to unlock S6.4); ADR-083 §7 (ODR-3); ADR-102 (consolidation, not duplicate).

> **Governance:** PROPOSED. The factory recorded the distributor posture (operator-supplied Agreement basis + ADR-138 canon) per §9; it issued **no regulatory opinion**. Promotion to confirmed = **MLRO/CTIO §1/§9** (the operator merge is that act). Prepared as a **DRAFT PR — DO NOT MERGE** without MLRO/CTIO regulatory sign-off. Pairs with ODR-1; S6.4-EN still needs operator GO + build-time RED-zone controls.
