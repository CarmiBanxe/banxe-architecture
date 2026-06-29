# ADR-151: Paybis embedded-markup fee transparency — Consumer Duty (FCA PS22/9)

**Status:** PROPOSED
**Date:** 2026-06-29
**Builds on:** ADR-108 (Paybis distribution model — BANXE distribution fee economics), ADR-114 (Travel Rule / Paybis CASP)
**Relates:** ADR-138 (Paybis sole external crypto provider — ACCEPTED pending, PR #881); existing Consumer-Duty surfaces ADR-079 (CRO risk-metrics), ADR-091 (quant-moat advisory seam), ADR-112 (voice-AI support); `docs/COMPLIANCE-MATRIX.md`; active plan item **S9-06 Consumer Duty FCA PS22/9**
**Plane:** banxe-architecture = decision/spec only. Ships no runtime code; makes no cross-repo write. Additive (ADR-119 append-only; never renumbers a prior ADR).

> **Dup-audit (ADR-102):** Consumer Duty exists in canon as a *framework* (COMPLIANCE-MATRIX, plan S9-06, ADR-079/091/112), and the Paybis *B2B* fee economics are canon in **ADR-108**. Neither covers the **consumer-facing disclosure of the embedded Paybis markup** — that intersection is the genuine gap this ADR fills. This ADR **applies** the existing Consumer-Duty obligation to the Paybis ramp price surface; it does **not** duplicate the framework, and it does **not** restate ADR-108's economics.

## Context

- Paybis on/off-ramp (BuyCrypto / SellCrypto, per ADR-138 / PAYBIS-LEGACY-FLOW-MAP) returns a **single quoted rate** to the end client. The BANXE distribution fee (the "partner fee" of ADR-108) is **embedded inside that rate** — the client sees one blended price / "Service Fee", not a separated BANXE markup line.
- **ADR-108** canonizes the *B2B* economics (BANXE as distribution agent earning a partner fee from Paybis). It does **not** decide how — or whether — that embedded markup is **disclosed to the end consumer**.
- **FCA Consumer Duty (PS22/9, PRIN 2A)** — the *price & fair value* and *consumer understanding* outcomes — requires a deliberate, evidenced decision on disclosure of an embedded markup on a retail payment surface. Absent that decision, the embedded-fee design is a Consumer-Duty exposure.

## Decision

This ADR fixes the **disclosure principle** (mechanism, not amounts):

1. **All-in price, no surprise.** The client MUST be shown the final, all-in price (including any embedded BANXE markup) **before** the transaction is consummated — no post-hoc fee discovery (Consumer Duty "consumer understanding").
2. **Existence-of-fee disclosure.** The presence of a BANXE service fee *within* the quoted rate MUST be disclosed in pre-contract terms / T&Cs and on the price surface (a "this price includes a BANXE service fee" disclosure), independent of whether the fee is itemised.
3. **Fair-value basis.** A documented **fair-value assessment** (PRIN 2A.4) MUST exist for the embedded markup and be re-reviewable; the price surface and its disclosure copy are a **Consumer-Duty-evidenced** artefact.
4. **Values live in config-as-data, not here.** The concrete tariff/margin numbers (partner-fee rate, any caps) are **internal configuration** referenced by pointer — never embedded in this ADR, in public docs, or in any external-facing API/egress path (§10 Configuration-over-Hardcoding; RED-zone).
5. **Ruflo-gated price surface.** Any agent/runtime surface that renders or quotes the ramp price is a **payment/compliance contour** → Ruflo in the regulatory-check path (BUG-005), and changes to the disclosure go through the §1/§9 governance gate.

## Rationale

- Embedding a markup invisibly in the rate, without a disclosure principle + fair-value basis, is the textbook Consumer-Duty failure mode (price & fair value, consumer understanding). Fixing the **principle** now — while the Paybis ramp is still pre-build (ADR-138 adapter not yet built) — keeps the consumer surface compliant by construction rather than retrofitted.
- Keeping the **values** out of canon (config-as-data) preserves both commercial confidentiality and egress-zero (tariffs never leak into public docs / external APIs), while still letting this ADR govern *how* disclosure must work.

## Consequences

- **Positive:** Consumer-Duty (PS22/9) compliance basis for the Paybis ramp price; disclosure obligation fixed before the price surface is built; egress = 0 on tariff values; Ruflo-gated payment surface.
- **Follow-up (separate, gated):** (a) a downstream **disclosure/UI spec** (price-surface copy + all-in-price presentation) in the frontend/BFF; (b) the actual **config-as-data tariff values** + fair-value assessment record (internal, RED-zone, operator/MLRO-owned). Neither is in this ADR.
- **Dependency:** ADR-108 economics (unchanged) and the Paybis price/quote contract.

## Out of scope (fail-closed)

No tariff/margin values (RED-zone — config-as-data only); no runtime code; no UI copy; no change to ADR-108's economics or ADR-114's Travel-Rule allocation; no new fee model. This ADR decides **disclosure mechanism + Consumer-Duty basis only**.

## Related

ADR-108 (distribution model / fee economics — anchor, numbers NOT copied), ADR-114 (Travel Rule / Paybis CASP), ADR-138 (Paybis sole provider, PR #881); ADR-079 / ADR-091 / ADR-112 + `docs/COMPLIANCE-MATRIX.md` + plan **S9-06** (existing Consumer-Duty surfaces); `docs/paybis-dossier/PAYBIS-LEGACY-FLOW-MAP.md` (embedded-rate ramp flow). **FCA Consumer Duty PS22/9, PRIN 2A (price & fair value, consumer understanding).**

> **Governance:** PROPOSED. Promotion to ACCEPTED is a **compliance decision** (Consumer Duty) requiring **CEO / CTIO / MLRO** human-in-the-loop per CLAUDE.md §1/§9 + Ruflo. Prepared as a **DRAFT PR — DO NOT MERGE** without explicit operator governance approval.
