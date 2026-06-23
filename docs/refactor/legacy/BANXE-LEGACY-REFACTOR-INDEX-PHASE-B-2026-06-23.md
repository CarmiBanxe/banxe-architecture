# BANXE Legacy Refactor INDEX — Phase B (post-Phase-A SPEC/CONTRACT batch)

**Date:** 2026-06-23 · **Status:** SYNTHESIS INDEX (Phase B entry point) · **IL:** IL-477
**Owner:** Right terminal (smart refactor) authored; Terminal B owns implementation.
**Complements:** `BANXE-LEGACY-REFACTOR-INDEX-2026-05-25.md` (Phase A, 7 SPECs / C1–C18 subset) — **referenced, not duplicated.**
**Governing:** `NEW-PROJECT-PRIORITY-MAP-2026-06-06.md` (NEW capabilities C1–C30 drive legacy reuse).

## Scope / motivation

The Phase-A INDEX (2026-05-25) is a complete entry point for only the **7 Phase-A SPECs** (#1–#7).
Since then, the 2026-06-06 / 2026-05-26 batch added **~20 finalized SPEC/CONTRACT docs** closing the
remaining refactor classes (CLASS_TRANSFORM / CLASS_PORT / CLASS_MERGE / CLASS_REVIEW / CLASS_TAIL),
surfacing capabilities **C19–C30**, and deepening the **6 executable port CONTRACT-SPECs** — but **no
synthesis index covers them**. Terminal B therefore had no single entry point for post-Phase-A work.
This document is that entry point. It catalogs only **verified** metadata (each doc's own `Status:`
line); it changes no SPEC decision (additive).

## ADR-102 Duplication Audit
| Candidate | Finding | Decision |
|---|---|---|
| `BANXE-LEGACY-REFACTOR-INDEX-2026-05-25.md` | indexes Phase-A 7 SPECs only | **keep** — this Phase-B index complements it; no overlap |
| any phase-b / extension / post-phase index | **none exists** (verified) | new file non-duplicative |
| the 20 batch docs themselves | finalized SPEC/CONTRACT (14) + executable CONTRACT (6) | **keep** — indexed, not rewritten |

## A. Refactor-class closure SPECs (design baseline; Terminal B implements)
| SPEC file | NEW capability (Cn) | CLASS | Status |
|---|---|---|---|
| vendor-to-oss-group-SPEC-2026-06-06.md | cross-cutting (vendor→OSS) | CLASS_TRANSFORM (first) | SPEC |
| vabs-to-openbanking-group-SPEC-2026-06-06.md | C3 (extends PartnerPort) | CLASS_TRANSFORM | SPEC |
| aml-patterns-SPEC-2026-06-06.md | C5 (AML patterns) | CLASS_TRANSFORM (extract-patterns) | SPEC |
| auth-identity-ports-SPEC-2026-06-06.md | C19 (auth / identity / 2FA) | CLASS_PORT | SPEC |
| partner-bank-adapters-SPEC-2026-06-06.md | C3/C4 (concretises PartnerPort) | CLASS_PORT | SPEC |
| bitrix-webhook-ports-SPEC-2026-06-06.md | C21 (webhook ingestion) | CLASS_PORT (closes) | SPEC #14 |
| card-issuance-SPEC-2026-06-06.md | C22 (card issuance) | CLASS_MERGE | SPEC #15 |
| customer-lifecycle-SPEC-2026-06-06.md | C23 (customer lifecycle) | CLASS_MERGE | SPEC #16 |
| merge-remainder-SPEC-2026-06-06.md | C24/C25 (KYB + FX rate) | CLASS_MERGE (closes) | SPEC #17 |
| shared-libs-SPEC-2026-06-06.md | cross-cutting (shared libs) | CLASS_REVIEW | SPEC |
| finops-review-closure-SPEC-2026-06-06.md | C26 (FinOps automation) | CLASS_REVIEW (closes) | SPEC #19 |
| automation-platform-SPEC-2026-06-06.md | C27 (workflow automation) | CLASS_TAIL | SPEC #20 |
| tail-remainder-SPEC-2026-06-06.md | C28/C29/C30 (EDD + settlements + support) | CLASS_TAIL (closes) | SPEC #21 |
| kyc-provider-port-SPEC-2026-05-26.md | C5 (KYC provider) | (standalone extraction) | SPEC #8 |

## B. Executable port CONTRACT-SPECs (deepen Phase-A SPECs; contract-binding)
| CONTRACT file | NEW capability (Cn) | Port | Deepens | Status |
|---|---|---|---|---|
| wallet-port-CONTRACT-SPEC-2026-06-06.md | C1 | WalletPort | SPEC #1 | CONTRACT (executable) |
| exchangeport-CONTRACT-SPEC-2026-06-06.md | C6 | ExchangePort | SPEC #4 | CONTRACT (contract-only) |
| emi-banking-partnerport-CONTRACT-SPEC-2026-06-06.md | C3/C4 | PartnerPort | SPEC #5 | CONTRACT (executable) |
| crm-port-CONTRACT-SPEC-2026-06-06.md | C10 | CRMPort | SPEC #6 | CONTRACT (executable) |
| notification-port-CONTRACT-SPEC-2026-06-06.md | C9 | NotificationPort | SPEC #3 | CONTRACT (executable) |
| kyc-provider-port-CONTRACT-SPEC-2026-06-06.md | C5 | KYCProviderPort | SPEC #8 | CONTRACT (executable) |

## C. DRAFT contracts — Architecture WG GATE (NOT buildable; NOT promoted here)
These three SPEC-#7 per-capability contracts are **DRAFT (not buildable); each requires Architecture WG
review before promotion to PROPOSED** (ADR-050 Option B). The factory does **not** promote DRAFT→PROPOSED
autonomously — operator/Arch-WG governance gate.
| DRAFT file | NEW capability (Cn) | Gate |
|---|---|---|
| crypto-ops-monitor-CONTRACT-SPEC-DRAFT-2026-06-08.md | C8 (multi-chain RPC ops) | Arch-WG review → PROPOSED |
| banxe-portfolio-CONTRACT-SPEC-DRAFT-2026-06-08.md | C7 (portfolio analytics) | Arch-WG review → PROPOSED |
| banxe-news-CONTRACT-SPEC-DRAFT-2026-06-08.md | C18 (news feed) | Arch-WG review → PROPOSED |

## Coverage summary
- Phase A INDEX: 7 SPECs (C1–C18 subset, CLASS_KEEP).
- Phase B (this index): **14 finalized SPECs** (CLASS_TRANSFORM/PORT/MERGE/REVIEW/TAIL closures + KYC #8,
  surfacing C19–C30) + **6 executable port CONTRACT-SPECs** (C1/C3/C4/C5/C6/C9/C10).
- **Gated (excluded from buildable):** 3 DRAFT contracts (C7/C8/C18) → Arch-WG.
- Together, Phase A + Phase B give Terminal B a complete entry point across C1–C30.

## Perimeter / operator gates NOT crossed
- No DRAFT→PROPOSED promotion (Arch-WG gate, §C).
- No cross-repo write into any NEW target repo (this is a docs-plane synthesis index).
- M2.8 Roster-C + web-next operator gates untouched.
- Built from verified `Status:` metadata only — no SPEC decision changed; no capability fabricated.

## References
`BANXE-LEGACY-REFACTOR-INDEX-2026-05-25.md`; `NEW-PROJECT-PRIORITY-MAP-2026-06-06.md`; all 20 batch docs
above; ADR-021 (ports), ADR-050 (delivery model / DRAFT gate), ADR-017/019/020; ADR-102/103/119; I-28.
