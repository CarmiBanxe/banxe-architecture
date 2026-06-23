# K-Gabriel — FCA Gabriel/RegData Regulatory-Returns Build-Spec

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-23 · **Block:** K-gabriel · **Priority:** P0 · **Deadline:** Q2 2026
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). This doc **specifies**; it ships **no** runtime code and makes **no** cross-repo write.
**Promotes:** GAP-006 seed (`sp24-gabriel-gap006`) + `agents/passports/regulatory_returns_governor.yaml` (PROPOSED) → actionable build-spec.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103, ADR-059-A/ADR-119 (append-only frozen ledger). Additive; mutates no prior artifact.

> Critical-path link J → E → D → **K**. K-gabriel is the **regulatory-returns submission + governance layer**.
> It **consumes** D-recon's breach hook and J-audit's immutable trail (referenced, not duplicated) and the
> FIN-RPT return content from F-finrpt — it does **not** reimplement the financial-reporting core.

---

## 0. Duplication Audit (ADR-102)
| Artifact | Role | Decision |
|---|---|---|
| `agents/passports/regulatory_returns_governor.yaml` (GAP-006, PROPOSED) | returns prep/submission/deadline/validation/sign-off governor | **keep** — this build-spec operationalises it; passport stays PROPOSED (not activated) |
| `ledger/.../sp24-gabriel-gap006` seed shard | GAP-006 OPEN→IN PROGRESS | **keep** — seed |
| `docs/safeguarding/J-ENGINE-BUILD-SPEC.md` §2.4 (breach hook iface) | `safeguarding.breach.detected` interface | **keep** — K-gabriel is the **consumer** of that event |
| `docs/D-RECON-BUILD-SPEC.md` §4 (breach pipeline) + §3 (`safeguarding_events`) | breach emission + audit table | **keep** — referenced; K-gabriel reads, does not re-define |
| `docs/safeguarding/E-SAFEGUARD-CASS15-SPEC.md`, `J-CROSS-REPO-HANDOFF.md` | safeguarding context | **keep** — referenced |
| **F-finrpt (GAP-007)** "FIN-RPT regulatory returns" | financial-reporting return **content/core** | **fence** — K-gabriel consumes FIN-RPT outputs; does NOT reimplement (seed non-goal) |
| financial-reporting governance (GAP-018) | reporting governance | **fence** — not duplicated (seed non-goal) |
No existing K-gabriel build-spec / `docs/regulatory/` dir on main → new file non-duplicative.

## 1. Scope
K-gabriel delivers the **FCA Gabriel/RegData regulatory-returns submission platform** + **breach-reporting workflow**:
1. **Return types & schedule** — FIN-REP (financial returns; content sourced from F-finrpt) + **EMI statistical returns** (e.g. FSA prudential/EMI data items), on their FCA periodic cadence (monthly/quarterly/annual per item).
2. **Preparation → validation → submission** pipeline with deadline tracking and pre-submission validation.
3. **Breach-reporting workflow** — on a confirmed safeguarding breach (from D-recon / J-engine), generate and route an FCA breach notification via **n8n**, HITL-gated (no auto-submission to the FCA).
4. **Submission audit trail + sign-off** — immutable record of every prepared/validated/submitted return + breach report.
KYC/KYB/AML and the FIN-RPT financial-reporting **core** are **out of scope** (consumed, not built).

## 2. Return schedule / types (config-as-data)
| Return | Content source | Cadence (config) | Governance |
|---|---|---|---|
| FIN-REP (financial return) | **F-finrpt** (GAP-007) outputs | periodic per FCA item | governor pre-submission validation |
| EMI statistical returns | EMI ledger + safeguarding (J/D/E) aggregates | periodic per FCA item | governor pre-submission validation |
| Safeguarding breach report | D-recon breach hook (`safeguarding.breach.detected`) | event-driven | HITL sign-off (I-27) |
> Deadlines, cadences, item codes are **config-as-data** (CLAUDE.md §10) — not hardcoded; governor invariant `returns_submitted_before_fca_deadline`.

## 3. Architecture perimeter & interfaces
- **`ReturnsGovernor`** (operationalises `regulatory_returns_governor`, PROPOSED): schedules prep, runs pre-submission validation, tracks deadlines, requires sign-off (invariants `returns_submitted_before_fca_deadline`, `submission_data_validated_and_signed_off`).
- **`FinRepSourcePort`** — pulls FIN-RPT return content from F-finrpt (consume-only; no reimplementation).
- **`StatReturnPort`** — assembles EMI statistical returns from J/D/E aggregates (read-only).
- **`BreachReportPort`** — consumes `safeguarding.breach.detected` (D-recon/J §2.4); produces FCA breach notification draft to **n8n :5678** (HITL, no FCA auto-submit).
- **`GabrielSubmissionPort`** — submission interface to FCA Gabriel/RegData (sandbox first); idempotent per return-period.
- **`AuditPort`** — append-only submission audit trail → ClickHouse (TTL 5Y, I-24/I-28), reusing the J-audit/D-recon `safeguarding_events`-class evidence pattern (referenced; returns evidence may use a sibling `regulatory_submissions` table — owned here).

### 3.1 Submission interface contract (stack must conform)
- **Submission record** (`GabrielSubmissionPort` → audit): `{ return_type, return_period, fca_item_code, prepared_at, validated_by, submitted_at, submission_ref, status, idempotency_key }` — append-only, TTL 5Y.
- **Breach→report trigger path:** `safeguarding.breach.detected` (D-recon) → `BreachReportPort` → n8n breach-report workflow → **HITL sign-off (Head of Compliance / MLRO)** → Gabriel submission draft. **No autonomous FCA submission.**

## 4. DoD / acceptance criteria (for the future banxe-emi-stack PR)
- [ ] `test_return_schedule_config_driven` (cadences/items from config, no hardcode).
- [ ] `test_pre_submission_validation_blocks_invalid` (governor refuses unvalidated return).
- [ ] `test_deadline_tracking_before_fca_cutoff` (`returns_submitted_before_fca_deadline`).
- [ ] `test_finrep_content_consumed_not_reimplemented` (FinRepSourcePort reads F-finrpt; no reporting-core logic).
- [ ] `test_breach_event_to_report_path` (consumes `safeguarding.breach.detected`; HITL sign-off required; no FCA auto-submit).
- [ ] `test_submission_audit_immutable_5y` (append-only, TTL 5Y, no UPDATE/DELETE — I-24/I-28).
- [ ] `test_submission_idempotent_per_period` (idempotency_key prevents double-filing).
- [ ] Coverage ≥ 90%, Ruff + semgrep clean; LedgerPort-only where ledger data is read (I-28).
- [ ] No KYC/KYB/AML touched; FIN-RPT core not reimplemented; governor passport NOT activated.

## 5. Out of scope (fail-closed)
No runtime code here; no cross-repo write into banxe-emi-stack; no FIN-RPT financial-reporting **core** (F-finrpt/GAP-007); no financial-reporting governance (GAP-018); no KYC/KYB/AML; no autonomous FCA submission (HITL-gated); no Gabriel production credentials (sandbox-first).

## 6. Operator gates NOT crossed
- **`regulatory_returns_governor` passport activation** (PROPOSED, human_double Head of Compliance) = CLASS_B governance gate — **not activated here**.
- **Cross-repo runtime** — building K-gabriel in `banxe-emi-stack` is a **separate operator-authorized action** (cross-repo write).
- M2.8 Roster-C + web-next operator gates untouched; Arch-WG DRAFT contracts untouched.
- If any is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 7. References
GAP-006 seed (`sp24-gabriel-gap006`); `agents/passports/regulatory_returns_governor.yaml`;
`docs/safeguarding/J-ENGINE-BUILD-SPEC.md` (§2.4 breach hook), `J-CROSS-REPO-HANDOFF.md`, `E-SAFEGUARD-CASS15-SPEC.md`,
`docs/D-RECON-BUILD-SPEC.md`; F-finrpt (GAP-007) + GAP-018 (fenced); `docs/ROADMAP-MATRIX.md` (K-gabriel);
ADR-102/103/115/116/117/119; FCA Gabriel/RegData, FIN-REP, EMI statistical returns; I-24/I-27/I-28.
