# DESIGN NOTE — #56 assistant-ui (GAP-080 floor-1) with Mastra (#76)

- **Status:** PROPOSED — working design note (untracked, advisory only; NO ledger sprint, NO code, NO activation).
- **Date:** 2026-07-10 · **Author:** Factory (Terminal-A) · **For:** Central/SMF1
- **Type:** DESIGN-ONLY / NON-LEDGER. Does not modify any ADR, ledger, or governance file.
- **Refines:** the earlier PROPOSED doc-only #56 design (ADR-167 placeholder + shard skeleton, framework-agnostic).
- **Consultant input:** `docs/handoff/CONSULTANT-VERDICTS-SP41-2026-07-09.md` (§5.A #76 ADOPT, #77 DEFER).

## 1. Purpose

Refine the **#56 GAP-080 floor-1 intent-first UI** design to incorporate the consultant's
framework recommendation — **Mastra (#76)** as the TypeScript-first agent framework — **without**
committing implementation code or opening a ledger sprint. This note advances the *design decision*
only; the framework choice remains **PROPOSED** and gated (see §4, §5).

## 2. Framework decision (design-level, PROPOSED)

- **Candidate framework: Mastra (#76)** — adopt as the candidate TypeScript-first agent framework
  for the #56 intent-first surface. Consultant rationale: Mastra "pairs directly with confirmed-ADOPT
  #56 assistant-ui" for GAP-080 and avoids a Python/JS runtime boundary on the frontend agent layer.
- **Fallback: LangChain-JS (#77)** — recorded as **fallback only**, to be reconsidered **iff** Mastra
  fails assistant-ui integration (consultant DEFER'd #77 in favour of Mastra). Not a parallel adoption.
- **Licence caveat (blocking for implementation):** Mastra's GitHub licence metadata is
  **`NOASSERTION`**. The actual licence text MUST be retrieved and confirmed compatible with BANXE
  licence policy **before** any production/implementation sprint. Until confirmed, Mastra is a
  design candidate only.
- **Still framework-*decision*, not framework-*commitment*:** this note selects Mastra as the
  candidate to carry into the #56 ADOPT ledger sprint; the binding commitment happens in that sprint's
  ADR (with its own ADR-102 duplication audit and the licence confirmation above).

## 3. Constraints carried forward (verbatim intent)

- **No credit/lending flows** — EMI out-of-scope (SP41 §2); the surface exposes no credit/lending journey.
- **Trading/quant only as PAYBIS-distribution** — external principal-led; where surfaced, the UI must
  **signpost** the capability as PAYBIS-distributed (PAYBIS licensed; BANXE distributor), never as a
  BANXE own-trading surface (SP41 §3).
- **Payment-authorisation controls are mandatory** — frontend agents **MUST route through BANXE
  payment-authorisation controls; no bypass** (consultant condition on #76). Any agent-initiated
  action touching funds goes through the existing authorisation path.
- **RED / B5-IRREVOCABLE actions remain HITL-gated** — irreversible / regulated actions require
  human-in-the-loop; in sandbox, SMF sign-off is **simulated** (no real activation). The UI surfaces
  decisions; it holds no authority (ADR-127/130; I-27).
- **Perimeter (ADR-117)** — this is a **project-perimeter** UI target; the **factory does not cross
  into it with code**. No cross-perimeter store or authority.

## 4. Integration milestone gate (consultant condition)

Per the consultant's condition, Mastra is confirmed only once the **"assistant-ui integration
milestone"** is reached. Concretely, that milestone is defined here as **all** of:

1. **Intent taxonomy mapped** — the floor-1 component intent taxonomy (inform / confirm / act /
   escalate, mapped to `UI-UX-DESIGN-SYSTEM-CANON` tokens) is expressed in Mastra's agent/workflow
   model, demonstrating the framework can represent the intent-first interaction model.
2. **API-boundary review passed** — a review confirming Mastra frontend agents invoke BANXE
   payment-authorisation controls at the API boundary and **cannot bypass** them (consultant #76 condition).
3. **HITL surfacing demonstrated** — a RED / B5-IRREVOCABLE path renders a HITL step (SMF sign-off
   simulated in sandbox) rather than an autonomous action.
4. **Licence confirmed** — Mastra's actual licence retrieved and confirmed compatible (§2 caveat resolved).
5. **Perimeter respected** — the integration artefact lives in the project perimeter; no factory-side code.

Passing all five = milestone met → Mastra confirmed for the #56 implementation sprint. Failing (2) or
(4) blocks Mastra; failing repeatedly triggers the #77 LangChain-JS fallback re-evaluation.

## 5. Sequencing (doc-only; gated on singleton)

- **This note is doc-only** — it starts no ledger sprint and writes no ledger/governance/ADR file.
- **The actual ADOPT #56 ledger sprint (ADR + shard) can only start AFTER PR #1116 is merged** — that
  PR currently holds the ledger singleton; no new ledger-touching work may begin until the operator/SMF
  merges it (FACTORY-MEMO §5) and the singleton is freed.
- **Then, one at a time:** #56 (this surface, carrying Mastra as the candidate) → **#68 langfuse**
  (observability) → **#66 lime-shap** (explainability). Each is a separate gated ledger sprint; only
  one open ledger PR at a time.

## References (pointer-first; not modified)

- `docs/handoff/CONSULTANT-VERDICTS-SP41-2026-07-09.md` — #76 ADOPT (with conditions), #77 DEFER.
- Earlier #56 design: ADR-167 placeholder + shard skeleton (framework-agnostic, PROPOSED — not yet on main).
- `governance/ADOPTION-FINALIZATION-SP41.md` §1.1 (#56 ADOPT), §2 (credit OOS), §3 (PAYBIS), §4 (cluster-3).
- ADR-117 (factory/project perimeter), ADR-127/130 (no authority), I-27 (HITL). Design canon:
  `docs/adr/ADR-045-intent-first-banking-architecture.md`, `docs/governance/UI-UX-DESIGN-SYSTEM-CANON.md`.
