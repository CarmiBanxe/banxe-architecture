---
il_ts: 2026-07-05T23:07:59Z
session_id: agent-factory-souls-cohort4-tech-integrations
source: CEO
status: PROPOSED
---
### Cohort 4 — author 5 Tech/Integrations governor SOULs (CTX-03), prepare-only, no activation

- **Objective:** Author 5 SOUL charters for the CTX-03 Tech/Integrations owner-agents that have PROPOSED passports but no SOUL: `midaz_mcp_agent`, `reasoning_bank_agent`, `ml_pipeline_agent`, `webhook_orchestrator_agent`, `webhooks_agent`. Forward-path continuation of the #1040 readiness audit (after Cohorts 1/#1042, 2/#1044, 3/#1046).
- **Facts grounded in the passports (origin/main), not memory:** all 5 are **L2 · AMBER · CTX-03 · CLASS_B · human_double CTO · invariants I-27 + I-08**, each the owner-governor of an EXISTING `banxe-emi-stack` service (`services/{midaz_mcp,reasoning_bank,ml_pipeline,webhook_orchestrator,webhooks}`). Routes taken verbatim from each passport's ports/allowed_callees:
  - `midaz_mcp_agent` — MidazPort→MidazClientPort (LedgerPort family, **I-28: no direct HTTP**; I-05 Decimal), callee clickhouse_writer; FCA CASS 7.
  - `reasoning_bank_agent` — ReasoningBankPort; **append-only** decision store; callee clickhouse_writer; EU AI Act Art.13 (explainability).
  - `ml_pipeline_agent` — MLSignalPort; **no autonomous model promotion** (HITL-gated); auto_refactor_pro prohibited; callee clickhouse_writer; EU AI Act Art.15 (drift).
  - `webhook_orchestrator_agent` — EventPublisherPort→DeliveryStore/CircuitBreakerStore; **no autonomous delivery-policy change**; callee webhooks; FCA SYSC 8.1.
  - `webhooks_agent` — WebhookDeliveryPort→WebhookAuditStore/Reliability; **delivery records append-only**; callees clickhouse_writer, notification_agent; FCA SYSC 8.1.
- **Route-not-reimplement (canon):** every SOUL governs/orchestrates the existing service; none reimplements service logic (matches each passport `non_goals`). SOUL **describes** authority, never expands it — enforcement in CI + ADR-117/128/121, not the SOUL.
- **Prepare-only (canon):** 5 SOUL docs only. **No passport touched; every agent stays PROPOSED.** PROPOSED→LIVE remains an I-27 HITL-L4 operator + CTO act (CLAUDE.md §11) — the Factory never activates. Per FACTORY-CANON.md (IL-932).
- **ADR-102 duplication audit:** repo-wide check of `agents/souls/` — no pre-existing or near-duplicate SOUL for any of the 5 stems. **Decision: add net-new (5).** No merge/delete; no hidden consumer.
- **Format:** each SOUL = 12 sections (Identity, Core Responsibilities, Tools Available, Data Sources (read-only), Constraints, Escalation, HITL Gate, HITL Workflow, Voice, Memory Policy, Core Truths, Pet Peeves), 63–64 lines. House style consistent with Cohorts 1–3.
- **Perimeter / canon:** banxe-architecture only; authored in isolated worktree off origin/main (ADR-120), not the shared checkout; no TRADING-001 / agent/specproj/* (Rule 6); no secrets; no code/runtime change; signed; `--force-with-lease` only.
- **Deliverable:** 5 `agents/souls/*.md` + this IL shard. ONE Draft PR, prepare-only. IL frozen-at-merge (Rule 8) — minted via build_ledger.py on current origin/main immediately before merge, not hardcoded here.
- **Refs:** SOUL cohorts #1042 (IL-925) / #1044 (IL-930) / #1046 (IL-934); FACTORY-CANON.md (#1047, IL-932); passports agents/passports/{midaz_mcp,reasoning_bank,ml_pipeline,webhook_orchestrator,webhooks}_agent.yaml; CLAUDE.md §11; I-27; I-28; I-08; I-05; ADR-102; ADR-117/120/121/128; parallel-session-isolation Rule 6.
