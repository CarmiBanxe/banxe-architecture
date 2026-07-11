# GROSSBUCH ADDENDUM — Two-Engine Capability Matrix
# Тип: Pointer-style аддendum к master analysis
# Статус: DRAFT — operator + Central ratification required (I-27)
# Дата: 2026-07-09
# Источник-base: two-engines-master-analysis-and-roadmap-canonical-2026-07-10.md
# Scope: 4 capability layers × 2 engines — только факты из источников (указатели, не дубликаты)

---

## Назначение документа

Этот документ НЕ дублирует source docs. Он описывает **состояние** каждого capability layer
по каждому engine с явной ссылкой на источник. Всё неизвестное — помечено `[НЕИЗВЕСТНО]`.
Формат: объяснения на русском, технические имена/пути/команды — на английском.

Layers:
1. **Model backend** — inference, routing, failover
2. **Internet access** — egress, web/API calls, restrictions
3. **Web interface** — browser UI, automation, authenticated flows
4. **Mobile app** — mobile client, SCA, push, external access

---

## SECTION A — Banking Engine

> Banking Engine = thin-client на Legion → evo1 (primary) + evo2 (failover) via LiteLLM :4000.
> Оркестратор: LangGraph. FCA CASS 15 compliance zone. Write в banking ledger — только banking engine.

### A-1. Model Backend

| Параметр | Факт | Статус | Источник |
|----------|------|--------|---------|
| Orchestrator | LangGraph (stateful checkpoint-based, durable, auditable, native HITL) | READY (canonical) | Correction 7 |
| Inference gateway | LiteLLM :4000 (20 aliases: `banxe-general`, `coding`, `qwen3-30b`, `reasoning`, etc.) | READY | litellm-config.v2.yaml |
| Primary model | [НЕИЗВЕСТНО] — какой именно LiteLLM alias Banking Engine использует по умолчанию | [НЕИЗВЕСТНО] | — |
| Failover chain | evo1 → evo2 (banking); Legion НЕ является fallback для banking-логики | READY (canon) | Correction 1 |
| SDK support | Strands SDK (AWS): Bedrock, Anthropic Claude, Gemini, OpenAI, Ollama, LiteLLM | PARTIAL (option, not confirmed in prod) | emi-banxe-engine-v2-2026-07-09.md |
| Cost caps | LiteLLM BudgetManager — per-agent financial cost caps | PARTIAL (designed, not confirmed deployed) | emi-banxe-intent-first-banking-2026-07-10.md |
| Banned on Banking Engine | `banxe-general` НЕ зарезервирован и NOT banned — это основной alias banking engine | READY | litellm-config.v2.yaml |
| Legion banking role | Thin-client only — execution на evo1. Legion НЕ executes banking logic. | READY (ADR-103) | Correction 1 |

**Вывод A-1:** Оркестратор и gateway подтверждены. Конкретный default model alias banking engine — `[НЕИЗВЕСТНО]`, требует ADR или config-audit.

---

### A-2. Internet Access

| Параметр | Факт | Статус | Источник |
|----------|------|--------|---------|
| External internet | Banking zone изолирована — нет прямых маршрутов во внешний интернет | READY (design) | Correction 4 (boundary section) |
| API Gateway egress | Данные пересекают API Gateway только с logging | READY | BANXE-Private-Legion-Engine-Otvety-na-otkrytye-voprosy-arkhitektury |
| Open Banking (PSD2) | Adorsys Open Banking Gateway (Apache 2.0) — RESTful API для PSD2/XS2A доступа к European banks | READY (design) | banxe-oss-free-agent-solutions-2026-07-10.md |
| MCP interface | MCP = standard interface агентов к banking API, ledger, CRM | READY | banxe-oss-free-agent-solutions-2026-07-10.md |
| Agent web search | DeerFlow Researcher Agent поддерживает web search + MCP tools | PARTIAL (option) | emi-banxe-engine-v2-2026-07-09.md |
| Production egress rules | [НЕИЗВЕСТНО] — конкретные firewall/network rules для evo1/evo2 | [НЕИЗВЕСТНО] | — |

**Вывод A-2:** Изоляция banking zone подтверждена архитектурно. Production network rules — `[НЕИЗВЕСТНО]`.

---

### A-3. Web Interface

Банковский web UI — для operators/customers, НЕ для автономных агентов.

| Параметр | Факт | Статус | Источник |
|----------|------|--------|---------|
| Web framework | Next.js 15 App Router + TypeScript | PARTIAL (designed) | banxe-uxui-architecture-2026-07-10.md |
| AI Chat UI | assistant-ui (MIT, YC W25) — production-grade AI chat library с Generative UI | PARTIAL (selected) | banxe-uxui-architecture-2026-07-10.md |
| Streaming | Vercel AI SDK (Apache 2.0) — unified streaming API, tool calling, structured outputs | PARTIAL (selected) | banxe-uxui-architecture-2026-07-10.md |
| Design system | shadcn/ui + Radix UI + Tailwind CSS + Lucide Icons (1600+ icons) | PARTIAL (designed) | banxe-uxui-architecture-2026-07-10.md |
| Design pipeline | Figma MCP Server (официальный, April 2026) — AI reads/writes Figma → code | PARTIAL (designed) | banxe-uxui-architecture-2026-07-10.md |
| Voice layer | Whisper (MIT) STT + Coqui TTS (MIT) | PARTIAL (selected) | emi-banxe-engine-v2-2026-07-09.md |
| Browser automation (banking agent) | [НЕИЗВЕСТНО] — нет данных о Playwright/browser-use для banking agent | [НЕИЗВЕСТНО] | — |
| Production deployment | [НЕИЗВЕСТНО] — web app deployed URL, infra | [НЕИЗВЕСТНО] | — |

**Вывод A-3:** Tech stack выбран и задокументирован. Production deployment — `[НЕИЗВЕСТНО]`.

---

### A-4. Mobile App

| Параметр | Факт | Статус | Источник |
|----------|------|--------|---------|
| Framework | React Native + Expo (cross-platform iOS/Android) | PARTIAL (designed) | banxe-uxui-architecture-2026-07-10.md |
| Styling | NativeWind (Tailwind CSS for React Native) | PARTIAL (designed) | banxe-uxui-architecture-2026-07-10.md |
| Navigation | Bottom Navigation Bar: 5 tabs (Home, AI Agent, Cards, Crypto, Profile) | PARTIAL (designed) | banxe-uxui-architecture-2026-07-10.md |
| AI access | Floating AI Button (Revolut AIR pattern) — accessible from any screen | PARTIAL (designed) | banxe-uxui-architecture-2026-07-10.md |
| SCA auth | Face ID / Touch ID biometric auth для payment operations | PARTIAL (designed) | emi-banxe-intent-first-banking-2026-07-10.md |
| Push notifications | AI Insight Cards с context-aware financial alerts | PARTIAL (designed) | banxe-uxui-architecture-2026-07-10.md |
| IAM | Keycloak 26.2 on :8180 (IAM_ADAPTER=keycloak) | READY (deployed) | CLAUDE.md stack |
| Production app store status | [НЕИЗВЕСТНО] | [НЕИЗВЕСТНО] | — |
| Latency SLO | [НЕИЗВЕСТНО] — конкретные SLO targets не найдены в источниках | [НЕИЗВЕСТНО] | — |

**Вывод A-4:** Mobile архитектура спроектирована полностью. Production readiness — `[НЕИЗВЕСТНО]`.

---

## SECTION B — Private Legion Engine

> Private Legion Engine = OpenManus autonomous agent (browser/bash/search/code) на Legion machine.
> Назначение: dev/research/operator tasks. НЕ часть banking compliance zone.
> Inference: LiteLLM :4000 → evo2 primary + evo1 failover. DLP boundary: ADR-103 / Correction 4.

### B-1. Model Backend

| Параметр | Факт | Статус | Источник |
|----------|------|--------|---------|
| Runtime | OpenManus (3-layer: Agent + Tool + Memory) — autonomous task execution | READY (artifact) | manus-legion-private-engine.md, config.toml |
| Active tier (default) | `qwen3-30b` → qwen3:30b-a3b на evo2 (18GB VRAM, 30B MoE) via LiteLLM :4000 | READY (config artifact) | config.toml |
| Tier 1 (local, optional) | `qwen2.5-coder:7b-instruct-q4_K_M` via local Ollama `127.0.0.1:11434` — 4.7GB VRAM | READY (Ollama confirmed present) | manus-legion-private-engine.md |
| Tier 3 (heavy) | `reasoning` / `reasoning-235b` → qwen3:235b-a22b (142GB) via :4000 | READY (alias exists) | litellm-config.v2.yaml |
| Tier 4 (coding) | `coding` / `factory-coder` → evo2 via :4000 | READY (alias confirmed live) | litellm-config.v2.yaml |
| VRAM constraint | Legion RTX 4070 Laptop = 8GB VRAM. Only ≤7B fits on GPU. 30B–235B — remote only. | HARD CONSTRAINT | Hardware audit |
| Failover | evo1 (100.68.102.48) ONLINE — mirrors qwen3:30b; LiteLLM auto-routes | READY | BANXE-Private-Legion-Engine-Otvety-na-otkrytye-voprosy-arkhitektury |
| API server | FastAPI `api_server.py` на :8000 — REST interface for OpenManus | PARTIAL (requires Phase 1 install) | manus-legion-private-engine.md |
| Blueprint backend (superseded) | llama-server :8080 с uncensored Qwen3.6 + Huihui vision :8081 — НЕ ИСПОЛЬЗУЕТСЯ | BLOCKED (design superseded) | manus-legion-private-engine.md |
| Banned alias | `banxe-general` — зарезервирован для Banking Engine, запрещён в config.toml | READY (enforced in artifact) | ADR-103 / config.toml |
| Memory (Legion) | Отдельный Qdrant instance на Legion + Mem0 (Apache 2.0) для operator sessions | PARTIAL (designed) | Correction 5 |

**Вывод B-1:** Model backend полностью спроектирован. Config artifact готов. Статус: READY — ожидает operator install (HITL Phase 1).

---

### B-2. Internet Access

| Параметр | Факт | Статус | Источник |
|----------|------|--------|---------|
| Search (free) | `duckduckgo_search` — no API keys, rate-limited by DuckDuckGo | READY (tool available) | manus-legion-private-engine.md |
| Search (premium) | Google Search via SerpAPI / Serper.dev (free tier: 100 queries/day) | PARTIAL (requires API key setup) | manus-legion-private-engine.md |
| Browser automation | `browser_use_tool` — Playwright Chromium; headless; may be blocked by Cloudflare/CAPTCHA | PARTIAL (requires Playwright install) | manus-legion-private-engine.md |
| Bash/shell egress | `bash_tool` — unrestricted shell exec в sandbox | READY (by design) | manus-legion-private-engine.md |
| DLP outbound rule | Legion НЕ ДОЛЖЕН выносить: PII, API keys, banking credentials, source code from banking repos | HARD CONSTRAINT (ADR-103) | Correction 4 |
| Banking zone access | READ-ONLY (статусы/метрики) — разрешено с логированием. WRITE — запрещено. | READY (design boundary) | Correction 4 |
| Network isolation | Legion не имеет маршрутов к banking DBs или internal compliance APIs | READY (design) | Correction 4 / ADR-103 |
| DLP implementation | NeMo Guardrails (NVIDIA, Apache 2.0) + LlamaFirewall + OS-sandbox (Landlock + seccomp) | PARTIAL (designed, not confirmed deployed) | Correction 4 |
| Telegram bot | Polling mode — no public IP required; 4096 char limit, 300s timeout | PARTIAL (option) | manus-legion-private-engine.md |

**Вывод B-2:** Internet-инструменты определены. DLP boundary задан архитектурно. Production DLP enforcement (NeMo Guardrails / LlamaFirewall) — `PARTIAL`.

---

### B-3. Web Interface

В Private Engine "web interface" = UI для взаимодействия operator с OpenManus API.
Это не customer-facing banking UI — это developer/operator shell.

| Параметр | Факт | Статус | Источник |
|----------|------|--------|---------|
| Option A | Open WebUI (self-hosted :3000, Docker): voice I/O, RAG, file artifacts | PARTIAL (option) | manus-legion-private-engine.md |
| Option B | LibreChat (Docker): Agent Builder UI, MCP-native, conversation forking, code exec | PARTIAL (option) | manus-legion-private-engine.md |
| Option C | AnythingLLM Desktop (AppImage): simplest no-Docker start, local LLM | PARTIAL (option) | manus-legion-private-engine.md |
| REST API | `POST http://localhost:8000/run/agent` + `GET http://localhost:8000/health` | PARTIAL (requires Phase 1 install) | RUNBOOK.md (artifact) |
| Selected option | [НЕИЗВЕСТНО] — оператор не указал какой UI вариант выбран для deploy | [НЕИЗВЕСТНО] | — |
| Browser automation web access | Playwright Chromium — агент сам открывает страницы как browser-use | PARTIAL (requires Playwright install) | manus-legion-private-engine.md |

**Вывод B-3:** Три варианта UI задокументированы. Выбор между ними — `[НЕИЗВЕСТНО]`, это HITL решение оператора.

---

### B-4. Mobile App

Mobile для Private Engine = внешний доступ к Legion API с мобильного устройства оператора.
Это НЕ customer banking app — это operator remote access.

| Параметр | Факт | Статус | Источник |
|----------|------|--------|---------|
| iOS client | Enchanted LLM (free, open-source): iOS 17.0+, Markdown/code rendering без truncation | PARTIAL (option) | manus-legion-private-engine.md |
| Android client | Open Mobile UI (React Native, official Open WebUI client, updated April 2026) | PARTIAL (option) | manus-legion-private-engine.md |
| External access (persistent) | Cloudflare Tunnel (free): `https://xxx-yyy.trycloudflare.com` — persistent URL, requires Cloudflare account | PARTIAL (option) | manus-legion-private-engine.md |
| External access (simple) | ngrok: simpler setup, free tier URL changes on restart | PARTIAL (option) | manus-legion-private-engine.md |
| Local Wi-Fi access | Прямой доступ к `192.168.x.x:8000` / `192.168.x.x:3000` без tunnel | READY (by default) | manus-legion-private-engine.md |
| Auth for mobile access | [НЕИЗВЕСТНО] — нет данных об auth/token для mobile → Legion API | [НЕИЗВЕСТНО] | — |
| SLA/latency target | [НЕИЗВЕСТНО] | [НЕИЗВЕСТНО] | — |

**Вывод B-4:** Mobile access options для operator remote defined. Tunnel setup и auth — `[НЕИЗВЕСТНО]`.

---

## SECTION C — Shared Constraints

Применяются к обоим engines безусловно.

| Invariant | Правило | Enforcement |
|-----------|---------|-------------|
| **I-71** (Single-writer) | Operator-only: git push, PR merge, git clone, install, systemctl enable/start | Canon (immutable) |
| **I-27** (HITL) | Agents PROPOSE, human DECIDES. Никакой autonomous write в banking. | HITL gates в LangGraph / services/hitl/ |
| **ADR-103** (DLP) | Banking Engine ↔ Legion = строгая data boundary. No PII / credentials / ledger write из Legion. | ADR-103 (canonical) |
| **I-24** (Audit trail) | Каждый write-action логируется (append-only). Banking zone: pgAudit + ClickHouse. | semgrep `banxe-audit-delete` |
| **I-01** (Decimal) | No float для денег — только `Decimal` (Python) / `Decimal(20,8)` (SQL). | semgrep `banxe-float-money` |
| **I-02** (Jurisdictions) | Blocked: RU/BY/IR/KP/CU/MM/AF/VE/SY | aml_thresholds.py |
| **Memory isolation** | Banking Qdrant (evo1) ≠ Legion Qdrant (local). Синхронизация только через human-approved export. | Correction 5 |
| **Source hierarchy** | LEVEL 0 Regulatory > LEVEL 1 ADR > LEVEL 2 BDSL fleet > LEVEL 3 Operational | Correction 6 |
| **`banxe-general` alias** | Зарезервирован для Banking Engine. NEVER в Private Engine config. | config.toml comment + RUNBOOK.md |
| **IPv4 only** | LiteLLM :4000 слушает на `0.0.0.0:4000` (IPv4). IPv6 `::1:4000` — refused. Использовать `127.0.0.1`. | Operator shell audit (confirmed) |

---

## SECTION D — Pointer Map

Для каждого capability layer — какие source docs покрывают его. Если layer не покрыт явно — помечен GAP.

### Pointer Map: Banking Engine

| Layer | Покрывающие документы | Gaps |
|-------|-----------------------|------|
| Model Backend | `emi-banxe-engine-v2-2026-07-09.md` §LangGraph / §Strands SDK; `Correction 7` §LangGraph canon; `litellm-config.v2.yaml` (20 aliases) | Default alias banking engine — GAP |
| Internet Access | `BANXE-Private-Legion-Engine-Otvety-na-otkrytye-voprosy-arkhitektury-2026-07-10.md` §isolation; `banxe-oss-free-agent-solutions-2026-07-10.md` §Adorsys / §MCP; `Correction 4` §boundary | Production firewall rules — GAP |
| Web Interface | `banxe-uxui-architecture-2026-07-10.md` (full UI stack); `emi-banxe-engine-v2-2026-07-09.md` §Whisper/Coqui | Production deployment URL — GAP |
| Mobile App | `banxe-uxui-architecture-2026-07-10.md` §React Native / §NativeWind / §SCA; `emi-banxe-intent-first-banking-2026-07-10.md` §Face ID | App store status, SLO — GAP |

### Pointer Map: Private Legion Engine

| Layer | Покрывающие документы | Gaps |
|-------|-----------------------|------|
| Model Backend | `manus-legion-private-engine.md` §[llm] schema; `litellm-config.v2.yaml` (aliases); `config.toml` (artifact); `Correction 1` §boundaries; `Correction 5` §Legion memory | [НЕИЗВЕСТНО] |
| Internet Access | `manus-legion-private-engine.md` §duckduckgo / §browser_use / §Telegram; `Correction 4` §DLP; `BANXE-Private-Legion-Engine-Otvety-na-otkrytye-voprosy-arkhitektury-2026-07-10.md` §isolation | NeMo Guardrails deploy status — GAP |
| Web Interface | `manus-legion-private-engine.md` §Open WebUI / §LibreChat / §AnythingLLM; `RUNBOOK.md` (artifact) §Phase 4 | Selected UI option — GAP (operator HITL) |
| Mobile App | `manus-legion-private-engine.md` §Enchanted / §Open Mobile UI / §Cloudflare Tunnel / §ngrok | Auth for mobile→Legion API — GAP; SLO — GAP |

---

## Open Items (не закрыты ни одним из источников)

| # | Item | Применимость |
|---|------|-------------|
| OI-1 | Banking Engine default LiteLLM alias — какой model используется по умолчанию? | Banking Engine A-1 |
| OI-2 | Production firewall/network policy для evo1/evo2 egress | Banking Engine A-2 |
| OI-3 | Banking Engine web app — production deployment URL и infra | Banking Engine A-3 |
| OI-4 | Mobile app — App Store / Play Store status; SLO targets | Banking Engine A-4 |
| OI-5 | Private Engine UI — operator selection: Open WebUI vs LibreChat vs AnythingLLM | Private Engine B-3 |
| OI-6 | Mobile access auth — token / auth method для operator remote → Legion :8000 | Private Engine B-4 |
| OI-7 | NeMo Guardrails + LlamaFirewall — confirmed deployed или только designed? | Both B-2 / ADR-103 |
| OI-8 | Temporal vs LangGraph — требует ADR перед выбором (Correction 7 §open item) | Banking Engine A-1 |

---

## References

| Документ | Путь |
|---------|------|
| Master two-engines analysis | `docs/architecture/two-engines-master-analysis-and-roadmap-canonical-2026-07-10.md` |
| Consultant corrections | `docs/sources/BANXE-Private-Legion-Engine-Otvety-Konsultanta-2026-07-10.md` |
| Open Q&A | `docs/sources/BANXE-Private-Legion-Engine-Otvety-na-otkrytye-voprosy-arkhitektury-2026-07-10.md` |
| Private Engine blueprint | `MetaClaw/docs/sources/manus-legion-private-engine.md` |
| UX/UI architecture | `MetaClaw/docs/sources/banxe-uxui-architecture-2026-07-10.md` |
| Engine v2 | `MetaClaw/docs/sources/emi-banxe-engine-v2-2026-07-09.md` |
| Intent-first banking | `MetaClaw/docs/sources/emi-banxe-intent-first-banking-2026-07-10.md` |
| OSS solutions | `MetaClaw/docs/sources/banxe-oss-free-agent-solutions-2026-07-10.md` |
| LiteLLM config | `MetaClaw/litellm/litellm-config.v2.yaml` |
| OpenManus config artifact | `wt/private-engine-openmanus/docs/ops/legion-private-engine/config.toml` |
| OpenManus RUNBOOK artifact | `wt/private-engine-openmanus/docs/ops/legion-private-engine/RUNBOOK.md` |
| ADR-103 DLP boundary | `docs/adr/ADR-103*.md` |
