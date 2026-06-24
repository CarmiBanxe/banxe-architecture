# F-FATCA — FATCA/CRS Tax-Reporting Build-Spec (classification, due-diligence, reporting)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-25 · **Block:** F-fatca · **Priority:** P2 · **Sprint:** 11 · **Promotes:** the 0% (new tax-reporting definition; promotes the DAC8 tax-reporting snapshot).
**Plane:** banxe-architecture = docs/regulatory/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). This doc **specifies/defines the tax-reporting contract**; ships **no** runtime code and makes **no** cross-repo write.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103 (server-only refactor / promotion gate), ADR-059-A/ADR-119 (append-only frozen ledger). Additive; mutates no prior artifact.

> ⚠️ **SCOPE/PRIVACY FENCE (read §8 first).** F-fatca is a **regulatory tax-reporting process only** — FATCA/CRS
> due-diligence, account-holder classification, and reporting. It is **NOT** tax advice to customers and **NOT**
> financial advice. **Specification only**: the factory performs no live classification and files nothing. **No
> autonomous regulatory submission** — every filing is **HITL-gated**. Privacy-by-design for tax PII: GDPR/UK-GDPR
> lawful basis = **legal obligation** (Art.6(1)(c)), data minimisation, customer notification of data transfer,
> retention limits, PII Proxy (Presidio).

---

## 0. Duplication Audit (ADR-102)

| Artifact | Role | Decision |
|---|---|---|
| `docs/sessions/SNAPSHOT-2026-05-06-dac8-tax-reporting-block.md` | DAC8 / CRS 2.0 / CARF / FATCA regulatory inventory (BANXE = Reporting Financial Institution / SEMP) | **keep / PROMOTE** — this build-spec operationalises the snapshot's obligations into an actionable contract |
| `docs/architecture/A-KYC-BUILD-SPEC.md` (IL-500) | Individual KYC onboarding orchestration | **keep / REUSE** — onboarding **captures tax-residency self-certification**; F-fatca **consumes** it for classification. KYC **not** reimplemented |
| `docs/architecture/B-EMI-BUILD-SPEC.md` (IL-498) / `D-GL-BUILD-SPEC.md` (IL-484) | account/product catalogue + GL balances | **keep / REUSE** — F-fatca **reads** account + balance/payment data (reportable-account financials); product/GL logic **not** duplicated |
| `docs/regulatory/K-GABRIEL-BUILD-SPEC.md` (IL-480) | regulatory-returns **submission + governance** layer (`GabrielSubmissionPort`, idempotent, HITL, sandbox-first, `AuditPort`) | **keep / REUSE pattern** — F-fatca submission **reuses the submission-port + HITL + audit pattern**; the generic submission engine is **not** reimplemented |
| `docs/regulatory/F-FINRPT-BUILD-SPEC.md` (IL-481) | FIN-RPT prudential return **content** | **keep / reference** — sibling regulatory return; **distinct domain** (prudential ≠ tax). Not duplicated |

No existing `F-FATCA-BUILD-SPEC` / FATCA/CRS artifact on main (live audit: `find docs -iname '*fatca*'`/`*crs*` ⇒ empty; `ls docs/regulatory` ⇒ E-CAPITAL/F-FINRPT/K-FSCS/K-GABRIEL/K-NCA only). New file is **non-duplicative**; it **defines the tax-reporting contract** consuming onboarding + account data and reusing the submission pattern, it does not re-implement them.

## 1. Scope — FATCA/CRS tax reporting

F-fatca defines the **tax due-diligence + classification + reporting** layer; all rules are **config-as-data** (CLAUDE.md §10 — reportable jurisdictions, thresholds, deadlines, schema versions not hardcoded):

1. **Account-holder classification** — determine tax status: **FATCA** (US person / US TIN / FFI status, IGA Model 1/2) and **CRS** (tax-residency jurisdiction(s), Reportable Person, Active/Passive NFE + controlling persons). DAC8/CARF context for SEMP/crypto where in scope.
2. **Tax-residency self-certification capture** — F-fatca **requires** self-certification at onboarding (orchestrated by A-kyc); validates reasonableness against KYC data; cures indicia/conflicts (due-diligence).
3. **Reportable-account determination** — apply due-diligence (new vs pre-existing accounts; individual vs entity; de-minimis thresholds config-as-data) to mark accounts reportable per regime/jurisdiction.
4. **Reporting file generation** — produce **FATCA XML** (IRS schema, e.g. Form 8966 / FATCA XML) and **CRS XML** (OECD CRS 2.0 schema); validate against schema; per reporting period.
5. **Submission (HITL)** — file to the relevant tax authority (IRS / local competent authority for CRS/DAC8 exchange) **via the K-gabriel-style submission port**; **HITL sign-off mandatory** (no autonomous filing); customer notification of data transfer (GDPR Art.6(1)(c)).

**Out** of F-fatca: KYC capture/verification (A-kyc), product/account creation (B-emi), GL posting (D-gl), the generic submission engine (K-gabriel pattern), and any tax/financial advice to customers.

## 2. Data model (TaxClassification / ReportableAccount / SelfCertification)

Declarative, config-as-data; Decimal for monetary amounts (I-01); tax PII minimised (§6).

### 2.1 `SelfCertification`
- `cert_id`, `customer_ref` (pseudonymous), `regime` (`FATCA | CRS`), `declared_tax_residencies[]` (jurisdiction + TIN), `us_person` (bool), `entity_type` (`individual | active_NFE | passive_NFE | FFI`), `controlling_persons[]` (for passive NFE), `captured_at`, `source` (A-kyc onboarding handle).
- Captured at onboarding (A-kyc orchestrates); F-fatca validates reasonableness vs KYC indicia.

### 2.2 `TaxClassification`
- `classification_id`, `customer_ref`, `fatca_status` (`us_person | non_us | recalcitrant | FFI...`), `crs_reportable` (bool + reportable jurisdictions[]), `indicia[]` (US/other indicia found), `cure_status`, `classified_at`, `evidence_refs` (PII-redacted).

### 2.3 `ReportableAccount`
- `account_ref` (B-emi/D-gl account), `regime`, `reportable_jurisdictions[]`, `account_balance` (Decimal, period-end, from D-gl), `gross_payments` (Decimal, by type), `reporting_period`, `determination_basis` (new | pre-existing; threshold applied), `report_status` (`pending | included | filed`).

## 3. Reporting flow (consume onboarding + account data; submit HITL)

```
onboarding (A-kyc) → SelfCertification captured
  1. F-fatca classify: SelfCertification + KYC indicia → TaxClassification (FATCA + CRS)
  2. due-diligence: new vs pre-existing; cure indicia/conflicts; de-minimis thresholds (config)
  3. determine ReportableAccount: read account + balance/payments (B-emi/D-gl, period-end)
  4. generate reporting file: FATCA XML (IRS) + CRS XML (OECD CRS 2.0), schema-validated
  5. submit via K-gabriel-style submission port → tax authority (IRS / competent authority)
       → HITL sign-off MANDATORY (no autonomous filing); idempotent per reporting period
  6. customer notification of data transfer (GDPR Art.6(1)(c)); audit → ClickHouse (5Y, I-24/I-28)
```

- F-fatca **never** files autonomously — submission requires HITL sign-off (analogous to K-gabriel `submission_data_validated_and_signed_off`).
- Schema versions, reportable jurisdictions, thresholds, deadlines = **config-as-data** (no hardcode); missing/invalid self-cert ⇒ fail-closed (flag for remediation, not silent omission).

## 4. Submission + governance (reuse, not reimplement)

- **Submission** reuses the **K-gabriel submission pattern** (`GabrielSubmissionPort`-style): idempotent per reporting period, sandbox-first, append-only audit. A tax-specific `TaxSubmissionPort` conforms to the same contract; the generic submission engine is **not** reimplemented.
- **HITL on filing** — every submission gated by human sign-off (I-27 governance posture: no autonomous regulatory submission).
- **Deadlines** — config-as-data (FATCA: per IRS; CRS/DAC8: first reporting Jan–Jul 2027 per MS per snapshot); governor invariant `report_filed_before_deadline`.

## 5. DoD / acceptance criteria (for the banxe-emi-stack PR)

- [ ] `test_classification_from_self_cert_and_indicia` (FATCA US-person + CRS residency from SelfCertification + KYC indicia; cure logic).
- [ ] `test_self_cert_consumed_from_a_kyc` (self-cert sourced from onboarding; F-fatca does not capture KYC itself).
- [ ] `test_reportable_account_determination` (new vs pre-existing; de-minimis thresholds config-as-data; balance/payments from D-gl).
- [ ] `test_fatca_xml_and_crs_xml_schema_valid` (IRS FATCA XML + OECD CRS 2.0 XML validate against schema; schema version config).
- [ ] `test_submission_via_kgabriel_pattern` (uses submission-port pattern; **no generic submission engine reimplementation**; idempotent per period; boundary test).
- [ ] `test_filing_requires_hitl` (no autonomous submission; HITL sign-off mandatory).
- [ ] `test_customer_notification_on_transfer` (GDPR Art.6(1)(c) notification recorded).
- [ ] `test_privacy_tax_pii_minimised` (legal-obligation basis; PII via Proxy; redacted audit; retention config).
- [ ] `test_fail_closed_on_missing_self_cert` (flag for remediation; no silent omission).
- [ ] Coverage ≥ 90%, Ruff + semgrep clean; A-kyc/D-gl/K-gabriel boundaries respected; audit rows per ADR-027 (5Y).

## 6. Privacy-by-design (tax PII)

- **Lawful basis:** **legal obligation** (GDPR Art.6(1)(c) — FATCA/CRS/DAC8 reporting duty); documented.
- **Customer notification:** mandatory notice that tax data will be transferred to the tax authority (DAC8/GDPR).
- **Data minimisation:** only fields required by the FATCA/CRS schema; tax PII routed via **PII Proxy (Presidio)**; no PII in logs/audit beyond redacted evidence.
- **Retention:** per regulatory requirement (config-as-data); ClickHouse audit (5Y, I-24/I-28).

## 7. Producer/consumer contracts (referenced, not duplicated)

- **Consumes A-kyc** (`A-KYC-BUILD-SPEC` IL-500): tax-residency **self-certification** + KYC indicia at onboarding. A-kyc captures; F-fatca classifies. KYC **not** reimplemented.
- **Consumes B-emi / D-gl** (`B-EMI` IL-498 / `D-GL` IL-484): account identity + period-end balance + gross payments for reportable-account financials. Read-only; product/GL logic **not** reimplemented.
- **Submits via K-gabriel pattern** (`K-GABRIEL-BUILD-SPEC` IL-480): reuses submission-port + HITL + audit discipline; generic submission engine **not** reimplemented.
- **Sibling F-finrpt** (`F-FINRPT` IL-481): prudential returns — distinct domain; not duplicated.

## 8. SCOPE/PRIVACY FENCE (tax-reporting only — fail-closed)

- F-fatca (and this build-spec) defines a **regulatory tax-reporting process only** — **not** tax advice, **not** financial advice to customers.
- **Specification only:** the factory performs no live classification and files nothing.
- **No autonomous regulatory submission** — every filing is HITL-gated (human sign-off).
- Privacy-by-design (§6): legal-obligation lawful basis, data minimisation, customer notification, retention limits, PII Proxy.
- **Fail-closed:** if any requirement would have the factory give tax/financial advice, file autonomously, or process tax PII beyond the schema minimum → **STOP + operator brief**; do not implement.

## 9. Out of scope (fail-closed)

No runtime code here; no cross-repo write into banxe-emi-stack; **no live classification / no filing** (spec only, §8 fence); **no autonomous regulatory submission** (HITL only); **no KYC capture/verification reimplementation** (A-kyc owns it); **no product/account creation** (B-emi); **no GL posting** (D-gl); **no generic submission-engine reimplementation** (K-gabriel pattern reused); **no tax or financial advice to customers**; no processing of tax PII beyond the schema minimum; no silent omission of a reportable account (fail-closed remediation).

## 10. Operator gates NOT crossed

- **Cross-repo runtime** — implementing F-fatca in `banxe-emi-stack` is a **separate operator-authorized action** (cross-repo write; NO write made here).
- **Live filing / authority enrolment / production submission** = operator-authorized + HITL sign-off — not done here.
- No passport activation; no DRAFT promotion; no operator-gated PR touched; Arch-WG DRAFTs untouched.
- If any gate is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 11. References

`docs/sessions/SNAPSHOT-2026-05-06-dac8-tax-reporting-block.md` (DAC8/CRS/CARF/FATCA inventory — promoted);
`docs/architecture/A-KYC-BUILD-SPEC.md` (IL-500 — self-certification source);
`docs/architecture/B-EMI-BUILD-SPEC.md` (IL-498) / `docs/architecture/D-GL-BUILD-SPEC.md` (IL-484 — account/balance data);
`docs/regulatory/K-GABRIEL-BUILD-SPEC.md` (IL-480 — submission pattern reused);
`docs/regulatory/F-FINRPT-BUILD-SPEC.md` (IL-481 — sibling regulatory return);
DAC8 Council Directive (EU) 2023/2226; OECD CRS 2.0 + CARF; US FATCA / IGA Model 1/2 (IRS); GDPR Art.6(1)(c);
ADR-027 (audit), ADR-102/103/115/116/117/119; I-01/I-24/I-27/I-28; CLAUDE.md §9/§10/§11; PII Proxy (Presidio).
