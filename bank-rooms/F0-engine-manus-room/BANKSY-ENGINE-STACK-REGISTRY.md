# BANKSY ENGINE — Stack Registry (unified) — 2026-07-23

**BANK CORE / BANKSY ENGINE STACK REGISTRY / DOCS-ONLY / READ-ONLY RUNTIME**
Single registry of the whole Banksy Engine stack (heart of the bank): a Manus-like agentic engine, two roles — CEO-conductor and client personal-manager. Anchors verified present read-only across repos; only engine-relevant files included (the 10547-file P9 sweep is NOT pulled in wholesale). Code is assembled later **by the factory** — this is docs only.

### Concept correction (supersedes "two-engine specialization")

**Banksy Engine and Legion are two separate engines / two separate worlds — NOT one stack, NOT specialization-over-Legion.**
- **Banksy Engine = bank core** (CEO-conductor + client-PM-friend), inside the bank, its own zone.
- **Legion = separate external trusted party / supplier** (OpenManus in a private zone on Legion's own laptop). NOT part of the bank.
- Both are the **same OSS technology** (one code/config base) but **deployed separately, in different zones**.
- Banksy uses Legion's tech as a **TEMPLATE**, deployed separately; Banksy is **NOT compiled over Legion/OpenManus**.
- **Legion has extra functions NOT permitted to Banksy** (Banksy is a limited bank profile).
- **Interface Banksy → Legion:** request/response for client-info gathering + access to special databases. Legion is an **external trusted supplier** (customer↔supplier), **not a shared runtime**. See `banksy-legion-interface.md`.

### Confirmations (from audit)
- **CEO-conductor CONFIRMED:** Moriel Carmi, SMF1, Board/Executive, autonomy L2_REVIEW, **PROPOSES only** (I-27 / HITL-L4). Source of truth = arch-repo souls(6)/passports(7).
- **Client-PM CONFIRMED:** ADR-045 (Intent-First) + ADR-171 (ClientIntentRecord).
- **OSS base = OpenManus technology used as TEMPLATE** (same tech), **NOT "compiled over Legion".**

## 1. CONCEPT (canon + ADRs)

Canonical concept:
- `MetaClaw/docs/architecture/legion-generic-engine-and-banxe-specialization-canonical-2026-07-10.md`
- `banxe-architecture/docs/architecture/two-engines-master-analysis-and-roadmap-canonical-2026-07-10.md`
- `banxe-architecture/docs/sources/BANXE-Private-Legion-Engine-Otvety-Konsultanta-2026-07-10.md` · `…-Otvety-na-otkrytye-voprosy-arkhitektury-2026-07-10.md`
- `MetaClaw/docs/audit/banxe-agent-engine-conclusion-{coverage,intel}-2026-07-10.md` · `emi-banxe-ideal-engine-math-{coverage,intel}-2026-07-10.md`

ADR basis (arch repo, verified):
- `docs/adr/ADR-045-intent-first-banking-architecture.md` (intent-first)
- `docs/adr/ADR-049-intent-layer-client-facing-agent-masks.md` (intent-layer masks)
- `docs/adr/ADR-060-multi-actor-orchestration.md`
- `docs/adr/ADR-154-shared-space-orchestration.md`
- `docs/adr/ADR-160-bilateral-orchestration-write-gate.md`
- `docs/adr/ADR-171-client-intent-record-schema.md`

## 2. ROLE-1 — CEO-CONDUCTOR (chairman/CEO brain)

Knows the full bank structure/technology; coordinates all department heads.

| element | path | kind |
|---|---|---|
| CEO orchestrator (soul) | `agents/souls/ceo-orchestration-agent.md` | soul |
| CEO orchestrator (passport) | `agents/passports/ceo_orchestration_agent.yaml` | passport |
| Orchestration tree | `domain/orchestration-tree.md` | topology |
| AML orchestrator | `agents/souls/banxe-aml-orchestrator.md` (passport `banxe_aml_orchestrator.yaml` = **canonical**) | soul |
| CFO orchestrator | `agents/souls/cfo-orchestration-agent.md` | soul |
| Webhook orchestrator | `agents/souls/webhook-orchestrator-agent.md` | soul |
| SEPA channel orchestrator | `agents/souls/channel-c-sepa-orchestrator.md` | soul |
| SWIFT channel orchestrator | `agents/souls/channel-c-swift-orchestrator.md` | soul |
| Graph sandbox (runtime) | `banxe-emi-stack: services/banking-engine/graph_sandbox.py` | runtime (read-only) |
| Tier workers (routing) | `banxe-emi-stack: services/agent_routing/tier_workers.py` | runtime (read-only) |
| Engine ops scripts | `scripts/engines/{install-engines,engine-health-check,engines-access}.sh` | ops scripts |

**Conductor cabinet = source of truth = arch-repo souls (6) + passports (7)** (ceo, (banxe-)aml, cfo, webhook, sepa, swift). **P9 reference counts (aml=242, webhook=98, ceo=59) are MENTIONS across repos, NOT agent counts — refs ≠ agent count.**
**AML passport duplicate:** `agents/passports/aml_orchestrator.yaml` AND `banxe_aml_orchestrator.yaml` both exist → canonical = **`banxe_aml_orchestrator.yaml`**; the other flagged `[dedup-needed / pending human ratification]` (not deleted).

## 3. ROLE-2 — CLIENT-PM-FRIEND (personal manager & friend)

Direct, friendly client contact; resolves client questions across bank functions.

| element | path | kind |
|---|---|---|
| Intent layer | `banxe-emi-stack: services/intent_layer/{canary,composition,observability,shadow}.py` | runtime (read-only) |
| Client-intent-record schema | ADR-171 (`docs/adr/ADR-171-client-intent-record-schema.md`) | schema |
| Intent router | `banxe-emi-stack: api/routers/intent.py` | runtime (read-only) |
| Support router | `banxe-emi-stack: api/routers/support.py` | runtime (read-only) |
| Notifications-hub router | `banxe-emi-stack: api/routers/notifications_hub.py` | runtime (read-only) |
| Quant-advisory router | `banxe-emi-stack: api/routers/quant_advisory.py` | runtime (read-only) |
| Quant-advisory service | `banxe-emi-stack: services/quant_advisory/service.py` | runtime (read-only) |

## 4. SUBSTRATE (safety / observability / OSS base)

| element | path | kind |
|---|---|---|
| Midaz MCP | `banxe-emi-stack: services/midaz_mcp/{midaz_agent,midaz_client}.py` | runtime (read-only) · gated Midaz/MCP→ledger `[counsel]` |
| Budget gate | `banxe-emi-stack: services/runtime_gate/budget.py` | runtime (read-only) |
| Lineage + recorders | `banxe-emi-stack: services/agents/{_lineage,recorders}.py` | runtime (read-only) |
| Guardrails config | `banxe-emi-stack: services/banking-engine/compliance/guardrails_config.yaml` | config (read-only) |
| OSS base (TEMPLATE) | OpenManus (Manus base, 711 orch-signals); + banxe-ai-infrastructure, vibe-coding, merged-repo, developer-core | **template tech only** — Banksy deployed in its own zone; **NOT compiled over Legion** |

## 5. EXPANSION-AGENTS (reusable, to grow the engine)

Reusable agents that can be folded into the engine for multiplicative growth (candidates — actual fold-in is a factory step):
- `swarm/{base,behavior,geo_risk,product_limits,profile_history,sanctions}` (Layer-A sub-modules, already earmarked)
- `ObservabilityAgent`, `NotificationAgent`
- `[pending human ratification]`: which of these become engine sub-modules vs remain bank-room agents (overlaps the fx_engine / design_pipeline contested set); `[audit]`.

## Notes
- Runtime paths marked "(read-only)" live in `~/banxe-emi-stack`; not modified — the factory assembles code later.
- **HEART_STACK = 32 verified files** (A=12, B=8, C=5, D=7). The earlier "21" figure is **closed as 32** (reconciled); no `[reconcile]` outstanding on the count.
- Only engine-relevant files included; the P9 10547-file sweep is a raw catch and is **not** ingested wholesale.
- All legal / regulatory characterisation → `[counsel]`.

---
**This does not replace legal advice.**
