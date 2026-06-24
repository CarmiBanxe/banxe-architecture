# A-KYC — Individual KYC Onboarding Orchestration Build-Spec (document verification + liveness via licensed provider)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-24 · **Block:** A-kyc · **Priority:** P1 · **Sprint:** 10 · **Promotes:** the 0% (new onboarding-orchestration definition).
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). This doc **specifies/orchestrates**; ships **no** runtime code and makes **no** cross-repo write.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103 (server-only refactor / promotion gate), ADR-059-A/ADR-119 (append-only frozen ledger). Additive; mutates no prior artifact.

> ⚠️ **SAFETY/PRIVACY FENCE (read §8 first).** This is a **specification of a regulatory KYC process only**.
> Banxe performs **no** in-house facial recognition, liveness detection, or biometric matching, and collects/stores
> **no** raw facial/biometric data. **All** document-verification, liveness, and biometric operations are
> **DELEGATED to a licensed third-party KYC/IDV provider** (SumSub primary, fallback adapter) **via the existing
> `KYCProviderPort`** (legacy contract — reused, not reimplemented). A-kyc defines the **orchestration, case/decision
> model, and port-consumption contract** — never an in-house biometric algorithm.

---

## 0. Duplication Audit (ADR-102)

| Artifact | Role | Decision |
|---|---|---|
| `docs/refactor/legacy/kyc-provider-port-CONTRACT-SPEC-2026-06-06.md` | Executable `KYCProviderPort` contract — `startSession`/`getStatus`/`handleWebhook`/`changeLevel`, SumSub primary + fallback, webhook reliability (DLQ/retry/HMAC), audit, idempotency | **keep / REUSE** — A-kyc **consumes** this port; **does NOT reimplement** it or its biometrics (ADR-102) |
| `docs/refactor/legacy/kyc-provider-port-SPEC-2026-05-26.md` | Parent SPEC #8 (KYCProviderPort origin) | **keep / reference** — port lineage |
| `docs/refactor/legacy/aml-patterns-SPEC-2026-06-06.md` | AML/sanctions/PEP screening patterns (F-aml) | **keep / reference** — A-kyc **hands off** to F-aml screening; AML logic **not** duplicated |
| `docs/architecture/B-EMI-BUILD-SPEC.md` (IL-498) | EMI product catalogue; account opening | **keep / reference** — A-kyc approval is the **gate** before B-emi account creation; account logic **not** duplicated |
| `docs/canon/g-kyc-01` / `g-kyc-03` audits (if present) | KYC governance audits | **keep / reference** — governance anchors |
| `ROADMAP-MATRIX.md` rows A-kyc / **A-idv** / A-kyb | onboarding block split | **keep** — A-kyc = KYC **orchestration**; **A-idv** (OCR + biometric matching pipeline) is a **separate sibling block**, also provider-delegated — not duplicated here; A-kyb = business KYB (separate) |

No existing `A-KYC-BUILD-SPEC` / A-kyc orchestration artifact on main (live audit: `find docs -iname '*a-kyc*'` ⇒ empty; `ls docs/architecture` ⇒ B-EMI/D-FEE/D-FIN/D-GL only). New file is **non-duplicative**; it **orchestrates** around the existing port, it does not re-implement it.

> **Scope correction (supersedes legacy ROADMAP shorthand):** the ROADMAP `A-kyc` description column historically reads *"document verification, liveness check (PassportEye, DeepFace)"*. Per the SAFETY FENCE (§8), **in-house PassportEye/DeepFace biometric processing is OUT of scope** — document verification + liveness are **provider-delegated** via `KYCProviderPort`. The frozen description row is left unaltered (additive discipline); this spec is the authoritative scope.

## 1. Scope — individual KYC onboarding orchestration

A-kyc orchestrates the **individual customer** KYC journey; all operations are **config-as-data** (CLAUDE.md §10):

1. **Onboarding orchestration** — initiate a KYC case for a customer at a required `KYCTier`, drive it through provider verification, and resolve a decision.
2. **Document verification + liveness (DELEGATED)** — `startSession` on `KYCProviderPort` issues the provider web-SDK token; the **provider** performs document OCR, authenticity, liveness, and biometric match; results return via `getStatus` / `handleWebhook`. **No in-house biometrics.**
3. **KYC case/decision model** — `KYCCase` lifecycle + `KYCDecision` (approve/reject/review) derived from provider `KYCResult` + risk-rating.
4. **Risk-rating + step-up / EDD** — risk score drives tier requirement; high-risk ⇒ Enhanced Due Diligence (EDD) step-up (tier upgrade via `changeLevel`).
5. **Sanctions/PEP handoff to F-aml** — on provider approval, hand the verified identity to **F-aml** for sanctions/PEP/adverse-media screening (A-kyc does not screen itself).
6. **Ongoing-monitoring trigger** — schedule re-verification (ADR-028) + periodic re-screening triggers; emits events, does not perform the screen.

**Out** of A-kyc: the port internals, any biometric algorithm, AML screening logic (F-aml), the OCR/biometric-matching pipeline (A-idv sibling), business KYB (A-kyb), account creation (B-emi).

## 2. Data model (KYCCase / KYCDecision)

Declarative, config-as-data; money/threshold values never hardcoded (CLAUDE.md §10); PII minimised (§4).

### 2.1 `KYCCase`
- `case_id`, `customer_id` (pseudonymous ref — not raw PII), `required_tier` (`none|basic|intermediate|full`, per `KYCTier`), `state` (see §3), `risk_rating` (§5), `correlation_id`.
- `provider_ref`: `{ provider_session_id, provider_level_id }` — the handle into `KYCProviderPort`; **no raw documents/biometrics stored here** (provider-held, §4).
- `consent_ref`: lawful-basis + consent capture record (§4).
- `created_at`, `updated_at`, `expires_at` (re-verification clock, ADR-028).

### 2.2 `KYCDecision`
- `decision_id`, `case_id`, `outcome` (`approved|rejected|review`), `decision_tier`, `reasons[]` (mapped from provider `rejectReasons`, PII-redacted), `decided_by` (`provider_auto` | `mlro_hitl`), `decided_at`.
- HITL: `review` and all `reject` of high-risk cases route to **MLRO** per HITL thresholds (BUG-007: AUTO >90% / REVIEW 70–90% / BLOCK <70%); no autonomous rejection of a borderline case.
- Every decision + state transition = immutable audit record (`guardian_audit_events`, ADR-027; 5-year retention, CASS 15/AMLD).

## 3. Provider-delegation flow (via KYCProviderPort — no in-house biometrics)

```
customer → A-kyc orchestrator
  1. open KYCCase(required_tier)            [state: not_started → pending]
  2. KYCProviderPort.startSession(userId, tier, correlationId)  → web-SDK token
  3. customer completes provider flow        [provider does OCR + liveness + biometric match]
  4. provider → webhook → KYCProviderPort.handleWebhook(payload, signature)  [HMAC-verified, idempotent, DLQ]
     (or poll KYCProviderPort.getStatus)     → KYCResult{status, tier, rejectReasons}
  5. A-kyc maps KYCResult → KYCDecision       [approved | rejected | review→MLRO HITL]
  6. on approved → handoff to F-aml (sanctions/PEP/adverse-media screening)
  7. on F-aml clear + approved → onboarding gate satisfied → B-emi account creation eligible
  8. step-up (EDD) → KYCProviderPort.changeLevel(userId, higher_tier)  [re-verification, ADR-028]
```

- A-kyc **never** calls a provider HTTP API directly nor runs any biometric model — only the four `KYCProviderPort` operations. Port semantics (idempotency, webhook HMAC, DLQ/retry, error model `InvalidSignature`/`ProviderUnavailable`/`TierDowngradeBlocked`) are **inherited from the contract spec**, not redefined.
- `ProviderUnavailable` ⇒ case stays `pending` on last-known status (fail-closed: no approval without provider confirmation); circuit-breaker per contract.

## 4. Privacy-by-design (GDPR / UK-GDPR)

- **Lawful basis:** legal obligation (MLR 2017 / AMLD — CDD) + contract necessity; recorded per case (`consent_ref`). Explicit consent captured for provider data sharing.
- **Data minimisation:** A-kyc stores **pseudonymous refs + decision metadata only**. Raw identity documents, facial images, and biometric templates are **held by the provider**, **never persisted in Banxe systems** beyond the provider boundary. `KYCResult.raw` retained only as PII-redacted FCA evidence (ADR-021 PII routing).
- **PII Proxy (Presidio):** any PII transiting A-kyc is routed through the PII Proxy per I-security; no PII in logs/audit beyond redacted fields.
- **Retention:** decision/audit records 5 years (CASS 15 / AMLD); provider-held raw data governed by provider DPA — Banxe holds no raw biometric beyond provider.
- **Right-to-erasure boundary:** subject to AML retention override (legal obligation) — documented, not silently honoured.

## 5. Risk-rating, step-up / EDD, ongoing monitoring

- **Risk-rating:** config-driven scoring (geography, product, PEP-likelihood, channel) → `risk_rating`; thresholds in config (CLAUDE.md §10), not code.
- **Tiering:** `risk_rating` → `required_tier`; standard ⇒ basic/intermediate; high-risk ⇒ `full` + **EDD step-up** via `changeLevel` (re-verification, ADR-028).
- **Ongoing monitoring:** A-kyc emits re-verification + periodic re-screening **triggers** (expiry clock, tier change, F-aml hit) — it schedules/handoffs; F-aml performs the screen.

## 6. Producer/consumer contracts (referenced, not duplicated)

- **Consumes `KYCProviderPort`** (`docs/refactor/legacy/kyc-provider-port-CONTRACT-SPEC`): the sole delegation surface for document/liveness/biometric verification. A-kyc is a **consumer**; the port + its adapters (SumSub primary, fallback) are **not** reimplemented.
- **Feeds F-aml** (`aml-patterns-SPEC`): on approval, hands verified identity for sanctions/PEP/adverse-media screening. A-kyc **produces** the screening trigger; F-aml **owns** the screen (not duplicated).
- **Gates B-emi onboarding** (`B-EMI-BUILD-SPEC` IL-498): a passed KYC decision (+ F-aml clear) is the **precondition** for e-money account creation/IBAN allocation. A-kyc produces the gate; B-emi owns account/IBAN (not duplicated).
- **Sibling A-idv:** OCR + biometric-matching pipeline is a **separate block** (also provider-delegated); A-kyc references provider IDV results, does **not** reimplement the pipeline.

## 7. DoD / acceptance criteria (for the banxe-emi-stack PR)

- [ ] `test_kyc_case_lifecycle` (not_started→pending→approved/rejected/review; expiry clock per ADR-028).
- [ ] `test_verification_delegated_via_port_only` (only the four `KYCProviderPort` ops called; **no in-house biometric/OCR code path**; boundary test).
- [ ] `test_decision_maps_provider_result` (KYCResult → KYCDecision; rejectReasons PII-redacted).
- [ ] `test_review_and_high_risk_reject_route_to_mlro_hitl` (HITL thresholds BUG-007; no autonomous borderline rejection).
- [ ] `test_approved_triggers_faml_handoff` (screening trigger emitted; A-kyc does not screen).
- [ ] `test_kyc_gate_precondition_for_b_emi` (account creation blocked until approved + F-aml clear).
- [ ] `test_provider_unavailable_fails_closed` (no approval on `ProviderUnavailable`; stays pending last-known).
- [ ] `test_edd_step_up_via_changelevel` (high-risk ⇒ tier upgrade + re-verification).
- [ ] `test_privacy_no_raw_biometric_persisted` (no raw facial/biometric data stored Banxe-side; PII Proxy routing; redacted audit).
- [ ] Coverage ≥ 90%, Ruff + semgrep clean; LedgerPort/KYCProviderPort boundaries respected; audit rows per ADR-027.

## 8. SAFETY/PRIVACY FENCE (biometrics provider-delegated — fail-closed)

- A-kyc (and this build-spec) defines a **regulatory KYC process only**. It **does not** perform, simulate, or implement facial recognition, liveness detection, or biometric matching, and **does not** collect, store, or process any facial or biometric data in-house.
- **All** biometric/liveness/document-verification operations are **delegated to a licensed third-party provider** via `KYCProviderPort` (SumSub primary + fallback). The spec defines the **port contract consumption + data-flow only**.
- Privacy-by-design is mandatory (§4): data minimisation, GDPR/UK-GDPR lawful basis, retention limits, no raw biometric persistence beyond the provider, consent capture, PII Proxy (Presidio) per I-security.
- **Fail-closed:** if any requirement would require Banxe/the factory itself to process biometric/facial data → **STOP + operator brief**; do not implement.

## 9. Out of scope (fail-closed)

No runtime code here; no cross-repo write into banxe-emi-stack; **no in-house biometric/facial/liveness processing** (provider-delegated, §8); **no `KYCProviderPort` reimplementation** (reused); **no AML/sanctions/PEP screening logic** (F-aml owns it); **no OCR/biometric-matching pipeline** (A-idv sibling); **no business KYB** (A-kyb); **no e-money account/IBAN creation** (B-emi); no autonomous rejection of borderline/high-risk cases (MLRO HITL); no raw-PII persistence beyond redacted evidence.

## 10. Operator gates NOT crossed

- **Cross-repo runtime** — implementing A-kyc in `banxe-emi-stack` is a **separate operator-authorized action** (cross-repo write; NO write made here).
- **Provider selection / activation** (SumSub vs fallback) = config + **MLRO approval** per the port contract — not done here.
- No passport activation; **PR #744 (M2.8 Roster-C) + Arch-WG DRAFTs untouched**.
- If any gate is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 11. References

`docs/refactor/legacy/kyc-provider-port-CONTRACT-SPEC-2026-06-06.md`, `kyc-provider-port-SPEC-2026-05-26.md` (KYCProviderPort — consumed, reused);
`docs/refactor/legacy/aml-patterns-SPEC-2026-06-06.md` (F-aml screening consumer);
`docs/architecture/B-EMI-BUILD-SPEC.md` (onboarding → account gate);
`ROADMAP-MATRIX.md` (A-kyc / A-idv / A-kyb split); ADR-021 (KYCProviderPort + PII routing), ADR-027 (audit trail), ADR-028 (KYC re-verification), ADR-034 (webhook reliability), ADR-102/103/115/116/117/119; I-01/I-28; BUG-007 (HITL thresholds); CLAUDE.md §9/§10/§11 (governance, config-as-data, fund/PII-state gate); I-security (PII Proxy / Presidio).
