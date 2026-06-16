# BANXE legacy → EMI BANXE AI BANK mapping (M0 task 3.3)

Maps each large legacy component (from the domain map, traceable to the snapshot/index)
onto the target EMI architecture (from `BANXE_MASTER_RESEARCH.md`: Midaz CBS, payment rails
ClearBank/Modulr/Hyperswitch, AML Marble/Jube/OpenSanctions, KYC Ballerine/Sumsub, CASS-15
Safeguarding, the delivered DSE advisory + sandbox stack, Postgres/ClickHouse). Strategy =
reuse / wrap / rewrite; priority P0 (critical core value) / P1 (important, not first) / P2
(low / drop / later).

| Legacy component (evidence) | EMI target | Strategy | Priority | Rationale |
|---|---|---|---|---|
| **`banxe` risk/DSE/analytics slice** (153 hits; smallest footprint) | EMI **DSE advisory** (delivered S12–S16 / SBOX-1..6, ADR-083/084) | **reuse + small rewrite** | **P0** | Smallest legacy surface, lowest blast radius, maps directly onto already-built DSE — highest alignment/value-per-risk |
| **Money handling** (`bignumber.js`, 711+587 refs; `decimal.js`=0) | EMI **Decimal** money model (I-01; Semgrep `banxe-float-money`) | **rewrite** | **P0** | Legacy uses bignumber.js; EMI mandates Decimal — invariant gate; must convert with contract tests before any money path migrates |
| **`banxe` wallets/accounts** (TS/NestJS, 2,664; 502 tests) | EMI Banking Core via **Midaz LedgerPort** (ADR-013) | **wrap** | **P1** | Modern, best-tested legacy slice; wrap behind the Midaz LedgerPort rather than rewrite |
| **Payments domain** (3,604; mixed TS+PHP, regulated) | EMI **payment rails** (ClearBank/Modulr/Hyperswitch) | **rewrite behind rails** | **P0** | EMI's critical 0% gap; legacy proprietary flow can't carry forward — rebuild behind BaaS rails (high-risk, see risk register) |
| **KYC/AML** (`banxe`469, `banxe-digital`164) | EMI **Marble + Jube + Ballerine + OpenSanctions** | **wrap/reuse** | **P1** | EMI compliance stack strong (55–70%); wrap legacy signals into it, don't rewrite the engine |
| **`crypto-api`** (TS, 1,275) | EMI crypto wallet API | **wrap** | **P1** | Clean TS; wrap behind an EMI crypto port |
| **`banxe-digital`** (TS, 1,202) | EMI digital/cards surface | **wrap** | **P1/P2** | TS; cards are BIN-sponsor-gated, defer |
| **`crypto-processing`** (PHP/WordPress; `wordpress-shop-example` 9,611) | — (mostly vendor) | **rewrite / DROP** | **P2** | Predominantly a WordPress shop example + vendored WP; low migration value, likely drop |
| **`banxe_site`** (PHP, 3,409) | EMI customer site (React/TS per CLAUDE.md FE) | **rewrite** | **P2** | Legacy PHP front; EMI front is React/TS — rebuild, don't port |
| **`binarity-team`/`consul-configs`/`internal_dev`** (infra) | EMI infra (Postgres/ClickHouse/Redis, deploy) | **rewrite/replace** | **P2** | Devops/config; replace with the EMI infra stack |

## Top-5 P0 mappings (first migration candidates)

1. **risk/DSE/analytics → EMI DSE advisory** — reuse+small rewrite (lowest risk, highest alignment).
2. **money (bignumber.js) → EMI Decimal** — rewrite, invariant gate (I-01) before any money path.
3. **payments → EMI payment rails** — rewrite behind ClearBank/Modulr/Hyperswitch (critical EMI gap; high-risk, gated).
4. **wallets/accounts → Midaz LedgerPort** — wrap (best-tested legacy slice).
5. **KYC/AML → Marble/Jube/Ballerine** — wrap/reuse into the existing compliance stack.

Recommended **M1 = risk/DSE/analytics** (P0, smallest, safest, aligned). Payments/money are P0
by value but high-risk → require the pre-work in the risk register first.

## Duplication Audit (ADR-102)

Coverage (same scan as 3.2): full index 100,488 paths + 50,806-file snapshot; exts
`.ts/.js/.php/.py/.sql/.json`; the 5 hotspots — cross-package shared/DTO (243 pkgs / 3,431
shared / 2,999 dto / 7 dirs), generated Apollo clients (7 across 6 banxe sub-packages),
money/BigNumber (37 paths / 711+587 refs / 0 decimal.js), SQL/migration (74 .sql / 891
migrations / 6 dirs), vendored bundles (wp-includes 2,316 / vendor 1,012 / shop-example
9,611 / node_modules 0). No mapping that implies a delete/merge (DROP of crypto-processing,
dedup of shared/Apollo) may execute until its per-hotspot repo-wide audit confirms no hidden
consumer. Fail-closed; escalate on doubt.
