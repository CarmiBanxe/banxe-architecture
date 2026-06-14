# FU-2 Live Activation Diagnostics (Phase 1) — 2026-06-14

> **READ-ONLY DIAGNOSTICS — NO MUTATIONS.** This document captures the Phase 1
> diagnostic findings for the FU-2 "live activation" workstream as a durable audit
> artifact. No code, configuration, infrastructure, or Intent Layer state was
> changed while producing it. It is the input to — not a record of — any later
> execution work.

## Metadata

| Field | Value |
| --- | --- |
| **Date** | 2026-06-14 |
| **Workstream** | FU-2 — live activation of LLM gateway, decision lineage sink, and Intent Layer cross-repo wiring |
| **Phase** | Phase 1 — diagnostics (this document) |
| **Mode** | READ-ONLY DIAGNOSTICS — NO MUTATIONS |
| **Repos inspected** | `banxe-architecture`, `banxe-emi-stack`, `banxe-payment-core` |
| **Reference baseline** | `origin/main` of each repo (see CRITICAL DRIFT below) |
| **Subsystems** | LLM-gateway (LiteLLM v2), ClickHouse + DecisionRecorder, Intent Layer (L1–L4) + cross-repo wiring |

## Scope

Phase 1 inspected three live-activation surfaces and the git hygiene of the trees
they live in:

1. **LLM-gateway** — the LiteLLM v2 deployment that fronts model routing.
2. **ClickHouse + DecisionRecorder** — the persistent sink for decision lineage.
3. **Intent Layer + cross-repo wiring** — the L1–L4 stack and the (missing) HTTP
   path between `banxe-emi-stack` and `banxe-payment-core`.

All conclusions below are derived from inspection of `origin/main` and the running
host, **not** from the stale local working trees (see the next section for why that
distinction is load-bearing).

---

## CRITICAL DRIFT

The single most important finding of Phase 1 is **git drift**: the local working
trees consulted during diagnostics are materially behind their remotes.

- **`banxe-emi-stack`** — local tree is **20+ commits behind `origin/main`**.
- **`banxe-architecture`** — local tree is **20+ commits behind `origin/main`**.

**Consequence.** Any conclusion drawn from the *local* state of these repos is
unsafe: a file, flag, adapter, or endpoint that appears "missing" locally may
already exist on `origin/main`, and vice-versa. Therefore **all diagnostics in this
document are recorded against `origin/main`**, and any execution work in later
phases MUST begin by fast-forwarding the local trees to `origin/main` and
re-confirming each finding before acting on it.

**Rule for Phase 2+.** Treat the local checkout as untrusted until it is level with
`origin/main`. Do not file, plan, or implement against local-only observations.

---

## LLM-GATEWAY — CURRENT STATE

**Where it runs today.**

- LiteLLM **v2** runs on the **Legion** host.
- Exposed on **port `:4000`** (LiteLLM proxy) and **port `:8080`** (companion
  surface).
- Backed by **PostgreSQL** (config/spend/keys persistence) and **Redis** (caching /
  routing state).
- Routing configuration lives in the LiteLLM v2 config (model list, aliases,
  fallbacks) on the host.

**What is missing to cold-start and healthcheck it reproducibly.**

- **No committed compose/orchestration file** that brings the gateway up from a
  clean host (LiteLLM proxy + Postgres + Redis as one reproducible unit).
- **No committed env template** enumerating the variables the gateway requires
  (DB URL, Redis URL, master key, provider keys) — today these live only as host
  state.
- **No runbook** describing cold-start, healthcheck, and teardown — i.e. no
  documented `/health` (or equivalent) probe sequence and expected responses.

**CI hooks.**

- **None.** There is no CI job that lints the LiteLLM config, validates the model
  list/routing, or smoke-tests gateway bring-up. The gateway is currently a
  host-only, manually-operated artifact with no automated reproducibility guarantee.

---

## CLICKHOUSE DECISIONRECORDER — CURRENT STATE

**What exists.**

- **ClickHouse services** are present and deployable.
- A **DecisionRecorder ABC** (abstract base class / port) defining the lineage-sink
  contract exists.
- Supporting **migration scaffolding** is present in the relevant repo.

**What does NOT exist.**

- **`ClickHouseDecisionRecorder`** — the concrete ABC implementation that writes
  decision lineage to ClickHouse is **absent**.
- **`decision_records` table** — the target ClickHouse table (schema + migration)
  for the sink does **not** exist.
- **Selection factory** — there is no factory wiring that selects the ClickHouse
  recorder over the default.

**Net effect.** The lineage sink is **in-memory only** today. Decision records are
not durably persisted; on process restart, lineage is lost. The ABC + ClickHouse
services are the foundation, but the concrete recorder, its table, and the factory
that activates it are all still to be built.

---

## INTENT LAYER & CROSS-REPO WIRING — CURRENT STATE

**Feature flags.**

- **`INTENT_LAYER_ENABLED=false`** by default — the Intent Layer ships dark and is
  not active out of the box.

**L1–L4 stack.**

- **L1–L4 are present on `origin/main`** of the relevant repo(s).
- **Real vs. stub:** the **L3 adapters are a mix** — some are real integrations,
  others are stubs. Phase 2 must enumerate which L3 adapters are real and which are
  placeholders before relying on any L3 path.

**Cross-repo wiring — the gap.**

- **No HTTP surface from `banxe-emi-stack` to `banxe-payment-core`** for the
  payment-relevant flows (payments, FX, wallet). The intended call path is not
  wired.
- **No agent-dispatch endpoint in `banxe-payment-core`** — there is no receiving
  endpoint for the Intent Layer / emi-stack to dispatch agent-driven actions into
  payment-core.
- Correspondingly, **no HTTP clients** in `banxe-emi-stack` targeting those (yet to
  exist) payment-core endpoints.

**Net effect.** Even with `INTENT_LAYER_ENABLED=true`, there is currently no live
HTTP path carrying payment/FX/wallet intents from emi-stack into payment-core; the
cross-repo dispatch seam is unimplemented on both ends.

---

## PROPOSED FU-2 EXECUTION PLAN (HIGH LEVEL)

The ordered steps below are the high-level Phase 1 plan. They are **intentionally
non-implementing** — sequencing only, no code or config in this document. Each step
is gated on the prior one and on a re-confirmation against `origin/main`.

- **Step 0 — De-drift.** Fast-forward local `banxe-emi-stack` and
  `banxe-architecture` to `origin/main`; re-confirm every Phase 1 finding against
  the fresh trees before any execution.
- **Step 1 — Gateway reproducibility.** Author the committed compose/orchestration
  + env template for LiteLLM v2 (proxy + Postgres + Redis) so the gateway cold-starts
  from a clean host.
- **Step 2 — Gateway runbook + healthcheck.** Document cold-start, healthcheck
  probe sequence, and teardown.
- **Step 3 — Gateway CI hook.** Add a CI job that validates the LiteLLM config and
  smoke-tests bring-up.
- **Step 4 — Decision table.** Define the `decision_records` ClickHouse schema and
  migration.
- **Step 5 — ClickHouse recorder.** Implement `ClickHouseDecisionRecorder` against
  the existing ABC.
- **Step 6 — Recorder factory.** Add the selection factory + flag that activates the
  ClickHouse recorder over the in-memory default.
- **Step 7 — L3 adapter inventory.** Enumerate real vs. stub L3 adapters; mark which
  are safe to activate.
- **Step 8 — payment-core dispatch endpoint.** Add the agent-dispatch endpoint in
  `banxe-payment-core` for payments/FX/wallet.
- **Step 9 — emi-stack HTTP clients.** Wire the HTTP client(s) in `banxe-emi-stack`
  to the new payment-core endpoint(s).
- **Step 10 — Staged activation.** Flip `INTENT_LAYER_ENABLED` in a gated/staged
  manner with the lineage sink and gateway proven healthy first.

> Steps 1–10 are scoped to their respective repos (`banxe-emi-stack`,
> `banxe-payment-core`) and are **out of scope** for this audit PR, which only adds
> this document to `banxe-architecture`.

---

## SECRETS / OPERATOR INPUT REQUIRED

The following must be supplied by the operator before the corresponding execution
step can run. **No concrete values are recorded here** — only the names of what is
required.

**LLM-gateway (LiteLLM v2):**

- LiteLLM master / admin key.
- Upstream model-provider API key(s) for each routed provider.
- PostgreSQL connection URL (host, db, user, password) for the gateway store.
- Redis connection URL for gateway caching/routing state.

**ClickHouse / DecisionRecorder:**

- ClickHouse connection details (host, port, database, user, password) for the
  `decision_records` sink.

**Intent Layer cross-repo wiring:**

- Base URL(s) for the `banxe-payment-core` agent-dispatch endpoint.
- Service-to-service auth credential/token for the emi-stack → payment-core HTTP
  client(s).
- The value/policy for flipping `INTENT_LAYER_ENABLED` per environment.

> All of the above are operator-provided secrets/config and MUST be injected via the
> environment / secret store — never committed.

---

*Generated as the Phase 1 audit artifact for FU-2. Phase 2.A = this document.
No mutations were performed outside adding this file.*
