---
il_ts: 2026-07-07T08:40:08Z
session_id: agent-factory-souls-case-management-agent
source: CEO
status: PROPOSED
---
### Author case_management_agent SOUL (w/ Decision Method) — AML-decision contour, prepare-only, no activation

- **Objective:** Author the SOUL charter for the genuinely-SOUL-less `case_management_agent` — owner-governor of the
  EXISTING `services/case_management/` (banxe-emi-stack; route-not-reimplement). 13 sections incl. mandatory
  `## Decision Method` (ADR-131 amended 11→12, #1077). **Prepare-only**; passport UNTOUCHED, stays PROPOSED; no activation.
- **ADR-102 dedup:** fuzzy-confirmed genuinely SOUL-less (no case-management / banxe-case-management SOUL). Net-new (1).
- **Grounded facts (from passport on origin/main, not memory):** L2 · RED · CTX-01 · CLASS_B; human double **MLRO**
  (owner/approver MLRO); status **PROPOSED** (genuine — body "PROPOSES only (I-27); NOT activated", no stray-active);
  capabilities case_create/case_lifecycle_track/marble_case_routing/mlro_case_queue; ports CaseManagementPort →
  MarbleCasePort/AuditPort; callers aml_orchestrator + banxe_aml_orchestrator; callee clickhouse_writer; invariants
  **I-27, I-08, I-12**; FCA **SYSC 6 + POCA 2002 (SAR)**; auto_refactor_pro PROHIBITED.
- **Honest schema note:** passport does NOT cite I-02/I-03/MLR-2017 — NOT attributed to the passport. AML-decision
  discipline grounded on the cited anchors (POCA 2002 / SAR, SYSC 6, I-27/I-08/I-12) + general fail-closed rigor.
- **AML-decision discipline (baked into Constraints/HITL Gate/Decision Method/HITL Workflow/Core Truths/Pet Peeves):**
  prepares & routes the case file — the clear/block/SAR-file disposition is the MLRO's, human-gated (I-27); never
  auto-files a SAR, never auto-clears a sanctions/PEP/TM hit, never self-escalates a level; a hit at/over the BUG-007
  threshold fails closed to MLRO; no PII leakage; append-only audit (I-08/I-24). SOUL describes authority, never expands it.
- **Decision Method:** grounded per this agent (enumerate case-handling actions → score by case-materiality /
  evidence-completeness / regulatory-deadline (MAUT) → satisfice within its MLRO HITL gate → escalate to MLRO;
  fail-closed precedence I-27/BUG-007). Pointer-first to best-decision-concept-2026-07-06-v2.md /
  consultant-escalation-protocol-2026-07-07.md / BEST-DECISION-BOUNDARY / ADR-162 — not restated.
- **Fleet impact:** genuinely-SOUL-less orchestrator/decision teachers narrowed to the aml_orchestrator identity
  question (3-passport / 2-id conflict — HELD for MLRO/operator governance decision, not authored here).
- **Perimeter:** banxe-architecture; worktree off origin/main (ADR-120), not shared checkout; no TRADING-001 /
  agent/specproj/* (Rule 6); no secrets; signed; --force-with-lease. Factory activates nothing (I-27 = operator+MLRO). IL frozen-at-merge (Rule 8).
- **Deliverable:** 1 `agents/souls/case-management-agent.md` + this shard. ONE Draft PR, prepare-only.
- **Refs:** ADR-131 (+#1077); FACTORY-CANON §1.11; ADR-117/128/121; I-08; I-12; I-24; I-27; BUG-007; ADR-102; GAP-078;
  FCA SYSC 6; POCA 2002; docs/sources/best-decision-concept-2026-07-06-v2.md;
  docs/sources/consultant-escalation-protocol-2026-07-07.md; docs/canon/BEST-DECISION-BOUNDARY.md; docs/adr/ADR-162-best-decision-principle.md.
