# K-FSCS — FSCS Reporting Build-Spec (Single Customer View + eligible deposits + scheme return)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-23 · **Block:** K-fscs · **Priority:** P1 · **Deadline:** Q3 2026
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). This doc **specifies**; ships **no** runtime code and makes **no** cross-repo write.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103, ADR-059-A/ADR-119. Additive; mutates no prior artifact.

> K-fscs is **FSCS-specific reporting** — Single Customer View (SCV) file, eligible-deposit classification,
> and compensation-scheme return. It **consumes** customer + balance data from D-gl and **reuses
> K-gabriel's submission/governance layer** for any regulatory submit. It does **not** reimplement the GL
> (D-gl) or the generic FCA Gabriel/RegData submission engine (K-gabriel).

---

## 0. Duplication Audit (ADR-102)
| Artifact | Role | Decision |
|---|---|---|
| `docs/regulatory/K-GABRIEL-BUILD-SPEC.md` | generic FCA submission/governance (`GabrielSubmissionPort`, `ReturnsGovernor`, `AuditPort`) | **keep / reuse** — K-fscs submits **via** this layer; does NOT re-author it |
| `docs/architecture/D-GL-BUILD-SPEC.md` | GL customer accounts + balances (`LedgerPort.get_balance`) | **keep / reference** — K-fscs derives SCV balances; does NOT reimplement GL |
| `docs/regulatory/F-FINRPT-BUILD-SPEC.md` | FIN-RPT return content | **keep** — sibling reporting; FSCS scheme-return is distinct content |
| `docs/safeguarding/E-SAFEGUARD-CASS15-SPEC.md` | safeguarded e-money | **keep / reference** — safeguarded e-money classification drives FSCS *eligibility* (§2.2) |
No existing K-fscs / SCV build-spec on main → new file non-duplicative.

## 1. Boundary (K-fscs vs K-gabriel vs D-gl) — drift reconciled
| Concern | Owner | This spec |
|---|---|---|
| Customer accounts + balances (source of truth) | **D-gl** | **reads** (consumer) |
| **FSCS reporting** — SCV file, eligibility classification, compensation-scheme return | **K-fscs** | **builds** |
| Generic FCA submission / deadline / sign-off / audit trail | **K-gabriel** | **reuses** (`GabrielSubmissionPort`/`ReturnsGovernor`/`AuditPort`) |
| FIN-REP / EMI statistical returns | F-finrpt / K-gabriel | sibling, not duplicated |

## 2. Scope — FSCS reporting
### 2.1 Single Customer View (SCV)
- Per-eligible-depositor aggregated view: customer identity, aggregated **eligible-deposit** balance, account references, exclusion/marking flags; point-in-time, produced on demand within the FSCS/PRA deadline (config-as-data).
### 2.2 Eligible-deposit classification (the EMI distinction — handled, not asserted)
- **Eligibility is a rule engine (config-as-data), not hardcoded.** Key consideration: **safeguarded e-money under the EMI/CASS regime is generally NOT an FSCS-eligible deposit** (it is *safeguarded*, per E-safeguard, not deposit-protected). The classifier therefore **excludes safeguarded e-money** and includes only balances that are FSCS-eligible deposits (e.g. held under a deposit-taking permission / eligible partner-bank arrangement). The exact eligibility set is **operator/compliance-configured**; the engine applies it deterministically.
- Standard FSCS exclusions (entity type, beneficial-owner structures, marked-for-exclusion) encoded as config rules.
### 2.3 Compensation-scheme return
- FSCS levy/return content (eligible-deposit totals + class data) for the FSCS reporting return — distinct content from FIN-REP/RegData.

## 3. SCV data model & eligibility rules (config-as-data)
| Element | Definition |
|---|---|
| `SCVRecord` | `{ customer_id, identifiers[], eligible_balance: Decimal, currency, account_refs[], exclusion_flags[], as_of }` |
| `SCVFile` | `{ as_of, version, records[], totals, file_hash, status }` — immutable once `FINAL` (I-24/I-28) |
| `EligibilityRule` | `{ rule_id, predicate(account_type/customer_type/safeguarded_flag/...), eligible: bool, effective_period }` — **config-as-data** (CLAUDE.md §10) |
- Decimal only (I-01); SCV derivation aggregates per customer across eligible accounts; `FINAL` SCV files immutable + versioned (evidence).

## 4. Derivation & interfaces (referenced, not duplicated)
- **Consumes (D-gl):** customer accounts + `LedgerPort.get_balance()` per account/currency (read-only; no posting). Safeguarded-vs-deposit flag from chart-of-accounts / E-safeguard metadata.
- **Provides:** `SCVProvider.generate_scv(as_of) -> SCVFile` (FINAL/validated/versioned) + `get_scheme_return(period) -> SchemeReturnContent`.
- **Submission (reuse K-gabriel):** an FSCS submission routes through K-gabriel's `GabrielSubmissionPort` / `ReturnsGovernor` (pre-submission validation, deadline tracking, sign-off) + `AuditPort` (5Y trail). **HITL sign-off** required on any regulatory submit; **no autonomous FCA/FSCS submission**.

## 5. DoD / acceptance criteria (for the banxe-emi-stack PR)
- [ ] `test_scv_aggregates_eligible_balance_per_customer` (Decimal I-01; across accounts).
- [ ] `test_safeguarded_emoney_excluded_from_scv` (E-safeguard balances classified non-eligible by rule).
- [ ] `test_eligibility_rules_config_driven` (no hardcoded eligibility; rule engine deterministic).
- [ ] `test_scv_file_immutable_after_final` (versioned, `file_hash`; no mutate — I-24/I-28).
- [ ] `test_scv_derived_from_gl_read_only` (consumes D-gl via port; no posting/write-back).
- [ ] `test_scheme_return_distinct_from_finrep` (FSCS content ≠ FIN-REP; no F-finrpt reimpl).
- [ ] `test_submission_via_kgabriel_hitl` (routes through `GabrielSubmissionPort`/`ReturnsGovernor`; HITL sign-off; no autonomous submit).
- [ ] Coverage ≥ 90%, Ruff + semgrep clean; GL reads via port only (I-28).

## 6. Out of scope (fail-closed)
No runtime code here; no cross-repo write; **no GL reimplementation** (D-gl); **no generic-submission reimplementation** (K-gabriel — reused); **no autonomous FCA/FSCS submission** (HITL-gated); no eligibility *legal determination* baked in code (operator/compliance-configured); no KYC/KYB/AML; read-only over GL.

## 7. Operator gates NOT crossed
- **Cross-repo runtime** — building K-fscs in `banxe-emi-stack` is a **separate operator-authorized action**.
- **FSCS eligibility set** is an operator/compliance configuration decision (not baked here).
- No passport activation; reuse of K-gabriel's `regulatory_returns_governor` stays PROPOSED (not activated); M2.8 Roster-C + web-next + Arch-WG DRAFTs untouched.
- If any is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 8. References
`docs/regulatory/K-GABRIEL-BUILD-SPEC.md` (`GabrielSubmissionPort`/`ReturnsGovernor`/`AuditPort` — reused); `docs/architecture/D-GL-BUILD-SPEC.md` (customer/balance source); `docs/regulatory/F-FINRPT-BUILD-SPEC.md`; `docs/safeguarding/E-SAFEGUARD-CASS15-SPEC.md` (safeguarded-e-money eligibility); `docs/ROADMAP-MATRIX.md` (K-fscs); FCA SUP/PRA Depositor Protection / FSCS SCV; ADR-102/103/115/116/117/119; I-01/I-24/I-28.
