# F-FinRpt — FIN-RPT Regulatory-Returns Content Core Build-Spec

**Status:** Spec-Locked (build-spec) · **Date:** 2026-06-23 · **Block:** F-finrpt (GAP-007) · **Priority:** P0 · **Deadline:** Q2 2026
**Plane:** banxe-architecture = docs/architecture/spec only. Runtime code → `CarmiBanxe/banxe-emi-stack` (ADR-115/116/117). This doc **specifies**; ships **no** runtime code and makes **no** cross-repo write.
**Discipline:** ADR-102 (Duplication Audit §0), ADR-103, ADR-059-A/ADR-119 (append-only frozen ledger). Additive; mutates no prior artifact.

> Last open P0 on the critical path **J → E → D → K → F-finrpt**. F-finrpt is the **FIN-RPT return
> content/computation CORE** — the **producer** behind K-gabriel's `FinRepSourcePort`. It computes and
> assembles regulatory-return content; **K-gabriel (GAP-006) consumes, validates, submits, and governs**.
> F-finrpt does **not** implement submission, breach-reporting, deadline-tracking, or sign-off (those are
> K-gabriel's) — it **references** them.

---

## 0. Duplication Audit (ADR-102)
| Artifact | Role | Decision |
|---|---|---|
| `docs/regulatory/K-GABRIEL-BUILD-SPEC.md` (GAP-006) | submission/governance; **consumer** of `FinRepSourcePort` | **keep / reference** — F-finrpt is the **producer** side of that port; no overlap |
| `docs/D-RECON-BUILD-SPEC.md` | 3-leg recon + `safeguarding_events` | **keep** — F-finrpt **reads** recon/ledger aggregates as derivation source; does not re-define |
| `docs/safeguarding/J-ENGINE-BUILD-SPEC.md` / J-audit | safeguarding aggregates + immutable trail | **keep** — referenced as a content source for EMI/safeguarding data items |
| GAP-018 (financial-reporting **governance**) | reporting governance | **fence** — F-finrpt is the content **core**; governance is GAP-018, not duplicated |
| GAP-006 K-gabriel submission/breach layer | submission/breach/sign-off | **fence** — referenced, NOT reimplemented (mirror of K-gabriel's GAP-007 non-goal) |
No existing F-finrpt spec / GAP-007 seed shard on main → new file non-duplicative; grounded from ROADMAP + K-gabriel `FinRepSourcePort`.

## 1. GAP-007 ↔ GAP-006 boundary (drift reconciled)
| Concern | Owner | This spec |
|---|---|---|
| FIN-RPT return **content** (FIN-REP data items, RegData computation/assembly, content-versioning) | **F-finrpt (GAP-007)** | **builds** |
| Pull/consume that content, validate, track deadlines, **submit** to FCA Gabriel/RegData, sign-off, breach-report | K-gabriel (GAP-006) | **references** (consumer) |
| Financial-reporting **governance** | GAP-018 | **fences** |
The two meet **only** at the `FinRepSourcePort` contract (§4). No submission/breach logic lives here.

## 2. Scope — FIN-RPT regulatory-returns content core
1. **Return content computation/assembly** for FCA FIN-REP financial data items + RegData return content (the numeric/structured content of each return, per FCA item code & period).
2. **Derivation from authoritative sources** (read-only): Midaz ledger balances/aggregates via `LedgerPort` (I-28), D-recon recon aggregates (`safeguarding_events`), J/E safeguarding totals — assembled into return line items (Decimal only, I-01).
3. **Content validation rules** (internal consistency, cross-foot, period continuity) — distinct from K-gabriel's pre-submission/regulatory validation (which gates submission).
4. **Content-versioning & immutability** — each assembled return content set is versioned and immutable once finalised (audit/evidence; I-24/I-28), so K-gabriel submits a pinned content version.

## 3. Return data model (config-as-data)
| Element | Definition |
|---|---|
| `ReturnContentSet` | `{ fca_item_code, return_period, version, line_items[], derived_at, source_refs[], content_hash, status }` — immutable once `FINAL` |
| `line_item` | `{ code, value: Decimal, currency, derivation_source, period }` |
| FCA item codes / periods / cadence | **config-as-data** (no hardcode, CLAUDE.md §10) — same registry K-gabriel reads for scheduling |
| Derivation sources | Midaz ledger (LedgerPort), D-recon aggregates, J/E safeguarding totals — read-only |
> Content is **Decimal**; never float for money (I-01). `content_hash` lets K-gabriel pin/idempotently submit an exact version.

## 4. Interface contract — producer side of `FinRepSourcePort` (K-gabriel consumes)
- **`FinRepContentProvider.get_return_content(fca_item_code, return_period) -> ReturnContentSet`** — returns the **FINAL, validated, versioned** content set for a given item/period; raises if not yet finalised (K-gabriel must not submit draft content).
- **`FinRepContentProvider.list_available(period) -> [fca_item_code]`** — what content is ready for the period.
- Contract guarantees: content is Decimal, immutable at `FINAL`, carries `content_hash` + `source_refs`. **K-gabriel's `FinRepSourcePort` is the consume-only mirror of this** (per K-GABRIEL §3 `FinRepSourcePort`). No submission/transport here.

## 5. Ports (hexagonal)
`LedgerPort` (read Midaz balances; I-28 no direct HTTP), `ReconSourcePort` (read D-recon `safeguarding_events` aggregates), `SafeguardingTotalsPort` (read J/E totals), `ReturnContentStore` (append-only versioned content + content_hash; immutable at FINAL, I-24/I-28), `FinRepContentProvider` (producer of FinRepSourcePort, §4).

## 6. DoD / acceptance criteria (for the future banxe-emi-stack PR)
- [ ] `test_return_content_decimal_only` (I-01; no float).
- [ ] `test_content_derived_from_ledger_and_recon` (read-only LedgerPort + ReconSourcePort; no write-back).
- [ ] `test_content_validation_rules` (cross-foot / period continuity; invalid content not finalisable).
- [ ] `test_content_immutable_after_final` (versioned; no mutate after FINAL — I-24/I-28).
- [ ] `test_content_hash_stable_per_version` (K-gabriel can pin/idempotent-submit).
- [ ] `test_finrep_source_port_returns_final_only` (provider refuses draft content to K-gabriel).
- [ ] `test_no_submission_logic_present` (F-finrpt does NOT submit/breach — that is K-gabriel).
- [ ] Coverage ≥ 90%, Ruff + semgrep clean; LedgerPort-only for ledger reads (I-28).
- [ ] No KYC/KYB/AML; no K-gabriel submission/breach reimplementation; no GAP-018 governance reimplementation.

## 7. Out of scope (fail-closed)
No runtime code here; no cross-repo write into banxe-emi-stack; **no submission / breach-reporting / deadline-tracking / sign-off** (K-gabriel/GAP-006); no financial-reporting **governance** (GAP-018); no KYC/KYB/AML; no write-back to ledger/recon (read-only derivation); no FCA transport/credentials.

## 8. Operator gates NOT crossed
- **Cross-repo runtime** — building F-finrpt in `banxe-emi-stack` is a **separate operator-authorized action** (cross-repo write).
- No passport activation (any related governance passport stays PROPOSED); no DRAFT promotion; M2.8 Roster-C + web-next + Arch-WG DRAFTs untouched.
- If any is required to proceed → emit a one-line operator decision-brief, do not proceed.

## 9. References
`docs/regulatory/K-GABRIEL-BUILD-SPEC.md` (§3 FinRepSourcePort — consumer); `docs/D-RECON-BUILD-SPEC.md` (recon source);
`docs/safeguarding/{J-ENGINE-BUILD-SPEC,E-SAFEGUARD-CASS15-SPEC}.md` (safeguarding totals); GAP-018 (governance, fenced);
`docs/ROADMAP-MATRIX.md` (F-finrpt); ADR-013 (ledger), ADR-102/103/115/116/117/119; FCA FIN-REP / RegData; I-01/I-24/I-28.
