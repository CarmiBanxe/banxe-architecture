---
il_ts: 2026-07-06T01:00:23Z
session_id: agent-factory-souls-cohort9-ctx07-agreement
source: CEO
status: PROPOSED
---
### Cohort 9 — complete CTX-07-AGREEMENT: author 2 governor SOULs, prepare-only, no activation

- **Objective:** Author the 2 SOUL charters that close the CTX-07-AGREEMENT context: `agreement_agent`, `legal_corporate_agent`. Forward-path continuation of the #1040 readiness audit (after Cohorts 1–8: #1042/#1044/#1046/#1050/#1053/#1056/#1057/#1060). Last low-risk context close before CTX-01 compliance/AML (~17) + CTX-04 payments (4).
- **Status body-check applied ([[passport-status-active-on-stub-is-unreliable]], 5th confirmation):**
  - `legal_corporate_agent` — grep flagged `status=active`; **BODY-CHECK VERDICT = STUB → PROPOSED.** Evidence line (passport body, verbatim): *"STUB passport (Sprint-2 Staff Matrix). … PROPOSES only (I-27); NOT activated. No service code exists yet — deferred to Sprint 3 (see GAP-078)."* No activation-ADR cited → NOT live. Stray-active field NOT trusted; Factory activated nothing.
  - `agreement_agent` — genuine PROPOSED.
- **Facts grounded per passport (origin/main), NOT normalised:**
  - `agreement_agent` — L2 · AMBER · **CLASS_A** · PROPOSED. human_double **Legal Counsel** (owner Legal Counsel + CCO; approvers CCO + CEO). Manages customer agreements/T&Cs per product (e-money, FX, savings, payment); DocuSign qualified e-signature (eIDAS Reg.910/2014); full version history; required for binding post-KYC onboarding. Ports AgreementPort→CustomerPort/ProductCatalogPort/CompliancePort/NotificationPort/AuditPort; callers customer_lifecycle_agent/admin_panel/kyc_specialist_v2; callees customer_lifecycle_agent/notification_agent/compliance_officer_v1. Invariant **I-06** (5yr, eIDAS+MLR 2017). FCA COBS 6 (product disclosure) / COBS 4 (comms) / eIDAS 910/2014 / MLR 2017. Risks AIGF-C-04 (invalid e-sig → unenforceable contract), AIGF-C-05 (version mismatch → breach). migration 5%. Route-not-reimplement (DocuSign via port). Binding/execution + material T&C change human-gated (Legal Counsel; material → Compliance review).
  - `legal_corporate_agent` — L2 · AMBER · CLASS_B · STUB → PROPOSED. human_double **Legal Counsel**; SMF Legal; **2nd-Line legal/corporate** dept-head; no ports, no service code (GAP-078). auto_refactor_pro prohibited (2nd-line independence — must not edit code it reviews). Coordinate/propose only; no autonomous legal action/filing.
- **Route-not-reimplement (canon):** agreement_agent integrates DocuSign via port (never reimplements it); legal_corporate is a coordination stub. SOUL **describes** authority, never expands it — enforcement in CI + ADR-117/128/121.
- **Agreement/legal-domain discipline:** contract binding requires a valid qualified e-signature; material T&C changes trigger regulatory review and are human-gated; contract execution/binding + any legal filing are human-gated at Legal Counsel; no autonomous binding or filing.
- **ADR-102 duplication audit:** `agents/souls/` checked — no pre-existing/near-duplicate SOUL for either stem. **Decision: add net-new (2).** No merge/delete; no hidden consumer.
- **Format:** each SOUL = 12 sections, 68 lines. House style consistent with Cohorts 1–8.
- **Perimeter / canon:** banxe-architecture only; isolated worktree off origin/main (ADR-120), not shared checkout; no TRADING-001 / agent/specproj/* (Rule 6); no secrets; no code/runtime change; signed; `--force-with-lease` only; NO-PASSPORT-DIFF guard before push. Serial single PR.
- **Deliverable:** 2 `agents/souls/*.md` + this IL shard. ONE Draft PR, prepare-only. IL frozen-at-merge (Rule 8) — minted via build_ledger.py on current origin/main immediately before merge (churn-resilient: factory re-rebases on conflict, per #1060 lesson).
- **Fleet impact:** 49 → 51 SOULs; **CTX-07-AGREEMENT complete**. Remaining SOUL-less after this: ~24 of 57 (only CTX-01 compliance/AML + CTX-04 payments + a few unmapped left — the high-sensitivity final tranches).
- **Refs:** SOUL cohorts #1042/#1044/#1046/#1050/#1053/#1056/#1057/#1060; FACTORY-CANON.md (#1047, IL-932); passports agents/passports/{agreement_agent,legal_corporate_agent}.yaml; CLAUDE.md §11; I-06; I-27; ADR-102; ADR-117/120/121/128; GAP-078; eIDAS Reg.910/2014; FCA COBS 6/4; MLR 2017; governance/CANONICAL-ORG-CHART-v2.md.
