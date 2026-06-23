# K-NCA — NCA SARs Build-Spec (SAR drafting + MLRO workflow + NCA filing)

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-23 · **Block:** K-nca · **Priority:** P1 · **Sprint:** 11
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). This doc **specifies**; ships **no** runtime code and makes **no** cross-repo write.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103, ADR-059-A/ADR-119. Additive; mutates no prior artifact.

> K-nca generates **Suspicious Activity Reports** from F-aml cases, routes them through the **MLRO
> (mandatory human decision)**, and files approved SARs/DAMLs to the NCA. **No autonomous filing.** It
> **consumes** AML alerts/cases from F-aml (Marble CM / Watchman) and **reuses** the submission/audit
> patterns (K-gabriel / J-audit) — it does **not** reimplement screening and does **not** activate the
> MLRO passport.

---

## 0. Duplication Audit (ADR-102)
| Artifact | Role | Decision |
|---|---|---|
| F-aml screening (`watchman_adapter`, Marble CM / ADR-005, `aml-patterns-SPEC`) | sanctions/AML/KYC screening → alerts & cases | **keep / reference** — K-nca **consumes** F-aml cases; does NOT reimplement screening |
| `docs/canon/passports/mlro.yaml` (MLRO role, UNDESIGNATED/interim; `sar-generator` tool, gate_authority=mlro) | human MLRO decision authority | **keep / reference** — K-nca routes to this role; **NOT modified/activated** (designation is operator-gated) |
| `docs/regulatory/K-GABRIEL-BUILD-SPEC.md` | FCA submission/governance pattern (`GabrielSubmissionPort`/`AuditPort`) | **keep / reuse pattern** — NCA filing/audit reuse the structured-submission + 5Y audit pattern, not the FCA endpoint |
| `docs/safeguarding/J-ENGINE-BUILD-SPEC.md` J-audit | immutable ClickHouse evidence trail | **keep / reuse pattern** — SAR audit trail uses the same append-only 5Y pattern |
No existing K-nca / SAR build-spec on main → new file non-duplicative.

## 1. Boundary (K-nca vs F-aml vs mlro passport) — drift reconciled
| Concern | Owner | This spec |
|---|---|---|
| AML/sanctions/KYC **screening** → alerts/cases | **F-aml** (Marble/Watchman) | **consumes** (case source) |
| **SAR generation + MLRO workflow + NCA filing** | **K-nca** | **builds** |
| MLRO **human decision authority** | **mlro.yaml role** (human, HITL) | **routes to** (not activated/modified) |
| Generic submission / audit-trail pattern | K-gabriel / J-audit | **reuses pattern** (not duplicated) |

## 2. Scope — NCA Suspicious Activity Reports
1. **SAR drafting** from F-aml cases — assemble a SAR draft (subject, suspicion grounds, linked transactions/alerts) from an F-aml `AMLCase`.
2. **MLRO review/decision workflow (HITL, mandatory)** — every SAR is presented to the **MLRO** (mlro.yaml role) who decides **file / no-file / request-more-info**. **No SAR is filed without explicit MLRO approval.**
3. **NCA submission** — file an approved SAR via the **NCA SAR Online** structured-filing path; **DAML** (Defence Against Money Laundering / consent SAR) where a transaction needs consent to proceed.
4. **Tipping-off controls (POCA s333A)** — restricted access; **no customer notification**; SAR existence is not disclosed outside the authorised compliance circle.
5. **Immutable audit trail** — every draft/decision/filing recorded append-only (J-audit/ClickHouse pattern, TTL 5Y, I-24/I-28).

## 3. Data model & decision gates
| Element | Definition |
|---|---|
| `AMLCase` (from F-aml) | screening alert/case — read-only input |
| `SARDraft` | `{ case_ref, subject, suspicion_grounds, linked_txns[], sar_type(SAR\|DAML), drafted_at, status }` |
| `MLRODecision` | `{ sar_ref, mlro_actor, decision(file\|no_file\|more_info), rationale, decided_at }` — **gate: file requires MLRO** |
| `SARFiling` | `{ sar_ref, nca_reference, filed_at, submitted_by_mlro, idempotency_key, status }` — append-only, immutable |
- **Hard gate:** `SARFiling` MUST be preceded by an `MLRODecision(decision=file)` by the MLRO role; the engine **fail-closes** otherwise (no autonomous filing). Decimal not applicable; identifiers + structured fields only. `FINAL` records immutable (I-28).

## 4. Interfaces (referenced, not duplicated)
- **Consumes (F-aml):** `AMLCasePort` — read F-aml cases/alerts (Marble/Watchman); no screening logic here.
- **MLRO gate:** `MLROReviewPort` — present `SARDraft` to the MLRO (mlro.yaml `sar-generator`/`marble-ui` tools), capture `MLRODecision` (HITL). Routes to the human role; does not activate/modify the passport.
- **Files (NCA):** `NCASubmissionPort` — structured SAR Online / DAML filing (sandbox-first), idempotent per SAR; **invoked only after MLRO approval**.
- **Audits:** `AuditPort` — append-only SAR lifecycle → ClickHouse (5Y, I-24/I-28), reusing the J-audit pattern.

## 5. DoD / acceptance criteria (for the banxe-emi-stack PR)
- [ ] `test_sar_draft_from_faml_case` (assembles SARDraft from `AMLCase`; no screening reimpl).
- [ ] `test_filing_requires_mlro_approval` (no `SARFiling` without `MLRODecision(file)` — **fail-closed**).
- [ ] `test_no_autonomous_filing` (engine cannot file without the MLRO gate; HITL mandatory).
- [ ] `test_daml_consent_path` (DAML/consent SAR routed correctly where flagged).
- [ ] `test_tipping_off_controls` (no customer notification; SAR access restricted to compliance circle).
- [ ] `test_sar_audit_immutable_5y` (append-only lifecycle; no UPDATE/DELETE — I-24/I-28).
- [ ] `test_filing_idempotent_per_sar` (idempotency_key prevents double-filing).
- [ ] Coverage ≥ 90%, Ruff + semgrep clean.

## 6. Out of scope (fail-closed)
No runtime code here; no cross-repo write; **no AML/sanctions/KYC screening reimplementation** (F-aml); **no autonomous SAR/DAML filing** (MLRO HITL mandatory); **no MLRO passport activation/modification** (mlro.yaml is UNDESIGNATED/interim — designation is operator-gated); no customer-facing disclosure (tipping-off); no KYC/KYB onboarding logic.

## 7. Operator gates NOT crossed
- **MLRO passport** (`mlro.yaml`) — referenced only; **not activated or modified** (MLRO designation = operator decision; currently interim/UNDESIGNATED).
- **Cross-repo runtime** — building K-nca in `banxe-emi-stack` is a **separate operator-authorized action**.
- No DRAFT promotion; M2.8 Roster-C + web-next + Arch-WG DRAFTs untouched.
- If any is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 8. References
F-aml (`agents/passports/watchman_adapter.yaml`, `decisions/ADR-005-marble-elastic-v2.md`, `docs/refactor/legacy/aml-patterns-SPEC-2026-06-06.md`); `docs/canon/passports/mlro.yaml` (MLRO role); `docs/regulatory/K-GABRIEL-BUILD-SPEC.md` (submission/audit pattern); `docs/safeguarding/J-ENGINE-BUILD-SPEC.md` (J-audit); `docs/governance/GLOSSARY.md`; `docs/ROADMAP-MATRIX.md` (K-nca); UK POCA 2002 (SAR / DAML / s333A tipping-off), NCA SAR Online; ADR-102/103/115/116/117/119; I-24/I-27/I-28.
