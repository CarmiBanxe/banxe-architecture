# A-IDV — Identity Verification Pipeline Build-Spec (document OCR + biometric/liveness matching via licensed provider)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-24 · **Block:** A-idv · **Priority:** P1 · **Sprint:** 10 · **Promotes:** the 0% (new IDV-pipeline definition).
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). This doc **specifies/defines the pipeline contract**; ships **no** runtime code and makes **no** cross-repo write.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103 (server-only refactor / promotion gate), ADR-059-A/ADR-119 (append-only frozen ledger). Additive; mutates no prior artifact.

> ⚠️ **SAFETY/PRIVACY FENCE (read §8 first).** This is a **specification of a regulatory identity-verification process only**.
> Banxe performs **no** in-house OCR, facial recognition, liveness detection, or biometric matching, and collects/stores
> **no** raw facial/biometric/document data. **All** document-capture/OCR and biometric/liveness operations are
> **DELEGATED to a licensed third-party IDV provider** (SumSub primary, fallback adapter) **via the existing
> `KYCProviderPort`** (legacy contract — reused, not reimplemented). A-idv defines the **verification-result model,
> pass/fail/refer flow, and the A-kyc interface contract** — never an in-house biometric/OCR algorithm.

---

## 0. Duplication Audit (ADR-102)

| Artifact | Role | Decision |
|---|---|---|
| `docs/architecture/A-KYC-BUILD-SPEC.md` (IL-500) | KYC onboarding **orchestration** — `KYCCase`/`KYCDecision`, risk-rating, EDD, handoffs | **keep / REUSE boundary** — A-idv is the **verification pipeline A-kyc invokes**; A-kyc orchestrates, A-idv verifies. A-idv produces the `VerificationResult` A-kyc maps to a decision. **No A-kyc orchestration logic here** (ADR-102) |
| `docs/refactor/legacy/kyc-provider-port-CONTRACT-SPEC-2026-06-06.md` | Executable `KYCProviderPort` — `startSession`/`getStatus`/`handleWebhook`/`changeLevel`, SumSub primary + fallback, webhook reliability (DLQ/retry/HMAC), audit, idempotency | **keep / REUSE** — A-idv **consumes** this port for OCR/biometric delegation; **does NOT reimplement** it (ADR-102) |
| `docs/refactor/legacy/kyc-provider-port-SPEC-2026-05-26.md` | Parent SPEC #8 (KYCProviderPort origin) | **keep / reference** — port lineage |
| `docs/refactor/legacy/aml-patterns-SPEC-2026-06-06.md` | AML/sanctions/PEP screening (F-aml) | **keep / reference** — A-idv result feeds A-kyc, which hands off to F-aml; screening **not** duplicated |
| `ROADMAP-MATRIX.md` rows A-kyc / **A-idv** / A-kyb | onboarding block split | **keep** — A-idv = the IDV **pipeline**; A-kyc = orchestration; A-kyb = business KYB (separate) |

No existing `A-IDV-BUILD-SPEC` / A-idv pipeline artifact on main (live audit: `find docs -iname '*a-idv*'` ⇒ empty; `ls docs/architecture` ⇒ A-KYC/B-EMI/D-FEE/D-FIN/D-GL only). New file is **non-duplicative**; it **defines the verification pipeline contract** around the existing port, it does not re-implement the port or A-kyc.

> **Scope correction (supersedes legacy ROADMAP shorthand):** the ROADMAP `A-idv` description column reads *"Identity verification pipeline — OCR + biometric matching"* (historically associated with in-house PassportEye/DeepFace). Per the SAFETY FENCE (§8), **in-house OCR/biometric processing is OUT of scope** — OCR + biometric/liveness matching are **provider-delegated** via `KYCProviderPort`. The frozen description row is left unaltered (additive discipline); this spec is the authoritative scope.

## 1. Scope — identity-verification pipeline

A-idv defines the **verification-execution** layer A-kyc invokes; all operations are **config-as-data** (CLAUDE.md §10):

1. **Document capture + OCR (DELEGATED)** — the provider captures and OCRs the identity document (passport/ID/DL), checks authenticity/MRZ/security features. A-idv **does not** parse documents in-house.
2. **Biometric / liveness matching (DELEGATED)** — the provider performs face-match (selfie ↔ document portrait) + active/passive liveness. A-idv **does not** run any biometric model.
3. **Verification-result model** — A-idv normalises provider output into a `VerificationResult` (score, per-check breakdown, decision, evidence refs) — see §2.
4. **Pass / fail / refer flow** — A-idv resolves the provider checks into `pass | fail | refer`; `refer` routes to A-kyc for MLRO HITL (A-idv does not auto-reject borderline cases).
5. **A-kyc interface contract** — A-idv exposes the verification trigger + `VerificationResult` consumed by A-kyc orchestration (§6); it does **not** own the case/decision lifecycle.

**Out** of A-idv: the port internals, any OCR/biometric algorithm, A-kyc case/decision orchestration, AML screening (F-aml), business KYB (A-kyb), account creation (B-emi).

## 2. Verification-result model (VerificationResult)

Declarative, config-as-data; thresholds never hardcoded (CLAUDE.md §10); PII minimised (§4).

### 2.1 `VerificationResult`
- `verification_id`, `case_ref` (A-kyc `case_id` handle), `correlation_id`.
- `provider_ref`: `{ provider_session_id, provider_check_id }` — handle into `KYCProviderPort`; **no raw document/biometric data stored here** (provider-held, §4).
- `overall_decision`: `pass | fail | refer`.
- `score`: normalised confidence (config-driven thresholds map score → decision; no hardcoded cutoffs).
- `checks[]`: per-check breakdown — `{ check_type (doc_authenticity | mrz | face_match | liveness), result (pass|fail|inconclusive), provider_reason_code }` (provider-returned; PII-redacted).
- `evidence_refs`: pointers to provider-held evidence (FCA Section 4 evidence; PII-redacted per ADR-021); **raw images/biometrics never persisted Banxe-side**.
- `verified_at`, `expires_at` (re-verification clock, ADR-028).

### 2.2 Decision mapping (config-driven)
- `score ≥ pass_threshold` AND all critical checks `pass` ⇒ `pass`.
- any critical check `fail` ⇒ `fail`.
- inconclusive / borderline / provider `review` ⇒ `refer` → A-kyc MLRO HITL (BUG-007: AUTO >90% / REVIEW 70–90% / BLOCK <70%).
- Thresholds + critical-check set are **config-as-data**, governance-tunable, not code.

## 3. Provider-delegation flow (via KYCProviderPort — no in-house OCR/biometrics)

```
A-kyc orchestrator → A-idv pipeline (verification trigger for case_ref, tier)
  1. A-idv → KYCProviderPort.startSession(userId, tier, correlationId)  → provider web-SDK token
  2. customer completes provider capture flow  [PROVIDER does OCR + face-match + liveness]
  3. provider → webhook → KYCProviderPort.handleWebhook(payload, signature)  [HMAC-verified, idempotent, DLQ]
     (or A-idv polls KYCProviderPort.getStatus)  → provider KYCResult
  4. A-idv normalises provider result → VerificationResult{score, checks[], overall_decision, evidence_refs}
  5. A-idv returns VerificationResult → A-kyc  [A-kyc maps to KYCDecision; refer → MLRO HITL]
```

- A-idv **never** calls a provider HTTP API directly outside `KYCProviderPort`, and runs **no** OCR/biometric model — only the port operations. Port semantics (idempotency, webhook HMAC, DLQ/retry, error model `InvalidSignature`/`ProviderUnavailable`/`TierDowngradeBlocked`) are **inherited from the contract spec**, not redefined.
- `ProviderUnavailable` ⇒ A-idv returns no `pass` (fail-closed: no verification without provider confirmation); circuit-breaker per contract.

## 4. Privacy-by-design (GDPR / UK-GDPR)

- **Lawful basis:** legal obligation (MLR 2017 / AMLD — CDD) + contract necessity; consent for provider data sharing captured upstream by A-kyc (`consent_ref`).
- **Data minimisation:** A-idv stores **the normalised `VerificationResult` + provider/evidence refs only**. Raw documents, facial images, and biometric templates are **provider-held**, **never persisted in Banxe systems** beyond the provider boundary. `evidence_refs` point to provider-held, PII-redacted evidence (ADR-021).
- **PII Proxy (Presidio):** any PII transiting A-idv routes through the PII Proxy per I-security; no PII in logs/audit beyond redacted fields.
- **Retention:** verification/audit records 5 years (CASS 15 / AMLD); provider-held raw data governed by provider DPA — Banxe holds no raw biometric/document beyond the provider.
- **Right-to-erasure boundary:** subject to AML retention override (legal obligation) — documented, not silently honoured.

## 5. Audit & re-verification

- Every verification trigger + `VerificationResult` + decision-mapping emits an immutable audit record (`guardian_audit_events`, ADR-027; correlation_id, case_ref, decision, score, timestamp_utc; PII-redacted).
- Re-verification (expiry / tier change / A-kyc step-up) re-runs the pipeline via `KYCProviderPort.changeLevel`/`startSession` (ADR-028); A-idv produces a fresh `VerificationResult`, it does not own the schedule (A-kyc triggers).

## 6. Producer/consumer contracts (referenced, not duplicated)

- **Consumes `KYCProviderPort`** (`kyc-provider-port-CONTRACT-SPEC`): sole delegation surface for OCR + biometric/liveness. A-idv is a **consumer**; the port + adapters (SumSub primary, fallback) are **not** reimplemented.
- **Produces `VerificationResult` → A-kyc** (`A-KYC-BUILD-SPEC` §3): A-idv is the verification-execution layer; A-kyc maps the result to `KYCDecision` and owns case lifecycle + MLRO HITL. A-idv **does not** orchestrate cases or screen AML.
- **Indirect to F-aml:** screening is triggered by A-kyc on `pass`, not by A-idv. A-idv produces the verification result only; F-aml screening is **not** duplicated.

## 7. DoD / acceptance criteria (for the banxe-emi-stack PR)

- [ ] `test_verification_delegated_via_port_only` (only `KYCProviderPort` ops called; **no in-house OCR/biometric code path**; boundary test).
- [ ] `test_verification_result_normalises_provider_output` (provider KYCResult → `VerificationResult`; per-check breakdown; PII-redacted reason codes).
- [ ] `test_decision_mapping_config_driven` (score/critical-check thresholds from config, not hardcoded; pass/fail/refer).
- [ ] `test_refer_routes_to_a_kyc_hitl` (borderline/inconclusive ⇒ refer; no autonomous A-idv rejection; BUG-007).
- [ ] `test_result_returned_to_a_kyc` (A-idv produces `VerificationResult`; does not create `KYCDecision` or `KYCCase`).
- [ ] `test_provider_unavailable_fails_closed` (no `pass` on `ProviderUnavailable`).
- [ ] `test_privacy_no_raw_document_or_biometric_persisted` (no raw doc/facial/biometric data stored Banxe-side; PII Proxy routing; redacted audit; evidence_refs provider-held).
- [ ] `test_reverification_produces_fresh_result` (re-run via port; ADR-028).
- [ ] Coverage ≥ 90%, Ruff + semgrep clean; KYCProviderPort boundary respected; audit rows per ADR-027.

## 8. SAFETY/PRIVACY FENCE (OCR + biometrics provider-delegated — fail-closed)

- A-idv (and this build-spec) defines a **regulatory identity-verification process only**. It **does not** perform, simulate, or implement OCR, facial recognition, liveness detection, or biometric matching, and **does not** collect, store, or process any facial, biometric, or raw document data in-house.
- **All** OCR + biometric/liveness operations are **delegated to a licensed third-party IDV provider** via `KYCProviderPort` (SumSub primary + fallback). The spec defines the **port contract consumption, verification-result model, and data-flow only**.
- Privacy-by-design is mandatory (§4): data minimisation, GDPR/UK-GDPR lawful basis, retention limits, no raw biometric/document persistence beyond the provider, consent capture (upstream A-kyc), PII Proxy (Presidio) per I-security.
- **Fail-closed:** if any requirement would require Banxe/the factory itself to process biometric/facial/document data → **STOP + operator brief**; do not implement.

## 9. Out of scope (fail-closed)

No runtime code here; no cross-repo write into banxe-emi-stack; **no in-house OCR / biometric / facial / liveness processing** (provider-delegated, §8); **no `KYCProviderPort` reimplementation** (reused); **no A-kyc case/decision orchestration** (A-kyc owns it); **no AML/sanctions/PEP screening** (F-aml owns it); **no business KYB** (A-kyb); **no e-money account/IBAN creation** (B-emi); no autonomous rejection of borderline cases (refer → A-kyc MLRO HITL); no raw-PII/document persistence beyond redacted evidence refs.

## 10. Operator gates NOT crossed

- **Cross-repo runtime** — implementing A-idv in `banxe-emi-stack` is a **separate operator-authorized action** (cross-repo write; NO write made here).
- **Provider selection / activation** (SumSub vs fallback) = config + **MLRO approval** per the port contract — not done here.
- No passport activation; **PR #744 (M2.8 Roster-C) + Arch-WG DRAFTs untouched**.
- If any gate is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 11. References

`docs/architecture/A-KYC-BUILD-SPEC.md` (IL-500 — orchestration sibling; consumes A-idv result);
`docs/refactor/legacy/kyc-provider-port-CONTRACT-SPEC-2026-06-06.md`, `kyc-provider-port-SPEC-2026-05-26.md` (KYCProviderPort — consumed, reused);
`docs/refactor/legacy/aml-patterns-SPEC-2026-06-06.md` (F-aml screening, via A-kyc handoff);
`ROADMAP-MATRIX.md` (A-kyc / A-idv / A-kyb split); ADR-021 (KYCProviderPort + PII routing), ADR-027 (audit trail), ADR-028 (re-verification), ADR-034 (webhook reliability), ADR-102/103/115/116/117/119; I-01/I-28; BUG-007 (HITL thresholds); CLAUDE.md §9/§10/§11; I-security (PII Proxy / Presidio).
