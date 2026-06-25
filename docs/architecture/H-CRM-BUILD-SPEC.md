# H-CRM — Customer Record + Case History + DSAR Build-Spec

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-25 · **Block:** H-crm · **Priority:** P2 · **Sprint:** 12 · **Promotes:** the 0% (new CRM + DSAR definition).
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). This doc **specifies/defines the CRM + DSAR contract**; ships **no** runtime code and makes **no** cross-repo write.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103 (server-only refactor / promotion gate), ADR-059-A/ADR-119 (append-only frozen ledger). Additive; mutates no prior artifact.

> ⚠️ **PRIVACY/DSAR FENCE (read §8 first).** H-crm is a **specification of a CRM + DSAR process only** — the
> factory collects/stores/processes **no** real customer PII; it defines the contract. **DSAR** = data-subject
> rights fulfilment (GDPR/UK-GDPR Art.15–22: access, rectification, erasure, portability) — a **legitimate
> customer right**, with **SLA (1 month)**, **identity verification before disclosure**, and **scope limits**.
> Privacy-by-design: lawful basis per purpose, data minimisation, retention limits, **purpose limitation** (NO
> profiling beyond service/compliance need, NO secondary use, NO surveillance), PII Proxy (Presidio), audit of
> every access.

---

## 0. Duplication Audit (ADR-102)

| Artifact | Role | Decision |
|---|---|---|
| `docs/refactor/legacy/crm-port-CONTRACT-SPEC-2026-06-06.md` (CRMPort / `CRMProviderPort`) | Frozen provider-facing CRM port — `getUser`/`updateUserTier`/`registerReferral`/`resolveReferralCode`, idempotent + audited (ADR-021/027) | **keep / REUSE** — H-crm **consumes** this port for provider-facing CRM ops (user/tier/referral); **does NOT reimplement** it (ADR-102) |
| `docs/architecture/A-KYC-BUILD-SPEC.md` (IL-500) / `A-KYB-BUILD-SPEC.md` (IL-502) | onboarding — individual/business identity capture | **keep / REUSE** — onboarding is the **source** of the customer/business record; H-crm builds the golden record over it. KYC/KYB **not** reimplemented |
| `ROADMAP-MATRIX.md` H-support row | support ticketing, escalation, SLA tracking (sibling) | **keep / FENCE** — **H-support owns the ticket lifecycle**; H-crm aggregates **case history** (customer-centric view, referencing support cases). Ticketing **not** duplicated |
| `ROADMAP-MATRIX.md` I-security | PII Proxy (Presidio) + Keycloak IAM | **keep / REUSE** — H-crm **integrates** PII Proxy (PII redaction) + IAM (access control); **does NOT reimplement** PII infra/IAM |

No existing `H-CRM-BUILD-SPEC` / CRM artifact on main (live audit: `find docs -iname '*h-crm*'`/`*crm*BUILD*` ⇒ empty; `ls docs/architecture` has A-*/B-*/D-*/E-TREASURY/G-*/I-API). New file is **non-duplicative**; it orchestrates the golden record + case history + DSAR over the reused CRMPort + onboarding sources, it does not re-implement them.

## 1. Scope — customer record, case history, DSAR fulfilment

H-crm defines three layers; all policy is **config-as-data** (CLAUDE.md §10):

1. **Customer record (golden record)** — a single customer-centric view: identity ref (from A-kyc/A-kyb), linkage to accounts/products (B-emi), tier/attributes (via `CRMProviderPort`), contact + consent state. **Linkage by reference** — H-crm does not re-store KYC documents or account balances; it links.
2. **Case history** — chronological log of customer interactions (onboarding events, support cases referenced from **H-support**, DSAR requests, compliance touchpoints) as an **audit trail**. H-crm aggregates the customer-centric view; H-support owns ticket workflow.
3. **DSAR fulfilment** — orchestrate data-subject rights (GDPR/UK-GDPR Art.15–22): **access** (Art.15), **rectification** (Art.16), **erasure** (Art.17), **portability** (Art.20), plus restriction/objection (Art.18/21) — with **SLA**, **identity verification**, **scope limits**, and **HITL on erasure**.

**Out** of H-crm: KYC/KYB capture (A-kyc/A-kyb), support ticketing workflow (H-support), PII-redaction/IAM infrastructure (I-security), account/product definitions (B-emi), provider CRM port internals (CRMPort).

## 2. Data model (CustomerRecord / CaseHistory / DSARRequest)

Declarative, config-as-data; PII minimised (§6); identity refs are pseudonymous.

### 2.1 `CustomerRecord`
- `customer_id` (golden id), `identity_ref` (A-kyc/A-kyb handle — not raw PII), `linked_accounts[]` (B-emi refs), `tier` (via `CRMProviderPort.get_user`), `attributes`, `contact_ref`, `consent_state` (per purpose), `created_at`, `updated_at`.

### 2.2 `CaseHistory`
- `case_id`, `customer_id`, `event_type` (`onboarding | support | dsar | compliance | tier_change`), `source` (`a-kyc | h-support | h-crm | f-aml | …`), `summary` (PII-redacted), `occurred_at`, `correlation_id`. Append-only audit trail (I-28).

### 2.3 `DSARRequest`
- `dsar_id`, `customer_id`, `right` (`access | rectification | erasure | portability | restriction | objection`), `state` (see §3), `received_at`, `sla_due_at` (received + 1 month, config), `identity_verified` (bool + method), `scope` (categories in/out), `reviewed_by` (HITL for erasure), `fulfilled_at`, `evidence_refs` (PII-redacted), `legal_hold` (AML/retention override flag).

## 3. DSAR workflow (request → verify → collect → review → fulfil)

```
DSAR received → DSARRequest(state: RECEIVED, sla_due = +1 month)
  1. IDENTITY VERIFY: verify requester is the data subject (before ANY disclosure) → VERIFIED | REJECTED
  2. SCOPE: determine in-scope data categories (config); exclude third-party PII + legally-withheld data
  3. COLLECT: gather references across sources (CustomerRecord links, CaseHistory, A-kyc, B-emi, F-aml) — by reference, PII via Proxy
  4. REVIEW (HITL): for ERASURE, mandatory human review — reconcile vs legal-obligation retention (AML/CASS/tax);
       legal_hold ⇒ erasure refused/deferred with documented reason (not silently honoured)
  5. FULFIL: produce response within SLA — access pack / rectified record / erasure confirmation / portable export (machine-readable)
  6. AUDIT: every step + every access logged (ADR-027); notify customer
```

- **Identity verification is mandatory before disclosure** (no data released to an unverified requester).
- **Erasure is HITL** and **fail-closed against legal retention**: AML (5y), CASS, tax (F-fatca) retention overrides erasure — documented refusal/deferral, never a silent delete of records under legal hold.
- **SLA = 1 month** (config-as-data; extendable per Art.12(3) with notice); breach risk flagged.

## 4. CRM provider delegation (CRMPort — reused, not reimplemented)

- Provider-facing CRM ops (`get_user`, `update_user_tier`, `register_referral`, `resolve_referral_code`) go through the frozen **`CRMProviderPort`** (CRMPort CONTRACT, ADR-021) — idempotent, audited (ADR-027). H-crm **consumes**; the port + `ReferralCRMAdapter` are **not** reimplemented.
- The golden record references provider attributes/tier; H-crm does not duplicate the provider's referral/tier logic.

## 5. Producer/consumer contracts (referenced, not duplicated)

- **Consumes A-kyc/A-kyb** (IL-500/IL-502): identity ref as the source of the customer/business record. Onboarding owns capture; H-crm links.
- **Consumes/links H-support** (sibling): support cases referenced into `CaseHistory`. H-support owns ticket lifecycle/SLA; H-crm presents the customer-centric history.
- **Consumes `CRMProviderPort`** (CRMPort CONTRACT): user/tier/referral; not reimplemented.
- **Integrates I-security**: PII Proxy (Presidio) for any PII in records/DSAR responses; IAM for access control. Not reimplemented.
- **Links B-emi**: account/product references on the golden record; account logic not duplicated.

## 6. Privacy-by-design (GDPR / UK-GDPR)

- **Lawful basis per purpose:** contract (service), legal obligation (AML/CASS/tax), legitimate interest (fraud/security) — recorded per processing purpose; DSAR itself is a legal obligation.
- **Data minimisation + purpose limitation:** golden record links by reference; **no profiling beyond service/compliance need, no secondary use, no surveillance**.
- **Retention limits:** per category, config-as-data; retention overrides erasure where legally required (§3).
- **PII Proxy (Presidio):** all PII in records/case history/DSAR responses routed via the proxy; no PII in logs/audit beyond redacted fields.
- **Audit of access:** every read/disclosure of a customer record + every DSAR step logged (ADR-027, 5Y per I-24/I-28).

## 7. DoD / acceptance criteria (for the banxe-emi-stack PR)

- [ ] `test_golden_record_links_not_restore` (record links to A-kyc/B-emi refs; does not re-store KYC docs/balances; boundary test).
- [ ] `test_crm_provider_ops_via_port` (user/tier/referral via `CRMProviderPort`; **no port reimplementation**; idempotent/audited).
- [ ] `test_case_history_append_only` (interactions append-only; support cases referenced from H-support, not duplicated; I-28).
- [ ] `test_dsar_identity_verification_before_disclosure` (no data released to unverified requester).
- [ ] `test_dsar_access_within_sla` (access pack produced ≤ 1 month; SLA config-as-data).
- [ ] `test_dsar_erasure_hitl_and_legal_hold` (erasure HITL; AML/CASS/tax retention overrides → documented refusal/deferral, no silent delete).
- [ ] `test_dsar_portability_machine_readable` (portable export in a structured, machine-readable format).
- [ ] `test_dsar_scope_excludes_third_party_pii` (scope limits; third-party/withheld data excluded).
- [ ] `test_privacy_pii_via_proxy_and_audit` (PII via Proxy; every access audited; no secondary use).
- [ ] Coverage ≥ 90%, Ruff + semgrep clean; A-kyc/H-support/I-security/CRMPort boundaries respected; audit rows per ADR-027.

## 8. PRIVACY/DSAR FENCE (CRM + DSAR only — fail-closed)

- H-crm (and this build-spec) defines a **CRM + DSAR process only**. The factory collects/stores/processes **no** real customer PII; it defines the contract.
- **DSAR is a legitimate customer right** (Art.15–22) with SLA (1 month), mandatory identity verification before disclosure, and scope limits.
- Privacy-by-design (§6): lawful basis per purpose, data minimisation, retention limits, **purpose limitation — no profiling beyond service/compliance, no secondary use, no surveillance**, PII Proxy (Presidio), audit of access.
- **Fail-closed:** if any requirement would enable profiling/secondary-use/surveillance, disclosure without identity verification, or erasure of records under legal hold → **STOP + operator brief**; do not implement.

## 9. Out of scope (fail-closed)

No runtime code here; no cross-repo write into banxe-emi-stack; **no KYC/KYB capture reimplementation** (A-kyc/A-kyb own it); **no support ticketing workflow** (H-support owns the ticket lifecycle/escalation/SLA); **no PII-infrastructure / IAM reimplementation** (I-security owns PII Proxy + Keycloak); **no `CRMProviderPort` reimplementation** (reused); **no account/product definitions** (B-emi); **no profiling beyond service/compliance need, no secondary use, no surveillance, no marketing analytics**; no DSAR disclosure without identity verification; no erasure overriding legal-retention obligations.

## 10. Operator gates NOT crossed

- **Cross-repo runtime** — implementing H-crm in `banxe-emi-stack` is a **separate operator-authorized action** (cross-repo write; NO write made here).
- **Live DSAR fulfilment / production customer-data access** = operator-authorized + DPO/HITL oversight — not done here.
- No passport activation; no DRAFT promotion; no operator-gated PR touched; Arch-WG DRAFTs untouched.
- If any gate is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 11. References

`docs/refactor/legacy/crm-port-CONTRACT-SPEC-2026-06-06.md` (CRMPort / `CRMProviderPort` — consumed, reused);
`docs/architecture/A-KYC-BUILD-SPEC.md` (IL-500) / `A-KYB-BUILD-SPEC.md` (IL-502 — customer/business record source);
`ROADMAP-MATRIX.md` (H-support sibling, I-security, B-emi rows);
GDPR/UK-GDPR Art.12–22 (DSAR rights, SLA); ADR-021 (CRMPort + PII routing), ADR-027 (audit trail), ADR-102/103/115/116/117/119; I-24/I-28; CLAUDE.md §9/§10/§11; I-security (PII Proxy / Presidio, Keycloak IAM).
