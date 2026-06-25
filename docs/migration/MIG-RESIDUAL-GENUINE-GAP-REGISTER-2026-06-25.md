# MIG — Residual genuine-gap register (DECISION stage, docs-only, no port)

> **Type:** definitive residual-gap register for BANXE.RAR → EMI BANXE AI BANK. Answers ONE
> question: after ADR-102 dup-audit against the **current** EMI codebase, which legacy
> microservices/domains are **genuinely not ported and not covered/blocker/rescope**.
> **Stage:** DECISION (migration state machine) — *not* a port. No scaffold, no code, no secrets.
> **Canon:** factory-only; shell = read-only audit; ADR-102 dup-audit; ADR-103 server-only
> refactor; ADR-119/I-28 append-only; live-verified (no memory).
> **Aggregator, not a duplicate** — references existing MIG docs / IL; overwrites nothing.

---

## 0. Live-audit baseline (re-verified, not memory)

| Item | Value (live) |
|---|---|
| `banxe-architecture` origin/main | audited @ `a5e2ddc`; rebased-to-merge @ `9d557b8` (IL max = 515; #761 IL-514 f-fatca + #762 IL-515 skills-audit merged) → this register frozen at max+1 = **IL-516** (Rule 8) |
| `banxe-emi-stack` origin/main | `35033ac` (MIG-M2.4e CBPII facade #212); `services/*` = **110+ service dirs** |
| Open PRs (not this track) | #761 F-fatca (other track — untouched); #205 emi-stack sp-thin (untouched) |
| Self dup-audit (ADR-102) | no prior residual register on main → this doc is non-duplicative |
| Prior genuine-gap count (`docs/migration`) | 0 (M2.x closed: 8 BLOCKER-already-exists, 4 RESCOPE, 2 COVERED) |

Sources read: `banxe_legacy_inventory.md`, `banxe_legacy_domain_map.md`,
`banxe_to_emi_mapping.md`, `MIG-INDEX-final-state-register.md`, `docs/ROADMAP-MATRIX.md`;
`banxe-emi-stack:services/*` (origin/main, read-only `git ls-tree`).

---

## 1. Method

For every legacy top-level module (inventory M0) and every cross-cutting legacy domain
(domain-map M0), an ADR-102 dup-audit was run against the **current** EMI codebase
(`banxe-emi-stack:services/*` + `banxe-architecture`): service-name / domain-entity match,
plus content-depth (`git ls-tree -r` file/`.py` counts) to distinguish a real target from an
empty placeholder. Verdicts: **COVERED** (target exists) / **BLOCKER** (target mismatch) /
**RESCOPE** (out of EMI-license scope or rebuild-not-port) / **GENUINE-GAP** (legacy-derived,
truly not ported) / **SERVER-AUDIT-REQUIRED** (legacy depth unreadable without ADR-103
server-side unpack — never into repo).

---

## 2. Legacy top-level modules → dup-verdict

| Legacy module (inventory) | Stack / size | EMI target (evidence) | Verdict | Port-priority (best-solution) | Target repo |
|---|---|---|---|---|---|
| `banxe` (core monorepo) | NestJS/TS, 26 496 files, 502 tests | spans payment / ledger / kyc / risk / card services (see §3 domains) | **COVERED** (decomposed by domain) | — (domain-level, §3) | banxe-emi-stack |
| `crypto-api` | TS, 1 275 | `services/crypto_custody` (8 py), `crypto_aml_graph` | **COVERED** | P2 — wrap-depth only | banxe-emi-stack |
| `banxe-digital` | TS, 1 202 | `services/card_issuing` (9 py), `merchant_acquiring` | **COVERED** | P2 — BIN-sponsor-gated | banxe-emi-stack |
| `dcard` | TS, 14 | `services/card_issuing` | **COVERED** | P2 | banxe-emi-stack |
| `neuron` | PHP+TS, 6 654 | no single 1:1 target — domain unclear from mechanical signals | **SERVER-AUDIT-REQUIRED** | audit-before-decision | — |
| `internal_dev` | JS/Py/Shell, 2 087 | EMI infra/tooling (`scripts/`, `deploy/`) | **SERVER-AUDIT-REQUIRED** → likely DROP/replace | P3 | — |
| `ilink` | SQL, 37 | schema reconcile (no service) | **SERVER-AUDIT-REQUIRED** | P3 — reconcile, not port | — |
| `crypto-processing` | PHP/WordPress, 6 699 (`wordpress-shop-example` 9 611) | — (vendored WP shop) | **RESCOPE/DROP** | P3 — drop (low value, ADR-102 dedup-gated) | — (drop) |
| `banxe_site` | PHP front, 5 705 | EMI React/TS frontend | **RESCOPE** (rewrite, not port) | P2 — gated by M2.8 roster | banxe-ui / banxe-platform |
| `consul-configs` | Shell/config, 209 | EMI infra stack (Consul→EMI deploy) | **RESCOPE/replace** | P3 | banxe-emi-stack/deploy |
| `binarity-team` | Py/Shell, 426 | EMI infra tooling | **RESCOPE/replace** | P3 | banxe-emi-stack |
| `(root)` | 2 files | — | **DROP** | — | — |

---

## 3. Legacy domains (cross-cutting) → dup-verdict

| Legacy domain (domain-map hits) | EMI target service(s) (depth) | Verdict | Evidence / MIG ref | Priority |
|---|---|---|---|---|
| **Payments** (banxe 3 604) | `payment` (20), `batch_payments`, `scheduled_payments`; `banxe-payment-core` (M2.1/M2.6) | **COVERED / scaffold** | MIG-INDEX §3 IL-378/380; OB-delta IL-418/420/422 | P0 depth |
| **Wallets/accounts** (banxe 2 664) | `ledger` (19), `midaz_mcp`, `multi_currency` (M2.2 SoT) | **COVERED** | MIG-INDEX §3 IL-374; ADR-013 LedgerPort | P1 depth |
| **KYC/AML** (banxe 469 + digital 164) | `kyc` (6), `kyb_onboarding`, `aml`, `sanctions_screening`, `adverse_media`, `compliance` | **COVERED (I-27 gated)** | MIG-INDEX §3 IL-391; ROADMAP A-kyc/A-idv/A-kyb Spec-Locked | gated |
| **Risk/DSE/analytics** (banxe 153) | `risk` (2), `risk_management`, `quant_advisory`; DSE advisory (SBOX-1..6) | **COVERED** | mapping P0 #1 (delivered DSE); ADR-083/084 | P1 depth |
| **Money model** (bignumber.js 711+587; decimal.js 0) | EMI Decimal (I-01; Semgrep `banxe-float-money`) | **COVERED (invariant)** | mapping P0 #2 — rewrite-gate, not a service port | P0 contract-tests |
| **Trading-core** (banxe 536 + crypto-processing 213) | `fx_exchange`, `fx_engine` (9) — **no crypto order-matching/exchange engine** | **RESCOPE/DROP** (out of EMI-license scope) + **SERVER-AUDIT-REQUIRED** | EMI = e-money institution, not a securities/crypto exchange; confirm legacy trading scope server-side | P3 — decide-then-drop |
| **Infra** (banxe 1 202 + binarity 426) | EMI Postgres/ClickHouse/Redis + `deploy/` | **RESCOPE/replace** | not a port | P3 |

---

## 4. ROADMAP 0% rows — legacy-derived vs net-new (cross-check)

| ROADMAP row (0%) | EMI service present? (depth) | Legacy-derived? | Verdict |
|---|---|---|---|
| **C-swift** (SWIFT MT/MX) | `swift_correspondent` (8 py) | yes (legacy intl payments) | **COVERED** — depth-build, not a new port |
| **E-treasury** (liquidity/FX/ALM) | `treasury` (11 py), `fx_engine`, `fx_rates` | partial | **COVERED** — depth-build |
| **F-fatca** (FATCA/CRS/DAC8) | `fatca_crs` (6 py) + PR #761 in-flight | net-new regulatory | **COVERED / in-progress** (other track) |
| **H-crm** (CRM/DSAR) | `crm` (1, thin) + `customer` + `customer_lifecycle` + `case_management` | yes (legacy CRM) | **COVERED-distributed** — thin `crm/`, domain spread across siblings |
| **H-support** (ticketing/SLA) | `support` (7), `complaints`, `dispute_resolution`, `voice_support` | partial | **COVERED** |
| **L-bi** (BI dashboards) | `reporting_analytics`, `audit_dashboard`, `reporting`; `L-lake` 30% | data layer yes; presentation net-new | **COVERED-data / net-new presentation** |
| **M-gateway** (public REST API) | `api_gateway` (8), `psd2_gateway`, `api_versioning` | net-new (public surface) | **COVERED** — depth-build |
| **M-sdk** (Python+JS SDK) | no `sdk` service | **NO** — legacy published no SDK | **GENUINE-GAP (NET-NEW, not a BANXE.RAR port)** |
| **M-sandbox** (mock rails/test accounts) | DSE sandbox delivered (SBOX-1..6); no `sandbox` svc | partial; net-new | **NET-NEW** (not a legacy port) |

---

## 5. DECISION — residual genuine-gap result

**Residual LEGACY-DERIVED genuine-gap (truly not ported AND not covered/blocker/rescope): `0` confirmed.**

- Every legacy module and every legacy domain resolves to **COVERED** (existing EMI service,
  content-verified), **RESCOPE/DROP** (out of EMI-license scope or rebuild-not-port), or
  **SERVER-AUDIT-REQUIRED** (depth unreadable without ADR-103 server unpack). None resolves to
  a clean legacy-derived GENUINE-GAP requiring a new port. This **confirms** the prior
  `docs/migration` genuine-gap count of 0 against the *current* (richer) EMI codebase.
- The only **GENUINE-GAP** items (M-sdk, M-sandbox, L-bi presentation) are **net-new**, not
  BANXE.RAR-derived — they belong to the ROADMAP forward plan, not legacy migration.
- **4 SERVER-AUDIT-REQUIRED** items (`neuron`, `internal_dev`, `ilink`, Trading-core) gate
  their final DROP/RESCOPE verdict on an ADR-103 server-side legacy read at
  `/home/mmber/banxe-legacy-unpack` — **never unpacked into the repo, no secrets committed**.

### Next track step (best-solution, for operator)
The migration's remaining value is **depth/quality of already-covered services** and the two
**operator gates** (M2.8 frontend roster; KYC/KYB I-27 HITL-L4), **not** new legacy ports.
Recommended next DECISION-stage move: an ADR-103 **server-side audit** of the 4
SERVER-AUDIT-REQUIRED modules to convert each to a final DROP/RESCOPE record — read-only on the
factory server, results back as a docs artifact. No port is unblocked by this register.

---

## 6. Canon confirmations

- **No secrets reached the repo** — no `.RAR` unpacked here; legacy depth left on the factory
  server (`/home/mmber/banxe-legacy-unpack`, ADR-103); audit was repo-side `git ls-tree` only.
- **No port, no scaffold, no code** — DECISION stage only; ADR-102 verdicts recorded, nothing
  created without a confirmed genuine-gap (there are none legacy-derived).
- **Append-only** — additive doc; references existing MIG docs / IL; overwrites nothing.

### Refs
`banxe_legacy_inventory.md`, `banxe_legacy_domain_map.md`, `banxe_to_emi_mapping.md`,
`MIG-INDEX-final-state-register.md` (IL-436), `docs/ROADMAP-MATRIX.md`; `banxe-emi-stack:services/*`
(origin/main `35033ac`); ADR-102, ADR-103, ADR-119; I-01, I-27, I-28.
