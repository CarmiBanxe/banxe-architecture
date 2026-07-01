---
il_ts: 2026-07-01T15:15:00Z
session_id: agent-factory-sprintplan04-b2-dispatcher-wiring
source: factory
status: PREPARED
---
### IL-770 — Sprint-B B2: Intent-Dispatcher Runtime Wiring (ADR-150)

- **Task:** B2 gate-in (A5 ✅ IL-765). Implement Intent-Dispatcher Runtime Wiring per ADR-150. Repo: banxe-ai-infrastructure. Branch: `agent/factory/sprintplan04/b2-dispatcher-wiring`. Commit: dc9d547.
- **Scope:** Exactly 3 areas — `intent_dispatcher/adapters/` (NEW), `services/intent_dispatcher/app.py` (wiring), `tests/test_intent_dispatcher/` (3 new test files).
- **New: `intent_dispatcher/adapters/` package:** `AgentAdapterPort` Protocol (runtime_checkable) + `LoggingAgentAdapter` reference impl (P1: CrewAI/LangGraph) + `PassportResolverPort` / `EnvPassportResolver` (reads `DISPATCHER_ROUTES` env, A5 planner.yaml-style JSON) / `InMemoryPassportResolver` (test double) / `PassportBackedRegistry` (RouteRegistryPort backed by PassportResolverPort).
- **Modified: `services/intent_dispatcher/app.py`:** `_build_route_registry()` — env set → PassportBackedRegistry, absent → InMemoryRouteRegistry(DEFAULT_ROUTES); `_build_adapter_registry()` — one LoggingAgentAdapter per unique target_agent; lifespan wires both; `/dispatch` L1 path reads message from bus → routes through adapter.
- **Tests: 47 new tests** — `test_adapters.py` (AdapterResult, LoggingAgentAdapter, Protocol conformance), `test_passport_resolver.py` (env/no-env/L1/L2/malformed, InMemory, PassportBackedRegistry get/miss/list/register), `test_b2_wired_dispatch.py` (composition-root helpers, HTTP L1→adapter, L2 HITL no-adapter, no-route error, I-24 audit_id, correlation_id propagation).
- **Gate-out (ADR-150):** end-to-end passport→adapter→bus ✅ | 92 tests green (100% coverage intent_dispatcher/) ✅ | semgrep 0 findings ✅ | changes confined to 3 scoped areas ✅.
- **Canon:** library intent_dispatcher/ NOT rewritten. InMemory stubs stay as test doubles. No hardcoded keys — DISPATCHER_ROUTES env at composition root. No B5/Redis drift. I-24 audit append-only ✅. I-27 HITL: L2 never auto-sent ✅.
- **Status:** PREPARED — PR open in banxe-ai-infrastructure, awaiting CI + operator review.
