# A-KYB — Business KYB Onboarding Build-Spec (Companies House registry + UBO chain + director checks)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-24 · **Block:** A-kyb · **Priority:** P1 · **Sprint:** 11 · **Promotes:** the 0% (new business-onboarding definition).
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). This doc **specifies/orchestrates**; ships **no** runtime code and makes **no** cross-repo write.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103 (server-only refactor / promotion gate), ADR-059-A/ADR-119 (append-only frozen ledger). Additive; mutates no prior artifact.

> ⚠️ **PRIVACY/DELEGATION FENCE (read §8 first).** This is a **specification of a regulatory KYB process only**.
> Banxe performs **no** in-house registry scraping, business-owner/director PII collection, or biometric/document
> processing. **Registry lookup** (Companies House or equivalent) and **UBO/director sanctions/PEP screening** are
> **DELEGATED to licensed data/screening providers** via port abstractions (reusing the `KYCProviderPort`
> delegation pattern where applicable). Individual verification of UBOs/directors is **handed off to A-idv/A-kyc**.
> A-kyb defines the **business-onboarding orchestration, entity/UBO/director model, and interface contracts** —
> never an in-house registry or screening algorithm.

---

## 0. Duplication Audit (ADR-102)

| Artifact | Role | Decision |
|---|---|---|
| `docs/architecture/A-KYC-BUILD-SPEC.md` (IL-500) | **Individual** KYC onboarding orchestration — `KYCCase`/`KYCDecision`, risk-rating, EDD, HITL | **keep / REUSE boundary** — A-kyb is the **business sibling**; each UBO/director is an **individual** verified via A-kyc. **No individual-KYC orchestration reimplemented here** (ADR-102) |
| `docs/architecture/A-IDV-BUILD-SPEC.md` (IL-501) | Identity-verification **pipeline** (OCR + biometric, provider-delegated) → `VerificationResult` | **keep / REUSE** — UBOs/directors needing identity proof are routed to **A-idv**; pipeline **not** duplicated |
| `docs/refactor/legacy/kyc-provider-port-CONTRACT-SPEC-2026-06-06.md` | `KYCProviderPort` delegation pattern (startSession/getStatus/handleWebhook/changeLevel, webhook reliability, audit) | **keep / REUSE pattern** — A-kyb's registry/screening ports follow the same delegation discipline; port **not** reimplemented |
| `docs/refactor/legacy/aml-patterns-SPEC-2026-06-06.md` | AML/sanctions/PEP screening (F-aml) | **keep / reference** — UBO/director screening **handed off** to F-aml; AML logic **not** duplicated |
| `ROADMAP-MATRIX.md` rows A-kyc / A-idv / **A-kyb** | onboarding block split | **keep** — A-kyb = **business entity** verification; completes Block A; A-kyc/A-idv = individual layers |

No existing `A-KYB-BUILD-SPEC` / business-KYB artifact on main (live audit: `find docs -iname '*a-kyb*'` ⇒ empty; `ls docs/architecture` ⇒ A-IDV/A-KYC/B-EMI/D-FEE/D-FIN/D-GL only). New file is **non-duplicative**; it **orchestrates** business onboarding around existing individual layers + delegated providers, it does not re-implement them.

## 1. Scope — business KYB onboarding orchestration

A-kyb orchestrates the **business customer** onboarding journey; all operations are **config-as-data** (CLAUDE.md §10):

1. **Registry lookup (DELEGATED)** — resolve the legal entity via Companies House (or equivalent jurisdiction registry) through a `RegistryProviderPort`: company number, status, incorporation, registered office, SIC, officers, PSC (persons with significant control). A-kyb **does not** scrape registries in-house.
2. **UBO / beneficial-owner chain resolution** — build the ownership graph from PSC data; identify **beneficial owners > 25%** (direct + indirect through the corporate chain); flag opaque/circular structures for EDD.
3. **Director identification + checks** — enumerate directors/officers; each individual is routed to **A-idv/A-kyc** for identity verification and to **F-aml** for sanctions/PEP/adverse-media screening (A-kyb does neither in-house).
4. **Business risk-rating + EDD** — config-driven scoring (jurisdiction, industry/SIC, structure complexity, nominee/opaque ownership) → risk; high-risk ⇒ Enhanced Due Diligence step-up.
5. **Decision / HITL** — `KYBDecision` (approve/reject/refer); `refer` + high-risk reject route to **MLRO** per HITL thresholds (BUG-007); no autonomous rejection of borderline cases.

**Out** of A-kyb: individual KYC orchestration (A-kyc), the IDV pipeline (A-idv), AML screening logic (F-aml), registry/screening provider internals, account creation (B-emi).

## 2. Data model (KYBCase / BusinessEntity / UBO / Director)

Declarative, config-as-data; thresholds never hardcoded (CLAUDE.md §10); PII minimised (§4).

### 2.1 `KYBCase`
- `case_id`, `business_ref` (pseudonymous), `state` (see §3), `risk_rating` (§1.4), `correlation_id`, `created_at`, `updated_at`, `expires_at` (re-verification clock, ADR-028).

### 2.2 `BusinessEntity`
- `company_number`, `legal_name`, `status` (active/dissolved/liquidation), `incorporation_date`, `jurisdiction`, `registered_office_ref`, `sic_codes[]`.
- `registry_ref`: `{ provider_lookup_id }` — handle into `RegistryProviderPort`; provider-sourced, PII-minimised.

### 2.3 `UBO` (beneficial owner > 25%)
- `ubo_id`, `case_id`, `nature_of_control` (ownership-of-shares / voting-rights / right-to-appoint), `ownership_pct` (direct + computed indirect), `is_individual` (vs intermediate entity), `chain_path` (ownership path), `individual_ref` (→ A-idv/A-kyc case if individual), `screening_ref` (→ F-aml).
- Chain resolution recurses through intermediate entities until individual UBOs or a configured depth/opacity limit (EDD trigger).

### 2.4 `Director`
- `director_id`, `case_id`, `role` (director/officer/PSC), `individual_ref` (→ A-idv/A-kyc), `screening_ref` (→ F-aml), `appointment_status`.

### 2.5 `KYBDecision`
- `decision_id`, `case_id`, `outcome` (`approved|rejected|refer`), `reasons[]` (PII-redacted), `decided_by` (`auto` | `mlro_hitl`), `decided_at`.
- Every decision + state transition = immutable audit record (`guardian_audit_events`, ADR-027; 5-year retention, CASS 15/AMLD).

## 3. KYB flow (provider-delegated registry + screening; individuals via A-idv/A-kyc + F-aml)

```
business → A-kyb orchestrator
  1. open KYBCase                                  [state: not_started → pending]
  2. RegistryProviderPort.lookup(company_number)   → BusinessEntity + officers + PSC   [DELEGATED]
  3. resolve UBO chain (>25%, direct+indirect)     → UBO[]  (recurse intermediate entities)
  4. for each UBO individual + Director:
       → A-idv/A-kyc (identity verification)        [individual_ref]
       → F-aml (sanctions/PEP/adverse-media)        [screening_ref]   [DELEGATED]
  5. business risk-rating (config-driven)          → risk; high-risk ⇒ EDD step-up
  6. resolve KYBDecision (approve | reject | refer) [refer/high-risk → MLRO HITL]
  7. on approved → onboarding gate satisfied        → B-emi business account eligible
```

- A-kyb **never** scrapes a registry directly nor screens AML in-house — only `RegistryProviderPort` (lookup) + handoffs to A-idv/A-kyc (individual IDV) and F-aml (screening). Delegation-port semantics (idempotency, webhook reliability, audit, error model) follow the `KYCProviderPort` discipline.
- `ProviderUnavailable` / incomplete registry data ⇒ case stays `pending` (fail-closed: no approval without resolved entity + UBO chain).

## 4. Privacy-by-design (GDPR / UK-GDPR)

- **Lawful basis:** legal obligation (MLR 2017 / AMLD — business CDD) + contract necessity; recorded per case. Beneficial-ownership data processed under the AML legal-obligation basis.
- **Data minimisation:** A-kyb stores **the entity/UBO/director graph + decision metadata + provider refs only**. Individual PII (UBO/director identity documents, biometrics) is **held by A-idv's provider**, never persisted Banxe-side beyond redacted evidence refs (ADR-021).
- **PII Proxy (Presidio):** any PII transiting A-kyb routes through the PII Proxy per I-security; no PII in logs/audit beyond redacted fields.
- **Retention:** decision/audit records 5 years (CASS 15 / AMLD); provider-held raw data governed by provider DPA.
- **Right-to-erasure boundary:** subject to AML retention override (legal obligation) — documented, not silently honoured.

## 5. Producer/consumer contracts (referenced, not duplicated)

- **Consumes `RegistryProviderPort`** (new, follows `KYCProviderPort` delegation pattern): Companies House / registry lookup; provider-delegated, not scraped in-house.
- **Hands off individuals to A-idv/A-kyc** (`A-IDV-BUILD-SPEC` IL-501 / `A-KYC-BUILD-SPEC` IL-500): each UBO/director individual is verified via the individual layers. A-kyb **produces** the individual-verification request; A-idv/A-kyc **own** identity verification (not duplicated).
- **Hands off UBOs/directors to F-aml** (`aml-patterns-SPEC`): sanctions/PEP/adverse-media screening. A-kyb **produces** the screening request; F-aml **owns** the screen (not duplicated).
- **Gates B-emi business onboarding** (`B-EMI-BUILD-SPEC` IL-498): an approved KYB decision is the **precondition** for business e-money account creation. A-kyb produces the gate; B-emi owns account/IBAN (not duplicated).

## 6. DoD / acceptance criteria (for the banxe-emi-stack PR)

- [ ] `test_registry_lookup_delegated_via_port` (only `RegistryProviderPort` used; **no in-house registry scraping**; boundary test).
- [ ] `test_ubo_chain_resolution_over_25pct` (direct + indirect ownership; intermediate-entity recursion; >25% threshold from config, not hardcoded).
- [ ] `test_opaque_structure_triggers_edd` (circular/nominee/depth-limit ⇒ EDD step-up).
- [ ] `test_directors_and_ubos_routed_to_idv_and_faml` (each individual → A-idv/A-kyc + F-aml; A-kyb does neither itself).
- [ ] `test_business_risk_rating_config_driven` (jurisdiction/SIC/structure thresholds from config).
- [ ] `test_refer_and_high_risk_route_to_mlro_hitl` (HITL thresholds BUG-007; no autonomous borderline rejection).
- [ ] `test_kyb_gate_precondition_for_b_emi` (business account blocked until approved).
- [ ] `test_provider_unavailable_fails_closed` (no approval on incomplete registry/UBO resolution).
- [ ] `test_privacy_no_individual_pii_persisted` (no raw UBO/director PII stored Banxe-side; PII Proxy; redacted audit).
- [ ] Coverage ≥ 90%, Ruff + semgrep clean; provider-port boundaries respected; audit rows per ADR-027.

## 7. Perimeter

- **In:** business-onboarding *orchestration* — registry lookup (delegated), UBO chain resolution, director identification, business risk-rating/EDD, KYB decision/HITL, the handoff *contracts* to A-idv/A-kyc/F-aml/B-emi.
- **Out (fail-closed, §9):** individual KYC orchestration (A-kyc), IDV pipeline (A-idv), AML screening (F-aml), registry/screening provider internals, account creation (B-emi).
- **Plane:** spec only here; runtime in `banxe-emi-stack` is a separate operator-authorized action (§10).

## 8. PRIVACY/DELEGATION FENCE (registry + screening provider-delegated — fail-closed)

- A-kyb (and this build-spec) defines a **regulatory KYB process only**. It **does not** scrape registries, collect/store real business-owner/director PII, or process biometric/document data in-house.
- **Registry lookup** is **delegated** to a licensed data provider via `RegistryProviderPort`; **UBO/director sanctions/PEP screening** is **delegated** to F-aml; **individual identity verification** is **delegated** to A-idv/A-kyc (provider-side OCR/biometrics).
- Privacy-by-design is mandatory (§4): data minimisation, GDPR/UK-GDPR lawful basis, retention limits, no individual raw-PII persistence beyond redacted refs, PII Proxy (Presidio) per I-security.
- **Fail-closed:** if any requirement would require Banxe/the factory itself to scrape a registry or process individual biometric/document PII → **STOP + operator brief**; do not implement.

## 9. Out of scope (fail-closed)

No runtime code here; no cross-repo write into banxe-emi-stack; **no in-house registry scraping / business-owner PII processing** (provider-delegated, §8); **no individual KYC orchestration reimplementation** (A-kyc owns it); **no IDV pipeline / OCR / biometric processing** (A-idv + provider own it); **no AML/sanctions/PEP screening logic** (F-aml owns it); **no e-money account/IBAN creation** (B-emi); no autonomous rejection of borderline/high-risk cases (MLRO HITL); no individual raw-PII persistence beyond redacted refs.

## 10. Operator gates NOT crossed

- **Cross-repo runtime** — implementing A-kyb in `banxe-emi-stack` is a **separate operator-authorized action** (cross-repo write; NO write made here).
- **Registry/screening provider selection / activation** = config + **MLRO approval** per the delegation-port discipline — not done here.
- No passport activation; **PR #751 (s-fac-65) + PR #749 (dup-salvage) + PR #744 (M2.8 Roster-C) + Arch-WG DRAFTs untouched**.
- If any gate is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 11. References

`docs/architecture/A-KYC-BUILD-SPEC.md` (IL-500 — individual sibling; UBO/director individuals routed here);
`docs/architecture/A-IDV-BUILD-SPEC.md` (IL-501 — IDV pipeline for individuals);
`docs/refactor/legacy/kyc-provider-port-CONTRACT-SPEC-2026-06-06.md`, `kyc-provider-port-SPEC-2026-05-26.md` (delegation pattern — reused);
`docs/refactor/legacy/aml-patterns-SPEC-2026-06-06.md` (F-aml screening handoff);
`docs/architecture/B-EMI-BUILD-SPEC.md` (business onboarding → account gate);
`ROADMAP-MATRIX.md` (A-kyc / A-idv / A-kyb split); ADR-021 (PII routing), ADR-027 (audit trail), ADR-028 (re-verification), ADR-034 (webhook reliability), ADR-102/103/115/116/117/119; I-01/I-28; BUG-007 (HITL thresholds); CLAUDE.md §9/§10/§11; I-security (PII Proxy / Presidio).
