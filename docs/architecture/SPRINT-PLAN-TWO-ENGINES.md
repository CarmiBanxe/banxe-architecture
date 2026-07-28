# SPRINT PLAN — Two-Engine Execution Roadmap
# Тип: Factory sprint plan — source-backed, no invention
# Статус: DRAFT — operator ratification required (I-27)
# Дата: 2026-07-11
# Source truth: GROSSBUCH-TWO-ENGINES-CAPABILITY-ADDENDUM.md + audited corpus
# Запрещено: новые архитектурные решения вне аудированных документов

---

## A. Executive Statement

### Что делаем

Последовательно валидируем два раздельных execution engine:
1. **Private Legion Engine** — автономный агент (OpenManus) на Legion machine
2. **Banking / Banksy Engine** — compliance-grade banking orchestrator (LangGraph) на evo1

### Почему Legion первый

- Legion — первая физически доступная working машина.
- Private Engine config artifact (`config.toml`, `RUNBOOK.md`, `banxe-private-engine.service`) уже готов (commit `f9e5d7b`).
- Валидация Legion не зависит от banking compliance zone, HITL gates, или MLRO approvals.
- Быстрый feedback loop: install → test → iterate без regulatory overhead.
- Источник: Correction 1 §"Legion НЕ является fallback для banking-логики"; GROSSBUCH §B.

### Почему Banking / Banksy второй

- Banking Engine сильнее (evo1/evo2 cluster, LangGraph, compliance-grade memory stack).
- Требует sandbox mode (никаких live banking connections до full validation).
- Зависит от MLRO/CRO sign-off на HITL gates и BudgetManager activation.
- Источник: Correction 3 §"production prerequisites"; Correction 7 §"LangGraph canonical orchestrator".

### Что запрещено изобретать

- Любые модели/алиасы вне `litellm-config.v2.yaml` (20 confirmed aliases).
- Любые UI-решения вне задокументированных: Open WebUI / LibreChat / AnythingLLM / Next.js / React Native.
- Любые compliance flows вне audited HITL gates.
- Инфраструктура вне подтверждённых: evo1 (`100.68.102.48`) + evo2 (`192.168.0.15`) + Legion local.
- Если факт не подтверждён источником → `GAP` или `[НЕИЗВЕСТНО]`.

---

## B. Sprint Plan — Private Legion Engine

> Движемся от model backend → internet → web interface → mobile → governance → validation.
> Single-writer canon (I-71): все install/systemctl команды — оператор, не factory.

---

### Sprint L-0: Pre-flight Verification

**Goal:** Убедиться, что инфраструктура готова до первого install-шага. Ноль изменений на системе.

**Source-backed scope:**
- RUNBOOK.md Phase 0 чеклист (5 пунктов + 3a/3b)
- Verify `litellm-lan-gateway.service` active
- Verify evo2 (`192.168.0.15:11434`) reachable + qwen3 model present
- Verify LiteLLM alias `qwen3-30b` responds via `127.0.0.1:4000`
- Verify evo1 (`100.68.102.48:11434`) reachable (failover)
- Verify port `:8000` free
- Verify local Ollama `qwen3:30b-a3b` present (Tier 1 primary — `ollama list` or `ollama pull qwen3:30b-a3b`)
- Verify local Ollama `qwen2.5-coder:7b-instruct-q4_K_M` present (Tier 1b fast — already confirmed present)

**Included layers:** Model backend pre-check only. No writes.

**Done criteria:**
- All 5 pre-flight checks GREEN (systemctl, curl evo2, curl :4000 alias, curl evo1, ss :8000)
- Tier 1 PRIMARY (`qwen3:30b-a3b`) confirmed present in Ollama (`ollama list`)
- Tier 1b fast (`qwen2.5-coder:7b`) confirmed present in Ollama

**GAPs remaining:**
- Auth method для :4000 rotation policy — not in scope here
- VRAM headroom under concurrent loads — `[НЕИЗВЕСТНО]`

---

### Sprint L-1: Core Engine Install + Model Backend

**Goal:** OpenManus running on Legion, Tier 1 LOCAL (qwen3:30b-a3b via Ollama :11434) round-trip confirmed.
Engine is AUTONOMOUS — primary inference runs locally on Legion without evo dependency.

**Source-backed scope:**
- PRE-FLIGHT (operator): `ollama pull qwen3:30b-a3b` (18.6 GB — confirmed on evo1+evo2 2026-07-11; OI-LOCAL-1 G-1 resolved)
- RUNBOOK.md Phase 1: `git clone OpenManus → ~/OpenManus`, venv, `pip install`
- RUNBOOK.md Phase 2: deploy `config.toml` (Tier 1 active: `qwen3:30b-a3b` via `127.0.0.1:11434`; evo :4000 fallback commented-out)
- RUNBOOK.md Phase 3: deploy systemd unit (`banxe-private-engine.service`), `systemctl enable + start`
- RUNBOOK.md Phase 4 steps 1–3: `is-active`, `/health`, local Ollama round-trip smoke test
- GPU offload verify: `nvidia-smi` — VRAM < 85% (< 6.96 GB of 8188 MiB) during inference
- DLP verification: `grep -E "postgres|IBAN|password"` на config — expected: no output

**Included layers:** Model backend (Tier 1 local). No internet tools yet.

**Done criteria:**
- `ollama run qwen3:30b-a3b "hello, what model are you?"` → responds locally (pre-flight)
- `systemctl is-active banxe-private-engine` → `active`
- `GET /health` → `200`
- `POST /run/agent` с задачей `"echo test"` → ответ через local Ollama :11434 (Tier 1 path confirmed)
- `nvidia-smi` VRAM < 85% during agent run
- DLP grep clean
- Evo :4000 (Tier 2 fallback): documented as commented-out block in config.toml — NOT active by default

**GAPs remaining:**
- `api_server.py` endpoint schema (`/run/agent` payload format) — зависит от OpenManus version
- Ollama `num_gpu` tuning (reference: 20 GPU layers from source; exact optimal value requires measurement after pull)

---

### Sprint L-2: Internet Access Layer

**Goal:** Search + browser automation работают; DLP boundary держит.

**Source-backed scope:**
- `duckduckgo_search` tool: free, no API key, rate-limited (source: `manus-legion-private-engine.md`)
- `browser_use_tool` (Playwright Chromium): headless browser, operator installs Playwright
- Google Search API key setup (SerpAPI/Serper.dev, free tier 100 q/day) — optional
- Telegram bot (polling mode, no public IP): 4096 char limit, 300s timeout
- DLP check post-execution: `journalctl | grep -E "IBAN|postgres|customer_id"` → 0 results
- Network isolation verify: Legion не имеет маршрутов к banking DBs

**Included layers:** Internet access. Bash tool. DLP boundary smoke test.

**Done criteria:**
- `duckduckgo_search` returns results for a test query
- `browser_use_tool` opens a public URL, returns page content
- DLP journal check: 0 banking data in agent output logs
- Telegram bot responds to `/start` (optional — if operator enables)

**GAPs remaining:**
- Cloudflare/CAPTCHA blocking: mitigation strategy not in sources — `[НЕИЗВЕСТНО]`
- Google Search API key provisioning — operator action, not automated

---

### Sprint L-3: Web Interface Layer

**Goal:** Operator has a working UI to interact with OpenManus beyond raw REST calls.

**Source-backed scope (operator selects ONE):**

| Option | Source | Notes |
|--------|--------|-------|
| Open WebUI (`:3000`, Docker) | `manus-legion-private-engine.md` | Voice I/O, RAG, file artifacts |
| LibreChat (Docker) | `manus-legion-private-engine.md` | Agent Builder UI, MCP-native, code exec |
| AnythingLLM Desktop (AppImage) | `manus-legion-private-engine.md` | Simplest, no Docker |

- Connect selected UI to OpenManus `api_server.py` backend on `:8000`
- FastAPI REST API: `POST /run/agent`, `GET /health` (source: RUNBOOK.md Phase 4)
- Verify bind: `:8000` on localhost only, NOT `0.0.0.0` (RUNBOOK.md Phase 4 step 4)

**Included layers:** Web interface (operator-facing). Admin/control surface.

**Done criteria:**
- Selected UI loads and sends a task to OpenManus successfully
- Response rendered in UI with full output (no truncation)
- `:8000` bind confirmed: NOT exposed to `0.0.0.0` without firewall rule

**GAPs remaining:**
- **[НЕИЗВЕСТНО]** — operator UI selection not made yet (OI-5 from grossbuch)
- Auth layer for UI access not specified in sources — `GAP`

---

### Sprint L-4: Mobile / Remote Access Layer

**Goal:** Operator accesses Legion engine from mobile device + outside local Wi-Fi.

**Source-backed scope:**
- iOS: Enchanted LLM (free, open-source, iOS 17.0+, Markdown/code rendering) — `manus-legion-private-engine.md`
- Android: Open Mobile UI (React Native, official Open WebUI client, updated April 2026)
- Tunnel option A: Cloudflare Tunnel (free, persistent URL `xxx-yyy.trycloudflare.com`, requires Cloudflare account)
- Tunnel option B: ngrok (simpler, URL changes on restart, free tier)
- Local Wi-Fi: direct `192.168.x.x:8000` or `:3000` — no tunnel needed

**Included layers:** Mobile operator access. Remote egress via tunnel.

**Done criteria:**
- Mobile client connects to Legion engine (via local Wi-Fi or tunnel)
- Operator sends a task from mobile, receives full response
- Tunnel URL (if used): stable across Legion restarts (→ Cloudflare preferred over ngrok)

**GAPs remaining:**
- **[НЕИЗВЕСТНО]** — auth/token method for mobile → Legion API (OI-6 from grossbuch)
- SLA/latency targets not defined in sources — `GAP`

---

### Sprint L-5: DLP Hardening + Governance Layer

**Goal:** DLP enforcement в production: NeMo Guardrails + OS-level sandbox.

**Source-backed scope:**
- NeMo Guardrails (NVIDIA, Apache 2.0): программные ограничения на agent output (Correction 4)
- LlamaFirewall: output-filter перед отправкой в UI (Correction 4)
- OS-sandbox: Landlock (Linux 5.13+) + seccomp + namespaces — изоляция Legion процессов (Correction 4)
- Verify: no banking credentials accessible to OpenManus process
- MLRO/CTO awareness memo filed (Correction 4 §"доступ Legion в banking zone: read-only, logged")

**Included layers:** DLP. OS isolation. Governance memo.

**Done criteria:**
- NeMo Guardrails configured and blocking PII output in test cases
- LlamaFirewall active on OpenManus output path
- OS sandbox: Legion process cannot read banking Postgres/ClickHouse (network unreachable test)
- MLRO/CTO memo: filed (operator action, not factory)

**GAPs remaining:**
- NeMo Guardrails deployment status: `PARTIAL` в источниках — designed, not confirmed deployed (OI-7)
- LlamaFirewall production version/config not specified in sources

---

### Sprint L-6: Memory Layer

**Goal:** Operator sessions имеют persistent memory; banking data не попадает в Legion memory.

**Source-backed scope:**
- Separate Qdrant instance на Legion — dev/research semantics only (Correction 5)
- Mem0 (Apache 2.0) — long-term memory для operator sessions (Correction 5)
- Hard boundary: Legion Qdrant ≠ banking Qdrant на evo1 (Correction 5)
- Sync between contours: только через human-approved export с audit trail (Correction 5)

**Included layers:** Memory (Legion-local only).

**Done criteria:**
- Legion Qdrant running locally and accessible to OpenManus
- Mem0 session memory persists between operator tasks
- Verify: Legion Qdrant has no network route to banking Qdrant on evo1

**GAPs remaining:**
- Qdrant version/config for Legion not specified in sources
- Mem0 integration with OpenManus `api_server.py` — integration pattern `[НЕИЗВЕСТНО]`

---

### Sprint L-7: Full Legion Validation

**Goal:** Private Legion Engine полностью валидирован как powerful multi-layer autonomous engine.

**Source-backed scope:**
- End-to-end test: multi-step research task (web search → browser → analysis → structured output)
- Tier-switching test: Tier 1 (local qwen3:30b-a3b via :11434) → Tier 2 (qwen3-30b via :4000 fallback) → Tier 3 (reasoning-235b) → Tier 4 (coding)
- DLP full audit: journalctl scan для IBAN/postgres/customer_id/kycId → 0 results
- Memory isolation verify: Legion Qdrant ≠ banking Qdrant (network unreachable)
- All 8 Open Items from grossbuch: resolved or formally documented as GAP

**Included layers:** All L-0 through L-6 layers.

**Done criteria:**
- All sprints L-0..L-6 Done criteria met
- Multi-tier model switching confirmed working
- Zero DLP leaks in test suite
- Open Items: each has status RESOLVED or documented GAP with owner

**GAPs remaining (carry-forward):**
- OI-1..OI-4 (Banking Engine — out of scope for Legion)
- Auth for mobile (OI-6) — если не resolved в L-4

---

## C. Sprint Plan — Banking / Banksy Engine

> Banking Engine = stronger, compliance-grade engine. Sandbox mode first — no live banking connections.
> Orchestrator: LangGraph (canonical, Correction 7). All HITL gates active.

---

### Sprint B-0: Sandbox Baseline

**Goal:** Banking Engine operation context established; sandbox confirmed (no live banking connections).

**Source-backed scope:**
- Confirm LangGraph available on evo1 or reachable target
- Confirm LiteLLM `:4000` accessible from Banking Engine (thin-client на Legion → evo1)
- Verify `banxe-general` alias responds: `curl -H "Authorization: Bearer ..."` → HTTP 200
- Sandbox mode definition: all external banking calls (PSD2, Adorsys) → stubs/mocks only
- Correction 1: Legion thin-client НЕ executes banking logic — evo1 is execution host

**Included layers:** Model backend (pre-check). Sandbox mode declaration.

**Done criteria:**
- LiteLLM `banxe-general` alias: HTTP 200 confirmed
- Sandbox mode: documented and enforced (no live PSD2/Adorsys connections)
- evo1 ↔ evo2 failover path: tested

**GAPs remaining:**
- **[НЕИЗВЕСТНО]** — default model alias for Banking Engine (OI-1 from grossbuch)

---

### Sprint B-1: LangGraph Orchestrator + Model Backend

**Goal:** LangGraph orchestrator running, wired to LiteLLM :4000, stateful checkpointing confirmed.

**Source-backed scope:**
- LangGraph: stateful, checkpoint-based, durable, auditable, native HITL (Correction 7)
- Wire to LiteLLM `:4000` via `banxe-general` alias (default banking model)
- LiteLLM BudgetManager: per-agent financial cost caps (source: `emi-banxe-intent-first-banking-2026-07-10.md`)
- Strands SDK (AWS) — optional multi-backend support (source: `emi-banxe-engine-v2-2026-07-09.md`)
- TransferAgent config: `claude-3-5-sonnet` or `DeepSeek-V3` (source: `emi-banxe-engine-v2-2026-07-09.md`)
- Temporal vs LangGraph: OPEN ITEM — ADR required (Correction 7 §open item → OI-8)

**Included layers:** Model backend. Orchestrator. Budget controls.

**Done criteria:**
- LangGraph workflow completes a test task end-to-end with checkpoint persistence
- LiteLLM BudgetManager: per-agent cap enforced (test: exceed cap → blocked)
- State transition logged (auditable)

**GAPs remaining:**
- OI-1: Default model alias not resolved
- OI-8: Temporal ADR not written — LangGraph-first по умолчанию (Correction 7)

---

### Sprint B-2: Internet Access (Controlled, PSD2 Sandbox)

**Goal:** Open Banking access works in sandbox mode; no uncontrolled external internet egress.

**Source-backed scope:**
- Open Banking Gateway: Adorsys (Apache 2.0), RESTful PSD2/XS2A — sandbox stub only (source: `banxe-oss-free-agent-solutions-2026-07-10.md`)
- MCP interface: banking API, ledger, CRM — stub adapters (source: `banxe-oss-free-agent-solutions-2026-07-10.md`)
- DeerFlow Researcher Agent: web search + MCP tools — sandbox only (source: `emi-banxe-engine-v2-2026-07-09.md`)
- Banking zone isolation: no direct external internet routes; data via API Gateway with logging (Correction 4)
- All egress logged: `X-Request-ID` on every request (API Contract Rules, `20-api-contracts.md`)

**Included layers:** Internet access (sandbox). PSD2 stub. MCP stubs.

**Done criteria:**
- Adorsys stub responds to bank statement request (CAMT.053 format)
- MCP tool call to banking ledger stub: returns test data
- Egress log: all outbound calls captured with `X-Request-ID`
- External internet: blocked at network level for banking zone (verify with `curl` from evo1)

**GAPs remaining:**
- Production Adorsys credentials + bank connections — out of scope for sandbox sprint
- OI-2: Production firewall rules — `GAP`

---

### Sprint B-3: Web Interface Layer

**Goal:** Banking web app foundation running locally (sandbox UI).

**Source-backed scope:**
- Next.js 15 App Router + TypeScript (source: `banxe-uxui-architecture-2026-07-10.md`)
- assistant-ui (MIT, YC W25): production-grade AI chat library + Generative UI (source: `banxe-uxui-architecture-2026-07-10.md`)
- Vercel AI SDK (Apache 2.0): streaming, tool calling, structured outputs (source: `banxe-uxui-architecture-2026-07-10.md`)
- Design system: shadcn/ui + Radix UI + Tailwind CSS + Lucide Icons (source: `banxe-uxui-architecture-2026-07-10.md`)
- Voice layer: Whisper (MIT) STT + Coqui TTS (MIT) (source: `emi-banxe-engine-v2-2026-07-09.md`)
- Figma MCP Server (official, April 2026): design-to-code pipeline (source: `banxe-uxui-architecture-2026-07-10.md`)

**Included layers:** Web interface. Design system. Voice layer.

**Done criteria:**
- Next.js 15 app boots locally
- assistant-ui: AI chat component renders and streams response from LangGraph backend
- shadcn/ui design system components load
- Voice round-trip: Whisper STT → LangGraph → Coqui TTS (sandbox, no live data)

**GAPs remaining:**
- OI-3: Production deployment URL/infra — `GAP`
- Figma-to-code pipeline: requires Figma file + Penpot MCP setup — operator action

---

### Sprint B-4: Mobile App Layer

**Goal:** Banking mobile app foundation runnable on device in sandbox mode.

**Source-backed scope:**
- React Native + Expo: cross-platform iOS/Android (source: `banxe-uxui-architecture-2026-07-10.md`)
- NativeWind: Tailwind CSS for React Native (source: `banxe-uxui-architecture-2026-07-10.md`)
- Bottom Navigation Bar: 5 tabs — Home, AI Agent, Cards, Crypto, Profile (source: `banxe-uxui-architecture-2026-07-10.md`)
- Floating AI Button: Revolut AIR pattern, accessible from any screen (source: `banxe-uxui-architecture-2026-07-10.md`)
- SCA: Face ID / Touch ID biometric auth для payment operations (source: `emi-banxe-intent-first-banking-2026-07-10.md`)
- Push notifications: AI Insight Cards с context-aware financial alerts (source: `banxe-uxui-architecture-2026-07-10.md`)
- IAM: Keycloak 26.2 on `:8180` (confirmed deployed, `CLAUDE.md` stack)

**Included layers:** Mobile client. SCA. Push notifications. Auth.

**Done criteria:**
- Expo app runs on device (iOS or Android)
- 5-tab navigation renders correctly
- Floating AI Button opens chat → connects to LangGraph sandbox backend
- Keycloak auth: login flow completes (sandbox Keycloak, no real customers)
- SCA mock: Face ID prompt appears on payment action (sandbox)

**GAPs remaining:**
- OI-4: App Store / Play Store deployment status — `GAP` (out of scope for sandbox sprint)
- SLO/latency targets: `[НЕИЗВЕСТНО]`

---

### Sprint B-5: HITL + Compliance Layer

**Goal:** Banking HITL gates enforced. AI proposes, human decides — no autonomous writes.

**Source-backed scope:**
- LangGraph native HITL support (Correction 7)
- HITL gates from `agent-authority.md`: SAR_filing (24h), AML_threshold_change (4h), sanctions_reversal (1h), PEP_onboarding (48h)
- NeMo Guardrails: output filtering for banking agent (Correction 4 / `80-ai-agents.md`)
- I-27 enforcement: agents PROPOSE, never auto-apply (`.claude/rules/financial-invariants.md`)
- pgAudit + ClickHouse: every financial action logged (I-24, append-only)
- Autonomy levels: L1 auto → L4 human-only per `agent-authority.md`

**Included layers:** HITL gates. Compliance agents. Audit trail.

**Done criteria:**
- HITL gate test: SAR candidate proposal → blocked pending MLRO approval (24h timeout enforced)
- LangGraph state checkpoint: every state transition has audit record in ClickHouse
- I-27 invariant: no agent auto-applies a write above its autonomy level (test: L2 agent cannot self-approve)
- pgAudit active on test financial table

**GAPs remaining:**
- NeMo Guardrails banking config: separate from Legion config — not yet specified (OI-7)

---

### Sprint B-6: Memory Layer (Banking)

**Goal:** Banking memory stack running on evo1; hard boundary with Legion confirmed.

**Source-backed scope:**
- Qdrant на evo1: semantic search по banking knowledge (Correction 5)
- Zep (Apache 2.0): Temporal Knowledge Graph для банковского контекста клиента (Correction 5)
- Graphiti: temporal KG с версионированием для compliance + audit (Correction 5)
- LlamaIndex: ingestion pipeline для regulatory documents (Correction 5)
- Hard boundary: banking Qdrant НЕ доступен Legion напрямую (Correction 5)
- Sync cross-contour: только через explicit human-approved export с audit trail (Correction 5)

**Included layers:** Semantic memory. Temporal KG. Regulatory document ingestion.

**Done criteria:**
- Qdrant evo1: vector store initialized with sandbox banking knowledge
- Zep: session context persisted across LangGraph turns
- Graphiti: at least one compliance event versioned with timestamp
- Network test: Legion cannot reach banking Qdrant evo1 (connection refused)

**GAPs remaining:**
- LlamaIndex regulatory corpus: which documents to ingest — operator decision
- Graphiti compliance audit schema: not specified in sources

---

### Sprint B-7: Full Banking Sandbox Validation

**Goal:** Banking Engine fully validated in sandbox mode — no live connections, all gates active.

**Source-backed scope:**
- End-to-end test: payment intent → LangGraph → HITL gate → sandbox confirmation
- Verify: Legion НЕ является fallback для banking-логики (Correction 1)
- Verify: no write to banking ledger from Legion (ADR-103)
- All HITL gates tested: SAR, AML threshold, sanctions
- DLP audit: no PII crosses banking ↔ Legion boundary
- EU AI Act Art.14: human oversight present at all L3+ decisions (Correction 4 §compliance)

**Included layers:** All B-0 through B-6 layers.

**Done criteria:**
- All sprints B-0..B-6 Done criteria met
- Payment intent test: completes via HITL approval, not auto-execute
- Legion ↔ Banking boundary: no unauthorized data flow in test suite
- EU AI Act Art.14: documented oversight evidence for each L3+ decision in test

**GAPs remaining (carry-forward):**
- OI-1: Default banking model alias — needs config-audit
- OI-2: Production firewall rules
- OI-3: Production web deployment
- OI-4: App Store status / SLO
- OI-8: Temporal vs LangGraph ADR

---

## D. Cross-Engine Alignment Sprint

### Sprint X-1: Shared Gateway + DLP Boundary Verification

**Goal:** LiteLLM :4000 serves both engines simultaneously without contamination.

**Source-backed scope:**

| Shared component | Fact | Source |
|-----------------|------|--------|
| LiteLLM :4000 | Shared inference gateway, 20 aliases | `litellm-config.v2.yaml` |
| Master key | `sk-banxe-llm-gateway-2026` (от gateway config, не от `.env`) | `litellm-config.v2.yaml` |
| IPv4 enforcement | `127.0.0.1:4000` only; `::1:4000` refused | Operator shell audit |
| `banxe-general` | Reserved for Banking Engine; BANNED from Private Engine `config.toml` | ADR-103 + `config.toml` |
| DLP boundary | ADR-103: no PII / banking creds / ledger write from Legion | Correction 4 |
| Memory isolation | Legion Qdrant ≠ banking Qdrant evo1 | Correction 5 |
| I-71 single-writer | Applies to BOTH engine configs | Canon (immutable) |

**What is separate (not shared):**

| Component | Banking Engine | Private Legion Engine |
|-----------|--------------|----------------------|
| Orchestrator | LangGraph | OpenManus |
| Default model alias | `banxe-general` (and related) | `qwen3:30b-a3b` (local Ollama :11434; `qwen3-30b` via :4000 as fallback) |
| Memory backend | Qdrant evo1 + Zep + Graphiti + LlamaIndex | Qdrant Legion + Mem0 |
| DLP outbound | NeMo Guardrails (banking config) | NeMo Guardrails (Legion config) |
| HITL gates | MLRO/CRO required | Operator-only (no MLRO) |
| Internet | Isolated; API Gateway only | Open (DLP-filtered) |
| Write authority | Ledger via LangGraph + HITL only | No write to banking ledger |

**Done criteria:**
- Concurrent load test: both engines calling LiteLLM :4000 simultaneously → no cross-contamination
- `banxe-general` alias: absent from Private Engine config (grep verify)
- Legion Qdrant ≠ banking Qdrant: network isolation confirmed
- I-71: both engine configs under single-writer governance (operator-only push)

**GAPs remaining:**
- OI-7: NeMo Guardrails deployment — confirmed deployed for both engines? `[НЕИЗВЕСТНО]`

---

### Sprint X-2: Temporal / LangGraph ADR Resolution

**Goal:** Закрыть OI-8 — открытый архитектурный вопрос по Temporal.

**Source-backed scope:**
- Correction 7 §Temporal: "OPEN ITEM — требует ADR перед выбором. LangGraph-first по умолчанию."
- "Если LangGraph реализует durable workflows через checkpoint + async → Temporal может быть избыточен для базовых CASS 15 workflows"
- "Если требуется cross-service saga pattern с guaranteed delivery → Temporal добавляет ценность"

**Required output:** New ADR in `docs/adr/` covering: LangGraph-only vs LangGraph + Temporal decision with CASS 15 workflow requirements as evidence.

**Done criteria:**
- ADR drafted and submitted for operator ratification
- LangGraph-first assumption: formally documented as interim default until ADR ratified

**GAPs remaining:**
- CASS 15 saga pattern requirements: not fully specified in current corpus → requires operator input

---

## E. Final Operator-Facing Sequencing

```
─────────────────────────────────────────────────────────────────────
PHASE 1: LEGION FULL VALIDATION
─────────────────────────────────────────────────────────────────────
  L-0  Pre-flight verification          [operator: read-only checks]
  L-1  Core engine install + backend    [operator: install + systemd]
  L-2  Internet access layer            [operator: Playwright install]
  L-3  Web interface layer              [operator: UI selection + Docker]
  L-4  Mobile / remote access           [operator: tunnel + mobile app]
  L-5  DLP hardening + governance       [operator: NeMo + Landlock]
  L-6  Memory layer                     [operator: Qdrant + Mem0]
  L-7  Full Legion validation           [operator: end-to-end test suite]

  EXIT CRITERION: Legion engine passes L-7 Done criteria.
  GAPs carry-forward to PHASE 3 if not resolved.

─────────────────────────────────────────────────────────────────────
PHASE 2: BANKING / BANKSY SANDBOX ENGINE
─────────────────────────────────────────────────────────────────────
  B-0  Sandbox baseline                 [operator: mode declaration]
  B-1  LangGraph + model backend        [operator: LangGraph setup]
  B-2  Internet access (sandbox)        [operator: Adorsys stub + MCP stubs]
  B-3  Web interface layer              [operator: Next.js + assistant-ui]
  B-4  Mobile app layer                 [operator: Expo + Keycloak]
  B-5  HITL + compliance layer          [operator: MLRO gates active]
  B-6  Memory layer                     [operator: Qdrant evo1 + Zep + Graphiti]
  B-7  Full Banking sandbox validation  [operator: end-to-end HITL test suite]

  EXIT CRITERION: Banking Engine passes B-7 Done criteria (sandbox mode).
  No live banking connections until operator explicitly authorizes PHASE 3.

─────────────────────────────────────────────────────────────────────
PHASE 3: DUAL-ENGINE CONVERGENCE
─────────────────────────────────────────────────────────────────────
  X-1  Shared gateway + DLP verification  [concurrent load test]
  X-2  Temporal / LangGraph ADR           [architecture decision]
  OI   Resolve remaining Open Items       [OI-1..OI-8 from grossbuch]

  EXIT CRITERION: All OI items either RESOLVED or formally documented as
  permanent GAP with owner. Both engines operating concurrently on LiteLLM :4000
  without contamination. ADR for Temporal filed.

─────────────────────────────────────────────────────────────────────
```

---

## Traceability Index

| Sprint | Primary sources |
|--------|----------------|
| L-0..L-1 | `RUNBOOK.md` artifact; `litellm-config.v2.yaml`; hardware audit |
| L-2 | `manus-legion-private-engine.md` §tools; Correction 4 §DLP |
| L-3 | `manus-legion-private-engine.md` §UI options; `RUNBOOK.md` Phase 4 |
| L-4 | `manus-legion-private-engine.md` §mobile; §tunnels |
| L-5 | Correction 4 §DLP implementation; `.claude/rules/80-ai-agents.md` |
| L-6 | Correction 5 §Private Engine memory |
| L-7 | GROSSBUCH §B all layers; Open Items OI-1..OI-8 |
| B-0..B-1 | Correction 7; `litellm-config.v2.yaml`; Correction 1 |
| B-2 | `banxe-oss-free-agent-solutions-2026-07-10.md`; Correction 4 |
| B-3 | `banxe-uxui-architecture-2026-07-10.md`; `emi-banxe-engine-v2-2026-07-09.md` |
| B-4 | `banxe-uxui-architecture-2026-07-10.md`; `emi-banxe-intent-first-banking-2026-07-10.md` |
| B-5 | `agent-authority.md`; `80-ai-agents.md`; Correction 4; I-27 |
| B-6 | Correction 5 §Banking Engine memory |
| B-7 | GROSSBUCH §A all layers; ADR-103; Correction 1; EU AI Act Art.14 |
| X-1 | ADR-103; Correction 5; `litellm-config.v2.yaml`; Operator shell audit |
| X-2 | Correction 7 §Temporal open item |
