# ADR-168: langfuse — LLM Prompt/Trace/Cost Observability over the LiteLLM :4000 Fleet

## Status
Proposed

> ADOPT #68 (`langfuse-llm-observability`) from `governance/ADOPTION-FINALIZATION-SP41.md` §1
> (ADOPT, S=0.6575) — SP41 roadmap §4 **cluster-3** (UI / observability / XAI), **2nd item**
> (after #56). Scope: **LLM prompt / trace / cost observability over the LiteLLM `:4000` fleet.**
> Handoff: GAP-LLM-OBSERVABILITY. **Design / governance decision record only** — no deploy code,
> no service/systemd change, no callback wiring (ADR-102 pointer-first, no restate).

## Context
Cluster-3's first item (#56, ADR-167) fixed the floor-1 UI surface. The next open capability is
**LLM-level observability** — per-call prompt, completion, token/cost, latency, and model visibility
across the LiteLLM gateway. This gap is **not** covered by any existing layer (each is cross-referenced
pointer-first, not restated):

- **`instruction-ledger/sprint-42/IL-OBS-01-observability-critical-services.md` (IL-OBS-01)** —
  **service-level** observability (structured logging / metrics / audit for critical EMI services).
  Different altitude: infra/service health, **not** LLM prompt/trace/cost.
- **`patches/litellm-guardrail-audit-hook-2026-05-12.py` (shadow-tap)** — a **regulated-request audit**
  hook feeding a ClickHouse HITL sink. A guardrail/audit path, **not** cost/trace observability.
- **`docs/adr/ADR-046-decision-lineage-schema.md`** — the `AgentDecisionRecord` **schema/contract**,
  not an observability implementation.
- **`docs/canon/decision-litellm-dual-gateway-2026-05-13.md`** — the canonical gateway decision
  (`litellm-v2.service` on `127.0.0.1:4000`).

## Decision
Adopt **langfuse** as the **LLM prompt/trace/cost observability layer** for the LiteLLM fleet:

1. **Attach as a LiteLLM callback / logging integration** on the canonical `:4000` gateway —
   **NOT** a second process or listener. Per
   `governance/specproj/SP03-LITELLM-SINGLE-LISTENER-GUARD.md`, multiple listeners on `:4000` via
   `SO_REUSEPORT` are a **known hazard**; langfuse therefore rides the existing gateway's callback
   surface, adding **zero** new listeners.
2. **Framework-agnostic at this ADR level.** The concrete deployment (self-hosted langfuse vs managed,
   callback registration, redaction pipeline) is deferred to a **follow-up integration ADR**.

**Scope fixed now:**
- **What is traced:** prompt, completion, token counts + cost, latency, and model/route — per LLM call.
- **Where it attaches:** the LiteLLM `:4000` **callback/logging** integration (single-listener-safe).
- **Boundaries:** observability/telemetry only — it does not gate, block, or alter requests (that
  remains the guardrail/shadow-tap and rails layers).

## Non-Goals
- **No deploy code, no systemd/service change, no new `:4000` listener, no callback wiring** in this sprint.
- **No framework/deployment commitment** (self-hosted vs managed) — deferred to the integration ADR.
- **Does not replace** the shadow-tap regulated-request audit or IL-OBS-01 service observability —
  it **complements** both at a distinct altitude.
- **No activation** — PROPOSED; operator/SMF ratify.

## Duplication Audit (ADR-102)
| Existing artefact | What it already provides | Relation to #68 |
|---|---|---|
| `instruction-ledger/sprint-42/IL-OBS-01-...md` | Service-level observability (critical EMI services) | Different altitude — infra/service, not LLM prompt/trace/cost. KEEP |
| `patches/litellm-guardrail-audit-hook-2026-05-12.py` | Regulated-request audit → ClickHouse HITL | Guardrail/audit, not cost/trace observability. KEEP (distinct path) |
| `docs/adr/ADR-046-decision-lineage-schema.md` | `AgentDecisionRecord` schema/contract | Contract, not an observability impl. KEEP (cross-ref) |
| `docs/canon/decision-litellm-dual-gateway-2026-05-13.md` | Canonical `:4000` gateway decision | #68 attaches to this gateway as a callback. KEEP |
| `governance/specproj/SP03-LITELLM-SINGLE-LISTENER-GUARD.md` | Single-listener hazard guard | Binds the integration form (callback, not listener). KEEP |

**Conclusion:**
- **What already exists:** service observability (IL-OBS-01), regulated-request audit (shadow-tap),
  the decision-lineage schema (ADR-046), and the canonical gateway + single-listener guard.
- **What would be duplicated if coded now:** standing up a langfuse listener/deploy without the
  integration decision would collide with the SP03 single-listener guard and re-encode telemetry the
  shadow-tap/IL-OBS-01 already emit at their altitudes.
- **What is genuinely missing:** an adopted decision to add **LLM prompt/trace/cost visibility** across
  the `:4000` fleet, in a single-listener-safe callback form. This ADR supplies exactly that; it
  duplicates nothing (ADD the ADR; KEEP every referenced layer).
- **Why documentation/governance only:** the missing piece is the *decision + integration form*, not
  code — implementation (callback wiring + PII redaction) is a separately-audited follow-up.

## Privacy / perimeter constraints
- **Prompt/response logs may contain PII** → a **DP / redaction pipeline + retention policy** is
  **required before any real capture**. This sprint captures nothing; it only fixes the decision.
- **Regulated-request audit stays on the shadow-tap → ClickHouse path** — langfuse is telemetry, not
  the audit system of record.
- **Perimeter (ADR-117)** — observability runs within a single perimeter; no cross-perimeter trace store.
- **No credit / lending** (SP41 §2); **trading/quant = PAYBIS-distribution** signposting unchanged (SP41 §3, ADR-138).
- **No authority (ADR-127/130)** — traces observe; they never grant a permission or action a decision.

## Follow-ups (separate, gated sprints — not this PR)
- **Integration ADR** — concrete langfuse deployment + LiteLLM callback registration + **PII
  redaction** pipeline + retention config; single-listener-safe per SP03.
- **`#66` lime-shap-hitl-explainability** — cluster-3 3rd/last item (decision-rationale XAI; pairs
  with ADR-046 decision-lineage) — next after #68.

## References
- `governance/ADOPTION-FINALIZATION-SP41.md` §1 (ADOPT #68), §4 (cluster-3), §2/§3 (credit / PAYBIS boundaries).
- `docs/canon/decision-litellm-dual-gateway-2026-05-13.md`, `governance/specproj/SP03-LITELLM-SINGLE-LISTENER-GUARD.md` — canonical `:4000` gateway + single-listener guard (KEEP).
- `instruction-ledger/sprint-42/IL-OBS-01-observability-critical-services.md` — service observability (KEEP, distinct).
- `patches/litellm-guardrail-audit-hook-2026-05-12.py` — regulated-request audit shadow-tap (KEEP, distinct).
- `docs/adr/ADR-046-decision-lineage-schema.md` — decision-lineage schema (cross-ref).
- Follow-ups: langfuse integration ADR; #66 lime-shap-hitl-explainability.
- ADR-102 (additive / pointer-first), ADR-117 (perimeter), ADR-127 / ADR-130 (no authority), ADR-138 (PAYBIS distribution), I-24 (audit append-only).
