# BANXE legacy domain map (M0 task 3.2)

Derived from the unlocked snapshot `/srv/banxe-legacy/work/banxe-code` (50,806
code/text files), `output/m0_signals.md`, and the file index (100,488 paths). Mechanical
signals only; judgements are traceable to the counts below — no fabrication.

## Stack reality (per top-level dir, by file extension)

| Dir | Files | Stack (evidence) |
|---|---|---|
| `banxe` | 26,496 | **TypeScript / NestJS monorepo** (ts=19,820, php=0, py=3); 243 packages total; 502 test files |
| `neuron` | 6,654 | mixed **PHP + TS** (php=1,406, ts=1,141) |
| `crypto-processing` | 6,699 | **PHP / WordPress** (php=3,783, ts=314; `wordpress-shop-example` = 9,611 paths) |
| `banxe_site` | 5,705 | **PHP** (php=3,409, ts=295, py=117) |
| `internal_dev` | 2,087 | JS / Python / Shell (1 test file) |
| `crypto-api` | 1,275 | **TypeScript** (ts=895) |
| `banxe-digital` | 1,202 | **TypeScript** (ts=1,132, sql=8) |
| `binarity-team` | 426 | Python / Shell (infra) |
| `consul-configs`/`dcard`/`ilink`/`(root)` | small | Shell/configs / SQL |

Backend stack = **NestJS** (`@nestjs` 9,564 import refs, `typeorm` 1,622, `class-validator`
736); frontend = **React + effector** (React 2,967, `effector-react` 667, `react-i18next`
1,033, `@linaria` 1,407); money = **bignumber.js** (`BigNumber` 711 + `bignumber` 587;
`decimal.js` = 0); GraphQL via `graphql-request` 707 + generated Apollo clients.

## Domain → key modules → external deps → quality

| Domain | Key legacy modules (keyword hits) | External deps | Quality notes |
|---|---|---|---|
| **Payments** | `banxe`(3,604), `crypto-processing`(204), `banxe_site`(169) | @nestjs, typeorm, bignumber | LARGEST + regulated; mixed TS(banxe)/PHP(crypto-processing); banxe slice tested, PHP slices thin |
| **Wallets/accounts** | `banxe`(2,664), `neuron`(785), `banxe-digital`(734), `crypto-api`(239) | @nestjs, typeorm, class-validator | large; banxe well-tested (502), neuron/digital thin |
| **Trading-core** | `banxe`(536), `crypto-processing`(213), `neuron`(120) | typeorm, bignumber, graphql | moderate; split TS/PHP |
| **KYC/AML** | `banxe`(469), `banxe-digital`(164), `banxe_site`(28) | class-validator | regulated; verify against MLR/FCA |
| **Risk/DSE/analytics** | `banxe`(153), `crypto-processing`(74), `binarity-team`(64) | bignumber | SMALLEST footprint; binarity-team is Python |
| **Infra** | `banxe`(1,202), `binarity-team`(426), `consul-configs`(209) | consul, shell, docker | devops/config; binarity-team Python tooling |

God-object hints (≥1000 LOC) are predominantly **vendored bundles** (`wp-includes/dist/*`,
`pdfmake.js`, `jquery-ui`) and **generated Apollo clients** (`__generated__/index.ts`,
36–40k LOC) — not hand-written god objects. INSUFFICIENT EVIDENCE for deeper per-service
coupling without reading individual files (deferred to M1 per-domain deep-read).

## Duplication Audit (ADR-102)

Coverage: scanned the full index (100,488 paths) + the snapshot tree (50,806 files), all
top-level dirs, extensions `.ts/.tsx/.js/.php/.py/.sql/.json`. Five hotspots:

1. **cross-package shared/DTO** — 243 `package.json`; 3,431 files under a `shared/` dir;
   2,999 `*.dto.*`/`dto/` files; across 7 top dirs (banxe, banxe-digital, banxe_site,
   crypto-api, crypto-processing, internal_dev, neuron). → source-of-truth + consumers
   unresolved; **no merge** until M1 audit.
2. **generated Apollo clients** — 7 `__generated__/index.ts` (banxe_auth, banxe-dashboard,
   banxe-frontend-demo, banxe-manual-payments, common_auth_web, tompayment-web). → regenerate
   from one schema; never hand-merge.
3. **money/BigNumber** — 37 bignumber paths; 711+587 import refs; `decimal.js`=0. → single
   money source-of-truth unconfirmed (legacy=bignumber.js, EMI mandates Decimal/I-01).
4. **SQL/migration fragments** — 74 `.sql`; 891 under `migrations/`; across 6 dirs (banxe,
   banxe-digital, banxe_site, crypto-processing, internal_dev, neuron). → reconcile before
   schema move.
5. **vendored bundles** — `wp-includes/` 2,316; `vendor/` 1,012; `wordpress-shop-example`
   9,611; `node_modules/`=0 (excluded). → exclude/drop; verify no app forks a copy.

Verdict: all five carry hidden-dependency risk; **no delete/merge/dedup** permitted until a
repo-wide ADR-102 audit per hotspot in M1. Fail-closed.
