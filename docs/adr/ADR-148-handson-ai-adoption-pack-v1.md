---
id: ADR-148
title: Hands-On-AI-Engineering adoption pack v1 — delta-grounded patterns, Ruflo+LiteLLM+vault-bound (read-only selection, not import)
status: PROPOSED
date: 2026-06-28
concept_only: false
relates:
  - "ADR-117 (factory↔project perimeter)"
  - "ADR-135 (held-out adoption gate — promotion mechanism; the self-reflective loop is NOT this gate)"
  - "ADR-137 + MEMOIR-PILOT-PRECOND-06/07 (RED ZONE fail-closed / no-authority-expansion)"
  - "ADR-143 / ADR-143-A (central allocator), ADR-145 Factory⊕Project fork target model (#852, IL-668), ADR-146 execution-sandbox-contract"
  - "Ruflo mandatory middleware (banxe-architecture/ruflo, banxe-emi-stack/infra/ruflo); LiteLLM egress seam (MetaClaw litellm-config.v2.yaml :4000); services/compliance_kb RAG; services/swarm/orchestrator.py; ~/banxe-fabric/.vault"
il_anchor: IL-695
il_anchor_note: "Provisional per ADR-119 Rule 8 — minted by the central Redis allocator (ADR-143/143-A) over current origin/main. Frozen at rebase-before-merge."
external_ref: "Sumanth077/Hands-On-AI-Engineering — referenced as PATTERNS, NOT imported; license review pending (open [UNKNOWN])"
scope: BANXE-factory-governance
---

# ADR-148 — Hands-On-AI-Engineering adoption pack v1

> **DRAFT governance artifact. PREPARE-ONLY.** Read-only architectural selection — **no install, no
> clone, no code import** (patterns only; license review pending). Promotion to ACCEPTED is operator
> (Software Factory Lead) action via the **ADR-135 held-out adoption gate**, Ruflo-reviewed where
> regulated-adjacent. No RED-zone content; authority stays factory-only.

## 1. Context

A read-only peer-reviewed selection of patterns from the external repo
[`Sumanth077/Hands-On-AI-Engineering`](https://github.com/Sumanth077/Hands-On-AI-Engineering). The
governing finding from a repo-wide audit of BANXE: **most candidate "adopt" patterns already exist in
BANXE production/canon** — MCP (`banxe_mcp/server.py`, ~225 tools), RAG (`services/compliance_kb/`),
routing (ARL + **Ruflo** mandatory middleware, dozens of `*_router.py`), schema-gated output (Pydantic
v2 across `api/models/`), and orchestration (`services/swarm/orchestrator.py` + OpenClaw/Ruflo swarms +
LangGraph/AutoGen). Therefore this pack is **delta-not-greenfield**: harvest the missing increment into an
existing seam, never re-import a whole product.

**Two canon-binding constraints** (omitted by a naive selection, restored here):
- **Ruflo is MANDATORY** for any `payment/compliance/kyc/aml/emi/fca` surface
  (`request → ARL → Ruflo → target → response`). Any adopted agent touching regulated context routes
  through Ruflo.
- **Egress seam = LiteLLM gateway only** (§0.5; `MetaClaw/litellm/litellm-config.v2.yaml`, `:4000`); local
  models (qwen3/llama3.3). **No external LLM API** (OpenAI/Mistral/Gemini/DeepSeek) — the repo's API
  choices are forbidden by construction. Secrets live in `~/banxe-fabric/.vault/`, never git.

## 2. Decision

**Adopt v1 as three Phase-1 deltas (factory, no new secret/infra/egress), three Phase-2 gated items, and
three explicit prohibitions** — all bound to Ruflo + LiteLLM + vault, RED-zone fail-closed.

### Phase 1 — factory, delta-only, zero new secret / zero new egress
1. **Self-reflective grade→rewrite→validate loop** added to the **existing `compliance_kb` RAG** — answer
   only on validated context. **Quality heuristic, explicitly NOT a governance gate** (an LLM grading its
   own retrieval ≠ the ADR-135 held-out, zero-regression gate; the two must not be conflated).
2. **Schema-gated output contract** formalized as a cross-agent invariant on the **existing Pydantic-v2**
   surface — **fail-closed on schema violation** (a *correctness* control; a valid schema can still carry
   RED-zone payload, so it is **not** a RED-zone control).
3. **Orchestration topology harvest** (supervisor / parallel-fanout) into the **existing
   `services/swarm/orchestrator.py` + LangGraph/AutoGen/OpenClaw swarms** — no new framework.

### Phase 2 — gated; each requires its control + Ruflo + LiteLLM seam
1. **Read-only GitHub-MCP factory research client** — fine-grained **read-scoped token in
   `~/banxe-fabric/.vault/`**, read-tool allowlist (no write tools), via LiteLLM model; zero write, zero
   PII. (MCP itself is already in-prod; the new bit is a factory read-only client.)
2. **Intent-routing delta into ARL/Ruflo** — destination set **excludes all RED shards by construction**;
   unknown intent **fails closed to no-route** (never default-route); **Ruflo mandatory** on any regulated
   route.
3. **NL→SQL read-only agent** — only after a **DB-level read-only role + non-RED schema/row allowlist** is
   in place (the agent is **not** trusted to self-limit; read-only ≠ non-RED). Scoped to ops data,
   **never** ledger/payment/KYC/AML/sanctions; Ruflo-gated if regulated-adjacent.

### Explicitly FORBIDDEN (v1)
1. **Medical Prescription Digitizer** — special-category medical PII.
2. **Finance / Personal-Finance product runtimes** (FinAgent / Stock / Portfolio / bank-statement ingest)
   — RED-zone financial + PII; BANXE already runs Ruflo-gated AML/payment services, an external
   finance-agent only adds unguarded surface.
3. **Browser-automation agent + any external-LLM-API that bypasses the LiteLLM gateway** — autonomous
   egress / prompt-injection + §0.5 single-egress-seam violation.

## 3. RED-zone & authority guarantees
- **RED ZONE fail-closed** (ADR-137): payment/KYC/AML/sanctions/ledger-write/secrets/PII out of scope by
  default; ambiguous ⇒ deny.
- **Authority non-delegable** (ADR-145, #852): mint/governance/merge/adoption-gate stay factory; project
  fork is an execution-consumer on synthetic/non-prod data only.
- **Ruflo-in-loop** for regulated surfaces; **egress only via LiteLLM**; **secrets only in vault**.

## 4. Open [UNKNOWN] — operator input required (blocks implementation, not design)
1. **Licenses** of the repo + each sub-project — required before any code is read-for-reuse (patterns
   only; **no import** without license review).
2. **GitHub-MCP tool/scope** — exact read-tool allowlist + fine-grained token (no `repo`/write), vault-held.
3. **DB-level read-only role + non-RED schema/row allowlist** existence — gates the Phase-2 NL→SQL item
   entirely.
4. Whether the self-reflective loop **integrates cleanly into `services/compliance_kb`** vs needs a
   parallel path.

## 5. Consequences
- v1 = **two genuinely new factory capabilities** (self-reflective `compliance_kb` loop; read-only
  GitHub-MCP client) + **three formalizations of existing BANXE seams** (schema-fail-closed, ARL/Ruflo
  intent-routing, topology harvest). Nothing greenfield is imported; nothing touches RED.
- Each item promotes only via ADR-135 (HITL), Ruflo-reviewed if regulated-adjacent. Phase-1 has zero
  secret/infra dependency; Phase-2 is blocked on §4.

## Anchors
- ADR-117/135/137/143/143-A/145(#852)/146; Ruflo (`ruflo/`, `infra/ruflo/`); LiteLLM seam
  (`MetaClaw/litellm/…:4000`); `services/compliance_kb/`; `services/swarm/orchestrator.py`;
  `banxe_mcp/server.py`; `~/banxe-fabric/.vault/`. External: `Sumanth077/Hands-On-AI-Engineering`
  (patterns only, NOT imported). PREPARE-ONLY; no runtime/secret; operator HITL via ADR-135.
