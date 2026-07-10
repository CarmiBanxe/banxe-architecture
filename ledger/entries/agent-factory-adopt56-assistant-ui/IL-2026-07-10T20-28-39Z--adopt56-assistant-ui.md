---
il_ts: 2026-07-10T20:28:39Z
session_id: agent-factory-adopt56-assistant-ui
source: CEO
status: PROPOSED
---
### ADOPT #56 — assistant-ui-agent-frontend → GAP-080 floor-1 intent-first UI (PROPOSED, doc-only) — first item of SP41 cluster-3

Design/governance decision record only (`docs/adr/ADR-167-assistant-ui-intent-first-floor1.md`, provisional number per ADR-119) — handoff GAP-080. Defines #56 as the intent-first interaction surface (SP41 §1, ADOPT S=0.6125), framework-agnostic at ADR level; consumes ADR-045 + UI-UX-DESIGN-SYSTEM-CANON pointer-first (ADR-102, no restate). Records consultant recommendation: **Mastra (#76) = CANDIDATE** TS-first framework (follow-up framework-selection ADR; licence NOASSERTION → confirm before implementation; gate on assistant-ui integration milestone + API-boundary no-bypass review); **LangChain-JS (#77) = fallback-only**. Scope fixed now: component intent taxonomy (inform/confirm/act/escalate → design-system tokens), HITL-aware surfacing (I-27), governance boundaries. **NO frontend code / framework commitment / package installs** this sprint. ADR-102 Duplication Audit: ADR-045 + UI-UX-DESIGN-SYSTEM-CANON + DESIGN-56 note exist → KEEP/cross-ref; genuinely-missing piece = the governance decision (this ADR). Licensing/perimeter: no credit/lending (§2); trading/quant = PAYBIS-distribution external/signposted (§3, ADR-138); frontend agents MUST route through payment-authorisation, no bypass; project-perimeter (ADR-117); no-authority (ADR-127/130). Next cluster-3 sequence: #68 langfuse → #66 lime-shap. PROPOSED/gated — nothing activated. Refs: ADOPTION-FINALIZATION-SP41 §1/§2/§3/§4, GAP-080, ADR-045, UI-UX-DESIGN-SYSTEM-CANON, ADR-102, ADR-117, ADR-127/130, ADR-138, ADR-046, I-27; consultant #76/#77.
