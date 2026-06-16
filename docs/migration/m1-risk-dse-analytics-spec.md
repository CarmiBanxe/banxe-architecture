# M1.0 — risk/DSE/analytics domain extraction spec (server-side, ADR-103)

> Recon + spec only (no code rewriting, no prod trading-platform edits). Produced
> server-side on evo1 from `/srv/banxe-legacy/work/banxe-code` (50,806 files),
> `docs/migration/{domain_map,to_emi_mapping}.md`, and `BANXE_MASTER_RESEARCH.md`.
> Every claim traces to the snapshot/index; "INSUFFICIENT EVIDENCE" where data is absent.

## 1. Headline finding (changes M1 scope)

The M0 "risk/DSE/analytics" keyword domain (153/74/64/49/14/13 hits) is **largely a
false-positive aggregate** — there is **no legacy DSE / quant / risk-analytics engine**.
Searching the full index for the EMI DSE-moat concepts returns essentially nothing:

| EMI DSE-moat concept | legacy index hits |
|---|---|
| market-making | 0 |
| fee-engine | 0 |
| quant | 10 (incidental) |
| execution/intent-preview | 0 |
| sentiment | 0 |
| stress / drawdown | 0 |
| kelly / sharpe | 0 |
| marketplace | 15 (incidental) |

⇒ **The EMI DSE advisory + moat (ADR-084, S12–S16, sandbox SBOX-1..6) is greenfield —
built by the factory, NOT derived from legacy. There is nothing to migrate into it;
doing so would duplicate delivered work (ADR-102).**

## 2. What the keyword domain actually decomposes into (concrete paths, LOC, lang, tests)

| Legacy thing | Path | LOC / files | Lang | Tests | Real domain |
|---|---|---|---|---|---|
| **AML risk-scoring** | `banxe/banxe-fiat-backend/banxe-identity/src/scoring-risk-level/` (+ `abs-risk-level.enum`, `aml-risk-level.enum`) | 589 LOC / 15 ts (full NestJS module: service/resolver/entity/dto/interface/module) | TS/NestJS | 0 | **KYC/AML** (not DSE) → out of M1 scope |
| **Earn / yield backend** | `banxe/banxe-crypto-earn/` (`crypto-earn-api`, `earn-config`, `earn-transactions`, `migrations`, graphql/dtos) | 7,020 LOC / 121 ts | TS/NestJS (typeorm, graphql, class-validator, schedule, event-emitter, microservices) | **0** | **Earn** — the only real DSE-adjacent module |
| **Dashboard charts (UI)** | `banxe/banxe-dashboard/src/.../*Chart*`, `RiskButton` | small | React/TS | n/a | frontend viz, not analytics |
| **Marketing pricing pages** | `banxe_site/**/pricing/`, `neuronext*/pricing/` | static | HTML/PHP | n/a | marketing, not an engine |
| **WordPress shop noise** | `crypto-processing/crypto-processing-wordpress-shop-example/` (44 hits) | vendor | PHP | n/a | vendor noise — exclude |

## 3. External deps & money-hotspot intersection

- `banxe-crypto-earn` deps: `@nestjs/{common,core,config,graphql,microservices,schedule,event-emitter,typeorm}`, `class-validator`. Integration points: TypeORM (DB), GraphQL (API), microservices/event-emitter (inter-service), `@nestjs/schedule` (rate jobs).
- **Money intersection = 0:** `banxe-crypto-earn` and `scoring-risk-level` use **neither `bignumber` nor `decimal.js`** (grep=0). This is a finding, not safety: any amount handling there is unverified for precision → the **money→Decimal (I-01)** pre-work from the risk register applies (must ADD Decimal, not just convert bignumber).

## 4. reuse / wrap / rewrite vs the existing EMI DSE (avoid duplication)

| Legacy component | EMI target | Strategy | Note |
|---|---|---|---|
| (no DSE/quant engine) | EMI DSE advisory + moat S12–S16 | **REUSE — do NOT migrate** | already delivered greenfield; migrating = duplication (ADR-102) |
| `banxe-crypto-earn` (earn/yield) | EMI **earn-rates advisory seam** (T7.5 `earn_rates` / DSE earn provider) | **wrap → rewrite** | real, bounded (7k LOC); 0 tests + no Decimal → heavy pre-work |
| `scoring-risk-level` (AML risk) | EMI AML (Marble/Jube) | **defer** | KYC/AML domain — OUT of M1 scope |
| dashboard charts / pricing pages | EMI React FE | rewrite (later) | frontend/marketing, not DSE |

## Duplication Audit (ADR-102)

Coverage: repo-wide search of the full index (100,488 paths) + snapshot (50,806 files),
exts `.ts/.js/.php`, for legacy risk/DSE/analytics implementations / DTOs / helpers that
overlap the **already-existing EMI DSE** (market-making, fee-engine, quant, execution-preview,
sentiment, stress, kelly/sharpe, marketplace, earn-rates).

- **Source-of-truth:** the EMI DSE advisory + moat (S12–S16) is the source-of-truth; it is
  greenfield. **Consumers:** the EMI backend + sandbox (SBOX-1..6) + frontend portal.
- **Legacy duplicates found:** **none** for the moat concepts (all 0 hits above). The only
  real adjacent legacy modules are `crypto-earn` (earn domain — maps to the earn-rates seam,
  not a duplicate of an existing DSE component) and `scoring-risk-level` (AML domain).
- **Decision:** **keep** the EMI DSE as-is (no merge from legacy); **do NOT delete/merge**
  anything; the earn module is a candidate to **wrap** (new earn seam wiring), not to dedup.
- **Fail-closed / escalate:** the keyword domain's ambiguity (AML-risk vs trading-risk) is a
  classic hidden-overlap trap → flagged; no structural change without per-module confirmation.

## M1 migration plan + RE-SCOPE recommendation

Because there is no legacy DSE engine, **M1 as "migrate risk/DSE/analytics" has no real
source** — proceeding would fabricate work. Recommendation:

- **Re-scope M1** to the one genuinely real, bounded, DSE-adjacent module: **`banxe-crypto-earn`
  → EMI earn-rates / DSE-earn advisory seam** (wrap, then selective rewrite). OR declare M1 a
  no-migration finding and pick a different first domain (e.g. the small `crypto-api`).

If M1 = earn (`banxe-crypto-earn`), the plan:
1. **Pre-work (blocking, from risk register):** add **characterization tests** (module has **0
   tests**); enforce **Decimal/I-01** on all amount fields (module uses neither bignumber nor
   decimal — add Decimal); reconcile its `migrations/` (part of the SQL/migration hotspot).
2. **Wrap:** expose the earn behaviour behind an EMI **EarnPort** (advisory/rate seam),
   mock-default, fail-closed — no live provider activation (operator-gated).
3. **Contract tests:** assert the wrapped earn matches the EMI earn-rates contract (DecimalString,
   advisory-only, no execution).
4. **Promote** per ADR-103 PART 2 (server-side + Duplication Audit) in a later M1.1 build sprint.

**Out of scope for M1:** payments, wallets/accounts, KYC/AML (incl. `scoring-risk-level`),
trading-core, crypto-processing/banxe_site PHP, vendored bundles. The greenfield EMI DSE
itself is **not migrated** (reuse).

INSUFFICIENT EVIDENCE (deferred to the M1.1 deep-read): exact earn amount-precision handling,
whether earn has any live-provider coupling, and the per-field DTO mapping to the earn-rates
contract — these need reading individual `crypto-earn` files, not just the index.
