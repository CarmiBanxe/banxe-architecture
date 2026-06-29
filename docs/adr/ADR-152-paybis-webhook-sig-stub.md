# ADR-152: Paybis webhook RSA-PSS signature verification — STUB (blocked on external)

**Status:** STUB / BLOCKED-ON-EXTERNAL
**Date:** 2026-06-29
**Builds on:** ADR-114 (Travel Rule / Paybis CASP), ADR-138 (Paybis sole external crypto provider — ACCEPTED), ADR-034 (webhook reliability)
**Plane:** banxe-architecture = decision/spec only. Ships no runtime code; makes no cross-repo write. Additive (ADR-119 append-only).

> **Dup-audit (ADR-102) — this is a CONSOLIDATION, not a new discovery.** The dependency is **already recorded** in canon (cross-referenced below); this STUB does not duplicate it — it **elevates a scattered dependency into one tracked, owned, ADR-level blocker** so it is discoverable and assignable. It records **no implementation** and edits **no foreign work**.
> - `docs/paybis-dossier/SRC-05-06-paybis-integration-map.md:42` — *"Exact webhook event names, payload schema, **signature verification method** = **Paybis**"*
> - `docs/paybis-dossier/SRC-INTAKE-REGISTER.md` (SRC-06) — *literal endpoints/auth/signature/schemas **НЕИЗВЕСТНО**, clean spec pending → Paybis*
> - `docs/paybis-dossier/PLAN-ROADMAP-SPRINTS-NEURONEXT-TO-PAYBIS.md:215` — SRC-06 clean API spec (incl. webhook verify) = Wave-B / **Paybis**

## Context

- Paybis webhooks (in/out, per the on/off-ramp flow — ADR-138 / PAYBIS-LEGACY-FLOW-MAP) are signed with **RSA-PSS (SHA-512)**. A `PaybisSignatureService` **already exists** in the `banxe-trading-backend`/EMI **foreign** track (`agent/factory/paybis/*` — Rule 6/7: **referenced, not touched, not edited here**).
- The **canonical, Paybis-supplied verification method** — key provisioning, key rotation cadence, payload canonicalization, and the exact signed-field set — is **Paybis-owned and not yet provided** (the integration-map and SRC-INTAKE register both defer it to Paybis). Therefore the verification cannot be canonized as a forward spec **until Paybis supplies it**.

## Decision (deferred — dependency record only)

1. **Requirement (binding now):** any Paybis webhook ingress MUST verify the RSA-PSS signature and **fail-closed on mismatch** (reject/quarantine, never process an unverified payload). This is the one invariant that does not need Paybis input.
2. **Implementation pointer (reference, not edit):** the existing `PaybisSignatureService` (RSA-PSS SHA-512, foreign `agent/factory/paybis/*`) is the integration point — **not modified by this ADR** (Rule 6/7).
3. **Deferred to a full spec:** key provisioning/rotation, payload canonicalization, and the exact signed-field list are **deferred until Paybis delivers the verification-method spec** (SRC-06). At that point this STUB is promoted to a full ADR/spec.

## RED-zone (fail-closed)

No keys/secrets/signing material in this ADR or any doc — key material lives in the **vault** (config-as-data, egress = 0). No runtime code; no cross-repo write; no edit to the foreign Paybis track; no implementation of the verification method (externally blocked).

## Blocker

**P-dep — AWAITS Paybis RSA-PSS verification-method spec** (key provisioning + rotation + canonicalization + signed fields). **Owner:** Paybis AM (via SRC-06 clean API spec, Wave-B). Until delivered, this remains `STUB / BLOCKED-ON-EXTERNAL` — do not implement a guessed verification method.

## Related

ADR-114 (Travel Rule / Paybis CASP), ADR-138 (Paybis sole provider — ACCEPTED), ADR-034 (webhook reliability); `docs/architecture/DOSSIER-PAYBIS-CRYPTO-PROVIDER-2026-06-26.md`; `docs/paybis-dossier/{SRC-05-06-paybis-integration-map,SRC-INTAKE-REGISTER,PLAN-ROADMAP-SPRINTS-NEURONEXT-TO-PAYBIS}.md`; foreign `agent/factory/paybis/*` (`PaybisSignatureService`, reference only). FATF R.16 / Travel-Rule webhook integrity.

> **Governance:** STUB. It records a dependency + the fail-closed requirement; it does NOT decide the verification method (Paybis-owned) and implements nothing. Prepared as a **DRAFT PR — DO NOT MERGE** without operator review; promote to a full spec only once Paybis delivers SRC-06.
