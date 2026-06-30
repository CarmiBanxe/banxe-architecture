# ODR-1: DeFi integrator keys & addresses (operator provisioning decision)

**Status:** PROVISIONING-CONFIRMED (operator §1/§9, 2026-06-30)
**Date:** 2026-06-30
**Provisioning confirmation:** 2026-06-30 — operator confirms the dYdX integrator values are **provisioned in the vault** and the **env schema below is confirmed** (§1/§9 factual signal). No values are recorded here (RED-zone — vault/secret-store only). This satisfies the **ODR-1** gate for S6.4-EN; **S6.4-EN remains blocked on ODR-3 (MiCA stance) + operator GO** (this confirmation unblocks only ODR-1, not live execution).
**Type:** Operator Decision Record (ODR) — resolves ADR-083 §"OPERATOR DECISION REQUIRED" item 1
**Anchors:** ADR-083 (Composable DeFi Stack) §7 ODR-1 · ADR-114 (Travel-Rule / CASP) · ADR-016 (AML/PII routing) · `docs/specs/dse-live-providers-options.md`
**Gates:** S6.4-EN (dYdX live order placement) · S6.5-EN (LI.FI quote-live) · *(S6.6-EN DROPPED per ADR-094)*
**Plane:** banxe-architecture = decision record only. Ships no runtime code; introduces **no secret values**. Additive (ADR-119 append-only).

> **RED-ZONE — no values here.** This record fixes **which** integrator credentials/addresses are needed, **where** they live (vault), and the **env-var schema** that consumes them. It contains **NO key/address/secret values**. Provisioning the actual values is the operator's act (vault, your hands); the factory never enters credentials (§9: prepares materials only).

## Context

S6.4-EN (dYdX ExchangePort sandbox-live → live order placement) and the other Phase-2 live providers are **operator-gated (ODR-1)** per ADR-083 §7: they require integrator keys / addresses that are **env-only, none committed**. The backend adapter already exists and is **fenced off** — live submission cannot activate until both the env values are provisioned **and** the kill-switch is flipped (see the existing config fields below). This ODR records the provisioning decision; it does not provision.

## Decision required (operator)

Provision the following **into the vault / deployment secret store only** (never committed; never in this repo), and record their **vault reference paths** + confirm the **env-var schema** below. The factory drafts the schema; the operator supplies values out-of-band.

### Scope for S6.4-EN (dYdX live order placement) — the immediate gate
The backend already exposes these **public config fields** (names are schema, not secrets) — they are populated from env at deploy:

| Config field (existing) | Role | Provisioning |
|---|---|---|
| `dydx_node_url` | dYdX v4 node endpoint for on-chain submission | env ← vault ref; **sandbox/testnet first** |
| `dydx_subaccount_number` | dYdX subaccount selector | env (non-secret integer) |
| `dydx_builder_address` | builder/fee-collection address | env ← vault ref |
| `dydx_builder_fee_ppm` | builder fee (ppm) | env (non-secret config) |
| `dydx_submit_enabled` | **master kill-switch** for live submission (default `False`) | env; flip to `true` **only** with a valid `dydx_node_url` (else fail-closed) |
| `dydx_submit_timeout_s` | submission timeout | env (non-secret config) |

**Self-custodial invariant (unchanged):** even with these set, the **client wallet signs every order**; the backend constructs the **unsigned** intent and **holds no wallet keys** (ADR-083). `dydx_node_url`/addresses are integrator/submission config, **not** custody of client keys.

### Full ODR-1 scope (other live providers — record now, provision when their sprint lands)
- **LI.FI** integrator string + fee-collection address (S6.5-EN quote-live).
- **StakeKit / Yield.xyz** API key — *contingent: S6.6-EN is DROPPED per ADR-094; do not provision unless revived by a dedicated ADR + IL.*

## Constraints (RED-zone, fail-closed)

1. **No values in git** — keys/addresses live in the **vault / GH-Actions secrets** only; this repo and all docs carry **pointers/schema only** (Configuration-over-Hardcoding §10; egress = 0).
2. **Kill-switch + fail-closed** — `dydx_submit_enabled` defaults `False`; any non-mock/live combination without valid config **fails closed** at startup (existing `assert_mock_only` / submission guard).
3. **Sandbox/testnet first** — provision the dYdX **testnet** path before mainnet; mainnet is a separate explicit step.
4. **Ruflo + HITL on execution** — the live order-execution surface is payment/compliance-classed → **Ruflo mandatory** (`.claude/rules/agents.md`) + HITL on order, enforced at S6.4-EN build (not this record).
5. **Pairs with ODR-3** — live execution also requires the **MiCA stance** (ODR-3); S6.4-EN unlocks only when **both ODR-1 and ODR-3** are decided.

## Blocker

**P-prov — AWAITS operator provisioning** of the dYdX integrator endpoint + addresses into the vault, plus confirmation of the env schema above. Owner: operator (provisioning) + platform. This record is the checklist; the values are supplied out-of-band.

## Related

ADR-083 §7 (ODR-1) · ADR-114 (Travel-Rule/CASP) · ADR-016 (AML/PII) · ADR-094 (S6.6 dropped — StakeKit contingent) · `docs/specs/dse-live-providers-options.md` · roadmap S6.4-EN/S6.5-EN rows · backend `config.py` (the `dydx_*` fields above), `ports/dydx_exchange.py`, `services/intent_preview.py`. Pairs with **ODR-3** (MiCA stance).

> **Governance:** DRAFT decision record. It enumerates the provisioning need + env schema; it provisions **nothing** and contains **no values**. Promotion to ACCEPTED = the operator confirms provisioning (vault paths populated) per §1/§9. Prepared as a **DRAFT PR — DO NOT MERGE** without operator sign-off. Pairs with ODR-3 before any S6.4-EN build.
