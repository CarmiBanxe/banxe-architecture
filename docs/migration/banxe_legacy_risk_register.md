# BANXE legacy risk register (M0 task 3.4)

High-risk zones where migration without preparation is dangerous. Each area traces to the
snapshot/index evidence; "blocking" = must not migrate before the pre-work lands.

| Area | Risk type | Blocking? | Required pre-work |
|---|---|---|---|
| **Payments domain** (3,604 hits; mixed TS+PHP; regulated) | regulatory + operational | **YES** | Characterization tests on the legacy flow; EMI best-execution + safeguarding (CASS-15) contracts; sandbox/mock providers for ClearBank/Modulr/Hyperswitch before any live touch |
| **Money handling** (`bignumber.js` 711+587; `decimal.js`=0) | compliance (I-01) + tech-debt | **YES** | Enumerate every money path; contract tests asserting Decimal equivalence; Semgrep `banxe-float-money` gate before migrating any amount logic |
| **Cross-package shared/DTO** (243 pkgs; 3,431 shared; 2,999 dto; 7 dirs) | tech-debt + hidden dependencies | **YES (ADR-102)** | Repo-wide source-of-truth + full consumer map per duplicate; no merge/dedup until confirmed |
| **SQL/migration fragments** (74 `.sql`; 891 under `migrations/`; 6 dirs) | operational (data) | **YES** | Reconcile migration history + DB schema characterization; additive-first migration plan (per emi-stack 60-migrations rule) before any schema move |
| **KYC/AML** (`banxe`469, `banxe-digital`164; regulated) | regulatory | **YES** | Map controls to MLR 2017 / FCA; verify EDD thresholds (£10k/£50k) and sanctions logic before wrapping into Marble/Jube |
| **Trading-core** (536; TS+PHP; bignumber) | operational + tech-debt | conditional | Characterization tests; confirm no live-execution path carries forward (advisory-only per ADR-083/084) |
| **`crypto-processing` / `banxe_site` PHP** (php 3,783 / 3,409; few tests) | tech-debt | conditional | If migrating: characterization tests first; else mark for DROP/rewrite |
| **Vendored bundles** (`wp-includes` 2,316; `vendor` 1,012; `wordpress-shop-example` 9,611) | low (vendor) | NO | Exclude/drop from migration; verify no application forks a vendored copy before deletion |
| **Personal/regulated data in archive** (6.4 GB; unknown PII content) | regulatory (data protection) | **YES** | Server-only handling (ADR-103) already enforced; before promoting any extracted content, confirm no PII/secret leaks into repos (Secrets Scan + manual review) |

## Top blocking risks (do-not-touch-without-pre-work)

1. **Payments** — regulatory + operational; needs characterization + best-exec/safeguarding contracts + provider sandboxes.
2. **Money (bignumber.js → Decimal)** — I-01 invariant; needs Decimal-equivalence contract tests.
3. **Cross-package shared/DTO** — hidden deps; needs ADR-102 repo-wide audit before any dedup.
4. **SQL/migration fragments** — data risk; needs migration-history reconciliation.
5. **KYC/AML** — regulatory; needs MLR/FCA control mapping.

INSUFFICIENT EVIDENCE (deferred to M1 deep-read): exact PII fields in payloads, precise
service-to-service coupling, and whether any legacy money path lacks rounding/precision
handling — these require reading individual files, not just the index.

## Duplication Audit (ADR-102)

Coverage (same scan as 3.2/3.3): full index 100,488 paths + 50,806-file snapshot; exts
`.ts/.js/.php/.py/.sql/.json`; 5 hotspots with the counts above (shared/DTO 243/3,431/2,999;
Apollo 7; money 711+587/0; SQL 74/891; vendored 2,316/1,012/9,611). Every risk that implies a
structural change (dedup shared, drop vendored/crypto-processing, consolidate migrations) is
**blocked** until its repo-wide ADR-102 audit (source-of-truth + every consumer) is recorded.
Fail-closed; escalate on doubt.
