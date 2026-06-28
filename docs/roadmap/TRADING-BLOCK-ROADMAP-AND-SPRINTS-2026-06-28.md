# BANXE-TRADING-001 — Road Map + Sprint Plan + Execution-Bridge

**File:** `docs/roadmap/TRADING-BLOCK-ROADMAP-AND-SPRINTS-2026-06-28.md`
**IL:** IL-714 (minted by `build_ledger.py` via the ADR-143 central allocator; provisional until merge-time freeze — ADR-119 Rule 8)
**Date:** 2026-06-28
**Status:** PROPOSED — docs-only road map; **no code, no runtime change, no new repo, no keys, no RAR content**
**Source:** factory (operator TASK, §71 single-writer)
**Track:** Trading Block (`banxe-trading-backend`), sprint series **S6.x** — a **separate track** from the EMI core-banking `ROADMAP-MATRIX.md` (departments A–K, Sprints 8–12). Do **not** cross-number the two.

> **⚠️ ADR-094 reconciliation (correction, 2026-06-29).** This road map (IL-714) originally listed **S6.6** (YieldPort) and **S6.7** (Hardening) as Phase-1 *executable* and **omitted any reference to ADR-094**. **ADR-094** (ACCEPTED, 2026-06-15, IL-237) canonically **DROPS S6.6 and S6.7 as out-of-scope for 2026** ("not part of the minimal core plus moat layer"); revival requires a **dedicated new ADR + IL** (operator decision). Per canon priority **ADRs > IL**, ADR-094 governs. The S6.6/S6.7 rows below are therefore corrected to **DROPPED per ADR-094**; their `earn/` advisory seam still exists (ADR-102 reuse) but is **not** a 2026 build obligation. The S6.6 build-spec PR **#875** is **HELD** pending an operator revival decision. All other rows (S6.2/6.4/6.5 built + S6.2-EN enable, S6.8, advisory seams, the three ADR-gated elements, SEC-1) are unaffected and stand.

---

## 0. Preamble — what this is, and the one discipline that governs it

**BANXE-TRADING-001** (the "13-section program", §1–§X) is a **greenfield DESIGN DOCUMENT**. A six-pass server-side audit of `BANXE.RAR` (evo1, read-only) returned **0 hits** for every program concept (trading engine, quant/DSE, gamification, agent-stack, software-factory, roadmap). The RAR contains only the **retired custodial lineage** — `crypto-api/*` + the BitShares-DEX fork `neuron/*` — already classified **ADR-083-retired / rebuild-not-port (IL-691)**.

The program does **not** map onto a from-scratch build. It maps onto an **existing, mostly-built sprint structure** in `banxe-trading-backend`. The governing discipline is therefore:

> **ADR-102 — reuse-not-rebuild.** Every item already shipped (ports S6.2–S6.5, DSE/Kelly, advisory seams, the EMI ARL swarm) is **enabled and extended, never rebuilt or re-imported.** Re-implementing a shipped port, or importing an external `ruvnet/ruflo`-style swarm over the built-in ARL, is an **ADR-102 violation.**

The **advisory moat** is the second invariant: the canonical end-to-end trajectory is **advice → unsigned intent → client signs/executes** (`dse-baas-component.md`). The trading backend **never** holds client keys and **never** executes autonomously (ADR-083 self-custodial; ADR-089/090/091 advisory seams).

All state in this road map is **PROPOSED / ODR-gated / ADR-gated**. This file changes nothing operational.

---

## A. §1–§X → canon map

Status legend: **BUILT** (shipped; ADR-102 reuse-not-rebuild) · **PROPOSED-MOCK** (seam built, mock-default, ODR-gated) · **ACCEPTED** (canon decision fixed) · **NET-NEW-GATED** (requires its own ADR + legal sign-off before any code) · **PROHIBITED** (excluded as buildable) · **GOV-DELTA** (must re-impose Banxe governance before adoption).

| Program area (§) | Canon owner | Status | Notes (verified) |
|---|---|---|---|
| Trading engine / venue model (§2, §3.1) | **ADR-083** (Composable DeFi Stack), ADR-021 (ExchangePort/MarketDataPort §D2/§D3) | **ACCEPTED** | MVP = **aggregate external liquidity** (dYdX v4 CLOB → LI.FI → StakeKit), **NOT a proprietary house MM-bot**. RAR trading = legacy CEX/DEX UIs only (**IL-691** rebuild-not-port). |
| dYdX MarketData / Exchange / Quote ports (§3.2) | ADR-021 + ADR-083 | **BUILT** | `ports/dydx_market_data.py`, `dydx_exchange.py`, `quote_port.py`, `lifi_quote.py`, `wallet_auth_port.py` — mock-default. **ADR-102 reuse.** See §B S6.2–S6.5. |
| Kelly / Half-Kelly sizing (DSE) (§3.3-A, §6) | **ADR-084** (DSE BaaS) | **BUILT** | `dse/kelly.py` + `dse/*` + 7 tests. **Advisory only — "never executes, signs, or holds keys."** **ADR-102 reuse.** |
| Quant pricing / Heston / Greeks / VaR (§3.3-B/C, §6) | **ADR-113** (PROPOSED) + **ADR-091** (mock) | **PROPOSED-MOCK** | `ports/quant_engine_port.py`, `api/quant.py`, `quant-engine-sandbox.md` — mock seam. Real models = **ODR-gated** (ADR-113 acceptance + absent `heston-solver.yaml`). |
| Market-making advisory seam (§4.1) | **ADR-089** | **PROPOSED-MOCK** | `ports/market_making_port.py` — advisory; live strategy host (Hummingbot sidecar) = **operator-gated ODR**. |
| Dynamic fee engine (advisory) (§4.5) | **ADR-090** | **PROPOSED-MOCK** | `ports/fee_engine_port.py` — advisory fee surface; autonomous live fee-setting = breach (see §3.3 row). |
| Sentiment (news / on-chain / social) (§6.8) | `dse-live-providers-options.md` | **PROPOSED-MOCK** | `SentimentProvider` seam (`BANXE_DSE_SENTIMENT_PROVIDER`), mock. **MiCA + PII (I-33) + provenance caveat** flagged. |
| DSE action space (HOLD/HEDGE/…) (§6.7) | ADR-084 | **BUILT (advisory)** | Trajectory = **advice → unsigned intent → execution** (`dse-baas-component.md`). DSE never executes. |
| Agent components — Ruflo/OpenClaw/MiroFish/MetaClaw (§6.8, §9.1) | `.claude/rules/agents.md`, IL-CANON-RUFLO | **BUILT (canon agents)** | Existing fleet, **not net-new naming**. External repo bindings (`ruvnet/ruflo`, `666ghj/MiroFish`, …) are **UNVERIFIED** → adoption = CLAUDE.md §9 gate + ADR-103. |
| ARL swarm / policy / reasoning-bank (§9.3) | **BUG-005** (Agent Routing Layer) | **BUILT (gated off)** | EMI `tests/test_agent_routing/` (swarm_orchestrator/policy/reasoning_bank/tier_workers), `AGENT_ROUTING_ENABLED=false`. **ENABLE+EXTEND — never re-import an external swarm (ADR-102).** |
| Yield / Earn (§3.3-C) | ADR-083 + **ADR-094** | **DROPPED (out-of-scope 2026)** | **ADR-094 (IL-237) closed S6.6 as DROPPED.** The `earn/` advisory seam exists (ADR-102 reuse) but **YieldPort is NOT a 2026 build obligation** — revival requires a dedicated new ADR + IL (operator decision). |
| HEDGE-with-PUT option (§6.7) | ADR-083 | **OUT-OF-MVP** | dYdX v4 has **no options venue** → no MVP venue; options post-MVP. |
| Hummingbot / Enso / OctoBot execution bots (§7.1) | ADR-046, ADR-089, ADR-083 | **ACCEPTED (internal-only)** | "future strategy sidecar, **not a port**"; **internal-analytics-only**; client offering = OUT-OF-SCOPE. |
| AGPL handling — dYdX, MiroFish, Jube (§7) | **ADR-140** (RD-03), ADR-004, ADR-083 §7 | **ACCEPTED** | dYdX consumed **API-only via public Indexer — no §13 trigger**; **MiroFish/Jube AGPL-3.0 = internal-use-only fence** (no BaaS externalisation). |
| BaaS / Kong gateway (§7, §9.2) | ADR-083 | **PENDING BUILD** | RAR gateway = legacy **Apollo federation**, not Kong → Kong is **net-new build**, not a port. |
| MetaClaw RL auto-adaptation of risk-profile (§6.10, §9.3) | **NET-NEW** | **NET-NEW-GATED ②** | 0 canon hits. **GDPR Art. 22** automated-profiling + advisory-moat. BUG-001: MetaClaw = **dev-time gate, NOT runtime**. New ADR + legal before code. |
| Autonomous MM + RL/DDQN execution (§3.3-B, §4.3) | **NET-NEW** | **NET-NEW-GATED ①** | **MiCA broker-dealer / MiFID investment-firm** reclassification. Breaches advisory moat. New ADR + legal before code. |
| AgentFi autonomous infra (ElizaOS/Olas/Orbs) (§7.5) | **NET-NEW** | **NET-NEW-GATED ③** | 0 canon hits. **EU AI Act Art. 14** human-oversight; conflicts with the pervasive *no-autonomous-execution* canon. New ADR + legal before code. |
| Real-money gamblification — VRRS / near-miss / leaderboards (§7.6) | **ADR-100** | **PROHIBITED** | ADR-100 permits **sandbox / educational demo ONLY**; real-money VRRS/near-miss explicitly **prohibited**. Excluded from the road map as buildable. |
| §9 autonomous swarm + auto-merge topology (§9.3–9.5) | Banxe canon | **GOV-DELTA** | See §D-GOV. Must re-impose operator-gated merge + Ruflo+HITL + AI-plane PII gateway + AGPL fence before any §9 adoption. |

---

## B. Sprint plan — continuing the S6.x track (enable-not-build)

> The Sprint-6.1 HANDOFF (`HANDOFF-composable-defi-stack-integration.md`) is marked "DRAFT — no integration code", but the trading-backend tree shows the **S6.2–S6.5 ports already landed** (mock-default). This plan therefore continues from a **mostly-built** base: the immediate work is **finish two pending builds + enable**, not build-from-zero.

### PHASE 1 — immediately executable (lowest-gate; **no keys, no legal sign-off**)

> **Correction (ADR-094):** S6.6 and S6.7 are **NOT** in Phase 1 — they are **DROPPED per ADR-094** (see the two rows below, marked ⛔). The genuinely-executable Phase-1 items are **S6.8** and **S6.2-EN** only.

| Sprint | Goal | Port/module | Gate | Acceptance | Advisory-moat |
|---|---|---|---|---|---|
| **S6.6** ⛔ | **YieldPort + StakeKit/Yield.xyz adapter** *(closed)* | `ports/yield_port.py` | ⛔ **DROPPED per ADR-094** — closed for 2026; may return only via a dedicated ADR + IL (operator decision) | *(former scope, retained for reference: port contract + mock impl + conformance test; atomic-unit strings (I-01); fail-closed)* | *(advisory-moat retained for any future revival: unsigned staking tx; client signs; no custody)* |
| **S6.7** ⛔ | **Hardening** — per-port conformance suites + MiCA/AML review hooks *(closed)* | all ports; `tests/test_ports.py` | ⛔ **DROPPED per ADR-094** — closed for 2026; may return only via a dedicated ADR + IL (operator decision) | *(former scope, retained for reference: snapshot-on-gap, idempotency/error-map, quote-fidelity; ADR-016 hook points)* | *(hooks were advisory/observability; no execution path)* |
| **S6.8** | **FE↔BFF mock-live wiring** — connect `banxe-trading-frontend` `trade-proxy.ts` (`:8080`) to the BFF over the **mock** feed | BFF REST/WS surface (no new repo) | **executable** (mock data; no keys) | FE renders order-book + places **unsigned** orders against mock ExchangePort; deterministic mock feed (IL-185) preserved as CI default | order = unsigned intent surfaced to client wallet; backend signs nothing |
| **S6.2-EN** | **Enable S6.2 sandbox-live** via **public dYdX Indexer** (`v4_orderbook`) — **no key required** | `dydx_market_data.py` flag flip | **executable** (public market data; API-only AGPL-safe) | `BANXE_DSE_MARKET_PROVIDER=dydx` + `BANXE_DSE_MARKET_MODE=sandbox-live` with `BANXE_DSE_LIVE_ALLOWED=true`; mock stays CI default | read-only market data; no orders, no keys |

**Phase-1 exclusions:** no order placement against a live venue (needs S6.4 keys = Phase 2); no prod-live; no new ADR-gated capability.

### PHASE 2 — ODR-gated (after the 5 operator decisions + keys land)

| Sprint | Goal | Port/module | Gate | Acceptance | Advisory-moat |
|---|---|---|---|---|---|
| **S6.4-EN** | dYdX **ExchangePort sandbox-live** — place/cancel/status as **unsigned** orders | `dydx_exchange.py` | **ODR-gated** (ODR-1 dYdX subaccount/addr; ODR-3 MiCA stance) | unsigned orders signed on FE; idempotency on `clientOrderId`; sandbox testnet first | client signs every order; backend holds no keys |
| **S6.5-EN** | QuotePort **LI.FI live** + per-layer provider selection | `lifi_quote.py` / `quote_port.py` | **ODR-gated** (ODR-1 integrator+fee addr; ODR-2 LI.FI vs 0x vs Rubic) | `/quote`, `/routes`, `/quote/build` return unsigned tx; provider chosen via config | quote/route only; unsigned build |
| **S6.6-EN** ⛔ | YieldPort **StakeKit live** *(contingent)* | `yield_port.py` | ⛔ **Contingent on a future S6.6-revival ADR** (S6.6 currently **DROPPED per ADR-094**) — *then* ODR-gated (ODR-1 StakeKit key; ODR-2 yield scope) | live yields + unsigned staking tx; sandbox first | non-custodial; unsigned |
| **S6.x-PROD** | Per-domain **sandbox-live → prod-live** promotion | all | **ODR-gated** (all 5 ODR + ODR-3 MiCA/CASP + Travel Rule) | `BANXE_DSE_PROVIDER_MODE=prod-live` per domain; master kill-switch `BANXE_DSE_LIVE_ALLOWED` retained; per-domain override | unchanged: advice → unsigned → client-signs |

### PHASE 3 — new-ADR-gated (author ADR + legal sign-off **before any code**)

| Item | ADR-stub | Gate | Note |
|---|---|---|---|
| **① Autonomous MM + RL/DDQN execution** (§3.3-B/§4.3) | ADR-stub **①** | **legal first** | MiCA broker-dealer / MiFID investment-firm reclassification. **Not buildable** until ADR accepted + legal sign-off. Breaches advisory moat by definition. |
| **② MetaClaw RL auto-adaptation of risk-profile** (§6.10/§9.3) | ADR-stub **②** | **legal first** | GDPR Art. 22 automated-profiling. Must keep **MetaClaw = dev-time-only (no runtime RL)** (BUG-001) until/unless ADR + DPIA clear it. |
| **③ AgentFi autonomous infra** (§7.5) | ADR-stub **③** | **legal first** | EU AI Act Art. 14 human-oversight. Conflicts with no-autonomous-execution canon. |

### EXCLUDED (not on the buildable road map)

- **Real-money gamblification (§7.6)** — **PROHIBITED** (ADR-100: sandbox/educational demo only). A demo/learning gamification layer (SBOX-5) is the *only* permissible form and is already scoped under ADR-097/098/099/100.
- **Rebuild of shipped ports / DSE / ARL** — **ADR-102 violation.** S6.2–S6.5 ports, `dse/*`, and the EMI ARL swarm are reuse-not-rebuild. External `ruvnet/ruflo`-style swarm import over the built-in ARL is forbidden.

---

## C. Per-sprint advisory-moat compliance (canonical clause)

Every Phase-1/2 sprint above conforms to the **advisory moat**: the backend produces **advice** (DSE recommendation, quote, route, sizing) → renders an **unsigned intent** (order/tx) → the **client's self-custodial wallet signs** → execution happens on-chain. The backend **never holds private keys** (ADR-083 self-custodial; `no user private keys in backend`), **never executes autonomously** (ADR-089/090/091 advisory seams), and every regulated path runs through **ARL → Ruflo → HITL** (BUG-005/007). Any sprint that would add an autonomous-execution path is **Phase 3 (ADR-gated)** by construction.

---

## D. Open-decisions register

### D-ODR — ADR-083 §7 "OPERATOR DECISION REQUIRED" (5; none decided; block promotion, not Phase-1 code)

| # | Decision | Blocks |
|---|---|---|
| **ODR-1** | Integrator keys/addresses — LI.FI integrator string + fee-collection address; StakeKit API key; dYdX subaccount/wallet addresses (env-only, none committed) | S6.4-EN, S6.5-EN, S6.6-EN *(contingent — S6.6 DROPPED per ADR-094)* |
| **ODR-2** | Per-layer provider selection — QuotePort (LI.FI vs 0x vs Rubic); dYdX market set; yield provider scope | S6.5-EN, S6.6-EN *(contingent — S6.6 DROPPED per ADR-094)* |
| **ODR-3** | AML/MiCA legal stance — CASP classification, Travel Rule applicability, MiCA surface (ADR-016) | S6.x-PROD, all live order paths |
| **ODR-4** | dYdX AGPL consumption mode — **API-only recommended** (public Indexer, no §13 trigger) vs vendoring | S6.2-EN (already API-only) / any vendoring |
| **ODR-5** | OpenDAX community-vs-commercial (reference UI) | optional FE decision |

### D-ADR — three net-new ADR-stubs (Phase 3; legal sign-off before code)

| # | ADR-stub | Regulatory gate |
|---|---|---|
| **①** | Autonomous MM + RL/DDQN execution | MiCA broker-dealer / MiFID investment-firm |
| **②** | MetaClaw RL auto-adaptation of risk-profile | GDPR Art. 22 automated-profiling (DPIA) |
| **③** | AgentFi autonomous infra | EU AI Act Art. 14 human-oversight |

### D-PROHIBITED

- **Real-money gamblification (§7.6)** — ADR-100 prohibits; sandbox/educational demo only. Not a gate; an exclusion.

### D-GOV — §9 governance delta (re-impose **before** any §9 adoption)

The §9 topology (Perplexity → 98-agent Raft/BFT swarm → auto-merge) is a **different governance architecture** than Banxe canon. To adopt any §9 element, re-impose:

1. **Operator-gated merge (§71)** — coverage ≥90% does **not** auto-authorise merge.
2. **ARL → Ruflo + HITL** mandatory on `payment`/`compliance`/`kyc` (BUG-005/007) — the §9 topology must not bypass the regulatory pre-filter.
3. **MetaClaw = dev-time-only** (BUG-001) — no runtime RL loop (ties to ADR-stub ②).
4. **AI-plane PII gateway (I-33)** — no transparent LLM proxy bypassing PII filtering.
5. **AGPL internal-only fence (ADR-140 §13)** — MiroFish/Jube not externalisable in BaaS.
6. **External repo provenance** — `ruvnet/ruflo`, `666ghj/MiroFish`, `openclaw/openclaw`, `aiming-lab/MetaClaw` are **UNVERIFIED**; adoption = CLAUDE.md §9 (rules-based + human-in-the-loop) + ADR-103 (server-only) + sanctioned-jurisdiction check (DO-NOT RU/IR/KP/BY/SY).

### D-SEC — tracked hygiene item

| # | Item | Severity | Status |
|---|---|---|---|
| **SEC-1** | AWS **presigned URLs** in 3 master-documents (`docs/master-document/01-master-full.md` ×3, `02-unified-stack.md` ×1, `03-gap-overlay.md` ×1) — STS temp creds, **already expired** (`Expires` ~2026-04-02), entered at commit `9f155b0` | LOW (dead creds; hygiene + detector gap) | **OPEN** — proportionate fix = scrub-to-bare-URL (5 spots) + add `.gitleaks.toml` presigned-URL rule; **history-rewrite NOT warranted** (expired). Separate operator-gated PR. |

---

## Anchors / references (verified, read-only)

- **ADR-083** Composable DeFi Stack (MVP dYdX v4 → LI.FI → StakeKit; §7 OPERATOR DECISION REQUIRED; AGPL API-only)
- **ADR-084** DSE BaaS (Kelly/Half-Kelly; "never executes, signs, or holds keys")
- **ADR-089** market-making advisory seam · **ADR-090** dynamic-fee advisory seam · **ADR-091** quant-engine advisory seam (mock)
- **ADR-100** sandbox educational gamification (SBOX-5; real-money VRRS/near-miss prohibited)
- **ADR-113** quant pricing/risk advisory (PROPOSED; `heston-solver.yaml` absent)
- **ADR-140** RD-03 AGPL boundary (Jube/MiroFish §13 internal-only) · **ADR-004** Jube adapter
- **ADR-102** no-smart-refactor-without-duplication-verification (reuse-not-rebuild) · **ADR-103** server-only refactoring · **ADR-119** stable IL numbering · **ADR-016** AML/PII routing
- **BUG-001** MetaClaw = dev-time gate (not runtime) · **BUG-005** ARL pipeline · **BUG-007** HITL thresholds
- **IL-691** RAR trading-core rebuild-not-port · **IL-CANON-RUFLO** Ruflo regulated pipeline
- `HANDOFF-composable-defi-stack-integration.md` (S6.x plan) · `dse-live-providers-options.md` (provider flags) · `dse-baas-component.md` (advice→unsigned-intent→execution) · `HANDOFF-trading-frontend-backend-integration.md` (FE↔BFF)
- Provenance: six read-only `BANXE.RAR` server audits (evo1) + EMI `3fc21f9` audit + `banxe-trading-backend` tree (2026-06-28). **No RAR content imported; no code; no secrets.**

> **Scope reaffirmation.** This file is docs-only. It creates no code, changes no runtime, creates no repo, supplies no keys, touches no FROZEN port/contract, and pulls no RAR content. Every already-built item is marked **reuse-not-rebuild (ADR-102)**. The IL number is provisional (ADR-119 Rule 8) until merge-time freeze.
