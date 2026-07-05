---
il_ts: 2026-07-05T21:59:51Z
session_id: agent-factory-souls-cohort3-platform-dev
source: agent-factory
status: PROPOSED
---

# SOUL authoring — Cohort 3: Platform/Dev governors (prepare-only)

## What

Third tranche of the #1040 forward-path (Cohort 1 #1042/IL-925, Cohort 2 #1044/IL-930). Net-new canonical
Markdown SOULs (_TEMPLATE.md, 12 sections incl HITL Workflow) for 4 low-customer-risk Platform/Dev governors:
sandbox_rails_governor (Eng/Dev Platform·Head of Platform Eng·CTX-09), sdk_release_governor (·CTX-09),
multi_tenancy_agent (·CTO·CTX-09, owns services/multi_tenancy), m_gateway_api_governor (Platform/API·CTIO·CTX-01,
routes to services/api_gateway). Describe authority, do not expand it; route-not-reimplement.

## Boundaries

Prepare-only. No activation — 4 passports stay PROPOSED (unchanged); PROPOSED→LIVE is I-27 HITL-L4/operator (§11).
CLASS-B charters written not activated. No TRADING-001 / agent/specproj/* (Rule 6). Authored in worktree (ADR-120).
IL minted redis-serialized at ratification.

## Anchors

agents/souls/{sandbox-rails-governor,sdk-release-governor,multi-tenancy-agent,m-gateway-api-governor}.md ·
agents/souls/_TEMPLATE.md · #1042/#1044 (Cohorts 1-2) · #1040 readiness · #1039 activation procedure.
