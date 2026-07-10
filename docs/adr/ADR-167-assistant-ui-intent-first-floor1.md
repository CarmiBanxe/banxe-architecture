# ADR-167: assistant-ui-agent-frontend — Floor-1 Intent-First UI Adoption Target

## Status
Proposed

> ADOPT #56 (`assistant-ui-agent-frontend`) from `governance/ADOPTION-FINALIZATION-SP41.md` §1
> (ADOPT, S=0.6125) — SP41 roadmap §4 **cluster-3** (UI / observability / XAI), **first item**.
> Target: **GAP-080 floor-1 intent-first UI**. Handoff: GAP-080. This is a **design / governance
> decision record only** — it introduces **no frontend code** (ADR-102 pointer-first, no restate).

## Context
Cluster-1 (LLM-safety perimeter #64/#65/#104) and cluster-2 (fraud engine #111/#49/#46) are landed;
both are backend/governance layers. **GAP-080 (floor-1 intent-first UI)** is the next open capability —
the customer-facing interaction surface the intent-first architecture presupposes but has not yet
realised as an adopted UI target.

The design substrate already exists on `main` and is **consumed pointer-first, not restated**:
`docs/adr/ADR-045-intent-first-banking-architecture.md` (the intent-first architecture) and
`docs/governance/UI-UX-DESIGN-SYSTEM-CANON.md` (design-system tokens / component canon). A prior
working design note (`docs/handoff/DESIGN-56-assistant-ui-with-mastra.md`) captured the framework
analysis that this ADR canonicalises. What is missing is the **governance decision** naming the
floor-1 intent-first UI as an adoption target and fixing its interaction model and boundaries **before**
any framework or code is chosen.

## Decision
Adopt `#56 assistant-ui-agent-frontend` as the **floor-1 intent-first UI adoption target**, at the
**design/governance layer only**:

1. **Intent-first interaction surface.** `#56` is defined as the intent-first interaction surface for
   floor-1 — the user expresses intent; the surface routes it — consistent with `ADR-045` and the
   design-system canon. It is an *interaction model*, not (yet) an implementation.
2. **Framework-agnostic at this ADR level.** This ADR commits to the **target and its boundaries**,
   **not** to a concrete frontend runtime. Per the consultant verdict
   (`docs/handoff/CONSULTANT-VERDICTS-SP41-2026-07-09.md`), **Mastra (`#76`
   mastra-typescript-agent-framework) is recorded as the CANDIDATE** TypeScript-first framework that
   "pairs directly with #56 assistant-ui" for GAP-080; **LangChain-JS (`#77`) is fallback-only**
   (consultant DEFER, reconsidered iff Mastra fails assistant-ui integration). The binding framework
   commitment is a **separate follow-up ADR** (see Follow-ups), gated on the conditions below.
3. **Scope fixed now:**
   - **Component intent taxonomy** — the classes of intent the surface expresses (inform / confirm /
     act / escalate), defined governance-side and mapped to `UI-UX-DESIGN-SYSTEM-CANON` tokens
     (pointer-first, not restated).
   - **HITL-aware surfacing (I-27)** — any L2+ / regulated / irreversible action reached through the
     surface renders a human-in-the-loop step; the UI never actions such a decision autonomously.
   - **Governance boundaries** — perimeter, licensing, and no-authority (below) are fixed here so the
     later implementation ADR inherits them.

## Non-Goals
- **No frontend code, no React scaffolding, no package installs** in this sprint.
- **No framework commitment** — Mastra (`#76`) / LangChain-JS (`#77`) are candidate/fallback, not selected.
- **No new design system** — `UI-UX-DESIGN-SYSTEM-CANON` remains the SSOT; this ADR points to it.
- **No activation** — PROPOSED; operator/SMF ratify; each downstream step is its own gated sprint.

## Duplication Audit (ADR-102)
| Existing artefact | What it already provides | Relation to #56 |
|---|---|---|
| `docs/adr/ADR-045-intent-first-banking-architecture.md` | The intent-first *architecture* decision | #56 is the **UI-surface realisation** of ADR-045's floor-1 — consumes it, does not restate |
| `docs/governance/UI-UX-DESIGN-SYSTEM-CANON.md` | Design-system tokens / component canon (SSOT) | #56 **maps intents onto** this canon; unchanged |
| `docs/handoff/DESIGN-56-assistant-ui-with-mastra.md` (working note) | Framework analysis (Mastra candidate, conditions) | Canonicalised **into this ADR**; the note stays an informal input |

**Conclusion:**
- **What already exists:** the intent-first *architecture* (ADR-045) and the *design-system canon*
  (UI-UX-DESIGN-SYSTEM-CANON); framework analysis in the DESIGN-56 working note.
- **What would be duplicated if we coded now:** a floor-1 UI implementation would re-encode
  design-system tokens already owned by UI-UX-DESIGN-SYSTEM-CANON and prematurely fork a framework
  runtime — before the interaction model / intent taxonomy / boundaries are ratified.
- **What is genuinely missing:** the **governance decision** that names the floor-1 intent-first UI as
  an adoption target and fixes its intent taxonomy, HITL-aware surfacing, and boundaries,
  framework-agnostically. This ADR supplies exactly that; it duplicates nothing (ADD the ADR, KEEP
  every referenced artefact).
- **Why documentation/governance only:** the missing piece is a *decision*, not code — so the
  non-duplicative next step is to fix the target + boundaries and defer implementation to a later,
  separately-audited sprint.

## Licensing / perimeter constraints
- **No credit / lending** — the surface exposes no credit or lending journey (SP41 §2: permanently out-of-scope for the EMI remit).
- **Trading / quant = PAYBIS-distribution** — any such capability reached via the surface is **PAYBIS-distributed** (PAYBIS licensed; BANXE distributor, ADR-138) and **signposted** as such in the UI; never a BANXE own-trading surface (SP41 §3).
- **Payment-authorisation is mandatory** — frontend agents **MUST route through BANXE payment-authorisation controls; no bypass** (consultant condition on #76). An API-boundary review confirming this is a gate on any framework confirmation.
- **Perimeter (ADR-117)** — this is a **project-perimeter** UI target; the factory does not cross into it with code. No cross-perimeter store or authority.
- **No authority (ADR-127 / ADR-130)** — the UI surfaces intents and decisions; it never grants a permission or actions a regulated decision — HITL / I-27 always mediates.
- **Mastra licence caveat** — Mastra's GitHub licence metadata is **`NOASSERTION`**; the actual licence MUST be retrieved and confirmed compatible with BANXE licence policy **before** any implementation sprint.

## Follow-ups (separate, gated sprints — not this PR)
- **Framework-selection ADR** — choose the concrete runtime (**Mastra `#76`** candidate vs **LangChain-JS `#77`** fallback), with the **Mastra licence confirmation**, an ADR-102 audit, an **assistant-ui integration milestone** (intent taxonomy mapped + API-boundary/no-bypass review + HITL demonstrated), and ADR-117 perimeter handling.
- **Implementation sprint** — floor-1 UI build against `UI-UX-DESIGN-SYSTEM-CANON`, once the framework ADR lands.
- **`#68` langfuse-llm-observability** — observability over any LLM-backed interaction the surface drives (cluster-3, next).
- **`#66` lime-shap-hitl-explainability** — decision-rationale surfacing for any model output the UI renders (cluster-3, after #68; pairs with ADR-046 decision-lineage).

## References
- `governance/ADOPTION-FINALIZATION-SP41.md` §1 (ADOPT #56), §4 (cluster-3), §2/§3 (credit / PAYBIS boundaries).
- `docs/adr/ADR-045-intent-first-banking-architecture.md`, `docs/governance/UI-UX-DESIGN-SYSTEM-CANON.md` — intent-first + design-system substrate (KEEP; consumed pointer-first).
- `docs/handoff/CONSULTANT-VERDICTS-SP41-2026-07-09.md` — #76 ADOPT (conditions), #77 DEFER.
- `docs/handoff/DESIGN-56-assistant-ui-with-mastra.md` — working design note (input, canonicalised here).
- Follow-ups: #68 langfuse-llm-observability, #66 lime-shap-hitl-explainability. Companion runtime: `#76` mastra (candidate), `#77` langchain-js (fallback).
- ADR-102 (additive / pointer-first), ADR-117 (perimeter), ADR-127 / ADR-130 (no authority), ADR-138 (PAYBIS distribution), ADR-046 (decision-lineage XAI), I-27.
